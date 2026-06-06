extends Area3D
class_name ShelfSlot

@export var slot_id: String = "shelf_slot_001"
@export var accepted_category: String = "used_game"
@export var occupied_item_path: NodePath
@export var placed_item_position: Vector3 = Vector3(0, 0, 0.02)
@export var placed_item_scale: Vector3 = Vector3(0.72, 0.72, 0.72)


func assign_category(category: String) -> bool:
	var normalized_category := category.strip_edges()
	if normalized_category.is_empty():
		return false

	if not is_available():
		return false

	accepted_category = normalized_category
	return true


func get_accepted_category() -> String:
	return accepted_category


func accepts_category(category: String) -> bool:
	return category == accepted_category


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


func can_accept(item: Node) -> bool:
	if not is_available():
		return false

	if item == null:
		return false

	var product := item.get("product") as ProductDefinition
	if product == null:
		return false

	return accepts_category(product.category)


func place_item(item: Node3D) -> bool:
	if not can_accept(item):
		return false

	var parent := item.get_parent()
	if parent != null:
		parent.remove_child(item)

	add_child(item)
	item.position = placed_item_position
	item.rotation = Vector3.ZERO
	item.scale = placed_item_scale
	occupied_item_path = get_path_to(item)

	if item.has_method("set_stocked"):
		item.set_stocked(slot_id)

	return true


func release_item() -> Node3D:
	var item := get_occupied_item() as Node3D
	if item == null:
		return null

	occupied_item_path = NodePath("")
	return item


func get_interaction_prompt() -> String:
	if is_available():
		return "Empty Game Display Slot"

	var item := get_occupied_item()
	if item != null and item.has_method("get_interaction_prompt"):
		return item.get_interaction_prompt()

	return "E Inspect Game Display Slot"


func get_interaction_prompt_for_actor(actor: Node) -> String:
	if actor != null and actor.has_method("get_held_item"):
		var held_item: Node = actor.get_held_item()
		if held_item != null and can_accept(held_item):
			return "E Stock %s" % _get_item_display_name(held_item)

	return get_interaction_prompt()


func interact() -> String:
	if is_available():
		return "%s is ready for a used game." % slot_id

	var item := get_occupied_item()
	if item != null and item.has_method("interact"):
		return item.interact()

	return get_slot_label()


func interact_with_actor(actor: Node) -> String:
	if actor != null and actor.has_method("place_held_item") and actor.place_held_item(self):
		var item := get_occupied_item()
		return "Stocked %s" % _get_item_display_name(item)

	return interact()


func _get_item_display_name(item: Node) -> String:
	if item == null:
		return "item"

	var product := item.get("product") as ProductDefinition
	if product != null and not product.display_name.is_empty():
		return product.display_name

	var item_name := str(item.get("display_name"))
	if not item_name.is_empty():
		return item_name

	return item.name
