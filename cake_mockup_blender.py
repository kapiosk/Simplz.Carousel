# =============================================================================
#  CAKE MOCKUP -- Blender build
# =============================================================================
#  Builds the same massing model as cake_mockup.scad, carousel horses included.
#  The dimensions AND the horse's side profile are READ FROM cake_mockup.scad,
#  so that file stays the single source of truth: edit it there and re-run this.
#
#  Head-less, writing a .blend and, optionally, two Cycles renders:
#      blender -b --factory-startup -P cake_mockup_blender.py -- \
#          --blend cake_mockup.blend \
#          --render renders/cake_mockup.png --closeup renders/carousel_closeup.png
#  (about 2.5 minutes on a Raspberry Pi 5 for both renders)
#
#  Or in the Blender UI: Scripting workspace -> open this file -> Run Script.
#
#  Scene units are millimetres: 1 Blender unit = 1 mm.
# =============================================================================
import math
import os
import re
import sys

import bmesh
import bpy

HERE = os.path.dirname(os.path.abspath(__file__)) if "__file__" in globals() else os.getcwd()
SCAD = os.path.join(HERE, "cake_mockup.scad")
SEGMENTS = 256          # facets round each cylinder; 256 keeps volume within 0.01 %

# ------------------------------------------------------------- dimensions ---
def read_scad(path):
    """Every `name = number;` assignment in the .scad, as floats."""
    with open(path) as fh:
        text = fh.read()
    return {m.group(1): float(m.group(2))
            for m in re.finditer(r"^([a-z_0-9]+)\s*=\s*([-0-9.]+)\s*;", text, re.M)}

P = read_scad(SCAD)
needed = ["plinth_d", "plinth_h", "cake_offset", "tier1_d", "tier1_h", "tier2_d",
          "tier2_h", "carousel_d", "carousel_h", "column_d", "column_h",
          "brim_d", "brim_h", "roof_d", "roof_h"]
missing = [n for n in needed if n not in P]
if missing:
    raise SystemExit("cake_mockup.scad is missing: " + ", ".join(missing))

# The .scad gives every size as a DIAMETER; Blender's primitives want radii.
# The stack, bottom to top: (name, radius, height, is_cone, x offset, colour)
off = P["cake_offset"]
STACK = [
    ("plinth",        P["plinth_d"] / 2,   P["plinth_h"],   False, 0.0, (0.86, 0.86, 0.86)),
    ("tier1",         P["tier1_d"] / 2,    P["tier1_h"],    False, off, (0.96, 0.87, 0.70)),
    ("tier2",         P["tier2_d"] / 2,    P["tier2_h"],    False, off, (1.00, 0.89, 0.88)),
    ("carousel_base", P["carousel_d"] / 2, P["carousel_h"], False, off, (0.27, 0.51, 0.71)),
    ("column",        P["column_d"] / 2,   P["column_h"],   False, off, (0.75, 0.75, 0.75)),
    ("brim",          P["brim_d"] / 2,     P["brim_h"],     False, off, (1.00, 0.39, 0.28)),
    ("roof",          P["roof_d"] / 2,     P["roof_h"],     True,  off, (1.00, 0.39, 0.28)),
]

# ---------------------------------------------------------------- horses ---
# The horse is the side profile listed in cake_mockup.scad, smoothed and scaled
# exactly as the .scad does it, so both files draw the same horse.
def read_points(path, name):
    """A `name = [[x, y], ...];` list from the .scad, as (x, y) tuples."""
    with open(path) as fh:
        text = fh.read()
    m = re.search(r"^%s\s*=\s*\[(.*?)\];" % name, text, re.M | re.S)
    if not m:
        raise SystemExit("cake_mockup.scad has no %s" % name)
    body = re.sub(r"//[^\n]*", "", m.group(1))
    return [(float(a), float(b))
            for a, b in re.findall(r"\[\s*(-?[\d.]+)\s*,\s*(-?[\d.]+)\s*\]", body)]


def chaikin(p):
    """Corner-cutting, as the .scad's chaikin(): each corner becomes two points."""
    out = []
    for i, a in enumerate(p):
        b = p[(i + 1) % len(p)]
        out += [(a[0] * 0.75 + b[0] * 0.25, a[1] * 0.75 + b[1] * 0.25),
                (a[0] * 0.25 + b[0] * 0.75, a[1] * 0.25 + b[1] * 0.75)]
    return out


def smooth(p, n):
    for _ in range(n):
        p = chaikin(p)
    return p


HORSES = "horse_count" in P
if HORSES:
    HORSE_SK = smooth(read_points(SCAD, "horse_profile"), 2)
    SADDLE_SK = smooth(read_points(SCAD, "saddle_profile"), 1)
    _xs, _ys = [q[0] for q in HORSE_SK], [q[1] for q in HORSE_SK]
    HCX, HCY = (min(_xs) + max(_xs)) / 2, (min(_ys) + max(_ys)) / 2
    HSX = P["horse_l"] / (max(_xs) - min(_xs))
    HSY = P["horse_h"] / (max(_ys) - min(_ys))
    POLE_X = (P["pole_at"] - HCX) * HSX

    def fit(p):
        """Sketch units -> mm, centred on the horse (the .scad's fit())."""
        return [((x - HCX) * HSX, (y - HCY) * HSY) for x, y in p]

# saddle colours as the .scad names them: Crimson, RoyalBlue, SeaGreen, DarkOrchid
SADDLE_RGB = [(0.86, 0.08, 0.24), (0.25, 0.41, 0.88), (0.18, 0.55, 0.34), (0.60, 0.20, 0.80)]

# ------------------------------------------------------------------ scene ---
def reset_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    s = bpy.context.scene
    s.unit_settings.system = "METRIC"
    s.unit_settings.scale_length = 0.001        # 1 unit shows as 1 mm
    s.unit_settings.length_unit = "MILLIMETERS"
    return s


def material(name, rgb):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs["Base Color"].default_value = (*rgb, 1.0)
        bsdf.inputs["Roughness"].default_value = 0.6
    mat.diffuse_color = (*rgb, 1.0)             # viewport / Workbench colour
    return mat


def add_body(name, r, h, cone, x, z, rgb, coll):
    if cone:
        bpy.ops.mesh.primitive_cone_add(vertices=SEGMENTS, radius1=r, radius2=0.0,
                                        depth=h, location=(x, 0.0, z + h / 2))
    else:
        bpy.ops.mesh.primitive_cylinder_add(vertices=SEGMENTS, radius=r,
                                            depth=h, location=(x, 0.0, z + h / 2))
    ob = bpy.context.active_object
    ob.name = ob.data.name = name
    try:                                        # smooth sides, crisp rims
        bpy.ops.object.shade_smooth_by_angle(angle=math.radians(30))
    except Exception:
        bpy.ops.object.shade_flat()
    ob.data.materials.append(material(name, rgb))
    for c in ob.users_collection:
        c.objects.unlink(ob)
    coll.objects.link(ob)
    return ob


def outline_mesh(name, pts, thickness):
    """A closed prism: the polygon `pts` (x, z) in the XZ plane, `thickness`
    deep along Y and centred on it -- the .scad's linear_extrude(center=true)
    after its rotate([90, 0, 0])."""
    n = len(pts)
    verts = [(x, -thickness / 2, z) for x, z in pts] + [(x, thickness / 2, z) for x, z in pts]
    faces = [list(range(n)), list(range(2 * n - 1, n - 1, -1))]
    faces += [[i, (i + 1) % n, n + (i + 1) % n, n + i] for i in range(n)]
    me = bpy.data.meshes.new(name)
    me.from_pydata(verts, [], faces)
    bm = bmesh.new()
    bm.from_mesh(me)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    bm.to_mesh(me)
    bm.free()
    for poly in me.polygons:
        poly.use_smooth = True
    try:                                        # smooth sides, crisp edges to the caps
        me.set_sharp_from_angle(angle=math.radians(30))
    except Exception:
        pass
    return me


def build_horses(coll, deck_top, gap):
    """horse_count horses round the column, facing the way the carousel turns,
    alternately raised and lowered, each on a brass pole from deck to brim."""
    n, ring = int(P["horse_count"]), P["horse_ring_d"] / 2
    mid = deck_top + gap / 2
    body = outline_mesh("horse", fit(HORSE_SK), P["horse_t"])
    body.materials.append(material("horse", (1.0, 0.97, 0.88)))
    saddles = []
    for k, rgb in enumerate(SADDLE_RGB):
        me = outline_mesh("saddle_%d" % k, fit(SADDLE_SK), P["horse_t"] + 3)
        me.materials.append(material("saddle_%d" % k, rgb))
        saddles.append(me)
    brass = material("brass", (0.83, 0.66, 0.22))
    brass.node_tree.nodes["Principled BSDF"].inputs["Metallic"].default_value = 1.0
    brass.node_tree.nodes["Principled BSDF"].inputs["Roughness"].default_value = 0.3

    for i in range(n):
        a = math.radians(90 + i * 360 / n)
        zm = mid + (P["horse_bob"] if i % 2 == 0 else -P["horse_bob"])
        cx, cy = off + ring * math.cos(a), ring * math.sin(a)
        for me, nm in ((body, "horse%d" % (i + 1)), (saddles[i % len(saddles)], "saddle%d" % (i + 1))):
            ob = bpy.data.objects.new(nm, me)
            ob.location = (cx, cy, zm)
            ob.rotation_euler = (0.0, 0.0, a + math.pi / 2)   # head along the tangent
            coll.objects.link(ob)
        tx, ty = -math.sin(a), math.cos(a)
        bpy.ops.mesh.primitive_cylinder_add(vertices=48, radius=P["pole_d"] / 2, depth=gap,
                                            location=(cx + POLE_X * tx, cy + POLE_X * ty, mid))
        pole = bpy.context.active_object
        pole.name = "pole%d" % (i + 1)
        pole.data.materials.append(brass)
        bpy.ops.object.shade_smooth()
        for c in pole.users_collection:
            c.objects.unlink(pole)
        coll.objects.link(pole)
    return body


def build(scene):
    coll = bpy.data.collections.new("CakeMockup")
    scene.collection.children.link(coll)
    z, objs = 0.0, []
    for name, r, h, cone, x, rgb in STACK:
        objs.append((add_body(name, r, h, cone, x, z, rgb, coll), r, h, cone, z))
        z += h
    horse = None
    if HORSES:
        deck_top = sum(h for name, r, h, *_ in STACK[:4])     # plinth .. carousel base
        horse = build_horses(coll, deck_top, P["column_h"])
    return objs, z, horse


def volume(me):
    bm = bmesh.new()
    bm.from_mesh(me)
    v = bm.calc_volume(signed=False)
    bm.free()
    return v


def report(objs, total, horse):
    print("\n%-14s %10s %10s %12s %9s" % ("body", "z from", "z to", "volume mm3", "vs exact"))
    tot = 0.0
    for ob, r, h, cone, z in objs:
        exact = math.pi * r * r * h / (3 if cone else 1)
        v = volume(ob.data)
        tot += v
        print("%-14s %10.1f %10.1f %12.0f %8.3f%%" % (ob.name, z, z + h, v, 100 * (v - exact) / exact))
    print("TOTAL HEIGHT %.0f mm (%.1f cm), volume %.2f litres" % (total, total / 10, tot / 1e6))
    if horse:
        xs = [v.co.x for v in horse.vertices]
        ys = [v.co.y for v in horse.vertices]
        zs = [v.co.z for v in horse.vertices]
        v = volume(horse)
        print("HORSE %.1f long x %.1f tall x %.1f thick mm, %.0f mm3 (%.0f g in chocolate), x%d"
              % (max(xs) - min(xs), max(zs) - min(zs), max(ys) - min(ys), v, v * 1.3e-3,
                 int(P["horse_count"])))
    print()


# ----------------------------------------------------------------- render ---
def stage(scene, total):
    """Sun, sky, a floor to catch the shadows, and Cycles on the CPU.
    Cycles needs no OpenGL context, so it works head-less; Workbench and EEVEE
    both abort with `blender -b` when there is no GL/EGL context, as on a
    Raspberry Pi without a display."""
    staging = bpy.data.collections.new("Staging")
    scene.collection.children.link(staging)

    sun = bpy.data.objects.new("Sun", bpy.data.lights.new("Sun", "SUN"))
    sun.data.energy = 2.6
    sun.data.angle = math.radians(8)            # soft-edged shadows
    sun.rotation_euler = (math.radians(45), math.radians(10), math.radians(35))
    staging.objects.link(sun)

    bpy.ops.mesh.primitive_plane_add(size=total * 8, location=(0, 0, -0.01))
    floor = bpy.context.active_object
    floor.name = "Floor"
    floor.data.materials.append(material("floor", (0.38, 0.36, 0.35)))
    for c in floor.users_collection:
        c.objects.unlink(floor)
    staging.objects.link(floor)

    scene.world = bpy.data.worlds.new("World")
    scene.world.use_nodes = True
    bg = scene.world.node_tree.nodes["Background"]
    bg.inputs["Color"].default_value = (0.88, 0.91, 0.95, 1.0)
    bg.inputs["Strength"].default_value = 0.4
    scene.view_settings.view_transform = "Standard"   # true colours, not AgX's roll-off

    scene.render.engine = "CYCLES"
    scene.cycles.device = "CPU"
    scene.cycles.samples = 128
    scene.cycles.use_denoising = False
    return staging


def shoot(scene, staging, name, target, dist, elevation_deg, size, path):
    cam_data = bpy.data.cameras.new(name)
    cam_data.clip_end = 20000
    cam_data.lens = 50
    cam = bpy.data.objects.new(name, cam_data)
    staging.objects.link(cam)
    az, el = math.radians(-50), math.radians(elevation_deg)
    cam.location = (target[0] + dist * math.cos(el) * math.sin(-az),
                    target[1] - dist * math.cos(el) * math.cos(az),
                    target[2] + dist * math.sin(el))
    cam.rotation_euler = _look_at([t - c for t, c in zip(target, cam.location)])
    scene.camera = cam
    scene.render.resolution_x, scene.render.resolution_y = size
    scene.render.filepath = path
    bpy.ops.render.render(write_still=True)
    print("rendered", path)


def _look_at(direction):
    from mathutils import Vector
    return Vector(direction).to_track_quat("-Z", "Y").to_euler()


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    opts = dict(zip(argv[::2], argv[1::2]))
    scene = reset_scene()
    objs, total, horse = build(scene)
    report(objs, total, horse)
    if "--render" in opts or "--closeup" in opts:
        staging = stage(scene, total)
        if "--render" in opts:                  # the whole display
            shoot(scene, staging, "Camera", (off, 0.0, total * 0.46), total * 2.05, 20,
                  (1000, 1150), os.path.abspath(opts["--render"]))
        if "--closeup" in opts:                 # the carousel and its horses
            deck_top = sum(h for name, r, h, *_ in STACK[:4])
            carousel_top = total
            target = (off, 0.0, (deck_top + carousel_top) / 2 - 10)
            shoot(scene, staging, "CloseUp", target, (carousel_top - deck_top) * 3.0, 14,
                  (1200, 950), os.path.abspath(opts["--closeup"]))
    if "--blend" in opts:
        bpy.ops.wm.save_as_mainfile(filepath=os.path.abspath(opts["--blend"]))
        print("saved", os.path.abspath(opts["--blend"]))


main()
