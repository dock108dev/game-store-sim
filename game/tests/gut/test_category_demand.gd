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


func test_category_demand_summary_lists_categories() -> void:
	var summary := CategoryDemandPolicy.get_summary_text()

	assert_string_contains(summary, "Category demand:")
	assert_string_contains(summary, "Used games x1.00")
	assert_string_contains(summary, "New games x0.90")
	assert_string_contains(summary, "Hardware x0.80")
