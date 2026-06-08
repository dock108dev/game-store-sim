extends GutTest

const CategoryDemandPolicy := preload("res://scripts/economy/category_demand.gd")


func test_category_demand_has_default_category_multipliers() -> void:
	assert_eq(CategoryDemandPolicy.get_category_multiplier("used_game"), 1.0)
	assert_eq(CategoryDemandPolicy.get_category_multiplier("new_game"), 0.9)
	assert_eq(CategoryDemandPolicy.get_category_multiplier("hardware"), 0.8)
	assert_eq(CategoryDemandPolicy.get_category_multiplier("unknown_category"), 1.0)


func test_category_demand_normalizes_category_names() -> void:
	assert_eq(CategoryDemandPolicy.get_category_multiplier(" Used_Game "), 1.0)
	assert_eq(CategoryDemandPolicy.get_category_label("new_game"), "New games")
	assert_eq(CategoryDemandPolicy.get_category_label("unknown_category"), "Unknown Category")


func test_category_demand_combines_tier_and_category() -> void:
	var product := ProductDefinition.new()
	product.category = "new_game"
	product.demand_tier = "high"

	assert_almost_eq(CategoryDemandPolicy.get_price_limit_multiplier(product), 1.035, 0.001)

	product.category = "hardware"
	product.demand_tier = "low"
	assert_almost_eq(CategoryDemandPolicy.get_price_limit_multiplier(product), 0.76, 0.001)


func test_category_demand_context_connects_visibility_price_rarity_marketing_event_and_archetype() -> void:
	var product := ProductDefinition.new()
	product.product_id = "used_signal_sprout"
	product.display_name = "Signal Sprout"
	product.category = "used_game"
	product.demand_tier = "high"
	product.rarity = "collector"
	product.market_value_cents = 4000
	product.suggested_price_cents = 3800

	var base_multiplier := CategoryDemandPolicy.get_price_limit_multiplier(product)
	var tuned_multiplier := CategoryDemandPolicy.get_contextual_demand_multiplier(product, {
		"shelf_visibility": "endcap",
		"marketing": "staff_pick",
		"event": "weekend",
		"customer_archetype": "collector",
		"price_cents": 3600,
	})
	var overpriced_multiplier := CategoryDemandPolicy.get_contextual_demand_multiplier(product, {
		"shelf_visibility": "backroom",
		"marketing": "none",
		"event": "rainy_day",
		"customer_archetype": "browser",
		"price_cents": 5200,
	})

	assert_gt(tuned_multiplier, base_multiplier)
	assert_lt(overpriced_multiplier, base_multiplier)
	assert_string_contains(
		CategoryDemandPolicy.get_context_summary_line(product, {
			"shelf_visibility": "endcap",
			"marketing": "staff_pick",
			"event": "weekend",
			"customer_archetype": "collector",
			"layout": "efficient",
			"price_cents": 3600,
		}),
		"Signal Sprout demand x"
	)
	assert_string_contains(
		CategoryDemandPolicy.get_context_summary_line(product, {"layout": "impulse"}),
		"layout:impulse"
	)


func test_category_demand_layout_signal_changes_context_multiplier() -> void:
	var product := ProductDefinition.new()
	product.category = "used_game"
	product.demand_tier = "medium"
	product.rarity = "common"
	product.market_value_cents = 2500

	var efficient := CategoryDemandPolicy.get_contextual_demand_multiplier(product, {"layout": "efficient"})
	var crowded := CategoryDemandPolicy.get_contextual_demand_multiplier(product, {"layout": "crowded"})

	assert_gt(efficient, crowded)


func test_category_demand_summary_lists_categories() -> void:
	var summary := CategoryDemandPolicy.get_summary_text()

	assert_string_contains(summary, "Category demand:")
	assert_string_contains(summary, "Used games x1.00")
	assert_string_contains(summary, "New games x0.90")
	assert_string_contains(summary, "Hardware x0.80")


func test_category_demand_tuning_summary_lists_signals() -> void:
	var summary := CategoryDemandPolicy.get_tuning_summary_text()

	assert_string_contains(summary, "shelf visibility")
	assert_string_contains(summary, "price")
	assert_string_contains(summary, "rarity")
	assert_string_contains(summary, "marketing")
	assert_string_contains(summary, "events")
	assert_string_contains(summary, "customer archetypes")
	assert_string_contains(summary, "layout")
