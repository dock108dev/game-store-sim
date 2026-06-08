extends GutTest

const DailyReportPolicy := preload("res://scripts/economy/daily_report.gd")


func test_daily_report_builds_open_day_snapshot() -> void:
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(session)

	var report := DailyReportPolicy.build_report(session)

	assert_eq(report.get("day_number"), 1)
	assert_false(report.get("is_closed"))
	assert_eq(report.get("day_phase"), StoreSession.DAY_PHASE_SETUP)
	assert_eq(report.get("day_phase_label"), "Setup")
	assert_eq(report.get("opening_cash_cents"), 50000)
	assert_eq(report.get("closing_cash_cents"), 50000)
	assert_eq(DailyReportPolicy.format_report(session), "Daily report: day still open")


func test_daily_report_formats_closed_day_totals() -> void:
	var ledger := TransactionLedger.new()
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	var sale_item: Node = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	var trade_customer: SimpleTradeInCustomer = load("res://scenes/customers/simple_trade_in_customer.tscn").instantiate()
	var service_customer: Node = load("res://scenes/customers/simple_service_customer.tscn").instantiate()
	add_child_autofree(ledger)
	add_child_autofree(session)
	add_child_autofree(sale_item)
	add_child_autofree(trade_customer)
	add_child_autofree(service_customer)

	session.ledger_path = session.get_path_to(ledger)
	var sale_transaction := ledger.record_sale("customer_001", sale_item)
	session.apply_sale(sale_transaction)
	var trade_transaction := ledger.record_trade_in("trade_seller_001", trade_customer.get_trade_item(), 760)
	session.apply_trade_in(trade_transaction)
	var service_transaction := ledger.record_service(service_customer)
	session.apply_service(service_transaction)
	session.end_day()

	var report := DailyReportPolicy.build_report(session)
	var text := DailyReportPolicy.format_report(session)

	assert_true(report.get("is_closed"))
	assert_eq(report.get("day_phase"), StoreSession.DAY_PHASE_REPORT)
	assert_eq(report.get("day_phase_label"), "Report")
	assert_eq(report.get("closing_cash_cents"), 51063)
	assert_eq(report.get("net_cash_change_cents"), 1063)
	assert_eq(report.get("services"), 1)
	assert_eq(report.get("preorders"), 0)
	assert_eq(report.get("service_revenue_cents"), 499)
	assert_eq(report.get("service_cost_cents"), 100)
	assert_eq(report.get("service_profit_cents"), 399)
	assert_eq(report.get("reputation"), 100)
	assert_eq(report.get("losses_cents"), 0)
	assert_eq(report.get("operating_expenses_cents"), 875)
	assert_eq(report.get("reserved_obligations_cents"), 0)
	assert_eq(report.get("bills_text"), "daily overhead posted at close")
	assert_string_contains(str(report.get("cash_pressure_text")), "Daily overhead due at close: $8.75")
	assert_string_contains(text, "Daily report day 1:")
	assert_string_contains(text, "End-of-day summary")
	assert_string_contains(text, "Phase: Report")
	assert_string_contains(text, "Day plan: Opening > Setup > Customer hours > Closing > Report > Tomorrow planning")
	assert_string_contains(text, "Closing cash $510.63")
	assert_string_contains(text, "Net cash +$10.63")
	assert_string_contains(text, "Sales 1 / Trade-ins 1 / Services 1")
	assert_string_contains(text, "Preorders 0")
	assert_string_contains(text, "Service revenue $4.99 / Service cost $1.00 / Service profit $3.99")
	assert_string_contains(text, "Gross profit $16.98")
	assert_string_contains(text, "Operating expenses: $8.75")
	assert_string_contains(text, "Reserved obligations: $0.00")
	assert_string_contains(text, "Preorders: count 0 / deposits $0.00")
	assert_string_contains(text, "Launch activity: 0 events / cash $0.00 / profit $0.00 / missed demand 0")
	assert_string_contains(text, "Reputation: 100")
	assert_string_contains(text, "Losses: $0.00")
	assert_string_contains(text, "Bills: daily overhead posted at close")
	assert_string_contains(text, "Tomorrow: Review reorder suggestions")


func test_daily_report_formats_launch_reputation_losses_and_tomorrow_plan() -> void:
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(session)
	session.day_number = 4
	session.reputation_score = 90
	session.replace_launch_events([
		{
			"product_name": "Neon Skyline",
			"missed_demand": 2,
			"cash_received_cents": 4999,
			"gross_profit_cents": 1299,
		},
	])
	session.end_day()

	var report := DailyReportPolicy.build_report(session)
	var text := DailyReportPolicy.format_report(session)

	assert_eq(report.get("launch_events"), 1)
	assert_eq(report.get("launch_revenue_cents"), 4999)
	assert_eq(report.get("launch_profit_cents"), 1299)
	assert_eq(report.get("missed_launch_demand"), 2)
	assert_eq(report.get("losses_cents"), 1000)
	assert_eq(report.get("reputation"), 90)
	assert_string_contains(text, "Launch activity: 1 events / cash $49.99 / profit $12.99 / missed demand 2")
	assert_string_contains(text, "Reputation: 90")
	assert_string_contains(text, "Losses: $10.00")
	assert_string_contains(text, "Day plan: Opening > Setup > Customer hours > Closing > Report > Tomorrow planning")
	assert_string_contains(text, "Tomorrow: Prepare Pocket Farm DX launch allocation")
