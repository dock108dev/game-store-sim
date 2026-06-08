extends Resource
class_name SupplierLot

@export var lot_id: String = ""
@export var supplier_id: String = ""
@export var display_name: String = ""
@export var category_label: String = ""
@export var cost_cents: int = 0
@export var delivery_days: int = 1
@export var item_scene_path: String = "res://scenes/props/placeholder_used_game.tscn"
@export var product_paths: Array[String] = []
@export var storage_requirement: String = ""
@export var receiving_expectation: String = ""


func get_item_count() -> int:
	return product_paths.size()


func get_category_label() -> String:
	if not category_label.strip_edges().is_empty():
		return category_label.strip_edges()

	return "General stock"


func get_storage_requirement() -> String:
	if not storage_requirement.strip_edges().is_empty():
		return storage_requirement.strip_edges()

	return "Receiving box intake before floor placement"


func get_receiving_expectation() -> String:
	if not receiving_expectation.strip_edges().is_empty():
		return receiving_expectation.strip_edges()

	return "Physical stock appears in receiving for pickup and placement"
