# Cake Carousel

A parametric carousel that turns a cake: a printed ball-race turntable, a small
gear drive, eight poles and a canopy. Modelled twice — once in **OpenSCAD** and
once in **FreeCAD** — from the same numbers and the same involute maths, so you
can work in whichever tool you prefer.

```
turntable        Ø 189.4 mm (a 93-tooth gear wheel, module 2)
reduction        6.64 : 1  (93 : 14)
overall height   286 mm with the finial
cake it suits    up to Ø 152 mm (6") and ~110 mm tall
```

| File | What it is |
|---|---|
| [carousel.scad](carousel.scad) | OpenSCAD model, all parts, assembly and print layout |
| [carousel_freecad.FCMacro](carousel_freecad.FCMacro) | FreeCAD macro building the same solids with OpenCascade (STEP output) |
| [BOM.md](BOM.md) | Bill of materials — two versions, ready-made base or NEMA 17 |

## How it works

* The **rotor** is a 93-tooth gear wheel. It sits on 40 loose 6 mm balls running
  in matching grooves in the rotor and the **base** — a printed thrust bearing
  that carries the cake, with a **retainer** ring keeping the balls spaced.
* The rotor is centred by a plain journal: its bore turns on the base's hub. The
  hub stops 0.3 mm below the rotor's top face, so a food-safe cake board sits
  flat straight on the turntable. Nothing clamps the rotor down — lift it off to
  clean, like any lazy-susan cake stand.
* A 14-tooth **pinion** sits just outside the rim on the base's drive pod. Turn
  its knurled thumbwheel (or bolt a NEMA 17 under the pod) and the wheel turns
  6.64 times slower — heavy, smooth and slow, which is what looks right.
* Eight **poles** rise from the rotor into the **canopy**'s eave band, topped by
  the **finial**, so roof and cake turn together. Optional **hanger** clips snap
  onto the poles for little horses.
* The **skirt** is a separate ring that lifts the base clear of the table, hides
  the works, and has a gap at the drive pod for the motor or the M4 nut.

## Quick start

OpenSCAD — preview the whole thing:

```bash
openscad carousel.scad
```

Export one part for printing:

```bash
openscad -o rotor.stl -D 'part="rotor"' carousel.scad
```

FreeCAD — open `carousel_freecad.FCMacro` via *Macro → Macros… → Execute*, or
head-less, with STEP + STL written to `./out`:

```bash
CAROUSEL_PART=rotor CAROUSEL_EXPORT=./out freecadcmd carousel_freecad.FCMacro
```

`part` / `CAROUSEL_PART` takes: `assembly`, `print_plate`, `base`, `skirt`,
`rotor`, `adapter`, `retainer`, `pinion`, `canopy`, `pole`, `finial`, `crank`,
`hanger`.

## Configurations

| Setting | Values | Effect |
|---|---|---|
| `base_style` | `printed` (default), `turntable` | printed base + ball race, or an `adapter` disc that drops onto a bought Ø 130 mm motorised turntable |
| `drive` | `thumbwheel` (default), `nema17` | knurled thumbwheel on an M4 pivot, or a NEMA 17 bolted under the pod (5 mm bore + grub screw, deeper skirt, 31 mm bolt square) |
| `sectors` | `0`, `2`, `3`, `4` | cut base / rotor / adapter / canopy into printable pie sectors, dowelled across each joint |
| `demo_angle` | degrees | spins the preview; the pinion stays correctly meshed |

In FreeCAD these are the `CAROUSEL_BASE_STYLE`, `CAROUSEL_DRIVE`,
`CAROUSEL_SECTORS`, `CAROUSEL_SECTOR_INDEX` and `CAROUSEL_DEMO_ANGLE`
environment variables.

### Printing on a small bed

The base is 239 × 220 mm (243 with the NEMA 17 pod) and the rotor Ø 189 mm. If that does not fit:

```bash
openscad -o base_a.stl -D 'part="base"' -D sectors=3 -D sector_index=0 carousel.scad
openscad -o base_b.stl -D 'part="base"' -D sectors=3 -D sector_index=1 carousel.scad
openscad -o base_c.stl -D 'part="base"' -D sectors=3 -D sector_index=2 carousel.scad
```

Each joint gets two cross-drilled 3 mm dowel holes; glue up with filament
offcuts through them. `split_rot` (default 28°) keeps the cut planes away from
the drive pod.

## Parameters worth touching

| Parameter | Default | Note |
|---|---|---|
| `rotor_teeth`, `pinion_teeth` | 93, 14 | sets both the size and the ratio; the file asserts the pair is geometrically sound |
| `gear_module` | 2 | bigger = coarser, stronger teeth |
| `backlash` | 0.30 mm | total; loosen to 0.4 if your printer runs fat |
| `fit` | 0.25 mm | clearance per side on every sliding fit |
| `ball_dia` | 6 | set 6.35 for 1/4″ balls |
| `pole_len`, `canopy_rise` | 160, 80 | how tall and how domed |
| `platform_dia`, `platform_h` | 130, 30 | your bought turntable, if not the one in the BOM |

The gear maths is guarded by asserts in both files: tooth-tip interference in
both directions, pointed teeth, the pinion fouling the wheel's roots, the
thumbwheel fouling the rim, and the pod being big enough. Change the tooth
counts to something unworkable and the model refuses to build rather than
quietly producing gears that bind.

## Print orientation

| Part | Orientation | Notes |
|---|---|---|
| `base` | as modelled, plate down | large flat first layer, brim helps |
| `skirt` | as modelled, pegs up | |
| `rotor` | as modelled, race groove down | the groove narrows upwards, so it self-supports |
| `adapter` | **flipped**, top face down | so the platform recess opens upwards |
| `retainer` | flat | |
| `pinion` | as modelled | 4–5 perimeters: these teeth do the work |
| `canopy` | as modelled, apex up | the cone leans inward, no supports needed |
| `pole` | upright | or use 6 mm hardwood dowels instead |
| `finial` | as modelled, spigot down | |
| `hanger` | **flipped**, hook up | |

0.2 mm layers, 3 perimeters, 20 % infill, PLA or PETG. No supports anywhere.
`part="print_plate"` lays every part out side by side if you would rather slice
one file.

## Assembly

**Printed base**

1. Press the skirt's seven pegs into the sockets in the base's underside; a dab
   of glue if they are loose.
2. Fit the drive. *Thumbwheel:* M4 nut into the hex pocket under the pod, pinion
   over the hole, M4 × 25 down through it — snug, but leave the pinion free to
   spin. *NEMA 17:* four M3 × 8 up through the pod into the motor face, then the
   pinion onto the 5 mm shaft, set at the height where its teeth line up with
   the rotor's, and nip the grub screw.
3. Lay the retainer into the base's race groove and drop a ball into each of its
   40 holes.
4. Lower the rotor over the hub. It should turn with a finger and the thumbwheel
   should drive it without a tight spot anywhere in a full revolution.
5. Poles into the rotor's eight sockets, canopy onto the poles, finial into the
   canopy's hub.
6. Cake board onto the rotor, cake onto the board.

**Ready-made turntable**

1. Stick four silicone pads into the adapter's grip pockets.
2. Drop the adapter over the platform — the recess centres it.
3. Poles, canopy, finial, board, cake, as above.

## What has been checked

* Both files build every part as a single closed solid: CGAL reports one volume
  per part in OpenSCAD, and OCC reports `isValid() == True`, one solid per part,
  in FreeCAD.
* The two files agree on geometry: every part's volume matches within 0.5 %
  (worst case 0.46 % on the poles), the remainder being OpenSCAD's polygonised
  circles against OCC's exact ones. That comparison is worth re-running after
  any edit — it is what caught a wrong tangent angle in the FreeCAD hull helper,
  which had quietly misshaped the crank and the hanger.
* The gear pair was checked two ways. A Python sweep of the analytic profiles
  across a full tooth pitch (61 positions) finds no crossing anywhere and a
  minimum flank gap of 0.28 mm — the intended backlash. Then the real solids
  were intersected in OpenSCAD at four rotor angles; every intersection is
  empty.
* The wheel's addendum is deliberately shortened (`rotor_add = 0.85`). At a full
  addendum, a 14-tooth pinion this size would be driven past the point where its
  flank is still a true involute — the assert catches it.

Re-run the interference check yourself with the shipped
[mesh_test.scad](mesh_test.scad) — "Current top level object is empty" is the
pass, and one tooth pitch is 3.87°:

```bash
for a in 0 1 2 3; do openscad -o /dev/null -D 'part="none"' -D demo_angle=$a mesh_test.scad; done
```

## Cleaning and food safety

Nothing printed touches the cake: it sits on a food-safe board on the turntable,
and the poles stand outside the cake's Ø 152 mm envelope. Printed plastic is not
a food-contact material — layer lines hold bacteria and PLA will not take a hot
wash. Lift the rotor off, tip the balls out and hand-wash in cool water.

## Caveats

* Nothing retains the rotor. Don't lift the stand by the turntable or the canopy
  — pick it up by the base.
* On a bought turntable the whole load goes through its little platform; see the
  weight limits in [BOM.md](BOM.md).
* The canopy is the big print: about 190 cm³ of solid volume and several hours.
  Raise `canopy_wall` for strength, or drop `canopy_rise` for a squatter roof.
