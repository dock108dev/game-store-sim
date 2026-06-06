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


func test_used_game_exists() -> void:
	assert_not_null(_store.get_node_or_null("PlaceholderUsedGame"))


func test_register_workstation_exists() -> void:
	assert_not_null(_store.get_node_or_null("RegisterWorkstation"))


func test_shelf_exists() -> void:
	assert_not_null(_store.get_node_or_null("PlaceholderShelf"))
