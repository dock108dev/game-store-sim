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
	assert_eq(customer.get_store_credit_offer_cents(), 950)
	assert_eq(customer.get_market_value_cents(), 1899)
	assert_eq(customer.get_max_offer_cents(), 1899)
	assert_string_contains(customer.get_interaction_prompt(), "Moon Escape")
	assert_string_contains(customer.get_trade_in_summary(), "Credit $9.50")


func test_trade_in_customer_carried_item_is_compact_and_body_anchored() -> void:
	var customer: SimpleTradeInCustomer = load("res://scenes/customers/simple_trade_in_customer.tscn").instantiate()
	add_child_autofree(customer)

	var item := customer.get_trade_item()
	assert_not_null(item)
	assert_lte(item.scale.x, 0.4)
	assert_gte(item.position.y, 0.56)
	assert_lte(item.position.y, 0.66)
	assert_gte(item.position.x, 0.1)
	assert_lte(item.position.x, 0.18)
	assert_lte(item.position.z, -0.1)
	assert_gte(item.position.z, -0.22)

	var case_mesh := item.get_node("CaseMesh") as MeshInstance3D
	var carried_top: float = item.position.y + (case_mesh.mesh.size.y * item.scale.y)
	assert_lt(carried_top, 0.76)


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

	assert_eq(register.get_interaction_prompt(), "E Review Trade-In Moon Escape")
	var message := register.interact()

	assert_string_contains(message, "Bought Moon Escape trade-in")
	assert_string_contains(message, "$7.60 cash")
	assert_eq(ledger.get_trade_in_count(), 1)
	assert_eq(ledger.get_total_trade_in_cost_cents(), 760)
	assert_eq(ledger.get_total_trade_in_credit_cents(), 0)
	assert_eq(ledger.get_sale_count(), 0)
	assert_eq(session.get_cash_cents(), 49240)
	assert_eq(receiving_box.get_child_count(), 1)
	assert_eq(receiving_box.get_child(0).get("location_id"), "receiving_box_001")


func test_register_accepts_adjusted_trade_in_offer() -> void:
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
	register.receiving_box_path = register.get_path_to(receiving_box)
	register.ledger_path = register.get_path_to(ledger)
	register.store_session_path = register.get_path_to(session)

	var message := register.accept_trade_in(customer, 860)

	assert_string_contains(message, "$8.60")
	assert_eq(ledger.get_total_trade_in_cost_cents(), 860)
	assert_eq(session.get_cash_cents(), 49140)
	assert_eq(receiving_box.get_child(0).get("cost_basis_cents"), 860)


func test_register_accepts_store_credit_trade_in_without_reducing_cash() -> void:
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
	register.receiving_box_path = register.get_path_to(receiving_box)
	register.ledger_path = register.get_path_to(ledger)
	register.store_session_path = register.get_path_to(session)

	var message := register.accept_trade_in_store_credit(customer)

	assert_string_contains(message, "$9.50 store credit")
	assert_eq(ledger.get_trade_in_count(), 1)
	assert_eq(ledger.get_total_trade_in_cost_cents(), 0)
	assert_eq(ledger.get_total_trade_in_credit_cents(), 950)
	assert_eq(session.get_cash_cents(), 50000)
	assert_eq(receiving_box.get_child(0).get("cost_basis_cents"), 950)
	var transaction := ledger.get_transactions()[0]
	assert_eq(transaction.get("tender_type"), "store_credit")
	assert_eq(transaction.get("trade_in_cash_cents"), 0)
	assert_eq(transaction.get("trade_in_credit_cents"), 950)


func test_register_opens_trade_in_offer_for_player_actor() -> void:
	var register: RegisterWorkstation = load("res://scenes/props/register_workstation.tscn").instantiate()
	var customer: SimpleTradeInCustomer = load("res://scenes/customers/simple_trade_in_customer.tscn").instantiate()
	var actor := _TradeInActor.new()
	add_child_autofree(register)
	add_child_autofree(customer)
	add_child_autofree(actor)

	register.trade_in_customer_path = register.get_path_to(customer)

	assert_eq(register.interact_with_actor(actor), "")
	assert_eq(actor.opened_register, register)
	assert_eq(actor.opened_customer, customer)


func test_trade_in_customer_can_be_declined() -> void:
	var customer: SimpleTradeInCustomer = load("res://scenes/customers/simple_trade_in_customer.tscn").instantiate()
	add_child_autofree(customer)

	assert_true(customer.decline_trade_in())
	assert_eq(customer.state, SimpleTradeInCustomer.STATE_TRADE_DECLINED)
	assert_false(customer.is_waiting_for_trade_in())
	assert_string_contains(customer.interact(), "declined")


class _TradeInActor:
	extends Node

	var opened_register: RegisterWorkstation = null
	var opened_customer: SimpleTradeInCustomer = null

	func open_trade_in_offer(register: RegisterWorkstation, customer: SimpleTradeInCustomer) -> String:
		opened_register = register
		opened_customer = customer
		return ""
