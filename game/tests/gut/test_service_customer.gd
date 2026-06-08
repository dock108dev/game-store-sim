extends GutTest


func test_service_customer_describes_disc_resurfacing_request() -> void:
	var customer: Node = load("res://scenes/customers/simple_service_customer.tscn").instantiate()
	add_child_autofree(customer)

	assert_true(customer.call("is_waiting_for_service"))
	assert_eq(customer.call("get_interaction_prompt"), "Service Customer: Disc Resurfacing")
	assert_string_contains(str(customer.call("interact")), "Disc Resurfacing")
	assert_string_contains(str(customer.call("interact")), "Scratched Orbit Disc")
	assert_string_contains(str(customer.call("interact")), "$5.99")
	assert_string_contains(str(customer.call("interact")), "$1.25")
	assert_string_contains(str(customer.call("interact")), "10m")


func test_service_customer_completes_once() -> void:
	var customer: Node = load("res://scenes/customers/simple_service_customer.tscn").instantiate()
	add_child_autofree(customer)

	assert_true(customer.call("complete_service"))
	assert_false(customer.call("is_waiting_for_service"))
	assert_eq(customer.call("get_interaction_prompt"), "Service Complete")
	assert_eq(customer.call("interact"), "Service already completed.")
	assert_false(customer.call("complete_service"))


func test_ledger_records_service_transaction() -> void:
	var ledger := TransactionLedger.new()
	var customer: Node = load("res://scenes/customers/simple_service_customer.tscn").instantiate()
	add_child_autofree(ledger)
	add_child_autofree(customer)

	var transaction := ledger.record_service(customer)

	assert_false(transaction.is_empty())
	assert_eq(transaction.get("type"), "service")
	assert_eq(transaction.get("customer_id"), "service_customer_001")
	assert_eq(transaction.get("service_id"), "disc_resurfacing")
	assert_eq(transaction.get("display_name"), "Disc Resurfacing")
	assert_eq(transaction.get("item_name"), "Scratched Orbit Disc")
	assert_eq(transaction.get("service_price_cents"), 599)
	assert_eq(transaction.get("service_cost_cents"), 125)
	assert_eq(transaction.get("profit_cents"), 474)
	assert_eq(ledger.get_service_count(), 1)
	assert_eq(ledger.get_total_service_revenue_cents(), 599)
	assert_eq(ledger.get_total_service_cost_cents(), 125)
	assert_eq(ledger.get_total_service_profit_cents(), 474)
	assert_eq(ledger.get_total_revenue_cents(), 599)
	assert_eq(ledger.get_total_profit_cents(), 474)
