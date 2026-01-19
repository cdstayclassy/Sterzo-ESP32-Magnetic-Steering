# Steering Controller 3D Model

A fully parametric OpenSCAD enclosure for the ESP32 Sterzo steering controller. This design houses an ESP32 microcontroller and AS5600 magnetic rotation sensor to detect steering input from a bicycle wheel.

Coming soon: Customizable 3d printable enclosure. Stay tuned! 🚀

## Parts Overview

The model generates several printable parts controlled by the `render_part` parameter:

| Value | Part | Description |
|-------|------|-------------|
| 0 | Base | Main enclosure with sensor pocket, ESP32 cavity, and cable holes |
| 1 | Door | Removable cover for the ESP32 pocket (bottom access) |
| 2 | Top | Rotating wheel cradle with magnet holder and bearing mounts |
| 3 | All Preview | Assembly view showing all parts together (not for printing) |
| 4 | Bearing Rod | Small rods that secure bearings in place |
| 5 | AS5600 Fit Test | Small test piece to verify sensor pocket and peg fit |
| 6 | Bearing Fit Test | Small test piece to verify bearing pocket and rod fit |
| 7 | Rubber Feet | Printable grip feet with textured bottom (print in TPU) |

## How It Works

1. The **base** sits stationary and contains the AS5600 sensor at its center post
2. The **rotating top** holds your bike wheel and spins freely on the base
3. A magnet in the top passes over the AS5600 sensor, which detects the rotation angle
4. Bearings mounted in the top ride on the base's outer rim for smooth rotation
5. The ESP32 reads the sensor data and transmits steering input via Bluetooth

## Key Parameters

### Main Dimensions
- `base_diameter` - Overall diameter of the enclosure (default: 115mm)
- `base_height` - Height of the base platform (default: 17mm)
- `center_diameter` - Diameter of the raised center post (default: 50mm)
- `center_height` - Additional height of center post above base (default: 8mm)

### AS5600 Sensor Pocket
- `as5600_width` / `as5600_depth` - Actual measured board dimensions
- `as5600_pocket_clearance` - Extra space added to pocket (default: 0.8mm)
- `as5600_ledge_depth` - How deep the board sits from the top
- `as5600_peg_diameter` - Diameter of mounting pegs (set smaller than board holes for fit)
- `as5600_peg_height` / `as5600_peg_spacing_*` - Peg configuration

### ESP32 Pocket
- `esp32_width` / `esp32_depth` - Cavity dimensions
- `esp32_pocket_height` - Depth of the pocket from bottom
- `esp32_offset_y` - Offset from center if needed

### Rotating Top
- `top_height` - Total height of the rotating section
- `top_wall_thickness` - Thickness of the wheel cradle walls
- `wheel1_width` / `wheel1_depth` - Primary wheel slot dimensions
- `wheel2_enabled` - Enable perpendicular wheel slots for different wheel sizes

### Bearings
- `bearings_enabled` - Toggle bearing system on/off
- `bearing_count` - Number of bearings (3, 4, or 5)
- `bearing_radius` - Distance from center to bearing position
- `bearing_od` / `bearing_id` / `bearing_thickness` - Bearing dimensions (default: 608 skateboard bearings)
- `bearing_pocket_clearance` - Extra space around bearing for free spinning (default: 1.0mm)
- `bearing_stickout` - How far bearings extend below top piece (directly affects magnet gap!)
- `bearing_rod_diameter` - Diameter of retention rods
- `bearing_rod_clearance` - Extra space around rod in slot (default: 0.3mm)

### Magnet and Sensor Gap

The AS5600 magnetic rotation sensor works best with a 2-3mm air gap between the magnet and the sensor chip.

**Understanding the geometry:**
- The bearings mounted in the top piece ride on the base's outer rim
- How far the bearings stick out below the top determines how high the top sits
- **Actual magnet-sensor gap** = `bearing_stickout` + `magnet_air_gap`

**Example with defaults:**
- bearing_stickout = 3mm
- magnet_air_gap = 0mm
- **Total gap = 3mm** (within optimal range)

**Parameters:**
- `bearing_stickout` - How far bearings extend below top (set to desired gap if magnet_air_gap=0)
- `magnet_diameter` / `magnet_height` - Magnet dimensions
- `magnet_air_gap` - Additional gap beyond bearing stickout (set to 0 if stickout provides adequate gap)

**Tip:** OpenSCAD will echo the actual magnet gap when you render. Check the console output for: `MAGNET GAP: bearing_stickout=Xmm + air_gap=Ymm = Zmm total`

### Optional Features
- `rubber_feet_enabled` - Add recesses for rubber feet
- `rubber_foot_diameter` / `rubber_foot_depth` - Recess dimensions
- `rubber_foot_height` - Height of printable feet (for TPU printing)
- `usb_enabled` - USB-C cable passthrough hole
- `led_enabled` - Status LED hole with stepped diameter
- `tilt_enabled` - Angle the base to compensate for bike headset angle

## Fit Testing (Recommended)

Before printing the full parts, use the fit test pieces to verify your clearance settings work with your printer:

1. **AS5600 Fit Test** (render_part = 5)
   - Print this small piece first
   - Test that your AS5600 board drops into the pocket easily
   - Verify the mounting pegs align with the board holes
   - Adjust `as5600_pocket_clearance` (larger = looser pocket) and `as5600_peg_diameter` (smaller = thinner pegs) as needed

2. **Bearing Fit Test** (render_part = 6)
   - Print this small piece to test bearing fit
   - Verify bearings slide into the pocket smoothly
   - Test that the rod fits into the cross slot
   - Adjust `bearing_pocket_clearance` and `bearing_rod_clearance` as needed

This saves significant time and filament compared to reprinting the full base or top.

## Printing Tips

- **Base**: Print with the flat bottom on the bed. Supports are needed inside the ESP32 pocket cavity (the ceiling spans 60mm+ and won't bridge cleanly). Surface quality in the pocket doesn't matter since the door covers it.
- **Door**: Print flat, countersunk screw holes face up
- **Top**: Print right-side up (bottom on bed). The center recess ceiling (~61mm ring with center hole) may need supports or can bridge on most printers. This is easier than printing upside down, which would require supporting the entire solid floor section.
- **Bearing Rod**: Print standing vertically for strength
- **Rubber Feet**: Print in TPU/flexible filament for best grip. Already oriented with textured surface on top (becomes the grip surface when installed). The textured nubs provide traction on smooth surfaces.

Recommended settings:
- Layer height: 0.2mm
- Infill: 20-30%
- Walls: 3-4 perimeters
- Material: PLA or PETG

## Hardware Required

- 1x ESP32 development board
- 1x AS5600 magnetic rotation sensor module
- 1x Diametrically magnetized magnet (sized to your parameters)
- 3-5x 608 skateboard bearings (or adjust parameters for your bearings)
- 4x M2/M2.5/M3 screws for door (selectable via `door_screw_size`)
- 4x Rubber feet (optional) - either adhesive feet or print your own in TPU using render_part = 7
- 1x 3mm LED (optional)

## Customization

Open `Steering Controller.scad` in OpenSCAD and use the Customizer panel (View > Hide Customizer to toggle) to adjust all parameters. Parameters are organized into logical groups in the right panel.

**Important**: If bearings are cutting through the outer wall, reduce `bearing_radius` to move them inward. The bearing pockets extend `bearing_od/2` beyond the bearing_radius position.

## License

See the main project repository for license information.
