# Cake Carousel — Bill of Materials

Two ways to build the same carousel. Both use the identical upper works — poles,
canopy, finial — and differ only in what turns them.

| | Version A — ready-made base | Version B — printed base + NEMA 17 |
|---|---|---|
| Turning gear | bought motorised turntable | printed ball race + 6.64:1 gear pair |
| Bought cost | **≈ €17** + delivery | **≈ €40–50** + delivery |
| Printed parts | 11 pieces, 4 distinct | 15 pieces, 8 distinct |
| Plastic (solid CAD volume) | 376 cm³, ≈ 380 g printed | 637 cm³, ≈ 570 g printed |
| Speed | 2 fixed speeds, both directions | fully adjustable, or hand-turned |
| Build time | an evening | a weekend |
| Max cake | ≈ 2 kg — stability, not the motor (carousel ≈ 0.5 kg of the 5 kg platform rating) | ≈ 5 kg, plate stiffness being the limit |
| CAD switch | `base_style="turntable"` | `base_style="printed"`, `drive="nema17"` |

Prices are amazon.de including VAT, seen 2026-08-22, delivery quoted separately
(≈ €11 to Cyprus on both items). Treat them as indicative.

---

## Version A — ready-made base

The printed **adapter** disc drops over the platform of a bought display
turntable and carries the poles and the canopy. No screws, no wiring, no gears,
and the cake board sits straight on the disc.

### Bought

| # | Item | Qty | Unit | Notes |
|---|---|---|---|---|
| A1 | [VAYOTOY electric turntable, 13 cm, 5 kg](https://www.amazon.de/-/en/gp/product/B0BJ2FQFCX) — ABS, 360°, adjustable speed, forward/reverse | 1 | €16.99 | ASIN B0BJ2FQFCX. Platform Ø 130 mm; USB **or** 3 × AAA; quoted 20–30 dB |
| A2 | AAA alkaline cells | 3 | ≈ €1.50 | not included; or run it from a USB power bank |
| A3 | Food-safe cake board / drum, Ø 150 mm | 1 | ≈ €1 | sits straight on the adapter; the only thing the cake touches |
| A4 | Self-adhesive silicone or felt pads, Ø 12 mm | 4 | ≈ €2 | drop into the adapter's grip pockets so the disc cannot slip on the platform |
| | | | **≈ €17–21** | |

### Printed

| Part | Qty | Solid cm³ | Notes |
|---|---|---|---|
| `adapter` | 1 | 127.7 | Ø 189 mm; the recess locates it on the 130 mm platform. Print it flipped |
| `canopy` | 1 | 207.7 | print apex-up, no supports; the big print |
| `pole` | 8 | 4.5 ea | or substitute 6 mm hardwood dowels / food-grade skewers |
| `finial` | 1 | 4.1 | |
| `hanger` | 0–8 | 0.8 ea | optional clip-on hooks for little horses |

### Watch out

* The platform is rated 5 kg and the carousel itself is only ≈ 0.5 kg, so the
  motor is not the constraint — balance is. Keep the cake under ≈ 2 kg and
  centred.
* A Ø 189 mm disc on a Ø 130 mm platform is top-heavy. Fine on a level table,
  not fine on a wobbling trolley.
* Speed is whatever the turntable's controller offers (fast / slow / off, plus
  direction). No fine control.
* Set `platform_dia` and `platform_h` in the CAD to your own turntable if you
  buy something else — everything above the adapter is unaffected.

---

## Version B — printed base + NEMA 17

The full mechanism: a printed thrust bearing on 40 loose balls, and a 14-tooth
pinion driving the 93-tooth turntable, 6.64 : 1. The stepper bolts straight to
the underside of the drive pod.

### Bought

| # | Item | Qty | Unit | Notes |
|---|---|---|---|---|
| B1 | [STEPPERONLINE NEMA 17 pancake stepper, 17 Ncm, 1 A, 42 × 42 × 23 mm, 1.8°](https://www.amazon.de/-/en/gp/product/B0B93PNYCP) | 1 | €10.50 | ASIN B0B93PNYCP. 5 mm shaft, 200 steps/rev. 17 Ncm × 6.64 = **1.1 Nm at the cake** — vast overkill, which is exactly what you want for silence |
| B2 | TMC2209 stepper driver (2-pack) | 1 | €9.99 | any A4988/DRV8825 works, but the TMC2209 is the quiet one — worth it next to a party |
| B3 | Microcontroller: Arduino Nano, RP2040 or ESP32 | 1 | ≈ €8 | ~20 lines of code: step pulses at a fixed rate. A standalone "stepper pulse generator" module (≈ €10) does the same with a knob and no code |
| B4 | 12 V / 1 A power supply, 5.5 × 2.1 mm barrel | 1 | ≈ €9 | |
| B5 | 6 mm steel balls | 40 | ≈ €5/100 | 6 mm airsoft BBs also work and are quieter; for 1/4″ (6.35 mm) balls set `ball_dia = 6.35` |
| B6 | M3 × 8 screws | 4 | ≈ €1 | motor face to the drive pod (31 mm bolt square) |
| B7 | M3 × 6 grub screw | 1 | ≈ €1 | clamps the pinion to the 5 mm shaft |
| B8 | Hook-up wire, panel switch, 10 kΩ pot | — | ≈ €5 | on/off and speed |
| B9 | Food-safe cake board / drum, Ø 150 mm | 1 | ≈ €1 | |
| B10 | 3 mm filament offcuts or dowel | 4–8 | — | only if you print the big discs in sectors |
| | | | **≈ €40–50** | |

### Printed

| Part | Qty | Solid cm³ | Notes |
|---|---|---|---|
| `base` | 1 | 199.9 | Ø 220 mm plus the drive pod → 239 × 220 mm; split into sectors if your bed is smaller |
| `skirt` | 1 | 44.5 | separate ring, pegs into the base; the gap clears the motor |
| `rotor` | 1 | 128.4 | the 93-tooth wheel, Ø 189 mm |
| `retainer` | 1 | 9.0 | keeps the 40 balls evenly spaced |
| `pinion` | 1 | 7.6 | 5 mm bore + grub screw for the stepper |
| `canopy` | 1 | 207.7 | |
| `pole` | 8 | 4.5 ea | |
| `finial` | 1 | 4.1 | |
| `hanger` | 0–8 | 0.8 ea | optional |
| `crank` | 0–1 | 16.2 | only for the hand-driven variant below |

### Driving it

* Cake speed of 2–6 rpm means the motor turns 13–40 rpm: 44–133 full steps/s,
  or 700–2100 microsteps/s at 1/16. Any driver will do this in its sleep.
* Set the driver current **low** — 0.3–0.4 A is plenty and keeps the motor cool
  and quiet. Torque demand at the pinion is a few mNm.
* A stepper holds position when energised, so the carousel stops dead rather
  than coasting. Nice for photos; disable the driver's ENABLE pin to free it.

### The €5 alternative: same base, no electronics

Print with `drive="thumbwheel"` instead and the pod carries a knurled
thumbwheel: one M4 × 25 screw (B6/B7 replaced), one M4 nut, the 40 balls, and
the optional `crank` lever if you want more leverage. A flick of a finger gives
about a third of a turn of cake. Everything else is unchanged.

---

## Food safety, both versions

Printed plastic is not a food-contact material: layer lines harbour bacteria and
PLA cannot be washed hot. Nothing printed here touches the cake — the cake sits
on a food-safe board on the turntable, and the poles are outside the cake's
Ø 152 mm envelope. If a pole must pass close to buttercream, wrap it in food film or use
food-grade skewers instead. Wash printed parts by hand in cool water; the
rotor lifts straight off so the ball race can be cleaned out.
