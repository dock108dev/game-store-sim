extends CanvasLayer
class_name SettingsPanel

const UIComponents := preload("res://scripts/ui/ui_component_library.gd")

@export var sensitivity_step: float = 0.0005
@export var min_sensitivity: float = 0.0005
@export var max_sensitivity: float = 0.01

@onready var modal_root: Control = $CenterContainer
@onready var title_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var sensitivity_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/SensitivityLabel
@onready var decrease_sensitivity_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/SensitivityRow/DecreaseSensitivityButton
@onready var increase_sensitivity_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/SensitivityRow/IncreaseSensitivityButton
@onready var invert_check_box: CheckBox = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/InvertCheckBox
@onready var window_mode_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/WindowModeButton
@onready var close_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CloseButton

var _player: Node = null
var _transition_state: String = "closed"
var _requested_mouse_mode: int = Input.MOUSE_MODE_CAPTURED
var _requested_window_mode: int = DisplayServer.WINDOW_MODE_WINDOWED


func _ready() -> void:
	hide()
	UIComponents.apply_modal_language(modal_root, UIComponents.SURFACE_SETTINGS)
	decrease_sensitivity_button.pressed.connect(decrease_sensitivity)
	increase_sensitivity_button.pressed.connect(increase_sensitivity)
	invert_check_box.toggled.connect(set_invert_look)
	window_mode_button.pressed.connect(toggle_window_mode)
	close_button.pressed.connect(close)
	_requested_window_mode = DisplayServer.window_get_mode()


func open_for_player(player: Node) -> bool:
	if player == null:
		return false

	_player = player
	_update_labels()
	_enter_modal(close_button)
	return true


func close() -> bool:
	if not is_open():
		return false

	_player = null
	_exit_modal()
	return true


func is_open() -> bool:
	return visible and _player != null


func get_active_player() -> Node:
	return _player


func get_transition_state() -> String:
	return _transition_state


func get_requested_mouse_mode() -> int:
	return _requested_mouse_mode


func get_requested_window_mode() -> int:
	return _requested_window_mode


func has_modal_focus() -> bool:
	var focus_owner := get_viewport().gui_get_focus_owner()
	return focus_owner != null and is_ancestor_of(focus_owner)


func has_ui_component_language() -> bool:
	return modal_root.get_meta("ui_surface", "") == UIComponents.SURFACE_SETTINGS \
		and modal_root.get_meta("ui_accessibility_requirements", {}).get("min_body_font_size", 0) >= UIComponents.MIN_BODY_FONT_SIZE \
		and close_button.get_meta("ui_component", "") == UIComponents.TOKEN_BUTTON


func has_accessibility_floor() -> bool:
	var audit: Dictionary = UIComponents.audit_modal_accessibility(modal_root)
	return bool(audit.get("passes", false))


func increase_sensitivity() -> bool:
	return _adjust_sensitivity(sensitivity_step)


func decrease_sensitivity() -> bool:
	return _adjust_sensitivity(-sensitivity_step)


func set_invert_look(is_inverted: bool) -> bool:
	if _player == null or not _player.has_method("set_invert_look"):
		return false

	_player.set_invert_look(is_inverted)
	_update_labels()
	return true


func toggle_window_mode() -> bool:
	var current_mode := _requested_window_mode
	if current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		_requested_window_mode = DisplayServer.WINDOW_MODE_WINDOWED
	else:
		_requested_window_mode = DisplayServer.WINDOW_MODE_FULLSCREEN

	DisplayServer.window_set_mode(_requested_window_mode)
	_update_labels()
	return true


func _adjust_sensitivity(delta: float) -> bool:
	if _player == null or not _player.has_method("get_mouse_sensitivity"):
		return false

	var next_sensitivity := clampf(
		float(_player.get_mouse_sensitivity()) + delta,
		min_sensitivity,
		max_sensitivity
	)
	if _player.has_method("set_mouse_sensitivity"):
		_player.set_mouse_sensitivity(next_sensitivity)
	_update_labels()
	return true


func _enter_modal(default_focus: Control) -> void:
	show()
	_requested_mouse_mode = Input.MOUSE_MODE_VISIBLE
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_transition_state = "open"
	if default_focus != null:
		default_focus.grab_focus()


func _exit_modal() -> void:
	_release_modal_focus()
	hide()
	_requested_mouse_mode = Input.MOUSE_MODE_CAPTURED
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_transition_state = "closed"


func _release_modal_focus() -> void:
	var focus_owner := get_viewport().gui_get_focus_owner()
	if focus_owner != null and is_ancestor_of(focus_owner):
		focus_owner.release_focus()


func _update_labels() -> void:
	title_label.text = "Settings"
	if _player != null and _player.has_method("get_mouse_sensitivity"):
		sensitivity_label.text = "Look sensitivity: %0.4f" % float(_player.get_mouse_sensitivity())
	if _player != null and _player.has_method("get_invert_look"):
		invert_check_box.set_pressed_no_signal(bool(_player.get_invert_look()))
	window_mode_button.text = "Window: Fullscreen" \
		if _requested_window_mode == DisplayServer.WINDOW_MODE_FULLSCREEN \
		else "Window: Windowed"
