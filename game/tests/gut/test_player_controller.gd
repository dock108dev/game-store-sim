extends GutTest

const PLAYER_SCENE := "res://scenes/player/player_controller.tscn"
const REQUIRED_ACTIONS := [
	"move_forward",
	"move_back",
	"move_left",
	"move_right",
	"interact",
]

var _player: CharacterBody3D


func before_each() -> void:
	_player = load(PLAYER_SCENE).instantiate()
	add_child_autofree(_player)


func test_player_scene_has_collision_shape() -> void:
	var shape := _player.get_node_or_null("CollisionShape3D") as CollisionShape3D
	assert_not_null(shape)
	assert_not_null(shape.shape)


func test_player_scene_has_current_camera() -> void:
	var camera := _player.get_node_or_null("Head/Camera3D") as Camera3D
	assert_not_null(camera)
	assert_true(camera.current)


func test_interaction_raycast_is_configured() -> void:
	var raycast := _player.get_node_or_null("Head/Camera3D/InteractionRaycast") as RayCast3D
	assert_not_null(raycast)
	assert_true(raycast.enabled)
	assert_true(raycast.collide_with_areas)
	assert_eq(raycast.target_position, Vector3(0, 0, -3))


func test_interaction_prompt_exists() -> void:
	assert_not_null(_player.get_node_or_null("InteractionPrompt"))


func test_keyboard_input_actions_exist() -> void:
	for action in REQUIRED_ACTIONS:
		assert_true(InputMap.has_action(action), "%s should exist" % action)


func test_keyboard_input_actions_have_events() -> void:
	for action in REQUIRED_ACTIONS:
		assert_gt(InputMap.action_get_events(action).size(), 0, "%s should have input events" % action)


func test_player_has_hold_anchor() -> void:
	var hold_anchor := _player.get_node_or_null("Head/Camera3D/HoldAnchor") as Node3D
	assert_not_null(hold_anchor)
	assert_lt(hold_anchor.position.z, 0.0)
	assert_gt(hold_anchor.position.x, 0.0)


func test_player_can_pick_up_item() -> void:
	var item: Node3D = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(item)

	assert_true(_player.pick_up_item(item))

	var hold_anchor := _player.get_node("Head/Camera3D/HoldAnchor") as Node3D
	var collision_shape := item.get_node("CollisionShape3D") as CollisionShape3D
	assert_eq(_player.get_held_item(), item)
	assert_eq(item.get_parent(), hold_anchor)
	assert_eq(item.get("location_id"), "held")
	assert_true(collision_shape.disabled)


func test_player_places_held_item_in_display_slot() -> void:
	var rack: Node3D = load("res://scenes/props/placeholder_shelf.tscn").instantiate()
	add_child_autofree(rack)
	var slot := rack.get_node("ShelfSlot001") as ShelfSlot

	var item: Node3D = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(item)

	assert_true(_player.pick_up_item(item))
	assert_true(_player.place_held_item(slot))

	var collision_shape := item.get_node("CollisionShape3D") as CollisionShape3D
	assert_null(_player.get_held_item())
	assert_eq(slot.get_occupied_item(), item)
	assert_eq(item.get("location_id"), "shelf_slot_001")
	assert_false(collision_shape.disabled)
