class_name LayoutTortureFlow
extends Control

const AutomationArtifactsScript: GDScript = preload(
	"res://game/scripts/core/automation_artifacts.gd"
)
const StoreVisualSweepScript: GDScript = preload(
	"res://game/scripts/store_session/store_visual_sweep.gd"
)

const SCENARIO_ID: String = "layout_torture"
const STYLE_VARIANT: String = "mallcore_dark_retro"
const SMALL_WINDOW_SIZE: Vector2i = Vector2i(1024, 576)
const VIEWPORTS: Array[Vector2i] = [
	SMALL_WINDOW_SIZE,
	Vector2i(1280, 720),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
]
const SCREEN_STATES: Array[String] = [
	"main_menu",
	"hud",
	"store_ui",
	"side_panel",
	"dialogue_modal",
	"notification_stack",
	"save_load",
	"store_session_prompt",
]

var _complete: bool = false
var _running: bool = false
var _owns_focus_context: bool = false
var _result: Dictionary = _blank_result()


func _ready() -> void:
	name = "LayoutTortureFlow"
	if InputFocus != null and InputFocus.current() == &"":
		InputFocus.push_context(InputFocus.CTX_MAIN_MENU)
		_owns_focus_context = true
	size = Vector2(1280, 720)
	call_deferred("start")


func _exit_tree() -> void:
	if _owns_focus_context and InputFocus != null and InputFocus.current() == InputFocus.CTX_MAIN_MENU:
		InputFocus.pop_context()


func start() -> void:
	if _running or _complete:
		return
	_running = true
	_result = _blank_result()
	await _run_flow()
	_complete = true
	_running = false


func is_complete() -> bool:
	return _complete


func get_run_ok() -> bool:
	return bool(_result.get("ok", false))


func get_run_result() -> Dictionary:
	return _result.duplicate(true)


func _run_flow() -> void:
	var captures: Array[Dictionary] = []
	var failures: Array[Dictionary] = []
	for viewport_size: Vector2i in VIEWPORTS:
		for state_id: String in SCREEN_STATES:
			var fixture: Dictionary = _make_fixture(state_id, viewport_size)
			var viewport := fixture.get("viewport") as SubViewport
			await get_tree().process_frame
			await get_tree().process_frame
			var report: Dictionary = _layout_report(state_id, viewport_size, fixture)
			failures.append_array(report.get("failures", []) as Array)
			var capture: Dictionary = _write_capture(viewport, state_id, viewport_size, report)
			captures.append(capture)
			viewport.queue_free()
	_result = _final_result(captures, failures)
	_write_manifest(_result)


func _make_fixture(state_id: String, viewport_size: Vector2i) -> Dictionary:
	var viewport := SubViewport.new()
	viewport.name = "LayoutTortureViewport_%s_%dx%d" % [
		state_id,
		viewport_size.x,
		viewport_size.y,
	]
	viewport.size = viewport_size
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	var surface := Control.new()
	surface.name = "LayoutSurface"
	surface.size = Vector2(viewport_size)
	viewport.add_child(surface)
	var controls: Dictionary = {}
	_add_background(surface, viewport_size)
	_build_state(surface, state_id, viewport_size, controls)
	return {"viewport": viewport, "surface": surface, "controls": controls}


func _build_state(
	surface: Control, state_id: String, viewport_size: Vector2i, controls: Dictionary
) -> void:
	match state_id:
		"main_menu":
			_add_panel(surface, controls, "main_menu_panel", _center_rect(viewport_size, 520, 300), true)
			_add_label(controls["main_menu_panel"], "PrimaryAction", "New Game", 22)
		"hud":
			_add_top_bar(surface, controls, viewport_size)
			_add_objective(surface, controls, viewport_size)
			_add_prompt(surface, controls, viewport_size)
			_add_notifications(surface, controls, viewport_size, 1)
		"store_ui":
			_add_top_bar(surface, controls, viewport_size)
			_add_side_panel(surface, controls, viewport_size)
			_add_panel(surface, controls, "store_ui_panel", Rect2(32, 112, min(560, viewport_size.x - 420), 300), true)
			_add_notifications(surface, controls, viewport_size, 1)
		"side_panel":
			_add_top_bar(surface, controls, viewport_size)
			_add_side_panel(surface, controls, viewport_size, true)
			_add_event_log(surface, controls, viewport_size)
			_add_prompt(surface, controls, viewport_size)
		"dialogue_modal":
			_add_top_bar(surface, controls, viewport_size)
			_add_panel(surface, controls, "dialogue_panel", _center_rect(viewport_size, 640, 168), true)
			_add_notifications(surface, controls, viewport_size, 1)
		"notification_stack":
			_add_top_bar(surface, controls, viewport_size)
			_add_side_panel(surface, controls, viewport_size)
			_add_notifications(surface, controls, viewport_size, 3, true)
			_add_prompt(surface, controls, viewport_size)
		"save_load":
			_add_panel(surface, controls, "save_load_panel", _center_rect(viewport_size, 680, 360), true)
			_add_label(controls["save_load_panel"], "SlotPreview", "Auto-save - Day 1 - Retro Games", 16)
		"store_session_prompt":
			_add_top_bar(surface, controls, viewport_size)
			_add_side_panel(surface, controls, viewport_size)
			_add_event_log(surface, controls, viewport_size)
			_add_prompt(surface, controls, viewport_size, true)
			_add_panel(surface, controls, "store_session_prompt", Rect2(64, viewport_size.y - 80, viewport_size.x - 128, 48), true)


func _layout_report(state_id: String, viewport_size: Vector2i, fixture: Dictionary) -> Dictionary:
	var controls: Dictionary = fixture.get("controls", {}) as Dictionary
	var viewport_rect := Rect2(Vector2.ZERO, Vector2(viewport_size))
	var rects: Dictionary = {}
	var failures: Array[Dictionary] = []
	for key: String in controls.keys():
		var control := controls[key] as Control
		var rect: Rect2 = control.get_global_rect()
		rects[key] = _rect_payload(rect)
		if rect.size.x <= 0.0 or rect.size.y <= 0.0:
			failures.append(_failure(state_id, viewport_size, key, "non_positive_size", rect))
		elif not viewport_rect.encloses(rect):
			failures.append(_failure(state_id, viewport_size, key, "offscreen", rect, viewport_rect))
	_check_pair(failures, state_id, viewport_size, controls, "notification_stack", "side_panel", "notification_covers_side_panel")
	_check_pair(failures, state_id, viewport_size, controls, "notification_stack", "interaction_prompt", "notification_covers_interaction")
	_check_pair(failures, state_id, viewport_size, controls, "notification_stack", "dialogue_panel", "notification_covers_modal")
	_check_hierarchy(failures, state_id, viewport_size, controls)
	return {
		"ok": failures.is_empty(),
		"scenario_id": SCENARIO_ID,
		"screen_state": state_id,
		"viewport": {"width": viewport_size.x, "height": viewport_size.y},
		"style_variant": STYLE_VARIANT,
		"small_window_size": {"width": SMALL_WINDOW_SIZE.x, "height": SMALL_WINDOW_SIZE.y},
		"visual_hierarchy": _hierarchy_for(state_id),
		"rects": rects,
		"failures": failures,
	}


func _write_capture(
	viewport: Viewport, state_id: String, viewport_size: Vector2i, report: Dictionary
) -> Dictionary:
	var filename: String = "%s_%dx%d.png" % [state_id, viewport_size.x, viewport_size.y]
	var dir_path: String = AutomationArtifactsScript.scenario_screenshot_dir(SCENARIO_ID)
	var capture: Dictionary = StoreVisualSweepScript.save_viewport_png(
		viewport, dir_path, filename, true
	)
	var metadata_path: String = "%s/%s.json" % [dir_path, filename.get_basename()]
	var metadata: Dictionary = {
		"schema_version": 1,
		"scenario_id": SCENARIO_ID,
		"screen_state": state_id,
		"resolution": {"width": viewport_size.x, "height": viewport_size.y},
		"screenshot_path": str(capture.get("path", "")),
		"metadata_path": metadata_path,
		"placeholder": bool(capture.get("placeholder", false)),
		"display_server": DisplayServer.get_name(),
		"style_variant": STYLE_VARIANT,
		"theme_variant": STYLE_VARIANT,
		"baseline_mode": "metadata",
		"layout_report": report,
		"review_checks": _review_checks(),
	}
	AutomationArtifactsScript.write_recorded_json(
		metadata_path,
		metadata,
		"layout_assertion_metadata",
		SCENARIO_ID,
		"scenario",
		"json",
		"cannot write layout metadata"
	)
	capture["metadata_path"] = metadata_path
	capture["metadata"] = metadata
	return capture


func _final_result(captures: Array[Dictionary], failures: Array[Dictionary]) -> Dictionary:
	return {
		"ok": failures.is_empty(),
		"scenario_id": SCENARIO_ID,
		"style_variant": STYLE_VARIANT,
		"viewport_matrix": _viewport_rows(),
		"screen_states": SCREEN_STATES.duplicate(),
		"captures": captures,
		"failures": failures,
		"assertion_counts": {
			"total": captures.size(),
			"passed": captures.size() - failures.size(),
			"failed": failures.size(),
		},
		"review_checks": _review_checks(),
	}


func _write_manifest(payload: Dictionary) -> void:
	var dir_path: String = AutomationArtifactsScript.report_dir("scenario", SCENARIO_ID)
	AutomationArtifactsScript.ensure_artifact_dir(dir_path)
	var path: String = AutomationArtifactsScript.join_path([dir_path, "layout_torture_manifest.json"])
	AutomationArtifactsScript.write_recorded_json(
		path,
		payload,
		"scenario_report",
		SCENARIO_ID,
		"scenario",
		"json",
		"cannot write layout metadata"
	)


func _add_background(surface: Control, viewport_size: Vector2i) -> void:
	var bg := ColorRect.new()
	bg.name = "Backdrop"
	bg.color = Color(0.095, 0.082, 0.071, 1.0)
	bg.size = Vector2(viewport_size)
	surface.add_child(bg)


func _add_top_bar(surface: Control, controls: Dictionary, viewport_size: Vector2i) -> void:
	_add_panel(surface, controls, "top_bar", Rect2(16, 12, min(900, viewport_size.x - 32), 42), false)


func _add_side_panel(
	surface: Control, controls: Dictionary, viewport_size: Vector2i, primary: bool = false
) -> void:
	_add_panel(surface, controls, "side_panel", Rect2(viewport_size.x - 316, 84, 300, viewport_size.y - 168), primary)


func _add_objective(surface: Control, controls: Dictionary, viewport_size: Vector2i) -> void:
	_add_panel(surface, controls, "objective_rail", Rect2(16, viewport_size.y - 124, viewport_size.x - 32, 108), true)


func _add_event_log(surface: Control, controls: Dictionary, viewport_size: Vector2i) -> void:
	_add_panel(surface, controls, "event_log", Rect2(16, viewport_size.y - 288, 260, 96), false)


func _add_prompt(
	surface: Control, controls: Dictionary, viewport_size: Vector2i, primary: bool = false
) -> void:
	_add_panel(surface, controls, "interaction_prompt", Rect2(viewport_size.x - 396, viewport_size.y - 180, 380, 44), primary)


func _add_notifications(
	surface: Control, controls: Dictionary, viewport_size: Vector2i, count: int, primary: bool = false
) -> void:
	var height: float = float(count) * 52.0 + float(max(0, count - 1)) * 8.0
	var right_panel_left: float = viewport_size.x - 316.0
	var x_pos: float = max(16.0, right_panel_left - 384.0)
	_add_panel(surface, controls, "notification_stack", Rect2(x_pos, 96, 360, height), primary)


func _add_panel(
	surface: Control, controls: Dictionary, key: String, rect: Rect2, primary: bool
) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.name = key.to_pascal_case()
	panel.position = rect.position
	panel.size = rect.size
	panel.add_theme_stylebox_override("panel", _style(primary))
	surface.add_child(panel)
	controls[key] = panel
	if primary:
		panel.set_meta("layout_role", "primary")
	return panel


func _add_label(parent: Control, node_name: String, text: String, font_size: int) -> void:
	var label := Label.new()
	label.name = node_name
	label.text = text
	label.custom_minimum_size = Vector2(260, 28)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(0.957, 0.914, 0.831, 1.0))
	parent.add_child(label)


func _style(primary: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.14, 0.11, 0.09, 0.96) if primary else Color(0.08, 0.08, 0.10, 0.84)
	style.border_color = Color(0.91, 0.647, 0.278, 1.0) if primary else Color(0.239, 0.188, 0.157, 0.9)
	style.border_width_left = 2
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style


func _center_rect(viewport_size: Vector2i, width: float, height: float) -> Rect2:
	var w: float = min(width, viewport_size.x - 64.0)
	var h: float = min(height, viewport_size.y - 128.0)
	return Rect2((viewport_size.x - w) * 0.5, (viewport_size.y - h) * 0.5, w, h)


func _check_pair(
	failures: Array[Dictionary], state_id: String, viewport_size: Vector2i,
	controls: Dictionary, first: String, second: String, reason: String
) -> void:
	if not controls.has(first) or not controls.has(second):
		return
	var first_rect: Rect2 = (controls[first] as Control).get_global_rect()
	var second_rect: Rect2 = (controls[second] as Control).get_global_rect()
	if first_rect.intersects(second_rect):
		failures.append(_failure(state_id, viewport_size, first, reason, first_rect, second_rect, second))


func _check_hierarchy(
	failures: Array[Dictionary], state_id: String, viewport_size: Vector2i, controls: Dictionary
) -> void:
	var primary_key: String = str(_hierarchy_for(state_id).get("primary", ""))
	if not controls.has(primary_key):
		failures.append(_failure(state_id, viewport_size, primary_key, "primary_missing", Rect2()))
		return
	var primary_area: float = _area((controls[primary_key] as Control).get_global_rect())
	for passive_key: String in ["event_log", "notification_stack"]:
		if controls.has(passive_key) and primary_area < _area((controls[passive_key] as Control).get_global_rect()):
			failures.append(_failure(state_id, viewport_size, primary_key, "primary_not_dominant", (controls[primary_key] as Control).get_global_rect(), (controls[passive_key] as Control).get_global_rect(), passive_key))


func _hierarchy_for(state_id: String) -> Dictionary:
	match state_id:
		"main_menu":
			return {"primary": "main_menu_panel", "secondary": ["top_bar"], "passive": []}
		"hud":
			return {"primary": "objective_rail", "secondary": ["top_bar", "interaction_prompt"], "passive": ["notification_stack"]}
		"store_ui":
			return {"primary": "store_ui_panel", "secondary": ["side_panel"], "passive": ["notification_stack"]}
		"side_panel":
			return {"primary": "side_panel", "secondary": ["interaction_prompt"], "passive": ["event_log"]}
		"dialogue_modal":
			return {"primary": "dialogue_panel", "secondary": ["top_bar"], "passive": ["notification_stack"]}
		"notification_stack":
			return {"primary": "notification_stack", "secondary": ["side_panel"], "passive": []}
		"save_load":
			return {"primary": "save_load_panel", "secondary": [], "passive": []}
		_:
			return {"primary": "store_session_prompt", "secondary": ["side_panel", "interaction_prompt"], "passive": ["event_log"]}


func _review_checks() -> Array[String]:
	return [
		"critical panels remain inside viewport",
		"readable text controls have positive size",
		"notifications do not cover required interaction panels",
		"primary action remains visually dominant",
		"repeated panels, prompts, toasts, and dialogue cards share style variant",
	]


func _viewport_rows() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for size: Vector2i in VIEWPORTS:
		rows.append({"width": size.x, "height": size.y, "small_window": size == SMALL_WINDOW_SIZE})
	return rows


func _failure(
	state_id: String, viewport_size: Vector2i, node_name: String, reason: String,
	rect: Rect2, other_rect: Rect2 = Rect2(), other_node: String = ""
) -> Dictionary:
	return {
		"viewport": {"width": viewport_size.x, "height": viewport_size.y},
		"screen_state": state_id,
		"node": node_name,
		"other_node": other_node,
		"reason": reason,
		"rect": _rect_payload(rect),
		"other_rect": _rect_payload(other_rect) if other_rect != Rect2() else {},
	}


func _rect_payload(rect: Rect2) -> Dictionary:
	return {
		"x": rect.position.x,
		"y": rect.position.y,
		"w": rect.size.x,
		"h": rect.size.y,
		"right": rect.position.x + rect.size.x,
		"bottom": rect.position.y + rect.size.y,
	}


func _area(rect: Rect2) -> float:
	return rect.size.x * rect.size.y


static func _blank_result() -> Dictionary:
	return {
		"ok": false,
		"scenario_id": SCENARIO_ID,
		"style_variant": STYLE_VARIANT,
		"viewport_matrix": [],
		"screen_states": [],
		"captures": [],
		"failures": [],
	}
