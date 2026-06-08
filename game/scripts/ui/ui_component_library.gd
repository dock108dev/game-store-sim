extends RefCounted
class_name UiComponentLibrary

const SURFACE_REGISTER := "register"
const SURFACE_BACKROOM := "backroom"
const SURFACE_PRICING := "pricing"
const SURFACE_TRADE_IN := "trade_in"

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

const _SURFACE_ACCENTS := {
	SURFACE_REGISTER: Color(0.18, 0.40, 0.55),
	SURFACE_BACKROOM: Color(0.26, 0.33, 0.42),
	SURFACE_PRICING: Color(0.35, 0.45, 0.24),
	SURFACE_TRADE_IN: Color(0.47, 0.34, 0.20),
}

const _SURFACE_TITLES := {
	SURFACE_REGISTER: "Register",
	SURFACE_BACKROOM: "Backroom",
	SURFACE_PRICING: "Pricing",
	SURFACE_TRADE_IN: "Trade-In",
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


static func apply_modal_language(root: Control, surface: String) -> void:
	if root == null:
		return

	root.set_meta("ui_surface", surface)
	root.set_meta("ui_language_tokens", get_component_tokens())
	root.set_meta("ui_surface_title", get_surface_title(surface))
	root.add_theme_font_size_override("font_size", MIN_BODY_FONT_SIZE)

	for child in _collect_controls(root):
		_apply_control_language(child, surface)


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
