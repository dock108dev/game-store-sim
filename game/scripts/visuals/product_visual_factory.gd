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
		node = ProductVisualCaseBuilderScript.build_console_box(identity)
	elif presentation == PRESENTATION_CARTRIDGE:
		var identity: Dictionary = catalog.get_platform_identity_for_item(normalized)
		node = ProductVisualCaseBuilderScript.build_cartridge(identity, normalized)
	else:
		var template: Dictionary = catalog.find_template_for_item(normalized)
		if not template.is_empty():
			node = ProductVisualCaseBuilderScript.build_case(template, catalog)
	if node == null:
		return null
	_apply_item_metadata(node, normalized)
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
	data["platform_id"] = String(definition.platform_id)
	if definition.extra is Dictionary:
		for key: String in [
			"box_art_key",
			"platform_visual_id",
			"visual_alias_id",
			"visual_presentation",
		]:
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


static func _apply_item_metadata(node: Node3D, data: Dictionary) -> void:
	for key: String in [
		"definition_id",
		"display_name",
		"category",
		"platform_id",
		"condition",
		"box_art_key",
		"platform_visual_id",
		"visual_alias_id",
		"visual_presentation",
		"price_cents",
		"stock_state",
		"route_role",
	]:
		if data.has(key):
			node.set_meta(key, data[key])
	node.set_meta("visual_source", "product_visual_factory")


static func _add_price_tag(node: Node3D, price_cents: int) -> void:
	var tag: MeshInstance3D = StoreVisualKitScript.instantiate_product_price_tag(price_cents)
	if tag != null:
		node.add_child(tag)
