## Executes data-driven automation scenario steps over existing runtime owners.
class_name ScenarioRunner
extends Node

signal scenario_started(scenario_id: StringName)
signal scenario_completed(result: Dictionary)
signal scenario_failed(result: Dictionary)
signal step_started(index: int, step: Dictionary)
signal step_completed(index: int, result: Dictionary)
signal step_failed(index: int, result: Dictionary)

const DEFAULT_STEP_TIMEOUT_FRAMES: int = 300
const PROTECTED_OUTCOME_SIGNALS: Dictionary = {
	&"store_ready": true,
	&"store_failed": true,
	&"scene_ready": true,
	&"first_sale_completed": true,
	&"day_closed": true,
	&"transaction_completed": true,
	&"customer_purchased": true,
}
const ASSERTIONS_SCRIPT: GDScript = preload("res://tests/automation/scenario_assertions.gd")
const LOADER_SCRIPT: GDScript = preload("res://tests/automation/scenario_loader.gd")
const WRITER_SCRIPT: GDScript = preload("res://tests/automation/scenario_artifact_writer.gd")
const TIME_CONTROLLER_SCRIPT: GDScript = preload(
	"res://game/scripts/systems/time_automation_controller.gd"
)
const SEMANTIC_STEPS_SCRIPT: GDScript = preload("res://tests/automation/scenario_semantic_steps.gd")
const ROUTE_STEP_SCRIPT: GDScript = preload("res://tests/automation/scenario_route_step.gd")
const SCREENSHOT_CAPTURE_SCRIPT: GDScript = preload(
	"res://game/scripts/automation/scenario_screenshot_capture.gd"
)
const ECONOMY_LOOP_RUNNER_SCRIPT: GDScript = preload(
	"res://game/scripts/automation/economy_loop_seed_runner.gd"
)
const SAVE_RELOAD_RUNNER_SCRIPT: GDScript = preload(
	"res://game/scripts/automation/save_reload_smoke_runner.gd"
)
const BAD_STATE_RESISTANCE_RUNNER_SCRIPT: GDScript = preload(
	"res://game/scripts/automation/bad_state_resistance_runner.gd"
)
const SOAK_METRICS_SCRIPT: GDScript = preload("res://game/scripts/automation/npc_soak_metrics.gd")
const RUNTIME_HELPERS_SCRIPT: GDScript = preload(
	"res://tests/automation/scenario_runtime_helpers.gd"
)
const LONG_DAY_SOAK_STEP_SCRIPT: GDScript = preload(
	"res://tests/automation/scenario_long_day_soak_step.gd"
)
const STORE_SESSION_TUTORIAL_FULL_STEP_SCRIPT: GDScript = preload(
	"res://tests/automation/store_session_tutorial_full_step.gd"
)
const FIRST60_QUALITY_GATE_STEP_SCRIPT: GDScript = preload(
	"res://tests/automation/first60_quality_gate_step.gd"
)
const AUTOMATION_MODE_SCRIPT: GDScript = preload("res://game/scripts/automation/automation_mode.gd")

var _is_running: bool = false
var _cancelled: bool = false
var _cancel_reason: String = ""
var _active_connections: Array[Dictionary] = []
var _seen_bus: Array[Dictionary] = []
var _last_result: Dictionary = {}


## Loads a scenario by id from the stable scenario catalog and executes it.
func run_by_id(scenario_id: String, options: Dictionary = {}) -> Dictionary:
	var loader = LOADER_SCRIPT.new()
	var loaded: Dictionary = loader.load_by_id(scenario_id)
	if not bool(loaded.get("ok", false)):
		var result: Dictionary = RUNTIME_HELPERS_SCRIPT.base_result(
			scenario_id, options, str(loaded.get("error", "scenario load failed"))
		)
		result["events"] = _seen_bus
		result["available_scenario_ids"] = loaded.get("context", {}).get(
			"available_scenario_ids", Array(loader.available_scenario_ids())
		)
		return _finish_result(result)
	return await run(loaded.get("scenario", {}) as Dictionary, options)


## Executes a validated scenario dictionary.
func run(scenario: Dictionary, options: Dictionary = {}) -> Dictionary:
	if _is_running:
		var busy_result: Dictionary = RUNTIME_HELPERS_SCRIPT.base_result(
			str(scenario.get("id", "")), options, "runner already active"
		)
		busy_result["events"] = _seen_bus
		return busy_result
	_reset_runtime_state()
	_is_running = true
	var scenario_id: String = str(scenario.get("id", ""))
	options = _options_with_scenario_defaults(scenario, options)
	var result: Dictionary = RUNTIME_HELPERS_SCRIPT.base_result(scenario_id, options)
	result["events"] = _seen_bus
	result["source_path"] = str(scenario.get("source_path", ""))
	var soak_metrics: Node = SOAK_METRICS_SCRIPT.new()
	add_child(soak_metrics)
	soak_metrics.call("start")
	scenario_started.emit(StringName(scenario_id))

	var steps: Array = scenario.get("steps", []) as Array
	for index: int in range(steps.size()):
		if _cancelled:
			_fail_result(result, index, {}, "cancelled: %s" % _cancel_reason)
			break
		var step: Dictionary = steps[index] as Dictionary
		step_started.emit(index, step)
		var step_result: Dictionary = await _execute_step(index, step, result, options)
		result["steps"].append(step_result)
		if bool(step_result.get("ok", false)):
			result["last_successful_step"] = step_result
			step_completed.emit(index, step_result)
		else:
			_fail_result(result, index, step, str(step_result.get("reason", "")))
			step_failed.emit(index, step_result)
			break

	if bool(result.get("ok", true)):
		result["ok"] = true
		result["summary"] = "scenario completed"
	_cleanup_connections()
	result["ended_msec"] = Time.get_ticks_msec()
	result["elapsed_msec"] = int(result["ended_msec"]) - int(result["started_msec"])
	result["soak_metrics"] = soak_metrics.call("stop")
	result["soak_fail_reasons"] = (result.get("soak_metrics", {}) as Dictionary).get(
		"fail_reasons", []
	)
	soak_metrics.queue_free()
	var writer = WRITER_SCRIPT.new()
	var report: Dictionary = writer.write_run_report(result)
	result["report"] = report
	return _finish_result(result)


## Cancels the active scenario and releases temporary listeners.
func cancel(reason: String = "cancelled") -> void:
	_cancelled = true
	_cancel_reason = reason
	_cleanup_connections()


## Returns a copy of the most recent run result.
func get_last_result() -> Dictionary:
	return _last_result.duplicate(true)


func _execute_step(
	index: int, step: Dictionary, result: Dictionary, options: Dictionary
) -> Dictionary:
	var started_frame: int = Engine.get_process_frames()
	var step_result: Dictionary = {
		"index": index,
		"id": str(step.get("id", "step_%d" % index)),
		"type": str(step.get("type", "")),
		"ok": false,
		"started_frame": started_frame,
		"data": {},
	}
	match str(step.get("type", "")):
		"wait_audit":
			step_result = await _step_wait_audit(step_result, step)
		"wait_bus":
			step_result = await _step_wait_bus(step_result, step)
		"wait_modal":
			step_result = await _step_wait_modal(step_result, step)
		"acknowledge_modal":
			step_result = await _step_acknowledge_modal(step_result)
		"wait_input_focus":
			step_result = await _step_wait_input_focus(step_result, step)
		"wait_store_session_prompt":
			step_result = await _step_wait_store_session_prompt(step_result, step)
		"acknowledge_prompt":
			step_result = await _step_acknowledge_prompt(step_result, step)
		"wait_customer_exit":
			step_result = await _step_wait_customer_exit(step_result, step)
		"fast_forward_animations":
			step_result = _step_fast_forward_animations(step_result, step)
		"emit_bus":
			step_result = _step_emit_bus(step_result, step, options)
		"enter_store":
			step_result = await _step_enter_store(step_result, step)
		"route_scene":
			step_result = await _step_route_scene(step_result, step)
		"wait_node":
			step_result = await _step_wait_node(step_result, step)
		"call_node":
			step_result = _step_call_node(step_result, step, options)
		"assert_node":
			step_result = _step_assert_node(step_result, step, options)
		"advance_frames":
			step_result = await _step_advance_frames(step_result, step)
		"time_speed":
			step_result = _step_time_speed(step_result, step)
		"time_step":
			step_result = _step_time_step(step_result, step)
		"move_to_target", "aim_at_target", "focus_target", "interact_target":
			step_result = await SEMANTIC_STEPS_SCRIPT.new().execute(self, step_result, step)
		"capture":
			step_result = await _step_capture(step_result, step, result)
		"screenshot":
			step_result = await _step_screenshot(step_result, step, result)
		"run_economy_loop":
			step_result = _step_run_economy_loop(step_result, result)
		"run_save_reload_smoke":
			step_result = _step_run_save_reload_smoke(step_result, result)
		"run_bad_state_resistance":
			step_result = _step_run_bad_state_resistance(step_result, result)
		"run_long_day_soak":
			step_result = await LONG_DAY_SOAK_STEP_SCRIPT.new().execute(
				self, step_result, step, result, options
			)
		"run_store_session_tutorial_full":
			step_result = await STORE_SESSION_TUTORIAL_FULL_STEP_SCRIPT.new().execute(
				self, step_result, step, result, options
			)
		"run_first60_quality_gate":
			step_result = await FIRST60_QUALITY_GATE_STEP_SCRIPT.new().execute(
				self, step_result, step, result, options
			)
		"finish":
			step_result["ok"] = true
		_:
			step_result["reason"] = "unknown step command '%s'" % str(step.get("type", ""))
	step_result["ended_frame"] = Engine.get_process_frames()
	step_result["elapsed_frames"] = int(step_result["ended_frame"]) - started_frame
	return step_result


func _step_wait_audit(step_result: Dictionary, step: Dictionary) -> Dictionary:
	if AuditLog == null:
		return _step_error(step_result, "AuditLog missing")
	var checkpoint := StringName(str(step.get("checkpoint", "")))
	var status: String = str(step.get("status", "PASS"))
	var recent: Dictionary = RUNTIME_HELPERS_SCRIPT.find_recent_audit(
		AuditLog.recent(AuditLog.RING_CAPACITY), checkpoint, status
	)
	if not recent.is_empty():
		step_result["ok"] = true
		step_result["data"] = recent
		return step_result
	var signal_name: StringName = &"checkpoint_passed" if status == "PASS" else &"checkpoint_failed"
	var box: Dictionary = {"done": false, "entry": {}}
	var callable: Callable = func(name: StringName, detail: String) -> void:
		if name != checkpoint:
			return
		box["done"] = true
		box["entry"] = {
			"status": status,
			"checkpoint": String(name),
			"detail": detail,
		}
	AuditLog.connect(signal_name, callable)
	_active_connections.append({"object": AuditLog, "signal": signal_name, "callable": callable})
	var timeout_frames: int = _timeout(step)
	for _i: int in range(timeout_frames):
		if bool(box.get("done", false)):
			step_result["ok"] = true
			step_result["data"] = box.get("entry", {})
			return step_result
		await get_tree().process_frame
	return _step_error(
		step_result,
		"timed out after %d frames waiting for AUDIT %s %s" % [timeout_frames, status, checkpoint]
	)


func _step_wait_bus(step_result: Dictionary, step: Dictionary) -> Dictionary:
	var signal_name := StringName(str(step.get("signal", "")))
	if not EventBus.has_signal(signal_name):
		return _step_error(step_result, "EventBus missing signal '%s'" % signal_name)
	var expected: Dictionary = step.get("match", {}) as Dictionary
	var box: Dictionary = {"done": false, "args": []}
	var callable: Callable = RUNTIME_HELPERS_SCRIPT.connect_bus_signal(
		EventBus, signal_name, box, _seen_bus, _active_connections
	)
	var timeout_frames: int = _timeout(step)
	var elapsed: int = 0
	while elapsed < timeout_frames:
		if bool(box.get("done", false)):
			var args: Array = box.get("args", []) as Array
			if RUNTIME_HELPERS_SCRIPT.matches_signal_args(signal_name, args, expected):
				step_result["ok"] = true
				step_result["data"] = {"signal": String(signal_name), "args": args}
				break
			box["done"] = false
		await get_tree().process_frame
		elapsed += 1
	_disconnect(EventBus, signal_name, callable)
	if not bool(step_result.get("ok", false)):
		return _step_error(
			step_result,
			(
				"timed out after %d frames waiting for EventBus.%s match=%s"
				% [timeout_frames, signal_name, expected]
			)
		)
	return step_result


func _step_wait_modal(step_result: Dictionary, step: Dictionary) -> Dictionary:
	if ModalQueue == null:
		return _step_error(step_result, "ModalQueue missing")
	var timeout_frames: int = _timeout(step)
	var state: String = str(step.get("state", "ready"))
	var expected: Dictionary = step.get("match", {}) as Dictionary
	for _i: int in range(timeout_frames):
		var snapshot: Dictionary = ModalQueue.get_modal_snapshot()
		var state_ok: bool = (
			(not bool(snapshot.get("busy", false)))
			if state == "closed"
			else bool(snapshot.get("busy", false))
		)
		if state_ok and _snapshot_matches(snapshot, expected):
			step_result["ok"] = true
			step_result["data"] = snapshot
			return step_result
		await get_tree().process_frame
	return _step_error(step_result, "timed out waiting for modal %s" % state)


func _step_acknowledge_modal(step_result: Dictionary) -> Dictionary:
	if ModalQueue == null:
		return _step_error(step_result, "ModalQueue missing")
	if not AUTOMATION_MODE_SCRIPT.is_enabled():
		return _step_error(step_result, "automation mode is not enabled")
	if not ModalQueue.acknowledge_active_for_automation():
		return _step_error(step_result, "active modal could not be acknowledged")
	await get_tree().process_frame
	step_result["ok"] = true
	step_result["data"] = ModalQueue.get_modal_snapshot()
	return step_result


func _step_wait_input_focus(step_result: Dictionary, step: Dictionary) -> Dictionary:
	if InputFocus == null:
		return _step_error(step_result, "InputFocus missing")
	var expected: Dictionary = step.get("match", {}) as Dictionary
	var timeout_frames: int = _timeout(step)
	for _i: int in range(timeout_frames):
		var snapshot: Dictionary = InputFocus.get_focus_snapshot()
		if _snapshot_matches(snapshot, expected):
			step_result["ok"] = true
			step_result["data"] = snapshot
			return step_result
		await get_tree().process_frame
	return _step_error(step_result, "timed out waiting for InputFocus match=%s" % expected)


func _step_wait_store_session_prompt(step_result: Dictionary, step: Dictionary) -> Dictionary:
	var controller: Node = _resolve_store_session_controller(step)
	if controller == null:
		return _step_error(step_result, "store-session controller unavailable")
	if not controller.has_method("get_session_progress_snapshot"):
		return _step_error(step_result, "store-session controller missing snapshot method")
	var expected: Dictionary = step.get("match", {}) as Dictionary
	var timeout_frames: int = _timeout(step)
	for _i: int in range(timeout_frames):
		var snapshot: Dictionary = controller.call("get_session_progress_snapshot")
		if _snapshot_matches(snapshot, expected):
			step_result["ok"] = true
			step_result["data"] = snapshot
			return step_result
		await get_tree().process_frame
	return _step_error(step_result, "timed out waiting for store-session prompt")


func _step_acknowledge_prompt(step_result: Dictionary, step: Dictionary) -> Dictionary:
	if not AUTOMATION_MODE_SCRIPT.is_enabled():
		return _step_error(step_result, "automation mode is not enabled")
	var target_path: String = str(step.get("target", ""))
	if not target_path.is_empty():
		var node: Node = _resolve_node(target_path)
		if node == null:
			return _step_error(step_result, "node not found: %s" % target_path)
		if not node.has_method("acknowledge_for_automation"):
			return _step_error(step_result, "node missing acknowledge_for_automation")
		if not bool(node.call("acknowledge_for_automation")):
			return _step_error(step_result, "node could not acknowledge prompt")
		step_result["ok"] = true
		return step_result
	var controller: Node = _resolve_store_session_controller(step)
	if (
		controller != null
		and controller.has_method("acknowledge_prompt_for_automation")
		and bool(controller.call("acknowledge_prompt_for_automation"))
	):
		step_result["ok"] = true
		return step_result
	if ModalQueue != null and ModalQueue.acknowledge_active_for_automation():
		step_result["ok"] = true
		return step_result
	return _step_error(step_result, "no prompt could be acknowledged")


func _step_wait_customer_exit(step_result: Dictionary, step: Dictionary) -> Dictionary:
	var controller: Node = _resolve_store_session_controller(step)
	if controller == null:
		return _step_error(step_result, "store-session controller unavailable")
	var expected_state: String = str(step.get("state", "exited_hidden"))
	var expected: Dictionary = step.get("match", {}) as Dictionary
	if not expected.has("customer.exit_state"):
		expected["customer.exit_state"] = expected_state
	var timeout_frames: int = _timeout(step)
	for _i: int in range(timeout_frames):
		var snapshot: Dictionary = controller.call("get_session_progress_snapshot")
		if _snapshot_matches(snapshot, expected):
			step_result["ok"] = true
			step_result["data"] = snapshot
			return step_result
		await get_tree().process_frame
	return _step_error(step_result, "timed out waiting for customer exit")


func _step_fast_forward_animations(step_result: Dictionary, step: Dictionary) -> Dictionary:
	if not AUTOMATION_MODE_SCRIPT.is_enabled():
		return _step_error(step_result, "automation mode is not enabled")
	var targets: Array[Node] = []
	var target_path: String = str(step.get("target", ""))
	if not target_path.is_empty():
		var target_node: Node = _resolve_node(target_path)
		if target_node == null:
			return _step_error(step_result, "node not found: %s" % target_path)
		targets.append(target_node)
	else:
		if ModalQueue != null and ModalQueue.active_panel() != null:
			targets.append(ModalQueue.active_panel())
		targets.append_array(get_tree().get_nodes_in_group("ui.tutorial_panel"))
		targets.append_array(get_tree().get_nodes_in_group("store_session_controller"))
	var advanced: int = 0
	for node: Node in targets:
		if node != null and node.has_method("fast_forward_animations_for_automation"):
			if bool(node.call("fast_forward_animations_for_automation")):
				advanced += 1
	step_result["ok"] = true
	step_result["data"] = {"advanced_count": advanced}
	return step_result


func _step_emit_bus(step_result: Dictionary, step: Dictionary, options: Dictionary) -> Dictionary:
	var signal_name := StringName(str(step.get("signal", "")))
	if not EventBus.has_signal(signal_name):
		return _step_error(step_result, "EventBus missing signal '%s'" % signal_name)
	if (
		PROTECTED_OUTCOME_SIGNALS.has(signal_name)
		and not bool(options.get("allow_outcome_signal_emit", false))
	):
		return _step_error(
			step_result, "protected outcome signal '%s' cannot be emitted" % signal_name
		)
	var args: Array = step.get("args", []) as Array
	Callable(EventBus, "emit_signal").callv([signal_name] + args)
	step_result["ok"] = true
	step_result["data"] = {"signal": String(signal_name), "args": args}
	return step_result


func _step_enter_store(step_result: Dictionary, step: Dictionary) -> Dictionary:
	if StoreDirector == null:
		return _step_error(step_result, "StoreDirector missing")
	if StoreDirector.state != StoreDirector.State.IDLE:
		return _step_error(step_result, "StoreDirector busy before enter_store")
	var ok: bool = await StoreDirector.enter_store(StringName(str(step.get("store_id", ""))))
	if not ok:
		return _step_error(step_result, "StoreDirector enter_store failed")
	step_result["ok"] = true
	return step_result


func _step_route_scene(step_result: Dictionary, step: Dictionary) -> Dictionary:
	return await ROUTE_STEP_SCRIPT.new().execute(self, step_result, step)


func _step_wait_node(step_result: Dictionary, step: Dictionary) -> Dictionary:
	var timeout_frames: int = _timeout(step)
	for _i: int in range(timeout_frames):
		var node: Node = _resolve_node(str(step.get("target", "")))
		if node != null:
			step_result["ok"] = true
			step_result["data"] = {"path": str(step.get("target", ""))}
			return step_result
		await get_tree().process_frame
	return _step_error(step_result, "node not found: %s" % str(step.get("target", "")))


func _step_call_node(step_result: Dictionary, step: Dictionary, options: Dictionary) -> Dictionary:
	var node: Node = _resolve_node(str(step.get("target", "")))
	if node == null:
		return _step_error(step_result, "node not found: %s" % str(step.get("target", "")))
	var method: String = str(step.get("method", ""))
	if method.begins_with("_") and not bool(options.get("allow_private_calls", false)):
		return _step_error(step_result, "private method call rejected: %s" % method)
	if not node.has_method(method):
		return _step_error(step_result, "node missing method: %s" % method)
	var value: Variant = node.callv(method, step.get("args", []) as Array)
	step_result["ok"] = true
	step_result["data"] = {"return_value": value}
	return step_result


func _step_assert_node(
	step_result: Dictionary, step: Dictionary, options: Dictionary
) -> Dictionary:
	var call_result: Dictionary = _step_call_node(step_result.duplicate(true), step, options)
	if not bool(call_result.get("ok", false)):
		return call_result
	var actual: Variant = (call_result.get("data", {}) as Dictionary).get("return_value")
	var assertion: Dictionary = ASSERTIONS_SCRIPT.evaluate(
		actual, step.get("assert", {}) as Dictionary
	)
	step_result["ok"] = bool(assertion.get("ok", false))
	step_result["data"] = assertion
	if not bool(step_result.get("ok", false)):
		step_result["reason"] = str(assertion.get("reason", "assertion failed"))
	return step_result


func _step_advance_frames(step_result: Dictionary, step: Dictionary) -> Dictionary:
	for _i: int in range(int(step.get("count", 1))):
		await get_tree().process_frame
	step_result["ok"] = true
	return step_result


func _step_time_speed(step_result: Dictionary, step: Dictionary) -> Dictionary:
	EventBus.time_speed_requested.emit(int(step.get("tier", 1)))
	step_result["ok"] = true
	return step_result


func _step_time_step(step_result: Dictionary, step: Dictionary) -> Dictionary:
	var time_system: TimeSystem = GameManager.get_time_system()
	if time_system == null:
		return _step_error(step_result, "TimeSystem unavailable")
	var controller = TIME_CONTROLLER_SCRIPT.new()
	controller.initialize(time_system)
	var advanced: float = controller.step_minutes(float(step.get("minutes", 0.0)))
	controller.free()
	step_result["ok"] = true
	step_result["data"] = {"minutes_advanced": advanced}
	return step_result


func _step_capture(step_result: Dictionary, step: Dictionary, result: Dictionary) -> Dictionary:
	var label: String = str(step.get("label", step.get("id", "capture")))
	match str(step.get("mode", "")):
		"state":
			var call_result: Dictionary = _step_call_node(
				step_result.duplicate(true),
				step,
				{
					"allow_private_calls": false,
				}
			)
			if not bool(call_result.get("ok", false)):
				return call_result
			result["captures"][label] = (call_result.get("data", {}) as Dictionary).get(
				"return_value"
			)
		"screenshot":
			return await _step_screenshot(step_result, step, result)
		_:
			return _step_error(step_result, "unsupported capture mode")
	step_result["ok"] = true
	return step_result


func _step_screenshot(step_result: Dictionary, step: Dictionary, result: Dictionary) -> Dictionary:
	var label: String = str(step.get("label", step.get("id", "screenshot")))
	var capture_options: Dictionary = {
		"scenario_id": str(result.get("scenario_id", "")),
		"seed": str(result.get("seed", "")),
		"scene": RUNTIME_HELPERS_SCRIPT.current_scene_name(get_tree()),
		"checkpoint": label,
		"index": int(step.get("checkpoint_index", int(step_result.get("index", 0)) + 1)),
		"allow_placeholder": bool(step.get("allow_placeholder", false)),
		"assertion_counts": RUNTIME_HELPERS_SCRIPT.assertion_counts(result),
	}
	var capture_result: Dictionary = SCREENSHOT_CAPTURE_SCRIPT.capture_viewport(
		get_viewport(), capture_options
	)
	if not bool(capture_result.get("ok", false)):
		return _step_error(step_result, str(capture_result.get("error", "screenshot failed")))
	result["captures"][label] = capture_result
	step_result["ok"] = true
	step_result["data"] = {
		"path": str(capture_result.get("path", "")),
		"metadata_path": str(capture_result.get("metadata_path", "")),
		"placeholder": bool(capture_result.get("placeholder", false)),
	}
	return step_result


func _step_run_economy_loop(step_result: Dictionary, result: Dictionary) -> Dictionary:
	var runner: Node = ECONOMY_LOOP_RUNNER_SCRIPT.new()
	add_child(runner)
	var proof: Dictionary = runner.call("run")
	runner.queue_free()
	result["captures"]["economy_loop_report"] = proof
	step_result["data"] = proof
	step_result["ok"] = bool(proof.get("ok", false))
	if not bool(step_result.get("ok", false)):
		step_result["reason"] = "economy loop proof failed: %s" % str(proof.get("failures", []))
	return step_result


func _step_run_save_reload_smoke(step_result: Dictionary, result: Dictionary) -> Dictionary:
	var runner: Node = SAVE_RELOAD_RUNNER_SCRIPT.new()
	add_child(runner)
	var proof: Dictionary = runner.call("run")
	runner.queue_free()
	result["captures"]["save_reload_report"] = proof
	step_result["data"] = proof
	step_result["ok"] = bool(proof.get("ok", false))
	if not bool(step_result.get("ok", false)):
		step_result["reason"] = "save-reload smoke failed: %s" % str(proof.get("failures", []))
	return step_result


func _step_run_bad_state_resistance(step_result: Dictionary, result: Dictionary) -> Dictionary:
	var runner: Node = BAD_STATE_RESISTANCE_RUNNER_SCRIPT.new()
	add_child(runner)
	var proof: Dictionary = runner.call(
		"run",
		{
			"scenario_id": str(result.get("scenario_id", "")),
			"seed": str(result.get("seed", "")),
			"record_screenshots": true,
		}
	)
	runner.queue_free()
	result["captures"]["bad_state_resistance_report"] = proof
	step_result["data"] = proof
	step_result["ok"] = bool(proof.get("ok", false))
	if not bool(step_result.get("ok", false)):
		step_result["reason"] = (
			"bad-state resistance proof failed: %s" % str(proof.get("failures", []))
		)
	return step_result


func _resolve_node(path: String) -> Node:
	if path.is_empty():
		return null
	if path.begins_with("/root/"):
		return get_tree().root.get_node_or_null(NodePath(path.trim_prefix("/root/")))
	if path.begins_with("root/"):
		return get_tree().root.get_node_or_null(NodePath(path.trim_prefix("root/")))
	if get_tree().current_scene != null:
		return get_tree().current_scene.get_node_or_null(NodePath(path))
	return get_node_or_null(NodePath(path))


func _resolve_store_session_controller(step: Dictionary) -> Node:
	var target_path: String = str(step.get("target", ""))
	if not target_path.is_empty():
		return _resolve_node(target_path)
	var controllers: Array[Node] = get_tree().get_nodes_in_group("store_session_controller")
	if controllers.is_empty():
		return null
	return controllers[0]


func _snapshot_matches(snapshot: Dictionary, expected: Dictionary) -> bool:
	for key: String in expected.keys():
		var actual: Variant = _snapshot_value(snapshot, key)
		var wanted: Variant = expected[key]
		if actual is StringName:
			actual = String(actual)
		if wanted is StringName:
			wanted = String(wanted)
		if actual != wanted:
			return false
	return true


func _snapshot_value(snapshot: Dictionary, key: String) -> Variant:
	if snapshot.has(key):
		return snapshot[key]
	var parts: PackedStringArray = key.split(".")
	var current: Variant = snapshot
	for part: String in parts:
		if current is not Dictionary:
			return null
		var dict: Dictionary = current as Dictionary
		if not dict.has(part):
			return null
		current = dict[part]
	return current


func _timeout(step: Dictionary) -> int:
	return int(step.get("timeout_frames", DEFAULT_STEP_TIMEOUT_FRAMES))


func _options_with_scenario_defaults(scenario: Dictionary, options: Dictionary) -> Dictionary:
	var resolved: Dictionary = options.duplicate(true)
	var fixed_seed: String = str(scenario.get("fixed_seed", "")).strip_edges()
	if not fixed_seed.is_empty():
		resolved["seed"] = fixed_seed
		if GameRandom != null and GameRandom.has_method("enable_test_mode"):
			GameRandom.enable_test_mode(fixed_seed)
	return resolved


func _step_error(step_result: Dictionary, reason: String) -> Dictionary:
	step_result["ok"] = false
	step_result["reason"] = reason
	return step_result


func _fail_result(result: Dictionary, index: int, step: Dictionary, reason: String) -> void:
	result["ok"] = false
	result["failed_step_index"] = index
	result["failed_step"] = step
	result["summary"] = (
		"last_successful_step=%s failed_step=%s reason=%s report_next=%s"
		% [
			str((result.get("last_successful_step", {}) as Dictionary).get("id", "")),
			str(step.get("id", "")),
			reason,
			"reports/scenario/%s" % str(result.get("scenario_id", "")),
		]
	)


func _finish_result(result: Dictionary) -> Dictionary:
	_cleanup_connections()
	_is_running = false
	_last_result = result.duplicate(true)
	if bool(result.get("ok", false)):
		scenario_completed.emit(result)
	else:
		scenario_failed.emit(result)
	return result


func _reset_runtime_state() -> void:
	_cleanup_connections()
	_seen_bus.clear()
	_cancelled = false
	_cancel_reason = ""


func _cleanup_connections() -> void:
	for entry: Dictionary in _active_connections:
		_disconnect(
			entry.get("object") as Object,
			StringName(str(entry.get("signal", ""))),
			entry.get("callable") as Callable
		)
	_active_connections.clear()


func _disconnect(object: Object, signal_name: StringName, callable: Callable) -> void:
	if object != null and callable.is_valid() and object.is_connected(signal_name, callable):
		object.disconnect(signal_name, callable)
