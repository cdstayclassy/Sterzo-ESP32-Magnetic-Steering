/*
 * Hook up an AS5600 magnetic rotary position sensor to ESP32 via I2C
 * AS5600 connections: SDA to GPIO 21, SCL to GPIO 22 (default ESP32 I2C pins)
 * Place magnet on rotating shaft - sensor reads angle from 0-360°
 * Standard settings for ESP32 are used for compile & download
 * The steering angle is mapped from sensor rotation and notified to Zwift
 * The steering angle is notified to the BLE client (Zwift) every second, and then reset.

 * char 30  : angle notifications
 * char 31  : ZWIFT -> STERZO
 * char 32 : STERZO -> ZWIFT
 */

#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <BLE2902.h>
#include <Wire.h>
#include <AS5600.h>

// Pin definitions
#define EXTERNAL_LED_PIN 2   // GPIO 2 for external status LED
#define CENTER_BUTTON_PIN 4  // GPIO 4 for recenter button (connect button between pin and GND)

// Device configuration
#define BLE_DEVICE_NAME "ESP32 Steering"  // Bluetooth device name shown to apps

// Steering configuration
#define STEERING_DEAD_ZONE 1.0      // Degrees from center that count as "straight"
#define STEERING_SENSITIVITY 768.0  // Raw sensor units for full steering range
                                    // Lower = more sensitive, Higher = less sensitive
                                    // 512 = ~45° physical rotation for full ±40° steering
                                    // 700 = ~62° physical rotation for full ±40° steering
                                    // 1024 = ~90° physical rotation for full ±40° steering
#define STEERING_UPDATE_MS 60       // Milliseconds between BLE updates
                                    // 1000 = 1 update/sec (laggy)
                                    // 100 = 10 updates/sec (responsive)
                                    // 50 = 20 updates/sec (very responsive)

#define STERZO_SERVICE_UUID "347b0001-7635-408b-8918-8ff3949ce592"
//#define CHAR12_UUID         "347b0012-7635-408b-8918-8ff3949ce592" // not needed for Zwift
//#define CHAR13_UUID         "347b0013-7635-408b-8918-8ff3949ce592" // not needed for Zwift
#define CHAR14_UUID         "347b0014-7635-408b-8918-8ff3949ce592"
//#define CHAR19_UUID         "347b0019-7635-408b-8918-8ff3949ce592" // not needed for Zwift
#define CHAR30_UUID         "347b0030-7635-408b-8918-8ff3949ce592"
#define CHAR31_UUID         "347b0031-7635-408b-8918-8ff3949ce592"
#define CHAR32_UUID         "347b0032-7635-408b-8918-8ff3949ce592"

BLEServer *pServer;
BLEService *pSvcSterzo;
BLECharacteristic *pChar14;
BLECharacteristic *pChar30;
BLECharacteristic *pChar31;
BLECharacteristic *pChar32;
BLE2902 *p2902Char14;
BLE2902 *p2902Char30;
BLE2902 *p2902Char32;

bool deviceConnected = false;
bool challengeOK = false;
bool ind32On = false;
float steeringAngle = 0.0;

AS5600 as5600;
uint16_t centerPosition = 0;  // Center position calibration value
bool sensorReady = false;

// Error codes for LED indication
// 0 = No error
// 1 = Sensor not found (3 fast flashes)
// 2 = Magnet not detected (4 fast flashes)
uint8_t errorCode = 0;

static uint32_t rotate_left32 (uint32_t value, uint32_t count) {
    const uint32_t mask = (CHAR_BIT * sizeof (value)) - 1;
    count &= mask;
    return (value << count) | (value >> (-count & mask));
}

static uint32_t hashed(uint64_t seed) {
    uint32_t ret = (seed + 0x16fa5717);
    uint64_t rax = seed * 0xba2e8ba3;
    uint64_t eax = (rax >> 35) * 0xb;
    uint64_t ecx = seed - eax;
    uint32_t edx = rotate_left32(seed, ecx & 0x0F);
    ret ^= edx;
    return ret;
}

static void bleNotifySteeringAngle() {
  // steeringAngle = float cast in 4 bytes
  if (1 /*char30.subscribed()*/) { //-> dit bestaat precies niet voor esp32??
    pChar30->setValue((uint8_t *)&steeringAngle,4);
    pChar30->notify();
    Serial.print("ntf angle ");Serial.println(steeringAngle);
    steeringAngle = 0.0;
  }
}

class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
      Serial.println("a device connected!");
    };

    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
      Serial.println("lost connection!");
    }
};

// if Zwift writes 0x310, we send a challenge on char32
class char31Callbacks: public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic* pCharacteristic) {
    String val = pCharacteristic->getValue();
    Serial.print("char31EventHandler : ");
    for (int i=0;i<val.length();i++){
      Serial.print(val[i],HEX);
      Serial.print('-');
    }
    Serial.println();
    
    if ((val[0] == 0x03) && (val[1] == 0x10)) {
      uint8_t challenge[] = {0x03,0x10,0x12,0x34}; //<2024 {0x03,0x10,0x4a,0x89}
      Serial.println("char31EventHandler : got 0x310!");
      pChar32->setValue(challenge,4);
      pChar32->indicate();
    }
    else if ((val[0] == 0x03) && (val[1] == 0x11)) {
      unsigned char fakeData[] = {0x03,0x11,0xff, 0xff};
      Serial.println("char31EventHandler : got 0x311!");
      challengeOK = true;
      pChar32->setValue(fakeData,4);
      pChar32->indicate();
    }

		else if ((val[0] == 0x03) && (val[1] == 0x12)) {
			uint32_t seed = val[5] << 24;
			seed |= val[4] << 16;
			seed |= val[3] << 8;
			seed |= val[2];
			uint32_t password = hashed(seed);
      Serial.print("char31EventHandler : got 0x312! seed = ");Serial.println(seed,HEX);

			uint8_t response[6];
			response[0] = 0x03;
			response[1] = 0x12;
			response[5] = (password & 0xFF000000 ) >> 24;
			response[4] = (password & 0x00FF0000 ) >> 16;
			response[3] = (password & 0x0000FF00 ) >> 8;
			response[2] = (password & 0x000000FF );
      pChar32->setValue(response,6);
      pChar32->indicate();

		} 
    else if ((val[0] == 0x03) && (val[1] == 0x13)) {
      Serial.println("char31EventHandler : got 0x313!");
			uint8_t response[3];
			response[0] = 0x03;
			response[1] = 0x13;
			response[2] = 0xFF;
      pChar32->setValue(response,3);
      pChar32->indicate();
      challengeOK = true; // BLE_CUS_START_SENDING_STEERING_DATA
    }
  } // onWrite

  void onRead(BLECharacteristic* pCharacteristic) {
    Serial.println("char31EventHandler onRead, doing nothing!");
  }
}; // char31Callbacks

// dummy for test to see if zwift comes here
class char32Callbacks: public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic* pCharacteristic) {
    Serial.println("char32EventHandler onWrite, doing nothing!");
  }

  void onRead(BLECharacteristic* pCharacteristic) {
    Serial.println("char32EventHandler onRead, doing nothing!");
  }
}; // char32Callbacks

class char32Desc2902Callbacks:public BLEDescriptorCallbacks {
  void onWrite(BLEDescriptor* pDescriptor) {
    uint8_t *value = pDescriptor->getValue();
    //size_t descLength = Descriptor->getLength();
    Serial.print("char32 desc 2902 written : ");Serial.println(value[0]);
    ind32On = true;
  }
};

void setup() {
  Serial.begin(115200);
  Serial.print("Starting ");
  Serial.print(BLE_DEVICE_NAME);
  Serial.println(" with AS5600!");

  // Initialize LEDs
  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(EXTERNAL_LED_PIN, OUTPUT);
  digitalWrite(LED_BUILTIN, HIGH);
  digitalWrite(EXTERNAL_LED_PIN, HIGH);  // Turn on external LED during startup

  // Initialize recenter button (uses internal pullup, button connects to GND)
  pinMode(CENTER_BUTTON_PIN, INPUT_PULLUP);

  // Initialize I2C for AS5600
  Wire.begin();
  Serial.println("I2C initialized");

  // Try initialization without direction pin first
  as5600.begin();
  as5600.setDirection(AS5600_CLOCK_WISE);  // Set rotation direction
  delay(100);  // Give sensor time to initialize

  Serial.print("Checking AS5600 connection... ");

  // Check if AS5600 is connected
  if (as5600.isConnected()) {
    Serial.println("AS5600 sensor detected!");
    sensorReady = true;

    // Check magnet status register (informational only)
    int magnetStatus = as5600.readStatus();
    Serial.print("Magnet status register: 0x");
    Serial.print(magnetStatus, HEX);
    Serial.print(" - ");
    if (magnetStatus & 0x20) Serial.print("Too strong ");
    if (magnetStatus & 0x10) Serial.print("Too weak ");
    if (magnetStatus & 0x08) Serial.print("Detected ");
    Serial.println();

    // Read initial center position for calibration
    delay(100);
    centerPosition = as5600.rawAngle();
    Serial.print("Center position set to: ");
    Serial.println(centerPosition);

    // Practical magnet detection: check if we get valid, consistent readings
    // Take a few readings and verify they're stable (not random noise)
    delay(50);
    uint16_t reading1 = as5600.rawAngle();
    delay(50);
    uint16_t reading2 = as5600.rawAngle();
    int16_t diff = abs((int16_t)reading1 - (int16_t)reading2);

    Serial.print("Stability check: ");
    Serial.print(reading1);
    Serial.print(" vs ");
    Serial.print(reading2);
    Serial.print(" (diff: ");
    Serial.print(diff);
    Serial.println(")");

    // If readings are valid (0-4095) and stable (not jumping around wildly), magnet is OK
    if (reading1 < 4096 && reading2 < 4096 && diff < 100) {
      errorCode = 0;  // No error - sensor working properly
      Serial.println("Magnet OK - readings are stable");
    } else {
      errorCode = 2;  // Magnet issue (4 flashes)
      Serial.println("Warning: Unstable readings - check magnet position");
    }
  } else {
    Serial.println("FAILED!");
    Serial.println("AS5600 sensor not responding to isConnected() check.");
    Serial.println("Attempting to read raw angle anyway...");

    // Try to read raw angle directly even if isConnected() fails
    uint16_t testAngle = as5600.rawAngle();
    Serial.print("Raw angle reading: ");
    Serial.println(testAngle);

    if (testAngle > 0 && testAngle < 4096) {
      Serial.println("Sensor appears to be working despite isConnected() failure!");
      sensorReady = true;
      centerPosition = testAngle;
      errorCode = 0;  // If we can read angles, it's working
    } else {
      Serial.println("Sensor not responding. Check wiring and magnet placement.");
      sensorReady = false;
      errorCode = 1;  // Sensor not found (3 flashes)
    }
  }

  BLEDevice::init(BLE_DEVICE_NAME);
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());
  //pSvcSterzo = pServer->createService("347b0001-7635-408b-8918-8ff3949ce592");
  pSvcSterzo = pServer->createService(BLEUUID(STERZO_SERVICE_UUID));
  pChar14 = pSvcSterzo->createCharacteristic(CHAR14_UUID,BLECharacteristic::PROPERTY_NOTIFY); // 1 byte 0xFF, doet niets
  pChar30 = pSvcSterzo->createCharacteristic(CHAR30_UUID,BLECharacteristic::PROPERTY_NOTIFY); // 4 bytes steering angle
  pChar31 = pSvcSterzo->createCharacteristic(CHAR31_UUID,BLECharacteristic::PROPERTY_WRITE); // zwift writes 4 bytes
  pChar32 = pSvcSterzo->createCharacteristic(CHAR32_UUID,BLECharacteristic::PROPERTY_INDICATE); // 4 bytes challenge

  p2902Char14 = new BLE2902();
  p2902Char30 = new BLE2902();
  p2902Char30->setNotifications(true);
  p2902Char32 = new BLE2902();
  p2902Char32->setCallbacks(new char32Desc2902Callbacks());
  pChar14->addDescriptor(p2902Char14);
  pChar30->addDescriptor(p2902Char30);
  pChar32->addDescriptor(p2902Char32);

  // initial values
  uint8_t defaultValue[4] = {0x0,0x0,0x0,0x0};
  pChar30->setValue(defaultValue,4); // default angle = 0
  defaultValue[0] = 0xFF; // fill other characteristics with a default 0xFF
  pChar14->setValue(defaultValue,1);
  pChar31->setValue(defaultValue,4);
  uint8_t challenge[] = {0x03,0x10,0x12, 0x34}; //<2024 {0x03,0x10,0x4a, 0x89};
  pChar32->setValue(challenge,4);

  pChar31->setCallbacks(new char31Callbacks());
  pChar32->setCallbacks(new char32Callbacks()); // 2024 for test only TODO REMOVE

  pSvcSterzo->start();
  // BLEAdvertising *pAdvertising = pServer->getAdvertising();  // this still is working for backward compatibility
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(STERZO_SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);  // functions that help with iPhone connections issue
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();
  Serial.print(BLE_DEVICE_NAME);
  Serial.println(" ready!");

  // Print error code status
  if (errorCode == 0) {
    Serial.println("Status: OK - Sensor and magnet detected");
    Serial.println("LED: Slow blink = waiting for Zwift, Fast blink = connected");
  } else if (errorCode == 1) {
    Serial.println("ERROR: Sensor not found!");
    Serial.println("LED: 3 fast flashes = sensor not found");
  } else if (errorCode == 2) {
    Serial.println("ERROR: Magnet not detected!");
    Serial.println("LED: 4 fast flashes = magnet not detected");
  }
}

uint32_t bleNotifyMillis;
uint32_t challengeMillis;
uint32_t blinkMillis;
uint32_t errorFlashMillis;
uint32_t lastRecenterMillis = 0;
uint8_t errorFlashCount = 0;
bool errorFlashState = false;
bool inErrorFlashSequence = false;

void loop() {

  uint32_t blinkInterval;

  // LED status indication:
  // - No error: Slow blink (1000ms) = Not connected, Fast blink (500ms) = Connected
  // - Error code 1 (sensor not found): 3 fast flashes, then pause
  // - Error code 2 (magnet not detected): 4 fast flashes, then pause

  if (errorCode > 0) {
    // Error flash pattern
    uint8_t flashCount = (errorCode == 1) ? 3 : 4;  // 3 flashes for sensor, 4 for magnet

    if (!inErrorFlashSequence) {
      // Start a new flash sequence
      inErrorFlashSequence = true;
      errorFlashCount = 0;
      errorFlashState = false;
      errorFlashMillis = millis();
    }

    uint32_t elapsed = millis() - errorFlashMillis;

    if (errorFlashCount < flashCount * 2) {
      // During flash sequence (100ms on, 100ms off per flash)
      if (elapsed > 100) {
        errorFlashState = !errorFlashState;
        digitalWrite(LED_BUILTIN, errorFlashState);
        digitalWrite(EXTERNAL_LED_PIN, errorFlashState);
        errorFlashMillis = millis();
        errorFlashCount++;
      }
    } else {
      // Pause after flashes (1500ms)
      digitalWrite(LED_BUILTIN, LOW);
      digitalWrite(EXTERNAL_LED_PIN, LOW);
      if (elapsed > 1500) {
        inErrorFlashSequence = false;  // Restart sequence
      }
    }
  } else {
    // Normal operation - blink to show connection status
    // Slow blink (1000ms) = Not connected to Zwift
    // Fast blink (500ms) = Connected to Zwift
    blinkInterval = 1000;
    if (deviceConnected) {
      blinkInterval = 500;
    }
    if ((millis() - blinkMillis) > blinkInterval) {
      bool ledState = !digitalRead(LED_BUILTIN);
      digitalWrite(LED_BUILTIN, ledState);
      digitalWrite(EXTERNAL_LED_PIN, ledState);  // Mirror state to external LED
      blinkMillis = millis();
    }
  }

  // Check recenter button (button pressed = LOW due to INPUT_PULLUP)
  if (sensorReady && digitalRead(CENTER_BUTTON_PIN) == LOW) {
    // Debounce: only allow recenter every 500ms
    if (millis() - lastRecenterMillis > 500) {
      lastRecenterMillis = millis();

      // Set current position as new center
      centerPosition = as5600.rawAngle();
      Serial.print("Recentered! New center position: ");
      Serial.println(centerPosition);

      // Visual feedback: 2 quick flashes
      for (int i = 0; i < 2; i++) {
        digitalWrite(LED_BUILTIN, HIGH);
        digitalWrite(EXTERNAL_LED_PIN, HIGH);
        delay(100);
        digitalWrite(LED_BUILTIN, LOW);
        digitalWrite(EXTERNAL_LED_PIN, LOW);
        delay(100);
      }
    }
  }

  // Read AS5600 sensor and calculate steering angle
  if (sensorReady) {
    uint16_t rawAngle = as5600.rawAngle();  // 0-4095 (12-bit)

    // Calculate angle difference from center position
    int16_t angleDiff = (int16_t)rawAngle - (int16_t)centerPosition;

    // Handle wraparound (e.g., if center is at 4000 and current is at 100)
    if (angleDiff > 2048) {
      angleDiff -= 4096;
    } else if (angleDiff < -2048) {
      angleDiff += 4096;
    }

    // Map angle difference to steering range (-40 to +40 degrees)
    float mappedAngle = (float)angleDiff / STEERING_SENSITIVITY * 40.0;

    // Limit to Zwift steering range
    if (mappedAngle > 40.0) mappedAngle = 40.0;
    if (mappedAngle < -40.0) mappedAngle = -40.0;

    // Apply dead zone - angles within ±STEERING_DEAD_ZONE are treated as straight
    if (mappedAngle > -STEERING_DEAD_ZONE && mappedAngle < STEERING_DEAD_ZONE) {
      mappedAngle = 0.0;
    }

    steeringAngle = mappedAngle;
  }
  // steering angle will be reset after each BLE-notify

  /*
  // alt : manually activate char32 indications, not waiting for zwift to do this
  if (deviceConnected && (!p2902Char32->getIndications())) {
    Serial.println("manually enabling char32 indications");
    p2902Char32->setIndications(true);
    challengeMillis = millis();
    ind32On = true;
  }
  */

  // if Zwift subscribes to the notifications, we send the initial challenge on char32
  // 2024 : put in a retry every 5 seconds until challengeOK, but zwift doesn't seem to send anything on char 31
  if (deviceConnected && ind32On && !challengeOK && ((millis() - challengeMillis) > 5000)) { 
    challengeMillis = millis();
    Serial.println("sending initial challenge on char32");
    uint8_t challenge[] = {0x03,0x10,0x12,0x34}; //<2024 {0x03,0x10,0x4a, 0x89};
    pChar32->setValue(challenge,4);
    pChar32->indicate();
  }

  // challengeOK remains false because zwift doesn't seem to send anything on char 31
  // so for workaround we start sending steering angles as soon as zwift connects, and strangely enough that works
  //if (deviceConnected && challengeOK) { 
  if (deviceConnected) {
    if (millis() - bleNotifyMillis > STEERING_UPDATE_MS) {
      bleNotifySteeringAngle ();
      bleNotifyMillis = millis();
    }
  }
} // loop
