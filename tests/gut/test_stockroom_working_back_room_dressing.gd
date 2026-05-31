extends GutTest

const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"
const EXPECTED_PICKUP_POSITION: Vector3 = Vector3(4.90, 0.0, -8.70)
const EXPECTED_BOUNDS_MIN: Vector3 = Vector3(-7.45, 0.0, -9.35)
const EXPECTED_BOUNDS_MAX: Vector3 = Vector3(7.45, 0.0, 9.05)
const STOCKROOM_APPARENT_MIN_AREA: float = 65.0
const STOCKROOM_APPARENT_MAX_AREA: float = 75.0

var _root: Node3D = null
var _saved_state: GameManager.State


func before_each() -> void:
	_saved_state = GameManager.current_state
	GameManager.current_state = GameManager.State.STORE_VIEW
	StoreSessionState.reset_new_run()
	var scene: PackedScene = load(SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	_root = scene.instantiate() as Node3D
	add_child(_root)
	await get_tree().process_frame
	await get_tree().process_frame


func after_each() -> void:
	if is_instance_valid(_root):
		_root.free()
	_root = null
	StoreSessionState.reset_new_run()
	GameManager.current_state = _saved_state


func test_stockroom_dressing_reads_as_working_back_room() -> void:
	var shell: Node3D = _shell()
	if shell == null:
		return
	for required: String in [
		"StockroomCoolFloorApron",
		"StockroomBackWallCoolPanel",
		"StockroomLeftWallCoolPanel",
		"StockroomBackRackShelf00",
		"StockroomBackRackShelf01",
		"StockroomBackRackShelf02",
		"StockroomTallCrate00",
		"StockroomTallCrate03",
		"StockroomOverheadShelf",
		"StockroomOverheadBin00",
		"StockroomReceivingTableTop",
		"StockroomTapeDispenserBase",
		"StockroomPackingClipboard",
		"StockroomPackingSlip00",
		"StockroomHandTruckToe",
	]:
		assert_not_null(_stockroom_node(shell, required), "Stockroom dressing missing: %s" % required)

	var vertical_storage_count: int = 0
	for prefix: String in [
		"StockroomBackRack",
		"StockroomTallCrate",
		"StockroomOverheadBin",
		"StockroomSupplyBox",
	]:
		vertical_storage_count += _count_children_with_prefix(shell, prefix)
	assert_gte(
		vertical_storage_count,
		18,
		"Stockroom should read through vertical storage density, not floor clutter"
	)


func test_stockroom_visual_footprint_reads_as_substantial_back_room() -> void:
	var shell: Node3D = _shell()
	if shell == null:
		return
	for required: String in [
		"StockroomExpandedCoolFloorApron",
		"StockroomExpandedBackWallPanel",
		"StockroomExpandedRightWallPanel",
		"StockroomExpandedFrontPartitionLow",
		"StockroomExpandedCeilingPanel",
		"StockroomExpandedDeepRackShelf00",
		"StockroomExpandedPalletStack00",
		"StockroomExpandedBoxWall00",
		"StockroomExpandedRollingLadderFrame",
	]:
		assert_not_null(
			shell.get_node_or_null(required), "Expanded stockroom visual missing: %s" % required
		)
	var apron: Node3D = shell.get_node_or_null("StockroomExpandedCoolFloorApron") as Node3D
	assert_not_null(apron, "Expanded stockroom needs a visual footprint apron")
	if apron == null:
		return
	var apron_size: Vector3 = _box_size(apron)
	var apparent_area: float = apron_size.x * apron_size.z
	assert_between(
		apparent_area,
		STOCKROOM_APPARENT_MIN_AREA,
		STOCKROOM_APPARENT_MAX_AREA,
		"Expanded stockroom visual footprint should target the 65-75 sq m guidance"
	)


func test_stockroom_dressing_uses_cooler_back_room_materials() -> void:
	var shell: Node3D = _shell()
	if shell == null:
		return
	var starter_floor: MeshInstance3D = shell.get_node_or_null("StarterFloor") as MeshInstance3D
	var cool_floor: MeshInstance3D = shell.get_node_or_null("StockroomCoolFloorApron") as MeshInstance3D
	var cool_panel: MeshInstance3D = shell.get_node_or_null("StockroomBackWallCoolPanel") as MeshInstance3D
	assert_not_null(starter_floor, "StarterFloor must exist")
	assert_not_null(cool_floor, "StockroomCoolFloorApron must exist")
	assert_not_null(cool_panel, "StockroomBackWallCoolPanel must exist")
	if starter_floor == null or cool_floor == null or cool_panel == null:
		return
	var starter_color: Color = _material_color(starter_floor)
	var cool_floor_color: Color = _material_color(cool_floor)
	var cool_panel_color: Color = _material_color(cool_panel)
	assert_gt(starter_color.r, starter_color.b, "Sales floor material should remain warmer")
	assert_gte(
		cool_floor_color.b,
		cool_floor_color.r,
		"Back-room floor material should shift cooler than the sales floor"
	)
	assert_gte(
		cool_panel_color.b,
		cool_panel_color.r,
		"Back-room wall panel material should shift cooler than the sales floor"
	)


func test_stockroom_dressing_remains_visual_only_and_clear_of_pickup_route() -> void:
	var shell: Node3D = _shell()
	var pickup: Node3D = _root.get_node_or_null("StoreSessionBackroomPickup") as Node3D
	assert_not_null(pickup, "StoreSessionBackroomPickup must exist")
	if shell == null or pickup == null:
		return
	var threshold: Node3D = shell.get_node_or_null("StockroomFloorTape") as Node3D
	assert_not_null(threshold, "StockroomFloorTape must mark the stockroom threshold")
	if threshold == null:
		return
	for prop_path: String in [
		"StockroomBackRackShelf00",
		"StockroomBackRackShelf01",
		"StockroomBackRackShelf02",
		"StockroomBackRackUpright350",
		"StockroomBackRackUpright528",
		"StockroomTallCrate00",
		"StockroomTallCrate03",
		"StockroomReceivingTableTop",
		"StockroomTapeDispenserBase",
		"StockroomPackingClipboard",
		"StockroomHandTruckToe",
	]:
		var prop: Node3D = _stockroom_node(shell, prop_path)
		assert_not_null(prop, "Stockroom visual-only prop missing: %s" % prop_path)
		if prop == null:
			continue
		assert_false(
			_has_interaction_descendant(prop),
			"%s must stay visual-only with no interaction or physics descendants" % prop_path
		)
		assert_gt(
			_flat_distance_to_segment(
				prop.global_position, threshold.global_position, pickup.global_position
			),
			0.34,
			"%s must not sit in the threshold-to-pickup route" % prop_path
		)


func test_stockroom_delivery_props_match_batch_flag_model() -> void:
	var shell: Node3D = _shell()
	var pickup: Node3D = _root.get_node_or_null("StoreSessionBackroomPickup") as Node3D
	assert_not_null(pickup, "StoreSessionBackroomPickup must exist")
	if shell == null or pickup == null:
		return
	var threshold: Node3D = shell.get_node_or_null("StockroomFloorTape") as Node3D
	assert_not_null(threshold, "StockroomFloorTape must mark the stockroom threshold")
	if threshold == null:
		return
	for prop_path: String in [
		"StockroomOpenDeliveryCartonBase",
		"StockroomOpenDeliveryCartonInterior",
		"StockroomOpenDeliveryCartonFrontFlap",
		"StockroomOpenDeliveryCartonBackFlap",
		"StockroomOpenDeliveryCartonLeftFlap",
		"StockroomOpenDeliveryCartonRightFlap",
		"StockroomClosedReserveCarton00",
		"StockroomClosedReserveCarton01",
	]:
		var prop: Node3D = shell.get_node_or_null(prop_path) as Node3D
		assert_not_null(prop, "Stockroom delivery prop missing: %s" % prop_path)
		if prop == null:
			continue
		assert_false(
			_has_interaction_descendant(prop),
			"%s must stay visual-only with no interaction or physics descendants" % prop_path
		)
		assert_gt(
			_flat_distance_to_segment(prop.position, threshold.position, pickup.position),
			0.55,
			"%s must leave the threshold-to-pickup route clear" % prop_path
		)
	assert_eq(
		_count_children_with_prefix(shell, "StockroomDeliveryCase"),
		StoreSessionController._BACKROOM_DELIVERY_QUANTITY,
		"Open delivery carton should show the current carried batch quantity"
	)
	assert_eq(
		_count_children_with_prefix(shell, "StockroomClosedReserveCarton"),
		StoreSessionController.starter_reserve_item_ids().size(),
		"Closed reserve cartons should read as non-interactive later stock"
	)


func test_expanded_stockroom_scope_is_visual_only_and_route_safe() -> void:
	var shell: Node3D = _shell()
	var pickup: Node3D = _root.get_node_or_null("StoreSessionBackroomPickup") as Node3D
	assert_not_null(pickup, "StoreSessionBackroomPickup must exist")
	if shell == null or pickup == null:
		return
	var threshold: Node3D = shell.get_node_or_null("StockroomFloorTape") as Node3D
	assert_not_null(threshold, "StockroomFloorTape must mark the stockroom threshold")
	if threshold == null:
		return
	for prop_path: String in [
		"StockroomExpandedFrontPartitionLow",
		"StockroomExpandedFrontPartitionHighA",
		"StockroomExpandedFrontPartitionHighB",
		"StockroomExpandedDeepRackShelf00",
		"StockroomExpandedDeepRackShelf03",
		"StockroomExpandedPalletStack00",
		"StockroomExpandedPalletStack02",
		"StockroomExpandedBoxWall00",
		"StockroomExpandedBoxWall03",
		"StockroomExpandedRollingLadderFrame",
	]:
		var prop: Node3D = shell.get_node_or_null(prop_path) as Node3D
		assert_not_null(prop, "Expanded stockroom visual-only prop missing: %s" % prop_path)
		if prop == null:
			continue
		assert_false(
			_has_interaction_descendant(prop),
			"%s must stay visual-only with no interaction or physics descendants" % prop_path
		)
		assert_gt(
			_flat_distance_to_segment(prop.position, threshold.position, pickup.position),
			0.55,
			"%s must not sit in the threshold-to-pickup route" % prop_path
		)


func test_expanded_stockroom_preserves_pickup_bounds_and_customer_route() -> void:
	var shell: Node3D = _shell()
	var pickup: Node3D = _root.get_node_or_null("StoreSessionBackroomPickup") as Node3D
	var spawn: Marker3D = _root.get_node_or_null("PlayerEntrySpawn") as Marker3D
	assert_not_null(shell, "Boot must generate the expanded expandable store shell")
	assert_not_null(pickup, "StoreSessionBackroomPickup must exist")
	assert_not_null(spawn, "PlayerEntrySpawn must exist")
	if shell == null or pickup == null or spawn == null:
		return
	assert_eq(pickup.position, EXPECTED_PICKUP_POSITION)
	assert_eq(spawn.get_meta("bounds_min"), EXPECTED_BOUNDS_MIN)
	assert_eq(spawn.get_meta("bounds_max"), EXPECTED_BOUNDS_MAX)
	var apron: Node3D = shell.get_node_or_null("StockroomExpandedCoolFloorApron") as Node3D
	assert_not_null(apron, "Expanded stockroom needs a visual footprint apron")
	if apron == null:
		return
	var apron_size: Vector3 = _box_size(apron)
	var nav_config: Node = _root.get_node_or_null("CustomerNavConfig")
	assert_not_null(nav_config, "CustomerNavConfig must exist")
	if nav_config == null:
		return
	for marker_name: String in [
		"BrowseWaypoint01",
		"BrowseWaypoint02",
		"BrowseWaypoint03",
		"BrowseWaypoint04",
		"CheckoutApproach",
	]:
		var marker: Marker3D = nav_config.get_node_or_null(marker_name) as Marker3D
		assert_not_null(marker, "%s must exist" % marker_name)
		if marker == null:
			continue
		assert_false(
			_is_inside_box_footprint(marker.position, apron.position, apron_size),
			"%s must not be consumed by the expanded stockroom visual footprint" % marker_name
		)


func _shell() -> Node3D:
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	assert_not_null(shell, "Boot must generate the expanded expandable store shell")
	return shell


func _count_children_with_prefix(parent: Node, prefix: String) -> int:
	var total := 0
	for child: Node in parent.get_children():
		if str(child.name).begins_with(prefix):
			total += 1
		total += _count_children_with_prefix(child, prefix)
	return total


func _stockroom_node(parent: Node, child_name: String) -> Node3D:
	var direct: Node3D = parent.get_node_or_null(child_name) as Node3D
	if direct != null:
		return direct
	return parent.find_child(child_name, true, false) as Node3D


func _material_color(mesh_instance: MeshInstance3D) -> Color:
	var material: StandardMaterial3D = mesh_instance.material_override as StandardMaterial3D
	if material == null:
		return Color.TRANSPARENT
	return material.albedo_color


func _box_size(node: Node3D) -> Vector3:
	var mesh_instance: MeshInstance3D = node as MeshInstance3D
	if mesh_instance == null:
		mesh_instance = node.get_node_or_null("Visual") as MeshInstance3D
	if mesh_instance == null:
		return Vector3.ZERO
	var box_mesh: BoxMesh = mesh_instance.mesh as BoxMesh
	if box_mesh == null:
		return Vector3.ZERO
	return box_mesh.size


func _has_interaction_descendant(root: Node) -> bool:
	if (
		root is Area3D
		or root is CollisionObject3D
		or root is CollisionShape3D
		or root is Interactable
	):
		return true
	for child: Node in root.get_children():
		if _has_interaction_descendant(child):
			return true
	return false


func _flat_distance_to_segment(point: Vector3, start: Vector3, end: Vector3) -> float:
	var point_2d := Vector2(point.x, point.z)
	var start_2d := Vector2(start.x, start.z)
	var end_2d := Vector2(end.x, end.z)
	var segment := end_2d - start_2d
	var length_squared: float = segment.length_squared()
	if length_squared <= 0.0001:
		return point_2d.distance_to(start_2d)
	var t: float = clampf((point_2d - start_2d).dot(segment) / length_squared, 0.0, 1.0)
	return point_2d.distance_to(start_2d + segment * t)


func _is_inside_box_footprint(point: Vector3, center: Vector3, size: Vector3) -> bool:
	return (
		point.x >= center.x - size.x * 0.5
		and point.x <= center.x + size.x * 0.5
		and point.z >= center.z - size.z * 0.5
		and point.z <= center.z + size.z * 0.5
	)
