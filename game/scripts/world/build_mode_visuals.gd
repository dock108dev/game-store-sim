## Coordinates build mode visual feedback: ghost preview, cell overlay, and animations.
class_name BuildModeVisuals
extends Node3D

const PlacementReasonTextScript = preload("res://game/resources/placement_reason_text.gd")

const SCALE_PUNCH_PEAK: float = 1.08
const SCALE_PUNCH_DURATION: float = 0.2
const REASON_LABEL_OFFSET: Vector3 = Vector3(0.0, 0.55, 0.0)

var _grid: BuildModeGrid = null
var _placement_system: FixturePlacementSystem = null
var _ghost: BuildModeGhost = null
var _cell_overlay: BuildModeCellOverlay = null
var _reason_label: Label3D = null


## Initializes visuals with required references.
func initialize(
	grid: BuildModeGrid,
	validator: FixturePlacementValidator,
	placement_system: FixturePlacementSystem
) -> void:
	_grid = grid
	_placement_system = placement_system

	_ghost = BuildModeGhost.new()
	_ghost.name = "GhostPreview"
	add_child(_ghost)
	_ghost.setup(grid)

	_reason_label = Label3D.new()
	_reason_label.name = "PlacementReasonLabel"
	_reason_label.visible = false
	_reason_label.font_size = 22
	_reason_label.modulate = Color(1.0, 0.91, 0.72, 1.0)
	_reason_label.outline_modulate = Color(0.08, 0.05, 0.03, 1.0)
	add_child(_reason_label)

	_cell_overlay = BuildModeCellOverlay.new()
	_cell_overlay.name = "CellOverlay"
	add_child(_cell_overlay)
	_cell_overlay.setup(grid, validator, placement_system)

	EventBus.build_mode_entered.connect(_on_build_mode_entered)
	EventBus.build_mode_exited.connect(_on_build_mode_exited)
	EventBus.fixture_placed.connect(_on_fixture_placed)
	EventBus.fixture_placement_invalid.connect(
		_on_fixture_placement_invalid
	)
	EventBus.fixture_selected.connect(_on_fixture_selected)


## Updates ghost preview position, rotation, and validity color.
func update_ghost(
	grid_pos: Variant,
	fixture_type: String,
	fixture_rotation: int
) -> void:
	if grid_pos == null or fixture_type.is_empty():
		_ghost.hide_ghost()
		_hide_reason_label()
		return

	var cell: Vector2i = grid_pos as Vector2i
	var feedback = _placement_system.get_preview_feedback_for(
		cell, fixture_type, fixture_rotation
	)

	_ghost.show_feedback(feedback)
	_show_reason_label(feedback)


## Hides the ghost preview.
func hide_ghost() -> void:
	_ghost.hide_ghost()
	_hide_reason_label()


## Updates the fixture highlight based on hovered cell.
func update_highlight(hovered_cell: Variant) -> void:
	_cell_overlay.update_highlight(hovered_cell)


func _on_build_mode_entered() -> void:
	_cell_overlay.build_overlay()
	_cell_overlay.fade(true)


func _on_build_mode_exited() -> void:
	_ghost.hide_ghost()
	_hide_reason_label()
	_cell_overlay.clear_selection()
	_cell_overlay.fade(false)


func _on_fixture_placed(
	fixture_id: String, grid_pos: Vector2i, fixture_rotation: int
) -> void:
	_play_scale_punch(fixture_id, grid_pos, fixture_rotation)
	_cell_overlay.build_overlay()


func _on_fixture_placement_invalid(reason: String) -> void:
	_ghost.play_shake()
	if reason.is_empty():
		return
	_reason_label.text = PlacementReasonTextScript.get_text(reason)
	_reason_label.visible = true


func _on_fixture_selected(fixture_id: String) -> void:
	_cell_overlay.set_selected_fixture(fixture_id)


func _play_scale_punch(
	fixture_id: String, grid_pos: Vector2i, fixture_rotation: int
) -> void:
	var cells: Array[Vector2i] = _get_placed_fixture_cells(
		fixture_id, grid_pos, fixture_rotation
	)
	if cells.is_empty():
		return

	_ghost.play_scale_punch()

	var punch_node: Node3D = _create_punch_footprint(cells)
	add_child(punch_node)

	var tween: Tween = create_tween()
	tween.tween_property(
		punch_node, "scale",
		Vector3(SCALE_PUNCH_PEAK, SCALE_PUNCH_PEAK, SCALE_PUNCH_PEAK),
		SCALE_PUNCH_DURATION * 0.5
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(
		punch_node, "scale",
		Vector3.ONE,
		SCALE_PUNCH_DURATION * 0.5
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(punch_node.queue_free)


func _show_reason_label(feedback) -> void:
	if not _reason_label:
		return
	if feedback.valid or feedback.display_message.is_empty():
		_hide_reason_label()
		return
	_reason_label.text = feedback.display_message
	_reason_label.position = _ghost.position + REASON_LABEL_OFFSET
	_reason_label.visible = true


func _hide_reason_label() -> void:
	if _reason_label:
		_reason_label.visible = false


func _get_placed_fixture_cells(
	fixture_id: String, grid_pos: Vector2i, fixture_rotation: int
) -> Array[Vector2i]:
	var data: Dictionary = _placement_system.get_fixture_data(fixture_id)
	if data.has("cells"):
		var stored_cells: Array[Vector2i] = []
		for cell: Variant in data.get("cells", []):
			stored_cells.append(cell as Vector2i)
		return stored_cells

	var fixture_type: String = str(data.get("fixture_type", ""))
	if fixture_type.is_empty():
		fixture_type = _placement_system.get_selected_fixture_type()
	if fixture_type.is_empty():
		return []
	return _get_fixture_cells(fixture_type, grid_pos, fixture_rotation)


func _create_punch_footprint(cells: Array[Vector2i]) -> Node3D:
	var punch_node := Node3D.new()
	punch_node.name = "PlacementPunch"
	punch_node.position = _get_cells_center(cells)

	var material := StandardMaterial3D.new()
	material.albedo_color = BuildModeGhost.VALID_COLOR
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.no_depth_test = true

	for cell: Vector2i in cells:
		var quad := PlaneMesh.new()
		quad.size = Vector2(
			BuildModeGrid.CELL_SIZE * 0.95,
			BuildModeGrid.CELL_SIZE * 0.95
		)
		var inst := MeshInstance3D.new()
		inst.mesh = quad
		inst.set_surface_override_material(0, material)
		inst.position = _grid.grid_to_world(cell) - punch_node.position
		inst.position.y = 0.0
		punch_node.add_child(inst)

	return punch_node


func _get_cells_center(cells: Array[Vector2i]) -> Vector3:
	var sum := Vector3.ZERO
	for cell: Vector2i in cells:
		sum += _grid.grid_to_world(cell)
	sum /= float(cells.size())
	sum.y += BuildModeGhost.Y_OFFSET
	return sum


func _get_fixture_cells(
	fixture_type: String,
	grid_pos: Vector2i,
	fixture_rotation: int
) -> Array[Vector2i]:
	var base_size: Vector2i = _placement_system.get_fixture_size(
		fixture_type
	)
	var size: Vector2i = base_size
	if fixture_rotation % 2 == 1:
		size = Vector2i(base_size.y, base_size.x)

	var cells: Array[Vector2i] = []
	for dx: int in range(size.x):
		for dy: int in range(size.y):
			cells.append(
				Vector2i(grid_pos.x + dx, grid_pos.y + dy)
			)
	return cells
