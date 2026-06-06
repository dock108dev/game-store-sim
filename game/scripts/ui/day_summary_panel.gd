extends CanvasLayer
class_name DaySummaryPanel

@onready var title_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var summary_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/SummaryLabel
@onready var last_sale_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/LastSaleLabel
@onready var inventory_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/InventoryLabel
@onready var status_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/StatusLabel
@onready var end_day_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionRow/EndDayButton
@onready var close_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionRow/CloseButton

var _session: Node = null


func _ready() -> void:
	hide()
	end_day_button.pressed.connect(end_day)
	close_button.pressed.connect(close)


func _unhandled_input(event: InputEvent) -> void:
	if not is_open():
		return

	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func open_for_session(session: Node) -> bool:
	if session == null:
		return false

	_session = session
	_update_labels()
	show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	return true


func is_open() -> bool:
	return visible and _session != null


func get_active_session() -> Node:
	return _session


func end_day() -> bool:
	if _session == null:
		return false

	_session.end_day()
	_update_labels()
	return true


func close() -> bool:
	if not is_open():
		return false

	_session = null
	hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	return true


func _update_labels() -> void:
	if _session == null:
		return

	title_label.text = "Backroom Computer"
	summary_label.text = _session.get_summary_text()
	if _session.has_method("get_recent_activity_text"):
		last_sale_label.text = _session.get_recent_activity_text()
	else:
		last_sale_label.text = "Recent activity unavailable"
	if _session.has_method("get_inventory_summary_text"):
		inventory_label.text = _session.get_inventory_summary_text()
	else:
		inventory_label.text = "Inventory unavailable"
	status_label.text = _session.get_status_label()
	end_day_button.disabled = _session.is_day_closed
