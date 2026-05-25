## Runs the long-day soak proof step and attaches its artifacts to the result.
class_name ScenarioLongDaySoakStep
extends RefCounted

const LONG_DAY_SOAK_RUNNER_SCRIPT: GDScript = preload(
	"res://game/scripts/automation/long_day_soak_runner.gd"
)


func execute(
	owner: Node, step_result: Dictionary, step: Dictionary, result: Dictionary, options: Dictionary
) -> Dictionary:
	var runner: Node = LONG_DAY_SOAK_RUNNER_SCRIPT.new()
	owner.add_child(runner)
	var run_options: Dictionary = options.duplicate(true)
	run_options["scenario_id"] = str(result.get("scenario_id", ""))
	run_options["run_id"] = str(result.get("run_id", ""))
	var proof: Dictionary = await runner.call("run", run_options, step)
	runner.queue_free()
	result["captures"]["long_day_soak_report"] = proof
	result["performance_soak"] = proof.get("performance_observation", {})
	result["threshold_summary"] = proof.get("threshold_summary", {})
	result["trend"] = proof.get("trend", {})
	step_result["data"] = proof
	step_result["ok"] = bool(proof.get("ok", false))
	if not bool(step_result.get("ok", false)):
		step_result["reason"] = "long day soak failed: %s" % str(proof.get("failures", []))
	return step_result
