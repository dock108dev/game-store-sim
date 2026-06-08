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


func test_product_catalog_contains_expanded_fictional_products() -> void:
	var products := _load_products()

	assert_gte(products.size(), 30)
	for product in products:
		assert_false(product.display_name.is_empty())
		assert_false(product.category.is_empty())
		assert_false(product.platform.is_empty())
		assert_false(product.get_platform_family().is_empty())
		assert_false(product.condition.is_empty())
		assert_false(product.completeness.is_empty())
		assert_false(product.format.is_empty())
		assert_false(product.authenticity.is_empty())
		assert_false(product.rarity.is_empty())
		assert_false(product.demand_tier.is_empty())
		assert_gt(product.market_value_cents, 0)
		assert_gt(product.suggested_price_cents, 0)
		assert_lte(product.suggested_price_cents, product.market_value_cents)
		assert_false(product.risk_level.is_empty())
		assert_false(product.default_location_id.is_empty())
		assert_true(product.has_complete_inventory_schema())
		if product.category != "service":
			assert_true(product.player_priceable)
		_assert_fictional_name(product.display_name)


func test_product_catalog_has_unique_ids() -> void:
	var seen := {}
	for product in _load_products():
		assert_false(seen.has(product.product_id), "Duplicate product_id: %s" % product.product_id)
		seen[product.product_id] = true


func test_product_catalog_covers_category_platform_condition_format_and_demand_variety() -> void:
	var categories := {}
	var platforms := {}
	var platform_families := {}
	var conditions := {}
	var formats := {}
	var demand_tiers := {}
	for product in _load_products():
		categories[product.category] = true
		platforms[product.platform] = true
		platform_families[product.get_platform_family()] = true
		conditions[product.condition] = true
		formats[product.format] = true
		demand_tiers[product.demand_tier] = true

	assert_true(categories.has("used_game"))
	assert_true(categories.has("new_game"))
	assert_true(categories.has("accessory"))
	assert_true(categories.has("hardware"))
	assert_true(categories.has("service"))
	assert_gte(platforms.size(), 4)
	assert_gte(platform_families.size(), 4)
	assert_gte(conditions.size(), 4)
	assert_true(formats.has("disc"))
	assert_true(formats.has("cartridge"))
	assert_true(formats.has("accessory"))
	assert_true(formats.has("console"))
	assert_true(formats.has("controller"))
	assert_true(formats.has("service_ticket"))
	assert_true(demand_tiers.has("low"))
	assert_true(demand_tiers.has("medium"))
	assert_true(demand_tiers.has("high"))


func test_product_catalog_has_enough_sellable_content_for_multiple_days() -> void:
	var sellable_count := 0
	var used_game_count := 0
	var non_used_sellable_count := 0
	for product in _load_products():
		if product.player_priceable:
			sellable_count += 1
			if product.category == "used_game":
				used_game_count += 1
			else:
				non_used_sellable_count += 1

	assert_gte(sellable_count, 24)
	assert_gte(used_game_count, 18)
	assert_gte(non_used_sellable_count, 6)


func test_product_catalog_covers_authenticity_rarity_risk_and_location_schema() -> void:
	var authenticities := {}
	var rarities := {}
	var risk_levels := {}
	var locations := {}
	var risk_tag_count := 0

	for product in _load_products():
		authenticities[product.authenticity] = true
		rarities[product.rarity] = true
		risk_levels[product.risk_level] = true
		locations[product.default_location_id] = true
		risk_tag_count += product.risk_tags.size()
		assert_true(product.get_schema_summary().has("platform_family"))
		assert_true(product.get_schema_summary().has("risk_tags"))

	assert_true(authenticities.has("verified"))
	assert_true(authenticities.has("uncertain"))
	assert_true(rarities.has("common"))
	assert_true(rarities.has("uncommon"))
	assert_true(rarities.has("rare"))
	assert_true(risk_levels.has("low"))
	assert_true(risk_levels.has("medium"))
	assert_true(risk_levels.has("high"))
	assert_true(locations.has("receiving_box_001"))
	assert_gt(risk_tag_count, 0)


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
