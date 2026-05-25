extends GutTest

const FLOW_SCENE: PackedScene = preload("res://tests/visual/layout_torture_flow.tscn")
const FLOW_SCRIPT: GDScript = preload("res://tests/visual/layout_torture_flow.gd")
const TEST_ROOT: String = "user://layout_torture_flow_test"

var _saved_artifact_env: String = ""
var _saved_workspace_env: String = ""


func before_each() -> void:
	_saved_artifact_env = OS.get_environment("MALLCORE_ARTIFACT_DIR")
	_saved_workspace_env = OS.get_environment("GITHUB_WORKSPACE")
	OS.set_environment("MALLCORE_ARTIFACT_DIR", TEST_ROOT)
	OS.set_environment("GITHUB_WORKSPACE", "")


func after_each() -> void:
	OS.set_environment("MALLCORE_ARTIFACT_DIR", _saved_artifact_env)
	OS.set_environment("GITHUB_WORKSPACE", _saved_workspace_env)


func test_viewport_matrix_matches_required_sizes() -> void:
	assert_true(FLOW_SCRIPT.VIEWPORTS.has(Vector2i(1280, 720)))
	assert_true(FLOW_SCRIPT.VIEWPORTS.has(Vector2i(1920, 1080)))
	assert_true(FLOW_SCRIPT.VIEWPORTS.has(Vector2i(2560, 1440)))
	assert_true(FLOW_SCRIPT.VIEWPORTS.has(FLOW_SCRIPT.SMALL_WINDOW_SIZE))


func test_screen_states_cover_major_runtime_surfaces() -> void:
	for state_id: String in [
		"main_menu",
		"hud",
		"store_ui",
		"side_panel",
		"dialogue_modal",
		"notification_stack",
		"save_load",
		"store_session_prompt",
	]:
		assert_true(FLOW_SCRIPT.SCREEN_STATES.has(state_id), "Missing state: %s" % state_id)


func test_flow_writes_screenshots_and_layout_metadata() -> void:
	var flow := FLOW_SCENE.instantiate() as Control
	add_child_autofree(flow)
	await _wait_for_flow(flow)
	assert_true(flow.call("get_run_ok"), JSON.stringify(flow.call("get_run_result")))
	var result: Dictionary = flow.call("get_run_result") as Dictionary
	assert_eq(str(result.get("style_variant", "")), FLOW_SCRIPT.STYLE_VARIANT)
	var captures: Array = result.get("captures", []) as Array
	assert_eq(captures.size(), FLOW_SCRIPT.VIEWPORTS.size() * FLOW_SCRIPT.SCREEN_STATES.size())
	var sample: Dictionary = captures[0] as Dictionary
	assert_true(FileAccess.file_exists(str(sample.get("path", ""))))
	assert_true(FileAccess.file_exists(str(sample.get("metadata_path", ""))))
	var metadata: Dictionary = _read_json(str(sample.get("metadata_path", "")))
	assert_eq(str(metadata.get("scenario_id", "")), FLOW_SCRIPT.SCENARIO_ID)
	assert_eq(str(metadata.get("style_variant", "")), FLOW_SCRIPT.STYLE_VARIANT)
	assert_true((metadata.get("layout_report", {}) as Dictionary).has("failures"))
	assert_true((metadata.get("review_checks", []) as Array).has("primary action remains visually dominant"))


func test_failure_payload_names_viewport_state_rects_and_reason() -> void:
	var flow := FLOW_SCENE.instantiate() as Control
	add_child_autofree(flow)
	var fixture: Dictionary = flow.call("_make_fixture", "notification_stack", Vector2i(1280, 720))
	var controls: Dictionary = fixture.get("controls", {}) as Dictionary
	(controls["notification_stack"] as Control).position = (controls["side_panel"] as Control).position
	var report: Dictionary = flow.call(
		"_layout_report", "notification_stack", Vector2i(1280, 720), fixture
	) as Dictionary
	var failures: Array = report.get("failures", []) as Array
	var overlap: Dictionary = _first_reason(failures, "notification_covers_side_panel")
	assert_false(overlap.is_empty(), JSON.stringify(failures))
	for key: String in ["viewport", "screen_state", "node", "other_node", "rect", "other_rect", "reason"]:
		assert_true(overlap.has(key), "Missing key: %s" % key)


func _wait_for_flow(flow: Control) -> void:
	for _i: int in range(180):
		if bool(flow.call("is_complete")):
			return
		await get_tree().process_frame
	fail_test("layout torture flow did not complete")


func _first_reason(failures: Array, reason: String) -> Dictionary:
	for failure: Variant in failures:
		var row := failure as Dictionary
		if str(row.get("reason", "")) == reason:
			return row
	return {}


func _read_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	assert_not_null(file, "JSON must open: %s" % path)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	assert_true(parsed is Dictionary)
	return parsed as Dictionary if parsed is Dictionary else {}
