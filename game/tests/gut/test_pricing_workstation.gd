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


func test_pricing_workstation_rejects_fixed_price_item() -> void:
	var fixed_price_item := _make_fixed_price_item()
	add_child_autofree(fixed_price_item)

	var actor := _PricingActor.new()
	actor.held_item = fixed_price_item
	add_child_autofree(actor)

	assert_eq(_workstation.get_interaction_prompt_for_actor(actor), "Fixed Price Item")
	assert_string_contains(_workstation.interact_with_actor(actor), "fixed price")
	assert_eq(actor.open_count, 0)


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
	var printer_mesh := _workstation.get_node("LabelPrinterMesh") as MeshInstance3D
	var touch_pad_mesh := _workstation.get_node("TouchPadMesh") as MeshInstance3D
	var label_mesh := _workstation.get_node("PriceLabelMesh") as MeshInstance3D

	var base_top: float = base_mesh.position.y + (base_mesh.mesh.size.y / 2.0)
	var printer_bottom: float = printer_mesh.position.y - (printer_mesh.mesh.size.y / 2.0)
	var touch_pad_bottom: float = touch_pad_mesh.position.y - (touch_pad_mesh.mesh.size.y / 2.0)
	var label_bottom: float = label_mesh.position.y - (label_mesh.mesh.size.y / 2.0)

	assert_almost_eq(printer_bottom, base_top, 0.08)
	assert_gte(touch_pad_bottom, base_top - 0.03)
	assert_gte(label_bottom, base_top - 0.03)


func test_pricing_workstation_is_not_register_silhouette() -> void:
	var base_mesh := _workstation.get_node("BaseMesh") as MeshInstance3D
	var touch_pad_mesh := _workstation.get_node("TouchPadMesh") as MeshInstance3D

	assert_gt(base_mesh.mesh.size.x, base_mesh.mesh.size.z)
	assert_lt(touch_pad_mesh.position.y, 0.25)
	assert_true(_workstation.get_node_or_null("ScreenPostMesh") == null)
	assert_true(_workstation.get_node_or_null("ScreenMesh") == null)


func _make_fixed_price_item() -> Node3D:
	var item: Node3D = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	var product := ProductDefinition.new()
	product.product_id = "new_orbit_racer"
	product.display_name = "New Orbit Racer"
	product.category = "new_game"
	product.platform = "Orbit 64"
	product.condition = "new"
	product.completeness = "sealed"
	product.cost_basis_cents = 3200
	product.market_value_cents = 5999
	product.suggested_price_cents = 5999
	product.player_priceable = false
	item.set("product", product)
	item.set("current_price_cents", 5999)
	return item


class _PricingActor:
	extends Node

	var held_item: Node3D = null
	var open_count: int = 0

	func get_held_item() -> Node3D:
		return held_item

	func open_pricing_for_held_item() -> String:
		open_count += 1
		return ""
