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
	if str(normalized.get("category", "")) == "console":
		var identity: Dictionary = catalog.get_platform_identity_for_item(normalized)
		return ProductVisualCaseBuilderScript.build_console_box(identity)
	var template: Dictionary = catalog.find_template_for_item(normalized)
	if template.is_empty():
		return null
	return ProductVisualCaseBuilderScript.build_case(template, catalog)


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
		for key: String in ["box_art_key", "platform_visual_id", "visual_alias_id"]:
			if definition.extra.has(key):
				data[key] = definition.extra[key]
	return data
