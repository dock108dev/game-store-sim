extends GutTest

const HIDDEN_THREAD_SCENARIOS_PATH := "res://tests/validation/scenarios/hidden_thread.json"
const MANUAL_CHECKS_PATH := "res://tests/validation/scenarios/manual_checks.json"
const VALIDATION_DOC_PATH := "res://../docs/production/06-validation.md"
const MANUAL_DOC_PATH := "res://../docs/production/07-current-manual-playtest.md"
const COMPLETION_PLAN_PATH := "res://../docs/production/11-game-completion-plan.md"


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


func test_hidden_thread_manual_checks_cover_clue_readability_and_nonblocking_play() -> void:
	var scenarios := _scenario_map(MANUAL_CHECKS_PATH)
	var required_ids := [
		"hidden_clue_surface_readability",
		"hidden_choice_path_readability",
		"hidden_consequence_readability",
		"hidden_thread_optionality_guard",
		"hidden_thread_flags_invisible",
		"mismatched_serial_discoverability",
		"supplier_message_readability",
		"evidence_storage_invisible",
	]

	for scenario_id in required_ids:
		assert_true(scenarios.has(scenario_id), "missing manual check %s" % scenario_id)
		var scenario: Dictionary = scenarios.get(scenario_id)
		assert_eq(scenario.get("status"), "manual", scenario_id)
		assert_false(str(scenario.get("reason", "")).is_empty(), scenario_id)
		assert_eq(scenario.get("owner"), "manual QA", scenario_id)


func test_hidden_thread_validation_docs_name_stop_10_6_sync() -> void:
	var validation_doc := FileAccess.get_file_as_string(VALIDATION_DOC_PATH)
	var manual_doc := FileAccess.get_file_as_string(MANUAL_DOC_PATH)
	var completion_plan := FileAccess.get_file_as_string(COMPLETION_PLAN_PATH)

	assert_string_contains(validation_doc, "Hidden-thread validation sync is complete through Stop 10.6")
	assert_string_contains(manual_doc, "Hidden-thread validation sync is implemented through Stop 10.6")
	assert_string_contains(completion_plan, "Stop 10.6: Hidden-thread validation sync. Done")


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
