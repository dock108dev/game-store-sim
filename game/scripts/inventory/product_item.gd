extends "res://scripts/interaction/interactable.gd"

@export var product: ProductDefinition
@export var instance_id: String = ""
@export var current_price_cents: int = 0
@export var location_id: String = "receiving_box_001"

var _default_collision_layer: int = 1
var _default_collision_mask: int = 1


func _ready() -> void:
	_default_collision_layer = collision_layer
	_default_collision_mask = collision_mask

	if product == null:
		return

	display_name = product.display_name
	if current_price_cents <= 0:
		current_price_cents = product.suggested_price_cents


func get_interaction_prompt() -> String:
	return _get_inspect_prompt()


func get_interaction_prompt_for_actor(actor: Node) -> String:
	if _can_actor_pick_up(actor):
		return "E Pick Up %s" % product.display_name

	return _get_inspect_prompt()


func interact_with_actor(actor: Node) -> String:
	if _can_actor_pick_up(actor):
		if actor.pick_up_item(self):
			return "Picked up %s" % product.display_name

	return interact()


func set_held() -> void:
	location_id = "held"
	set_collision_enabled(false)


func set_stocked(slot_id: String) -> void:
	location_id = slot_id
	set_collision_enabled(true)


func set_customer_held(customer_id: String) -> void:
	location_id = "customer:%s" % customer_id
	set_collision_enabled(false)


func set_sold() -> void:
	location_id = "sold"
	set_collision_enabled(false)


func set_collision_enabled(is_enabled: bool) -> void:
	collision_layer = _default_collision_layer if is_enabled else 0
	collision_mask = _default_collision_mask if is_enabled else 0

	for child in find_children("*", "CollisionShape3D", true, false):
		var shape := child as CollisionShape3D
		shape.disabled = not is_enabled


func _get_inspect_prompt() -> String:
	if product == null:
		return super.get_interaction_prompt()

	return "E Inspect %s" % product.display_name


func interact() -> String:
	if product == null:
		return super.interact()

	return "%s - Price $%0.2f - Location %s" % [
		product.describe(),
		current_price_cents / 100.0,
		location_id,
	]


func _can_actor_pick_up(actor: Node) -> bool:
	if product == null:
		return false

	if location_id != "receiving_box_001":
		return false

	if actor == null or not actor.has_method("can_pick_up_item"):
		return false

	return actor.can_pick_up_item(self)
