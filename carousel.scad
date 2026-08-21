// =============================================================================
//  CAKE CAROUSEL  --  a parametric, hand-spun carousel mechanism for cakes
// =============================================================================
//  How it works
//    * A large printed gear wheel (the ROTOR, 190 mm) rides on a ring of 40
//      loose 6 mm balls trapped between two grooves -- a printed thrust
//      bearing that carries the weight of the cake.
//    * The rotor is centred by a plain journal: its bore runs on the BASE hub,
//      whose top finishes flush with the turntable so a cake board can sit
//      straight on it.  Nothing clamps the rotor down -- lift it off to clean,
//      exactly like a lazy-susan cake stand.
//    * A small PINION with a knurled thumbwheel sits just outside the rotor
//      rim, at the far side of the base's drive pod.  One flick of the
//      thumbwheel = 93/14 = 6.6 turns of gear reduction ... in reverse, so the
//      wheel is easy to spin and the cake turns slowly and smoothly.
//    * Eight POLES rise from the rotor and carry the CANOPY + FINIAL, so roof
//      and cake turn together.  The SKIRT is a separate ring that lifts the
//      base off the table and hides the works.
//
//  Two builds come out of this one file (see BOM.md):
//    printed base + thumbwheel  -- base_style="printed", drive="thumbwheel"
//    printed base + NEMA 17     -- base_style="printed", drive="nema17"
//    ready-made turntable       -- base_style="turntable": base, skirt, ball
//                                  race, retainer and pinion are dropped and an
//                                  ADAPTER disc sits on a bought 130 mm
//                                  motorised turntable instead.
//
//  Companion file: carousel_freecad.FCMacro  (same geometry, built with the
//  FreeCAD / OpenCascade kernel).  See README.md for printing and assembly.
//
//  Units: mm.  Requires OpenSCAD 2021.01 or newer.
// =============================================================================

/* [Render] */
part = "assembly"; // [assembly, print_plate, base, skirt, rotor, adapter, retainer, pinion, canopy, pole, finial, crank, hanger]
// preview: how far the cake has turned
demo_angle = 0;    // [0:5:360]
// ghost the cake, the balls and the bought turntable in the assembly view
show_ghosts = true;

/* [Configuration] */
// printed  = printed base, ball race and pinion drive
// turntable = sit on a bought motorised turntable, print the adapter instead
base_style = "printed";   // [printed, turntable]
// how the pinion is turned (base_style = "printed" only)
drive = "thumbwheel";     // [thumbwheel, nema17]
// bought turntable: platform diameter and height of its top face
platform_dia = 130;
platform_h   = 30;
adapter_t       = 6;
platform_recess = 3;

/* [Split for small print beds] */
// 0 = one piece, otherwise cut base/rotor/canopy into N sectors
sectors = 0;       // [0, 2, 3, 4]
sector_index = 0;  // [0:3]
// rotate the cut planes away from the drive pod
split_rot = 28;
dowel_dia = 3;

/* [Gears] */
gear_module    = 2;
rotor_teeth    = 93;
pinion_teeth   = 14;
pressure_angle = 20;
backlash       = 0.30;
// addendum factors (x module).  The wheel's teeth are shortened so a small
// pinion can be used without tip/root interference -- see the asserts below.
rotor_add      = 0.85;
pinion_add     = 1.0;

/* [Plates] */
plate_t = 6;   // base plate
rotor_t = 6;   // rotor / gear wheel

/* [Ball race] */
ball_dia     = 6;    // 6 mm steel balls or airsoft BBs
race_r       = 78;   // radius of the ball circle
ball_count   = 40;
groove_depth = 1.8;
retainer_t   = 2;

/* [Hub] */
hub_r   = 12;     // the rotor's bore turns on this post
peg_dia = 8;      // finial spigot

/* [Base] */
base_r     = 110;
skirt_wall = 4;
skirt_pegs = 7;    // locating pegs between skirt and base
peg_d      = 4;
vent_dia   = 12;
vent_count = 12;

/* [Poles and canopy] */
pole_count   = 8;
pole_r       = 84;
pole_dia     = 6;
pole_len     = 160;
socket_depth = 4;    // into the rotor
canopy_r     = 90;
canopy_rise  = 80;
canopy_wall  = 4.3;  // radial; about 3 mm measured square to the slope
canopy_grip  = 8;    // pole socket depth in the canopy
eave_h       = 12;   // depth of the rim band that holds the poles

/* [Fit] */
fit = 0.25;        // printed clearance, per side
$fa = 2;
$fs = 0.5;

// ---------------------------------------------------------------- derived ---
rotor_r     = gear_module * (rotor_teeth / 2 + rotor_add);   // turntable radius
pinion_tip  = gear_module * (pinion_teeth / 2 + pinion_add);
center_dist = gear_module * (rotor_teeth + pinion_teeth) / 2;  // 107
ratio       = rotor_teeth / pinion_teeth;

// the drive pod has to hold a NEMA 17 bolt circle, and the skirt has to be
// deep enough to hide whatever hangs off the bottom
pod_r   = (drive == "nema17") ? 26 : 22;
skirt_h = (drive == "nema17") ? 34 : 20;
nema_bolt   = 31;    // NEMA 17 bolt square
nema_pilot  = 22;    // pilot boss diameter
nema_shaft  = 5;

ball_z    = plate_t + ball_dia / 2 - groove_depth;   // ball centre height
rotor_z   = ball_z + ball_dia / 2 - groove_depth;    // rotor underside
rotor_top = rotor_z + rotor_t;
hub_top   = rotor_top - 0.3;       // flush: a cake board can sit right on top

// top face of whatever rotates -- the printed rotor, or the adapter disc.
// This is where the cake board goes.
plate_top = (base_style == "turntable")
            ? platform_h + adapter_t - platform_recess : rotor_top;

pinion_boss_h = rotor_z - plate_t - 0.2;
pinion_gear_h = rotor_top + 2 - (plate_t + pinion_boss_h);
knob_dia      = 20;
knob_h        = 11.6;
knob_z        = plate_t + pinion_boss_h + pinion_gear_h;

pole_z    = plate_top - socket_depth;
canopy_z  = pole_z + pole_len - canopy_grip;

// --- interference guards -------------------------------------------------
// A tooth tip must not dig in past the point where the mating flank stops
// being a true involute: sqrt(r_tip^2 - r_base^2) <= centre distance * sin(pa)
function tip_reach(n, m, add, pa) =
    let (rp = m * n / 2)
    sqrt(pow(rp + add * m, 2) - pow(rp * cos(pa), 2));
assert(tip_reach(rotor_teeth, gear_module, rotor_add, pressure_angle)
       <= center_dist * sin(pressure_angle),
       "wheel teeth are too tall for this pinion: lower rotor_add or add teeth to the pinion");
assert(tip_reach(pinion_teeth, gear_module, pinion_add, pressure_angle)
       <= center_dist * sin(pressure_angle),
       "pinion teeth are too tall: lower pinion_add");
assert(center_dist - pinion_tip > gear_module * (rotor_teeth / 2 - 1.25),
       "pinion tip fouls the wheel's tooth roots");
assert(center_dist - rotor_r > gear_module * (pinion_teeth / 2 - 1.25),
       "wheel tip fouls the pinion's tooth roots");
assert(flank(rotor_teeth, gear_module, pressure_angle, backlash, rotor_r) > 0.1 &&
       flank(pinion_teeth, gear_module, pressure_angle, backlash, pinion_tip) > 0.1,
       "teeth come to a point: reduce an addendum factor");
assert(center_dist - knob_dia / 2 > rotor_r + 1, "thumbwheel fouls the turntable rim");
assert(pod_r > pinion_tip + 3, "drive pod is too small for the pinion");

echo(str("rotor ", 2*rotor_r, " mm  |  reduction ", ratio, ":1  |  overall height ",
         canopy_z + canopy_rise + 44, " mm"));

// =============================================================================
//  Involute gear geometry (shared, verbatim, with the FreeCAD macro)
// =============================================================================
function pol(r, a) = [r * cos(a), r * sin(a)];

// polar angle swept by an involute of base radius rb out to radius r
function inv_ang(rb, r) = let (a = acos(min(1, rb / r))) tan(a) * 180 / PI - a;

// Half tooth angle at radius r, for a tooth centred on 0 deg, with half the
// backlash taken off each flank.  The two flanks of a tooth are involutes of
// opposite hand, so the tooth narrows as r grows: hence -inv_ang(rb, r).
function flank(n, m, pa, bl, r) =
    let (rp = m * n / 2, rb = rp * cos(pa))
    90 / n - (bl / 2) / rp * 180 / PI + inv_ang(rb, rp) - inv_ang(rb, r);

function gear_profile(n, m, pa = 20, bl = 0, add = 1.0, steps = 8) =
    let (
        rp = m * n / 2,
        rb = rp * cos(pa),
        ro = rp + add * m,                 // tip
        rr = max(0.6, rp - 1.25 * m),      // root
        rs = max(rb + 0.02, rr),           // flanks start at the base circle
        a0 = flank(n, m, pa, bl, rs),
        a1 = flank(n, m, pa, bl, ro),
        pitch = 360 / n
    )
    [ for (k = [0 : n - 1]) let (o = k * pitch) each concat(
        // radial root step up to the start of the working flank
        [ if (rs > rr + 0.02) pol(rr, o - a0) ],
        // trailing flank, root -> tip
        [ for (i = [0 : steps]) let (r = rs + (ro - rs) * i / steps)
              pol(r, o - flank(n, m, pa, bl, r)) ],
        // tip arc
        [ for (i = [1 : 3]) pol(ro, o - a1 + 2 * a1 * i / 4) ],
        // leading flank, tip -> root
        [ for (i = [steps : -1 : 0]) let (r = rs + (ro - rs) * i / steps)
              pol(r, o + flank(n, m, pa, bl, r)) ],
        [ if (rs > rr + 0.02) pol(rr, o + a0) ],
        // root arc across to the next tooth
        [ for (i = [1 : 2]) pol(rr, o + a0 + (pitch - 2 * a0) * i / 3) ]
    ) ];

module gear(n, h, add = 1.0, bore = 0) {
    difference() {
        linear_extrude(h, convexity = 10)
            polygon(gear_profile(n, gear_module, pressure_angle, backlash, add));
        if (bore > 0) translate([0, 0, -1]) cylinder(d = bore, h = h + 2);
    }
}

// =============================================================================
//  Small helpers
// =============================================================================
module ring(ri, ro, h) {
    difference() {
        cylinder(r = ro, h = h);
        translate([0, 0, -0.5]) cylinder(r = ri, h = h + 1);
    }
}

module pie(r, a) {
    rotate_extrude(angle = a)
        polygon([[0.02, -400], [r, -400], [r, 600], [0.02, 600]]);
}

// knurled thumbwheel blank, also used as the crank's spline socket
module knob_shape(d, h, grooves = 24) {
    difference() {
        cylinder(d = d, h = h);
        for (i = [0 : grooves - 1])
            rotate([0, 0, i * 360 / grooves])
                translate([d / 2, 0, -0.5]) cylinder(d = 2 + fit, h = h + 1);
    }
}

// Cut a big disc into printable sectors, with cross dowels across every joint.
module split(r_max, z) {
    if (sectors <= 1) children();
    else {
        a = 360 / sectors;
        intersection() {
            difference() {
                children();
                rotate([0, 0, split_rot])
                    for (k = [0 : sectors - 1]) rotate([0, 0, k * a])
                        for (rr = [0.45 * r_max, 0.82 * r_max])
                            translate([rr, 0, z]) rotate([90, 0, 0])
                                cylinder(d = dowel_dia + 0.3, h = 30, center = true);
            }
            rotate([0, 0, split_rot + sector_index * a]) pie(r_max, a);
        }
    }
}

module ball_groove() {
    rotate_extrude() translate([race_r, ball_z]) circle(d = ball_dia + 0.4);
}

// =============================================================================
//  Parts  (all modelled in assembly coordinates)
// =============================================================================
module base_outline() {
    union() {
        circle(r = base_r);
        translate([center_dist, 0]) circle(r = pod_r);
    }
}

module base() {
    split(140, plate_t / 2) difference() {
        union() {
            linear_extrude(plate_t) base_outline();
            cylinder(r = hub_r, h = hub_top);          // journal for the rotor
        }
        ball_groove();
        // sockets for the skirt's locating pegs
        for (i = [1 : skirt_pegs]) rotate([0, 0, i * 360 / (skirt_pegs + 1)])
            translate([base_r - skirt_wall / 2, 0, -0.01])
                cylinder(d = peg_d + 0.3, h = 4.6);
        if (drive == "thumbwheel") {
            translate([center_dist, 0, -1]) cylinder(d = 4.3, h = plate_t + 2);
            translate([center_dist, 0, -0.01])           // captive M4 nut
                cylinder(d = 8.1, h = 3.2, $fn = 6);
        } else {
            // NEMA 17 bolts straight onto the underside of the pod
            translate([center_dist, 0, -1]) cylinder(d = nema_shaft + 1.5, h = plate_t + 2);
            translate([center_dist, 0, -0.01]) cylinder(d = nema_pilot + 1, h = 2.5);
            for (x = [-nema_bolt / 2, nema_bolt / 2], y = [-nema_bolt / 2, nema_bolt / 2])
                translate([center_dist + x, y, -1]) cylinder(d = 3.3, h = plate_t + 2);
        }
        // lighten the plate between hub and race
        translate([0, 0, plate_t - 2.5 + 0.01]) ring(hub_r + 8, race_r - 12, 2.6);
    }
}

// Separate ring so both it and the base plate print flat, with no bridging.
// The gap around the drive pod clears the stepper (or the M4 nut) and doubles
// as the access hatch.
module skirt() {
    difference() {
        union() {
            ring(base_r - skirt_wall, base_r, skirt_h);
            for (i = [1 : skirt_pegs]) rotate([0, 0, i * 360 / (skirt_pegs + 1)])
                translate([base_r - skirt_wall / 2, 0, skirt_h - 0.5])
                    cylinder(d = peg_d, h = 4.5);
        }
        translate([center_dist, 0, -1]) cylinder(r = 32, h = skirt_h + 2);
        for (i = [0 : vent_count - 1]) rotate([0, 0, i * 360 / vent_count])
            translate([base_r, 0, skirt_h / 2]) rotate([0, -90, 0])
                cylinder(d = vent_dia, h = skirt_wall + 6, center = true);
    }
}

module rotor() {
    split(rotor_r + 2, rotor_z + rotor_t / 2) difference() {
        translate([0, 0, rotor_z]) gear(rotor_teeth, rotor_t, rotor_add);
        translate([0, 0, rotor_z - 1]) cylinder(r = hub_r + fit, h = rotor_t + 2);
        ball_groove();
        translate([0, 0, rotor_z - 0.01]) ring(hub_r + 8, 60, 2.5);   // lightening
        for (i = [0 : pole_count - 1]) rotate([0, 0, i * 360 / pole_count])
            translate([pole_r, 0, pole_z]) cylinder(d = pole_dia + 0.4, h = socket_depth + 1);
    }
}

// Used instead of base + rotor + retainer + pinion + cap when the mechanism
// rides on a bought motorised turntable: a plain disc that drops over the
// platform and carries the poles.
module adapter() {
    split(rotor_r + 2, adapter_t / 2) difference() {
        cylinder(r = rotor_r, h = adapter_t);
        translate([0, 0, -0.01])                       // locates on the platform
            cylinder(d = platform_dia + 1, h = platform_recess);
        for (i = [0 : pole_count - 1]) rotate([0, 0, i * 360 / pole_count])
            translate([pole_r, 0, adapter_t - socket_depth])
                cylinder(d = pole_dia + 0.4, h = socket_depth + 1);
        // grip pockets for double-sided tape or silicone pads
        for (i = [0 : 3]) rotate([0, 0, 45 + i * 90])
            translate([platform_dia / 2 - 12, 0, -0.01]) cylinder(d = 12, h = 1.2);
    }
}

module retainer() {
    difference() {
        ring(race_r - 6, race_r + 6, retainer_t);
        for (i = [0 : ball_count - 1]) rotate([0, 0, i * 360 / ball_count])
            translate([race_r, 0, -0.5]) cylinder(d = ball_dia + 0.6, h = retainer_t + 1);
    }
}

module pinion() {
    bore = (drive == "nema17") ? nema_shaft + 0.15 : 4.35;
    difference() {
        union() {
            translate([0, 0, plate_t]) cylinder(d = 12, h = pinion_boss_h);   // thrust boss
            translate([0, 0, plate_t + pinion_boss_h]) gear(pinion_teeth, pinion_gear_h, pinion_add);
            translate([0, 0, knob_z]) knob_shape(knob_dia, knob_h);
        }
        translate([0, 0, plate_t - 1]) cylinder(d = bore, h = knob_z + knob_h + 2);
        if (drive == "thumbwheel")
            translate([0, 0, knob_z + knob_h - 4]) cylinder(d = 8.6, h = 5); // screw head
        else                                        // M3 grub against the shaft
            translate([0, 0, knob_z + 2.5]) rotate([0, 90, 0])
                cylinder(d = 2.9, h = knob_dia / 2 + 1);
    }
}

module canopy() {
    split(canopy_r + 2, canopy_z + 4) translate([0, 0, canopy_z]) difference() {
        union() {
            difference() {                                       // 3 mm-ish shell
                cylinder(r1 = canopy_r, r2 = 8, h = canopy_rise);
                translate([0, 0, -0.01])
                    cylinder(r1 = canopy_r - canopy_wall, r2 = 2, h = canopy_rise - 3);
            }
            ring(pole_r - 6, canopy_r, eave_h);   // eave band, holds the poles
            cylinder(d = 18, h = canopy_rise - 2);               // finial hub
        }
        for (i = [0 : pole_count - 1]) rotate([0, 0, i * 360 / pole_count])
            translate([pole_r, 0, -1]) cylinder(d = pole_dia + 0.4, h = canopy_grip + 1);
        translate([0, 0, canopy_rise - 12]) cylinder(d = peg_dia + fit, h = 14);
    }
}

module pole() {
    cylinder(d1 = pole_dia - 1.2, d2 = pole_dia, h = 0.6);
    translate([0, 0, 0.6]) cylinder(d = pole_dia, h = pole_len - 1.2);
    translate([0, 0, pole_len - 0.6]) cylinder(d1 = pole_dia, d2 = pole_dia - 1.2, h = 0.6);
}

module finial() {
    cylinder(d = peg_dia, h = 10);
    translate([0, 0, 10]) cylinder(d1 = 16, d2 = 12, h = 6);
    translate([0, 0, 16]) sphere(d = 18);
    translate([0, 0, 24]) cylinder(d1 = 10, d2 = 1.6, h = 22);
}

// optional lever handle: splines onto the thumbwheel for more torque
module crank(arm = 60) {
    difference() {
        union() {
            hull() {
                cylinder(d = knob_dia + 8, h = 10);
                translate([arm, 0, 0]) cylinder(d = 16, h = 10);
            }
            translate([arm, 0, 10]) cylinder(d = 9, h = 16);
            translate([arm, 0, 26]) cylinder(d1 = 13, d2 = 10, h = 3);
        }
        translate([0, 0, -0.01]) knob_shape(knob_dia + 2 * fit, 8);
    }
}

// clip-on hook for hanging little horses / decorations from a pole
module hanger() {
    difference() {
        union() {
            cylinder(d = pole_dia + 5, h = 6);
            hull() {
                cylinder(d = pole_dia + 5, h = 6);
                translate([12, 0, 0]) cylinder(d = 5, h = 6);
            }
            translate([12, 0, -8]) cylinder(d = 3, h = 9);
            translate([12, 0, -9.5]) sphere(d = 4.5);
        }
        translate([0, 0, -1]) cylinder(d = pole_dia + 0.35, h = 8);
        translate([-20, -1.5, -1]) cube([20, 3, 8]);          // snap-on opening
    }
}

// =============================================================================
//  Assembly / print layout
// =============================================================================
module assembly() {
    if (base_style == "printed") {
        color("Gainsboro") base();
        color("SteelBlue") rotate([0, 0, demo_angle]) rotor();
        color("Silver")    translate([0, 0, ball_z - retainer_t / 2]) retainer();
        color("Tomato")    translate([center_dist, 0, 0])
                               rotate([0, 0, 180 / pinion_teeth - demo_angle * ratio]) pinion();
        color("Gainsboro") translate([0, 0, -skirt_h]) skirt();
        if (show_ghosts)
            % for (i = [0 : ball_count - 1]) rotate([0, 0, i * 360 / ball_count])
                translate([race_r, 0, ball_z]) sphere(d = ball_dia);
    } else {
        color("SteelBlue") rotate([0, 0, demo_angle])
            translate([0, 0, platform_h - platform_recess]) adapter();
        if (show_ghosts) % cylinder(d = platform_dia, h = platform_h);
    }
    rotate([0, 0, demo_angle]) {
        color("Tomato") canopy();
        color("Ivory") for (i = [0 : pole_count - 1]) rotate([0, 0, i * 360 / pole_count])
            translate([pole_r, 0, pole_z]) pole();
        color("Goldenrod") translate([0, 0, canopy_z + canopy_rise - 12]) finial();
    }
    if (show_ghosts)                                   // cake board and cake
        % rotate([0, 0, demo_angle]) translate([0, 0, plate_top])
            cylinder(d = 152, h = 112);
}

module print_plate() {
    if (base_style == "printed") {
        base();
        translate([300, 0, -rotor_z])  rotor();
        translate([300, 260, 0])       retainer();
        translate([0, 260, -plate_t])  pinion();
        translate([0, 280, 0])         skirt();
        if (drive == "thumbwheel") translate([540, 220, 0]) crank();
    } else {
        translate([300, 0, 0]) adapter();
    }
    translate([600, 0, -canopy_z])      canopy();
    translate([600, 220, 0])            finial();
    for (i = [0 : pole_count - 1]) translate([560 + i * 10, 300, 0]) pole();
    for (i = [0 : 3]) translate([480, 160 + i * 16, 9.5]) rotate([180, 0, 0]) hanger();
}

if      (part == "assembly")     assembly();
else if (part == "print_plate")  print_plate();
else if (part == "base")         base();
else if (part == "skirt")        skirt();
else if (part == "rotor")        rotor();
else if (part == "adapter")      adapter();
else if (part == "retainer")     retainer();
else if (part == "pinion")       pinion();
else if (part == "canopy")       canopy();
else if (part == "pole")         pole();
else if (part == "finial")       finial();
else if (part == "crank")        crank();
else if (part == "hanger")       hanger();
else echo("unknown part");
