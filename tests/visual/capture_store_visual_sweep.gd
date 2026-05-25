## Display-backed entry point for the store-session visual acceptance sweep.
extends SceneTree

const StoreVisualSweepScript: GDScript = preload(
	"res://game/scripts/store_session/store_visual_sweep.gd"
)
const StoreVisualScopeProfileScript: GDScript = preload(
	"res://game/scripts/store_session/store_visual_scope_profile.gd"
)

const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"
const SCREENSHOT_MODE_SETTING: String = "mallcore/test/screenshot_mode"
const REFERENCE_REVIEW_MODE_SETTING: String = "mallcore/test/reference_corner_review_mode"
const SETTLE_FRAMES: int = 5

var _store_root: Node3D = null
var _camera: Camera3D = null
var _captures: Array[Dictionary] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		_fail("Store visual sweep requires a display-backed viewport; do not use --headless.")
		return
	_configure_deterministic_capture()

	var packed: PackedScene = load(SCENE_PATH) as PackedScene
	if packed == null:
		_fail("Store scene missing: %s" % SCENE_PATH)
		return
	_store_root = packed.instantiate() as Node3D
	if _store_root == null:
		_fail("Store scene root must be Node3D: %s" % SCENE_PATH)
		return
	root.add_child(_store_root)
	await _wait_frames(SETTLE_FRAMES)
	_add_capture_camera()
	await _wait_frames(2)

	for row: Dictionary in StoreVisualSweepScript.rows():
		var row_result: Dictionary = await _capture_row(row)
		_captures.append(row_result)
		if not bool(row_result.get("ok", false)):
			_write_manifest()
			_fail(str(row_result.get("error", "capture failed")))
			return

	var manifest: Dictionary = _write_manifest()
	if not bool(manifest.get("ok", false)):
		_fail(str(manifest.get("error", "review manifest failed")))
		return
	print("Store visual sweep captured %d views: %s" % [
		_captures.size(),
		StoreVisualSweepScript.acceptance_current_dir(),
	])
	quit(0)


func _configure_deterministic_capture() -> void:
	seed(StoreVisualSweepScript.CAPTURE_RANDOM_SEED)
	ProjectSettings.set_setting(SCREENSHOT_MODE_SETTING, true)
	ProjectSettings.set_setting(REFERENCE_REVIEW_MODE_SETTING, true)
	DisplayServer.window_set_size(StoreVisualSweepScript.CAPTURE_RESOLUTION)
	root.size = StoreVisualSweepScript.CAPTURE_RESOLUTION
	var game_manager: Node = _autoload("GameManager")
	if game_manager != null:
		game_manager.set("current_state", 8)
		game_manager.call("set_current_day", 1)
	var store_session_state: Node = _autoload("StoreSessionState")
	if store_session_state != null:
		store_session_state.call("reset_new_run")
		store_session_state.set("preopening_complete", true)
	for singleton_name: String in ["InputFocus", "ModalQueue", "InteractionPrompt"]:
		var singleton: Node = _autoload(singleton_name)
		if singleton != null and singleton.has_method("_reset_for_tests"):
			singleton.call("_reset_for_tests")


func _add_capture_camera() -> void:
	_camera = Camera3D.new()
	_camera.name = "StoreVisualSweepCamera"
	_camera.fov = StoreVisualSweepScript.CAPTURE_CAMERA_FOV
	_camera.near = 0.05
	_store_root.add_child(_camera)
	_camera.current = true


func _capture_row(row: Dictionary) -> Dictionary:
	var mode: int = _scope_mode_from_label(str(row.get("visual_scope_mode", "")))
	StoreVisualScopeProfileScript.apply_mode_to_tree(_store_root, mode)
	await _wait_frames(2)

	var focus_path: String = str(row.get("focus", ""))
	var focus: Node3D = _store_root.get_node_or_null(NodePath(focus_path)) as Node3D
	if focus == null:
		return _capture_error(row, "Missing focus node: %s" % focus_path)
	_camera.global_position = row.get("camera", Vector3.ZERO) as Vector3
	_camera.look_at(focus.global_position, Vector3.UP)
	_camera.current = true
	await _wait_frames(SETTLE_FRAMES)

	var result: Dictionary = StoreVisualSweepScript.save_viewport_png(
		root,
		StoreVisualSweepScript.acceptance_current_dir(),
		str(row.get("filename", "")),
		false
	)
	result["beat"] = str(row.get("name", ""))
	result["visual_scope_mode"] = str(row.get("visual_scope_mode", ""))
	result["camera_fov"] = StoreVisualSweepScript.CAPTURE_CAMERA_FOV
	result["random_seed"] = StoreVisualSweepScript.CAPTURE_RANDOM_SEED
	result["expected_width"] = StoreVisualSweepScript.CAPTURE_RESOLUTION.x
	result["expected_height"] = StoreVisualSweepScript.CAPTURE_RESOLUTION.y
	if not bool(result.get("ok", false)):
		return result
	if bool(result.get("placeholder", false)):
		return _capture_error(row, "Placeholder capture rejected: %s" % row.get("filename", ""))
	if int(result.get("width", 0)) != StoreVisualSweepScript.CAPTURE_RESOLUTION.x \
			or int(result.get("height", 0)) != StoreVisualSweepScript.CAPTURE_RESOLUTION.y:
		return _capture_error(
			row,
			"Wrong capture dimensions for %s: %dx%d"
			% [row.get("filename", ""), int(result.get("width", 0)), int(result.get("height", 0))]
		)
	if not FileAccess.file_exists(str(result.get("path", ""))):
		return _capture_error(row, "Capture file missing: %s" % row.get("filename", ""))
	return result


func _write_manifest() -> Dictionary:
	return StoreVisualSweepScript.write_review_manifest(
		StoreVisualSweepScript.acceptance_manifest_dir(),
		StoreVisualSweepScript.rows(),
		_captures
	)


func _scope_mode_from_label(label: String) -> int:
	match label:
		StoreVisualScopeProfileScript.MODE_STORE_SESSION_RUNTIME_LABEL:
			return StoreVisualScopeProfileScript.MODE_STORE_SESSION_RUNTIME
		StoreVisualScopeProfileScript.MODE_STORE_SESSION_REFERENCE_VISIBLE_LABEL:
			return StoreVisualScopeProfileScript.MODE_STORE_SESSION_REFERENCE_VISIBLE
		StoreVisualScopeProfileScript.MODE_SUPPRESSION_DIFF_LABEL:
			return StoreVisualScopeProfileScript.MODE_SUPPRESSION_DIFF
		_:
			return StoreVisualScopeProfileScript.MODE_AUTHORED_FULL


func _capture_error(row: Dictionary, message: String) -> Dictionary:
	return {
		"ok": false,
		"beat": str(row.get("name", "")),
		"filename": str(row.get("filename", "")),
		"error": message,
	}


func _wait_frames(count: int) -> void:
	for _i: int in range(count):
		await process_frame


func _autoload(singleton_name: String) -> Node:
	return root.get_node_or_null(NodePath(singleton_name))


func _fail(message: String) -> void:
	push_error(message)
	print("Store visual sweep failed: %s" % message)
	quit(1)
