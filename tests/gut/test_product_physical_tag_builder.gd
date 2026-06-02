extends GutTest

const ProductPhysicalTagBuilderScript: GDScript = preload(
	"res://game/scripts/visuals/product_physical_tag_builder.gd"
)
const ProductVisualCatalogScript: GDScript = preload(
	"res://game/scripts/visuals/product_visual_catalog.gd"
)
const ProductVisualFactoryScript: GDScript = preload(
	"res://game/scripts/visuals/product_visual_factory.gd"
)


func test_common_good_item_derives_plain_condition_and_rarity_tags() -> void:
	var spec: Dictionary = ProductPhysicalTagBuilderScript.build_physical_tag_spec(
		{
			"definition_id": "plain_case",
			"category": "cartridge",
			"condition": "good",
			"rarity": "common",
			"platform_id": "neo_ignite",
		}
	)

	assert_eq(spec.get("schema", ""), "physical_tag_spec.v1")
	assert_eq((spec.get("condition", {}) as Dictionary).get("grade_badge", ""), "G")
	assert_eq((spec.get("rarity", {}) as Dictionary).get("sticker", ""), "paper_dot")
	assert_eq((spec.get("protector", {}) as Dictionary).get("style", ""), "thin_clear_wrap")


func test_rare_high_value_item_derives_premium_rarity_marker() -> void:
	var spec: Dictionary = ProductPhysicalTagBuilderScript.build_physical_tag_spec(
		{
			"definition_id": "rare_case",
			"category": "cartridge",
			"condition": "near_mint",
			"rarity": "rare",
			"rarity_tier": 2,
			"appreciates": true,
		}
	)
	var rarity: Dictionary = spec.get("rarity", {}) as Dictionary

	assert_eq(rarity.get("sticker", ""), "metallic_starburst")
	assert_eq(rarity.get("trim", ""), "silver_edge")
	assert_true(_has_metadata_kind(spec, "collector_market"))


func test_poor_condition_item_derives_wear_without_downgrading_rarity() -> void:
	var spec: Dictionary = ProductPhysicalTagBuilderScript.build_physical_tag_spec(
		{
			"definition_id": "rough_legend",
			"category": "cartridge",
			"condition": "poor",
			"rarity": "legendary",
			"rarity_tier": 4,
		}
	)

	assert_eq((spec.get("condition", {}) as Dictionary).get("wear_overlay", ""), "heavy_scuffs")
	assert_eq((spec.get("rarity", {}) as Dictionary).get("sticker", ""), "embossed_certificate")
	assert_eq((spec.get("protector", {}) as Dictionary).get("style", ""), "hard_shell")


func test_trade_in_staff_pick_and_sale_tags_are_metadata_only() -> void:
	var spec: Dictionary = ProductPhysicalTagBuilderScript.build_physical_tag_spec(
		{
			"definition_id": "tagged_case",
			"category": "cartridge",
			"condition": "good",
			"rarity": "uncommon",
			"tags": PackedStringArray(["trade_in", "staff_pick", "sale"]),
		}
	)

	assert_true(_has_metadata_kind(spec, "trade_in"))
	assert_true(_has_metadata_kind(spec, "staff_pick"))
	assert_true(_has_metadata_kind(spec, "sale"))


func test_protective_case_marker_uses_condition_grades() -> void:
	var spec: Dictionary = ProductPhysicalTagBuilderScript.build_physical_tag_spec(
		{
			"definition_id": "sealed_possible",
			"category": "cartridge",
			"condition": "mint",
			"rarity": "common",
			"condition_grades": ["Loose", "CIB", "Sealed"],
		}
	)

	assert_eq((spec.get("protector", {}) as Dictionary).get("style", ""), "hard_shell")
	assert_true(_has_metadata_kind(spec, "protective_case"))


func test_platform_tags_use_known_fictional_shapes() -> void:
	var spec: Dictionary = ProductPhysicalTagBuilderScript.build_physical_tag_spec(
		{
			"definition_id": "platform_case",
			"category": "cartridge",
			"platform_id": "canopy_wave",
		}
	)

	assert_eq((spec.get("platform", {}) as Dictionary).get("tag_shape", ""), "handle_tab")
	assert_eq((spec.get("platform", {}) as Dictionary).get("label", ""), "CW")


func test_suspicious_and_collector_items_get_neutral_inspection_tags() -> void:
	var spec: Dictionary = ProductPhysicalTagBuilderScript.build_physical_tag_spec(
		{
			"definition_id": "collector_case",
			"category": "cartridge",
			"rarity": "very_rare",
			"condition": "near_mint",
			"suspicious_chance": 0.25,
			"decay_profile": "collector_market",
			"supply_constrained": true,
		}
	)

	assert_true(_has_metadata_kind(spec, "inspection"))
	assert_true(_has_metadata_kind(spec, "collector_market"))
	assert_true(_has_metadata_kind(spec, "limited_supply"))


func test_factory_adds_physical_tag_nodes_without_mutating_item_resources() -> void:
	var definition := ItemDefinition.new()
	definition.id = "visual_only_fixture"
	definition.item_name = "Visual Only Fixture"
	definition.category = &"cartridges"
	definition.platform_id = &"neo_ignite"
	definition.rarity = "rare"
	definition.condition_range = PackedStringArray(["poor", "fair", "good", "near_mint"])
	definition.tags = PackedStringArray(["staff_pick"])
	definition.product_set_name = "Fixture Set"
	definition.supply_constrained = true
	definition.extra = {
		"box_art_key": "motorway_kings_neo_ignite",
		"platform_visual_id": "neo_ignite_disc_tower",
		"visual_presentation": "game_case",
		"condition_grades": ["Loose", "CIB", "Sealed"],
	}
	var item: ItemInstance = ItemInstance.create_from_definition(definition, "poor")
	item.player_price = 123.0
	var original_condition: String = item.condition
	var original_rarity: String = definition.rarity
	var original_stock_location: String = item.current_location

	var catalog: RefCounted = ProductVisualCatalogScript.new()
	catalog.load_from_dictionary(_minimal_catalog())
	var visual_data: Dictionary = ProductVisualFactoryScript.visual_data_from_item(item)
	var node: Node3D = ProductVisualFactoryScript.create_visual_for_item_with_catalog(
		visual_data, catalog
	)

	assert_not_null(node, "Factory must still build catalog-backed product visuals")
	if node != null:
		var tag_root: Node = node.get_node_or_null("PhysicalTagRoot")
		assert_not_null(tag_root, "Factory must attach derived physical tags")
		assert_not_null(tag_root.get_node_or_null("ConditionSleeve"))
		assert_not_null(tag_root.get_node_or_null("RaritySticker"))
		assert_not_null(tag_root.get_node_or_null("PlatformPhysicalTag"))
		assert_not_null(tag_root.get_node_or_null("MetadataTagStaffPick"))
		assert_not_null(tag_root.get_node_or_null("ProtectorShell"))
		node.free()
	assert_eq(item.condition, original_condition)
	assert_eq(definition.rarity, original_rarity)
	assert_eq(item.current_location, original_stock_location)
	assert_almost_eq(item.player_price, 123.0, 0.001)


func _has_metadata_kind(spec: Dictionary, kind: String) -> bool:
	for tag: Dictionary in spec.get("metadata_tags", []):
		if str(tag.get("kind", "")) == kind:
			return true
	return false


func _minimal_catalog() -> Dictionary:
	return {
		"type": "product_visual_catalog_data",
		"game_box_templates": [
			{
				"template_id": "motorway_kings_neo_ignite",
				"display_title": "Motorway Kings",
				"platform_visual_id": "neo_ignite_disc_tower",
				"front_color": "#445566",
				"case_shape": "tall_disc_case",
				"title_block": {"text": "MOTORWAY KINGS", "fill_color": "#ddd28a"},
				"simple_symbol": {"shape": "stripes", "fill_color": "#222222"},
				"spine_color": "#222222",
				"spine_label": {"text": "MOTORWAY KINGS"},
				"platform_stripe": {
					"catalog_label": "NEO IGNITE",
					"fill_color": "#111111",
					"accent_color": "#ddaa44",
				},
				"shelf_display": {"preferred_facing": "front"},
			},
		],
		"platform_visual_identities": [
			{
				"platform_visual_id": "neo_ignite_disc_tower",
				"display_label": "Neo Ignite",
				"body_color": "#222222",
				"accent_color": "#ddaa44",
				"label_plate_color": "#eeeecc",
			},
		],
	}
