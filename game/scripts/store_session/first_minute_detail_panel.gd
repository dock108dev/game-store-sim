class_name FirstMinuteDetailPanel
extends ModalPanel

signal detail_acknowledged(detail_id: StringName)

const DETAIL_MANAGER_BRIEFING: StringName = &"manager_briefing"
const DETAIL_REGISTER_CHECK: StringName = &"register_check"
const DETAIL_BACKROOM_INVENTORY: StringName = &"backroom_inventory"

const _PASSIVE_DETAILS: Dictionary = {
	DETAIL_MANAGER_BRIEFING: true,
	DETAIL_BACKROOM_INVENTORY: true,
}
const _BLOCKING_DETAILS: Dictionary = {
	DETAIL_REGISTER_CHECK: true,
}

var _detail_id: StringName = &""
var _showing: bool = false
var _acknowledged: bool = false
var _blocker: ColorRect
var _tag_label: Label
var _title_label: Label
var _body_label: RichTextLabel
var _confirm_button: Button


func _ready() -> void:
	layer = 79
	visible = false
	_blocker = ColorRect.new()
	_blocker.name = "Blocker"
	_blocker.color = StoreModalTheme.COLOR_PASSIVE_BLOCKER
	_blocker.set_anchors_preset(Control.PRESET_FULL_RECT)
	_blocker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_blocker)

	var panel := PanelContainer.new()
	panel.name = "Panel"
	panel.custom_minimum_size = StoreModalTheme.DETAIL_PANEL_MIN_SIZE
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -(StoreModalTheme.DETAIL_PANEL_MIN_SIZE.x * 0.5)
	panel.offset_top = -(StoreModalTheme.DETAIL_PANEL_MIN_SIZE.y * 0.5)
	panel.offset_right = StoreModalTheme.DETAIL_PANEL_MIN_SIZE.x * 0.5
	panel.offset_bottom = StoreModalTheme.DETAIL_PANEL_MIN_SIZE.y * 0.5
	panel.add_theme_stylebox_override("panel", StoreModalTheme.make_panel_style())
	_blocker.add_child(panel)

	var root := VBoxContainer.new()
	root.name = "Content"
	root.add_theme_constant_override("separation", StoreModalTheme.DETAIL_PANEL_SPACING)
	panel.add_child(root)

	_tag_label = Label.new()
	_tag_label.name = "Tag"
	_tag_label.add_theme_font_size_override("font_size", StoreModalTheme.DETAIL_TAG_FONT_SIZE)
	_tag_label.add_theme_color_override("font_color", StoreModalTheme.COLOR_TEXT_HEADER)
	root.add_child(_tag_label)

	_title_label = Label.new()
	_title_label.name = "Title"
	_title_label.add_theme_font_size_override("font_size", StoreModalTheme.DETAIL_TITLE_FONT_SIZE)
	_title_label.add_theme_color_override("font_color", StoreModalTheme.COLOR_TEXT_PRIMARY)
	_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(_title_label)

	_body_label = RichTextLabel.new()
	_body_label.bbcode_enabled = true
	_body_label.fit_content = true
	_body_label.scroll_active = false
	_body_label.custom_minimum_size = Vector2(0, 260)
	_body_label.add_theme_font_size_override(
		"normal_font_size", StoreModalTheme.DETAIL_BODY_FONT_SIZE
	)
	_body_label.add_theme_color_override("default_color", StoreModalTheme.COLOR_TEXT_PRIMARY)
	root.add_child(_body_label)

	_confirm_button = Button.new()
	_confirm_button.name = "ConfirmButton"
	_confirm_button.custom_minimum_size = Vector2(0, StoreModalTheme.DETAIL_BUTTON_MIN_HEIGHT)
	_confirm_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	StoreModalTheme.apply_button_theme(_confirm_button)
	_confirm_button.pressed.connect(_on_confirm_pressed)
	root.add_child(_confirm_button)


## Opens one of the supported first-minute detail panels.
func show_detail(detail_id: StringName, payload: Dictionary = {}) -> bool:
	if not supports_detail(detail_id):
		return false
	enqueue(_priority_for_detail(detail_id), {"detail_id": detail_id, "payload": payload})
	return true


func supports_detail(detail_id: StringName) -> bool:
	return _PASSIVE_DETAILS.has(detail_id) or _BLOCKING_DETAILS.has(detail_id)


func active_detail_id() -> StringName:
	return _detail_id


func is_showing_detail() -> bool:
	return _showing


func close() -> void:
	visible = false
	_showing = false
	_acknowledged = false
	_detail_id = &""
	_modal_focusables.clear()
	if _focus_pushed:
		_pop_modal_focus()
	_clear_content()
	ModalQueue.cancel(self)
	ModalQueue.notify_closed(self)


func _open_from_queue(payload: Dictionary) -> void:
	var detail_id: StringName = StringName(str(payload.get("detail_id", "")))
	if not supports_detail(detail_id):
		ModalQueue.notify_closed(self)
		return
	if _BLOCKING_DETAILS.has(detail_id):
		_push_modal_focus()
	visible = true
	_on_queued_open(payload)


func _on_queued_open(payload: Dictionary) -> void:
	_detail_id = StringName(str(payload.get("detail_id", "")))
	var data: Dictionary = payload.get("payload", {}) as Dictionary
	_showing = true
	_acknowledged = false
	_blocker.color = (
		StoreModalTheme.COLOR_BLOCKER
		if _BLOCKING_DETAILS.has(_detail_id)
		else StoreModalTheme.COLOR_PASSIVE_BLOCKER
	)
	_blocker.mouse_filter = (
		Control.MOUSE_FILTER_STOP if _BLOCKING_DETAILS.has(_detail_id) else Control.MOUSE_FILTER_IGNORE
	)
	_tag_label.text = str(data.get("tag", "FIRST MINUTE"))
	_title_label.text = str(data.get("title", "Store Check"))
	_body_label.text = str(data.get("body", ""))
	_confirm_button.text = str(data.get("confirm_label", "Done"))
	_register_modal_focusables([_confirm_button] if _BLOCKING_DETAILS.has(_detail_id) else [])
	if _BLOCKING_DETAILS.has(_detail_id):
		_focus_modal_control_deferred(_confirm_button)
	else:
		_confirm_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if not _showing:
		return
	if _BLOCKING_DETAILS.has(_detail_id):
		if not _modal_can_handle_input():
			return
		if _is_modal_focus_next_event(event):
			_cycle_modal_focus(true)
			get_viewport().set_input_as_handled()
			return
		if _is_modal_focus_previous_event(event):
			_cycle_modal_focus(false)
			get_viewport().set_input_as_handled()
			return
		if event.is_action_pressed(&"ui_accept"):
			if not _activate_focused_modal_button():
				_focus_modal_control(_confirm_button)
			get_viewport().set_input_as_handled()
			return
		if event.is_action_pressed(&"interact") or event.is_action_pressed(&"ui_cancel"):
			get_viewport().set_input_as_handled()
			return
	if (
		event.is_action_pressed(&"interact")
		or event.is_action_pressed(&"ui_accept")
		or event.is_action_pressed(&"ui_cancel")
	):
		_on_confirm_pressed()
		get_viewport().set_input_as_handled()


func acknowledge_for_automation() -> bool:
	if not AutomationModeScript.is_enabled():
		return false
	if not visible:
		return false
	_on_confirm_pressed()
	return true


func _on_confirm_pressed() -> void:
	if _acknowledged or not _showing:
		return
	_acknowledged = true
	var acknowledged_detail: StringName = _detail_id
	close()
	detail_acknowledged.emit(acknowledged_detail)


func _priority_for_detail(detail_id: StringName) -> int:
	if _BLOCKING_DETAILS.has(detail_id):
		return ModalQueue.Priority.DAY_SUMMARY
	return ModalQueue.Priority.VIC_NOTE


func _clear_content() -> void:
	if _tag_label != null:
		_tag_label.text = ""
	if _title_label != null:
		_title_label.text = ""
	if _body_label != null:
		_body_label.text = ""
	if _confirm_button != null:
		_confirm_button.text = ""
