extends GutTest

const MarketDriftPolicy := preload("res://scripts/economy/market_drift.gd")


func test_market_drift_keeps_day_one_market_value() -> void:
	var product := _make_product("used_game", "medium", 2499)

	assert_eq(MarketDriftPolicy.get_adjusted_market_value_cents(product, 1), 2499)


func test_market_drift_combines_category_and_demand_tier_rates() -> void:
	var product := _make_product("used_game", "high", 2000)

	assert_eq(MarketDriftPolicy.get_daily_rate(product), 0.025)
	assert_eq(MarketDriftPolicy.get_adjusted_market_value_cents(product, 2), 2050)


func test_market_drift_can_lower_low_demand_new_games() -> void:
	var product := _make_product("new_game", "low", 2000)

	assert_eq(MarketDriftPolicy.get_daily_rate(product), -0.015)
	assert_eq(MarketDriftPolicy.get_adjusted_market_value_cents(product, 3), 1940)


func test_market_drift_summary_deduplicates_products() -> void:
	var product := _make_product("used_game", "high", 2000)
	product.product_id = "used_star_trader"
	product.display_name = "Star Trader"

	var summary := MarketDriftPolicy.format_summary_for_products([product, product], 2)

	assert_string_contains(summary, "Market drift day 2:")
	assert_string_contains(summary, "Star Trader $20.00 -> $20.50 (+$0.50)")
	assert_eq(summary.count("Star Trader"), 1)


func _make_product(category: String, demand_tier: String, market_value_cents: int) -> ProductDefinition:
	var product := ProductDefinition.new()
	product.product_id = "%s_%s" % [category, demand_tier]
	product.display_name = "%s %s" % [category, demand_tier]
	product.category = category
	product.demand_tier = demand_tier
	product.market_value_cents = market_value_cents
	product.suggested_price_cents = market_value_cents
	return product
