extends CanvasLayer
class_name DaySummaryPanel

const UIComponents := preload("res://scripts/ui/ui_component_library.gd")

const TAB_DASHBOARD := "dashboard"
const TAB_INVENTORY := "inventory"
const TAB_ORDERING := "ordering"
const TAB_RELEASES := "releases"
const TAB_REPORTS := "reports"
const TAB_SERVICES := "services"
const TAB_STORAGE := "storage"
const TAB_SUPPLIERS := "suppliers"
const TAB_SETTINGS := "settings"
const TAB_RECORDS := "records"
const BACKROOM_TABS := [
	TAB_DASHBOARD,
	TAB_INVENTORY,
	TAB_ORDERING,
	TAB_RELEASES,
	TAB_REPORTS,
	TAB_SERVICES,
	TAB_STORAGE,
	TAB_SUPPLIERS,
	TAB_SETTINGS,
	TAB_RECORDS,
]

@onready var title_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var modal_root: Control = $CenterContainer
@onready var tab_grid: GridContainer = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TabGrid
@onready var dashboard_tab_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TabGrid/DashboardTabButton
@onready var inventory_tab_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TabGrid/InventoryTabButton
@onready var ordering_tab_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TabGrid/OrderingTabButton
@onready var releases_tab_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TabGrid/ReleasesTabButton
@onready var reports_tab_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TabGrid/ReportsTabButton
@onready var services_tab_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TabGrid/ServicesTabButton
@onready var storage_tab_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TabGrid/StorageTabButton
@onready var suppliers_tab_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TabGrid/SuppliersTabButton
@onready var settings_tab_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TabGrid/SettingsTabButton
@onready var records_tab_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TabGrid/RecordsTabButton
@onready var content_scroll: ScrollContainer = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer
@onready var dashboard_header: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ContentVBox/DashboardHeader
@onready var summary_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ContentVBox/SummaryLabel
@onready var report_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ContentVBox/ReportLabel
@onready var activity_header: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ContentVBox/ActivityHeader
@onready var last_sale_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ContentVBox/LastSaleLabel
@onready var services_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ContentVBox/ServicesLabel
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
@onready var settings_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ContentVBox/SettingsLabel
@onready var hidden_records_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ContentVBox/HiddenRecordsLabel
@onready var status_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/StatusLabel
@onready var supplier_action_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionGroupRow/SupplierActions/SupplierActionLabel
@onready var storage_action_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionGroupRow/StorageActions/StorageActionLabel
@onready var release_action_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionGroupRow/ReleaseActions/ReleaseActionLabel
@onready var day_action_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionGroupRow/DayActions/DayActionLabel
@onready var placement_action_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/PlacementGroup/PlacementActionLabel
@onready var commit_allocation_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionGroupRow/ReleaseActions/CommitAllocationButton
@onready var order_games_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionGroupRow/SupplierActions/OrderGamesButton
@onready var open_box_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionGroupRow/SupplierActions/ReceivingActionButtons/OpenBoxButton
@onready var check_invoice_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionGroupRow/SupplierActions/ReceivingActionButtons/CheckInvoiceButton
@onready var sort_receiving_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionGroupRow/SupplierActions/ReceivingActionButtons/SortReceivingButton
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
var _active_tab: String = TAB_DASHBOARD


func _ready() -> void:
	hide()
	UIComponents.apply_modal_language(modal_root, UIComponents.SURFACE_BACKROOM)
	tab_grid.set_meta("ui_component", UIComponents.TOKEN_TAB)
	_prepare_tab_button(dashboard_tab_button, TAB_DASHBOARD)
	_prepare_tab_button(inventory_tab_button, TAB_INVENTORY)
	_prepare_tab_button(ordering_tab_button, TAB_ORDERING)
	_prepare_tab_button(releases_tab_button, TAB_RELEASES)
	_prepare_tab_button(reports_tab_button, TAB_REPORTS)
	_prepare_tab_button(services_tab_button, TAB_SERVICES)
	_prepare_tab_button(storage_tab_button, TAB_STORAGE)
	_prepare_tab_button(suppliers_tab_button, TAB_SUPPLIERS)
	_prepare_tab_button(settings_tab_button, TAB_SETTINGS)
	_prepare_tab_button(records_tab_button, TAB_RECORDS)
	commit_allocation_button.pressed.connect(commit_release_allocation)
	order_games_button.pressed.connect(order_used_game_lot)
	open_box_button.pressed.connect(open_receiving_box)
	check_invoice_button.pressed.connect(check_receiving_invoice)
	sort_receiving_button.pressed.connect(sort_receiving_batch)
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
	_apply_tab_visibility()


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
	_active_tab = TAB_DASHBOARD
	_update_labels()
	content_scroll.scroll_vertical = 0
	_apply_tab_visibility()
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
		and tab_grid.get_meta("ui_component", "") == UIComponents.TOKEN_TAB \
		and content_scroll.get_meta("ui_component", "") == UIComponents.TOKEN_LIST \
		and close_button.get_meta("ui_component", "") == UIComponents.TOKEN_BUTTON


func get_available_tabs() -> Array:
	return BACKROOM_TABS.duplicate()


func get_active_tab() -> String:
	return _active_tab


func set_active_tab(tab_id: String) -> bool:
	if not BACKROOM_TABS.has(tab_id):
		return false

	_active_tab = tab_id
	_apply_tab_visibility()
	content_scroll.scroll_vertical = 0
	return true


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


func open_receiving_box() -> bool:
	var batch := _get_first_pending_receiving_batch()
	if batch.is_empty() or _session == null or not _session.has_method("open_receiving_batch"):
		status_label.text = "No receiving box waiting to open."
		return false

	var opened: Dictionary = _session.open_receiving_batch(str(batch.get("batch_id", batch.get("order_id", ""))))
	_update_labels()
	if opened.is_empty():
		status_label.text = "Could not open receiving box."
		return false

	status_label.text = "Opened %s receiving box." % str(opened.get("display_name", "supplier lot"))
	return true


func check_receiving_invoice() -> bool:
	var batch := _get_first_pending_receiving_batch()
	if batch.is_empty() or _session == null or not _session.has_method("check_receiving_invoice"):
		status_label.text = "No receiving invoice waiting."
		return false

	var checked: Dictionary = _session.check_receiving_invoice(str(batch.get("batch_id", batch.get("order_id", ""))))
	_update_labels()
	if checked.is_empty():
		status_label.text = "Could not check receiving invoice."
		return false

	status_label.text = "Checked invoice: %d expected / %d received." % [
		int(checked.get("expected_count", 0)),
		int(checked.get("received_count", 0)),
	]
	return true


func sort_receiving_batch() -> bool:
	var batch := _get_first_pending_receiving_batch()
	if batch.is_empty() or _session == null or not _session.has_method("sort_receiving_batch"):
		status_label.text = "No receiving batch waiting to sort."
		return false

	var sorted: Dictionary = _session.sort_receiving_batch(str(batch.get("batch_id", batch.get("order_id", ""))), "price_stock")
	_update_labels()
	if sorted.is_empty():
		status_label.text = "Could not sort receiving batch."
		return false

	status_label.text = "Sorted %s for pricing and stocking." % str(sorted.get("display_name", "supplier lot"))
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
	if _session.has_method("get_onboarding_summary_text"):
		summary_label.text += "\n" + _session.get_onboarding_summary_text()
	if _session.has_method("get_daily_report_text"):
		report_label.text = _session.get_daily_report_text()
	else:
		report_label.text = "Daily report unavailable"
	if _session.has_method("get_recent_activity_text"):
		last_sale_label.text = _session.get_recent_activity_text()
	else:
		last_sale_label.text = "Recent activity unavailable"
	services_label.text = _get_services_text()
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
	if _session.has_method("get_upgrade_summary_text"):
		settings_label.text = "Settings: input and window settings are available from the pause/settings panel.\n" + _session.get_upgrade_summary_text()
	else:
		settings_label.text = "Settings: input and window settings are available from the pause/settings panel."
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
	var pending_receiving: Dictionary = _get_first_pending_receiving_batch()
	var has_pending_receiving: bool = not pending_receiving.is_empty() and not _session.is_day_closed
	open_box_button.disabled = not has_pending_receiving or str(pending_receiving.get("box_status", "")) != "sealed"
	check_invoice_button.disabled = not has_pending_receiving or str(pending_receiving.get("invoice_status", "")) == "checked"
	sort_receiving_button.disabled = not has_pending_receiving
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
	_update_tab_button_states()


func _prepare_tab_button(button: Button, tab_id: String) -> void:
	button.toggle_mode = true
	button.focus_mode = Control.FOCUS_ALL
	button.set_meta("ui_component", UIComponents.TOKEN_TAB)
	button.set_meta("ui_tab", tab_id)
	button.pressed.connect(set_active_tab.bind(tab_id))


func _get_tab_button(tab_id: String) -> Button:
	match tab_id:
		TAB_DASHBOARD:
			return dashboard_tab_button
		TAB_INVENTORY:
			return inventory_tab_button
		TAB_ORDERING:
			return ordering_tab_button
		TAB_RELEASES:
			return releases_tab_button
		TAB_REPORTS:
			return reports_tab_button
		TAB_SERVICES:
			return services_tab_button
		TAB_STORAGE:
			return storage_tab_button
		TAB_SUPPLIERS:
			return suppliers_tab_button
		TAB_SETTINGS:
			return settings_tab_button
		TAB_RECORDS:
			return records_tab_button
	return dashboard_tab_button


func _get_first_pending_receiving_batch() -> Dictionary:
	if _session == null or not _session.has_method("get_pending_receiving_batches"):
		return {}

	var batches: Array = _session.get_pending_receiving_batches()
	if batches.is_empty() or typeof(batches[0]) != TYPE_DICTIONARY:
		return {}

	var batch: Dictionary = batches[0]
	return batch


func _update_tab_button_states() -> void:
	for tab_id in BACKROOM_TABS:
		var button := _get_tab_button(tab_id)
		button.button_pressed = tab_id == _active_tab
		button.set_meta("ui_selected", button.button_pressed)


func _apply_tab_visibility() -> void:
	var all_content := [
		dashboard_header,
		summary_label,
		report_label,
		activity_header,
		last_sale_label,
		services_label,
		inventory_header,
		inventory_label,
		reorder_label,
		market_header,
		demand_label,
		market_drift_label,
		release_header,
		release_calendar_label,
		operations_header,
		supplier_order_label,
		fixture_label,
		settings_label,
		hidden_records_label,
	]
	_set_controls_visible(all_content, false)

	match _active_tab:
		TAB_DASHBOARD:
			_set_controls_visible([dashboard_header, summary_label, activity_header, last_sale_label], true)
		TAB_INVENTORY:
			_set_controls_visible([inventory_header, inventory_label, reorder_label, market_header, demand_label, market_drift_label], true)
		TAB_ORDERING:
			_set_controls_visible([operations_header, supplier_order_label, fixture_label], true)
		TAB_RELEASES:
			_set_controls_visible([release_header, release_calendar_label], true)
		TAB_REPORTS:
			_set_controls_visible([dashboard_header, report_label], true)
		TAB_SERVICES:
			_set_controls_visible([activity_header, services_label], true)
		TAB_STORAGE:
			_set_controls_visible([operations_header, fixture_label], true)
		TAB_SUPPLIERS:
			_set_controls_visible([operations_header, supplier_order_label], true)
		TAB_SETTINGS:
			_set_controls_visible([settings_label], true)
		TAB_RECORDS:
			_set_controls_visible([hidden_records_label], true)
	_update_tab_button_states()


func _set_controls_visible(controls: Array, is_control_visible: bool) -> void:
	for control in controls:
		if control is Control:
			(control as Control).visible = is_control_visible


func _get_services_text() -> String:
	if _session == null:
		return "Services: none"
	if not _session.has_method("get_service_count"):
		return "Services unavailable"

	var count := int(_session.get_service_count())
	if count <= 0:
		return "Services: none"

	return "Services: %d completed\nRevenue: %s\nCost: %s\nProfit: %s" % [
		count,
		_session.format_money(int(_session.get_total_service_revenue_cents())),
		_session.format_money(int(_session.get_total_service_cost_cents())),
		_session.format_money(int(_session.get_total_service_profit_cents())),
	]


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
