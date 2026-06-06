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


static func get_price_limit_multiplier(product: ProductDefinition) -> float:
	if product == null:
		return 0.0

	return get_tier_multiplier(product.demand_tier) * get_category_multiplier(product.category)


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


static func get_summary_text() -> String:
	return "\n".join(get_summary_lines())


static func _normalize_category(category: String) -> String:
	return category.strip_edges().to_lower()
