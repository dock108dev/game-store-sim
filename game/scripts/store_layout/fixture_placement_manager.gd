extends Node3D
class_name FixturePlacementManager

@export var default_ghost_position: Vector3 = Vector3(-0.8, 0.04, 2.15)
@export var default_ghost_rotation_y: float = 0.0
@export var ghost_preview_path: NodePath = NodePath("GhostRackPreview")

var current_order_id: String = ""
var current_fixture_id: String = ""


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
	ghost.position = default_ghost_position
	ghost.rotation = Vector3(0.0, default_ghost_rotation_y, 0.0)
	ghost.visible = true
	return true


func hide_ghost() -> void:
	var ghost := _get_ghost_preview()
	if ghost != null:
		ghost.visible = false
	current_order_id = ""
	current_fixture_id = ""


func is_ghost_visible() -> bool:
	var ghost := _get_ghost_preview()
	return ghost != null and ghost.visible


func get_ghost_position() -> Vector3:
	var ghost := _get_ghost_preview()
	if ghost == null:
		return Vector3.ZERO

	return ghost.position


func get_current_order_id() -> String:
	return current_order_id


func get_current_fixture_id() -> String:
	return current_fixture_id


func _get_ghost_preview() -> Node3D:
	if ghost_preview_path.is_empty():
		return null

	return get_node_or_null(ghost_preview_path) as Node3D
