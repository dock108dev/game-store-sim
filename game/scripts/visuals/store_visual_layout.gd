## Data-only catalog for generated store layouts.
## Runtime instantiation belongs to StoreLayoutRuntime; this module only loads
## and filters placement dictionaries.
class_name StoreVisualLayout
extends RefCounted

const DEFAULT_PATH: String = "res://game/content/visuals/store_visual_layouts.json"
const SCRIPT_PATH: String = "res://game/scripts/visuals/store_visual_layout.gd"
const RETRO_GAMES_STARTER_LAYOUT: StringName = &"retro_games_starter_small"
const RETRO_GAMES_GROWTH_LAYOUT: StringName = &"retro_games_growth_unlocks"
const STOCK_STATE_FIRST_DELIVERY: StringName = &"first_delivery_stocked"
const STOCK_STATE_RESERVE: StringName = &"reserve"

var load_error: String = ""

var _layouts_by_id: Dictionary = {}


static func load_default() -> RefCounted:
	return load_from_path(DEFAULT_PATH)


static func load_from_path(path: String) -> RefCounted:
	var layout_script: GDScript = load(SCRIPT_PATH)
	var catalog: RefCounted = layout_script.new()
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		catalog.load_error = "Store visual layout catalog missing: %s" % path
		return catalog
	var text: String = file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if parsed is not Dictionary:
		catalog.load_error = "Store visual layout catalog did not parse as a Dictionary"
		return catalog
	catalog.load_from_dictionary(parsed as Dictionary)
	return catalog


func load_from_dictionary(data: Dictionary) -> void:
	_layouts_by_id.clear()
	load_error = ""
	for raw_entry: Variant in data.get("entries", []):
		if raw_entry is not Dictionary:
			continue
		var entry: Dictionary = (raw_entry as Dictionary).duplicate(true)
		var layout_id: StringName = StringName(str(entry.get("layout_id", "")))
		if String(layout_id).is_empty():
			continue
		_layouts_by_id[layout_id] = entry


func get_layout_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for raw_id: Variant in _layouts_by_id.keys():
		ids.append(raw_id as StringName)
	ids.sort()
	return ids


func has_layout(layout_id: StringName) -> bool:
	return _layouts_by_id.has(layout_id)


func get_layout(layout_id: StringName) -> Dictionary:
	return (_layouts_by_id.get(layout_id, {}) as Dictionary).duplicate(true)


func get_placements(
	layout_id: StringName, active_unlocks: Array[StringName] = []
) -> Array[Dictionary]:
	var layout: Dictionary = get_layout(layout_id)
	var result: Array[Dictionary] = []
	for raw_placement: Variant in layout.get("placements", []):
		if raw_placement is not Dictionary:
			continue
		var placement: Dictionary = (raw_placement as Dictionary).duplicate(true)
		if _placement_is_unlocked(placement, active_unlocks):
			result.append(placement)
	return result


## Returns the first fixture placement whose fixture_id matches `fixture_id`.
func get_fixture_placement(
	layout_id: StringName, fixture_id: String, active_unlocks: Array[StringName] = []
) -> Dictionary:
	for placement: Dictionary in get_placements(layout_id, active_unlocks):
		if str(placement.get("fixture_id", "")) == fixture_id:
			return placement
	return {}


## Returns product placements, optionally filtered by stock_state.
func get_product_placements(
	layout_id: StringName, stock_state: StringName = &"", active_unlocks: Array[StringName] = []
) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for placement: Dictionary in get_placements(layout_id, active_unlocks):
		if str(placement.get("product_item_id", "")).is_empty():
			continue
		var placement_stock_state: StringName = StringName(str(placement.get("stock_state", "")))
		if not String(stock_state).is_empty() and placement_stock_state != stock_state:
			continue
		result.append(placement)
	result.sort_custom(_sort_product_placements_by_delivery_index)
	return result


## Returns product ids in the same order the layout declares delivery_index.
func get_product_item_ids(
	layout_id: StringName, stock_state: StringName = &"", active_unlocks: Array[StringName] = []
) -> PackedStringArray:
	var ids: PackedStringArray = []
	for placement: Dictionary in get_product_placements(layout_id, stock_state, active_unlocks):
		ids.append(str(placement.get("product_item_id", "")))
	return ids


func count_placements(layout_id: StringName, active_unlocks: Array[StringName] = []) -> int:
	return get_placements(layout_id, active_unlocks).size()


func _placement_is_unlocked(placement: Dictionary, active_unlocks: Array[StringName]) -> bool:
	var required_unlock: StringName = StringName(str(placement.get("required_unlock", "")))
	return String(required_unlock).is_empty() or active_unlocks.has(required_unlock)


func _sort_product_placements_by_delivery_index(a: Dictionary, b: Dictionary) -> bool:
	return int(a.get("delivery_index", 9999)) < int(b.get("delivery_index", 9999))
