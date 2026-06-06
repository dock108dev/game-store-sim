extends GutTest


func test_fixture_placement_manager_starts_with_hidden_ghost() -> void:
	var manager := _make_manager()

	assert_false(manager.is_ghost_visible())
	assert_eq(manager.get_current_order_id(), "")
	assert_eq(manager.get_current_fixture_id(), "")


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


func _make_manager() -> Node:
	var manager: Node = load("res://scripts/store_layout/fixture_placement_manager.gd").new()
	var ghost := Node3D.new()
	ghost.name = "GhostRackPreview"
	add_child_autofree(manager)
	manager.add_child(ghost)
	manager._ready()
	return manager
