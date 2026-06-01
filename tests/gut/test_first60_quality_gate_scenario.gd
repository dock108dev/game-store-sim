extends GutTest

const LOADER_SCRIPT: GDScript = preload("res://tests/automation/scenario_loader.gd")


func test_fresh_install_fixture_runs_first60_quality_gate_after_day1_ready() -> void:
	var loader = LOADER_SCRIPT.new()
	var result: Dictionary = loader.load_by_id("fresh_install_smoke")
	var scenario: Dictionary = result.get("scenario", {}) as Dictionary
	var steps: Array = scenario.get("steps", []) as Array
	var ready_index: int = _step_index(steps, "day1_playable_ready")
	var gate_index: int = _step_index(steps, "first60_quality_gate")
	var audit_index: int = _step_index(steps, "first60_quality_ready")

	assert_true(bool(result.get("ok", false)), str(result.get("error", "")))
	assert_gte(ready_index, 0)
	assert_gt(gate_index, ready_index)
	assert_gt(audit_index, gate_index)
	assert_eq(str((steps[gate_index] as Dictionary).get("type", "")), "run_first60_quality_gate")
	assert_eq(
		str((steps[audit_index] as Dictionary).get("checkpoint", "")),
		"first60_quality_ready"
	)


func _step_index(steps: Array, step_id: String) -> int:
	for index: int in range(steps.size()):
		var step: Dictionary = steps[index] as Dictionary
		if str(step.get("id", "")) == step_id:
			return index
	return -1
