extends StaticBody3D
class_name SimpleTradeInCustomer

const STATE_WAITING_FOR_TRADE := "waiting_for_trade"
const STATE_TRADE_COMPLETE := "trade_complete"
const STATE_TRADE_DECLINED := "trade_declined"

@export var customer_id: String = "trade_seller_001"
@export var carried_item_path: NodePath = NodePath("TradeInItem")
@export var offer_rate: float = 0.4
@export var receiving_item_position: Vector3 = Vector3(0.0, 0.2, 0.14)

var state: String = STATE_WAITING_FOR_TRADE


func _ready() -> void:
	var item := get_trade_item()
	if item != null and item.has_method("set_customer_held"):
		item.set_customer_held(customer_id)


func get_interaction_prompt() -> String:
	if state == STATE_TRADE_COMPLETE:
		return "Trade-In Complete"

	if state == STATE_TRADE_DECLINED:
		return "Trade-In Declined"

	var item := get_trade_item()
	if item != null:
		return "Trade-In Seller: %s" % _get_item_display_name(item)

	return "Trade-In Seller"


func interact() -> String:
	if state == STATE_TRADE_COMPLETE:
		return "Trade-in already completed."

	if state == STATE_TRADE_DECLINED:
		return "Trade-in declined."

	var item := get_trade_item()
	if item == null:
		return "Seller has no trade-in item."

	return get_trade_in_summary()


func is_waiting_for_trade_in() -> bool:
	return state == STATE_WAITING_FOR_TRADE and get_trade_item() != null


func get_trade_item() -> Node3D:
	if carried_item_path.is_empty():
		return null

	return get_node_or_null(carried_item_path) as Node3D


func get_offer_cents() -> int:
	return maxi(1, int(round(get_market_value_cents() * offer_rate)))


func get_market_value_cents() -> int:
	var item := get_trade_item()
	if item == null:
		return 0

	var product := item.get("product") as ProductDefinition
	if product == null:
		return 0

	return product.market_value_cents


func get_max_offer_cents() -> int:
	return maxi(1, get_market_value_cents())


func get_trade_in_summary() -> String:
	var item := get_trade_item()
	if item == null:
		return "Seller has no trade-in item."

	var product := item.get("product") as ProductDefinition
	if product == null:
		return "Seller has an unknown item."

	return "%s - %s - %s - Demand %s - Market $%0.2f - Offer $%0.2f" % [
		product.display_name,
		product.platform,
		product.condition.capitalize(),
		product.demand_tier.capitalize(),
		product.market_value_cents / 100.0,
		get_offer_cents() / 100.0,
	]


func complete_trade_in(receiving_box: Node) -> Node3D:
	if not is_waiting_for_trade_in() or receiving_box == null:
		return null

	var item := get_trade_item()
	var parent := item.get_parent()
	if parent != null:
		parent.remove_child(item)

	receiving_box.add_child(item)
	item.position = receiving_item_position
	item.rotation = Vector3.ZERO
	item.scale = Vector3.ONE
	carried_item_path = NodePath("")
	state = STATE_TRADE_COMPLETE

	item.set("location_id", "receiving_box_001")
	if item.has_method("set_collision_enabled"):
		item.set_collision_enabled(true)

	return item


func decline_trade_in() -> bool:
	if state != STATE_WAITING_FOR_TRADE:
		return false

	state = STATE_TRADE_DECLINED
	return true


func _get_item_display_name(item: Node) -> String:
	if item == null:
		return "item"

	var product := item.get("product") as ProductDefinition
	if product != null and not product.display_name.is_empty():
		return product.display_name

	return item.name
