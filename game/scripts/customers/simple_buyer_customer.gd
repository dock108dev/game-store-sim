extends StaticBody3D
class_name SimpleBuyerCustomer

const STATE_BROWSING := "browsing"
const STATE_WAITING_FOR_REGISTER := "waiting_for_register"
const STATE_SALE_COMPLETE := "sale_complete"

@export var customer_id: String = "customer_001"
@export var target_product_id: String = "used_star_trader"
@export var display_slot_path: NodePath
@export var register_queue_position: Vector3 = Vector3(1.15, 0.0, -3.2)
@export var carried_item_position: Vector3 = Vector3(0.0, 0.85, -0.35)
@export var carried_item_scale: Vector3 = Vector3(0.55, 0.55, 0.55)

var state: String = STATE_BROWSING
var _checkout_item: Node3D = null


func _process(_delta: float) -> void:
	if state != STATE_BROWSING:
		return

	if display_slot_path.is_empty():
		return

	var slot := get_node_or_null(display_slot_path)
	if slot != null:
		claim_item_from_slot(slot)


func get_interaction_prompt() -> String:
	if state == STATE_WAITING_FOR_REGISTER and _checkout_item != null:
		return "%s Waiting At Register" % _get_item_display_name(_checkout_item)

	if state == STATE_SALE_COMPLETE:
		return "Customer Checked Out"

	return "Customer Looking For %s" % target_product_id


func interact() -> String:
	if state == STATE_WAITING_FOR_REGISTER and _checkout_item != null:
		return "Customer is ready to buy %s." % _get_item_display_name(_checkout_item)

	if state == STATE_SALE_COMPLETE:
		return "Customer completed checkout."

	return "Customer is browsing for a matching game."


func is_waiting_for_register() -> bool:
	return state == STATE_WAITING_FOR_REGISTER and _checkout_item != null


func get_checkout_item() -> Node3D:
	return _checkout_item


func claim_item_from_slot(slot: Node) -> bool:
	if state != STATE_BROWSING:
		return false

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
	state = STATE_WAITING_FOR_REGISTER
	global_position = register_queue_position

	if item.has_method("set_customer_held"):
		item.set_customer_held(customer_id)

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
