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
	assert_eq(raycast.target_position, Vector3(0, 0, -3))


func test_interaction_prompt_exists() -> void:
	assert_not_null(_player.get_node_or_null("InteractionPrompt"))


func test_keyboard_input_actions_exist() -> void:
	for action in REQUIRED_ACTIONS:
		assert_true(InputMap.has_action(action), "%s should exist" % action)


func test_keyboard_input_actions_have_events() -> void:
	for action in REQUIRED_ACTIONS:
		assert_gt(InputMap.action_get_events(action).size(), 0, "%s should have input events" % action)
