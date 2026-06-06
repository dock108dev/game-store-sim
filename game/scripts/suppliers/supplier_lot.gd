extends Resource
class_name SupplierLot

@export var lot_id: String = ""
@export var supplier_id: String = ""
@export var display_name: String = ""
@export var cost_cents: int = 0
@export var delivery_days: int = 1
@export var item_scene_path: String = "res://scenes/props/placeholder_used_game.tscn"
@export var product_paths: Array[String] = []


func get_item_count() -> int:
	return product_paths.size()
