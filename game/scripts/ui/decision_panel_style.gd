## Shared visual grammar helpers for retail decision panels.
class_name DecisionPanelStyle
extends RefCounted

const PANEL_CORNER_RADIUS: int = 6
const PANEL_BORDER_WIDTH: int = 2
const PANEL_PADDING: int = 12
const ROW_GAP: int = 6
const BUTTON_HEIGHT: int = 36
const BUTTON_HEIGHT_COMPACT: int = 30
const STATUS_ALPHA_MUTED: float = 0.72
const PRICING_ZONE_GREEN_MAX: float = 0.9
const PRICING_ZONE_BLUE_MAX: float = 1.1
const PRICING_ZONE_YELLOW_MAX: float = 1.5


static func docked_panel_style(accent: Color = UIThemeConstants.ACCENT_COLOR) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = UIThemeConstants.DARK_PANEL_FILL
	style.border_color = accent
	style.set_border_width_all(PANEL_BORDER_WIDTH)
	style.set_corner_radius_all(PANEL_CORNER_RADIUS)
	style.content_margin_left = PANEL_PADDING
	style.content_margin_top = PANEL_PADDING
	style.content_margin_right = PANEL_PADDING
	style.content_margin_bottom = PANEL_PADDING
	return style


static func apply_panel_style(
	panel: PanelContainer, accent: Color = UIThemeConstants.ACCENT_COLOR
) -> void:
	if panel == null:
		return
	panel.add_theme_stylebox_override(&"panel", docked_panel_style(accent))


static func apply_header_label(label: Label) -> void:
	if label == null:
		return
	label.theme_type_variation = &"HeaderLabel"
	label.add_theme_font_size_override("font_size", UIThemeConstants.FONT_SIZE_H2)
	label.add_theme_color_override("font_color", UIThemeConstants.HEADER_FONT_COLOR)


static func apply_body_label(label: Label) -> void:
	if label == null:
		return
	label.add_theme_font_size_override("font_size", UIThemeConstants.FONT_SIZE_BODY)
	label.add_theme_color_override("font_color", UIThemeConstants.DARK_PANEL_TEXT)


static func apply_secondary_label(label: Label) -> void:
	if label == null:
		return
	label.add_theme_font_size_override("font_size", UIThemeConstants.FONT_SIZE_CAPTION)
	label.add_theme_color_override(
		"font_color", UIThemeConstants.DARK_PANEL_TEXT_SECONDARY
	)


static func apply_table_header(label: Label) -> void:
	apply_secondary_label(label)
	if label == null:
		return
	label.add_theme_color_override("font_color", UIThemeConstants.ACCENT_COLOR_AMBER)


static func apply_status_label(label: Label, state: StringName) -> void:
	if label == null:
		return
	label.add_theme_font_size_override("font_size", UIThemeConstants.FONT_SIZE_CAPTION)
	label.add_theme_color_override("font_color", status_color(state))


static func apply_action_button(button: Button, primary: bool = false) -> void:
	if button == null:
		return
	button.custom_minimum_size.y = BUTTON_HEIGHT if primary else BUTTON_HEIGHT_COMPACT
	button.add_theme_font_size_override("font_size", UIThemeConstants.FONT_SIZE_BODY)
	button.modulate = Color.WHITE if primary else Color(1.0, 1.0, 1.0, 0.78)


static func apply_tab_button(button: Button, active: bool, accent: Color) -> void:
	if button == null:
		return
	button.modulate = accent if active else Color.WHITE
	button.add_theme_font_size_override("font_size", UIThemeConstants.FONT_SIZE_BODY)


static func status_color(state: StringName) -> Color:
	match state:
		&"ready", &"ok", &"success", &"selected", &"mint", &"near_mint":
			return UIThemeConstants.get_positive_color()
		&"unaffordable", &"warning", &"fair", &"flagged":
			return UIThemeConstants.get_warning_color()
		&"locked", &"limit", &"error", &"poor", &"mismatch":
			return UIThemeConstants.get_negative_color()
		&"info", &"good":
			return UIThemeConstants.ACCENT_COLOR
		_:
			return UIThemeConstants.DARK_PANEL_TEXT_SECONDARY


static func money_delta_color(amount: float) -> Color:
	if amount > 0.0:
		return UIThemeConstants.SEMANTIC_MONEY_GAIN
	if amount < 0.0:
		return UIThemeConstants.SEMANTIC_MONEY_COST
	return UIThemeConstants.DARK_PANEL_TEXT


static func pricing_ratio_color(ratio: float) -> Color:
	if ratio < PRICING_ZONE_GREEN_MAX:
		return UIThemeConstants.get_positive_color()
	if ratio <= PRICING_ZONE_BLUE_MAX:
		return UIThemeConstants.SEMANTIC_INFO
	if ratio <= PRICING_ZONE_YELLOW_MAX:
		return UIThemeConstants.get_warning_color()
	return UIThemeConstants.get_negative_color()


static func catalog_card_modulate(state: StringName) -> Color:
	match state:
		&"locked":
			return Color(0.722, 0.659, 0.549, STATUS_ALPHA_MUTED)
		&"unaffordable":
			return Color(1.0, 0.706, 0.659, 0.9)
		&"selected":
			return UIThemeConstants.SEMANTIC_SUCCESS
		_:
			return Color.WHITE
