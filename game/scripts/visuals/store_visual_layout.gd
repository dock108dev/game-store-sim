## Data-only catalog for generated store layouts.
## Runtime instantiation belongs to StoreLayoutRuntime; this module only loads
## and filters placement dictionaries.
class_name StoreVisualLayout
extends RefCounted

const DEFAULT_PATH: String = "res://game/content/visuals/store_visual_layouts.json"
const SCRIPT_PATH: String = "res://game/scripts/visuals/store_visual_layout.gd"
const PhysicalContractValidatorScript: GDScript = preload(
	"res://game/scripts/visuals/store_physical_contract_validator.gd"
)
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
		push_warning(catalog.load_error)
		return catalog
	var text: String = file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if parsed is not Dictionary:
		catalog.load_error = "Store visual layout catalog did not parse as a Dictionary"
		push_warning("%s: %s" % [catalog.load_error, path])
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


## Returns the optional authored physical contract for a layout.
func get_physical_contract(layout_id: StringName) -> Dictionary:
	var layout: Dictionary = get_layout(layout_id)
	return (layout.get("physical_contract", {}) as Dictionary).duplicate(true)


## Returns named physical zones keyed by zone_id.
func get_named_zones(layout_id: StringName) -> Dictionary:
	var zones: Dictionary = {}
	for raw_zone: Variant in get_physical_contract(layout_id).get("zones", []):
		if raw_zone is not Dictionary:
			continue
		var zone: Dictionary = raw_zone as Dictionary
		var zone_id: String = str(zone.get("zone_id", ""))
		if not zone_id.is_empty():
			zones[zone_id] = zone.duplicate(true)
	return zones


## Returns canonical facing definitions declared by the physical contract.
func get_facing_definitions(layout_id: StringName) -> Dictionary:
	return (
		(get_physical_contract(layout_id).get("facing_directions", {}) as Dictionary)
		.duplicate(true)
	)


## Returns placement contracts, filtered by required_unlock when present.
func get_placement_contracts(
	layout_id: StringName, active_unlocks: Array[StringName] = []
) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for raw_contract: Variant in get_physical_contract(layout_id).get("placement_contracts", []):
		if raw_contract is not Dictionary:
			continue
		var contract: Dictionary = (raw_contract as Dictionary).duplicate(true)
		if _entry_is_unlocked(contract, active_unlocks):
			result.append(contract)
	return result


## Returns no-overlap validation rules declared by the physical contract.
func get_no_overlap_rules(layout_id: StringName) -> Array[Dictionary]:
	return _duplicate_dictionary_array(get_physical_contract(layout_id).get("no_overlap", []))


## Returns room-level physical contracts declared by the layout.
func get_room_contracts(layout_id: StringName) -> Array[Dictionary]:
	return _duplicate_dictionary_array(get_physical_contract(layout_id).get("room_contracts", []))


## Returns the room-level contract with the requested room_id.
func get_room_contract(layout_id: StringName, room_id: String) -> Dictionary:
	for room: Dictionary in get_room_contracts(layout_id):
		if str(room.get("room_id", "")) == room_id:
			return room
	return {}


## Returns clearance validation rules declared by the physical contract.
func get_clearance_rules(layout_id: StringName) -> Array[Dictionary]:
	return _duplicate_dictionary_array(get_physical_contract(layout_id).get("clearance_rules", []))


## Returns validation metadata declared by the physical contract.
func get_validation_metadata(layout_id: StringName) -> Dictionary:
	return (get_physical_contract(layout_id).get("validation", {}) as Dictionary).duplicate(true)


## Returns placement contracts whose selector matches the supplied placement.
func get_matching_placement_contracts(
	layout_id: StringName, placement: Dictionary, active_unlocks: Array[StringName] = []
) -> Array[Dictionary]:
	var matches: Array[Dictionary] = []
	for contract: Dictionary in get_placement_contracts(layout_id, active_unlocks):
		if _selector_matches_placement(contract.get("selector", {}) as Dictionary, placement):
			matches.append(contract)
	return matches


## Returns placements that match a supplied placement contract selector.
func get_placements_matching_contract(
	layout_id: StringName, contract: Dictionary, active_unlocks: Array[StringName] = []
) -> Array[Dictionary]:
	var matches: Array[Dictionary] = []
	var selector: Dictionary = contract.get("selector", {}) as Dictionary
	for placement: Dictionary in get_placements(layout_id, active_unlocks):
		if _selector_matches_placement(selector, placement):
			matches.append(placement)
	return matches


## Validates data-level physical contract references, bounds, and facing metadata.
func validate_physical_contract(
	layout_id: StringName, active_unlocks: Array[StringName] = []
) -> PackedStringArray:
	return PhysicalContractValidatorScript.validate_layout(self, layout_id, active_unlocks)


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


func _placement_is_unlocked(placement: Dictionary, active_unlocks: Array[StringName]) -> bool:
	return _entry_is_unlocked(placement, active_unlocks)


func _entry_is_unlocked(entry: Dictionary, active_unlocks: Array[StringName]) -> bool:
	var required_unlock: StringName = StringName(str(entry.get("required_unlock", "")))
	return String(required_unlock).is_empty() or active_unlocks.has(required_unlock)


func _sort_product_placements_by_delivery_index(a: Dictionary, b: Dictionary) -> bool:
	return int(a.get("delivery_index", 9999)) < int(b.get("delivery_index", 9999))


func _duplicate_dictionary_array(raw_items: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for raw_item: Variant in raw_items:
		if raw_item is Dictionary:
			result.append((raw_item as Dictionary).duplicate(true))
	return result


func _selector_matches_placement(selector: Dictionary, placement: Dictionary) -> bool:
	var matched_selector: bool = false
	var matches: bool = true
	if selector.is_empty():
		return false
	if (
		selector.has("fixture_id")
		and str(placement.get("fixture_id", "")) != str(selector["fixture_id"])
	):
		matches = false
	matched_selector = matched_selector or selector.has("fixture_id")
	if selector.has("fixture_ids"):
		var fixture_ids: Array = selector.get("fixture_ids", []) as Array
		if not fixture_ids.has(str(placement.get("fixture_id", ""))):
			matches = false
		matched_selector = true
	if selector.has("parent_fixture_id") and (
		str(placement.get("parent_fixture_id", "")) != str(selector["parent_fixture_id"])
	):
		matches = false
	matched_selector = matched_selector or selector.has("parent_fixture_id")
	if selector.has("name") and str(placement.get("name", "")) != str(selector["name"]):
		matches = false
	matched_selector = matched_selector or selector.has("name")
	if selector.has("product_item_id"):
		var product_selector: String = str(selector["product_item_id"])
		var product_id: String = str(placement.get("product_item_id", ""))
		var product_matches: bool = (
			(product_selector == "*" and not product_id.is_empty())
			or product_id == product_selector
		)
		if not product_matches:
			matches = false
		matched_selector = true
	if selector.has("zone_id") and str(placement.get("zone", "")) != str(selector["zone_id"]):
		matches = false
	matched_selector = matched_selector or selector.has("zone_id")
	return matches and matched_selector
