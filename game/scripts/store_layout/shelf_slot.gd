extends Area3D
class_name ShelfSlot

@export var slot_id: String = "shelf_slot_001"
@export var accepted_category: String = "used_game"
@export var occupied_item_path: NodePath


func is_available() -> bool:
	return occupied_item_path.is_empty()


func get_occupied_item() -> Node:
	if occupied_item_path.is_empty():
		return null

	return get_node_or_null(occupied_item_path)


func get_slot_label() -> String:
	if is_available():
		return "%s empty %s slot" % [slot_id, accepted_category]

	var item := get_occupied_item()
	if item != null:
		var item_name := str(item.get("display_name"))
		if not item_name.is_empty():
			return "%s stocked with %s" % [slot_id, item_name]

	return "%s occupied" % slot_id
