extends GutTest

var _panel: Node
var _player: Node


func before_each() -> void:
	_panel = load("res://scenes/ui/pause_menu_panel.tscn").instantiate()
	_player = Node.new()
	add_child_autofree(_panel)
	add_child_autofree(_player)


func test_pause_menu_panel_starts_hidden_with_ui_language() -> void:
	assert_false(_panel.visible)
	assert_false(_panel.is_open())
	assert_eq(_panel.get_transition_state(), "closed")
	assert_true(_panel.has_ui_component_language())
	assert_true(_panel.has_accessibility_floor())


func test_pause_menu_panel_alpha_layout_is_readable() -> void:
	var panel_container := _panel.get_node("CenterContainer/PanelContainer") as Control
	assert_gte(panel_container.custom_minimum_size.x, 600.0)
	assert_gte(panel_container.custom_minimum_size.y, 500.0)
	assert_gte(_font_size(_panel.title_label), 26)
	assert_gte(_font_size(_panel.status_label), 18)
	for button in [
		_panel.resume_button,
		_panel.start_button,
		_panel.settings_button,
		_panel.save_load_button,
		_panel.main_menu_button,
		_panel.quit_button,
	]:
		assert_gte(button.custom_minimum_size.x, 220.0)
		assert_gte(button.custom_minimum_size.y, 48.0)
		assert_gte(_font_size(button), 18)


func test_pause_menu_opens_pause_and_resumes_with_mouse_capture() -> void:
	assert_true(_panel.open_pause(_player))

	assert_true(_panel.is_open())
	assert_true(_panel.is_pause_mode())
	assert_eq(_panel.get_requested_mouse_mode(), Input.MOUSE_MODE_VISIBLE)
	assert_true(_panel.get_requested_pause_state())
	assert_true(_panel.resume_button.visible)
	assert_false(_panel.start_button.visible)
	assert_true(_panel.has_modal_focus())

	assert_true(_panel.resume_game())
	assert_false(_panel.is_open())
	assert_eq(_panel.get_requested_mouse_mode(), Input.MOUSE_MODE_CAPTURED)
	assert_false(_panel.get_requested_pause_state())
	assert_eq(_panel.get_last_action(), "resume")


func test_pause_menu_opens_main_menu_and_start_returns_to_game() -> void:
	assert_true(_panel.open_main_menu(_player))

	assert_true(_panel.is_open())
	assert_true(_panel.is_main_menu_mode())
	assert_eq(_panel.title_label.text, "Game Store Sim")
	assert_true(_panel.start_button.visible)
	assert_false(_panel.resume_button.visible)

	assert_true(_panel.start_game())
	assert_false(_panel.is_open())
	assert_eq(_panel.get_last_action(), "start")


func test_pause_menu_requests_settings_save_load_and_quit() -> void:
	var signal_counts := {
		"settings": 0,
		"save_load": 0,
		"quit": 0,
	}
	_panel.settings_requested.connect(func(): signal_counts["settings"] += 1)
	_panel.save_load_requested.connect(func(): signal_counts["save_load"] += 1)
	_panel.quit_requested.connect(func(): signal_counts["quit"] += 1)

	assert_true(_panel.open_pause(_player))
	assert_true(_panel.request_settings())
	assert_eq(signal_counts["settings"], 1)
	assert_eq(_panel.get_last_action(), "settings")
	assert_false(_panel.is_open())

	assert_true(_panel.open_pause(_player))
	assert_true(_panel.request_save_load())
	assert_eq(signal_counts["save_load"], 1)
	assert_eq(_panel.get_last_action(), "save_load")
	assert_false(_panel.is_open())

	assert_true(_panel.open_pause(_player))
	assert_true(_panel.request_quit())
	assert_eq(signal_counts["quit"], 1)
	assert_true(_panel.has_quit_request())
	assert_true(_panel.is_open())
	assert_string_contains(_panel.status_label.text, "Quit requested")


func _font_size(control: Control) -> int:
	return int(control.get("theme_override_font_sizes/font_size"))
