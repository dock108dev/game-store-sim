extends "res://scripts/interaction/interactable.gd"
class_name RegisterWorkstation

@export var customer_path: NodePath
@export var customer_manager_path: NodePath
@export var trade_in_customer_path: NodePath
@export var receiving_box_path: NodePath
@export var ledger_path: NodePath
@export var store_session_path: NodePath


func get_interaction_prompt() -> String:
	var customer := _get_waiting_customer()
	if customer != null:
		var item: Node = customer.get_checkout_item()
		return "E Ring Up %s" % _get_item_display_name(item)

	var trade_in_customer := _get_waiting_trade_in_customer()
	if trade_in_customer != null:
		var trade_item: Node = trade_in_customer.get_trade_item()
		return "E Review Trade-In %s" % _get_item_display_name(trade_item)

	return "Register Workstation"


func get_interaction_prompt_for_actor(_actor: Node) -> String:
	return get_interaction_prompt()


func interact() -> String:
	return _complete_waiting_sale()


func interact_with_actor(_actor: Node) -> String:
	var customer := _get_waiting_customer()
	if customer != null:
		return _complete_waiting_sale()

	var trade_in_customer := _get_waiting_trade_in_customer()
	if trade_in_customer != null and _actor != null and _actor.has_method("open_trade_in_offer"):
		return str(_actor.open_trade_in_offer(self, trade_in_customer))

	return _complete_waiting_sale()


func _complete_waiting_sale() -> String:
	var customer := _get_waiting_customer()
	if customer == null:
		return _complete_waiting_trade_in()

	var item: Node = customer.get_checkout_item()
	var ledger := _get_ledger()
	if item == null or ledger == null:
		return "Register is not ready to complete a sale."

	var transaction := ledger.record_sale(str(customer.get("customer_id")), item)
	if transaction.is_empty():
		return "Register could not record the sale."

	var store_session := _get_store_session()
	if store_session != null:
		store_session.apply_sale(transaction)

	customer.complete_sale()
	var customer_manager := _get_customer_manager()
	if customer_manager != null and customer_manager.has_method("compact_after_sale"):
		customer_manager.compact_after_sale()

	return "Sold %s for $%0.2f. Profit $%0.2f." % [
		str(transaction.get("display_name", "item")),
		int(transaction.get("sale_price_cents", 0)) / 100.0,
		int(transaction.get("profit_cents", 0)) / 100.0,
	]


func _complete_waiting_trade_in() -> String:
	var customer := _get_waiting_trade_in_customer()
	if customer == null:
		return "No customer waiting at the register."

	return accept_trade_in(customer)


func accept_trade_in(customer: SimpleTradeInCustomer, offer_cents: int = -1) -> String:
	if customer == null or not customer.is_waiting_for_trade_in():
		return "No trade-in waiting at the register."

	var item: Node = customer.get_trade_item()
	var ledger := _get_ledger()
	var receiving_box := _get_receiving_box()
	if item == null or ledger == null or receiving_box == null:
		return "Register is not ready to complete a trade-in."

	var final_offer_cents := offer_cents
	if final_offer_cents < 0:
		final_offer_cents = customer.get_offer_cents()
	final_offer_cents = maxi(1, final_offer_cents)

	var transaction := ledger.record_trade_in(str(customer.get("customer_id")), item, final_offer_cents)
	if transaction.is_empty():
		return "Register could not record the trade-in."

	item.set("cost_basis_cents", final_offer_cents)
	var acquired_item := customer.complete_trade_in(receiving_box)
	if acquired_item == null:
		return "Register could not receive the trade-in item."

	var store_session := _get_store_session()
	if store_session != null:
		store_session.apply_trade_in(transaction)

	return "Bought %s trade-in for $%0.2f." % [
		str(transaction.get("display_name", "item")),
		final_offer_cents / 100.0,
	]


func decline_trade_in(customer: SimpleTradeInCustomer) -> String:
	if customer == null or not customer.is_waiting_for_trade_in():
		return "No trade-in waiting at the register."

	if customer.decline_trade_in():
		return "Declined %s trade-in." % _get_item_display_name(customer.get_trade_item())

	return "Could not decline trade-in."


func _get_waiting_customer() -> SimpleBuyerCustomer:
	var customer_manager := _get_customer_manager()
	if customer_manager != null and customer_manager.has_method("get_next_waiting_customer"):
		var managed_customer := customer_manager.get_next_waiting_customer() as SimpleBuyerCustomer
		if managed_customer != null:
			return managed_customer

	if customer_path.is_empty():
		return null

	var customer := get_node_or_null(customer_path) as SimpleBuyerCustomer
	if customer != null and customer.has_method("is_waiting_for_register") and customer.is_waiting_for_register():
		return customer

	return null


func _get_waiting_trade_in_customer() -> SimpleTradeInCustomer:
	if trade_in_customer_path.is_empty():
		return null

	var customer := get_node_or_null(trade_in_customer_path) as SimpleTradeInCustomer
	if customer != null and customer.has_method("is_waiting_for_trade_in") and customer.is_waiting_for_trade_in():
		return customer

	return null


func _get_customer_manager() -> Node:
	if customer_manager_path.is_empty():
		return null

	return get_node_or_null(customer_manager_path)


func _get_receiving_box() -> Node:
	if receiving_box_path.is_empty():
		return null

	return get_node_or_null(receiving_box_path)


func _get_ledger() -> TransactionLedger:
	if ledger_path.is_empty():
		return null

	return get_node_or_null(ledger_path) as TransactionLedger


func _get_store_session() -> Node:
	if store_session_path.is_empty():
		return null

	return get_node_or_null(store_session_path)


func _get_item_display_name(item: Node) -> String:
	if item == null:
		return "item"

	var product := item.get("product") as ProductDefinition
	if product != null and not product.display_name.is_empty():
		return product.display_name

	return item.name
