## Executes semantic target scenario steps through SemanticInputDriver.
class_name ScenarioSemanticSteps
extends RefCounted

const DRIVER_SCRIPT: GDScript = preload("res://game/scripts/automation/semantic_input_driver.gd")


## Runs one semantic target step and returns a standard scenario step result.
func execute(owner: Node, step_result: Dictionary, step: Dictionary) -> Dictionary:
	var driver = DRIVER_SCRIPT.new()
	driver.name = "SemanticInputDriver"
	owner.add_child(driver)
	var ok: bool = false
	match str(step.get("type", "")):
		"move_to_target":
			ok = driver.move_to_target(step.get("target"), step.get("options", {}) as Dictionary)
		"aim_at_target":
			ok = driver.aim_at_target(step.get("target"), step.get("options", {}) as Dictionary)
		"focus_target":
			ok = await driver.focus_target(step.get("target"), step.get("options", {}) as Dictionary)
		"interact_target":
			ok = await driver.interact_target(step.get("target"), step.get("options", {}) as Dictionary)
	if ok:
		step_result["ok"] = true
		step_result["data"] = _step_data(driver)
	else:
		step_result["ok"] = false
		step_result["reason"] = driver.get_last_error()
	driver.queue_free()
	return step_result


func _step_data(driver) -> Dictionary:
	var resolved: Dictionary = driver.get_last_resolved()
	return {
		"target_id": String(resolved.get("id", &"")),
		"source": String(resolved.get("source", &"")),
		"path": str(resolved.get("scene_path", "")),
	}
