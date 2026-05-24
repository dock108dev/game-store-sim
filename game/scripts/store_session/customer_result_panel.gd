class_name CustomerResultPanel
extends ModalPanel

signal result_acknowledged(event_id: StringName, choice_id: StringName)

var _event_id: StringName = &""
var _choice_id: StringName = &""
var _tag_label: Label
var _title_label: Label
var _subhead_label: Label
var _choice_label: Label
var _acknowledgement_label: Label
var _continue_button: Button


func _ready() -> void:
	layer = 80
	visible = false
	var blocker := ColorRect.new()
	blocker.color = StoreModalTheme.COLOR_BLOCKER
	blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	blocker.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(blocker)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(560, 280)
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -280
	panel.offset_top = -140
	panel.offset_right = 280
	panel.offset_bottom = 140
	panel.add_theme_stylebox_override("panel", StoreModalTheme.make_panel_style())
	blocker.add_child(panel)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 10)
	panel.add_child(root)

	_tag_label = Label.new()
	_tag_label.text = "OUTCOME NOTED"
	_tag_label.add_theme_font_size_override("font_size", 14)
	_tag_label.add_theme_color_override("font_color", StoreModalTheme.COLOR_TEXT_MUTED)
	root.add_child(_tag_label)

	_title_label = Label.new()
	_title_label.add_theme_font_size_override("font_size", 24)
	_title_label.add_theme_color_override("font_color", StoreModalTheme.COLOR_TEXT_PRIMARY)
	_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(_title_label)

	_subhead_label = _make_body_label(root, StoreModalTheme.COLOR_TEXT_MUTED)
	_choice_label = _make_body_label(root, StoreModalTheme.COLOR_TEXT_MUTED)
	_acknowledgement_label = _make_body_label(root, StoreModalTheme.COLOR_TEXT_PRIMARY)

	_continue_button = Button.new()
	_continue_button.text = "Done"
	_continue_button.custom_minimum_size = Vector2(0, 48)
	_continue_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	StoreModalTheme.apply_button_theme(_continue_button)
	_continue_button.pressed.connect(_on_continue_pressed)
	root.add_child(_continue_button)


func show_result(result_data: Dictionary) -> void:
	enqueue(ModalQueue.Priority.DAY_SUMMARY, {"result_data": result_data})


func _on_queued_open(payload: Dictionary) -> void:
	var result_data: Dictionary = payload.get("result_data", {}) as Dictionary
	_event_id = StringName(str(result_data.get("event_id", "")))
	_choice_id = StringName(str(result_data.get("choice_id", "")))
	var result: Dictionary = result_data.get("result", {}) as Dictionary
	var customer_name: String = str(result_data.get("customer_name", "Customer"))
	var event_title: String = str(result_data.get("event_title", "Customer"))
	var choice_label: String = str(result_data.get("choice_label", ""))

	_title_label.text = str(result.get("headline", "Customer Served"))
	_subhead_label.text = "%s - %s" % [customer_name, event_title]
	_choice_label.text = _choice_acknowledgement(choice_label)
	_choice_label.visible = not choice_label.is_empty()
	_acknowledgement_label.text = str(result.get("acknowledgement", "Outcome noted."))
	_continue_button.text = str(result.get("ack_prompt", "Done"))

	_register_modal_focusables([_continue_button])
	_focus_modal_control_deferred(_continue_button)


func _unhandled_input(event: InputEvent) -> void:
	if not _modal_can_handle_input():
		return
	if event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed(&"ui_accept"):
		if _activate_focused_modal_button():
			get_viewport().set_input_as_handled()
		return
	if _is_modal_focus_previous_event(event):
		if _cycle_modal_focus(false):
			get_viewport().set_input_as_handled()
		return
	if _is_modal_focus_next_event(event):
		if _cycle_modal_focus(true):
			get_viewport().set_input_as_handled()


func _choice_acknowledgement(logged_choice: String) -> String:
	if logged_choice.is_empty():
		return ""
	return "Choice logged."


func _make_body_label(parent: Container, color: Color) -> Label:
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label


func _on_continue_pressed() -> void:
	result_acknowledged.emit(_event_id, _choice_id)
	close()
