extends GutTest

const StoreVisualLayoutScript: GDScript = preload(
	"res://game/scripts/visuals/store_visual_layout.gd"
)
const VisualValueUtilScript: GDScript = preload("res://game/scripts/visuals/visual_value_util.gd")


func test_physical_contract_accessors_expose_named_sections() -> void:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	var layout_id: StringName = StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT

	assert_false((catalog.call("get_physical_contract", layout_id) as Dictionary).is_empty())
	assert_true((catalog.call("get_named_zones", layout_id) as Dictionary).has("checkout"))
	assert_true((catalog.call("get_facing_definitions", layout_id) as Dictionary).has("south"))
	assert_gte((catalog.call("get_placement_contracts", layout_id) as Array).size(), 10)
	assert_false((catalog.call("get_room_contract", layout_id, "stockroom") as Dictionary).is_empty())
	assert_eq((catalog.call("get_room_contracts", layout_id) as Array).size(), 1)
	assert_gte((catalog.call("get_no_overlap_rules", layout_id) as Array).size(), 3)
	assert_gte((catalog.call("get_clearance_rules", layout_id) as Array).size(), 3)
	assert_eq(
		str(
			(catalog.call("get_validation_metadata", layout_id) as Dictionary).get(
				"unknown_zone_severity", ""
			)
		),
		"error"
	)


func test_starter_physical_contract_passes_data_level_validation() -> void:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	var errors: PackedStringArray = catalog.call(
		"validate_physical_contract", StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT
	)
	assert_eq(Array(errors), [], "Starter physical contract should validate cleanly")


func test_queue_lane_contract_declares_front_right_inside_store_envelope() -> void:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	var layout_id: StringName = StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT
	var zones: Dictionary = catalog.call("get_named_zones", layout_id) as Dictionary
	var queue_zone: Dictionary = zones.get("queue_lane", {}) as Dictionary
	assert_eq(queue_zone.get("min"), [2.60, 0.0, 6.85])
	assert_eq(queue_zone.get("max"), [4.95, 2.4, 8.10])
	assert_true(bool(queue_zone.get("reserved", false)), "Queue lane must be reserved")

	var store_bounds: Dictionary = (
		(catalog.call("get_physical_contract", layout_id) as Dictionary).get(
			"store_bounds", {}
		) as Dictionary
	)
	for raw_position: Variant in (
		_contract_for_object(catalog, "queue_marker_positions").get("positions", []) as Array
	):
		var position: Vector3 = VisualValueUtilScript.vector3_from_exact_array(
			raw_position, Vector3.ZERO
		)
		_assert_inside_bounds(position, queue_zone, "marker position")
		_assert_inside_player_bounds(position, store_bounds, "marker position")
	var lane_position: Vector3 = VisualValueUtilScript.vector3_from_exact_array(
		_contract_for_object(catalog, "front_lane_queue").get("position", []), Vector3.ZERO
	)
	_assert_inside_bounds(lane_position, queue_zone, "FrontLaneQueue")
	_assert_inside_player_bounds(lane_position, store_bounds, "FrontLaneQueue")


func test_queue_lane_contract_names_explicit_overlap_exclusions() -> void:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	var zones: Dictionary = catalog.call(
		"get_named_zones", StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT
	)
	var queue_zone: Dictionary = zones.get("queue_lane", {}) as Dictionary
	var exclusions: Array = queue_zone.get("no_overlap_constraints", []) as Array
	assert_eq(exclusions.size(), 1, "Queue lane must declare one exclusion set")
	if exclusions.is_empty():
		return
	var exclusion: Dictionary = exclusions[0] as Dictionary
	var against_zones: Array = exclusion.get("against_zones", []) as Array
	for zone_id: String in [
		"entrance",
		"front_wall_mall_threshold",
		"stockroom",
		"starter_display",
	]:
		assert_true(against_zones.has(zone_id), "Queue lane must avoid %s" % zone_id)
	var against_roles: Array = exclusion.get("against_roles", []) as Array
	for role: String in [
		"checkout_station",
		"manager_staff_spot",
		"customer_service",
		"staff_service",
		"stockroom_wall",
		"stockroom_doorway",
		"stockroom_contents",
		"spawn",
		"door",
		"starter_display",
	]:
		assert_true(against_roles.has(role), "Queue lane must avoid %s" % role)


func test_stockroom_room_contract_declares_single_back_right_room() -> void:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	var layout_id: StringName = StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT
	var zones: Dictionary = catalog.call("get_named_zones", layout_id) as Dictionary
	var stockroom_zone: Dictionary = zones.get("stockroom", {}) as Dictionary
	var stockroom: Dictionary = catalog.call("get_room_contract", layout_id, "stockroom") as Dictionary
	assert_false(stockroom.is_empty(), "Stockroom room contract must be declared")
	assert_eq(str(stockroom.get("zone_id", "")), "stockroom")

	var bounds: Dictionary = stockroom.get("bounds", {}) as Dictionary
	assert_eq(bounds.get("position"), stockroom_zone.get("position"))
	assert_eq(bounds.get("size"), stockroom_zone.get("size"))
	assert_eq(bounds.get("min"), [1.25, 0.0, -9.95])
	assert_eq(bounds.get("max"), [7.50, 2.8, 1.25])

	var doorways: Array = stockroom.get("doorways", []) as Array
	assert_eq(doorways.size(), 1, "Stockroom must expose a single sales-floor doorway")
	if doorways.size() != 1:
		return
	var doorway: Dictionary = doorways[0] as Dictionary
	assert_eq(str(doorway.get("face", "")), "front")
	assert_eq(str(doorway.get("faces_zone", "")), "sales_floor")
	assert_eq(doorway.get("position"), [4.95, 0.06, 1.16])
	assert_eq((doorway.get("opening_bounds", {}) as Dictionary).get("max"), [5.725, 2.72, 1.25])
	assert_gte(float(doorway.get("clear_width_m", 0.0)), 1.35)
	assert_eq(str(doorway.get("threshold_node", "")), "ExpandableStoreShell/StockroomFloorTape")
	for node_path: String in [
		"ExpandableStoreShell/StockroomCoolDoorRevealLeft",
		"ExpandableStoreShell/StockroomCoolDoorRevealRight",
		"ExpandableStoreShell/StockroomCoolDoorRevealHeader",
		"ExpandableStoreShell/StockroomDoorJambRight",
	]:
		assert_true(
			(doorway.get("required_nodes", []) as Array).has(node_path),
			"Doorway must declare %s" % node_path
		)


func test_stockroom_room_contract_names_walls_contents_and_exclusions() -> void:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	var stockroom: Dictionary = catalog.call(
		"get_room_contract", StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT, "stockroom"
	)
	var walls: Dictionary = _room_entries_by_id(stockroom.get("walls", []) as Array, "wall_id")
	for wall_id: String in [
		"left_wall",
		"right_wall",
		"back_wall",
		"front_left_doorway_frame",
		"front_right_doorway_frame",
	]:
		assert_true(walls.has(wall_id), "%s wall contract must be declared" % wall_id)
		assert_false(((walls[wall_id] as Dictionary).get("required_nodes", []) as Array).is_empty())

	var left_wall: Dictionary = walls.get("left_wall", {}) as Dictionary
	assert_true(bool(left_wall.get("continuous_visual_span_required", false)))
	assert_eq(str(left_wall.get("span_from", "")), "sales_floor_stockroom_doorway")
	assert_eq(str(left_wall.get("span_to", "")), "back_wall")
	assert_lte(float(left_wall.get("connection_tolerance_m", 99.0)), 0.12)
	for wall_id: String in ["right_wall", "back_wall"]:
		assert_lte(float((walls[wall_id] as Dictionary).get("connection_tolerance_m", 99.0)), 0.12)

	var content_zones: Dictionary = _room_entries_by_id(
		stockroom.get("interior_content_zones", []) as Array, "zone_id"
	)
	for zone_id: String in [
		"pickup_bay",
		"receiving_table",
		"side_rack",
		"deep_rack",
		"pallet_storage",
		"ladder_parking",
	]:
		assert_true(content_zones.has(zone_id), "%s interior zone must be declared" % zone_id)

	var content_rules: Dictionary = _room_entries_by_id(
		stockroom.get("content_rules", []) as Array, "family_id"
	)
	for family_id: String in [
		"boxes",
		"metal_shelf",
		"receiving_table",
		"pickup_bay",
		"racks",
		"pallets",
		"ladder",
	]:
		assert_true(
			content_rules.has(family_id), "%s content family must be declared" % family_id
		)
		assert_true(
			bool(
				(content_rules[family_id] as Dictionary).get(
					"must_be_inside_room_bounds", false
				)
			)
		)
	assert_true(
		bool(
			(content_rules.get("doorway_threshold_props", {}) as Dictionary).get(
				"may_be_doorway_or_threshold_prop", false
			)
		),
		"Doorway and threshold props must be explicitly exempted from interior containment"
	)

	var exclusions: Array = stockroom.get("no_overlap_constraints", []) as Array
	assert_eq(exclusions.size(), 1)
	if exclusions.size() != 1:
		return
	var against_zones: Array = (
		(exclusions[0] as Dictionary).get("against_zones", []) as Array
	)
	for zone_id: String in [
		"checkout",
		"queue_lane",
		"entrance",
		"customer_route_core",
		"starter_display",
	]:
		assert_true(against_zones.has(zone_id), "Stockroom must avoid %s" % zone_id)


func test_reserved_routes_service_points_and_rules_reference_declared_targets() -> void:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	var layout_id: StringName = StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT
	var zones: Dictionary = catalog.call("get_named_zones", layout_id) as Dictionary
	var roles: Dictionary = _known_roles(catalog.call("get_placement_contracts", layout_id) as Array)
	var service_points: Dictionary = _known_service_points(
		catalog.call("get_placement_contracts", layout_id) as Array
	)

	for zone_id: String in ["customer_route_core", "staff_route_core"]:
		assert_true(zones.has(zone_id), "%s reserved route must be declared" % zone_id)
		assert_true(bool((zones[zone_id] as Dictionary).get("reserved", false)), zone_id)

	for rule: Dictionary in catalog.call("get_no_overlap_rules", layout_id):
		_assert_rule_refs(rule, zones, roles, "no-overlap")
	for rule: Dictionary in catalog.call("get_clearance_rules", layout_id):
		_assert_rule_refs(rule, zones, roles, "clearance")
		for point_id: String in rule.get("applies_to_service_points", []):
			assert_true(service_points.has(point_id), "clearance unknown service point: %s" % point_id)


func test_facing_contracts_cover_angled_display_and_checkout_sides() -> void:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	var layout_id: StringName = StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT
	var display_contract: Dictionary = _contract_for_object(catalog, "starter_display_table")
	assert_eq(
		float((display_contract.get("facing", {}) as Dictionary).get("yaw_degrees", 0.0)),
		-8.0
	)

	var checkout_contract: Dictionary = _contract_for_object(catalog, "starter_checkout_counter")
	var customer_point: Dictionary = _service_point(checkout_contract, "checkout_customer_spot")
	var staff_point: Dictionary = _service_point(checkout_contract, "checkout_staff_spot")
	assert_eq(str((customer_point.get("facing", {}) as Dictionary).get("direction", "")), "north")
	assert_eq(str((staff_point.get("facing", {}) as Dictionary).get("direction", "")), "south")

	var errors: PackedStringArray = catalog.call("validate_physical_contract", layout_id)
	assert_eq(Array(errors), [], "Facing validation should pass for starter contract")


func test_checkout_station_contract_declares_counter_spots_devices_and_clutter() -> void:
	var station: Dictionary = _checkout_station_contract()
	assert_false(station.is_empty(), "Checkout station object contract must be declared")
	assert_eq(str(station.get("zone_id", "")), "checkout")

	var gameplay_owner: Dictionary = station.get("gameplay_owner", {}) as Dictionary
	assert_eq(str(gameplay_owner.get("active_register_path", "")), "checkout_counter/Interactable")
	assert_true(bool(gameplay_owner.get("only_active_register_prompt", false)))
	assert_eq(str(gameplay_owner.get("authored_visual_register_path", "")), "Checkout/Register")
	assert_false(bool(gameplay_owner.get("authored_visual_register_enabled", true)))
	assert_true(bool(gameplay_owner.get("generated_visuals_are_visual_only", false)))

	var counter: Dictionary = station.get("counter", {}) as Dictionary
	assert_eq(str(counter.get("object_id", "")), "checkout_counter_body")
	assert_eq((counter.get("required_nodes", []) as Array).size(), 5)
	assert_eq(
		((counter.get("footprint", {}) as Dictionary).get("size", []) as Array),
		[2.85, 1.25, 1.25]
	)

	var spots: Dictionary = _station_entries_by_id(
		station.get("service_spots", []) as Array, "spot_id"
	)
	for spot_id: String in ["checkout_customer_service_spot", "checkout_employee_service_spot"]:
		assert_true(spots.has(spot_id), "%s must be declared" % spot_id)
	var customer_spot: Dictionary = spots.get("checkout_customer_service_spot", {}) as Dictionary
	var employee_spot: Dictionary = spots.get("checkout_employee_service_spot", {}) as Dictionary
	assert_eq(customer_spot.get("position"), [4.85, 0.0, 7.25])
	assert_eq(employee_spot.get("position"), [5.85, 0.0, 5.40])
	assert_gt(
		float((customer_spot.get("position", []) as Array)[2]),
		float((counter.get("position", []) as Array)[2])
	)
	assert_lt(
		float((employee_spot.get("position", []) as Array)[2]),
		float((counter.get("position", []) as Array)[2])
	)
	for role: String in ["manager_staff_spot", "queue_marker", "queue_prop"]:
		assert_true((customer_spot.get("distinguish_from_roles", []) as Array).has(role))

	var devices: Dictionary = _station_entries_by_id(
		station.get("device_footprints", []) as Array, "role"
	)
	for role: String in [
		"register_monitor",
		"receipt_printer",
		"card_reader",
		"cash_drawer",
		"barcode_scanner",
		"customer_payment_display",
	]:
		assert_true(devices.has(role), "%s device footprint must be declared" % role)
	var primary_count := 0
	for raw_device: Variant in station.get("device_footprints", []):
		if bool((raw_device as Dictionary).get("primary_device", false)):
			primary_count += 1
	assert_eq(primary_count, 4, "Primary checkout device contract must stay counter-readable")

	var clutter: Dictionary = station.get("clutter_cluster", {}) as Dictionary
	assert_eq(str(clutter.get("cluster_id", "")), "checkout_bounded_clutter")
	assert_lte(int(clutter.get("max_prominent_props", 99)), 2)
	assert_lte(float(clutter.get("max_countertop_coverage_ratio", 1.0)), 0.22)


func test_checkout_station_contract_keeps_actionable_looking_props_inert() -> void:
	var station: Dictionary = _checkout_station_contract()
	for raw_device: Variant in station.get("device_footprints", []):
		var device: Dictionary = raw_device as Dictionary
		var role: String = str(device.get("role", ""))
		assert_true(bool(device.get("visual_only", false)), "%s must be visual-only" % role)
		assert_false(bool(device.get("exposes_prompt", true)), "%s must not expose prompts" % role)
		assert_false(bool(device.get("exposes_highlight", true)), "%s must not expose highlights" % role)
		assert_eq(str(device.get("supported_by", "")), "checkout_counter_body")
		assert_false((device.get("required_nodes", []) as Array).is_empty(), role)
	var clutter: Dictionary = station.get("clutter_cluster", {}) as Dictionary
	assert_true(bool(clutter.get("visual_only", false)))
	assert_false(bool(clutter.get("exposes_prompt", true)))
	assert_false(bool(clutter.get("exposes_highlight", true)))


func test_checkout_station_contract_bounds_overlap_and_facing_policy() -> void:
	var station: Dictionary = _checkout_station_contract()
	var limits: Dictionary = station.get("limits", {}) as Dictionary
	assert_eq(int(limits.get("counter_count", 0)), 1)
	assert_lte(int(limits.get("max_primary_device_count", 99)), 4)
	assert_lte(int(limits.get("max_secondary_device_count", 99)), 2)
	assert_lte(int(limits.get("max_prominent_clutter_props", 99)), 2)
	for role: String in ["register_monitor", "receipt_printer", "card_reader", "cash_drawer"]:
		assert_true((limits.get("dedupe_roles", []) as Array).has(role), "%s must be deduped" % role)

	var no_overlap: Dictionary = station.get("no_overlap", {}) as Dictionary
	for zone_id: String in ["queue_lane", "entrance", "stockroom"]:
		assert_true(
			(no_overlap.get("checkout_objects_must_not_overlap_zones", []) as Array).has(zone_id),
			"Checkout objects must avoid %s" % zone_id
		)
	for role: String in [
		"manager_staff_spot",
		"customer_service",
		"employee_service",
		"queue_marker",
		"queue_prop",
		"stockroom_wall",
		"stockroom_doorway",
		"stockroom_contents",
	]:
		assert_true(
			(no_overlap.get("checkout_objects_must_not_overlap_roles", []) as Array).has(role),
			"Checkout objects must avoid %s" % role
		)
	assert_eq(
		str(no_overlap.get("active_register_interaction_anchor", "")),
		"checkout_counter/Interactable"
	)
	for object_id: String in [
		"checkout_register_monitor",
		"checkout_receipt_printer",
		"checkout_card_reader",
		"checkout_cash_drawer",
		"checkout_bounded_clutter",
	]:
		assert_true(
			(no_overlap.get("allowed_supported_on_counter_overlap", []) as Array).has(object_id),
			"%s must be explicitly declared as counter-supported" % object_id
		)

	var devices: Dictionary = _station_entries_by_id(
		station.get("device_footprints", []) as Array, "role"
	)
	assert_eq(str((devices["register_monitor"] as Dictionary).get("facing_side", "")), "staff")
	assert_eq(str((devices["receipt_printer"] as Dictionary).get("facing_side", "")), "staff")
	assert_eq(str((devices["cash_drawer"] as Dictionary).get("facing_side", "")), "staff")
	assert_eq(str((devices["card_reader"] as Dictionary).get("facing_side", "")), "customer")
	assert_eq(
		str((devices["customer_payment_display"] as Dictionary).get("facing_side", "")),
		"customer"
	)
	for raw_device: Variant in station.get("device_footprints", []):
		var device: Dictionary = raw_device as Dictionary
		var facing: Dictionary = device.get("facing", {}) as Dictionary
		assert_false(facing.is_empty(), "%s must declare facing" % str(device.get("role", "")))
		assert_lte(float(facing.get("tolerance_degrees", 99.0)), 25.0)


func test_validation_failures_identify_offending_contract_and_reason() -> void:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	var broken_catalog: RefCounted = StoreVisualLayoutScript.new()
	var broken_layout: Dictionary = catalog.call(
		"get_layout", StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT
	)
	broken_layout["layout_id"] = "validation_failure_probe"
	_break_contract(broken_layout)
	broken_catalog.call("load_from_dictionary", {"entries": [broken_layout]})

	var errors: PackedStringArray = broken_catalog.call(
		"validate_physical_contract", &"validation_failure_probe"
	)
	var error_message: String = str(Array(errors))
	assert_true(_contains_error(errors, "missing field", "starter_display_table"), error_message)
	assert_true(_contains_error(errors, "out-of-zone", "starter_checkout_counter"), error_message)
	assert_true(_contains_error(errors, "bad facing", "starter_checkout_counter"), error_message)
	assert_true(_contains_error(errors, "clearance", "missing_service_point"), error_message)
	assert_true(_contains_error(errors, "no-overlap", "missing_physical_role"), error_message)


func _break_contract(layout: Dictionary) -> void:
	var placements: Array = layout.get("placements", []) as Array
	(placements[0] as Dictionary).erase("position")
	(placements[1] as Dictionary)["position"] = [50.0, 0.0, 50.0]
	var contract: Dictionary = layout.get("physical_contract", {}) as Dictionary
	var placement_contracts: Array = contract.get("placement_contracts", []) as Array
	((placement_contracts[1] as Dictionary).get("facing", {}) as Dictionary)["tolerance_degrees"] = 1.0
	((placement_contracts[1] as Dictionary).get("facing", {}) as Dictionary)["yaw_degrees"] = 90.0
	var clearance: Array = contract.get("clearance_rules", []) as Array
	(clearance[0] as Dictionary)["applies_to_service_points"] = ["missing_service_point"]
	var no_overlap: Array = contract.get("no_overlap", []) as Array
	(no_overlap[0] as Dictionary)["against_roles"] = ["missing_physical_role"]


func _assert_inside_bounds(position: Vector3, bounds: Dictionary, label: String) -> void:
	var min_bound: Vector3 = VisualValueUtilScript.vector3_from_exact_array(
		bounds.get("min", []), Vector3.ZERO
	)
	var max_bound: Vector3 = VisualValueUtilScript.vector3_from_exact_array(
		bounds.get("max", []), Vector3.ZERO
	)
	assert_between(position.x, min_bound.x, max_bound.x, "%s X inside bounds" % label)
	assert_between(position.z, min_bound.z, max_bound.z, "%s Z inside bounds" % label)


func _assert_inside_player_bounds(
	position: Vector3, store_bounds: Dictionary, label: String
) -> void:
	var min_bound: Vector3 = VisualValueUtilScript.vector3_from_exact_array(
		store_bounds.get("player_bounds_min", []), Vector3.ZERO
	)
	var max_bound: Vector3 = VisualValueUtilScript.vector3_from_exact_array(
		store_bounds.get("player_bounds_max", []), Vector3.ZERO
	)
	assert_between(position.x, min_bound.x, max_bound.x, "%s X inside player bounds" % label)
	assert_between(position.z, min_bound.z, max_bound.z, "%s Z inside player bounds" % label)


func _known_roles(placement_contracts: Array) -> Dictionary:
	var roles: Dictionary = {}
	for raw_contract: Variant in placement_contracts:
		var entry: Dictionary = raw_contract as Dictionary
		roles[str(entry.get("physical_role", ""))] = true
	return roles


func _known_service_points(placement_contracts: Array) -> Dictionary:
	var points: Dictionary = {}
	for raw_contract: Variant in placement_contracts:
		for raw_point: Variant in (raw_contract as Dictionary).get("service_points", []):
			if raw_point is Dictionary:
				points[str((raw_point as Dictionary).get("point_id", ""))] = true
	return points


func _assert_rule_refs(
	rule: Dictionary, zones: Dictionary, roles: Dictionary, label: String
) -> void:
	for zone_id: String in rule.get("applies_to_zones", []):
		assert_true(zones.has(zone_id), "%s unknown zone: %s" % [label, zone_id])
	for zone_id: String in rule.get("against_zones", []):
		assert_true(zones.has(zone_id), "%s unknown zone: %s" % [label, zone_id])
	for role: String in rule.get("applies_to_roles", []):
		assert_true(roles.has(role), "%s unknown role: %s" % [label, role])
	for role: String in rule.get("against_roles", []):
		assert_true(roles.has(role), "%s unknown role: %s" % [label, role])


func _room_entries_by_id(entries: Array, key: String) -> Dictionary:
	var result: Dictionary = {}
	for raw_entry: Variant in entries:
		if raw_entry is Dictionary:
			var entry: Dictionary = raw_entry as Dictionary
			result[str(entry.get(key, ""))] = entry
	return result


func _contract_for_object(catalog: RefCounted, object_id: String) -> Dictionary:
	for raw_contract: Variant in catalog.call(
		"get_placement_contracts", StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT
	):
		var entry: Dictionary = raw_contract as Dictionary
		if str(entry.get("object_id", "")) == object_id:
			return entry
	return {}


func _service_point(contract: Dictionary, point_id: String) -> Dictionary:
	for raw_point: Variant in contract.get("service_points", []):
		var point: Dictionary = raw_point as Dictionary
		if str(point.get("point_id", "")) == point_id:
			return point
	return {}


func _checkout_station_contract() -> Dictionary:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	var contract: Dictionary = catalog.call(
		"get_physical_contract", StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT
	)
	for raw_station: Variant in contract.get("checkout_station_contracts", []):
		var station: Dictionary = raw_station as Dictionary
		if str(station.get("station_id", "")) == "front_right_checkout_station":
			return station
	return {}


func _station_entries_by_id(entries: Array, key: String) -> Dictionary:
	var result: Dictionary = {}
	for raw_entry: Variant in entries:
		if raw_entry is Dictionary:
			var entry: Dictionary = raw_entry as Dictionary
			result[str(entry.get(key, ""))] = entry
	return result


func _contains_error(errors: PackedStringArray, category: String, subject: String) -> bool:
	for error: String in errors:
		if error.contains(category) and error.contains(subject):
			return true
	return false
