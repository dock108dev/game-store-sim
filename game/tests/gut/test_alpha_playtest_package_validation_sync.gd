extends GutTest

const STATUS_PATH := "res://../docs/status.json"
const BACKLOG_PATH := "res://../docs/production/04-backlog.md"
const QA_README_PATH := "res://../docs/qa/README.md"
const PACKAGE_SCENARIOS_PATH := "res://tests/validation/scenarios/alpha_playtest_package.json"
const MANUAL_CHECKS_PATH := "res://tests/validation/scenarios/manual_checks.json"


func test_external_package_docs_are_removed_until_owner_visual_review_approves() -> void:
	var status := _load_json(STATUS_PATH)
	var backlog := FileAccess.get_file_as_string(BACKLOG_PATH)
	var qa_readme := FileAccess.get_file_as_string(QA_README_PATH)

	assert_eq(status.get("playtest_state"), "paused_until_owner_visual_review")
	assert_string_contains(backlog, "External alpha/beta packaging")
	assert_string_contains(qa_readme, "not active until owner visual review approves")
	assert_false(FileAccess.file_exists("res://../docs/production/15-alpha-playtest-package.md"))
	assert_false(FileAccess.file_exists("res://../docs/qa/release-package-check.md"))


func test_legacy_package_validation_scenarios_remain_structured() -> void:
	var scenarios := _scenario_map(PACKAGE_SCENARIOS_PATH)

	assert_true(scenarios.has("alpha_playtest_package_validation_sync"))
	var sync_scenario: Dictionary = scenarios.get("alpha_playtest_package_validation_sync")
	assert_eq(sync_scenario.get("status"), "automated")
	assert_true(sync_scenario.get("critical"))
	assert_string_contains(str(sync_scenario.get("evidence", "")), "test_alpha_playtest_package_validation_sync.gd")


func test_manual_package_checks_remain_paused_inputs() -> void:
	var manual_checks := _scenario_map(MANUAL_CHECKS_PATH)
	for scenario_id in ["alpha_playtest_package_artifact_review", "alpha_external_playtest_run", "alpha_feedback_triage_review"]:
		assert_true(manual_checks.has(scenario_id), "missing manual check %s" % scenario_id)
		var scenario: Dictionary = manual_checks.get(scenario_id)
		assert_eq(scenario.get("status"), "manual", scenario_id)
		assert_eq(scenario.get("owner"), "manual QA", scenario_id)


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
