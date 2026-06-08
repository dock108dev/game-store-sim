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
		"footprint_size": Vector2(2.4, 0.6),
	}

	assert_true(manager.show_ghost_for_order(order))

	assert_true(manager.is_ghost_visible())
	assert_eq(manager.get_current_order_id(), "fixture_order_001")
	assert_eq(manager.get_current_fixture_id(), "fixture_game_display_rack")
	assert_eq(manager.get_ghost_position(), manager.get("default_ghost_position"))
	assert_eq(manager.get_placement_state(), "valid")
	assert_true(manager.is_current_position_valid())
	assert_string_contains(manager.get_placement_summary_text(), "footprint 2.40x0.60")


func test_fixture_placement_manager_marks_out_of_bounds_ghost_invalid() -> void:
	var manager := _make_manager()
	manager.show_ghost_for_order({
		"order_id": "fixture_order_001",
		"fixture_id": "fixture_game_display_rack",
		"footprint_size": Vector2(2.4, 0.6),
	})

	assert_false(manager.set_ghost_position(Vector3(5.4, 0.04, 2.15)))

	assert_eq(manager.get_placement_state(), "invalid")
	assert_eq(manager.get_placement_issue(), "out_of_bounds")
	assert_false(manager.is_current_position_valid())


func test_fixture_placement_manager_blocks_critical_path_points() -> void:
	var manager := _make_manager()
	manager.path_clearance_points = PackedVector3Array([Vector3(-0.8, 0.04, 2.15)])
	manager.show_ghost_for_order({
		"order_id": "fixture_order_001",
		"fixture_id": "fixture_game_display_rack",
		"footprint_size": Vector2(2.4, 0.6),
	})

	assert_eq(manager.get_placement_state(), "invalid")
	assert_eq(manager.get_placement_issue(), "path_blocked")
	assert_string_contains(manager.get_placement_summary_text(), "path_blocked")


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


func test_fixture_placement_manager_snaps_ghost_to_grid() -> void:
	var manager := _make_manager()
	manager.show_ghost_for_order({
		"order_id": "fixture_order_001",
		"fixture_id": "fixture_game_display_rack",
	})
	manager.set_ghost_position(Vector3(-0.73, 0.04, 2.13))

	assert_true(manager.snap_ghost_to_grid())

	var position: Vector3 = manager.get_ghost_position()
	assert_almost_eq(position.x, -0.75, 0.001)
	assert_almost_eq(position.z, 2.25, 0.001)
	assert_eq(manager.get_placement_state(), "valid")


func test_fixture_placement_manager_moves_ghost_by_grid() -> void:
	var manager := _make_manager()
	manager.show_ghost_for_order({
		"order_id": "fixture_order_001",
		"fixture_id": "fixture_game_display_rack",
	})

	assert_true(manager.move_ghost_by_grid(2, -1))

	var position: Vector3 = manager.get_ghost_position()
	assert_almost_eq(position.x, -0.25, 0.001)
	assert_almost_eq(position.z, 2.0, 0.001)


func test_fixture_placement_manager_undoes_adjustments() -> void:
	var manager := _make_manager()
	manager.show_ghost_for_order({
		"order_id": "fixture_order_001",
		"fixture_id": "fixture_game_display_rack",
	})
	var start_position: Vector3 = manager.get_ghost_position()
	assert_false(manager.can_undo_adjustment())

	assert_true(manager.move_ghost_by_grid(2, -1))
	assert_true(manager.can_undo_adjustment())
	assert_ne(manager.get_ghost_position(), start_position)

	assert_true(manager.undo_last_adjustment())

	assert_eq(manager.get_ghost_position(), start_position)
	assert_false(manager.can_undo_adjustment())


func test_fixture_placement_manager_rotates_ghost_by_fixed_step() -> void:
	var manager := _make_manager()
	manager.show_ghost_for_order({
		"order_id": "fixture_order_001",
		"fixture_id": "fixture_game_display_rack",
	})

	assert_true(manager.rotate_ghost())

	assert_almost_eq(manager.get_ghost_rotation_y(), deg_to_rad(90.0), 0.001)
	assert_eq(manager.get_placement_state(), "valid")


func test_fixture_placement_manager_counter_rotates_ghost() -> void:
	var manager := _make_manager()
	manager.show_ghost_for_order({
		"order_id": "fixture_order_001",
		"fixture_id": "fixture_game_display_rack",
	})
	manager.rotate_ghost()

	assert_true(manager.rotate_ghost(false))

	assert_almost_eq(manager.get_ghost_rotation_y(), 0.0, 0.001)


func test_fixture_placement_manager_rejects_overlapping_placed_fixture() -> void:
	var manager := _make_manager()
	var parent := Node3D.new()
	add_child_autofree(parent)
	manager.show_ghost_for_order({
		"order_id": "fixture_order_001",
		"fixture_id": "fixture_game_display_rack",
		"footprint_size": Vector2(2.4, 0.6),
	})
	var placed: Node3D = manager.confirm_current_placement(
		parent,
		"res://scenes/props/placeholder_shelf.tscn"
	)
	assert_not_null(placed)

	manager.show_ghost_for_order({
		"order_id": "fixture_order_002",
		"fixture_id": "fixture_game_display_rack",
		"footprint_size": Vector2(2.4, 0.6),
	})

	assert_eq(manager.get_placement_state(), "invalid")
	assert_eq(manager.get_placement_issue(), "overlap")


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


func test_fixture_placement_manager_cancels_current_placement() -> void:
	var manager := _make_manager()
	manager.show_ghost_for_order({
		"order_id": "fixture_order_001",
		"fixture_id": "fixture_game_display_rack",
	})

	var canceled: Dictionary = manager.cancel_current_placement()

	assert_eq(canceled.get("order_id"), "fixture_order_001")
	assert_eq(canceled.get("fixture_id"), "fixture_game_display_rack")
	assert_false(manager.is_ghost_visible())
	assert_eq(manager.get_current_order_id(), "")
	assert_eq(manager.get_current_fixture_id(), "")
	assert_eq(manager.get_placement_state(), "hidden")


func test_fixture_placement_manager_confirms_valid_placement() -> void:
	var manager := _make_manager()
	var parent := Node3D.new()
	add_child_autofree(parent)
	manager.show_ghost_for_order({
		"order_id": "fixture_order_001",
		"fixture_id": "fixture_game_display_rack",
	})
	manager.move_ghost_by_grid(1, 1)
	manager.rotate_ghost()
	var expected_position: Vector3 = manager.get_ghost_position()
	var expected_rotation_y: float = manager.get_ghost_rotation_y()

	var placed: Node3D = manager.confirm_current_placement(
		parent,
		"res://scenes/props/placeholder_shelf.tscn"
	)

	assert_not_null(placed)
	assert_eq(placed.get_parent(), parent)
	assert_eq(placed.name, "PlacedGameDisplayRack001")
	assert_almost_eq(placed.global_position.x, expected_position.x, 0.001)
	assert_almost_eq(placed.global_position.z, expected_position.z, 0.001)
	assert_almost_eq(placed.global_rotation.y, expected_rotation_y, 0.001)
	assert_false(manager.is_ghost_visible())
	assert_eq(manager.get_placement_state(), "hidden")
	assert_string_contains(manager.get_placement_summary_text(), "Last placed fixture_game_display_rack")


func test_fixture_placement_manager_rejects_invalid_confirmation() -> void:
	var manager := _make_manager()
	var parent := Node3D.new()
	add_child_autofree(parent)
	manager.show_ghost_for_order({
		"order_id": "fixture_order_001",
		"fixture_id": "fixture_game_display_rack",
	})
	manager.set_ghost_position(Vector3(99.0, 0.04, 2.15))

	var placed: Node3D = manager.confirm_current_placement(
		parent,
		"res://scenes/props/placeholder_shelf.tscn"
	)

	assert_null(placed)
	assert_true(manager.is_ghost_visible())
	assert_eq(manager.get_placement_state(), "invalid")
	assert_eq(parent.get_child_count(), 0)


func _make_manager() -> Node:
	var manager: Node = load("res://scripts/store_layout/fixture_placement_manager.gd").new()
	var ghost := Node3D.new()
	ghost.name = "GhostRackPreview"
	add_child_autofree(manager)
	manager.add_child(ghost)
	manager._ready()
	return manager
