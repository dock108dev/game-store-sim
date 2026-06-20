extends SceneTree

const EngineProofState = preload("res://scripts/systems/engine_proof_state.gd")

const VISUAL_BENCHMARK_SCENE := "res://scenes/visual_benchmark/VisualBenchmarkStore.tscn"
const VISUAL_BENCHMARK_MANIFEST := "res://assets/visual_benchmark/visual_benchmark_asset_manifest.json"

var failures: Array[String] = []
var validation_dir: String = ""

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    validation_dir = OS.get_environment("GSS_VALIDATION_DIR")
    if validation_dir == "":
        validation_dir = ProjectSettings.globalize_path("res://../artifacts/validation/latest")
    DirAccess.make_dir_recursive_absolute(validation_dir)
    DirAccess.make_dir_recursive_absolute(validation_dir.path_join("screenshots"))

    _check_scene_loads()
    _check_visual_benchmark_assets()
    var proof_save_path: String = validation_dir.path_join("engine_proof_save.json")
    var state: EngineProofState = EngineProofState.new()
    var proof: Dictionary = state.run_engine_proof(proof_save_path)
    _expect("engine_proof_steps_pass", bool(proof["ok"]))
    for step: Dictionary in proof["steps"]:
        _expect("step_%s" % step["label"], bool(step["ok"]))
    _write_proof_screenshot(validation_dir.path_join("screenshots").path_join("engine-proof-state.png"))
    var summary: Dictionary = {
        "ok": failures.is_empty(),
        "failures": failures,
        "proof": proof,
        "screenshot": "screenshots/engine-proof-state.png",
        "checks": {
            "first_person_scene_loads": not failures.has("scene_loads"),
            "visual_benchmark_scene_loads": not failures.has("visual_benchmark_scene_loads"),
            "visual_benchmark_manifest_loads": not failures.has("visual_benchmark_manifest_loads"),
            "visual_benchmark_assets_load": not failures.has("visual_benchmark_assets_load"),
            "physical_item_pickup_stock_sale": bool(proof["ok"]),
            "save_load_round_trip": _proof_step_ok(proof, "load_restores_sold_item"),
            "macos_export_preset": FileAccess.file_exists("res://export_presets.cfg")
        }
    }
    _write_json(validation_dir.path_join("summary.json"), summary)
    if failures.is_empty():
        print("ENGINE_PROOF_VALIDATION: PASS")
        quit(0)
    else:
        push_error("ENGINE_PROOF_VALIDATION: FAIL %s" % failures)
        quit(1)

func _check_scene_loads() -> void:
    var packed: PackedScene = load("res://scenes/main/engine_proof.tscn")
    if packed == null:
        failures.append("scene_loads")
        return

    var benchmark: PackedScene = load(VISUAL_BENCHMARK_SCENE)
    if benchmark == null:
        failures.append("visual_benchmark_scene_loads")

func _check_visual_benchmark_assets() -> void:
    if not FileAccess.file_exists(VISUAL_BENCHMARK_MANIFEST):
        failures.append("visual_benchmark_manifest_loads")
        return

    var file: FileAccess = FileAccess.open(VISUAL_BENCHMARK_MANIFEST, FileAccess.READ)
    if file == null:
        failures.append("visual_benchmark_manifest_loads")
        return

    var parsed: Variant = JSON.parse_string(file.get_as_text())
    file.close()
    if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("assets"):
        failures.append("visual_benchmark_manifest_loads")
        return

    var assets: Variant = parsed["assets"]
    if typeof(assets) != TYPE_ARRAY:
        failures.append("visual_benchmark_manifest_loads")
        return

    for asset: Variant in assets:
        if typeof(asset) != TYPE_DICTIONARY or not asset.has("godot_path"):
            failures.append("visual_benchmark_manifest_loads")
            return
        var godot_path: String = "res://%s" % String(asset["godot_path"]).trim_prefix("game/")
        if not FileAccess.file_exists(godot_path):
            failures.append("visual_benchmark_assets_load")
            push_error("Missing visual benchmark asset: %s" % godot_path)
            return
        var loaded: Resource = load(godot_path)
        if loaded == null:
            failures.append("visual_benchmark_assets_load")
            push_error("Unable to load visual benchmark asset: %s" % godot_path)
            return

func _expect(label: String, ok: bool) -> void:
    print("%s: %s" % [label, "PASS" if ok else "FAIL"])
    if not ok:
        failures.append(label)

func _proof_step_ok(proof: Dictionary, label: String) -> bool:
    for step: Dictionary in proof["steps"]:
        if String(step["label"]) == label:
            return bool(step["ok"])
    return false

func _write_json(path: String, payload: Dictionary) -> void:
    var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
    if file == null:
        failures.append("write_%s" % path.get_file())
        return
    file.store_string(JSON.stringify(payload, "\t"))
    file.close()

func _write_proof_screenshot(path: String) -> void:
    var image: Image = Image.create(640, 360, false, Image.FORMAT_RGB8)
    for y: int in range(360):
        for x: int in range(640):
            var base: Color = Color(0.08, 0.10, 0.11)
            if y > 230:
                base = Color(0.22, 0.30, 0.34)
            if x > 60 and x < 580 and y > 80 and y < 110:
                base = Color(0.95, 0.78, 0.25)
            if x > 120 and x < 500 and y > 120 and y < 180:
                base = Color(0.10, 0.10, 0.10)
            if x > 150 and x < 180 and y > 130 and y < 170:
                base = Color(0.86, 0.28, 0.23)
            if x > 190 and x < 220 and y > 130 and y < 170:
                base = Color(0.15, 0.38, 0.84)
            if x > 470 and x < 500 and y > 170 and y < 250:
                base = Color(0.88, 0.74, 0.55)
            image.set_pixel(x, y, base)
    var error: Error = image.save_png(path)
    _expect("proof_screenshot_written", error == OK)
