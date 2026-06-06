extends Resource
class_name FixtureDefinition

@export var fixture_id: String = ""
@export var display_name: String = ""
@export var category: String = "display"
@export var cost_cents: int = 0
@export var footprint_size: Vector2 = Vector2.ONE
@export var default_slot_category: String = "used_game"
@export_file("*.tscn") var scene_path: String = ""
@export var placeable: bool = true


func describe() -> String:
	return "%s - %s - %s" % [
		display_name,
		category.capitalize(),
		format_money(cost_cents),
	]


func format_money(cents: int) -> String:
	return "$%0.2f" % (cents / 100.0)
