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
	assert_string_contains(session.get_summary_text(), "Profit: $12.99")


func test_store_session_can_close_day() -> void:
	var session: Node = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(session)

	session.end_day()

	assert_true(session.is_day_closed)
	assert_eq(session.get_status_label(), "Day closed")
