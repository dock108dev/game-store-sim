## Automation-facing controller for deterministic TimeSystem operations.
class_name TimeAutomationController
extends Node

enum StepMode { ALLOW_DAY_END, STOP_BEFORE_DAY_END, RESPECT_STORE_SESSION_OWNER }

const DAY_END_EPSILON_MINUTES: float = 0.001

var _time_system: TimeSystem
var _automation_pause_depth: int = 0
var _speed_before_automation_pause: TimeSystem.SpeedTier = TimeSystem.SpeedTier.NORMAL
var _has_saved_speed: bool = false


## Binds the controller to the active TimeSystem.
func initialize(time_system: TimeSystem) -> void:
	_time_system = time_system


## Pauses frame-driven time while preserving the requested speed tier.
func pause(_reason: String = "automation") -> void:
	if _time_system == null:
		return
	if _automation_pause_depth == 0:
		_speed_before_automation_pause = _time_system.get_requested_speed_tier()
		_has_saved_speed = true
		request_speed(TimeSystem.SpeedTier.PAUSED)
	_automation_pause_depth += 1


## Releases one automation pause and restores the prior requested tier at depth zero.
func resume(_reason: String = "automation") -> void:
	if _time_system == null or _automation_pause_depth <= 0:
		return
	_automation_pause_depth -= 1
	if _automation_pause_depth > 0:
		return
	var restore_speed: TimeSystem.SpeedTier = TimeSystem.SpeedTier.NORMAL
	if _has_saved_speed:
		restore_speed = _speed_before_automation_pause
	_has_saved_speed = false
	request_speed(restore_speed)


## Requests a supported TimeSystem speed tier through the runtime signal path.
func request_speed(tier: TimeSystem.SpeedTier) -> void:
	EventBus.time_speed_requested.emit(int(tier))


## Advances explicit in-game minutes and returns the minutes actually advanced.
func step_minutes(
	minutes: float,
	mode: StepMode = StepMode.RESPECT_STORE_SESSION_OWNER
) -> float:
	if _time_system == null or minutes <= 0.0:
		return 0.0
	if _time_system.is_day_ended():
		return 0.0

	var actual_minutes: float = minutes
	if mode == StepMode.STOP_BEFORE_DAY_END:
		actual_minutes = _clamp_before_day_end(minutes)
	elif mode == StepMode.RESPECT_STORE_SESSION_OWNER \
			and _time_system.is_day_end_owned_by_store_session():
		actual_minutes = _clamp_before_day_end(minutes)

	if actual_minutes <= 0.0:
		return 0.0
	_time_system.advance_by_minutes(actual_minutes)
	return actual_minutes


## Returns true when automation has at least one outstanding pause request.
func is_automation_paused() -> bool:
	return _automation_pause_depth > 0


## Returns the current nested automation pause depth.
func get_pause_depth() -> int:
	return _automation_pause_depth


func _clamp_before_day_end(minutes: float) -> float:
	var available: float = _time_system.get_minutes_until_day_end() - DAY_END_EPSILON_MINUTES
	return minf(minutes, maxf(0.0, available))
