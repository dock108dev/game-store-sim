extends CanvasLayer
class_name DaySummaryPanel

@onready var title_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var summary_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/SummaryLabel
@onready var last_sale_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/LastSaleLabel
@onready var inventory_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/InventoryLabel
@onready var reorder_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ReorderLabel
@onready var fixture_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/FixtureLabel
@onready var status_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/StatusLabel
@onready var order_rack_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionRow/OrderRackButton
@onready var end_day_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionRow/EndDayButton
@onready var close_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionRow/CloseButton

const GAME_DISPLAY_RACK_ID := "fixture_game_display_rack"

var _session: Node = null


func _ready() -> void:
	hide()
	order_rack_button.pressed.connect(order_game_display_rack)
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


func order_game_display_rack() -> bool:
	if _session == null or not _session.has_method("order_fixture"):
		return false

	var order: Dictionary = _session.order_fixture(GAME_DISPLAY_RACK_ID)
	_update_labels()
	if order.is_empty():
		status_label.text = "Could not order rack."
		return false

	status_label.text = "Ordered %s." % str(order.get("display_name", "fixture"))
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
	if _session.has_method("get_reorder_suggestions_text"):
		reorder_label.text = _session.get_reorder_suggestions_text()
	else:
		reorder_label.text = "Reorder suggestions unavailable"
	if _session.has_method("get_fixture_order_summary_text"):
		fixture_label.text = _session.get_fixture_order_summary_text()
	else:
		fixture_label.text = "Fixtures unavailable"
	status_label.text = _session.get_status_label()
	if _session.has_method("can_order_fixture"):
		order_rack_button.disabled = _session.is_day_closed or not _session.can_order_fixture(GAME_DISPLAY_RACK_ID)
	else:
		order_rack_button.disabled = true
	end_day_button.disabled = _session.is_day_closed
