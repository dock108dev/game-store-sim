extends CanvasLayer
class_name PauseMenuPanel

const UIComponents := preload("res://scripts/ui/ui_component_library.gd")

signal resume_requested
signal settings_requested
signal save_load_requested
signal main_menu_requested
signal quit_requested
signal start_requested

@onready var modal_root: Control = $CenterContainer
@onready var title_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var mode_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ModeLabel
@onready var resume_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ResumeButton
@onready var start_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/StartButton
@onready var settings_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/SettingsButton
@onready var save_load_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/SaveLoadButton
@onready var main_menu_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/MainMenuButton
@onready var quit_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/QuitButton
@onready var status_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/StatusLabel

var _player: Node = null
var _transition_state: String = "closed"
var _mode: String = "pause"
var _requested_mouse_mode: int = Input.MOUSE_MODE_CAPTURED
var _requested_pause_state: bool = false
var _quit_requested: bool = false
var _last_action: String = ""


func _ready() -> void:
	hide()
	UIComponents.apply_modal_language(modal_root, UIComponents.SURFACE_SETTINGS)
	resume_button.pressed.connect(resume_game)
	start_button.pressed.connect(start_game)
	settings_button.pressed.connect(request_settings)
	save_load_button.pressed.connect(request_save_load)
	main_menu_button.pressed.connect(open_main_menu)
	quit_button.pressed.connect(request_quit)
	_update_labels()


func open_pause(player: Node) -> bool:
	if player == null:
		return false

	_player = player
	_mode = "pause"
	_quit_requested = false
	_last_action = "pause"
	_enter_modal(resume_button)
	_update_labels()
	return true


func open_main_menu(player: Node = null) -> bool:
	_player = player
	_mode = "main_menu"
	_quit_requested = false
	_last_action = "main_menu"
	main_menu_requested.emit()
	_enter_modal(start_button)
	_update_labels()
	return true


func resume_game() -> bool:
	if not is_open():
		return false

	_last_action = "resume"
	resume_requested.emit()
	_exit_modal()
	return true


func start_game() -> bool:
	if not is_open():
		return false

	_last_action = "start"
	start_requested.emit()
	_exit_modal()
	return true


func request_settings() -> bool:
	if not is_open():
		return false

	_last_action = "settings"
	settings_requested.emit()
	_exit_modal()
	return true


func request_save_load() -> bool:
	if not is_open():
		return false

	_last_action = "save_load"
	save_load_requested.emit()
	_exit_modal()
	return true


func request_quit() -> bool:
	if not is_open():
		return false

	_quit_requested = true
	_last_action = "quit"
	status_label.text = "Quit requested"
	quit_requested.emit()
	return true


func is_open() -> bool:
	return visible and _transition_state == "open"


func is_pause_mode() -> bool:
	return _mode == "pause"


func is_main_menu_mode() -> bool:
	return _mode == "main_menu"


func get_transition_state() -> String:
	return _transition_state


func get_requested_mouse_mode() -> int:
	return _requested_mouse_mode


func get_requested_pause_state() -> bool:
	return _requested_pause_state


func has_quit_request() -> bool:
	return _quit_requested


func get_last_action() -> String:
	return _last_action


func has_modal_focus() -> bool:
	var focus_owner := get_viewport().gui_get_focus_owner()
	return focus_owner != null and is_ancestor_of(focus_owner)


func has_ui_component_language() -> bool:
	return modal_root.get_meta("ui_surface", "") == UIComponents.SURFACE_SETTINGS \
		and modal_root.get_meta("ui_accessibility_requirements", {}).get("min_body_font_size", 0) >= UIComponents.MIN_BODY_FONT_SIZE \
		and resume_button.get_meta("ui_component", "") == UIComponents.TOKEN_BUTTON


func has_accessibility_floor() -> bool:
	var audit: Dictionary = UIComponents.audit_modal_accessibility(modal_root)
	return bool(audit.get("passes", false))


func _enter_modal(default_focus: Control) -> void:
	show()
	_requested_mouse_mode = Input.MOUSE_MODE_VISIBLE
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_requested_pause_state = true
	_transition_state = "open"
	if default_focus != null:
		default_focus.grab_focus()


func _exit_modal() -> void:
	_release_modal_focus()
	hide()
	_requested_mouse_mode = Input.MOUSE_MODE_CAPTURED
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_requested_pause_state = false
	_transition_state = "closed"


func _release_modal_focus() -> void:
	var focus_owner := get_viewport().gui_get_focus_owner()
	if focus_owner != null and is_ancestor_of(focus_owner):
		focus_owner.release_focus()


func _update_labels() -> void:
	if _mode == "main_menu":
		title_label.text = "Game Store Sim"
		mode_label.text = "Main Menu"
		resume_button.visible = false
		start_button.visible = true
		main_menu_button.visible = false
		save_load_button.visible = true
	else:
		title_label.text = "Paused"
		mode_label.text = "Game paused"
		resume_button.visible = true
		start_button.visible = false
		main_menu_button.visible = true
		save_load_button.visible = true

	if status_label.text.is_empty() or _last_action != "quit":
		status_label.text = "Mouse visible while menu is open"
