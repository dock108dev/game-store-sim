extends GutTest

var _panel: SettingsPanel
var _player: _SettingsPlayer
const TEST_SETTINGS_PATH := "user://settings_panel_test_profile.json"


func before_each() -> void:
	_remove_test_settings_file()
	_panel = load("res://scenes/ui/settings_panel.tscn").instantiate()
	_panel.set_settings_file_path(TEST_SETTINGS_PATH)
	_player = _SettingsPlayer.new()
	add_child_autofree(_panel)
	add_child_autofree(_player)


func after_each() -> void:
	_remove_test_settings_file()


func test_settings_panel_starts_hidden() -> void:
	assert_false(_panel.visible)
	assert_false(_panel.is_open())
	assert_eq(_panel.get_transition_state(), "closed")
	assert_true(_panel.has_ui_component_language())
	assert_true(_panel.has_accessibility_floor())


func test_settings_panel_opens_with_mouse_focus_and_player_values() -> void:
	assert_true(_panel.open_for_player(_player))

	assert_true(_panel.is_open())
	assert_eq(_panel.get_active_player(), _player)
	assert_eq(_panel.get_transition_state(), "open")
	assert_eq(_panel.get_requested_mouse_mode(), Input.MOUSE_MODE_VISIBLE)
	assert_true(_panel.has_modal_focus())
	assert_eq(get_viewport().gui_get_focus_owner(), _panel.close_button)
	assert_eq(_panel.close_button.focus_mode, Control.FOCUS_ALL)
	assert_string_contains(_panel.sensitivity_label.text, "0.0025")
	assert_false(_panel.invert_check_box.button_pressed)
	assert_string_contains(_panel.master_volume_label.text, "80%")
	assert_string_contains(_panel.controls_summary_label.text, "Left Click")


func test_settings_panel_updates_sensitivity_invert_and_window_mode() -> void:
	assert_true(_panel.open_for_player(_player))

	assert_true(_panel.increase_sensitivity())
	assert_almost_eq(_player.mouse_sensitivity, 0.003, 0.00001)
	assert_string_contains(_panel.sensitivity_label.text, "0.0030")

	assert_true(_panel.decrease_sensitivity())
	assert_almost_eq(_player.mouse_sensitivity, 0.0025, 0.00001)

	assert_true(_panel.set_invert_look(true))
	assert_true(_player.invert_look)
	assert_true(_panel.invert_check_box.button_pressed)

	var starting_mode := _panel.get_requested_window_mode()
	assert_true(_panel.toggle_window_mode())
	assert_ne(_panel.get_requested_window_mode(), starting_mode)


func test_settings_panel_exposes_production_settings_sections() -> void:
	assert_true(_panel.open_for_player(_player))

	var summary := _panel.get_settings_summary_text()
	assert_string_contains(summary, "Audio master")
	assert_string_contains(summary, "Display")
	assert_string_contains(summary, "Controls remappable")
	assert_string_contains(summary, "Accessibility")
	assert_not_null(_panel.reset_defaults_button)
	assert_not_null(_panel.reset_bindings_button)


func test_settings_panel_updates_audio_display_accessibility_and_reset_defaults() -> void:
	assert_true(_panel.open_for_player(_player))

	assert_true(_panel.adjust_master_volume(10))
	assert_eq(_player.master_volume, 90)
	assert_string_contains(_panel.master_volume_label.text, "90%")

	assert_true(_panel.adjust_music_volume(-20))
	assert_eq(_player.music_volume, 50)

	assert_true(_panel.adjust_sfx_volume(-10))
	assert_eq(_player.sfx_volume, 75)

	assert_true(_panel.adjust_resolution_scale(-15))
	assert_eq(_player.resolution_scale, 85)
	assert_string_contains(_panel.resolution_scale_label.text, "85%")

	assert_true(_panel.adjust_text_scale(10))
	assert_eq(_player.text_scale, 110)

	assert_true(_panel.set_high_contrast(true))
	assert_true(_player.high_contrast_ui)
	assert_true(_panel.high_contrast_check_box.button_pressed)

	assert_true(_panel.set_reduce_motion(true))
	assert_true(_player.reduce_motion)
	assert_true(_panel.reduce_motion_check_box.button_pressed)

	assert_true(_panel.reset_bindings_to_defaults())
	assert_true(bool(_panel.get_settings_data().get("input_bindings_reset")))

	assert_true(_panel.reset_defaults())
	assert_eq(_player.master_volume, 80)
	assert_eq(_player.music_volume, 70)
	assert_eq(_player.sfx_volume, 85)
	assert_eq(_player.resolution_scale, 100)
	assert_eq(_player.text_scale, 100)
	assert_false(_player.high_contrast_ui)
	assert_false(_player.reduce_motion)


func test_settings_panel_persists_profile_between_instances() -> void:
	assert_true(_panel.open_for_player(_player))
	assert_true(_panel.adjust_master_volume(15))
	assert_true(_panel.adjust_resolution_scale(-10))
	assert_true(_panel.set_reduce_motion(true))
	assert_true(_panel.set_invert_look(true))
	assert_true(FileAccess.file_exists(TEST_SETTINGS_PATH))

	var next_panel: SettingsPanel = load("res://scenes/ui/settings_panel.tscn").instantiate()
	next_panel.set_settings_file_path(TEST_SETTINGS_PATH)
	var next_player := _SettingsPlayer.new()
	add_child_autofree(next_panel)
	add_child_autofree(next_player)

	assert_true(next_panel.open_for_player(next_player))
	assert_eq(next_player.master_volume, 95)
	assert_eq(next_player.resolution_scale, 90)
	assert_true(next_player.reduce_motion)
	assert_true(next_player.invert_look)
	assert_string_contains(next_panel.get_last_save_result(), "loaded")


func test_settings_panel_closes_to_captured_mouse_and_releases_focus() -> void:
	assert_true(_panel.open_for_player(_player))

	assert_true(_panel.close())

	assert_false(_panel.is_open())
	assert_false(_panel.visible)
	assert_eq(_panel.get_transition_state(), "closed")
	assert_eq(_panel.get_requested_mouse_mode(), Input.MOUSE_MODE_CAPTURED)
	assert_false(_panel.has_modal_focus())


func test_input_binding_catalog_has_remappable_core_actions() -> void:
	var json_text := FileAccess.get_file_as_string("res://data/input/default_input_bindings.json")
	var parsed: Dictionary = JSON.parse_string(json_text)
	var bindings: Array = parsed.get("bindings", [])
	var actions := {}
	for binding in bindings:
		if typeof(binding) == TYPE_DICTIONARY:
			var row: Dictionary = binding
			actions[str(row.get("action", ""))] = row

	for action in ["move_forward", "move_back", "move_left", "move_right", "interact", "ui_cancel"]:
		assert_true(actions.has(action), "%s should be listed" % action)
		assert_true(bool(actions[action].get("remappable", false)), "%s should be remappable" % action)
		assert_false(str(actions[action].get("display_name", "")).is_empty(), "%s needs display text" % action)
		assert_false(str(actions[action].get("default_key", "")).is_empty(), "%s needs a default key" % action)


func _remove_test_settings_file() -> void:
	if FileAccess.file_exists(TEST_SETTINGS_PATH):
		DirAccess.remove_absolute(TEST_SETTINGS_PATH)


class _SettingsPlayer:
	extends Node

	var mouse_sensitivity: float = 0.0025
	var invert_look: bool = false
	var master_volume: int = 80
	var music_volume: int = 70
	var sfx_volume: int = 85
	var resolution_scale: int = 100
	var text_scale: int = 100
	var high_contrast_ui: bool = false
	var reduce_motion: bool = false

	func get_mouse_sensitivity() -> float:
		return mouse_sensitivity

	func set_mouse_sensitivity(value: float) -> void:
		mouse_sensitivity = value

	func get_invert_look() -> bool:
		return invert_look

	func set_invert_look(value: bool) -> void:
		invert_look = value

	func apply_settings_profile(settings: Dictionary) -> void:
		master_volume = int(settings.get("master_volume", master_volume))
		music_volume = int(settings.get("music_volume", music_volume))
		sfx_volume = int(settings.get("sfx_volume", sfx_volume))
		resolution_scale = int(settings.get("resolution_scale", resolution_scale))
		text_scale = int(settings.get("text_scale", text_scale))
		high_contrast_ui = bool(settings.get("high_contrast", high_contrast_ui))
		reduce_motion = bool(settings.get("reduce_motion", reduce_motion))
		mouse_sensitivity = float(settings.get("look_sensitivity", mouse_sensitivity))
		invert_look = bool(settings.get("invert_look", invert_look))
