extends GutTest

const StoreVisualKitScript: GDScript = preload("res://game/scripts/visuals/store_visual_kit.gd")
const StoreVisualLayoutScript: GDScript = preload(
	"res://game/scripts/visuals/store_visual_layout.gd"
)


func test_default_layout_catalog_loads_retro_games_starter_layout() -> void:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	assert_eq(str(catalog.get("load_error")), "")
	assert_true(
		catalog.call("has_layout", StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT),
		"Retro Games starter layout should be registered"
	)


func test_layout_loader_surfaces_load_error_as_warning() -> void:
	var source: String = _read_text("res://game/scripts/visuals/store_visual_layout.gd")
	assert_string_contains(source, "push_warning(catalog.load_error)")
	assert_string_contains(source, "Store visual layout catalog missing")
	assert_string_contains(source, "Store visual layout catalog did not parse")


func test_retro_games_starter_layout_stays_small_and_uses_kit_visuals() -> void:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	var starter_ids: Array[StringName] = StoreVisualKitScript.starter_store_ids()
	var placements: Array[Dictionary] = catalog.call(
		"get_placements", StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT
	)
	assert_eq(placements.size(), 16)

	var visual_counts: Dictionary = {}
	var product_item_ids: PackedStringArray = []
	for placement: Dictionary in placements:
		var visual_id: StringName = StringName(str(placement.get("visual_id", "")))
		var product_item_id: String = str(placement.get("product_item_id", ""))
		if product_item_id.is_empty():
			assert_true(starter_ids.has(visual_id), "%s should come from starter kit" % visual_id)
			visual_counts[visual_id] = int(visual_counts.get(visual_id, 0)) + 1
		else:
			product_item_ids.append(product_item_id)

	assert_eq(int(visual_counts.get(StoreVisualKitScript.DISPLAY_TABLE, 0)), 1)
	assert_eq(int(visual_counts.get(StoreVisualKitScript.CHECKOUT_COUNTER, 0)), 1)
	assert_eq(int(visual_counts.get(StoreVisualKitScript.REGISTER, 0)), 1)
	assert_eq(int(visual_counts.get(StoreVisualKitScript.CARD_READER, 0)), 1)
	assert_eq(int(visual_counts.get(StoreVisualKitScript.RECEIPT_PRINTER, 0)), 1)
	assert_eq(int(visual_counts.get(StoreVisualKitScript.ACRYLIC_STAND, 0)), 1)
	assert_eq(int(visual_counts.get(StoreVisualKitScript.CONTROLLER_BIN_PROP, 0)), 1)
	assert_eq(int(visual_counts.get(StoreVisualKitScript.REPAIR_TESTING_MAT, 0)), 1)
	assert_eq(int(visual_counts.get(StoreVisualKitScript.CLIPBOARD, 0)), 1)
	assert_eq(int(visual_counts.get(StoreVisualKitScript.TAPED_BOX_LABEL, 0)), 1)
	assert_eq(int(visual_counts.get(StoreVisualKitScript.SECURITY_TAG_BLOCK, 0)), 1)
	assert_eq(
		product_item_ids,
		PackedStringArray(
			[
				"console_neo_ignite",
				"neo_ignite_motorway_kings_loose",
				"neo_ignite_kingdom_embers_loose",
				"neo_ignite_torque_force_3_loose",
				"neo_ignite_gridiron_2005_loose",
			]
		)
	)

	for product_item_id: String in product_item_ids:
		var product_placement: Dictionary = {}
		for placement: Dictionary in placements:
			if str(placement.get("product_item_id", "")) == product_item_id:
				product_placement = placement
				break
		assert_true(bool(product_placement.get("show_price_tag", false)))
		assert_eq(str(product_placement.get("route_role", "")), "starter_sale_item")


func test_retro_games_starter_layout_declares_sparse_first_delivery_contract() -> void:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	var first_delivery_ids: PackedStringArray = catalog.call(
		"get_product_item_ids",
		StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT,
		StoreVisualLayoutScript.STOCK_STATE_FIRST_DELIVERY,
	)
	var reserve_ids: PackedStringArray = catalog.call(
		"get_product_item_ids",
		StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT,
		StoreVisualLayoutScript.STOCK_STATE_RESERVE,
	)
	assert_eq(first_delivery_ids, StoreSessionController.starter_first_delivery_item_ids())
	assert_eq(reserve_ids, StoreSessionController.starter_reserve_item_ids())

	var first_delivery: Array[Dictionary] = catalog.call(
		"get_product_placements",
		StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT,
		StoreVisualLayoutScript.STOCK_STATE_FIRST_DELIVERY,
	)
	for index: int in range(first_delivery.size()):
		assert_eq(int(first_delivery[index].get("delivery_index", -1)), index)


func test_starter_fixture_layout_matches_generated_shell_anchor_contract() -> void:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	var display_table: Dictionary = catalog.call(
		"get_fixture_placement",
		StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT,
		"starter_display_table",
	)
	var checkout_counter: Dictionary = catalog.call(
		"get_fixture_placement",
		StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT,
		"starter_checkout_counter",
	)
	assert_eq(display_table.get("position"), [-4.10, 0.0, -1.20])
	assert_eq(display_table.get("rotation_degrees"), [0.0, -8.0, 0.0])
	assert_eq(checkout_counter.get("position"), [5.65, 0.0, 6.15])
	assert_eq(checkout_counter.get("rotation_degrees"), [0.0, 0.0, 0.0])


func test_starter_layout_preserves_physical_contract_metadata() -> void:
	var contract: Dictionary = _starter_physical_contract()
	assert_eq(int(contract.get("schema_version", 0)), 1)
	assert_eq(str(contract.get("coordinate_space", "")), "godot_world_xz")
	assert_eq(str(contract.get("units", "")), "meters")

	var store_bounds: Dictionary = contract.get("store_bounds", {}) as Dictionary
	assert_eq(store_bounds.get("min"), [-8.0, 0.0, -10.0])
	assert_eq(store_bounds.get("max"), [8.0, 3.5, 10.0])
	assert_eq(store_bounds.get("player_bounds_min"), [-7.45, 0.0, -9.35])
	assert_eq(store_bounds.get("player_bounds_max"), [7.45, 0.0, 9.05])

	var facings: Dictionary = contract.get("facing_directions", {}) as Dictionary
	for direction: String in ["north", "south", "east", "west"]:
		assert_true(facings.has(direction), "%s must be a canonical facing" % direction)
		var facing: Dictionary = facings.get(direction, {}) as Dictionary
		assert_eq((facing.get("vector", []) as Array).size(), 3)
		assert_true(facing.has("yaw_degrees"))


func test_starter_physical_contract_declares_required_day_one_zones() -> void:
	var contract: Dictionary = _starter_physical_contract()
	var zone_ids: PackedStringArray = _zone_ids(contract)
	var required_zones := PackedStringArray(
		[
			"sales_floor",
			"checkout",
			"queue_lane",
			"stockroom",
			"starter_display",
			"entrance",
			"customer_route_core",
			"staff_route_core",
			"reserved_navigation_player_bounds",
		]
	)
	for zone_id: String in required_zones:
		assert_true(zone_ids.has(zone_id), "%s zone must be declared" % zone_id)

	for raw_zone: Variant in contract.get("zones", []):
		assert_true(raw_zone is Dictionary)
		var zone: Dictionary = raw_zone as Dictionary
		assert_false(str(zone.get("zone_id", "")).is_empty())
		assert_false(str(zone.get("shape", "")).is_empty())
		if zone.get("shape") == "box":
			assert_eq((zone.get("position", []) as Array).size(), 3)
			assert_eq((zone.get("size", []) as Array).size(), 3)
			assert_eq((zone.get("min", []) as Array).size(), 3)
			assert_eq((zone.get("max", []) as Array).size(), 3)


func test_starter_physical_contract_covers_day_one_object_families() -> void:
	var contract: Dictionary = _starter_physical_contract()
	var roles: PackedStringArray = _contract_roles(contract)
	var required_roles := PackedStringArray(
		[
			"checkout_station",
			"manager_staff_spot",
			"queue_marker",
			"queue_prop",
			"stockroom_wall",
			"stockroom_doorway",
			"stockroom_contents",
			"starter_display",
			"product_display",
			"route_corridor",
			"sightline",
		]
	)
	for role: String in required_roles:
		assert_true(roles.has(role), "%s must have a placement contract" % role)

	var checkout: Dictionary = _contract_for_object(contract, "starter_checkout_counter")
	var service_point_ids: PackedStringArray = _service_point_ids(checkout)
	assert_true(service_point_ids.has("checkout_customer_spot"))
	assert_true(service_point_ids.has("checkout_staff_spot"))

	var no_overlap: Array = contract.get("no_overlap", [])
	var clearance_rules: Array = contract.get("clearance_rules", [])
	assert_gte(no_overlap.size(), 3)
	assert_gte(clearance_rules.size(), 3)


func test_starter_physical_placement_contracts_are_answerable() -> void:
	var contract: Dictionary = _starter_physical_contract()
	for raw_contract: Variant in contract.get("placement_contracts", []):
		assert_true(raw_contract is Dictionary)
		var entry: Dictionary = raw_contract as Dictionary
		var object_id: String = str(entry.get("object_id", ""))
		assert_false(object_id.is_empty())
		assert_false((entry.get("selector", {}) as Dictionary).is_empty(), object_id)
		assert_false(str(entry.get("zone_id", "")).is_empty(), object_id)
		assert_false(str(entry.get("physical_role", "")).is_empty(), object_id)
		assert_true(
			entry.has("position") or entry.has("positions") or entry.has("position_source"),
			"%s must declare where it is or how to read placement position" % object_id
		)

		var footprint: Dictionary = entry.get("footprint", {}) as Dictionary
		assert_false(footprint.is_empty(), "%s must declare a footprint" % object_id)
		assert_true(
			footprint.has("size") or footprint.has("corridor_width"),
			"%s must declare footprint size" % object_id
		)
		assert_false((entry.get("facing", {}) as Dictionary).is_empty(), object_id)
		assert_false((entry.get("clearance", {}) as Dictionary).is_empty(), object_id)

		var constraints: Dictionary = entry.get("constraints", {}) as Dictionary
		assert_false(constraints.is_empty(), "%s must declare constraints" % object_id)
		assert_true(
			constraints.has("must_not_overlap_roles")
			or constraints.has("may_overlap_roles")
			or constraints.has("ignore_no_overlap_with_parent")
			or constraints.has("must_remain_open"),
			"%s must declare no-overlap behavior" % object_id
		)


func test_starter_placements_declare_physical_fields_and_contract_coverage() -> void:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	var zones: Dictionary = catalog.call(
		"get_named_zones", StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT
	)
	var placements: Array[Dictionary] = catalog.call(
		"get_placements", StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT
	)
	for placement: Dictionary in placements:
		var placement_id: String = _placement_id(placement)
		var zone_id: String = str(placement.get("zone", ""))
		assert_false(zone_id.is_empty(), "%s missing field: zone" % placement_id)
		assert_true(zones.has(zone_id), "%s references unknown zone %s" % [placement_id, zone_id])
		assert_eq(
			(placement.get("position", []) as Array).size(),
			3,
			"%s missing field: position" % placement_id
		)
		assert_eq(
			(placement.get("rotation_degrees", []) as Array).size(),
			3,
			"%s missing field: rotation_degrees" % placement_id
		)
		var matches: Array[Dictionary] = catalog.call(
			"get_matching_placement_contracts",
			StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT,
			placement,
		)
		assert_true(
			matches.size() > 0 or bool(placement.get("physical_contract_exempt", false)),
			"%s missing contract: no matching placement_contract" % placement_id
		)


func test_starter_checkout_layout_declares_named_device_pieces() -> void:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	for component: Dictionary in StoreVisualKitScript.starter_checkout_station_components():
		var fixture_id: String = str(component.get("concept_id", ""))
		var placement: Dictionary = catalog.call(
			"get_fixture_placement",
			StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT,
			fixture_id,
		)
		assert_false(placement.is_empty(), "%s must be placed in the starter layout" % fixture_id)
		assert_eq(
			StringName(str(placement.get("visual_id", ""))),
			component.get("visual_id", &"") as StringName
		)
		assert_true(bool(placement.get("starter_owned", false)))
		if fixture_id != "starter_checkout_counter":
			assert_true(bool(placement.get("visual_only", false)))
			assert_eq(str(placement.get("parent_fixture_id", "")), "starter_checkout_counter")


func test_starter_layout_places_small_display_prop_kit() -> void:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	for component: Dictionary in StoreVisualKitScript.starter_small_display_prop_components():
		var fixture_id: String = str(component.get("concept_id", ""))
		var placement: Dictionary = catalog.call(
			"get_fixture_placement",
			StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT,
			fixture_id,
		)
		assert_false(placement.is_empty(), "%s must be placed in the starter layout" % fixture_id)
		assert_eq(
			StringName(str(placement.get("visual_id", ""))),
			component.get("visual_id", &"") as StringName
		)
		assert_true(bool(placement.get("starter_owned", false)))
		assert_true(bool(placement.get("visual_only", false)))
		assert_false(str(placement.get("zone", "")).is_empty())


func test_layout_catalog_does_not_expose_legacy_visual_apply_path() -> void:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	assert_false(
		catalog.has_method("apply_to"),
		"StoreLayoutRuntime is the SSOT for turning layout data into nodes"
	)


func test_unlock_gated_layout_entries_apply_only_when_unlock_is_active() -> void:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	var locked: Array[Dictionary] = catalog.call(
		"get_placements", StoreVisualLayoutScript.RETRO_GAMES_GROWTH_LAYOUT
	)
	assert_eq(locked.size(), 0)

	var unlocked: Array[Dictionary] = (
		catalog
		. call(
			"get_placements",
			StoreVisualLayoutScript.RETRO_GAMES_GROWTH_LAYOUT,
			[&"upgrade:store_expansion"] as Array[StringName],
		)
	)
	assert_eq(unlocked.size(), 1)
	assert_eq(
		StringName(str(unlocked[0].get("visual_id", ""))),
		StoreVisualKitScript.QUEUE_LANE
	)
	assert_eq(str(unlocked[0].get("zone", "")), "growth_queue_endcap")


func _read_text(path: String) -> String:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	assert_not_null(file, "Source file should open: %s" % path)
	if file == null:
		return ""
	var text: String = file.get_as_text()
	file.close()
	return text


func _starter_physical_contract() -> Dictionary:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	var layout: Dictionary = catalog.call(
		"get_layout", StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT
	)
	assert_false(layout.is_empty(), "Starter layout must load")
	var contract: Dictionary = layout.get("physical_contract", {}) as Dictionary
	assert_false(contract.is_empty(), "Starter layout must preserve physical contract data")
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


func _service_point_ids(contract: Dictionary) -> PackedStringArray:
	var ids: PackedStringArray = []
	for raw_point: Variant in contract.get("service_points", []):
		if raw_point is Dictionary:
			ids.append(str((raw_point as Dictionary).get("point_id", "")))
	return ids


func _placement_id(placement: Dictionary) -> String:
	for key: String in ["fixture_id", "product_item_id", "name"]:
		var value: String = str(placement.get(key, ""))
		if not value.is_empty():
			return value
	return "<unnamed>"
