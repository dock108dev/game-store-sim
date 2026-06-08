extends GutTest

const PACKAGE_DOC_PATH := "res://../docs/production/15-alpha-playtest-package.md"
const BUG_LIST_PATH := "res://../docs/production/13-alpha-bug-list.md"
const VALIDATION_DOC_PATH := "res://../docs/production/06-validation.md"
const MANUAL_DOC_PATH := "res://../docs/production/07-current-manual-playtest.md"
const COMPLETION_PLAN_PATH := "res://../docs/production/11-game-completion-plan.md"
const PACKAGE_SCENARIOS_PATH := "res://tests/validation/scenarios/alpha_playtest_package.json"
const MANUAL_CHECKS_PATH := "res://tests/validation/scenarios/manual_checks.json"


func test_alpha_playtest_package_doc_covers_build_script_known_issues_feedback_and_rollback() -> void:
	var package_doc := FileAccess.get_file_as_string(PACKAGE_DOC_PATH)

	assert_string_contains(package_doc, "scripts/validate_godot.sh")
	assert_string_contains(package_doc, "scripts/verify_desktop_export.sh --pack-smoke")
	assert_string_contains(package_doc, "artifacts/builds/desktop/game-store-sim.pck")
	assert_string_contains(package_doc, "Playtest Script")
	assert_string_contains(package_doc, "Known Issues")
	assert_string_contains(package_doc, "Feedback Form")
	assert_string_contains(package_doc, "Rollback Plan")
	assert_string_contains(package_doc, "813fa0b")
	assert_string_contains(package_doc, "Godot export templates")
	assert_string_contains(package_doc, "start-save-quit-relaunch-continue")


func test_alpha_playtest_package_matrix_covers_manual_handoff_steps() -> void:
	var scenarios := _scenario_map(PACKAGE_SCENARIOS_PATH)

	assert_true(scenarios.has("alpha_playtest_package_validation_sync"))
	var sync_scenario: Dictionary = scenarios.get("alpha_playtest_package_validation_sync")
	assert_eq(sync_scenario.get("status"), "automated")
	assert_true(sync_scenario.get("critical"))
	assert_string_contains(str(sync_scenario.get("evidence", "")), "test_alpha_playtest_package_validation_sync.gd")


func test_alpha_playtest_manual_checks_include_external_package_review() -> void:
	var manual_checks := _scenario_map(MANUAL_CHECKS_PATH)
	var required_ids := [
		"alpha_playtest_package_artifact_review",
		"alpha_external_playtest_run",
		"alpha_feedback_triage_review",
	]

	for scenario_id in required_ids:
		assert_true(manual_checks.has(scenario_id), "missing manual check %s" % scenario_id)
		var scenario: Dictionary = manual_checks.get(scenario_id)
		assert_eq(scenario.get("status"), "manual", scenario_id)
		assert_eq(scenario.get("owner"), "manual QA", scenario_id)
		assert_false(str(scenario.get("reason", "")).is_empty(), scenario_id)


func test_alpha_playtest_package_docs_name_stop_13_6_sync() -> void:
	var bug_list := FileAccess.get_file_as_string(BUG_LIST_PATH)
	var validation_doc := FileAccess.get_file_as_string(VALIDATION_DOC_PATH)
	var manual_doc := FileAccess.get_file_as_string(MANUAL_DOC_PATH)
	var completion_plan := FileAccess.get_file_as_string(COMPLETION_PLAN_PATH)

	assert_string_contains(bug_list, "Stop 13.6 external playtest package: done")
	assert_string_contains(validation_doc, "Alpha playtest package is complete through Stop 13.6")
	assert_string_contains(manual_doc, "Alpha playtest package is implemented through Stop 13.6")
	assert_string_contains(completion_plan, "Stop 13.6: External playtest package. Done")


func _scenario_map(path: String) -> Dictionary:
	var data := _load_json(path)
	var scenarios: Array = data.get("ui_scenarios", [])
	var by_id := {}
	for scenario in scenarios:
		by_id[str(scenario.get("id", ""))] = scenario
	return by_id


func _load_json(path: String) -> Dictionary:
	var text := FileAccess.get_file_as_string(path)
	assert_false(text.is_empty(), path)
	var parsed = JSON.parse_string(text)
	assert_true(parsed is Dictionary, path)
	return parsed as Dictionary
