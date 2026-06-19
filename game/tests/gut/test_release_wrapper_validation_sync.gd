extends GutTest

const RELEASE_WRAPPER_SCENARIOS_PATH := "res://tests/validation/scenarios/release_wrapper.json"
const DESKTOP_EXPORT_TOOL_PATH := "res://tests/validation/tool_checks/desktop_export.json"
const STATUS_PATH := "res://../docs/status.json"
const QA_README_PATH := "res://../docs/qa/README.md"


func test_release_wrapper_validation_matrix_remains_structured_but_external_release_is_paused() -> void:
	var scenarios := _scenario_map(RELEASE_WRAPPER_SCENARIOS_PATH)
	var status := _load_json(STATUS_PATH)
	var qa_readme := FileAccess.get_file_as_string(QA_README_PATH)

	for scenario_id in ["release_pack_artifact_review", "release_binary_export_template_review", "release_from_build_save_load_review"]:
		assert_true(scenarios.has(scenario_id), "missing manual release wrapper scenario %s" % scenario_id)
		var scenario: Dictionary = scenarios.get(scenario_id)
		assert_eq(scenario.get("status"), "manual", scenario_id)
		assert_eq(scenario.get("owner"), "manual QA", scenario_id)

	assert_true(scenarios.has("release_wrapper_validation_sync_audit"))
	assert_eq(status.get("playtest_state"), "paused_until_owner_visual_review")
	assert_string_contains(qa_readme, "External playtest and release-package checks are intentionally not active")


func test_release_wrapper_tool_manifest_covers_desktop_export_smoke() -> void:
	var tools := _tool_map(DESKTOP_EXPORT_TOOL_PATH)
	assert_true(tools.has("desktop_export_pack_smoke"))
	var tool: Dictionary = tools.get("desktop_export_pack_smoke")

	assert_eq(tool.get("status"), "active")
	assert_eq(tool.get("command"), "scripts/verify_desktop_export.sh --pack-smoke")
	var covered_paths: Array = tool.get("covered_paths", [])
	var requirements: Array = tool.get("requirements", [])
	assert_true(covered_paths.has("game/export_presets.cfg"))
	assert_true(covered_paths.has("scripts/verify_desktop_export.sh"))
	assert_true(requirements.has("The exported pack boots through Godot without editor-only project paths."))


func _scenario_map(path: String) -> Dictionary:
	var data := _load_json(path)
	var scenarios: Array = data.get("ui_scenarios", [])
	var by_id := {}
	for scenario in scenarios:
		by_id[str(scenario.get("id", ""))] = scenario
	return by_id


func _tool_map(path: String) -> Dictionary:
	var data := _load_json(path)
	var tools: Array = data.get("validation_tools", [])
	var by_id := {}
	for tool in tools:
		by_id[str(tool.get("id", ""))] = tool
	return by_id


func _load_json(path: String) -> Dictionary:
	var text := FileAccess.get_file_as_string(path)
	assert_false(text.is_empty(), path)
	var parsed = JSON.parse_string(text)
	assert_true(parsed is Dictionary, path)
	return parsed as Dictionary
