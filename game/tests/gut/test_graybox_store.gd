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


func test_display_rack_slot_starts_empty() -> void:
	var slot := _store.get_node("GameDisplayRack/ShelfSlot001") as ShelfSlot
	assert_true(slot.is_available())
	assert_null(slot.get_occupied_item())


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


func test_no_standalone_pricing_workstation_exists() -> void:
	assert_null(_store.get_node_or_null("PricingWorkstation"))


func test_game_display_rack_exists() -> void:
	assert_not_null(_store.get_node_or_null("GameDisplayRack"))
