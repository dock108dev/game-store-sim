extends GutTest

var _panel: SettingsPanel
var _player: _SettingsPlayer


func before_each() -> void:
	_panel = load("res://scenes/ui/settings_panel.tscn").instantiate()
	_player = _SettingsPlayer.new()
	add_child_autofree(_panel)
	add_child_autofree(_player)


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


class _SettingsPlayer:
	extends Node

	var mouse_sensitivity: float = 0.0025
	var invert_look: bool = false

	func get_mouse_sensitivity() -> float:
		return mouse_sensitivity

	func set_mouse_sensitivity(value: float) -> void:
		mouse_sensitivity = value

	func get_invert_look() -> bool:
		return invert_look

	func set_invert_look(value: bool) -> void:
		invert_look = value
