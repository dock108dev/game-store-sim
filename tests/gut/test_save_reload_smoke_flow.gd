extends GutTest

const RUNNER_SCRIPT: GDScript = preload("res://tests/automation/scenario_runner.gd")
const SCENARIO_ID: String = "save_reload_smoke"
const SALE_PRICE: float = 42.0
const STARTING_CASH: float = 100.0
const FLOAT_EPSILON: float = 0.001

var _saved_artifact_env: String = ""
var _saved_day: int = 1
var _saved_store_id: StringName = &""
var _saved_owned_stores: Array[StringName] = []
var _saved_game_flags: Dictionary = {}
var _saved_session_state: Dictionary = {}
var _saved_settings_path: String = ""


func before_each() -> void:
	var path_err: Error = UserDataPaths.configure_test_run(
		"save_reload_smoke_flow",
		true
	)
	assert_eq(path_err, OK, "test setup must isolate save paths")
	_saved_artifact_env = OS.get_environment("MALLCORE_ARTIFACT_DIR")
	OS.set_environment("MALLCORE_ARTIFACT_DIR", "user://save_reload_smoke_artifacts")
	_saved_day = GameManager.get_current_day()
	_saved_store_id = GameManager.current_store_id
	_saved_owned_stores = GameManager.owned_stores.duplicate()
	_saved_game_flags = GameState.flags.duplicate(true)
	_saved_session_state = StoreSessionState.get_save_data()
	_saved_settings_path = Settings.settings_path
	Settings.settings_path = UserDataPaths.settings_path()


func after_each() -> void:
	OS.set_environment("MALLCORE_ARTIFACT_DIR", _saved_artifact_env)
	GameManager.set_current_day(_saved_day)
	GameManager.current_store_id = _saved_store_id
	GameManager.owned_stores = _saved_owned_stores.duplicate()
	GameState.flags = _saved_game_flags.duplicate(true)
	StoreSessionState.load_save_data(_saved_session_state)
	Settings.settings_path = _saved_settings_path
	UserDataPaths.cleanup_active_test_run()
	UserDataPaths.reset_for_normal_play()


func test_save_reload_smoke_scenario_persists_sale_and_playable_state() -> void:
	var runner: Node = RUNNER_SCRIPT.new()
	add_child_autofree(runner)
	var result: Dictionary = await runner.call(
		"run_by_id",
		SCENARIO_ID,
		{"seed": "unit_seed", "fresh_save": true}
	)

	assert_true(bool(result.get("ok", false)), str(result.get("summary", "")))
	var captures: Dictionary = result.get("captures", {}) as Dictionary
	var report: Dictionary = captures.get("save_reload_report", {}) as Dictionary
	assert_true(bool(report.get("ok", false)), str(report.get("failures", [])))
	assert_eq(str(report.get("resolved_store_id", "")), "retro_games")
	assert_almost_eq(
		float(report.get("money_delta", 0.0)),
		SALE_PRICE,
		FLOAT_EPSILON
	)
	assert_eq(int(report.get("stock_delta", 0)), -1)

	var save_checks: Dictionary = report.get("save_checks", {}) as Dictionary
	assert_true(bool(save_checks.get("file_exists", false)))
	assert_true(bool(save_checks.get("slot_index_has_slot", false)))
	assert_eq(
		int(save_checks.get("schema_version", -1)),
		SaveManager.CURRENT_SAVE_VERSION
	)

	var guards: Dictionary = report.get("failure_guards", {}) as Dictionary
	assert_true(bool(guards.get("missing_slot_failed", false)))
	assert_true(bool(guards.get("corrupt_slot_failed", false)))
	assert_true(bool(guards.get("state_recovered", false)))

	var reload: Dictionary = report.get("reload_checks", {}) as Dictionary
	assert_true(bool(reload.get("money_persisted", false)))
	assert_true(bool(reload.get("sold_item_absent", false)))
	assert_true(bool(reload.get("empty_shelf_target_persisted", false)))
	assert_true(bool(reload.get("tutorial_completed_persisted", false)))
	assert_true(bool(reload.get("session_flags_persisted", false)))
	assert_true(bool(reload.get("preopening_persisted", false)))
	assert_true(bool(reload.get("active_store_persisted", false)))
	assert_true(
		bool(
			(reload.get("post_reload_basic_interaction", {}) as Dictionary).get(
				"ok",
				false
			)
		)
	)

	var economy_after: float = STARTING_CASH + SALE_PRICE
	var metadata: Dictionary = save_checks.get("metadata", {}) as Dictionary
	assert_almost_eq(float(metadata.get("cash", 0.0)), economy_after, FLOAT_EPSILON)

	for label: String in ["store_ui_open", "stock_shelf", "sale_complete", "save_reload"]:
		var capture: Dictionary = captures.get(label, {}) as Dictionary
		assert_true(bool(capture.get("ok", false)), "%s capture should exist" % label)
		assert_true(FileAccess.file_exists(str(capture.get("metadata_path", ""))))

	var run_report: Dictionary = result.get("report", {}) as Dictionary
	assert_true(bool(run_report.get("ok", false)))
	assert_true(FileAccess.file_exists(str(run_report.get("path", ""))))
