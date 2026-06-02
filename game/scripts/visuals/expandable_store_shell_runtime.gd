# gdlint:disable=max-file-lines
## Runtime visual shell for the one-store expansion model.
##
## `retro_games.tscn` still owns gameplay anchors and interactables, but boot
## presentation is generated here: an expanded starter footprint with a closed
## expansion bay. Growth should unlock more generated layout pieces instead of
## revealing legacy authored full-store fixtures.
class_name ExpandableStoreShellRuntime
extends RefCounted

const StoreVisualKitScript: GDScript = preload("res://game/scripts/visuals/store_visual_kit.gd")
const StoreVisualLayoutScript: GDScript = preload(
	"res://game/scripts/visuals/store_visual_layout.gd"
)
const ProductVisualFactoryScript: GDScript = preload(
	"res://game/scripts/visuals/product_visual_factory.gd"
)
const StarterProductVisualResolverScript: GDScript = preload(
	"res://game/scripts/visuals/starter_product_visual_resolver.gd"
)
const OnboardingRouteCueRuntimeScript: GDScript = preload(
	"res://game/scripts/visuals/onboarding_route_cue_runtime.gd"
)
const StarterDetailBuilderScript: GDScript = preload(
	"res://game/scripts/visuals/starter_detail_builder.gd"
)
const StoreVisualStyleScript: GDScript = preload("res://game/scripts/visuals/store_visual_style.gd")
const VisualValueUtilScript: GDScript = preload("res://game/scripts/visuals/visual_value_util.gd")
const StockroomInventoryVisualProjectorScript: GDScript = preload(
	"res://game/scripts/visuals/stockroom_inventory_visual_projector.gd"
)

const ROOT_NAME: StringName = &"ExpandableStoreShell"
const _SHELL_WIDTH: float = 16.0
const _SHELL_DEPTH: float = 20.0
const _SHELL_CENTER_Z: float = 0.0
const _SHELL_LEFT_X: float = -8.0
const _SHELL_RIGHT_X: float = 8.0
const _SHELL_BACK_Z: float = -10.0
const _SHELL_FRONT_Z: float = 10.0
const _PLAYER_BOUNDS_MIN: Vector3 = Vector3(-7.45, 0.0, -9.35)
const _PLAYER_BOUNDS_MAX: Vector3 = Vector3(7.45, 0.0, 9.05)
const _PLAYER_SPAWN_POSITION: Vector3 = Vector3(-0.55, 0.0, 9.0)
const _PLAYER_SPAWN_ROTATION: Vector3 = Vector3(0.0, -25.0, 0.0)
const _ENTRANCE_POSITION: Vector3 = Vector3(0.0, 0.0, 9.72)
const _ENTRY_AREA_POSITION: Vector3 = Vector3(0.0, 1.2, 9.15)
const _CHECKOUT_POSITION: Vector3 = Vector3(5.65, 0.0, 6.15)
const _SHELF_TARGET_POSITION: Vector3 = Vector3(-4.10, 0.0, -1.20)
const _CHECKOUT_SERVICE_OFFSET_FROM_LAYOUT: Vector3 = Vector3(-0.80, 0.0, 1.10)
const _STOCKROOM_PICKUP_POSITION: Vector3 = Vector3(4.90, 0.0, -8.70)
const _STOCKROOM_THRESHOLD_POSITION: Vector3 = Vector3(4.95, 0.06, -5.65)
const _STOCKROOM_VISUAL_WIDTH: float = 6.25
const _STOCKROOM_VISUAL_DEPTH: float = 11.20
const _STOCKROOM_VISUAL_CENTER_X: float = 4.375
const _STOCKROOM_VISUAL_CENTER_Z: float = -4.35
const _ANCHOR_SCALE_CHECKOUT: Vector3 = Vector3(0.82, 0.82, 0.82)

const _HIDDEN_AUTHORED_VISUAL_ROOTS: Array[String] = [
	"Floor",
	"BackWallBody",
	"LeftWallBody",
	"RightWallBody",
	"Ceiling",
	"FrontWallLeftBody",
	"FrontWallRightBody",
	"Storefront",
	"EntranceInterior",
	"InteriorSignage",
	"ZoneLabels",
	"ReadabilityProps",
	"ReadabilityProps/ShelfSpineRuns",
	"ReadabilityProps/ProductDisplayRows",
	"ReadabilityProps/SpawnViewFloorDressing",
	"ReadabilityProps/DayOneRouteMarkers",
	"CartRackLeft",
	"Checkout",
	"back_room",
	"StoreSessionBackroomWallSide",
	"StoreSessionBackroomWallFrontLeft",
	"StoreSessionBackroomWallFrontRight",
	"Decorations",
	"TimeClock",
]
const _HIDDEN_AUTHORED_COLLISION_ALLOWLIST: Array[String] = [
	"Checkout/StaticBody3D",
]


static func apply(store: Node) -> void:
	if store == null:
		return
	var layout_catalog: RefCounted = StoreVisualLayoutScript.load_default()
	_apply_with_catalog(store, layout_catalog)


static func _apply_with_catalog(store: Node, layout_catalog: RefCounted) -> void:
	if store == null:
		return
	_hide_authored_visual_roots(store)
	_move_starter_anchors(store, layout_catalog)
	var shell: Node3D = _ensure_shell_root(store)
	_rebuild_shell(store, shell, layout_catalog)


## Returns authored visual roots hidden before the generated starter shell is built.
static func hidden_authored_visual_roots() -> Array[String]:
	return _HIDDEN_AUTHORED_VISUAL_ROOTS.duplicate()


static func _hide_authored_visual_roots(store: Node) -> void:
	for node_path: String in _HIDDEN_AUTHORED_VISUAL_ROOTS:
		var node: Node3D = store.get_node_or_null(NodePath(node_path)) as Node3D
		if node != null:
			node.visible = false
			_disable_hidden_collision_descendants(store, node)


static func _disable_hidden_collision_descendants(store: Node, node: Node) -> void:
	if node is CollisionObject3D:
		var body: CollisionObject3D = node as CollisionObject3D
		if not _hidden_collision_allowlisted(store, body):
			body.collision_layer = 0
			body.collision_mask = 0
	for child: Node in node.get_children():
		_disable_hidden_collision_descendants(store, child)


static func _hidden_collision_allowlisted(store: Node, node: Node) -> bool:
	var relative_path: String = _relative_store_path(store, node)
	return _HIDDEN_AUTHORED_COLLISION_ALLOWLIST.has(relative_path)


static func _relative_store_path(store: Node, node: Node) -> String:
	if store == null or node == null:
		return ""
	var names: Array[String] = []
	var current: Node = node
	while current != null and current != store:
		names.push_front(str(current.name))
		current = current.get_parent()
	if current != store:
		return ""
	return "/".join(names)


static func _move_starter_anchors(store: Node, layout_catalog: RefCounted) -> void:
	var physical_contract: Dictionary = _starter_physical_contract(layout_catalog)
	var display_table: Dictionary = _starter_fixture_placement(
		layout_catalog, "starter_display_table"
	)
	var checkout_counter: Dictionary = _starter_fixture_placement(
		layout_catalog, "starter_checkout_counter"
	)
	var checkout_contract: Dictionary = _placement_contract(
		physical_contract, "starter_checkout_counter"
	)
	var spawn_contract: Dictionary = _placement_contract(physical_contract, "player_entry_spawn")
	var entrance_contract: Dictionary = _placement_contract(physical_contract, "entrance_door")
	var entry_area_contract: Dictionary = _placement_contract(physical_contract, "entry_area")
	var stockroom_pickup_contract: Dictionary = _placement_contract(
		physical_contract, "stockroom_pickup"
	)
	var queue_contract: Dictionary = _placement_contract(
		physical_contract, "queue_marker_positions"
	)
	var browse_contract: Dictionary = _placement_contract(
		physical_contract, "customer_browse_waypoints"
	)
	var lighting_contract: Dictionary = _placement_contract(
		physical_contract, "lighting_context_points"
	)
	var route_points: Array[Vector3] = _zone_points(
		physical_contract, "customer_route_core", _customer_route_fallback_points()
	)
	var store_bounds: Dictionary = physical_contract.get("store_bounds", {}) as Dictionary
	var shelf_position: Vector3 = _placement_position(display_table, _SHELF_TARGET_POSITION)
	var shelf_rotation: Vector3 = _placement_rotation(display_table, Vector3(0.0, -8.0, 0.0))
	var checkout_position: Vector3 = _placement_position(checkout_counter, _CHECKOUT_POSITION)
	var checkout_rotation: Vector3 = _placement_rotation(checkout_counter, Vector3.ZERO)
	var checkout_scale: Vector3 = _placement_scale(checkout_counter, _ANCHOR_SCALE_CHECKOUT)
	var checkout_service_position_from_contract: Vector3 = _service_point_position(
		checkout_contract,
		"checkout_customer_spot",
		checkout_position,
		_CHECKOUT_SERVICE_OFFSET_FROM_LAYOUT
	)
	var checkout_staff_position: Vector3 = _service_point_position(
		checkout_contract,
		"checkout_staff_spot",
		checkout_position,
		Vector3(0.20, 0.0, -0.75)
	)
	var spawn_position: Vector3 = _contract_vector3(
		spawn_contract, "position", _PLAYER_SPAWN_POSITION, "player_entry_spawn.position"
	)
	var spawn_rotation: Vector3 = _contract_vector3(
		spawn_contract,
		"rotation_degrees",
		_PLAYER_SPAWN_ROTATION,
		"player_entry_spawn.rotation_degrees"
	)
	var entrance_position: Vector3 = _contract_vector3(
		entrance_contract, "position", _ENTRANCE_POSITION, "entrance_door.position"
	)
	var entry_area_position: Vector3 = _contract_vector3(
		entry_area_contract, "position", _ENTRY_AREA_POSITION, "entry_area.position"
	)
	var stockroom_pickup_position: Vector3 = _contract_vector3(
		stockroom_pickup_contract,
		"position",
		_STOCKROOM_PICKUP_POSITION,
		"stockroom_pickup.position"
	)
	var queue_positions: Array[Vector3] = _contract_positions(
		queue_contract,
		(
			[
				checkout_service_position_from_contract,
				checkout_service_position_from_contract + Vector3(-0.95, 0.0, 0.25),
				checkout_service_position_from_contract + Vector3(-1.90, 0.0, 0.50),
			]
			as Array[Vector3]
		),
		"queue_marker_positions.positions"
	)
	var checkout_service_position: Vector3 = _queue_position(
		queue_positions,
		RegisterQueue.ACTIVE_SERVICE_SLOT_INDEX,
		checkout_service_position_from_contract
	)
	var front_lane_position: Vector3 = _queue_position(
		queue_positions,
		RegisterQueue.FIRST_WAITING_SLOT_INDEX,
		checkout_service_position + Vector3(-0.95, 0.0, 0.25)
	)
	var browse_positions: Array[Vector3] = _contract_positions(
		browse_contract,
		(
			[
				Vector3(-5.25, 0.05, -6.05),
				Vector3(0.30, 0.05, -2.05),
				Vector3(-5.65, 0.05, 2.45),
			]
			as Array[Vector3]
		),
		"customer_browse_waypoints.positions"
	)
	var lighting_positions: Array[Vector3] = _contract_positions(
		lighting_contract,
		(
			[
				Vector3(4.95, 2.35, -8.45),
				Vector3(5.05, 3.1, 6.75),
				Vector3(0.0, 3.25, -0.15),
				Vector3(-5.6, 2.1, -0.9),
				Vector3(6.2, 2.2, 5.85),
			]
			as Array[Vector3]
		),
		"lighting_context_points.positions"
	)
	_set_position(store, "PlayerEntrySpawn", spawn_position)
	_set_rotation_degrees(store, "PlayerEntrySpawn", spawn_rotation)
	_set_player_bounds(
		store,
		_contract_vector3(
			store_bounds, "player_bounds_min", _PLAYER_BOUNDS_MIN, "store_bounds.player_bounds_min"
		),
		_contract_vector3(
			store_bounds, "player_bounds_max", _PLAYER_BOUNDS_MAX, "store_bounds.player_bounds_max"
		)
	)
	_set_position(store, "Checkout", checkout_position)
	_set_rotation_degrees(store, "Checkout", checkout_rotation)
	_set_scale(store, "Checkout", checkout_scale)
	_set_position(store, "checkout_counter", checkout_position)
	_set_rotation_degrees(store, "checkout_counter", checkout_rotation)
	_set_scale(store, "checkout_counter", checkout_scale)
	_set_position(store, "RegisterArea", checkout_service_position + Vector3(0.0, 1.0, 0.0))
	_set_position(store, "StoreSessionDayOneCustomer", checkout_service_position)
	_set_position(store, "StoreSessionManager", checkout_staff_position)
	_set_rotation_degrees(store, "StoreSessionManager", Vector3.ZERO)
	_set_global_position(
		store,
		"Checkout/StoreSessionCustomerFloorMat",
		checkout_service_position + Vector3(0.0, 0.01, 0.0)
	)
	_set_global_position(
		store,
		"Checkout/CheckoutManagerFloorMat",
		checkout_staff_position + Vector3(0.0, 0.01, 0.0)
	)
	_set_position(store, "StoreSessionDayEndTrigger", checkout_position + Vector3(0.0, 1.05, 0.0))
	_set_position(store, "StoreSessionRestockShelf", shelf_position)
	_set_rotation_degrees(store, "StoreSessionRestockShelf", shelf_rotation)
	_hide_node(store, "StoreSessionRestockShelf/RestockCrate")
	_set_position(store, "StoreSessionBackroomPickup", stockroom_pickup_position)
	_set_position(store, "EntranceDoor", entrance_position)
	_hide_node(store, "EntranceDoor/DoorMesh")
	_hide_node(store, "EntranceDoor/StaticBody3D")
	_set_position(store, "EntryArea", entry_area_position)
	_set_position(store, "QueueMarker1", queue_positions[0])
	_set_position(store, "QueueMarker2", queue_positions[1])
	_set_position(store, "QueueMarker3", queue_positions[2])
	_set_position(store, "FrontLaneQueue", front_lane_position)
	_set_position(store, "BackroomUtilityLight", lighting_positions[0])
	_set_position(store, "CheckoutLaneSpotlight", lighting_positions[1])
	_set_position(store, "FluorescentKeyLight", lighting_positions[2])
	_set_position(store, "WarmNeonFill", lighting_positions[3])
	_set_position(store, "GreenNeonFill", lighting_positions[4])
	_set_customer_nav(
		store,
		shelf_position,
		checkout_service_position,
		checkout_staff_position,
		stockroom_pickup_position,
		entry_area_position,
		route_points,
		browse_positions
	)


static func _set_customer_nav(
	store: Node,
	shelf_position: Vector3,
	checkout_service_position: Vector3,
	checkout_staff_position: Vector3,
	stockroom_pickup_position: Vector3,
	entry_area_position: Vector3,
	route_points: Array[Vector3],
	browse_positions: Array[Vector3]
) -> void:
	var entry_floor_position: Vector3 = entry_area_position + Vector3(0.0, -1.15, 0.0)
	var route_entry_position: Vector3 = _route_point(route_points, 0, entry_floor_position)
	var route_shelf_position: Vector3 = _route_point(route_points, 1, shelf_position)
	_set_position(store, "StoreStaffConfig/RegisterPoint", checkout_staff_position)
	_set_position(store, "StoreStaffConfig/BackroomPoint", stockroom_pickup_position)
	_set_position(store, "StoreStaffConfig/GreeterPoint", route_entry_position)
	_set_position(store, "CustomerNavConfig/EntryPoint", entry_floor_position)
	_set_position(
		store, "CustomerNavConfig/BrowseWaypoint01", route_shelf_position + Vector3(0.0, 0.05, 0.0)
	)
	_set_position(store, "CustomerNavConfig/BrowseWaypoint02", browse_positions[0])
	_set_position(store, "CustomerNavConfig/BrowseWaypoint03", browse_positions[1])
	_set_position(store, "CustomerNavConfig/BrowseWaypoint04", browse_positions[2])
	_set_position(
		store,
		"CustomerNavConfig/CheckoutApproach",
		checkout_service_position + Vector3(0.0, 0.05, 0.0)
	)
	_set_position(store, "CustomerNavConfig/ExitPoint", entry_floor_position)


static func _set_position(store: Node, path: String, position: Vector3) -> void:
	var node: Node3D = store.get_node_or_null(NodePath(path)) as Node3D
	if node != null:
		node.position = position


static func _set_global_position(store: Node, path: String, global_position: Vector3) -> void:
	var node: Node3D = store.get_node_or_null(NodePath(path)) as Node3D
	if node == null:
		return
	if node.is_inside_tree():
		node.global_position = global_position
		return
	var parent_node: Node3D = node.get_parent() as Node3D
	if parent_node == null:
		node.position = global_position
		return
	var parent_transform: Transform3D = _local_global_transform(parent_node)
	node.position = parent_transform.affine_inverse() * global_position


static func _set_rotation_degrees(store: Node, path: String, rotation_degrees: Vector3) -> void:
	var node: Node3D = store.get_node_or_null(NodePath(path)) as Node3D
	if node != null:
		node.rotation_degrees = rotation_degrees


static func _set_scale(store: Node, path: String, scale: Vector3) -> void:
	var node: Node3D = store.get_node_or_null(NodePath(path)) as Node3D
	if node != null:
		node.scale = scale


static func _hide_node(store: Node, path: String) -> void:
	var node: Node3D = store.get_node_or_null(NodePath(path)) as Node3D
	if node != null:
		node.visible = false


static func _starter_physical_contract(layout_catalog: RefCounted) -> Dictionary:
	if layout_catalog == null:
		return {}
	return (
		layout_catalog.call(
			"get_physical_contract", StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT
		)
		as Dictionary
	)


static func _placement_contract(physical_contract: Dictionary, object_id: String) -> Dictionary:
	for raw_contract: Variant in physical_contract.get("placement_contracts", []):
		if raw_contract is not Dictionary:
			continue
		var entry: Dictionary = raw_contract as Dictionary
		if str(entry.get("object_id", "")) == object_id:
			return entry
	return {}


static func _zone_contract(physical_contract: Dictionary, zone_id: String) -> Dictionary:
	for raw_zone: Variant in physical_contract.get("zones", []):
		if raw_zone is not Dictionary:
			continue
		var zone: Dictionary = raw_zone as Dictionary
		if str(zone.get("zone_id", "")) == zone_id:
			return zone
	return {}


static func _zone_points(
	physical_contract: Dictionary, zone_id: String, fallback: Array[Vector3]
) -> Array[Vector3]:
	var zone: Dictionary = _zone_contract(physical_contract, zone_id)
	if zone.is_empty():
		return fallback
	return _contract_positions(zone, fallback, "%s.points" % zone_id, "points")


static func _customer_route_fallback_points() -> Array[Vector3]:
	return (
		[
			Vector3(0.0, 0.0, 8.20),
			_SHELF_TARGET_POSITION,
			_CHECKOUT_POSITION + _CHECKOUT_SERVICE_OFFSET_FROM_LAYOUT,
			Vector3(0.0, 0.0, 8.20),
		]
		as Array[Vector3]
	)


static func _shell_bounds(layout_catalog: RefCounted) -> Dictionary:
	var physical_contract: Dictionary = _starter_physical_contract(layout_catalog)
	var store_bounds: Dictionary = physical_contract.get("store_bounds", {}) as Dictionary
	var fallback_min := Vector3(_SHELL_LEFT_X, 0.0, _SHELL_BACK_Z)
	var fallback_max := Vector3(_SHELL_RIGHT_X, 3.5, _SHELL_FRONT_Z)
	var fallback_size := Vector3(_SHELL_WIDTH, 3.5, _SHELL_DEPTH)
	var fallback_center := Vector3(0.0, 0.0, _SHELL_CENTER_Z)
	return {
		"min": _contract_vector3(store_bounds, "min", fallback_min, "store_bounds.min"),
		"max": _contract_vector3(store_bounds, "max", fallback_max, "store_bounds.max"),
		"size": _contract_vector3(store_bounds, "size", fallback_size, "store_bounds.size"),
		"center":
		_contract_vector3(store_bounds, "position", fallback_center, "store_bounds.position"),
	}


static func _stockroom_zone_metrics(layout_catalog: RefCounted) -> Dictionary:
	var physical_contract: Dictionary = _starter_physical_contract(layout_catalog)
	var zone: Dictionary = _zone_contract(physical_contract, "stockroom")
	return {
		"center":
		_contract_vector3(
			zone,
			"position",
			Vector3(_STOCKROOM_VISUAL_CENTER_X, 0.0, _STOCKROOM_VISUAL_CENTER_Z),
			"stockroom.position"
		),
		"size":
		_contract_vector3(
			zone,
			"size",
			Vector3(_STOCKROOM_VISUAL_WIDTH, 2.8, _STOCKROOM_VISUAL_DEPTH),
			"stockroom.size"
		),
	}


static func _route_point(points: Array[Vector3], index: int, fallback: Vector3) -> Vector3:
	if index >= 0 and index < points.size():
		return points[index]
	return fallback


static func _queue_position(
	positions: Array[Vector3], index: int, fallback: Vector3
) -> Vector3:
	if index >= 0 and index < positions.size():
		return positions[index]
	return fallback


static func _service_point_position(
	contract: Dictionary, point_id: String, anchor: Vector3, fallback_offset: Vector3
) -> Vector3:
	for raw_point: Variant in contract.get("service_points", []):
		if raw_point is not Dictionary:
			continue
		var point: Dictionary = raw_point as Dictionary
		if str(point.get("point_id", "")) != point_id:
			continue
		var offset: Vector3 = _contract_vector3(
			point, "position_offset", fallback_offset, "%s.position_offset" % point_id
		)
		return anchor + offset
	return anchor + fallback_offset


static func _contract_vector3(
	entry: Dictionary, field: String, fallback: Vector3, label: String
) -> Vector3:
	if entry.is_empty() or not entry.has(field):
		return fallback
	var raw_value: Variant = entry.get(field)
	if VisualValueUtilScript.is_vector3_array(raw_value):
		return VisualValueUtilScript.vector3_from_exact_array(raw_value, fallback)
	_warn_layout_fallback(label)
	return fallback


static func _contract_positions(
	entry: Dictionary, fallback: Array[Vector3], label: String, field: String = "positions"
) -> Array[Vector3]:
	if entry.is_empty() or not entry.has(field):
		return fallback
	var raw_positions: Variant = entry.get(field)
	if raw_positions is not Array:
		_warn_layout_fallback(label)
		return fallback
	var values: Array = raw_positions as Array
	var resolved: Array[Vector3] = []
	for index: int in range(fallback.size()):
		if index >= values.size() or not VisualValueUtilScript.is_vector3_array(values[index]):
			_warn_layout_fallback("%s[%d]" % [label, index])
			resolved.append(fallback[index])
			continue
		resolved.append(
			VisualValueUtilScript.vector3_from_exact_array(values[index], fallback[index])
		)
	return resolved


static func _warn_layout_fallback(label: String) -> void:
	push_warning(
		(
			(
				"ExpandableStoreShellRuntime: invalid physical layout contract value for %s; "
				+ "using fallback"
			)
			% label
		)
	)


static func _starter_fixture_placement(
	layout_catalog: RefCounted, fixture_id: String
) -> Dictionary:
	if layout_catalog == null:
		return {}
	return (
		(
			layout_catalog
			. call(
				"get_fixture_placement",
				StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT,
				fixture_id,
			)
		)
		as Dictionary
	)


static func _starter_first_delivery_products(layout_catalog: RefCounted) -> Array[Dictionary]:
	if layout_catalog == null:
		return []
	return (
		(
			layout_catalog
			. call(
				"get_product_placements",
				StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT,
				StoreVisualLayoutScript.STOCK_STATE_FIRST_DELIVERY,
			)
		)
		as Array[Dictionary]
	)


static func _placement_position(placement: Dictionary, fallback: Vector3) -> Vector3:
	return VisualValueUtilScript.vector3_from_array(placement.get("position", []), fallback)


static func _placement_rotation(placement: Dictionary, fallback: Vector3) -> Vector3:
	return VisualValueUtilScript.vector3_from_array(placement.get("rotation_degrees", []), fallback)


static func _placement_scale(placement: Dictionary, fallback: Vector3) -> Vector3:
	return VisualValueUtilScript.vector3_from_array(placement.get("scale", []), fallback)


static func _set_player_bounds(store: Node, bounds_min: Vector3, bounds_max: Vector3) -> void:
	var spawn: Marker3D = store.get_node_or_null("PlayerEntrySpawn") as Marker3D
	if spawn == null:
		return
	spawn.set_meta("bounds_min", bounds_min)
	spawn.set_meta("bounds_max", bounds_max)


static func _ensure_shell_root(store: Node) -> Node3D:
	var shell: Node3D = store.get_node_or_null(NodePath(ROOT_NAME)) as Node3D
	if shell == null and store.has_meta("_expandable_store_shell_pending"):
		shell = store.get_meta("_expandable_store_shell_pending") as Node3D
	if shell == null:
		shell = Node3D.new()
		shell.name = ROOT_NAME
		store.set_meta("_expandable_store_shell_pending", shell)
		if store.is_inside_tree():
			store.add_child.call_deferred(shell)
		else:
			store.add_child(shell)
	shell.visible = true
	for child: Node in shell.get_children():
		child.free()
	return shell


static func _local_global_transform(node: Node3D) -> Transform3D:
	var chain: Array[Node3D] = []
	var current: Node = node
	while current is Node3D:
		chain.push_front(current as Node3D)
		current = current.get_parent()
	var result := Transform3D.IDENTITY
	for item: Node3D in chain:
		result *= item.transform
	return result


static func _rebuild_shell(store: Node, shell: Node3D, layout_catalog: RefCounted) -> void:
	var shell_recipe: Dictionary = StoreVisualStyleScript.surface_recipe(
		StoreVisualStyleScript.RECIPE_SHELL
	)
	var stockroom_recipe: Dictionary = StoreVisualStyleScript.surface_recipe(
		StoreVisualStyleScript.RECIPE_STOCKROOM
	)
	var checkout_recipe: Dictionary = StoreVisualStyleScript.surface_recipe(
		StoreVisualStyleScript.RECIPE_CHECKOUT
	)
	var signage_recipe: Dictionary = StoreVisualStyleScript.surface_recipe(
		StoreVisualStyleScript.RECIPE_SIGNAGE
	)
	var product_recipe: Dictionary = StoreVisualStyleScript.surface_recipe(
		StoreVisualStyleScript.RECIPE_PRODUCT
	)
	var wall_mat: StandardMaterial3D = _recipe_token_mat(shell_recipe, "wall")
	var trim_mat: StandardMaterial3D = _recipe_token_mat(shell_recipe, "trim")
	var floor_mat: StandardMaterial3D = _recipe_token_mat(shell_recipe, "floor")
	var ceiling_mat: StandardMaterial3D = _mat(Color(0.60, 0.57, 0.51, 1.0))
	var shutter_mat: StandardMaterial3D = _mat(Color(0.20, 0.17, 0.22, 1.0))
	var sign_mat: StandardMaterial3D = _recipe_token_mat(signage_recipe, "panel")
	var dark_mat: StandardMaterial3D = _recipe_token_mat(checkout_recipe, "device")
	var shelf_mat: StandardMaterial3D = _recipe_family_mat(checkout_recipe, "counter")
	var table_mat: StandardMaterial3D = _recipe_family_mat(checkout_recipe, "counter")
	var paper_mat: StandardMaterial3D = _recipe_token_mat(stockroom_recipe, "box")
	var blue_case_mat: StandardMaterial3D = _recipe_token_mat(product_recipe, "blue")
	var green_case_mat: StandardMaterial3D = _recipe_token_mat(product_recipe, "green")
	var red_case_mat: StandardMaterial3D = _recipe_token_mat(product_recipe, "red")
	var sales_panel_mat: StandardMaterial3D = _recipe_token_mat(shell_recipe, "floor_panel")
	var shelf_cool_panel_mat: StandardMaterial3D = _recipe_token_mat(stockroom_recipe, "floor")
	var checkout_service_mat: StandardMaterial3D = _recipe_token_mat(
		checkout_recipe, "service_panel"
	)
	var stock_box_mat: StandardMaterial3D = _recipe_token_mat(stockroom_recipe, "box")
	var backroom_floor_mat: StandardMaterial3D = _recipe_token_mat(stockroom_recipe, "floor")
	var backroom_panel_mat: StandardMaterial3D = _recipe_token_mat(stockroom_recipe, "panel")
	var backroom_rack_mat: StandardMaterial3D = _recipe_token_mat(stockroom_recipe, "rack")
	var crate_shadow_mat: StandardMaterial3D = StoreVisualStyleScript.material_for_token(
		StoreVisualStyleScript.TOKEN_SHADOW_ACCENT_SEAM
	)
	var gold_mat: StandardMaterial3D = _recipe_token_mat(signage_recipe, "trim")
	var paper_white_mat: StandardMaterial3D = _recipe_token_mat(signage_recipe, "paper")
	var purple_case_mat: StandardMaterial3D = _recipe_token_mat(product_recipe, "purple")
	var teal_case_mat: StandardMaterial3D = _recipe_token_mat(product_recipe, "teal")
	var rubber_mat: StandardMaterial3D = _recipe_token_mat(stockroom_recipe, "rubber")
	var identity_panel_mat: StandardMaterial3D = _mat(Color(0.17, 0.23, 0.24, 1.0))
	var identity_trim_mat: StandardMaterial3D = StoreVisualStyleScript.store_accent_material(
		&"retro_games"
	)
	var sightline_mat: StandardMaterial3D = _mat(Color(0.31, 0.20, 0.13, 1.0))
	var floor_seam_mat: StandardMaterial3D = _recipe_token_mat(shell_recipe, "floor_seam")
	var floor_scuff_mat: StandardMaterial3D = _recipe_token_mat(shell_recipe, "floor_scuff")
	var storefront_frame_mat: StandardMaterial3D = _recipe_token_mat(
		shell_recipe, "threshold_metal"
	)
	var storefront_metal_mat: StandardMaterial3D = _recipe_token_mat(
		shell_recipe, "threshold_metal"
	)
	var storefront_threshold_mat: StandardMaterial3D = _recipe_token_mat(
		shell_recipe, "threshold_tile"
	)
	var storefront_glass_mat: StandardMaterial3D = _recipe_token_mat(
		shell_recipe, "threshold_glass"
	)
	var palette: Dictionary = {
		"wall": wall_mat,
		"trim": trim_mat,
		"floor": floor_mat,
		"ceiling": ceiling_mat,
		"shutter": shutter_mat,
		"sign": sign_mat,
		"dark": dark_mat,
		"shelf": shelf_mat,
		"table": table_mat,
		"paper": paper_mat,
		"blue_case": blue_case_mat,
		"green_case": green_case_mat,
		"red_case": red_case_mat,
		"sales_panel": sales_panel_mat,
		"shelf_cool_panel": shelf_cool_panel_mat,
		"checkout_service": checkout_service_mat,
		"stock_box": stock_box_mat,
		"gold": gold_mat,
		"paper_white": paper_white_mat,
		"purple_case": purple_case_mat,
		"teal_case": teal_case_mat,
		"rubber": rubber_mat,
		"identity_panel": identity_panel_mat,
		"identity_trim": identity_trim_mat,
		"sightline": sightline_mat,
		"floor_seam": floor_seam_mat,
		"floor_scuff": floor_scuff_mat,
		"backroom_floor": backroom_floor_mat,
		"backroom_panel": backroom_panel_mat,
		"backroom_rack": backroom_rack_mat,
		"crate_shadow": crate_shadow_mat,
	}
	var shell_bounds: Dictionary = _shell_bounds(layout_catalog)
	var shell_center: Vector3 = shell_bounds["center"] as Vector3
	var shell_size: Vector3 = shell_bounds["size"] as Vector3
	var shell_min: Vector3 = shell_bounds["min"] as Vector3
	var shell_max: Vector3 = shell_bounds["max"] as Vector3
	var physical_contract: Dictionary = _starter_physical_contract(layout_catalog)
	var stockroom_doorway_contract: Dictionary = _placement_contract(
		physical_contract, "stockroom_doorway"
	)
	var stockroom_threshold_position: Vector3 = _contract_vector3(
		stockroom_doorway_contract,
		"position",
		_STOCKROOM_THRESHOLD_POSITION,
		"stockroom_doorway.position"
	)
	var stockroom_doorway_size: Vector3 = _contract_vector3(
		stockroom_doorway_contract.get("footprint", {}) as Dictionary,
		"size",
		Vector3(1.55, 2.72, 0.18),
		"stockroom_doorway.footprint.size"
	)
	var stockroom_metrics: Dictionary = _stockroom_zone_metrics(layout_catalog)
	var stockroom_center: Vector3 = stockroom_metrics["center"] as Vector3
	var stockroom_size: Vector3 = stockroom_metrics["size"] as Vector3
	var stockroom_min: Vector3 = stockroom_center - stockroom_size * 0.5
	var stockroom_max: Vector3 = stockroom_center + stockroom_size * 0.5
	var stockroom_wall_height: float = stockroom_size.y
	var stockroom_wall_y: float = stockroom_wall_height * 0.5
	var stockroom_front_wall_thickness: float = 0.10
	var stockroom_side_wall_thickness: float = 0.12
	var stockroom_front_wall_z: float = stockroom_max.z - stockroom_front_wall_thickness * 0.5
	var stockroom_back_wall_z: float = stockroom_min.z + stockroom_front_wall_thickness * 0.5
	var stockroom_opening_min_x: float = (
		stockroom_threshold_position.x - stockroom_doorway_size.x * 0.5
	)
	var stockroom_opening_max_x: float = (
		stockroom_threshold_position.x + stockroom_doorway_size.x * 0.5
	)
	var stockroom_front_left_width: float = stockroom_opening_min_x - stockroom_min.x
	var stockroom_front_right_width: float = stockroom_max.x - stockroom_opening_max_x

	_add_box(
		shell,
		"StarterFloor",
		Vector3(shell_center.x, 0.025, shell_center.z),
		Vector3(shell_size.x, 0.05, shell_size.z),
		floor_mat
	)
	_add_box(
		shell,
		"StarterCeiling",
		Vector3(shell_center.x, 3.45, shell_center.z),
		Vector3(shell_size.x, 0.08, shell_size.z),
		ceiling_mat
	)
	_add_wall(
		shell,
		"StarterBackWall",
		Vector3(shell_center.x, 1.72, shell_min.z),
		Vector3(shell_size.x, 3.45, 0.12),
		wall_mat
	)
	_add_wall(
		shell,
		"StarterLeftWall",
		Vector3(shell_min.x, 1.72, shell_center.z),
		Vector3(0.12, 3.45, shell_size.z),
		wall_mat
	)
	_add_wall(
		shell,
		"StarterRightWall",
		Vector3(shell_max.x, 1.72, shell_center.z),
		Vector3(0.12, 3.45, shell_size.z),
		wall_mat
	)
	_add_wall(
		shell,
		"StarterFrontWallLeft",
		Vector3(-5.15, 1.72, shell_max.z),
		Vector3(5.7, 3.45, 0.12),
		wall_mat
	)
	_add_wall(
		shell,
		"StarterFrontWallRight",
		Vector3(5.15, 1.72, shell_max.z),
		Vector3(5.7, 3.45, 0.12),
		wall_mat
	)

	_add_box(
		shell,
		"BackWallTrim",
		Vector3(shell_center.x, 0.68, shell_min.z + 0.09),
		Vector3(15.4, 0.08, 0.10),
		trim_mat
	)
	_add_box(
		shell,
		"LeftWallTrim",
		Vector3(shell_min.x + 0.09, 0.68, shell_center.z),
		Vector3(0.10, 0.08, 19.4),
		trim_mat
	)
	_add_box(
		shell,
		"RightWallTrim",
		Vector3(shell_max.x - 0.09, 0.68, shell_center.z),
		Vector3(0.10, 0.08, 19.4),
		trim_mat
	)
	_add_box(
		shell,
		"EntryThreshold",
		Vector3(0.0, 0.046, 9.66),
		Vector3(1.92, 0.022, 0.18),
		storefront_threshold_mat
	)
	_add_box(
		shell,
		"FrontDoorFrameLeft",
		Vector3(-0.94, 1.32, 9.90),
		Vector3(0.040, 2.48, 0.060),
		storefront_frame_mat
	)
	_add_box(
		shell,
		"FrontDoorFrameRight",
		Vector3(0.94, 1.32, 9.90),
		Vector3(0.040, 2.48, 0.060),
		storefront_frame_mat
	)
	_add_box(
		shell,
		"FrontDoorFrameTop",
		Vector3(0.0, 2.56, 9.90),
		Vector3(1.92, 0.045, 0.060),
		storefront_frame_mat
	)
	_add_wall(
		shell,
		"StarterGlassDoorBlocker",
		Vector3(0.0, 1.30, 9.94),
		Vector3(1.64, 1.88, 0.020),
		storefront_glass_mat
	)
	_add_box(
		shell,
		"FrontDoorPushPlate",
		Vector3(0.44, 1.12, 9.82),
		Vector3(0.040, 0.24, 0.020),
		storefront_metal_mat
	)
	_build_storefront_threshold_identity(shell, palette)

	_add_box(
		shell,
		"StarterSignBacking",
		Vector3(-4.75, 2.70, _SHELL_BACK_Z + 0.15),
		Vector3(1.85, 0.34, 0.08),
		sign_mat
	)
	_add_label(
		shell, "StarterSignLabel", "RETRO REWIND", Vector3(-4.75, 2.74, _SHELL_BACK_Z + 0.22), 30
	)
	_add_label(
		shell, "GamesBayLabel", "", Vector3(-4.75, 2.35, _SHELL_BACK_Z + 0.23), 20
	)
	_add_spawn_identity_composition(shell, palette)

	_add_wall(
		shell,
		"StockroomPartition",
		Vector3(
			stockroom_min.x + stockroom_front_left_width * 0.5,
			stockroom_wall_y,
			stockroom_front_wall_z
		),
		Vector3(stockroom_front_left_width, stockroom_wall_height, stockroom_front_wall_thickness),
		backroom_panel_mat
	)
	_add_wall(
		shell,
		"StockroomLeftSideReturn",
		Vector3(
			stockroom_min.x + stockroom_side_wall_thickness * 0.5,
			stockroom_wall_y,
			stockroom_center.z
		),
		Vector3(stockroom_side_wall_thickness, stockroom_wall_height, stockroom_size.z),
		backroom_panel_mat
	)
	_add_wall(
		shell,
		"StockroomSideReturn",
		Vector3(
			stockroom_max.x - stockroom_side_wall_thickness * 0.5,
			stockroom_wall_y,
			stockroom_center.z
		),
		Vector3(stockroom_side_wall_thickness, stockroom_wall_height, stockroom_size.z),
		backroom_panel_mat
	)
	_add_wall(
		shell,
		"StockroomBackPanel",
		Vector3(stockroom_center.x, stockroom_wall_y, stockroom_back_wall_z),
		Vector3(stockroom_size.x, stockroom_wall_height, stockroom_front_wall_thickness),
		backroom_panel_mat
	)
	_add_box(
		shell,
		"StockroomPost",
		Vector3(stockroom_opening_min_x - 0.06, stockroom_wall_y, stockroom_front_wall_z),
		Vector3(0.12, stockroom_wall_height, 0.12),
		dark_mat
	)
	_add_box(
		shell,
		"StockroomDoorJambRight",
		Vector3(stockroom_opening_max_x + 0.06, stockroom_wall_y, stockroom_front_wall_z),
		Vector3(0.12, stockroom_wall_height, 0.12),
		dark_mat
	)
	_add_wall(
		shell,
		"StockroomFrontRightWallPanel",
		Vector3(
			stockroom_opening_max_x + stockroom_front_right_width * 0.5,
			stockroom_wall_y,
			stockroom_front_wall_z
		),
		Vector3(stockroom_front_right_width, stockroom_wall_height, stockroom_front_wall_thickness),
		backroom_panel_mat
	)
	_add_box(
		shell,
		"StockroomDoorLintel",
		Vector3(stockroom_threshold_position.x, stockroom_doorway_size.y, stockroom_front_wall_z),
		Vector3(stockroom_doorway_size.x + 0.24, 0.12, 0.14),
		dark_mat
	)
	_add_box(
		shell,
		"StockroomHeader",
		Vector3(stockroom_threshold_position.x, 2.20, stockroom_front_wall_z + 0.04),
		Vector3(stockroom_doorway_size.x, 0.08, 0.16),
		trim_mat
	)
	_add_box(
		shell,
		"StockroomDoorHandle",
		Vector3(stockroom_opening_min_x - 0.10, 1.10, stockroom_front_wall_z + 0.08),
		Vector3(0.08, 0.16, 0.04),
		gold_mat
	)
	_add_box(
		shell,
		"StockroomFloorTape",
		stockroom_threshold_position,
		Vector3(1.55, 0.025, 0.18),
		backroom_rack_mat
	)
	_add_box(
		shell,
		"StockroomEmployeeStripeLeft",
		Vector3(4.22, 0.073, -6.72),
		Vector3(0.12, 0.018, 1.55),
		dark_mat
	)
	_add_box(
		shell,
		"StockroomEmployeeStripeRight",
		Vector3(5.28, 0.073, -6.72),
		Vector3(0.12, 0.018, 1.55),
		dark_mat
	)
	_add_box(
		shell,
		"StockroomDoorStop",
		Vector3(stockroom_threshold_position.x - 0.20, 0.16, stockroom_front_wall_z + 0.04),
		Vector3(stockroom_doorway_size.x - 0.10, 0.14, 0.05),
		trim_mat
	)

	_add_box(
		shell,
		"ExpansionDoorPanel",
		Vector3(_SHELL_LEFT_X + 0.07, 1.65, 0.40),
		Vector3(0.10, 2.55, 3.55),
		shutter_mat
	)
	_add_box(
		shell,
		"ExpansionHeader",
		Vector3(_SHELL_LEFT_X + 0.14, 2.95, 0.40),
		Vector3(0.10, 0.36, 3.65),
		sign_mat
	)
	_add_label(
		shell,
		"ExpansionLabel",
		"",
		Vector3(_SHELL_LEFT_X + 0.20, 2.96, 0.40),
		34,
		Vector3(0.0, -90.0, 0.0)
	)

	_add_box(
		shell,
		"StarterAisleMat",
		Vector3(1.40, 0.065, 6.55),
		Vector3(5.70, 0.025, 1.45),
		_mat(Color(0.20, 0.13, 0.10, 1.0))
	)

	# Floor wear gives scale without fighting the customer-facing retail fixtures.
	for index: int in range(15):
		var x_line: float = -7.0 + float(index) * 1.0
		_add_box(
			shell,
			"FloorBoardSeam%02d" % index,
			Vector3(x_line, 0.072, _SHELL_CENTER_Z),
			Vector3(0.018, 0.012, 19.0),
			floor_seam_mat
		)
	for index: int in range(9):
		var z_line: float = -8.35 + float(index) * 2.05
		_add_box(
			shell,
			"FloorTrafficScuff%02d" % index,
			Vector3(0.10, 0.076, z_line),
			Vector3(6.2, 0.008, 0.035),
			floor_scuff_mat
		)

	_add_readable_zone_surfaces(shell, palette)
	_add_store_identity_posters(shell, palette)

	for index: int in range(5):
		var light_x: float = -4.8 + float(index) * 2.4
		_add_box(
			shell,
			"CeilingFluorescent%02d" % index,
			Vector3(light_x, 3.39, -0.25),
			Vector3(1.05, 0.035, 0.16),
			_mat(Color(0.96, 0.91, 0.70, 1.0), Color(1.0, 0.84, 0.42, 1.0), 0.55)
		)
	_add_practical_zone_sources(shell)
	_add_omni_light(
		shell,
		"ShelfWallWarmPractical",
		Vector3(-4.60, 2.65, -9.25),
		Color(1.0, 0.76, 0.48, 1.0),
		0.52,
		3.6
	)
	_add_omni_light(
		shell,
		"ShelfEdgeCoolPractical",
		Vector3(-4.20, 1.85, -1.25),
		Color(0.66, 0.76, 1.0, 1.0),
		0.42,
		2.8
	)
	_add_omni_light(
		shell,
		"CheckoutRegisterPractical",
		Vector3(5.58, 1.55, 5.95),
		Color(1.0, 0.74, 0.48, 1.0),
		0.56,
		2.8
	)
	_add_omni_light(
		shell,
		"StockroomUtilityPractical",
		Vector3(4.95, 2.30, -8.45),
		Color(0.58, 0.74, 1.0, 1.0),
		0.62,
		3.2
	)
	_add_omni_light(
		shell,
		"EntryThresholdPractical",
		Vector3(0.0, 2.15, 8.95),
		Color(1.0, 0.78, 0.55, 1.0),
		0.28,
		2.4
	)
	_add_intentional_day_one_fixtures(store, shell, palette, layout_catalog)


static func _build_storefront_threshold_identity(shell: Node3D, palette: Dictionary) -> void:
	var identity_panel_mat: StandardMaterial3D = palette["identity_panel"] as StandardMaterial3D
	var identity_trim_mat: StandardMaterial3D = palette["identity_trim"] as StandardMaterial3D
	var gold_mat: StandardMaterial3D = palette["gold"] as StandardMaterial3D
	var teal_case_mat: StandardMaterial3D = palette["teal_case"] as StandardMaterial3D
	var paper_white_mat: StandardMaterial3D = palette["paper_white"] as StandardMaterial3D
	var rubber_mat: StandardMaterial3D = palette["rubber"] as StandardMaterial3D
	var glass_mat: StandardMaterial3D = StoreVisualStyleScript.material_for_token(
		StoreVisualStyleScript.TOKEN_THRESHOLD_GLASS_PANEL
	)
	var metal_mat: StandardMaterial3D = StoreVisualStyleScript.material_for_token(
		StoreVisualStyleScript.TOKEN_THRESHOLD_METAL_TRIM
	)
	var mall_tile_mat: StandardMaterial3D = StoreVisualStyleScript.material_for_token(
		StoreVisualStyleScript.TOKEN_THRESHOLD_TILE_PLATE
	)
	var cool_glow_mat := _mat(
		Color(0.33, 0.45, 0.47, 1.0), Color(0.30, 0.62, 0.72, 1.0), 0.14
	)

	_mark_storefront_identity(
		_add_box(
			shell,
			"FrontGlassLeftLite",
			Vector3(-2.46, 1.20, 8.30),
			Vector3(0.62, 1.48, 0.026),
			glass_mat
		),
		"glass_lite"
	)
	_mark_storefront_identity(
		_add_box(
			shell,
			"FrontGlassRightLite",
			Vector3(2.46, 1.20, 8.30),
			Vector3(0.62, 1.48, 0.026),
			glass_mat
		),
		"glass_lite"
	)
	_mark_storefront_identity(
		_add_box(
			shell,
			"MallSideTransomGlow",
			Vector3(0.0, 2.36, 9.50),
			Vector3(4.36, 0.18, 0.030),
			cool_glow_mat
		),
		"mall_context_glow"
	)
	_mark_storefront_identity(
		_add_box(
			shell,
			"StorefrontSignCanopyFace",
			Vector3(0.0, 2.62, 9.34),
			Vector3(4.82, 0.32, 0.055),
			identity_trim_mat
		),
		"storefront_sign"
	)
	_mark_storefront_identity(
		_add_box(
			shell,
			"StorefrontSignCanopyBacker",
			Vector3(0.0, 2.60, 9.39),
			Vector3(5.16, 0.42, 0.030),
			identity_panel_mat
		),
		"storefront_sign"
	)
	var canopy_label: Label3D = _add_label(
		shell,
		"StorefrontCanopyLabel",
		"RETRO REWIND",
		Vector3(0.0, 2.63, 9.29),
		26
	)
	_mark_storefront_identity(canopy_label, "storefront_sign_text")
	_mark_storefront_identity(
		_add_box(
			shell,
			"ThresholdFloorInlay",
			Vector3(0.0, 0.086, 8.44),
			Vector3(2.42, 0.012, 0.10),
			gold_mat
		),
		"branded_floor_inlay"
	)
	_mark_storefront_identity(
		_add_box(
			shell,
			"WelcomeMatInset",
			Vector3(0.0, 0.078, 8.54),
			Vector3(2.92, 0.012, 0.54),
			rubber_mat
		),
		"entry_mat"
	)
	_mark_storefront_identity(
		_add_box(
			shell,
			"MallTileToStoreFloorBreak",
			Vector3(0.0, 0.068, 8.78),
			Vector3(6.60, 0.012, 0.20),
			mall_tile_mat
		),
		"mall_floor_break"
	)
	_mark_storefront_identity(
		_add_box(
			shell,
			"StoreHoursPlaque",
			Vector3(1.58, 1.24, 9.26),
			Vector3(0.44, 0.58, 0.020),
			paper_white_mat
		),
		"hours_plaque"
	)
	var hours_label: Label3D = _add_label(
		shell,
		"StoreHoursPlaqueText",
		"",
		Vector3(1.58, 1.24, 9.235),
		11
	)
	_mark_storefront_identity(hours_label, "hours_plaque_text")
	_mark_storefront_identity(
		_add_box(
			shell,
			"FrontWindowDecalLeft",
			Vector3(-2.46, 1.18, 8.265),
			Vector3(0.38, 0.030, 0.016),
			gold_mat
		),
		"window_decal"
	)
	_mark_storefront_identity(
		_add_box(
			shell,
			"FrontWindowDecalRight",
			Vector3(2.46, 1.18, 8.265),
			Vector3(0.38, 0.030, 0.016),
			gold_mat
		),
		"window_decal"
	)
	_mark_storefront_identity(
		_add_box(
			shell,
			"EntryReturnLeftTrim",
			Vector3(-2.06, 1.18, 8.20),
			Vector3(0.05, 1.58, 0.10),
			metal_mat
		),
		"entry_return_trim"
	)
	_mark_storefront_identity(
		_add_box(
			shell,
			"EntryReturnRightTrim",
			Vector3(2.06, 1.18, 8.20),
			Vector3(0.05, 1.58, 0.10),
			metal_mat
		),
		"entry_return_trim"
	)
	_mark_storefront_identity(
		_add_box(
			shell,
			"WindowDisplayCartridgeStack",
			Vector3(-2.42, 0.54, 8.18),
			Vector3(0.64, 0.28, 0.12),
			teal_case_mat
		),
		"window_display"
	)


static func _mark_storefront_identity(node: Node, role: String) -> void:
	if node == null:
		return
	node.set_meta("storefront_threshold_identity", true)
	node.set_meta("storefront_identity_role", role)
	node.set_meta("visual_only", true)


static func _add_practical_zone_sources(shell: Node3D) -> void:
	var warm_source_mat := _mat(
		Color(0.98, 0.74, 0.34, 1.0), Color(1.0, 0.58, 0.18, 1.0), 0.48
	)
	var cool_source_mat := _mat(
		Color(0.52, 0.68, 0.92, 1.0), Color(0.36, 0.58, 1.0, 1.0), 0.46
	)
	var register_glow_mat := _mat(
		Color(0.10, 0.52, 0.30, 1.0), Color(0.20, 0.88, 0.48, 1.0), 0.52
	)
	var sign_crt_mat := _mat(
		Color(0.20, 0.68, 0.58, 1.0), Color(0.24, 0.92, 0.68, 1.0), 0.44
	)
	var featured_accent_mat := _mat(
		Color(0.26, 0.34, 0.88, 1.0), Color(0.36, 0.48, 1.0, 1.0), 0.38
	)
	var foreground_plane_mat := _mat(Color(0.30, 0.18, 0.10, 1.0))
	var midground_plane_mat := _mat(Color(0.42, 0.28, 0.16, 1.0))
	var background_plane_mat := _mat(Color(0.20, 0.25, 0.28, 1.0))

	_mark_lighting_plane(
		_add_box(
			shell,
			"SpawnForegroundWarmPlane",
			Vector3(0.55, 0.089, 7.95),
			Vector3(4.10, 0.012, 0.82),
			foreground_plane_mat
		),
		"foreground"
	)
	_mark_lighting_plane(
		_add_box(
			shell,
			"MainMidgroundWorkSurfacePlane",
			Vector3(-4.10, 0.091, -1.20),
			Vector3(3.15, 0.012, 1.28),
			midground_plane_mat
		),
		"midground"
	)
	_mark_lighting_plane(
		_add_box(
			shell,
			"BackWallBackgroundCoolPlane",
			Vector3(-1.05, 1.02, -9.91),
			Vector3(3.55, 0.82, 0.026),
			background_plane_mat
		),
		"background"
	)
	_mark_lighting_plane(
		_add_box(
			shell,
			"StockroomCoolBackgroundPlane",
			Vector3(4.95, 1.20, -9.91),
			Vector3(2.45, 0.92, 0.026),
			background_plane_mat
		),
		"background"
	)
	_mark_practical_source(
		_add_box(
			shell,
			"CheckoutRegisterPracticalSource",
			Vector3(5.64, 1.40, 5.31),
			Vector3(0.42, 0.16, 0.018),
			register_glow_mat
		),
		"register",
		"foreground"
	)
	_mark_practical_source(
		_add_box(
			shell,
			"CrtSignGlowPracticalSource",
			Vector3(-4.18, 1.58, -9.82),
			Vector3(0.48, 0.24, 0.020),
			sign_crt_mat
		),
		"crt_sign",
		"background"
	)
	_mark_practical_source(
		_add_box(
			shell,
			"StockroomStripLightSource",
			Vector3(4.95, 2.86, -8.45),
			Vector3(1.12, 0.042, 0.12),
			cool_source_mat
		),
		"stockroom_strip",
		"background"
	)
	_mark_practical_source(
		_add_box(
			shell,
			"FeaturedDisplayAccentPracticalSource",
			Vector3(-4.10, 1.66, -0.80),
			Vector3(0.72, 0.052, 0.14),
			featured_accent_mat
		),
		"featured_display",
		"midground"
	)
	_mark_practical_source(
		_add_box(
			shell,
			"StorefrontCanopyGlowSource",
			Vector3(0.0, 2.72, 9.82),
			Vector3(1.62, 0.075, 0.040),
			warm_source_mat
		),
		"storefront",
		"foreground"
	)


static func _mark_practical_source(node: MeshInstance3D, role: String, plane: String) -> void:
	if node == null:
		return
	node.set_meta("practical_light_source", true)
	node.set_meta("practical_light_role", role)
	node.set_meta("visual_plane", plane)
	node.set_meta("route_critical_shadow_policy", "preserve")


static func _mark_lighting_plane(node: MeshInstance3D, plane: String) -> void:
	if node == null:
		return
	node.set_meta("visual_plane", plane)
	node.set_meta("route_critical_shadow_policy", "preserve")


static func _add_spawn_identity_composition(shell: Node3D, palette: Dictionary) -> void:
	var identity_panel_mat: StandardMaterial3D = palette["identity_panel"] as StandardMaterial3D
	var identity_trim_mat: StandardMaterial3D = palette["identity_trim"] as StandardMaterial3D
	var sightline_mat: StandardMaterial3D = palette["sightline"] as StandardMaterial3D
	var gold_mat: StandardMaterial3D = palette["gold"] as StandardMaterial3D
	var teal_case_mat: StandardMaterial3D = palette["teal_case"] as StandardMaterial3D
	var backroom_panel_mat: StandardMaterial3D = palette["backroom_panel"] as StandardMaterial3D
	var rubber_mat: StandardMaterial3D = palette["rubber"] as StandardMaterial3D
	_add_box(
		shell,
		"StoreIdentityWallPanel",
		Vector3(-4.75, 2.20, _SHELL_BACK_Z + 0.105),
		Vector3(2.64, 1.42, 0.035),
		identity_panel_mat
	)
	_add_box(
		shell,
		"StoreIdentitySignCanopy",
		Vector3(-4.75, 2.96, _SHELL_BACK_Z + 0.19),
		Vector3(2.24, 0.12, 0.12),
		identity_trim_mat
	)
	_add_box(
		shell,
		"StoreIdentitySignUnderRail",
		Vector3(-4.75, 2.48, _SHELL_BACK_Z + 0.20),
		Vector3(2.08, 0.07, 0.10),
		gold_mat
	)
	for side: int in [-1, 1]:
		_add_box(
			shell,
			"StoreIdentitySignBracket%s" % ("Left" if side < 0 else "Right"),
			Vector3(-4.75 + float(side) * 1.06, 2.70, _SHELL_BACK_Z + 0.19),
			Vector3(0.08, 0.46, 0.10),
			identity_trim_mat
		)
	for index: int in range(3):
		_add_box(
			shell,
			"StoreIdentityCaseStripe%02d" % index,
			Vector3(-5.60 + float(index) * 0.82, 2.13, _SHELL_BACK_Z + 0.16),
			Vector3(0.44, 0.10, 0.045),
			teal_case_mat if index != 1 else gold_mat
		)
	_add_box(
		shell,
		"SpawnAisleRunner",
		Vector3(1.32, 0.080, 6.28),
		Vector3(5.78, 0.014, 1.18),
		sightline_mat
	)
	_add_box(
		shell,
		"SpawnCheckoutSightlineStrip",
		Vector3(3.52, 0.092, 6.66),
		Vector3(2.30, 0.012, 0.12),
		gold_mat
	)
	_add_box(
		shell,
		"SpawnStarterDisplaySightlineStrip",
		Vector3(-3.10, 0.092, 4.10),
		Vector3(0.16, 0.012, 3.72),
		teal_case_mat
	)
	_add_box(
		shell,
		"SpawnStockroomSightlineStrip",
		Vector3(4.74, 0.094, -4.88),
		Vector3(1.34, 0.012, 0.10),
		backroom_panel_mat
	)
	_add_box(
		shell,
		"SpawnRetailZoneLowRail",
		Vector3(-1.70, 0.46, 2.20),
		Vector3(0.10, 0.68, 1.92),
		rubber_mat
	)
	_add_omni_light(
		shell,
		"StoreIdentitySignWashPractical",
		Vector3(-4.75, 2.50, -8.80),
		Color(1.0, 0.72, 0.40, 1.0),
		0.38,
		2.2
	)


static func _add_readable_zone_surfaces(shell: Node3D, palette: Dictionary) -> void:
	var trim_mat: StandardMaterial3D = palette["trim"] as StandardMaterial3D
	var gold_mat: StandardMaterial3D = palette["gold"] as StandardMaterial3D
	var blue_case_mat: StandardMaterial3D = palette["blue_case"] as StandardMaterial3D
	var teal_case_mat: StandardMaterial3D = palette["teal_case"] as StandardMaterial3D
	var purple_case_mat: StandardMaterial3D = palette["purple_case"] as StandardMaterial3D
	var sales_panel_mat: StandardMaterial3D = palette["sales_panel"] as StandardMaterial3D
	var shelf_cool_panel_mat: StandardMaterial3D = palette["shelf_cool_panel"] as StandardMaterial3D
	var checkout_service_mat: StandardMaterial3D = palette["checkout_service"] as StandardMaterial3D
	var backroom_panel_mat: StandardMaterial3D = palette["backroom_panel"] as StandardMaterial3D
	var backroom_floor_mat: StandardMaterial3D = palette["backroom_floor"] as StandardMaterial3D
	var rubber_mat: StandardMaterial3D = palette["rubber"] as StandardMaterial3D
	_add_box(
		shell,
		"SalesFloorWarmBackWallPanel",
		Vector3(-1.15, 1.30, _SHELL_BACK_Z + 0.075),
		Vector3(3.30, 1.45, 0.030),
		sales_panel_mat
	)
	_add_box(
		shell,
		"ShelfWallCoolReadPanel",
		Vector3(-4.60, 1.34, _SHELL_BACK_Z + 0.090),
		Vector3(2.92, 1.34, 0.035),
		shelf_cool_panel_mat
	)
	_add_box(
		shell,
		"ShelfWallAccentTopRail",
		Vector3(-4.60, 2.03, _SHELL_BACK_Z + 0.13),
		Vector3(2.72, 0.055, 0.060),
		teal_case_mat
	)
	_add_box(
		shell,
		"ShelfWallBlueBayPatch",
		Vector3(-5.62, 1.28, _SHELL_BACK_Z + 0.135),
		Vector3(0.28, 0.34, 0.045),
		blue_case_mat
	)
	_add_box(
		shell,
		"ShelfWallPurpleBayPatch",
		Vector3(-3.62, 1.52, _SHELL_BACK_Z + 0.135),
		Vector3(0.30, 0.30, 0.045),
		purple_case_mat
	)
	_add_box(
		shell,
		"CheckoutServiceWarmWallPanel",
		Vector3(7.90, 1.28, 6.04),
		Vector3(0.035, 1.30, 2.10),
		checkout_service_mat
	)
	_add_box(
		shell,
		"CheckoutServiceFloorPool",
		Vector3(5.30, 0.071, 6.66),
		Vector3(2.15, 0.012, 1.42),
		_mat(Color(0.26, 0.17, 0.10, 1.0))
	)
	_add_box(
		shell,
		"CheckoutCounterEdgeLine",
		Vector3(5.03, 0.88, 6.68),
		Vector3(0.92, 0.035, 0.035),
		trim_mat
	)
	_add_box(
		shell,
		"ManagerAreaBackPanel",
		Vector3(7.90, 1.72, 7.16),
		Vector3(0.035, 0.74, 0.88),
		checkout_service_mat
	)
	_add_box(
		shell,
		"ManagerAreaLedgerRail",
		Vector3(7.86, 1.98, 7.16),
		Vector3(0.050, 0.055, 0.72),
		gold_mat
	)
	_add_box(
		shell,
		"QueueLaneWarmInlay",
		Vector3(3.90, 0.083, 7.50),
		Vector3(2.05, 0.012, 0.22),
		checkout_service_mat
	)
	for index: int in range(3):
		_add_box(
			shell,
			"QueueLaneMarkerPuck%02d" % index,
			Vector3(4.85 - float(index) * 0.95, 0.088, 7.25 + float(index) * 0.25),
			Vector3(0.26, 0.014, 0.16),
			rubber_mat
		)
	_add_box(
		shell,
		"StockroomCoolDoorRevealLeft",
		Vector3(4.035, 1.24, 1.22),
		Vector3(0.12, 1.58, 0.035),
		backroom_panel_mat
	)
	_add_box(
		shell,
		"StockroomCoolDoorRevealRight",
		Vector3(5.865, 1.24, 1.22),
		Vector3(0.12, 1.58, 0.035),
		backroom_panel_mat
	)
	_add_box(
		shell,
		"StockroomCoolDoorRevealHeader",
		Vector3(4.95, 2.05, 1.22),
		Vector3(1.55, 0.12, 0.035),
		backroom_panel_mat
	)
	_add_box(
		shell,
		"StockroomUtilityFloorApron",
		Vector3(4.86, 0.069, -6.34),
		Vector3(1.66, 0.014, 1.12),
		backroom_floor_mat
	)
	_add_box(
		shell,
		"StockroomWarmPickupSightPatch",
		Vector3(4.90, 0.092, -8.50),
		Vector3(0.92, 0.020, 0.55),
		gold_mat
	)
	_add_box(
		shell,
		"EntryMutedFloorMat",
		Vector3(-0.25, 0.070, 8.82),
		Vector3(1.85, 0.012, 0.62),
		rubber_mat
	)
	_add_box(
		shell,
		"EntryWarmSightlineStrip",
		Vector3(0.0, 0.086, 9.28),
		Vector3(1.60, 0.012, 0.075),
		gold_mat
	)


static func _add_store_identity_posters(shell: Node3D, palette: Dictionary) -> void:
	var identity_panel_mat: StandardMaterial3D = palette["identity_panel"] as StandardMaterial3D
	var identity_trim_mat: StandardMaterial3D = palette["identity_trim"] as StandardMaterial3D
	var gold_mat: StandardMaterial3D = palette["gold"] as StandardMaterial3D
	var teal_case_mat: StandardMaterial3D = palette["teal_case"] as StandardMaterial3D
	var purple_case_mat: StandardMaterial3D = palette["purple_case"] as StandardMaterial3D
	var paper_white_mat: StandardMaterial3D = palette["paper_white"] as StandardMaterial3D
	_add_poster_panel(
		shell,
		"ShelfLifeTradePoster",
		Vector3(7.90, 1.84, 4.58),
		Vector3(0.0, -90.0, 0.0),
		identity_panel_mat,
		identity_trim_mat,
		gold_mat,
		teal_case_mat
	)
	_add_poster_panel(
		shell,
		"ShelfLifeRepairPoster",
		Vector3(-7.90, 1.78, -1.65),
		Vector3(0.0, 90.0, 0.0),
		identity_panel_mat,
		identity_trim_mat,
		teal_case_mat,
		purple_case_mat
	)
	_add_box(
		shell,
		"ShelfLifeQueueCardPanel",
		Vector3(7.90, 1.38, 7.08),
		Vector3(0.034, 0.50, 0.42),
		paper_white_mat
	)
	_add_box(
		shell,
		"ShelfLifeQueueCardTopRule",
		Vector3(7.86, 1.57, 7.08),
		Vector3(0.048, 0.035, 0.34),
		gold_mat
	)
	_add_box(
		shell,
		"ShelfLifeQueueCardBottomRule",
		Vector3(7.86, 1.21, 7.08),
		Vector3(0.048, 0.026, 0.30),
		identity_trim_mat
	)


static func _add_poster_panel(
	shell: Node3D,
	base_name: String,
	position: Vector3,
	rotation_degrees: Vector3,
	panel_mat: StandardMaterial3D,
	trim_mat: StandardMaterial3D,
	accent_a_mat: StandardMaterial3D,
	accent_b_mat: StandardMaterial3D
) -> void:
	var root := Node3D.new()
	root.name = base_name
	root.position = position
	root.rotation_degrees = rotation_degrees
	root.set_meta("visual_source", "store_identity_poster")
	shell.add_child(root)
	_add_box(root, "Panel", Vector3.ZERO, Vector3(0.034, 0.78, 0.54), panel_mat)
	_add_box(root, "TopRail", Vector3(-0.003, 0.33, 0.0), Vector3(0.046, 0.050, 0.48), trim_mat)
	_add_box(root, "BottomRail", Vector3(-0.003, -0.33, 0.0), Vector3(0.046, 0.042, 0.42), trim_mat)
	for index: int in range(3):
		_add_box(
			root,
			"CaseStripe%02d" % index,
			Vector3(-0.010, 0.10 - float(index) * 0.12, -0.15 + float(index) * 0.15),
			Vector3(0.050, 0.075, 0.18),
			accent_a_mat if index != 1 else accent_b_mat
		)


static func _add_intentional_day_one_fixtures(
	store: Node, shell: Node3D, palette: Dictionary, layout_catalog: RefCounted
) -> void:
	var trim_mat: StandardMaterial3D = palette["trim"] as StandardMaterial3D
	var dark_mat: StandardMaterial3D = palette["dark"] as StandardMaterial3D
	var shelf_mat: StandardMaterial3D = palette["shelf"] as StandardMaterial3D
	var table_mat: StandardMaterial3D = palette["table"] as StandardMaterial3D
	var paper_mat: StandardMaterial3D = palette["paper"] as StandardMaterial3D
	var paper_white_mat: StandardMaterial3D = palette["paper_white"] as StandardMaterial3D
	var gold_mat: StandardMaterial3D = palette["gold"] as StandardMaterial3D
	var rubber_mat: StandardMaterial3D = palette["rubber"] as StandardMaterial3D
	var backroom_floor_mat: StandardMaterial3D = palette["backroom_floor"] as StandardMaterial3D
	var backroom_panel_mat: StandardMaterial3D = palette["backroom_panel"] as StandardMaterial3D
	var backroom_rack_mat: StandardMaterial3D = palette["backroom_rack"] as StandardMaterial3D
	var crate_shadow_mat: StandardMaterial3D = palette["crate_shadow"] as StandardMaterial3D
	var graphite_mat: StandardMaterial3D = StoreVisualStyleScript.material_for_token(
		StoreVisualStyleScript.TOKEN_CHECKOUT_DEVICE_BODY
	)
	var stock_box_mat: StandardMaterial3D = palette["stock_box"] as StandardMaterial3D
	var checkout_placement: Dictionary = _starter_fixture_placement(
		layout_catalog, "starter_checkout_counter"
	)
	var display_table_placement: Dictionary = _starter_fixture_placement(
		layout_catalog, "starter_display_table"
	)
	var checkout_position: Vector3 = _placement_position(checkout_placement, _CHECKOUT_POSITION)
	var display_position: Vector3 = _placement_position(
		display_table_placement, _SHELF_TARGET_POSITION
	)

	_add_checkout_core(
		shell,
		dark_mat,
		table_mat,
		paper_mat,
		paper_white_mat,
		gold_mat,
		graphite_mat,
		checkout_position
	)
	_add_used_game_wall_shelf(shell, trim_mat, shelf_mat)
	_add_starter_display_table_context(shell, trim_mat, dark_mat, table_mat, display_position)
	for placement: Dictionary in _starter_first_delivery_products(layout_catalog):
		_add_starter_product_visual(shell, placement)
	_add_expanded_stockroom_visual_scope(shell, palette, layout_catalog)
	_add_stockroom_contents(
		shell,
		trim_mat,
		dark_mat,
		stock_box_mat,
		paper_white_mat,
		gold_mat,
		rubber_mat,
		backroom_floor_mat,
		backroom_panel_mat,
		backroom_rack_mat,
		crate_shadow_mat
	)
	_add_stockroom_inventory_projection(store, shell)
	OnboardingRouteCueRuntimeScript.apply(shell)


static func _add_expanded_stockroom_visual_scope(
	shell: Node3D, palette: Dictionary, layout_catalog: RefCounted
) -> void:
	var backroom_floor_mat: StandardMaterial3D = palette["backroom_floor"] as StandardMaterial3D
	var backroom_panel_mat: StandardMaterial3D = palette["backroom_panel"] as StandardMaterial3D
	var backroom_rack_mat: StandardMaterial3D = palette["backroom_rack"] as StandardMaterial3D
	var stock_box_mat: StandardMaterial3D = palette["stock_box"] as StandardMaterial3D
	var crate_shadow_mat: StandardMaterial3D = palette["crate_shadow"] as StandardMaterial3D
	var paper_white_mat: StandardMaterial3D = palette["paper_white"] as StandardMaterial3D
	var rubber_mat: StandardMaterial3D = palette["rubber"] as StandardMaterial3D
	var stockroom: Dictionary = _stockroom_zone_metrics(layout_catalog)
	var stockroom_center: Vector3 = stockroom["center"] as Vector3
	var stockroom_size: Vector3 = stockroom["size"] as Vector3
	var stockroom_front_z: float = stockroom_center.z + stockroom_size.z * 0.5 - 0.05
	_add_box(
		shell,
		"StockroomExpandedCoolFloorApron",
		Vector3(stockroom_center.x, 0.055, stockroom_center.z),
		Vector3(stockroom_size.x, 0.025, stockroom_size.z),
		backroom_floor_mat
	)
	_add_box(
		shell,
		"StockroomExpandedBackWallPanel",
		Vector3(stockroom_center.x, 1.25, -9.88),
		Vector3(6.00, 1.65, 0.055),
		backroom_panel_mat
	)
	_add_box(
		shell,
		"StockroomExpandedLeftWallPanel",
		Vector3(1.31, 1.25, stockroom_center.z),
		Vector3(0.055, 1.65, 10.90),
		backroom_panel_mat
	)
	_add_box(
		shell,
		"StockroomExpandedRightWallPanel",
		Vector3(7.44, 1.25, stockroom_center.z),
		Vector3(0.055, 1.65, 10.90),
		backroom_panel_mat
	)
	_add_box(
		shell,
		"StockroomExpandedFrontPartitionLow",
		Vector3(2.7125, 0.72, stockroom_front_z),
		Vector3(2.925, 1.25, 0.08),
		backroom_panel_mat
	)
	_add_box(
		shell,
		"StockroomExpandedFrontPartitionHighA",
		Vector3(2.7125, 1.72, stockroom_front_z),
		Vector3(2.925, 3.20, 0.08),
		backroom_panel_mat
	)
	_add_box(
		shell,
		"StockroomExpandedFrontPartitionHighB",
		Vector3(6.6125, 1.72, stockroom_front_z),
		Vector3(1.775, 3.20, 0.08),
		backroom_panel_mat
	)
	_add_box(
		shell,
		"StockroomExpandedAisleShadow",
		Vector3(4.86, 0.062, -6.92),
		Vector3(1.35, 0.015, 2.75),
		crate_shadow_mat
	)
	_add_box(
		shell,
		"StockroomExpandedOverheadRun00",
		Vector3(2.10, 2.72, -8.65),
		Vector3(2.00, 0.28, 0.58),
		backroom_rack_mat
	)
	_add_box(
		shell,
		"StockroomExpandedOverheadRun01",
		Vector3(6.90, 2.72, -3.55),
		Vector3(0.58, 0.28, 5.50),
		backroom_rack_mat
	)
	for level: int in range(3):
		_add_box(
			shell,
			"StockroomExpandedSideRackShelf%02d" % level,
			Vector3(7.06, 0.74 + float(level) * 0.62, -3.55),
			Vector3(0.42, 0.11, 3.20),
			backroom_rack_mat
		)
	for index: int in range(4):
		_add_box(
			shell,
			"StockroomExpandedSideRackUpright%02d" % index,
			Vector3(7.04, 1.42, -4.92 + float(index) * 0.92),
			Vector3(0.11, 1.98, 0.10),
			backroom_rack_mat
		)
	_add_box(
		shell,
		"StockroomExpandedPalletZonePaint",
		Vector3(2.90, 0.066, -6.70),
		Vector3(2.20, 0.012, 1.35),
		crate_shadow_mat
	)
	_add_box(
		shell,
		"StockroomExpandedReceivingStripeA",
		Vector3(4.08, 0.071, -5.80),
		Vector3(0.06, 0.012, 2.20),
		rubber_mat
	)
	_add_box(
		shell,
		"StockroomExpandedReceivingStripeB",
		Vector3(5.72, 0.071, -5.80),
		Vector3(0.06, 0.012, 2.20),
		rubber_mat
	)
	for level: int in range(4):
		_add_box(
			shell,
			"StockroomExpandedDeepRackShelf%02d" % level,
			Vector3(2.12, 0.78 + float(level) * 0.64, -9.24),
			Vector3(1.70, 0.12, 0.48),
			backroom_rack_mat
		)
	for index: int in range(5):
		_add_box(
			shell,
			"StockroomExpandedDeepRackUpright%02d" % index,
			Vector3(1.30 + float(index) * 0.48, 1.62, -9.24),
			Vector3(0.08, 2.25, 0.12),
			backroom_rack_mat
		)
	for index: int in range(3):
		_add_box(
			shell,
			"StockroomExpandedPalletStack%02d" % index,
			Vector3(2.35 + float(index) * 0.74, 0.38 + float(index % 2) * 0.22, -6.95),
			Vector3(0.84, 0.62 + float(index % 2) * 0.34, 0.68),
			stock_box_mat if index != 1 else crate_shadow_mat
		)
	for index: int in range(4):
		_add_box(
			shell,
			"StockroomExpandedBoxWall%02d" % index,
			Vector3(6.88, 0.48 + float(index % 3) * 0.42, -7.25 + float(index) * 0.62),
			Vector3(0.50, 0.70, 0.54),
			stock_box_mat if index % 2 == 0 else crate_shadow_mat
		)
		_add_box(
			shell,
			"StockroomExpandedBoxLabel%02d" % index,
			Vector3(6.59, 0.58 + float(index % 3) * 0.42, -7.25 + float(index) * 0.62),
			Vector3(0.018, 0.10, 0.18),
			paper_white_mat
		)
	for index: int in range(4):
		var high_bin_position := (
			Vector3(2.00 + float(index) * 0.46, 2.93, -8.65)
			if index < 2
			else Vector3(6.90, 2.93, -4.55 + float(index - 2) * 1.20)
		)
		_add_box(
			shell,
			"StockroomExpandedHighBin%02d" % index,
			high_bin_position,
			Vector3(0.42, 0.34, 0.44),
			crate_shadow_mat
		)
	for index: int in range(4):
		_add_box(
			shell,
			"StockroomExpandedRackBin%02d" % index,
			Vector3(6.82, 1.04 + float(index % 2) * 0.58, -4.52 + float(index / 2) * 1.12),
			Vector3(0.36, 0.30, 0.42),
			crate_shadow_mat
		)
	_add_box(
		shell,
		"StockroomExpandedRollingLadderFrame",
		Vector3(1.62, 1.12, -4.85),
		Vector3(0.12, 2.05, 0.12),
		rubber_mat
	)
	for index: int in range(3):
		_add_box(
			shell,
			"StockroomExpandedRollingLadderStep%02d" % index,
			Vector3(1.90, 0.45 + float(index) * 0.37, -4.85),
			Vector3(0.58, 0.06, 0.10),
			rubber_mat
		)


static func _add_checkout_core(
	shell: Node3D,
	dark_mat: StandardMaterial3D,
	table_mat: StandardMaterial3D,
	paper_mat: StandardMaterial3D,
	paper_white_mat: StandardMaterial3D,
	gold_mat: StandardMaterial3D,
	graphite_mat: StandardMaterial3D,
	checkout_position: Vector3
) -> void:
	var screen_mat := _mat(Color(0.04, 0.16, 0.11, 1.0), Color(0.12, 0.58, 0.34, 1.0), 0.48)
	var readiness_mat := _mat(Color(0.14, 0.48, 0.28, 1.0), Color(0.22, 0.78, 0.40, 1.0), 0.42)
	var service_mat: StandardMaterial3D = StoreVisualStyleScript.material_for_family(
		StoreVisualStyleScript.FAMILY_WOOD_LAMINATE
	)
	var mat_mat: StandardMaterial3D = StoreVisualStyleScript.material_for_token(
		StoreVisualStyleScript.TOKEN_RUBBER_FLOOR_MAT
	)
	var checkout_offset: Vector3 = checkout_position - _CHECKOUT_POSITION
	var counter_component: Dictionary = _checkout_component(
		StoreVisualKitScript.STARTER_CHECKOUT_COUNTER
	)
	var monitor_component: Dictionary = _checkout_component(
		StoreVisualKitScript.STARTER_REGISTER_TERMINAL
	)
	var printer_component: Dictionary = _checkout_component(
		StoreVisualKitScript.STARTER_RECEIPT_PRINTER
	)
	var card_reader_component: Dictionary = _checkout_component(
		StoreVisualKitScript.STARTER_CARD_READER
	)
	var counter_top: MeshInstance3D = _add_box(
		shell,
		"CheckoutCounterTop",
		Vector3(5.60, 0.79, 6.14) + checkout_offset,
		Vector3(1.22, 0.08, 1.12),
		table_mat
	)
	_mark_checkout_component(counter_top, counter_component)
	_add_box(
		shell,
		"CheckoutCustomerSidePanel",
		Vector3(5.60, 0.42, 6.69) + checkout_offset,
		Vector3(1.16, 0.56, 0.08),
		table_mat
	)
	_add_box(
		shell,
		"CheckoutEmployeeSidePanel",
		Vector3(5.60, 0.42, 5.59) + checkout_offset,
		Vector3(1.16, 0.56, 0.08),
		table_mat
	)
	_add_box(
		shell,
		"CheckoutLeftSidePanel",
		Vector3(4.97, 0.42, 6.14) + checkout_offset,
		Vector3(0.08, 0.56, 1.02),
		table_mat
	)
	_add_box(
		shell,
		"CheckoutRightSidePanel",
		Vector3(6.23, 0.42, 6.14) + checkout_offset,
		Vector3(0.08, 0.56, 1.02),
		table_mat
	)
	_add_box(
		shell,
		"CheckoutFrontLaminatePanel",
		Vector3(5.45, 0.43, 6.58) + checkout_offset,
		Vector3(0.92, 0.52, 0.055),
		table_mat
	)
	_add_box(
		shell,
		"CheckoutFrontToeKick",
		Vector3(5.45, 0.13, 6.62) + checkout_offset,
		Vector3(0.84, 0.12, 0.06),
		dark_mat
	)
	_add_box(
		shell,
		"CheckoutRegisterDrawer",
		Vector3(5.64, 0.89, 5.64) + checkout_offset,
		Vector3(0.54, 0.12, 0.23),
		graphite_mat
	)
	_add_box(
		shell,
		"CheckoutRegisterCashSlot",
		Vector3(5.64, 0.96, 5.50) + checkout_offset,
		Vector3(0.34, 0.028, 0.026),
		graphite_mat
	)
	_add_checkout_indicator(
		shell,
		"CheckoutCashDrawerReadyLight",
		Vector3(5.81, 0.975, 5.50) + checkout_offset,
		readiness_mat
	)
	_add_box(
		shell,
		"CheckoutRegisterNeck",
		Vector3(5.64, 1.105, 5.54) + checkout_offset,
		Vector3(0.075, 0.25, 0.075),
		graphite_mat
	)
	_add_box(
		shell,
		"CheckoutRegisterScreenBezel",
		Vector3(5.64, 1.30, 5.40) + checkout_offset,
		Vector3(0.62, 0.40, 0.035),
		graphite_mat
	)
	var register_screen: MeshInstance3D = _add_box(
		shell,
		"CheckoutRegisterScreen",
		Vector3(5.64, 1.30, 5.36) + checkout_offset,
		Vector3(0.48, 0.30, 0.026),
		screen_mat
	)
	_mark_checkout_component(register_screen, monitor_component)
	_add_box(
		shell,
		"CheckoutRegisterKeypad",
		Vector3(5.35, 0.95, 5.84) + checkout_offset,
		Vector3(0.15, 0.030, 0.12),
		graphite_mat
	)
	_add_box(
		shell,
		"CheckoutReceiptSlip",
		Vector3(6.08, 0.905, 5.90) + checkout_offset,
		Vector3(0.13, 0.014, 0.08),
		paper_white_mat
	)
	_add_box(
		shell,
		"CheckoutManagerNamePlate",
		Vector3(5.50, 0.58, 6.625) + checkout_offset,
		Vector3(0.28, 0.07, 0.025),
		gold_mat
	)
	_add_box(
		shell,
		"CheckoutCounterPaperStack",
		Vector3(6.10, 0.848, 6.28) + checkout_offset,
		Vector3(0.13, 0.026, 0.09),
		paper_mat
	)
	var receipt_printer: MeshInstance3D = _add_box(
		shell,
		"CheckoutReceiptPrinterBody",
		Vector3(6.08, 0.865, 5.88) + checkout_offset,
		Vector3(0.21, 0.07, 0.15),
		graphite_mat
	)
	_mark_checkout_component(receipt_printer, printer_component)
	_add_box(
		shell,
		"CheckoutReceiptPaperRoll",
		Vector3(6.08, 0.915, 5.83) + checkout_offset,
		Vector3(0.10, 0.028, 0.032),
		paper_white_mat
	)
	_add_checkout_indicator(
		shell,
		"CheckoutPrinterReadyLight",
		Vector3(5.99, 0.902, 5.85) + checkout_offset,
		readiness_mat
	)
	var card_reader: MeshInstance3D = _add_box(
		shell,
		"CheckoutCardReader",
		Vector3(5.20, 0.855, 6.50) + checkout_offset,
		Vector3(0.12, 0.045, 0.15),
		graphite_mat
	)
	_mark_checkout_component(card_reader, card_reader_component)
	_add_box(
		shell,
		"CheckoutBarcodeScanner",
		Vector3(6.18, 0.848, 6.02) + checkout_offset,
		Vector3(0.105, 0.036, 0.060),
		graphite_mat
	)
	_add_checkout_indicator(
		shell,
		"CheckoutScannerReadyLight",
		Vector3(6.14, 0.882, 6.00) + checkout_offset,
		readiness_mat
	)
	_add_box(
		shell,
		"CheckoutCustomerPaymentDisplay",
		Vector3(5.20, 0.94, 6.64) + checkout_offset,
		Vector3(0.16, 0.060, 0.022),
		graphite_mat
	)
	_add_box(
		shell,
		"CheckoutCustomerPaymentDisplayScreen",
		Vector3(5.20, 0.94, 6.665) + checkout_offset,
		Vector3(0.11, 0.038, 0.014),
		screen_mat
	)
	_add_box(
		shell,
		"CheckoutCounterCableRun",
		Vector3(5.67, 0.807, 5.96) + checkout_offset,
		Vector3(0.22, 0.010, 0.014),
		dark_mat
	)
	_add_box(
		shell,
		"CheckoutScannerCable",
		Vector3(6.08, 0.807, 5.99) + checkout_offset,
		Vector3(0.15, 0.010, 0.014),
		dark_mat
	)
	_add_box(
		shell,
		"CheckoutBaggingSurface",
		Vector3(5.45, 0.836, 6.45) + checkout_offset,
		Vector3(0.24, 0.012, 0.15),
		service_mat
	)
	_add_box(
		shell,
		"CheckoutBagStack",
		Vector3(5.45, 0.858, 6.47) + checkout_offset,
		Vector3(0.12, 0.036, 0.075),
		paper_white_mat
	)
	_add_box(
		shell,
		"CheckoutManagerFloorMat",
		Vector3(5.85, 0.077, 5.40) + checkout_offset,
		Vector3(0.42, 0.014, 0.55),
		mat_mat
	)
	_add_box(
		shell,
		"CheckoutCustomerFloorMat",
		Vector3(4.85, 0.077, 7.22) + checkout_offset,
		Vector3(0.58, 0.014, 0.42),
		mat_mat
	)
	_add_label(shell, "CheckoutTradeInsText", "", Vector3(5.50, 1.12, 6.58) + checkout_offset, 15)
	_mark_checkout_visual_family(shell)


static func _add_checkout_indicator(
	shell: Node3D, name: String, position: Vector3, material: StandardMaterial3D
) -> void:
	var indicator: MeshInstance3D = _add_box(
		shell, name, position, Vector3(0.055, 0.018, 0.055), material
	)
	indicator.set_meta("checkout_station_visual_only", true)
	indicator.set_meta("checkout_station_role", "readiness_indicator")


static func _mark_checkout_visual_family(shell: Node3D) -> void:
	for child: Node in shell.get_children():
		if child.name.begins_with("Checkout"):
			child.set_meta("checkout_station_visual_only", true)


static func _checkout_component(concept_id: StringName) -> Dictionary:
	if String(concept_id).is_empty():
		return {}
	for component: Dictionary in StoreVisualKitScript.starter_checkout_station_components():
		if component.get("concept_id", &"") == concept_id:
			return component
	return {}


static func _mark_checkout_component(node: Node, component: Dictionary) -> void:
	if node == null or component.is_empty():
		return
	node.set_meta("starter_checkout_component_id", component.get("concept_id", &""))
	node.set_meta("starter_checkout_visual_id", component.get("visual_id", &""))
	node.set_meta("checkout_station_visual_only", true)
	node.set_meta("day_one_default_checkout_piece", bool(component.get("day_one_default", false)))


static func _add_used_game_wall_shelf(
	shell: Node3D, trim_mat: StandardMaterial3D, shelf_mat: StandardMaterial3D
) -> void:
	_add_box(
		shell,
		"StarterUsedShelfBacker",
		Vector3(-4.60, 1.34, -9.865),
		Vector3(2.48, 1.18, 0.045),
		_mat(Color(0.16, 0.11, 0.08, 1.0))
	)
	for rail: int in range(3):
		_add_box(
			shell,
			"StarterUsedShelfRail%02d" % rail,
			Vector3(-4.60, 0.88 + float(rail) * 0.44, -9.38),
			Vector3(2.34, 0.065, 0.13),
			shelf_mat
		)
	_add_box(
		shell,
		"StarterUsedShelfTopLip",
		Vector3(-4.60, 1.78, -9.31),
		Vector3(2.42, 0.055, 0.07),
		trim_mat
	)
	_add_box(
		shell,
		"StarterUsedShelfMiddleLip",
		Vector3(-4.60, 1.32, -9.31),
		Vector3(2.42, 0.055, 0.07),
		trim_mat
	)
	for index: int in range(3):
		_add_box(
			shell,
			"StarterUsedEmptySlot%02d" % index,
			Vector3(-5.18 + float(index) * 0.48, 1.00, -9.33),
			Vector3(0.30, 0.18, 0.026),
			_mat(Color(0.10, 0.075, 0.055, 1.0))
		)
		_add_box(
			shell,
			"StarterUsedShelfPriceTag%02d" % index,
			Vector3(-5.18 + float(index) * 0.48, 0.82, -9.28),
			Vector3(0.18, 0.052, 0.018),
			StoreVisualStyleScript.material_for_token(StoreVisualStyleScript.TOKEN_PRICE_TAG_FILL)
		)
	_add_box(
		shell,
		"StarterUsedShelfLeftDivider",
		Vector3(-5.74, 1.33, -9.32),
		Vector3(0.045, 0.92, 0.09),
		trim_mat
	)
	_add_box(
		shell,
		"StarterUsedShelfCenterDivider",
		Vector3(-4.60, 1.33, -9.32),
		Vector3(0.045, 0.92, 0.09),
		trim_mat
	)
	_add_box(
		shell,
		"StarterUsedShelfRightDivider",
		Vector3(-3.46, 1.33, -9.32),
		Vector3(0.045, 0.92, 0.09),
		trim_mat
	)
	_add_box(
		shell,
		"StarterUsedShelfBottomLip",
		Vector3(-4.60, 0.86, -9.31),
		Vector3(2.42, 0.055, 0.08),
		trim_mat
	)
	_add_box(
		shell,
		"StarterUsedShelfRightEmptyBay",
		Vector3(-3.72, 1.43, -9.33),
		Vector3(0.34, 0.23, 0.028),
		_mat(Color(0.10, 0.075, 0.055, 1.0))
	)
	_add_box(
		shell,
		"StarterUsedShelfRightPriceTag",
		Vector3(-3.72, 1.20, -9.28),
		Vector3(0.20, 0.055, 0.018),
		StoreVisualStyleScript.material_for_token(StoreVisualStyleScript.TOKEN_PRICE_TAG_FILL)
	)
	_add_box(
		shell,
		"StarterUsedShelfFloorFootprint",
		Vector3(-4.60, 0.078, -8.45),
		Vector3(2.55, 0.012, 0.34),
		_mat(Color(0.13, 0.09, 0.06, 1.0))
	)


static func _add_starter_display_table_context(
	shell: Node3D,
	trim_mat: StandardMaterial3D,
	dark_mat: StandardMaterial3D,
	table_mat: StandardMaterial3D,
	display_position: Vector3
) -> void:
	var display_center := display_position + Vector3(0.0, 0.0, 0.08)
	_add_box(
		shell,
		"StarterDisplayTableFootprint",
		display_center + Vector3(0.0, 0.078, 0.0),
		Vector3(2.82, 0.012, 1.18),
		_mat(Color(0.12, 0.09, 0.06, 1.0))
	)
	_add_box(
		shell,
		"StarterDisplayTableBacker",
		display_center + Vector3(0.0, 1.22, -0.44),
		Vector3(2.10, 0.42, 0.045),
		_mat(Color(0.17, 0.11, 0.07, 1.0))
	)
	_add_box(
		shell,
		"StarterDisplayTableBackRail",
		display_center + Vector3(0.0, 1.41, -0.37),
		Vector3(2.18, 0.055, 0.10),
		trim_mat
	)
	_add_box(
		shell,
		"StarterDisplayTableFrontLip",
		display_center + Vector3(0.0, 1.02, 0.46),
		Vector3(2.42, 0.075, 0.10),
		table_mat
	)
	_add_box(
		shell,
		"StarterDisplayTableLeftDivider",
		display_center + Vector3(-0.82, 1.17, 0.08),
		Vector3(0.045, 0.30, 0.70),
		trim_mat
	)
	_add_box(
		shell,
		"StarterDisplayTableRightDivider",
		display_center + Vector3(0.82, 1.17, 0.08),
		Vector3(0.045, 0.30, 0.70),
		trim_mat
	)
	_add_box(
		shell,
		"StarterDisplayTableRiser",
		display_center + Vector3(-0.48, 1.23, -0.12),
		Vector3(0.58, 0.10, 0.42),
		dark_mat
	)
	_add_box(
		shell,
		"StarterDisplayTableTray",
		display_center + Vector3(0.55, 1.09, 0.10),
		Vector3(0.64, 0.055, 0.48),
		table_mat
	)
	for index: int in range(2):
		_add_box(
			shell,
			"StarterDisplayEmptySlot%02d" % index,
			display_center + Vector3(0.16 + float(index) * 0.48, 1.015, 0.43),
			Vector3(0.22, 0.035, 0.030),
			_mat(Color(0.12, 0.085, 0.055, 1.0))
		)


static func _add_starter_product_visual(shell: Node3D, placement: Dictionary) -> void:
	var item_id: String = str(placement.get("product_item_id", ""))
	var visual: Node3D = ProductVisualFactoryScript.create_visual_for_item(
		_starter_product_visual_data(item_id, placement)
	)
	if visual == null:
		return
	visual.name = str(placement.get("name", item_id))
	visual.position = _placement_position(placement, Vector3.ZERO)
	visual.rotation_degrees = _placement_rotation(placement, Vector3.ZERO)
	visual.scale = _placement_scale(placement, Vector3.ONE)
	visual.set_meta("product_item_id", item_id)
	visual.set_meta("route_role", str(placement.get("route_role", "starter_sale_item")))
	visual.set_meta("stock_state", str(placement.get("stock_state", "")))
	if placement.has("delivery_index"):
		visual.set_meta("delivery_index", int(placement.get("delivery_index", -1)))
	visual.add_to_group("product_display")
	_mute_product_labels(visual)
	shell.add_child(visual)


static func _starter_product_visual_data(item_id: String, placement: Dictionary) -> Dictionary:
	var data: Dictionary = StarterProductVisualResolverScript.visual_data_for_item_id(item_id)
	data["route_role"] = str(placement.get("route_role", "starter_sale_item"))
	data["stock_state"] = str(placement.get("stock_state", ""))
	data["show_price_tag"] = bool(placement.get("show_price_tag", true))
	return data


static func _mute_product_labels(node: Node) -> void:
	var label: Label3D = node as Label3D
	if label != null:
		label.text = ""
	for child: Node in node.get_children():
		_mute_product_labels(child)


static func _add_stockroom_contents(
	shell: Node3D,
	trim_mat: StandardMaterial3D,
	dark_mat: StandardMaterial3D,
	stock_box_mat: StandardMaterial3D,
	paper_white_mat: StandardMaterial3D,
	gold_mat: StandardMaterial3D,
	rubber_mat: StandardMaterial3D,
	backroom_floor_mat: StandardMaterial3D,
	backroom_panel_mat: StandardMaterial3D,
	backroom_rack_mat: StandardMaterial3D,
	crate_shadow_mat: StandardMaterial3D
) -> void:
	_add_box(
		shell,
		"StockroomCoolFloorApron",
		Vector3(4.58, 0.079, -7.75),
		Vector3(2.52, 0.014, 4.30),
		backroom_floor_mat
	)
	_add_box(
		shell,
		"StockroomBackWallCoolPanel",
		Vector3(4.375, 1.44, -9.88),
		Vector3(6.00, 1.74, 0.026),
		backroom_panel_mat
	)
	_add_box(
		shell,
		"StockroomLeftWallCoolPanel",
		Vector3(1.34, 1.36, -7.80),
		Vector3(0.026, 1.58, 4.20),
		backroom_panel_mat
	)
	var stockroom_shelf: Node3D = _add_store_visual(
		shell,
		"StockroomBackRackKit",
		StoreVisualKitScript.STOCKROOM_SHELF,
		Vector3(4.52, 0.0, -9.50),
		Vector3.ONE
	)
	_flatten_visual_children(stockroom_shelf, shell)
	for index: int in range(4):
		var row: int = index / 2
		var column: int = index % 2
		_add_box(
			shell,
			"StockroomTallCrate%02d" % index,
			Vector3(3.48 + float(column) * 0.26, 0.37 + float(row) * 0.28, -8.35),
			Vector3(0.22, 0.24, 0.28),
			stock_box_mat if index % 2 == 0 else crate_shadow_mat
		)
		_add_box(
			shell,
			"StockroomTallCrateFace%02d" % index,
			Vector3(3.48 + float(column) * 0.26, 0.40 + float(row) * 0.28, -8.19),
			Vector3(0.13, 0.04, 0.018),
			paper_white_mat
		)
	_add_box(
		shell,
		"StockroomOverheadShelf",
		Vector3(4.72, 2.18, -8.58),
		Vector3(1.58, 0.06, 0.32),
		backroom_rack_mat
	)
	for index: int in range(3):
		_add_box(
			shell,
			"StockroomOverheadBin%02d" % index,
			Vector3(4.18 + float(index) * 0.48, 2.34, -8.58),
			Vector3(0.28, 0.20, 0.24),
			crate_shadow_mat
		)
	for index: int in range(6):
		var row: int = index / 3
		var column: int = index % 3
		_add_box(
			shell,
			"StockroomSupplyBox%02d" % index,
			Vector3(4.02 + float(column) * 0.34, 1.02 + float(row) * 0.44, -9.32),
			Vector3(0.26, 0.20, 0.24),
			stock_box_mat if index % 2 == 0 else crate_shadow_mat
		)
	_add_box(
		shell,
		"StockroomReceivingTableTop",
		Vector3(5.50, 0.78, -7.95),
		Vector3(0.48, 0.10, 0.70),
		backroom_rack_mat
	)
	_add_box(
		shell,
		"StockroomPickupBayFloorPlate",
		Vector3(4.90, 0.091, -8.70),
		Vector3(1.02, 0.018, 0.72),
		gold_mat
	)
	_add_box(
		shell,
		"StockroomPickupBayBackLightPanel",
		Vector3(4.90, 1.10, -9.82),
		Vector3(1.18, 1.18, 0.024),
		backroom_panel_mat
	)
	_add_box(
		shell,
		"StockroomPickupBayLabelPlate",
		Vector3(4.90, 1.76, -9.78),
		Vector3(0.72, 0.18, 0.030),
		gold_mat
	)
	_add_box(
		shell,
		"StockroomPickupBayLeftGuide",
		Vector3(4.27, 0.105, -8.70),
		Vector3(0.08, 0.018, 0.78),
		rubber_mat
	)
	_add_box(
		shell,
		"StockroomPickupBayRightGuide",
		Vector3(5.53, 0.105, -8.70),
		Vector3(0.08, 0.018, 0.78),
		rubber_mat
	)
	_add_box(
		shell,
		"StockroomReceivingTableLegA",
		Vector3(5.34, 0.39, -7.70),
		Vector3(0.055, 0.68, 0.055),
		backroom_rack_mat
	)
	_add_box(
		shell,
		"StockroomReceivingTableLegB",
		Vector3(5.66, 0.39, -8.20),
		Vector3(0.055, 0.68, 0.055),
		backroom_rack_mat
	)
	_add_box(
		shell,
		"StockroomReceivingTapeRoll",
		Vector3(5.40, 0.86, -7.83),
		Vector3(0.12, 0.08, 0.12),
		gold_mat
	)
	_add_box(
		shell,
		"StockroomTapeDispenserBase",
		Vector3(5.40, 0.84, -7.97),
		Vector3(0.22, 0.05, 0.10),
		crate_shadow_mat
	)
	_add_box(
		shell,
		"StockroomPackingClipboard",
		Vector3(5.56, 0.86, -8.09),
		Vector3(0.18, 0.035, 0.24),
		paper_white_mat
	)
	_add_box(
		shell,
		"StockroomOpenDeliveryCartonBase",
		Vector3(5.82, 0.92, -8.02),
		Vector3(0.36, 0.12, 0.26),
		stock_box_mat
	)
	_add_box(
		shell,
		"StockroomOpenDeliveryCartonInterior",
		Vector3(5.82, 1.005, -8.02),
		Vector3(0.30, 0.025, 0.20),
		crate_shadow_mat
	)
	_add_box(
		shell,
		"StockroomOpenDeliveryCartonFrontFlap",
		Vector3(5.82, 1.03, -7.84),
		Vector3(0.34, 0.035, 0.14),
		stock_box_mat
	)
	_add_box(
		shell,
		"StockroomOpenDeliveryCartonBackFlap",
		Vector3(5.82, 1.03, -8.20),
		Vector3(0.34, 0.035, 0.14),
		stock_box_mat
	)
	_add_box(
		shell,
		"StockroomOpenDeliveryCartonLeftFlap",
		Vector3(5.58, 1.03, -8.02),
		Vector3(0.12, 0.035, 0.24),
		stock_box_mat
	)
	_add_box(
		shell,
		"StockroomOpenDeliveryCartonRightFlap",
		Vector3(6.06, 1.03, -8.02),
		Vector3(0.12, 0.035, 0.24),
		stock_box_mat
	)
	for index: int in range(3):
		var case_mat: StandardMaterial3D = (
			dark_mat if index == 0 else backroom_rack_mat if index == 1 else crate_shadow_mat
		)
		_add_box(
			shell,
			"StockroomDeliveryCase%02d" % index,
			Vector3(5.73 + float(index) * 0.09, 1.06, -8.02),
			Vector3(0.065, 0.085, 0.16),
			case_mat
		)
	for index: int in range(2):
		_add_box(
			shell,
			"StockroomPackingSlip%02d" % index,
			Vector3(5.42 + float(index) * 0.14, 0.895, -8.20),
			Vector3(0.10, 0.014, 0.15),
			paper_white_mat
		)
		_add_box(
			shell,
			"StockroomClosedReserveCarton%02d" % index,
			Vector3(3.58 + float(index) * 0.34, 0.72, -9.20),
			Vector3(0.28, 0.24, 0.34),
			stock_box_mat
		)
		_add_box(
			shell,
			"StockroomReserveCartonTape%02d" % index,
			Vector3(3.58 + float(index) * 0.34, 0.85, -9.20),
			Vector3(0.035, 0.018, 0.30),
			gold_mat
		)
	_add_box(
		shell,
		"StockroomSortingMat",
		Vector3(4.12, 0.074, -7.35),
		Vector3(0.62, 0.018, 1.10),
		rubber_mat
	)
	_add_box(
		shell, "StockroomWallRack", Vector3(3.30, 1.52, -7.90), Vector3(0.10, 0.86, 1.30), trim_mat
	)
	_add_box(
		shell,
		"StockroomHandTruckHint",
		Vector3(5.68, 0.54, -6.45),
		Vector3(0.10, 0.72, 0.08),
		rubber_mat
	)
	_add_box(
		shell,
		"StockroomHandTruckToe",
		Vector3(5.62, 0.13, -6.61),
		Vector3(0.38, 0.05, 0.12),
		rubber_mat
	)
	_add_label(
		shell, "StockroomWallTaskText", "", Vector3(5.80, 1.87, -6.45), 18, Vector3(0.0, -90.0, 0.0)
	)


static func _add_stockroom_inventory_projection(store: Node, shell: Node3D) -> void:
	if shell == null:
		return
	var projector: Node3D = StockroomInventoryVisualProjectorScript.new() as Node3D
	projector.name = StockroomInventoryVisualProjectorScript.ROOT_NAME
	shell.add_child(projector)
	projector.setup(store, _resolve_inventory_system(store), _resolve_store_id(store))


static func _resolve_inventory_system(store: Node) -> InventorySystem:
	var inventory: InventorySystem = GameManager.get_inventory_system()
	if inventory != null:
		return inventory
	if store != null:
		var local_inventory: Variant = store.get("_inventory_system")
		if local_inventory is InventorySystem:
			return local_inventory as InventorySystem
	return null


static func _resolve_store_id(store: Node) -> StringName:
	var active: StringName = GameManager.get_active_store_id()
	if not String(active).is_empty():
		return active
	if store != null:
		var store_type: String = str(store.get("store_type"))
		if not store_type.is_empty():
			return StringName(store_type)
	return &"retro_games"


static func _add_wall(
	parent: Node3D, name: String, position: Vector3, size: Vector3, material: StandardMaterial3D
) -> void:
	var body := StaticBody3D.new()
	body.name = name
	body.collision_layer = 1
	body.collision_mask = 0
	body.position = position
	parent.add_child(body)
	_add_mesh_box(body, "Visual", Vector3.ZERO, size, material)
	var collision := CollisionShape3D.new()
	collision.name = "CollisionShape3D"
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)


static func _add_box(
	parent: Node3D, name: String, position: Vector3, size: Vector3, material: StandardMaterial3D
) -> MeshInstance3D:
	return _add_mesh_box(parent, name, position, size, material)


static func _add_product_box(
	parent: Node3D, name: String, position: Vector3, size: Vector3, material: StandardMaterial3D
) -> Node3D:
	var visual := Node3D.new()
	visual.name = name
	visual.position = position
	visual.set_meta("visual_source", "plain_case")
	visual.add_to_group("product_display")
	parent.add_child(visual)
	_add_mesh_box(visual, "Case", Vector3.ZERO, size, material)
	_add_mesh_box(
		visual,
		"SpineStripe",
		Vector3(0.0, size.y * 0.22, size.z * 0.56),
		Vector3(size.x * 0.70, size.y * 0.10, size.z * 0.16),
		_mat(Color(0.92, 0.72, 0.34, 1.0))
	)
	return visual


static func _add_store_visual(
	parent: Node3D,
	name: String,
	visual_id: StringName,
	position: Vector3,
	scale: Vector3,
	rotation_degrees: Vector3 = Vector3.ZERO
) -> Node3D:
	var visual: Node3D = StoreVisualKitScript.instantiate(visual_id) as Node3D
	if visual == null:
		push_error(
			"ExpandableStoreShellRuntime: visual '%s' missing from StoreVisualKit" % visual_id
		)
		visual = Node3D.new()
	visual.name = name
	visual.position = position
	visual.rotation_degrees = rotation_degrees
	visual.scale = scale
	visual.set_meta("visual_source", "store_visual_kit")
	visual.set_meta("store_visual_id", visual_id)
	parent.add_child(visual)
	return visual


static func _flatten_visual_children(source: Node3D, target: Node3D) -> void:
	if source == null or target == null:
		return
	var source_position: Vector3 = source.position
	for child: Node in source.get_children().duplicate():
		var child_3d: Node3D = child as Node3D
		if child_3d != null:
			child_3d.position += source_position
		source.remove_child(child)
		target.add_child(child)
	source.queue_free()


static func _add_plane_prop(
	parent: Node3D,
	name: String,
	position: Vector3,
	size: Vector2,
	material: StandardMaterial3D,
	rotation_degrees: Vector3 = Vector3.ZERO
) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	mesh_instance.position = position
	mesh_instance.rotation_degrees = rotation_degrees
	var mesh := PlaneMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	mesh_instance.set_meta("visual_source", "authored_surface")
	parent.add_child(mesh_instance)
	return mesh_instance


static func _add_mesh_box(
	parent: Node3D, name: String, position: Vector3, size: Vector3, material: StandardMaterial3D
) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	mesh_instance.position = position
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	StoreVisualStyleScript.apply_material_metadata(
		mesh_instance, material, _detail_role_for_size(size)
	)
	parent.add_child(mesh_instance)
	return mesh_instance


static func _detail_role_for_size(size: Vector3) -> StringName:
	var smallest: float = minf(size.x, minf(size.y, size.z))
	if smallest <= StarterDetailBuilderScript.MIN_DETAIL_THICKNESS + 0.006:
		return StarterDetailBuilderScript.ROLE_SEAM
	if size.y <= StarterDetailBuilderScript.MAX_DETAIL_THICKNESS:
		return StarterDetailBuilderScript.ROLE_LIP
	return StarterDetailBuilderScript.ROLE_PANEL


static func _add_omni_light(
	parent: Node3D, name: String, position: Vector3, color: Color, energy: float, omni_range: float
) -> void:
	var light := OmniLight3D.new()
	light.name = name
	light.position = position
	light.light_color = color
	light.light_energy = energy
	light.omni_range = omni_range
	parent.add_child(light)


static func _add_label(
	parent: Node3D,
	name: String,
	text: String,
	position: Vector3,
	font_size: int,
	rotation_degrees: Vector3 = Vector3.ZERO
) -> Label3D:
	var label := Label3D.new()
	label.name = name
	label.text = text
	label.position = position
	label.rotation_degrees = rotation_degrees
	label.pixel_size = 0.006
	label.font_size = font_size
	label.modulate = Color(1.0, 0.86, 0.46, 1.0)
	label.outline_size = 6
	label.outline_modulate = Color(0.05, 0.04, 0.03, 1.0)
	label.double_sided = false
	label.shaded = false
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	parent.add_child(label)
	return label


static func _recipe_token_mat(recipe: Dictionary, key: String) -> StandardMaterial3D:
	var token: StringName = recipe.get(key, &"") as StringName
	return StoreVisualStyleScript.material_for_token(token)


static func _recipe_family_mat(recipe: Dictionary, key: String) -> StandardMaterial3D:
	var family: StringName = recipe.get(key, &"") as StringName
	return StoreVisualStyleScript.material_for_family(family)


static func _mat(
	albedo: Color, emission: Color = Color.TRANSPARENT, emission_energy: float = 0.0
) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = albedo
	material.roughness = 0.86
	if emission_energy > 0.0:
		material.emission_enabled = true
		material.emission = emission
		material.emission_energy_multiplier = emission_energy
	return material


static func _glass_mat(albedo: Color) -> StandardMaterial3D:
	var material := _mat(albedo)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.blend_mode = BaseMaterial3D.BLEND_MODE_MIX
	return material
