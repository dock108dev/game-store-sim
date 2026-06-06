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
	assert_eq(session.get_cash_cents(), 49240)
	assert_string_contains(session.get_summary_text(), "Trade-ins: 1")
	assert_string_contains(session.get_summary_text(), "Trade spend: $7.60")


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


func test_store_session_can_close_day() -> void:
	var session: Node = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(session)

	session.end_day()

	assert_true(session.is_day_closed)
	assert_eq(session.get_status_label(), "Day closed")
