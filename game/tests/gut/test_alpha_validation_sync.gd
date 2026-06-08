extends GutTest

const VALIDATION_SYNC_SCENARIOS_PATH := "res://tests/validation/scenarios/alpha_validation_sync.json"
const VALIDATION_DOC_PATH := "res://../docs/production/06-validation.md"
const MANUAL_DOC_PATH := "res://../docs/production/07-current-manual-playtest.md"
const COMPLETION_PLAN_PATH := "res://../docs/production/11-game-completion-plan.md"
const BUG_LIST_PATH := "res://../docs/production/13-alpha-bug-list.md"
const BACKLOG_PATH := "res://../docs/production/04-backlog.md"
const PACKAGE_DOC_PATH := "res://../docs/production/15-alpha-playtest-package.md"


func test_alpha_validation_sync_scenario_matrix_is_automated() -> void:
	var scenarios := _scenario_map(VALIDATION_SYNC_SCENARIOS_PATH)
	var required_ids := [
		"alpha_validation_sync_audit",
		"alpha_validation_gate_snapshot",
		"alpha_manual_checklist_sync_audit",
	]

	for scenario_id in required_ids:
		assert_true(scenarios.has(scenario_id), "missing alpha validation scenario %s" % scenario_id)
		var scenario: Dictionary = scenarios.get(scenario_id)
		assert_eq(scenario.get("status"), "automated", scenario_id)
		assert_true(scenario.get("critical"), scenario_id)
		assert_string_contains(str(scenario.get("evidence", "")), "test_alpha_validation_sync.gd")


func test_alpha_validation_sync_docs_name_stop_13_7() -> void:
	var validation_doc := FileAccess.get_file_as_string(VALIDATION_DOC_PATH)
	var manual_doc := FileAccess.get_file_as_string(MANUAL_DOC_PATH)
	var completion_plan := FileAccess.get_file_as_string(COMPLETION_PLAN_PATH)
	var bug_list := FileAccess.get_file_as_string(BUG_LIST_PATH)
	var backlog := FileAccess.get_file_as_string(BACKLOG_PATH)

	assert_string_contains(validation_doc, "Alpha validation sync is complete through Stop 13.7")
	assert_string_contains(manual_doc, "Alpha validation sync is implemented through Stop 13.7")
	assert_string_contains(completion_plan, "Stop 13.7: Alpha validation sync. Done")
	assert_string_contains(bug_list, "Stop 13.7 alpha validation sync: done")
	assert_string_contains(backlog, "Alpha hardening is complete through Stop 13.7")


func test_alpha_validation_snapshot_records_current_gate_outputs() -> void:
	var validation_doc := FileAccess.get_file_as_string(VALIDATION_DOC_PATH)
	var manual_doc := FileAccess.get_file_as_string(MANUAL_DOC_PATH)
	var completion_plan := FileAccess.get_file_as_string(COMPLETION_PLAN_PATH)
	var bug_list := FileAccess.get_file_as_string(BUG_LIST_PATH)

	for doc in [validation_doc, manual_doc, completion_plan, bug_list]:
		assert_string_contains(doc, "514 GUT tests")
		assert_string_contains(doc, "476/594")
		assert_string_contains(doc, "51/51")
		assert_string_contains(doc, "3 active")
		assert_string_contains(doc, "33 catalog products")

	assert_string_contains(validation_doc, "Desktop pack export smoke passed")
	assert_string_contains(completion_plan, "desktop pack smoke")


func test_completion_handoff_points_to_external_playtest_not_finished_milestones() -> void:
	var completion_plan := FileAccess.get_file_as_string(COMPLETION_PLAN_PATH)
	var backlog := FileAccess.get_file_as_string(BACKLOG_PATH)
	var decision_log := FileAccess.get_file_as_string("res://../docs/production/03-decision-log.md")

	assert_string_contains(completion_plan, "## Current Handoff")
	assert_string_contains(completion_plan, "Milestones 1 through 13 are implemented, validated, committed, and pushed")
	assert_string_contains(completion_plan, "human external playtest and feedback-triage pass")
	assert_string_contains(completion_plan, "Human approval still requires the external playtest/manual window pass")
	assert_false(completion_plan.contains("The next implementation phase should begin with Milestone 1"))

	assert_string_contains(backlog, "Store environment production pass. Done through Milestone 2.")
	assert_string_contains(backlog, "Product and content pipeline. Done through Milestone 6.")
	assert_string_contains(backlog, "Alpha hardening. Complete through Stop 13.7")
	assert_false(backlog.contains("- Player-facing save/load slot UI."))
	assert_false(backlog.contains("- Full audio, animation, VFX, and art-production pass."))
	assert_string_contains(decision_log, "Milestones 1 through 13")


func test_alpha_manual_checklist_covers_all_alpha_focus_sections() -> void:
	var manual_doc := FileAccess.get_file_as_string(MANUAL_DOC_PATH)
	var package_doc := FileAccess.get_file_as_string(PACKAGE_DOC_PATH)

	var required_sections := [
		"Alpha Bug Triage Focus",
		"Alpha Performance Focus",
		"Alpha Regression Focus",
		"Alpha Scene Readability Focus",
		"Alpha Content Copy Focus",
		"Alpha Balance Focus",
		"Alpha Playtest Package Focus",
		"Alpha Validation Sync Focus",
	]

	for section in required_sections:
		assert_string_contains(manual_doc, section)

	assert_string_contains(package_doc, "scripts/validate_godot.sh")
	assert_string_contains(package_doc, "Feedback Form")
	assert_string_contains(manual_doc, "Every implementation summary should say whether these were checked, skipped, or not relevant.")


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
