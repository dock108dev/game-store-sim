extends GutTest

const StoreVisualLayoutScript: GDScript = preload(
	"res://game/scripts/visuals/store_visual_layout.gd"
)


func test_starter_physical_contract_declares_granular_overhaul_zones() -> void:
	var contract: Dictionary = _physical_contract(StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT)
	var zone_ids: PackedStringArray = _zone_ids(contract)
	for zone_id: String in [
		"storefront_full_width",
		"storefront_sign_band",
		"storefront_door_portal",
		"storefront_mall_approach",
		"storefront_entry_clearance",
		"front_window_left",
		"front_window_right",
		"front_window_display_left",
		"front_window_display_right",
		"front_window_sightline_left",
		"front_window_sightline_right",
		"queue_entry_pad",
		"queue_wait_spot_01",
		"queue_wait_spot_02",
		"queue_checkout_handoff",
		"queue_lane_clearance",
		"customer_holds_counter",
		"customer_holds_pickup_bay",
		"holds_labeling_surface",
		"staff_checkout_to_stockroom_path",
		"customer_route_entry_beat",
		"customer_route_browse_beat",
		"customer_route_checkout_beat",
		"featured_display",
	]:
		assert_true(zone_ids.has(zone_id), "%s zone must be declared" % zone_id)

	var roles: PackedStringArray = _contract_roles(contract)
	for role: String in [
		"store_sign",
		"door_frame",
		"entry_threshold",
		"entry_cue",
		"window_glass",
		"window_display_deck",
		"window_sightline",
		"customer_wait_spot",
		"queue_exit",
		"customer_hold_surface",
		"customer_hold_pickup",
		"hold_label_surface",
		"staff_path",
		"customer_route_beat",
		"featured_display",
	]:
		assert_true(roles.has(role), "%s must have a placement contract" % role)


func test_starter_physical_contract_distinguishes_action_and_dressing_contracts() -> void:
	var contract: Dictionary = _physical_contract(StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT)
	for object_id: String in [
		"storefront_door_frame",
		"storefront_entry_clearance",
		"front_left_window_glass",
		"front_left_window_sightline",
		"queue_entry_marker",
		"queue_lane_clearance_corridor",
		"customer_holds_counter",
		"staff_checkout_to_stockroom_path",
		"featured_display_surface",
	]:
		_assert_contract_shape(_contract_for_object(contract, object_id), object_id)


func test_growth_layout_declares_self_contained_physical_contract() -> void:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	var layout_id: StringName = StoreVisualLayoutScript.RETRO_GAMES_GROWTH_LAYOUT
	var contract: Dictionary = catalog.call("get_physical_contract", layout_id)
	assert_false(contract.is_empty(), "Growth layout must declare its own physical contract")
	assert_false((contract.get("store_bounds", {}) as Dictionary).is_empty())
	assert_gte((contract.get("zones", []) as Array).size(), 30)
	assert_gte((contract.get("room_contracts", []) as Array).size(), 1)
	assert_gte((contract.get("checkout_station_contracts", []) as Array).size(), 1)
	assert_gte((contract.get("placement_contracts", []) as Array).size(), 20)
	assert_gte((contract.get("no_overlap", []) as Array).size(), 3)
	assert_gte((contract.get("clearance_rules", []) as Array).size(), 3)
	assert_true(bool((contract.get("validation", {}) as Dictionary).get("complete_surface", false)))

	var facings: Dictionary = catalog.call("get_facing_definitions", layout_id) as Dictionary
	for direction: String in ["north", "south", "east", "west"]:
		assert_true(facings.has(direction), "%s must be a growth facing" % direction)

	var zones: Dictionary = catalog.call("get_named_zones", layout_id) as Dictionary
	for zone_id: String in [
		"sales_floor",
		"checkout",
		"queue_lane",
		"stockroom",
		"starter_display",
		"entrance",
		"front_wall_mall_threshold",
		"customer_route_core",
		"staff_route_core",
		"reserved_navigation_player_bounds",
		"spawn_sightline_core",
		"growth_feature_display",
		"growth_side_display",
		"expanded_wall_display",
		"growth_queue_endcap",
		"stockroom_upgrade_surface",
		"sales_floor_expansion_surface",
	]:
		assert_true(zones.has(zone_id), "%s growth zone must be declared" % zone_id)

	var locked_errors: PackedStringArray = catalog.call("validate_physical_contract", layout_id)
	assert_eq(Array(locked_errors), [], "Locked growth physical contract should validate cleanly")
	var unlocked_errors: PackedStringArray = catalog.call(
		"validate_physical_contract", layout_id, [&"upgrade:store_expansion"] as Array[StringName]
	)
	assert_eq(Array(unlocked_errors), [], "Unlocked growth physical contract should validate cleanly")


func test_growth_layout_contracts_cover_unlocked_expansion_placement() -> void:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	var layout_id: StringName = StoreVisualLayoutScript.RETRO_GAMES_GROWTH_LAYOUT
	var active_unlocks: Array[StringName] = [&"upgrade:store_expansion"]
	var placements: Array[Dictionary] = catalog.call("get_placements", layout_id, active_unlocks)
	assert_eq(placements.size(), 1)
	if placements.is_empty():
		return
	var placement: Dictionary = placements[0]
	var matches: Array[Dictionary] = catalog.call(
		"get_matching_placement_contracts", layout_id, placement, active_unlocks
	)
	assert_eq(matches.size(), 1)
	var entry: Dictionary = matches[0]
	assert_eq(str(entry.get("object_id", "")), "growth_queue_lane")
	assert_eq(str(entry.get("zone_id", "")), "growth_queue_endcap")
	assert_eq(str(entry.get("physical_role", "")), "queue_prop")
	assert_true(entry.has("action_critical"))
	assert_true(entry.has("visual_dressing"))


func _physical_contract(layout_id: StringName) -> Dictionary:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	var contract: Dictionary = catalog.call("get_physical_contract", layout_id)
	assert_false(contract.is_empty(), "Layout must preserve physical contract data")
	return contract


func _zone_ids(contract: Dictionary) -> PackedStringArray:
	var ids: PackedStringArray = []
	for raw_zone: Variant in contract.get("zones", []):
		if raw_zone is Dictionary:
			ids.append(str((raw_zone as Dictionary).get("zone_id", "")))
	return ids


func _contract_roles(contract: Dictionary) -> PackedStringArray:
	var roles: PackedStringArray = []
	for raw_contract: Variant in contract.get("placement_contracts", []):
		if raw_contract is Dictionary:
			roles.append(str((raw_contract as Dictionary).get("physical_role", "")))
	return roles


func _contract_for_object(contract: Dictionary, object_id: String) -> Dictionary:
	for raw_contract: Variant in contract.get("placement_contracts", []):
		if (
			raw_contract is Dictionary
			and str((raw_contract as Dictionary).get("object_id", "")) == object_id
		):
			return raw_contract as Dictionary
	return {}


func _assert_contract_shape(entry: Dictionary, object_id: String) -> void:
	assert_false(entry.is_empty(), "%s contract must exist" % object_id)
	assert_false((entry.get("selector", {}) as Dictionary).is_empty(), object_id)
	assert_false(str(entry.get("zone_id", "")).is_empty(), object_id)
	assert_false(str(entry.get("physical_role", "")).is_empty(), object_id)
	assert_false((entry.get("footprint", {}) as Dictionary).is_empty(), object_id)
	assert_false((entry.get("facing", {}) as Dictionary).is_empty(), object_id)
	assert_false((entry.get("clearance", {}) as Dictionary).is_empty(), object_id)
	assert_false((entry.get("constraints", {}) as Dictionary).is_empty(), object_id)
	assert_true(entry.has("action_critical"), "%s must classify action-critical use" % object_id)
	assert_true(entry.has("visual_dressing"), "%s must classify dressing use" % object_id)
