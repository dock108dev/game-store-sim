extends GutTest


func test_register_workstation_is_interactable() -> void:
	var register: Node = load("res://scenes/props/register_workstation.tscn").instantiate()
	add_child_autofree(register)

	assert_true(register.has_method("get_interaction_prompt"))
	assert_true(register.has_method("interact"))
	assert_string_contains(register.get_interaction_prompt(), "Register Workstation")
	assert_string_contains(register.interact(), "Register placeholder")


func test_register_screen_has_visible_support() -> void:
	var register: Node3D = load("res://scenes/props/register_workstation.tscn").instantiate()
	add_child_autofree(register)

	var base_mesh := register.get_node("BaseMesh") as MeshInstance3D
	var post_mesh := register.get_node("ScreenPostMesh") as MeshInstance3D
	var screen_mesh := register.get_node("ScreenMesh") as MeshInstance3D

	var base_top: float = base_mesh.position.y + (base_mesh.mesh.size.y / 2.0)
	var post_bottom: float = post_mesh.position.y - (post_mesh.mesh.size.y / 2.0)
	var post_top: float = post_mesh.position.y + (post_mesh.mesh.size.y / 2.0)
	var screen_bottom: float = screen_mesh.position.y - (screen_mesh.mesh.size.y / 2.0)

	assert_almost_eq(post_bottom, base_top, 0.01)
	assert_gte(post_top, screen_bottom - 0.03)


func test_interactable_base_returns_prompt_and_inspect_text() -> void:
	var interactable: Node = load("res://scripts/interaction/interactable.gd").new()
	interactable.display_name = "Test Object"
	interactable.inspect_text = "Inspection result"
	add_child_autofree(interactable)

	assert_eq(interactable.get_interaction_prompt(), "E Inspect Test Object")
	assert_eq(interactable.interact(), "Inspection result")


func test_interaction_prompt_show_and_hide() -> void:
	var prompt: Node = load("res://scenes/ui/interaction_prompt.tscn").instantiate()
	add_child_autofree(prompt)

	prompt.show_prompt("E Inspect Test")
	assert_true(prompt.visible)
	assert_eq(prompt.label.text, "E Inspect Test")

	prompt.hide_prompt()
	assert_false(prompt.visible)


func test_interaction_raycast_ignores_empty_interaction_messages() -> void:
	var script: Script = load("res://scripts/interaction/interaction_raycast.gd")
	var raycast: RayCast3D = script.new()
	var prompt: Node = load("res://scenes/ui/interaction_prompt.tscn").instantiate()
	var interactable := _SilentInteractable.new()
	add_child_autofree(raycast)
	add_child_autofree(prompt)
	add_child_autofree(interactable)

	raycast._prompt = prompt
	raycast._current_interactable = interactable

	var event := InputEventAction.new()
	event.action = "interact"
	event.pressed = true
	raycast._unhandled_input(event)

	assert_false(prompt.visible)


func test_interaction_raycast_uses_held_item_fallback_prompt() -> void:
	var script: Script = load("res://scripts/interaction/interaction_raycast.gd")
	var raycast: RayCast3D = script.new()
	var prompt: Node = load("res://scenes/ui/interaction_prompt.tscn").instantiate()
	var actor := _HeldItemActor.new()
	add_child_autofree(actor)
	actor.add_child(raycast)
	add_child_autofree(prompt)

	raycast._prompt = prompt
	raycast._physics_process(0.016)

	assert_true(prompt.visible)
	assert_eq(prompt.label.text, "E Price Star Trader")

	var event := InputEventAction.new()
	event.action = "interact"
	event.pressed = true
	raycast._unhandled_input(event)

	assert_eq(actor.price_count, 1)


class _SilentInteractable:
	extends Node

	func get_interaction_prompt() -> String:
		return "E Silent"

	func interact() -> String:
		return ""


class _HeldItemActor:
	extends Node

	var price_count: int = 0

	func is_holding_item() -> bool:
		return true

	func get_held_item_interaction_prompt() -> String:
		return "E Price Star Trader"

	func interact_with_held_item() -> String:
		price_count += 1
		return ""
