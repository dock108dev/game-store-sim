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
const PLATFORM_FAMILY_RULES := {
	"nova_disc": {
		"platforms": ["Nova Cube"],
		"formats": ["disc", "accessory", "controller"],
	},
	"orbit_classic": {
		"platforms": ["Orbit 64"],
		"formats": ["cartridge", "accessory", "console"],
	},
	"pocket_handheld": {
		"platforms": ["Pocket Star"],
		"formats": ["cartridge", "accessory", "console"],
	},
	"service_bench": {
		"platforms": ["Service Bench"],
		"formats": ["service_ticket"],
	},
}
const ALLOWED_TAXONOMY := {
	"category": ["used_game", "new_game", "accessory", "hardware", "service"],
	"condition": ["new", "excellent", "good", "fair", "poor", "refurbished", "service"],
	"completeness": ["sealed", "complete", "box_only", "manual_missing", "loose", "ticket"],
	"authenticity": ["verified", "trusted", "uncertain", "needs_review"],
	"rarity": ["common", "uncommon", "rare", "collector", "standard", "launch"],
	"demand_tier": ["low", "medium", "high"],
	"risk_level": ["low", "medium", "high"],
}
const ALLOWED_SERVICE_NAMES := [
	"Cartridge Cleaning Ticket",
	"Controller Test Ticket",
	"Disc Resurfacing Ticket",
]
const MIN_TOTAL_PRODUCTS := 60
const MIN_SELLABLE_PRODUCTS := 57
const MIN_USED_GAMES := 36
const MIN_NEW_GAMES := 9
const MIN_ACCESSORY_HARDWARE := 9
const MIN_SERVICE_TICKETS := 3


func test_product_catalog_contains_expanded_fictional_products() -> void:
	var products := _load_products()

	assert_gte(products.size(), MIN_TOTAL_PRODUCTS)
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
	var new_game_count := 0
	var accessory_hardware_count := 0
	var service_count := 0
	var non_used_sellable_count := 0
	for product in _load_products():
		match product.category:
			"used_game":
				used_game_count += 1
			"new_game":
				new_game_count += 1
			"accessory", "hardware":
				accessory_hardware_count += 1
			"service":
				service_count += 1

		if product.player_priceable:
			sellable_count += 1
			if product.category != "used_game":
				non_used_sellable_count += 1

	assert_gte(sellable_count, MIN_SELLABLE_PRODUCTS)
	assert_gte(used_game_count, MIN_USED_GAMES)
	assert_gte(new_game_count, MIN_NEW_GAMES)
	assert_gte(accessory_hardware_count, MIN_ACCESSORY_HARDWARE)
	assert_gte(service_count, MIN_SERVICE_TICKETS)
	assert_gte(non_used_sellable_count, MIN_NEW_GAMES + MIN_ACCESSORY_HARDWARE)


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


func test_product_catalog_uses_locked_fictional_platform_and_taxonomy_language() -> void:
	for product in _load_products():
		assert_true(PLATFORM_FAMILY_RULES.has(product.platform_family))
		if PLATFORM_FAMILY_RULES.has(product.platform_family):
			var family_rules: Dictionary = PLATFORM_FAMILY_RULES[product.platform_family]
			assert_true(family_rules["platforms"].has(product.platform))
			assert_true(family_rules["formats"].has(product.format))

		assert_true(ALLOWED_TAXONOMY["category"].has(product.category))
		assert_true(ALLOWED_TAXONOMY["condition"].has(product.condition))
		assert_true(ALLOWED_TAXONOMY["completeness"].has(product.completeness))
		assert_true(ALLOWED_TAXONOMY["authenticity"].has(product.authenticity))
		assert_true(ALLOWED_TAXONOMY["rarity"].has(product.rarity))
		assert_true(ALLOWED_TAXONOMY["demand_tier"].has(product.demand_tier))
		assert_true(ALLOWED_TAXONOMY["risk_level"].has(product.risk_level))
		_assert_fictional_name(product.platform)

		if product.category == "service":
			assert_true(ALLOWED_SERVICE_NAMES.has(product.display_name))


func test_product_catalog_names_fit_tags_receipts_and_catalog_cards() -> void:
	for product in _load_products():
		assert_lte(product.display_name.length(), 28)
		assert_eq(product.display_name.find(":"), -1)
		assert_false(product.display_name.begins_with("The "))


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
