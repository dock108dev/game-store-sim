extends GutTest

const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"
const StoreVisualLayoutScript: GDScript = preload(
	"res://game/scripts/visuals/store_visual_layout.gd"
)
const VisualValueUtilScript: GDScript = preload(
	"res://game/scripts/visuals/visual_value_util.gd"
)


func test_starter_display_contract_names_shared_merchandising_surface() -> void:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	var zone: Dictionary = _zone(catalog, "starter_display")
	assert_eq(zone.get("position"), [-4.10, 0.0, -1.20])
	assert_eq(zone.get("rotation_degrees"), [0.0, -8.0, 0.0])
	for allowed_role: String in [
		"fixture",
		"product_display",
		"visual_dressing",
		"customer_path",
		"route_cue",
	]:
		assert_true((zone.get("allows", []) as Array).has(allowed_role), allowed_role)

	var restock: Dictionary = _contract(catalog, "store_session_restock_shelf")
	assert_eq(str(restock.get("aligned_with_fixture_id", "")), "starter_display_table")
	assert_true((restock.get("required_nodes", []) as Array).has("StoreSessionRestockShelf"))
	assert_true(
		(restock.get("required_nodes", []) as Array).has(
			"StoreSessionRestockShelf/StaticBody3D"
		)
	)

	var products: Dictionary = _contract(catalog, "starter_product_display")
	assert_eq(str(products.get("zone_id", "")), "starter_display")
	assert_eq(str(products.get("supported_by", "")), "starter_display_table")

	for object_id: String in ["starter_display_browse_waypoint", "starter_display_route_cue"]:
		var entry: Dictionary = _contract(catalog, object_id)
		assert_eq(str(entry.get("zone_id", "")), "starter_display", object_id)
		assert_eq(str(entry.get("aligned_with_fixture_id", "")), "starter_display_table", object_id)


func test_starter_products_and_tabletop_props_live_inside_display_zone() -> void:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	var zone: Dictionary = _zone(catalog, "starter_display")
	for fixture_id: String in [
		"starter_display_table",
		"starter_acrylic_stand",
		"starter_controller_bin",
	]:
		var placement: Dictionary = catalog.call(
			"get_fixture_placement", StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT, fixture_id
		)
		assert_eq(str(placement.get("zone", "")), "starter_display", fixture_id)
		_assert_position_inside_zone(_position(placement), zone, fixture_id)

	var products: Array[Dictionary] = catalog.call(
		"get_product_placements", StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT
	)
	assert_eq(products.size(), 5)
	for placement: Dictionary in products:
		var label: String = str(placement.get("name", ""))
		assert_eq(str(placement.get("zone", "")), "starter_display", label)
		assert_eq(str(placement.get("route_role", "")), "starter_sale_item", label)
		_assert_position_inside_zone(_position(placement), zone, label)
		assert_gt(_position(placement).z, -2.40, "%s must not drift to the rear wall" % label)


func test_merchandise_footprints_stay_clear_of_unrelated_day_one_zones() -> void:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	var zones: Dictionary = catalog.call(
		"get_named_zones", StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT
	)
	var unrelated_zone_ids := PackedStringArray(["queue_lane", "checkout", "entrance", "stockroom"])
	var merchandise: Array[Dictionary] = [
		catalog.call(
			"get_fixture_placement",
			StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT,
			"starter_acrylic_stand",
		),
		catalog.call(
			"get_fixture_placement",
			StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT,
			"starter_controller_bin",
		),
	]
	merchandise.append_array(
		catalog.call("get_product_placements", StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT)
	)

	var route: Dictionary = zones.get("customer_route_core", {}) as Dictionary
	for placement: Dictionary in merchandise:
		var label: String = _placement_label(placement)
		var position: Vector3 = _position(placement)
		for zone_id: String in unrelated_zone_ids:
			assert_false(_point_inside_box_zone(position, zones.get(zone_id, {}) as Dictionary), label)
		assert_gt(
			_distance_to_polyline(position, route),
			0.62,
			"%s must dress the table edge without blocking the route core" % label
		)


func test_scene_keeps_restock_target_and_browse_marker_on_display_anchor() -> void:
	var saved_state: GameManager.State = GameManager.current_state
	GameManager.current_state = GameManager.State.STORE_VIEW
	StoreSessionState.reset_new_run()
	var scene: PackedScene = load(SCENE_PATH)
	assert_not_null(scene, "Store scene must load")
	if scene == null:
		GameManager.current_state = saved_state
		return
	var root: Node3D = scene.instantiate() as Node3D
	add_child(root)
	await get_tree().process_frame
	await get_tree().process_frame

	var shelf: Node3D = root.get_node_or_null("StoreSessionRestockShelf") as Node3D
	var body: StaticBody3D = (
		root.get_node_or_null("StoreSessionRestockShelf/StaticBody3D") as StaticBody3D
	)
	var browse: Marker3D = root.get_node_or_null("CustomerNavConfig/BrowseWaypoint01") as Marker3D
	var cue: Node3D = (
		root.get_node_or_null(
			"ExpandableStoreShell/OnboardingRouteCues/StarterShelfLocalFloorWear"
		) as Node3D
	)
	assert_not_null(shelf, "Restock shelf must remain the gameplay target")
	assert_not_null(body, "Restock shelf collision body must remain under the target")
	assert_not_null(browse, "Starter browse waypoint must remain authored")
	assert_not_null(cue, "Local starter route cue must render")
	if shelf == null or body == null or browse == null or cue == null:
		root.free()
		StoreSessionState.reset_new_run()
		GameManager.current_state = saved_state
		return

	_assert_near(shelf.global_position, Vector3(-4.10, 0.0, -1.20), 0.02, "restock shelf")
	_assert_near(body.global_position, shelf.global_position, 0.02, "restock collision")
	_assert_near(browse.global_position, Vector3(-4.10, 0.05, -1.20), 0.02, "browse waypoint")
	_assert_position_inside_zone(
		cue.global_position,
		_zone(StoreVisualLayoutScript.load_default(), "starter_display"),
		"route cue"
	)
	root.free()
	StoreSessionState.reset_new_run()
	GameManager.current_state = saved_state


func _contract(catalog: RefCounted, object_id: String) -> Dictionary:
	for entry: Dictionary in catalog.call(
		"get_placement_contracts", StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT
	):
		if str(entry.get("object_id", "")) == object_id:
			return entry
	return {}


func _zone(catalog: RefCounted, zone_id: String) -> Dictionary:
	var zones: Dictionary = catalog.call(
		"get_named_zones", StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT
	) as Dictionary
	return zones.get(zone_id, {}) as Dictionary


func _position(placement: Dictionary) -> Vector3:
	return VisualValueUtilScript.vector3_from_exact_array(
		placement.get("position", []), Vector3.ZERO
	)


func _placement_label(placement: Dictionary) -> String:
	for key: String in ["fixture_id", "product_item_id", "name"]:
		var value: String = str(placement.get(key, ""))
		if not value.is_empty():
			return value
	return "<unnamed>"


func _assert_position_inside_zone(position: Vector3, zone: Dictionary, label: String) -> void:
	assert_false(zone.is_empty(), "Zone must exist")
	if zone.is_empty():
		return
	assert_true(_point_inside_box_zone(position, zone), "%s must be inside starter display" % label)


func _point_inside_box_zone(position: Vector3, zone: Dictionary) -> bool:
	var min_bound: Vector3 = VisualValueUtilScript.vector3_from_exact_array(
		zone.get("min", []), Vector3.ZERO
	)
	var max_bound: Vector3 = VisualValueUtilScript.vector3_from_exact_array(
		zone.get("max", []), Vector3.ZERO
	)
	return (
		position.x >= min_bound.x
		and position.x <= max_bound.x
		and position.z >= min_bound.z
		and position.z <= max_bound.z
	)


func _distance_to_polyline(position: Vector3, route: Dictionary) -> float:
	var points: Array = route.get("points", []) as Array
	var best: float = INF
	for index: int in range(points.size() - 1):
		var start: Vector3 = VisualValueUtilScript.vector3_from_exact_array(
			points[index], Vector3.ZERO
		)
		var end: Vector3 = VisualValueUtilScript.vector3_from_exact_array(
			points[index + 1], Vector3.ZERO
		)
		best = minf(best, _distance_to_segment(position, start, end))
	return best


func _distance_to_segment(position: Vector3, start: Vector3, end: Vector3) -> float:
	var point := Vector2(position.x, position.z)
	var segment_start := Vector2(start.x, start.z)
	var segment_end := Vector2(end.x, end.z)
	var segment := segment_end - segment_start
	var length_squared := segment.length_squared()
	if length_squared <= 0.0001:
		return point.distance_to(segment_start)
	var t: float = clampf((point - segment_start).dot(segment) / length_squared, 0.0, 1.0)
	return point.distance_to(segment_start + segment * t)


func _assert_near(actual: Vector3, expected: Vector3, tolerance: float, label: String) -> void:
	assert_almost_eq(actual.x, expected.x, tolerance, "%s.x" % label)
	assert_almost_eq(actual.y, expected.y, tolerance, "%s.y" % label)
	assert_almost_eq(actual.z, expected.z, tolerance, "%s.z" % label)
