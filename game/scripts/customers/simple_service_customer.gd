extends StaticBody3D
class_name SimpleServiceCustomer

const AlphaBalancePolicy := preload("res://scripts/economy/alpha_balance_profile.gd")

const STATE_WAITING_FOR_SERVICE := "waiting_for_service"
const STATE_SERVICE_COMPLETE := "service_complete"

@export var customer_id: String = "service_customer_001"
@export var archetype: CustomerArchetype
@export var service_id: String = "disc_resurfacing"
@export var service_name: String = "Disc Resurfacing"
@export var item_name: String = "Scratched Orbit Disc"
@export var price_cents: int = AlphaBalancePolicy.DISC_RESURFACING_PRICE_CENTS
@export var cost_cents: int = AlphaBalancePolicy.DISC_RESURFACING_COST_CENTS
@export var turnaround_minutes: int = 10

var state: String = STATE_WAITING_FOR_SERVICE


func _ready() -> void:
	show_customer_feedback("Service?", CustomerFeedbackBubble.TONE_INFO)


func get_interaction_prompt() -> String:
	if state == STATE_SERVICE_COMPLETE:
		return "Service Complete"

	return "Service Customer: %s" % service_name


func interact() -> String:
	if state == STATE_SERVICE_COMPLETE:
		return "Service already completed."

	return get_service_summary()


func is_waiting_for_service() -> bool:
	return state == STATE_WAITING_FOR_SERVICE


func complete_service() -> bool:
	if not is_waiting_for_service():
		return false

	state = STATE_SERVICE_COMPLETE
	show_customer_feedback("Service complete.", CustomerFeedbackBubble.TONE_POSITIVE)
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


func get_service_summary() -> String:
	return "%s for %s - Price %s - Cost %s - Time %dm" % [
		service_name,
		item_name,
		_format_money(get_price_cents()),
		_format_money(get_cost_cents()),
		get_turnaround_minutes(),
	]


func get_price_cents() -> int:
	return maxi(1, price_cents)


func get_cost_cents() -> int:
	return maxi(0, cost_cents)


func get_turnaround_minutes() -> int:
	return maxi(1, turnaround_minutes)


func _format_money(cents: int) -> String:
	return "$%0.2f" % (cents / 100.0)


func _feedback_bubble() -> CustomerFeedbackBubble:
	return get_node_or_null("FeedbackBubble") as CustomerFeedbackBubble
