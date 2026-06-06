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

const PLACEMENT_STATE_HIDDEN := "hidden"
const PLACEMENT_STATE_VALID := "valid"
const PLACEMENT_STATE_INVALID := "invalid"

var current_order_id: String = ""
var current_fixture_id: String = ""
var placement_state: String = PLACEMENT_STATE_HIDDEN


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
	placement_state = PLACEMENT_STATE_HIDDEN


func is_ghost_visible() -> bool:
	var ghost := _get_ghost_preview()
	return ghost != null and ghost.visible


func get_ghost_position() -> Vector3:
	var ghost := _get_ghost_preview()
	if ghost == null:
		return Vector3.ZERO

	return ghost.position


func set_ghost_position(position: Vector3) -> bool:
	var ghost := _get_ghost_preview()
	if ghost == null:
		return false

	ghost.position = position
	_refresh_placement_state()
	return is_current_position_valid()


func snap_ghost_to_grid() -> bool:
	var ghost := _get_ghost_preview()
	if ghost == null:
		return false

	return set_ghost_position(_snap_position(ghost.position))


func move_ghost_by_grid(delta_x: int, delta_z: int) -> bool:
	var ghost := _get_ghost_preview()
	if ghost == null:
		return false

	var position := ghost.position + Vector3(
		float(delta_x) * snap_grid_size,
		0.0,
		float(delta_z) * snap_grid_size
	)
	return set_ghost_position(_snap_position(position))


func rotate_ghost(clockwise: bool = true) -> bool:
	var ghost := _get_ghost_preview()
	if ghost == null:
		return false

	var direction := 1.0 if clockwise else -1.0
	ghost.rotation.y = _normalize_radians(
		ghost.rotation.y + deg_to_rad(rotation_step_degrees) * direction
	)
	_refresh_placement_state()
	return is_current_position_valid()


func get_ghost_rotation_y() -> float:
	var ghost := _get_ghost_preview()
	if ghost == null:
		return 0.0

	return ghost.rotation.y


func validate_ghost_position(position: Vector3) -> bool:
	return position.x >= placement_bounds_min.x \
		and position.x <= placement_bounds_max.x \
		and position.z >= placement_bounds_min.z \
		and position.z <= placement_bounds_max.z


func is_current_position_valid() -> bool:
	return placement_state == PLACEMENT_STATE_VALID


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
