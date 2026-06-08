extends CanvasLayer
class_name SettingsPanel

const UIComponents := preload("res://scripts/ui/ui_component_library.gd")

@export var sensitivity_step: float = 0.0005
@export var min_sensitivity: float = 0.0005
@export var max_sensitivity: float = 0.01
@export var volume_step: int = 5
@export var scale_step: int = 5
@export var settings_file_path: String = "user://settings_profile.json"

@onready var modal_root: Control = $CenterContainer
@onready var title_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var master_volume_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/SettingsContent/MasterVolumeLabel
@onready var decrease_master_volume_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/SettingsContent/MasterVolumeRow/DecreaseMasterVolumeButton
@onready var increase_master_volume_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/SettingsContent/MasterVolumeRow/IncreaseMasterVolumeButton
@onready var music_volume_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/SettingsContent/MusicVolumeLabel
@onready var decrease_music_volume_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/SettingsContent/MusicVolumeRow/DecreaseMusicVolumeButton
@onready var increase_music_volume_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/SettingsContent/MusicVolumeRow/IncreaseMusicVolumeButton
@onready var sfx_volume_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/SettingsContent/SfxVolumeLabel
@onready var decrease_sfx_volume_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/SettingsContent/SfxVolumeRow/DecreaseSfxVolumeButton
@onready var increase_sfx_volume_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/SettingsContent/SfxVolumeRow/IncreaseSfxVolumeButton
@onready var window_mode_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/SettingsContent/WindowModeButton
@onready var resolution_scale_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/SettingsContent/ResolutionScaleLabel
@onready var decrease_resolution_scale_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/SettingsContent/ResolutionScaleRow/DecreaseResolutionScaleButton
@onready var increase_resolution_scale_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/SettingsContent/ResolutionScaleRow/IncreaseResolutionScaleButton
@onready var sensitivity_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/SettingsContent/SensitivityLabel
@onready var decrease_sensitivity_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/SettingsContent/SensitivityRow/DecreaseSensitivityButton
@onready var increase_sensitivity_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/SettingsContent/SensitivityRow/IncreaseSensitivityButton
@onready var invert_check_box: CheckBox = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/SettingsContent/InvertCheckBox
@onready var controls_summary_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/SettingsContent/ControlsSummaryLabel
@onready var reset_bindings_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/SettingsContent/ResetBindingsButton
@onready var text_scale_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/SettingsContent/TextScaleLabel
@onready var decrease_text_scale_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/SettingsContent/TextScaleRow/DecreaseTextScaleButton
@onready var increase_text_scale_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/SettingsContent/TextScaleRow/IncreaseTextScaleButton
@onready var high_contrast_check_box: CheckBox = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/SettingsContent/HighContrastCheckBox
@onready var reduce_motion_check_box: CheckBox = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/SettingsContent/ReduceMotionCheckBox
@onready var settings_status_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/SettingsContent/SettingsStatusLabel
@onready var reset_defaults_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/FooterRow/ResetDefaultsButton
@onready var close_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/FooterRow/CloseButton

var _player: Node = null
var _transition_state: String = "closed"
var _requested_mouse_mode: int = Input.MOUSE_MODE_CAPTURED
var _requested_window_mode: int = DisplayServer.WINDOW_MODE_WINDOWED
var _settings: Dictionary = {}
var _last_save_result: String = ""

const SETTINGS_SCHEMA_VERSION := 1
const DEFAULT_SETTINGS := {
	"schema_version": SETTINGS_SCHEMA_VERSION,
	"master_volume": 80,
	"music_volume": 70,
	"sfx_volume": 85,
	"window_mode": "windowed",
	"resolution_scale": 100,
	"look_sensitivity": 0.0025,
	"invert_look": false,
	"input_bindings_reset": true,
	"text_scale": 100,
	"high_contrast": false,
	"reduce_motion": false,
}


func _ready() -> void:
	hide()
	UIComponents.apply_modal_language(modal_root, UIComponents.SURFACE_SETTINGS)
	_settings = DEFAULT_SETTINGS.duplicate(true)
	decrease_master_volume_button.pressed.connect(func(): adjust_master_volume(-volume_step))
	increase_master_volume_button.pressed.connect(func(): adjust_master_volume(volume_step))
	decrease_music_volume_button.pressed.connect(func(): adjust_music_volume(-volume_step))
	increase_music_volume_button.pressed.connect(func(): adjust_music_volume(volume_step))
	decrease_sfx_volume_button.pressed.connect(func(): adjust_sfx_volume(-volume_step))
	increase_sfx_volume_button.pressed.connect(func(): adjust_sfx_volume(volume_step))
	decrease_sensitivity_button.pressed.connect(decrease_sensitivity)
	increase_sensitivity_button.pressed.connect(increase_sensitivity)
	invert_check_box.toggled.connect(set_invert_look)
	window_mode_button.pressed.connect(toggle_window_mode)
	decrease_resolution_scale_button.pressed.connect(func(): adjust_resolution_scale(-scale_step))
	increase_resolution_scale_button.pressed.connect(func(): adjust_resolution_scale(scale_step))
	reset_bindings_button.pressed.connect(reset_bindings_to_defaults)
	decrease_text_scale_button.pressed.connect(func(): adjust_text_scale(-scale_step))
	increase_text_scale_button.pressed.connect(func(): adjust_text_scale(scale_step))
	high_contrast_check_box.toggled.connect(set_high_contrast)
	reduce_motion_check_box.toggled.connect(set_reduce_motion)
	reset_defaults_button.pressed.connect(reset_defaults)
	close_button.pressed.connect(close)
	_requested_window_mode = DisplayServer.window_get_mode()
	_update_labels()


func open_for_player(player: Node) -> bool:
	if player == null:
		return false

	_player = player
	_load_settings()
	_apply_settings_to_player()
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


func get_settings_file_path() -> String:
	return settings_file_path


func set_settings_file_path(path: String) -> void:
	settings_file_path = path


func get_settings_data() -> Dictionary:
	return _settings.duplicate(true)


func get_last_save_result() -> String:
	return _last_save_result


func get_settings_summary_text() -> String:
	return "Settings menu:\nAudio master %d music %d sfx %d\nDisplay %s render %d%%\nMouse sensitivity %0.4f invert %s\nControls remappable with defaults reset\nAccessibility text %d%% high contrast %s reduce motion %s" % [
		int(_settings.get("master_volume", DEFAULT_SETTINGS["master_volume"])),
		int(_settings.get("music_volume", DEFAULT_SETTINGS["music_volume"])),
		int(_settings.get("sfx_volume", DEFAULT_SETTINGS["sfx_volume"])),
		str(_settings.get("window_mode", DEFAULT_SETTINGS["window_mode"])),
		int(_settings.get("resolution_scale", DEFAULT_SETTINGS["resolution_scale"])),
		float(_settings.get("look_sensitivity", DEFAULT_SETTINGS["look_sensitivity"])),
		"on" if bool(_settings.get("invert_look", false)) else "off",
		int(_settings.get("text_scale", DEFAULT_SETTINGS["text_scale"])),
		"on" if bool(_settings.get("high_contrast", false)) else "off",
		"on" if bool(_settings.get("reduce_motion", false)) else "off",
	]


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
	_settings["invert_look"] = is_inverted
	if _player != null and _player.has_method("set_invert_look"):
		_player.set_invert_look(is_inverted)
	_update_labels()
	save_settings()
	return true


func toggle_window_mode() -> bool:
	var current_mode := _requested_window_mode
	if current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		_requested_window_mode = DisplayServer.WINDOW_MODE_WINDOWED
		_settings["window_mode"] = "windowed"
	else:
		_requested_window_mode = DisplayServer.WINDOW_MODE_FULLSCREEN
		_settings["window_mode"] = "fullscreen"

	DisplayServer.window_set_mode(_requested_window_mode)
	_update_labels()
	save_settings()
	return true


func adjust_master_volume(delta: int) -> bool:
	return _adjust_int_setting("master_volume", delta, 0, 100)


func adjust_music_volume(delta: int) -> bool:
	return _adjust_int_setting("music_volume", delta, 0, 100)


func adjust_sfx_volume(delta: int) -> bool:
	return _adjust_int_setting("sfx_volume", delta, 0, 100)


func adjust_resolution_scale(delta: int) -> bool:
	return _adjust_int_setting("resolution_scale", delta, 70, 120)


func adjust_text_scale(delta: int) -> bool:
	return _adjust_int_setting("text_scale", delta, 90, 120)


func set_high_contrast(is_enabled: bool) -> bool:
	_settings["high_contrast"] = is_enabled
	_apply_settings_to_player()
	_update_labels()
	save_settings()
	return true


func set_reduce_motion(is_enabled: bool) -> bool:
	_settings["reduce_motion"] = is_enabled
	_apply_settings_to_player()
	_update_labels()
	save_settings()
	return true


func reset_bindings_to_defaults() -> bool:
	_settings["input_bindings_reset"] = true
	settings_status_label.text = "Bindings reset to defaults"
	save_settings()
	return true


func reset_defaults() -> bool:
	_settings = DEFAULT_SETTINGS.duplicate(true)
	_requested_window_mode = DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(_requested_window_mode)
	_apply_settings_to_player()
	_update_labels()
	save_settings()
	settings_status_label.text = "Settings reset to defaults"
	return true


func save_settings() -> bool:
	if settings_file_path.is_empty():
		_last_save_result = "Settings persistence disabled."
		return false

	var file := FileAccess.open(settings_file_path, FileAccess.WRITE)
	if file == null:
		_last_save_result = "Settings could not be saved."
		return false

	file.store_string(JSON.stringify(_settings, "\t"))
	_last_save_result = "Settings saved."
	return true


func load_settings() -> bool:
	return _load_settings()


func _adjust_int_setting(key: String, delta: int, min_value: int, max_value: int) -> bool:
	var next_value := clampi(int(_settings.get(key, DEFAULT_SETTINGS.get(key, min_value))) + delta, min_value, max_value)
	_settings[key] = next_value
	_apply_settings_to_player()
	_update_labels()
	save_settings()
	return true


func _adjust_sensitivity(delta: float) -> bool:
	var current_sensitivity := float(_settings.get("look_sensitivity", DEFAULT_SETTINGS["look_sensitivity"]))
	if _player != null and _player.has_method("get_mouse_sensitivity"):
		current_sensitivity = float(_player.get_mouse_sensitivity())
	var next_sensitivity := clampf(
		current_sensitivity + delta,
		min_sensitivity,
		max_sensitivity
	)
	_settings["look_sensitivity"] = next_sensitivity
	if _player != null and _player.has_method("set_mouse_sensitivity"):
		_player.set_mouse_sensitivity(next_sensitivity)
	_update_labels()
	save_settings()
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
	master_volume_label.text = "Master volume: %d%%" % int(_settings.get("master_volume", DEFAULT_SETTINGS["master_volume"]))
	music_volume_label.text = "Music volume: %d%%" % int(_settings.get("music_volume", DEFAULT_SETTINGS["music_volume"]))
	sfx_volume_label.text = "SFX volume: %d%%" % int(_settings.get("sfx_volume", DEFAULT_SETTINGS["sfx_volume"]))
	resolution_scale_label.text = "Render scale: %d%%" % int(_settings.get("resolution_scale", DEFAULT_SETTINGS["resolution_scale"]))
	sensitivity_label.text = "Look sensitivity: %0.4f" % float(_settings.get("look_sensitivity", DEFAULT_SETTINGS["look_sensitivity"]))
	invert_check_box.set_pressed_no_signal(bool(_settings.get("invert_look", DEFAULT_SETTINGS["invert_look"])))
	window_mode_button.text = "Window: Fullscreen" \
		if _requested_window_mode == DisplayServer.WINDOW_MODE_FULLSCREEN \
		else "Window: Windowed"
	controls_summary_label.text = "Move WASD / Interact Left Click / Pause Escape / remappable defaults"
	text_scale_label.text = "Text scale: %d%%" % int(_settings.get("text_scale", DEFAULT_SETTINGS["text_scale"]))
	high_contrast_check_box.set_pressed_no_signal(bool(_settings.get("high_contrast", DEFAULT_SETTINGS["high_contrast"])))
	reduce_motion_check_box.set_pressed_no_signal(bool(_settings.get("reduce_motion", DEFAULT_SETTINGS["reduce_motion"])))
	if settings_status_label.text.is_empty():
		settings_status_label.text = _last_save_result if not _last_save_result.is_empty() else "Settings saved automatically"


func _load_settings() -> bool:
	_settings = DEFAULT_SETTINGS.duplicate(true)
	if settings_file_path.is_empty() or not FileAccess.file_exists(settings_file_path):
		_sync_settings_from_player()
		return false

	var json_text := FileAccess.get_file_as_string(settings_file_path)
	var parsed: Variant = JSON.parse_string(json_text)
	if typeof(parsed) != TYPE_DICTIONARY:
		_last_save_result = "Settings file ignored."
		_sync_settings_from_player()
		return false

	var loaded: Dictionary = parsed
	for key in DEFAULT_SETTINGS.keys():
		if loaded.has(key):
			_settings[key] = loaded[key]
	_sanitize_settings()
	_last_save_result = "Settings loaded."
	return true


func _sync_settings_from_player() -> void:
	if _player != null and _player.has_method("get_mouse_sensitivity"):
		_settings["look_sensitivity"] = clampf(float(_player.get_mouse_sensitivity()), min_sensitivity, max_sensitivity)
	if _player != null and _player.has_method("get_invert_look"):
		_settings["invert_look"] = bool(_player.get_invert_look())
	_settings["window_mode"] = "fullscreen" if _requested_window_mode == DisplayServer.WINDOW_MODE_FULLSCREEN else "windowed"
	_sanitize_settings()


func _sanitize_settings() -> void:
	_settings["schema_version"] = SETTINGS_SCHEMA_VERSION
	_settings["master_volume"] = clampi(int(_settings.get("master_volume", DEFAULT_SETTINGS["master_volume"])), 0, 100)
	_settings["music_volume"] = clampi(int(_settings.get("music_volume", DEFAULT_SETTINGS["music_volume"])), 0, 100)
	_settings["sfx_volume"] = clampi(int(_settings.get("sfx_volume", DEFAULT_SETTINGS["sfx_volume"])), 0, 100)
	_settings["window_mode"] = "fullscreen" if str(_settings.get("window_mode", DEFAULT_SETTINGS["window_mode"])) == "fullscreen" else "windowed"
	_settings["resolution_scale"] = clampi(int(_settings.get("resolution_scale", DEFAULT_SETTINGS["resolution_scale"])), 70, 120)
	_settings["look_sensitivity"] = clampf(float(_settings.get("look_sensitivity", DEFAULT_SETTINGS["look_sensitivity"])), min_sensitivity, max_sensitivity)
	_settings["invert_look"] = bool(_settings.get("invert_look", DEFAULT_SETTINGS["invert_look"]))
	_settings["input_bindings_reset"] = bool(_settings.get("input_bindings_reset", DEFAULT_SETTINGS["input_bindings_reset"]))
	_settings["text_scale"] = clampi(int(_settings.get("text_scale", DEFAULT_SETTINGS["text_scale"])), 90, 120)
	_settings["high_contrast"] = bool(_settings.get("high_contrast", DEFAULT_SETTINGS["high_contrast"]))
	_settings["reduce_motion"] = bool(_settings.get("reduce_motion", DEFAULT_SETTINGS["reduce_motion"]))
	_requested_window_mode = DisplayServer.WINDOW_MODE_FULLSCREEN \
		if str(_settings.get("window_mode", "windowed")) == "fullscreen" \
		else DisplayServer.WINDOW_MODE_WINDOWED


func _apply_settings_to_player() -> void:
	_sanitize_settings()
	if _player == null:
		return
	if _player.has_method("set_mouse_sensitivity"):
		_player.set_mouse_sensitivity(float(_settings.get("look_sensitivity", DEFAULT_SETTINGS["look_sensitivity"])))
	if _player.has_method("set_invert_look"):
		_player.set_invert_look(bool(_settings.get("invert_look", DEFAULT_SETTINGS["invert_look"])))
	if _player.has_method("apply_settings_profile"):
		_player.apply_settings_profile(_settings.duplicate(true))
