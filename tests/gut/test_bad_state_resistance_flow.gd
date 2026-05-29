extends GutTest

const RUNNER_SCRIPT: GDScript = preload("res://tests/automation/scenario_runner.gd")
const SCENARIO_ID: String = "bad_state_resistance"

var _saved_artifact_env: String = ""
var _saved_focus_stack: Array[StringName] = []
var _saved_state: GameManager.State = GameManager.State.MAIN_MENU
var _saved_paused: bool = false


func before_each() -> void:
	_saved_artifact_env = OS.get_environment("MALLCORE_ARTIFACT_DIR")
	OS.set_environment("MALLCORE_ARTIFACT_DIR", "user://bad_state_resistance_artifacts")
	_saved_focus_stack = InputFocus.stack_snapshot()
	_saved_state = GameManager.current_state
	_saved_paused = get_tree().paused
	InputFocus._reset_for_tests()
	ModalQueue._reset_for_tests()


func after_each() -> void:
	OS.set_environment("MALLCORE_ARTIFACT_DIR", _saved_artifact_env)
	ModalQueue._reset_for_tests()
	InputFocus._reset_for_tests()
	for ctx: StringName in _saved_focus_stack:
		InputFocus.push_context(ctx)
	GameManager.current_state = _saved_state
	get_tree().paused = _saved_paused
	GameRandom.disable_test_mode()


func test_bad_state_resistance_scenario_reports_recovered_gameplay_focus() -> void:
	var runner: Node = RUNNER_SCRIPT.new()
	add_child_autofree(runner)
	var result: Dictionary = await runner.call(
		"run_by_id",
		SCENARIO_ID,
		{"seed": "unit_seed", "fresh_save": true}
	)

	assert_true(bool(result.get("ok", false)), str(result.get("summary", "")))
	var captures: Dictionary = result.get("captures", {}) as Dictionary
	var report: Dictionary = captures.get("bad_state_resistance_report", {}) as Dictionary
	assert_true(bool(report.get("ok", false)), str(report.get("failures", [])))

	var interaction: Dictionary = report.get("interaction", {}) as Dictionary
	assert_eq(int(interaction.get("interact_calls", 0)), 2)
	assert_eq(str(interaction.get("focus_current", "")), "store_gameplay")
	assert_eq(int(interaction.get("focus_depth", 0)), 1)

	var modal_queue: Dictionary = report.get("modal_queue", {}) as Dictionary
	assert_false(bool(modal_queue.get("busy", true)))
	assert_eq(int(modal_queue.get("pending_count", -1)), 0)

	var panel_counts: Array = report.get("panel_counts", []) as Array
	assert_true(_panel_count_seen(panel_counts, "inventory", 1))
	assert_true(_panel_count_seen(panel_counts, "inventory", 0))

	var prompts: Array = report.get("prompt_status", []) as Array
	assert_true(prompts.has("Close the open panel to interact"))
	assert_true(prompts.has("Close the current panel or menu to interact"))

	var notification_queue: Dictionary = report.get("notification_queue", {}) as Dictionary
	assert_eq(
		int(notification_queue.get("mouse_filter", -1)),
		Control.MOUSE_FILTER_IGNORE,
		"Toasts must remain click-through during conflict flow"
	)

	var screenshots: Array = report.get("screenshots", []) as Array
	assert_gte(screenshots.size(), 3)
	for shot_variant: Variant in screenshots:
		var shot: Dictionary = shot_variant as Dictionary
		assert_true(bool(shot.get("ok", false)), "Screenshot checkpoint must be recorded")
		assert_true(FileAccess.file_exists(str(shot.get("metadata_path", ""))))

	var run_report: Dictionary = result.get("report", {}) as Dictionary
	assert_true(bool(run_report.get("ok", false)))
	assert_true(FileAccess.file_exists(str(run_report.get("path", ""))))


func _panel_count_seen(rows: Array, panel_name: String, count: int) -> bool:
	for row_variant: Variant in rows:
		var row: Dictionary = row_variant as Dictionary
		if str(row.get("panel", "")) == panel_name and int(row.get("count", -1)) == count:
			return true
	return false
