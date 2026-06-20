import math
from pathlib import Path

import bpy
from mathutils import Vector


REPO_ROOT = Path(__file__).resolve().parents[3]
SOURCE_BLEND = REPO_ROOT / "assets" / "blender" / "source" / "game_store_visual_benchmark_assets.blend"
OUTPUT_DIR = REPO_ROOT / "artifacts" / "validation" / "latest" / "screenshots" / "visual-benchmark"


SHOTS = [
    {
        "filename": "01-storefront-from-mall.png",
        "camera": (5.8, 1.65, 6.25),
        "target": (0.0, 1.35, 2.45),
        "lens": 24,
    },
    {
        "filename": "02-empty-sales-floor.png",
        "camera": (-2.15, 1.62, 1.35),
        "target": (1.25, 1.0, -2.75),
        "lens": 22,
    },
    {
        "filename": "03-receiving-backroom.png",
        "camera": (-3.05, 1.55, -5.75),
        "target": (0.25, 0.95, -7.55),
        "lens": 26,
    },
    {
        "filename": "04-starter-shipment-open.png",
        "camera": (-2.20, 1.42, -6.45),
        "target": (-1.02, 0.96, -7.25),
        "lens": 38,
    },
    {
        "filename": "05-picked-up-case.png",
        "camera": (0.25, 1.55, 1.95),
        "target": (0.05, 1.10, 0.50),
        "lens": 32,
    },
    {
        "filename": "06-stocked-shelf-density.png",
        "camera": (-3.05, 1.45, -4.85),
        "target": (-2.50, 1.10, -5.75),
        "lens": 42,
    },
    {
        "filename": "07-counter-register.png",
        "camera": (1.75, 1.45, 0.25),
        "target": (3.05, 1.05, -0.75),
        "lens": 34,
    },
    {
        "filename": "08-customer-entering-from-mall.png",
        "camera": (2.30, 1.55, 4.55),
        "target": (-1.10, 1.05, 1.90),
        "lens": 30,
    },
    {
        "filename": "09-daily-report-view.png",
        "camera": (0.20, 1.55, -6.85),
        "target": (1.25, 1.02, -8.18),
        "lens": 38,
    },
]


def look_at(obj: bpy.types.Object, target: tuple[float, float, float]) -> None:
    direction = Vector(target) - obj.location
    obj.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()


def ensure_blend_loaded() -> None:
    if Path(bpy.data.filepath).resolve() != SOURCE_BLEND:
        bpy.ops.wm.open_mainfile(filepath=str(SOURCE_BLEND))


def configure_render() -> None:
    scene = bpy.context.scene
    scene.render.resolution_x = 1280
    scene.render.resolution_y = 720
    scene.render.film_transparent = False
    scene.world.color = (0.06, 0.07, 0.075)
    try:
        scene.render.engine = "BLENDER_EEVEE_NEXT"
        scene.eevee.taa_render_samples = 32
    except Exception:
        scene.render.engine = "BLENDER_WORKBENCH"
    scene.view_settings.view_transform = "Filmic"
    scene.view_settings.look = "Medium High Contrast"
    scene.view_settings.exposure = 0
    scene.view_settings.gamma = 1


def capture_shot(shot: dict[str, object]) -> None:
    camera_data = bpy.data.cameras.new(f"ReviewCamera_{shot['filename']}")
    camera = bpy.data.objects.new(f"ReviewCamera_{shot['filename']}", camera_data)
    bpy.context.scene.collection.objects.link(camera)
    camera.location = shot["camera"]
    camera.data.lens = shot["lens"]
    camera.data.sensor_width = 32
    camera.data.dof.use_dof = False
    look_at(camera, shot["target"])
    bpy.context.scene.camera = camera
    bpy.context.scene.render.filepath = str(OUTPUT_DIR / shot["filename"])
    bpy.ops.render.render(write_still=True)
    bpy.data.objects.remove(camera, do_unlink=True)


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    ensure_blend_loaded()
    configure_render()
    for shot in SHOTS:
        capture_shot(shot)
    print(f"Captured {len(SHOTS)} visual benchmark screenshots to {OUTPUT_DIR}")


if __name__ == "__main__":
    main()
