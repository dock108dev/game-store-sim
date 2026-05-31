## Parses automation CLI flags and starts scenarios after boot succeeds.
extends Node

signal automation_started(config: Dictionary)
signal automation_completed(result: Dictionary)

const DEFAULT_SCENARIO_ID: String = "fresh_install_smoke"
const SUPPORTED_SCENARIOS: Array[String] = [
	"bad_state_resistance",
	"economy_loop_seed_001",
	"fresh_install_smoke",
	"layout_torture",
	"long_day_soak",
	"save_reload_smoke",
	"smoke",
	"tutorial_full",
]
const SCENARIO_RUNNER_SCRIPT_PATH: String = "res://tests/automation/scenario_runner.gd"
const TIME_AUTOMATION_CONTROLLER_SCRIPT: GDScript = preload(
	"res://game/scripts/systems/time_automation_controller.gd"
)
# Automation accepts legacy 2x/4x CLI values, but the gameplay clock only
# supports TimeSystem tiers. Clamp upward so requested speed never runs slower
# than the automation caller asked for, and expose that in the parsed config.
const SUPPORTED_SPEEDS: Dictionary = {
	"1x":
	{
		"requested_multiplier": 1.0,
		"speed_multiplier": 1.0,
		"speed_tier": 1,
		"clamped": false,
	},
	"2x":
	{
		"requested_multiplier": 2.0,
		"speed_multiplier": 3.0,
		"speed_tier": 3,
		"clamped": true,
	},
	"3x":
	{
		"requested_multiplier": 3.0,
		"speed_multiplier": 3.0,
		"speed_tier": 3,
		"clamped": false,
	},
	"4x":
	{
		"requested_multiplier": 4.0,
		"speed_multiplier": 6.0,
		"speed_tier": 6,
		"clamped": true,
	},
	"6x":
	{
		"requested_multiplier": 6.0,
		"speed_multiplier": 6.0,
		"speed_tier": 6,
		"clamped": false,
	},
}
const AUTOMATION_FLAGS: Array[String] = [
	"--scenario",
	"--seed",
	"--fresh-save",
	"--record-screenshots",
	"--record-video",
	"--exit-on-complete",
	"--speed",
]

var _config: Dictionary = {}
var _errors: Array[Dictionary] = []
var _enabled: bool = false
var _started: bool = false


func _ready() -> void:
	var parsed: Dictionary = parse_cli_args(OS.get_cmdline_user_args())
	_config = parsed.get("config", {}) as Dictionary
	_errors = parsed.get("errors", []) as Array[Dictionary]
	_enabled = bool(_config.get("enabled", false)) or not _errors.is_empty()
	if _enabled and _errors.is_empty():
		_prepare_fresh_save_root_early()
	if _enabled:
		_print_resolution()


## Parses Godot user command-line args into validated automation config.
func parse_cli_args(args: PackedStringArray) -> Dictionary:
	var config: Dictionary = _default_config()
	var errors: Array[Dictionary] = []
	var saw_automation_flag: bool = false
	var i: int = 0
	while i < args.size():
		var arg: String = args[i]
		if arg == "--test-mode":
			config["enabled"] = true
			i += 1
			continue
		var parsed_flag: Dictionary = _parse_flag_value(args, i)
		var flag: String = str(parsed_flag.get("flag", ""))
		if not AUTOMATION_FLAGS.has(flag):
			i += 1
			continue
		saw_automation_flag = true
		var value: String = str(parsed_flag.get("value", ""))
		var consumed: int = int(parsed_flag.get("consumed", 1))
		_apply_flag(config, errors, flag, value, parsed_flag)
		i += consumed
	if saw_automation_flag and not bool(config.get("enabled", false)):
		errors.append(
			_validation_error(
				"missing_flag", "--test-mode", "", "automation flags require --test-mode", config
			)
		)
	if bool(config.get("enabled", false)):
		_finalize_config(config, errors)
	return {"config": config, "errors": errors}


## Returns true when boot should skip the main menu and enter automation.
func should_take_over_boot() -> bool:
	return _enabled


## Starts the selected automation scenario after boot validation completes.
func handle_boot_completed() -> void:
	if _started:
		return
	_started = true
	if not _errors.is_empty():
		_fail_validation_errors()
		return
	if not _check_required_services():
		return
	ScenarioExit.arm(_config)
	_apply_pre_gameplay_config()
	if ScenarioExit.has_failed():
		ScenarioExit.finish()
		return
	automation_started.emit(get_config())
	call_deferred("_open_main_menu_and_run_selected_scenario")


## Returns the current automation config snapshot.
func get_config() -> Dictionary:
	return _config.duplicate(true)


## Returns validation errors from startup parsing.
func get_validation_errors() -> Array[Dictionary]:
	return _errors.duplicate(true)


func _default_config() -> Dictionary:
	return {
		"enabled": false,
		"scenario_id": "",
		"scenario_explicit": false,
		"seed": "automation_default",
		"fresh_save": false,
		"fresh_save_root": "",
		"record_screenshots": false,
		"record_video": false,
		"record_video_mode": "off",
		"record_video_reason": "",
		"exit_on_complete": false,
		"speed": "1x",
		"speed_requested_multiplier": 1.0,
		"speed_multiplier": 1.0,
		"speed_tier": TimeSystem.SpeedTier.NORMAL,
		"speed_clamped": false,
	}


func _parse_flag_value(args: PackedStringArray, index: int) -> Dictionary:
	var arg: String = args[index]
	if arg.contains("="):
		var parts: PackedStringArray = arg.split("=", true, 1)
		return {"flag": parts[0], "value": parts[1], "consumed": 1}
	var value: String = ""
	var consumed: int = 1
	if index + 1 < args.size() and not args[index + 1].begins_with("--"):
		value = args[index + 1]
		consumed = 2
	return {"flag": arg, "value": value, "consumed": consumed}


func _apply_flag(
	config: Dictionary,
	errors: Array[Dictionary],
	flag: String,
	value: String,
	parsed_flag: Dictionary
) -> void:
	match flag:
		"--scenario":
			if value.is_empty():
				errors.append(
					_validation_error("missing_value", flag, value, "scenario id required", config)
				)
			else:
				config["scenario_id"] = value
				config["scenario_explicit"] = true
		"--seed":
			if value.is_empty():
				errors.append(
					_validation_error("missing_value", flag, value, "seed value required", config)
				)
			else:
				config["seed"] = value
		"--fresh-save":
			config["fresh_save"] = true
			config["fresh_save_root"] = value
		"--record-screenshots":
			config["record_screenshots"] = true
		"--record-video":
			config["record_video"] = true
			config["record_video_mode"] = "unsupported_non_movie"
			config["record_video_reason"] = (
				"Video capture requires the Movie Maker scenario runner; "
				+ "standard automation scenarios do not record video."
			)
		"--exit-on-complete":
			config["exit_on_complete"] = true
		"--speed":
			_apply_speed(config, errors, flag, value)
		_:
			errors.append(
				_validation_error(
					"unsupported_flag",
					flag,
					str(parsed_flag.get("value", "")),
					"unsupported automation flag",
					config
				)
			)


func _apply_speed(
	config: Dictionary, errors: Array[Dictionary], flag: String, value: String
) -> void:
	if not SUPPORTED_SPEEDS.has(value):
		errors.append(
			_validation_error(
				"invalid_value",
				flag,
				value,
				"accepted values: %s" % _join_strings(SUPPORTED_SPEEDS.keys()),
				config
			)
		)
		return
	var speed_config: Dictionary = SUPPORTED_SPEEDS[value] as Dictionary
	config["speed"] = value
	config["speed_requested_multiplier"] = float(speed_config.get("requested_multiplier", 1.0))
	config["speed_multiplier"] = float(speed_config.get("speed_multiplier", 1.0))
	config["speed_tier"] = int(speed_config.get("speed_tier", TimeSystem.SpeedTier.NORMAL))
	config["speed_clamped"] = bool(speed_config.get("clamped", false))


func _finalize_config(config: Dictionary, errors: Array[Dictionary]) -> void:
	if str(config.get("scenario_id", "")).is_empty():
		config["scenario_id"] = DEFAULT_SCENARIO_ID
		config["scenario_defaulted"] = true
	else:
		config["scenario_defaulted"] = false
	var scenario_id: String = str(config.get("scenario_id", ""))
	if not SUPPORTED_SCENARIOS.has(scenario_id):
		errors.append(
			_validation_error(
				"invalid_value",
				"--scenario",
				scenario_id,
				"accepted values: %s" % _join_strings(SUPPORTED_SCENARIOS),
				config
			)
		)
	if bool(config.get("fresh_save", false)):
		var root: String = str(config.get("fresh_save_root", ""))
		if root.is_empty():
			root = _default_fresh_save_root(config)
		elif UserDataPaths != null:
			root = UserDataPaths.resolve_test_run_root(root)
		if root.is_empty():
			errors.append(
				_validation_error(
					"invalid_value",
					"--fresh-save",
					str(config.get("fresh_save_root", "")),
					"fresh-save root must be under user://test_runs/",
					config
				)
			)
		config["fresh_save_root"] = root


func _default_fresh_save_root(config: Dictionary) -> String:
	var scenario_id: String = str(config.get("scenario_id", DEFAULT_SCENARIO_ID))
	var seed_text: String = str(config.get("seed", "automation_default"))
	return (
		"user://test_runs/%s_%s"
		% [
			_fresh_save_segment(scenario_id),
			_fresh_save_segment(seed_text),
		]
	)


func _fresh_save_segment(raw: String) -> String:
	var out: String = UserDataPaths.sanitize_run_id(raw)
	if out.is_empty():
		return "default"
	return out.substr(0, 64)


func _validation_error(
	code: String, flag: String, value: String, message: String, config: Dictionary
) -> Dictionary:
	return {
		"type": "automation_error",
		"code": code,
		"flag": flag,
		"value": value,
		"message": message,
		"scenario_id": _scenario_context(config),
		"default_scenario": DEFAULT_SCENARIO_ID,
	}


func _fail_validation_errors() -> void:
	var config_for_exit: Dictionary = _config.duplicate(true)
	config_for_exit["scenario_id"] = str(config_for_exit.get("scenario_id", DEFAULT_SCENARIO_ID))
	ScenarioExit.arm(config_for_exit)
	for error: Dictionary in _errors:
		_print_machine_line(error)
		ScenarioExit.fail(
			ScenarioExit.CONFIG_ERROR,
			StringName(str(error.get("code", "config_error"))),
			str(error.get("message", "")),
			error
		)
	ScenarioExit.finish()


func _check_required_services() -> bool:
	var missing: Array[String] = []
	if GameManager == null:
		missing.append("GameManager")
	if EventBus == null:
		missing.append("EventBus")
	if ScenarioExit == null:
		missing.append("ScenarioExit")
	if UserDataPaths == null:
		missing.append("UserDataPaths")
	if missing.is_empty():
		return true
	var context: Dictionary = {"missing_services": missing}
	ScenarioExit.arm(_config)
	ScenarioExit.fail(
		ScenarioExit.CONFIG_ERROR,
		&"missing_required_services",
		"missing required services: %s" % _join_strings(missing),
		context
	)
	ScenarioExit.finish()
	return false


func _apply_pre_gameplay_config() -> void:
	GameRandom.enable_test_mode(str(_config.get("seed", "automation_default")))
	if bool(_config.get("fresh_save", false)):
		var root: String = str(_config.get("fresh_save_root", ""))
		if UserDataPaths.get_automation_root() != root:
			var err: Error = UserDataPaths.configure_automation_root(root, true)
			if err != OK:
				ScenarioExit.fail(
					ScenarioExit.CONFIG_ERROR,
					&"fresh_save_root_failed",
					"failed to prepare fresh-save root '%s'" % root,
					{"error": error_string(err), "fresh_save_root": root}
				)
				return
		if ScenarioExit.has_failed():
			return
		Settings.settings_path = UserDataPaths.settings_path()
	_print_startup_log()


func _prepare_fresh_save_root_early() -> void:
	if not bool(_config.get("fresh_save", false)):
		return
	var root: String = str(_config.get("fresh_save_root", ""))
	var err: Error = UserDataPaths.configure_automation_root(root, true)
	if err != OK:
		_errors.append(
			_validation_error(
				"path_error",
				"--fresh-save",
				root,
				"failed to prepare fresh-save root: %s" % error_string(err),
				_config
			)
		)


func _on_gameplay_ready() -> void:
	if EventBus.gameplay_ready.is_connected(_on_gameplay_ready):
		EventBus.gameplay_ready.disconnect(_on_gameplay_ready)
	_apply_gameplay_speed()
	var result: Dictionary = {
		"scenario_id": str(_config.get("scenario_id", "")),
		"record_screenshots": bool(_config.get("record_screenshots", false)),
		"record_video": bool(_config.get("record_video", false)),
		"record_video_mode": str(_config.get("record_video_mode", "off")),
		"record_video_reason": str(_config.get("record_video_reason", "")),
	}
	automation_completed.emit(result)
	ScenarioExit.complete_success(result)


func _run_selected_scenario() -> void:
	var runner_script: GDScript = load(SCENARIO_RUNNER_SCRIPT_PATH)
	if runner_script == null:
		ScenarioExit.fail(
			ScenarioExit.CONFIG_ERROR,
			&"scenario_runner_missing",
			"scenario runner unavailable",
			{"path": SCENARIO_RUNNER_SCRIPT_PATH}
		)
		ScenarioExit.finish()
		return
	var runner: Node = runner_script.new()
	add_child(runner)
	var options: Dictionary = _config.duplicate(true)
	var result: Dictionary = await runner.call(
		"run_by_id", str(_config.get("scenario_id", DEFAULT_SCENARIO_ID)), options
	)
	runner.queue_free()
	automation_completed.emit(result)
	if bool(result.get("ok", false)):
		ScenarioExit.complete_success(result)
	else:
		ScenarioExit.fail(
			ScenarioExit.SCENARIO_FAILURE,
			&"scenario_failed",
			str(result.get("summary", "scenario failed")),
			result
		)
		ScenarioExit.finish(result)


func _open_main_menu_and_run_selected_scenario() -> void:
	GameManager.change_state(GameManager.State.MAIN_MENU)
	await SceneRouter.route_to(&"main_menu")
	await get_tree().process_frame
	_run_selected_scenario()


func _apply_gameplay_speed() -> void:
	var tier: int = int(_config.get("speed_tier", TimeSystem.SpeedTier.NORMAL))
	var time_system: TimeSystem = GameManager.get_time_system()
	if time_system == null:
		EventBus.time_speed_requested.emit(tier)
		return
	var controller = TIME_AUTOMATION_CONTROLLER_SCRIPT.new()
	controller.initialize(time_system)
	controller.request_speed(tier as TimeSystem.SpeedTier)
	controller.free()


func _print_resolution() -> void:
	var payload: Dictionary = {
		"type": "automation_config",
		"enabled": bool(_config.get("enabled", false)),
		"scenario_id": str(_config.get("scenario_id", DEFAULT_SCENARIO_ID)),
		"errors": _errors,
	}
	_print_machine_line(payload)


func _print_startup_log() -> void:
	var payload: Dictionary = {
		"type": "automation_start",
		"scenario_id": str(_config.get("scenario_id", "")),
		"seed": str(_config.get("seed", "")),
		"fresh_save_root": str(_config.get("fresh_save_root", "")),
		"speed": str(_config.get("speed", "")),
		"speed_tier": int(_config.get("speed_tier", TimeSystem.SpeedTier.NORMAL)),
		"speed_clamped": bool(_config.get("speed_clamped", false)),
		"record_screenshots": bool(_config.get("record_screenshots", false)),
		"record_video": bool(_config.get("record_video", false)),
		"record_video_mode": str(_config.get("record_video_mode", "off")),
		"record_video_reason": str(_config.get("record_video_reason", "")),
		"exit_on_complete": bool(_config.get("exit_on_complete", false)),
	}
	_print_machine_line(payload)


func _print_machine_line(payload: Dictionary) -> void:
	print("AUTOMATION: %s" % JSON.stringify(payload))


## Returns true once the current runtime tree contains a player node.
func is_player_present() -> bool:
	return get_tree().get_nodes_in_group(&"player").size() > 0


## Returns true once the active viewport has a current 3D camera.
func is_current_camera_present() -> bool:
	var viewport: Viewport = get_viewport()
	return viewport != null and viewport.get_camera_3d() != null


## Returns true once the gameplay HUD scene has entered the runtime tree.
func is_hud_present() -> bool:
	var current: Node = get_tree().current_scene
	return current != null and current.find_child("HUD", true, false) != null


## Returns true once the gameplay shell has a world and loaded store subtree.
func is_mall_or_store_scene_present() -> bool:
	var current: Node = get_tree().current_scene
	if current == null:
		return false
	var world: Node = current.get_node_or_null("GameWorld")
	if world == null:
		world = current.find_child("GameWorld", true, false)
	if world == null:
		return false
	var store_container: Node = world.get_node_or_null("StoreContainer")
	return store_container != null and store_container.get_child_count() > 0


## Returns true when a blocking popup, fatal panel, or modal focus remains active.
func has_blocking_error_or_modal() -> bool:
	return not get_blocking_error_or_modal_reason().is_empty()


## Returns the first visible blocker reason, or an empty string when clear.
func get_blocking_error_or_modal_reason() -> String:
	if InputFocus != null and InputFocus.current() == InputFocus.CTX_MODAL:
		return "input_focus_modal"
	return _visible_blocker_reason(get_tree().current_scene)


func _visible_blocker_reason(node: Node) -> String:
	if node == null:
		return ""
	if node is AcceptDialog and (node as AcceptDialog).visible:
		return str(node.get_path())
	if node.name == "ErrorPanel" and node is CanvasItem and (node as CanvasItem).visible:
		return str(node.get_path())
	for child: Node in node.get_children():
		var reason: String = _visible_blocker_reason(child)
		if not reason.is_empty():
			return reason
	return ""


func _scenario_context(config: Dictionary) -> String:
	var scenario_id: String = str(config.get("scenario_id", ""))
	if scenario_id.is_empty():
		return DEFAULT_SCENARIO_ID
	return scenario_id


func _join_strings(values: Array) -> String:
	var text: PackedStringArray = []
	for value: Variant in values:
		text.append(str(value))
	return ", ".join(text)
