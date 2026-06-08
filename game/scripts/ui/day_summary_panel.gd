extends CanvasLayer
class_name DaySummaryPanel

const UIComponents := preload("res://scripts/ui/ui_component_library.gd")

@onready var title_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var modal_root: Control = $CenterContainer
@onready var content_scroll: ScrollContainer = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer
@onready var dashboard_header: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ContentVBox/DashboardHeader
@onready var summary_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ContentVBox/SummaryLabel
@onready var report_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ContentVBox/ReportLabel
@onready var activity_header: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ContentVBox/ActivityHeader
@onready var last_sale_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ContentVBox/LastSaleLabel
@onready var inventory_header: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ContentVBox/InventoryHeader
@onready var inventory_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ContentVBox/InventoryLabel
@onready var reorder_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ContentVBox/ReorderLabel
@onready var market_header: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ContentVBox/MarketHeader
@onready var demand_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ContentVBox/DemandLabel
@onready var market_drift_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ContentVBox/MarketDriftLabel
@onready var release_header: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ContentVBox/ReleaseHeader
@onready var release_calendar_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ContentVBox/ReleaseCalendarLabel
@onready var operations_header: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ContentVBox/OperationsHeader
@onready var supplier_order_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ContentVBox/SupplierOrderLabel
@onready var fixture_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ContentVBox/FixtureLabel
@onready var status_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/StatusLabel
@onready var supplier_action_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionGroupRow/SupplierActions/SupplierActionLabel
@onready var storage_action_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionGroupRow/StorageActions/StorageActionLabel
@onready var release_action_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionGroupRow/ReleaseActions/ReleaseActionLabel
@onready var day_action_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionGroupRow/DayActions/DayActionLabel
@onready var placement_action_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/PlacementGroup/PlacementActionLabel
@onready var commit_allocation_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionGroupRow/ReleaseActions/CommitAllocationButton
@onready var order_games_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionGroupRow/SupplierActions/OrderGamesButton
@onready var order_rack_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionGroupRow/StorageActions/StorageActionButtons/OrderRackButton
@onready var place_rack_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionGroupRow/StorageActions/StorageActionButtons/PlaceRackButton
@onready var end_day_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionGroupRow/DayActions/DayActionButtons/EndDayButton
@onready var close_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionGroupRow/DayActions/DayActionButtons/CloseButton
@onready var rack_left_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/PlacementGroup/PlacementRow/RackLeftButton
@onready var rack_right_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/PlacementGroup/PlacementRow/RackRightButton
@onready var rack_forward_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/PlacementGroup/PlacementRow/RackForwardButton
@onready var rack_back_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/PlacementGroup/PlacementRow/RackBackButton
@onready var rotate_rack_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/PlacementGroup/PlacementRow/RotateRackButton
@onready var snap_rack_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/PlacementGroup/PlacementRow/SnapRackButton
@onready var cancel_rack_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/PlacementGroup/PlacementRow/CancelRackButton

const GAME_DISPLAY_RACK_ID := "fixture_game_display_rack"
const USED_GAME_STARTER_LOT_ID := "supplier_lot_used_games_001"
const NEON_SKYLINE_RELEASE_ID := "release_neon_skyline"

var _session: Node = null
var _transition_state: String = "closed"
var _requested_mouse_mode: int = Input.MOUSE_MODE_CAPTURED


func _ready() -> void:
	hide()
	UIComponents.apply_modal_language(modal_root, UIComponents.SURFACE_BACKROOM)
	commit_allocation_button.pressed.connect(commit_release_allocation)
	order_games_button.pressed.connect(order_used_game_lot)
	order_rack_button.pressed.connect(order_game_display_rack)
	place_rack_button.pressed.connect(place_pending_rack)
	rack_left_button.pressed.connect(move_pending_rack_left)
	rack_right_button.pressed.connect(move_pending_rack_right)
	rack_forward_button.pressed.connect(move_pending_rack_forward)
	rack_back_button.pressed.connect(move_pending_rack_back)
	rotate_rack_button.pressed.connect(rotate_pending_rack)
	snap_rack_button.pressed.connect(snap_pending_rack)
	cancel_rack_button.pressed.connect(cancel_pending_rack)
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
	_enter_modal(close_button)
	return true


func is_open() -> bool:
	return visible and _session != null


func get_active_session() -> Node:
	return _session


func get_transition_state() -> String:
	return _transition_state


func get_requested_mouse_mode() -> int:
	return _requested_mouse_mode


func has_modal_focus() -> bool:
	var focus_owner := get_viewport().gui_get_focus_owner()
	return focus_owner != null and is_ancestor_of(focus_owner)


func has_ui_component_language() -> bool:
	return modal_root.get_meta("ui_language_tokens", []).has(UIComponents.TOKEN_TAB) \
		and modal_root.get_meta("ui_language_tokens", []).has(UIComponents.TOKEN_RECEIPT) \
		and content_scroll.get_meta("ui_component", "") == UIComponents.TOKEN_LIST \
		and close_button.get_meta("ui_component", "") == UIComponents.TOKEN_BUTTON


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


func move_pending_rack_left() -> bool:
	return _adjust_pending_rack(-1, 0, "left")


func move_pending_rack_right() -> bool:
	return _adjust_pending_rack(1, 0, "right")


func move_pending_rack_forward() -> bool:
	return _adjust_pending_rack(0, -1, "forward")


func move_pending_rack_back() -> bool:
	return _adjust_pending_rack(0, 1, "back")


func rotate_pending_rack() -> bool:
	if _session == null or not _session.has_method("rotate_pending_fixture_placement"):
		return false

	var did_rotate: bool = _session.rotate_pending_fixture_placement(true)
	_update_labels()
	if not did_rotate:
		status_label.text = "Could not rotate storage rack preview."
		return false

	status_label.text = "Rotated storage rack preview."
	return true


func snap_pending_rack() -> bool:
	if _session == null or not _session.has_method("snap_pending_fixture_placement"):
		return false

	var did_snap: bool = _session.snap_pending_fixture_placement()
	_update_labels()
	if not did_snap:
		status_label.text = "Could not snap storage rack preview."
		return false

	status_label.text = "Snapped storage rack preview to grid."
	return true


func cancel_pending_rack() -> bool:
	if _session == null or not _session.has_method("cancel_pending_fixture_placement"):
		return false

	var canceled: Dictionary = _session.cancel_pending_fixture_placement()
	_update_labels()
	if canceled.is_empty():
		status_label.text = "Could not cancel storage rack placement."
		return false

	status_label.text = "Canceled %s placement. Refunded %s." % [
		str(canceled.get("display_name", "fixture")),
		"$%0.2f" % (int(canceled.get("cost_cents", 0)) / 100.0),
	]
	return true


func close() -> bool:
	if not is_open():
		return false

	_session = null
	_exit_modal()
	return true


func _enter_modal(default_focus: Control) -> void:
	show()
	_requested_mouse_mode = Input.MOUSE_MODE_VISIBLE
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_transition_state = "open"
	if default_focus != null:
		default_focus.grab_focus()


func _exit_modal() -> void:
	_release_modal_focus()
	hide()
	_requested_mouse_mode = Input.MOUSE_MODE_CAPTURED
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_transition_state = "closed"


func _release_modal_focus() -> void:
	var focus_owner := get_viewport().gui_get_focus_owner()
	if focus_owner != null and is_ancestor_of(focus_owner):
		focus_owner.release_focus()


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
	var can_adjust_fixture := false
	if _session.has_method("can_adjust_pending_fixture_placement"):
		can_adjust_fixture = not _session.is_day_closed and _session.can_adjust_pending_fixture_placement()
	for button in [
		rack_left_button,
		rack_right_button,
		rack_forward_button,
		rack_back_button,
		rotate_rack_button,
		snap_rack_button,
		cancel_rack_button,
	]:
		button.disabled = not can_adjust_fixture
	if _session.has_method("can_cancel_pending_fixture_placement"):
		cancel_rack_button.disabled = _session.is_day_closed or not _session.can_cancel_pending_fixture_placement()
	end_day_button.disabled = false
	end_day_button.text = "Start Day" if _session.is_day_closed else "End Day"


func _adjust_pending_rack(delta_x: int, delta_z: int, direction_label: String) -> bool:
	if _session == null or not _session.has_method("move_pending_fixture_placement"):
		return false

	var did_move: bool = _session.move_pending_fixture_placement(delta_x, delta_z)
	_update_labels()
	if not did_move:
		status_label.text = "Could not move storage rack preview %s." % direction_label
		return false

	status_label.text = "Moved storage rack preview %s." % direction_label
	return true
