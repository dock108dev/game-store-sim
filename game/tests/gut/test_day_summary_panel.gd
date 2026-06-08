extends GutTest

const UIComponents := preload("res://scripts/ui/ui_component_library.gd")

var _panel: Node
var _session: Node
var _ledger: TransactionLedger


func before_each() -> void:
	_panel = load("res://scenes/ui/day_summary_panel.tscn").instantiate()
	_session = load("res://scripts/systems/store_session.gd").new()
	_ledger = TransactionLedger.new()
	add_child_autofree(_panel)
	add_child_autofree(_ledger)
	add_child_autofree(_session)
	_session.ledger_path = _session.get_path_to(_ledger)


func test_day_summary_panel_starts_hidden() -> void:
	assert_false(_panel.visible)
	assert_false(_panel.is_open())
	assert_true(_panel.has_ui_component_language())
	assert_true(UIComponents.audit_modal_accessibility(_panel.modal_root).get("passes"))


func test_day_summary_panel_opens_with_cash_and_sales_fields() -> void:
	assert_true(_panel.open_for_session(_session))

	assert_true(_panel.is_open())
	assert_eq(_panel.get_active_session(), _session)
	assert_string_contains(_panel.title_label.text, "Backroom Computer")
	assert_eq(_panel.dashboard_header.text, "Dashboard")
	assert_eq(_panel.activity_header.text, "Activity")
	assert_eq(_panel.inventory_header.text, "Inventory")
	assert_eq(_panel.market_header.text, "Market")
	assert_eq(_panel.release_header.text, "Releases")
	assert_eq(_panel.operations_header.text, "Operations")
	assert_string_contains(_panel.summary_label.text, "Cash: $500.00")
	assert_string_contains(_panel.summary_label.text, "Sales: 0")
	assert_string_contains(_panel.summary_label.text, "Owner checklist:")
	assert_string_contains(_panel.summary_label.text, "Next - Receiving")
	assert_string_contains(_panel.summary_label.text, "Later - Pricing")
	assert_eq(_panel.report_label.text, "Daily report: day still open")
	assert_eq(_panel.last_sale_label.text, "Recent activity: none")
	assert_string_contains(_panel.release_calendar_label.text, "Release calendar:")
	assert_string_contains(_panel.release_calendar_label.text, "Neon Skyline")
	assert_string_contains(_panel.release_calendar_label.text, "MSRP $49.99")
	assert_string_contains(_panel.release_calendar_label.text, "Release allocations: none")
	assert_string_contains(_panel.supplier_order_label.text, "Order Used Game Starter Lot $27.00")
	assert_string_contains(_panel.supplier_order_label.text, "Category: Used games")
	assert_string_contains(_panel.supplier_order_label.text, "Cart: 1 lot / 3 items")
	assert_string_contains(_panel.supplier_order_label.text, "Delivery: due day 2 (1 day)")
	assert_string_contains(_panel.supplier_order_label.text, "Storage: Receiving box intake")
	assert_string_contains(_panel.supplier_order_label.text, "Receiving: Delivered as physical cases")
	assert_string_contains(_panel.supplier_order_label.text, "Pending receiving: none")
	assert_string_contains(_panel.fixture_label.text, "Order Game Display Rack $125.00 for storage placement")
	assert_eq(_panel.services_label.text, "Services: none")
	assert_string_contains(_panel.settings_label.text, "Settings:")
	assert_eq(_panel.hidden_records_label.text, "Hidden records: no active records.")
	assert_eq(_panel.get_active_tab(), "dashboard")
	assert_true(_panel.dashboard_tab_button.button_pressed)
	assert_true(_panel.summary_label.visible)
	assert_false(_panel.inventory_label.visible)
	assert_false(_panel.commit_allocation_button.disabled)
	assert_false(_panel.order_games_button.disabled)
	assert_false(_panel.order_rack_button.disabled)
	assert_true(_panel.place_rack_button.disabled)
	assert_eq(_panel.supplier_action_label.text, "Supplier")
	assert_eq(_panel.storage_action_label.text, "Storage")
	assert_eq(_panel.release_action_label.text, "Release")
	assert_eq(_panel.day_action_label.text, "Day")
	assert_eq(_panel.placement_action_label.text, "Storage Placement")
	assert_eq(_panel.order_games_button.text, "Order Lot")
	assert_eq(_panel.order_rack_button.text, "Order Rack")
	assert_eq(_panel.place_rack_button.text, "Place Rack")
	assert_eq(_panel.commit_allocation_button.text, "Commit Release")
	assert_eq(_panel.rack_left_button.text, "Left")
	assert_eq(_panel.rack_right_button.text, "Right")
	assert_eq(_panel.rack_forward_button.text, "Fwd")
	assert_eq(_panel.rack_back_button.text, "Back")
	assert_eq(_panel.rotate_rack_button.text, "Rotate")
	assert_eq(_panel.snap_rack_button.text, "Snap")
	assert_eq(_panel.cancel_rack_button.text, "Cancel")
	assert_eq(_panel.status_label.text, "Day open")
	assert_false(_panel.end_day_button.disabled)
	assert_eq(_panel.end_day_button.text, "End Day")


func test_day_summary_panel_exposes_backroom_computer_tabs() -> void:
	assert_true(_panel.open_for_session(_session))

	assert_eq(_panel.get_available_tabs(), [
		"dashboard",
		"inventory",
		"ordering",
		"releases",
		"reports",
		"services",
		"storage",
		"suppliers",
		"settings",
		"records",
	])
	assert_eq(_panel.dashboard_tab_button.text, "Dashboard")
	assert_eq(_panel.inventory_tab_button.text, "Inventory")
	assert_eq(_panel.ordering_tab_button.text, "Ordering")
	assert_eq(_panel.releases_tab_button.text, "Releases")
	assert_eq(_panel.reports_tab_button.text, "Reports")
	assert_eq(_panel.services_tab_button.text, "Services")
	assert_eq(_panel.storage_tab_button.text, "Storage")
	assert_eq(_panel.suppliers_tab_button.text, "Suppliers")
	assert_eq(_panel.settings_tab_button.text, "Settings")
	assert_eq(_panel.records_tab_button.text, "Records")
	assert_eq(_panel.tab_grid.get_meta("ui_component", ""), "tab")


func test_day_summary_panel_switches_backroom_tab_visibility() -> void:
	var customer: Node = load("res://scenes/customers/simple_service_customer.tscn").instantiate()
	add_child_autofree(customer)
	var transaction := _ledger.record_service(customer)
	_session.apply_service(transaction)
	assert_true(_panel.open_for_session(_session))

	assert_true(_panel.set_active_tab("inventory"))
	assert_eq(_panel.get_active_tab(), "inventory")
	assert_true(_panel.inventory_label.visible)
	assert_true(_panel.demand_label.visible)
	assert_false(_panel.summary_label.visible)
	assert_true(_panel.inventory_tab_button.button_pressed)
	assert_false(_panel.dashboard_tab_button.button_pressed)

	assert_true(_panel.set_active_tab("services"))
	assert_true(_panel.services_label.visible)
	assert_string_contains(_panel.services_label.text, "Services: 1 completed")
	assert_string_contains(_panel.services_label.text, "Revenue: $4.99")
	assert_false(_panel.inventory_label.visible)

	assert_true(_panel.set_active_tab("settings"))
	assert_true(_panel.settings_label.visible)
	assert_string_contains(_panel.settings_label.text, "Upgrades:")
	assert_string_contains(_panel.settings_label.text, "Staff Picks Signage")
	assert_false(_panel.services_label.visible)

	assert_true(_panel.set_active_tab("records"))
	assert_true(_panel.hidden_records_label.visible)
	assert_false(_panel.set_active_tab("missing"))
	assert_eq(_panel.get_active_tab(), "records")


func test_day_summary_panel_transition_controls_mouse_and_focus() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	assert_eq(_panel.get_transition_state(), "closed")
	assert_true(_panel.open_for_session(_session))

	assert_eq(_panel.get_transition_state(), "open")
	assert_eq(_panel.get_requested_mouse_mode(), Input.MOUSE_MODE_VISIBLE)
	assert_true(_panel.has_modal_focus())
	assert_eq(get_viewport().gui_get_focus_owner(), _panel.close_button)

	assert_true(_panel.close())

	assert_eq(_panel.get_transition_state(), "closed")
	assert_eq(_panel.get_requested_mouse_mode(), Input.MOUSE_MODE_CAPTURED)
	assert_false(_panel.has_modal_focus())


func test_day_summary_panel_groups_readouts_by_management_section() -> void:
	assert_true(_panel.open_for_session(_session))

	var content_vbox := _panel.get_node("CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ContentVBox")
	var expected_order := [
		"DashboardHeader",
		"SummaryLabel",
		"ReportLabel",
		"ActivityHeader",
		"LastSaleLabel",
		"ServicesLabel",
		"InventoryHeader",
		"InventoryLabel",
		"ReorderLabel",
		"MarketHeader",
		"DemandLabel",
		"MarketDriftLabel",
		"ReleaseHeader",
		"ReleaseCalendarLabel",
		"OperationsHeader",
		"SupplierOrderLabel",
		"FixtureLabel",
		"SettingsLabel",
		"HiddenRecordsLabel",
	]

	assert_eq(content_vbox.get_child_count(), expected_order.size())
	for index in range(expected_order.size()):
		assert_eq(content_vbox.get_child(index).name, expected_order[index])


func test_day_summary_panel_groups_actions_by_operation() -> void:
	assert_true(_panel.open_for_session(_session))

	assert_eq(_panel.order_games_button.get_parent().name, "SupplierActions")
	assert_eq(_panel.order_rack_button.get_parent().get_parent().name, "StorageActions")
	assert_eq(_panel.place_rack_button.get_parent().get_parent().name, "StorageActions")
	assert_eq(_panel.commit_allocation_button.get_parent().name, "ReleaseActions")
	assert_eq(_panel.end_day_button.get_parent().get_parent().name, "DayActions")
	assert_eq(_panel.close_button.get_parent().get_parent().name, "DayActions")
	assert_eq(_panel.rack_left_button.get_parent().get_parent().name, "PlacementGroup")


func test_day_summary_panel_includes_recent_sale_activity() -> void:
	var item: Node = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(item)
	var transaction := _ledger.record_sale("customer_001", item)
	_session.apply_sale(transaction)

	assert_true(_panel.open_for_session(_session))

	assert_string_contains(_panel.summary_label.text, "Cash: $521.99")
	assert_string_contains(_panel.summary_label.text, "Revenue: $21.99")
	assert_string_contains(_panel.summary_label.text, "Profit: $12.99")
	assert_string_contains(_panel.last_sale_label.text, "Recent activity:")
	assert_string_contains(_panel.last_sale_label.text, "Sale Star Trader $21.99 profit $12.99")


func test_day_summary_panel_includes_recent_trade_in_activity() -> void:
	var customer: SimpleTradeInCustomer = load("res://scenes/customers/simple_trade_in_customer.tscn").instantiate()
	add_child_autofree(customer)
	var transaction := _ledger.record_trade_in("trade_seller_001", customer.get_trade_item(), 760)
	_session.apply_trade_in(transaction)

	assert_true(_panel.open_for_session(_session))

	assert_string_contains(_panel.summary_label.text, "Trade-ins: 1")
	assert_string_contains(_panel.summary_label.text, "Trade cash: $7.60")
	assert_string_contains(_panel.summary_label.text, "Store credit: $0.00")
	assert_string_contains(_panel.last_sale_label.text, "Trade-in Moon Escape offer $7.60")


func test_day_summary_panel_includes_store_credit_trade_in_activity() -> void:
	var customer: SimpleTradeInCustomer = load("res://scenes/customers/simple_trade_in_customer.tscn").instantiate()
	add_child_autofree(customer)
	var transaction := _ledger.record_trade_in(
		"trade_seller_001",
		customer.get_trade_item(),
		950,
		"store_credit"
	)
	_session.apply_trade_in(transaction)

	assert_true(_panel.open_for_session(_session))

	assert_string_contains(_panel.summary_label.text, "Trade-ins: 1")
	assert_string_contains(_panel.summary_label.text, "Trade cash: $0.00")
	assert_string_contains(_panel.summary_label.text, "Store credit: $9.50")
	assert_string_contains(_panel.last_sale_label.text, "Trade-in Moon Escape credit $9.50")


func test_day_summary_panel_includes_preorder_deposit_activity() -> void:
	var release := load("res://data/releases/neon_skyline_launch.tres")
	var transaction := _ledger.record_preorder_deposit("preorder_customer_001", release, 500)
	_session.apply_preorder_deposit(transaction)

	assert_true(_panel.open_for_session(_session))

	assert_string_contains(_panel.summary_label.text, "Preorders: 1")
	assert_string_contains(_panel.summary_label.text, "Preorder deposits: $5.00")
	assert_string_contains(_panel.last_sale_label.text, "Preorder Neon Skyline deposit $5.00")


func test_day_summary_panel_commits_release_allocation_from_backroom_computer() -> void:
	assert_true(_panel.open_for_session(_session))

	assert_true(_panel.commit_release_allocation())

	assert_eq(_session.get_cash_cents(), 46800)
	assert_eq(_session.get_release_allocation_count(), 1)
	assert_string_contains(_panel.summary_label.text, "Cash: $468.00")
	assert_string_contains(_panel.summary_label.text, "Release allocations: 1")
	assert_string_contains(_panel.summary_label.text, "Allocation cost: $32.00")
	assert_string_contains(_panel.release_calendar_label.text, "Neon Skyline x1 committed $32.00 due day 3")
	assert_eq(_panel.status_label.text, "Committed 1 Neon Skyline allocation.")
	assert_false(_panel.commit_allocation_button.disabled)


func test_day_summary_panel_starts_launch_day_and_shows_release_outcome() -> void:
	var release := load("res://data/releases/neon_skyline_launch.tres")
	var preorder := _ledger.record_preorder_deposit("preorder_customer_001", release, 500)
	_session.apply_preorder_deposit(preorder)
	_session.commit_release_allocation("release_neon_skyline", 4)
	assert_true(_panel.open_for_session(_session))

	assert_true(_panel.end_day())
	assert_true(_panel.end_day())
	assert_eq(_session.day_number, 2)
	assert_true(_panel.end_day())
	assert_true(_panel.end_day())

	assert_eq(_session.day_number, 3)
	assert_eq(_session.get_launch_event_count(), 1)
	assert_string_contains(_panel.status_label.text, "Started day 3.")
	assert_string_contains(_panel.status_label.text, "Resolved 1 launch.")
	assert_string_contains(_panel.summary_label.text, "Launch events: 1")
	assert_string_contains(_panel.summary_label.text, "Reputation: 100")
	assert_string_contains(_panel.summary_label.text, "Launch cash: $144.97")
	assert_string_contains(_panel.release_calendar_label.text, "Launch events:")
	assert_string_contains(_panel.release_calendar_label.text, "Neon Skyline launch: preorders 1/1, queue 2/2, missed 0")
	assert_true(_panel.commit_allocation_button.disabled)


func test_day_summary_panel_includes_inventory_summary() -> void:
	var item: Node = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(item)
	_session.inventory_root_path = _session.get_path_to(item.get_parent())

	assert_true(_panel.open_for_session(_session))

	assert_string_contains(_panel.inventory_label.text, "Inventory:")
	assert_string_contains(_panel.inventory_label.text, "Star Trader x1")


func test_day_summary_panel_includes_reorder_suggestions() -> void:
	var root := Node3D.new()
	var sold_item: Node = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	var active_item: Node = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(root)
	root.add_child(active_item)
	add_child_autofree(sold_item)
	_session.inventory_root_path = _session.get_path_to(root)
	_ledger.record_sale("customer_001", sold_item)

	assert_true(_panel.open_for_session(_session))

	assert_string_contains(_panel.reorder_label.text, "Reorder suggestions:")
	assert_string_contains(_panel.reorder_label.text, "Restock Star Trader")


func test_day_summary_panel_includes_category_demand() -> void:
	assert_true(_panel.open_for_session(_session))

	assert_string_contains(_panel.demand_label.text, "Category demand:")
	assert_string_contains(_panel.demand_label.text, "Used games x1.00")
	assert_string_contains(_panel.demand_label.text, "Hardware x0.80")
	assert_string_contains(_panel.demand_label.text, "Demand tuning signals:")


func test_day_summary_panel_includes_market_drift() -> void:
	var item: Node = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(item)
	_session.inventory_root_path = _session.get_path_to(item.get_parent())

	assert_true(_panel.open_for_session(_session))

	assert_string_contains(_panel.market_drift_label.text, "Market drift day 1:")
	assert_string_contains(_panel.market_drift_label.text, "Star Trader")


func test_day_summary_panel_orders_fixture_from_backroom_computer() -> void:
	assert_true(_panel.open_for_session(_session))

	assert_true(_panel.order_game_display_rack())

	assert_eq(_session.get_cash_cents(), 37500)
	assert_string_contains(_panel.summary_label.text, "Cash: $375.00")
	assert_string_contains(_panel.fixture_label.text, "Pending storage placement:")
	assert_string_contains(_panel.fixture_label.text, "Game Display Rack $125.00")
	assert_eq(_panel.status_label.text, "Ordered Game Display Rack for storage placement.")
	assert_true(_panel.place_rack_button.disabled)
	assert_true(_panel.rack_left_button.disabled)


func test_day_summary_panel_orders_supplier_lot_from_backroom_computer() -> void:
	assert_true(_panel.open_for_session(_session))

	assert_true(_panel.order_used_game_lot())

	assert_eq(_session.get_cash_cents(), 47300)
	assert_string_contains(_panel.summary_label.text, "Cash: $473.00")
	assert_string_contains(_panel.supplier_order_label.text, "Pending receiving:")
	assert_string_contains(_panel.supplier_order_label.text, "Used Game Starter Lot due to receiving day 2 (3 items)")
	assert_string_contains(_panel.supplier_order_label.text, "Delivery state: pending delivery")
	assert_string_contains(_panel.supplier_order_label.text, "Cost reserved: $27.00")
	assert_eq(_panel.status_label.text, "Ordered Used Game Starter Lot to receiving.")


func test_day_summary_panel_starts_next_day_and_delivers_supplier_lot() -> void:
	var root := Node3D.new()
	var receiving_box: Node3D = load("res://scenes/props/receiving_box.tscn").instantiate()
	add_child_autofree(root)
	root.add_child(receiving_box)
	_session.inventory_root_path = _session.get_path_to(root)
	_session.receiving_box_path = _session.get_path_to(receiving_box)
	assert_true(_panel.open_for_session(_session))
	assert_true(_panel.order_used_game_lot())

	assert_true(_panel.end_day())
	assert_true(_session.is_day_closed)
	assert_eq(_panel.end_day_button.text, "Start Day")

	assert_true(_panel.end_day())

	assert_false(_session.is_day_closed)
	assert_eq(_session.day_number, 2)
	assert_string_contains(_panel.status_label.text, "Started day 2. Delivered 1 order.")
	assert_string_contains(_panel.supplier_order_label.text, "Receiving box:")
	assert_string_contains(_panel.supplier_order_label.text, "Delivery state: delivered")
	assert_string_contains(_panel.supplier_order_label.text, "3 items ready for pickup, pricing, and stocking")
	assert_string_contains(_panel.inventory_label.text, "Moon Escape x1")
	assert_not_null(receiving_box.get_node_or_null("DeliveredUsedGame004"))
	assert_eq(_panel.end_day_button.text, "End Day")


func test_day_summary_panel_places_pending_fixture_from_backroom_computer() -> void:
	var fixture_root := Node3D.new()
	var manager: Node = load("res://scripts/store_layout/fixture_placement_manager.gd").new()
	var ghost := Node3D.new()
	ghost.name = "GhostRackPreview"
	add_child_autofree(fixture_root)
	fixture_root.add_child(manager)
	manager.add_child(ghost)
	manager._ready()
	_session.fixture_placement_manager_path = _session.get_path_to(manager)
	_session.inventory_root_path = _session.get_path_to(fixture_root)
	assert_true(_panel.open_for_session(_session))
	assert_true(_panel.order_game_display_rack())

	assert_false(_panel.place_rack_button.disabled)
	assert_true(_panel.place_pending_rack())

	assert_eq(_session.get_pending_fixture_orders().size(), 0)
	assert_eq(_session.get_placed_fixture_orders().size(), 1)
	assert_not_null(fixture_root.get_node_or_null("PlacedGameDisplayRack001"))
	assert_string_contains(_panel.fixture_label.text, "Pending storage placement: none")
	assert_string_contains(_panel.fixture_label.text, "Placed storage fixtures:")
	assert_eq(_panel.status_label.text, "Placed Game Display Rack in storage.")
	assert_true(_panel.place_rack_button.disabled)


func test_day_summary_panel_adjusts_pending_fixture_preview() -> void:
	var fixture_root := Node3D.new()
	var manager: FixturePlacementManager = load("res://scripts/store_layout/fixture_placement_manager.gd").new()
	var ghost := Node3D.new()
	ghost.name = "GhostRackPreview"
	add_child_autofree(fixture_root)
	fixture_root.add_child(manager)
	manager.add_child(ghost)
	manager._ready()
	_session.fixture_placement_manager_path = _session.get_path_to(manager)
	_session.inventory_root_path = _session.get_path_to(fixture_root)
	assert_true(_panel.open_for_session(_session))
	assert_true(_panel.order_game_display_rack())

	var start_position := manager.get_ghost_position()
	var start_rotation := manager.get_ghost_rotation_y()

	assert_false(_panel.rack_left_button.disabled)
	assert_false(_panel.rotate_rack_button.disabled)
	assert_false(_panel.cancel_rack_button.disabled)
	assert_true(_panel.move_pending_rack_right())
	assert_gt(manager.get_ghost_position().x, start_position.x)
	assert_eq(_panel.status_label.text, "Moved storage rack preview right.")
	assert_true(_panel.rotate_pending_rack())
	assert_ne(manager.get_ghost_rotation_y(), start_rotation)
	assert_eq(_panel.status_label.text, "Rotated storage rack preview.")
	manager.set_ghost_position(Vector3(-0.83, 0.04, 2.11))
	assert_true(_panel.snap_pending_rack())
	assert_almost_eq(manager.get_ghost_position().x, -0.75, 0.001)
	assert_almost_eq(manager.get_ghost_position().z, 2.0, 0.001)
	assert_eq(_panel.status_label.text, "Snapped storage rack preview to grid.")


func test_day_summary_panel_cancels_pending_fixture_preview() -> void:
	var fixture_root := Node3D.new()
	var manager: FixturePlacementManager = load("res://scripts/store_layout/fixture_placement_manager.gd").new()
	var ghost := Node3D.new()
	ghost.name = "GhostRackPreview"
	add_child_autofree(fixture_root)
	fixture_root.add_child(manager)
	manager.add_child(ghost)
	manager._ready()
	_session.fixture_placement_manager_path = _session.get_path_to(manager)
	_session.inventory_root_path = _session.get_path_to(fixture_root)
	assert_true(_panel.open_for_session(_session))
	assert_true(_panel.order_game_display_rack())

	assert_false(_panel.cancel_rack_button.disabled)
	assert_eq(_session.get_cash_cents(), 37500)
	assert_true(_panel.cancel_pending_rack())

	assert_eq(_session.get_cash_cents(), 50000)
	assert_eq(_session.get_pending_fixture_orders().size(), 0)
	assert_false(manager.is_ghost_visible())
	assert_string_contains(_panel.fixture_label.text, "Pending storage placement: none")
	assert_eq(_panel.status_label.text, "Canceled Game Display Rack placement. Refunded $125.00.")
	assert_true(_panel.cancel_rack_button.disabled)


func test_day_summary_panel_end_day_updates_status() -> void:
	assert_true(_panel.open_for_session(_session))

	assert_true(_panel.end_day())

	assert_true(_session.is_day_closed)
	assert_eq(_panel.status_label.text, "Day closed")
	assert_string_contains(_panel.report_label.text, "Daily report day 1:")
	assert_true(_panel.order_rack_button.disabled)
	assert_true(_panel.commit_allocation_button.disabled)
	assert_true(_panel.place_rack_button.disabled)
	assert_true(_panel.rack_left_button.disabled)
	assert_true(_panel.rotate_rack_button.disabled)
	assert_true(_panel.cancel_rack_button.disabled)
	assert_false(_panel.end_day_button.disabled)
	assert_eq(_panel.end_day_button.text, "Start Day")


func test_day_summary_panel_close_hides_panel() -> void:
	assert_true(_panel.open_for_session(_session))

	assert_true(_panel.close())

	assert_false(_panel.visible)
	assert_false(_panel.is_open())
