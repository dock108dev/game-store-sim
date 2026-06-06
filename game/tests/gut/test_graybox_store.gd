extends GutTest

const MAIN_SCENE := "res://scenes/world/graybox_store.tscn"

var _store: Node3D


func before_each() -> void:
	_store = load(MAIN_SCENE).instantiate()
	add_child_autofree(_store)


func test_main_scene_loads_graybox_store() -> void:
	assert_not_null(_store)
	assert_true(_store is Node3D)


func test_main_scene_has_expected_root_name() -> void:
	assert_eq(_store.name, "GrayboxStore")


func test_player_controller_exists() -> void:
	assert_not_null(_store.get_node_or_null("PlayerController"))


func test_player_starts_above_floor() -> void:
	var player := _store.get_node("PlayerController") as CharacterBody3D
	assert_gt(player.global_position.y, -0.01)


func test_floor_collision_is_enabled() -> void:
	var floor := _store.get_node("Floor") as CSGBox3D
	assert_true(floor.use_collision)


func test_front_door_opening_is_blocked_for_now() -> void:
	var blocker := _store.get_node_or_null("FrontDoorBlocker") as StaticBody3D
	assert_not_null(blocker)
	assert_false(blocker.visible)
	assert_almost_eq(blocker.global_position.z, -6.0, 0.01)

	var collision_shape := blocker.get_node_or_null("CollisionShape3D") as CollisionShape3D
	assert_not_null(collision_shape)
	assert_false(collision_shape.disabled)

	var shape := collision_shape.shape as BoxShape3D
	assert_not_null(shape)
	assert_gte(shape.size.x, 3.5)
	assert_gte(shape.size.y, 2.5)
	assert_gte(shape.size.z, 0.2)


func test_receiving_box_exists() -> void:
	assert_not_null(_store.get_node_or_null("ReceivingBox"))


func test_used_game_exists() -> void:
	assert_not_null(_store.get_node_or_null("ReceivingBox/PlaceholderUsedGame"))


func test_used_game_starts_in_receiving_box() -> void:
	var receiving_box := _store.get_node("ReceivingBox") as Node3D
	var item := receiving_box.get_node("PlaceholderUsedGame") as Node3D

	assert_eq(item.get_parent(), receiving_box)
	assert_eq(item.get("location_id"), "receiving_box_001")
	assert_gt(item.global_position.y, 0.15)


func test_receiving_box_has_multiple_items() -> void:
	var receiving_box := _store.get_node("ReceivingBox") as Node3D
	assert_not_null(receiving_box.get_node_or_null("PlaceholderUsedGame"))
	assert_not_null(receiving_box.get_node_or_null("PlaceholderUsedGame002"))
	assert_not_null(receiving_box.get_node_or_null("PlaceholderUsedGame003"))


func test_display_rack_slot_starts_empty() -> void:
	var slot := _store.get_node("GameDisplayRack/ShelfSlot001") as ShelfSlot
	assert_true(slot.is_available())
	assert_null(slot.get_occupied_item())


func test_display_rack_has_three_slots() -> void:
	assert_not_null(_store.get_node_or_null("GameDisplayRack/ShelfSlot001"))
	assert_not_null(_store.get_node_or_null("GameDisplayRack/ShelfSlot002"))
	assert_not_null(_store.get_node_or_null("GameDisplayRack/ShelfSlot003"))


func test_display_rack_slots_are_assigned_used_game_category() -> void:
	for slot_name in ["ShelfSlot001", "ShelfSlot002", "ShelfSlot003"]:
		var slot := _store.get_node("GameDisplayRack/%s" % slot_name) as ShelfSlot
		assert_eq(slot.get_accepted_category(), "used_game")


func test_display_rack_is_wall_aligned() -> void:
	var rack := _store.get_node("GameDisplayRack") as Node3D
	assert_almost_eq(rack.global_position.z, 5.62, 0.01)
	assert_gt(rack.global_position.x, -3.3)


func test_receiving_box_is_clear_of_corner() -> void:
	var receiving_box := _store.get_node("ReceivingBox") as Node3D
	assert_gt(receiving_box.global_position.x, -5.0)
	assert_lt(receiving_box.global_position.z, 4.1)


func test_backroom_floor_marker_stays_subtle() -> void:
	var backroom_zone := _store.get_node("BackroomZone") as CSGBox3D
	assert_lte(backroom_zone.size.y, 0.013)
	assert_lte(backroom_zone.size.x, 12.4)


func test_register_workstation_exists() -> void:
	assert_not_null(_store.get_node_or_null("RegisterWorkstation"))


func test_customer_manager_exists() -> void:
	assert_not_null(_store.get_node_or_null("CustomerManager"))


func test_customer_manager_has_two_buyers() -> void:
	var manager := _store.get_node("CustomerManager")
	assert_eq(manager.get_customers().size(), 2)


func test_trade_in_customer_exists_with_item() -> void:
	var customer := _store.get_node_or_null("TradeInCustomer") as SimpleTradeInCustomer
	assert_not_null(customer)
	assert_not_null(customer.get_trade_item())


func test_transaction_ledger_exists() -> void:
	assert_not_null(_store.get_node_or_null("TransactionLedger"))


func test_store_session_exists() -> void:
	assert_not_null(_store.get_node_or_null("StoreSession"))


func test_suspicious_event_log_exists() -> void:
	var event_log := _store.get_node_or_null("SuspiciousEventLog")
	assert_not_null(event_log)
	assert_eq(event_log.get_event_count(), 0)


func test_backroom_computer_exists() -> void:
	assert_not_null(_store.get_node_or_null("BackroomComputer"))


func test_fixture_placement_manager_exists_with_hidden_ghost() -> void:
	var manager := _store.get_node_or_null("FixturePlacementManager")
	assert_not_null(manager)
	assert_false(manager.is_ghost_visible())
	assert_not_null(_store.get_node_or_null("FixturePlacementManager/GhostRackPreview"))


func test_register_is_wired_to_customer_manager_ledger_and_session() -> void:
	var register := _store.get_node("RegisterWorkstation") as RegisterWorkstation
	var manager := register.get_node_or_null(register.customer_manager_path)
	var trade_customer := register.get_node_or_null(register.trade_in_customer_path)
	var receiving_box := register.get_node_or_null(register.receiving_box_path)
	var ledger := register.get_node_or_null(register.ledger_path) as TransactionLedger
	var session := register.get_node_or_null(register.store_session_path)

	assert_not_null(manager)
	assert_not_null(trade_customer)
	assert_not_null(receiving_box)
	assert_not_null(ledger)
	assert_not_null(session)


func test_store_session_is_wired_to_transaction_ledger() -> void:
	var session := _store.get_node("StoreSession")
	var ledger := session.get_node_or_null(session.get("ledger_path")) as TransactionLedger

	assert_not_null(ledger)


func test_store_session_is_wired_to_inventory_root() -> void:
	var session := _store.get_node("StoreSession")
	assert_eq(session.get_node_or_null(session.get("inventory_root_path")), _store)
	assert_gt(session.get_active_inventory_items().size(), 0)


func test_store_session_is_wired_to_fixture_placement_manager() -> void:
	var session := _store.get_node("StoreSession")
	var manager := session.get_node_or_null(session.get("fixture_placement_manager_path"))

	assert_not_null(manager)


func test_fixture_order_shows_placement_ghost() -> void:
	var session := _store.get_node("StoreSession")
	var manager := _store.get_node("FixturePlacementManager")

	var order: Dictionary = session.order_fixture("fixture_game_display_rack")

	assert_false(order.is_empty())
	assert_true(manager.is_ghost_visible())
	assert_eq(manager.get_current_order_id(), order.get("order_id"))
	assert_eq(manager.get_current_fixture_id(), "fixture_game_display_rack")
	assert_eq(manager.get_placement_state(), "valid")


func test_fixture_placement_ghost_marks_invalid_out_of_bounds_position() -> void:
	var session := _store.get_node("StoreSession")
	var manager := _store.get_node("FixturePlacementManager")
	session.order_fixture("fixture_game_display_rack")

	assert_false(manager.set_ghost_position(Vector3(99.0, 0.04, 2.15)))

	assert_eq(manager.get_placement_state(), "invalid")
	assert_false(manager.is_current_position_valid())


func test_fixture_placement_ghost_supports_rotation_and_grid_movement() -> void:
	var session := _store.get_node("StoreSession")
	var manager := _store.get_node("FixturePlacementManager")
	session.order_fixture("fixture_game_display_rack")

	assert_true(manager.rotate_ghost())
	assert_true(manager.move_ghost_by_grid(1, 1))

	assert_almost_eq(manager.get_ghost_rotation_y(), deg_to_rad(90.0), 0.001)
	assert_eq(manager.get_placement_state(), "valid")


func test_backroom_computer_is_wired_to_store_session() -> void:
	var computer := _store.get_node("BackroomComputer")
	var session := computer.get_node_or_null(computer.get("store_session_path"))

	assert_not_null(session)


func test_customer_manager_targets_display_slots() -> void:
	var manager := _store.get_node("CustomerManager")
	for slot_path in manager.get("display_slot_paths"):
		var slot := manager.get_node_or_null(slot_path) as ShelfSlot
		assert_not_null(slot)


func test_customer_manager_paths_validate_inside_store() -> void:
	var manager := _store.get_node("CustomerManager")
	assert_eq(manager.validate_customer_paths(), [])


func test_no_standalone_pricing_workstation_exists() -> void:
	assert_null(_store.get_node_or_null("PricingWorkstation"))


func test_no_standalone_price_register_exists() -> void:
	assert_null(_store.get_node_or_null("PricingRegister"))


func test_game_display_rack_exists() -> void:
	assert_not_null(_store.get_node_or_null("GameDisplayRack"))
