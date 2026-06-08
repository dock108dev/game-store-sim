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


func test_loose_cartridge_profile_uses_loose_and_cartridge_variants() -> void:
	var product := _make_product("used_game", "cartridge", "loose")
	var profile := ProductVisualRules.build_profile(product)

	assert_eq(profile.get("container_variant"), ProductVisualRules.VARIANT_LOOSE)
	assert_eq(profile.get("media_variant"), ProductVisualRules.VARIANT_CARTRIDGE)
	assert_eq(profile.get("state_variant"), ProductVisualRules.VARIANT_LOOSE)
	assert_lt((profile.get("case_size") as Vector3).y, 0.34)
	assert_false(profile.get("show_spine"))


func test_sealed_disc_profile_marks_seal_variant() -> void:
	var product := _make_product("used_game", "disc", "sealed")
	var profile := ProductVisualRules.build_profile(product)

	assert_eq(profile.get("state_variant"), ProductVisualRules.VARIANT_SEALED)
	assert_true((profile.get("variant_keys") as Array).has(ProductVisualRules.VARIANT_SEALED))


func test_hardware_profiles_choose_boxed_device_variants() -> void:
	var console := ProductVisualRules.build_profile(_make_product("hardware", "console", "complete"))
	var controller := ProductVisualRules.build_profile(_make_product("hardware", "controller", "complete"))
	var accessory := ProductVisualRules.build_profile(_make_product("hardware", "cable", "complete"))

	assert_eq(console.get("container_variant"), ProductVisualRules.VARIANT_BOX)
	assert_eq(console.get("media_variant"), ProductVisualRules.VARIANT_CONSOLE)
	assert_eq(controller.get("media_variant"), ProductVisualRules.VARIANT_CONTROLLER)
	assert_eq(accessory.get("media_variant"), ProductVisualRules.VARIANT_ACCESSORY)


func test_service_ticket_profile_stays_distinct_from_sale_products() -> void:
	var profile := ProductVisualRules.build_profile(_make_product("service", "service_ticket", "complete"))

	assert_eq(profile.get("container_variant"), ProductVisualRules.VARIANT_SERVICE_TICKET)
	assert_eq(profile.get("media_variant"), ProductVisualRules.VARIANT_SERVICE_TICKET)
	assert_false(profile.get("show_price_sticker"))


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
