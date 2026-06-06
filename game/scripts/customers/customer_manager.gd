extends Node3D
class_name CustomerManager

@export var target_product_id: String = "used_star_trader"
@export var register_queue_start: Vector3 = Vector3(1.0, 0.0, -3.35)
@export var register_queue_spacing: Vector3 = Vector3(-0.45, 0.0, 0.18)
@export var display_slot_paths: Array[NodePath] = []

func _process(_delta: float) -> void:
	process_customer_claims()


func process_customer_claims() -> void:
	_compact_register_queue()

	for customer in get_customers():
		if not _customer_can_claim(customer):
			continue

		var slot := _find_available_target_slot(customer)
		if slot == null:
			continue

		customer.register_queue_position = _queue_position_for_index(get_waiting_customers().size())
		if customer.claim_item_from_slot(slot):
			_compact_register_queue()


func get_customers() -> Array[SimpleBuyerCustomer]:
	var customers: Array[SimpleBuyerCustomer] = []
	for child in get_children():
		var customer := child as SimpleBuyerCustomer
		if customer != null:
			customers.append(customer)
	return customers


func get_waiting_customers() -> Array[SimpleBuyerCustomer]:
	var waiting: Array[SimpleBuyerCustomer] = []
	for customer in get_customers():
		if customer.is_waiting_for_register():
			waiting.append(customer)
	return waiting


func get_next_waiting_customer() -> SimpleBuyerCustomer:
	var waiting := get_waiting_customers()
	if waiting.is_empty():
		return null

	return waiting[0]


func compact_after_sale() -> void:
	_compact_register_queue()


func _customer_can_claim(customer: SimpleBuyerCustomer) -> bool:
	return customer != null and customer.state == SimpleBuyerCustomer.STATE_BROWSING


func _find_available_target_slot(customer: SimpleBuyerCustomer) -> Node:
	for slot_path in display_slot_paths:
		var slot := get_node_or_null(slot_path)
		if slot == null or not slot.has_method("get_occupied_item"):
			continue

		var item: Node = slot.get_occupied_item()
		if _customer_wants_item(customer, item):
			return slot

	return null


func _customer_wants_item(customer: SimpleBuyerCustomer, item: Node) -> bool:
	if item == null:
		return false

	var product := item.get("product") as ProductDefinition
	if product == null:
		return false

	return product.product_id == customer.target_product_id


func _compact_register_queue() -> void:
	var index := 0
	for customer in get_waiting_customers():
		customer.global_position = _queue_position_for_index(index)
		index += 1


func _queue_position_for_index(index: int) -> Vector3:
	return register_queue_start + (register_queue_spacing * index)
