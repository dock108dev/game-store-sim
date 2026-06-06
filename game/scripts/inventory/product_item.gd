extends "res://scripts/interaction/interactable.gd"

@export var product: ProductDefinition
@export var instance_id: String = ""
@export var current_price_cents: int = 0
@export var cost_basis_cents: int = 0
@export var location_id: String = "receiving_box_001"
@export var serial_id: String = ""
@export var expected_serial_id: String = ""
@export var suspicious_event_id: String = ""

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
	if cost_basis_cents <= 0:
		cost_basis_cents = product.cost_basis_cents


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


func has_serial_mismatch() -> bool:
	return not serial_id.strip_edges().is_empty() \
		and not expected_serial_id.strip_edges().is_empty() \
		and serial_id.strip_edges() != expected_serial_id.strip_edges()


func get_serial_status_text() -> String:
	if serial_id.strip_edges().is_empty():
		return "Serial untracked"

	if has_serial_mismatch():
		return "Serial mismatch %s expected %s" % [
			serial_id.strip_edges(),
			expected_serial_id.strip_edges(),
		]

	return "Serial %s" % serial_id.strip_edges()


func get_suspicious_event_id() -> String:
	if not suspicious_event_id.strip_edges().is_empty():
		return suspicious_event_id.strip_edges()

	if not instance_id.strip_edges().is_empty():
		return "serial_mismatch_%s" % instance_id.strip_edges()

	return "serial_mismatch_unknown_item"


func flag_serial_mismatch(event_log: Node) -> Dictionary:
	if not has_serial_mismatch():
		return {}

	if event_log == null or not event_log.has_method("flag_event"):
		return {}

	var product_id := ""
	var product_name := display_name
	if product != null:
		product_id = product.product_id
		product_name = product.display_name

	return event_log.flag_event(
		get_suspicious_event_id(),
		"Mismatched serial for %s" % product_name,
		"inventory",
		"medium",
		{
			"instance_id": instance_id,
			"product_id": product_id,
			"serial_id": serial_id.strip_edges(),
			"expected_serial_id": expected_serial_id.strip_edges(),
			"location_id": location_id,
		}
	)


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

	return "%s - Price $%0.2f - Location %s - %s" % [
		product.describe(),
		current_price_cents / 100.0,
		location_id,
		get_serial_status_text(),
	]


func _can_actor_pick_up(actor: Node) -> bool:
	if product == null:
		return false

	if location_id != "receiving_box_001":
		return false

	if actor == null or not actor.has_method("can_pick_up_item"):
		return false

	return actor.can_pick_up_item(self)
