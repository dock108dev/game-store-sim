import json
import math
import shutil
from pathlib import Path

import bpy
from mathutils import Euler


REPO_ROOT = Path(__file__).resolve().parents[3]
SOURCE_DIR = REPO_ROOT / "assets" / "blender" / "source"
EXPORT_DIR = REPO_ROOT / "assets" / "blender" / "exports"
GAME_ASSET_DIR = REPO_ROOT / "game" / "assets" / "visual_benchmark"
MANIFEST_PATH = GAME_ASSET_DIR / "visual_benchmark_asset_manifest.json"
SOURCE_BLEND = SOURCE_DIR / "game_store_visual_benchmark_assets.blend"


ASSET_EXPORTS = {
    "mall_store_shell": {
        "collection": "Store Shell",
        "description": "Mall concourse, storefront, sales floor shell, walls, ceiling lights, and core floor materials.",
        "targets": ["01-storefront-from-mall.png", "02-empty-sales-floor.png"],
    },
    "starter_shelving_pack": {
        "collection": "Shelving Pack",
        "description": "Wall shelf, freestanding gondola, readable shelf capacity states, category strips.",
        "targets": ["02-empty-sales-floor.png", "06-stocked-shelf-density.png"],
    },
    "checkout_counter_register": {
        "collection": "Counter Register",
        "description": "Checkout counter, register, scanner, cash drawer, receipt props, and counter clutter.",
        "targets": ["07-counter-register.png"],
    },
    "receiving_backroom_pack": {
        "collection": "Receiving Backroom",
        "description": "Receiving table, starter shipment boxes, open box, invoice cue, backroom clutter.",
        "targets": ["03-receiving-backroom.png", "04-starter-shipment-open.png"],
    },
    "product_case_pack": {
        "collection": "Product Cases",
        "description": "Fictional new/used game cases, price stickers, grouped rows, held-case sample.",
        "targets": ["05-picked-up-case.png", "06-stocked-shelf-density.png"],
    },
    "signage_and_posters_pack": {
        "collection": "Signage Posters",
        "description": "Fictional storefront sign, open/closed sign, sale tags, shelf headers, promo poster surfaces.",
        "targets": ["01-storefront-from-mall.png", "06-stocked-shelf-density.png"],
    },
    "customer_placeholder": {
        "collection": "Customer Placeholder",
        "description": "Simple readable customer silhouette for mall-to-store entry staging.",
        "targets": ["08-customer-entering-from-mall.png"],
    },
    "daily_report_computer": {
        "collection": "Daily Report Computer",
        "description": "Backroom computer with business-tool daily report screen and simple desk props.",
        "targets": ["09-daily-report-view.png"],
    },
    "game_store_visual_benchmark_full": {
        "collection": "Full Benchmark Store",
        "description": "Complete assembled first 0.3% visual benchmark store scene.",
        "targets": [
            "01-storefront-from-mall.png",
            "02-empty-sales-floor.png",
            "03-receiving-backroom.png",
            "04-starter-shipment-open.png",
            "05-picked-up-case.png",
            "06-stocked-shelf-density.png",
            "07-counter-register.png",
            "08-customer-entering-from-mall.png",
            "09-daily-report-view.png",
        ],
    },
}


def reset_scene() -> None:
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete()
    bpy.context.scene.unit_settings.system = "METRIC"
    bpy.context.scene.unit_settings.scale_length = 1.0


def make_collection(name: str) -> bpy.types.Collection:
    collection = bpy.data.collections.new(name)
    bpy.context.scene.collection.children.link(collection)
    return collection


def link_to_collection(obj: bpy.types.Object, collection: bpy.types.Collection) -> bpy.types.Object:
    for existing in obj.users_collection:
        existing.objects.unlink(obj)
    collection.objects.link(obj)
    return obj


def to_blender_loc(loc: tuple[float, float, float]) -> tuple[float, float, float]:
    # Author asset placement in Godot-style coordinates: X right, Y up, Z depth.
    # Blender is Z-up, and the GLB exporter converts Blender Z-up to glTF/Godot Y-up.
    return (loc[0], -loc[2], loc[1])


def to_blender_scale(scale: tuple[float, float, float]) -> tuple[float, float, float]:
    return (scale[0], scale[2], scale[1])


def material(name: str, color: tuple[float, float, float, float], roughness: float = 0.72, metallic: float = 0.0) -> bpy.types.Material:
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    mat.diffuse_color = color
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs["Base Color"].default_value = color
        bsdf.inputs["Roughness"].default_value = roughness
        bsdf.inputs["Metallic"].default_value = metallic
        if color[3] < 1.0:
            mat.blend_method = "BLEND"
            bsdf.inputs["Alpha"].default_value = color[3]
    return mat


def cube(
    name: str,
    collection: bpy.types.Collection,
    loc: tuple[float, float, float],
    scale: tuple[float, float, float],
    mat: bpy.types.Material,
    bevel: float = 0.0,
) -> bpy.types.Object:
    bpy.ops.mesh.primitive_cube_add(size=1, location=to_blender_loc(loc))
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = to_blender_scale(scale)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(mat)
    if bevel > 0:
        mod = obj.modifiers.new("small_bevel", "BEVEL")
        mod.width = bevel
        mod.segments = 2
        obj.modifiers.new("weighted_normals", "WEIGHTED_NORMAL")
    link_to_collection(obj, collection)
    return obj


def cylinder(
    name: str,
    collection: bpy.types.Collection,
    loc: tuple[float, float, float],
    radius: float,
    depth: float,
    mat: bpy.types.Material,
    vertices: int = 24,
    rotation: tuple[float, float, float] = (0.0, 0.0, 0.0),
) -> bpy.types.Object:
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=depth, location=to_blender_loc(loc), rotation=rotation)
    obj = bpy.context.object
    obj.name = name
    obj.data.materials.append(mat)
    obj.modifiers.new("weighted_normals", "WEIGHTED_NORMAL")
    link_to_collection(obj, collection)
    return obj


def sphere(
    name: str,
    collection: bpy.types.Collection,
    loc: tuple[float, float, float],
    radius: float,
    mat: bpy.types.Material,
) -> bpy.types.Object:
    bpy.ops.mesh.primitive_uv_sphere_add(segments=24, ring_count=12, radius=radius, location=to_blender_loc(loc))
    obj = bpy.context.object
    obj.name = name
    obj.data.materials.append(mat)
    obj.modifiers.new("weighted_normals", "WEIGHTED_NORMAL")
    link_to_collection(obj, collection)
    return obj


def text_obj(
    name: str,
    collection: bpy.types.Collection,
    text: str,
    loc: tuple[float, float, float],
    size: float,
    mat: bpy.types.Material,
    rotation: tuple[float, float, float] = (math.radians(90), 0.0, 0.0),
    align: str = "CENTER",
) -> bpy.types.Object:
    bpy.ops.object.text_add(location=to_blender_loc(loc), rotation=rotation)
    obj = bpy.context.object
    obj.name = name
    obj.data.body = text
    obj.data.align_x = align
    obj.data.align_y = "CENTER"
    obj.data.size = size
    obj.data.extrude = 0.006
    obj.data.materials.append(mat)
    link_to_collection(obj, collection)
    return obj


def add_area_light(name: str, collection: bpy.types.Collection, loc: tuple[float, float, float], energy: float, size: float) -> None:
    light_data = bpy.data.lights.new(name, "AREA")
    light_data.energy = energy
    light_data.size = size
    obj = bpy.data.objects.new(name, light_data)
    obj.location = to_blender_loc(loc)
    collection.objects.link(obj)


def make_case(
    collection: bpy.types.Collection,
    name: str,
    loc: tuple[float, float, float],
    spine_mat: bpy.types.Material,
    cover_mat: bpy.types.Material,
    sticker_mat: bpy.types.Material,
    rotation_y: float = 0.0,
    used: bool = False,
) -> None:
    root = cube(name, collection, loc, (0.16, 0.25, 0.035), spine_mat, 0.006)
    root.rotation_euler = Euler((0.0, rotation_y, 0.0), "XYZ")
    cover_z = loc[2] + (0.023 if name.startswith("first_person_held") else -0.023)
    sticker_z = loc[2] + (0.030 if name.startswith("first_person_held") else -0.030)
    cover = cube(f"{name}_cover_block", collection, (loc[0], loc[1] + 0.002, cover_z), (0.135, 0.17, 0.010), cover_mat, 0.002)
    cover.rotation_euler = root.rotation_euler
    reverse_cover_z = loc[2] - (0.030 if name.startswith("first_person_held") else -0.030)
    reverse_cover = cube(f"{name}_reverse_cover_block", collection, (loc[0], loc[1] + 0.002, reverse_cover_z), (0.135, 0.17, 0.010), cover_mat, 0.002)
    reverse_cover.rotation_euler = root.rotation_euler
    side_color_left = cube(f"{name}_left_color_spine", collection, (loc[0] - 0.082, loc[1] + 0.000, loc[2]), (0.012, 0.23, 0.030), cover_mat, 0.001)
    side_color_left.rotation_euler = root.rotation_euler
    side_color_right = cube(f"{name}_right_color_spine", collection, (loc[0] + 0.082, loc[1] + 0.000, loc[2]), (0.012, 0.23, 0.030), cover_mat, 0.001)
    side_color_right.rotation_euler = root.rotation_euler
    title_bar = cube(f"{name}_cover_title_bar", collection, (loc[0], loc[1] + 0.050, sticker_z), (0.118, 0.018, 0.009), sticker_mat, 0.001)
    title_bar.rotation_euler = root.rotation_euler
    platform_band = cube(f"{name}_platform_color_band", collection, (loc[0], loc[1] - 0.071, sticker_z), (0.125, 0.018, 0.009), spine_mat, 0.001)
    platform_band.rotation_euler = root.rotation_euler
    cover_line_1 = cube(f"{name}_cover_detail_line_1", collection, (loc[0] - 0.018, loc[1] + 0.015, sticker_z), (0.060, 0.012, 0.009), sticker_mat, 0.001)
    cover_line_1.rotation_euler = root.rotation_euler
    cover_line_2 = cube(f"{name}_cover_detail_line_2", collection, (loc[0] + 0.018, loc[1] - 0.010, sticker_z), (0.052, 0.012, 0.009), sticker_mat, 0.001)
    cover_line_2.rotation_euler = root.rotation_euler
    sticker_x = loc[0] + (0.045 if not used else -0.045)
    sticker = cube(f"{name}_price_sticker", collection, (sticker_x, loc[1] + 0.004, sticker_z), (0.050, 0.030, 0.008), sticker_mat, 0.001)
    sticker.rotation_euler = root.rotation_euler
    if used:
        used_tag = cube(f"{name}_used_corner_tag", collection, (loc[0] - 0.044, loc[1] + 0.069, sticker_z), (0.046, 0.018, 0.010), sticker_mat, 0.001)
        used_tag.rotation_euler = root.rotation_euler


def poster_panel(
    collection: bpy.types.Collection,
    name: str,
    loc: tuple[float, float, float],
    scale: tuple[float, float, float],
    panel_mat: bpy.types.Material,
    accent_mat: bpy.types.Material,
    dark_mat: bpy.types.Material,
) -> list[bpy.types.Object]:
    x, y, z = loc
    w, h, d = scale
    return [
        cube(f"{name}_panel", collection, loc, scale, panel_mat, 0.004),
        cube(f"{name}_title_band", collection, (x, y + h * 0.34, z + d * 0.55), (w * 0.72, h * 0.08, d * 0.40), accent_mat, 0.001),
        cube(f"{name}_art_block", collection, (x, y - h * 0.06, z + d * 0.55), (w * 0.58, h * 0.42, d * 0.40), dark_mat, 0.001),
        cube(f"{name}_caption_bar", collection, (x, y - h * 0.34, z + d * 0.55), (w * 0.62, h * 0.05, d * 0.40), accent_mat, 0.001),
    ]


def price_tag(
    collection: bpy.types.Collection,
    name: str,
    loc: tuple[float, float, float],
    mat: bpy.types.Material,
) -> bpy.types.Object:
    return cube(name, collection, loc, (0.34, 0.08, 0.018), mat, 0.002)


def label_line(
    collection: bpy.types.Collection,
    name: str,
    loc: tuple[float, float, float],
    width: float,
    mat: bpy.types.Material,
    height: float = 0.018,
    depth: float = 0.007,
) -> bpy.types.Object:
    return cube(name, collection, loc, (width, height, depth), mat, 0.001)


def build_assets() -> dict[str, bpy.types.Collection]:
    mats = {
        "carpet": material("muted blue-gray low-pile carpet", (0.12, 0.20, 0.22, 1.0)),
        "mall_tile": material("warm off-white mall tile", (0.54, 0.53, 0.47, 1.0)),
        "wall": material("light scuffed retail wall", (0.58, 0.62, 0.58, 1.0)),
        "wall_shadow": material("subtle wall scuff shadow", (0.40, 0.43, 0.40, 1.0)),
        "slatwall": material("cream retail slatwall", (0.67, 0.65, 0.56, 1.0)),
        "black_metal": material("black powder-coated metal", (0.015, 0.017, 0.018, 1.0), 0.55, 0.25),
        "brushed_metal": material("brushed register metal", (0.34, 0.36, 0.34, 1.0), 0.42, 0.35),
        "wood": material("warm laminate wood shelf", (0.44, 0.27, 0.12, 1.0)),
        "cardboard": material("corrugated cardboard", (0.48, 0.31, 0.14, 1.0)),
        "cardboard_edge": material("dark corrugated cardboard edge", (0.29, 0.18, 0.09, 1.0)),
        "packing_tape": material("clear amber packing tape", (0.90, 0.62, 0.22, 0.66)),
        "glass": material("slightly blue storefront glass", (0.36, 0.62, 0.76, 0.34)),
        "yellow": material("yellow sale sticker", (0.88, 0.67, 0.10, 1.0)),
        "orange_tag": material("clearance orange tag", (0.94, 0.38, 0.10, 1.0)),
        "red": material("used red case art", (0.82, 0.17, 0.16, 1.0)),
        "blue": material("new blue case art", (0.08, 0.32, 0.86, 1.0)),
        "green": material("accessory green box art", (0.16, 0.56, 0.25, 1.0)),
        "purple": material("fictional purple cover accent", (0.42, 0.18, 0.62, 1.0)),
        "orange": material("fictional orange cover accent", (0.90, 0.45, 0.13, 1.0)),
        "magenta": material("fictional magenta promo accent", (0.76, 0.10, 0.48, 1.0)),
        "cyan": material("fictional cyan promo accent", (0.08, 0.62, 0.72, 1.0)),
        "white": material("printed white label", (0.78, 0.75, 0.64, 1.0)),
        "paper": material("warm receipt paper", (0.92, 0.88, 0.74, 1.0)),
        "transparent_case": material("display case acrylic", (0.58, 0.82, 0.88, 0.28), 0.22),
        "dark": material("register dark plastic", (0.04, 0.05, 0.06, 1.0)),
        "screen": material("soft cyan screen glow", (0.05, 0.30, 0.34, 1.0)),
        "screen_dark": material("dark teal screen panel", (0.02, 0.13, 0.15, 1.0)),
        "skin": material("warm neutral skin placeholder", (0.78, 0.58, 0.42, 1.0)),
        "shirt": material("customer muted green jacket", (0.18, 0.31, 0.27, 1.0)),
        "jeans": material("customer denim", (0.12, 0.18, 0.32, 1.0)),
        "hair": material("customer dark hair", (0.08, 0.05, 0.035, 1.0)),
    }

    collections = {spec["collection"]: make_collection(spec["collection"]) for spec in ASSET_EXPORTS.values()}
    full = collections["Full Benchmark Store"]

    def add_to_full(obj: bpy.types.Object) -> None:
        if obj.name not in full.objects:
            try:
                full.objects.link(obj)
            except RuntimeError:
                pass

    shell = collections["Store Shell"]
    for obj in [
        cube("mall_concourse_tile_floor", shell, (0, -0.055, 4.0), (12.0, 0.10, 3.0), mats["mall_tile"]),
        cube("store_low_pile_carpet_floor", shell, (0, -0.05, -1.8), (9.6, 0.10, 8.8), mats["carpet"]),
        cube("backroom_sealed_floor", shell, (0, -0.045, -7.2), (4.8, 0.10, 2.6), mats["mall_tile"]),
        cube("left_wall_light_retail", shell, (-4.9, 1.35, -1.8), (0.18, 2.8, 8.8), mats["wall"]),
        cube("right_wall_light_retail", shell, (4.9, 1.35, -1.8), (0.18, 2.8, 8.8), mats["wall"]),
        cube("rear_slatwall_game_wall", shell, (0, 1.35, -6.25), (9.6, 2.8, 0.18), mats["slatwall"]),
        cube("storefront_glass_left_bay", shell, (-2.9, 1.35, 2.65), (3.4, 2.5, 0.06), mats["glass"]),
        cube("storefront_glass_right_bay", shell, (2.9, 1.35, 2.65), (3.4, 2.5, 0.06), mats["glass"]),
        cube("storefront_door_threshold", shell, (0, 0.05, 2.65), (1.6, 0.18, 0.20), mats["black_metal"], 0.01),
        cube("storefront_upper_frame", shell, (0, 2.72, 2.63), (8.8, 0.18, 0.12), mats["black_metal"]),
        cube("backroom_door_frame", shell, (-2.25, 1.05, -6.15), (1.0, 2.1, 0.14), mats["black_metal"], 0.01),
        cube("ceiling_light_bar_front", shell, (0, 2.75, 0.2), (7.2, 0.05, 0.18), mats["white"]),
        cube("ceiling_light_bar_rear", shell, (0, 2.75, -3.6), (7.2, 0.05, 0.18), mats["white"]),
        cube("backroom_header_sign", shell, (-2.25, 2.15, -6.05), (1.15, 0.28, 0.06), mats["yellow"], 0.004),
    ]:
        add_to_full(obj)
    for x in [-5.0, -2.5, 0.0, 2.5, 5.0]:
        add_to_full(cube(f"mall_tile_grout_line_x_{x}", shell, (x, 0.002, 4.0), (0.018, 0.012, 3.0), mats["wall_shadow"]))
    for z in [3.05, 3.75, 4.45, 5.15]:
        add_to_full(cube(f"mall_tile_grout_line_z_{z}", shell, (0, 0.003, z), (12.0, 0.012, 0.018), mats["wall_shadow"]))
    for x in [-4.25, -1.55, 1.55, 4.25]:
        add_to_full(cube(f"storefront_black_vertical_mullion_{x}", shell, (x, 1.38, 2.58), (0.06, 2.45, 0.08), mats["black_metal"], 0.004))
    for x in [-0.42, 0.42]:
        add_to_full(cube(f"storefront_door_handle_{x}", shell, (x, 1.05, 2.47), (0.055, 0.62, 0.055), mats["brushed_metal"], 0.006))
    for i, y in enumerate([0.58, 0.82, 1.06, 1.30, 1.54, 1.78], start=1):
        add_to_full(cube(f"rear_slatwall_horizontal_groove_{i}", shell, (0, y, -6.14), (9.2, 0.026, 0.030), mats["wall_shadow"], 0.001))
    for x, name in [(-5.8, "left_neighbor_lease_hint"), (5.8, "right_neighbor_lease_hint")]:
        add_to_full(cube(name, shell, (x, 1.25, 3.18), (1.25, 2.1, 0.08), mats["wall"], 0.008))
        add_to_full(cube(f"{name}_sign_band", shell, (x, 2.38, 3.14), (1.05, 0.22, 0.05), mats["dark"], 0.004))
    for x in [-3.4, -1.2, 1.2, 3.4]:
        add_to_full(cube(f"ceiling_panel_seam_{x}", shell, (x, 2.735, -1.8), (0.025, 0.018, 8.2), mats["wall_shadow"]))
    for z in [1.3, -0.5, -2.3, -4.1]:
        add_to_full(cube(f"ceiling_panel_cross_seam_{z}", shell, (0, 2.737, z), (8.8, 0.018, 0.025), mats["wall_shadow"]))
    for obj in [
        cube("rear_wall_red_category_band", shell, (-2.70, 2.05, -6.12), (2.85, 0.16, 0.040), mats["red"], 0.002),
        cube("rear_wall_blue_category_band", shell, (0.10, 2.05, -6.12), (2.35, 0.16, 0.040), mats["blue"], 0.002),
        cube("rear_wall_green_category_band", shell, (2.65, 2.05, -6.12), (2.45, 0.16, 0.040), mats["green"], 0.002),
        cube("left_wall_poster_column_backer", shell, (-4.78, 1.42, -2.70), (0.050, 1.75, 1.10), mats["dark"], 0.004),
        cube("right_wall_price_policy_board", shell, (4.78, 1.45, -1.15), (0.050, 1.10, 0.92), mats["screen_dark"], 0.004),
    ]:
        add_to_full(obj)
    for i, z in enumerate([-3.10, -2.72, -2.34], start=1):
        for obj in poster_panel(shell, f"left_wall_period_poster_{i}", (-4.735, 1.22 + (i % 2) * 0.18, z), (0.040, 0.56, 0.30), [mats["blue"], mats["red"], mats["purple"]][i - 1], mats["yellow"], mats["white"]):
            add_to_full(obj)
    text_obj("rear_red_category_text", shell, "USED WALL", (-2.70, 2.07, -6.075), 0.10, mats["white"], (math.radians(90), 0, 0))
    text_obj("rear_blue_category_text", shell, "NEW CASES", (0.10, 2.07, -6.075), 0.10, mats["white"], (math.radians(90), 0, 0))
    text_obj("rear_green_category_text", shell, "ACCESSORIES", (2.65, 2.07, -6.075), 0.10, mats["white"], (math.radians(90), 0, 0))
    text_obj("backroom_header_text", shell, "RECEIVING", (-2.25, 2.16, -6.015), 0.12, mats["dark"], (math.radians(90), 0, 0))
    add_area_light("warm_retail_area_light_front", shell, (0, 2.55, 0.2), 260, 5.0)
    add_area_light("warm_retail_area_light_back", shell, (0, 2.55, -3.6), 210, 4.0)

    shelving = collections["Shelving Pack"]
    # Wall shelf.
    for i, y in enumerate([0.45, 0.85, 1.25]):
        add_to_full(cube(f"used_wall_shelf_wood_level_{i+1}", shelving, (-2.6, y, -5.92), (2.9, 0.07, 0.38), mats["wood"], 0.01))
        add_to_full(cube(f"used_wall_shelf_front_lip_{i+1}", shelving, (-2.6, y + 0.045, -5.70), (2.9, 0.055, 0.035), mats["black_metal"], 0.004))
        add_to_full(cube(f"used_wall_shelf_back_price_rail_{i+1}", shelving, (-2.6, y + 0.075, -5.71), (2.55, 0.045, 0.025), mats["yellow"], 0.002))
    for x in [-4.0, -2.6, -1.2]:
        add_to_full(cube(f"used_wall_shelf_black_upright_{x}", shelving, (x, 0.78, -5.78), (0.06, 1.4, 0.10), mats["black_metal"], 0.005))
    add_to_full(cube("used_wall_shelf_header_strip", shelving, (-2.6, 1.60, -5.72), (2.9, 0.18, 0.05), mats["yellow"], 0.006))
    text_obj("used_games_header_text", shelving, "USED FICTIONAL GAMES", (-2.6, 1.62, -5.69), 0.12, mats["dark"], (math.radians(90), 0, 0))
    for i, x in enumerate([-3.45, -2.55, -1.65], start=1):
        add_to_full(price_tag(shelving, f"used_wall_shelf_price_tag_{i}", (x, 0.62, -5.70), mats["yellow"]))
    for row, y in enumerate([0.56, 0.96, 1.36], start=1):
        for col, x in enumerate([-3.90, -3.60, -3.30, -3.00, -2.70, -2.40, -2.10, -1.80, -1.50, -1.20], start=1):
            color = [mats["blue"], mats["red"], mats["green"], mats["purple"], mats["orange"], mats["magenta"], mats["cyan"]][(row + col) % 7]
            add_to_full(cube(f"wall_dense_cover_face_{row}_{col}", shelving, (x, y, -5.665), (0.15, 0.22, 0.020), color, 0.003))
            add_to_full(cube(f"wall_dense_price_tick_{row}_{col}", shelving, (x + 0.045, y - 0.075, -5.650), (0.045, 0.026, 0.018), mats["yellow"], 0.001))
    for i, x in enumerate([-3.78, -3.08, -2.38, -1.68], start=1):
        add_to_full(cube(f"platform_header_chip_{i}", shelving, (x, 1.82, -5.66), (0.46, 0.12, 0.030), [mats["blue"], mats["red"], mats["green"], mats["orange"]][i - 1], 0.003))
    # Gondola.
    for i, y in enumerate([0.42, 0.78, 1.14]):
        add_to_full(cube(f"starter_gondola_center_shelf_{i+1}", shelving, (1.15, y, -2.55), (2.3, 0.08, 0.72), mats["wood"], 0.01))
        add_to_full(cube(f"starter_gondola_front_lip_{i+1}", shelving, (1.15, y + 0.04, -2.14), (2.25, 0.05, 0.04), mats["black_metal"], 0.004))
        add_to_full(cube(f"starter_gondola_rear_lip_{i+1}", shelving, (1.15, y + 0.04, -2.96), (2.25, 0.05, 0.04), mats["black_metal"], 0.004))
    for x in [0.0, 1.15, 2.30]:
        add_to_full(cube(f"starter_gondola_black_post_{x}", shelving, (x, 0.78, -2.55), (0.06, 1.35, 0.78), mats["black_metal"], 0.004))
    add_to_full(cube("starter_gondola_new_release_header", shelving, (1.15, 1.48, -2.55), (2.35, 0.18, 0.08), mats["yellow"], 0.006))
    text_obj("new_releases_header_text", shelving, "NEW RELEASES", (1.15, 1.50, -2.49), 0.13, mats["dark"], (math.radians(90), 0, 0))
    add_to_full(price_tag(shelving, "gondola_sale_price_tag_front", (1.15, 0.60, -2.14), mats["yellow"]))
    for i, x in enumerate([0.45, 0.85, 1.25, 1.65, 2.05], start=1):
        add_to_full(cube(f"gondola_empty_capacity_slot_{i}", shelving, (x, 0.82, -2.12), (0.12, 0.10, 0.018), mats["wall"], 0.002))
    for obj in [
        cube("narrow_clearance_endcap_base", shelving, (2.82, 0.50, -2.55), (0.42, 1.00, 0.62), mats["black_metal"], 0.012),
        cube("narrow_clearance_endcap_face", shelving, (2.82, 1.05, -2.22), (0.40, 0.30, 0.045), mats["orange_tag"], 0.004),
        cube("wire_grid_accessory_panel", shelving, (3.72, 1.08, -3.25), (0.06, 1.34, 1.06), mats["black_metal"], 0.006),
    ]:
        add_to_full(obj)
    for i, y in enumerate([0.58, 0.82, 1.06, 1.30, 1.54], start=1):
        add_to_full(cube(f"wire_grid_horizontal_{i}", shelving, (3.66, y, -3.25), (0.045, 0.018, 1.02), mats["brushed_metal"], 0.001))
    for i, z in enumerate([-3.70, -3.46, -3.22, -2.98, -2.74], start=1):
        add_to_full(cube(f"wire_grid_vertical_{i}", shelving, (3.655, 1.04, z), (0.045, 1.18, 0.018), mats["brushed_metal"], 0.001))
    for i, z in enumerate([-3.58, -3.30, -3.02], start=1):
        add_to_full(cube(f"accessory_hanging_pack_{i}", shelving, (3.58, 1.22 - i * 0.18, z), (0.12, 0.22, 0.16), [mats["green"], mats["blue"], mats["orange"]][i - 1], 0.004))
    text_obj("clearance_endcap_text", shelving, "USED DEALS", (2.82, 1.07, -2.18), 0.062, mats["dark"], (math.radians(90), 0, 0))

    counter = collections["Counter Register"]
    for obj in [
        cube("checkout_counter_laminate_base", counter, (3.0, 0.48, -0.75), (2.25, 0.95, 0.86), mats["wood"], 0.035),
        cube("checkout_counter_black_top", counter, (3.0, 0.98, -0.75), (2.35, 0.08, 0.92), mats["black_metal"], 0.02),
        cube("cash_drawer_front", counter, (2.55, 0.77, -0.28), (0.72, 0.18, 0.05), mats["dark"], 0.01),
        cube("register_body", counter, (2.65, 1.15, -0.92), (0.55, 0.20, 0.30), mats["dark"], 0.02),
        cube("register_screen", counter, (2.65, 1.34, -1.04), (0.55, 0.36, 0.06), mats["screen"], 0.01),
        cube("barcode_scanner_wedge", counter, (3.35, 1.12, -0.55), (0.16, 0.10, 0.36), mats["dark"], 0.01),
        cube("receipt_roll", counter, (3.55, 1.08, -0.90), (0.20, 0.08, 0.20), mats["white"], 0.02),
        cube("counter_trade_mat_placeholder", counter, (2.95, 1.04, -0.48), (0.75, 0.015, 0.34), mats["green"], 0.004),
        cube("customer_queue_floor_marker", counter, (2.1, 0.012, 0.20), (0.75, 0.024, 0.09), mats["yellow"], 0.002),
        cube("counter_receipt_slip", counter, (3.28, 1.035, -0.32), (0.22, 0.012, 0.36), mats["white"], 0.002),
        cube("customer_side_counter_sign", counter, (2.18, 0.83, -0.24), (0.55, 0.22, 0.035), mats["yellow"], 0.004),
        cube("staff_side_counter_sign", counter, (3.82, 0.83, -1.20), (0.48, 0.20, 0.035), mats["screen_dark"], 0.004),
        cube("card_reader_body", counter, (3.48, 1.10, -0.30), (0.24, 0.11, 0.18), mats["dark"], 0.008),
        cube("card_reader_screen", counter, (3.48, 1.18, -0.35), (0.18, 0.07, 0.022), mats["screen"], 0.002),
        cube("register_customer_display_pole", counter, (2.18, 1.32, -0.88), (0.045, 0.42, 0.045), mats["black_metal"], 0.004),
        cube("register_customer_display", counter, (2.18, 1.58, -0.88), (0.40, 0.16, 0.050), mats["screen"], 0.004),
        cube("glass_counter_display_front", counter, (3.05, 0.72, -0.18), (1.32, 0.42, 0.040), mats["transparent_case"], 0.006),
        cube("glass_counter_display_top", counter, (3.05, 0.96, -0.46), (1.32, 0.035, 0.54), mats["transparent_case"], 0.004),
        cube("counter_console_box_blue", counter, (3.72, 1.14, -0.82), (0.30, 0.28, 0.22), mats["blue"], 0.008),
        cube("counter_console_box_green", counter, (3.78, 1.13, -0.50), (0.28, 0.26, 0.20), mats["green"], 0.008),
        cube("counter_flyer_stand", counter, (2.28, 1.10, -0.42), (0.18, 0.28, 0.040), mats["paper"], 0.003),
        cube("counter_impulse_rack_back", counter, (3.84, 1.00, -1.26), (0.36, 0.58, 0.050), mats["black_metal"], 0.004),
    ]:
        add_to_full(obj)
    for i, y in enumerate([0.78, 0.64, 0.50], start=1):
        for j, x in enumerate([2.58, 2.82, 3.06, 3.30], start=1):
            add_to_full(cube(f"inside_glass_case_memory_card_{i}_{j}", counter, (x, y, -0.175), (0.12, 0.08, 0.018), [mats["blue"], mats["red"], mats["green"], mats["purple"]][(i + j) % 4], 0.002))
    for i, y in enumerate([0.82, 1.02, 1.22], start=1):
        add_to_full(cube(f"counter_impulse_pack_{i}", counter, (3.83, y, -1.21), (0.22, 0.15, 0.030), [mats["orange"], mats["cyan"], mats["magenta"]][i - 1], 0.003))
    for row in range(3):
        for col in range(4):
            add_to_full(cube(f"register_keypad_button_{row}_{col}", counter, (2.48 + col * 0.055, 1.275 - row * 0.035, -0.745), (0.032, 0.014, 0.020), mats["brushed_metal"], 0.002))
    for i, z in enumerate([-0.38, -0.32, -0.26], start=1):
        add_to_full(label_line(counter, f"receipt_print_line_{i}", (3.28, 1.045, z), 0.16 - i * 0.02, mats["dark"], 0.010, 0.006))
    text_obj("register_screen_sale_text", counter, "SALE  $24.99", (2.65, 1.35, -0.995), 0.055, mats["white"], (math.radians(90), 0, 0))
    text_obj("customer_side_counter_text", counter, "CHECKOUT", (2.18, 0.84, -0.190), 0.055, mats["dark"], (math.radians(90), 0, 0))
    text_obj("staff_side_counter_text", counter, "TILL", (3.82, 0.84, -1.175), 0.050, mats["white"], (math.radians(90), 0, 0))
    text_obj("register_customer_display_text", counter, "$24.99", (2.18, 1.585, -0.835), 0.050, mats["white"], (math.radians(90), 0, 0))
    text_obj("counter_flyer_stand_text", counter, "TRADE\nTODAY", (2.28, 1.11, -0.390), 0.030, mats["dark"], (math.radians(90), 0, 0))

    receiving = collections["Receiving Backroom"]
    for obj in [
        cube("receiving_table_laminate_top", receiving, (-1.2, 0.74, -7.25), (1.8, 0.08, 0.95), mats["wood"], 0.012),
        cube("receiving_table_left_leg", receiving, (-1.95, 0.36, -6.9), (0.08, 0.72, 0.08), mats["black_metal"], 0.004),
        cube("receiving_table_right_leg", receiving, (-0.45, 0.36, -7.6), (0.08, 0.72, 0.08), mats["black_metal"], 0.004),
        cube("open_shipment_box_bottom", receiving, (-1.15, 0.86, -7.25), (0.95, 0.12, 0.62), mats["cardboard"], 0.01),
        cube("open_shipment_box_back_flap", receiving, (-1.15, 1.10, -7.55), (0.95, 0.42, 0.06), mats["cardboard"], 0.01),
        cube("open_shipment_box_left_flap", receiving, (-1.66, 1.08, -7.25), (0.06, 0.36, 0.62), mats["cardboard"], 0.01),
        cube("open_shipment_box_front_lip", receiving, (-1.15, 0.98, -6.92), (0.95, 0.24, 0.05), mats["cardboard_edge"], 0.006),
        cube("open_shipment_box_right_flap", receiving, (-0.64, 1.02, -7.25), (0.06, 0.24, 0.62), mats["cardboard"], 0.008),
        cube("open_shipment_visible_tape_front", receiving, (-1.15, 1.12, -6.89), (0.62, 0.060, 0.018), mats["packing_tape"], 0.002),
        cube("open_shipment_front_label", receiving, (-1.15, 1.04, -6.88), (0.34, 0.120, 0.018), mats["paper"], 0.002),
        cube("shipment_box_tape_strip", receiving, (-1.15, 1.18, -7.55), (0.72, 0.045, 0.012), mats["packing_tape"], 0.002),
        cube("shipment_box_white_label", receiving, (-1.15, 1.20, -7.50), (0.40, 0.12, 0.014), mats["paper"], 0.002),
        cube("invoice_manifest_sheet", receiving, (-0.55, 0.83, -7.00), (0.38, 0.012, 0.26), mats["white"], 0.002),
        cube("receiving_clipboard", receiving, (-0.48, 0.86, -6.86), (0.46, 0.035, 0.30), mats["dark"], 0.004),
        cube("manifest_top_sheet", receiving, (-0.48, 0.89, -6.86), (0.40, 0.012, 0.24), mats["white"], 0.002),
        cube("odd_manifest_note", receiving, (-0.86, 0.94, -6.93), (0.24, 0.012, 0.15), mats["orange_tag"], 0.002),
        cube("sealed_backroom_shipper_a", receiving, (0.35, 0.30, -7.75), (0.70, 0.60, 0.52), mats["cardboard"], 0.012),
        cube("sealed_backroom_shipper_b", receiving, (0.92, 0.22, -7.20), (0.46, 0.44, 0.42), mats["cardboard"], 0.012),
        cube("backroom_wall_clipboard_hook", receiving, (0.15, 1.55, -8.42), (0.50, 0.34, 0.030), mats["dark"], 0.003),
        cube("backroom_wall_schedule_sheet", receiving, (0.15, 1.55, -8.39), (0.42, 0.27, 0.018), mats["paper"], 0.002),
        cube("receiving_floor_pallet", receiving, (0.52, 0.09, -6.55), (1.00, 0.12, 0.62), mats["wood"], 0.006),
        cube("receiving_pallet_box_small", receiving, (0.28, 0.34, -6.52), (0.38, 0.36, 0.34), mats["cardboard"], 0.006),
        cube("receiving_pallet_box_label", receiving, (0.28, 0.44, -6.33), (0.24, 0.10, 0.012), mats["paper"], 0.001),
        cube("receiving_tape_gun_body", receiving, (-0.72, 0.93, -7.58), (0.24, 0.10, 0.11), mats["orange_tag"], 0.006),
        cube("receiving_tape_gun_handle", receiving, (-0.72, 0.84, -7.57), (0.07, 0.16, 0.07), mats["dark"], 0.004),
        cube("receiving_marker_pen", receiving, (-0.30, 0.91, -6.92), (0.20, 0.020, 0.025), mats["dark"], 0.003),
        cube("receiving_label_roll", receiving, (-0.22, 0.92, -7.22), (0.18, 0.08, 0.18), mats["paper"], 0.010),
        cube("backroom_wall_sort_sign", receiving, (-1.40, 1.52, -8.41), (0.62, 0.38, 0.025), mats["yellow"], 0.002),
        cube("backroom_backstock_shelf_a", receiving, (3.35, 0.48, -8.85), (0.78, 0.10, 0.42), mats["wood"], 0.006),
        cube("backroom_backstock_shelf_b", receiving, (3.35, 0.88, -8.85), (0.78, 0.10, 0.42), mats["wood"], 0.006),
        cube("backroom_backstock_post_left", receiving, (2.95, 0.64, -8.85), (0.05, 1.00, 0.46), mats["black_metal"], 0.002),
        cube("backroom_backstock_post_right", receiving, (3.75, 0.64, -8.85), (0.05, 1.00, 0.46), mats["black_metal"], 0.002),
    ]:
        add_to_full(obj)
    for i, x in enumerate([-1.42, -1.24, -1.06, -0.88], start=1):
        add_to_full(cube(f"open_box_visible_case_spine_{i}", receiving, (x, 1.08, -7.02), (0.12, 0.30, 0.040), [mats["blue"], mats["red"], mats["green"], mats["purple"]][i - 1], 0.003))
    for i, x in enumerate([-0.69, -0.61, -0.53, -0.45], start=1):
        add_to_full(label_line(receiving, f"manifest_barcode_line_{i}", (x, 0.845, -6.87), 0.030, mats["dark"], 0.045, 0.005))
    text_obj("invoice_manifest_text", receiving, "INVOICE\n12 CASES", (-0.55, 0.842, -7.00), 0.045, mats["dark"], (math.radians(90), 0, 0))
    text_obj("manifest_clipboard_text", receiving, "STARTER\nSHIPMENT", (-0.48, 0.902, -6.86), 0.040, mats["dark"], (math.radians(90), 0, 0))
    text_obj("odd_manifest_note_text", receiving, "1 EXTRA?", (-0.86, 0.952, -6.93), 0.030, mats["dark"], (math.radians(90), 0, 0))
    text_obj("shipment_box_label_text", receiving, "PIXEL DEPOT\nBOX 1", (-1.15, 1.215, -7.49), 0.032, mats["dark"], (math.radians(90), 0, 0))
    text_obj("open_shipment_front_label_text", receiving, "12 CASES", (-1.15, 1.055, -6.85), 0.032, mats["dark"], (math.radians(90), 0, 0))
    text_obj("backroom_schedule_text", receiving, "RECEIVE\nPRICE\nSTOCK", (0.15, 1.56, -8.37), 0.032, mats["dark"], (math.radians(90), 0, 0))
    text_obj("backroom_wall_sort_text", receiving, "SORT:\nNEW\nUSED\nPRICE", (-1.40, 1.53, -8.39), 0.038, mats["dark"], (math.radians(90), 0, 0))
    for i, x in enumerate([3.12, 3.35, 3.58], start=1):
        add_to_full(cube(f"backstock_shelf_case_stack_{i}", receiving, (x, 1.05, -8.69), (0.14, 0.24, 0.040), [mats["blue"], mats["red"], mats["green"]][i - 1], 0.003))

    product = collections["Product Cases"]
    cover_mats = [mats["blue"], mats["red"], mats["green"], mats["purple"], mats["orange"]]
    for i in range(18):
        x = -3.65 + (i % 9) * 0.27
        y = 1.42 if i >= 9 else 1.02
        make_case(product, f"fictional_game_case_shelf_{i+1:02d}", (x, y, -5.60), cover_mats[i % len(cover_mats)], cover_mats[(i + 1) % len(cover_mats)], mats["yellow"], used=i % 2 == 1)
    for i in range(8):
        make_case(product, f"open_box_case_{i+1:02d}", (-1.45 + (i % 4) * 0.20, 1.03 + (i // 4) * 0.06, -7.24), cover_mats[(i + 1) % len(cover_mats)], cover_mats[(i + 2) % len(cover_mats)], mats["yellow"], used=i % 2 == 0)
    make_case(product, "first_person_held_case_sample", (0.28, 1.03, 0.62), mats["blue"], mats["green"], mats["yellow"], used=False)
    add_to_full(cube("held_case_large_title_plate", product, (0.28, 1.08, 0.664), (0.11, 0.035, 0.010), mats["white"], 0.001))
    add_to_full(cube("held_case_genre_stripe", product, (0.28, 0.98, 0.666), (0.12, 0.020, 0.010), mats["orange_tag"], 0.001))
    text_obj("held_case_title_text", product, "STAR\nRUNNER", (0.28, 1.05, 0.690), 0.034, mats["white"], (math.radians(90), 0, 0))
    text_obj("held_case_price_text", product, "$24", (0.327, 1.035, 0.692), 0.024, mats["dark"], (math.radians(90), 0, 0))
    for i, label in enumerate(["NOVA", "VERTEX", "PULSE"]):
        text_obj(f"shelf_platform_spine_text_{i}", product, label, (-3.56 + i * 0.78, 1.64, -5.575), 0.050, mats["white"], (math.radians(90), 0, 0))
    for i, label in enumerate(["NEW", "USED", "USED"]):
        text_obj(f"shelf_condition_sticker_text_{i}", product, label, (-3.45 + i * 0.54, 1.205, -5.635), 0.026, mats["dark"], (math.radians(90), 0, 0))
    add_to_full(cube("held_case_player_hand_left", product, (0.15, 0.86, 0.60), (0.10, 0.08, 0.06), mats["skin"], 0.012))
    add_to_full(cube("held_case_player_hand_right", product, (0.42, 0.86, 0.60), (0.10, 0.08, 0.06), mats["skin"], 0.012))
    for obj in list(product.objects):
        add_to_full(obj)

    signage = collections["Signage Posters"]
    for obj in [
        cube("fictional_storefront_sign_backlit_panel", signage, (0, 2.35, 2.56), (3.25, 0.34, 0.08), mats["yellow"], 0.012),
        cube("open_closed_hanging_sign", signage, (0.0, 1.65, 2.50), (0.72, 0.25, 0.04), mats["dark"], 0.006),
        cube("front_window_poster_left", signage, (-3.35, 1.55, 2.48), (0.56, 0.78, 0.025), mats["blue"], 0.004),
        cube("front_window_poster_right", signage, (3.35, 1.50, 2.48), (0.56, 0.72, 0.025), mats["red"], 0.004),
        cube("sale_tag_pack_header", signage, (1.15, 1.32, -2.12), (0.55, 0.16, 0.025), mats["yellow"], 0.003),
        cube("window_hours_decal_panel", signage, (-0.78, 1.05, 2.49), (0.38, 0.30, 0.020), mats["paper"], 0.002),
        cube("window_buy_sell_decal_panel", signage, (0.78, 1.05, 2.49), (0.42, 0.28, 0.020), mats["orange_tag"], 0.002),
        cube("storefront_sign_black_trim_top", signage, (0, 2.55, 2.50), (3.50, 0.060, 0.060), mats["black_metal"], 0.004),
        cube("storefront_sign_black_trim_bottom", signage, (0, 2.16, 2.50), (3.50, 0.060, 0.060), mats["black_metal"], 0.004),
        cube("poster_left_title_bar", signage, (-3.35, 1.82, 2.455), (0.42, 0.070, 0.014), mats["yellow"], 0.001),
        cube("poster_left_art_block", signage, (-3.35, 1.46, 2.455), (0.35, 0.34, 0.014), mats["green"], 0.001),
        cube("poster_right_title_bar", signage, (3.35, 1.74, 2.455), (0.38, 0.070, 0.014), mats["yellow"], 0.001),
        cube("poster_right_art_block", signage, (3.35, 1.42, 2.455), (0.32, 0.30, 0.014), mats["purple"], 0.001),
    ]:
        add_to_full(obj)
    for i, x in enumerate([-1.05, -0.72, -0.39, -0.06, 0.27, 0.60, 0.93], start=1):
        add_to_full(cube(f"storefront_pixel_logo_block_{i}", signage, (x, 2.36, 2.62), (0.20, 0.16, 0.022), mats["dark"], 0.002))
    add_to_full(cube("storefront_depot_wordmark_bar", signage, (0.0, 2.25, 2.62), (1.90, 0.050, 0.022), mats["dark"], 0.001))
    text_obj("fictional_storefront_sign_text", signage, "PIXEL DEPOT", (0, 2.36, 2.64), 0.22, mats["dark"], (math.radians(90), 0, 0))
    text_obj("open_closed_sign_text", signage, "CLOSED", (0, 1.655, 2.53), 0.10, mats["yellow"], (math.radians(90), 0, 0))
    text_obj("sale_tag_header_text", signage, "USED $9-24", (1.15, 1.33, -2.10), 0.055, mats["dark"], (math.radians(90), 0, 0))
    text_obj("window_hours_decal_text", signage, "OPEN\n11-8", (-0.78, 1.055, 2.53), 0.035, mats["dark"], (math.radians(90), 0, 0))
    text_obj("window_buy_sell_decal_text", signage, "BUY\nSELL", (0.78, 1.055, 2.53), 0.038, mats["dark"], (math.radians(90), 0, 0))
    text_obj("poster_left_title_text", signage, "LAUNCH", (-3.35, 1.825, 2.53), 0.034, mats["dark"], (math.radians(90), 0, 0))
    text_obj("poster_right_title_text", signage, "USED", (3.35, 1.745, 2.53), 0.034, mats["dark"], (math.radians(90), 0, 0))

    customer = collections["Customer Placeholder"]
    for obj in [
        cylinder("customer_placeholder_torso", customer, (-1.7, 0.95, 1.85), 0.24, 0.78, mats["shirt"], 24),
        sphere("customer_placeholder_head", customer, (-1.7, 1.50, 1.85), 0.18, mats["skin"]),
        sphere("customer_hair_cap", customer, (-1.7, 1.62, 1.85), 0.16, mats["hair"]),
        cube("customer_shoulder_line", customer, (-1.7, 1.22, 1.85), (0.62, 0.10, 0.16), mats["shirt"], 0.015),
        cube("customer_left_arm", customer, (-2.03, 0.92, 1.85), (0.10, 0.55, 0.10), mats["shirt"], 0.018),
        cube("customer_right_arm", customer, (-1.37, 0.92, 1.85), (0.10, 0.55, 0.10), mats["shirt"], 0.018),
        cylinder("customer_left_leg", customer, (-1.82, 0.39, 1.85), 0.07, 0.72, mats["jeans"], 16),
        cylinder("customer_right_leg", customer, (-1.58, 0.39, 1.85), 0.07, 0.72, mats["jeans"], 16),
        cube("customer_left_shoe", customer, (-1.82, 0.04, 1.76), (0.16, 0.08, 0.26), mats["dark"], 0.012),
        cube("customer_right_shoe", customer, (-1.58, 0.04, 1.94), (0.16, 0.08, 0.26), mats["dark"], 0.012),
        cube("customer_carry_bag_hint", customer, (-1.37, 0.82, 1.78), (0.18, 0.28, 0.08), mats["white"], 0.008),
        cube("customer_bag_handle", customer, (-1.37, 1.00, 1.78), (0.12, 0.05, 0.035), mats["dark"], 0.004),
        cube("customer_entry_shadow", customer, (-1.70, 0.012, 1.85), (0.72, 0.020, 0.46), mats["wall_shadow"], 0.004),
    ]:
        add_to_full(obj)

    report = collections["Daily Report Computer"]
    for obj in [
        cube("backroom_computer_desk", report, (1.25, 0.72, -7.95), (1.30, 0.10, 0.62), mats["wood"], 0.01),
        cube("daily_report_crt_body", report, (1.25, 1.02, -8.08), (0.72, 0.46, 0.32), mats["dark"], 0.025),
        cube("daily_report_crt_screen", report, (1.25, 1.04, -7.90), (0.56, 0.32, 0.025), mats["screen"], 0.004),
        cube("keyboard_block", report, (1.25, 0.82, -7.72), (0.72, 0.04, 0.20), mats["dark"], 0.006),
        cube("daily_report_paper_printout", report, (0.74, 0.86, -7.70), (0.34, 0.012, 0.46), mats["white"], 0.002),
        cube("daily_report_screen_panel", report, (1.25, 1.08, -7.868), (0.62, 0.40, 0.012), mats["screen_dark"], 0.003),
        cube("daily_report_title_bar", report, (1.25, 1.23, -7.852), (0.50, 0.042, 0.008), mats["yellow"], 0.001),
        cube("daily_report_sales_bar", report, (1.18, 1.125, -7.852), (0.30, 0.024, 0.008), mats["yellow"], 0.001),
        cube("daily_report_margin_bar", report, (1.16, 1.055, -7.852), (0.25, 0.024, 0.008), mats["green"], 0.001),
        cube("daily_report_restock_bar", report, (1.28, 0.985, -7.852), (0.42, 0.024, 0.008), mats["white"], 0.001),
        cube("daily_report_table_left_rule", report, (0.98, 1.055, -7.850), (0.012, 0.230, 0.007), mats["white"], 0.001),
        cube("daily_report_table_mid_rule", report, (1.25, 1.055, -7.850), (0.012, 0.230, 0.007), mats["white"], 0.001),
        cube("daily_report_table_bottom_rule", report, (1.25, 0.925, -7.850), (0.50, 0.010, 0.007), mats["white"], 0.001),
        cube("mouse_block", report, (1.77, 0.82, -7.72), (0.16, 0.04, 0.23), mats["dark"], 0.010),
        cube("computer_sticky_note", report, (0.84, 1.18, -7.90), (0.18, 0.14, 0.012), mats["yellow"], 0.002),
    ]:
        add_to_full(obj)
    for row, y in enumerate([0.79, 0.815, 0.84], start=1):
        for col, x in enumerate([1.02, 1.13, 1.24, 1.35, 1.46], start=1):
            add_to_full(cube(f"keyboard_key_{row}_{col}", report, (x, y, -7.62), (0.060, 0.010, 0.030), mats["brushed_metal"], 0.001))
    add_to_full(cube("daily_report_screen_title_block", report, (1.25, 1.19, -7.815), (0.42, 0.030, 0.010), mats["white"], 0.001))
    add_to_full(cube("daily_report_screen_cash_block", report, (1.16, 1.10, -7.815), (0.22, 0.024, 0.010), mats["yellow"], 0.001))
    add_to_full(cube("daily_report_screen_margin_block", report, (1.17, 1.04, -7.815), (0.28, 0.024, 0.010), mats["green"], 0.001))
    add_to_full(cube("daily_report_screen_restock_block", report, (1.25, 0.98, -7.815), (0.40, 0.024, 0.010), mats["paper"], 0.001))
    text_obj("daily_report_screen_text", report, "DAY 1", (1.25, 1.205, -7.790), 0.028, mats["white"], (math.radians(90), 0, 0))
    text_obj("daily_report_sales_text", report, "SALES", (1.07, 1.105, -7.790), 0.022, mats["white"], (math.radians(90), 0, 0))
    text_obj("daily_report_sales_value_text", report, "$74", (1.42, 1.105, -7.790), 0.024, mats["yellow"], (math.radians(90), 0, 0))
    text_obj("daily_report_margin_text", report, "MARGIN", (1.07, 1.045, -7.790), 0.022, mats["white"], (math.radians(90), 0, 0))
    text_obj("daily_report_margin_value_text", report, "$31", (1.42, 1.045, -7.790), 0.024, mats["green"], (math.radians(90), 0, 0))
    text_obj("daily_report_restock_text", report, "RESTOCK USED", (1.25, 0.985, -7.790), 0.021, mats["white"], (math.radians(90), 0, 0))
    text_obj("daily_report_printout_text", report, "END DAY\nUSED LOW\nORDER 6", (0.74, 0.875, -7.70), 0.034, mats["dark"], (math.radians(90), 0, 0))
    text_obj("computer_sticky_note_text", report, "COUNT\nCASH", (0.84, 1.185, -7.885), 0.026, mats["dark"], (math.radians(90), 0, 0))

    # Convert text objects to mesh for reliable GLB import.
    bpy.ops.object.select_all(action="DESELECT")
    text_objects = [obj for obj in bpy.context.scene.objects if obj.type == "FONT"]
    for obj in text_objects:
        obj.select_set(True)
        bpy.context.view_layer.objects.active = obj
        bpy.ops.object.convert(target="MESH")
        obj.select_set(False)

    for collection_name, collection in collections.items():
        if collection_name == "Full Benchmark Store":
            continue
        for obj in collection.objects:
            add_to_full(obj)

    # Add a review camera.
    bpy.ops.object.camera_add(location=(6.2, 2.2, 6.2), rotation=(math.radians(64), 0, math.radians(135)))
    bpy.context.scene.camera = bpy.context.object

    return collections


def export_collection(collection: bpy.types.Collection, filepath: Path) -> None:
    bpy.ops.object.select_all(action="DESELECT")
    objects = [obj for obj in collection.objects if obj.type in {"MESH", "LIGHT", "CAMERA"}]
    for obj in objects:
        obj.select_set(True)
    if objects:
        bpy.context.view_layer.objects.active = objects[0]
    bpy.ops.export_scene.gltf(
        filepath=str(filepath),
        export_format="GLB",
        use_selection=True,
        export_apply=True,
        export_yup=True,
        export_materials="EXPORT",
        export_lights=True,
    )


def main() -> None:
    SOURCE_DIR.mkdir(parents=True, exist_ok=True)
    EXPORT_DIR.mkdir(parents=True, exist_ok=True)
    GAME_ASSET_DIR.mkdir(parents=True, exist_ok=True)

    reset_scene()
    collections = build_assets()
    bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE_BLEND))

    manifest = {
        "source_blend": str(SOURCE_BLEND.relative_to(REPO_ROOT)),
        "generated_by": str(Path(__file__).relative_to(REPO_ROOT)),
        "assets": [],
    }

    for asset_name, spec in ASSET_EXPORTS.items():
        collection = collections[spec["collection"]]
        export_path = EXPORT_DIR / f"{asset_name}.glb"
        game_path = GAME_ASSET_DIR / f"{asset_name}.glb"
        export_collection(collection, export_path)
        shutil.copyfile(export_path, game_path)
        manifest["assets"].append(
            {
                "asset": asset_name,
                "source_collection": spec["collection"],
                "source_blend": str(SOURCE_BLEND.relative_to(REPO_ROOT)),
                "export_path": str(export_path.relative_to(REPO_ROOT)),
                "godot_path": str(game_path.relative_to(REPO_ROOT)),
                "description": spec["description"],
                "benchmark_targets": spec["targets"],
            }
        )

    MANIFEST_PATH.write_text(json.dumps(manifest, indent=2) + "\n")
    print(json.dumps(manifest, indent=2))


if __name__ == "__main__":
    main()
