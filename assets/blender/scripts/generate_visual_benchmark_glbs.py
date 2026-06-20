import json
import math
import shutil
import struct
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[3]
EXPORT_DIR = REPO_ROOT / "assets" / "blender" / "exports"
GAME_DIR = REPO_ROOT / "game" / "assets" / "visual_benchmark"
MANIFEST_PATH = GAME_DIR / "visual_benchmark_asset_manifest.json"


MATERIALS = {
    "carpet": (0.16, 0.24, 0.27, 1.0),
    "mall_tile": (0.68, 0.66, 0.58, 1.0),
    "wall": (0.72, 0.74, 0.68, 1.0),
    "slatwall": (0.80, 0.79, 0.70, 1.0),
    "black_metal": (0.015, 0.017, 0.018, 1.0),
    "wood": (0.50, 0.32, 0.17, 1.0),
    "cardboard": (0.55, 0.37, 0.17, 1.0),
    "glass": (0.45, 0.76, 0.95, 0.36),
    "yellow": (0.96, 0.80, 0.18, 1.0),
    "red": (0.82, 0.17, 0.16, 1.0),
    "blue": (0.08, 0.32, 0.86, 1.0),
    "green": (0.16, 0.56, 0.25, 1.0),
    "purple": (0.42, 0.18, 0.62, 1.0),
    "orange": (0.90, 0.45, 0.13, 1.0),
    "white": (0.93, 0.91, 0.84, 1.0),
    "dark": (0.04, 0.05, 0.06, 1.0),
    "screen": (0.05, 0.30, 0.34, 1.0),
    "skin": (0.78, 0.58, 0.42, 1.0),
    "shirt": (0.18, 0.31, 0.27, 1.0),
    "jeans": (0.12, 0.18, 0.32, 1.0),
}


ASSETS = {
    "mall_store_shell": {
        "targets": ["01-storefront-from-mall.png", "02-empty-sales-floor.png"],
        "description": "Mall concourse, storefront, sales floor shell, walls, ceiling light bars, and core floor materials.",
    },
    "starter_shelving_pack": {
        "targets": ["02-empty-sales-floor.png", "06-stocked-shelf-density.png"],
        "description": "Wall shelf, gondola shelf, readable capacity states, shelf headers.",
    },
    "checkout_counter_register": {
        "targets": ["07-counter-register.png"],
        "description": "Checkout counter, register, scanner, cash drawer, receipt props, and counter clutter.",
    },
    "receiving_backroom_pack": {
        "targets": ["03-receiving-backroom.png", "04-starter-shipment-open.png"],
        "description": "Receiving table, starter shipment boxes, open box, invoice cue, and backroom clutter.",
    },
    "product_case_pack": {
        "targets": ["05-picked-up-case.png", "06-stocked-shelf-density.png"],
        "description": "Fictional new/used game cases, price stickers, grouped rows, held-case sample.",
    },
    "signage_and_posters_pack": {
        "targets": ["01-storefront-from-mall.png", "06-stocked-shelf-density.png"],
        "description": "Fictional storefront sign, open/closed sign, sale tags, shelf headers, promo poster surfaces.",
    },
    "customer_placeholder": {
        "targets": ["08-customer-entering-from-mall.png"],
        "description": "Simple readable customer silhouette for mall-to-store entry staging.",
    },
    "daily_report_computer": {
        "targets": ["09-daily-report-view.png"],
        "description": "Backroom computer with business-tool daily report screen and simple desk props.",
    },
}


def box(asset: str, name: str, loc: tuple[float, float, float], scale: tuple[float, float, float], mat: str) -> dict:
    return {"asset": asset, "name": name, "translation": loc, "scale": scale, "material": mat}


def add_case(objects: list[dict], asset: str, name: str, x: float, y: float, z: float, cover: str, used: bool = False) -> None:
    objects.append(box(asset, f"{name}_body", (x, y, z), (0.16, 0.25, 0.035), "dark"))
    objects.append(box(asset, f"{name}_cover", (x, y + 0.002, z - 0.020), (0.135, 0.17, 0.008), cover))
    objects.append(box(asset, f"{name}_price_sticker", (x + (-0.045 if used else 0.045), y + 0.004, z - 0.026), (0.045, 0.025, 0.006), "yellow"))


def build_objects() -> list[dict]:
    objects: list[dict] = []

    for spec in [
        ("mall_concourse_tile_floor", (0, -0.055, 4.0), (12.0, 0.10, 3.0), "mall_tile"),
        ("store_low_pile_carpet_floor", (0, -0.05, -1.8), (9.6, 0.10, 8.8), "carpet"),
        ("backroom_sealed_floor", (0, -0.045, -7.2), (4.8, 0.10, 2.6), "mall_tile"),
        ("left_wall_light_retail", (-4.9, 1.35, -1.8), (0.18, 2.8, 8.8), "wall"),
        ("right_wall_light_retail", (4.9, 1.35, -1.8), (0.18, 2.8, 8.8), "wall"),
        ("rear_slatwall_game_wall", (0, 1.35, -6.25), (9.6, 2.8, 0.18), "slatwall"),
        ("storefront_glass_left_bay", (-2.9, 1.35, 2.65), (3.4, 2.5, 0.06), "glass"),
        ("storefront_glass_right_bay", (2.9, 1.35, 2.65), (3.4, 2.5, 0.06), "glass"),
        ("storefront_door_threshold", (0, 0.05, 2.65), (1.6, 0.18, 0.20), "black_metal"),
        ("storefront_upper_frame", (0, 2.72, 2.63), (8.8, 0.18, 0.12), "black_metal"),
        ("backroom_door_frame", (-2.25, 1.05, -6.15), (1.0, 2.1, 0.14), "black_metal"),
        ("ceiling_light_bar_front", (0, 2.75, 0.2), (7.2, 0.05, 0.18), "white"),
        ("ceiling_light_bar_rear", (0, 2.75, -3.6), (7.2, 0.05, 0.18), "white"),
    ]:
        objects.append(box("mall_store_shell", spec[0], spec[1], spec[2], spec[3]))

    for i, y in enumerate([0.45, 0.85, 1.25], start=1):
        objects.append(box("starter_shelving_pack", f"used_wall_shelf_wood_level_{i}", (-2.6, y, -5.92), (2.9, 0.07, 0.38), "wood"))
    for i, x in enumerate([-4.0, -2.6, -1.2], start=1):
        objects.append(box("starter_shelving_pack", f"used_wall_shelf_black_upright_{i}", (x, 0.78, -5.78), (0.06, 1.4, 0.10), "black_metal"))
    objects.append(box("starter_shelving_pack", "used_wall_shelf_header_strip", (-2.6, 1.60, -5.72), (2.9, 0.18, 0.05), "yellow"))
    for i, y in enumerate([0.42, 0.78, 1.14], start=1):
        objects.append(box("starter_shelving_pack", f"starter_gondola_center_shelf_{i}", (1.15, y, -2.55), (2.3, 0.08, 0.72), "wood"))
    for i, x in enumerate([0.0, 1.15, 2.30], start=1):
        objects.append(box("starter_shelving_pack", f"starter_gondola_black_post_{i}", (x, 0.78, -2.55), (0.06, 1.35, 0.78), "black_metal"))
    objects.append(box("starter_shelving_pack", "starter_gondola_new_release_header", (1.15, 1.48, -2.55), (2.35, 0.18, 0.08), "yellow"))

    for spec in [
        ("checkout_counter_laminate_base", (3.0, 0.48, -0.75), (2.25, 0.95, 0.86), "wood"),
        ("checkout_counter_black_top", (3.0, 0.98, -0.75), (2.35, 0.08, 0.92), "black_metal"),
        ("cash_drawer_front", (2.55, 0.77, -0.28), (0.72, 0.18, 0.05), "dark"),
        ("register_body", (2.65, 1.15, -0.92), (0.55, 0.20, 0.30), "dark"),
        ("register_screen", (2.65, 1.34, -1.04), (0.55, 0.36, 0.06), "screen"),
        ("barcode_scanner_wedge", (3.35, 1.12, -0.55), (0.16, 0.10, 0.36), "dark"),
        ("receipt_roll", (3.55, 1.08, -0.90), (0.20, 0.08, 0.20), "white"),
        ("counter_trade_mat_placeholder", (2.95, 1.04, -0.48), (0.75, 0.015, 0.34), "green"),
    ]:
        objects.append(box("checkout_counter_register", spec[0], spec[1], spec[2], spec[3]))

    for spec in [
        ("receiving_table_laminate_top", (-1.2, 0.74, -7.25), (1.8, 0.08, 0.95), "wood"),
        ("receiving_table_left_leg", (-1.95, 0.36, -6.9), (0.08, 0.72, 0.08), "black_metal"),
        ("receiving_table_right_leg", (-0.45, 0.36, -7.6), (0.08, 0.72, 0.08), "black_metal"),
        ("open_shipment_box_bottom", (-1.15, 0.86, -7.25), (0.95, 0.12, 0.62), "cardboard"),
        ("open_shipment_box_back_flap", (-1.15, 1.10, -7.55), (0.95, 0.42, 0.06), "cardboard"),
        ("open_shipment_box_left_flap", (-1.66, 1.08, -7.25), (0.06, 0.36, 0.62), "cardboard"),
        ("invoice_manifest_sheet", (-0.55, 0.83, -7.00), (0.38, 0.012, 0.26), "white"),
        ("sealed_backroom_shipper_a", (0.35, 0.30, -7.75), (0.70, 0.60, 0.52), "cardboard"),
        ("sealed_backroom_shipper_b", (0.92, 0.22, -7.20), (0.46, 0.44, 0.42), "cardboard"),
    ]:
        objects.append(box("receiving_backroom_pack", spec[0], spec[1], spec[2], spec[3]))

    covers = ["blue", "red", "green", "purple", "orange"]
    for i in range(18):
        add_case(objects, "product_case_pack", f"fictional_game_case_shelf_{i+1:02d}", -3.65 + (i % 9) * 0.27, 1.42 if i >= 9 else 1.02, -5.60, covers[i % len(covers)], i % 2 == 1)
    for i in range(8):
        add_case(objects, "product_case_pack", f"open_box_case_{i+1:02d}", -1.45 + (i % 4) * 0.20, 1.03 + (i // 4) * 0.06, -7.24, covers[(i + 2) % len(covers)], i % 2 == 0)
    add_case(objects, "product_case_pack", "first_person_held_case_sample", 0.0, 1.15, 0.95, "blue", False)

    for spec in [
        ("fictional_storefront_sign_backlit_panel", (0, 2.35, 2.56), (3.25, 0.34, 0.08), "yellow"),
        ("open_closed_hanging_sign", (0.0, 1.65, 2.50), (0.72, 0.25, 0.04), "dark"),
        ("front_window_poster_left", (-3.35, 1.55, 2.48), (0.56, 0.78, 0.025), "blue"),
        ("front_window_poster_right", (3.35, 1.50, 2.48), (0.56, 0.72, 0.025), "red"),
        ("sale_tag_pack_header", (1.15, 1.32, -2.12), (0.55, 0.16, 0.025), "yellow"),
    ]:
        objects.append(box("signage_and_posters_pack", spec[0], spec[1], spec[2], spec[3]))

    for spec in [
        ("customer_placeholder_torso", (-1.7, 0.95, 1.85), (0.42, 0.78, 0.24), "shirt"),
        ("customer_placeholder_head", (-1.7, 1.50, 1.85), (0.28, 0.28, 0.28), "skin"),
        ("customer_left_leg", (-1.82, 0.39, 1.85), (0.10, 0.72, 0.10), "jeans"),
        ("customer_right_leg", (-1.58, 0.39, 1.85), (0.10, 0.72, 0.10), "jeans"),
        ("customer_carry_bag_hint", (-1.37, 0.82, 1.78), (0.18, 0.28, 0.08), "white"),
    ]:
        objects.append(box("customer_placeholder", spec[0], spec[1], spec[2], spec[3]))

    for spec in [
        ("backroom_computer_desk", (1.25, 0.72, -7.95), (1.30, 0.10, 0.62), "wood"),
        ("daily_report_crt_body", (1.25, 1.02, -8.08), (0.72, 0.46, 0.32), "dark"),
        ("daily_report_crt_screen", (1.25, 1.04, -8.25), (0.56, 0.32, 0.025), "screen"),
        ("keyboard_block", (1.25, 0.82, -7.72), (0.72, 0.04, 0.20), "dark"),
        ("report_row_sales", (1.25, 1.11, -8.268), (0.42, 0.025, 0.006), "white"),
        ("report_row_margin", (1.25, 1.04, -8.268), (0.36, 0.025, 0.006), "yellow"),
        ("report_row_restock", (1.25, 0.97, -8.268), (0.46, 0.025, 0.006), "green"),
    ]:
        objects.append(box("daily_report_computer", spec[0], spec[1], spec[2], spec[3]))

    return objects


def cube_geometry() -> tuple[list[float], list[float], list[int]]:
    # 24 vertices, one normal per face, centered 1m cube.
    faces = [
        ((0, 0, 1), [(-0.5, -0.5, 0.5), (0.5, -0.5, 0.5), (0.5, 0.5, 0.5), (-0.5, 0.5, 0.5)]),
        ((0, 0, -1), [(0.5, -0.5, -0.5), (-0.5, -0.5, -0.5), (-0.5, 0.5, -0.5), (0.5, 0.5, -0.5)]),
        ((1, 0, 0), [(0.5, -0.5, 0.5), (0.5, -0.5, -0.5), (0.5, 0.5, -0.5), (0.5, 0.5, 0.5)]),
        ((-1, 0, 0), [(-0.5, -0.5, -0.5), (-0.5, -0.5, 0.5), (-0.5, 0.5, 0.5), (-0.5, 0.5, -0.5)]),
        ((0, 1, 0), [(-0.5, 0.5, 0.5), (0.5, 0.5, 0.5), (0.5, 0.5, -0.5), (-0.5, 0.5, -0.5)]),
        ((0, -1, 0), [(-0.5, -0.5, -0.5), (0.5, -0.5, -0.5), (0.5, -0.5, 0.5), (-0.5, -0.5, 0.5)]),
    ]
    positions: list[float] = []
    normals: list[float] = []
    indices: list[int] = []
    for face_index, (normal, verts) in enumerate(faces):
        start = face_index * 4
        for vert in verts:
            positions.extend(vert)
            normals.extend(normal)
        indices.extend([start, start + 1, start + 2, start, start + 2, start + 3])
    return positions, normals, indices


def align4(data: bytearray) -> None:
    while len(data) % 4:
        data.append(0)


def write_glb(path: Path, objects: list[dict]) -> None:
    positions, normals, indices = cube_geometry()
    bin_data = bytearray()
    buffer_views = []
    accessors = []

    def add_buffer(payload: bytes, target: int | None = None) -> int:
        align4(bin_data)
        offset = len(bin_data)
        bin_data.extend(payload)
        view = {"buffer": 0, "byteOffset": offset, "byteLength": len(payload)}
        if target is not None:
            view["target"] = target
        buffer_views.append(view)
        return len(buffer_views) - 1

    pos_bytes = struct.pack("<" + "f" * len(positions), *positions)
    normal_bytes = struct.pack("<" + "f" * len(normals), *normals)
    index_bytes = struct.pack("<" + "H" * len(indices), *indices)
    pos_view = add_buffer(pos_bytes, 34962)
    normal_view = add_buffer(normal_bytes, 34962)
    index_view = add_buffer(index_bytes, 34963)
    accessors.append({"bufferView": pos_view, "componentType": 5126, "count": 24, "type": "VEC3", "min": [-0.5, -0.5, -0.5], "max": [0.5, 0.5, 0.5]})
    accessors.append({"bufferView": normal_view, "componentType": 5126, "count": 24, "type": "VEC3"})
    accessors.append({"bufferView": index_view, "componentType": 5123, "count": 36, "type": "SCALAR"})

    material_names = sorted({obj["material"] for obj in objects})
    material_index = {name: i for i, name in enumerate(material_names)}
    materials = [
        {
            "name": name,
            "pbrMetallicRoughness": {
                "baseColorFactor": MATERIALS[name],
                "metallicFactor": 0.2 if name == "black_metal" else 0.0,
                "roughnessFactor": 0.72,
            },
            **({"alphaMode": "BLEND"} if MATERIALS[name][3] < 1.0 else {}),
        }
        for name in material_names
    ]

    meshes = []
    mesh_index_by_material = {}
    for name in material_names:
        mesh_index_by_material[name] = len(meshes)
        meshes.append(
            {
                "name": f"cube_{name}",
                "primitives": [
                    {
                        "attributes": {"POSITION": 0, "NORMAL": 1},
                        "indices": 2,
                        "material": material_index[name],
                    }
                ],
            }
        )

    nodes = []
    for obj in objects:
        nodes.append(
            {
                "name": obj["name"],
                "mesh": mesh_index_by_material[obj["material"]],
                "translation": list(obj["translation"]),
                "scale": list(obj["scale"]),
            }
        )

    gltf = {
        "asset": {"version": "2.0", "generator": "Game Store Sim deterministic visual benchmark exporter"},
        "scene": 0,
        "scenes": [{"name": path.stem, "nodes": list(range(len(nodes)))}],
        "nodes": nodes,
        "meshes": meshes,
        "materials": materials,
        "buffers": [{"byteLength": len(bin_data)}],
        "bufferViews": buffer_views,
        "accessors": accessors,
    }

    json_chunk = json.dumps(gltf, separators=(",", ":")).encode("utf-8")
    while len(json_chunk) % 4:
        json_chunk += b" "
    align4(bin_data)
    total_length = 12 + 8 + len(json_chunk) + 8 + len(bin_data)
    with path.open("wb") as handle:
        handle.write(struct.pack("<III", 0x46546C67, 2, total_length))
        handle.write(struct.pack("<I4s", len(json_chunk), b"JSON"))
        handle.write(json_chunk)
        handle.write(struct.pack("<I4s", len(bin_data), b"BIN\x00"))
        handle.write(bin_data)


def main() -> None:
    EXPORT_DIR.mkdir(parents=True, exist_ok=True)
    GAME_DIR.mkdir(parents=True, exist_ok=True)
    objects = build_objects()
    manifest = {
        "source_recipe": "assets/blender/scripts/generate_visual_benchmark_store.py",
        "generated_by": "assets/blender/scripts/generate_visual_benchmark_glbs.py",
        "note": "Blender 5.1.2 currently segfaults on Python execution in this environment; GLBs were generated from the same procedural asset specification for immediate Godot import.",
        "assets": [],
    }
    for asset_name, spec in ASSETS.items():
        subset = [obj for obj in objects if obj["asset"] == asset_name]
        export_path = EXPORT_DIR / f"{asset_name}.glb"
        game_path = GAME_DIR / f"{asset_name}.glb"
        write_glb(export_path, subset)
        shutil.copyfile(export_path, game_path)
        manifest["assets"].append(
            {
                "asset": asset_name,
                "export_path": str(export_path.relative_to(REPO_ROOT)),
                "godot_path": str(game_path.relative_to(REPO_ROOT)),
                "description": spec["description"],
                "benchmark_targets": spec["targets"],
                "object_count": len(subset),
            }
        )
    full_export = EXPORT_DIR / "game_store_visual_benchmark_full.glb"
    full_game = GAME_DIR / "game_store_visual_benchmark_full.glb"
    write_glb(full_export, objects)
    shutil.copyfile(full_export, full_game)
    manifest["assets"].append(
        {
            "asset": "game_store_visual_benchmark_full",
            "export_path": str(full_export.relative_to(REPO_ROOT)),
            "godot_path": str(full_game.relative_to(REPO_ROOT)),
            "description": "Complete assembled first 0.3% visual benchmark store scene.",
            "benchmark_targets": [
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
            "object_count": len(objects),
        }
    )
    MANIFEST_PATH.write_text(json.dumps(manifest, indent=2) + "\n")
    print(json.dumps(manifest, indent=2))


if __name__ == "__main__":
    main()
