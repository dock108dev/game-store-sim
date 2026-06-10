extends GutTest


func test_return_customer_starts_with_returned_item() -> void:
	var customer: SimpleReturnCustomer = load("res://scenes/customers/simple_return_customer.tscn").instantiate()
	add_child_autofree(customer)

	var item := customer.get_returned_item()

	assert_not_null(item)
	assert_eq(customer.state, SimpleReturnCustomer.STATE_WAITING_FOR_RETURN)
	assert_true(customer.is_waiting_for_return())
	assert_eq(item.get("location_id"), "customer:return_customer_001")
	assert_eq(customer.get_refund_cents(), 2199)
	assert_string_contains(customer.get_interaction_prompt(), "Solar Ferry")
	assert_string_contains(customer.get_return_summary(), "defective copy")
	assert_string_contains(customer.get_return_summary(), "$21.99")
	assert_string_contains(customer.get_archetype_summary(), "Return")


func test_return_customer_completes_into_receiving_review() -> void:
	var customer: SimpleReturnCustomer = load("res://scenes/customers/simple_return_customer.tscn").instantiate()
	var receiving_box := Node3D.new()
	add_child_autofree(customer)
	add_child_autofree(receiving_box)

	var item := customer.get_returned_item()
	var received_item := customer.complete_return(receiving_box)

	assert_eq(received_item, item)
	assert_eq(customer.state, SimpleReturnCustomer.STATE_RETURN_COMPLETE)
	assert_false(customer.is_waiting_for_return())
	assert_eq(item.get_parent(), receiving_box)
	assert_eq(item.get("location_id"), "receiving_box_001")
	assert_string_contains(customer.interact(), "already completed")


func test_return_customer_can_be_refused_once() -> void:
	var customer: SimpleReturnCustomer = load("res://scenes/customers/simple_return_customer.tscn").instantiate()
	add_child_autofree(customer)

	assert_true(customer.refuse_return())
	assert_eq(customer.state, SimpleReturnCustomer.STATE_RETURN_REFUSED)
	assert_false(customer.is_waiting_for_return())
	assert_string_contains(customer.interact(), "refused")
	assert_false(customer.refuse_return())


func test_ledger_records_return_transaction() -> void:
	var ledger := TransactionLedger.new()
	var customer: SimpleReturnCustomer = load("res://scenes/customers/simple_return_customer.tscn").instantiate()
	add_child_autofree(ledger)
	add_child_autofree(customer)

	var transaction := ledger.record_return(
		customer,
		customer.get_returned_item(),
		customer.get_refund_cents(),
		customer.return_disposition
	)

	assert_false(transaction.is_empty())
	assert_eq(transaction.get("type"), "return")
	assert_eq(transaction.get("customer_id"), "return_customer_001")
	assert_eq(transaction.get("display_name"), "Solar Ferry")
	assert_eq(transaction.get("refund_cents"), 2199)
	assert_eq(transaction.get("reason"), "defective copy")
	assert_eq(transaction.get("disposition"), "inspect_restock")
	assert_eq(ledger.get_return_count(), 1)
	assert_eq(ledger.get_total_return_refund_cents(), 2199)
	assert_eq(ledger.get_total_revenue_cents(), 0)
