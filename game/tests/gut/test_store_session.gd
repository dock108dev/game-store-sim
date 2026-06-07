extends GutTest


func test_store_session_starts_with_open_day_and_cash() -> void:
	var session: Node = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(session)

	assert_eq(session.day_number, 1)
	assert_false(session.is_day_closed)
	assert_eq(session.get_cash_cents(), 50000)
	assert_eq(session.get_status_label(), "Day open")


func test_store_session_applies_sale_to_cash() -> void:
	var session: Node = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(session)

	session.apply_sale({"sale_price_cents": 2199})

	assert_eq(session.get_cash_cents(), 52199)


func test_store_session_applies_trade_in_to_cash() -> void:
	var session: Node = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(session)

	session.apply_trade_in({"trade_in_cost_cents": 760})

	assert_eq(session.get_cash_cents(), 49240)


func test_store_session_reads_ledger_totals() -> void:
	var ledger := TransactionLedger.new()
	var session: Node = load("res://scripts/systems/store_session.gd").new()
	var item: Node = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(ledger)
	add_child_autofree(session)
	add_child_autofree(item)

	session.ledger_path = session.get_path_to(ledger)
	var transaction := ledger.record_sale("customer_001", item)
	session.apply_sale(transaction)

	assert_eq(session.get_sale_count(), 1)
	assert_eq(session.get_total_revenue_cents(), 2199)
	assert_eq(session.get_total_cost_cents(), 900)
	assert_eq(session.get_total_profit_cents(), 1299)
	assert_eq(session.get_last_transaction().get("display_name"), "Star Trader")
	assert_string_contains(session.get_summary_text(), "Cash: $521.99")
	assert_string_contains(session.get_summary_text(), "Trade-ins: 0")
	assert_string_contains(session.get_summary_text(), "Profit: $12.99")


func test_store_session_reads_trade_in_totals_without_counting_sales() -> void:
	var ledger := TransactionLedger.new()
	var session: Node = load("res://scripts/systems/store_session.gd").new()
	var customer: SimpleTradeInCustomer = load("res://scenes/customers/simple_trade_in_customer.tscn").instantiate()
	add_child_autofree(ledger)
	add_child_autofree(session)
	add_child_autofree(customer)

	session.ledger_path = session.get_path_to(ledger)
	var item: Node = customer.get_trade_item()
	var transaction := ledger.record_trade_in("trade_seller_001", item, 760)
	session.apply_trade_in(transaction)

	assert_eq(session.get_sale_count(), 0)
	assert_eq(session.get_trade_in_count(), 1)
	assert_eq(session.get_total_revenue_cents(), 0)
	assert_eq(session.get_total_trade_in_cost_cents(), 760)
	assert_eq(session.get_total_trade_in_credit_cents(), 0)
	assert_eq(session.get_cash_cents(), 49240)
	assert_string_contains(session.get_summary_text(), "Trade-ins: 1")
	assert_string_contains(session.get_summary_text(), "Trade cash: $7.60")
	assert_string_contains(session.get_summary_text(), "Store credit: $0.00")


func test_store_session_tracks_store_credit_trade_in_without_spending_cash() -> void:
	var ledger := TransactionLedger.new()
	var session: Node = load("res://scripts/systems/store_session.gd").new()
	var customer: SimpleTradeInCustomer = load("res://scenes/customers/simple_trade_in_customer.tscn").instantiate()
	add_child_autofree(ledger)
	add_child_autofree(session)
	add_child_autofree(customer)

	session.ledger_path = session.get_path_to(ledger)
	var item: Node = customer.get_trade_item()
	var transaction := ledger.record_trade_in("trade_seller_001", item, 950, "store_credit")
	session.apply_trade_in(transaction)

	assert_eq(session.get_trade_in_count(), 1)
	assert_eq(session.get_total_trade_in_cost_cents(), 0)
	assert_eq(session.get_total_trade_in_credit_cents(), 950)
	assert_eq(session.get_cash_cents(), 50000)
	assert_string_contains(session.get_summary_text(), "Trade cash: $0.00")
	assert_string_contains(session.get_summary_text(), "Store credit: $9.50")


func test_store_session_tracks_preorder_deposits_without_sale_revenue() -> void:
	var ledger := TransactionLedger.new()
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	var release := load("res://data/releases/neon_skyline_launch.tres")
	add_child_autofree(ledger)
	add_child_autofree(session)

	session.ledger_path = session.get_path_to(ledger)
	var transaction := ledger.record_preorder_deposit("preorder_customer_001", release, 500)
	session.apply_preorder_deposit(transaction)

	assert_eq(session.get_preorder_deposit_count(), 1)
	assert_eq(session.get_total_preorder_deposit_cents(), 500)
	assert_eq(session.get_sale_count(), 0)
	assert_eq(session.get_total_revenue_cents(), 0)
	assert_eq(session.get_total_profit_cents(), 0)
	assert_eq(session.get_cash_cents(), 50500)
	assert_string_contains(session.get_summary_text(), "Preorders: 1")
	assert_string_contains(session.get_summary_text(), "Preorder deposits: $5.00")


func test_store_session_formats_recent_activity_history() -> void:
	var ledger := TransactionLedger.new()
	var session: Node = load("res://scripts/systems/store_session.gd").new()
	var sale_item: Node = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	var trade_customer: SimpleTradeInCustomer = load("res://scenes/customers/simple_trade_in_customer.tscn").instantiate()
	add_child_autofree(ledger)
	add_child_autofree(session)
	add_child_autofree(sale_item)
	add_child_autofree(trade_customer)

	session.ledger_path = session.get_path_to(ledger)
	var sale_transaction := ledger.record_sale("customer_001", sale_item)
	session.apply_sale(sale_transaction)
	var trade_transaction := ledger.record_trade_in("trade_seller_001", trade_customer.get_trade_item(), 760)
	session.apply_trade_in(trade_transaction)

	var activity: String = session.get_recent_activity_text()
	assert_string_contains(activity, "Recent activity:")
	assert_string_contains(activity, "Sale Star Trader $21.99 profit $12.99")
	assert_string_contains(activity, "Trade-in Moon Escape offer $7.60")
	assert_lt(activity.find("Trade-in Moon Escape"), activity.find("Sale Star Trader"))


func test_store_session_formats_store_credit_recent_activity() -> void:
	var ledger := TransactionLedger.new()
	var session: Node = load("res://scripts/systems/store_session.gd").new()
	var trade_customer: SimpleTradeInCustomer = load("res://scenes/customers/simple_trade_in_customer.tscn").instantiate()
	add_child_autofree(ledger)
	add_child_autofree(session)
	add_child_autofree(trade_customer)

	session.ledger_path = session.get_path_to(ledger)
	var trade_transaction := ledger.record_trade_in(
		"trade_seller_001",
		trade_customer.get_trade_item(),
		950,
		"store_credit"
	)
	session.apply_trade_in(trade_transaction)

	var activity: String = session.get_recent_activity_text()
	assert_string_contains(activity, "Trade-in Moon Escape credit $9.50")


func test_store_session_formats_preorder_recent_activity_and_summary() -> void:
	var ledger := TransactionLedger.new()
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	var release := load("res://data/releases/neon_skyline_launch.tres")
	add_child_autofree(ledger)
	add_child_autofree(session)

	session.ledger_path = session.get_path_to(ledger)
	var transaction := ledger.record_preorder_deposit("preorder_customer_001", release, 500)
	session.apply_preorder_deposit(transaction)

	assert_string_contains(session.get_recent_activity_text(), "Preorder Neon Skyline deposit $5.00")
	assert_string_contains(session.get_preorder_summary_text(), "Preorders:")
	assert_string_contains(session.get_preorder_summary_text(), "Neon Skyline deposit $5.00")
	assert_string_contains(session.get_preorder_summary_text(), "due day 3")


func test_store_session_suggests_reorder_for_low_active_stock_after_sales() -> void:
	var ledger := TransactionLedger.new()
	var session: Node = load("res://scripts/systems/store_session.gd").new()
	var root := Node3D.new()
	var sold_item: Node = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	var active_item: Node = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(ledger)
	add_child_autofree(session)
	add_child_autofree(root)
	root.add_child(active_item)
	add_child_autofree(sold_item)

	session.ledger_path = session.get_path_to(ledger)
	session.inventory_root_path = session.get_path_to(root)
	ledger.record_sale("customer_001", sold_item)

	var suggestions: String = session.get_reorder_suggestions_text()
	assert_string_contains(suggestions, "Reorder suggestions:")
	assert_string_contains(suggestions, "Restock Star Trader (sold 1, active 1)")


func test_store_session_summarizes_category_demand() -> void:
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(session)

	var summary := session.get_category_demand_summary_text()

	assert_string_contains(summary, "Category demand:")
	assert_string_contains(summary, "Used games x1.00")
	assert_string_contains(summary, "New games x0.90")
	assert_string_contains(summary, "Hardware x0.80")


func test_store_session_summarizes_market_drift_for_active_inventory() -> void:
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	var root := Node3D.new()
	var item: Node = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(session)
	add_child_autofree(root)
	root.add_child(item)

	session.day_number = 2
	session.inventory_root_path = session.get_path_to(root)

	var summary := session.get_market_drift_summary_text()

	assert_string_contains(summary, "Market drift day 2:")
	assert_string_contains(summary, "Star Trader $24.99")
	assert_string_contains(summary, "+$")


func test_store_session_formats_daily_report_after_close() -> void:
	var ledger := TransactionLedger.new()
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	var item: Node = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(ledger)
	add_child_autofree(session)
	add_child_autofree(item)

	session.ledger_path = session.get_path_to(ledger)
	var transaction := ledger.record_sale("customer_001", item)
	session.apply_sale(transaction)
	session.end_day()

	assert_string_contains(session.get_daily_report_text(), "Daily report day 1:")
	assert_string_contains(session.get_daily_report_text(), "Closing cash $521.99")
	assert_string_contains(session.get_daily_report_text(), "Gross profit $12.99")


func test_store_session_summarizes_active_inventory_items() -> void:
	var session: Node = load("res://scripts/systems/store_session.gd").new()
	var root := Node3D.new()
	var receiving_item: Node = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	var stocked_item: Node = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	var sold_item: Node = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	var customer_item: Node = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(root)
	add_child_autofree(session)
	root.add_child(receiving_item)
	root.add_child(stocked_item)
	root.add_child(sold_item)
	root.add_child(customer_item)

	stocked_item.set("location_id", "shelf_slot_001")
	sold_item.set("location_id", "sold")
	customer_item.set("location_id", "customer:customer_001")
	session.inventory_root_path = session.get_path_to(root)

	assert_eq(session.get_active_inventory_items().size(), 2)
	assert_string_contains(session.get_inventory_summary_text(), "Star Trader x2")


func test_store_session_lists_available_fixture_orders() -> void:
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(session)

	var fixtures := session.get_available_fixture_definitions()

	assert_eq(fixtures.size(), 1)
	assert_eq(fixtures[0].get("fixture_id"), "fixture_game_display_rack")
	assert_true(session.can_order_fixture("fixture_game_display_rack"))
	assert_string_contains(session.get_fixture_order_summary_text(), "Order Game Display Rack $125.00")
	assert_string_contains(session.get_fixture_order_summary_text(), "Pending placement: none")


func test_store_session_lists_available_supplier_lots() -> void:
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(session)

	var lots := session.get_available_supplier_lots()

	assert_eq(lots.size(), 1)
	assert_eq(lots[0].get("lot_id"), "supplier_lot_used_games_001")
	assert_true(session.can_order_supplier_lot("supplier_lot_used_games_001"))
	assert_string_contains(session.get_supplier_order_summary_text(), "Supplier orders:")
	assert_string_contains(session.get_supplier_order_summary_text(), "Order Used Game Starter Lot $27.00")
	assert_string_contains(session.get_supplier_order_summary_text(), "Pending delivery: none")


func test_store_session_lists_release_calendar_sorted_by_launch_day() -> void:
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(session)

	var releases := session.get_release_calendar()

	assert_eq(releases.size(), 3)
	assert_eq(releases[0].get("product_name"), "Neon Skyline")
	assert_eq(releases[1].get("product_name"), "Pocket Farm DX")
	assert_eq(releases[2].get("product_name"), "Skycart Grand Prix")
	assert_eq(releases[0].get("release_day"), 3)
	assert_eq(releases[1].get("release_day"), 5)
	assert_eq(releases[2].get("release_day"), 8)


func test_store_session_formats_upcoming_release_calendar() -> void:
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(session)

	var summary: String = session.get_release_calendar_text()

	assert_string_contains(summary, "Release calendar:")
	assert_string_contains(summary, "Day 3 (in 2 days): Neon Skyline - Orbit 64")
	assert_string_contains(summary, "cost $32.00")
	assert_string_contains(summary, "MSRP $49.99")
	assert_string_contains(summary, "allocation 4")
	assert_string_contains(summary, "demand High")


func test_store_session_commits_release_allocation_and_reserves_cash() -> void:
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(session)

	var allocation := session.commit_release_allocation("release_neon_skyline", 1)

	assert_eq(allocation.get("release_id"), "release_neon_skyline")
	assert_eq(allocation.get("product_name"), "Neon Skyline")
	assert_eq(allocation.get("quantity"), 1)
	assert_eq(allocation.get("wholesale_cost_cents"), 3200)
	assert_eq(allocation.get("total_cost_cents"), 3200)
	assert_eq(allocation.get("status"), "committed")
	assert_eq(session.get_cash_cents(), 46800)
	assert_eq(session.get_release_allocation_count(), 1)
	assert_eq(session.get_release_allocation_quantity("release_neon_skyline"), 1)
	assert_eq(session.get_total_release_allocation_cost_cents(), 3200)
	assert_string_contains(session.get_release_allocation_summary_text(), "Release allocations:")
	assert_string_contains(session.get_release_allocation_summary_text(), "Neon Skyline x1 committed $32.00 due day 3")
	assert_string_contains(session.get_summary_text(), "Release allocations: 1")
	assert_string_contains(session.get_summary_text(), "Allocation cost: $32.00")


func test_store_session_rejects_release_allocation_over_limit_without_cash_or_after_close() -> void:
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(session)

	assert_true(session.can_commit_release_allocation("release_neon_skyline", 4))
	assert_true(session.commit_release_allocation("release_neon_skyline", 5).is_empty())
	assert_eq(session.get_release_allocation_count(), 0)

	assert_false(session.commit_release_allocation("release_neon_skyline", 4).is_empty())
	assert_false(session.can_commit_release_allocation("release_neon_skyline", 1))
	assert_true(session.commit_release_allocation("release_neon_skyline", 1).is_empty())
	assert_eq(session.get_release_allocation_count(), 4)

	var poor_session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(poor_session)
	poor_session.cash_cents = 1000
	assert_false(poor_session.can_commit_release_allocation("release_neon_skyline", 1))
	assert_true(poor_session.commit_release_allocation("release_neon_skyline", 1).is_empty())

	var closed_session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(closed_session)
	closed_session.end_day()
	assert_false(closed_session.can_commit_release_allocation("release_neon_skyline", 1))
	assert_true(closed_session.commit_release_allocation("release_neon_skyline", 1).is_empty())


func test_store_session_filters_released_calendar_entries() -> void:
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(session)
	session.day_number = 4

	var upcoming := session.get_upcoming_releases()
	var summary: String = session.get_release_calendar_text()

	assert_eq(upcoming.size(), 2)
	assert_eq(upcoming[0].get("product_name"), "Pocket Farm DX")
	assert_eq(summary.find("Neon Skyline"), -1)
	assert_string_contains(summary, "Day 5 (tomorrow): Pocket Farm DX")


func test_store_session_orders_supplier_lot_and_reserves_cash() -> void:
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(session)

	var order := session.order_supplier_lot("supplier_lot_used_games_001")

	assert_eq(order.get("lot_id"), "supplier_lot_used_games_001")
	assert_eq(order.get("supplier_id"), "North Dock Wholesale")
	assert_eq(order.get("status"), "pending_delivery")
	assert_eq(order.get("ordered_day"), 1)
	assert_eq(order.get("due_day"), 2)
	assert_eq(order.get("item_count"), 3)
	assert_eq(order.get("cost_cents"), 2700)
	assert_eq(session.get_cash_cents(), 47300)
	assert_eq(session.get_pending_supplier_orders().size(), 1)
	assert_string_contains(session.get_supplier_order_summary_text(), "Pending delivery:")
	assert_string_contains(session.get_supplier_order_summary_text(), "Used Game Starter Lot due day 2 (3 items)")


func test_store_session_rejects_supplier_order_without_cash() -> void:
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(session)
	session.cash_cents = 1000

	var order := session.order_supplier_lot("supplier_lot_used_games_001")

	assert_true(order.is_empty())
	assert_false(session.can_order_supplier_lot("supplier_lot_used_games_001"))
	assert_eq(session.get_cash_cents(), 1000)
	assert_eq(session.get_pending_supplier_orders().size(), 0)


func test_store_session_delivers_supplier_lot_on_next_day() -> void:
	var root := Node3D.new()
	var receiving_box: Node3D = load("res://scenes/props/receiving_box.tscn").instantiate()
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(root)
	root.add_child(receiving_box)
	root.add_child(session)
	session.inventory_root_path = session.get_path_to(root)
	session.receiving_box_path = session.get_path_to(receiving_box)
	session.order_supplier_lot("supplier_lot_used_games_001")

	session.end_day()
	var started := session.start_next_day()

	assert_false(started.is_empty())
	assert_eq(started.get("day_number"), 2)
	assert_eq(started.get("delivered_count"), 1)
	assert_false(session.is_day_closed)
	assert_eq(session.day_number, 2)
	assert_eq(session.get_pending_supplier_orders().size(), 0)
	assert_eq(session.get_delivered_supplier_orders().size(), 1)
	assert_string_contains(session.get_supplier_order_summary_text(), "Delivered lots:")
	assert_string_contains(session.get_supplier_order_summary_text(), "Used Game Starter Lot delivered day 2")
	assert_eq(_count_inventory_items(receiving_box), 6)
	assert_not_null(receiving_box.get_node_or_null("DeliveredUsedGame004"))
	assert_string_contains(session.get_inventory_summary_text(), "Moon Escape x1")
	assert_string_contains(session.get_inventory_summary_text(), "Neon Harbor x1")


func test_store_session_orders_fixture_and_reserves_cash() -> void:
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(session)

	var order := session.order_fixture("fixture_game_display_rack")

	assert_eq(order.get("fixture_id"), "fixture_game_display_rack")
	assert_eq(order.get("status"), "pending_placement")
	assert_eq(order.get("slot_category"), "used_game")
	assert_eq(order.get("cost_cents"), 12500)
	assert_eq(session.get_cash_cents(), 37500)
	assert_eq(session.get_pending_fixture_orders().size(), 1)
	assert_string_contains(session.get_fixture_order_summary_text(), "Pending placement:")
	assert_string_contains(session.get_fixture_order_summary_text(), "Game Display Rack $125.00")
	assert_string_contains(session.get_fixture_order_summary_text(), "slots:used_game")


func test_store_session_places_pending_fixture_and_clears_pending_order() -> void:
	var fixture_root := Node3D.new()
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	var manager: Node = load("res://scripts/store_layout/fixture_placement_manager.gd").new()
	var ghost := Node3D.new()
	ghost.name = "GhostRackPreview"
	add_child_autofree(fixture_root)
	fixture_root.add_child(manager)
	fixture_root.add_child(session)
	manager.add_child(ghost)
	manager._ready()
	session.fixture_placement_manager_path = session.get_path_to(manager)
	session.inventory_root_path = session.get_path_to(fixture_root)
	var order := session.order_fixture("fixture_game_display_rack")

	var placed := session.place_pending_fixture()

	assert_false(order.is_empty())
	assert_false(placed.is_empty())
	assert_eq(placed.get("order_id"), order.get("order_id"))
	assert_eq(placed.get("status"), "placed")
	assert_eq(session.get_pending_fixture_orders().size(), 0)
	assert_eq(session.get_placed_fixture_orders().size(), 1)
	assert_false(manager.is_ghost_visible())
	assert_not_null(fixture_root.get_node_or_null("PlacedGameDisplayRack001"))
	assert_string_contains(session.get_fixture_order_summary_text(), "Pending placement: none")
	assert_string_contains(session.get_fixture_order_summary_text(), "Placed fixtures:")
	assert_string_contains(session.get_fixture_order_summary_text(), "Game Display Rack placed")


func test_store_session_rejects_pending_fixture_placement_when_ghost_is_invalid() -> void:
	var fixture_root := Node3D.new()
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	var manager: Node = load("res://scripts/store_layout/fixture_placement_manager.gd").new()
	var ghost := Node3D.new()
	ghost.name = "GhostRackPreview"
	add_child_autofree(fixture_root)
	fixture_root.add_child(manager)
	fixture_root.add_child(session)
	manager.add_child(ghost)
	manager._ready()
	session.fixture_placement_manager_path = session.get_path_to(manager)
	session.inventory_root_path = session.get_path_to(fixture_root)
	session.order_fixture("fixture_game_display_rack")
	manager.set_ghost_position(Vector3(99.0, 0.04, 2.15))

	var placed := session.place_pending_fixture()

	assert_true(placed.is_empty())
	assert_false(session.can_place_pending_fixture())
	assert_eq(session.get_pending_fixture_orders().size(), 1)
	assert_eq(session.get_placed_fixture_orders().size(), 0)
	assert_true(manager.is_ghost_visible())
	assert_null(fixture_root.get_node_or_null("PlacedGameDisplayRack001"))


func test_store_session_rejects_fixture_order_without_cash() -> void:
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(session)
	session.cash_cents = 1000

	var order := session.order_fixture("fixture_game_display_rack")

	assert_true(order.is_empty())
	assert_false(session.can_order_fixture("fixture_game_display_rack"))
	assert_eq(session.get_cash_cents(), 1000)
	assert_eq(session.get_pending_fixture_orders().size(), 0)


func test_store_session_can_close_day() -> void:
	var session: Node = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(session)

	session.end_day()

	assert_true(session.is_day_closed)
	assert_eq(session.get_status_label(), "Day closed")


func _count_inventory_items(root: Node) -> int:
	var count := 0
	for child in root.get_children():
		var product := child.get("product") as ProductDefinition
		if product != null:
			count += 1
	return count
