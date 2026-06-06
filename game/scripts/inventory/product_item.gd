extends "res://scripts/interaction/interactable.gd"

@export var product: ProductDefinition
@export var instance_id: String = ""
@export var current_price_cents: int = 0
@export var location_id: String = "shelf_slot_001"


func _ready() -> void:
	if product == null:
		return

	display_name = product.display_name
	if current_price_cents <= 0:
		current_price_cents = product.suggested_price_cents


func get_interaction_prompt() -> String:
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
