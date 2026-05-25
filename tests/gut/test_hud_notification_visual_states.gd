extends GutTest

const _SurfaceScene: PackedScene = preload(
	"res://tests/visual/hud_notification_visual_states.tscn"
)
const _SurfaceScript: GDScript = preload(
	"res://tests/visual/hud_notification_visual_state_scene.gd"
)
const _Artifacts: GDScript = preload(
	"res://tests/visual/hud_visual_state_artifacts.gd"
)

const _TEST_ROOT: String = "user://hud_notification_visual_state_test"

var _saved_artifact_env: String = ""
var _saved_workspace_env: String = ""


func before_each() -> void:
	_saved_artifact_env = OS.get_environment("MALLCORE_ARTIFACT_DIR")
	_saved_workspace_env = OS.get_environment("GITHUB_WORKSPACE")
	OS.set_environment("MALLCORE_ARTIFACT_DIR", _TEST_ROOT)
	OS.set_environment("GITHUB_WORKSPACE", "")


func after_each() -> void:
	OS.set_environment("MALLCORE_ARTIFACT_DIR", _saved_artifact_env)
	OS.set_environment("GITHUB_WORKSPACE", _saved_workspace_env)


func test_visual_surface_is_named_for_automation() -> void:
	var fixture: Dictionary = await _make_surface("normal", Vector2i(1280, 720))
	var surface := fixture.get("surface") as Control
	assert_eq(surface.get_meta("visual_surface_id", ""), "hud_notification_states")
	assert_eq(surface.get_meta("scenario_target_kind", ""), "visual_test_surface")


func test_state_registry_and_resolution_matrix_cover_required_surfaces() -> void:
	for state_id: String in [
		"normal",
		"low_money",
		"many_notifications",
		"stock_warning",
		"tutorial_active",
		"side_panel_open",
		"store_ui_open",
		"dialogue_plus_notification",
		"small_resolution",
		"ultrawide_resolution",
	]:
		assert_true(_SurfaceScript.STATE_IDS.has(state_id), "Missing visual state: %s" % state_id)
	for size: Vector2i in [
		Vector2i(1024, 576),
		Vector2i(1280, 720),
		Vector2i(1600, 900),
		Vector2i(1920, 1080),
		Vector2i(2560, 1080),
	]:
		assert_true(_SurfaceScript.RESOLUTION_MATRIX.has(size), "Missing viewport: %s" % [size])


func test_baseline_manifest_matches_surface_registry() -> void:
	var manifest: Dictionary = _Artifacts.baseline_manifest()
	assert_true(bool(manifest.get("ok", false)), str(manifest.get("error", "")))
	assert_eq(str(manifest.get("visual_surface_id", "")), "hud_notification_states")
	assert_eq(str(manifest.get("mode", "")), "soft")
	var states: Array = manifest.get("states", []) as Array
	for state_id: String in _SurfaceScript.STATE_IDS:
		assert_true(states.has(state_id), "Baseline manifest missing state: %s" % state_id)
	var matrix: Array = manifest.get("resolution_matrix", []) as Array
	for size: Vector2i in _SurfaceScript.RESOLUTION_MATRIX:
		assert_true(
			_matrix_has_size(matrix, size),
			"Baseline manifest missing resolution: %dx%d" % [size.x, size.y]
		)


func test_all_states_pass_layout_assertions_across_resolution_matrix() -> void:
	for state_id: String in _SurfaceScript.STATE_IDS:
		for size: Vector2i in _SurfaceScript.RESOLUTION_MATRIX:
			var fixture: Dictionary = await _make_surface(state_id, size)
			var report: Dictionary = fixture.get("report", {}) as Dictionary
			assert_true(
				bool(report.get("ok", false)),
				"Layout failed: %s" % JSON.stringify(report.get("failures", []))
			)


func test_visual_snapshots_write_metadata_for_states_and_resolution_matrix() -> void:
	var captures: Array[Dictionary] = []
	for state_id: String in _SurfaceScript.STATE_IDS:
		captures.append({"state": state_id, "size": _default_size(state_id)})
	for size: Vector2i in _SurfaceScript.RESOLUTION_MATRIX:
		captures.append({"state": "normal", "size": size})
	for spec: Dictionary in captures:
		var state_id: String = str(spec.get("state", "normal"))
		var size: Vector2i = spec.get("size", Vector2i(1280, 720)) as Vector2i
		var fixture: Dictionary = await _make_surface(state_id, size)
		var viewport := fixture.get("viewport") as Viewport
		var report: Dictionary = fixture.get("report", {}) as Dictionary
		var result: Dictionary = _Artifacts.capture_state(
			viewport, state_id, size, report, true
		)
		assert_true(bool(result.get("ok", false)), str(result.get("error", "")))
		assert_true(FileAccess.file_exists(str(result.get("path", ""))))
		assert_true(FileAccess.file_exists(str(result.get("metadata_path", ""))))
		var metadata: Dictionary = _read_json(str(result.get("metadata_path", "")))
		assert_eq(str(metadata.get("visual_surface_id", "")), "hud_notification_states")
		assert_eq(str(metadata.get("state_id", "")), state_id)
		assert_eq(int((metadata.get("resolution", {}) as Dictionary).get("width", 0)), size.x)
		assert_eq(int((metadata.get("resolution", {}) as Dictionary).get("height", 0)), size.y)
		assert_true((metadata.get("render_environment", {}) as Dictionary).has("display_server"))
		assert_eq(bool(metadata.get("placeholder", false)), DisplayServer.get_name() == "headless")
		assert_eq(str((metadata.get("baseline", {}) as Dictionary).get("mode", "")), "soft")
		assert_true(bool((metadata.get("layout_report", {}) as Dictionary).get("ok", false)))


func test_failure_payload_includes_viewport_rects_and_reason() -> void:
	var fixture: Dictionary = await _make_surface("stock_warning", Vector2i(1280, 720))
	var surface := fixture.get("surface") as Control
	var stack := surface.get_node("HUDVisualStateSurface/NotificationStack") as Control
	var right_panel := surface.get_node("HUDVisualStateSurface/RightPanel") as Control
	stack.position = right_panel.position
	var report: Dictionary = surface.call("layout_report") as Dictionary
	assert_false(bool(report.get("ok", true)))
	var failures: Array = report.get("failures", []) as Array
	var overlap: Dictionary = _first_failure_with_reason(failures, "overlaps_right_panel")
	assert_false(overlap.is_empty(), "Expected right-panel overlap failure")
	for key: String in ["node", "other_node", "state_id", "viewport", "rect", "other_rect", "reason"]:
		assert_true(overlap.has(key), "Failure payload missing key: %s" % key)
	assert_eq(str(overlap.get("state_id", "")), "stock_warning")
	assert_eq(str(overlap.get("other_node", "")), "right_panel")


func test_style_contract_uses_consistent_panel_language() -> void:
	for state_id: String in _SurfaceScript.STATE_IDS:
		var fixture: Dictionary = await _make_surface(state_id, _default_size(state_id))
		var surface := fixture.get("surface") as Control
		for panel: PanelContainer in _panel_containers(surface):
			var style := panel.get_theme_stylebox("panel") as StyleBoxFlat
			assert_not_null(style, "Panel must expose a StyleBoxFlat: %s" % panel.name)
			if style == null:
				continue
			assert_eq(style.corner_radius_top_left, _SurfaceScript.PANEL_RADIUS)
			assert_eq(style.corner_radius_top_right, _SurfaceScript.PANEL_RADIUS)
			assert_eq(style.corner_radius_bottom_left, _SurfaceScript.PANEL_RADIUS)
			assert_eq(style.corner_radius_bottom_right, _SurfaceScript.PANEL_RADIUS)


func test_many_notifications_keep_reading_order_and_safe_lane() -> void:
	var fixture: Dictionary = await _make_surface("many_notifications", Vector2i(1280, 720))
	var surface := fixture.get("surface") as Control
	var stack := surface.get_node("HUDVisualStateSurface/NotificationStack") as VBoxContainer
	assert_lte(stack.get_child_count(), 5, "Notification stack must stay capped")
	var previous_y: float = -1.0
	for child: Node in stack.get_children():
		var control := child as Control
		assert_gt(control.get_global_rect().position.y, previous_y)
		previous_y = control.get_global_rect().position.y
	var rect := stack.get_global_rect()
	var right_panel_left: float = 1280.0 - _SurfaceScript.RIGHT_PANEL_INSET - _SurfaceScript.RIGHT_PANEL_WIDTH
	assert_lte(
		rect.position.x + rect.size.x,
		right_panel_left - _SurfaceScript.TOAST_RIGHT_PANEL_GAP,
		"Notification stack must preserve the right-panel safe lane"
	)


func test_state_hierarchy_markers_distinguish_warning_and_tutorial_states() -> void:
	var normal: Dictionary = (await _make_surface("normal", Vector2i(1280, 720))).get("report", {})
	var low: Dictionary = (await _make_surface("low_money", Vector2i(1280, 720))).get("report", {})
	var stock: Dictionary = (await _make_surface("stock_warning", Vector2i(1280, 720))).get("report", {})
	var tutorial: Dictionary = (await _make_surface("tutorial_active", Vector2i(1280, 720))).get("report", {})
	assert_false((normal.get("rects", {}) as Dictionary).has("low_money_banner"))
	assert_true((low.get("rects", {}) as Dictionary).has("low_money_banner"))
	assert_true((stock.get("rects", {}) as Dictionary).has("right_panel"))
	assert_true((tutorial.get("rects", {}) as Dictionary).has("tutorial_bar"))


func _make_surface(state_id: String, size: Vector2i) -> Dictionary:
	var viewport := SubViewport.new()
	viewport.name = "VisualStateViewport_%s_%dx%d" % [state_id, size.x, size.y]
	viewport.size = size
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child_autofree(viewport)
	var surface := _SurfaceScene.instantiate() as Control
	viewport.add_child(surface)
	var initial_report: Dictionary = surface.call("render_state", state_id, size) as Dictionary
	await get_tree().process_frame
	await get_tree().process_frame
	var final_report: Dictionary = initial_report
	if bool(initial_report.get("ok", false)):
		final_report = surface.call("layout_report") as Dictionary
	return {
		"viewport": viewport,
		"surface": surface,
		"report": final_report,
	}


func _default_size(state_id: String) -> Vector2i:
	return _SurfaceScript.DEFAULT_STATE_RESOLUTIONS.get(state_id, Vector2i(1280, 720)) as Vector2i


func _matrix_has_size(matrix: Array, size: Vector2i) -> bool:
	for entry: Variant in matrix:
		if entry is not Dictionary:
			continue
		var row := entry as Dictionary
		if int(row.get("width", 0)) == size.x and int(row.get("height", 0)) == size.y:
			return true
	return false


func _read_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	assert_not_null(file, "JSON file must open: %s" % path)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	assert_true(parsed is Dictionary, "JSON payload must be an object")
	if parsed is Dictionary:
		return parsed as Dictionary
	return {}


func _first_failure_with_reason(failures: Array, reason: String) -> Dictionary:
	for failure: Variant in failures:
		if failure is Dictionary and str((failure as Dictionary).get("reason", "")) == reason:
			return failure as Dictionary
	return {}


func _panel_containers(root: Node) -> Array[PanelContainer]:
	var panels: Array[PanelContainer] = []
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		if node is PanelContainer:
			panels.append(node as PanelContainer)
		for child: Node in node.get_children():
			stack.append(child)
	return panels
