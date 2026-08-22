# The µcad port

[friction_drive.µcad](friction_drive.µcad) is a third implementation of the
friction mechanism, alongside the OpenSCAD and FreeCAD versions, written in
[µcad](https://microcad.xyz) 0.5 — a young Rust CAD language.

**It is geometrically the same design.** Exporting all three and comparing
solid volumes:

| Part | OpenSCAD | FreeCAD | µcad | spread |
|---|---|---|---|---|
| `base` | 220 467.7 mm³ | 220 502.0 mm³ | 220 474.3 mm³ | 0.02 % |
| `platter` | 141 057.5 mm³ | 141 080.8 mm³ | 141 048.1 mm³ | 0.02 % |
| `roller` | 3 109.3 mm³ | 3 108.5 mm³ | 3 109.2 mm³ | 0.02 % |

The residual is mesh resolution, not geometry.

## Running it

```bash
cargo install microcad        # the CLI crate is just "microcad"
```

```bash
microcad check  friction_drive.µcad
microcad export friction_drive.µcad              # writes the three STLs
microcad export -r 0.05mm friction_drive.µcad    # finer mesh
microcad watch  friction_drive.µcad              # re-render on save
```

`microcad create <name>` also installs the standard library into
`~/.config/microcad/lib/std` — worth reading, it is written in µcad itself and
is the most accurate reference for the language there is.

The three `#[export(...)]` attributes name the output files. Parts are
instantiated where they sit in the assembly, so the render shows the whole
mechanism and each STL carries that offset; slicers re-centre on load.

## What the language is like

It reads like a cross between OpenSCAD and Rust, and is more strongly typed than
either: quantities carry units (`190mm`, `45°`, `100%`), and `Length`, `Angle`,
`Scalar`, `Integer`, `Bool`, `Vec2/3` are distinct types.

```µcad
const platter_dia = 190mm;
const platter_r   = platter_dia / 2;          // Length / Integer -> Length
const ratio       = platter_r / (tyre_r - squish / 2);   // Length / Length -> Scalar
```

* `sketch` defines 2D geometry, `part` defines 3D, `op` defines an operation.
  Both take named parameters with defaults, and extra `init(...)` constructors —
  which is how `Cylinder` accepts `(radius, height)` or `(radius, bottom, top)`.
* Booleans are operators: `|` union, `-` difference, `&` intersection. There is
  no `+`.
* Everything else is a method: `.extrude(6mm)`, `.translate(z = 3mm)`,
  `.rotate(90°, Y)`, `.hull()`, `.revolve()`, `.center()`.
* **Multiplicity replaces `for` loops.** Pass an array where a scalar is
  expected and you get one instance per element; pass two arrays and you get the
  cross product. This is the nicest thing in the language:

```µcad
// eight pole sockets, evenly spaced
Cylinder(radius = 3.2mm, bottom = 13mm, top = 18mm)
    .translate(distance = pole_r, angle = [0..pole_count - 1] * (360° / pole_count));

// sixteen pilot holes: four radii x four diagonals
Cylinder(radius = 1.25mm, bottom = -1mm, top = 7mm)
    .translate(distance = [36mm, 42mm, 48mm, 54mm], angle = [45°, 135°, 225°, 315°]);

// the motor's four bolt slots
Slot(dia = 3.4mm, length = 12mm, bottom = -1mm, top = 7mm)
    .translate(x = [axis_r - 15.5mm, axis_r + 15.5mm], y = [-15.5mm, 15.5mm]);
```

* `std::debug::assert(cond, "message")` works, so the design guards carried over
  from the other two files unchanged.
* `std::print("...{value}...")` interpolates.

## Three things that bit, and the workarounds

**1. `if` produces geometry, not values.** There is no conditional expression for
ordinary values — `const x = if flag { 1mm } else { 2mm };` evaluates to a
geometry `Group`, and any later arithmetic on it fails with
`Invalid operator: Group (root) -> + 2mm`. Inside a `sketch`/`part` body an
`if` is fine, because there the result *is* geometry:

```µcad
sketch BearingFootprint(size: Length) {
    if bearing_square { Rect(size) } else { Circle(radius = size / 2) }
}
```

So the swept radius of the bearing takes the square case unconditionally, which
is the larger of the two and therefore a safe guard for a round bearing as well.

**2. `Ring(outer_radius, inner_radius)` is ambiguous.** std's `Ring` has four
`init` forms and the call cannot be resolved:
`Workbench Ring has ambiguous initialization for those arguments`. The `Tube`
helper here builds the annulus from two circles instead.

**3. A comment as the first token inside a group breaks the next operator** —
when the following operand also starts with `(`. This file therefore keeps
comments above each group, and documents the parts with `///` doc comments on
small composed sub-parts rather than inline. Minimal reproducer:

```µcad
use std::geo2d::*; use std::geo3d::*; use std::ops::*;
part P() {
    (
        // this comment is the problem
        (Circle(radius = 50mm) | Circle(radius = 20mm, center = (x = 60mm, y = 0mm)))
            .extrude(6mm)
        | Cylinder(radius = 7mm, bottom = -34mm, top = 0mm)
    ) - Cylinder(radius = 5mm, bottom = -1mm, top = 7mm)
}
P();
```

```
error: 3:5: Invalid operator: (Operation union() (root) ->) - Operation union() (root) ->
```

Move the comment above the `(` and it compiles. Worth reporting upstream; it
cost an hour to isolate because the error is reported against the operator, far
from the comment, and a second error elsewhere masked it.

## What did not get ported

* **Sector splitting for small print beds.** The OpenSCAD and FreeCAD versions
  cut the base and platter into dowelled pie pieces; that is not in the µcad
  file. µcad has `Sector` and `&`, so it is expressible, but the dowel pattern
  and the sector selection would need a parameter mechanism it does not have yet
  (see below). Use [friction_drive.scad](friction_drive.scad) if you need to
  split — the parts are identical.
* **Parameters from the command line.** There is no `-D name=value` as in
  OpenSCAD; edit the `const` block. That also means one file cannot emit both
  the square- and round-bearing variants without editing.

## Verdict

For a mechanism of this shape, µcad was pleasant: units caught two unit errors
while typing, multiplicity expressed the bolt patterns more clearly than nested
`for` loops, and `check` is instant. It is alpha, though — the three
workarounds above are all in one 250-line file, and the diagnostics point at
symptoms rather than causes. Keep the OpenSCAD file as the reference
implementation, and treat this one as the readable version.
