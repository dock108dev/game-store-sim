extends Resource
class_name CategoryDemand

const CATEGORY_DEMAND := {
	"used_game": {
		"label": "Used games",
		"multiplier": 1.0,
	},
	"new_game": {
		"label": "New games",
		"multiplier": 0.9,
	},
	"hardware": {
		"label": "Hardware",
		"multiplier": 0.8,
	},
}

const TIER_MULTIPLIERS := {
	"high": 1.15,
	"medium": 1.05,
	"low": 0.95,
}
const RARITY_MULTIPLIERS := {
	"common": 1.0,
	"uncommon": 1.04,
	"rare": 1.10,
	"collector": 1.18,
	"launch": 1.15,
}
const SHELF_VISIBILITY_MULTIPLIERS := {
	"front": 1.10,
	"endcap": 1.15,
	"standard": 1.0,
	"low": 0.92,
	"backroom": 0.75,
}
const MARKETING_MULTIPLIERS := {
	"none": 1.0,
	"staff_pick": 1.08,
	"sale_tag": 1.06,
	"featured": 1.12,
}
const EVENT_MULTIPLIERS := {
	"normal": 1.0,
	"weekend": 1.07,
	"launch_day": 1.18,
	"rainy_day": 0.96,
}
const ARCHETYPE_MULTIPLIERS := {
	"browser": 0.96,
	"target_buyer": 1.08,
	"collector": 1.14,
	"parent_gift_buyer": 1.04,
	"regular": 1.02,
}


static func get_category_multiplier(category: String) -> float:
	var normalized_category := _normalize_category(category)
	if CATEGORY_DEMAND.has(normalized_category):
		return float(CATEGORY_DEMAND[normalized_category].get("multiplier", 1.0))

	return 1.0


static func get_category_label(category: String) -> String:
	var normalized_category := _normalize_category(category)
	if CATEGORY_DEMAND.has(normalized_category):
		return str(CATEGORY_DEMAND[normalized_category].get("label", normalized_category))

	return normalized_category.capitalize()


static func get_tier_multiplier(demand_tier: String) -> float:
	var normalized_tier := demand_tier.strip_edges().to_lower()
	if TIER_MULTIPLIERS.has(normalized_tier):
		return float(TIER_MULTIPLIERS[normalized_tier])

	return float(TIER_MULTIPLIERS["medium"])


static func get_price_limit_multiplier(product: ProductDefinition, context: Dictionary = {}) -> float:
	if product == null:
		return 0.0

	if context.is_empty():
		return get_tier_multiplier(product.demand_tier) * get_category_multiplier(product.category)

	return get_contextual_demand_multiplier(product, context)


static func get_contextual_demand_multiplier(product: ProductDefinition, context: Dictionary = {}) -> float:
	if product == null:
		return 0.0

	var multiplier := get_tier_multiplier(product.demand_tier) * get_category_multiplier(product.category)
	multiplier *= _lookup_multiplier(RARITY_MULTIPLIERS, product.rarity, 1.0)
	multiplier *= _lookup_multiplier(SHELF_VISIBILITY_MULTIPLIERS, str(context.get("shelf_visibility", "standard")), 1.0)
	multiplier *= _lookup_multiplier(MARKETING_MULTIPLIERS, str(context.get("marketing", "none")), 1.0)
	multiplier *= _lookup_multiplier(EVENT_MULTIPLIERS, str(context.get("event", "normal")), 1.0)
	multiplier *= _lookup_multiplier(ARCHETYPE_MULTIPLIERS, str(context.get("customer_archetype", "regular")), 1.0)
	multiplier *= _get_price_pressure_multiplier(product, int(context.get("price_cents", 0)))
	return multiplier


static func get_context_summary_line(product: ProductDefinition, context: Dictionary = {}) -> String:
	if product == null:
		return "Demand tuning: no product"

	return "%s demand x%0.2f (%s, %s, %s, %s, %s)" % [
		product.display_name,
		get_contextual_demand_multiplier(product, context),
		str(context.get("shelf_visibility", "standard")),
		product.rarity,
		str(context.get("marketing", "none")),
		str(context.get("event", "normal")),
		str(context.get("customer_archetype", "regular")),
	]


static func get_summary_lines() -> Array[String]:
	var categories := CATEGORY_DEMAND.keys()
	categories.sort()

	var lines: Array[String] = ["Category demand:"]
	for category in categories:
		lines.append("%s x%0.2f" % [
			get_category_label(category),
			get_category_multiplier(category),
		])

	return lines


static func get_tuning_summary_text() -> String:
	return "Demand tuning signals: shelf visibility, price, rarity, marketing, events, and customer archetypes"


static func get_summary_text() -> String:
	return "\n".join(get_summary_lines())


static func _normalize_category(category: String) -> String:
	return category.strip_edges().to_lower()


static func _lookup_multiplier(table: Dictionary, key: String, fallback: float) -> float:
	var normalized_key := key.strip_edges().to_lower()
	if table.has(normalized_key):
		return float(table[normalized_key])
	return fallback


static func _get_price_pressure_multiplier(product: ProductDefinition, price_cents: int) -> float:
	var market_value := product.market_value_cents
	if market_value <= 0:
		market_value = product.suggested_price_cents
	if market_value <= 0 or price_cents <= 0:
		return 1.0

	var ratio := float(price_cents) / float(market_value)
	if ratio <= 0.90:
		return 1.08
	if ratio <= 1.00:
		return 1.03
	if ratio <= 1.20:
		return 0.95
	return 0.75
