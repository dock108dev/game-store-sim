extends GutTest


func test_store_save_codec_serializes_session_transactions_and_inventory() -> void:
	var codec: RefCounted = load("res://scripts/save/store_save_codec.gd").new()
	var ledger := TransactionLedger.new()
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	var root := Node3D.new()
	var item: Node = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(ledger)
	add_child_autofree(session)
	add_child_autofree(root)
	root.add_child(item)

	session.ledger_path = session.get_path_to(ledger)
	session.inventory_root_path = session.get_path_to(root)
	var transaction := ledger.record_sale("customer_001", item)
	session.apply_sale(transaction)
	session.start_customer_hours()
	var preorder_transaction := ledger.record_preorder_deposit(
		"preorder_customer_001",
		load("res://data/releases/neon_skyline_launch.tres"),
		500
	)
	session.apply_preorder_deposit(preorder_transaction)
	session.commit_release_allocation("release_neon_skyline", 1)
	session.order_fixture("fixture_game_display_rack")
	session.order_supplier_lot("supplier_lot_used_games_001")
	item.set("current_price_cents", 2399)
	item.set("location_id", "shelf_slot_001")

	var data: Dictionary = codec.create_save_data(session)

	assert_eq(data.get("version"), 1)
	assert_eq(data.get("day_number"), 1)
	assert_eq(data.get("day_phase"), StoreSession.DAY_PHASE_CUSTOMER_HOURS)
	assert_eq(data.get("cash_cents"), 34299)
	assert_eq((data.get("transactions") as Array).size(), 2)
	var preorder_deposits: Array = data.get("preorder_deposits")
	assert_eq(preorder_deposits.size(), 1)
	assert_eq(preorder_deposits[0].get("release_id"), "release_neon_skyline")
	assert_eq(preorder_deposits[0].get("deposit_cents"), 500)
	var release_allocations: Array = data.get("release_allocations")
	assert_eq(release_allocations.size(), 1)
	assert_eq(release_allocations[0].get("release_id"), "release_neon_skyline")
	assert_eq(release_allocations[0].get("quantity"), 1)
	assert_eq(release_allocations[0].get("total_cost_cents"), 3200)
	assert_eq((data.get("launch_events") as Array).size(), 0)
	assert_eq(data.get("reputation_score"), 100)
	var fixture_orders: Array = data.get("fixture_orders")
	assert_eq(fixture_orders.size(), 1)
	assert_eq(fixture_orders[0].get("fixture_id"), "fixture_game_display_rack")
	assert_eq(fixture_orders[0].get("status"), "pending_placement")
	var supplier_orders: Array = data.get("supplier_orders")
	assert_eq(supplier_orders.size(), 1)
	assert_eq(supplier_orders[0].get("lot_id"), "supplier_lot_used_games_001")
	assert_eq(supplier_orders[0].get("status"), "pending_delivery")
	var inventory_items: Array = data.get("inventory_items")
	assert_eq(inventory_items.size(), 1)
	assert_eq(inventory_items[0].get("instance_id"), "item_used_star_trader_001")
	assert_eq(inventory_items[0].get("current_price_cents"), 2399)
	assert_eq(inventory_items[0].get("location_id"), "shelf_slot_001")


func test_store_save_codec_json_roundtrip_preserves_data() -> void:
	var codec: RefCounted = load("res://scripts/save/store_save_codec.gd").new()
	var data: Dictionary = {
		"version": 1,
		"day_number": 2,
		"day_phase": StoreSession.DAY_PHASE_TOMORROW_PLANNING,
		"cash_cents": 61234,
		"is_day_closed": true,
		"transactions": [{"transaction_id": "sale_001", "type": "sale"}],
		"fixture_orders": [{"fixture_id": "fixture_game_display_rack", "status": "pending_placement"}],
		"supplier_orders": [{"lot_id": "supplier_lot_used_games_001", "status": "pending_delivery"}],
		"preorder_deposits": [{"release_id": "release_neon_skyline", "deposit_cents": 500}],
		"release_allocations": [{"release_id": "release_neon_skyline", "quantity": 1}],
		"launch_events": [{"release_id": "release_neon_skyline", "missed_demand": 2}],
		"reputation_score": 90,
		"inventory_items": [{"instance_id": "item_001", "location_id": "held"}],
	}

	var json_text: String = codec.encode_to_json(data)
	var decoded: Dictionary = codec.decode_from_json(json_text)

	assert_eq(int(decoded.get("version")), 1)
	assert_eq(int(decoded.get("day_number")), 2)
	assert_eq(str(decoded.get("day_phase")), StoreSession.DAY_PHASE_TOMORROW_PLANNING)
	assert_eq(int(decoded.get("cash_cents")), 61234)
	assert_true(decoded.get("is_day_closed"))
	assert_eq((decoded.get("transactions") as Array).size(), 1)
	assert_eq((decoded.get("fixture_orders") as Array)[0].get("fixture_id"), "fixture_game_display_rack")
	assert_eq((decoded.get("supplier_orders") as Array)[0].get("lot_id"), "supplier_lot_used_games_001")
	assert_eq((decoded.get("preorder_deposits") as Array)[0].get("release_id"), "release_neon_skyline")
	assert_eq((decoded.get("release_allocations") as Array)[0].get("release_id"), "release_neon_skyline")
	assert_eq((decoded.get("launch_events") as Array)[0].get("release_id"), "release_neon_skyline")
	assert_eq(int(decoded.get("reputation_score")), 90)
	assert_eq((decoded.get("inventory_items") as Array)[0].get("location_id"), "held")


func test_store_save_codec_restores_session_ledger_and_existing_item_state() -> void:
	var codec: RefCounted = load("res://scripts/save/store_save_codec.gd").new()
	var ledger := TransactionLedger.new()
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	var root := Node3D.new()
	var item: Node = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(ledger)
	add_child_autofree(session)
	add_child_autofree(root)
	root.add_child(item)

	var data: Dictionary = {
		"version": 1,
		"day_number": 3,
		"day_phase": StoreSession.DAY_PHASE_REPORT,
		"cash_cents": 44444,
		"is_day_closed": true,
		"transactions": [
			{
				"transaction_id": "sale_001",
				"type": "sale",
				"display_name": "Star Trader",
				"sale_price_cents": 2499,
				"profit_cents": 1599,
			}
		],
		"fixture_orders": [
			{
				"order_id": "fixture_order_001",
				"fixture_id": "fixture_game_display_rack",
				"display_name": "Game Display Rack",
				"cost_cents": 12500,
				"status": "pending_placement",
			}
		],
		"supplier_orders": [
			{
				"order_id": "supplier_order_001",
				"lot_id": "supplier_lot_used_games_001",
				"display_name": "Used Game Starter Lot",
				"cost_cents": 2700,
				"ordered_day": 3,
				"due_day": 4,
				"item_count": 3,
				"status": "pending_delivery",
			}
		],
		"preorder_deposits": [
			{
				"transaction_id": "preorder_deposit_001",
				"type": "preorder_deposit",
				"customer_id": "preorder_customer_001",
				"release_id": "release_neon_skyline",
				"product_name": "Neon Skyline",
				"display_name": "Neon Skyline",
				"platform": "Orbit 64",
				"release_day": 3,
				"deposit_cents": 500,
			}
		],
		"release_allocations": [
			{
				"allocation_id": "release_allocation_001",
				"release_id": "release_neon_skyline",
				"product_name": "Neon Skyline",
				"display_name": "Neon Skyline",
				"platform": "Orbit 64",
				"release_day": 3,
				"quantity": 2,
				"wholesale_cost_cents": 3200,
				"total_cost_cents": 6400,
				"status": "committed",
			}
		],
		"launch_events": [
			{
				"event_id": "launch_event_001",
				"release_id": "release_neon_skyline",
				"product_name": "Neon Skyline",
				"release_day": 3,
				"preorder_count": 1,
				"preorder_fulfilled": 1,
				"launch_queue_demand": 2,
				"launch_queue_fulfilled": 1,
				"missed_demand": 1,
				"cash_received_cents": 9498,
				"gross_profit_cents": 3598,
				"reputation_score": 95,
			}
		],
		"reputation_score": 95,
		"inventory_items": [
			{
				"instance_id": "item_used_star_trader_001",
				"current_price_cents": 2499,
				"cost_basis_cents": 900,
				"location_id": "shelf_slot_001",
			}
		],
	}

	assert_true(codec.restore_into_existing_scene(session, ledger, root, data))

	assert_eq(session.day_number, 3)
	assert_eq(session.get_day_phase(), StoreSession.DAY_PHASE_REPORT)
	assert_eq(session.get_cash_cents(), 44444)
	assert_true(session.is_day_closed)
	assert_eq(ledger.get_sale_count(), 1)
	assert_eq(ledger.get_total_revenue_cents(), 2499)
	assert_eq(session.get_pending_fixture_orders().size(), 1)
	assert_eq(session.get_pending_supplier_orders().size(), 1)
	assert_eq(session.get_preorder_deposits().size(), 1)
	assert_eq(session.get_total_preorder_deposit_cents(), 500)
	assert_eq(session.get_release_allocation_count(), 2)
	assert_eq(session.get_total_release_allocation_cost_cents(), 6400)
	assert_eq(session.get_launch_event_count(), 1)
	assert_eq(session.get_total_launch_revenue_cents(), 9498)
	assert_eq(session.get_total_launch_profit_cents(), 3598)
	assert_eq(session.get_reputation_score(), 95)
	assert_eq(item.get("current_price_cents"), 2499)
	assert_eq(item.get("location_id"), "shelf_slot_001")
