// =============================================================================
//  CAKE CAROUSEL -- FRICTION DRIVE MECHANISM
// =============================================================================
//  Mechanism only: a bought turntable (lazy-susan) bearing carries the load, a
//  NEMA 17 hanging under the base spins an O-ring tyre against the rim of the
//  platter.  No gear teeth anywhere.
//
//  Three printed parts: BASE, PLATTER, ROLLER.
//
//  Why friction works here
//    * A 100 mm bearing under a 2 kg cake needs about 0.05 Nm at the platter,
//      i.e. ~0.5 N at the rim.  An O-ring squeezed 0.4 mm presses with 2-4 N and
//      grips at mu ~= 0.7, so traction margin is about 4x -- from the rubber
//      alone, with no spring in the mount.
//    * 17 Ncm of motor through 8.8:1 is ~30x the torque required.
//    * Nothing needs to know the angle, so slip costs nothing.  It is a safety
//      feature: grab the cake and the tyre slips instead of stalling the motor.
//    * Set-up is one adjustment: slide the motor in its slots until the tyre
//      just squeezes the rim, then tighten its own four screws.
//
//  The platter matches carousel.scad's rotor -- same 190 mm diameter and the
//  same ring of eight pole sockets -- so the canopy, poles and finial from the
//  geared design drop straight on.
//
//  Companion file: friction_drive.FCMacro (same geometry, FreeCAD/OCC).
//  Units: mm.  Requires OpenSCAD 2021.01 or newer.
// =============================================================================

/* [Render] */
part = "assembly"; // [assembly, print_plate, base, platter, roller]
// ghost the bearing, the motor and the cake
show_ghosts = true;
// preview: how far the cake has turned
demo_angle = 0;    // [0:5:360]

/* [Split for small print beds] */
sectors = 0;       // [0, 2, 3, 4]
sector_index = 0;  // [0:3]
split_rot = 40;
dowel_dia = 3;

/* [Platter] */
platter_dia = 190;
platter_t   = 6;
rim_drop    = 3;    // rim flange below the platter: deepens the drive band
// pole sockets, so the canopy from carousel.scad fits
with_poles   = true;
pole_count   = 8;
pole_r       = 84;
pole_dia     = 6;
socket_depth = 4;

/* [Turntable bearing] */
// MEASURE YOURS -- these are 4 inch nominals
bearing_shape = "square";  // [square, round]
bearing_size  = 100;       // side of the square, or diameter if round
bearing_h     = 8;         // closed height, plate face to plate face
pocket_depth = 1.5;   // recess that captures each stamped plate
pocket_fit   = 0.4;
// pilot holes for optional M3 screws, on the diagonals: pick the pair that
// lines up with your bearing's holes
pilot_dia = 2.5;
pilot_rs  = [36, 42, 48, 54];

/* [Base] */
base_dia   = 210;
base_t     = 6;
leg_count  = 4;
leg_dia    = 14;
leg_h      = 34;      // must clear the motor hanging underneath
leg_r      = 90;

/* [Drive] */
roller_dia = 20;      // body; the tyre sits in a groove in it
roller_h   = 12;
oring_id   = 16;      // nitrile O-ring, 16 x 3 is a stock size
oring_cs   = 3;
squish     = 0.4;     // how far the tyre is crushed at the rim
travel     = 12;      // adjustment range of the motor slots
shaft_dia  = 5;
shaft_len  = 21;      // NEMA 17 pancake, measured from the motor face

/* [Motor] */
nema_bolt   = 31;     // bolt square
nema_pilot  = 22;     // pilot boss diameter
nema_body   = 42.3;
nema_length = 23;     // pancake; 40 for a full-size NEMA 17

/* [Fit] */
fit = 0.25;
$fa = 2;
$fs = 0.5;

// ---------------------------------------------------------------- derived ---
platter_r = platter_dia / 2;
base_r    = base_dia / 2;
oring_od  = oring_id + 2 * oring_cs;
tyre_r    = oring_od / 2;                       // tyre radius, uncompressed
axis_r    = platter_r + tyre_r - squish;        // motor axis at nominal squeeze
ratio     = platter_r / (tyre_r - squish / 2);  // rolling radii
motor_pad_r = nema_bolt / 2 * sqrt(2) + travel / 2 + 5;

pocket_sq  = bearing_size + pocket_fit;
// radius the bearing's plates sweep as they turn
swept_r    = (bearing_shape == "square") ? bearing_size * sqrt(2) / 2
                                        : bearing_size / 2;
platter_z  = base_t + bearing_h - 2 * pocket_depth;   // platter underside
platter_top = platter_z + platter_t;
band_bot   = platter_z - rim_drop;                    // drive band, lower edge
roller_z   = band_bot - 1;
groove_z   = roller_z + roller_h / 2;                 // tyre centre height

echo(str("platter ", platter_dia, " mm  |  friction reduction ", ratio,
         ":1  |  platter top at ", platter_top, " mm"));
echo(str("one motor turn = ", 360 / ratio, " deg of cake; 3 rpm cake = ",
         3 * ratio, " rpm motor"));

// --------------------------------------------------------------- guards ----
assert(platter_r > swept_r + 2,
       "platter is too small to cover the bearing's plates as they sweep");
assert(base_r > swept_r + 2, "base is too small for the bearing");
assert(travel > squish + 4, "motor slots are too short to disengage the tyre");
assert(shaft_len > roller_z + roller_h - base_t + nema_pilot * 0, 
       "motor shaft is too short to reach the tyre: shorten roller_h");
assert(roller_dia > oring_id + 1, "roller body is smaller than the O-ring bore");
assert(oring_cs > pocket_fit + 1, "O-ring section too small to grip");
assert(groove_z > band_bot && groove_z < platter_top,
       "tyre does not line up with the platter's drive band");
assert(leg_h > nema_length + 5, "legs are too short: the motor would touch down");
assert(axis_r - nema_body * sqrt(2) / 2 > 0, "motor body reaches past the centre");
assert(!with_poles || pole_r + pole_dia < platter_r - 2,
       "pole sockets are too close to the drive rim");

// =============================================================================
//  Helpers
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

// radially elongated hole, centred on the nominal position
module slot(x, y, d, len, h, z = 0) {
    hull() for (s = [-1, 1]) translate([x + s * len / 2, y, z]) cylinder(d = d, h = h);
}

// Cut a disc into printable sectors, dowelled across every joint.
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

// A pocket in each plate captures the bearing.  With a SQUARE bearing that
// pocket also takes the drive torque, so the screws are optional and any hole
// pattern will do.  A ROUND bearing can spin in its pocket, so there the
// screws are what hold it -- measure your hole positions and set pilot_rs.
module bearing_pocket(z) {
    translate([0, 0, z])
        if (bearing_shape == "square")
            linear_extrude(pocket_depth + 1)
                square([pocket_sq, pocket_sq], center = true);
        else
            cylinder(d = pocket_sq, h = pocket_depth + 1);
}

module pilot_holes(z, h) {
    for (a = [45 : 90 : 315], r = pilot_rs)
        rotate([0, 0, a]) translate([r, 0, z]) cylinder(d = pilot_dia, h = h);
}

// =============================================================================
//  Parts
// =============================================================================
module base_outline() {
    union() {
        circle(r = base_r);
        translate([axis_r, 0]) circle(r = motor_pad_r);
    }
}

module base() {
    split(base_r + motor_pad_r, base_t / 2) difference() {
        union() {
            linear_extrude(base_t) base_outline();
            for (i = [0 : leg_count - 1]) rotate([0, 0, 45 + i * 360 / leg_count])
                translate([leg_r, 0, -leg_h]) cylinder(d = leg_dia, h = leg_h + 0.5);
        }
        // bearing seat, in the top face
        bearing_pocket(base_t - pocket_depth);
        pilot_holes(-1, base_t + 2);
        // motor: four slots on the bolt square, a slot for the shaft, and a
        // pocket for the pilot boss.  Slide the motor to set the squeeze.
        for (sy = [-1, 1], sx = [-1, 1])
            slot(axis_r + sx * nema_bolt / 2, sy * nema_bolt / 2, 3.4, travel, base_t + 2, -1);
        slot(axis_r, 0, shaft_dia + 2, travel, base_t + 2, -1);
        slot(axis_r, 0, nema_pilot + 1.5, travel, 2.5, -0.01);
        // felt pad recesses under the legs
        for (i = [0 : leg_count - 1]) rotate([0, 0, 45 + i * 360 / leg_count])
            translate([leg_r, 0, -leg_h - 0.01]) cylinder(d = leg_dia - 2, h = 1);
        // anchor post hole, in case you want to add a rubber band preload
        translate([axis_r + motor_pad_r - 6, 0, -1]) cylinder(d = 3.2, h = base_t + 2);
    }
}

module platter() {
    split(platter_r + 2, platter_z + platter_t / 2) difference() {
        union() {
            translate([0, 0, platter_z]) cylinder(r = platter_r, h = platter_t);
            // rim flange: gives the tyre a 9 mm tall band to run on
            translate([0, 0, band_bot]) ring(platter_r - 5, platter_r, rim_drop + 0.5);
        }
        bearing_pocket(platter_z - 0.01);
        pilot_holes(platter_z - 1, platter_t + 2);
        // lighten it, keeping the bearing seat and the rim solid
        translate([0, 0, platter_z - 0.01])
            ring(swept_r + 3, platter_r - 12, 2.5);
        if (with_poles)
            for (i = [0 : pole_count - 1]) rotate([0, 0, i * 360 / pole_count])
                translate([pole_r, 0, platter_top - socket_depth])
                    cylinder(d = pole_dia + 0.4, h = socket_depth + 1);
    }
}

module roller() {
    difference() {
        cylinder(d = roller_dia, h = roller_h);
        // tyre groove: the O-ring stands proud and does the driving
        translate([0, 0, roller_h / 2 - (oring_cs + 0.2) / 2])
            ring(oring_id / 2, roller_dia / 2 + 1, oring_cs + 0.2);
        translate([0, 0, -1]) cylinder(d = shaft_dia + 0.15, h = roller_h + 2);
        // M3 grub screw onto the flat of the shaft
        translate([0, 0, 3]) rotate([0, 90, 0]) cylinder(d = 2.9, h = roller_dia);
    }
}

// =============================================================================
//  Assembly / print layout
// =============================================================================
module ghost_bearing() {
    for (z = [base_t - pocket_depth, platter_z + pocket_depth - 1.2])
        % translate([0, 0, z])
            if (bearing_shape == "square")
                linear_extrude(1.2) square([bearing_size, bearing_size], center = true);
            else
                cylinder(d = bearing_size, h = 1.2);
    % translate([0, 0, base_t + bearing_h / 2 - pocket_depth])
        ring(bearing_size / 2 - 9, bearing_size / 2 - 6, 3);
}

module assembly() {
    color("Gainsboro") base();
    color("SteelBlue") rotate([0, 0, demo_angle]) platter();
    color("Tomato") translate([axis_r, 0, roller_z])
        rotate([0, 0, -demo_angle * ratio]) roller();
    if (show_ghosts) {
        ghost_bearing();
        // motor body, boss and shaft
        % translate([axis_r - nema_body / 2, -nema_body / 2, -nema_length])
            cube([nema_body, nema_body, nema_length]);
        % translate([axis_r, 0, 0]) cylinder(d = nema_pilot, h = 2);
        % translate([axis_r, 0, 0]) cylinder(d = shaft_dia, h = shaft_len);
        // the tyre
        % translate([axis_r, 0, groove_z]) rotate_extrude()
            translate([oring_id / 2 + oring_cs / 2, 0]) circle(d = oring_cs);
        // cake board and cake
        % rotate([0, 0, demo_angle]) translate([0, 0, platter_top])
            cylinder(d = 152, h = 112);
    }
}

module print_plate() {
    translate([0, 0, leg_h])            base();
    translate([260, 0, -band_bot])      platter();
    translate([260, 240, 0])            roller();
}

if      (part == "assembly")    assembly();
else if (part == "print_plate") print_plate();
else if (part == "base")        base();
else if (part == "platter")     platter();
else if (part == "roller")      roller();
else echo("unknown part");
