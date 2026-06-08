extends Resource
class_name FixtureDefinition

@export var fixture_id: String = ""
@export var display_name: String = ""
@export var category: String = "display"
@export var cost_cents: int = 0
@export var footprint_size: Vector2 = Vector2.ONE
@export var default_slot_category: String = "used_game"
@export var slot_count: int = 0
@export var accepted_product_categories: PackedStringArray = PackedStringArray()
@export var placement_zone: String = "sales_floor"
@export var gameplay_tags: PackedStringArray = PackedStringArray()
@export var requires_upgrade_id: String = ""
@export_file("*.tscn") var scene_path: String = ""
@export var placeable: bool = true
@export var placeholder: bool = false
@export_multiline var description: String = ""


func describe() -> String:
	return "%s - %s - %s - %d slots - %s" % [
		display_name,
		category.capitalize(),
		format_money(cost_cents),
		slot_count,
		placement_zone,
	]


func format_money(cents: int) -> String:
	return "$%0.2f" % (cents / 100.0)
