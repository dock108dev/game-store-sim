extends GutTest

const DailyReportPolicy := preload("res://scripts/economy/daily_report.gd")


func test_daily_report_builds_open_day_snapshot() -> void:
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(session)

	var report := DailyReportPolicy.build_report(session)

	assert_eq(report.get("day_number"), 1)
	assert_false(report.get("is_closed"))
	assert_eq(report.get("opening_cash_cents"), 50000)
	assert_eq(report.get("closing_cash_cents"), 50000)
	assert_eq(DailyReportPolicy.format_report(session), "Daily report: day still open")


func test_daily_report_formats_closed_day_totals() -> void:
	var ledger := TransactionLedger.new()
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
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
	session.end_day()

	var report := DailyReportPolicy.build_report(session)
	var text := DailyReportPolicy.format_report(session)

	assert_true(report.get("is_closed"))
	assert_eq(report.get("closing_cash_cents"), 51439)
	assert_eq(report.get("net_cash_change_cents"), 1439)
	assert_string_contains(text, "Daily report day 1:")
	assert_string_contains(text, "Closing cash $514.39")
	assert_string_contains(text, "Net cash +$14.39")
	assert_string_contains(text, "Sales 1 / Trade-ins 1")
	assert_string_contains(text, "Gross profit $12.99")
