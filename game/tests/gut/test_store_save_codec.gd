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
	session.record_reputation_event("pricing_high_star_trader", "Over-market pricing for Star Trader", "pricing", -3)
	session.purchase_upgrade("upgrade_signage_staff_picks")
	var preorder_transaction := ledger.record_preorder_deposit(
		"preorder_customer_001",
		load("res://data/releases/neon_skyline_launch.tres"),
		500
	)
	session.apply_preorder_deposit(preorder_transaction)
	session.commit_release_allocation("release_neon_skyline", 1)
	session.order_fixture("fixture_game_display_rack")
	session.order_supplier_lot("supplier_lot_used_games_001")
	session.start_service_ticket("disc_resurfacing")
	session.review_management_task("supplier_messages")
	session.apply_decoration("decor_wall_paint_savepoint_blue")
	session.record_hidden_thread_choice("document", "serial_mismatch_item_used_star_trader_003", {"surface_id": "serial_lookup"})
	item.set("current_price_cents", 2399)
	item.set("location_id", "shelf_slot_001")

	var data: Dictionary = codec.create_save_data(session)

	assert_eq(data.get("version"), 1)
	assert_eq(data.get("day_number"), 1)
	assert_eq(data.get("day_phase"), StoreSession.DAY_PHASE_CUSTOMER_HOURS)
	assert_eq(data.get("cash_cents"), 25299)
	assert_eq((data.get("transactions") as Array).size(), 2)
	assert_eq((data.get("receiving_batches") as Array).size(), 0)
	assert_eq((data.get("storage_movements") as Array).size(), 0)
	assert_eq((data.get("service_tickets") as Array).size(), 1)
	assert_eq((data.get("management_reviews") as Array).size(), 1)
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
	assert_eq((data.get("operating_expenses") as Array).size(), 0)
	assert_eq((data.get("reputation_events") as Array).size(), 2)
	assert_eq((data.get("purchased_upgrades") as Array).size(), 1)
	var purchased_decorations: Array = data.get("purchased_decorations")
	assert_eq(purchased_decorations.size(), 1)
	assert_eq(purchased_decorations[0].get("decoration_id"), "decor_wall_paint_savepoint_blue")
	var hidden_thread_choices: Array = data.get("hidden_thread_choices")
	assert_eq(hidden_thread_choices.size(), 1)
	assert_eq(hidden_thread_choices[0].get("choice_id"), "document")
	var hidden_thread_consequences: Array = data.get("hidden_thread_consequences")
	assert_eq(hidden_thread_consequences.size(), 1)
	assert_eq(hidden_thread_consequences[0].get("story_state"), "documented")
	assert_eq(data.get("hidden_supplier_access_score"), 50)
	assert_eq(data.get("hidden_customer_trust_score"), 51)
	assert_eq(data.get("hidden_inspection_risk_score"), 0)
	assert_eq(data.get("hidden_story_state"), "documented")
	assert_eq(data.get("reputation_score"), 98)
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
		"receiving_batches": [{"batch_id": "supplier_order_001", "status": "pending_receiving"}],
		"storage_movements": [{"movement_id": "storage_move_001", "action": "stored"}],
		"service_tickets": [{"ticket_id": "service_ticket_001", "status": "ready_for_pickup"}],
		"management_reviews": [{"review_id": "management_review_001", "task_id": "supplier_messages"}],
		"preorder_deposits": [{"release_id": "release_neon_skyline", "deposit_cents": 500}],
		"release_allocations": [{"release_id": "release_neon_skyline", "quantity": 1}],
		"launch_events": [{"release_id": "release_neon_skyline", "missed_demand": 2}],
		"operating_expenses": [{"expense_id": "rent_reserve", "amount_cents": 700}],
		"reputation_events": [{"event_id": "pricing_high_star_trader", "delta": -3}],
		"purchased_upgrades": [{"upgrade_id": "upgrade_signage_staff_picks"}],
		"purchased_decorations": [{"decoration_id": "decor_wall_paint_savepoint_blue"}],
		"hidden_thread_choices": [{"choice_record_id": "document_serial_mismatch_item_used_star_trader_003", "choice_id": "document"}],
		"hidden_thread_consequences": [{"consequence_id": "consequence_document_serial_mismatch_item_used_star_trader_003", "choice_id": "document"}],
		"hidden_supplier_access_score": 50,
		"hidden_customer_trust_score": 51,
		"hidden_inspection_risk_score": 0,
		"hidden_story_state": "documented",
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
	assert_eq((decoded.get("receiving_batches") as Array)[0].get("status"), "pending_receiving")
	assert_eq((decoded.get("storage_movements") as Array)[0].get("action"), "stored")
	assert_eq((decoded.get("service_tickets") as Array)[0].get("status"), "ready_for_pickup")
	assert_eq((decoded.get("management_reviews") as Array)[0].get("task_id"), "supplier_messages")
	assert_eq((decoded.get("preorder_deposits") as Array)[0].get("release_id"), "release_neon_skyline")
	assert_eq((decoded.get("release_allocations") as Array)[0].get("release_id"), "release_neon_skyline")
	assert_eq((decoded.get("launch_events") as Array)[0].get("release_id"), "release_neon_skyline")
	assert_eq((decoded.get("operating_expenses") as Array)[0].get("expense_id"), "rent_reserve")
	assert_eq((decoded.get("reputation_events") as Array)[0].get("event_id"), "pricing_high_star_trader")
	assert_eq((decoded.get("purchased_upgrades") as Array)[0].get("upgrade_id"), "upgrade_signage_staff_picks")
	assert_eq((decoded.get("purchased_decorations") as Array)[0].get("decoration_id"), "decor_wall_paint_savepoint_blue")
	assert_eq((decoded.get("hidden_thread_choices") as Array)[0].get("choice_id"), "document")
	assert_eq((decoded.get("hidden_thread_consequences") as Array)[0].get("choice_id"), "document")
	assert_eq(int(decoded.get("hidden_customer_trust_score")), 51)
	assert_eq(str(decoded.get("hidden_story_state")), "documented")
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
		"receiving_batches": [
			{
				"batch_id": "supplier_order_001",
				"order_id": "supplier_order_001",
				"display_name": "Used Game Starter Lot",
				"expected_count": 3,
				"received_count": 3,
				"box_status": "opened",
				"invoice_status": "checked",
				"invoice_variance": 0,
				"sorting_status": "waiting",
				"sort_destination": "unsorted",
				"status": "invoice_checked",
			}
		],
		"storage_movements": [
			{
				"movement_id": "storage_move_001",
				"action": "stored",
				"display_name": "Star Trader",
				"from_location": "receiving_box_001",
				"to_location": "backstock_shelf_001",
			}
		],
		"service_tickets": [
			{
				"ticket_id": "service_ticket_001",
				"service_id": "disc_resurfacing",
				"service_name": "Disc Resurfacing",
				"item_name": "Scratched Orbit Disc",
				"status": "ready_for_pickup",
				"progress_percent": 100,
			}
		],
		"management_reviews": [
			{
				"review_id": "management_review_001",
				"task_id": "supplier_messages",
				"label": "Supplier messages",
				"category": "records",
				"desk_id": "backroom_management_desk",
				"status": "reviewed",
				"reviewed_day": 3,
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
		"operating_expenses": [
			{
				"expense_id": "rent_reserve",
				"label": "Rent reserve",
				"amount_cents": 700,
				"day_number": 3,
				"status": "posted",
			}
		],
		"reputation_events": [
			{
				"event_id": "pricing_high_star_trader",
				"label": "Over-market pricing for Star Trader",
				"category": "pricing",
				"delta": -3,
				"day_number": 3,
				"reputation_score": 95,
			}
		],
		"purchased_upgrades": [
			{
				"upgrade_id": "upgrade_signage_staff_picks",
				"label": "Staff Picks Signage",
				"category": "signage",
				"cost_cents": 5000,
				"status": "purchased",
			},
			{
				"upgrade_id": "upgrade_backroom_storage",
				"label": "Backroom Storage Bay",
				"category": "storage",
				"cost_cents": 10000,
				"status": "purchased",
			},
			{
				"upgrade_id": "upgrade_store_expansion",
				"label": "Starter Store Expansion",
				"category": "expansion",
				"cost_cents": 30000,
				"status": "purchased",
			}
		],
		"purchased_decorations": [
			{
				"decoration_id": "decor_wall_paint_savepoint_blue",
				"label": "Savepoint Blue Wall Paint",
				"category": "wall_paint",
				"cost_cents": 4000,
				"status": "applied",
			}
		],
		"hidden_thread_choices": [
			{
				"choice_record_id": "document_serial_mismatch_item_used_star_trader_003",
				"choice_id": "document",
				"label": "Document evidence",
				"stance": "cautious",
				"subject_id": "serial_mismatch_item_used_star_trader_003",
				"recorded_day": 3,
			}
		],
		"hidden_thread_consequences": [
			{
				"consequence_id": "consequence_document_serial_mismatch_item_used_star_trader_003",
				"choice_record_id": "document_serial_mismatch_item_used_star_trader_003",
				"choice_id": "document",
				"label": "Documented evidence",
				"reputation_delta": 1,
				"customer_trust_delta": 1,
				"inspection_risk_delta": -1,
				"story_state": "documented",
			}
		],
		"hidden_supplier_access_score": 50,
		"hidden_customer_trust_score": 51,
		"hidden_inspection_risk_score": 0,
		"hidden_story_state": "documented",
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
	assert_eq(session.get_pending_receiving_batches().size(), 1)
	assert_eq(session.get_storage_movements().size(), 1)
	assert_eq(session.get_service_tickets().size(), 1)
	assert_eq(session.get_management_reviews().size(), 1)
	assert_true(session.has_decoration("decor_wall_paint_savepoint_blue"))
	assert_string_contains(session.get_receiving_workflow_summary_text(), "Invoice: checked expected 3 received 3 variance 0")
	assert_string_contains(session.get_storage_workflow_summary_text(), "Recent storage move: stored Star Trader")
	assert_string_contains(session.get_storage_workflow_summary_text(), "Capacity: 18 cases (store expansion)")
	assert_string_contains(session.get_service_bench_summary_text(), "ready_for_pickup 100%")
	assert_string_contains(session.get_management_desk_summary_text(), "Supplier messages - reviewed")
	assert_eq(session.get_preorder_deposits().size(), 1)
	assert_eq(session.get_total_preorder_deposit_cents(), 500)
	assert_eq(session.get_release_allocation_count(), 2)
	assert_eq(session.get_total_release_allocation_cost_cents(), 6400)
	assert_eq(session.get_launch_event_count(), 1)
	assert_eq(session.get_total_launch_revenue_cents(), 9498)
	assert_eq(session.get_total_launch_profit_cents(), 3598)
	assert_eq(session.get_operating_expenses_total_cents(), 700)
	assert_eq(session.get_reputation_events().size(), 1)
	assert_true(session.has_upgrade("upgrade_signage_staff_picks"))
	assert_true(session.has_store_expansion())
	assert_eq(session.get_hidden_thread_choice_records().size(), 1)
	assert_string_contains(session.get_hidden_thread_choice_summary_text(), "Document evidence")
	assert_eq(session.get_hidden_thread_consequence_events().size(), 1)
	assert_string_contains(session.get_hidden_consequence_summary_text(), "Documented evidence")
	assert_eq(session.customer_trust_score, 51)
	assert_eq(session.hidden_story_state, "documented")
	assert_eq(session.get_reputation_score(), 95)
	assert_eq(item.get("current_price_cents"), 2499)
	assert_eq(item.get("location_id"), "shelf_slot_001")
