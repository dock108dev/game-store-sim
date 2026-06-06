extends "res://scripts/interaction/interactable.gd"
class_name PricingWorkstation


func get_interaction_prompt() -> String:
	return "Hold Item To Price"


func get_interaction_prompt_for_actor(actor: Node) -> String:
	var item := _get_actor_held_item(actor)
	if item == null:
		return "Hold Item To Price"

	if not _is_item_player_priceable(item):
		return "Fixed Price Item"

	return "E Price %s" % _get_item_display_name(item)


func interact() -> String:
	return "Hold an item at the pricing workstation to set a sale price."


func interact_with_actor(actor: Node) -> String:
	var item := _get_actor_held_item(actor)
	if item == null:
		return interact()

	if not _is_item_player_priceable(item):
		return "%s has a fixed price." % _get_item_display_name(item)

	if actor != null and actor.has_method("open_pricing_for_held_item"):
		return str(actor.open_pricing_for_held_item())

	return "Pricing panel unavailable."


func _get_actor_held_item(actor: Node) -> Node:
	if actor == null or not actor.has_method("get_held_item"):
		return null

	var item: Node = actor.get_held_item()
	if item == null:
		return null

	var product := item.get("product") as ProductDefinition
	if product == null:
		return null

	return item


func _is_item_player_priceable(item: Node) -> bool:
	var product := item.get("product") as ProductDefinition
	return product != null and product.player_priceable


func _get_item_display_name(item: Node) -> String:
	var product := item.get("product") as ProductDefinition
	if product != null and not product.display_name.is_empty():
		return product.display_name

	return item.name
