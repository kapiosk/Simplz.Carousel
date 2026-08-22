# Friction Drive Mechanism

Mechanism only, no gear teeth: a bought turntable bearing carries the cake, and a
NEMA 17 hanging under the base spins an O-ring tyre against the rim of the
platter. **Three printed parts.**

```
platter          Ø 190 mm, top face 17 mm above the table
reduction        8.8 : 1   (rim 95 mm / tyre 10.8 mm rolling radius)
one motor turn   41° of cake        3 rpm cake = 26 rpm motor
printed volume   365 cm³ solid (base 220, platter 141, roller 3)
bought parts     bearing, motor, one O-ring, four screws
```

| File | |
|---|---|
| [friction_drive.scad](friction_drive.scad) | OpenSCAD model |
| [friction_drive.FCMacro](friction_drive.FCMacro) | Same geometry in FreeCAD/OCC, with STEP export |
| [friction_drive.µcad](friction_drive.µcad) | Same geometry again in µcad 0.5 — see [MICROCAD.md](MICROCAD.md) |

The platter deliberately matches [carousel.scad](carousel.scad)'s rotor — same
Ø 190 mm, same ring of eight pole sockets at r = 84 — so the canopy, poles and
finial from the geared design drop straight on.

## Is friction a bad idea here? No — it's the better choice

The usual objection to friction drives is that they slip. That objection assumes
you need positional accuracy and a lot of torque. Neither is true for a cake.

**Torque needed.** A 100 mm turntable bearing under a 2 kg cake takes roughly
0.05 N·m to keep turning — about 0.5 N of tangential force at the 95 mm rim.

**Traction available.** A nitrile O-ring squeezed 0.4 mm presses on the rim with
2–4 N, and rubber on printed plastic gives µ ≈ 0.7. So there is about 2 N of
grip against a 0.5 N demand: **4× margin, from the rubber alone**, with no spring
anywhere in the mount.

**Motor margin.** 17 N·cm through 8.8:1 is 1.5 N·m at the platter — roughly 30×
what is required. The drive will never stall; it will slip first, which is what
you want next to a cake.

**Slip costs nothing.** Nothing in a decorative carousel needs to know its
angle. And because the tyre slips before the motor stalls, grabbing the cake
mid-rotation harms neither the cake nor the mechanism. With gear teeth that same
grab is transmitted straight into the teeth.

**It's also smoother.** 8.8:1 means the stepper spins 8.8× faster than the
platter, so you get 8.8× more microsteps per degree of cake than a direct drive
would — less audible stepping, less visible cogging at 3 rpm.

Three things make the difference between a friction drive that works and the
kind that gives them a bad name:

1. **A rubber tyre, not bare plastic.** PLA on PLA has a low and inconsistent µ
   and polishes itself smooth. A €0.10 O-ring in a grooved roller fixes it.
2. **Let the rubber be the spring.** Because the tyre is compliant, a rigid
   slidable motor mount set to a 0.4 mm interference is enough. No spring, no
   pivot, no flexure — which is why this design has three parts instead of six.
3. **Keep the drive rim clean.** This is the real weakness: icing or crumbs on
   the rim will make it slip. The rim is a bare band on the platter's edge,
   below the cake board, so it stays out of the way — but wipe it.

The other honest caveat: a tyre left compressed for months takes a flat spot and
starts to rumble. Back the motor off a millimetre for storage, or replace the
O-ring.

## How it works

* **base** — a Ø 210 mm plate on four 34 mm legs. The bearing's lower plate
  drops into a pocket in the top face. The motor bolts to the underside through
  four **radial slots**, so sliding it sets the tyre squeeze; its own four
  screws are the clamp. Its shaft comes up through a slot, and a pocket clears
  the 22 mm pilot boss.
* **platter** — a Ø 190 mm disc with a matching pocket underneath for the
  bearing's upper plate, a rim flange that deepens the drive band to 9 mm, a
  lightening pocket, and the eight pole sockets.
* **roller** — a 20 mm body with a groove holding a 16 × 3 O-ring, a 5 mm bore
  and an M3 grub screw. The tyre stands 1 mm proud of the body, so the body
  itself never touches the platter — there is a deliberate 0.6 mm gap.

With a **square** bearing the pockets take the drive torque, so the screws are
optional and the hole pattern doesn't matter. With a **round** bearing
(`bearing_shape = "round"`) the plate can spin in its pocket, so there the
screws are what hold it: measure your hole radius and set `pilot_rs`.

## Bill of materials

| # | Item | Qty | Unit | Notes |
|---|---|---|---|---|
| 1 | Turntable / lazy-susan bearing, 4″ (100 mm) square | 1 | ≈ €6 | **measure it** and set `bearing_size`, `bearing_h`, `bearing_shape` |
| 2 | [NEMA 17 pancake stepper, 17 N·cm, 42 × 23 mm](https://www.amazon.de/-/en/gp/product/B0B93PNYCP) | 1 | €10.50 | 5 mm shaft; the model assumes 21 mm of shaft above the face |
| 3 | Stepper driver (TMC2209 for quiet) | 1 | ≈ €5 | |
| 4 | Controller — Arduino Nano / RP2040 / ESP32, or a pulse-generator module | 1 | ≈ €8 | ~20 lines of code, or a knob and none |
| 5 | 12 V / 1 A supply | 1 | ≈ €9 | run the driver at 0.3–0.4 A |
| 6 | Nitrile O-ring, 16 mm ID × 3 mm section | 1 | ≈ €5/pack | the wear part; buy a few |
| 7 | M3 × 8 screws + washers | 4 | ≈ €1 | motor to base, through the slots |
| 8 | M3 × 6 grub screw | 1 | ≈ €1 | roller to shaft |
| 9 | M3 × 10 self-tapping screws | 0–8 | ≈ €1 | bearing; optional with a square bearing, required with a round one |
| 10 | Self-adhesive felt pads, Ø 12 mm | 4 | ≈ €2 | recesses are printed into the feet |
| | | | **≈ €48** | |

Printed: ≈ 365 cm³ solid, so ≈ 300 g of filament at 20 % infill.

## Printing

| Part | Orientation | Notes |
|---|---|---|
| `base` | **flipped** — top face on the bed, legs pointing up | all pockets and slots become first-layer features; no supports |
| `platter` | **flipped** — top face on the bed | bearing pocket and rim flange point up; the cake side comes out bed-smooth |
| `roller` | as modelled | 4–5 perimeters; the groove needs to hold the tyre |

0.2 mm layers, 3 perimeters, 20 % infill. The base is 244 × 210 mm — if that
won't fit, `sectors=3` splits base and platter into dowelled pie pieces
(OpenSCAD and FreeCAD only):

```bash
openscad -o base_a.stl -D 'part="base"' -D sectors=3 -D sector_index=0 friction_drive.scad
```

## Assembly and the one adjustment

1. Bearing into the base's pocket, then the platter's pocket over its upper
   plate. Screws if you're using them (rotate the plates to reach the holes).
2. Roller onto the motor shaft, grub screw nipped, tyre in its groove.
3. Motor to the underside of the base with its four screws in the **outermost**
   end of the slots — tyre clear of the rim.
4. Loosen, slide the motor in until the tyre just touches the rim, then a
   further ≈ 0.4 mm, and tighten.
5. Test by hand: the platter should turn with a finger on the roller, and
   holding the platter should make the tyre slip rather than the roller stop. If
   it slips while turning normally, add another 0.2 mm. If the platter feels
   stiff or the motor whines, back it off.

Want a sprung preload instead? There's a printed anchor post hole beside the
motor pad — hook a rubber band from there to the motor and leave the screws just
snug. Not needed in normal use.

## What has been checked

* Every part builds as a single closed solid in both kernels (CGAL reports one
  volume each; OCC reports `isValid()` and one solid each), for both the square
  and round bearing options.
* All **three** implementations — OpenSCAD, FreeCAD and µcad — agree on every
  part's volume to within 0.02 %.
* Asserts cover the things that quietly ruin this design: platter or base too
  small for the bearing's swept circle, slots too short to disengage the tyre,
  motor shaft too short to reach it, tyre not lined up with the drive band, legs
  too short to clear the motor, and pole sockets encroaching on the drive rim.
* Geometry: 0.6 mm gap between the roller body and the rim, so only rubber ever
  touches; tyre centred in a 9 mm tall band, giving ±4 mm of assembly slop.
* Not checked: nothing has been printed. µ = 0.7 and the O-ring force are
  handbook figures, not measured on your filament.

## Friction drive vs the geared design

| | [carousel.scad](carousel.scad) — geared | this — friction |
|---|---|---|
| Printed parts | 8 distinct | 3 distinct |
| Bought | 40 balls, screws | turntable bearing, one O-ring |
| Reduction | 6.64:1, exact | 8.8:1, slips under overload |
| Load path | printed ball race | steel bearing |
| Noise | tooth mesh, needs backlash right | silent |
| Tolerance sensitivity | high — teeth bind or rattle | low — the rubber absorbs it |
| Positional accuracy | exact | none, and none needed |
| Fails by | binding or stripping teeth | slipping |
| Hand-turnable | yes, thumbwheel | yes, but only via the motor shaft |

If you want it silent, simple and robust to print tolerances, build this one. The
geared version is the one to build if you want no bought bearing, or the look of
a big visible gear wheel.
