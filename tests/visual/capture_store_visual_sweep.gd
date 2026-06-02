## Display-backed entry point for the store-session visual acceptance sweep.
extends SceneTree

const StoreVisualSweepScript: GDScript = preload(
	"res://game/scripts/store_session/store_visual_sweep.gd"
)
const StoreVisualScopeProfileScript: GDScript = preload(
	"res://game/scripts/store_session/store_visual_scope_profile.gd"
)
const VisualSweepOverhaulFixturesScript: GDScript = preload(
	"res://tests/visual/visual_sweep_overhaul_fixtures.gd"
)

const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"
const SCREENSHOT_MODE_SETTING: String = "mallcore/test/screenshot_mode"
const REFERENCE_REVIEW_MODE_SETTING: String = "mallcore/test/reference_corner_review_mode"
const SETTLE_FRAMES: int = 5

var _store_root: Node3D = null
var _camera: Camera3D = null
var _captures: Array[Dictionary] = []
var _target_mode: String = StoreVisualSweepScript.FIRST_TEN_SECONDS_TARGET_MODE


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_target_mode = _resolve_target_mode()
	await _wait_for_settings_ready()
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
	await _wait_until_store_enters_tree()
	await _wait_frames(SETTLE_FRAMES)
	_add_capture_camera()
	await _wait_frames(24)

	for row: Dictionary in StoreVisualSweepScript.rows_for_target(_target_mode):
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
		StoreVisualSweepScript.acceptance_current_dir_for_target(_target_mode),
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
	var setup_result: Dictionary = _apply_row_setup(row)
	if not bool(setup_result.get("ok", false)):
		return _capture_error(row, str(setup_result.get("error", "row setup failed")))
	var mode: int = _scope_mode_from_label(str(row.get("visual_scope_mode", "")))
	StoreVisualScopeProfileScript.apply_mode_to_tree(_store_root, mode)
	await _wait_frames(2)

	var focus_path: String = str(row.get("focus", ""))
	var focus: Node3D = _store_root.get_node_or_null(NodePath(focus_path)) as Node3D
	if focus == null:
		return _capture_error(row, "Missing focus node: %s" % focus_path)
	var anchor_validation: Dictionary = _validate_row_anchors(row)
	if not bool(anchor_validation.get("ok", false)):
		return _capture_error(
			row,
			"Missing or hidden visual anchor for %s" % row.get("filename", ""),
			{"anchor_validation": anchor_validation}
		)
	var action_context_validation: Dictionary = StoreVisualSweepScript.validate_action_context(row)
	if not bool(action_context_validation.get("ok", false)):
		return _capture_error(
			row,
			"Ambiguous or missing action context for %s" % row.get("filename", ""),
			{
				"anchor_validation": anchor_validation,
				"action_context_validation": action_context_validation,
			}
		)
	_camera.global_position = row.get("camera", Vector3.ZERO) as Vector3
	if row.has("camera_rotation_degrees"):
		_camera.rotation_degrees = row.get("camera_rotation_degrees", Vector3.ZERO) as Vector3
	else:
		_camera.look_at(focus.global_position, Vector3.UP)
	_camera.current = true
	if int(row.get("index", 0)) == 1:
		await _wait_frames(18)
	else:
		await _wait_frames(SETTLE_FRAMES)

	var debug_ui_validation: Dictionary = _validate_no_editor_debug_ui()
	if not bool(debug_ui_validation.get("ok", false)):
		return _capture_error(row, "Debug/editor UI visible during capture", {
			"anchor_validation": anchor_validation,
			"debug_ui_validation": debug_ui_validation,
		})

	var result: Dictionary = StoreVisualSweepScript.save_viewport_png(
		root,
		StoreVisualSweepScript.acceptance_current_dir_for_target(_target_mode),
		str(row.get("filename", "")),
		false
	)
	result = _normalize_capture_resolution(result)
	result["beat"] = str(row.get("name", ""))
	result["active_route_stage"] = str(row.get("active_route_stage", ""))
	result["active_prompt"] = str(row.get("active_prompt", ""))
	result["next_expected_beat"] = str(row.get("next_expected_beat", ""))
	result["local_action"] = str(row.get("local_action", ""))
	result["next_destination"] = str(row.get("next_destination", ""))
	result["primary_work_surface_target"] = str(row.get("primary_work_surface_target", ""))
	result["design_checks"] = row.get("design_checks", [])
	result["inspiration_closeout"] = row.get("inspiration_closeout", {})
	result["spawn_acceptance_review"] = row.get("spawn_acceptance_review", {})
	result["spawn_readability_anchors"] = row.get("spawn_readability_anchors", [])
	result["setup_state"] = str(row.get("setup_state", ""))
	result["setup_result"] = setup_result
	result["review_manifest_contract"] = StoreVisualSweepScript.review_manifest_contract(row)
	result["review_target"] = str(row.get("review_target", ""))
	result["visual_scope_mode"] = str(row.get("visual_scope_mode", ""))
	result["visual_scope_mode_asserted"] = true
	result["anchor_validation"] = anchor_validation
	result["action_context"] = row.get("action_context", {})
	result["action_context_validation"] = action_context_validation
	result["debug_ui_validation"] = debug_ui_validation
	result["camera_fov"] = StoreVisualSweepScript.CAPTURE_CAMERA_FOV
	if row.has("camera_rotation_degrees"):
		var camera_rotation: Vector3 = row.get("camera_rotation_degrees", Vector3.ZERO) as Vector3
		result["camera_rotation_degrees"] = [
			camera_rotation.x,
			camera_rotation.y,
			camera_rotation.z,
		]
	result["random_seed"] = StoreVisualSweepScript.CAPTURE_RANDOM_SEED
	result["expected_width"] = StoreVisualSweepScript.CAPTURE_RESOLUTION.x
	result["expected_height"] = StoreVisualSweepScript.CAPTURE_RESOLUTION.y
	return _validate_saved_capture(row, result)


func _validate_saved_capture(row: Dictionary, result: Dictionary) -> Dictionary:
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
	var image_validation: Dictionary = _validate_capture_image(str(result.get("path", "")))
	result["image_validation"] = image_validation
	if not bool(image_validation.get("ok", false)):
		return _capture_error(row, str(image_validation.get("error", "Capture image invalid")), result)
	result["acceptance_evidence"] = true
	result["non_acceptance_evidence"] = false
	return result


func _normalize_capture_resolution(result: Dictionary) -> Dictionary:
	if not bool(result.get("ok", false)):
		return result
	var expected_size: Vector2i = StoreVisualSweepScript.CAPTURE_RESOLUTION
	if int(result.get("width", 0)) == expected_size.x \
			and int(result.get("height", 0)) == expected_size.y:
		return result
	var path: String = str(result.get("path", ""))
	var image := Image.new()
	if image.load(path) != OK:
		return result
	image.resize(expected_size.x, expected_size.y, Image.INTERPOLATE_LANCZOS)
	if image.save_png(path) != OK:
		return result
	result["width"] = expected_size.x
	result["height"] = expected_size.y
	return result


func _write_manifest() -> Dictionary:
	return StoreVisualSweepScript.write_review_manifest(
		StoreVisualSweepScript.acceptance_manifest_dir_for_target(_target_mode),
		StoreVisualSweepScript.rows_for_target(_target_mode),
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
		StoreVisualScopeProfileScript.MODE_AUTHORED_FULL_LABEL:
			return StoreVisualScopeProfileScript.MODE_AUTHORED_FULL
		_:
			return StoreVisualScopeProfileScript.MODE_AUTHORED_FULL


func _resolve_target_mode() -> String:
	var env_target: String = OS.get_environment("MALLCORE_VISUAL_SWEEP_TARGET")
	if not env_target.is_empty():
		return _normalize_target_mode(env_target)
	var args: PackedStringArray = OS.get_cmdline_user_args()
	for index: int in range(args.size()):
		var arg: String = args[index]
		if arg.begins_with("--target="):
			return _normalize_target_mode(arg.get_slice("=", 1))
		if arg == "--target" and index + 1 < args.size():
			return _normalize_target_mode(args[index + 1])
	return StoreVisualSweepScript.FIRST_TEN_SECONDS_TARGET_MODE


func _normalize_target_mode(raw: String) -> String:
	var normalized: String = raw.strip_edges().replace("-", "_")
	match normalized:
		"overhaul", StoreVisualSweepScript.OVERHAUL_TARGET_MODE:
			return StoreVisualSweepScript.OVERHAUL_TARGET_MODE
		"first", "first_ten", StoreVisualSweepScript.FIRST_TEN_SECONDS_TARGET_MODE:
			return StoreVisualSweepScript.FIRST_TEN_SECONDS_TARGET_MODE
		_:
			return StoreVisualSweepScript.FIRST_TEN_SECONDS_TARGET_MODE


func _apply_row_setup(row: Dictionary) -> Dictionary:
	return VisualSweepOverhaulFixturesScript.apply(_store_root, row)


func _capture_error(row: Dictionary, message: String, extra: Dictionary = {}) -> Dictionary:
	var result: Dictionary = {
		"ok": false,
		"beat": str(row.get("name", "")),
		"filename": str(row.get("filename", "")),
		"active_route_stage": str(row.get("active_route_stage", "")),
		"active_prompt": str(row.get("active_prompt", "")),
		"next_expected_beat": str(row.get("next_expected_beat", "")),
		"local_action": str(row.get("local_action", "")),
		"next_destination": str(row.get("next_destination", "")),
		"primary_work_surface_target": str(row.get("primary_work_surface_target", "")),
		"action_context": row.get("action_context", {}),
		"action_context_validation": StoreVisualSweepScript.validate_action_context(row),
		"inspiration_closeout": row.get("inspiration_closeout", {}),
		"spawn_acceptance_review": row.get("spawn_acceptance_review", {}),
		"spawn_readability_anchors": row.get("spawn_readability_anchors", []),
		"setup_state": str(row.get("setup_state", "")),
		"review_manifest_contract": StoreVisualSweepScript.review_manifest_contract(row),
		"review_target": str(row.get("review_target", "")),
		"visual_scope_mode": str(row.get("visual_scope_mode", "")),
		"acceptance_evidence": false,
		"non_acceptance_evidence": true,
		"error": message,
	}
	if message.to_lower().contains("headless") or message.to_lower().contains("placeholder"):
		result["non_acceptance_reason"] = (
			"placeholder/headless captures cannot satisfy work-surface polish acceptance"
		)
	for key: Variant in extra.keys():
		if ["ok", "error", "acceptance_evidence", "non_acceptance_evidence"].has(str(key)):
			continue
		result[key] = extra[key]
	return result


func _validate_row_anchors(row: Dictionary) -> Dictionary:
	var missing: Array[String] = []
	var hidden: Array[String] = []
	var visible: Array[String] = []
	var anchors: Array = (row.get("anchors", []) as Array).duplicate()
	var route_anchor: String = str(row.get("route_anchor", ""))
	if not route_anchor.is_empty() and not anchors.has(route_anchor):
		anchors.append(route_anchor)
	for anchor_variant: Variant in anchors:
		var anchor_path: String = str(anchor_variant)
		var anchor: Node3D = _store_root.get_node_or_null(NodePath(anchor_path)) as Node3D
		if anchor == null:
			missing.append(anchor_path)
		elif not _is_visible_through_ancestors(anchor):
			hidden.append(anchor_path)
		else:
			visible.append(anchor_path)
	return {
		"ok": missing.is_empty() and hidden.is_empty(),
		"visible": visible,
		"missing": missing,
		"hidden": hidden,
		"route_anchor": route_anchor,
		"route_anchor_exists": route_anchor.is_empty() \
			or _store_root.get_node_or_null(NodePath(route_anchor)) != null,
		"route_anchor_visible": route_anchor.is_empty() \
			or visible.has(route_anchor),
		"intended_anchor_count": anchors.size(),
	}


func _validate_no_editor_debug_ui() -> Dictionary:
	var visible_debug_items: Array[String] = []
	_collect_visible_debug_items(root, visible_debug_items)
	return {
		"ok": visible_debug_items.is_empty(),
		"visible_debug_items": visible_debug_items,
		"editor_debug_ui_absent": visible_debug_items.is_empty(),
	}


func _collect_visible_debug_items(node: Node, out: Array[String]) -> void:
	if node is CanvasItem:
		var item: CanvasItem = node as CanvasItem
		var lower_name: String = item.name.to_lower()
		if item.is_visible_in_tree() \
				and (lower_name.contains("debug") or lower_name.contains("editor")):
			out.append(String(item.get_path()))
	for child: Node in node.get_children():
		_collect_visible_debug_items(child, out)


func _validate_capture_image(path: String) -> Dictionary:
	var image := Image.new()
	var load_err: int = image.load(path)
	if load_err != OK:
		return {"ok": false, "error": "Capture image unreadable: %s" % path}
	if image.get_width() != StoreVisualSweepScript.CAPTURE_RESOLUTION.x \
			or image.get_height() != StoreVisualSweepScript.CAPTURE_RESOLUTION.y:
		return {
			"ok": false,
			"error": "Capture image dimensions drifted after save: %dx%d"
			% [image.get_width(), image.get_height()],
		}
	var stats: Dictionary = _capture_blankness_metrics(image)
	if float(stats.get("luminance_stddev", 0.0)) < 2.0:
		return {"ok": false, "error": "Capture is near-blank", "blankness": stats}
	if float(stats.get("near_black_ratio", 0.0)) > 0.98:
		return {"ok": false, "error": "Capture is near-black", "blankness": stats}
	if float(stats.get("near_white_ratio", 0.0)) > 0.98:
		return {"ok": false, "error": "Capture is near-white", "blankness": stats}
	return {"ok": true, "blankness": stats}


func _capture_blankness_metrics(image: Image) -> Dictionary:
	var total: int = image.get_width() * image.get_height()
	if total <= 0:
		return {"luminance_stddev": 0.0, "near_black_ratio": 1.0, "near_white_ratio": 0.0}
	var sum: float = 0.0
	var sum_sq: float = 0.0
	var near_black: int = 0
	var near_white: int = 0
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var color: Color = image.get_pixel(x, y)
			var luminance: float = (color.r * 54.213) + (color.g * 182.376) + (color.b * 18.411)
			sum += luminance
			sum_sq += luminance * luminance
			if luminance <= 8.0:
				near_black += 1
			if luminance >= 247.0:
				near_white += 1
	var mean: float = sum / float(total)
	var variance: float = maxf((sum_sq / float(total)) - (mean * mean), 0.0)
	return {
		"luminance_stddev": sqrt(variance),
		"near_black_ratio": float(near_black) / float(total),
		"near_white_ratio": float(near_white) / float(total),
	}


func _is_visible_through_ancestors(node: Node) -> bool:
	var current: Node = node
	while current != null and current != _store_root:
		if current is Node3D and not (current as Node3D).visible:
			return false
		current = current.get_parent()
	return true


func _wait_frames(count: int) -> void:
	for _i: int in range(count):
		await process_frame


func _wait_until_store_enters_tree() -> void:
	await _wait_frames(6)
	_request_store_add()
	for _i: int in range(60):
		if _store_root != null and _store_root.get_parent() == root:
			return
		await process_frame
	_fail("Store scene did not enter the visual sweep tree.")
	return


func _request_store_add() -> void:
	if _store_root != null and _store_root.get_parent() == null:
		root.add_child.call_deferred(_store_root)


func _wait_for_settings_ready() -> void:
	var settings: Node = _autoload("Settings")
	if settings != null and not settings.is_node_ready():
		await settings.ready


func _autoload(singleton_name: String) -> Node:
	return root.get_node_or_null(NodePath(singleton_name))


func _fail(message: String) -> void:
	push_error(message)
	print("Store visual sweep failed: %s" % message)
	quit(1)
