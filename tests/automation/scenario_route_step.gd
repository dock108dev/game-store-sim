class_name ScenarioRouteStep
extends RefCounted

const DEFAULT_TIMEOUT_FRAMES: int = 300


func execute(owner: Node, step_result: Dictionary, step: Dictionary) -> Dictionary:
	if SceneRouter == null or not SceneRouter.has_method("route_to_path"):
		return _error(step_result, "SceneRouter route_to_path unavailable")
	if not SceneRouter.has_signal("scene_ready") or not SceneRouter.has_signal("scene_failed"):
		return _error(step_result, "SceneRouter scene signals unavailable")
	var box: Dictionary = {"ready": false, "failed": false, "target": &"", "reason": ""}
	var on_ready: Callable = func(target: StringName, _payload: Dictionary) -> void:
		box["ready"] = true
		box["target"] = target
	var on_failed: Callable = func(target: StringName, reason: String) -> void:
		box["failed"] = true
		box["target"] = target
		box["reason"] = reason
	SceneRouter.scene_ready.connect(on_ready, CONNECT_ONE_SHOT)
	SceneRouter.scene_failed.connect(on_failed, CONNECT_ONE_SHOT)
	var scene_path: String = str(step.get("scene_path", ""))
	SceneRouter.route_to_path(scene_path, step.get("payload", {}) as Dictionary)
	for _i: int in range(int(step.get("timeout_frames", DEFAULT_TIMEOUT_FRAMES))):
		if bool(box.get("ready", false)):
			_disconnect(&"scene_failed", on_failed)
			step_result["ok"] = true
			step_result["data"] = {"scene_path": scene_path, "target": String(box.get("target", &""))}
			return step_result
		if bool(box.get("failed", false)):
			_disconnect(&"scene_ready", on_ready)
			return _error(
				step_result,
				"SceneRouter route failed target=%s reason=%s"
				% [String(box.get("target", &"")), str(box.get("reason", ""))]
			)
		await owner.get_tree().process_frame
	_disconnect(&"scene_ready", on_ready)
	_disconnect(&"scene_failed", on_failed)
	return _error(
		step_result,
		"timed out after %d frames waiting for SceneRouter.scene_ready path=%s"
		% [int(step.get("timeout_frames", DEFAULT_TIMEOUT_FRAMES)), scene_path]
	)


func _disconnect(signal_name: StringName, callable: Callable) -> void:
	if callable.is_valid() and SceneRouter.is_connected(signal_name, callable):
		SceneRouter.disconnect(signal_name, callable)


func _error(step_result: Dictionary, reason: String) -> Dictionary:
	step_result["ok"] = false
	step_result["reason"] = reason
	return step_result
