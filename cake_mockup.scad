// =============================================================================
//  CAKE MOCKUP -- proportions of the whole display, not a printable part
// =============================================================================
//  A massing model: plinth, two cake tiers sitting off-centre on it, then the
//  carousel's base, column, hat brim and conical roof.  Use it to judge
//  proportions and overall height before committing to anything.
//
//  Units are mm (cm in the comments, as you gave them).  Every size is a
//  DIAMETER: plinth_d = 300 is a plinth 30 cm across.
//
//      openscad cake_mockup.scad
//      openscad -o mockup.png --camera=0,0,320,70,0,25,1900 cake_mockup.scad
// =============================================================================

/* [Plinth] */
plinth_d = 300;   // Ø30 cm
plinth_h =  20;   //  2 cm

/* [Cake] */
// shift the cake off-centre on the plinth; everything above follows it
cake_offset =   0; //  0 cm
tier1_d  = 220;   // Ø22 cm
tier1_h  = 150;   // 15 cm
tier2_d  = 180;   // Ø18 cm
tier2_h  = 150;   // 15 cm

/* [Carousel] */
carousel_d = 150; // Ø15 cm
carousel_h =  65; // 6.5 cm
column_d   =  30; // Ø3 cm
column_h   = 130; // 13 cm
brim_d     = 150; // Ø15 cm
brim_h     =  20; //  2 cm
roof_d     = 150; // Ø15 cm
roof_h     =  80; //  8 cm

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
echo(str("widest       ", plinth_d, " mm plinth, ", tier1_d, " mm cake"));
echo(str("plinth margin ", (plinth_d - tier1_d) / 2 - cake_offset, " mm on the offset side, ",
         (plinth_d - tier1_d) / 2 + cake_offset, " mm on the other"));
echo(str("carousel deck margin on the top tier ", (tier2_d - carousel_d) / 2, " mm"));

// =============================================================================
module stack() {
    color("Gainsboro")                                  // plinth
        cylinder(d = plinth_d, h = plinth_h);

    translate([cake_offset, 0, 0]) {
        color("Wheat")                                  // bottom tier
            translate([0, 0, z_tier1]) cylinder(d = tier1_d, h = tier1_h);
        color("MistyRose")                              // top tier
            translate([0, 0, z_tier2]) cylinder(d = tier2_d, h = tier2_h);

        color("SteelBlue")                              // carousel base
            translate([0, 0, z_carousel]) cylinder(d = carousel_d, h = carousel_h);
        color("Silver")                                 // column
            translate([0, 0, z_column]) cylinder(d = column_d, h = column_h);
        color("Tomato")                                 // hat brim
            translate([0, 0, z_brim]) cylinder(d = brim_d, h = brim_h);
        color("Tomato")                                 // conical roof
            translate([0, 0, z_roof]) cylinder(d1 = roof_d, d2 = 0, h = roof_h);
    }
}

if (section)
    difference() {
        stack();
        translate([-1000, 0, -10]) cube([2000, 1000, 2000]);
    }
else
    stack();
