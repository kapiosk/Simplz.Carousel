// =============================================================================
//  CAKE MOCKUP -- proportions of the whole display, not a printable part
// =============================================================================
//  A massing model: plinth, two cake tiers sitting off-centre on it, then the
//  carousel's base, column, hat brim and conical roof.  Use it to judge
//  proportions and overall height before committing to anything.
//
//  Units are mm (cm in the comments, as you gave them).
//
//      openscad cake_mockup.scad
//      openscad -o mockup.png --camera=0,0,320,70,0,25,1900 cake_mockup.scad
// =============================================================================

/* [Plinth] */
plinth_r = 300;   // 30 cm
plinth_h =  20;   //  4 cm

/* [Cake] */
// the cake sits off-centre on the plinth; everything above follows it
cake_offset = 0; // 5 cm
tier1_r  = 220;   // 20 cm
tier1_h  = 150;   // 15 cm
tier2_r  = 180;   // 18 cm
tier2_h  = 150;   // 15 cm

/* [Carousel] */
carousel_r = 150; // 15 cm
carousel_h =  65; // 6.5 cm
column_r   =  30; //  3 cm
column_h   = 130; // 13 cm
brim_r     = 150; // 15 cm
brim_h     =  20; //  2 cm
roof_r     = 150; // 15 cm
roof_h     =  80; //  7 cm

/* [View] */
// slice the whole thing in half to read the stack
section = false;
$fa = 2;
$fs = 1;

// ---------------------------------------------------------------- derived ---
z_tier1    = plinth_h;
z_tier2    = z_tier1 + tier1_h;
z_carousel = z_tier2 + tier2_h;
z_column   = z_carousel + carousel_h;
z_brim     = z_column + column_h;
z_roof     = z_brim + brim_h;
total_h    = z_roof + roof_h;

echo(str("plinth top   ", z_tier1,    " mm"));
echo(str("tier 1 top   ", z_tier2,    " mm"));
echo(str("tier 2 top   ", z_carousel, " mm  <- the carousel sits here"));
echo(str("column top   ", z_brim,     " mm"));
echo(str("roof base    ", z_roof,     " mm"));
echo(str("TOTAL HEIGHT ", total_h, " mm (", total_h / 10, " cm)"));
echo(str("widest       ", 2 * plinth_r, " mm plinth, ", 2 * tier1_r, " mm cake"));
echo(str("plinth margin ", plinth_r - cake_offset - tier1_r, " mm on the offset side, ",
         plinth_r + cake_offset - tier1_r, " mm on the other"));

// =============================================================================
module stack() {
    color("Gainsboro")                                  // plinth
        cylinder(r = plinth_r, h = plinth_h);

    translate([cake_offset, 0, 0]) {
        color("Wheat")                                  // bottom tier
            translate([0, 0, z_tier1]) cylinder(r = tier1_r, h = tier1_h);
        color("MistyRose")                              // top tier
            translate([0, 0, z_tier2]) cylinder(r = tier2_r, h = tier2_h);

        color("SteelBlue")                              // carousel base
            translate([0, 0, z_carousel]) cylinder(r = carousel_r, h = carousel_h);
        color("Silver")                                 // column
            translate([0, 0, z_column]) cylinder(r = column_r, h = column_h);
        color("Tomato")                                 // hat brim
            translate([0, 0, z_brim]) cylinder(r = brim_r, h = brim_h);
        color("Tomato")                                 // conical roof
            translate([0, 0, z_roof]) cylinder(r1 = roof_r, r2 = 0, h = roof_h);
    }
}

if (section)
    difference() {
        stack();
        translate([-1000, 0, -10]) cube([2000, 1000, 2000]);
    }
else
    stack();
