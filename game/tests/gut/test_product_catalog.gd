extends GutTest

const PRODUCT_DIR := "res://data/products"
const FORBIDDEN_REAL_NAMES := [
	"mario",
	"zelda",
	"pokemon",
	"playstation",
	"xbox",
	"nintendo",
	"sega",
]


func test_product_catalog_contains_twelve_fictional_used_games() -> void:
	var products := _load_products()

	assert_eq(products.size(), 12)
	for product in products:
		assert_eq(product.category, "used_game")
		assert_true(product.player_priceable)
		assert_true(product.product_id.begins_with("used_"))
		assert_false(product.display_name.is_empty())
		assert_false(product.platform.is_empty())
		assert_false(product.condition.is_empty())
		assert_false(product.completeness.is_empty())
		assert_false(product.format.is_empty())
		assert_false(product.demand_tier.is_empty())
		assert_gt(product.market_value_cents, 0)
		assert_gt(product.suggested_price_cents, 0)
		assert_lte(product.suggested_price_cents, product.market_value_cents)
		_assert_fictional_name(product.display_name)


func test_product_catalog_has_unique_ids() -> void:
	var seen := {}
	for product in _load_products():
		assert_false(seen.has(product.product_id), "Duplicate product_id: %s" % product.product_id)
		seen[product.product_id] = true


func test_product_catalog_covers_platform_condition_and_demand_variety() -> void:
	var platforms := {}
	var conditions := {}
	var demand_tiers := {}
	for product in _load_products():
		platforms[product.platform] = true
		conditions[product.condition] = true
		demand_tiers[product.demand_tier] = true

	assert_gte(platforms.size(), 3)
	assert_gte(conditions.size(), 4)
	assert_true(demand_tiers.has("low"))
	assert_true(demand_tiers.has("medium"))
	assert_true(demand_tiers.has("high"))


func _load_products() -> Array[ProductDefinition]:
	var products: Array[ProductDefinition] = []
	var dir := DirAccess.open(PRODUCT_DIR)
	assert_not_null(dir)
	if dir == null:
		return products

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while not file_name.is_empty():
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var product := load("%s/%s" % [PRODUCT_DIR, file_name]) as ProductDefinition
			if product != null:
				products.append(product)
		file_name = dir.get_next()
	dir.list_dir_end()
	return products


func _assert_fictional_name(display_name: String) -> void:
	var normalized := display_name.to_lower()
	for forbidden in FORBIDDEN_REAL_NAMES:
		assert_false(
			normalized.contains(forbidden),
			"Product name should stay fictional: %s" % display_name
		)
