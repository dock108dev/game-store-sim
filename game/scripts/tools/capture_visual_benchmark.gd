extends SceneTree

const OUTPUT_DIR_ENV := "GSS_VISUAL_BENCHMARK_SCREENSHOT_DIR"
const DEFAULT_OUTPUT_DIR := "res://../artifacts/validation/latest/screenshots/visual-benchmark-godot"
const SCENE_PATH := "res://scenes/visual_benchmark/VisualBenchmarkStore.tscn"

const SHOTS: Array[Dictionary] = [
    {
        "filename": "01-storefront-from-mall.png",
        "camera": Vector3(5.8, 1.65, 6.25),
        "target": Vector3(0.0, 1.35, 2.45),
        "fov": 62.0,
    },
    {
        "filename": "02-empty-sales-floor.png",
        "camera": Vector3(-2.15, 1.62, 1.35),
        "target": Vector3(1.25, 1.0, -2.75),
        "fov": 64.0,
    },
    {
        "filename": "03-receiving-backroom.png",
        "camera": Vector3(-2.70, 1.55, -6.55),
        "target": Vector3(-0.10, 0.90, -7.45),
        "fov": 60.0,
    },
    {
        "filename": "04-starter-shipment-open.png",
        "camera": Vector3(-2.20, 1.42, -6.45),
        "target": Vector3(-1.02, 0.96, -7.25),
        "fov": 42.0,
    },
    {
        "filename": "05-picked-up-case.png",
        "camera": Vector3(0.20, 1.42, 1.35),
        "target": Vector3(0.28, 1.03, 0.62),
        "fov": 60.0,
    },
    {
        "filename": "06-stocked-shelf-density.png",
        "camera": Vector3(-3.05, 1.45, -4.85),
        "target": Vector3(-2.50, 1.10, -5.75),
        "fov": 42.0,
    },
    {
        "filename": "07-counter-register.png",
        "camera": Vector3(1.45, 1.42, 0.55),
        "target": Vector3(3.02, 1.03, -0.78),
        "fov": 56.0,
    },
    {
        "filename": "08-customer-entering-from-mall.png",
        "camera": Vector3(2.30, 1.55, 4.55),
        "target": Vector3(-1.10, 1.05, 1.90),
        "fov": 52.0,
    },
    {
        "filename": "09-daily-report-view.png",
        "camera": Vector3(1.22, 1.32, -7.18),
        "target": Vector3(1.25, 1.05, -7.90),
        "fov": 38.0,
    },
]

var output_dir: String = ""
var viewport: SubViewport
var root_3d: Node3D
var camera: Camera3D

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    output_dir = OS.get_environment(OUTPUT_DIR_ENV)
    if output_dir == "":
        output_dir = ProjectSettings.globalize_path(DEFAULT_OUTPUT_DIR)
    DirAccess.make_dir_recursive_absolute(output_dir)

    var packed: PackedScene = load(SCENE_PATH)
    if packed == null:
        push_error("Unable to load visual benchmark scene: %s" % SCENE_PATH)
        quit(1)
        return

    viewport = SubViewport.new()
    viewport.size = Vector2i(1280, 720)
    viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    viewport.disable_3d = false
    root.add_child(viewport)

    root_3d = Node3D.new()
    viewport.add_child(root_3d)
    root_3d.add_child(packed.instantiate())

    camera = Camera3D.new()
    camera.current = true
    root_3d.add_child(camera)

    await process_frame
    await process_frame
    for shot: Dictionary in SHOTS:
        _position_camera(shot)
        await process_frame
        await process_frame
        var image: Image = viewport.get_texture().get_image()
        var path: String = output_dir.path_join(String(shot["filename"]))
        var error: Error = image.save_png(path)
        if error != OK:
            push_error("Unable to save screenshot: %s" % path)
            quit(1)
            return
        print("Captured %s" % path)
    quit(0)

func _position_camera(shot: Dictionary) -> void:
    camera.global_position = shot["camera"]
    camera.fov = float(shot["fov"])
    camera.look_at(shot["target"], Vector3.UP)
