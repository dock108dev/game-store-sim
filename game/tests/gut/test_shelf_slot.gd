extends GutTest

var _shelf: Node3D
var _slot: ShelfSlot
var _item: Node3D


func before_each() -> void:
	_shelf = load("res://scenes/props/placeholder_shelf.tscn").instantiate()
	add_child_autofree(_shelf)
	_slot = _shelf.get_node_or_null("ShelfSlot001") as ShelfSlot
	_item = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(_item)


func test_shelf_slot_exists() -> void:
	assert_not_null(_slot)


func test_shelf_has_three_display_slots() -> void:
	assert_not_null(_shelf.get_node_or_null("ShelfSlot001"))
	assert_not_null(_shelf.get_node_or_null("ShelfSlot002"))
	assert_not_null(_shelf.get_node_or_null("ShelfSlot003"))


func test_shelf_slot_has_identity() -> void:
	assert_eq(_slot.slot_id, "shelf_slot_001")
	assert_eq(_slot.accepted_category, "used_game")
	assert_eq(_slot.get_accepted_category(), "used_game")
	assert_true(_slot.accepts_category("used_game"))
	assert_false(_slot.accepts_category("hardware"))


func test_shelf_slot_can_assign_category_when_empty() -> void:
	assert_true(_slot.assign_category("hardware"))

	assert_eq(_slot.get_accepted_category(), "hardware")
	assert_false(_slot.can_accept(_item))


func test_shelf_slot_rejects_empty_category_assignment() -> void:
	assert_false(_slot.assign_category(""))
	assert_false(_slot.assign_category("   "))

	assert_eq(_slot.get_accepted_category(), "used_game")


func test_shelf_slot_starts_available() -> void:
	assert_true(_slot.is_available())
	assert_null(_slot.get_occupied_item())
	assert_string_contains(_slot.get_slot_label(), "empty used_game slot")


func test_shelf_slot_marker_is_upright_display_bay() -> void:
	var marker := _slot.get_node("SlotMarker") as CSGBox3D
	assert_gt(marker.size.y, marker.size.x)
	assert_gt(marker.size.y, marker.size.z * 10.0)


func test_shelf_has_readable_used_game_category_header() -> void:
	var header_panel := _shelf.get_node_or_null("CategoryHeaderPanel") as CSGBox3D
	var header_label := _shelf.get_node_or_null("CategoryHeaderPanel/CategoryHeaderLabel") as Label3D

	assert_not_null(header_panel)
	assert_not_null(header_label)
	assert_false(header_panel.use_collision)
	assert_eq(header_label.text, "USED GAMES")
	assert_gte(header_label.font_size, 30)
	assert_lt(header_panel.global_position.y, 1.7)


func test_shelf_has_alpha_profile_cues_for_angled_fixture_screenshots() -> void:
	var front_face := _shelf.get_node_or_null("FrontFaceCue") as CSGBox3D
	var left_stripe := _shelf.get_node_or_null("LeftProfileStripe") as CSGBox3D
	var right_stripe := _shelf.get_node_or_null("RightProfileStripe") as CSGBox3D

	assert_not_null(front_face)
	assert_not_null(left_stripe)
	assert_not_null(right_stripe)
	assert_false(front_face.use_collision)
	assert_false(left_stripe.use_collision)
	assert_false(right_stripe.use_collision)
	assert_gt(front_face.size.x, 1.4)
	assert_gt(front_face.size.y, 0.6)
	assert_lte(left_stripe.size.x, 0.04)
	assert_lte(right_stripe.size.x, 0.04)


func test_shelf_slots_have_compact_category_rails() -> void:
	for slot_name in ["ShelfSlot001", "ShelfSlot002", "ShelfSlot003"]:
		var slot := _shelf.get_node(slot_name) as Area3D
		var marker := slot.get_node("SlotMarker") as CSGBox3D
		var rail := slot.get_node_or_null("SlotCategoryRail") as CSGBox3D

		assert_not_null(rail)
		assert_false(rail.use_collision)
		assert_lt(rail.size.x, marker.size.x)
		assert_lte(rail.size.y, 0.04)
		assert_lte(absf(rail.position.x) + rail.size.x / 2.0, marker.size.x / 2.0)


func test_shelf_slot_hover_highlight_toggles_nonblocking_frame() -> void:
	var frame := _slot.get_node_or_null("SlotHoverFrame") as CSGBox3D

	assert_not_null(frame)
	assert_false(frame.use_collision)
	assert_false(frame.visible)
	assert_gte(frame.size.x, 0.66)
	assert_gte(frame.size.y, 0.8)
	var frame_material := frame.material as StandardMaterial3D
	assert_not_null(frame_material)
	assert_gte(frame_material.albedo_color.a, 0.55)
	assert_false(_slot.is_hovered())

	_slot.set_hovered(true)
	assert_true(_slot.is_hovered())
	assert_true(frame.visible)

	_slot.set_hovered(false)
	assert_false(_slot.is_hovered())
	assert_false(frame.visible)


func test_shelf_slot_accepts_used_game_when_empty() -> void:
	assert_true(_slot.can_accept(_item))


func test_shelf_slot_places_used_game() -> void:
	assert_true(_slot.place_item(_item))

	assert_false(_slot.is_available())
	assert_eq(_slot.get_occupied_item(), _item)
	assert_eq(_item.get_parent(), _slot)
	assert_eq(_item.get("location_id"), "shelf_slot_001")
	assert_almost_eq(_item.position.y, 0.0, 0.01)
	assert_almost_eq(_item.scale.x, 0.56, 0.001)
	assert_lt(_item.scale.x, 1.0)


func test_shelf_slot_rejects_item_when_occupied() -> void:
	var other_item: Node3D = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(other_item)

	assert_true(_slot.place_item(_item))
	assert_false(_slot.can_accept(other_item))
	assert_false(_slot.place_item(other_item))


func test_shelf_slot_rejects_category_assignment_when_occupied() -> void:
	assert_true(_slot.place_item(_item))

	assert_false(_slot.assign_category("hardware"))
	assert_eq(_slot.get_accepted_category(), "used_game")


func test_shelf_slot_stock_prompt_uses_held_item_name() -> void:
	var actor := _make_actor_with_held_item(_item)
	assert_eq(_slot.get_interaction_prompt_for_actor(actor), "Click Stock Star Trader")


func test_shelf_slot_rejects_wrong_category_with_clear_feedback() -> void:
	var hardware_item := _make_item_with_category("Controller Dock", "hardware")
	var actor := _make_actor_with_held_item(hardware_item)

	assert_false(_slot.can_accept(hardware_item))
	assert_eq(_slot.get_interaction_prompt_for_actor(actor), "Cannot Stock Controller Dock In used_game Slot")
	assert_eq(_slot.interact_with_actor(actor), "Cannot Stock Controller Dock In used_game Slot.")


func test_shelf_slot_inspects_occupied_item() -> void:
	_slot.place_item(_item)

	assert_eq(_slot.get_interaction_prompt(), "Click Inspect Star Trader")
	assert_string_contains(_slot.interact(), "Star Trader")
	assert_string_contains(_slot.interact(), "shelf_slot_001")


func test_shelf_slot_stocking_confirms_landing_slot() -> void:
	var actor := _PlacingActor.new()
	actor.held_item = _item
	add_child_autofree(actor)

	assert_eq(_slot.interact_with_actor(actor), "Stocked Star Trader in shelf_slot_001.")
	assert_eq(_slot.get_occupied_item(), _item)


func _make_actor_with_held_item(item: Node3D) -> Node:
	var actor := _HeldActor.new()
	actor.held_item = item
	add_child_autofree(actor)
	return actor


func _make_item_with_category(display_name: String, category: String) -> Node3D:
	var item: Node3D = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	var product := ProductDefinition.new()
	product.product_id = display_name.to_snake_case()
	product.display_name = display_name
	product.category = category
	product.platform = "Test"
	product.condition = "used"
	product.completeness = "loose"
	product.cost_basis_cents = 100
	product.market_value_cents = 200
	product.suggested_price_cents = 300
	item.set("product", product)
	add_child_autofree(item)
	return item


class _HeldActor:
	extends Node

	var held_item: Node3D = null

	func get_held_item() -> Node3D:
		return held_item


class _PlacingActor:
	extends Node

	var held_item: Node3D = null

	func get_held_item() -> Node3D:
		return held_item

	func place_held_item(slot: Node) -> bool:
		if held_item == null or not slot.has_method("place_item"):
			return false

		return slot.place_item(held_item)
