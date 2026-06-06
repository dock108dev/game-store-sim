extends StaticBody3D
class_name SimpleBuyerCustomer

const STATE_BROWSING := "browsing"
const STATE_MOVING_TO_ITEM := "moving_to_item"
const STATE_MOVING_TO_REGISTER := "moving_to_register"
const STATE_WAITING_FOR_REGISTER := "waiting_for_register"
const STATE_SALE_COMPLETE := "sale_complete"

@export var customer_id: String = "customer_001"
@export var target_product_id: String = "used_star_trader"
@export var display_slot_path: NodePath
@export var register_queue_position: Vector3 = Vector3(1.15, 0.0, -3.2)
@export var item_approach_offset: Vector3 = Vector3(0.0, 0.0, -0.85)
@export var movement_speed: float = 3.2
@export var arrival_distance: float = 0.06
@export var carried_item_position: Vector3 = Vector3(0.0, 0.85, -0.35)
@export var carried_item_scale: Vector3 = Vector3(0.55, 0.55, 0.55)

var state: String = STATE_BROWSING
var _checkout_item: Node3D = null
var _move_target: Vector3 = Vector3.ZERO
var _target_slot_path: NodePath


func _process(delta: float) -> void:
	if state == STATE_BROWSING and not display_slot_path.is_empty():
		var slot := get_node_or_null(display_slot_path)
		if slot != null:
			begin_claim_from_slot(slot, register_queue_position)
		return

	if state == STATE_MOVING_TO_ITEM:
		if _move_toward(_move_target, delta):
			var slot := get_node_or_null(_target_slot_path)
			if _take_item_from_slot(slot):
				state = STATE_MOVING_TO_REGISTER
				_move_target = register_queue_position
			else:
				state = STATE_BROWSING
				_target_slot_path = NodePath("")
		return

	if state == STATE_MOVING_TO_REGISTER:
		if _move_toward(register_queue_position, delta):
			state = STATE_WAITING_FOR_REGISTER


func get_interaction_prompt() -> String:
	if state == STATE_MOVING_TO_ITEM:
		return "Customer Walking To %s" % target_product_id

	if state == STATE_MOVING_TO_REGISTER and _checkout_item != null:
		return "%s Heading To Register" % _get_item_display_name(_checkout_item)

	if state == STATE_WAITING_FOR_REGISTER and _checkout_item != null:
		return "%s Waiting At Register" % _get_item_display_name(_checkout_item)

	if state == STATE_SALE_COMPLETE:
		return "Customer Checked Out"

	return "Customer Looking For %s" % target_product_id


func interact() -> String:
	if state == STATE_MOVING_TO_ITEM:
		return "Customer is heading to the display rack."

	if state == STATE_MOVING_TO_REGISTER and _checkout_item != null:
		return "Customer is carrying %s to the register." % _get_item_display_name(_checkout_item)

	if state == STATE_WAITING_FOR_REGISTER and _checkout_item != null:
		return "Customer is ready to buy %s." % _get_item_display_name(_checkout_item)

	if state == STATE_SALE_COMPLETE:
		return "Customer completed checkout."

	return "Customer is browsing for a matching game."


func is_waiting_for_register() -> bool:
	return state == STATE_WAITING_FOR_REGISTER and _checkout_item != null


func get_checkout_item() -> Node3D:
	return _checkout_item


func is_moving_to_register() -> bool:
	return state == STATE_MOVING_TO_REGISTER and _checkout_item != null


func is_claiming_slot(slot: Node) -> bool:
	return slot != null and not _target_slot_path.is_empty() and get_node_or_null(_target_slot_path) == slot


func set_queue_position(queue_position: Vector3) -> void:
	register_queue_position = queue_position
	if state == STATE_WAITING_FOR_REGISTER:
		global_position = queue_position


func begin_claim_from_slot(slot: Node, queue_position: Vector3) -> bool:
	if state != STATE_BROWSING:
		return false

	if slot == null or not slot.has_method("get_occupied_item"):
		return false

	if not _wants_item(slot.get_occupied_item()):
		return false

	register_queue_position = queue_position
	_target_slot_path = get_path_to(slot)
	_move_target = _approach_position_for_slot(slot)
	state = STATE_MOVING_TO_ITEM
	return true


func claim_item_from_slot(slot: Node) -> bool:
	if state != STATE_BROWSING:
		return false

	register_queue_position = register_queue_position
	if not _take_item_from_slot(slot):
		return false

	state = STATE_WAITING_FOR_REGISTER
	global_position = register_queue_position
	return true


func complete_sale() -> Node3D:
	if not is_waiting_for_register():
		return null

	var item := _checkout_item
	_checkout_item = null
	state = STATE_SALE_COMPLETE

	if item.has_method("set_sold"):
		item.set_sold()
	item.visible = false

	return item


func _take_item_from_slot(slot: Node) -> bool:
	if slot == null or not slot.has_method("get_occupied_item") or not slot.has_method("release_item"):
		return false

	var item := slot.get_occupied_item() as Node3D
	if not _wants_item(item):
		return false

	item = slot.release_item()
	if item == null:
		return false

	var parent := item.get_parent()
	if parent != null:
		parent.remove_child(item)

	add_child(item)
	item.position = carried_item_position
	item.rotation = Vector3.ZERO
	item.scale = carried_item_scale
	_checkout_item = item
	_target_slot_path = NodePath("")

	if item.has_method("set_customer_held"):
		item.set_customer_held(customer_id)

	return true


func _wants_item(item: Node) -> bool:
	if item == null:
		return false

	var product := item.get("product") as ProductDefinition
	return product != null and product.product_id == target_product_id


func _get_item_display_name(item: Node) -> String:
	if item == null:
		return "item"

	var product := item.get("product") as ProductDefinition
	if product != null and not product.display_name.is_empty():
		return product.display_name

	return item.name


func _approach_position_for_slot(slot: Node) -> Vector3:
	var slot_3d := slot as Node3D
	if slot_3d == null:
		return global_position

	var target := slot_3d.global_position + item_approach_offset
	target.y = global_position.y
	return target


func _move_toward(target: Vector3, delta: float) -> bool:
	var flattened_target := Vector3(target.x, global_position.y, target.z)
	if global_position.distance_to(flattened_target) <= arrival_distance:
		global_position = flattened_target
		return true

	global_position = global_position.move_toward(flattened_target, movement_speed * delta)
	if global_position.distance_to(flattened_target) <= arrival_distance:
		global_position = flattened_target
		return true

	return false
