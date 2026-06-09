extends GutTest

var _item: Node


func before_each() -> void:
	_item = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(_item)


func test_used_game_item_has_product_data() -> void:
	assert_not_null(_item.product)
	assert_eq(_item.product.product_id, "used_star_trader")
	assert_eq(_item.product.display_name, "Star Trader")
	assert_eq(_item.product.platform, "Orbit 64")
	assert_eq(_item.product.get_platform_family(), "orbit_classic")
	assert_eq(_item.product.condition, "good")
	assert_eq(_item.product.market_value_cents, 2499)
	assert_true(_item.product.player_priceable)


func test_used_game_item_initializes_price() -> void:
	assert_eq(_item.current_price_cents, 2199)


func test_used_game_item_has_location() -> void:
	assert_eq(_item.location_id, "receiving_box_001")


func test_used_game_mesh_sits_on_node_origin() -> void:
	var case_mesh := _item.get_node("CaseMesh") as MeshInstance3D
	var collision_shape := _item.get_node("CollisionShape3D") as CollisionShape3D

	assert_almost_eq(case_mesh.position.y - (case_mesh.mesh.size.y / 2.0), 0.0, 0.001)
	assert_almost_eq(collision_shape.position.y - (collision_shape.shape.size.y / 2.0), 0.0, 0.001)


func test_used_game_is_upright_display_case() -> void:
	var case_mesh := _item.get_node("CaseMesh") as MeshInstance3D
	assert_gt(case_mesh.mesh.size.y, case_mesh.mesh.size.x)
	assert_gt(case_mesh.mesh.size.y, case_mesh.mesh.size.z * 5.0)


func test_used_game_case_is_compact_for_display_racks() -> void:
	var case_mesh := _item.get_node("CaseMesh") as MeshInstance3D
	var collision_shape := _item.get_node("CollisionShape3D") as CollisionShape3D

	assert_lte(case_mesh.mesh.size.x, 0.26)
	assert_lte(case_mesh.mesh.size.y, 0.36)
	assert_lte(case_mesh.mesh.size.z, 0.05)
	assert_lte(collision_shape.shape.size.x, 0.28)
	assert_lte(collision_shape.shape.size.y, 0.38)
	assert_lte(collision_shape.shape.size.z, 0.065)


func test_used_game_has_readable_front_cover_label() -> void:
	var cover_mesh := _item.get_node_or_null("CoverLabelMesh") as MeshInstance3D
	var case_mesh := _item.get_node("CaseMesh") as MeshInstance3D
	assert_not_null(cover_mesh)
	assert_gt(cover_mesh.mesh.size.x, 0.16)
	assert_gt(cover_mesh.mesh.size.y, 0.22)
	assert_lt(cover_mesh.mesh.size.x, case_mesh.mesh.size.x)
	assert_lt(cover_mesh.mesh.size.y, case_mesh.mesh.size.y)
	assert_lt(cover_mesh.mesh.size.z, 0.02)


func test_used_game_case_has_spine_platform_and_price_cues() -> void:
	var spine_mesh := _item.get_node_or_null("SpineStripeMesh") as MeshInstance3D
	var platform_band := _item.get_node_or_null("PlatformBandMesh") as MeshInstance3D
	var price_sticker := _item.get_node_or_null("PriceStickerMesh") as MeshInstance3D
	var media_variant := _item.get_node_or_null("MediaVariantMesh") as MeshInstance3D

	assert_not_null(spine_mesh)
	assert_not_null(platform_band)
	assert_not_null(price_sticker)
	assert_not_null(media_variant)
	assert_gt(spine_mesh.mesh.size.y, 0.28)
	assert_gt(platform_band.mesh.size.x, 0.15)
	assert_lte(price_sticker.mesh.size.x, 0.06)
	assert_lte(price_sticker.mesh.size.y, 0.04)
	assert_true(media_variant.visible)


func test_used_game_case_visual_cues_stay_inside_case_bounds() -> void:
	var case_mesh := _item.get_node("CaseMesh") as MeshInstance3D
	var front_cues := [
		_item.get_node("CoverLabelMesh") as MeshInstance3D,
		_item.get_node("SpineStripeMesh") as MeshInstance3D,
		_item.get_node("PlatformBandMesh") as MeshInstance3D,
		_item.get_node("PriceStickerMesh") as MeshInstance3D,
	]
	var half_width: float = case_mesh.mesh.size.x / 2.0
	var top_y: float = case_mesh.position.y + case_mesh.mesh.size.y / 2.0

	for cue in front_cues:
		assert_lte(absf(cue.position.x) + cue.mesh.size.x / 2.0, half_width + 0.002)
		assert_lte(cue.position.y + cue.mesh.size.y / 2.0, top_y + 0.002)
		assert_lt(cue.mesh.size.z, case_mesh.mesh.size.z)


func test_product_item_uses_product_visual_profile() -> void:
	var profile: Dictionary = _item.get_visual_profile()
	var variant_keys := profile.get("variant_keys") as Array

	assert_eq(profile.get("container_variant"), ProductVisualRules.VARIANT_CASE)
	assert_eq(profile.get("media_variant"), ProductVisualRules.VARIANT_CARTRIDGE)
	assert_true(variant_keys.has(ProductVisualRules.VARIANT_CASE))
	assert_true(variant_keys.has(ProductVisualRules.VARIANT_CARTRIDGE))
	assert_true(variant_keys.has(ProductVisualRules.VARIANT_BOX))


func test_product_item_rebuilds_visuals_for_loose_disc_profile() -> void:
	var product := _make_product("Loose Disc", "used_game", "disc", "loose")
	_item.set("product", product)
	_item.apply_product_visuals()

	var case_mesh := _item.get_node("CaseMesh") as MeshInstance3D
	var media_variant := _item.get_node("MediaVariantMesh") as MeshInstance3D
	var loose_variant := _item.get_node("LooseVariantMesh") as MeshInstance3D
	var spine_mesh := _item.get_node("SpineStripeMesh") as MeshInstance3D

	assert_eq(_item.get_visual_profile().get("container_variant"), ProductVisualRules.VARIANT_LOOSE)
	assert_eq(_item.get_visual_profile().get("media_variant"), ProductVisualRules.VARIANT_DISC)
	assert_lt(case_mesh.mesh.size.y, 0.24)
	assert_true(media_variant.visible)
	assert_true(loose_variant.visible)
	assert_false(spine_mesh.visible)


func test_product_item_rebuilds_visuals_for_hardware_and_service_profiles() -> void:
	var hardware := _make_product("Controller Dock", "hardware", "controller", "complete")
	_item.set("product", hardware)
	_item.apply_product_visuals()

	assert_eq(_item.get_visual_profile().get("container_variant"), ProductVisualRules.VARIANT_BOX)
	assert_eq(_item.get_visual_profile().get("media_variant"), ProductVisualRules.VARIANT_CONTROLLER)
	assert_true((_item.get_node("BoxVariantMesh") as MeshInstance3D).visible)

	var service := _make_product("Service Ticket", "service", "service_ticket", "complete")
	_item.set("product", service)
	_item.apply_product_visuals()

	assert_eq(_item.get_visual_profile().get("container_variant"), ProductVisualRules.VARIANT_SERVICE_TICKET)
	assert_true((_item.get_node("ServiceTicketVariantMesh") as MeshInstance3D).visible)
	assert_false((_item.get_node("PriceStickerMesh") as MeshInstance3D).visible)


func test_product_item_applies_condition_and_authenticity_cue_meshes() -> void:
	var product := _make_product("Risk Copy", "used_game", "disc", "manual_missing")
	product.condition = "poor"
	product.authenticity = "needs_review"
	var product_tags: Array[String] = ["label_wear", "serial_check"]
	product.risk_tags = product_tags
	_item.set("product", product)
	_item.apply_product_visuals()

	assert_true((_item.get_node("ScratchCueMesh") as MeshInstance3D).visible)
	assert_true((_item.get_node("MissingManualCueMesh") as MeshInstance3D).visible)
	assert_true((_item.get_node("DamagedLabelCueMesh") as MeshInstance3D).visible)
	assert_true((_item.get_node("SerialRiskCueMesh") as MeshInstance3D).visible)
	assert_false((_item.get_node("ResealCueMesh") as MeshInstance3D).visible)

	var loose_product := _make_product("Loose Cart", "used_game", "cartridge", "loose")
	_item.set("product", loose_product)
	_item.apply_product_visuals()

	assert_true((_item.get_node("LooseMediaCueMesh") as MeshInstance3D).visible)

	var resealed_product := _make_product("Resealed Disc", "used_game", "disc", "sealed")
	resealed_product.authenticity = "uncertain"
	_item.set("product", resealed_product)
	_item.apply_product_visuals()

	assert_true((_item.get_node("ResealCueMesh") as MeshInstance3D).visible)


func test_product_item_serial_mismatch_shows_suspicious_marker() -> void:
	var product := _make_product("Clean Copy", "used_game", "disc", "complete")
	_item.set("product", product)
	_item.serial_id = "GST-999"
	_item.expected_serial_id = "GST-001"
	_item.apply_product_visuals()

	assert_true(_item.has_serial_mismatch())
	assert_true((_item.get_node("SerialRiskCueMesh") as MeshInstance3D).visible)


func test_product_item_price_tag_label_shows_category_platform_and_price() -> void:
	var label := _item.get_node_or_null("ProductTagLabel") as Label3D
	var lines: Array[String] = _item.get_price_tag_lines()

	assert_not_null(label)
	assert_true(label.visible)
	assert_eq(lines.size(), 2)
	assert_eq(lines[0], "Used Game")
	assert_string_contains(lines[1], "Orbit 64")
	assert_string_contains(lines[1], "$21.99")
	assert_eq(label.text, "\n".join(lines))
	assert_lte(label.pixel_size, 0.0025)
	assert_gte(label.font_size, 18)
	assert_true(label.no_depth_test)


func test_product_item_price_tag_badges_cover_sale_preorder_staff_and_bargain() -> void:
	var product := _make_product("Launch Pick", "new_game", "disc", "sealed")
	product.demand_tier = "high"
	product.rarity = "launch"
	product.market_value_cents = 5000
	product.suggested_price_cents = 5000
	_item.set("product", product)
	_item.current_price_cents = 3500
	_item.apply_product_visuals()

	var lines: Array[String] = _item.get_price_tag_lines()
	assert_eq(lines.size(), 3)
	assert_string_contains(lines[2], "PREORDER")
	assert_string_contains(lines[2], "STAFF")
	assert_string_contains(lines[2], "SALE")
	assert_string_contains(lines[2], "BARGAIN")
	assert_lte(lines[2].length(), 32)


func test_used_game_hover_highlight_toggles_visual_cue() -> void:
	var highlight := _item.get_node_or_null("HoverHighlight") as CSGBox3D

	assert_not_null(highlight)
	assert_false(highlight.use_collision)
	assert_false(highlight.visible)
	assert_gte(highlight.size.x, 0.319)
	assert_gte(highlight.size.y, 0.419)
	var highlight_material := highlight.material as StandardMaterial3D
	assert_not_null(highlight_material)
	assert_gte(highlight_material.albedo_color.a, 0.5)
	assert_false(_item.is_hovered())

	_item.set_hovered(true)
	assert_true(_item.is_hovered())
	assert_true(highlight.visible)

	_item.set_hovered(false)
	assert_false(_item.is_hovered())
	assert_false(highlight.visible)


func test_used_game_prompt_uses_product_name() -> void:
	assert_eq(_item.get_interaction_prompt(), "Click Inspect Star Trader")


func test_used_game_inspect_text_is_product_backed() -> void:
	var text: String = _item.interact()
	assert_string_contains(text, "Star Trader")
	assert_string_contains(text, "Orbit 64")
	assert_string_contains(text, "orbit_classic")
	assert_string_contains(text, "Cost $9.00")
	assert_string_contains(text, "Market $24.99")
	assert_string_contains(text, "Price $21.99")
	assert_string_contains(text, "receiving_box_001")
	assert_string_contains(text, "Serial untracked")


func test_used_game_can_enter_held_state() -> void:
	_item.set_held()

	var collision_shape := _item.get_node("CollisionShape3D") as CollisionShape3D
	assert_eq(_item.location_id, "held")
	assert_eq(_item.collision_layer, 0)
	assert_eq(_item.collision_mask, 0)
	assert_true(collision_shape.disabled)


func test_used_game_can_enter_stocked_state() -> void:
	_item.set_held()
	_item.set_stocked("shelf_slot_001")

	var collision_shape := _item.get_node("CollisionShape3D") as CollisionShape3D
	assert_eq(_item.location_id, "shelf_slot_001")
	assert_gt(_item.collision_layer, 0)
	assert_gt(_item.collision_mask, 0)
	assert_false(collision_shape.disabled)


func test_product_item_serial_defaults_to_untracked() -> void:
	var log := Node.new()
	add_child_autofree(log)

	assert_false(_item.has_serial_mismatch())
	assert_eq(_item.get_serial_status_text(), "Serial untracked")
	assert_eq(_item.flag_serial_mismatch(log), {})


func test_product_item_detects_matching_serial() -> void:
	_item.serial_id = "GST-001"
	_item.expected_serial_id = "GST-001"

	assert_false(_item.has_serial_mismatch())
	assert_eq(_item.get_serial_status_text(), "Serial GST-001")


func test_product_item_detects_mismatched_serial() -> void:
	_item.serial_id = "GST-1047"
	_item.expected_serial_id = "GST-003"

	assert_true(_item.has_serial_mismatch())
	assert_eq(_item.get_serial_status_text(), "Serial mismatch GST-1047 expected GST-003")
	assert_string_contains(_item.interact(), "Serial mismatch GST-1047 expected GST-003")


func test_product_item_flags_serial_mismatch_event() -> void:
	var log: Node = load("res://scripts/narrative/suspicious_event_log.gd").new()
	add_child_autofree(log)
	_item.instance_id = "item_used_star_trader_003"
	_item.serial_id = "GST-1047"
	_item.expected_serial_id = "GST-003"
	_item.suspicious_event_id = "serial_mismatch_item_used_star_trader_003"

	var event: Dictionary = _item.flag_serial_mismatch(log)

	assert_eq(event.get("event_id"), "serial_mismatch_item_used_star_trader_003")
	assert_eq(event.get("title"), "Mismatched serial for Star Trader")
	assert_eq(event.get("source"), "inventory")
	assert_eq(event.get("severity"), "medium")
	assert_eq(event.get("metadata").get("instance_id"), "item_used_star_trader_003")
	assert_eq(event.get("metadata").get("product_id"), "used_star_trader")
	assert_eq(event.get("metadata").get("serial_id"), "GST-1047")
	assert_eq(event.get("metadata").get("expected_serial_id"), "GST-003")
	assert_true(log.has_event("serial_mismatch_item_used_star_trader_003"))


func test_product_definition_describes_retail_fields() -> void:
	var product := load("res://data/products/used_star_trader.tres") as ProductDefinition
	var description := product.describe()
	assert_string_contains(description, "Star Trader")
	assert_string_contains(description, "Orbit 64")
	assert_string_contains(description, "orbit_classic")
	assert_string_contains(description, "Good")
	assert_string_contains(description, "Uncommon")
	assert_string_contains(description, "Demand Medium")
	assert_string_contains(description, "Cost $9.00")
	assert_string_contains(description, "Market $24.99")
	assert_string_contains(description, "Risk Low")


func test_product_definition_exposes_complete_inventory_schema_summary() -> void:
	var product := load("res://data/products/used_star_trader.tres") as ProductDefinition
	var summary := product.get_schema_summary()

	assert_true(product.has_complete_inventory_schema())
	assert_true(product.is_authentic())
	assert_eq(summary.get("category"), "used_game")
	assert_eq(summary.get("platform_family"), "orbit_classic")
	assert_eq(summary.get("format"), "cartridge")
	assert_eq(summary.get("condition"), "good")
	assert_eq(summary.get("completeness"), "complete")
	assert_eq(summary.get("authenticity"), "verified")
	assert_eq(summary.get("rarity"), "uncommon")
	assert_eq(summary.get("demand_tier"), "medium")
	assert_eq(summary.get("cost_basis_cents"), 900)
	assert_eq(summary.get("market_value_cents"), 2499)
	assert_eq(summary.get("risk_level"), "low")
	assert_eq(summary.get("default_location_id"), "receiving_box_001")


func _make_product(
	display_name: String,
	category: String,
	format: String,
	completeness: String
) -> ProductDefinition:
	var product := ProductDefinition.new()
	product.product_id = display_name.to_snake_case()
	product.display_name = display_name
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
