extends GutTest

const NavmeshRouteGuard := preload("res://tests/automation/navmesh_route_guard.gd")
const PLAYER_SCENE_PATH: String = "res://game/scenes/player/store_player_body.tscn"
const STORE_SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"
const WORLD_LAYER: int = 1
const FIXTURE_LAYER: int = 2
const PLAYER_LAYER: int = 4
const PLAYER_COLLISION_MASK: int = WORLD_LAYER | FIXTURE_LAYER
const PLAYER_RADIUS: float = 0.35
const PLAYER_HEIGHT: float = 1.8

const BLOCKING_BODIES: Array[Dictionary] = [
	{"path": "ExpandableStoreShell/StarterBackWall", "layer": WORLD_LAYER},
	{"path": "ExpandableStoreShell/StarterLeftWall", "layer": WORLD_LAYER},
	{"path": "ExpandableStoreShell/StarterRightWall", "layer": WORLD_LAYER},
	{"path": "ExpandableStoreShell/StarterFrontWallLeft", "layer": WORLD_LAYER},
	{"path": "ExpandableStoreShell/StarterFrontWallRight", "layer": WORLD_LAYER},
	{"path": "ExpandableStoreShell/StarterGlassDoorBlocker", "layer": WORLD_LAYER},
	{"path": "ExpandableStoreShell/StockroomPartition", "layer": WORLD_LAYER},
	{"path": "ExpandableStoreShell/StockroomSideReturn", "layer": WORLD_LAYER},
	{"path": "ExpandableStoreShell/StockroomBackPanel", "layer": WORLD_LAYER},
	{"path": "Checkout/StaticBody3D", "layer": FIXTURE_LAYER},
	{"path": "StoreSessionRestockShelf/StaticBody3D", "layer": FIXTURE_LAYER},
	{"path": "StoreSessionBackroomPickup/StockBoxStaticBody", "layer": FIXTURE_LAYER},
	{"path": "EntranceDoor/StaticBody3D", "layer": FIXTURE_LAYER},
	{"path": "FrontLaneQueue/LaneFixture/LeftGuideRopeBody", "layer": FIXTURE_LAYER},
	{"path": "FrontLaneQueue/LaneFixture/RightGuideRopeBody", "layer": FIXTURE_LAYER},
	{"path": "FrontLaneQueue/LaneFixture/RegisterLeftPost/StaticBody3D", "layer": FIXTURE_LAYER},
	{"path": "FrontLaneQueue/LaneFixture/RegisterRightPost/StaticBody3D", "layer": FIXTURE_LAYER},
]

const PLAYER_PROBES: Array[Dictionary] = [
	{"label": "back wall", "path": "ExpandableStoreShell/StarterBackWall"},
	{"label": "left wall", "path": "ExpandableStoreShell/StarterLeftWall"},
	{"label": "right wall", "path": "ExpandableStoreShell/StarterRightWall"},
	{"label": "front door", "path": "ExpandableStoreShell/StarterGlassDoorBlocker"},
	{"label": "stockroom wall", "path": "ExpandableStoreShell/StockroomPartition"},
	{"label": "checkout counter", "path": "Checkout/StaticBody3D"},
	{"label": "display table", "path": "StoreSessionRestockShelf/StaticBody3D"},
	{"label": "stock box", "path": "StoreSessionBackroomPickup/StockBoxStaticBody"},
	{"label": "queue rope", "path": "FrontLaneQueue/LaneFixture/LeftGuideRopeBody"},
	{"label": "queue post", "path": "FrontLaneQueue/LaneFixture/RegisterLeftPost/StaticBody3D"},
]

const VISUAL_ONLY_SURFACES: PackedStringArray = [
	"ExpandableStoreShell/CheckoutRegisterScreen",
	"ExpandableStoreShell/CheckoutReceiptPrinterBody",
	"ExpandableStoreShell/CheckoutCardReader",
	"ExpandableStoreShell/StarterDisplayTableTray",
	"ExpandableStoreShell/StockroomReceivingTableTop",
	"ExpandableStoreShell/StockroomExpandedBoxWall00",
	"ExpandableStoreShell/StockroomExpandedRollingLadderFrame",
]
const FIRST_MINUTE_ROUTE_ANCHORS: PackedStringArray = [
	"PlayerEntrySpawn",
	"StoreStaffConfig/RegisterPoint",
	"CustomerNavConfig/CheckoutApproach",
	"StoreSessionDayOneCustomer",
	"CustomerNavConfig/BrowseWaypoint01",
	"StoreSessionBackroomPickup",
	"StoreSessionRestockShelf",
	"CustomerNavConfig/BrowseWaypoint02",
	"StoreSessionDayEndTrigger",
]
const FIRST_MINUTE_REPLAY_OFFSETS: Array[Vector3] = [
	Vector3.ZERO,
	Vector3(0.16, 0.0, 0.0),
	Vector3(-0.16, 0.0, 0.0),
	Vector3(0.0, 0.0, 0.16),
	Vector3(0.0, 0.0, -0.16),
]
const OBJECTIVE_TARGET_PATHS: PackedStringArray = [
	"StoreSessionDayOneCustomer/Interactable",
	"StoreSessionDayEndTrigger/Interactable",
	"StoreSessionBackroomPickup/Interactable",
	"StoreSessionRestockShelf/Interactable",
]

var _root: Node3D = null
var _saved_state: GameManager.State


func before_each() -> void:
	_saved_state = GameManager.current_state
	GameManager.current_state = GameManager.State.STORE_VIEW
	StoreSessionState.reset_new_run()
	var scene: PackedScene = load(STORE_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	_root = scene.instantiate() as Node3D
	add_child(_root)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().physics_frame


func after_each() -> void:
	if is_instance_valid(_root):
		_root.free()
	_root = null
	StoreSessionState.reset_new_run()
	GameManager.current_state = _saved_state


func test_first_person_player_collides_with_world_and_fixture_layers() -> void:
	var player_scene: PackedScene = load(PLAYER_SCENE_PATH)
	assert_not_null(player_scene, "store_player_body.tscn must load")
	if player_scene == null:
		return
	var player: CharacterBody3D = player_scene.instantiate() as CharacterBody3D
	assert_not_null(player, "store_player_body.tscn root must be a CharacterBody3D")
	if player == null:
		return
	autoqfree(player)
	assert_eq(player.collision_layer, PLAYER_LAYER)
	assert_eq(player.collision_mask, PLAYER_COLLISION_MASK)
	var shape: CollisionShape3D = player.get_node_or_null("CollisionShape3D") as CollisionShape3D
	assert_not_null(shape, "Player must own a capsule collision shape")
	if shape == null:
		return
	var capsule: CapsuleShape3D = shape.shape as CapsuleShape3D
	assert_not_null(capsule, "Player collision shape must be a CapsuleShape3D")
	if capsule == null:
		return
	assert_almost_eq(capsule.radius, PLAYER_RADIUS, 0.001)
	assert_almost_eq(capsule.height, PLAYER_HEIGHT, 0.001)


func test_runtime_visible_blockers_have_player_reachable_collision_layers() -> void:
	for contract: Dictionary in BLOCKING_BODIES:
		var path: String = str(contract["path"])
		var layer: int = int(contract["layer"])
		var body: StaticBody3D = _node(path) as StaticBody3D
		assert_not_null(body, "%s must be a StaticBody3D blocker" % path)
		if body == null:
			continue
		assert_eq(body.collision_layer & layer, layer, "%s must use layer %d" % [path, layer])
		var shape: CollisionShape3D = body.get_node_or_null("CollisionShape3D") as CollisionShape3D
		assert_not_null(shape, "%s must own a CollisionShape3D" % path)
		if shape != null:
			assert_not_null(shape.shape, "%s collision shape must be set" % path)


func test_player_capsule_probe_hits_first_minute_blockers() -> void:
	for probe: Dictionary in PLAYER_PROBES:
		var path: String = str(probe["path"])
		var label: String = str(probe["label"])
		var expected: CollisionObject3D = _node(path) as CollisionObject3D
		assert_not_null(expected, "%s expected blocker must exist" % label)
		if expected == null:
			continue
		var hits: Array[Dictionary] = _intersect_player_capsule(expected.global_position)
		assert_true(
			_hits_include(hits, expected),
			"Player capsule probe at %s must hit %s" % [label, path]
		)


func test_generated_details_are_visual_only_and_not_physics_decoys() -> void:
	for path: String in VISUAL_ONLY_SURFACES:
		var node: Node = _node(path)
		assert_not_null(node, "%s must exist as a classified visual-only surface" % path)
		if node == null:
			continue
		assert_false(
			_has_collision_descendant(node),
			"%s must not add a second physics surface over the real blocker" % path
		)


func test_first_minute_route_replays_do_not_clip_or_hide_objective_targets() -> void:
	var player_spawn: Node3D = _node("PlayerEntrySpawn") as Node3D
	assert_not_null(player_spawn, "PlayerEntrySpawn must define first-minute player bounds")
	if player_spawn == null:
		return
	var bounds_min: Vector3 = player_spawn.get_meta("bounds_min", Vector3.ZERO)
	var bounds_max: Vector3 = player_spawn.get_meta("bounds_max", Vector3.ZERO)
	var route_graph: Dictionary = _first_minute_route_graph()
	assert_false(route_graph.is_empty(), "Baked navmesh route graph must be available")
	if route_graph.is_empty():
		return

	for target_path: String in OBJECTIVE_TARGET_PATHS:
		var target: Node3D = _node(target_path) as Node3D
		assert_not_null(target, "%s must exist for first-minute routing" % target_path)
		if target != null:
			assert_true(_is_visible_through_ancestors(target), "%s must stay visible" % target_path)
			assert_true(
				_is_inside_bounds(target.global_position, bounds_min, bounds_max),
				"%s must stay inside first-minute player bounds" % target_path
			)
			assert_lte(
				NavmeshRouteGuard.distance_to_graph(route_graph, target.global_position),
				NavmeshRouteGuard.MAX_SNAP_DISTANCE_DEFAULT,
				"%s must stay reachable from the first-minute route" % target_path
			)

	for replay_index: int in range(FIRST_MINUTE_REPLAY_OFFSETS.size()):
		var offset: Vector3 = FIRST_MINUTE_REPLAY_OFFSETS[replay_index]
		for index: int in range(FIRST_MINUTE_ROUTE_ANCHORS.size() - 1):
			var start: Node3D = _node(FIRST_MINUTE_ROUTE_ANCHORS[index]) as Node3D
			var end: Node3D = _node(FIRST_MINUTE_ROUTE_ANCHORS[index + 1]) as Node3D
			assert_not_null(start, "%s route anchor must exist" % FIRST_MINUTE_ROUTE_ANCHORS[index])
			assert_not_null(end, "%s route anchor must exist" % FIRST_MINUTE_ROUTE_ANCHORS[index + 1])
			if start == null or end == null:
				continue
			var result: Dictionary = NavmeshRouteGuard.route_result(
				route_graph,
				start.global_position + offset,
				end.global_position + offset,
				NavmeshRouteGuard.MAX_SNAP_DISTANCE_DEFAULT
			)
			assert_true(
				result.get("reachable", false),
				"Replay %d route segment %s to %s must stay connected"
				% [
					replay_index + 1,
					FIRST_MINUTE_ROUTE_ANCHORS[index],
					FIRST_MINUTE_ROUTE_ANCHORS[index + 1],
				]
			)


func _intersect_player_capsule(position: Vector3) -> Array[Dictionary]:
	var shape := CapsuleShape3D.new()
	shape.radius = PLAYER_RADIUS
	shape.height = PLAYER_HEIGHT
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = Transform3D(Basis.IDENTITY, Vector3(position.x, PLAYER_HEIGHT * 0.5, position.z))
	query.collision_mask = PLAYER_COLLISION_MASK
	query.collide_with_bodies = true
	query.collide_with_areas = false
	var state: PhysicsDirectSpaceState3D = _root.get_world_3d().direct_space_state
	return state.intersect_shape(query, 32)


func _hits_include(hits: Array[Dictionary], expected: CollisionObject3D) -> bool:
	for hit: Dictionary in hits:
		var collider: Object = hit.get("collider")
		if collider == expected:
			return true
	return false


func _first_minute_route_graph() -> Dictionary:
	var navigation_region: NavigationRegion3D = (
		_root.get_node_or_null("NavigationRegion3D") as NavigationRegion3D
	)
	assert_not_null(navigation_region, "retro_games.tscn must include NavigationRegion3D")
	if navigation_region == null:
		return {}
	var navigation_mesh: NavigationMesh = navigation_region.navigation_mesh
	assert_not_null(navigation_mesh, "NavigationRegion3D must reference the baked navmesh")
	if navigation_mesh == null:
		return {}
	assert_eq(
		navigation_mesh.geometry_parsed_geometry_type,
		NavigationMesh.PARSED_GEOMETRY_STATIC_COLLIDERS,
		"First-minute route graph must be baked from static colliders"
	)
	return NavmeshRouteGuard.build_graph(navigation_mesh)


func _is_inside_bounds(position: Vector3, bounds_min: Vector3, bounds_max: Vector3) -> bool:
	return (
		position.x >= bounds_min.x
		and position.x <= bounds_max.x
		and position.z >= bounds_min.z
		and position.z <= bounds_max.z
	)


func _is_visible_through_ancestors(node: Node) -> bool:
	var current: Node = node
	while current != null and current != _root:
		var node_3d: Node3D = current as Node3D
		if node_3d != null and not node_3d.visible:
			return false
		current = current.get_parent()
	return true


func _has_collision_descendant(node: Node) -> bool:
	if node is CollisionObject3D or node is CollisionShape3D:
		return true
	for child: Node in node.get_children():
		if _has_collision_descendant(child):
			return true
	return false


func _node(path: String) -> Node:
	if _root == null:
		return null
	return _root.get_node_or_null(NodePath(path))
