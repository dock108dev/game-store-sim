extends GutTest


func test_fixture_placement_manager_starts_with_hidden_ghost() -> void:
	var manager := _make_manager()

	assert_false(manager.is_ghost_visible())
	assert_eq(manager.get_current_order_id(), "")
	assert_eq(manager.get_current_fixture_id(), "")
	assert_eq(manager.get_placement_state(), "hidden")


func test_fixture_placement_manager_shows_ghost_for_order() -> void:
	var manager := _make_manager()
	var order := {
		"order_id": "fixture_order_001",
		"fixture_id": "fixture_game_display_rack",
	}

	assert_true(manager.show_ghost_for_order(order))

	assert_true(manager.is_ghost_visible())
	assert_eq(manager.get_current_order_id(), "fixture_order_001")
	assert_eq(manager.get_current_fixture_id(), "fixture_game_display_rack")
	assert_eq(manager.get_ghost_position(), manager.get("default_ghost_position"))
	assert_eq(manager.get_placement_state(), "valid")
	assert_true(manager.is_current_position_valid())


func test_fixture_placement_manager_marks_out_of_bounds_ghost_invalid() -> void:
	var manager := _make_manager()
	manager.show_ghost_for_order({
		"order_id": "fixture_order_001",
		"fixture_id": "fixture_game_display_rack",
	})

	assert_false(manager.set_ghost_position(Vector3(99.0, 0.04, 2.15)))

	assert_eq(manager.get_placement_state(), "invalid")
	assert_false(manager.is_current_position_valid())


func test_fixture_placement_manager_applies_valid_and_invalid_materials() -> void:
	var manager := _make_manager()
	var valid_material := StandardMaterial3D.new()
	var invalid_material := StandardMaterial3D.new()
	manager.set("valid_placement_material", valid_material)
	manager.set("invalid_placement_material", invalid_material)

	var panel := CSGBox3D.new()
	panel.name = "Panel"
	manager.get_node("GhostRackPreview").add_child(panel)

	manager.show_ghost_for_order({
		"order_id": "fixture_order_001",
		"fixture_id": "fixture_game_display_rack",
	})

	assert_eq(panel.material, valid_material)

	manager.set_ghost_position(Vector3(99.0, 0.04, 2.15))

	assert_eq(panel.material, invalid_material)


func test_fixture_placement_manager_hides_ghost() -> void:
	var manager := _make_manager()
	manager.show_ghost_for_order({
		"order_id": "fixture_order_001",
		"fixture_id": "fixture_game_display_rack",
	})

	manager.hide_ghost()

	assert_false(manager.is_ghost_visible())
	assert_eq(manager.get_current_order_id(), "")
	assert_eq(manager.get_current_fixture_id(), "")
	assert_eq(manager.get_placement_state(), "hidden")


func _make_manager() -> Node:
	var manager: Node = load("res://scripts/store_layout/fixture_placement_manager.gd").new()
	var ghost := Node3D.new()
	ghost.name = "GhostRackPreview"
	add_child_autofree(manager)
	manager.add_child(ghost)
	manager._ready()
	return manager
