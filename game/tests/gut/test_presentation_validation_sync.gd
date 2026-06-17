extends GutTest

const PRESENTATION_SCENARIOS_PATH := "res://tests/validation/scenarios/presentation.json"
const MANUAL_CHECKS_PATH := "res://tests/validation/scenarios/manual_checks.json"
const VALIDATION_DOC_PATH := "res://../docs/production/06-validation.md"
const SCREENSHOT_REVIEW_PATH := "res://../docs/qa/screenshot-review.md"


func test_presentation_validation_matrix_covers_audio_vfx_and_camera_stops() -> void:
	var scenarios := _scenario_map(PRESENTATION_SCENARIOS_PATH)
	var required_ids := [
		"store_ambience_catalog",
		"store_ambience_scene_players",
		"interaction_audio_catalog",
		"interaction_audio_player_wiring",
		"customer_audio_placeholder_catalog",
		"customer_audio_scene_profiles",
		"presentation_microfeedback_catalog",
		"presentation_microfeedback_player_wiring",
		"camera_feel_comfort_bounds",
		"camera_feel_runtime_motion",
		"camera_feel_workstation_focus",
		"presentation_validation_sync_audit",
	]

	for scenario_id in required_ids:
		assert_true(scenarios.has(scenario_id), "missing scenario %s" % scenario_id)
		var scenario: Dictionary = scenarios.get(scenario_id)
		assert_eq(scenario.get("status"), "automated", scenario_id)
		assert_true(str(scenario.get("evidence", "")).begins_with("res://tests/gut/"), scenario_id)


func test_presentation_manual_checks_stay_secondary_to_design_reset_gate() -> void:
	var scenarios := _scenario_map(MANUAL_CHECKS_PATH)
	var validation_doc := FileAccess.get_file_as_string(VALIDATION_DOC_PATH)
	var screenshot_review := FileAccess.get_file_as_string(SCREENSHOT_REVIEW_PATH)

	for scenario_id in ["store_ambience_mix_readability", "camera_feel_motion_comfort", "presentation_milestone_11_review"]:
		assert_true(scenarios.has(scenario_id), "missing manual check %s" % scenario_id)
		var scenario: Dictionary = scenarios.get(scenario_id)
		assert_eq(scenario.get("status"), "manual", scenario_id)
		assert_eq(scenario.get("owner"), "manual QA", scenario_id)

	assert_string_contains(validation_doc, "design reset")
	assert_string_contains(screenshot_review, "The question is not whether the project is mechanically complete")


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
