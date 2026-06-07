extends GutTest


func test_preorder_customer_describes_release_request() -> void:
	var customer: SimplePreorderCustomer = load("res://scenes/customers/simple_preorder_customer.tscn").instantiate()
	add_child_autofree(customer)

	assert_true(customer.is_waiting_for_preorder())
	assert_eq(customer.get_release_name(), "Neon Skyline")
	assert_eq(customer.get_deposit_cents(), 500)
	assert_eq(customer.get_interaction_prompt(), "Preorder Customer: Neon Skyline")
	assert_string_contains(customer.interact(), "Wants to preorder Neon Skyline")
	assert_string_contains(customer.interact(), "$5.00 deposit")


func test_preorder_customer_completes_once() -> void:
	var customer: SimplePreorderCustomer = load("res://scenes/customers/simple_preorder_customer.tscn").instantiate()
	add_child_autofree(customer)

	assert_true(customer.complete_preorder())

	assert_false(customer.is_waiting_for_preorder())
	assert_false(customer.complete_preorder())
	assert_eq(customer.get_interaction_prompt(), "Preorder Complete")
	assert_string_contains(customer.interact(), "already recorded")


func test_register_records_preorder_deposit_after_trade_queue_clears() -> void:
	var register: RegisterWorkstation = load("res://scenes/props/register_workstation.tscn").instantiate()
	var customer: SimplePreorderCustomer = load("res://scenes/customers/simple_preorder_customer.tscn").instantiate()
	var ledger := TransactionLedger.new()
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(register)
	add_child_autofree(customer)
	add_child_autofree(ledger)
	add_child_autofree(session)

	session.ledger_path = session.get_path_to(ledger)
	register.preorder_customer_path = register.get_path_to(customer)
	register.ledger_path = register.get_path_to(ledger)
	register.store_session_path = register.get_path_to(session)

	assert_eq(register.get_interaction_prompt(), "E Take Preorder Neon Skyline")
	var message := register.interact()

	assert_string_contains(message, "Took $5.00 preorder deposit for Neon Skyline")
	assert_false(customer.is_waiting_for_preorder())
	assert_eq(ledger.get_preorder_deposit_count(), 1)
	assert_eq(ledger.get_total_preorder_deposit_cents(), 500)
	assert_eq(ledger.get_sale_count(), 0)
	assert_eq(ledger.get_total_revenue_cents(), 0)
	assert_eq(session.get_cash_cents(), 50500)
	assert_eq(session.get_preorder_deposit_count(), 1)
	assert_eq(session.get_total_preorder_deposit_cents(), 500)
