extends GutTest

const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"
const TERMINAL_PATH: String = "BackOfficeTerminal"
const TERMINAL_TABS_PATH: String = "BackOfficeTerminal/TerminalTabs"
const TERMINAL_STATUS_PATH: String = "BackOfficeTerminal/TerminalStatus"
const ORDERS_BRIDGE_PATH: String = "BackOfficeTerminal/OrdersBridgeTag"
const MIN_PICKUP_CLEARANCE: float = 1.25
const MIN_APPROACH_LANE_CLEARANCE: float = 0.65

var _root: Node3D = null


func before_each() -> void:
	var scene: PackedScene = load(SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	_root = scene.instantiate() as Node3D
	assert_not_null(_root, "retro_games.tscn must instantiate as Node3D")


func after_each() -> void:
	if is_instance_valid(_root):
		_root.free()
	_root = null


func test_terminal_is_authored_as_visible_back_office_surface() -> void:
	var terminal: Node3D = _node3d(TERMINAL_PATH)
	var pickup: Node3D = _node3d("StoreSessionBackroomPickup")
	var threshold: Node3D = _node3d("ReadabilityProps/ZoneIdentity/BackroomDoorThreshold")
	if terminal == null or pickup == null or threshold == null:
		return

	assert_true(
		_is_visible_through_ancestors(terminal),
		"Back-office terminal must be visible in its authored scene path"
	)
	assert_true(
		StoreVisualScopeProfile.KEEP_ROOT_NODES.has(StringName(TERMINAL_PATH)),
		"Back-office terminal must stay in the Day-1 visible root scope"
	)
	assert_gt(
		_flat_distance(terminal, pickup),
		MIN_PICKUP_CLEARANCE,
		"Terminal must not crowd the back-room inventory pickup"
	)
	assert_gt(
		_flat_distance_to_segment(
			_scene_position(terminal),
			_scene_position(threshold),
			_scene_position(pickup)
		),
		MIN_APPROACH_LANE_CLEARANCE,
		"Terminal must not sit in the back-room entry or exit lane"
	)


func test_terminal_shell_copy_marks_destinations_locked_or_existing() -> void:
	var tabs: Label3D = _label(TERMINAL_TABS_PATH)
	var status: Label3D = _label(TERMINAL_STATUS_PATH)
	var bridge: Label3D = _label(ORDERS_BRIDGE_PATH)
	if tabs == null or status == null or bridge == null:
		return

	var tabs_text: String = tabs.text.to_upper()
	for destination: String in [
		"CALENDAR",
		"ORDERS",
		"BUY STOCK",
		"MESSAGES",
		"STORE NOTES",
	]:
		assert_true(
			tabs_text.contains(destination),
			"Terminal shell must represent staged destination: %s" % destination
		)
	assert_true(
		tabs_text.contains("LOCKED"),
		"Terminal shell must mark staged destinations as locked"
	)
	assert_true(
		tabs_text.contains("ORDER PANEL"),
		"Orders shell copy must point at the existing order panel contract"
	)
	assert_true(
		status.text.to_upper().contains("NO DAY 1 TASK"),
		"Terminal status must not create a Day-1 objective"
	)
	assert_true(
		bridge.text.to_lower().contains("existing order panel"),
		"Terminal must describe orders as an existing surface, not duplicate state"
	)


func test_terminal_has_no_prompt_owner_or_runtime_state() -> void:
	var terminal: Node = _root.get_node_or_null(TERMINAL_PATH)
	assert_not_null(terminal, "Back-office terminal must exist")
	if terminal == null:
		return

	var forbidden: Array[String] = []
	_collect_forbidden_runtime_nodes(terminal, forbidden)
	assert_eq(
		forbidden,
		[] as Array[String],
		"Terminal must remain staged dressing without interactables, collision, or scripts"
	)

	var controller: Node = _root.get_node_or_null("StoreSessionController")
	assert_not_null(controller, "StoreSessionController must exist")
	if controller == null:
		return
	var terminal_target: String = "%s/Interactable" % TERMINAL_PATH
	for table: Array in [
		controller.get("_training_objectives"),
		controller.get("_day_one_objectives"),
	]:
		for entry: Dictionary in table:
			assert_ne(
				str(entry.get("target_path", "")),
				terminal_target,
				"Terminal must not become a training or Day-1 objective target"
			)


func _node3d(node_path: String) -> Node3D:
	var node: Node3D = _root.get_node_or_null(node_path) as Node3D
	assert_not_null(node, "%s must exist" % node_path)
	return node


func _label(node_path: String) -> Label3D:
	var label: Label3D = _root.get_node_or_null(node_path) as Label3D
	assert_not_null(label, "%s must exist" % node_path)
	return label


func _collect_forbidden_runtime_nodes(node: Node, out: Array[String]) -> void:
	if (
		node is Interactable
		or node is Area3D
		or node is CollisionObject3D
		or node is CollisionShape3D
		or node.get_script() != null
	):
		out.append(_relative_path(node))
	for child: Node in node.get_children():
		_collect_forbidden_runtime_nodes(child, out)


func _is_visible_through_ancestors(node: Node) -> bool:
	var cursor: Node = node
	while cursor != null and cursor != _root:
		if cursor is Node3D and not (cursor as Node3D).visible:
			return false
		cursor = cursor.get_parent()
	return true


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


func _relative_path(node: Node) -> String:
	return str(_root.get_path_to(node))
