extends StaticBody3D
class_name SimpleBuyerCustomer

const CategoryDemandPolicy := preload("res://scripts/economy/category_demand.gd")

const STATE_BROWSING := "browsing"
const STATE_MOVING_TO_ITEM := "moving_to_item"
const STATE_MOVING_TO_REGISTER := "moving_to_register"
const STATE_WAITING_FOR_REGISTER := "waiting_for_register"
const STATE_SALE_COMPLETE := "sale_complete"

@export var customer_id: String = "customer_001"
@export var target_product_id: String = "used_star_trader"
@export var display_slot_path: NodePath
@export var register_queue_position: Vector3 = Vector3(1.15, 0.0, -3.2)
@export var browse_position: Vector3 = Vector3(-2.15, 0.0, 4.25)
@export var register_approach_position: Vector3 = Vector3(1.25, 0.0, -2.75)
@export var leave_position: Vector3 = Vector3(-5.6, 0.0, 4.8)
@export var item_approach_offset: Vector3 = Vector3(0.0, 0.0, -0.85)
@export var movement_speed: float = 3.2
@export var arrival_distance: float = 0.06
@export var carried_item_position: Vector3 = Vector3(0.16, 0.64, -0.19)
@export var carried_item_scale: Vector3 = Vector3(0.38, 0.38, 0.38)
@export var leave_after_sale_enabled: bool = true

var state: String = STATE_BROWSING
var last_feedback: String = ""
var has_left_store: bool = false
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
		return

	if state == STATE_SALE_COMPLETE and leave_after_sale_enabled and not has_left_store:
		if _move_toward(leave_position, delta):
			has_left_store = true
			visible = false


func get_interaction_prompt() -> String:
	if state == STATE_MOVING_TO_ITEM:
		return "Customer Walking To %s" % target_product_id

	if state == STATE_MOVING_TO_REGISTER and _checkout_item != null:
		return "%s Heading To Register" % _get_item_display_name(_checkout_item)

	if state == STATE_WAITING_FOR_REGISTER and _checkout_item != null:
		return "%s Waiting At Register" % _get_item_display_name(_checkout_item)

	if state == STATE_SALE_COMPLETE:
		if has_left_store:
			return "Customer Left Store"
		return "Customer Checked Out"

	if not last_feedback.is_empty():
		return "Customer Feedback"

	return "Customer Looking For %s" % target_product_id


func interact() -> String:
	if state == STATE_MOVING_TO_ITEM:
		return "Customer is heading to the display rack."

	if state == STATE_MOVING_TO_REGISTER and _checkout_item != null:
		return "Customer is carrying %s to the register." % _get_item_display_name(_checkout_item)

	if state == STATE_WAITING_FOR_REGISTER and _checkout_item != null:
		return "Customer is ready to buy %s." % _get_item_display_name(_checkout_item)

	if state == STATE_SALE_COMPLETE:
		if has_left_store:
			return "Customer left after checkout."
		return "Customer completed checkout."

	if not last_feedback.is_empty():
		return last_feedback

	return "Customer is browsing for a matching game."


func is_waiting_for_register() -> bool:
	return state == STATE_WAITING_FOR_REGISTER and _checkout_item != null


func get_checkout_item() -> Node3D:
	return _checkout_item


func is_moving_to_register() -> bool:
	return state == STATE_MOVING_TO_REGISTER and _checkout_item != null


func is_claiming_slot(slot: Node) -> bool:
	return slot != null and not _target_slot_path.is_empty() and get_node_or_null(_target_slot_path) == slot


func get_last_feedback() -> String:
	return last_feedback


func would_buy_item(item: Node) -> bool:
	if not matches_target_product(item):
		last_feedback = ""
		return false

	var product := item.get("product") as ProductDefinition
	var current_price := get_effective_price_cents_for_item(item)
	var max_price := get_price_limit_cents_for_item(item)
	if current_price > max_price:
		last_feedback = "%s is too expensive at $%0.2f." % [
			product.display_name,
			current_price / 100.0,
		]
		show_customer_feedback("Too expensive.", CustomerFeedbackBubble.TONE_WARNING)
		return false

	last_feedback = "Interested in %s." % product.display_name
	show_customer_feedback(last_feedback, CustomerFeedbackBubble.TONE_POSITIVE)
	return true


func matches_target_product(item: Node) -> bool:
	var product: ProductDefinition = null
	if item != null:
		product = item.get("product") as ProductDefinition
	return product != null and product.product_id == target_product_id


func get_effective_price_cents_for_item(item: Node) -> int:
	var product: ProductDefinition = null
	if item != null:
		product = item.get("product") as ProductDefinition
	if product == null:
		return 0

	var current_price := int(item.get("current_price_cents"))
	if current_price <= 0:
		current_price = product.suggested_price_cents
	return current_price


func is_item_affordable(item: Node, update_feedback: bool = true) -> bool:
	if not matches_target_product(item):
		if update_feedback:
			last_feedback = ""
		return false

	var product := item.get("product") as ProductDefinition
	var current_price := get_effective_price_cents_for_item(item)
	var max_price := get_price_limit_cents_for_item(item)
	if current_price > max_price:
		if update_feedback:
			last_feedback = "%s is too expensive at $%0.2f." % [
				product.display_name,
				current_price / 100.0,
			]
			show_customer_feedback("Too expensive.", CustomerFeedbackBubble.TONE_WARNING)
		return false

	if update_feedback:
		last_feedback = "Interested in %s." % product.display_name
		show_customer_feedback(last_feedback, CustomerFeedbackBubble.TONE_POSITIVE)
	return true


func report_item_too_expensive(item: Node) -> void:
	if not matches_target_product(item):
		last_feedback = ""
		return

	var product := item.get("product") as ProductDefinition
	var current_price := get_effective_price_cents_for_item(item)
	last_feedback = "%s is too expensive at $%0.2f." % [
		product.display_name,
		current_price / 100.0,
	]
	show_customer_feedback("Too expensive.", CustomerFeedbackBubble.TONE_WARNING)


func get_price_limit_cents_for_item(item: Node) -> int:
	var product: ProductDefinition = null
	if item != null:
		product = item.get("product") as ProductDefinition
	if product == null:
		return 0

	var basis := product.market_value_cents
	if basis <= 0:
		basis = product.suggested_price_cents
	if basis <= 0:
		basis = int(item.get("current_price_cents"))

	var multiplier := CategoryDemandPolicy.get_price_limit_multiplier(product)

	return int(round(basis * multiplier))


func set_queue_position(queue_position: Vector3) -> void:
	register_queue_position = queue_position
	if state == STATE_WAITING_FOR_REGISTER:
		global_position = queue_position


func set_path_points(new_browse_position: Vector3, new_register_approach: Vector3, new_leave_position: Vector3) -> void:
	browse_position = new_browse_position
	register_approach_position = new_register_approach
	leave_position = new_leave_position
	if state == STATE_BROWSING and _checkout_item == null:
		global_position = browse_position


func recover_from_blocked_path(recovery_position: Vector3) -> void:
	global_position = recovery_position
	browse_position = recovery_position
	_move_target = Vector3.ZERO
	_target_slot_path = NodePath("")
	state = STATE_BROWSING
	last_feedback = "Customer returned to browsing after a blocked path."
	show_customer_feedback("Path blocked. Browsing again.", CustomerFeedbackBubble.TONE_WARNING)


func get_pathing_summary() -> Dictionary:
	return {
		"browse_position": browse_position,
		"register_approach_position": register_approach_position,
		"register_queue_position": register_queue_position,
		"leave_position": leave_position,
		"has_left_store": has_left_store,
	}


func show_customer_feedback(message: String, tone: String = CustomerFeedbackBubble.TONE_INFO) -> void:
	var bubble := _feedback_bubble()
	if bubble != null:
		bubble.show_feedback(message, tone)


func clear_customer_feedback() -> void:
	var bubble := _feedback_bubble()
	if bubble != null:
		bubble.clear_feedback()


func get_feedback_summary() -> Dictionary:
	var bubble := _feedback_bubble()
	if bubble == null:
		return {}

	return bubble.get_feedback_summary()


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
	register_approach_position = queue_position
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
	_move_target = leave_position
	last_feedback = "Customer paid and is leaving the store."
	show_customer_feedback("Thanks. Heading out.", CustomerFeedbackBubble.TONE_POSITIVE)

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
	last_feedback = "Taking %s to the register." % _get_item_display_name(item)
	show_customer_feedback("I'll take %s." % _get_item_display_name(item), CustomerFeedbackBubble.TONE_POSITIVE)
	_checkout_item = item
	_target_slot_path = NodePath("")

	if item.has_method("set_customer_held"):
		item.set_customer_held(customer_id)

	return true


func _wants_item(item: Node) -> bool:
	return would_buy_item(item)


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


func _feedback_bubble() -> CustomerFeedbackBubble:
	return get_node_or_null("FeedbackBubble") as CustomerFeedbackBubble
