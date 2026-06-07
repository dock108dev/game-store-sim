extends GutTest

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


func test_day_summary_panel_opens_with_cash_and_sales_fields() -> void:
	assert_true(_panel.open_for_session(_session))

	assert_true(_panel.is_open())
	assert_eq(_panel.get_active_session(), _session)
	assert_string_contains(_panel.title_label.text, "Backroom Computer")
	assert_string_contains(_panel.summary_label.text, "Cash: $500.00")
	assert_string_contains(_panel.summary_label.text, "Sales: 0")
	assert_eq(_panel.report_label.text, "Daily report: day still open")
	assert_eq(_panel.last_sale_label.text, "Recent activity: none")
	assert_string_contains(_panel.release_calendar_label.text, "Release calendar:")
	assert_string_contains(_panel.release_calendar_label.text, "Neon Skyline")
	assert_string_contains(_panel.release_calendar_label.text, "MSRP $49.99")
	assert_string_contains(_panel.supplier_order_label.text, "Order Used Game Starter Lot $27.00")
	assert_string_contains(_panel.supplier_order_label.text, "Pending delivery: none")
	assert_string_contains(_panel.fixture_label.text, "Order Game Display Rack $125.00")
	assert_false(_panel.order_games_button.disabled)
	assert_false(_panel.order_rack_button.disabled)
	assert_true(_panel.place_rack_button.disabled)
	assert_eq(_panel.status_label.text, "Day open")
	assert_false(_panel.end_day_button.disabled)
	assert_eq(_panel.end_day_button.text, "End Day")


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
	assert_string_contains(_panel.fixture_label.text, "Pending placement:")
	assert_string_contains(_panel.fixture_label.text, "Game Display Rack $125.00")
	assert_eq(_panel.status_label.text, "Ordered Game Display Rack.")
	assert_true(_panel.place_rack_button.disabled)


func test_day_summary_panel_orders_supplier_lot_from_backroom_computer() -> void:
	assert_true(_panel.open_for_session(_session))

	assert_true(_panel.order_used_game_lot())

	assert_eq(_session.get_cash_cents(), 47300)
	assert_string_contains(_panel.summary_label.text, "Cash: $473.00")
	assert_string_contains(_panel.supplier_order_label.text, "Pending delivery:")
	assert_string_contains(_panel.supplier_order_label.text, "Used Game Starter Lot due day 2 (3 items)")
	assert_eq(_panel.status_label.text, "Ordered Used Game Starter Lot.")


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
	assert_string_contains(_panel.supplier_order_label.text, "Delivered lots:")
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
	assert_string_contains(_panel.fixture_label.text, "Pending placement: none")
	assert_string_contains(_panel.fixture_label.text, "Placed fixtures:")
	assert_eq(_panel.status_label.text, "Placed Game Display Rack.")
	assert_true(_panel.place_rack_button.disabled)


func test_day_summary_panel_end_day_updates_status() -> void:
	assert_true(_panel.open_for_session(_session))

	assert_true(_panel.end_day())

	assert_true(_session.is_day_closed)
	assert_eq(_panel.status_label.text, "Day closed")
	assert_string_contains(_panel.report_label.text, "Daily report day 1:")
	assert_true(_panel.order_rack_button.disabled)
	assert_true(_panel.place_rack_button.disabled)
	assert_false(_panel.end_day_button.disabled)
	assert_eq(_panel.end_day_button.text, "Start Day")


func test_day_summary_panel_close_hides_panel() -> void:
	assert_true(_panel.open_for_session(_session))

	assert_true(_panel.close())

	assert_false(_panel.visible)
	assert_false(_panel.is_open())
