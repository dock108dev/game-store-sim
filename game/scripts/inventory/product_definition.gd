extends Resource
class_name ProductDefinition

@export var product_id: String = ""
@export var display_name: String = ""
@export var category: String = "used_game"
@export var platform: String = ""
@export var platform_family: String = ""
@export var condition: String = "good"
@export var completeness: String = "complete"
@export var format: String = "disc"
@export var authenticity: String = "verified"
@export var rarity: String = "common"
@export var demand_tier: String = "medium"
@export var cost_basis_cents: int = 0
@export var market_value_cents: int = 0
@export var suggested_price_cents: int = 0
@export var risk_level: String = "low"
@export var risk_tags: Array[String] = []
@export var default_location_id: String = "receiving_box_001"
@export var player_priceable: bool = false


func describe() -> String:
	var details := [
		display_name,
		platform,
		get_platform_family(),
		condition.capitalize(),
		completeness.capitalize(),
		rarity.capitalize(),
		"Demand %s" % demand_tier.capitalize(),
		"Cost $%0.2f" % (cost_basis_cents / 100.0),
		"Market $%0.2f" % (market_value_cents / 100.0),
		"Risk %s" % get_risk_summary(),
	]
	return " - ".join(details)


func get_platform_family() -> String:
	if not platform_family.strip_edges().is_empty():
		return platform_family.strip_edges()
	return platform.strip_edges()


func get_risk_summary() -> String:
	var parts: Array[String] = [risk_level.capitalize()]
	if authenticity != "verified":
		parts.append(authenticity.capitalize())
	if not risk_tags.is_empty():
		parts.append(", ".join(risk_tags))
	return " / ".join(parts)


func is_authentic() -> bool:
	return authenticity == "verified" or authenticity == "trusted"


func has_complete_inventory_schema() -> bool:
	return not product_id.strip_edges().is_empty() \
		and not display_name.strip_edges().is_empty() \
		and not category.strip_edges().is_empty() \
		and not platform.strip_edges().is_empty() \
		and not get_platform_family().is_empty() \
		and not condition.strip_edges().is_empty() \
		and not completeness.strip_edges().is_empty() \
		and not format.strip_edges().is_empty() \
		and not authenticity.strip_edges().is_empty() \
		and not rarity.strip_edges().is_empty() \
		and not demand_tier.strip_edges().is_empty() \
		and market_value_cents > 0 \
		and suggested_price_cents > 0 \
		and not risk_level.strip_edges().is_empty() \
		and not default_location_id.strip_edges().is_empty()


func get_schema_summary() -> Dictionary:
	return {
		"product_id": product_id,
		"display_name": display_name,
		"category": category,
		"platform": platform,
		"platform_family": get_platform_family(),
		"format": format,
		"condition": condition,
		"completeness": completeness,
		"authenticity": authenticity,
		"rarity": rarity,
		"demand_tier": demand_tier,
		"cost_basis_cents": cost_basis_cents,
		"market_value_cents": market_value_cents,
		"suggested_price_cents": suggested_price_cents,
		"risk_level": risk_level,
		"risk_tags": risk_tags.duplicate(),
		"default_location_id": default_location_id,
	}
