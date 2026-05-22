## Verifies first-person camera and capsule safety for the authored
## retro_games reference corner. These checks complement collider-presence
## tests by validating aisle widths, blocked squeeze gaps, fixture backs,
## and eye-level clearance from actual scene geometry.
extends GutTest

const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"
const PLAYER_SCENE_PATH: String = "res://game/scenes/player/store_player_body.tscn"

const PLAYER_RADIUS: float = 0.35
const PLAYER_DIAMETER: float = PLAYER_RADIUS * 2.0
const MIN_COMFORT_AISLE_WIDTH: float = 1.0
const MAX_BLOCKED_GAP_WIDTH: float = PLAYER_DIAMETER - 0.02
const CAMERA_EYE_HEIGHT: float = 1.7
const CAMERA_CLEARANCE_MIN: float = 0.08
const TALL_PANEL_MIN_WALKING_DISTANCE: float = 0.45
const EYE_LEVEL_PANEL_BOTTOM_MAX: float = CAMERA_EYE_HEIGHT + 0.1

const GAP_CONTRACTS: Array[Dictionary] = [
	{
		"name": "checkout_customer_lane_to_display",
		"a": "Checkout",
		"b": "featured_display",
		"axis": "x",
		"policy": "passable",
		"min_width": MIN_COMFORT_AISLE_WIDTH,
	},
	{
		"name": "staff_picks_to_left_wall",
		"a": "LeftWallBody",
		"b": "staff_picks_table",
		"axis": "x",
		"policy": "passable",
		"min_width": MIN_COMFORT_AISLE_WIDTH,
	},
	{
		"name": "console_shelf_right_wall_gap",
		"a": "ConsoleShelf",
		"b": "RightWallBody",
		"axis": "x",
		"policy": "blocked",
		"max_width": MAX_BLOCKED_GAP_WIDTH,
	},
	{
		"name": "accessories_bin_left_wall_gap",
		"a": "AccessoriesBin",
		"b": "LeftWallBody",
		"axis": "x",
		"policy": "blocked",
		"max_width": MAX_BLOCKED_GAP_WIDTH,
	},
	{
		"name": "featured_display_to_staff_picks_route",
		"a": "featured_display",
		"b": "staff_picks_table",
		"axis": "x",
		"policy": "passable",
		"min_width": MIN_COMFORT_AISLE_WIDTH,
	},
]

const CAMERA_STANDING_POINTS: Array[Dictionary] = [
	{
		"name": "checkout_customer_mat",
		"point": Vector3(5.05, CAMERA_EYE_HEIGHT, 8.45),
		"near": ["Checkout", "EntranceDoor"],
	},
	{
		"name": "checkout_display_lane",
		"point": Vector3(3.35, CAMERA_EYE_HEIGHT, 6.7),
		"near": ["Checkout", "featured_display"],
	},
	{
		"name": "featured_display_front",
		"point": Vector3(-2.6, CAMERA_EYE_HEIGHT, 3.2),
		"near": ["featured_display"],
	},
	{
		"name": "staff_picks_front",
		"point": Vector3(-5.5, CAMERA_EYE_HEIGHT, 7.35),
		"near": ["staff_picks_table"],
	},
	{
		"name": "accessories_bin_customer_side",
		"point": Vector3(-6.85, CAMERA_EYE_HEIGHT, 1.43),
		"near": ["AccessoriesBin", "LeftWallBody"],
	},
	{
		"name": "console_shelf_customer_side",
		"point": Vector3(6.45, CAMERA_EYE_HEIGHT, -4.29),
		"near": ["ConsoleShelf", "RightWallBody"],
	},
]

const REAR_SAFETY_CONTRACTS: Array[Dictionary] = [
	{
		"name": "console_shelf_backed_by_right_wall",
		"fixture": "ConsoleShelf",
		"blocker": "RightWallBody",
		"axis": "x",
		"max_rear_clearance": MAX_BLOCKED_GAP_WIDTH,
	},
	{
		"name": "accessories_bin_backed_by_left_wall",
		"fixture": "AccessoriesBin",
		"blocker": "LeftWallBody",
		"axis": "x",
		"max_rear_clearance": MAX_BLOCKED_GAP_WIDTH,
	},
	{
		"name": "staff_picks_table_finished_360",
		"fixture": "staff_picks_table",
		"min_x_size": 1.15,
		"min_z_size": 0.55,
	},
	{
		"name": "featured_display_finished_360",
		"fixture": "featured_display",
		"min_x_size": 0.95,
		"min_z_size": 0.55,
	},
	{
		"name": "checkout_counter_finished_back",
		"fixture": "Checkout",
		"min_x_size": 1.75,
		"min_z_size": 0.6,
	},
]

const TALL_PANEL_CONTRACTS: Array[Dictionary] = [
	{
		"name": "checkout_sign",
		"panel": "Checkout/Register/CheckoutSignBacking",
		"sample": Vector3(5.05, CAMERA_EYE_HEIGHT, 8.45),
	},
	{
		"name": "staff_picks_sign",
		"panel": "ZoneLabels/StaffPicksBacking",
		"sample": Vector3(-5.5, CAMERA_EYE_HEIGHT, 7.35),
	},
	{
		"name": "used_consoles_sign",
		"panel": "ZoneLabels/UsedConsolesBacking",
		"sample": Vector3(6.45, CAMERA_EYE_HEIGHT, -4.29),
	},
	{
		"name": "backroom_sign",
		"panel": "ZoneLabels/BackroomBacking",
		"sample": Vector3(6.3, CAMERA_EYE_HEIGHT, -7.25),
	},
]

var _root: Node3D = null


func before_all() -> void:
	var scene: PackedScene = load(SCENE_PATH)
	assert_not_null(scene, "Retro Games scene must load")
	if scene:
		_root = scene.instantiate() as Node3D
		add_child(_root)


func after_all() -> void:
	if is_instance_valid(_root):
		_root.free()
	_root = null


func test_player_capsule_collides_with_world_and_fixtures() -> void:
	var scene: PackedScene = load(PLAYER_SCENE_PATH)
	assert_not_null(scene, "Store player body scene must load")
	if scene == null:
		return
	var player: CharacterBody3D = scene.instantiate() as CharacterBody3D
	assert_not_null(player, "Store player body scene root must be CharacterBody3D")
	if player == null:
		return
	assert_eq(
		player.collision_mask & 1,
		1,
		"Player capsule must collide with world_geometry layer",
	)
	assert_eq(
		player.collision_mask & 2,
		2,
		"Player capsule must collide with store_fixtures layer",
	)
	player.free()


func test_reference_corner_gaps_are_comfortable_or_blocked() -> void:
	for contract: Dictionary in GAP_CONTRACTS:
		var width: float = _gap_width(
			String(contract["a"]),
			String(contract["b"]),
			String(contract["axis"]),
		)
		var policy: String = String(contract["policy"])
		if policy == "passable":
			assert_gte(
				width,
				float(contract["min_width"]),
				(
					"%s gap %.3f m must be a comfortable first-person route, "
					+ "not a capsule squeeze"
				) % [contract["name"], width],
			)
		elif policy == "blocked":
			assert_lte(
				width,
				float(contract["max_width"]),
				"%s gap %.3f m must be below capsule pass width %.3f m"
				% [contract["name"], width, float(contract["max_width"])],
			)
		else:
			fail_test("Unknown gap policy '%s'" % policy)


func test_camera_standing_points_clear_fixture_faces() -> void:
	for sample: Dictionary in CAMERA_STANDING_POINTS:
		var point: Vector3 = sample["point"] as Vector3
		for path: String in sample["near"]:
			var distance: float = _distance_point_to_aabb(point, _node_aabb(path))
			assert_gte(
				distance,
				CAMERA_CLEARANCE_MIN,
				(
					"%s camera eye at %s must stay %.2f m from %s blocking geometry; got %.3f"
				) % [
					sample["name"], point, CAMERA_CLEARANCE_MIN, path, distance,
				],
			)


func test_fixture_rears_are_blocked_or_finished_for_close_inspection() -> void:
	for contract: Dictionary in REAR_SAFETY_CONTRACTS:
		if contract.has("blocker"):
			var clearance: float = _gap_width(
				String(contract["fixture"]),
				String(contract["blocker"]),
				String(contract["axis"]),
			)
			assert_lte(
				clearance,
				float(contract["max_rear_clearance"]),
				"%s rear gap %.3f m must be blocked before the capsule can enter"
				% [contract["name"], clearance],
			)
			continue
		var bounds: AABB = _node_aabb(String(contract["fixture"]))
		assert_gte(
			bounds.size.x,
			float(contract["min_x_size"]),
			"%s must keep enough X footprint to read as finished from the side"
			% contract["name"],
		)
		assert_gte(
			bounds.size.z,
			float(contract["min_z_size"]),
			"%s must keep enough Z footprint to read as finished from the rear"
			% contract["name"],
		)


func test_tall_panels_stay_out_of_normal_camera_framing_distance() -> void:
	for contract: Dictionary in TALL_PANEL_CONTRACTS:
		var panel_bounds: AABB = _node_aabb(String(contract["panel"]))
		var sample: Vector3 = contract["sample"] as Vector3
		var distance: float = _distance_point_to_aabb(sample, panel_bounds)
		if panel_bounds.position.y <= EYE_LEVEL_PANEL_BOTTOM_MAX:
			assert_gte(
				distance,
				TALL_PANEL_MIN_WALKING_DISTANCE,
				"%s panel must not fill the camera at normal walking distance"
				% contract["name"],
			)
		assert_gt(
			panel_bounds.position.y,
			CAMERA_EYE_HEIGHT,
			"%s panel bottom must stay above the first-person eye line" % contract["name"],
		)


func _node_aabb(path: String) -> AABB:
	var node: Node = _root.get_node_or_null(path)
	assert_not_null(node, "%s must exist for FP camera safety checks" % path)
	if node == null:
		return AABB()
	if node is MeshInstance3D:
		return _mesh_aabb(node as MeshInstance3D)
	if node is StaticBody3D:
		return _first_collision_aabb(node)
	var body: StaticBody3D = node.get_node_or_null("StaticBody3D") as StaticBody3D
	assert_not_null(body, "%s must own StaticBody3D for FP camera safety checks" % path)
	if body == null:
		return AABB()
	return _first_collision_aabb(body)


func _first_collision_aabb(body: StaticBody3D) -> AABB:
	var shape_node: CollisionShape3D = (
		body.get_node_or_null("CollisionShape3D") as CollisionShape3D
	)
	assert_not_null(shape_node, "%s must own CollisionShape3D" % body.name)
	if shape_node == null:
		return AABB()
	assert_true(
		shape_node.shape is BoxShape3D,
		"%s collision shape must be BoxShape3D for authored gap checks"
		% body.name,
	)
	if not (shape_node.shape is BoxShape3D):
		return AABB()
	var box := shape_node.shape as BoxShape3D
	return _box_aabb(shape_node.global_transform, box.size)


func _mesh_aabb(mesh_instance: MeshInstance3D) -> AABB:
	assert_not_null(mesh_instance.mesh, "%s must have mesh" % mesh_instance.name)
	if mesh_instance.mesh == null:
		return AABB()
	var mesh_bounds: AABB = mesh_instance.mesh.get_aabb()
	return _box_aabb(
		mesh_instance.global_transform.translated_local(mesh_bounds.get_center()),
		mesh_bounds.size,
	)


func _box_aabb(transform: Transform3D, size: Vector3) -> AABB:
	var extents: Vector3 = size * 0.5
	var corners: Array[Vector3] = [
		Vector3(-extents.x, -extents.y, -extents.z),
		Vector3(-extents.x, -extents.y, extents.z),
		Vector3(-extents.x, extents.y, -extents.z),
		Vector3(-extents.x, extents.y, extents.z),
		Vector3(extents.x, -extents.y, -extents.z),
		Vector3(extents.x, -extents.y, extents.z),
		Vector3(extents.x, extents.y, -extents.z),
		Vector3(extents.x, extents.y, extents.z),
	]
	var min_point: Vector3 = transform * corners[0]
	var max_point: Vector3 = min_point
	for corner: Vector3 in corners:
		var world: Vector3 = transform * corner
		min_point = min_point.min(world)
		max_point = max_point.max(world)
	return AABB(min_point, max_point - min_point)


func _gap_width(path_a: String, path_b: String, axis: String) -> float:
	var a: AABB = _node_aabb(path_a)
	var b: AABB = _node_aabb(path_b)
	var a_min: float = a.position.x if axis == "x" else a.position.z
	var a_max: float = a_min + (a.size.x if axis == "x" else a.size.z)
	var b_min: float = b.position.x if axis == "x" else b.position.z
	var b_max: float = b_min + (b.size.x if axis == "x" else b.size.z)
	if a_max < b_min:
		return b_min - a_max
	if b_max < a_min:
		return a_min - b_max
	return 0.0


func _distance_point_to_aabb(point: Vector3, bounds: AABB) -> float:
	var max_point: Vector3 = bounds.position + bounds.size
	var dx: float = max(bounds.position.x - point.x, 0.0, point.x - max_point.x)
	var dy: float = max(bounds.position.y - point.y, 0.0, point.y - max_point.y)
	var dz: float = max(bounds.position.z - point.z, 0.0, point.z - max_point.z)
	return Vector3(dx, dy, dz).length()
