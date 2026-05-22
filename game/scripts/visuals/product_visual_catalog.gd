## Runtime lookup helper for visual-only product packaging metadata.
class_name ProductVisualCatalog
extends RefCounted

const DEFAULT_PATH: String = "res://game/content/visuals/retro_games_product_visual_catalog.json"
const SCRIPT_PATH: String = "res://game/scripts/visuals/product_visual_catalog.gd"
const _ShelfCategoryNormalizer: GDScript = preload(
	"res://game/scripts/stores/shelf_category_normalizer.gd"
)
const CATEGORY_FALLBACKS: Dictionary = {
	"cartridge": "motorway_kings_neo_ignite",
	"sealed_product": "goblin_kart_canopy_wave",
}

var load_error: String = ""

var _templates_by_id: Dictionary = {}
var _templates_by_definition_id: Dictionary = {}
var _templates_by_platform_id: Dictionary = {}
var _templates_by_platform_visual_id: Dictionary = {}
var _platforms_by_visual_id: Dictionary = {}
var _platform_visual_by_platform_id: Dictionary = {}
var _aliases_by_id: Dictionary = {}


## Loads the checked-in visual-only catalog.
static func load_default() -> RefCounted:
	return load_from_path(DEFAULT_PATH)


## Loads a product visual catalog from a JSON file path.
static func load_from_path(path: String) -> RefCounted:
	var catalog_script: GDScript = load(SCRIPT_PATH)
	var catalog: RefCounted = catalog_script.new()
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		catalog.load_error = "Product visual catalog missing: %s" % path
		return catalog
	var text: String = file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if parsed is not Dictionary:
		catalog.load_error = "Product visual catalog did not parse as a Dictionary"
		return catalog
	catalog.load_from_dictionary(parsed as Dictionary)
	return catalog


## Rebuilds lookup indexes from parsed catalog data.
func load_from_dictionary(data: Dictionary) -> void:
	_templates_by_id.clear()
	_templates_by_definition_id.clear()
	_templates_by_platform_id.clear()
	_templates_by_platform_visual_id.clear()
	_platforms_by_visual_id.clear()
	_platform_visual_by_platform_id.clear()
	_aliases_by_id.clear()
	load_error = ""

	for raw_template: Variant in data.get("game_box_templates", []):
		if raw_template is not Dictionary:
			continue
		var template: Dictionary = (raw_template as Dictionary).duplicate(true)
		var template_id: String = str(template.get("template_id", ""))
		if template_id.is_empty():
			continue
		_templates_by_id[template_id] = template
		for raw_definition_id: Variant in template.get("catalog_definition_ids", []):
			var definition_id: String = str(raw_definition_id)
			if not definition_id.is_empty():
				_templates_by_definition_id[definition_id] = template
		var stripe: Dictionary = _as_dictionary(template.get("platform_stripe", {}))
		var platform_id: String = str(stripe.get("platform_id", ""))
		var visual_id: String = str(stripe.get("platform_visual_id", ""))
		if not platform_id.is_empty() and not _templates_by_platform_id.has(platform_id):
			_templates_by_platform_id[platform_id] = template
		if not visual_id.is_empty() and not _templates_by_platform_visual_id.has(visual_id):
			_templates_by_platform_visual_id[visual_id] = template

	for raw_identity: Variant in data.get("platform_visual_identities", []):
		if raw_identity is not Dictionary:
			continue
		var identity: Dictionary = (raw_identity as Dictionary).duplicate(true)
		var visual_id: String = str(identity.get("platform_visual_id", ""))
		var platform_id: String = str(identity.get("platform_id", ""))
		if not visual_id.is_empty():
			_platforms_by_visual_id[visual_id] = identity
		if not platform_id.is_empty() and not _platform_visual_by_platform_id.has(platform_id):
			_platform_visual_by_platform_id[platform_id] = identity

	for raw_alias: Variant in data.get("visual_aliases", []):
		if raw_alias is not Dictionary:
			continue
		var alias: Dictionary = (raw_alias as Dictionary).duplicate(true)
		var alias_id: String = str(alias.get("alias_id", ""))
		if not alias_id.is_empty():
			_aliases_by_id[alias_id] = alias


## Returns a duplicated game-case template by template id.
func get_template(template_id: String) -> Dictionary:
	return (_templates_by_id.get(template_id, {}) as Dictionary).duplicate(true)


## Returns a duplicated console/platform visual identity by visual id.
func get_platform_identity(platform_visual_id: String) -> Dictionary:
	return (_platforms_by_visual_id.get(platform_visual_id, {}) as Dictionary).duplicate(true)


## Resolves the console/platform identity for item metadata.
func get_platform_identity_for_item(item: Dictionary) -> Dictionary:
	var visual_id: String = str(item.get("platform_visual_id", ""))
	if not visual_id.is_empty():
		var by_visual: Dictionary = get_platform_identity(visual_id)
		if not by_visual.is_empty():
			return by_visual
	var platform_id: String = str(item.get("platform_id", ""))
	if not platform_id.is_empty():
		return (_platform_visual_by_platform_id.get(platform_id, {}) as Dictionary).duplicate(true)
	return {}


## Resolves the best reusable case template for item metadata.
func find_template_for_item(item: Dictionary) -> Dictionary:
	if item.is_empty():
		return {}
	var alias_id: String = str(item.get("visual_alias_id", item.get("alias_id", "")))
	if not alias_id.is_empty() and _aliases_by_id.has(alias_id):
		var alias: Dictionary = _aliases_by_id[alias_id]
		var alias_template: Dictionary = get_template(str(alias.get("box_art_key", "")))
		if not alias_template.is_empty():
			return alias_template
	var direct_key: String = str(item.get("box_art_key", ""))
	if not direct_key.is_empty():
		var direct_template: Dictionary = get_template(direct_key)
		if not direct_template.is_empty():
			return direct_template
	var definition_id: String = str(item.get("definition_id", item.get("id", "")))
	if not definition_id.is_empty() and _templates_by_definition_id.has(definition_id):
		return (_templates_by_definition_id[definition_id] as Dictionary).duplicate(true)
	var platform_id: String = str(item.get("platform_id", ""))
	if not platform_id.is_empty() and _templates_by_platform_id.has(platform_id):
		return (_templates_by_platform_id[platform_id] as Dictionary).duplicate(true)
	var platform_visual_id: String = str(item.get("platform_visual_id", ""))
	if not platform_visual_id.is_empty() and _templates_by_platform_visual_id.has(platform_visual_id):
		return (_templates_by_platform_visual_id[platform_visual_id] as Dictionary).duplicate(true)
	var category: String = _ShelfCategoryNormalizer.normalize(item.get("category", ""))
	var fallback_id: String = str(CATEGORY_FALLBACKS.get(category, ""))
	if not fallback_id.is_empty():
		return get_template(fallback_id)
	return {}


## Returns true when item metadata can resolve to a reusable case template.
func has_template_for_item(item: Dictionary) -> bool:
	return not find_template_for_item(item).is_empty()


static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return value as Dictionary
	return {}
