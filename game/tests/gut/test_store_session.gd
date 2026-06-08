extends GutTest


func test_store_session_starts_with_open_day_and_cash() -> void:
	var session: Node = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(session)

	assert_eq(session.day_number, 1)
	assert_false(session.is_day_closed)
	assert_eq(session.get_cash_cents(), 50000)
	assert_eq(session.get_status_label(), "Day open")
	assert_eq(session.get_day_phase(), StoreSession.DAY_PHASE_SETUP)
	assert_eq(session.get_day_phase_label(), "Setup")


func test_store_session_exposes_production_day_structure() -> void:
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(session)

	var structure := session.get_day_structure()
	var structure_text := session.get_day_structure_text()

	assert_eq(structure.size(), 6)
	assert_eq(structure[0].get("phase"), StoreSession.DAY_PHASE_OPENING)
	assert_eq(structure[2].get("phase"), StoreSession.DAY_PHASE_CUSTOMER_HOURS)
	assert_string_contains(structure_text, "Opening: Post overnight bills, deliveries, launch events")
	assert_string_contains(structure_text, "Setup: Price incoming stock")
	assert_string_contains(structure_text, "Customer hours: Serve buyers")
	assert_string_contains(structure_text, "Closing: Stop new customer work")
	assert_string_contains(structure_text, "Report: Review sales")
	assert_string_contains(structure_text, "Tomorrow planning: Plan deliveries")
	assert_string_contains(session.get_tomorrow_planning_text(), "Tomorrow planning:")


func test_store_session_tracks_day_phase_through_close_and_next_day() -> void:
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(session)

	assert_true(session.start_customer_hours())
	assert_eq(session.get_day_phase(), StoreSession.DAY_PHASE_CUSTOMER_HOURS)
	assert_true(session.begin_closing())
	assert_eq(session.get_day_phase(), StoreSession.DAY_PHASE_CLOSING)

	session.end_day()

	assert_true(session.is_day_closed)
	assert_eq(session.get_day_phase(), StoreSession.DAY_PHASE_REPORT)
	assert_true(session.begin_tomorrow_planning())
	assert_eq(session.get_day_phase(), StoreSession.DAY_PHASE_TOMORROW_PLANNING)

	var started := session.start_next_day()

	assert_eq(started.get("day_number"), 2)
	assert_eq(started.get("day_phase"), StoreSession.DAY_PHASE_SETUP)
	assert_eq(started.get("day_phase_label"), "Setup")
	assert_string_contains(str(started.get("opening_summary")), "Opening day 2")
	assert_eq((started.get("day_structure") as Array).size(), 6)
	assert_false(session.is_day_closed)
	assert_eq(session.get_day_phase(), StoreSession.DAY_PHASE_SETUP)


func test_store_session_applies_daily_cash_pressure_once_on_close() -> void:
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(session)

	assert_eq(session.get_daily_cash_pressure_cents(), 875)
	session.end_day()

	assert_eq(session.get_cash_cents(), 49125)
	assert_eq(session.get_operating_expenses_total_cents(), 875)
	assert_eq(session.get_operating_expenses_total_cents(1), 875)
	assert_eq(session.get_operating_expenses().size(), 2)

	session.end_day()

	assert_eq(session.get_cash_cents(), 49125)
	assert_eq(session.get_operating_expenses_total_cents(), 875)


func test_store_session_summarizes_cash_pressure_and_reserved_obligations() -> void:
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(session)

	session.commit_release_allocation("release_neon_skyline", 1)
	session.order_supplier_lot("supplier_lot_used_games_001")
	session.order_fixture("fixture_game_display_rack")
	var summary := session.get_cash_pressure_summary_text()

	assert_string_contains(summary, "Cash pressure:")
	assert_string_contains(summary, "Daily overhead due at close: $8.75")
	assert_string_contains(summary, "Rent reserve: $7.00")
	assert_string_contains(summary, "Utilities: $1.75")
	assert_string_contains(summary, "Payroll placeholder: $0.00")
	assert_string_contains(summary, "Repairs placeholder: $0.00")
	assert_string_contains(summary, "Shrinkage placeholder: $0.00")
	assert_string_contains(summary, "Supplier terms: current starter lots are prepaid")
	assert_string_contains(summary, "Reserved obligations: $184.00")


func test_store_session_records_reputation_events_for_core_pressure_sources() -> void:
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(session)

	session.record_pricing_fairness("Star Trader", 3200, 2499)
	session.record_wait_time("customer_001", 75.0)
	session.record_preorder_outcome("Neon Skyline", true)
	session.record_service_outcome("Disc Resurfacing", true)
	session.record_return_handling("rejected_unfairly")
	session.record_suspicious_choice("accepted_suspicious_cash")
	session.record_stock_variety(1)

	assert_eq(session.get_reputation_events().size(), 7)
	assert_eq(session.get_reputation_score(), 89)
	var summary := session.get_reputation_summary_text(7)
	assert_string_contains(summary, "Reputation: 89")
	assert_string_contains(summary, "Over-market pricing for Star Trader -3 (pricing)")
	assert_string_contains(summary, "Long register wait -2 (wait_time)")
	assert_string_contains(summary, "Preorder fulfilled: Neon Skyline +3 (preorder)")
	assert_string_contains(summary, "Service completed: Disc Resurfacing +2 (service)")
	assert_string_contains(summary, "Unfair return rejection -4 (returns)")
	assert_string_contains(summary, "Accepted suspicious cash -5 (suspicious)")
	assert_string_contains(summary, "Low stock variety -2 (stock_variety)")


func test_store_session_reputation_events_are_idempotent_and_clamped() -> void:
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(session)

	var event := session.record_reputation_event("repeat_event", "Repeated event", "test", -80)
	var duplicate := session.record_reputation_event("repeat_event", "Repeated event", "test", -80)
	session.record_reputation_event("large_penalty", "Large penalty", "test", -80)
	session.record_reputation_event("large_bonus", "Large bonus", "test", 200)

	assert_eq(event.get("event_id"), duplicate.get("event_id"))
	assert_eq(session.get_reputation_events().size(), 3)
	assert_eq(session.get_reputation_score(), 100)


func test_store_session_lists_upgrade_path_baseline() -> void:
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(session)

	var catalog := session.get_upgrade_catalog()
	var available := session.get_available_upgrades()
	var summary := session.get_upgrade_summary_text()

	assert_eq(catalog.size(), 7)
	assert_eq(available.size(), 6)
	assert_false(session.can_purchase_upgrade("upgrade_store_expansion"))
	assert_string_contains(summary, "Accessory Peg Wall $80.00 (fixture)")
	assert_string_contains(summary, "Accessory Category License $60.00 (category)")
	assert_string_contains(summary, "Service Cleaning Tools $120.00 (service_tool)")
	assert_string_contains(summary, "Computer Analytics $90.00 (computer_tool)")
	assert_string_contains(summary, "Staff Picks Signage $50.00 (signage)")
	assert_string_contains(summary, "Backroom Storage Bay $100.00 (storage)")
	assert_string_contains(summary, "Locked: Starter Store Expansion")


func test_store_session_purchases_upgrades_and_unlocks_expansion_path() -> void:
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(session)

	var signage := session.purchase_upgrade("upgrade_signage_staff_picks")
	var storage := session.purchase_upgrade("upgrade_backroom_storage")

	assert_eq(signage.get("upgrade_id"), "upgrade_signage_staff_picks")
	assert_eq(storage.get("upgrade_id"), "upgrade_backroom_storage")
	assert_true(session.has_upgrade("upgrade_signage_staff_picks"))
	assert_true(session.has_upgrade("upgrade_backroom_storage"))
	assert_true(session.can_purchase_upgrade("upgrade_store_expansion"))
	assert_eq(session.get_cash_cents(), 35000)
	assert_string_contains(session.get_upgrade_summary_text(), "Purchased: Staff Picks Signage, Backroom Storage Bay")
	assert_string_contains(session.get_upgrade_summary_text(), "Starter Store Expansion $300.00")


func test_store_session_exposes_owner_onboarding_baseline() -> void:
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(session)

	var steps := session.get_onboarding_steps()
	var summary := session.get_onboarding_summary_text()

	assert_eq(steps.size(), 8)
	assert_eq(steps[0].get("step_id"), "receiving")
	assert_eq(steps[0].get("status"), "next")
	assert_eq(steps[1].get("status"), "later")
	assert_string_contains(summary, "Owner checklist:")
	assert_string_contains(summary, "Next - Receiving: Pick up incoming games from receiving")
	assert_string_contains(summary, "Later - Pricing: Set a fair price")
	assert_string_contains(summary, "Later - Stocking: Place priced games")
	assert_string_contains(summary, "Later - Checkout: Ring up waiting buyers")
	assert_string_contains(summary, "Later - Trade-in: Review condition")
	assert_string_contains(summary, "Later - Backroom Computer: Review reports")
	assert_string_contains(summary, "Later - Ordering: Order supplier lots")
	assert_string_contains(summary, "Later - Closing: End the day")


func test_store_session_onboarding_advances_from_real_progress() -> void:
	var ledger := TransactionLedger.new()
	var inventory_root := Node.new()
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	var item: Node = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	var trade_item: Node = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(ledger)
	add_child_autofree(inventory_root)
	add_child_autofree(session)
	inventory_root.add_child(item)
	inventory_root.add_child(trade_item)
	session.ledger_path = session.get_path_to(ledger)
	session.inventory_root_path = session.get_path_to(inventory_root)

	item.set("location_id", "shelf_slot_001")
	item.set("current_price_cents", 1999)
	var sale_transaction := ledger.record_sale("customer_001", item)
	session.apply_sale(sale_transaction)
	var trade_transaction := ledger.record_trade_in("trade_seller_001", trade_item, 760)
	session.apply_trade_in(trade_transaction)
	session.order_supplier_lot("supplier_lot_used_games_001")
	session.end_day()

	var summary := session.get_onboarding_summary_text()

	assert_string_contains(summary, "Done - Receiving")
	assert_string_contains(summary, "Done - Pricing")
	assert_string_contains(summary, "Done - Stocking")
	assert_string_contains(summary, "Done - Checkout")
	assert_string_contains(summary, "Done - Trade-in")
	assert_string_contains(summary, "Done - Backroom Computer")
	assert_string_contains(summary, "Done - Ordering")
	assert_string_contains(summary, "Done - Closing")


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


func test_store_session_tracks_service_revenue_cost_and_profit() -> void:
	var ledger := TransactionLedger.new()
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	var customer: Node = load("res://scenes/customers/simple_service_customer.tscn").instantiate()
	add_child_autofree(ledger)
	add_child_autofree(session)
	add_child_autofree(customer)

	session.ledger_path = session.get_path_to(ledger)
	var transaction := ledger.record_service(customer)
	session.apply_service(transaction)

	assert_eq(session.get_service_count(), 1)
	assert_eq(session.get_total_service_revenue_cents(), 499)
	assert_eq(session.get_total_service_cost_cents(), 100)
	assert_eq(session.get_total_service_profit_cents(), 399)
	assert_eq(session.get_total_revenue_cents(), 499)
	assert_eq(session.get_total_cost_cents(), 100)
	assert_eq(session.get_total_profit_cents(), 399)
	assert_eq(session.get_cash_cents(), 50499)
	assert_string_contains(session.get_summary_text(), "Services: 1")
	assert_string_contains(session.get_summary_text(), "Services revenue: $4.99")
	assert_string_contains(session.get_summary_text(), "Services profit: $3.99")


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


func test_store_session_formats_service_recent_activity() -> void:
	var ledger := TransactionLedger.new()
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	var customer: Node = load("res://scenes/customers/simple_service_customer.tscn").instantiate()
	add_child_autofree(ledger)
	add_child_autofree(session)
	add_child_autofree(customer)

	session.ledger_path = session.get_path_to(ledger)
	var transaction := ledger.record_service(customer)
	session.apply_service(transaction)

	assert_string_contains(
		session.get_recent_activity_text(),
		"Service Disc Resurfacing for Scratched Orbit Disc $4.99 profit $3.99"
	)


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
	assert_string_contains(summary, "Demand tuning signals:")


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


func test_store_session_summarizes_active_inventory_demand_tuning() -> void:
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	var root := Node3D.new()
	var item: Node = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(session)
	add_child_autofree(root)
	root.add_child(item)

	item.set("location_id", "shelf_slot_001")
	session.inventory_root_path = session.get_path_to(root)
	var lines := session.get_active_inventory_demand_tuning_lines()
	var summary := session.get_category_demand_summary_text()

	assert_eq(lines.size(), 1)
	assert_string_contains(lines[0], "Star Trader demand x")
	assert_string_contains(lines[0], "front")
	assert_string_contains(summary, "Star Trader demand x")


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
	assert_string_contains(session.get_daily_report_text(), "Phase: Report")
	assert_string_contains(session.get_daily_report_text(), "Day plan: Opening > Setup > Customer hours > Closing > Report > Tomorrow planning")
	assert_string_contains(session.get_daily_report_text(), "Closing cash $513.24")
	assert_string_contains(session.get_daily_report_text(), "Gross profit $12.99")
	assert_string_contains(session.get_daily_report_text(), "Operating expenses: $8.75")


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
	assert_string_contains(session.get_fixture_order_summary_text(), "Order Game Display Rack $125.00 for storage placement")
	assert_string_contains(session.get_fixture_order_summary_text(), "Pending storage placement: none")


func test_store_session_lists_available_supplier_lots() -> void:
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(session)

	var lots := session.get_available_supplier_lots()

	assert_eq(lots.size(), 1)
	assert_eq(lots[0].get("lot_id"), "supplier_lot_used_games_001")
	assert_true(session.can_order_supplier_lot("supplier_lot_used_games_001"))
	assert_string_contains(session.get_supplier_order_summary_text(), "Receiving orders:")
	assert_string_contains(session.get_supplier_order_summary_text(), "Order Used Game Starter Lot $27.00")
	assert_string_contains(session.get_supplier_order_summary_text(), "Category: Used games")
	assert_string_contains(session.get_supplier_order_summary_text(), "Cart: 1 lot / 3 items")
	assert_string_contains(session.get_supplier_order_summary_text(), "Cost: $27.00 reserved on order")
	assert_string_contains(session.get_supplier_order_summary_text(), "Delivery: due day 2 (1 day)")
	assert_string_contains(session.get_supplier_order_summary_text(), "Storage: Receiving box intake")
	assert_string_contains(session.get_supplier_order_summary_text(), "Receiving: Delivered as physical cases")
	assert_string_contains(session.get_supplier_order_summary_text(), "Pending receiving: none")


func test_store_session_formats_supplier_order_ui_details() -> void:
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(session)

	var order := session.order_supplier_lot("supplier_lot_used_games_001")
	var summary := session.get_supplier_order_summary_text()

	assert_eq(order.get("category_label"), "Used games")
	assert_eq(order.get("delivery_days"), 1)
	assert_eq(order.get("storage_requirement"), "Receiving box intake, then display rack or backstock")
	assert_string_contains(str(order.get("receiving_expectation")), "physical cases in the receiving box")
	assert_string_contains(summary, "Pending receiving:")
	assert_string_contains(summary, "Delivery state: pending delivery")
	assert_string_contains(summary, "Cost reserved: $27.00")
	assert_string_contains(summary, "Storage needed: Receiving box intake")
	assert_string_contains(summary, "Receiving expectation: Delivered as physical cases")


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

	var launch_day_session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(launch_day_session)
	launch_day_session.day_number = 3
	assert_false(launch_day_session.can_commit_release_allocation("release_neon_skyline", 1))
	assert_true(launch_day_session.commit_release_allocation("release_neon_skyline", 1).is_empty())


func test_store_session_resolves_launch_day_preorders_and_queue_demand() -> void:
	var ledger := TransactionLedger.new()
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	var release := load("res://data/releases/neon_skyline_launch.tres")
	add_child_autofree(ledger)
	add_child_autofree(session)
	session.ledger_path = session.get_path_to(ledger)
	var preorder := ledger.record_preorder_deposit("preorder_customer_001", release, 500)
	session.apply_preorder_deposit(preorder)
	session.commit_release_allocation("release_neon_skyline", 4)

	session.end_day()
	var day_two := session.start_next_day()
	session.end_day()
	var day_three := session.start_next_day()

	assert_eq(day_two.get("launch_event_count"), 0)
	assert_eq(day_three.get("day_number"), 3)
	assert_eq(day_three.get("launch_event_count"), 1)
	assert_eq(session.get_launch_event_count(), 1)
	assert_eq(session.get_cash_cents(), 50447)
	assert_eq(session.get_operating_expenses_total_cents(), 1750)
	assert_eq(session.get_total_launch_revenue_cents(), 14497)
	assert_eq(session.get_total_launch_profit_cents(), 5397)
	assert_eq(session.get_reputation_score(), 100)
	var event := session.get_launch_events()[0]
	assert_eq(event.get("release_id"), "release_neon_skyline")
	assert_eq(event.get("allocation_quantity"), 4)
	assert_eq(event.get("preorder_count"), 1)
	assert_eq(event.get("preorder_fulfilled"), 1)
	assert_eq(event.get("launch_queue_demand"), 2)
	assert_eq(event.get("launch_queue_fulfilled"), 2)
	assert_eq(event.get("missed_demand"), 0)
	assert_eq(event.get("surplus_quantity"), 1)
	assert_eq(event.get("reputation_delta"), 0)
	assert_string_contains(session.get_preorder_summary_text(), "Neon Skyline preorder fulfilled day 3")
	assert_string_contains(session.get_release_allocation_summary_text(), "Neon Skyline x4 launched $128.00 due day 3")
	assert_string_contains(session.get_launch_summary_text(), "Neon Skyline launch: preorders 1/1, queue 2/2, missed 0")
	assert_string_contains(session.get_summary_text(), "Launch events: 1")
	assert_string_contains(session.get_summary_text(), "Launch cash: $144.97")
	assert_string_contains(session.get_summary_text(), "Launch profit: $53.97")


func test_store_session_launch_day_shortage_reduces_reputation() -> void:
	var ledger := TransactionLedger.new()
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	var release := load("res://data/releases/neon_skyline_launch.tres")
	add_child_autofree(ledger)
	add_child_autofree(session)
	session.ledger_path = session.get_path_to(ledger)
	var preorder := ledger.record_preorder_deposit("preorder_customer_001", release, 500)
	session.apply_preorder_deposit(preorder)
	session.commit_release_allocation("release_neon_skyline", 1)

	session.end_day()
	session.start_next_day()
	session.end_day()
	session.start_next_day()

	var event := session.get_launch_events()[0]
	assert_eq(event.get("preorder_fulfilled"), 1)
	assert_eq(event.get("launch_queue_fulfilled"), 0)
	assert_eq(event.get("missed_demand"), 2)
	assert_eq(event.get("reputation_delta"), -10)
	assert_eq(event.get("reputation_score"), 90)
	assert_eq(session.get_reputation_score(), 90)
	assert_eq(session.get_reputation_events().size(), 1)
	assert_string_contains(session.get_reputation_summary_text(), "Missed launch demand for Neon Skyline -10")
	assert_eq(session.get_cash_cents(), 50049)
	assert_eq(session.get_operating_expenses_total_cents(), 1750)
	assert_string_contains(session.get_launch_summary_text(), "queue 0/2, missed 2")


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
	assert_string_contains(session.get_supplier_order_summary_text(), "Pending receiving:")
	assert_string_contains(session.get_supplier_order_summary_text(), "Used Game Starter Lot due to receiving day 2 (3 items)")
	assert_string_contains(session.get_supplier_order_summary_text(), "Delivery state: pending delivery")
	assert_string_contains(session.get_supplier_order_summary_text(), "Cost reserved: $27.00")


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
	assert_eq(session.get_pending_receiving_batches().size(), 1)
	assert_string_contains(session.get_supplier_order_summary_text(), "Receiving box:")
	assert_string_contains(session.get_supplier_order_summary_text(), "Used Game Starter Lot delivered to receiving day 2")
	assert_string_contains(session.get_supplier_order_summary_text(), "Delivery state: delivered")
	assert_string_contains(session.get_supplier_order_summary_text(), "3 items ready for pickup, pricing, and stocking")
	assert_string_contains(session.get_supplier_order_summary_text(), "Receiving workflow:")
	assert_string_contains(session.get_supplier_order_summary_text(), "Delivery point: Backroom receiving mat / receiving_box_001")
	assert_string_contains(session.get_supplier_order_summary_text(), "Box: sealed")
	assert_string_contains(session.get_supplier_order_summary_text(), "Invoice: unchecked expected 3 received 3 variance 0")
	assert_string_contains(session.get_supplier_order_summary_text(), "Sorting: waiting -> unsorted")
	assert_eq(_count_inventory_items(receiving_box), 6)
	assert_not_null(receiving_box.get_node_or_null("DeliveredUsedGame004"))
	assert_string_contains(session.get_inventory_summary_text(), "Moon Escape x1")
	assert_string_contains(session.get_inventory_summary_text(), "Neon Harbor x1")


func test_store_session_opens_checks_and_sorts_receiving_batch() -> void:
	var root := Node3D.new()
	var receiving_box: Node3D = load("res://scenes/props/receiving_box.tscn").instantiate()
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(root)
	root.add_child(receiving_box)
	root.add_child(session)
	session.inventory_root_path = session.get_path_to(root)
	session.receiving_box_path = session.get_path_to(receiving_box)
	var order := session.order_supplier_lot("supplier_lot_used_games_001")

	session.end_day()
	session.start_next_day()
	var batch_id := str(order.get("order_id"))
	var opened := session.open_receiving_batch(batch_id)
	var checked := session.check_receiving_invoice(batch_id)
	var sorted := session.sort_receiving_batch(batch_id, "price_stock")

	assert_eq(opened.get("box_status"), "opened")
	assert_eq(checked.get("invoice_status"), "checked")
	assert_eq(checked.get("invoice_variance"), 0)
	assert_eq(sorted.get("sorting_status"), "sorted")
	assert_eq(sorted.get("sort_destination"), "price_stock")
	assert_eq(sorted.get("status"), "completed")
	assert_eq(session.get_pending_receiving_batches().size(), 0)
	assert_string_contains(session.get_receiving_workflow_summary_text(), "Box: opened")
	assert_string_contains(session.get_receiving_workflow_summary_text(), "Invoice: checked expected 3 received 3 variance 0")
	assert_string_contains(session.get_receiving_workflow_summary_text(), "Sorting: sorted -> price_stock")
	assert_string_contains(session.get_receiving_workflow_summary_text(), "Receiving state: completed")


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
	assert_string_contains(session.get_fixture_order_summary_text(), "Pending storage placement:")
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
	assert_string_contains(session.get_fixture_order_summary_text(), "Pending storage placement: none")
	assert_string_contains(session.get_fixture_order_summary_text(), "Placed storage fixtures:")
	assert_string_contains(session.get_fixture_order_summary_text(), "Game Display Rack placed")


func test_store_session_adjusts_pending_fixture_placement() -> void:
	var fixture_root := Node3D.new()
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	var manager: FixturePlacementManager = load("res://scripts/store_layout/fixture_placement_manager.gd").new()
	var ghost := Node3D.new()
	ghost.name = "GhostRackPreview"
	add_child_autofree(fixture_root)
	fixture_root.add_child(manager)
	fixture_root.add_child(session)
	manager.add_child(ghost)
	manager._ready()
	session.fixture_placement_manager_path = session.get_path_to(manager)
	session.inventory_root_path = session.get_path_to(fixture_root)

	assert_false(session.can_adjust_pending_fixture_placement())
	session.order_fixture("fixture_game_display_rack")
	var start_position := manager.get_ghost_position()
	var start_rotation := manager.get_ghost_rotation_y()

	assert_true(session.can_adjust_pending_fixture_placement())
	assert_true(session.move_pending_fixture_placement(1, 0))
	assert_gt(manager.get_ghost_position().x, start_position.x)
	assert_true(session.rotate_pending_fixture_placement())
	assert_ne(manager.get_ghost_rotation_y(), start_rotation)
	manager.set_ghost_position(Vector3(-0.83, 0.04, 2.11))
	assert_true(session.snap_pending_fixture_placement())
	assert_almost_eq(manager.get_ghost_position().x, -0.75, 0.001)
	assert_almost_eq(manager.get_ghost_position().z, 2.0, 0.001)


func test_store_session_cancels_pending_fixture_placement_and_refunds_cash() -> void:
	var fixture_root := Node3D.new()
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	var manager: FixturePlacementManager = load("res://scripts/store_layout/fixture_placement_manager.gd").new()
	var ghost := Node3D.new()
	ghost.name = "GhostRackPreview"
	add_child_autofree(fixture_root)
	fixture_root.add_child(manager)
	fixture_root.add_child(session)
	manager.add_child(ghost)
	manager._ready()
	session.fixture_placement_manager_path = session.get_path_to(manager)
	session.inventory_root_path = session.get_path_to(fixture_root)

	assert_eq(session.get_cash_cents(), 50000)
	var order := session.order_fixture("fixture_game_display_rack")
	assert_false(order.is_empty())
	assert_eq(session.get_cash_cents(), 37500)
	assert_true(manager.is_ghost_visible())

	var canceled := session.cancel_pending_fixture_placement()

	assert_eq(canceled.get("order_id"), order.get("order_id"))
	assert_eq(canceled.get("status"), "canceled")
	assert_eq(session.get_cash_cents(), 50000)
	assert_eq(session.get_pending_fixture_orders().size(), 0)
	assert_eq(session.get_placed_fixture_orders().size(), 0)
	assert_false(manager.is_ghost_visible())
	assert_eq(session.fixture_orders[0].get("status"), "canceled")


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
