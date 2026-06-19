extends GutTest


func test_product_visual_rules_support_required_variants() -> void:
	var variants := ProductVisualRules.get_supported_variants()

	for variant in [
		ProductVisualRules.VARIANT_CASE,
		ProductVisualRules.VARIANT_DISC,
		ProductVisualRules.VARIANT_CARTRIDGE,
		ProductVisualRules.VARIANT_ACCESSORY,
		ProductVisualRules.VARIANT_CONSOLE,
		ProductVisualRules.VARIANT_CONTROLLER,
		ProductVisualRules.VARIANT_BOX,
		ProductVisualRules.VARIANT_SEALED,
		ProductVisualRules.VARIANT_LOOSE,
		ProductVisualRules.VARIANT_SERVICE_TICKET,
	]:
		assert_true(variants.has(variant), "Missing visual variant %s" % variant)


func test_used_disc_game_profile_uses_case_disc_and_box_variants() -> void:
	var product := _make_product("used_game", "disc", "complete")
	var profile := ProductVisualRules.build_profile(product)

	assert_eq(profile.get("container_variant"), ProductVisualRules.VARIANT_CASE)
	assert_eq(profile.get("media_variant"), ProductVisualRules.VARIANT_DISC)
	assert_eq(profile.get("state_variant"), ProductVisualRules.VARIANT_BOX)
	assert_true((profile.get("variant_keys") as Array).has(ProductVisualRules.VARIANT_DISC))
	assert_true(profile.get("show_spine"))
	assert_true(profile.has("platform_color"))
	assert_true(profile.has("genre_color"))
	assert_true(profile.get("show_genre_accent"))
	assert_true(profile.get("show_used_sticker"))


func test_loose_cartridge_profile_uses_loose_and_cartridge_variants() -> void:
	var product := _make_product("used_game", "cartridge", "loose")
	var profile := ProductVisualRules.build_profile(product)

	assert_eq(profile.get("container_variant"), ProductVisualRules.VARIANT_LOOSE)
	assert_eq(profile.get("media_variant"), ProductVisualRules.VARIANT_CARTRIDGE)
	assert_eq(profile.get("state_variant"), ProductVisualRules.VARIANT_LOOSE)
	assert_lt((profile.get("case_size") as Vector3).y, 0.34)
	assert_false(profile.get("show_spine"))


func test_sealed_disc_profile_marks_seal_variant() -> void:
	var product := _make_product("new_game", "disc", "sealed")
	var profile := ProductVisualRules.build_profile(product)

	assert_eq(profile.get("state_variant"), ProductVisualRules.VARIANT_SEALED)
	assert_true((profile.get("variant_keys") as Array).has(ProductVisualRules.VARIANT_SEALED))
	assert_false(profile.get("show_used_sticker"))


func test_platform_and_genre_colors_are_distinct_visual_signals() -> void:
	var sports := _make_product("new_game", "disc", "sealed")
	sports.platform_family = "vortex"
	sports.genre_id = "sports"
	var adventure := _make_product("new_game", "cartridge", "sealed")
	adventure.platform_family = "pocket_handheld"
	adventure.genre_id = "rpg_adventure"

	var sports_profile := ProductVisualRules.build_profile(sports)
	var adventure_profile := ProductVisualRules.build_profile(adventure)

	assert_ne(sports_profile.get("platform_color"), sports_profile.get("genre_color"))
	assert_ne(adventure_profile.get("platform_color"), adventure_profile.get("genre_color"))
	assert_ne(sports_profile.get("genre_color"), adventure_profile.get("genre_color"))
	assert_ne(sports_profile.get("platform_color"), adventure_profile.get("platform_color"))


func test_vortex_starter_profiles_expose_product_art_keys_and_packaging_scale() -> void:
	var footy := load("res://data/products/new_footy_2002.tres") as ProductDefinition
	var critter := load("res://data/products/new_critter_quest_ii.tres") as ProductDefinition
	var console := load("res://data/products/hardware_vortex_console.tres") as ProductDefinition
	var controller := load("res://data/products/hardware_vortex_controller.tres") as ProductDefinition

	var footy_profile := ProductVisualRules.build_profile(footy)
	var critter_profile := ProductVisualRules.build_profile(critter)
	var console_profile := ProductVisualRules.build_profile(console)
	var controller_profile := ProductVisualRules.build_profile(controller)

	assert_eq(footy_profile.get("product_art_key"), "footy_2002")
	assert_eq(critter_profile.get("product_art_key"), "critter_quest_ii")
	assert_eq(console_profile.get("product_art_key"), "vortex_console_box")
	assert_eq(controller_profile.get("product_art_key"), "vortex_controller_box")
	assert_gt((console_profile.get("case_size") as Vector3).x, (footy_profile.get("case_size") as Vector3).x * 2.0)
	assert_gt((controller_profile.get("case_size") as Vector3).y, (footy_profile.get("case_size") as Vector3).y * 0.9)


func test_hardware_profiles_choose_boxed_device_variants() -> void:
	var console := ProductVisualRules.build_profile(_make_product("hardware", "console", "complete"))
	var controller := ProductVisualRules.build_profile(_make_product("hardware", "controller", "complete"))
	var accessory := ProductVisualRules.build_profile(_make_product("hardware", "cable", "complete"))
	var boxed_accessory := ProductVisualRules.build_profile(_make_product("accessory", "card", "complete"))

	assert_eq(console.get("container_variant"), ProductVisualRules.VARIANT_BOX)
	assert_eq(console.get("media_variant"), ProductVisualRules.VARIANT_CONSOLE)
	assert_eq(controller.get("media_variant"), ProductVisualRules.VARIANT_CONTROLLER)
	assert_eq(accessory.get("media_variant"), ProductVisualRules.VARIANT_ACCESSORY)
	assert_eq(boxed_accessory.get("container_variant"), ProductVisualRules.VARIANT_BOX)
	assert_eq(boxed_accessory.get("media_variant"), ProductVisualRules.VARIANT_ACCESSORY)


func test_service_ticket_profile_stays_distinct_from_sale_products() -> void:
	var profile := ProductVisualRules.build_profile(_make_product("service", "service_ticket", "complete"))

	assert_eq(profile.get("container_variant"), ProductVisualRules.VARIANT_SERVICE_TICKET)
	assert_eq(profile.get("media_variant"), ProductVisualRules.VARIANT_SERVICE_TICKET)
	assert_false(profile.get("show_price_sticker"))


func test_condition_cues_mark_wear_missing_manual_reseal_and_serial_risk() -> void:
	var worn_copy := _make_product("used_game", "disc", "manual_missing")
	worn_copy.condition = "poor"
	worn_copy.authenticity = "needs_review"
	var worn_tags: Array[String] = ["label_wear", "serial_check"]
	worn_copy.risk_tags = worn_tags
	var worn_cues := ProductVisualRules.build_profile(worn_copy).get("condition_cues") as Array

	assert_true(worn_cues.has(ProductVisualRules.CUE_SCRATCHES))
	assert_true(worn_cues.has(ProductVisualRules.CUE_MISSING_MANUAL))
	assert_true(worn_cues.has(ProductVisualRules.CUE_DAMAGED_LABEL))
	assert_true(worn_cues.has(ProductVisualRules.CUE_SERIAL_RISK))

	var loose_copy := _make_product("used_game", "cartridge", "loose")
	var loose_cues := ProductVisualRules.build_profile(loose_copy).get("condition_cues") as Array
	assert_true(loose_cues.has(ProductVisualRules.CUE_LOOSE_MEDIA))

	var resealed_copy := _make_product("used_game", "disc", "sealed")
	resealed_copy.authenticity = "uncertain"
	var resealed_cues := ProductVisualRules.build_profile(resealed_copy).get("condition_cues") as Array
	assert_true(resealed_cues.has(ProductVisualRules.CUE_RESEALED))
	assert_true(resealed_cues.has(ProductVisualRules.CUE_SERIAL_RISK))


func _make_product(category: String, format: String, completeness: String) -> ProductDefinition:
	var product := ProductDefinition.new()
	product.product_id = "%s_%s_%s" % [category, format, completeness]
	product.display_name = "Variant Test"
	product.category = category
	product.platform = "Test Platform"
	product.platform_family = "test_family"
	product.format = format
	product.condition = "good"
	product.completeness = completeness
	product.authenticity = "verified"
	product.rarity = "common"
	product.demand_tier = "medium"
	product.cost_basis_cents = 100
	product.market_value_cents = 200
	product.suggested_price_cents = 150
	product.risk_level = "low"
	return product
