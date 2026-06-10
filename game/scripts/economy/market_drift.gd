extends Resource
class_name MarketDrift

const CATEGORY_DAILY_RATES := {
	"used_game": 0.015,
	"new_game": -0.005,
	"hardware": 0.0,
}

const DEMAND_TIER_DAILY_RATES := {
	"high": 0.01,
	"medium": 0.0,
	"low": -0.01,
}

const MINIMUM_MARKET_MULTIPLIER := 0.25


static func get_daily_rate(product: ProductDefinition) -> float:
	if product == null:
		return 0.0

	return _get_category_daily_rate(product.category) + _get_tier_daily_rate(product.demand_tier)


static func get_adjusted_market_value_cents(product: ProductDefinition, day_number: int) -> int:
	if product == null:
		return 0

	var basis := product.market_value_cents
	if basis <= 0:
		basis = product.suggested_price_cents
	if basis <= 0:
		return 0

	var elapsed_days := maxi(0, day_number - 1)
	var multiplier := maxf(MINIMUM_MARKET_MULTIPLIER, 1.0 + (get_daily_rate(product) * elapsed_days))
	return maxi(1, int(round(basis * multiplier)))


static func get_delta_cents(product: ProductDefinition, day_number: int) -> int:
	if product == null:
		return 0

	return get_adjusted_market_value_cents(product, day_number) - product.market_value_cents


static func format_summary_for_products(products: Array, day_number: int) -> String:
	if products.is_empty():
		return "Market drift: no active inventory"

	var lines: Array[String] = ["Market drift day %d:" % day_number]
	var seen_product_ids := {}
	for product_value in products:
		var product := product_value as ProductDefinition
		if product == null or product.product_id.is_empty():
			continue
		if seen_product_ids.has(product.product_id):
			continue

		seen_product_ids[product.product_id] = true
		lines.append("%s %s -> %s (%s)" % [
			product.display_name,
			_format_money(product.market_value_cents),
			_format_money(get_adjusted_market_value_cents(product, day_number)),
			_format_delta(get_delta_cents(product, day_number)),
		])

	if lines.size() == 1:
		return "Market drift: no active inventory"

	return "\n".join(lines)


static func _get_category_daily_rate(category: String) -> float:
	var normalized_category := category.strip_edges().to_lower()
	if CATEGORY_DAILY_RATES.has(normalized_category):
		return float(CATEGORY_DAILY_RATES[normalized_category])

	return 0.0


static func _get_tier_daily_rate(demand_tier: String) -> float:
	var normalized_tier := demand_tier.strip_edges().to_lower()
	if DEMAND_TIER_DAILY_RATES.has(normalized_tier):
		return float(DEMAND_TIER_DAILY_RATES[normalized_tier])

	return 0.0


static func _format_delta(cents: int) -> String:
	if cents > 0:
		return "+%s" % _format_money(cents)

	return _format_money(cents)


static func _format_money(cents: int) -> String:
	return "$%0.2f" % (cents / 100.0)
