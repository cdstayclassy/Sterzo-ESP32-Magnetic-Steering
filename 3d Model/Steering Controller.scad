// ESP32 Sterzo Enclosure Base
// Round base with raised center for AS5600 sensor
// Parametric design with rubber feet, USB-C hole, and LED hole

/* [Main Dimensions] */
// Base diameter
base_diameter = 115;
// Base height (not including center post)
base_height = 17;
// Center post diameter
center_diameter = 50;
// Center post additional height
center_height = 8;
// Total height = base_height + center_height = 23mm

/* [AS5600 Sensor Pocket] */
// AS5600 board width (enter actual measured width)
as5600_width = 23;
// AS5600 board depth (enter actual measured depth)
as5600_depth = 23;
// Pocket clearance (extra space added to width and depth for fit)
as5600_pocket_clearance = 0.8;
// AS5600 ledge depth (board sits on this ledge, recessed from top)
as5600_ledge_depth = 3;
// Opening below AS5600 (for wires from ESP32) - goes through to ESP32 pocket
as5600_opening_width = 18;
as5600_opening_depth = 18;

/* [AS5600 Mounting Pegs] */
// Enable mounting pegs (for clip-in mounting)
as5600_peg_enabled = true;
// Peg diameter (set smaller than board hole for fit, e.g. 2.8 for 3mm holes)
as5600_peg_diameter = 2.8; // [1:0.1:5]
// Peg height above pocket floor (negative = recessed below floor)
as5600_peg_height = 3; // [-5:0.1:10]
// Peg spacing X (distance between peg centers, left to right)
as5600_peg_spacing_x = 15.4; // [1:0.1:30]
// Peg spacing Y (distance between peg centers, front to back)
as5600_peg_spacing_y = 15.4; // [1:0.1:30]

/* [ESP32 Pocket (Bottom)] */
// ESP32 pocket enabled
esp32_enabled = true;
// ESP32 pocket width
esp32_width = 60;
// ESP32 pocket depth
esp32_depth = 35;
// ESP32 pocket height (from bottom)
esp32_pocket_height = 14;
// ESP32 pocket offset from center (0 = centered below AS5600 opening)
esp32_offset_y = 0;

/* [ESP32 Door] */
// Door thickness
door_thickness = 2;
// Door clearance (gap between door and pocket walls)
door_clearance = 0.3;
// Door corner radius (should match pocket)
door_corner_radius = 3;
// Screw size (0=M2, 1=M2.5, 2=M3)
door_screw_size = 0; // [0:M2, 1:M2.5, 2:M3]
// Mounting post diameter (should be larger than screw hole)
door_post_diameter = 6;
// Mounting post height (from door surface into pocket)
door_post_height = 8;
// Screw hole depth in post
door_screw_depth = 6;

// Screw dimensions lookup tables (hole diameter, head diameter, countersink depth)
// M2: 2.2mm hole, 4mm head, 1.2mm countersink
// M2.5: 2.7mm hole, 5mm head, 1.5mm countersink
// M3: 3.2mm hole, 6mm head, 1.8mm countersink
door_screw_diameter = (door_screw_size == 0) ? 2.2 : (door_screw_size == 1) ? 2.7 : 3.2;
door_screw_head_diameter = (door_screw_size == 0) ? 4 : (door_screw_size == 1) ? 5 : 6;
door_countersink_depth = (door_screw_size == 0) ? 1.2 : (door_screw_size == 1) ? 1.5 : 1.8;

/* [Rubber Feet] */
// Enable rubber feet recesses
rubber_feet_enabled = true;
// Rubber foot diameter
rubber_foot_diameter = 10;
// Rubber foot recess depth (how deep the foot sits in the base)
rubber_foot_depth = 1;
// Rubber foot total height (for printable feet)
rubber_foot_height = 3; // [1:0.5:10]
// Rubber foot clearance (subtracted from diameter for fit)
rubber_foot_clearance = 0.3;
// Rubber foot distance from center
rubber_foot_radius = 50;
// Number of rubber feet
rubber_foot_count = 4;

/* [USB-C Hole] */
// Enable USB-C cable hole
usb_enabled = true;
// USB-C hole width
usb_width = 6;
// USB-C hole height
usb_height = 12;
// USB-C hole center height from bottom (outside)
usb_center_height = 8;
// USB-C hole angular position (degrees, 0 = front)
usb_angle = 0;

/* [LED Hole] */
// Enable LED hole
led_enabled = true;
// LED lens diameter (front opening)
led_lens_diameter = 3;
// LED body diameter (back opening for wires)
led_body_diameter = 4;
// LED lens depth (how far the 3mm section extends)
led_lens_depth = 3;
// LED hole center height from bottom (outside)
led_center_height = 5;
// LED hole angular position (degrees, 180 = opposite USB)
led_angle = 180;

/* [Button Hole] */
// Enable button/reset hole
button_enabled = false;
// Button shaft hole diameter (threaded part that goes through wall)
button_diameter = 7; // [5:1:16]
// Button flange diameter (outer recess for button head - set to 0 for no recess)
button_flange_diameter = 0; // [0:1:20]
// Button flange recess depth (creates flat mounting surface on curved wall)
button_flange_depth = 2; // [1:0.5:5]
// Button hole center height from bottom (outside)
button_center_height = 8;
// Button hole angular position (degrees, 0 = USB side, 90 = right side)
button_angle = 90;

/* [Angled Base] */
// Enable angled/tilted base (for bike headset angle compensation)
tilt_enabled = false;
// Tilt percentage (grade: 10 = 10% grade = ~5.7 degrees, typical bike is 5-15%)
tilt_percent = 0;
// Tilt direction (degrees: 0 = back edge high, 90 = right edge high, 180 = front edge high)
tilt_direction = 0;

/* [Rotating Top - Main] */
// Top total height
top_height = 50;
// Top wall thickness (also determines floor thickness above bearing pockets)
// Must be thick enough that bearing_pocket_depth doesn't cut through floor
top_wall_thickness = 18;
// Radial clearance between top recess and base center post (side gap)
top_recess_clearance = 1;

/* [Rotating Top - Wheel 1 (Front/Back)] */
// Wheel 1 slot width (tire width + clearance)
wheel1_width = 30;
// Wheel 1 slot depth (how far DOWN from top the cutout extends)
wheel1_depth = 23;

/* [Rotating Top - Wheel 2 (Left/Right)] */
// Enable second wheel position (for different wheel sizes)
wheel2_enabled = true;
// Wheel 2 slot width (tire width + clearance)
wheel2_width = 50;
// Wheel 2 slot depth (how far DOWN from top the cutout extends)
wheel2_depth = 25;

/* [Rotating Top - Magnet] */
// Magnet diameter
magnet_diameter = 2;
// Magnet height/thickness
magnet_height = 1;
// Magnet pocket extra clearance
magnet_clearance = 0.2;
// IMPORTANT: The actual magnet-to-sensor gap = bearing_stickout + magnet_air_gap
// where bearing_stickout = bearing_od - bearing_pocket_depth (how far bearing extends below top)
// With default values: stickout = 22 - 19 = 3mm, so set air_gap = 0 for ~3mm total gap
// Air gap between magnet and center post top (add to bearing stickout for total sensor gap)
magnet_air_gap = 0;

/* [Rotating Top - Bearings] */
// Enable bearing rod slots
bearings_enabled = true;
// Number of bearings (3, 4, or 5)
bearing_count = 4; // [3, 4, 5]
// Bearing outer diameter (608 skateboard = 22mm)
bearing_od = 22;
// Bearing inner diameter (608 skateboard = 8mm)
bearing_id = 8;
// Bearing thickness (608 skateboard = 7mm)
bearing_thickness = 7;
// Bearing pocket clearance (extra space around bearing for free spinning)
bearing_pocket_clearance = 1.0; // [0:0.1:5]
// Bearing stickout (how far bearing extends below top piece - directly affects magnet gap!)
// For AS5600, aim for 2-3mm total gap. If magnet_air_gap=0, set stickout to desired gap.
bearing_stickout = 3; // [0:0.1:10]
// Bearing distance from center (should be in the track area)
bearing_radius = 40;
// Rod diameter for bearing retention
bearing_rod_diameter = 8;
// Rod clearance (extra space around rod in slot)
bearing_rod_clearance = 0.3;
// Rod slot length (horizontal part of cross for locking)
bearing_rod_slot_length = 12;
// Bearing rod length (length of rod that goes through bearing)
bearing_rod_length = 20;

/* [Rendering] */
// What to render
render_part = 0; // [0:Base, 1:Door, 2:Top, 3:All Preview, 4:Bearing Rod, 5:AS5600 Fit Test, 6:Bearing Fit Test, 7:Rubber Feet]
$fn = 100;

// Calculate wall thickness at edge
wall_thickness = 2;

// ==================== DERIVED CALCULATIONS ====================
// These depend on parameters defined above

// AS5600 derived dimensions (with clearances applied)
as5600_pocket_width = as5600_width + as5600_pocket_clearance;
as5600_pocket_depth = as5600_depth + as5600_pocket_clearance;

// Bearing pocket depth: derived from stickout (how deep the pocket is in the top piece)
bearing_pocket_depth = bearing_od - bearing_stickout;

// Actual magnet-to-sensor gap (for AS5600 optimal range is 2-3mm)
// = bearing_stickout + magnet_air_gap
actual_magnet_gap = bearing_stickout + magnet_air_gap;
echo(str("MAGNET GAP: bearing_stickout=", bearing_stickout, "mm + air_gap=", magnet_air_gap, "mm = ", actual_magnet_gap, "mm total"));

// Rod ledge depth - where rod rests to achieve correct bearing stickout
// Rod center must align with bearing center for proper support
// Formula: (bearing_od/2) + (rod_diameter/2) - bearing_stickout
rod_ledge_depth = bearing_od/2 + bearing_rod_diameter/2 - bearing_stickout;

// Floor thickness check - warn if bearing pockets would cut through
floor_thickness = center_height + magnet_air_gap + top_wall_thickness;
floor_remaining = floor_thickness - bearing_pocket_depth;
if (floor_remaining < 2) {
    echo(str("WARNING: Floor too thin! Only ", floor_remaining, "mm remaining. Increase top_wall_thickness."));
}
echo(str("BEARING: pocket_depth=", bearing_pocket_depth, "mm, rod_ledge_depth=", rod_ledge_depth, "mm, floor_remaining=", floor_remaining, "mm"));

// Derived: recess depth clears center post by the magnet air gap amount
top_recess_depth = center_height + magnet_air_gap;

// Magnet position: bottom of magnet should be (center_height + magnet_air_gap) above base top
magnet_pocket_z = center_height + magnet_air_gap;

// Calculate tilt angle from percentage
tilt_angle = atan(tilt_percent / 100);

// ==================== MODULES ====================

// Main module
module base_enclosure() {
    difference() {
        // Solid parts
        union() {
            // Main base cylinder
            cylinder(d = base_diameter, h = base_height);

            // Center raised post
            cylinder(d = center_diameter, h = base_height + center_height);

            // AS5600 mounting pegs
            if (as5600_peg_enabled) {
                as5600_mounting_pegs();
            }

            // ESP32 door mounting posts
            if (esp32_enabled) {
                translate([0, esp32_offset_y, 0])
                    esp32_mounting_posts();
            }
        }

        // Cutouts

        // AS5600 sensor pocket (recessed ledge at top for board to sit on)
        translate([0, 0, base_height + center_height - as5600_ledge_depth])
            as5600_ledge();

        // Open through-hole below AS5600 (connects to ESP32 pocket for wires)
        translate([0, 0, -0.01])
            as5600_through_hole();

        // ESP32 pocket (from bottom)
        if (esp32_enabled) {
            translate([0, esp32_offset_y, -0.01])
                esp32_pocket();
            // Screw holes for door mounting
            translate([0, esp32_offset_y, 0])
                esp32_screw_holes();
        }

        // Rubber feet recesses
        if (rubber_feet_enabled) {
            rubber_feet_cutouts();
        }

        // USB-C hole
        if (usb_enabled) {
            usb_hole_cutout();
        }

        // LED hole
        if (led_enabled) {
            led_hole_cutout();
        }

        // Button/reset hole
        if (button_enabled) {
            button_hole_cutout();
        }
    }
}

// AS5600 sensor ledge (recessed area at top where board sits)
module as5600_ledge() {
    difference() {
        // Rectangular pocket for the board to sit in (recessed from top)
        // Uses pocket dimensions which include clearance
        translate([-as5600_pocket_width/2, -as5600_pocket_depth/2, 0])
            cube([as5600_pocket_width, as5600_pocket_depth, as5600_ledge_depth + 0.01]);

        // Protect peg locations - only up to actual peg height (not full ledge depth)
        // This prevents the ledge from cutting away the pegs
        if (as5600_peg_enabled && as5600_peg_height > 0) {
            for (x = [-as5600_peg_spacing_x/2, as5600_peg_spacing_x/2]) {
                for (y = [-as5600_peg_spacing_y/2, as5600_peg_spacing_y/2]) {
                    translate([x, y, -0.01])
                        cylinder(d = as5600_peg_diameter, h = as5600_peg_height + 0.01);
                }
            }
        }
    }
}

// Through-hole below AS5600 for wires (connects AS5600 to ESP32 pocket)
module as5600_through_hole() {
    pocket_floor = base_height + center_height - as5600_ledge_depth;
    rib_width = 2;  // Width of support ribs

    difference() {
        // Rectangular opening from bottom up to the AS5600 ledge
        translate([-as5600_opening_width/2, -as5600_opening_depth/2, 0])
            cube([as5600_opening_width, as5600_opening_depth, pocket_floor + 0.02]);

        // Leave solid columns at peg locations with support ribs to walls
        if (as5600_peg_enabled) {
            for (x = [-as5600_peg_spacing_x/2, as5600_peg_spacing_x/2]) {
                for (y = [-as5600_peg_spacing_y/2, as5600_peg_spacing_y/2]) {
                    // Column at peg location
                    translate([x, y, -0.01])
                        cylinder(d = as5600_peg_diameter, h = pocket_floor + 0.02);

                    // Support rib in X direction (from column to wall)
                    wall_x = (x > 0) ? as5600_opening_width/2 : -as5600_opening_width/2;
                    translate([min(x, wall_x), y - rib_width/2, -0.01])
                        cube([abs(wall_x - x), rib_width, pocket_floor + 0.02]);

                    // Support rib in Y direction (from column to wall)
                    wall_y = (y > 0) ? as5600_opening_depth/2 : -as5600_opening_depth/2;
                    translate([x - rib_width/2, min(y, wall_y), -0.01])
                        cube([rib_width, abs(wall_y - y), pocket_floor + 0.02]);
                }
            }
        }
    }
}

// AS5600 mounting pegs (cylinders starting at pocket floor)
module as5600_mounting_pegs() {
    // Pocket floor is where the AS5600 board sits
    pocket_floor = base_height + center_height - as5600_ledge_depth;

    // Pegs start at pocket floor and go up by peg_height
    // Positive peg_height = sticks up above floor
    // Negative peg_height = recessed below floor (starts lower)
    // Zero = flush with floor (no visible peg)
    if (as5600_peg_height != 0) {
        for (x = [-as5600_peg_spacing_x/2, as5600_peg_spacing_x/2]) {
            for (y = [-as5600_peg_spacing_y/2, as5600_peg_spacing_y/2]) {
                translate([x, y, pocket_floor])
                    cylinder(d = as5600_peg_diameter, h = as5600_peg_height);
            }
        }
    }
}

// ESP32 pocket on bottom
module esp32_pocket() {
    // Corner radius
    r = 3;

    // Screw positions at corners (same as mounting posts)
    screw_x = esp32_width/2 - r;
    screw_y = esp32_depth/2 - r;

    // Size of the wedge extension (same as mounting posts)
    wedge_size = door_post_diameter;

    difference() {
        // Rounded rectangle pocket
        hull() {
            for (x = [-esp32_width/2 + r, esp32_width/2 - r]) {
                for (y = [-esp32_depth/2 + r, esp32_depth/2 - r]) {
                    translate([x, y, 0])
                        cylinder(r = r, h = esp32_pocket_height + 0.01);
                }
            }
        }

        // Protect mounting post wedge locations at corners (from door_thickness up)
        for (mx = [-1, 1]) {
            for (my = [-1, 1]) {
                translate([mx * screw_x, my * screw_y, door_thickness - 0.01])
                    hull() {
                        cylinder(d = door_post_diameter, h = esp32_pocket_height + 0.03);
                        translate([mx * (wedge_size/2 - r/2), 0, 0])
                            cylinder(d = r*2, h = esp32_pocket_height + 0.03);
                        translate([0, my * (wedge_size/2 - r/2), 0])
                            cylinder(d = r*2, h = esp32_pocket_height + 0.03);
                    }
            }
        }
    }
}

// Rubber feet cutouts
module rubber_feet_cutouts() {
    for (i = [0:rubber_foot_count-1]) {
        angle = i * 360 / rubber_foot_count + 45;  // Start at 45 degrees
        translate([
            rubber_foot_radius * cos(angle),
            rubber_foot_radius * sin(angle),
            -0.01
        ])
            cylinder(d = rubber_foot_diameter, h = rubber_foot_depth + 0.01);
    }
}

// USB-C hole cutout - cuts from outside edge into ESP32 pocket
module usb_hole_cutout() {
    // Calculate depth needed to reach ESP32 pocket
    // From outer edge to center is base_diameter/2, pocket extends esp32_depth/2 from center
    hole_depth = base_diameter/2 - esp32_depth/2 + 5;  // +5 for overlap into pocket

    rotate([0, 0, usb_angle])
        translate([esp32_depth/2 - 5, 0, usb_center_height])
            rotate([0, 90, 0])
                usb_hole_shape(hole_depth);
}

// USB hole shape (rounded rectangle)
module usb_hole_shape(depth) {
    hull() {
        r = min(usb_height/2, 2);
        for (x = [-usb_width/2 + r, usb_width/2 - r]) {
            for (y = [-usb_height/2 + r, usb_height/2 - r]) {
                translate([x, y, 0])
                    cylinder(r = r, h = depth);
            }
        }
    }
}

// LED hole cutout - stepped, cuts from outside edge into ESP32 pocket
module led_hole_cutout() {
    // Calculate depth needed to reach ESP32 pocket
    hole_depth = base_diameter/2 - esp32_depth/2 + 5;  // +5 for overlap into pocket

    rotate([0, 0, led_angle])
        translate([base_diameter/2 + 0.01, 0, led_center_height])
            rotate([0, -90, 0])
                led_hole_shape(hole_depth);
}

// LED hole shape - stepped: narrow at outside (lens), wider inside (body/wires)
module led_hole_shape(depth) {
    // Outer section (lens hole) - 3mm diameter, first few mm from outside
    cylinder(d = led_lens_diameter, h = led_lens_depth + 0.01);

    // Inner section (body/wire hole) - 4mm diameter, rest of the way
    translate([0, 0, led_lens_depth - 0.01])
        cylinder(d = led_body_diameter, h = depth - led_lens_depth + 0.02);
}

// Button/reset hole cutout - stepped hole with optional flange recess
// Flange recess creates a flat mounting surface on the curved outer wall
module button_hole_cutout() {
    // Calculate depth needed to go through wall into ESP32 pocket area
    hole_depth = base_diameter/2 - esp32_depth/2 + 5;  // +5 for overlap into pocket

    rotate([0, 0, button_angle])
        translate([base_diameter/2 + 0.01, 0, button_center_height])
            rotate([0, -90, 0]) {
                // Main shaft hole (goes all the way through)
                cylinder(d = button_diameter, h = hole_depth);

                // Flange recess (optional - creates flat surface for button head)
                // Larger diameter cylinder at the outer surface, going inward
                if (button_flange_diameter > 0) {
                    cylinder(d = button_flange_diameter, h = button_flange_depth);
                }
            }
}

// ESP32 door mounting posts (corner wedges that contact both walls)
module esp32_mounting_posts() {
    // Corner radius for pocket shape
    r = 3;

    // Position posts at the corner radius centers
    screw_x = esp32_width/2 - r;
    screw_y = esp32_depth/2 - r;

    // Size of the wedge extension along each wall
    wedge_size = door_post_diameter;

    for (mx = [-1, 1]) {
        for (my = [-1, 1]) {
            translate([mx * screw_x, my * screw_y, door_thickness])
                // Wedge shape using hull - fills corner and contacts both walls
                hull() {
                    // Center cylinder for screw
                    cylinder(d = door_post_diameter, h = door_post_height);
                    // Extension toward X wall
                    translate([mx * (wedge_size/2 - r/2), 0, 0])
                        cylinder(d = r*2, h = door_post_height);
                    // Extension toward Y wall
                    translate([0, my * (wedge_size/2 - r/2), 0])
                        cylinder(d = r*2, h = door_post_height);
                }
        }
    }
}

// ESP32 door screw holes (cut separately in difference section)
module esp32_screw_holes() {
    // Corner radius for pocket shape
    r = 3;

    // Position holes at the corner radius centers (same as posts)
    screw_x = esp32_width/2 - r;
    screw_y = esp32_depth/2 - r;

    for (x = [-screw_x, screw_x]) {
        for (y = [-screw_y, screw_y]) {
            // Screw hole from bottom surface into post
            translate([x, y, -0.01])
                cylinder(d = door_screw_diameter, h = door_screw_depth + door_thickness + 0.02);
        }
    }
}

// ESP32 door (separate part to print)
module esp32_door() {
    // Door dimensions (slightly smaller than pocket for clearance)
    door_width = esp32_width - door_clearance * 2;
    door_depth = esp32_depth - door_clearance * 2;

    // Corner radius for pocket shape
    r = 3;

    // Screw positions at corners (same as mounting posts)
    screw_x = esp32_width/2 - r;
    screw_y = esp32_depth/2 - r;

    difference() {
        // Door body - rounded rectangle
        hull() {
            dr = door_corner_radius - door_clearance;
            for (x = [-door_width/2 + dr, door_width/2 - dr]) {
                for (y = [-door_depth/2 + dr, door_depth/2 - dr]) {
                    translate([x, y, 0])
                        cylinder(r = dr, h = door_thickness);
                }
            }
        }

        // Screw holes with countersink at corners
        for (x = [-screw_x, screw_x]) {
            for (y = [-screw_y, screw_y]) {
                translate([x, y, 0]) {
                    // Through hole for screw
                    translate([0, 0, -0.01])
                        cylinder(d = door_screw_diameter, h = door_thickness + 0.02);
                    // Countersink from top
                    translate([0, 0, door_thickness - door_countersink_depth])
                        cylinder(d1 = door_screw_diameter, d2 = door_screw_head_diameter, h = door_countersink_depth + 0.01);
                }
            }
        }
    }
}

// ==================== ROTATING TOP MODULES ====================

// Main rotating top module
module rotating_top() {
    recess_diameter = center_diameter + top_recess_clearance * 2;

    // Base section height (solid part with bearings)
    base_section_height = top_recess_depth + top_wall_thickness;

    difference() {
        union() {
            // Solid base section (bottom cylinder)
            cylinder(d = base_diameter, h = base_section_height);

            // Upper walls section
            difference() {
                // Full cylinder for upper section
                translate([0, 0, base_section_height])
                    cylinder(d = base_diameter, h = top_height - base_section_height);

                // Hollow out the center (inside the walls)
                translate([0, 0, base_section_height - 0.01])
                    cylinder(d = base_diameter - top_wall_thickness * 2, h = top_height - base_section_height + 0.02);
            }
        }

        // Center recess (fits over base center post)
        translate([0, 0, -0.01])
            cylinder(d = recess_diameter, h = top_recess_depth + 0.01);

        // Wheel 1 channel cutouts (front and back - 0° and 180°)
        for (angle = [0, 180]) {
            rotate([0, 0, angle])
                wheel_channel_cutout(base_section_height, wheel1_width, wheel1_depth);
        }

        // Wheel 2 channel cutouts (left and right - 90° and 270°)
        if (wheel2_enabled) {
            for (angle = [90, 270]) {
                rotate([0, 0, angle])
                    wheel_channel_cutout(base_section_height, wheel2_width, wheel2_depth);
            }
        }

        // Magnet pocket (centered, opens from recess floor, positions magnet at correct air gap)
        // Pocket starts at recess floor and extends up to hold the magnet
        translate([0, 0, top_recess_depth - 0.01])
            cylinder(d = magnet_diameter + magnet_clearance * 2,
                     h = (magnet_pocket_z - top_recess_depth) + magnet_height + magnet_clearance + 0.02);

        // Bearing pockets with rod slots
        if (bearings_enabled) {
            bearing_pockets();
        }
    }
}

// Wheel channel cutout - rounded U-shape slot
// w = slot width, d = how far DOWN from the top the cutout extends
module wheel_channel_cutout(floor_height, w, d) {
    r = w / 2;  // Radius for rounded bottom
    bottom_z = top_height - d + r;  // Center of rounded bottom
    slot_length = base_diameter;  // Extends past outer edge

    // Rounded slot using hull between bottom and top spheres
    hull() {
        translate([0, r, bottom_z])
            sphere(r = r);
        translate([0, slot_length, bottom_z])
            sphere(r = r);
        translate([0, r, top_height + r])
            sphere(r = r);
        translate([0, slot_length, top_height + r])
            sphere(r = r);
    }
}

// Bearing pockets arranged around bottom of floor (track area)
module bearing_pockets() {
    for (i = [0:bearing_count-1]) {
        angle = i * 360 / bearing_count;
        rotate([0, 0, angle])
            translate([bearing_radius, 0, 0])
                bearing_pocket();
    }
}

// Single bearing pocket - forms a + shape when viewed from below
// Bearing arm: TANGENT direction (parallel to center) - DEEP, accommodates bearing body
// Rod arm: RADIAL direction (toward/away from center) - SHALLOWER, rod rests on ledge here
module bearing_pocket() {
    rod_d = bearing_rod_diameter + bearing_rod_clearance;
    half_slot = bearing_rod_slot_length / 2;

    // Bearing pocket dimensions
    pocket_width = bearing_od + bearing_pocket_clearance;
    pocket_thickness = bearing_thickness + bearing_pocket_clearance;

    // Rod ledge depth = (bearing_od/2) + (rod_diameter/2) - bearing_stickout
    rod_ledge_depth = bearing_od/2 + bearing_rod_diameter/2 - bearing_stickout;

    // BEARING ARM of + (TANGENT direction, parallel to center) - DEEPER
    translate([-pocket_thickness/2, -bearing_od/2 - bearing_pocket_clearance/2, -0.01])
        cube([pocket_thickness, pocket_width, bearing_pocket_depth + 0.01]);

    // ROD ARM of + (RADIAL direction, toward/away from center) - SHALLOWER
    // The floor creates a ledge that holds the rod/bearing in position
    translate([-half_slot - rod_d/2, -rod_d/2, -0.01])
        cube([bearing_rod_slot_length + rod_d, rod_d, rod_ledge_depth + 0.02]);
}

// Solid wedge to fill underneath the tilted base
module tilt_wedge_fill() {
    // Height at the back (high) edge
    back_rise = base_diameter * sin(tilt_angle);

    rotate([0, 0, tilt_direction])
    difference() {
        // Solid cylinder tall enough to reach the tilted base
        cylinder(d = base_diameter, h = back_rise + 1);

        // Cut with angled plane matching the tilt
        translate([0, 0, back_rise / 2])
            rotate([tilt_angle, 0, 0])
                translate([0, 0, back_rise])
                    cube([base_diameter + 10, base_diameter + 10, back_rise * 2], center = true);
    }
}

// Render base enclosure with optional tilt
module render_base() {
    if (tilt_enabled && tilt_percent > 0) {
        // Calculate how much the front edge drops when rotated
        front_drop = (base_diameter / 2) * sin(tilt_angle);
        back_rise = base_diameter * sin(tilt_angle);

        difference() {
            union() {
                // Rotate around X axis and lift so front edge is at Z=0
                translate([0, 0, front_drop])
                    rotate([0, 0, tilt_direction])
                        rotate([tilt_angle, 0, 0])
                            rotate([0, 0, -tilt_direction])
                                base_enclosure();

                // Fill in the wedge underneath
                tilt_wedge_fill();
            }

            // Cut everything below Z=0 (clean up any artifacts)
            translate([0, 0, -500])
                cube([1000, 1000, 1000], center = true);

            // Cut ESP32 pocket from bottom (vertical cut from Z=0)
            if (esp32_enabled) {
                translate([0, esp32_offset_y, -0.01])
                    esp32_pocket();
            }

            // Cut rubber feet from bottom (vertical cut from Z=0)
            if (rubber_feet_enabled) {
                rubber_feet_cutouts();
            }
        }
    } else {
        base_enclosure();
    }
}

// Bearing rod - cylinder that goes through bearing and into cross slot
module bearing_rod() {
    cylinder(d = bearing_rod_diameter, h = bearing_rod_length);
}

// ==================== FIT TEST MODULES ====================

// AS5600 fit test - small piece to test pocket and peg fit before full print
module as5600_fit_test() {
    // Margin around the pocket
    margin = 2;
    // Test piece dimensions
    test_width = as5600_pocket_width + margin * 2;
    test_depth = as5600_pocket_depth + margin * 2;
    test_height = as5600_ledge_depth + 5;  // Ledge depth + base material

    difference() {
        union() {
            // Solid block
            translate([-test_width/2, -test_depth/2, 0])
                cube([test_width, test_depth, test_height]);

            // Add mounting pegs if enabled
            if (as5600_peg_enabled && as5600_peg_height > 0) {
                for (x = [-as5600_peg_spacing_x/2, as5600_peg_spacing_x/2]) {
                    for (y = [-as5600_peg_spacing_y/2, as5600_peg_spacing_y/2]) {
                        translate([x, y, test_height - as5600_ledge_depth])
                            cylinder(d = as5600_peg_diameter, h = as5600_peg_height);
                    }
                }
            }
        }

        // AS5600 pocket (at top) - where the board sits
        // But protect the peg locations from being cut away
        difference() {
            translate([0, 0, test_height - as5600_ledge_depth])
                translate([-as5600_pocket_width/2, -as5600_pocket_depth/2, 0])
                    cube([as5600_pocket_width, as5600_pocket_depth, as5600_ledge_depth + 0.01]);

            // Protect peg locations
            if (as5600_peg_enabled && as5600_peg_height > 0) {
                for (x = [-as5600_peg_spacing_x/2, as5600_peg_spacing_x/2]) {
                    for (y = [-as5600_peg_spacing_y/2, as5600_peg_spacing_y/2]) {
                        translate([x, y, test_height - as5600_ledge_depth - 0.01])
                            cylinder(d = as5600_peg_diameter, h = as5600_peg_height + 0.02);
                    }
                }
            }
        }

        // Through-hole for wire connectors (same as as5600_opening in main model)
        // But protect the peg column locations with support ribs to walls
        difference() {
            translate([-as5600_opening_width/2, -as5600_opening_depth/2, -0.01])
                cube([as5600_opening_width, as5600_opening_depth, test_height - as5600_ledge_depth + 0.02]);

            // Leave solid columns at peg locations with support ribs
            if (as5600_peg_enabled) {
                rib_width = 2;
                through_height = test_height - as5600_ledge_depth + 0.04;

                for (x = [-as5600_peg_spacing_x/2, as5600_peg_spacing_x/2]) {
                    for (y = [-as5600_peg_spacing_y/2, as5600_peg_spacing_y/2]) {
                        // Column at peg location
                        translate([x, y, -0.02])
                            cylinder(d = as5600_peg_diameter, h = test_height + 0.04);

                        // Support rib in X direction (from column to wall)
                        wall_x = (x > 0) ? as5600_opening_width/2 : -as5600_opening_width/2;
                        translate([min(x, wall_x), y - rib_width/2, -0.02])
                            cube([abs(wall_x - x), rib_width, through_height]);

                        // Support rib in Y direction (from column to wall)
                        wall_y = (y > 0) ? as5600_opening_depth/2 : -as5600_opening_depth/2;
                        translate([x - rib_width/2, min(y, wall_y), -0.02])
                            cube([rib_width, abs(wall_y - y), through_height]);
                    }
                }
            }
        }
    }
}

// Bearing fit test - small piece to test bearing pocket and rod slot fit
// Rendered upside down so it prints without supports (pocket opens upward)
module bearing_fit_test() {
    // Wall thickness around cutouts
    wall = 3;

    rod_d = bearing_rod_diameter + bearing_rod_clearance;
    half_slot = bearing_rod_slot_length / 2;

    // Calculate extents of all cutouts
    bearing_min_x = -bearing_od/2 - bearing_pocket_clearance/2;
    bearing_max_x = bearing_od/2 + bearing_pocket_clearance/2;

    // Rod slot extends half_slot + rod_d/2 in each direction
    rod_extent = half_slot + rod_d/2;

    // Bearing thickness extent
    bearing_y_extent = (bearing_thickness + bearing_pocket_clearance) / 2;

    // Use the larger of rod slot or bearing thickness for Y
    max_y = max(rod_extent, bearing_y_extent);

    // Test piece dimensions with walls on all sides
    min_x = bearing_min_x - wall;
    max_x = max(bearing_max_x, rod_extent) + wall;
    min_y = -max_y - wall;
    max_y_dim = max_y + wall;

    test_width = max_x - min_x;
    test_depth = max_y_dim - min_y;
    test_height = bearing_pocket_depth + wall;  // Bearing arm is deepest

    // Flip upside down for printing (pocket opens from top)
    translate([0, 0, test_height])
    rotate([180, 0, 0])
    difference() {
        // Solid block properly positioned to contain all cutouts
        translate([min_x, min_y, 0])
            cube([test_width, test_depth, test_height]);

        // BEARING ARM of + (TANGENT direction) - DEEPER
        translate([-bearing_y_extent, bearing_min_x, -0.01])
            cube([bearing_thickness + bearing_pocket_clearance, bearing_od + bearing_pocket_clearance, bearing_pocket_depth + 0.01]);

        // ROD ARM of + (RADIAL direction) - SHALLOWER, creates ledge for rod
        translate([-half_slot - rod_d/2, -rod_d/2, -0.01])
            cube([bearing_rod_slot_length + rod_d, rod_d, rod_ledge_depth + 0.02]);
    }
}

// Rubber foot - printable foot with textured grip surface
// Rendered upside down so textured surface prints on top (becomes bottom when installed)
module rubber_foot() {
    foot_d = rubber_foot_diameter - rubber_foot_clearance;
    grip_nub_d = 1.5;  // Diameter of grip nubs
    grip_nub_h = 0.6;  // Height of grip nubs
    grip_nub_spacing = 2.5;  // Spacing between nub centers

    // Flip upside down for printing (grip surface on top during print)
    translate([0, 0, rubber_foot_height])
    rotate([180, 0, 0])
    union() {
        // Main foot body
        cylinder(d = foot_d, h = rubber_foot_height);

        // Textured grip surface (small nubs on bottom)
        // Create a grid of nubs within the foot diameter
        nub_radius = foot_d/2 - grip_nub_d;
        for (x = [-nub_radius : grip_nub_spacing : nub_radius]) {
            for (y = [-nub_radius : grip_nub_spacing : nub_radius]) {
                if (sqrt(x*x + y*y) <= nub_radius) {
                    translate([x, y, -grip_nub_h + 0.01])
                        cylinder(d1 = grip_nub_d, d2 = grip_nub_d * 0.6, h = grip_nub_h);
                }
            }
        }
    }
}

// Render all rubber feet arranged for printing
module rubber_feet_printable() {
    spacing = rubber_foot_diameter + 5;
    cols = ceil(sqrt(rubber_foot_count));

    for (i = [0 : rubber_foot_count - 1]) {
        col = i % cols;
        row = floor(i / cols);
        translate([col * spacing, row * spacing, 0])
            rubber_foot();
    }
}

// Main rendering based on render_part selection
if (render_part == 0) {
    // Base only
    render_base();
} else if (render_part == 1) {
    // Door only (positioned for printing)
    esp32_door();
} else if (render_part == 2) {
    // Top only (right-side up for preview)
    rotating_top();
} else if (render_part == 3) {
    // All preview - assembled view
    render_base();
    translate([0, esp32_offset_y, -door_thickness - 2])
        esp32_door();
    translate([0, 0, base_height + center_height + 2])
        rotating_top();
} else if (render_part == 4) {
    // Bearing rod only (for printing)
    bearing_rod();
} else if (render_part == 5) {
    // AS5600 fit test - small piece to verify pocket and peg fit
    as5600_fit_test();
} else if (render_part == 6) {
    // Bearing fit test - small piece to verify bearing pocket and rod fit
    bearing_fit_test();
} else if (render_part == 7) {
    // Rubber feet - printable feet with textured grip (print in TPU)
    rubber_feet_printable();
}
