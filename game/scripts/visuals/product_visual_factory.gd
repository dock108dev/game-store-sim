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
	var node: Node3D = null
	if str(normalized.get("category", "")) == "console":
		var identity: Dictionary = catalog.get_platform_identity_for_item(normalized)
		node = ProductVisualCaseBuilderScript.build_console_box(identity)
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
		for key: String in ["box_art_key", "platform_visual_id", "visual_alias_id"]:
			if definition.extra.has(key):
				data[key] = definition.extra[key]
	return data


static func _apply_item_metadata(node: Node3D, data: Dictionary) -> void:
	for key: String in [
		"definition_id",
		"display_name",
		"category",
		"platform_id",
		"condition",
		"price_cents",
		"stock_state",
		"route_role",
	]:
		if data.has(key):
			node.set_meta(key, data[key])
	node.set_meta("visual_source", "product_visual_factory")


static func _add_price_tag(node: Node3D, price_cents: int) -> void:
	var tag := MeshInstance3D.new()
	tag.name = "ProductPriceTag"
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.070, 0.026, 0.006)
	tag.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.96, 0.78, 0.32, 1.0)
	material.roughness = 0.82
	tag.material_override = material
	tag.position = Vector3(0.060, -0.080, 0.036)
	tag.set_meta("price_cents", price_cents)
	node.add_child(tag)
