// =============================================================================
//  CAROUSEL BASE -- the hollow part on its own: Ø15 cm, 5 cm tall, open at the top
// =============================================================================
//  A cup: Ø13 cm inside, 4 cm deep, on a 1 cm floor. The 1.5 cm deck disc sits
//  on it, and the two together are the 6.5 cm carousel in cake_mockup.scad.
//  The same part as "carousel base" in carousel_parts.solidcraft.json, standing
//  on Z 0. Its sizes (carousel_d, carousel_h, deck_h, base_wall, base_depth)
//  live in cake_mockup.scad, so the files never disagree: edit them there.
//  Three are needed.
//
//      openscad carousel_base.scad
//      openscad -o carousel_base.stl carousel_base.scad
// =============================================================================

include <cake_mockup.scad>

part = "base";   // overrides the include's "stack": the last assignment wins
