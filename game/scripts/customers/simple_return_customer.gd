extends StaticBody3D
class_name SimpleReturnCustomer

const STATE_WAITING_FOR_RETURN := "waiting_for_return"
const STATE_RETURN_COMPLETE := "return_complete"
const STATE_RETURN_REFUSED := "return_refused"

@export var customer_id: String = "return_customer_001"
@export var archetype: CustomerArchetype
@export var returned_item_path: NodePath = NodePath("ReturnedItem")
@export var refund_cents: int = 2199
@export var return_reason: String = "defective copy"
@export var return_disposition: String = "inspect_restock"
@export var receiving_item_position: Vector3 = Vector3(0.24, 0.2, 0.12)

var state: String = STATE_WAITING_FOR_RETURN


func _ready() -> void:
	var item := get_returned_item()
	if item != null and item.has_method("set_customer_held"):
		item.set_customer_held(customer_id)
	show_customer_feedback("Return?", CustomerFeedbackBubble.TONE_WARNING)


func get_interaction_prompt() -> String:
	if state == STATE_RETURN_COMPLETE:
		return "Return Complete"

	if state == STATE_RETURN_REFUSED:
		return "Return Refused"

	var item := get_returned_item()
	if item != null:
		return "Return Customer: %s" % _get_item_display_name(item)

	return "Return Customer"


func interact() -> String:
	if state == STATE_RETURN_COMPLETE:
		return "Return already completed."

	if state == STATE_RETURN_REFUSED:
		return "Return was refused."

	var item := get_returned_item()
	if item == null:
		return "Customer has no returned item."

	return get_return_summary()


func is_waiting_for_return() -> bool:
	return state == STATE_WAITING_FOR_RETURN and get_returned_item() != null


func get_returned_item() -> Node3D:
	if returned_item_path.is_empty():
		return null

	return get_node_or_null(returned_item_path) as Node3D


func get_refund_cents() -> int:
	return maxi(1, refund_cents)


func get_return_summary() -> String:
	var item := get_returned_item()
	if item == null:
		return "Customer has no returned item."

	var product := item.get("product") as ProductDefinition
	if product == null:
		return "Customer has an unknown returned item."

	return "%s return - %s - Refund %s - %s" % [
		product.display_name,
		return_reason,
		_format_money(get_refund_cents()),
		return_disposition,
	]


func complete_return(receiving_box: Node) -> Node3D:
	if not is_waiting_for_return() or receiving_box == null:
		return null

	var item := get_returned_item()
	var parent := item.get_parent()
	if parent != null:
		parent.remove_child(item)

	receiving_box.add_child(item)
	item.position = receiving_item_position
	item.rotation = Vector3.ZERO
	item.scale = Vector3.ONE
	returned_item_path = NodePath("")
	state = STATE_RETURN_COMPLETE
	show_customer_feedback("Return handled.", CustomerFeedbackBubble.TONE_POSITIVE)

	item.set("location_id", "receiving_box_001")
	if item.has_method("set_collision_enabled"):
		item.set_collision_enabled(true)

	return item


func refuse_return() -> bool:
	if state != STATE_WAITING_FOR_RETURN:
		return false

	state = STATE_RETURN_REFUSED
	show_customer_feedback("Not happy.", CustomerFeedbackBubble.TONE_WARNING)
	return true


func show_customer_feedback(message: String, tone: String = CustomerFeedbackBubble.TONE_INFO) -> void:
	var bubble := _feedback_bubble()
	if bubble != null:
		bubble.show_feedback(message, tone)


func get_feedback_summary() -> Dictionary:
	var bubble := _feedback_bubble()
	if bubble == null:
		return {}

	return bubble.get_feedback_summary()


func get_archetype_summary() -> String:
	if archetype == null:
		return ""

	return archetype.summary_line()


func _get_item_display_name(item: Node) -> String:
	if item == null:
		return "item"

	var product := item.get("product") as ProductDefinition
	if product != null and not product.display_name.is_empty():
		return product.display_name

	return item.name


func _format_money(cents: int) -> String:
	return "$%0.2f" % (cents / 100.0)


func _feedback_bubble() -> CustomerFeedbackBubble:
	return get_node_or_null("FeedbackBubble") as CustomerFeedbackBubble
