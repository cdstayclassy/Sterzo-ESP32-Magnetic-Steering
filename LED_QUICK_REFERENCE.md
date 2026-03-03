# External LED - Quick Reference

## Hardware Hookup

### What You Need
- 3mm LED (any color - red, green, blue, yellow, etc.)
- 220Ω resistor (red-red-brown or red-red-black-black-brown)
- 2x jumper wires

### Wiring (Simple!)

```
ESP32 GPIO 2 ──[220Ω resistor]──►|──── ESP32 GND
                                LED
```

**Step-by-step:**
1. LED long leg (+) → one end of 220Ω resistor
2. Other end of resistor → ESP32 GPIO 2
3. LED short leg (-) → ESP32 GND

### Pin Location

**GPIO 2** is located on your ESP32 board - check the pinout for your specific model:
- Usually labeled "GPIO2", "D2", or "IO2"
- Common ESP32 Dev boards have it near the top

**GND** - Any ground pin on the ESP32

## Code Support

✅ **The code already supports this!**

The LED functionality is built into `Sterzo-ESP32-Magnetic-Steering.ino`:
- `#define EXTERNAL_LED_PIN 2` - Pin definition
- `#define LED_ACTIVE_LOW false` - Set to `true` for ESP32-C3 Super Mini (onboard LED is active-low)
- `LED_ON` / `LED_OFF` macros automatically handle inverted logic when `LED_ACTIVE_LOW` is enabled

**No code changes needed** - just wire it up and upload!

### ESP32-C3 Super Mini Users

If you are using an **ESP32-C3 Super Mini**, the onboard LED uses active-low logic (LOW = on, HIGH = off). Change this line in `Sterzo-ESP32-Magnetic-Steering.ino`:
```cpp
#define LED_ACTIVE_LOW true  // Set to true for ESP32-C3 onboard LED
```

## LED Status Meanings

### Normal Operation

| Blink Pattern | Meaning |
|---------------|---------|
| Slow blink (1 sec on/off) | Ready, waiting for Zwift/GTBikeV connection |
| Fast blink (0.5 sec on/off) | Connected to Zwift/GTBikeV! |
| Solid on | Booting up |
| Off | Not powered or code issue |

### Error Codes

| Flash Pattern | Meaning | Fix |
|---------------|---------|-----|
| 3 fast flashes, pause, repeat | Sensor not found | Check I2C wiring (SDA→GPIO21, SCL→GPIO20) |
| 4 fast flashes, pause, repeat | Magnet not detected | Check magnet placement over sensor |

**Error flash timing:** 100ms on, 100ms off for each flash, then 1.5 second pause before repeating.

## Testing

1. Upload `Sterzo-ESP32-Magnetic-Steering.ino` to ESP32
2. Connect LED as shown above
3. LED should turn on solid for ~2 seconds during boot
4. If sensor/magnet OK → slow blinking (waiting for connection)
5. If error → 3 or 4 fast flashes repeating (see Error Codes above)
6. When you pair with Zwift/GTBikeV → fast blinking!

## Troubleshooting

### LED doesn't turn on at all
- ❌ Check polarity: Long leg to resistor, short leg to GND
- ❌ Check resistor is connected
- ❌ Verify GPIO 2 is connected
- ❌ Try a different LED (might be dead)

### LED very dim
- Resistor too high - try 150Ω instead
- Wrong LED type - use standard 3mm LED

### LED too bright or gets warm
- ⚠️ Resistor too low or missing - **MUST** use 220Ω minimum
- Never connect LED directly to GPIO without resistor!

### Built-in LED works but external doesn't
- Check GPIO 2 connection
- Try different GPIO pin and update code (line 22)

## Alternative Pins

Don't like GPIO 2? You can use these instead:

**Safe alternatives:** GPIO 4, 5, 12, 13, 14, 15, 16, 17, 18, 19, 22, 23, 25, 26, 27, 32, 33

**Change in code:**
Edit line 22 in `Sterzo-ESP32-Magnetic-Steering.ino`:
```cpp
#define EXTERNAL_LED_PIN 2  // Change to your desired pin
```

**Don't use:** GPIO 20, 21 (I2C), GPIO 0, 1, 3 (boot/serial)

## Resistor Value Guide

| Resistor | Brightness | Notes |
|----------|------------|-------|
| 100Ω | Very bright | May damage LED over time |
| 150Ω | Bright | Good for dim environments |
| **220Ω** | **Normal** | **Recommended** |
| 330Ω | Dimmer | Good for bright environments |
| 470Ω | Very dim | Hard to see in daylight |

## Multiple LEDs?

Want red for disconnected, green for connected?

**You'll need to modify the code** - but it's easy:

1. Add second LED definition:
```cpp
#define DISCONNECTED_LED_PIN 2  // Red LED
#define CONNECTED_LED_PIN 4     // Green LED
```

2. In setup(), initialize both:
```cpp
pinMode(DISCONNECTED_LED_PIN, OUTPUT);
pinMode(CONNECTED_LED_PIN, OUTPUT);
```

3. In loop(), control separately:
```cpp
if (deviceConnected) {
  digitalWrite(CONNECTED_LED_PIN, ledState);    // Blink green
  digitalWrite(DISCONNECTED_LED_PIN, LOW);      // Red off
} else {
  digitalWrite(DISCONNECTED_LED_PIN, ledState); // Blink red
  digitalWrite(CONNECTED_LED_PIN, LOW);         // Green off
}
```

Wire each LED with its own 220Ω resistor to different GPIO pins!

## Why 220Ω?

ESP32 GPIO pins output 3.3V and can safely provide ~40mA max (20mA recommended).

**Math:**
- LED forward voltage: ~2V (typical red LED)
- Remaining voltage: 3.3V - 2V = 1.3V
- Desired current: 5-10mA (safe for LED and ESP32)
- Resistor needed: 1.3V ÷ 0.01A = 130Ω minimum

**220Ω gives:** 1.3V ÷ 220Ω = 5.9mA (safe, bright enough)

## Quick Checks ✓

Before powering on:
- [ ] 220Ω resistor in series with LED
- [ ] LED polarity correct (long leg to GPIO 2)
- [ ] All connections secure
- [ ] No exposed wires touching each other
- [ ] Code uploaded to ESP32

Power on and enjoy your status LED! 💡
