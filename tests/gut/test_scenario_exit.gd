## Tests for the automation scenario exit-status owner.
extends GutTest


func after_each() -> void:
	ScenarioExit.reset()


func test_unarmed_failure_calls_are_inert() -> void:
	ScenarioExit.reset()

	ScenarioExit.fail(
		ScenarioExit.BOOT_FAILURE,
		&"boot_failed",
		"boot failed"
	)

	assert_false(ScenarioExit.is_armed())
	assert_false(ScenarioExit.has_failed())
	assert_eq(ScenarioExit.get_exit_code(), ScenarioExit.OK)
	assert_true(ScenarioExit.get_failures().is_empty())


func test_repeated_failures_preserve_first_code_and_all_records() -> void:
	ScenarioExit.arm({"scenario_id": "unit_status", "emit_logs": false})

	ScenarioExit.fail(
		ScenarioExit.SAVE_LOAD_FAILURE,
		&"save_round_trip_failed",
		"save mismatch",
		{"slot": 1}
	)
	ScenarioExit.fail(
		ScenarioExit.UI_FAILURE,
		&"button_missing",
		"expected button was absent",
		{"screen": "main_menu"}
	)

	var failures: Array[Dictionary] = ScenarioExit.get_failures()
	assert_true(ScenarioExit.has_failed())
	assert_eq(ScenarioExit.get_exit_code(), ScenarioExit.SAVE_LOAD_FAILURE)
	assert_eq(failures.size(), 2)
	assert_eq(failures[0].get("code", 0), ScenarioExit.SAVE_LOAD_FAILURE)
	assert_eq(failures[1].get("code", 0), ScenarioExit.UI_FAILURE)


func test_success_cannot_overwrite_recorded_failure_code() -> void:
	ScenarioExit.arm({"scenario_id": "unit_status", "emit_logs": false})
	ScenarioExit.fail(
		ScenarioExit.TIMEOUT,
		&"scenario_timeout",
		"scenario exceeded timeout"
	)

	ScenarioExit.complete_success({"attempted": true})

	assert_eq(ScenarioExit.get_exit_code(), ScenarioExit.TIMEOUT)
	assert_true(bool(ScenarioExit.get_status().get("completed", false)))


func test_exit_code_contract_includes_all_documented_categories() -> void:
	assert_eq(ScenarioExit.OK, 0)
	assert_eq(ScenarioExit.BOOT_FAILURE, 10)
	assert_eq(ScenarioExit.SCENARIO_FAILURE, 11)
	assert_eq(ScenarioExit.AUDIT_MISSING, 12)
	assert_eq(ScenarioExit.UNEXPECTED_RUNTIME_ERROR, 13)
	assert_eq(ScenarioExit.TIMEOUT, 14)
	assert_eq(ScenarioExit.CONFIG_ERROR, 15)
	assert_eq(ScenarioExit.SAVE_LOAD_FAILURE, 20)
	assert_eq(ScenarioExit.SESSION_FAILURE, 21)
	assert_eq(ScenarioExit.UI_FAILURE, 22)
	assert_eq(ScenarioExit.INTERNAL_ERROR, 70)


func test_status_lines_have_stable_prefixes() -> void:
	var source: String = load("res://game/autoload/scenario_exit.gd").source_code

	assert_string_contains(source, "SCENARIO: PASS")
	assert_string_contains(source, "SCENARIO: FAIL")
	assert_string_contains(source, "SCENARIO: EXIT")
