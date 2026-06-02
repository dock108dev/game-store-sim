## Creates designed product visuals when visual-only catalog metadata resolves.
class_name ProductVisualFactory
extends RefCounted

const ShelfCategoryNormalizerScript: GDScript = preload(
	"res://game/scripts/stores/shelf_category_normalizer.gd"
)
const ProductVisualCatalogScript: GDScript = preload(
	"res://game/scripts/visuals/product_visual_catalog.gd"
)
const ProductVisualCaseBuilderScript: GDScript = preload(
	"res://game/scripts/visuals/product_visual_case_builder.gd"
)
const ProductPhysicalTagBuilderScript: GDScript = preload(
	"res://game/scripts/visuals/product_physical_tag_builder.gd"
)
const StoreVisualKitScript: GDScript = preload(
	"res://game/scripts/visuals/store_visual_kit.gd"
)

const PRESENTATION_GAME_CASE: String = "game_case"
const PRESENTATION_CARTRIDGE: String = "cartridge"
const _VISUAL_PRESENTATION_KEYS: Array[String] = [
	"visual_presentation",
	"presentation",
	"product_visual_kind",
]
const _VISUAL_EXTRA_KEYS: Array[String] = [
	"box_art_key",
	"platform_visual_id",
	"visual_alias_id",
	"visual_presentation",
	"visual_variant_id",
	"case_shape_override",
	"cartridge_shape_override",
	"console_box_shape_override",
	"package_finish",
	"package_wear_level",
]
const _PHYSICAL_TAG_EXTRA_KEYS: Array[String] = [
	"physical_tag_profile",
	"condition_grade",
	"condition_grades",
	"edition_badge",
	"authenticity_badge",
	"sleeve_style",
	"protector_style",
	"sticker_shape",
	"tag_shape",
	"tag_color_override",
	"platform_tag_override",
	"staff_pick",
	"sale",
	"clearance",
	"trade_in_base",
]


## Creates a designed product visual using the default product visual catalog.
static func create_visual_for_item(item: Dictionary) -> Node3D:
	var catalog: RefCounted = ProductVisualCatalogScript.load_default()
	return create_visual_for_item_with_catalog(item, catalog)


## Creates a designed product visual using an injected catalog instance.
static func create_visual_for_item_with_catalog(
	item: Dictionary, catalog: RefCounted
) -> Node3D:
	if catalog == null or item.is_empty():
		return null
	var normalized: Dictionary = item.duplicate(true)
	normalized["category"] = ShelfCategoryNormalizerScript.normalize(
		str(normalized.get("category", ""))
	)
	var node: Node3D = null
	var presentation: String = _presentation_for_item(normalized)
	if str(normalized.get("category", "")) == "console":
		var identity: Dictionary = catalog.get_platform_identity_for_item(normalized)
		_merge_visual_overrides(identity, normalized)
		node = ProductVisualCaseBuilderScript.build_console_box(identity)
	elif presentation == PRESENTATION_CARTRIDGE:
		var identity: Dictionary = catalog.get_platform_identity_for_item(normalized)
		node = ProductVisualCaseBuilderScript.build_cartridge(identity, normalized)
	else:
		var template: Dictionary = catalog.find_template_for_item(normalized)
		if not template.is_empty():
			_merge_visual_overrides(template, normalized)
			node = ProductVisualCaseBuilderScript.build_case(template, catalog)
	if node == null:
		return null
	_apply_item_metadata(node, normalized)
	if _has_physical_tag_inputs(normalized):
		normalized["product_visual_kind"] = str(node.get_meta("product_visual_kind", ""))
		ProductPhysicalTagBuilderScript.apply_physical_tags(node, normalized)
	if bool(normalized.get("show_price_tag", false)):
		_add_price_tag(node, int(normalized.get("price_cents", -1)))
	return node


## Extracts visual-only catalog metadata from an inventory item.
static func visual_data_from_item(item: ItemInstance) -> Dictionary:
	if item == null:
		return {}
	var data: Dictionary = {
		"instance_id": String(item.instance_id),
		"condition": item.condition,
	}
	if item.definition == null:
		return data
	var definition: ItemDefinition = item.definition
	data["definition_id"] = definition.id
	data["display_name"] = definition.item_name
	data["category"] = ShelfCategoryNormalizerScript.normalize(String(definition.category))
	data["rarity"] = definition.rarity
	data["rarity_tier"] = definition.rarity_tier
	data["condition_tier"] = item.condition_tier
	data["condition_range"] = definition.condition_range
	data["condition_tier_range"] = definition.condition_tier_range
	data["tags"] = definition.tags
	data["product_set_name"] = definition.product_set_name
	data["appreciates"] = definition.appreciates
	data["depreciates"] = definition.depreciates
	data["decay_profile"] = String(definition.decay_profile)
	data["platform"] = definition.platform
	data["platform_id"] = String(definition.platform_id)
	data["region"] = definition.region
	data["suspicious_chance"] = definition.suspicious_chance
	data["supply_constrained"] = definition.supply_constrained
	data["launch_window_start_day"] = definition.launch_window_start_day
	data["launch_window_end_day"] = definition.launch_window_end_day
	if definition.extra is Dictionary:
		for key: String in _VISUAL_EXTRA_KEYS:
			if definition.extra.has(key):
				data[key] = definition.extra[key]
		for key: String in _PHYSICAL_TAG_EXTRA_KEYS:
			if definition.extra.has(key):
				data[key] = definition.extra[key]
	return data


static func _presentation_for_item(item: Dictionary) -> String:
	for key: String in _VISUAL_PRESENTATION_KEYS:
		var raw: String = str(item.get(key, "")).strip_edges().to_lower()
		match raw:
			"loose_cartridge", "starter_cartridge", "cartridge":
				return PRESENTATION_CARTRIDGE
			"case", "game_case", "starter_game_case", "boxed":
				return PRESENTATION_GAME_CASE
	return PRESENTATION_GAME_CASE


static func _merge_visual_overrides(target: Dictionary, item: Dictionary) -> void:
	for key: String in [
		"case_shape_override",
		"console_box_shape_override",
		"visual_variant_id",
		"package_finish",
		"package_wear_level",
	]:
		if item.has(key):
			target[key] = item[key]


static func _has_physical_tag_inputs(item: Dictionary) -> bool:
	for key: String in [
		"definition_id",
		"condition",
		"condition_tier",
		"rarity",
		"rarity_tier",
		"tags",
		"product_set_name",
		"decay_profile",
		"suspicious_chance",
		"supply_constrained",
	]:
		if item.has(key):
			return true
	return false


static func _apply_item_metadata(node: Node3D, data: Dictionary) -> void:
	for key: String in [
		"definition_id",
		"display_name",
		"category",
		"platform_id",
		"condition",
		"condition_tier",
		"condition_range",
		"condition_tier_range",
		"rarity",
		"rarity_tier",
		"tags",
		"product_set_name",
		"appreciates",
		"depreciates",
		"decay_profile",
		"platform",
		"box_art_key",
		"platform_visual_id",
		"visual_alias_id",
		"visual_presentation",
		"price_cents",
		"stock_state",
		"route_role",
		"visual_resolution_source",
		"visual_variant_id",
		"case_shape_override",
		"cartridge_shape_override",
		"console_box_shape_override",
		"package_finish",
		"package_wear_level",
		"region",
		"suspicious_chance",
		"supply_constrained",
		"launch_window_start_day",
		"launch_window_end_day",
		"condition_grade",
		"condition_grades",
		"edition_badge",
		"authenticity_badge",
		"sleeve_style",
		"protector_style",
		"sticker_shape",
		"tag_shape",
		"tag_color_override",
		"platform_tag_override",
		"staff_pick",
		"sale",
		"clearance",
		"trade_in_base",
	]:
		if data.has(key):
			node.set_meta(key, data[key])
	node.set_meta("visual_source", "product_visual_factory")


static func _add_price_tag(node: Node3D, price_cents: int) -> void:
	var tag: MeshInstance3D = StoreVisualKitScript.instantiate_product_price_tag(price_cents)
	if tag != null:
		node.add_child(tag)
