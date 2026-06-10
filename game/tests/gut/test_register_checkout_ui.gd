extends GutTest


func test_register_checkout_ui_builds_itemized_sale_totals_and_tender() -> void:
	var setup := _make_sale_register()
	var register := setup.get("register") as RegisterWorkstation
	register.default_cash_tender_cents = 5000

	var state := register.get_checkout_ui_state()
	var lines: Array = state.get("cart_lines", [])

	assert_eq(state.get("surface"), "register")
	assert_eq(state.get("transaction_type"), "sale")
	assert_eq(lines.size(), 1)
	assert_eq(lines[0].get("label"), "Star Trader")
	assert_eq(lines[0].get("quantity"), 1)
	assert_eq(lines[0].get("line_total_cents"), 2199)
	assert_eq(state.get("subtotal_cents"), 2199)
	assert_eq(state.get("tax_cents"), 0)
	assert_eq(state.get("total_cents"), 2199)
	assert_eq(state.get("tender_method"), "Cash")
	assert_eq(state.get("tendered_cents"), 5000)
	assert_eq(state.get("change_due_cents"), 2801)
	assert_string_contains(str(state.get("return_placeholder")), "Returns")
	assert_true(state.get("has_active_checkout"))


func test_register_checkout_ui_completion_records_confirmation_feedback() -> void:
	var setup := _make_sale_register()
	var register := setup.get("register") as RegisterWorkstation

	var message := register.complete_active_checkout()
	var state := register.get_last_checkout_ui_state()

	assert_string_contains(message, "Sold Star Trader")
	assert_true(state.get("completed"))
	assert_false(state.get("has_active_checkout"))
	assert_string_contains(str(state.get("sale_confirmation")), "Sold Star Trader")
	assert_string_contains(str(state.get("transaction_feedback")), "Profit")
	var ledger := setup.get("ledger") as TransactionLedger
	var item := setup.get("item") as Node
	assert_eq(ledger.get_sale_count(), 1)
	assert_eq(item.get("location_id"), "sold")


func test_register_checkout_ui_builds_preorder_deposit_line() -> void:
	var register: RegisterWorkstation = load("res://scenes/props/register_workstation.tscn").instantiate()
	var customer: SimplePreorderCustomer = load("res://scenes/customers/simple_preorder_customer.tscn").instantiate()
	var ledger := TransactionLedger.new()
	add_child_autofree(register)
	add_child_autofree(customer)
	add_child_autofree(ledger)
	register.preorder_customer_path = register.get_path_to(customer)
	register.ledger_path = register.get_path_to(ledger)

	var state := register.get_checkout_ui_state()

	assert_eq(state.get("transaction_type"), "preorder_deposit")
	assert_string_contains(str(state.get("preorder_line")), "Neon Skyline")
	assert_eq(state.get("subtotal_cents"), 500)
	assert_eq(state.get("total_cents"), 500)
	assert_eq(state.get("change_due_cents"), 0)
	assert_string_contains(str(state.get("sale_confirmation")), "not counted as sale revenue")


func test_register_checkout_ui_builds_service_line_and_profit() -> void:
	var register: RegisterWorkstation = load("res://scenes/props/register_workstation.tscn").instantiate()
	var customer: Node = load("res://scenes/customers/simple_service_customer.tscn").instantiate()
	var ledger := TransactionLedger.new()
	add_child_autofree(register)
	add_child_autofree(customer)
	add_child_autofree(ledger)
	register.service_customer_path = register.get_path_to(customer)
	register.ledger_path = register.get_path_to(ledger)

	var state := register.get_checkout_ui_state()
	var lines: Array = state.get("cart_lines", [])

	assert_eq(state.get("transaction_type"), "service")
	assert_string_contains(str(state.get("service_line")), "Disc Resurfacing")
	assert_string_contains(str(state.get("service_line")), "Scratched Orbit Disc")
	assert_eq(state.get("subtotal_cents"), 599)
	assert_eq(lines[0].get("service_cost_cents"), 125)
	assert_eq(lines[0].get("profit_cents"), 474)
	assert_string_contains(str(state.get("sale_confirmation")), "Service revenue")


func test_register_checkout_ui_builds_return_review_line_and_refund() -> void:
	var register: RegisterWorkstation = load("res://scenes/props/register_workstation.tscn").instantiate()
	var customer: SimpleReturnCustomer = load("res://scenes/customers/simple_return_customer.tscn").instantiate()
	var ledger := TransactionLedger.new()
	add_child_autofree(register)
	add_child_autofree(customer)
	add_child_autofree(ledger)
	register.return_customer_path = register.get_path_to(customer)
	register.ledger_path = register.get_path_to(ledger)

	var state := register.get_checkout_ui_state()
	var lines: Array = state.get("cart_lines", [])

	assert_eq(state.get("transaction_type"), "return")
	assert_eq(state.get("title"), "Return Review")
	assert_eq(lines.size(), 1)
	assert_eq(lines[0].get("label"), "Solar Ferry")
	assert_eq(lines[0].get("line_type"), "return")
	assert_eq(lines[0].get("line_total_cents"), -2199)
	assert_eq(state.get("subtotal_cents"), -2199)
	assert_eq(state.get("total_cents"), -2199)
	assert_eq(state.get("tender_method"), "Cash refund")
	assert_eq(state.get("refund_due_cents"), 2199)
	assert_string_contains(str(state.get("return_line")), "Solar Ferry refund $21.99")
	assert_string_contains(str(state.get("return_placeholder")), "route item to receiving")
	assert_string_contains(str(state.get("sale_confirmation")), "protect reputation")


func test_register_checkout_ui_idle_state_includes_return_scope() -> void:
	var register: RegisterWorkstation = load("res://scenes/props/register_workstation.tscn").instantiate()
	add_child_autofree(register)

	var state := register.get_checkout_ui_state()

	assert_eq(state.get("transaction_type"), "idle")
	assert_false(state.get("has_active_checkout"))
	assert_string_contains(str(state.get("confirmation")), "No checkout waiting")
	assert_string_contains(str(state.get("return_placeholder")), "register review handles refund")


func _make_sale_register() -> Dictionary:
	var rack: Node3D = load("res://scenes/props/placeholder_shelf.tscn").instantiate()
	var customer: SimpleBuyerCustomer = load("res://scenes/customers/simple_buyer_customer.tscn").instantiate()
	var register: RegisterWorkstation = load("res://scenes/props/register_workstation.tscn").instantiate()
	var ledger := TransactionLedger.new()
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	var item: Node3D = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(rack)
	add_child_autofree(customer)
	add_child_autofree(register)
	add_child_autofree(ledger)
	add_child_autofree(session)

	var slot := rack.get_node("ShelfSlot001") as ShelfSlot
	assert_true(slot.place_item(item))
	assert_true(customer.claim_item_from_slot(slot))

	session.ledger_path = session.get_path_to(ledger)
	register.customer_path = register.get_path_to(customer)
	register.ledger_path = register.get_path_to(ledger)
	register.store_session_path = register.get_path_to(session)

	return {
		"register": register,
		"customer": customer,
		"ledger": ledger,
		"session": session,
		"item": item,
	}
