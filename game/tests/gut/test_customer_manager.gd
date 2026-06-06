extends GutTest


func test_customer_manager_collects_child_customers() -> void:
	var manager: Node = load("res://scripts/customers/customer_manager.gd").new()
	var customer: SimpleBuyerCustomer = load("res://scenes/customers/simple_buyer_customer.tscn").instantiate()
	add_child_autofree(manager)
	manager.add_child(customer)

	assert_eq(manager.get_customers().size(), 1)
	assert_eq(manager.get_customers()[0], customer)


func test_customer_manager_claims_stocked_items_for_multiple_customers() -> void:
	var rack: Node3D = load("res://scenes/props/placeholder_shelf.tscn").instantiate()
	var manager: Node = load("res://scripts/customers/customer_manager.gd").new()
	var first_customer: SimpleBuyerCustomer = load("res://scenes/customers/simple_buyer_customer.tscn").instantiate()
	var second_customer: SimpleBuyerCustomer = load("res://scenes/customers/simple_buyer_customer.tscn").instantiate()
	var first_item: Node3D = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	var second_item: Node3D = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(rack)
	add_child_autofree(manager)
	manager.add_child(first_customer)
	manager.add_child(second_customer)
	first_customer.customer_id = "customer_001"
	second_customer.customer_id = "customer_002"

	var first_slot := rack.get_node("ShelfSlot001") as ShelfSlot
	var second_slot := rack.get_node("ShelfSlot002") as ShelfSlot
	assert_true(first_slot.place_item(first_item))
	assert_true(second_slot.place_item(second_item))
	var slot_paths: Array[NodePath] = [
		manager.get_path_to(first_slot),
		manager.get_path_to(second_slot),
	]
	manager.display_slot_paths = slot_paths

	manager.process_customer_claims()

	assert_eq(manager.get_waiting_customers().size(), 2)
	assert_eq(manager.get_next_waiting_customer(), first_customer)
	assert_true(first_slot.is_available())
	assert_true(second_slot.is_available())
	assert_eq(first_item.get("location_id"), "customer:customer_001")
	assert_eq(second_item.get("location_id"), "customer:customer_002")
	assert_almost_eq(second_customer.global_position.x, manager.register_queue_start.x + manager.register_queue_spacing.x, 0.001)


func test_register_completes_multiple_customer_manager_sales() -> void:
	var rack: Node3D = load("res://scenes/props/placeholder_shelf.tscn").instantiate()
	var manager: Node = load("res://scripts/customers/customer_manager.gd").new()
	var register: RegisterWorkstation = load("res://scenes/props/register_workstation.tscn").instantiate()
	var ledger := TransactionLedger.new()
	var session: Node = load("res://scripts/systems/store_session.gd").new()
	var first_customer: SimpleBuyerCustomer = load("res://scenes/customers/simple_buyer_customer.tscn").instantiate()
	var second_customer: SimpleBuyerCustomer = load("res://scenes/customers/simple_buyer_customer.tscn").instantiate()
	var first_item: Node3D = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	var second_item: Node3D = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(rack)
	add_child_autofree(manager)
	add_child_autofree(register)
	add_child_autofree(ledger)
	add_child_autofree(session)
	manager.add_child(first_customer)
	manager.add_child(second_customer)

	first_customer.customer_id = "customer_001"
	second_customer.customer_id = "customer_002"
	first_item.set("instance_id", "item_used_star_trader_001")
	second_item.set("instance_id", "item_used_star_trader_002")
	var first_slot := rack.get_node("ShelfSlot001") as ShelfSlot
	var second_slot := rack.get_node("ShelfSlot002") as ShelfSlot
	assert_true(first_slot.place_item(first_item))
	assert_true(second_slot.place_item(second_item))
	var slot_paths: Array[NodePath] = [
		manager.get_path_to(first_slot),
		manager.get_path_to(second_slot),
	]
	manager.display_slot_paths = slot_paths
	manager.process_customer_claims()

	session.ledger_path = session.get_path_to(ledger)
	register.customer_manager_path = register.get_path_to(manager)
	register.ledger_path = register.get_path_to(ledger)
	register.store_session_path = register.get_path_to(session)

	assert_string_contains(register.interact(), "Sold Star Trader")
	assert_string_contains(register.interact(), "Sold Star Trader")

	assert_eq(ledger.get_sale_count(), 2)
	assert_eq(ledger.get_total_revenue_cents(), 4398)
	assert_eq(ledger.get_total_profit_cents(), 2598)
	assert_eq(session.get_cash_cents(), 54398)
	assert_eq(manager.get_waiting_customers().size(), 0)
	assert_eq(first_customer.state, SimpleBuyerCustomer.STATE_SALE_COMPLETE)
	assert_eq(second_customer.state, SimpleBuyerCustomer.STATE_SALE_COMPLETE)
