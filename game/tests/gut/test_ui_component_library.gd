extends GutTest

const UIComponents := preload("res://scripts/ui/ui_component_library.gd")


func test_ui_component_library_defines_required_tokens() -> void:
	var tokens: Array[String] = UIComponents.get_component_tokens()

	for token in [
		UIComponents.TOKEN_BUTTON,
		UIComponents.TOKEN_TAB,
		UIComponents.TOKEN_LIST,
		UIComponents.TOKEN_STAT,
		UIComponents.TOKEN_RECEIPT,
		UIComponents.TOKEN_MODAL,
		UIComponents.TOKEN_TOOLTIP,
		UIComponents.TOKEN_ALERT,
		UIComponents.TOKEN_DISABLED,
		UIComponents.TOKEN_SELECTED,
	]:
		assert_true(tokens.has(token), "Missing token %s" % token)


func test_ui_component_library_defines_button_and_alert_states() -> void:
	var button_states: Array[String] = UIComponents.get_button_states()
	var alert_states: Array[String] = UIComponents.get_alert_states()

	assert_true(button_states.has(UIComponents.BUTTON_PRIMARY))
	assert_true(button_states.has(UIComponents.BUTTON_SECONDARY))
	assert_true(button_states.has(UIComponents.BUTTON_DANGER))
	assert_true(button_states.has(UIComponents.BUTTON_GHOST))
	assert_true(button_states.has(UIComponents.TOKEN_DISABLED))
	assert_true(button_states.has(UIComponents.TOKEN_SELECTED))
	assert_true(alert_states.has(UIComponents.ALERT_INFO))
	assert_true(alert_states.has(UIComponents.ALERT_SUCCESS))
	assert_true(alert_states.has(UIComponents.ALERT_WARNING))
	assert_true(alert_states.has(UIComponents.ALERT_DANGER))


func test_ui_component_library_defines_accessibility_requirements() -> void:
	var requirements := UIComponents.get_accessibility_requirements()

	assert_eq(requirements.get("min_button_height"), UIComponents.MIN_BUTTON_HEIGHT)
	assert_eq(requirements.get("min_body_font_size"), UIComponents.MIN_BODY_FONT_SIZE)
	assert_eq(requirements.get("min_header_font_size"), UIComponents.MIN_HEADER_FONT_SIZE)
	assert_eq(requirements.get("max_modal_width_1280"), UIComponents.MAX_MODAL_WIDTH_1280)
	assert_eq(requirements.get("max_modal_height_720"), UIComponents.MAX_MODAL_HEIGHT_720)
	assert_eq(requirements.get("min_contrast_ratio"), UIComponents.MIN_CONTRAST_RATIO)


func test_ui_component_library_contrast_meets_accessibility_floor() -> void:
	var modal_style := UIComponents.get_modal_background_style(UIComponents.SURFACE_BACKROOM)
	var normal_button_style := UIComponents.get_button_style(UIComponents.SURFACE_BACKROOM, UIComponents.BUTTON_SECONDARY)

	assert_true(UIComponents.has_accessible_contrast(Color.WHITE, modal_style.bg_color))
	assert_true(UIComponents.has_accessible_contrast(Color.WHITE, normal_button_style.bg_color))
	assert_gte(UIComponents.get_contrast_ratio(Color.WHITE, modal_style.bg_color), UIComponents.MIN_CONTRAST_RATIO)


func test_ui_component_library_applies_modal_language() -> void:
	var root := CenterContainer.new()
	var panel := PanelContainer.new()
	var title := Label.new()
	var action := Button.new()
	title.name = "TitleLabel"
	action.name = "ApplyButton"
	root.add_child(panel)
	panel.add_child(title)
	panel.add_child(action)
	add_child_autofree(root)

	UIComponents.apply_modal_language(root, UIComponents.SURFACE_PRICING)

	assert_eq(root.get_meta("ui_surface"), UIComponents.SURFACE_PRICING)
	assert_eq(root.get_meta("ui_surface_title"), "Pricing")
	assert_true(root.get_meta("ui_language_tokens").has(UIComponents.TOKEN_MODAL))
	assert_eq(panel.get_meta("ui_component"), UIComponents.TOKEN_MODAL)
	assert_eq(title.get_meta("ui_component"), UIComponents.TOKEN_STAT)
	assert_eq(action.get_meta("ui_component"), UIComponents.TOKEN_BUTTON)
	assert_true(action.get_meta("ui_states").has(UIComponents.TOKEN_DISABLED))
	assert_true(panel.custom_minimum_size.x >= UIComponents.MIN_MODAL_WIDTH)
	assert_true(action.custom_minimum_size.y >= UIComponents.MIN_BUTTON_HEIGHT)
	assert_eq(action.focus_mode, Control.FOCUS_ALL)


func test_ui_component_library_audits_modal_accessibility_floor() -> void:
	var root := CenterContainer.new()
	var panel := PanelContainer.new()
	var title := Label.new()
	var action := Button.new()
	title.name = "TitleLabel"
	action.name = "ApplyButton"
	panel.custom_minimum_size = Vector2(560, 420)
	root.add_child(panel)
	panel.add_child(title)
	panel.add_child(action)
	add_child_autofree(root)

	UIComponents.apply_modal_language(root, UIComponents.SURFACE_REGISTER)
	var audit: Dictionary = UIComponents.audit_modal_accessibility(root)

	assert_true(audit.get("passes"))
	assert_true((audit.get("violations") as Array).is_empty())
