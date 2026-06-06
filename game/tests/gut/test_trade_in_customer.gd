extends GutTest


func test_trade_in_customer_starts_with_carried_item() -> void:
	var customer: SimpleTradeInCustomer = load("res://scenes/customers/simple_trade_in_customer.tscn").instantiate()
	add_child_autofree(customer)

	var item := customer.get_trade_item()
	assert_not_null(item)
	assert_eq(customer.state, SimpleTradeInCustomer.STATE_WAITING_FOR_TRADE)
	assert_true(customer.is_waiting_for_trade_in())
	assert_eq(item.get("location_id"), "customer:trade_seller_001")
	assert_eq(customer.get_offer_cents(), 760)
	assert_string_contains(customer.get_interaction_prompt(), "Moon Escape")


func test_trade_in_customer_completes_into_receiving_inventory() -> void:
	var customer: SimpleTradeInCustomer = load("res://scenes/customers/simple_trade_in_customer.tscn").instantiate()
	var receiving_box := Node3D.new()
	add_child_autofree(customer)
	add_child_autofree(receiving_box)

	var item := customer.get_trade_item()
	item.set("cost_basis_cents", customer.get_offer_cents())

	var received_item := customer.complete_trade_in(receiving_box)

	assert_eq(received_item, item)
	assert_eq(customer.state, SimpleTradeInCustomer.STATE_TRADE_COMPLETE)
	assert_false(customer.is_waiting_for_trade_in())
	assert_eq(item.get_parent(), receiving_box)
	assert_eq(item.get("location_id"), "receiving_box_001")
	assert_eq(item.get("cost_basis_cents"), 760)


func test_register_completes_trade_in_when_no_buyer_is_waiting() -> void:
	var register: RegisterWorkstation = load("res://scenes/props/register_workstation.tscn").instantiate()
	var customer: SimpleTradeInCustomer = load("res://scenes/customers/simple_trade_in_customer.tscn").instantiate()
	var receiving_box := Node3D.new()
	var ledger := TransactionLedger.new()
	var session: Node = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(register)
	add_child_autofree(customer)
	add_child_autofree(receiving_box)
	add_child_autofree(ledger)
	add_child_autofree(session)

	session.ledger_path = session.get_path_to(ledger)
	register.trade_in_customer_path = register.get_path_to(customer)
	register.receiving_box_path = register.get_path_to(receiving_box)
	register.ledger_path = register.get_path_to(ledger)
	register.store_session_path = register.get_path_to(session)

	assert_eq(register.get_interaction_prompt(), "E Buy Trade-In Moon Escape")
	var message := register.interact()

	assert_string_contains(message, "Bought Moon Escape trade-in")
	assert_eq(ledger.get_trade_in_count(), 1)
	assert_eq(ledger.get_total_trade_in_cost_cents(), 760)
	assert_eq(ledger.get_sale_count(), 0)
	assert_eq(session.get_cash_cents(), 49240)
	assert_eq(receiving_box.get_child_count(), 1)
	assert_eq(receiving_box.get_child(0).get("location_id"), "receiving_box_001")
