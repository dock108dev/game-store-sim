extends CanvasLayer
class_name DaySummaryPanel

@onready var title_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var content_scroll: ScrollContainer = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer
@onready var summary_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ContentVBox/SummaryLabel
@onready var report_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ContentVBox/ReportLabel
@onready var last_sale_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ContentVBox/LastSaleLabel
@onready var inventory_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ContentVBox/InventoryLabel
@onready var reorder_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ContentVBox/ReorderLabel
@onready var demand_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ContentVBox/DemandLabel
@onready var market_drift_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ContentVBox/MarketDriftLabel
@onready var release_calendar_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ContentVBox/ReleaseCalendarLabel
@onready var supplier_order_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ContentVBox/SupplierOrderLabel
@onready var fixture_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ContentVBox/FixtureLabel
@onready var status_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/StatusLabel
@onready var commit_allocation_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionRow/CommitAllocationButton
@onready var order_games_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionRow/OrderGamesButton
@onready var order_rack_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionRow/OrderRackButton
@onready var place_rack_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionRow/PlaceRackButton
@onready var end_day_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionRow/EndDayButton
@onready var close_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionRow/CloseButton

const GAME_DISPLAY_RACK_ID := "fixture_game_display_rack"
const USED_GAME_STARTER_LOT_ID := "supplier_lot_used_games_001"
const NEON_SKYLINE_RELEASE_ID := "release_neon_skyline"

var _session: Node = null


func _ready() -> void:
	hide()
	commit_allocation_button.pressed.connect(commit_release_allocation)
	order_games_button.pressed.connect(order_used_game_lot)
	order_rack_button.pressed.connect(order_game_display_rack)
	place_rack_button.pressed.connect(place_pending_rack)
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
	content_scroll.scroll_vertical = 0
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

	if _session.is_day_closed and _session.has_method("start_next_day"):
		var started: Dictionary = _session.start_next_day()
		_update_labels()
		if started.is_empty():
			status_label.text = "Could not start next day."
			return false

		var delivered_count := int(started.get("delivered_count", 0))
		var launch_event_count := int(started.get("launch_event_count", 0))
		var status_parts: Array[String] = ["Started day %d." % int(started.get("day_number", 0))]
		if delivered_count > 0:
			status_parts.append("Delivered %d order." % delivered_count)
		if launch_event_count > 0:
			status_parts.append("Resolved %d launch." % launch_event_count)
		status_label.text = " ".join(status_parts)
		return true

	_session.end_day()
	_update_labels()
	return true


func commit_release_allocation() -> bool:
	if _session == null or not _session.has_method("commit_release_allocation"):
		return false

	var allocation: Dictionary = _session.commit_release_allocation(NEON_SKYLINE_RELEASE_ID, 1)
	_update_labels()
	if allocation.is_empty():
		status_label.text = "Could not commit allocation."
		return false

	status_label.text = "Committed %d %s allocation." % [
		int(allocation.get("quantity", 0)),
		str(allocation.get("product_name", "release")),
	]
	return true


func order_used_game_lot() -> bool:
	if _session == null or not _session.has_method("order_supplier_lot"):
		return false

	var order: Dictionary = _session.order_supplier_lot(USED_GAME_STARTER_LOT_ID)
	_update_labels()
	if order.is_empty():
		status_label.text = "Could not order games."
		return false

	status_label.text = "Ordered %s to receiving." % str(order.get("display_name", "supplier lot"))
	return true


func order_game_display_rack() -> bool:
	if _session == null or not _session.has_method("order_fixture"):
		return false

	var order: Dictionary = _session.order_fixture(GAME_DISPLAY_RACK_ID)
	_update_labels()
	if order.is_empty():
		status_label.text = "Could not order rack."
		return false

	status_label.text = "Ordered %s for storage placement." % str(order.get("display_name", "fixture"))
	return true


func place_pending_rack() -> bool:
	if _session == null or not _session.has_method("place_pending_fixture"):
		return false

	var placed: Dictionary = _session.place_pending_fixture()
	_update_labels()
	if placed.is_empty():
		status_label.text = "Could not place rack."
		return false

	status_label.text = "Placed %s in storage." % str(placed.get("display_name", "fixture"))
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
	if _session.has_method("get_daily_report_text"):
		report_label.text = _session.get_daily_report_text()
	else:
		report_label.text = "Daily report unavailable"
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
	if _session.has_method("get_category_demand_summary_text"):
		demand_label.text = _session.get_category_demand_summary_text()
	else:
		demand_label.text = "Category demand unavailable"
	if _session.has_method("get_market_drift_summary_text"):
		market_drift_label.text = _session.get_market_drift_summary_text()
	else:
		market_drift_label.text = "Market drift unavailable"
	if _session.has_method("get_release_calendar_text"):
		release_calendar_label.text = _session.get_release_calendar_text()
		if _session.has_method("get_release_allocation_summary_text"):
			release_calendar_label.text += "\n" + _session.get_release_allocation_summary_text()
		if _session.has_method("get_launch_summary_text"):
			release_calendar_label.text += "\n" + _session.get_launch_summary_text()
	else:
		release_calendar_label.text = "Release calendar unavailable"
	if _session.has_method("get_supplier_order_summary_text"):
		supplier_order_label.text = _session.get_supplier_order_summary_text()
	else:
		supplier_order_label.text = "Supplier orders unavailable"
	if _session.has_method("get_fixture_order_summary_text"):
		fixture_label.text = _session.get_fixture_order_summary_text()
	else:
		fixture_label.text = "Fixtures unavailable"
	status_label.text = _session.get_status_label()
	if _session.has_method("can_commit_release_allocation"):
		commit_allocation_button.disabled = _session.is_day_closed \
			or not _session.can_commit_release_allocation(NEON_SKYLINE_RELEASE_ID, 1)
	else:
		commit_allocation_button.disabled = true
	if _session.has_method("can_order_supplier_lot"):
		order_games_button.disabled = _session.is_day_closed \
			or not _session.can_order_supplier_lot(USED_GAME_STARTER_LOT_ID)
	else:
		order_games_button.disabled = true
	if _session.has_method("can_order_fixture"):
		order_rack_button.disabled = _session.is_day_closed or not _session.can_order_fixture(GAME_DISPLAY_RACK_ID)
	else:
		order_rack_button.disabled = true
	if _session.has_method("can_place_pending_fixture"):
		place_rack_button.disabled = _session.is_day_closed or not _session.can_place_pending_fixture()
	else:
		place_rack_button.disabled = true
	end_day_button.disabled = false
	end_day_button.text = "Start Day" if _session.is_day_closed else "End Day"
