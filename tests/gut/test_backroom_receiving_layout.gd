extends GutTest

const RETRO_GAMES_SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"
const PICKUP_PATH: String = "StoreSessionBackroomPickup"
const PICKUP_INTERACTABLE_PATH: String = "StoreSessionBackroomPickup/Interactable"
const HIDDEN_CLUE_PATH: String = "StoreSessionHiddenClue"
const HIDDEN_CLUE_INTERACTABLE_PATH: String = "StoreSessionHiddenClue/Interactable"
const LOADING_MAT_PATH: String = "ReadabilityProps/BackroomDressing/LoadingZoneMat"
const RECEIVING_TABLE_PATH: String = "ReadabilityProps/BackroomDressing/ReceivingTableTop"
const DOOR_THRESHOLD_PATH: String = "ReadabilityProps/ZoneIdentity/BackroomDoorThreshold"
const MIN_PICKUP_CLEARANCE: float = 0.72
const MIN_APPROACH_LANE_CLEARANCE: float = 0.52

var _root: Node3D = null


func before_each() -> void:
	var scene: PackedScene = load(RETRO_GAMES_SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	_root = scene.instantiate() as Node3D
	assert_not_null(_root, "retro_games.tscn must instantiate as Node3D")


func after_each() -> void:
	if is_instance_valid(_root):
		_root.free()
	_root = null


func test_pickup_bay_centers_inventory_target() -> void:
	var pickup: Node3D = _node3d(PICKUP_PATH)
	var interactable: Node3D = _node3d(PICKUP_INTERACTABLE_PATH)
	var loading_mat: Node3D = _node3d(LOADING_MAT_PATH)
	var table: Node3D = _node3d(RECEIVING_TABLE_PATH)
	if pickup == null or interactable == null or loading_mat == null or table == null:
		return

	assert_lt(
		_flat_distance(pickup, interactable),
		0.05,
		"Backroom pickup trigger must remain aligned with its root"
	)
	assert_lt(
		_flat_distance(pickup, loading_mat),
		0.28,
		"LoadingZoneMat must stay centered on the inventory pickup"
	)
	assert_between(
		_flat_distance(pickup, table),
		0.65,
		1.15,
		"Receiving table must sit beside the pickup bay without occupying it"
	)
	assert_gt(
		_scene_position(table).x,
		_scene_position(pickup).x + 0.55,
		"Receiving table must read as the side work surface, not the pickup target"
	)


func test_backroom_threshold_uses_floor_guides_not_route_text() -> void:
	var threshold: Node3D = _node3d(DOOR_THRESHOLD_PATH)
	var left_guide: Node3D = _node3d(
		"ReadabilityProps/ZoneIdentity/BackroomThresholdLeftGuide"
	)
	var right_guide: Node3D = _node3d(
		"ReadabilityProps/ZoneIdentity/BackroomThresholdRightGuide"
	)
	if threshold == null or left_guide == null or right_guide == null:
		return
	assert_lt(
		_flat_distance(threshold, left_guide),
		1.1,
		"Left threshold guide must stay tied to the backroom doorway"
	)
	assert_lt(
		_flat_distance(threshold, right_guide),
		1.1,
		"Right threshold guide must stay tied to the backroom doorway"
	)
	assert_lt(
		_scene_position(left_guide).x,
		_scene_position(threshold).x,
		"Left guide must frame the doorway from the sales-floor side"
	)
	assert_gt(
		_scene_position(right_guide).x,
		_scene_position(threshold).x,
		"Right guide must frame the doorway from the sales-floor side"
	)
	for cue: Node in [threshold, left_guide, right_guide]:
		assert_false(
			_has_label_descendant(cue),
			"Backroom floor/threshold affordances must not add route text"
		)


func test_backroom_props_leave_pickup_and_exit_lane_clear() -> void:
	var pickup: Node3D = _node3d(PICKUP_PATH)
	var threshold: Node3D = _node3d(DOOR_THRESHOLD_PATH)
	if pickup == null or threshold == null:
		return

	for prop_path: String in [
		RECEIVING_TABLE_PATH,
		"ReadabilityProps/BackroomDressing/ReceivingCartonStackA",
		"ReadabilityProps/BackroomDressing/ReceivingCartonStackB",
		"ReadabilityProps/BackroomDressing/StockStackA",
		"ReadabilityProps/BackroomDressing/StockStackB",
		"ReadabilityProps/BackroomDressing/StockStackC",
		"ReadabilityProps/BackroomDressing/HandTruckToePlate",
		HIDDEN_CLUE_PATH,
	]:
		var prop: Node3D = _node3d(prop_path)
		if prop == null:
			continue
		assert_gt(
			_flat_distance(pickup, prop),
			MIN_PICKUP_CLEARANCE,
			"%s must not crowd the inventory pickup" % prop_path
		)
		assert_gt(
			_flat_distance_to_segment(
				_scene_position(prop),
				_scene_position(threshold),
				_scene_position(pickup)
			),
			MIN_APPROACH_LANE_CLEARANCE,
			"%s must not sit in the backroom entry/exit lane" % prop_path
		)


func test_storage_run_and_receiving_paperwork_are_authored() -> void:
	for prop_path: String in [
		"ReadabilityProps/BackroomDressing/StorageRunShelfLower",
		"ReadabilityProps/BackroomDressing/StorageRunShelfUpper",
		"ReadabilityProps/BackroomDressing/StorageRunUprightLeft",
		"ReadabilityProps/BackroomDressing/StorageRunUprightRight",
		"ReadabilityProps/BackroomDressing/PickupBayClipboard",
		"ReadabilityProps/BackroomDressing/ReceivingSheet",
	]:
		var prop: MeshInstance3D = _root.get_node_or_null(prop_path) as MeshInstance3D
		assert_not_null(prop, "Backroom receiving prop missing: %s" % prop_path)
		if prop != null:
			assert_not_null(prop.mesh, "%s must carry authored mesh" % prop_path)

	var pickup: Node3D = _node3d(PICKUP_PATH)
	var shelf: Node3D = _node3d("ReadabilityProps/BackroomDressing/StorageRunShelfLower")
	if pickup != null and shelf != null:
		assert_lt(
			_scene_position(shelf).z,
			_scene_position(pickup).z - 0.75,
			"Storage run must read along the back wall behind the pickup bay"
		)


func test_hidden_clue_stays_accessible_flavor_not_objective_clutter() -> void:
	var pickup: Node3D = _node3d(PICKUP_PATH)
	var clue: Node3D = _node3d(HIDDEN_CLUE_PATH)
	var interactable: Node = _root.get_node_or_null(HIDDEN_CLUE_INTERACTABLE_PATH)
	if pickup == null or clue == null or interactable == null:
		return

	assert_eq(
		(interactable.get_script() as Script).resource_path,
		"res://game/scripts/store_session/hidden_clue_interactable.gd",
		"Hidden clue must keep its hidden-thread interactable script"
	)
	assert_lte(
		_flat_distance(pickup, clue),
		2.25,
		"Hidden clue should remain discoverable inside the backroom"
	)
	assert_gt(
		_flat_distance(pickup, clue),
		0.9,
		"Hidden clue must not compete with the inventory pickup hotspot"
	)
	for prop_path: String in [
		"StoreSessionHiddenClue/ClueConsoleBase",
		"StoreSessionHiddenClue/ClueConsoleShell",
		"StoreSessionHiddenClue/ClueRepairTag",
	]:
		assert_not_null(
			_root.get_node_or_null(prop_path),
			"Hidden clue needs grounded console-stack flavor: %s" % prop_path
		)


func test_backroom_signage_and_dressing_stay_non_interactive() -> void:
	for label_path: String in [
		"ReadabilityProps/BackroomDressing/TodayDeliverySign",
		"back_room/RefurbHeader",
		"ZoneLabels/BackroomLabel",
	]:
		var label: Label3D = _root.get_node_or_null(label_path) as Label3D
		assert_not_null(label, "Backroom sign missing: %s" % label_path)
		if label != null:
			assert_false(label.double_sided, "%s must not mirror from behind" % label_path)

	var dressing: Node = _root.get_node_or_null("ReadabilityProps/BackroomDressing")
	assert_not_null(dressing, "BackroomDressing must exist")
	if dressing != null:
		assert_false(
			_has_interaction_descendant(dressing),
			"BackroomDressing must remain visual-only"
		)


func _node3d(node_path: String) -> Node3D:
	var node: Node3D = _root.get_node_or_null(node_path) as Node3D
	assert_not_null(node, "%s must exist" % node_path)
	return node


func _has_interaction_descendant(root: Node) -> bool:
	if root is Area3D or root is CollisionShape3D or root is StaticBody3D:
		return true
	for child: Node in root.get_children():
		if _has_interaction_descendant(child):
			return true
	return false


func _has_label_descendant(root: Node) -> bool:
	if root is Label3D:
		return true
	for child: Node in root.get_children():
		if _has_label_descendant(child):
			return true
	return false


func _flat_distance(a: Node3D, b: Node3D) -> float:
	return _flat_distance_vec(_scene_position(a), _scene_position(b))


func _flat_distance_vec(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x, a.z).distance_to(Vector2(b.x, b.z))


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


func _scene_position(node: Node3D) -> Vector3:
	return _scene_transform(node).origin


func _scene_transform(node: Node3D) -> Transform3D:
	var scene_transform: Transform3D = node.transform
	var cursor: Node = node.get_parent()
	while cursor is Node3D:
		scene_transform = (cursor as Node3D).transform * scene_transform
		cursor = cursor.get_parent()
	return scene_transform
