extends GutTest

var _shelf: Node3D
var _slot: ShelfSlot


func before_each() -> void:
	_shelf = load("res://scenes/props/placeholder_shelf.tscn").instantiate()
	add_child_autofree(_shelf)
	_slot = _shelf.get_node_or_null("ShelfSlot001") as ShelfSlot


func test_shelf_slot_exists() -> void:
	assert_not_null(_slot)


func test_shelf_slot_has_identity() -> void:
	assert_eq(_slot.slot_id, "shelf_slot_001")
	assert_eq(_slot.accepted_category, "used_game")


func test_shelf_slot_starts_available() -> void:
	assert_true(_slot.is_available())
	assert_null(_slot.get_occupied_item())
	assert_string_contains(_slot.get_slot_label(), "empty used_game slot")
