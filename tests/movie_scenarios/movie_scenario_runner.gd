## Runs deterministic Godot Movie Maker review scenarios.
class_name MovieScenarioRunner
extends Node

const DEFAULT_DURATION_FRAMES: int = 600
const MAX_DURATION_FRAMES: int = 36000
const DEFAULT_SCENE_PATH: String = ""
const DEFAULT_SCENARIO_ID: String = "store_opening"
const SCENARIOS: Dictionary = {
	"store_opening": {
		"duration_frames": 720,
		"scene_path": DEFAULT_SCENE_PATH,
		"title": "Opening Readability",
		"objective": "Storefront, HUD hierarchy, and first impression.",
		"camera_position": Vector3(0.0, 3.1, 11.5),
		"camera_rotation": Vector3(deg_to_rad(-13.0), deg_to_rad(180.0), 0.0),
		"events": [
			{"frame": 1, "type": "caption", "text": "Entry view and headline shelves"},
			{"frame": 180, "type": "caption", "text": "Readable lane labels and stock shapes"},
			{"frame": 420, "type": "caption", "text": "Register route remains visible"},
		],
	},
	"checkout_pressure": {
		"duration_frames": 900,
		"scene_path": DEFAULT_SCENE_PATH,
		"title": "Checkout Pressure",
		"objective": "Register framing, customer lane, and transaction feedback.",
		"camera_position": Vector3(4.8, 2.5, 4.4),
		"camera_rotation": Vector3(deg_to_rad(-10.0), deg_to_rad(135.0), 0.0),
		"events": [
			{"frame": 1, "type": "caption", "text": "Register and queue lane"},
			{"frame": 240, "type": "toast", "text": "Customer waiting at checkout"},
			{"frame": 540, "type": "caption", "text": "Counter props stay legible under pressure"},
		],
	},
	"upgrade_purchase_loop": {
		"duration_frames": 840,
		"scene_path": DEFAULT_SCENE_PATH,
		"title": "Upgrade Loop",
		"objective": "Upgrade affordances, back-room read, and economy feedback.",
		"camera_position": Vector3(-4.6, 2.8, 4.2),
		"camera_rotation": Vector3(deg_to_rad(-11.0), deg_to_rad(-145.0), 0.0),
		"events": [
			{"frame": 1, "type": "caption", "text": "Back-room and upgrade surfaces"},
			{"frame": 300, "type": "toast", "text": "Fixture upgrade preview ready"},
			{"frame": 600, "type": "caption", "text": "Economy feedback area remains uncluttered"},
		],
	},
	"toast_readability_pass": {
		"duration_frames": 600,
		"scene_path": DEFAULT_SCENE_PATH,
		"title": "Toast Readability",
		"objective": "Toast lane spacing and transient message timing.",
		"camera_position": Vector3(0.0, 2.9, 8.0),
		"camera_rotation": Vector3(deg_to_rad(-12.0), deg_to_rad(180.0), 0.0),
		"events": [
			{"frame": 1, "type": "toast", "text": "Delivery checked in"},
			{"frame": 150, "type": "toast", "text": "Shelf restocked"},
			{"frame": 330, "type": "toast", "text": "Objective advanced"},
		],
	},
	"objective_rail_progression": {
		"duration_frames": 780,
		"scene_path": DEFAULT_SCENE_PATH,
		"title": "Objective Progression",
		"objective": "Objective wording, suppression, and progress updates.",
		"camera_position": Vector3(2.6, 2.7, 6.2),
		"camera_rotation": Vector3(deg_to_rad(-12.0), deg_to_rad(155.0), 0.0),
		"events": [
			{"frame": 1, "type": "caption", "text": "Objective: talk to the manager"},
			{"frame": 260, "type": "caption", "text": "Objective: pick up back-room delivery"},
			{"frame": 520, "type": "caption", "text": "Objective: stock an open shelf"},
		],
	},
	"gallery_walkthrough_smoke": {
		"duration_frames": 840,
		"scene_path": "res://tests/visual/visual_gallery.tscn",
		"title": "Gallery Walkthrough Smoke",
		"objective": "Internal asset gallery pass using shared video artifact paths.",
		"camera_position": Vector3(-1.8, 3.2, 10.2),
		"camera_rotation": Vector3(deg_to_rad(-12.0), deg_to_rad(170.0), 0.0),
		"events": [
			{"frame": 1, "type": "caption", "text": "Wide store pass"},
			{"frame": 280, "type": "caption", "text": "Fixture and product gallery"},
			{"frame": 560, "type": "caption", "text": "Register and exit route"},
		],
	},
}

var _scenario_id: String = DEFAULT_SCENARIO_ID
var _duration_frames: int = DEFAULT_DURATION_FRAMES
var _current_frame: int = 0
var _scenario: Dictionary = {}
var _events_by_frame: Dictionary = {}
var _running: bool = false
var _stage_root: Node = null
var _camera: Camera3D = null
var _caption_label: Label = null
var _toast_label: Label = null


func _ready() -> void:
	var parsed: Dictionary = parse_cli_args(OS.get_cmdline_user_args())
	if not bool(parsed.get("ok", false)):
		_fail_and_quit(str(parsed.get("code", "invalid_args")), str(parsed.get("message", "")))
		return
	start(parsed)


func _process(_delta: float) -> void:
	if not _running:
		return
	_current_frame += 1
	_apply_events_for_frame(_current_frame)
	if _current_frame >= _duration_frames:
		_emit_status("complete", {"frames": _current_frame, "scenario_id": _scenario_id})
		get_tree().quit(0)


## Parses Movie Maker scenario args passed after Godot's `--` separator.
func parse_cli_args(args: PackedStringArray) -> Dictionary:
	var scenario_id: String = ""
	var duration_frames: int = 0
	var i: int = 0
	while i < args.size():
		var parsed: Dictionary = _parse_flag_value(args, i)
		var flag: String = str(parsed.get("flag", ""))
		var value: String = str(parsed.get("value", ""))
		var consumed: int = int(parsed.get("consumed", 1))
		match flag:
			"--movie-scenario", "--scenario":
				scenario_id = value
			"--duration-frames":
				duration_frames = value.to_int()
		i += consumed
	if scenario_id.is_empty():
		scenario_id = DEFAULT_SCENARIO_ID
	return scenario_config(scenario_id, duration_frames)


## Returns a validated scenario config without mutating the runtime tree.
func scenario_config(scenario_id: String, duration_frames: int = 0) -> Dictionary:
	if not SCENARIOS.has(scenario_id):
		return {
			"ok": false,
			"code": "unknown_scenario_id",
			"message": "unknown scenario id '%s'" % scenario_id,
			"available_scenario_ids": available_scenario_ids(),
		}
	var scenario: Dictionary = (SCENARIOS[scenario_id] as Dictionary).duplicate(true)
	var frames: int = duration_frames
	if frames <= 0:
		frames = int(scenario.get("duration_frames", DEFAULT_DURATION_FRAMES))
	frames = clampi(frames, 1, MAX_DURATION_FRAMES)
	return {
		"ok": true,
		"scenario_id": scenario_id,
		"duration_frames": frames,
		"scenario": scenario,
	}


## Returns sorted Movie Maker scenario ids.
func available_scenario_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	for id: String in SCENARIOS.keys():
		ids.append(id)
	ids.sort()
	return ids


## Starts a validated scenario config.
func start(config: Dictionary) -> void:
	_scenario_id = str(config.get("scenario_id", DEFAULT_SCENARIO_ID))
	_duration_frames = int(config.get("duration_frames", DEFAULT_DURATION_FRAMES))
	_scenario = config.get("scenario", {}) as Dictionary
	_current_frame = 0
	if not _load_stage():
		return
	_build_review_overlay()
	_index_events()
	_apply_camera_pose(_scenario)
	_running = true
	_emit_status("start", {
		"frames": _duration_frames,
		"scenario_id": _scenario_id,
		"scene_path": str(_scenario.get("scene_path", "")),
	})


func _parse_flag_value(args: PackedStringArray, index: int) -> Dictionary:
	var arg: String = args[index]
	if arg.contains("="):
		var parts: PackedStringArray = arg.split("=", true, 1)
		return {"flag": parts[0], "value": parts[1], "consumed": 1}
	var value: String = ""
	var consumed: int = 1
	if index + 1 < args.size() and not args[index + 1].begins_with("--"):
		value = args[index + 1]
		consumed = 2
	return {"flag": arg, "value": value, "consumed": consumed}


func _prepare_content() -> bool:
	if DataLoaderSingleton != null:
		DataLoaderSingleton.load_all()
		var errors: Array[String] = DataLoaderSingleton.get_load_errors()
		if not errors.is_empty():
			_fail_and_quit("content_setup_failed", "\n".join(errors))
			return false
	return true


func _load_stage() -> bool:
	var scene_path: String = str(_scenario.get("scene_path", DEFAULT_SCENE_PATH))
	if scene_path.is_empty():
		_create_review_stage()
		return true
	if not _prepare_content():
		return false
	var packed: PackedScene = load(scene_path)
	if packed == null:
		_fail_and_quit("stage_scene_missing", "cannot load scene '%s'" % scene_path)
		return false
	_stage_root = packed.instantiate()
	_stage_root.name = "MovieScenarioStage"
	add_child(_stage_root)
	_camera = Camera3D.new()
	_camera.name = "MovieScenarioCamera"
	add_child(_camera)
	if CameraAuthority != null and CameraAuthority.has_method("request_current"):
		CameraAuthority.request_current(_camera, &"movie_scenario_runner")
	else:
		_camera.current = true
	return true


func _create_review_stage() -> void:
	_stage_root = Node3D.new()
	_stage_root.name = "MovieScenarioStage"
	add_child(_stage_root)

	_add_mesh(
		"Floor", Vector3(16.0, 0.1, 20.0), Vector3(0.0, -0.05, 0.0),
		Color(0.38, 0.28, 0.18)
	)
	_add_mesh(
		"BackWall", Vector3(16.0, 3.8, 0.18), Vector3(0.0, 1.85, -7.2),
		Color(0.72, 0.64, 0.48)
	)
	_add_mesh(
		"LeftWall", Vector3(0.18, 3.8, 14.0), Vector3(-7.9, 1.85, 0.0),
		Color(0.54, 0.46, 0.34)
	)
	_add_mesh(
		"RegisterCounter", Vector3(3.1, 1.05, 1.0), Vector3(4.8, 0.52, 1.6),
		Color(0.55, 0.38, 0.2)
	)
	_add_mesh(
		"RegisterScreen", Vector3(0.8, 0.48, 0.12), Vector3(4.8, 1.35, 1.0),
		Color(0.1, 0.55, 0.34)
	)
	_add_mesh(
		"CheckoutLane", Vector3(0.25, 0.1, 5.8), Vector3(2.4, 0.05, 2.2),
		Color(0.88, 0.64, 0.25)
	)
	_add_fixture_row("MainShelves", Vector3(-4.4, 0.75, -1.0), Color(0.31, 0.22, 0.13))
	_add_fixture_row("FeatureTable", Vector3(0.0, 0.55, 1.6), Color(0.63, 0.46, 0.23))
	_add_fixture_row("BackRoom", Vector3(-5.5, 0.65, 5.4), Color(0.33, 0.42, 0.46))

	var light := DirectionalLight3D.new()
	light.name = "MovieScenarioKeyLight"
	light.rotation = Vector3(deg_to_rad(-48.0), deg_to_rad(-30.0), 0.0)
	light.light_energy = 2.8
	_stage_root.add_child(light)

	var fill := OmniLight3D.new()
	fill.name = "MovieScenarioWarmFill"
	fill.position = Vector3(0.0, 4.0, 3.0)
	fill.light_color = Color(1.0, 0.72, 0.42)
	fill.light_energy = 1.4
	fill.omni_range = 18.0
	_stage_root.add_child(fill)

	_camera = Camera3D.new()
	_camera.name = "MovieScenarioCamera"
	add_child(_camera)
	if CameraAuthority != null and CameraAuthority.has_method("request_current"):
		CameraAuthority.request_current(_camera, &"movie_scenario_runner")
	else:
		_camera.current = true


func _add_fixture_row(name_prefix: String, origin: Vector3, color: Color) -> void:
	for index: int in range(3):
		var offset := Vector3(float(index) * 1.45, 0.0, 0.0)
		_add_mesh(
			"%s%d" % [name_prefix, index + 1],
			Vector3(1.1, 1.1, 0.55),
			origin + offset,
			color
		)
		_add_mesh(
			"%sStock%d" % [name_prefix, index + 1],
			Vector3(0.75, 0.32, 0.36),
			origin + offset + Vector3(0.0, 0.7, 0.0),
			Color(0.82, 0.68, 0.36)
		)


func _add_mesh(name: String, size: Vector3, position: Vector3, color: Color) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.position = position
	mesh_instance.material_override = _material(color)
	_stage_root.add_child(mesh_instance)


func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.72
	return material


func _build_review_overlay() -> void:
	var layer := CanvasLayer.new()
	layer.name = "MovieScenarioOverlay"
	layer.layer = 90
	add_child(layer)

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)

	_caption_label = _new_label(28, Color(1.0, 0.94, 0.78, 1.0))
	_caption_label.position = Vector2(36.0, 34.0)
	_caption_label.size = Vector2(1000.0, 96.0)
	_caption_label.text = "%s\n%s" % [
		str(_scenario.get("title", _scenario_id)),
		str(_scenario.get("objective", "")),
	]
	root.add_child(_caption_label)

	_toast_label = _new_label(22, Color(0.22, 0.15, 0.09, 1.0))
	_toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast_label.position = Vector2(760.0, 54.0)
	_toast_label.size = Vector2(460.0, 56.0)
	_toast_label.text = ""
	_toast_label.visible = false
	root.add_child(_toast_label)


func _new_label(font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _index_events() -> void:
	_events_by_frame.clear()
	for event_variant: Variant in _scenario.get("events", []) as Array:
		var event: Dictionary = event_variant as Dictionary
		var frame: int = max(1, int(event.get("frame", 1)))
		if not _events_by_frame.has(frame):
			_events_by_frame[frame] = []
		(_events_by_frame[frame] as Array).append(event)


func _apply_events_for_frame(frame: int) -> void:
	if not _events_by_frame.has(frame):
		return
	for event: Dictionary in _events_by_frame[frame] as Array:
		match str(event.get("type", "")):
			"caption":
				_caption_label.text = "%s\n%s" % [
					str(_scenario.get("title", _scenario_id)),
					str(event.get("text", "")),
				]
			"toast":
				_toast_label.text = str(event.get("text", ""))
				_toast_label.visible = true
			"camera":
				_apply_camera_pose(event)


func _apply_camera_pose(config: Dictionary) -> void:
	if _camera == null:
		return
	_camera.position = config.get("camera_position", Vector3(0.0, 3.0, 10.0)) as Vector3
	_camera.rotation = config.get("camera_rotation", Vector3.ZERO) as Vector3
	_camera.fov = float(config.get("fov", 58.0))


func _emit_status(status: String, context: Dictionary = {}) -> void:
	var payload: Dictionary = {
		"type": "movie_scenario",
		"status": status,
		"scenario_id": _scenario_id,
	}
	for key: Variant in context.keys():
		payload[key] = context[key]
	print("MOVIE: %s" % JSON.stringify(payload))


func _fail_and_quit(code: String, message: String) -> void:
	_emit_status("fail", {"code": code, "message": message})
	get_tree().quit(1)
