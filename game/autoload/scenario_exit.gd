## Owns automation scenario status and process exit codes.
extends Node

signal scenario_completed(status: Dictionary)

const OK: int = 0
## Boot or content validation failure.
const BOOT_FAILURE: int = 10
## Scenario assertion or checkpoint failure.
const SCENARIO_FAILURE: int = 11
## Required audit checkpoint was not observed.
const AUDIT_MISSING: int = 12
## Unexpected runtime error, including push_error gates under automation.
const UNEXPECTED_RUNTIME_ERROR: int = 13
## Scenario timeout.
const TIMEOUT: int = 14
## Scenario runner misuse or invalid automation configuration.
const CONFIG_ERROR: int = 15
## Save/load scenario failure.
const SAVE_LOAD_FAILURE: int = 20
## Gameplay session startup or economy scenario failure.
const SESSION_FAILURE: int = 21
## UI interaction scenario failure.
const UI_FAILURE: int = 22
## Internal scenario runner exception.
const INTERNAL_ERROR: int = 70

var _armed: bool = false
var _exit_on_complete: bool = false
var _emit_logs: bool = true
var _scenario_id: StringName = &""
var _exit_code: int = OK
var _failures: Array[Dictionary] = []
var _completed: bool = false


## Arms process-exit handling for a single automation scenario.
func arm(config: Dictionary) -> void:
	_armed = true
	_exit_on_complete = bool(config.get("exit_on_complete", false))
	_emit_logs = bool(config.get("emit_logs", true))
	_scenario_id = StringName(str(config.get("scenario_id", "")))
	_exit_code = OK
	_failures.clear()
	_completed = false


## Clears scenario status without quitting.
func reset() -> void:
	_armed = false
	_exit_on_complete = false
	_emit_logs = true
	_scenario_id = &""
	_exit_code = OK
	_failures.clear()
	_completed = false


## Returns true when automation exit handling is active.
func is_armed() -> bool:
	return _armed


## Returns true once a non-zero scenario failure has been recorded.
func has_failed() -> bool:
	return _exit_code != OK


## Returns the current exit code.
func get_exit_code() -> int:
	return _exit_code


## Returns a deep copy of recorded failures.
func get_failures() -> Array[Dictionary]:
	return _failures.duplicate(true)


## Records a failure while preserving the first non-zero exit code.
func fail(
	code: int,
	name: StringName,
	message: String,
	context: Dictionary = {}
) -> void:
	if not _armed:
		return
	if code == OK:
		code = SCENARIO_FAILURE
	if _exit_code == OK:
		_exit_code = code
	var failure: Dictionary = {
		"code": code,
		"name": String(name),
		"message": message,
		"context": context.duplicate(true),
	}
	_failures.append(failure)
	if _emit_logs:
		_print_fail(failure)


## Emits a pass marker for successful checkpoints while armed.
func pass_check(name: StringName, context: Dictionary = {}) -> void:
	if not _armed:
		return
	if _emit_logs:
		print(
			"SCENARIO: PASS name=%s context=%s"
			% [String(name), JSON.stringify(context)]
		)


## Marks the scenario successful and finishes with code 0.
func complete_success(context: Dictionary = {}) -> void:
	if not _armed or _completed:
		return
	if has_failed():
		finish(context)
		return
	pass_check(&"scenario_complete", context)
	finish(context)


## Emits the final exit marker and optionally quits with the chosen status.
func finish(context: Dictionary = {}) -> void:
	if not _armed or _completed:
		return
	_completed = true
	var detail: String = "SCENARIO: EXIT code=%d failures=%d" % [
		_exit_code,
		_failures.size(),
	]
	if not context.is_empty():
		detail += " context=%s" % JSON.stringify(context)
	if _emit_logs:
		print(detail)
	scenario_completed.emit(get_status())
	if _exit_on_complete:
		call_deferred("_quit_with_status")


## Emits the final exit marker and quits even when the scenario is non-terminal.
func finish_and_quit(context: Dictionary = {}) -> void:
	if not _armed:
		return
	_exit_on_complete = true
	finish(context)


## Returns a status snapshot suitable for reports.
func get_status() -> Dictionary:
	return {
		"armed": _armed,
		"completed": _completed,
		"emit_logs": _emit_logs,
		"scenario_id": String(_scenario_id),
		"exit_code": _exit_code,
		"failures": _failures.duplicate(true),
	}


func _quit_with_status() -> void:
	var tree: SceneTree = get_tree()
	if tree != null:
		tree.quit(_exit_code)


func _print_fail(failure: Dictionary) -> void:
	print(
		"SCENARIO: FAIL code=%d name=%s message=%s context=%s"
		% [
			int(failure.get("code", SCENARIO_FAILURE)),
			str(failure.get("name", "")),
			str(failure.get("message", "")),
			JSON.stringify(failure.get("context", {})),
		]
	)
