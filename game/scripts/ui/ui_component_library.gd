extends RefCounted
class_name UiComponentLibrary

const SURFACE_REGISTER := "register"
const SURFACE_BACKROOM := "backroom"
const SURFACE_PRICING := "pricing"
const SURFACE_TRADE_IN := "trade_in"
const SURFACE_SETTINGS := "settings"
const SURFACE_SAVE_LOAD := "save_load"

const BUTTON_PRIMARY := "primary"
const BUTTON_SECONDARY := "secondary"
const BUTTON_DANGER := "danger"
const BUTTON_GHOST := "ghost"

const ALERT_INFO := "info"
const ALERT_SUCCESS := "success"
const ALERT_WARNING := "warning"
const ALERT_DANGER := "danger"

const TOKEN_BUTTON := "button"
const TOKEN_TAB := "tab"
const TOKEN_LIST := "list"
const TOKEN_STAT := "stat"
const TOKEN_RECEIPT := "receipt"
const TOKEN_MODAL := "modal"
const TOKEN_TOOLTIP := "tooltip"
const TOKEN_ALERT := "alert"
const TOKEN_DISABLED := "disabled"
const TOKEN_SELECTED := "selected"

const MIN_BUTTON_HEIGHT := 44
const MIN_COMPACT_BUTTON_HEIGHT := 38
const MIN_MODAL_WIDTH := 520
const MIN_MODAL_HEIGHT := 360
const MIN_BODY_FONT_SIZE := 15
const MIN_HEADER_FONT_SIZE := 18
const MAX_MODAL_WIDTH_1280 := 760
const MAX_MODAL_HEIGHT_720 := 700
const MIN_CONTRAST_RATIO := 4.5

const _SURFACE_ACCENTS := {
	SURFACE_REGISTER: Color(0.18, 0.40, 0.55),
	SURFACE_BACKROOM: Color(0.26, 0.33, 0.42),
	SURFACE_PRICING: Color(0.35, 0.45, 0.24),
	SURFACE_TRADE_IN: Color(0.47, 0.34, 0.20),
	SURFACE_SETTINGS: Color(0.30, 0.36, 0.45),
	SURFACE_SAVE_LOAD: Color(0.22, 0.42, 0.46),
}

const _SURFACE_TITLES := {
	SURFACE_REGISTER: "Register",
	SURFACE_BACKROOM: "Backroom",
	SURFACE_PRICING: "Pricing",
	SURFACE_TRADE_IN: "Trade-In",
	SURFACE_SETTINGS: "Settings",
	SURFACE_SAVE_LOAD: "Save / Load",
}


static func get_component_tokens() -> Array[String]:
	return [
		TOKEN_BUTTON,
		TOKEN_TAB,
		TOKEN_LIST,
		TOKEN_STAT,
		TOKEN_RECEIPT,
		TOKEN_MODAL,
		TOKEN_TOOLTIP,
		TOKEN_ALERT,
		TOKEN_DISABLED,
		TOKEN_SELECTED,
	]


static func get_button_states() -> Array[String]:
	return [
		BUTTON_PRIMARY,
		BUTTON_SECONDARY,
		BUTTON_DANGER,
		BUTTON_GHOST,
		TOKEN_DISABLED,
		TOKEN_SELECTED,
	]


static func get_alert_states() -> Array[String]:
	return [
		ALERT_INFO,
		ALERT_SUCCESS,
		ALERT_WARNING,
		ALERT_DANGER,
	]


static func get_accessibility_requirements() -> Dictionary:
	return {
		"min_button_height": MIN_BUTTON_HEIGHT,
		"min_body_font_size": MIN_BODY_FONT_SIZE,
		"min_header_font_size": MIN_HEADER_FONT_SIZE,
		"max_modal_width_1280": MAX_MODAL_WIDTH_1280,
		"max_modal_height_720": MAX_MODAL_HEIGHT_720,
		"min_contrast_ratio": MIN_CONTRAST_RATIO,
	}


static func get_surface_title(surface: String) -> String:
	return str(_SURFACE_TITLES.get(surface, "Store UI"))


static func get_surface_accent(surface: String) -> Color:
	return _SURFACE_ACCENTS.get(surface, Color(0.24, 0.34, 0.40))


static func get_modal_background_style(surface: String) -> StyleBoxFlat:
	var accent := get_surface_accent(surface)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.09, 0.10, 0.96)
	style.border_color = accent.lightened(0.30)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.45)
	style.shadow_size = 12
	style.content_margin_left = 18
	style.content_margin_top = 16
	style.content_margin_right = 18
	style.content_margin_bottom = 16
	return style


static func get_button_style(surface: String, state: String) -> StyleBoxFlat:
	var accent := get_surface_accent(surface)
	var style := StyleBoxFlat.new()
	style.set_corner_radius_all(4)
	style.set_border_width_all(1)
	style.content_margin_left = 12
	style.content_margin_top = 8
	style.content_margin_right = 12
	style.content_margin_bottom = 8

	if state == BUTTON_PRIMARY or state == TOKEN_SELECTED:
		style.bg_color = accent
		style.border_color = accent.lightened(0.38)
	elif state == BUTTON_DANGER:
		style.bg_color = Color(0.43, 0.16, 0.14)
		style.border_color = Color(0.78, 0.35, 0.28)
	elif state == BUTTON_GHOST:
		style.bg_color = Color(0.12, 0.13, 0.14, 0.55)
		style.border_color = Color(0.45, 0.48, 0.50)
	elif state == TOKEN_DISABLED:
		style.bg_color = Color(0.10, 0.10, 0.10, 0.62)
		style.border_color = Color(0.25, 0.26, 0.27)
	else:
		style.bg_color = Color(0.16, 0.17, 0.18)
		style.border_color = accent.darkened(0.10)

	return style


static func get_alert_color(state: String) -> Color:
	if state == ALERT_SUCCESS:
		return Color(0.44, 0.70, 0.35)
	if state == ALERT_WARNING:
		return Color(0.88, 0.67, 0.25)
	if state == ALERT_DANGER:
		return Color(0.82, 0.32, 0.26)
	return Color(0.48, 0.65, 0.78)


static func get_contrast_ratio(first: Color, second: Color) -> float:
	var first_luminance := _relative_luminance(first)
	var second_luminance := _relative_luminance(second)
	var lighter := maxf(first_luminance, second_luminance)
	var darker := minf(first_luminance, second_luminance)
	return (lighter + 0.05) / (darker + 0.05)


static func has_accessible_contrast(first: Color, second: Color) -> bool:
	return get_contrast_ratio(first, second) >= MIN_CONTRAST_RATIO


static func apply_modal_language(root: Control, surface: String) -> void:
	if root == null:
		return

	root.set_meta("ui_surface", surface)
	root.set_meta("ui_language_tokens", get_component_tokens())
	root.set_meta("ui_surface_title", get_surface_title(surface))
	root.set_meta("ui_accessibility_requirements", get_accessibility_requirements())
	root.add_theme_font_size_override("font_size", MIN_BODY_FONT_SIZE)

	for child in _collect_controls(root):
		_apply_control_language(child, surface)


static func audit_modal_accessibility(root: Control) -> Dictionary:
	var violations: Array[String] = []
	if root == null:
		return {"passes": false, "violations": ["Missing modal root"]}

	for control in _collect_controls(root):
		if control is PanelContainer:
			if control.custom_minimum_size.x > MAX_MODAL_WIDTH_1280:
				violations.append("%s exceeds 1280-width modal target" % control.name)
			if control.custom_minimum_size.y > MAX_MODAL_HEIGHT_720:
				violations.append("%s exceeds 720-height modal target" % control.name)
		elif control is Button:
			var button := control as Button
			if button.custom_minimum_size.y < MIN_BUTTON_HEIGHT:
				violations.append("%s button is below hit-height floor" % button.name)
			if button.focus_mode == Control.FOCUS_NONE:
				violations.append("%s button is not keyboard-focusable" % button.name)
		elif control is CheckBox:
			var check_box := control as CheckBox
			if check_box.custom_minimum_size.y < MIN_BUTTON_HEIGHT:
				violations.append("%s checkbox is below hit-height floor" % check_box.name)
			if check_box.focus_mode == Control.FOCUS_NONE:
				violations.append("%s checkbox is not keyboard-focusable" % check_box.name)
		elif control is Label:
			var label := control as Label
			if label.get_theme_font_size("font_size") < MIN_BODY_FONT_SIZE:
				violations.append("%s label is below text-size floor" % label.name)

	return {
		"passes": violations.is_empty(),
		"violations": violations,
	}


static func _collect_controls(root: Control) -> Array[Control]:
	var controls: Array[Control] = [root]
	for child in root.get_children():
		if child is Control:
			controls.append_array(_collect_controls(child))
	return controls


static func _apply_control_language(control: Control, surface: String) -> void:
	if control is PanelContainer:
		control.add_theme_stylebox_override("panel", get_modal_background_style(surface))
		control.custom_minimum_size.x = maxf(control.custom_minimum_size.x, MIN_MODAL_WIDTH)
		control.custom_minimum_size.y = maxf(control.custom_minimum_size.y, MIN_MODAL_HEIGHT)
		control.set_meta("ui_component", TOKEN_MODAL)
	elif control is Button:
		_apply_button_language(control as Button, surface)
	elif control is CheckBox:
		control.add_theme_font_size_override("font_size", MIN_BODY_FONT_SIZE)
		control.set_meta("ui_component", TOKEN_BUTTON)
	elif control is Label:
		_apply_label_language(control as Label)
	elif control is ScrollContainer:
		control.set_meta("ui_component", TOKEN_LIST)


static func _apply_button_language(button: Button, surface: String) -> void:
	button.custom_minimum_size.y = maxf(button.custom_minimum_size.y, MIN_BUTTON_HEIGHT)
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_stylebox_override("normal", get_button_style(surface, BUTTON_SECONDARY))
	button.add_theme_stylebox_override("hover", get_button_style(surface, BUTTON_PRIMARY))
	button.add_theme_stylebox_override("pressed", get_button_style(surface, TOKEN_SELECTED))
	button.add_theme_stylebox_override("disabled", get_button_style(surface, TOKEN_DISABLED))
	button.add_theme_font_size_override("font_size", MIN_BODY_FONT_SIZE)
	button.set_meta("ui_component", TOKEN_BUTTON)
	button.set_meta("ui_states", get_button_states())


static func _apply_label_language(label: Label) -> void:
	label.add_theme_font_size_override("font_size", MIN_BODY_FONT_SIZE)
	if label.name.to_lower().contains("title") or label.name.to_lower().contains("header"):
		label.add_theme_font_size_override("font_size", MIN_HEADER_FONT_SIZE)
		label.set_meta("ui_component", TOKEN_STAT)
	else:
		label.set_meta("ui_component", TOKEN_LIST)


static func _relative_luminance(color: Color) -> float:
	var red := _linearized_channel(color.r)
	var green := _linearized_channel(color.g)
	var blue := _linearized_channel(color.b)
	return 0.2126 * red + 0.7152 * green + 0.0722 * blue


static func _linearized_channel(channel: float) -> float:
	if channel <= 0.03928:
		return channel / 12.92

	return pow((channel + 0.055) / 1.055, 2.4)
