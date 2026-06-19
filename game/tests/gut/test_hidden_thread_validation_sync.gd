extends GutTest

const HIDDEN_THREAD_SCENARIOS_PATH := "res://tests/validation/scenarios/hidden_thread.json"
const MANUAL_CHECKS_PATH := "res://tests/validation/scenarios/manual_checks.json"
const CURRENT_STATE_PATH := "res://../docs/CURRENT_STATE.md"
const STATUS_PATH := "res://../docs/status.json"


func test_hidden_thread_validation_matrix_covers_flags_dedupe_persistence_and_optionality() -> void:
	var scenarios := _scenario_map(HIDDEN_THREAD_SCENARIOS_PATH)
	var required_ids := [
		"suspicious_event_log_records_flags",
		"suspicious_event_log_deduplicates_ids",
		"suspicious_event_log_normalizes_invalid_input",
		"hidden_choice_save_load",
		"hidden_consequence_save_load",
		"hidden_optionality_session_guard",
		"hidden_optionality_records_tab",
	]

	for scenario_id in required_ids:
		assert_true(scenarios.has(scenario_id), "missing scenario %s" % scenario_id)
		var scenario: Dictionary = scenarios.get(scenario_id)
		assert_eq(scenario.get("status"), "automated", scenario_id)
		assert_true(str(scenario.get("evidence", "")).begins_with("res://tests/gut/"), scenario_id)


func test_hidden_thread_manual_checks_remain_structured_but_not_visual_blockers() -> void:
	var scenarios := _scenario_map(MANUAL_CHECKS_PATH)
	var current_state := FileAccess.get_file_as_string(CURRENT_STATE_PATH)
	var status := _load_json(STATUS_PATH)

	for scenario_id in ["hidden_clue_surface_readability", "hidden_choice_path_readability", "hidden_thread_optionality_guard"]:
		assert_true(scenarios.has(scenario_id), "missing manual check %s" % scenario_id)
		var scenario: Dictionary = scenarios.get(scenario_id)
		assert_eq(scenario.get("status"), "manual", scenario_id)
		assert_eq(scenario.get("owner"), "manual QA", scenario_id)

	assert_string_contains(current_state, "optional hidden-thread hooks")
	assert_true(status.get("playable_state", {}).get("implemented_systems", []).has("hidden_thread_hooks"))


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
