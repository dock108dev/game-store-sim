## Verifies retro_games.tscn navigation: nav mesh covers the expanded floor,
## CustomerNavConfig markers sit at their runtime-reflowed positions, and each
## furniture fixture carries a NavigationObstacle3D so customers steer
## around shelves and counters instead of clipping through them.
extends GutTest

const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"

const EXPECTED_WAYPOINTS: Dictionary = {
	"EntryPoint": Vector3(0.0, 0.05, 9.05),
	"BrowseWaypoint01": Vector3(-2.65, 0.05, 1.05),
	"BrowseWaypoint02": Vector3(-3.85, 0.05, -3.45),
	"BrowseWaypoint03": Vector3(0.40, 0.05, -1.35),
	"BrowseWaypoint04": Vector3(-4.45, 0.05, 2.65),
	"CheckoutApproach": Vector3(3.55, 0.05, 6.65),
	"ExitPoint": Vector3(0.0, 0.05, 9.05),
}

# Fixture root path -> expected NavigationObstacle3D radius. Path encodes
# whether the obstacle hangs off the StaticBody3D (preferred when a static
# body exists) or directly off the fixture root (testing_station and
# refurb_bench have no StaticBody3D).
const EXPECTED_OBSTACLES: Dictionary = {
	"CartRackLeft/StaticBody3D/NavigationObstacle3D": 1.3,
	"CartRackRight/StaticBody3D/NavigationObstacle3D": 1.3,
	"GlassCase/StaticBody3D/NavigationObstacle3D": 1.2,
	"ConsoleShelf/StaticBody3D/NavigationObstacle3D": 0.5,
	"AccessoriesBin/StaticBody3D/NavigationObstacle3D": 0.85,
	"Checkout/StaticBody3D/NavigationObstacle3D": 1.0,
	"testing_station/NavigationObstacle3D": 0.8,
	"refurb_bench/NavigationObstacle3D": 0.9,
}

var _root: Node3D = null


func before_all() -> void:
	var scene: PackedScene = load(SCENE_PATH)
	assert_not_null(scene, "Retro Games scene must load")
	if scene:
		_root = scene.instantiate() as Node3D
		ExpandableStoreShellRuntime.apply(_root)
		add_child(_root)


func after_all() -> void:
	if is_instance_valid(_root):
		_root.free()
	_root = null


# ── Baked navigation mesh has obstacle cutouts and covers the floor ─────────

func test_navigation_mesh_is_baked_with_obstacle_cutouts() -> void:
	var region: NavigationRegion3D = (
		_root.get_node_or_null("NavigationRegion3D") as NavigationRegion3D
	)
	assert_not_null(region, "NavigationRegion3D must exist")
	if region == null:
		return
	var nav_mesh: NavigationMesh = region.navigation_mesh
	assert_not_null(nav_mesh, "NavigationRegion3D must carry a NavigationMesh")
	if nav_mesh == null:
		return
	# A baked mesh with furniture cutouts must contain many polygons rather
	# than the prior single-quad stub that let customers walk through fixtures.
	assert_gt(
		nav_mesh.get_polygon_count(), 1,
		"Baked nav mesh must have more than one polygon (got %d)"
		% nav_mesh.get_polygon_count()
	)
	var vertices: PackedVector3Array = nav_mesh.vertices
	assert_gt(
		vertices.size(), 4,
		"Baked nav mesh must have more than 4 vertices (got %d)"
		% vertices.size()
	)
	# The bake walks just above the floor (Y ≈ 0.20 with cell_height = 0.1).
	# Confirm the surface is at ground level rather than sitting on the
	# ceiling slab or a floating platform.
	var min_x: float = INF
	var max_x: float = -INF
	var min_y: float = INF
	var max_y: float = -INF
	var min_z: float = INF
	var max_z: float = -INF
	for v: Vector3 in vertices:
		min_x = minf(min_x, v.x)
		max_x = maxf(max_x, v.x)
		min_y = minf(min_y, v.y)
		max_y = maxf(max_y, v.y)
		min_z = minf(min_z, v.z)
		max_z = maxf(max_z, v.z)
	assert_lt(min_y, 1.0, "Nav mesh min Y must be near ground (got %f)" % min_y)
	assert_lt(max_y, 2.0, "Nav mesh max Y must stay below ceiling (got %f)" % max_y)
	var bake_bounds: AABB = nav_mesh.filter_baking_aabb
	assert_eq(
		bake_bounds,
		AABB(Vector3(-5.6, -1.0, -7.25), Vector3(11.2, 2.5, 16.7)),
		"Nav mesh bake AABB must match the expanded runtime floor after agent inset"
	)
	assert_lt(min_x, -5.5, "Nav mesh must extend toward the expanded left aisle")
	assert_gt(max_x, 5.5, "Nav mesh must extend toward the expanded right aisle")
	assert_lt(min_z, -7.0, "Nav mesh must extend toward the stockroom work area")
	assert_gt(max_z, 9.0, "Nav mesh must extend toward the expanded entry side")


func test_navigation_mesh_is_external_resource() -> void:
	var scene_text: String = FileAccess.get_file_as_string(SCENE_PATH)
	assert_string_contains(
		scene_text,
		"path=\"res://game/navigation/retro_games_navmesh.tres\"",
		"retro_games.tscn must reference the external baked nav mesh"
	)
	assert_false(
		scene_text.contains("sub_resource type=\"NavigationMesh\""),
		"retro_games.tscn must not embed the nav mesh inline"
	)


# ── Customer waypoints ──────────────────────────────────────────────────────

func test_all_seven_customer_markers_exist_with_runtime_reflowed_positions() -> void:
	var nav_config: Node = _root.get_node_or_null("CustomerNavConfig")
	assert_not_null(nav_config, "CustomerNavConfig node must exist")
	if nav_config == null:
		return
	for marker_name: String in EXPECTED_WAYPOINTS:
		var marker: Marker3D = (
			nav_config.get_node_or_null(marker_name) as Marker3D
		)
		assert_not_null(
			marker,
			"CustomerNavConfig/%s must exist with exact case-matching name"
			% marker_name,
		)
		if marker == null:
			continue
		var expected: Vector3 = EXPECTED_WAYPOINTS[marker_name]
		assert_almost_eq(
			marker.global_position.x, expected.x, 0.001,
			"%s X position" % marker_name,
		)
		assert_almost_eq(
			marker.global_position.y, expected.y, 0.001,
			"%s Y position" % marker_name,
		)
		assert_almost_eq(
			marker.global_position.z, expected.z, 0.001,
			"%s Z position" % marker_name,
		)


func test_customer_nav_config_getters_return_runtime_reflowed_positions() -> void:
	var nav_config: CustomerNavConfig = (
		_root.get_node_or_null("CustomerNavConfig") as CustomerNavConfig
	)
	assert_not_null(nav_config, "CustomerNavConfig must resolve to script type")
	if nav_config == null:
		return
	# Auto-discovery runs in _ready(); the scene was added to the tree in
	# before_all, so the markers should be wired up by now.
	assert_almost_eq(
		nav_config.get_entry_position().distance_to(
			EXPECTED_WAYPOINTS["EntryPoint"]
		),
		0.0,
		0.001,
		"get_entry_position() must return runtime EntryPoint world position",
	)
	assert_almost_eq(
		nav_config.get_checkout_position().distance_to(
			EXPECTED_WAYPOINTS["CheckoutApproach"]
		),
		0.0,
		0.001,
		"get_checkout_position() must return runtime CheckoutApproach world position",
	)
	assert_almost_eq(
		nav_config.get_exit_position().distance_to(
			EXPECTED_WAYPOINTS["ExitPoint"]
		),
		0.0,
		0.001,
		"get_exit_position() must return runtime ExitPoint world position",
	)
	var browse: Array[Vector3] = nav_config.get_browse_positions()
	assert_eq(
		browse.size(), 4,
		"get_browse_positions() must return all 4 BrowseWaypoints",
	)
	for pos: Vector3 in browse:
		assert_ne(
			pos, Vector3.ZERO,
			"Browse position must not fall back to ZERO (missing marker)",
		)


func test_all_customer_waypoints_stay_out_of_staff_only_stock_closet() -> void:
	var nav_config: CustomerNavConfig = (
		_root.get_node_or_null("CustomerNavConfig") as CustomerNavConfig
	)
	assert_not_null(nav_config, "CustomerNavConfig must resolve to script type")
	if nav_config == null:
		return
	var markers: Array[Marker3D] = nav_config.get_customer_waypoint_markers()
	assert_gt(
		markers.size(), 0,
		"CustomerNavConfig must expose customer waypoint markers"
	)
	for marker: Marker3D in markers:
		assert_true(
			CustomerNavConfig.is_customer_position_allowed(
				marker.global_position
			),
			"%s must not route customers into the staff-only stock closet"
			% marker.name
		)


func test_day_one_customer_route_targets_stay_customer_allowed() -> void:
	var nav_config: CustomerNavConfig = (
		_root.get_node_or_null("CustomerNavConfig") as CustomerNavConfig
	)
	assert_not_null(nav_config, "CustomerNavConfig must resolve to script type")
	if nav_config == null:
		return
	var route_positions: Array[Vector3] = [
		nav_config.get_entry_position(),
		nav_config.get_checkout_position(),
		nav_config.get_exit_position(),
	]
	route_positions.append_array(nav_config.get_browse_positions())
	for position: Vector3 in route_positions:
		assert_true(
			CustomerNavConfig.is_customer_position_allowed(position),
			"Day-one customer route target must stay outside staff-only bounds"
		)


func test_stock_closet_remains_staff_and_player_reachable() -> void:
	var staff_backroom: Marker3D = (
		_root.get_node_or_null("StoreStaffConfig/BackroomPoint") as Marker3D
	)
	var pickup: Node3D = (
		_root.get_node_or_null("StoreSessionBackroomPickup") as Node3D
	)
	var pickup_interactable: Area3D = (
		_root.get_node_or_null("StoreSessionBackroomPickup/Interactable") as Area3D
	)
	var threshold: Node3D = (
		_root.get_node_or_null(
			"ReadabilityProps/ZoneIdentity/BackroomDoorThreshold"
		) as Node3D
	)
	assert_not_null(staff_backroom, "Backroom staff marker must exist")
	assert_not_null(pickup, "Stock pickup must exist")
	assert_not_null(pickup_interactable, "Stock pickup interactable must exist")
	assert_not_null(threshold, "Backroom threshold affordance must exist")
	if (
		staff_backroom == null
		or pickup == null
		or pickup_interactable == null
		or threshold == null
	):
		return
	assert_true(
		CustomerNavConfig.is_position_in_staff_only_zone(
			staff_backroom.global_position
		),
		"Staff backroom point must remain inside the staff-only closet"
	)
	assert_true(
		CustomerNavConfig.is_position_in_staff_only_zone(
			pickup.global_position
		),
		"Stock pickup must remain inside the staff-only closet"
	)
	assert_false(
		CustomerNavConfig.is_position_in_staff_only_zone(
			threshold.global_position
		),
		"Door threshold should remain outside the forbidden customer area"
	)
	assert_lt(
		_xz_distance(threshold.global_position, pickup.global_position),
		2.0,
		"Stock pickup must remain reachable from the backroom threshold"
	)


func test_checkout_queue_markers_share_register_flow() -> void:
	var register_area: Area3D = _root.get_node_or_null("RegisterArea") as Area3D
	var checkout_marker: Marker3D = (
		_root.get_node_or_null("CustomerNavConfig/CheckoutApproach") as Marker3D
	)
	assert_not_null(register_area, "RegisterArea must exist")
	assert_not_null(checkout_marker, "CheckoutApproach must exist")
	if register_area == null or checkout_marker == null:
		return
	var queue_markers: Array[Marker3D] = []
	for index: int in range(1, RegisterQueue.MAX_QUEUE_SIZE + 1):
		var marker: Marker3D = (
			_root.get_node_or_null("QueueMarker%d" % index) as Marker3D
		)
		assert_not_null(marker, "QueueMarker%d must exist" % index)
		if marker != null:
			queue_markers.append(marker)
	assert_eq(
		queue_markers.size(),
		RegisterQueue.MAX_QUEUE_SIZE,
		"Checkout must expose one queue marker per queue slot",
	)
	if queue_markers.size() != RegisterQueue.MAX_QUEUE_SIZE:
		return

	var first_to_register: float = _xz_distance(
		queue_markers[0].global_position,
		register_area.global_position
	)
	assert_lt(
		first_to_register,
		0.05,
		"QueueMarker1 must align with RegisterArea"
	)
	assert_lt(
		_xz_distance(
			queue_markers[0].global_position,
			checkout_marker.global_position
		),
		0.05,
		"QueueMarker1 must align with CheckoutApproach"
	)
	for index: int in range(1, queue_markers.size()):
		var spacing: float = _xz_distance(
			queue_markers[index - 1].global_position,
			queue_markers[index].global_position
		)
		assert_between(
			spacing,
			0.95,
			1.15,
			"Queue marker spacing must keep a practical checkout lane"
		)
		assert_gt(
			_xz_distance(
				queue_markers[index].global_position,
				register_area.global_position
			),
			_xz_distance(
				queue_markers[index - 1].global_position,
				register_area.global_position
			),
			"Queue markers must be ordered away from the register"
		)


# ── Furniture obstacle avoidance ────────────────────────────────────────────

func test_each_furniture_carries_navigation_obstacle_with_expected_radius() -> void:
	for path: String in EXPECTED_OBSTACLES:
		var obstacle: NavigationObstacle3D = (
			_root.get_node_or_null(path) as NavigationObstacle3D
		)
		assert_not_null(
			obstacle,
			"%s must exist so customers steer around the fixture" % path,
		)
		if obstacle == null:
			continue
		var expected_radius: float = EXPECTED_OBSTACLES[path]
		assert_almost_eq(
			obstacle.radius, expected_radius, 0.001,
			"%s radius" % path,
		)
		assert_gt(
			obstacle.height, 0.0,
			"%s height must be positive so it covers customer extents" % path,
		)


func _xz_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x, a.z).distance_to(Vector2(b.x, b.z))
