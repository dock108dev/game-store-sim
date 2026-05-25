extends GutTest

const RUNNER_SCRIPT: GDScript = preload(
	"res://game/autoload/automation_runner.gd"
)

const AUTOMATION_TEST_RUN: String = "automation_runner_test"


func after_each() -> void:
	GameRandom.disable_test_mode()
	UserDataPaths.cleanup_active_test_run()
	UserDataPaths.reset_for_normal_play()


func test_cli_without_flags_is_inert() -> void:
	var result: Dictionary = _parse([])
	var config: Dictionary = result.get("config", {}) as Dictionary

	assert_false(bool(config.get("enabled", true)))
	assert_true((result.get("errors", []) as Array).is_empty())


func test_test_mode_defaults_to_fresh_install_smoke() -> void:
	var result: Dictionary = _parse(["--test-mode"])
	var config: Dictionary = result.get("config", {}) as Dictionary

	assert_true(bool(config.get("enabled", false)))
	assert_eq(config.get("scenario_id", ""), "fresh_install_smoke")
	assert_true(bool(config.get("scenario_defaulted", false)))
	assert_true((result.get("errors", []) as Array).is_empty())


func test_full_cli_config_surfaces_capture_and_fresh_save() -> void:
	var result: Dictionary = _parse([
		"--test-mode",
		"--scenario=tutorial_full",
		"--seed",
		"mallcore_001",
		"--fresh-save",
		"--record-screenshots",
		"--record-video",
		"--exit-on-complete",
		"--speed=4x",
	])
	var config: Dictionary = result.get("config", {}) as Dictionary

	assert_eq(config.get("scenario_id", ""), "tutorial_full")
	assert_eq(config.get("seed", ""), "mallcore_001")
	assert_true(bool(config.get("fresh_save", false)))
	assert_string_contains(
		str(config.get("fresh_save_root", "")),
		"user://test_runs/tutorial_full_mallcore_001"
	)
	assert_true(bool(config.get("record_screenshots", false)))
	assert_true(bool(config.get("record_video", false)))
	assert_eq(str(config.get("record_video_mode", "")), "unsupported_non_movie")
	assert_string_contains(str(config.get("record_video_reason", "")), "Movie Maker")
	assert_true(bool(config.get("exit_on_complete", false)))
	assert_eq(config.get("speed", ""), "4x")
	assert_eq(float(config.get("speed_requested_multiplier", 0.0)), 4.0)
	assert_eq(float(config.get("speed_multiplier", 0.0)), 6.0)
	assert_eq(int(config.get("speed_tier", 0)), TimeSystem.SpeedTier.ULTRA)
	assert_true(bool(config.get("speed_clamped", false)))
	assert_true((result.get("errors", []) as Array).is_empty())


func test_invalid_scenario_reports_accepted_values_and_context() -> void:
	var result: Dictionary = _parse([
		"--test-mode",
		"--scenario=missing_route",
	])
	var errors: Array = result.get("errors", []) as Array

	assert_eq(errors.size(), 1)
	assert_eq(errors[0].get("flag", ""), "--scenario")
	assert_eq(errors[0].get("value", ""), "missing_route")
	assert_string_contains(str(errors[0].get("message", "")), "accepted values")
	assert_string_contains(str(errors[0].get("message", "")), "save_reload_smoke")
	assert_eq(errors[0].get("scenario_id", ""), "missing_route")
	assert_eq(errors[0].get("default_scenario", ""), "fresh_install_smoke")


func test_invalid_speed_reports_bad_value_and_accepted_values() -> void:
	var result: Dictionary = _parse([
		"--test-mode",
		"--speed=warp",
	])
	var errors: Array = result.get("errors", []) as Array

	assert_eq(errors.size(), 1)
	assert_eq(errors[0].get("flag", ""), "--speed")
	assert_eq(errors[0].get("value", ""), "warp")
	assert_string_contains(str(errors[0].get("message", "")), "1x")
	assert_string_contains(str(errors[0].get("message", "")), "6x")
	assert_eq(errors[0].get("scenario_id", ""), "fresh_install_smoke")


func test_supported_speed_maps_to_nearest_time_system_tier() -> void:
	var result: Dictionary = _parse([
		"--test-mode",
		"--speed=2x",
	])
	var config: Dictionary = result.get("config", {}) as Dictionary

	assert_eq(config.get("speed", ""), "2x")
	assert_eq(float(config.get("speed_requested_multiplier", 0.0)), 2.0)
	assert_eq(float(config.get("speed_multiplier", 0.0)), 3.0)
	assert_eq(int(config.get("speed_tier", 0)), TimeSystem.SpeedTier.FAST)
	assert_true(bool(config.get("speed_clamped", false)))
	assert_true((result.get("errors", []) as Array).is_empty())


func test_automation_flags_require_test_mode() -> void:
	var result: Dictionary = _parse(["--scenario=fresh_install_smoke"])
	var errors: Array = result.get("errors", []) as Array

	assert_eq(errors.size(), 1)
	assert_eq(errors[0].get("flag", ""), "--test-mode")
	assert_string_contains(str(errors[0].get("message", "")), "require")


func test_project_registers_automation_autoload_after_core_singletons() -> void:
	var source: String = _read_project_file()

	assert_lt(source.find("GameManager="), source.find("AutomationRunner="))
	assert_lt(source.find("EventBus="), source.find("AutomationRunner="))
	assert_lt(source.find("GameRandom="), source.find("AutomationRunner="))
	assert_lt(source.find("AutomationRunner="), source.find("Settings="))


func test_pre_gameplay_config_enables_seeded_game_random() -> void:
	var runner: Node = RUNNER_SCRIPT.new()
	runner.set("_config", {
		"seed": "mallcore_001",
		"speed_multiplier": 1.0,
		"fresh_save": false,
	})

	runner.call("_apply_pre_gameplay_config")

	assert_true(GameRandom.is_test_mode())
	assert_eq(GameRandom.get_root_seed(), "mallcore_001")
	runner.free()


func test_boot_handoff_checks_automation_before_main_menu() -> void:
	var script: GDScript = load("res://game/scripts/core/boot.gd")
	var source: String = script.source_code
	var automation_pos: int = source.find("AutomationRunner.handle_boot_completed()")
	var menu_pos: int = source.find("_transition_to_main_menu()", automation_pos)
	var runner_script: GDScript = load("res://game/autoload/automation_runner.gd")
	var runner_source: String = runner_script.source_code

	assert_gte(automation_pos, 0)
	assert_gt(menu_pos, automation_pos)
	assert_string_contains(runner_source, "SceneRouter.route_to(&\"main_menu\")")


func test_runtime_assertion_helpers_default_false_without_scene() -> void:
	var runner: Node = RUNNER_SCRIPT.new()
	add_child_autofree(runner)

	assert_false(runner.call("is_player_present"))
	assert_false(runner.call("is_current_camera_present"))
	assert_false(runner.call("is_hud_present"))
	assert_false(runner.call("is_mall_or_store_scene_present"))


func test_save_paths_follow_automation_root() -> void:
	var err: Error = UserDataPaths.configure_automation_root(
		AUTOMATION_TEST_RUN,
		true
	)
	assert_eq(err, OK)

	var manager := SaveManager.new()
	assert_eq(
		manager._get_slot_path(2),
		"user://test_runs/automation_runner_test/save_slot_2.json"
	)
	assert_eq(
		UserDataPaths.slot_index_path(),
		"user://test_runs/automation_runner_test/save_index.cfg"
	)
	manager.free()


func _parse(args: Array) -> Dictionary:
	var runner: Node = RUNNER_SCRIPT.new()
	var packed := PackedStringArray(args)
	var result: Dictionary = runner.call("parse_cli_args", packed) as Dictionary
	runner.free()
	return result


func _read_project_file() -> String:
	var file: FileAccess = FileAccess.open("res://project.godot", FileAccess.READ)
	assert_not_null(file)
	if file == null:
		return ""
	var source: String = file.get_as_text()
	file.close()
	return source
