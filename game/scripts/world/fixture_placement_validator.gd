## Validates fixture placement against aisle, entry zone, wall, count, and connectivity rules.
class_name FixturePlacementValidator
extends RefCounted

enum CellState { EMPTY, OCCUPIED, WALL, ENTRY_ZONE }

const PlacementPreviewFeedbackScript = preload("res://game/resources/placement_preview_feedback.gd")

const MIN_AISLE_GAP: int = 2

const MAX_FIXTURES: Dictionary = {
	BuildModeGrid.StoreSize.SMALL: 6,
	BuildModeGrid.StoreSize.MEDIUM: 8,
	BuildModeGrid.StoreSize.LARGE: 12,
}

var _grid_size: Vector2i = Vector2i.ZERO
var _entry_depth: int = 2
var _entry_edge: int = 0
var _store_size: BuildModeGrid.StoreSize = BuildModeGrid.StoreSize.SMALL


## Configures the validator for a specific grid size and entry location.
func setup(
	grid_size: Vector2i,
	entry_edge_y: int,
	store_size: BuildModeGrid.StoreSize = BuildModeGrid.StoreSize.SMALL
) -> void:
	_grid_size = grid_size
	_entry_edge = entry_edge_y
	_store_size = store_size


## Returns the CellState for a given cell position.
func get_cell_state(cell: Vector2i, occupied_cells: Dictionary) -> CellState:
	if not _is_in_bounds(cell):
		return CellState.WALL
	if _is_in_entry_zone(cell):
		return CellState.ENTRY_ZONE
	if occupied_cells.has(cell):
		return CellState.OCCUPIED
	return CellState.EMPTY


## Full validation returning a PlacementResult.
func validate_placement(
	cells: Array[Vector2i],
	occupied_cells: Dictionary,
	register_cells: Array[Vector2i],
	fixture_count: int,
	requires_wall: bool,
	facing_direction: Vector2i = Vector2i.ZERO
) -> PlacementResult:
	return (
		get_placement_feedback(
			cells, occupied_cells, register_cells, fixture_count, requires_wall, facing_direction
		)
		. to_result()
	)


## Returns complete placement feedback for preview and commit validation.
func get_placement_feedback(
	cells: Array[Vector2i],
	occupied_cells: Dictionary,
	register_cells: Array[Vector2i],
	fixture_count: int,
	requires_wall: bool,
	facing_direction: Vector2i = Vector2i.ZERO
):
	var feedback = PlacementPreviewFeedbackScript.new()
	feedback.footprint_cells = cells.duplicate()
	feedback.facing_direction = facing_direction
	feedback.front_edge_cells = _get_front_edge_cells(cells, facing_direction)
	feedback.wall_candidate_cells = _get_wall_candidate_cells(cells)

	feedback.out_of_bounds_cells = _get_out_of_bounds_cells(cells)
	if not feedback.out_of_bounds_cells.is_empty():
		feedback.add_reason("out_of_bounds", feedback.out_of_bounds_cells)

	feedback.collision_cells = _get_collision_cells(cells, occupied_cells)
	if not feedback.collision_cells.is_empty():
		feedback.add_reason("occupied_collision", feedback.collision_cells)

	feedback.entry_zone_cells = _get_entry_zone_conflicts(cells)
	if not feedback.entry_zone_cells.is_empty():
		feedback.add_reason("entry_zone_blocked", feedback.entry_zone_cells)

	var max_allowed: int = MAX_FIXTURES.get(_store_size, 6)
	if fixture_count >= max_allowed:
		feedback.add_reason("max_fixtures_reached", cells)

	if requires_wall:
		if feedback.wall_candidate_cells.is_empty():
			feedback.add_reason("wall_required", cells)
		elif not _wall_mount_faces_aisle(cells, facing_direction):
			feedback.add_reason("wrong_facing", feedback.front_edge_cells)

	var aisle_conflicts: Dictionary = _get_aisle_conflicts(cells, occupied_cells)
	var narrow_cells: Array[Vector2i] = _typed_cells(aisle_conflicts.get("invalid_cells", []))
	feedback.nearby_blocker_cells = _typed_cells(aisle_conflicts.get("blocker_cells", []))
	if not narrow_cells.is_empty():
		feedback.add_reason("aisle_too_narrow", narrow_cells)

	if _can_check_connectivity(feedback):
		var test_occupied: Dictionary = occupied_cells.duplicate()
		for cell: Vector2i in cells:
			test_occupied[cell] = "pending"
		if not _is_layout_connected(test_occupied, register_cells):
			feedback.add_reason("not_reachable", cells)

	feedback.finalize()
	return feedback


## Returns true if the fixture cells avoid the entry zone.
func is_outside_entry_zone(cells: Array[Vector2i]) -> bool:
	for cell: Vector2i in cells:
		if _is_in_entry_zone(cell):
			return false
	return true


## Returns true if minimum aisle width is maintained.
func has_valid_aisles(new_cells: Array[Vector2i], occupied_cells: Dictionary) -> bool:
	return _get_narrow_aisle_cells(new_cells, occupied_cells).is_empty()


## BFS from entry zone through empty cells. Returns true if every empty cell and
## every occupied fixture/register cell remains reachable from the entrance.
func is_layout_connected(all_occupied: Dictionary, register_cells: Array[Vector2i]) -> bool:
	return _is_layout_connected(all_occupied, register_cells)


## Checks whether a register fixture exists.
func has_register(register_fixture_id: String) -> PlacementResult:
	if register_fixture_id.is_empty():
		return PlacementResult.failure("no_register")
	return PlacementResult.success()


## Returns true if any cell in the set is on the grid boundary (wall-adjacent).
func _is_against_wall(cells: Array[Vector2i]) -> bool:
	for cell: Vector2i in cells:
		if cell.x == 0 or cell.x == _grid_size.x - 1 or cell.y == 0 or cell.y == _grid_size.y - 1:
			return true
	return false


func _get_entry_zone_conflicts(cells: Array[Vector2i]) -> Array[Vector2i]:
	var conflicts: Array[Vector2i] = []
	for cell: Vector2i in cells:
		if _is_in_entry_zone(cell):
			conflicts.append(cell)
	return conflicts


func _get_out_of_bounds_cells(cells: Array[Vector2i]) -> Array[Vector2i]:
	var conflicts: Array[Vector2i] = []
	for cell: Vector2i in cells:
		if not _is_in_bounds(cell):
			conflicts.append(cell)
	return conflicts


func _get_collision_cells(
	new_cells: Array[Vector2i], occupied_cells: Dictionary
) -> Array[Vector2i]:
	var collisions: Array[Vector2i] = []
	for cell: Vector2i in new_cells:
		if occupied_cells.has(cell):
			collisions.append(cell)
	return collisions


func _get_narrow_aisle_cells(
	new_cells: Array[Vector2i], occupied_cells: Dictionary
) -> Array[Vector2i]:
	return _typed_cells(_get_aisle_conflicts(new_cells, occupied_cells).get("invalid_cells", []))


func _get_aisle_conflicts(new_cells: Array[Vector2i], occupied_cells: Dictionary) -> Dictionary:
	var invalid_cells: Array[Vector2i] = []
	var blocker_cells: Array[Vector2i] = []
	for new_cell: Vector2i in new_cells:
		for occ_key: Variant in occupied_cells:
			var occ_cell: Vector2i = occ_key as Vector2i
			var dx: int = absi(new_cell.x - occ_cell.x)
			var dy: int = absi(new_cell.y - occ_cell.y)
			if dx == 0 and dy == 0:
				continue
			if dx == 0 and dy > 0 and dy <= MIN_AISLE_GAP:
				_add_aisle_conflict(invalid_cells, blocker_cells, new_cell, occ_cell)
			elif dy == 0 and dx > 0 and dx <= MIN_AISLE_GAP:
				_add_aisle_conflict(invalid_cells, blocker_cells, new_cell, occ_cell)
	return {"invalid_cells": invalid_cells, "blocker_cells": blocker_cells}


func _add_aisle_conflict(
	invalid_cells: Array[Vector2i],
	blocker_cells: Array[Vector2i],
	new_cell: Vector2i,
	occ_cell: Vector2i
) -> void:
	if new_cell not in invalid_cells:
		invalid_cells.append(new_cell)
	if occ_cell not in blocker_cells:
		blocker_cells.append(occ_cell)


func _get_wall_candidate_cells(cells: Array[Vector2i]) -> Array[Vector2i]:
	var candidates: Array[Vector2i] = []
	for cell: Vector2i in cells:
		if cell.x == 0 or cell.x == _grid_size.x - 1 or cell.y == 0 or cell.y == _grid_size.y - 1:
			candidates.append(cell)
	return candidates


func _get_front_edge_cells(cells: Array[Vector2i], facing_direction: Vector2i) -> Array[Vector2i]:
	if cells.is_empty() or facing_direction == Vector2i.ZERO:
		return []
	var max_projection: int = -2147483648
	for cell: Vector2i in cells:
		max_projection = maxi(max_projection, _project(cell, facing_direction))
	var front: Array[Vector2i] = []
	for cell: Vector2i in cells:
		if _project(cell, facing_direction) == max_projection:
			front.append(cell)
	return front


func _wall_mount_faces_aisle(cells: Array[Vector2i], facing_direction: Vector2i) -> bool:
	if facing_direction == Vector2i.ZERO:
		return true
	var back_direction: Vector2i = -facing_direction
	for cell: Vector2i in cells:
		var behind: Vector2i = cell + back_direction
		if not _is_in_bounds(behind):
			return true
	return false


func _project(cell: Vector2i, direction: Vector2i) -> int:
	return cell.x * direction.x + cell.y * direction.y


func _can_check_connectivity(feedback) -> bool:
	return (
		feedback.out_of_bounds_cells.is_empty()
		and feedback.collision_cells.is_empty()
		and feedback.entry_zone_cells.is_empty()
	)


func _typed_cells(value: Variant) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	if value is Array:
		for cell: Variant in value:
			cells.append(cell as Vector2i)
	return cells


func _is_layout_connected(all_occupied: Dictionary, register_cells: Array[Vector2i]) -> bool:
	var entry_cells: Array[Vector2i] = _get_entry_zone_cells()
	if entry_cells.is_empty():
		return true

	var reachable: Dictionary = {}
	var queue: Array[Vector2i] = []

	for cell: Vector2i in entry_cells:
		if not all_occupied.has(cell):
			reachable[cell] = true
			queue.append(cell)

	var head: int = 0
	while head < queue.size():
		var current: Vector2i = queue[head]
		head += 1
		for offset: Vector2i in _cardinal_offsets():
			var neighbor: Vector2i = current + offset
			if not _is_in_bounds(neighbor):
				continue
			if reachable.has(neighbor):
				continue
			if all_occupied.has(neighbor):
				continue
			reachable[neighbor] = true
			queue.append(neighbor)

	for x: int in range(_grid_size.x):
		for y: int in range(_grid_size.y):
			var cell := Vector2i(x, y)
			if all_occupied.has(cell):
				continue
			if not reachable.has(cell):
				return false

	for occ_key: Variant in all_occupied:
		var occ_cell: Vector2i = occ_key as Vector2i
		if not _has_reachable_neighbor(occ_cell, reachable):
			return false

	for reg_cell: Vector2i in register_cells:
		if not _has_reachable_neighbor(reg_cell, reachable):
			return false

	return true


func _is_in_entry_zone(cell: Vector2i) -> bool:
	return (
		cell.y >= _entry_edge
		and cell.y < _entry_edge + _entry_depth
		and cell.x >= 0
		and cell.x < _grid_size.x
	)


func _get_entry_zone_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for x: int in range(_grid_size.x):
		for y: int in range(_entry_edge, _entry_edge + _entry_depth):
			if _is_in_bounds(Vector2i(x, y)):
				cells.append(Vector2i(x, y))
	return cells


func _is_in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < _grid_size.x and cell.y >= 0 and cell.y < _grid_size.y


func _has_reachable_neighbor(cell: Vector2i, reachable: Dictionary) -> bool:
	for offset: Vector2i in _cardinal_offsets():
		var neighbor: Vector2i = cell + offset
		if reachable.has(neighbor):
			return true
	return false


func _cardinal_offsets() -> Array[Vector2i]:
	return [
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1),
	]
