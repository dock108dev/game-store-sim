extends Node3D
class_name CustomerManager

@export var target_product_id: String = "used_star_trader"
@export var register_queue_start: Vector3 = Vector3(1.65, 0.0, -3.55)
@export var register_queue_spacing: Vector3 = Vector3(-0.7, 0.0, -0.2)
@export var playable_min: Vector3 = Vector3(-6.6, 0.0, -5.6)
@export var playable_max: Vector3 = Vector3(6.6, 0.0, 5.7)
@export var minimum_queue_spacing_distance: float = 0.62
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

		var queue_position := _queue_position_for_index(get_register_bound_customers().size())
		if is_position_inside_store(queue_position) and customer.begin_claim_from_slot(slot, queue_position):
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


func get_register_bound_customers() -> Array[SimpleBuyerCustomer]:
	var customers: Array[SimpleBuyerCustomer] = []
	for customer in get_customers():
		if (
			customer.state == SimpleBuyerCustomer.STATE_MOVING_TO_ITEM
			or customer.is_moving_to_register()
			or customer.is_waiting_for_register()
		):
			customers.append(customer)
	return customers


func get_next_waiting_customer() -> SimpleBuyerCustomer:
	var waiting := get_waiting_customers()
	if waiting.is_empty():
		return null

	return waiting[0]


func compact_after_sale() -> void:
	_compact_register_queue()


func is_position_inside_store(position: Vector3) -> bool:
	return (
		position.x >= playable_min.x
		and position.x <= playable_max.x
		and position.z >= playable_min.z
		and position.z <= playable_max.z
	)


func validate_customer_paths() -> Array[String]:
	var issues: Array[String] = []
	var customers := get_customers()
	for index in range(customers.size()):
		var customer := customers[index]
		if not is_position_inside_store(customer.global_position):
			issues.append("customer_%d_position_outside_store" % index)

		var queue_position := _queue_position_for_index(index)
		if not is_position_inside_store(queue_position):
			issues.append("queue_position_%d_outside_store" % index)

		if index > 0:
			var previous_queue_position := _queue_position_for_index(index - 1)
			if previous_queue_position.distance_to(queue_position) < minimum_queue_spacing_distance:
				issues.append("queue_spacing_%d_too_tight" % index)

	for slot_path in display_slot_paths:
		var slot := get_node_or_null(slot_path) as Node3D
		if slot == null:
			issues.append("missing_display_slot:%s" % str(slot_path))
			continue

		if not is_position_inside_store(slot.global_position):
			issues.append("display_slot_outside_store:%s" % str(slot_path))

		for index in range(customers.size()):
			var approach_position := _approach_position_for_customer(customers[index], slot)
			if not is_position_inside_store(approach_position):
				issues.append("customer_%d_approach_outside_store:%s" % [
					index,
					str(slot_path),
				])

	return issues


func _customer_can_claim(customer: SimpleBuyerCustomer) -> bool:
	return customer != null and customer.state == SimpleBuyerCustomer.STATE_BROWSING


func _find_available_target_slot(customer: SimpleBuyerCustomer) -> Node:
	for slot_path in display_slot_paths:
		var slot := get_node_or_null(slot_path)
		if slot == null or not slot.has_method("get_occupied_item"):
			continue
		if _is_slot_claimed(slot):
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
	for customer in get_register_bound_customers():
		customer.set_queue_position(_queue_position_for_index(index))
		index += 1


func _queue_position_for_index(index: int) -> Vector3:
	return register_queue_start + (register_queue_spacing * index)


func _approach_position_for_customer(customer: SimpleBuyerCustomer, slot: Node3D) -> Vector3:
	var approach_offset := Vector3(0.0, 0.0, -0.85)
	if customer != null:
		approach_offset = customer.item_approach_offset

	var position := slot.global_position + approach_offset
	if customer != null:
		position.y = customer.global_position.y
	return position


func _is_slot_claimed(slot: Node) -> bool:
	for customer in get_customers():
		if customer.is_claiming_slot(slot):
			return true
	return false
