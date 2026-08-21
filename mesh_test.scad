// Gear mesh interference check.
//
//   openscad -o /dev/null -D 'part="none"' -D demo_angle=3 mesh_test.scad
//
// A pass prints "Current top level object is empty": at that rotor angle the
// wheel and the pinion share no material.  Sweep demo_angle over one tooth
// pitch (360/rotor_teeth = 3.87 deg) to cover the whole mesh cycle.
include <carousel.scad>

a = demo_angle;
intersection() {
    rotate([0, 0, a]) rotor();
    translate([center_dist, 0, 0])
        rotate([0, 0, 180 / pinion_teeth - a * ratio]) pinion();
}
