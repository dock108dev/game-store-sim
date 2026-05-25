extends GutTest

const RUNNER_SCRIPT: GDScript = preload("res://game/scripts/automation/long_day_soak_runner.gd")

var _saved_state: int
var _saved_store_id: StringName


func before_each() -> void:
	_saved_state = int(GameManager.current_state)
	_saved_store_id = GameManager.current_store_id
	GameManager.current_state = GameManager.State.GAMEPLAY
	GameManager.current_store_id = &"retro_games"
	GameManager.set("_store_state_manager_ref", null)


func after_each() -> void:
	GameManager.current_state = _saved_state
	GameManager.current_store_id = _saved_store_id
	GameState.set_flag(&"first_sale_complete", false)


func test_profiles_document_standard_and_sixty_minute_runs() -> void:
	var standard: Dictionary = RUNNER_SCRIPT.resolve_profile("standard")
	var nightly: Dictionary = RUNNER_SCRIPT.resolve_profile("nightly")
	var release: Dictionary = RUNNER_SCRIPT.resolve_profile("release")

	assert_eq(float(standard.get("equivalent_gameplay_minutes", 0.0)), 30.0)
	assert_eq(float(nightly.get("equivalent_gameplay_minutes", 0.0)), 60.0)
	assert_eq(float(release.get("equivalent_gameplay_minutes", 0.0)), 60.0)
	assert_true(bool(nightly.get("nightly_capable", false)))
	assert_true(RUNNER_SCRIPT.supported_profiles().has("standard"))
	assert_eq(RUNNER_SCRIPT.selected_profile_id({"soak_profile": "release"}, {}), "release")


func test_long_soak_runner_advances_time_and_writes_artifacts() -> void:
	var time := TimeSystem.new()
	add_child_autofree(time)
	time.initialize()
	time.game_time_minutes = 540.0
	time.current_hour = 9
	time.set("_last_emitted_hour", 9)

	var performance := PerformanceManager.new()
	add_child_autofree(performance)
	performance.initialize()

	var runner: Node = RUNNER_SCRIPT.new()
	add_child_autofree(runner)
	var result: Dictionary = await (
		runner
		. call(
			"run",
			{
				"scenario_id": "long_day_soak",
				"run_id": "unit_long_day_soak",
				"seed": "unit_seed",
			},
			{
				"profile_overrides":
				{
					"equivalent_gameplay_minutes": 1.0,
					"sample_interval_minutes": 0.5,
					"frames_per_sample": 1,
					"target_active_customers": 0,
				},
			}
		)
	)
	var simulation: Dictionary = result.get("simulation", {}) as Dictionary
	var threshold_summary: Dictionary = result.get("threshold_summary", {}) as Dictionary
	var artifacts: Dictionary = result.get("artifact_paths", {}) as Dictionary
	var metrics_artifact: Dictionary = artifacts.get("soak_metrics", {}) as Dictionary

	assert_true(bool(result.get("ok", false)), str(result.get("failures", [])))
	assert_gte(float(simulation.get("equivalent_gameplay_minutes", 0.0)), 1.0)
	assert_true(bool(threshold_summary.get("passed", false)))
	assert_true(FileAccess.file_exists(str(metrics_artifact.get("path", ""))))
