extends GutTest


const TIME_AUTOMATION_CONTROLLER_SCRIPT: GDScript = preload(
	"res://game/scripts/systems/time_automation_controller.gd"
)

var _time: TimeSystem
var _controller


func before_each() -> void:
	_time = TimeSystem.new()
	add_child_autofree(_time)
	_time.initialize()
	_controller = TIME_AUTOMATION_CONTROLLER_SCRIPT.new()
	add_child_autofree(_controller)
	_controller.initialize(_time)


func test_nested_pause_restores_previous_requested_speed() -> void:
	_time.set_speed(TimeSystem.SpeedTier.FAST)

	_controller.pause("outer")
	_controller.pause("inner")

	assert_eq(_controller.get_pause_depth(), 2)
	assert_eq(_time.get_requested_speed_tier(), TimeSystem.SpeedTier.PAUSED)
	assert_almost_eq(_time.get_effective_speed_multiplier(), 0.0, 0.01)

	_controller.resume("inner")

	assert_eq(_controller.get_pause_depth(), 1)
	assert_eq(_time.get_requested_speed_tier(), TimeSystem.SpeedTier.PAUSED)
	assert_almost_eq(_time.get_effective_speed_multiplier(), 0.0, 0.01)

	_controller.resume("outer")

	assert_eq(_controller.get_pause_depth(), 0)
	assert_eq(_time.get_requested_speed_tier(), TimeSystem.SpeedTier.FAST)
	assert_almost_eq(_time.get_effective_speed_multiplier(), 3.0, 0.01)


func test_pause_overrides_auto_slow_and_resume_preserves_requested_speed() -> void:
	_time.set_speed(TimeSystem.SpeedTier.ULTRA)
	_time.push_auto_slow("event")
	assert_almost_eq(_time.get_effective_speed_multiplier(), 1.0, 0.01)

	_controller.pause()

	assert_eq(_time.get_requested_speed_tier(), TimeSystem.SpeedTier.PAUSED)
	assert_almost_eq(_time.get_effective_speed_multiplier(), 0.0, 0.01)

	_controller.resume()

	assert_eq(_time.get_requested_speed_tier(), TimeSystem.SpeedTier.ULTRA)
	assert_almost_eq(_time.get_effective_speed_multiplier(), 1.0, 0.01)
	_time.pop_auto_slow("event")
	assert_almost_eq(_time.get_effective_speed_multiplier(), 6.0, 0.01)


func test_step_minutes_advances_while_frame_time_is_paused() -> void:
	_time.set_speed(TimeSystem.SpeedTier.PAUSED)
	_time.game_time_minutes = 525.0
	_time.current_phase = TimeSystem.DayPhase.PRE_OPEN
	_time.current_hour = 8
	_time.set("_last_emitted_hour", 8)

	var actual: float = _controller.step_minutes(20.0)

	assert_almost_eq(actual, 20.0, 0.01)
	assert_almost_eq(_time.game_time_minutes, 545.0, 0.01)
	assert_eq(_time.current_hour, 9)
	assert_eq(_time.current_phase, TimeSystem.DayPhase.MORNING_RAMP)
	assert_true(_time.is_paused())


func test_step_stop_before_day_end_clamps_without_emitting_day_end() -> void:
	var ended_days: Array[int] = []
	EventBus.day_ended.connect(func(day: int) -> void: ended_days.append(day))
	_time.game_time_minutes = 1015.0
	_time.current_hour = 16
	_time.set("_last_emitted_hour", 16)

	var actual: float = _controller.step_minutes(
		30.0,
		TIME_AUTOMATION_CONTROLLER_SCRIPT.StepMode.STOP_BEFORE_DAY_END
	)

	assert_almost_eq(actual, 4.999, 0.001)
	assert_lt(_time.game_time_minutes, _time.get_day_end_minutes())
	assert_false(_time.is_day_ended())
	assert_true(ended_days.is_empty())


func test_step_allows_day_end_when_requested() -> void:
	var ended_days: Array[int] = []
	EventBus.day_ended.connect(func(day: int) -> void: ended_days.append(day))
	_time.game_time_minutes = 1015.0
	_time.current_hour = 16
	_time.set("_last_emitted_hour", 16)

	var actual: float = _controller.step_minutes(
		30.0,
		TIME_AUTOMATION_CONTROLLER_SCRIPT.StepMode.ALLOW_DAY_END
	)

	assert_almost_eq(actual, 30.0, 0.01)
	assert_true(_time.is_day_ended())
	assert_eq(ended_days, [1])


func test_step_respects_store_session_day_end_owner_by_default() -> void:
	var owner := Node.new()
	owner.add_to_group("store_session_controller")
	add_child_autofree(owner)
	_time.game_time_minutes = 1015.0
	_time.current_hour = 16
	_time.set("_last_emitted_hour", 16)

	var actual: float = _controller.step_minutes(30.0)

	assert_almost_eq(actual, 4.999, 0.001)
	assert_false(_time.is_day_ended())
	assert_lt(_time.game_time_minutes, _time.get_day_end_minutes())
