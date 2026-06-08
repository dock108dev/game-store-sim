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
