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
    sticker_x = loc[0] + (0.045 if not used else -0.045)
    sticker = cube(f"{name}_price_sticker", collection, (sticker_x, loc[1] + 0.004, sticker_z), (0.050, 0.030, 0.008), sticker_mat, 0.001)
    sticker.rotation_euler = root.rotation_euler


def price_tag(
    collection: bpy.types.Collection,
    name: str,
    loc: tuple[float, float, float],
    mat: bpy.types.Material,
) -> bpy.types.Object:
    return cube(name, collection, loc, (0.34, 0.08, 0.018), mat, 0.002)


def build_assets() -> dict[str, bpy.types.Collection]:
    mats = {
        "carpet": material("muted blue-gray low-pile carpet", (0.12, 0.20, 0.22, 1.0)),
        "mall_tile": material("warm off-white mall tile", (0.54, 0.53, 0.47, 1.0)),
        "wall": material("light scuffed retail wall", (0.58, 0.62, 0.58, 1.0)),
        "slatwall": material("cream retail slatwall", (0.67, 0.65, 0.56, 1.0)),
        "black_metal": material("black powder-coated metal", (0.015, 0.017, 0.018, 1.0), 0.55, 0.25),
        "wood": material("warm laminate wood shelf", (0.44, 0.27, 0.12, 1.0)),
        "cardboard": material("corrugated cardboard", (0.48, 0.31, 0.14, 1.0)),
        "glass": material("slightly blue storefront glass", (0.36, 0.62, 0.76, 0.34)),
        "yellow": material("yellow sale sticker", (0.88, 0.67, 0.10, 1.0)),
        "red": material("used red case art", (0.82, 0.17, 0.16, 1.0)),
        "blue": material("new blue case art", (0.08, 0.32, 0.86, 1.0)),
        "green": material("accessory green box art", (0.16, 0.56, 0.25, 1.0)),
        "purple": material("fictional purple cover accent", (0.42, 0.18, 0.62, 1.0)),
        "orange": material("fictional orange cover accent", (0.90, 0.45, 0.13, 1.0)),
        "white": material("printed white label", (0.78, 0.75, 0.64, 1.0)),
        "dark": material("register dark plastic", (0.04, 0.05, 0.06, 1.0)),
        "screen": material("soft cyan screen glow", (0.05, 0.30, 0.34, 1.0)),
        "skin": material("warm neutral skin placeholder", (0.78, 0.58, 0.42, 1.0)),
        "shirt": material("customer muted green jacket", (0.18, 0.31, 0.27, 1.0)),
        "jeans": material("customer denim", (0.12, 0.18, 0.32, 1.0)),
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
    text_obj("backroom_header_text", shell, "RECEIVING", (-2.25, 2.16, -6.015), 0.12, mats["dark"], (math.radians(90), 0, 0))
    add_area_light("warm_retail_area_light_front", shell, (0, 2.55, 0.2), 260, 5.0)
    add_area_light("warm_retail_area_light_back", shell, (0, 2.55, -3.6), 210, 4.0)

    shelving = collections["Shelving Pack"]
    # Wall shelf.
    for i, y in enumerate([0.45, 0.85, 1.25]):
        add_to_full(cube(f"used_wall_shelf_wood_level_{i+1}", shelving, (-2.6, y, -5.92), (2.9, 0.07, 0.38), mats["wood"], 0.01))
    for x in [-4.0, -2.6, -1.2]:
        add_to_full(cube(f"used_wall_shelf_black_upright_{x}", shelving, (x, 0.78, -5.78), (0.06, 1.4, 0.10), mats["black_metal"], 0.005))
    add_to_full(cube("used_wall_shelf_header_strip", shelving, (-2.6, 1.60, -5.72), (2.9, 0.18, 0.05), mats["yellow"], 0.006))
    text_obj("used_games_header_text", shelving, "USED FICTIONAL GAMES", (-2.6, 1.62, -5.69), 0.12, mats["dark"], (math.radians(90), 0, 0))
    for i, x in enumerate([-3.45, -2.55, -1.65], start=1):
        add_to_full(price_tag(shelving, f"used_wall_shelf_price_tag_{i}", (x, 0.62, -5.70), mats["yellow"]))
    # Gondola.
    for i, y in enumerate([0.42, 0.78, 1.14]):
        add_to_full(cube(f"starter_gondola_center_shelf_{i+1}", shelving, (1.15, y, -2.55), (2.3, 0.08, 0.72), mats["wood"], 0.01))
    for x in [0.0, 1.15, 2.30]:
        add_to_full(cube(f"starter_gondola_black_post_{x}", shelving, (x, 0.78, -2.55), (0.06, 1.35, 0.78), mats["black_metal"], 0.004))
    add_to_full(cube("starter_gondola_new_release_header", shelving, (1.15, 1.48, -2.55), (2.35, 0.18, 0.08), mats["yellow"], 0.006))
    text_obj("new_releases_header_text", shelving, "NEW RELEASES", (1.15, 1.50, -2.49), 0.13, mats["dark"], (math.radians(90), 0, 0))
    add_to_full(price_tag(shelving, "gondola_sale_price_tag_front", (1.15, 0.60, -2.14), mats["yellow"]))

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
    ]:
        add_to_full(obj)
    text_obj("register_screen_sale_text", counter, "SALE  $24.99", (2.65, 1.35, -1.075), 0.055, mats["white"], (math.radians(90), 0, 0))

    receiving = collections["Receiving Backroom"]
    for obj in [
        cube("receiving_table_laminate_top", receiving, (-1.2, 0.74, -7.25), (1.8, 0.08, 0.95), mats["wood"], 0.012),
        cube("receiving_table_left_leg", receiving, (-1.95, 0.36, -6.9), (0.08, 0.72, 0.08), mats["black_metal"], 0.004),
        cube("receiving_table_right_leg", receiving, (-0.45, 0.36, -7.6), (0.08, 0.72, 0.08), mats["black_metal"], 0.004),
        cube("open_shipment_box_bottom", receiving, (-1.15, 0.86, -7.25), (0.95, 0.12, 0.62), mats["cardboard"], 0.01),
        cube("open_shipment_box_back_flap", receiving, (-1.15, 1.10, -7.55), (0.95, 0.42, 0.06), mats["cardboard"], 0.01),
        cube("open_shipment_box_left_flap", receiving, (-1.66, 1.08, -7.25), (0.06, 0.36, 0.62), mats["cardboard"], 0.01),
        cube("invoice_manifest_sheet", receiving, (-0.55, 0.83, -7.00), (0.38, 0.012, 0.26), mats["white"], 0.002),
        cube("receiving_clipboard", receiving, (-0.48, 0.86, -6.86), (0.46, 0.035, 0.30), mats["dark"], 0.004),
        cube("manifest_top_sheet", receiving, (-0.48, 0.89, -6.86), (0.40, 0.012, 0.24), mats["white"], 0.002),
        cube("sealed_backroom_shipper_a", receiving, (0.35, 0.30, -7.75), (0.70, 0.60, 0.52), mats["cardboard"], 0.012),
        cube("sealed_backroom_shipper_b", receiving, (0.92, 0.22, -7.20), (0.46, 0.44, 0.42), mats["cardboard"], 0.012),
    ]:
        add_to_full(obj)
    text_obj("invoice_manifest_text", receiving, "INVOICE\n12 CASES", (-0.55, 0.842, -7.00), 0.045, mats["dark"], (math.radians(90), 0, 0))
    text_obj("manifest_clipboard_text", receiving, "STARTER\nSHIPMENT", (-0.48, 0.902, -6.86), 0.040, mats["dark"], (math.radians(90), 0, 0))

    product = collections["Product Cases"]
    cover_mats = [mats["blue"], mats["red"], mats["green"], mats["purple"], mats["orange"]]
    for i in range(18):
        x = -3.65 + (i % 9) * 0.27
        y = 1.42 if i >= 9 else 1.02
        make_case(product, f"fictional_game_case_shelf_{i+1:02d}", (x, y, -5.60), mats["dark"], cover_mats[i % len(cover_mats)], mats["yellow"], used=i % 2 == 1)
    for i in range(8):
        make_case(product, f"open_box_case_{i+1:02d}", (-1.45 + (i % 4) * 0.20, 1.03 + (i // 4) * 0.06, -7.24), mats["dark"], cover_mats[(i + 2) % len(cover_mats)], mats["yellow"], used=i % 2 == 0)
    make_case(product, "first_person_held_case_sample", (0.28, 1.03, 0.62), mats["dark"], mats["blue"], mats["yellow"], used=False)
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
    ]:
        add_to_full(obj)
    text_obj("fictional_storefront_sign_text", signage, "PIXEL DEPOT", (0, 2.36, 2.51), 0.22, mats["dark"], (math.radians(90), 0, 0))
    text_obj("open_closed_sign_text", signage, "CLOSED", (0, 1.655, 2.47), 0.10, mats["yellow"], (math.radians(90), 0, 0))
    text_obj("sale_tag_header_text", signage, "USED $9-24", (1.15, 1.33, -2.10), 0.055, mats["dark"], (math.radians(90), 0, 0))

    customer = collections["Customer Placeholder"]
    for obj in [
        cylinder("customer_placeholder_torso", customer, (-1.7, 0.95, 1.85), 0.24, 0.78, mats["shirt"], 24),
        sphere("customer_placeholder_head", customer, (-1.7, 1.50, 1.85), 0.18, mats["skin"]),
        cylinder("customer_left_leg", customer, (-1.82, 0.39, 1.85), 0.07, 0.72, mats["jeans"], 16),
        cylinder("customer_right_leg", customer, (-1.58, 0.39, 1.85), 0.07, 0.72, mats["jeans"], 16),
        cube("customer_carry_bag_hint", customer, (-1.37, 0.82, 1.78), (0.18, 0.28, 0.08), mats["white"], 0.008),
    ]:
        add_to_full(obj)

    report = collections["Daily Report Computer"]
    for obj in [
        cube("backroom_computer_desk", report, (1.25, 0.72, -7.95), (1.30, 0.10, 0.62), mats["wood"], 0.01),
        cube("daily_report_crt_body", report, (1.25, 1.02, -8.08), (0.72, 0.46, 0.32), mats["dark"], 0.025),
        cube("daily_report_crt_screen", report, (1.25, 1.04, -7.90), (0.56, 0.32, 0.025), mats["screen"], 0.004),
        cube("keyboard_block", report, (1.25, 0.82, -7.72), (0.72, 0.04, 0.20), mats["dark"], 0.006),
        cube("daily_report_paper_printout", report, (0.74, 0.86, -7.70), (0.34, 0.012, 0.46), mats["white"], 0.002),
        cube("daily_report_screen_panel", report, (1.25, 1.08, -7.885), (0.62, 0.40, 0.012), mats["screen"], 0.003),
        cube("daily_report_title_bar", report, (1.25, 1.19, -7.868), (0.42, 0.030, 0.008), mats["white"], 0.001),
        cube("daily_report_sales_bar", report, (1.18, 1.10, -7.868), (0.30, 0.024, 0.008), mats["yellow"], 0.001),
        cube("daily_report_margin_bar", report, (1.16, 1.04, -7.868), (0.25, 0.024, 0.008), mats["green"], 0.001),
        cube("daily_report_restock_bar", report, (1.28, 0.98, -7.868), (0.42, 0.024, 0.008), mats["white"], 0.001),
    ]:
        add_to_full(obj)
    text_obj("daily_report_screen_text", report, "DAILY REPORT\nSALES  $74\nMARGIN $31\nRESTOCK USED", (1.25, 1.05, -7.872), 0.044, mats["white"], (math.radians(90), 0, 0))
    text_obj("daily_report_printout_text", report, "END DAY\nUSED LOW\nORDER 6", (0.74, 0.875, -7.70), 0.034, mats["dark"], (math.radians(90), 0, 0))

    # Convert text objects to mesh for reliable GLB import.
    bpy.ops.object.select_all(action="DESELECT")
    text_objects = [obj for obj in bpy.context.scene.objects if obj.type == "FONT"]
    for obj in text_objects:
        obj.select_set(True)
        bpy.context.view_layer.objects.active = obj
        bpy.ops.object.convert(target="MESH")
        obj.select_set(False)

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
