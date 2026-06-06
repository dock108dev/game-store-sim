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


func test_shelf_slot_has_identity() -> void:
	assert_eq(_slot.slot_id, "shelf_slot_001")
	assert_eq(_slot.accepted_category, "used_game")


func test_shelf_slot_starts_available() -> void:
	assert_true(_slot.is_available())
	assert_null(_slot.get_occupied_item())
	assert_string_contains(_slot.get_slot_label(), "empty used_game slot")


func test_shelf_slot_marker_is_upright_display_bay() -> void:
	var marker := _slot.get_node("SlotMarker") as CSGBox3D
	assert_gt(marker.size.y, marker.size.x)
	assert_gt(marker.size.y, marker.size.z * 10.0)


func test_shelf_slot_accepts_used_game_when_empty() -> void:
	assert_true(_slot.can_accept(_item))


func test_shelf_slot_places_used_game() -> void:
	assert_true(_slot.place_item(_item))

	assert_false(_slot.is_available())
	assert_eq(_slot.get_occupied_item(), _item)
	assert_eq(_item.get_parent(), _slot)
	assert_eq(_item.get("location_id"), "shelf_slot_001")
	assert_almost_eq(_item.position.y, 0.0, 0.01)


func test_shelf_slot_rejects_item_when_occupied() -> void:
	var other_item: Node3D = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(other_item)

	assert_true(_slot.place_item(_item))
	assert_false(_slot.can_accept(other_item))
	assert_false(_slot.place_item(other_item))


func test_shelf_slot_stock_prompt_uses_held_item_name() -> void:
	var actor := _make_actor_with_held_item(_item)
	assert_eq(_slot.get_interaction_prompt_for_actor(actor), "E Stock Star Trader")


func test_shelf_slot_inspects_occupied_item() -> void:
	_slot.place_item(_item)

	assert_eq(_slot.get_interaction_prompt(), "E Inspect Star Trader")
	assert_string_contains(_slot.interact(), "Star Trader")
	assert_string_contains(_slot.interact(), "shelf_slot_001")


func _make_actor_with_held_item(item: Node3D) -> Node:
	var actor := _HeldActor.new()
	actor.held_item = item
	add_child_autofree(actor)
	return actor


class _HeldActor:
	extends Node

	var held_item: Node3D = null

	func get_held_item() -> Node3D:
		return held_item
