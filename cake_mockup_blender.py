# =============================================================================
#  CAKE MOCKUP -- Blender build
# =============================================================================
#  Builds the same massing model as cake_mockup.scad.  The dimensions are READ
#  FROM cake_mockup.scad, so that file stays the single source of truth: edit
#  the numbers there and re-run this.
#
#  Head-less, writing a .blend (and optionally a PNG):
#      blender -b --factory-startup -P cake_mockup_blender.py -- \
#          --blend cake_mockup.blend --render cake_mockup.png
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


def build(scene):
    coll = bpy.data.collections.new("CakeMockup")
    scene.collection.children.link(coll)
    z, objs = 0.0, []
    for name, r, h, cone, x, rgb in STACK:
        objs.append((add_body(name, r, h, cone, x, z, rgb, coll), r, h, cone, z))
        z += h
    return objs, z


def volume(ob):
    bm = bmesh.new()
    bm.from_mesh(ob.data)
    v = bm.calc_volume(signed=False)
    bm.free()
    return v


def report(objs, total):
    print("\n%-14s %10s %10s %12s %9s" % ("body", "z from", "z to", "volume mm3", "vs exact"))
    tot = 0.0
    for ob, r, h, cone, z in objs:
        exact = math.pi * r * r * h / (3 if cone else 1)
        v = volume(ob)
        tot += v
        print("%-14s %10.1f %10.1f %12.0f %8.3f%%" % (ob.name, z, z + h, v, 100 * (v - exact) / exact))
    print("TOTAL HEIGHT %.0f mm (%.1f cm), volume %.2f litres\n" % (total, total / 10, tot / 1e6))


def stage_render(scene, total, path):
    """Cycles on the CPU: needs no OpenGL context, so it works head-less.
    (Workbench and EEVEE both abort with `blender -b` when no GL/EGL context
    exists, e.g. on a Raspberry Pi without a display.)"""
    span = 2 * max(r for _, r, *_ in STACK)
    cam_data = bpy.data.cameras.new("Camera")
    cam_data.clip_end = 20000
    cam = bpy.data.objects.new("Camera", cam_data)
    scene.collection.objects.link(cam)
    target = (0.0, 0.0, total * 0.45)
    dist = max(span, total) * 1.9
    cam.location = (dist * 0.75, -dist * 0.95, total * 0.45 + dist * 0.45)
    direction = [t - c for t, c in zip(target, cam.location)]
    cam.rotation_euler = _look_at(direction)
    scene.camera = cam

    sun = bpy.data.objects.new("Sun", bpy.data.lights.new("Sun", "SUN"))
    sun.data.energy = 3.0
    sun.rotation_euler = (math.radians(50), math.radians(10), math.radians(30))
    scene.collection.objects.link(sun)

    scene.world = bpy.data.worlds.new("World")
    scene.world.use_nodes = True
    bg = scene.world.node_tree.nodes["Background"]
    bg.inputs["Color"].default_value = (0.9, 0.92, 0.95, 1.0)
    bg.inputs["Strength"].default_value = 0.35
    scene.view_settings.view_transform = "Standard"   # true colours, not AgX's soft roll-off

    scene.render.engine = "CYCLES"
    scene.cycles.device = "CPU"
    scene.cycles.samples = 32
    scene.cycles.use_denoising = False
    scene.render.resolution_x, scene.render.resolution_y = 800, 900
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
    objs, total = build(scene)
    report(objs, total)
    if "--render" in opts:
        stage_render(scene, total, os.path.abspath(opts["--render"]))
    if "--blend" in opts:
        bpy.ops.wm.save_as_mainfile(filepath=os.path.abspath(opts["--blend"]))
        print("saved", os.path.abspath(opts["--blend"]))


main()
