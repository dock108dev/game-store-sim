## Draws a compact data-driven silhouette for a build-catalog fixture card.
class_name FixtureSilhouetteView
extends Control

const _CATEGORY_COLORS: Dictionary = {
	"fixtures": Color(0.72, 0.86, 0.95),
	"shelves": Color(0.76, 0.88, 0.72),
	"counters": Color(0.86, 0.78, 0.70),
	"signage": Color(0.88, 0.84, 0.62),
	"decor": Color(0.84, 0.74, 0.90),
	"surfaces": Color(0.70, 0.82, 0.78),
	"lighting": Color(0.95, 0.86, 0.54),
	"stockroom": Color(0.68, 0.76, 0.82),
}

var fixture: FixtureDefinition
var locked: bool = false


func _init() -> void:
	custom_minimum_size = Vector2(56.0, 56.0)


## Sets the fixture data used by the silhouette renderer.
func configure(source_fixture: FixtureDefinition, is_locked: bool) -> void:
	fixture = source_fixture
	locked = is_locked
	queue_redraw()


func _draw() -> void:
	if fixture == null:
		return
	var cells: Array[Vector2i] = fixture.footprint_cells
	if cells.is_empty():
		cells = [Vector2i.ZERO]
	var bounds: Rect2i = _cell_bounds(cells)
	var pad: float = 7.0
	var draw_size: Vector2 = size - Vector2(pad * 2.0, pad * 2.0)
	var unit: float = minf(
		draw_size.x / float(bounds.size.x),
		draw_size.y / float(bounds.size.y)
	)
	var color: Color = _category_color(fixture.catalog_category)
	if locked:
		color.a = 0.36
	var offset := Vector2(
		(size.x - unit * float(bounds.size.x)) * 0.5,
		(size.y - unit * float(bounds.size.y)) * 0.5
	)
	for cell: Vector2i in cells:
		var local := Vector2(
			float(cell.x - bounds.position.x) * unit,
			float(cell.y - bounds.position.y) * unit
		)
		draw_rect(
			Rect2(offset + local + Vector2(2.0, 2.0), Vector2(unit - 4.0, unit - 4.0)),
			color
		)
	if fixture.requires_wall:
		draw_rect(Rect2(Vector2(5.0, 4.0), Vector2(size.x - 10.0, 4.0)), color.darkened(0.35))
	draw_rect(Rect2(Vector2.ZERO, size), color.darkened(0.45), false, 1.0)


func _cell_bounds(cells: Array[Vector2i]) -> Rect2i:
	var min_cell: Vector2i = cells[0]
	var max_cell: Vector2i = cells[0]
	for cell: Vector2i in cells:
		min_cell.x = mini(min_cell.x, cell.x)
		min_cell.y = mini(min_cell.y, cell.y)
		max_cell.x = maxi(max_cell.x, cell.x)
		max_cell.y = maxi(max_cell.y, cell.y)
	return Rect2i(min_cell, max_cell - min_cell + Vector2i.ONE)


func _category_color(category: String) -> Color:
	return _CATEGORY_COLORS.get(category, Color(0.78, 0.82, 0.86)) as Color
