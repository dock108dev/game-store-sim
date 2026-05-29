extends GutTest

const DRIVER_SCRIPT: GDScript = preload("res://game/scripts/automation/semantic_input_driver.gd")
const RAY_SCRIPT: GDScript = preload("res://game/scripts/player/interaction_ray.gd")


class MockInteractable:
	extends Interactable

	var interact_calls: int = 0
	var allowed: bool = true
	var disabled_copy: String = ""

	func can_interact(_actor: Node = null) -> bool:
		return allowed

	func get_disabled_reason(_actor: Node = null) -> String:
		return disabled_copy

	func interact(by: Node = null) -> void:
		interact_calls += 1
		super.interact(by)


class ObjectiveController:
	extends Node

	var rows: Array[Dictionary] = []

	func _ready() -> void:
		add_to_group("store_session_controller")

	func get_semantic_objective_targets() -> Array[Dictionary]:
		return rows.duplicate(true)


var _root: Node3D = null
var _driver = null
var _player: CharacterBody3D = null
var _camera: Camera3D = null
var _ray: Node = null


func before_each() -> void:
	InputFocus._reset_for_tests()
	InputFocus.push_context(InputFocus.CTX_STORE_GAMEPLAY)
	_root = Node3D.new()
	_root.name = "SemanticDriverFixture"
	add_child_autofree(_root)
	_driver = DRIVER_SCRIPT.new()
	_root.add_child(_driver)
	_setup_player()


func after_each() -> void:
	InputFocus._reset_for_tests()


func test_resolves_objective_before_name_fallback() -> void:
	var objective_target := _add_interactable("ObjectiveTarget", Vector3(0, 0, -2), "objective target")
	var fallback_target := _add_interactable("TalkToCustomer", Vector3(2, 0, -2), "talk to customer")
	var controller := ObjectiveController.new()
	controller.name = "StoreSessionController"
	controller.rows = [
		{
			"id": "talk_to_customer",
			"stage": "talk_to_customer",
			"target_path": "ObjectiveTarget",
			"prompt_display_name": "customer",
			"action_verb": "Talk",
		},
	]
	_root.add_child(controller)

	var resolved: Dictionary = _driver.resolve_target({
		"semantic_id": "talk_to_customer",
		"kind": "interactable",
		"fallback_names": ["talk to customer"],
	})

	assert_true(bool(resolved.get("ok", false)))
	assert_same(resolved.get("interactable"), objective_target)
	assert_ne(resolved.get("interactable"), fallback_target)


func test_reports_ambiguous_name_fallback() -> void:
	_add_interactable("AmbiguousA", Vector3(-1, 0, -2), "shared target")
	_add_interactable("AmbiguousB", Vector3(1, 0, -2), "shared target")

	var resolved: Dictionary = _driver.resolve_target({
		"kind": "interactable",
		"fallback_names": ["shared target"],
	})

	assert_false(bool(resolved.get("ok", true)))
	assert_string_contains(str(resolved.get("reason", "")), "ambiguous_target")


func test_move_and_aim_compute_player_pose() -> void:
	var target := _add_interactable("AimTarget", Vector3(0, 1.2, -2.0), "aim target")
	target.interactable_id = &"aim.target"
	_ray.set("ray_distance", 2.5)

	var moved: bool = _driver.move_to_target(&"aim.target", {"stand_distance": 1.6})
	var aimed: bool = _driver.aim_at_target(&"aim.target", {"stand_distance": 1.6})
	var resolved: Dictionary = _driver.get_last_resolved()
	var aim: Vector3 = resolved.get("aim_position", Vector3.ZERO) as Vector3
	var to_aim: Vector3 = (aim - _camera.global_position).normalized()
	var camera_forward: Vector3 = -_camera.global_transform.basis.z.normalized()

	assert_true(moved)
	assert_true(aimed)
	assert_lte(_camera.global_position.distance_to(aim), 2.5)
	assert_gt(camera_forward.dot(to_aim), 0.95)


func test_focus_sets_hovered_target() -> void:
	var target := _add_interactable("FocusTarget", Vector3(0, 1.0, -1.6), "focus target")
	target.interactable_id = &"focus.target"

	var ok: bool = await _driver.focus_target(
		&"focus.target",
		{"allow_direct_hover_seam": true}
	)

	assert_true(ok)
	assert_same(_ray.call("get_hovered_target"), target)


func test_interact_dispatches_through_interaction_ray() -> void:
	var target := _add_interactable("InteractTarget", Vector3(0, 1.0, -1.6), "interact target")
	target.interactable_id = &"interact.target"

	var ok: bool = await _driver.interact_target(
		&"interact.target",
		{"allow_direct_hover_seam": true}
	)

	assert_true(ok)
	assert_eq(target.interact_calls, 1)


func test_disabled_target_fails_before_dispatch() -> void:
	var target := _add_interactable("DisabledTarget", Vector3(0, 1.0, -1.6), "disabled target")
	target.interactable_id = &"disabled.target"
	target.allowed = false
	target.disabled_copy = "Not ready."

	var ok: bool = await _driver.interact_target(
		&"disabled.target",
		{"allow_direct_hover_seam": true}
	)

	assert_false(ok)
	assert_eq(target.interact_calls, 0)
	assert_string_contains(_driver.get_last_error(), "target_disabled")


func _setup_player() -> void:
	_player = CharacterBody3D.new()
	_player.name = "Player"
	_player.add_to_group("player")
	_root.add_child(_player)
	_camera = Camera3D.new()
	_camera.name = "StoreCamera"
	_camera.position = Vector3(0, 1.7, 0)
	_player.add_child(_camera)
	_ray = RAY_SCRIPT.new()
	_ray.name = "InteractionRay"
	_player.add_child(_ray)
	_ray.call("_apply_camera", _camera)


func _add_interactable(name: String, position: Vector3, display_name: String) -> MockInteractable:
	var target := MockInteractable.new()
	target.name = name
	target.display_name = display_name
	target.position = position
	target.add_child(_shape())
	_root.add_child(target)
	return target


func _shape() -> CollisionShape3D:
	var box := BoxShape3D.new()
	box.size = Vector3(1.0, 2.0, 1.0)
	var shape := CollisionShape3D.new()
	shape.shape = box
	return shape
