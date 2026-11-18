// =============================================================================
//  ROOF -- the carousel's hat on its own: Ø15 cm brim, 2 cm, with a 7 cm cone
// =============================================================================
//  The same part as the brim and roof cone in cake_mockup.scad, standing on
//  Z 0. Its sizes (brim_d, brim_h, roof_d, roof_h) live in cake_mockup.scad,
//  so the two never disagree: edit them there. Three are needed.
//
//      openscad roof.scad
//      openscad -o roof.stl roof.scad
// =============================================================================

include <cake_mockup.scad>

part = "roof";   // overrides the include's "stack": the last assignment wins
