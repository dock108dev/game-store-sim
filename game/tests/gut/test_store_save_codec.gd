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
	session.order_fixture("fixture_game_display_rack")
	session.order_supplier_lot("supplier_lot_used_games_001")
	item.set("current_price_cents", 2399)
	item.set("location_id", "shelf_slot_001")

	var data: Dictionary = codec.create_save_data(session)

	assert_eq(data.get("version"), 1)
	assert_eq(data.get("day_number"), 1)
	assert_eq(data.get("cash_cents"), 36999)
	assert_eq((data.get("transactions") as Array).size(), 1)
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
		"cash_cents": 61234,
		"is_day_closed": true,
		"transactions": [{"transaction_id": "sale_001", "type": "sale"}],
		"fixture_orders": [{"fixture_id": "fixture_game_display_rack", "status": "pending_placement"}],
		"supplier_orders": [{"lot_id": "supplier_lot_used_games_001", "status": "pending_delivery"}],
		"inventory_items": [{"instance_id": "item_001", "location_id": "held"}],
	}

	var json_text: String = codec.encode_to_json(data)
	var decoded: Dictionary = codec.decode_from_json(json_text)

	assert_eq(int(decoded.get("version")), 1)
	assert_eq(int(decoded.get("day_number")), 2)
	assert_eq(int(decoded.get("cash_cents")), 61234)
	assert_true(decoded.get("is_day_closed"))
	assert_eq((decoded.get("transactions") as Array).size(), 1)
	assert_eq((decoded.get("fixture_orders") as Array)[0].get("fixture_id"), "fixture_game_display_rack")
	assert_eq((decoded.get("supplier_orders") as Array)[0].get("lot_id"), "supplier_lot_used_games_001")
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
	assert_eq(session.get_cash_cents(), 44444)
	assert_true(session.is_day_closed)
	assert_eq(ledger.get_sale_count(), 1)
	assert_eq(ledger.get_total_revenue_cents(), 2499)
	assert_eq(session.get_pending_fixture_orders().size(), 1)
	assert_eq(session.get_pending_supplier_orders().size(), 1)
	assert_eq(item.get("current_price_cents"), 2499)
	assert_eq(item.get("location_id"), "shelf_slot_001")
