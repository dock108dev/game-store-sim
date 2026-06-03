## Display-backed FP roam capture harness used as a reusable visual control.
extends SceneTree

const AutomationArtifactsScript: GDScript = preload(
	"res://game/scripts/core/automation_artifacts.gd"
)
const FPRoamManifestScript: GDScript = preload(
	"res://tests/visual/fp_roam_validation_manifest.gd"
)
const StoreVisualScopeProfileScript: GDScript = preload(
	"res://game/scripts/store_session/store_visual_scope_profile.gd"
)
const StoreVisualSweepScript: GDScript = preload(
	"res://game/scripts/store_session/store_visual_sweep.gd"
)
const WorkSurfaceLayoutScript: GDScript = preload(
	"res://game/scripts/ui/work_surface_layout.gd"
)

const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"
const SCREENSHOT_MODE_SETTING: String = "mallcore/test/screenshot_mode"
const SETTLE_FRAMES: int = 5

var _captures: Array[Dictionary] = []
var _camera: Camera3D = null
var _fp_state_seeded: bool = false
var _fp_sentence_label: Label = null
var _run_label: String = FPRoamManifestScript.CONTROL_RUN
var _store_root: Node3D = null
var _validation_overlay: CanvasLayer = null


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_run_label = _resolve_run_label()
	await _wait_for_settings_ready()
	if DisplayServer.get_name() == "headless":
		_fail("FP roam validation requires a display-backed viewport.")
		return
	_configure_capture()

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
	_add_fp_validation_overlay()
	await _wait_frames(12)
	_apply_fp_hud_state()

	for row: Dictionary in FPRoamManifestScript.rows():
		var row_result: Dictionary = await _capture_row(row)
		_captures.append(row_result)
		if not bool(row_result.get("ok", false)):
			_write_manifest()
			_fail(str(row_result.get("error", "FP roam capture failed")))
			return

	var manifest: Dictionary = _write_manifest()
	if not bool(manifest.get("ok", false)):
		_fail(str(manifest.get("error", "FP roam manifest failed")))
		return
	print("FP roam validation captured %d %s views: %s" % [
		_captures.size(),
		_run_label,
		FPRoamManifestScript.current_dir(_run_label),
	])
	quit(0)


func _configure_capture() -> void:
	seed(FPRoamManifestScript.CAPTURE_RANDOM_SEED)
	ProjectSettings.set_setting(SCREENSHOT_MODE_SETTING, true)
	DisplayServer.window_set_size(FPRoamManifestScript.CAPTURE_RESOLUTION)
	root.size = FPRoamManifestScript.CAPTURE_RESOLUTION
	var game_manager: Node = _autoload("GameManager")
	if game_manager != null:
		game_manager.set("current_state", 8)
		if game_manager.has_method("set_current_day"):
			game_manager.call("set_current_day", 1)
	var store_session_state: Node = _autoload("StoreSessionState")
	if store_session_state != null:
		if store_session_state.has_method("reset_new_run"):
			store_session_state.call("reset_new_run")
		store_session_state.set("preopening_complete", false)
	for singleton_name: String in ["InputFocus", "ModalQueue", "InteractionPrompt"]:
		var singleton: Node = _autoload(singleton_name)
		if singleton != null and singleton.has_method("_reset_for_tests"):
			singleton.call("_reset_for_tests")
	_emit_event("interactable_unfocused", [])


func _add_capture_camera() -> void:
	_camera = Camera3D.new()
	_camera.name = "FPRoamValidationCamera"
	_camera.fov = FPRoamManifestScript.CAPTURE_CAMERA_FOV
	_camera.near = 0.05
	_store_root.add_child(_camera)
	_camera.current = true


func _add_fp_validation_overlay() -> void:
	_validation_overlay = CanvasLayer.new()
	_validation_overlay.name = "FPRoamValidationOverlay"
	_validation_overlay.layer = 30
	root.add_child(_validation_overlay)
	_add_overlay_label("FPCashLabel", "$500.00", WorkSurfaceLayoutScript.FP_CASH_RECT)
	_add_overlay_label(
		"FPTimeLabel",
		"First Day - 8:00 AM",
		WorkSurfaceLayoutScript.FP_TIME_RECT,
		HORIZONTAL_ALIGNMENT_CENTER
	)
	_fp_sentence_label = _add_overlay_label(
		"FpSentenceLabel",
		"Talk to the manager at checkout for opening instructions",
		WorkSurfaceLayoutScript.FP_SENTENCE_RECT,
		HORIZONTAL_ALIGNMENT_CENTER
	)
	_add_overlay_label("Crosshair", "+", Rect2(-8.0, -8.0, 16.0, 16.0), HORIZONTAL_ALIGNMENT_CENTER)


func _add_overlay_label(
	label_name: String,
	text: String,
	rect: Rect2,
	alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT
) -> Label:
	var label := Label.new()
	label.name = label_name
	label.text = text
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.modulate = Color(1.0, 1.0, 1.0, 0.9)
	label.clip_text = true
	if label_name == "FPCashLabel":
		label.anchor_left = 0.0
		label.anchor_right = 0.0
		label.anchor_top = 0.0
		label.anchor_bottom = 0.0
	elif label_name == "FPTimeLabel":
		label.anchor_left = 0.5
		label.anchor_right = 0.5
		label.anchor_top = 0.0
		label.anchor_bottom = 0.0
	elif label_name == "Crosshair":
		label.anchor_left = 0.5
		label.anchor_right = 0.5
		label.anchor_top = 0.5
		label.anchor_bottom = 0.5
	else:
		label.anchor_left = 0.5
		label.anchor_right = 0.5
		label.anchor_top = 1.0
		label.anchor_bottom = 1.0
	label.offset_left = rect.position.x
	label.offset_top = rect.position.y
	label.offset_right = rect.position.x + rect.size.x
	label.offset_bottom = rect.position.y + rect.size.y
	_validation_overlay.add_child(label)
	return label


func _apply_fp_hud_state() -> void:
	if not _fp_state_seeded:
		_emit_event("money_changed", [0.0, 500.0])
		_emit_event("day_started", [1])
		_emit_event("hour_changed", [8])
		_fp_state_seeded = true
	_emit_event("objective_changed", [{
		"text": "Talk to the manager at checkout for opening instructions.",
		"action": "Get the opening routine from the manager",
		"key": "E",
	}])
	_emit_event("fp_mode_changed", [true])


func _capture_row(row: Dictionary) -> Dictionary:
	_apply_scope(row)
	_apply_row_camera(row)
	_apply_row_prompt(row)
	_apply_fp_hud_state()
	await _wait_frames(16)
	var anchor_validation: Dictionary = _validate_row_anchors(row)
	if not bool(anchor_validation.get("ok", false)):
		return _capture_error(row, "Missing or hidden anchors", {
			"anchor_validation": anchor_validation,
		})
	var ui_validation: Dictionary = _validate_fp_ui(row)
	if not bool(ui_validation.get("ok", false)):
		return _capture_error(row, "FP UI contract failed", {
			"anchor_validation": anchor_validation,
			"ui_validation": ui_validation,
		})
	var density_validation: Dictionary = _validate_density_requirements(row)
	if not bool(density_validation.get("ok", false)):
		return _capture_error(row, "Retail density contract failed", {
			"anchor_validation": anchor_validation,
			"ui_validation": ui_validation,
			"density_validation": density_validation,
		})
	await RenderingServer.frame_post_draw
	var result: Dictionary = StoreVisualSweepScript.save_viewport_png(
		root,
		FPRoamManifestScript.current_dir(_run_label),
		str(row.get("filename", "")),
		false
	)
	result = _normalize_capture_resolution(result)
	if not bool(result.get("ok", false)):
		return _capture_error(row, str(result.get("error", "save failed")), result)
	result["run_label"] = _run_label
	result["beat"] = str(row.get("name", ""))
	result["review_goal"] = str(row.get("review_goal", ""))
	result["prompt_text"] = str(row.get("prompt_text", ""))
	result["objective_text"] = str(row.get("objective_text", ""))
	result["inspiration_tags"] = row.get("inspiration_tags", [])
	result["checklist"] = row.get("checklist", [])
	result["anchor_validation"] = anchor_validation
	result["ui_validation"] = ui_validation
	result["density_validation"] = density_validation
	result["camera_fov"] = FPRoamManifestScript.CAPTURE_CAMERA_FOV
	result["acceptance_evidence"] = true
	result["non_acceptance_evidence"] = false
	var image_validation: Dictionary = _validate_capture_image(str(result.get("path", "")), row)
	result["image_validation"] = image_validation
	if not bool(image_validation.get("ok", false)):
		return _capture_error(row, str(image_validation.get("error", "")), result)
	return result


func _validate_density_requirements(row: Dictionary) -> Dictionary:
	var requirements: Dictionary = row.get("density_requirements", {}) as Dictionary
	var phase4_summary: Dictionary = _phase4_density_summary()
	var failures: Array[String] = []
	for raw_role: Variant in requirements.get("required_phase4_roles", []) as Array:
		var role: String = str(raw_role)
		if int((phase4_summary.get("roles", {}) as Dictionary).get(role, 0)) <= 0:
			failures.append("Missing Phase 4 retail role: %s" % role)
	for raw_state_key: Variant in requirements.get("required_phase4_states", []) as Array:
		var state_key: String = str(raw_state_key)
		if int((phase4_summary.get("states", {}) as Dictionary).get(state_key, 0)) <= 0:
			failures.append("Missing Phase 4 retail state key: %s" % state_key)
	for raw_pair: Variant in requirements.get("required_phase4_state_values", []) as Array:
		var pair: String = str(raw_pair)
		if int((phase4_summary.get("state_values", {}) as Dictionary).get(pair, 0)) <= 0:
			failures.append("Missing Phase 4 retail state value: %s" % pair)
	return {
		"ok": failures.is_empty(),
		"failures": failures,
		"phase4": phase4_summary,
	}


func _phase4_density_summary() -> Dictionary:
	var roles: Dictionary = {}
	var kinds: Dictionary = {}
	var states: Dictionary = {}
	var state_values: Dictionary = {}
	var total: int = 0
	total = _collect_phase4_density(_store_root, roles, kinds, states, state_values, total)
	return {
		"total": total,
		"roles": roles,
		"kinds": kinds,
		"states": states,
		"state_values": state_values,
	}


func _collect_phase4_density(
	node: Node,
	roles: Dictionary,
	kinds: Dictionary,
	states: Dictionary,
	state_values: Dictionary,
	total: int
) -> int:
	if node == null:
		return total
	if bool(node.get_meta("phase4_retail_prop", false)):
		total += 1
		var role: String = str(node.get_meta("retail_prop_role", ""))
		var kind: String = str(node.get_meta("retail_prop_kind", ""))
		var state_key: String = str(node.get_meta("retail_state_key", ""))
		var state_value: String = str(node.get_meta("retail_state_value", ""))
		roles[role] = int(roles.get(role, 0)) + 1
		kinds[kind] = int(kinds.get(kind, 0)) + 1
		if not state_key.is_empty():
			states[state_key] = int(states.get(state_key, 0)) + 1
		if not state_key.is_empty() and not state_value.is_empty():
			var pair: String = "%s:%s" % [state_key, state_value]
			state_values[pair] = int(state_values.get(pair, 0)) + 1
	for child: Node in node.get_children():
		total = _collect_phase4_density(child, roles, kinds, states, state_values, total)
	return total


func _apply_scope(row: Dictionary) -> void:
	var mode: int = StoreVisualScopeProfileScript.MODE_STORE_SESSION_RUNTIME
	var label: String = str(row.get("visual_scope_mode", ""))
	if label == StoreVisualScopeProfileScript.MODE_STORE_SESSION_REFERENCE_VISIBLE_LABEL:
		mode = StoreVisualScopeProfileScript.MODE_STORE_SESSION_REFERENCE_VISIBLE
	StoreVisualScopeProfileScript.apply_mode_to_tree(_store_root, mode)


func _apply_row_camera(row: Dictionary) -> void:
	var focus_path: String = str(row.get("focus", ""))
	var focus: Node3D = _store_root.get_node_or_null(NodePath(focus_path)) as Node3D
	_camera.global_position = row.get("camera", Vector3.ZERO) as Vector3
	if focus != null:
		_camera.look_at(focus.global_position, Vector3.UP)
	_camera.current = true


func _apply_row_prompt(row: Dictionary) -> void:
	var prompt_text: String = str(row.get("prompt_text", ""))
	if prompt_text.is_empty():
		_emit_event("interactable_unfocused", [])
	else:
		_emit_event("interactable_focused", [prompt_text])


func _validate_row_anchors(row: Dictionary) -> Dictionary:
	var missing: Array[String] = []
	var hidden: Array[String] = []
	var visible: Array[String] = []
	for anchor_variant: Variant in row.get("anchors", []) as Array:
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
		"missing": missing,
		"hidden": hidden,
		"visible": visible,
	}


func _validate_fp_ui(row: Dictionary) -> Dictionary:
	var failures: Array[String] = []
	var objective_rail: CanvasLayer = _autoload("ObjectiveRail") as CanvasLayer
	var interaction_prompt: CanvasLayer = _autoload("InteractionPrompt") as CanvasLayer
	var status_panel: Node = root.get_tree().get_first_node_in_group("store_status_panel")
	var prompt_panel: Control = null
	if interaction_prompt != null:
		prompt_panel = interaction_prompt.get_node_or_null("PanelContainer") as Control
	var prompt_expected: bool = not str(row.get("prompt_text", "")).is_empty()
	var objective_rail_visible: bool = false if objective_rail == null else objective_rail.visible
	if objective_rail_visible:
		failures.append("ObjectiveRail visible in FP mode")
	if _fp_sentence_label == null \
			or not _fp_sentence_label.visible \
			or _fp_sentence_label.text.strip_edges().is_empty():
		failures.append("FP validation sentence missing, hidden, or empty")
	if prompt_panel == null:
		failures.append("InteractionPrompt panel missing")
	elif prompt_expected and not prompt_panel.visible:
		failures.append("InteractionPrompt hidden on focused stop")
	elif not prompt_expected and prompt_panel.visible:
		failures.append("InteractionPrompt visible on unfocused stop")
	var status_panel_width: float = 0.0
	var status_panel_bg_alpha: float = 0.0
	if status_panel != null:
		if status_panel.has_method("get_panel_width"):
			status_panel_width = float(status_panel.call("get_panel_width"))
		if status_panel.has_method("get_panel_background_alpha"):
			status_panel_bg_alpha = float(status_panel.call("get_panel_background_alpha"))
	if status_panel == null:
		failures.append("StoreStatusPanel missing")
	elif status_panel_width > 260.0:
		failures.append("StoreStatusPanel too wide in FP mode")
	elif status_panel_bg_alpha > 0.62:
		failures.append("StoreStatusPanel too opaque in FP mode")
	return {
		"ok": failures.is_empty(),
		"failures": failures,
		"objective_rail_visible": objective_rail_visible,
		"fp_sentence_text": "" if _fp_sentence_label == null else _fp_sentence_label.text,
		"fp_sentence_visible": false if _fp_sentence_label == null else _fp_sentence_label.visible,
		"top_bar_visible": false,
		"prompt_expected": prompt_expected,
		"prompt_visible": false if prompt_panel == null else prompt_panel.visible,
		"status_panel_width": status_panel_width,
		"status_panel_bg_alpha": status_panel_bg_alpha,
	}


func _capture_error(
	row: Dictionary,
	message: String,
	extra: Dictionary = {}
) -> Dictionary:
	var result: Dictionary = {
		"ok": false,
		"run_label": _run_label,
		"beat": str(row.get("name", "")),
		"filename": str(row.get("filename", "")),
		"review_goal": str(row.get("review_goal", "")),
		"prompt_text": str(row.get("prompt_text", "")),
		"inspiration_tags": row.get("inspiration_tags", []),
		"checklist": row.get("checklist", []),
		"acceptance_evidence": false,
		"non_acceptance_evidence": true,
		"error": message,
	}
	for key: Variant in extra.keys():
		if ["ok", "error"].has(str(key)):
			continue
		result[key] = extra[key]
	return result


func _normalize_capture_resolution(result: Dictionary) -> Dictionary:
	if not bool(result.get("ok", false)):
		return result
	var expected_size: Vector2i = FPRoamManifestScript.CAPTURE_RESOLUTION
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


func _validate_capture_image(path: String, row: Dictionary) -> Dictionary:
	var image := Image.new()
	if image.load(path) != OK:
		return {"ok": false, "error": "Capture image unreadable: %s" % path}
	var stats: Dictionary = _capture_blankness_metrics(image)
	if float(stats.get("luminance_stddev", 0.0)) < 2.0:
		return {"ok": false, "error": "Capture is near-blank", "blankness": stats}
	if float(stats.get("near_black_ratio", 0.0)) > 0.98:
		return {"ok": false, "error": "Capture is near-black", "blankness": stats}
	var image_limits: Dictionary = row.get("image_limits", {}) as Dictionary
	var max_near_white: float = float(image_limits.get("max_near_white_ratio", 0.20))
	if float(stats.get("near_white_ratio", 0.0)) > max_near_white:
		return {
			"ok": false,
			"error": "Capture has too much high-luminance dominance",
			"blankness": stats,
			"image_limits": image_limits,
		}
	return {"ok": true, "blankness": stats}


func _capture_blankness_metrics(image: Image) -> Dictionary:
	var total: int = image.get_width() * image.get_height()
	var sum: float = 0.0
	var sum_sq: float = 0.0
	var near_black: int = 0
	var near_white: int = 0
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var color: Color = image.get_pixel(x, y)
			var luminance: float = (
				(color.r * 54.213) + (color.g * 182.376) + (color.b * 18.411)
			)
			sum += luminance
			sum_sq += luminance * luminance
			if luminance <= 8.0:
				near_black += 1
			if luminance >= 215.0:
				near_white += 1
	var mean: float = sum / float(total)
	var variance: float = maxf((sum_sq / float(total)) - (mean * mean), 0.0)
	return {
		"luminance_stddev": sqrt(variance),
		"near_black_ratio": float(near_black) / float(total),
		"near_white_ratio": float(near_white) / float(total),
	}


func _write_manifest() -> Dictionary:
	var payload: Dictionary = {
		"ok": _all_captures_ok(),
		"suite": FPRoamManifestScript.SUITE,
		"run_label": _run_label,
		"artifact_dir": FPRoamManifestScript.current_dir(_run_label),
		"capture_resolution": [
			FPRoamManifestScript.CAPTURE_RESOLUTION.x,
			FPRoamManifestScript.CAPTURE_RESOLUTION.y,
			],
			"capture_fov": FPRoamManifestScript.CAPTURE_CAMERA_FOV,
			"review_checklist": FPRoamManifestScript.review_checklist(),
			"control_candidate_policy": {
				"control": "Capture before a visual/HUD phase.",
				"candidate": "Capture after the scoped phase and compare same stops.",
				"extend_by": "Add new rows to fp_roam_validation_manifest.gd.",
			},
			"capture_overlay_note": (
				"Display-backed script captures use a lightweight FP validation overlay "
				+ "for stable control/candidate screenshots; focused GUT tests cover "
				+ "the full HUD scene FP contract."
			),
			"density_summary": _phase4_density_summary(),
			"actual_hud_contract_source": [
				"tests/gut/test_hud_fp_mode.gd",
				"tests/gut/test_objective_rail_day1_visibility.gd",
				"tests/gut/test_interaction_prompt.gd",
			],
			"beats": FPRoamManifestScript.rows(),
			"captures": _captures,
		}
	return AutomationArtifactsScript.write_recorded_json(
		FPRoamManifestScript.manifest_path(_run_label),
		payload,
		"report",
		"",
		FPRoamManifestScript.SUITE,
		"manifest",
		"Cannot write FP roam validation manifest"
	)


func _all_captures_ok() -> bool:
	for capture: Dictionary in _captures:
		if not bool(capture.get("ok", false)):
			return false
	return true


func _is_visible_through_ancestors(node: Node) -> bool:
	var current: Node = node
	while current != null and current != _store_root:
		if current is Node3D and not (current as Node3D).visible:
			return false
		current = current.get_parent()
	return true


func _resolve_run_label() -> String:
	var env_label: String = OS.get_environment("MALLCORE_FP_ROAM_RUN")
	if not env_label.is_empty():
		return FPRoamManifestScript.normalize_run_label(env_label)
	var args: PackedStringArray = OS.get_cmdline_user_args()
	for index: int in range(args.size()):
		var arg: String = args[index]
		if arg.begins_with("--run="):
			return FPRoamManifestScript.normalize_run_label(arg.get_slice("=", 1))
		if arg == "--run" and index + 1 < args.size():
			return FPRoamManifestScript.normalize_run_label(args[index + 1])
	return FPRoamManifestScript.CONTROL_RUN


func _autoload(singleton_name: String) -> Node:
	return root.get_node_or_null(NodePath(singleton_name))


func _emit_event(signal_name: String, args: Array) -> void:
	var event_bus: Node = _autoload("EventBus")
	if event_bus == null:
		return
	event_bus.callv("emit_signal", [signal_name] + args)


func _wait_for_settings_ready() -> void:
	var settings: Node = _autoload("Settings")
	if settings != null and not settings.is_node_ready():
		await settings.ready


func _wait_until_store_enters_tree() -> void:
	await _wait_frames(6)
	_request_store_add()
	for _i: int in range(60):
		if _store_root != null and _store_root.get_parent() == root:
			return
		await process_frame
	_fail("Store scene did not enter the FP roam validation tree.")
	return


func _request_store_add() -> void:
	if _store_root != null and _store_root.get_parent() == null:
		root.add_child.call_deferred(_store_root)


func _wait_frames(count: int) -> void:
	for _i: int in range(count):
		await process_frame


func _fail(message: String) -> void:
	push_error(message)
	print("FP roam validation failed: %s" % message)
	quit(1)
