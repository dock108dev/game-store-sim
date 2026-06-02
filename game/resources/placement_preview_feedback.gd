## Rich placement preview contract shared by build-mode validation and visuals.
class_name PlacementPreviewFeedback
extends RefCounted

const PlacementReasonTextScript = preload("res://game/resources/placement_reason_text.gd")

var valid: bool = true
var primary_reason: String = ""
var reasons: Array[String] = []
var footprint_cells: Array[Vector2i] = []
var invalid_cells: Array[Vector2i] = []
var collision_cells: Array[Vector2i] = []
var nearby_blocker_cells: Array[Vector2i] = []
var entry_zone_cells: Array[Vector2i] = []
var out_of_bounds_cells: Array[Vector2i] = []
var wall_candidate_cells: Array[Vector2i] = []
var facing_direction: Vector2i = Vector2i.ZERO
var front_edge_cells: Array[Vector2i] = []
var display_message: String = ""


## Adds a reason and associates any invalid cells with it.
func add_reason(reason: String, cells: Array[Vector2i] = []) -> void:
	if reason.is_empty():
		return
	if not reasons.has(reason):
		reasons.append(reason)
	for cell: Vector2i in cells:
		_add_unique_cell(invalid_cells, cell)
	finalize()


## Recomputes validity and player-facing message from the reason list.
func finalize() -> void:
	valid = reasons.is_empty()
	primary_reason = PlacementReasonTextScript.choose_primary(reasons)
	display_message = PlacementReasonTextScript.get_text(primary_reason)
	if valid:
		display_message = ""


## Returns the compatibility placement result for existing callers.
func to_result() -> PlacementResult:
	if valid:
		return PlacementResult.success()
	return PlacementResult.failure(primary_reason, invalid_cells)


func _add_unique_cell(target: Array[Vector2i], cell: Vector2i) -> void:
	if cell not in target:
		target.append(cell)
