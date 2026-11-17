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
column_h   = 100; // 10 cm
brim_d     = 150; // Ø15 cm
brim_h     =  20; //  2 cm
roof_d     = 150; // Ø15 cm
roof_h     =  60; //  6 cm

/* [Horses] */
horse_count  = 4;
horse_h      = 55;    //  5.5 cm tall
horse_l      = 60;    //  6 cm nose to tail
horse_t      = 14;    //  1.4 cm thick
horse_ring_d = 110;   // Ø11 cm: the circle the horses stand on
horse_bob    = 12;    // alternate horses ride this much up / down
pole_d       = 4;     // brass pole through each horse

// Side profile of a prancing carousel horse, head to the right, in sketch units.
// It is smoothed and then scaled to exactly horse_l x horse_h, so these numbers
// only set the shape. cake_mockup_blender.py reads this same list.
horse_profile = [
    [100,60],[96,68],[90,78],[85,84],[84,91],[81,86],[78,85],           // face, ear, poll
    [72,82],[66,76],[61,68],[56,63],                                    // arched neck
    [48,61],[38,61],[30,62],[24,63],[20,61],                            // back, croup
    [14,59],[8,53],[4,45],[3,37],[6,41],[10,49],[15,54],[19,55],        // tail
    [20,50],[17,42],[12,30],[8,20],[6,12],[4,8],[9,7],[12,13],[15,22],  // hind leg, stretched back
    [20,32],[23,38],[24,36],[25,30],[25,18],[24,10],[23,6],[29,6],      // hind leg, planted
    [30,12],[30,22],[31,32],[33,38],[40,41],[50,41],[58,41],            // belly
    [62,33],[67,28],[64,22],[61,17],[63,14],[66,16],[69,22],[72,28],    // front leg, folded
    [70,33],[68,38],[74,37],[82,34],[80,27],[78,22],[81,19],[84,21],    // front leg, raised
    [86,28],[88,35],[84,41],[77,45],[74,49],[77,55],[81,58],[88,57],    // chest, throat, jaw
    [94,55],[98,56]
];
// Saddle, in the same sketch units, so it lands on the horse's back.
saddle_profile = [[38,58],[39,66],[43,64],[50,63],[55,64],[58,67],[59,60],[56,52],[41,52]];
pole_at = 48;         // sketch x of the pole: through the middle of the saddle

/* [View] */
// slice the whole thing in half to read the stack
section = false;
// show a single horse, side on, to judge its shape
horse_only = false;
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

// --------------------------------------------------------------- horses ---
// Chaikin corner-cutting: each pass replaces every corner with two points.
function chaikin(p) = [for (i = [0 : len(p) - 1])
    let (a = p[i], b = p[(i + 1) % len(p)]) each [a * 0.75 + b * 0.25, a * 0.25 + b * 0.75]];
function smooth(p, n) = n == 0 ? p : smooth(chaikin(p), n - 1);

horse_sk = smooth(horse_profile, 2);
hx0 = min([for (q = horse_sk) q[0]]);  hx1 = max([for (q = horse_sk) q[0]]);
hy0 = min([for (q = horse_sk) q[1]]);  hy1 = max([for (q = horse_sk) q[1]]);
hsx = horse_l / (hx1 - hx0);
hsy = horse_h / (hy1 - hy0);
// sketch units -> mm, centred on the horse
function fit(p) = [for (q = p) [(q[0] - (hx0 + hx1) / 2) * hsx, (q[1] - (hy0 + hy1) / 2) * hsy]];
pole_x = (pole_at - (hx0 + hx1) / 2) * hsx;

horse_mid   = z_column + column_h / 2;    // centre of the gap under the brim
horse_ring  = horse_ring_d / 2;
// clearances: horse corners against the brim / deck edge, and the gap between neighbours
horse_reach = sqrt(pow(horse_ring + horse_t / 2, 2) + pow(horse_l / 2, 2));
echo(str("horses: ", horse_count, " of ", horse_l, " x ", horse_h, " mm on a Ø", horse_ring_d,
         " ring; outer corners reach Ø", round(2 * horse_reach), " under a Ø", brim_d, " brim"));
assert(2 * horse_reach < min(brim_d, carousel_d), "horses stick out past the brim or the deck");
assert(horse_ring - horse_t / 2 > column_d / 2 + 2, "horses touch the column");
assert(horse_h / 2 + horse_bob < column_h / 2, "horses hit the deck or the brim when bobbing");

module horse(i) {
    a = 90 + i * 360 / horse_count;                   // ring position
    zm = horse_mid + (i % 2 == 0 ? horse_bob : -horse_bob);
    translate([horse_ring * cos(a), horse_ring * sin(a), zm])
        rotate([0, 0, a + 90]) {                       // face the way it turns
            rotate([90, 0, 0]) {
                color("Ivory")
                    linear_extrude(horse_t, center = true) polygon(fit(horse_sk));
                color(["Crimson", "RoyalBlue", "SeaGreen", "DarkOrchid"][i % 4])
                    linear_extrude(horse_t + 3, center = true)
                        polygon(fit(smooth(saddle_profile, 1)));
            }
            color("Goldenrod")                         // pole, deck to brim
                translate([pole_x, 0, z_column - zm]) cylinder(d = pole_d, h = column_h);
        }
}

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

        for (i = [0 : horse_count - 1]) horse(i);
    }
}

if (horse_only)
    rotate([90, 0, 0]) {
        color("Ivory") linear_extrude(horse_t, center = true) polygon(fit(horse_sk));
        color("Crimson") linear_extrude(horse_t + 3, center = true)
            polygon(fit(smooth(saddle_profile, 1)));
    }
else if (section)
    difference() {
        stack();
        translate([-1000, 0, -10]) cube([2000, 1000, 2000]);
    }
else
    stack();
