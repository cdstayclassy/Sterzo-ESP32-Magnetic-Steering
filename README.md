# Build your own bike trainer steering device with AS5600 magnetic sensor!

A DIY bike trainer for apps such as Zwift or GTBikeV, similar to the Sterzo steering device. This project, built using an ESP32 and AS5600 magnetic rotary position sensor, allows you to add realistic steering control to your indoor cycling experience using a rotating handlebar mechanism with magnetic angle detection.

Original code forked from stefaandesmet2003/ESP32Sterzo (youtube video: https://youtu.be/6pxeI_YN5Yk)

**Update 01/2026**: Converted from touch buttons in the forked project to AS5600 magnetic rotary sensor for smooth, continuous steering control.

## Features

- Smooth, continuous steering control using magnetic rotary position sensor
- Bluetooth Low Energy (BLE) communication with Zwift and GTBikeV
- Auto-calibration at startup
- Handlebar-mounted recenter button for mid-ride calibration
- ±40° steering range (Zwift standard)
- Configurable dead zone for easier straight-line riding
- Adjustable sensitivity and update rate
- LED status indicator with error codes for easy troubleshooting
- All settings easily configurable at top of code file

## Hardware Required

**Required:**
- **ESP32 Development Board** (any variant with I2C support)
- **AS5600 Magnetic Rotary Position Sensor** - 12-bit contactless angle measurement
- **Diametrically magnetized magnet** (typically included with AS5600 or purchase separately)
  - Recommended: 6mm diameter x 3mm thickness
- **Mounting mechanism** for handlebar rotation (DIY - see below)
- **Jumper wires** - for connections
- **USB cable** - for power and programming

**Optional:**
- **3-5mm LED and 220Ω resistor** (any color) - for status indication
- **Momentary push button** - for recenter function (mount on handlebars)

## Wiring Connections

### AS5600 Sensor

| AS5600 Pin | ESP32 Pin | Description |
|------------|-----------|-------------|
| VCC | 3.3V | Power supply (use 3.3V, NOT 5V) |
| GND | GND | Ground |
| SDA | GPIO 21 | I2C Data (default) |
| SCL | GPIO 22 | I2C Clock (default) |

### External LED - OPTIONAL (Status Indicator)

| LED Connection | ESP32 Pin | Description |
|----------------|-----------|-------------|
| LED Anode (+, long leg) | GPIO 2 | Via 220Ω resistor |
| LED Cathode (-, short leg) | GND | Ground |

### Recenter Button - OPTIONAL

| Button Connection | ESP32 Pin | Description |
|-------------------|-----------|-------------|
| One leg | GPIO 4 | No resistor needed |
| Other leg | GND | Ground |

### Quick Wiring Summary

```
AS5600 SDA  → ESP32 GPIO 21
AS5600 SCL  → ESP32 GPIO 22
AS5600 VCC  → ESP32 3.3V
AS5600 GND  → ESP32 GND

LED (+)     → 220Ω resistor → ESP32 GPIO 2  (OPTIONAL)
LED (-)     → ESP32 GND

Button      → ESP32 GPIO 4 and GND          (OPTIONAL)
```

**For detailed wiring diagrams and step-by-step instructions, see [WIRING_GUIDE.md](WIRING_GUIDE.md)**

**Magnet placement**: Position the diametrically magnetized magnet 2-3mm directly above the AS5600 chip, centered on the sensor. The magnet should rotate freely with your steering mechanism.

## Software Setup

### Required Libraries

Install the following libraries through Arduino IDE Library Manager:

1. **ESP32 Board Support** - Install via Board Manager
2. **AS5600 by Rob Tillaart** - For magnetic sensor communication

### Installation Steps

1. Clone or download this repository
2. Open `ESP32Sterzo.ino` in Arduino IDE
3. Install required libraries (see above)
4. Select your ESP32 board from Tools > Board
5. Select the correct COM port from Tools > Port
6. Upload the sketch to your ESP32

## Usage

1. **Initial Calibration**: Power on the ESP32 with your steering mechanism in the **center position**. The device will automatically calibrate this as the center point.
2. **Pairing with Zwift**:
   - Open Zwift on your device
   - Go to Settings > Connections
   - Look for your device name (default: "ESP32 Steering") in the Controllable devices
   - Pair the device
3. **Steering**: Rotate your handlebars left/right to steer in Zwift
4. **Recentering** (if button installed): If the base gets bumped during a ride, center your handlebars and press the recenter button. LED will flash twice to confirm.

## LED Status

**Normal operation:**
- **Slow blink (1 second)**: Device ready, waiting for connection
- **Fast blink (0.5 seconds)**: Connected to Zwift/GTBikeV
- **2 quick flashes**: Recenter button pressed - new center position set

**Error codes:**
- **3 fast flashes, then pause**: Sensor not found - check I2C wiring
- **4 fast flashes, then pause**: Magnet not detected - check magnet placement

## Configuration

All settings are located at the top of `ESP32Sterzo.ino` for easy customization:

```cpp
// Pin definitions
#define EXTERNAL_LED_PIN 2   // GPIO for status LED
#define CENTER_BUTTON_PIN 4  // GPIO for recenter button

// Device configuration
#define BLE_DEVICE_NAME "ESP32 Steering"  // Bluetooth device name shown to apps

// Steering configuration
#define STEERING_DEAD_ZONE 2.0      // Degrees from center that count as "straight"
#define STEERING_SENSITIVITY 750.0  // Raw sensor units for full steering range
#define STEERING_UPDATE_MS 67       // Milliseconds between BLE updates
```

### Settings explained:

| Setting | Description | Adjust if... |
|---------|-------------|--------------|
| `EXTERNAL_LED_PIN` | GPIO pin for status LED | Using a different pin |
| `CENTER_BUTTON_PIN` | GPIO pin for recenter button | Using a different pin |
| `BLE_DEVICE_NAME` | Name shown in Zwift/GTBikeV pairing | You want a custom name |
| `STEERING_DEAD_ZONE` | Degrees near center that report as straight | Hard to ride straight (increase) or feels unresponsive (decrease) |
| `STEERING_SENSITIVITY` | How much physical rotation for full steering | Too twitchy (increase) or too sluggish (decrease) |
| `STEERING_UPDATE_MS` | How often steering data is sent | Laggy response (decrease) or connection issues (increase) |

### Sensitivity examples:
- `512` = ~45° physical rotation for full ±40° steering (very sensitive)
- `750` = ~66° physical rotation for full ±40° steering (moderate)
- `1024` = ~90° physical rotation for full ±40° steering (less sensitive)

### Update rate examples:
- `50` = 20 updates/sec (very responsive)
- `67` = 15 updates/sec (smooth)
- `100` = 10 updates/sec (responsive)
- `1000` = 1 update/sec (laggy)

## Troubleshooting

**AS5600 sensor not detected:**
- Check I2C wiring connections (SDA to GPIO 21, SCL to GPIO 22)
- Verify the sensor has power (3.3V or 5V)
- Ensure magnet is positioned 2-3mm above the sensor
- Check Serial Monitor for error messages

**Steering not responding in Zwift:**
- Ensure device is paired in Zwift Connections
- Check that LED is blinking fast (connected state)
- Verify center calibration by restarting with handlebars centered

**Erratic steering behavior:**
- Check magnet alignment and distance from sensor
- Ensure magnet is diametrically magnetized
- Try adjusting sensitivity setting
- Verify no other magnets are nearby interfering with sensor

## Building the Physical Mechanism

The code handles the sensor input, but you'll need to build a physical mounting mechanism that:

1. Allows handlebars to rotate left/right
2. Mounts the AS5600 sensor in a fixed position
3. Attaches the magnet to the rotating handlebar shaft
4. Keeps the magnet centered over the sensor at 2-3mm distance

Common approaches:
- 3D printed handlebar mount with bearing
- Modified bike stem with rotation mechanism
- PVC pipe pivot mount

## How It Works

The AS5600 sensor uses a magnet's magnetic field to determine angular position with 12-bit resolution (0-4095 counts = 0-360°). The ESP32:

1. Reads the raw angle from the AS5600 via I2C
2. Calculates the difference from the calibrated center position
3. Handles wraparound for seamless 360° operation
4. Maps the physical rotation to Zwift's ±40° steering range
5. Sends steering data via BLE using the Sterzo protocol

## Technical Details

- **BLE Service UUID**: `347b0001-7635-408b-8918-8ff3949ce592`
- **Steering angle characteristic**: `347b0030-7635-408b-8918-8ff3949ce592`
- **Update rate**: Configurable (default: 15 Hz / 67ms)
- **Steering range**: ±40° (Zwift standard)
- **Sensor resolution**: 0.087° (12-bit, 4096 positions)

## Issues & Contributions

Feel free to raise an issue if you encounter problems or have suggestions for improvements!