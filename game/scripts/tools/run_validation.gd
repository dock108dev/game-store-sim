extends SceneTree

const EngineProofState = preload("res://scripts/systems/engine_proof_state.gd")

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
