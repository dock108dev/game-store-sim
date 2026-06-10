extends Node3D
class_name FixturePlacementManager

@export var default_ghost_position: Vector3 = Vector3(-0.8, 0.04, 2.15)
@export var default_ghost_rotation_y: float = 0.0
@export var ghost_preview_path: NodePath = NodePath("GhostRackPreview")
@export var placement_bounds_min: Vector3 = Vector3(-5.7, 0.0, -4.8)
@export var placement_bounds_max: Vector3 = Vector3(5.7, 0.0, 4.8)
@export var valid_placement_material: Material
@export var invalid_placement_material: Material
@export var snap_grid_size: float = 0.25
@export var rotation_step_degrees: float = 90.0
@export var path_clearance_points: PackedVector3Array = PackedVector3Array([
	Vector3(0.9, 0.0, -2.5),
	Vector3(2.8, 0.0, 0.6),
	Vector3(-4.6, 0.0, 2.6),
])
@export var path_clearance_radius: float = 0.8
@export var obstacle_clearance_radius: float = 0.15

const PLACEMENT_STATE_HIDDEN := "hidden"
const PLACEMENT_STATE_VALID := "valid"
const PLACEMENT_STATE_INVALID := "invalid"

var current_order_id: String = ""
var current_fixture_id: String = ""
var current_fixture_footprint_size: Vector2 = Vector2.ONE
var placement_issue: String = ""
var placement_state: String = PLACEMENT_STATE_HIDDEN
var placed_fixture_count: int = 0
var placement_history: Array[Dictionary] = []
var placed_fixture_bounds: Array[Dictionary] = []
var last_confirmation: Dictionary = {}


func _ready() -> void:
	hide_ghost()


func show_ghost_for_order(order: Dictionary) -> bool:
	if order.is_empty():
		return false

	var ghost := _get_ghost_preview()
	if ghost == null:
		return false

	current_order_id = str(order.get("order_id", ""))
	current_fixture_id = str(order.get("fixture_id", ""))
	var footprint_variant = order.get("footprint_size", Vector2.ONE)
	current_fixture_footprint_size = footprint_variant if footprint_variant is Vector2 else Vector2.ONE
	placement_history.clear()
	placement_issue = ""
	last_confirmation.clear()
	ghost.rotation = Vector3(0.0, default_ghost_rotation_y, 0.0)
	ghost.visible = true
	set_ghost_position(default_ghost_position)
	return true


func hide_ghost() -> void:
	var ghost := _get_ghost_preview()
	if ghost != null:
		ghost.visible = false
	current_order_id = ""
	current_fixture_id = ""
	current_fixture_footprint_size = Vector2.ONE
	placement_history.clear()
	placement_issue = ""
	placement_state = PLACEMENT_STATE_HIDDEN


func cancel_current_placement() -> Dictionary:
	if current_order_id.is_empty():
		return {}

	var canceled := {
		"order_id": current_order_id,
		"fixture_id": current_fixture_id,
	}
	hide_ghost()
	return canceled


func is_ghost_visible() -> bool:
	var ghost := _get_ghost_preview()
	return ghost != null and ghost.visible


func get_ghost_position() -> Vector3:
	var ghost := _get_ghost_preview()
	if ghost == null:
		return Vector3.ZERO

	return ghost.position


func set_ghost_position(position: Vector3, record_history: bool = false) -> bool:
	var ghost := _get_ghost_preview()
	if ghost == null:
		return false

	if record_history:
		_record_adjustment_state()
	ghost.position = position
	_refresh_placement_state()
	return is_current_position_valid()


func snap_ghost_to_grid() -> bool:
	var ghost := _get_ghost_preview()
	if ghost == null:
		return false

	return set_ghost_position(_snap_position(ghost.position), true)


func move_ghost_by_grid(delta_x: int, delta_z: int) -> bool:
	var ghost := _get_ghost_preview()
	if ghost == null:
		return false

	var position := ghost.position + Vector3(
		float(delta_x) * snap_grid_size,
		0.0,
		float(delta_z) * snap_grid_size
	)
	return set_ghost_position(_snap_position(position), true)


func rotate_ghost(clockwise: bool = true) -> bool:
	var ghost := _get_ghost_preview()
	if ghost == null:
		return false

	var direction := 1.0 if clockwise else -1.0
	_record_adjustment_state()
	ghost.rotation.y = _normalize_radians(
		ghost.rotation.y + deg_to_rad(rotation_step_degrees) * direction
	)
	_refresh_placement_state()
	return is_current_position_valid()


func undo_last_adjustment() -> bool:
	var ghost := _get_ghost_preview()
	if ghost == null or not can_undo_adjustment():
		return false

	var previous: Dictionary = placement_history.pop_back()
	ghost.position = previous.get("position", ghost.position)
	ghost.rotation.y = float(previous.get("rotation_y", ghost.rotation.y))
	_refresh_placement_state()
	return true


func can_undo_adjustment() -> bool:
	return is_ghost_visible() and not placement_history.is_empty()


func get_ghost_rotation_y() -> float:
	var ghost := _get_ghost_preview()
	if ghost == null:
		return 0.0

	return ghost.rotation.y


func validate_ghost_position(position: Vector3) -> bool:
	var footprint := _get_rotated_footprint(get_ghost_rotation_y())
	var half_x := footprint.x * 0.5
	var half_z := footprint.y * 0.5
	if position.x - half_x < placement_bounds_min.x \
			or position.x + half_x > placement_bounds_max.x \
			or position.z - half_z < placement_bounds_min.z \
			or position.z + half_z > placement_bounds_max.z:
		placement_issue = "out_of_bounds"
		return false

	if _blocks_critical_path(position, footprint):
		placement_issue = "path_blocked"
		return false

	if _overlaps_placed_fixture(position, footprint):
		placement_issue = "overlap"
		return false

	placement_issue = ""
	return true


func is_current_position_valid() -> bool:
	return placement_state == PLACEMENT_STATE_VALID


func can_confirm_current_placement() -> bool:
	return is_ghost_visible() and is_current_position_valid() and not current_order_id.is_empty()


func get_placement_issue() -> String:
	if placement_state == PLACEMENT_STATE_VALID:
		return ""
	return placement_issue


func get_placement_summary_text() -> String:
	if not is_ghost_visible():
		if last_confirmation.is_empty():
			return "Placement preview: hidden"
		return "Last placed %s at %.2f, %.2f" % [
			str(last_confirmation.get("fixture_id", "fixture")),
			float(last_confirmation.get("position_x", 0.0)),
			float(last_confirmation.get("position_z", 0.0)),
		]

	var issue_text := "valid" if is_current_position_valid() else placement_issue
	var position := get_ghost_position()
	var footprint := _get_rotated_footprint(get_ghost_rotation_y())
	return "Placement preview: %s | pos %.2f, %.2f | rot %d | footprint %.2fx%.2f" % [
		issue_text,
		position.x,
		position.z,
		int(roundf(rad_to_deg(get_ghost_rotation_y()))),
		footprint.x,
		footprint.y,
	]


func confirm_current_placement(parent: Node, fixture_scene_path: String) -> Node3D:
	if parent == null or fixture_scene_path.is_empty() or not can_confirm_current_placement():
		return null

	var fixture_scene := load(fixture_scene_path) as PackedScene
	if fixture_scene == null:
		return null

	var fixture := fixture_scene.instantiate() as Node3D
	if fixture == null:
		return null

	var ghost := _get_ghost_preview()
	var placed_transform := ghost.global_transform
	placed_fixture_count += 1
	fixture.name = "%s%03d" % [_fixture_node_name(current_fixture_id), placed_fixture_count]
	parent.add_child(fixture)
	fixture.global_transform = placed_transform
	var footprint := _get_rotated_footprint(placed_transform.basis.get_euler().y)
	placed_fixture_bounds.append({
		"order_id": current_order_id,
		"fixture_id": current_fixture_id,
		"position": placed_transform.origin,
		"footprint_size": footprint,
	})
	last_confirmation = {
		"order_id": current_order_id,
		"fixture_id": current_fixture_id,
		"position_x": placed_transform.origin.x,
		"position_z": placed_transform.origin.z,
		"rotation_y": placed_transform.basis.get_euler().y,
	}
	hide_ghost()
	return fixture


func get_placement_state() -> String:
	return placement_state


func get_current_order_id() -> String:
	return current_order_id


func get_current_fixture_id() -> String:
	return current_fixture_id


func _get_ghost_preview() -> Node3D:
	if ghost_preview_path.is_empty():
		return null

	return get_node_or_null(ghost_preview_path) as Node3D


func _refresh_placement_state() -> void:
	var ghost := _get_ghost_preview()
	if ghost == null or not ghost.visible:
		placement_state = PLACEMENT_STATE_HIDDEN
		return

	if validate_ghost_position(ghost.position):
		placement_state = PLACEMENT_STATE_VALID
		_apply_ghost_material(valid_placement_material)
	else:
		placement_state = PLACEMENT_STATE_INVALID
		_apply_ghost_material(invalid_placement_material)


func _record_adjustment_state() -> void:
	var ghost := _get_ghost_preview()
	if ghost == null or not ghost.visible:
		return

	placement_history.append({
		"position": ghost.position,
		"rotation_y": ghost.rotation.y,
	})


func _apply_ghost_material(material: Material) -> void:
	if material == null:
		return

	var ghost := _get_ghost_preview()
	if ghost == null:
		return

	_apply_material_recursive(ghost, material)


func _apply_material_recursive(node: Node, material: Material) -> void:
	if node is CSGPrimitive3D:
		(node as CSGPrimitive3D).material = material
	elif node is GeometryInstance3D:
		(node as GeometryInstance3D).material_override = material

	for child in node.get_children():
		_apply_material_recursive(child, material)


func _snap_position(position: Vector3) -> Vector3:
	if snap_grid_size <= 0.0:
		return position

	return Vector3(
		roundf(position.x / snap_grid_size) * snap_grid_size,
		position.y,
		roundf(position.z / snap_grid_size) * snap_grid_size
	)


func _normalize_radians(value: float) -> float:
	return fposmod(value, TAU)


func _get_rotated_footprint(rotation_y: float) -> Vector2:
	var quarter_turn := int(roundf(rad_to_deg(_normalize_radians(rotation_y)) / 90.0)) % 2
	if quarter_turn == 1:
		return Vector2(current_fixture_footprint_size.y, current_fixture_footprint_size.x)
	return current_fixture_footprint_size


func _blocks_critical_path(position: Vector3, footprint: Vector2) -> bool:
	if path_clearance_points.is_empty():
		return false

	var required_clearance: float = path_clearance_radius + minf(footprint.x, footprint.y) * 0.5
	for point in path_clearance_points:
		var distance := Vector2(position.x, position.z).distance_to(Vector2(point.x, point.z))
		if distance < required_clearance:
			return true
	return false


func _overlaps_placed_fixture(position: Vector3, footprint: Vector2) -> bool:
	for placed in placed_fixture_bounds:
		var placed_position: Vector3 = placed.get("position", Vector3.ZERO)
		var placed_footprint: Vector2 = placed.get("footprint_size", Vector2.ONE)
		var x_overlap := absf(position.x - placed_position.x) \
			< (footprint.x + placed_footprint.x) * 0.5 + obstacle_clearance_radius
		var z_overlap := absf(position.z - placed_position.z) \
			< (footprint.y + placed_footprint.y) * 0.5 + obstacle_clearance_radius
		if x_overlap and z_overlap:
			return true
	return false


func _fixture_node_name(fixture_id: String) -> String:
	match fixture_id:
		"fixture_game_display_rack":
			return "PlacedGameDisplayRack"
		"fixture_wall_shelf":
			return "PlacedWallShelf"
		"fixture_accessory_peg_wall":
			return "PlacedAccessoryPegWall"
		"fixture_bargain_bin":
			return "PlacedBargainBin"
		"fixture_locked_case":
			return "PlacedLockedCase"
		"fixture_counter_rack":
			return "PlacedCounterRack"
		"fixture_demo_kiosk":
			return "PlacedDemoKiosk"
		"fixture_new_release_wall":
			return "PlacedNewReleaseWall"
		"fixture_backroom_rack":
			return "PlacedBackroomRack"
		_:
			return "PlacedFixture"
