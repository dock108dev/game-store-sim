extends GutTest


func test_customer_claims_matching_stocked_item_and_waits_at_register() -> void:
	var rack: Node3D = load("res://scenes/props/placeholder_shelf.tscn").instantiate()
	var customer: SimpleBuyerCustomer = load("res://scenes/customers/simple_buyer_customer.tscn").instantiate()
	var item: Node3D = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(rack)
	add_child_autofree(customer)

	var slot := rack.get_node("ShelfSlot001") as ShelfSlot
	assert_true(slot.place_item(item))

	assert_true(customer.claim_item_from_slot(slot))

	var collision_shape := item.get_node("CollisionShape3D") as CollisionShape3D
	assert_true(slot.is_available())
	assert_eq(customer.state, SimpleBuyerCustomer.STATE_WAITING_FOR_REGISTER)
	assert_true(customer.is_waiting_for_register())
	assert_eq(customer.get_checkout_item(), item)
	assert_eq(item.get_parent(), customer)
	assert_eq(item.get("location_id"), "customer:customer_001")
	assert_true(collision_shape.disabled)
	assert_almost_eq(customer.global_position.x, customer.register_queue_position.x, 0.001)


func test_customer_moves_to_stocked_item_before_waiting_at_register() -> void:
	var rack: Node3D = load("res://scenes/props/placeholder_shelf.tscn").instantiate()
	var customer: SimpleBuyerCustomer = load("res://scenes/customers/simple_buyer_customer.tscn").instantiate()
	var item: Node3D = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(rack)
	add_child_autofree(customer)

	var slot := rack.get_node("ShelfSlot001") as ShelfSlot
	assert_true(slot.place_item(item))

	assert_true(customer.begin_claim_from_slot(slot, Vector3(1.0, 0.0, -3.35)))
	assert_eq(customer.state, SimpleBuyerCustomer.STATE_MOVING_TO_ITEM)
	assert_false(slot.is_available())

	_advance_customer(customer, 4.0)

	assert_true(slot.is_available())
	assert_eq(customer.state, SimpleBuyerCustomer.STATE_WAITING_FOR_REGISTER)
	assert_true(customer.is_waiting_for_register())
	assert_eq(customer.get_checkout_item(), item)
	assert_eq(item.get_parent(), customer)
	assert_almost_eq(customer.global_position.z, customer.register_queue_position.z, 0.001)


func test_customer_ignores_unstocked_or_mismatched_items() -> void:
	var rack: Node3D = load("res://scenes/props/placeholder_shelf.tscn").instantiate()
	var customer: SimpleBuyerCustomer = load("res://scenes/customers/simple_buyer_customer.tscn").instantiate()
	add_child_autofree(rack)
	add_child_autofree(customer)

	var slot := rack.get_node("ShelfSlot001") as ShelfSlot
	assert_false(customer.claim_item_from_slot(slot))
	assert_false(customer.is_waiting_for_register())

	var item: Node3D = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	var product := ProductDefinition.new()
	product.product_id = "used_other_game"
	product.display_name = "Other Game"
	product.category = "used_game"
	product.platform = "Orbit 64"
	product.condition = "good"
	product.completeness = "complete"
	product.cost_basis_cents = 700
	product.market_value_cents = 1999
	product.suggested_price_cents = 1799
	product.player_priceable = true
	item.set("product", product)
	add_child_autofree(item)
	assert_true(slot.place_item(item))

	assert_false(customer.claim_item_from_slot(slot))
	assert_false(slot.is_available())
	assert_eq(customer.state, SimpleBuyerCustomer.STATE_BROWSING)


func test_customer_rejects_overpriced_matching_item() -> void:
	var rack: Node3D = load("res://scenes/props/placeholder_shelf.tscn").instantiate()
	var customer: SimpleBuyerCustomer = load("res://scenes/customers/simple_buyer_customer.tscn").instantiate()
	var item: Node3D = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(rack)
	add_child_autofree(customer)

	var slot := rack.get_node("ShelfSlot001") as ShelfSlot
	item.set("current_price_cents", 4000)
	assert_true(slot.place_item(item))

	assert_false(customer.claim_item_from_slot(slot))

	assert_false(slot.is_available())
	assert_eq(customer.state, SimpleBuyerCustomer.STATE_BROWSING)
	assert_null(customer.get_checkout_item())
	assert_string_contains(customer.get_last_feedback(), "too expensive")
	assert_string_contains(customer.interact(), "too expensive")


func test_customer_completes_sale_and_marks_item_sold() -> void:
	var rack: Node3D = load("res://scenes/props/placeholder_shelf.tscn").instantiate()
	var customer: SimpleBuyerCustomer = load("res://scenes/customers/simple_buyer_customer.tscn").instantiate()
	var item: Node3D = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(rack)
	add_child_autofree(customer)

	var slot := rack.get_node("ShelfSlot001") as ShelfSlot
	assert_true(slot.place_item(item))
	assert_true(customer.claim_item_from_slot(slot))

	var sold_item := customer.complete_sale()

	assert_eq(sold_item, item)
	assert_eq(customer.state, SimpleBuyerCustomer.STATE_SALE_COMPLETE)
	assert_null(customer.get_checkout_item())
	assert_eq(item.get("location_id"), "sold")
	assert_false(item.visible)


func test_transaction_ledger_records_sale_totals() -> void:
	var ledger := TransactionLedger.new()
	var item: Node = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(ledger)
	add_child_autofree(item)

	var transaction := ledger.record_sale("customer_001", item)

	assert_eq(transaction.get("transaction_id"), "sale_001")
	assert_eq(transaction.get("customer_id"), "customer_001")
	assert_eq(transaction.get("item_instance_id"), "item_used_star_trader_001")
	assert_eq(transaction.get("product_id"), "used_star_trader")
	assert_eq(transaction.get("display_name"), "Star Trader")
	assert_eq(transaction.get("sale_price_cents"), 2199)
	assert_eq(transaction.get("cost_basis_cents"), 900)
	assert_eq(transaction.get("profit_cents"), 1299)
	assert_eq(ledger.get_sale_count(), 1)
	assert_eq(ledger.get_total_revenue_cents(), 2199)
	assert_eq(ledger.get_total_profit_cents(), 1299)


func _advance_customer(customer: SimpleBuyerCustomer, seconds: float) -> void:
	var step := 0.1
	var steps := int(ceil(seconds / step))
	for _index in range(steps):
		customer._process(step)
