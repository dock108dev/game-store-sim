extends GutTest

var _workstation: PricingWorkstation
var _item: Node3D


func before_each() -> void:
	_workstation = load("res://scenes/props/pricing_workstation.tscn").instantiate()
	add_child_autofree(_workstation)
	_item = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(_item)


func test_pricing_workstation_is_interactable() -> void:
	assert_true(_workstation.has_method("get_interaction_prompt"))
	assert_true(_workstation.has_method("interact"))
	assert_string_contains(_workstation.get_interaction_prompt(), "Hold Item")
	assert_string_contains(_workstation.interact(), "set a sale price")


func test_pricing_workstation_prompt_prices_held_item() -> void:
	var actor := _PricingActor.new()
	actor.held_item = _item
	add_child_autofree(actor)

	assert_eq(_workstation.get_interaction_prompt_for_actor(actor), "E Price Star Trader")


func test_pricing_workstation_prompts_for_item_when_empty_handed() -> void:
	var actor := _PricingActor.new()
	add_child_autofree(actor)

	assert_eq(_workstation.get_interaction_prompt_for_actor(actor), "Hold Item To Price")
	assert_string_contains(_workstation.interact_with_actor(actor), "Hold an item")


func test_pricing_workstation_opens_actor_pricing_flow() -> void:
	var actor := _PricingActor.new()
	actor.held_item = _item
	add_child_autofree(actor)

	assert_eq(_workstation.interact_with_actor(actor), "")
	assert_eq(actor.open_count, 1)


func test_pricing_workstation_screen_has_visible_support() -> void:
	var base_mesh := _workstation.get_node("BaseMesh") as MeshInstance3D
	var post_mesh := _workstation.get_node("ScreenPostMesh") as MeshInstance3D
	var screen_mesh := _workstation.get_node("ScreenMesh") as MeshInstance3D

	var base_top: float = base_mesh.position.y + (base_mesh.mesh.size.y / 2.0)
	var post_bottom: float = post_mesh.position.y - (post_mesh.mesh.size.y / 2.0)
	var post_top: float = post_mesh.position.y + (post_mesh.mesh.size.y / 2.0)
	var screen_bottom: float = screen_mesh.position.y - (screen_mesh.mesh.size.y / 2.0)

	assert_almost_eq(post_bottom, base_top, 0.02)
	assert_gte(post_top, screen_bottom - 0.03)


class _PricingActor:
	extends Node

	var held_item: Node3D = null
	var open_count: int = 0

	func get_held_item() -> Node3D:
		return held_item

	func open_pricing_for_held_item() -> String:
		open_count += 1
		return ""
