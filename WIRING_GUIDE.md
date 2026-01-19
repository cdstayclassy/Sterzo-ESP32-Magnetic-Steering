# ESP32 Sterzo - Wiring Guide

## Components Needed

**Required:**
- ESP32 Development Board
- AS5600 Magnetic Rotary Position Sensor Module
- 6mm diameter disc magnet (3mm thick, diametrically magnetized)
- Jumper wires
- USB-C cable (for power/programming)

**Optional:**
- 3mm LED (any color) - for status indication
- 220Ω resistor (for LED)
- Momentary push button - for recenter function (mount on handlebars)

## Complete Wiring Diagram

```
                     ESP32
                  ┌─────────┐
                  │         │
AS5600 SDA ──────►│ GPIO21  │ (I2C Data)
AS5600 SCL ──────►│ GPIO22  │ (I2C Clock)
AS5600 VCC ──────►│ 3.3V    │
AS5600 GND ──────►│ GND     │
                  │         │
LED (+) ─[220Ω]──►│ GPIO2   │ (Status LED - OPTIONAL)
LED (-) ─────────►│ GND     │
                  │         │
Button ──────────►│ GPIO4   │ (Recenter Button - OPTIONAL)
Button ──────────►│ GND     │
                  │         │
USB-C ───────────►│ USB     │ (Power/Programming)
                  └─────────┘
```

## Pin-by-Pin Connections

### AS5600 Sensor → ESP32

| AS5600 Pin | ESP32 Pin | Description |
|------------|-----------|-------------|
| VCC        | 3.3V      | Power supply (NOT 5V!) |
| GND        | GND       | Ground |
| SDA        | GPIO 21   | I2C Data line |
| SCL        | GPIO 22   | I2C Clock line |

**Note:** Some AS5600 modules have additional pins (DIR, PGO, OUT) - these are not used and can be left unconnected.

### External LED → ESP32 (OPTIONAL)

| LED Connection | ESP32 Pin | Notes |
|----------------|-----------|-------|
| Anode (+, long leg) | 220Ω resistor → GPIO 2 | Use resistor! |
| Cathode (-, short leg) | GND | Ground |

**Important:** The 220Ω resistor is **required** to limit current and prevent damaging the LED or ESP32.

### Recenter Button → ESP32 (OPTIONAL)

| Button Connection | ESP32 Pin | Notes |
|-------------------|-----------|-------|
| One leg | GPIO 4 | No resistor needed (uses internal pullup) |
| Other leg | GND | Ground |

**Usage:** Press button to set current handlebar position as new center. Useful if the base gets bumped during a ride. LED will flash twice to confirm.

**Mounting tip:** Use a handlebar-mounted button for easy access while riding. Any momentary push button will work.

### Power

| Connection | ESP32 Pin | Notes |
|------------|-----------|-------|
| USB-C Cable | USB Port | Provides 5V power and programming interface |

## Step-by-Step Wiring Instructions

### 1. Power Off
- Ensure ESP32 is **NOT** connected to USB before wiring
- This prevents accidental shorts

### 2. Connect AS5600 Sensor

**a) Power connections:**
1. Connect AS5600 **VCC** to ESP32 **3.3V** (red wire recommended)
2. Connect AS5600 **GND** to ESP32 **GND** (black wire recommended)

**b) I2C connections:**
3. Connect AS5600 **SDA** to ESP32 **GPIO 21** (yellow/green wire)
4. Connect AS5600 **SCL** to ESP32 **GPIO 22** (orange/blue wire)

### 3. Connect External LED (Optional)

**a) Identify LED polarity:**
- **Anode (+)** = Long leg, goes to GPIO 2
- **Cathode (-)** = Short leg, goes to GND
- If legs are cut, look inside: smaller piece = anode

**b) Wire LED:**
1. Connect LED **anode (+)** to one end of 220Ω resistor
2. Connect other end of resistor to ESP32 **GPIO 2**
3. Connect LED **cathode (-)** to ESP32 **GND**

```
GPIO 2 ──[220Ω]──►|──── GND
                  LED
```

### 4. Connect Recenter Button (Optional)

**a) Wire button:**
1. Connect one leg of button to ESP32 **GPIO 4**
2. Connect other leg to ESP32 **GND**

```
GPIO 4 ──[Button]── GND
```

**No resistor needed** - the ESP32 uses its internal pullup resistor.

### 5. Double-Check Connections

Before powering on, verify:
- [ ] AS5600 VCC → ESP32 3.3V (NOT 5V!)
- [ ] AS5600 GND → ESP32 GND
- [ ] AS5600 SDA → ESP32 GPIO 21
- [ ] AS5600 SCL → ESP32 GPIO 22
- [ ] (If using LED) LED has 220Ω resistor in series
- [ ] (If using LED) LED polarity is correct (long leg to GPIO 2)
- [ ] (If using button) Button connected between GPIO 4 and GND
- [ ] No wires touching each other

### 6. Power On and Test

1. Connect USB-C cable to ESP32
2. Open Arduino IDE Serial Monitor (115200 baud)
3. You should see:
   ```
   Starting ESP32 Steering with AS5600!
   I2C initialized
   Checking AS5600 connection...
   AS5600 sensor detected!
   Magnet status: Detected
   ESP32 Steering ready!
   Status: OK - Sensor and magnet detected
   ```
4. If using LED: should turn on and start blinking
5. If using button: press it and LED will flash twice, Serial will show "Recentered!"

## LED Status Codes

### Normal Operation

| LED Behavior | Meaning |
|--------------|---------|
| Slow blink (1 sec on/off) | Waiting for Zwift/GTBikeV connection |
| Fast blink (0.5 sec on/off) | Connected to Zwift/GTBikeV - ready to use! |
| 2 quick flashes | Recenter button pressed - new center set |
| Solid on | Booting up / initializing |
| Off | Not powered or code not running |

### Error Codes

| LED Behavior | Meaning | Fix |
|--------------|---------|-----|
| 3 fast flashes, pause, repeat | Sensor not found | Check I2C wiring (SDA→GPIO21, SCL→GPIO22) |
| 4 fast flashes, pause, repeat | Magnet not detected | Check magnet placement over sensor |

## GPIO Pin Information

### Why GPIO 2?

GPIO 2 is chosen because:
- ✅ Safe to use on all ESP32 boards
- ✅ Can be used as output
- ✅ Often has built-in LED too
- ✅ Not used for I2C or other critical functions
- ✅ Accessible on most ESP32 dev boards

### Why NOT GPIO 21/22?

GPIO 21 and GPIO 22 are reserved for I2C communication with the AS5600 sensor and **cannot** be used for LED.

### Alternative Pins (Advanced)

If default pins are already in use, you can use these alternatives:
- GPIO 5, 12, 13, 14, 15, 16, 17, 18, 19, 23, 25, 26, 27, 32, 33

**To change LED pin:**
Edit line 22 in `ESP32Sterzo.ino`:
```cpp
#define EXTERNAL_LED_PIN 2  // Change to your desired GPIO number
```

**To change button pin:**
Edit line 23 in `ESP32Sterzo.ino`:
```cpp
#define CENTER_BUTTON_PIN 4  // Change to your desired GPIO number
```

**Don't use:** GPIO 21, 22 (I2C), GPIO 0, 1, 3 (boot/serial)

## Troubleshooting

### LED doesn't light up
- Check polarity (long leg to GPIO 2)
- Check resistor is connected
- Check LED is working (test with battery)
- Verify GPIO 2 connection

### LED is very dim
- Resistor value too high - try 150Ω instead of 220Ω
- LED voltage drop mismatch - try different LED

### LED is too bright or gets hot
- Resistor value too low - must use at least 150Ω
- No resistor - **NEVER** connect LED directly to GPIO!

### AS5600 not detected
- Check VCC is connected to 3.3V (NOT 5V!)
- Check SDA/SCL wires not swapped
- Check I2C address (should be 0x36)
- Try different jumper wires

### "Magnet too weak" or "Magnet too strong"
- Adjust distance between magnet and sensor
- Optimal gap: 1-3mm
- Magnet must be centered over sensor

### Recenter button doesn't work
- Check button is connected between GPIO 4 and GND
- Verify button works (use multimeter continuity test)
- Try a different GPIO pin and update code
- Check Serial Monitor for "Recentered!" message when pressed

## Physical Assembly

### Magnet Placement

The 6mm magnet should be:
1. **Centered** on the rotation axis
2. **2-3mm above** the AS5600 sensor chip
3. **Rotating** with the wheel/shaft
4. **Flat side parallel** to sensor surface

```
  [Rotating Part]
        |
    [Magnet] ← 6mm disc, centered
        ↕ 2-3mm gap
    [AS5600] ← Stationary, in base
        |
     [Base]
```

### LED Mounting

The 3mm LED fits into the 3.2mm hole in the front of the base:
1. Insert LED from inside
2. Route wires to ESP32
3. LED should be flush with or slightly recessed in hole
4. Secure with hot glue if needed

## Wiring Tips

1. **Use different colored wires** for easy identification:
   - Red = Power (3.3V)
   - Black = Ground
   - Yellow/Green = SDA
   - Blue/Orange = SCL

2. **Keep wires short** to reduce noise and clutter

3. **Route wires neatly** along edges to avoid pinching

4. **Label connections** with tape if using same-colored wires

5. **Test continuity** with multimeter before powering on

6. **Take photos** of your wiring before closing the case

## Safety Notes

⚠️ **Important:**
- AS5600 is a **3.3V device** - connecting to 5V may damage it
- Always use a resistor with LED - direct connection can damage ESP32
- Double-check polarity before powering on
- Disconnect power before making wiring changes

## Next Steps

After wiring is complete:
1. Upload `ESP32Sterzo.ino` to ESP32
2. Open Serial Monitor at 115200 baud
3. Verify sensor detection
4. Test LED blinking
5. Place magnet and test rotation
6. Connect to Zwift and enjoy!

## Questions?

If you encounter issues, check Serial Monitor output at 115200 baud for diagnostic messages.
