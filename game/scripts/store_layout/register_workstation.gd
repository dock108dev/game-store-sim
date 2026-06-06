extends "res://scripts/interaction/interactable.gd"
class_name RegisterWorkstation

@export var customer_path: NodePath
@export var ledger_path: NodePath


func get_interaction_prompt() -> String:
	var customer := _get_waiting_customer()
	if customer != null:
		var item: Node = customer.get_checkout_item()
		return "E Ring Up %s" % _get_item_display_name(item)

	return "Register Workstation"


func get_interaction_prompt_for_actor(_actor: Node) -> String:
	return get_interaction_prompt()


func interact() -> String:
	return _complete_waiting_sale()


func interact_with_actor(_actor: Node) -> String:
	return _complete_waiting_sale()


func _complete_waiting_sale() -> String:
	var customer := _get_waiting_customer()
	if customer == null:
		return "No customer waiting at the register."

	var item: Node = customer.get_checkout_item()
	var ledger := _get_ledger()
	if item == null or ledger == null:
		return "Register is not ready to complete a sale."

	var transaction := ledger.record_sale(str(customer.get("customer_id")), item)
	if transaction.is_empty():
		return "Register could not record the sale."

	customer.complete_sale()
	return "Sold %s for $%0.2f. Profit $%0.2f." % [
		str(transaction.get("display_name", "item")),
		int(transaction.get("sale_price_cents", 0)) / 100.0,
		int(transaction.get("profit_cents", 0)) / 100.0,
	]


func _get_waiting_customer() -> SimpleBuyerCustomer:
	if customer_path.is_empty():
		return null

	var customer := get_node_or_null(customer_path) as SimpleBuyerCustomer
	if customer != null and customer.has_method("is_waiting_for_register") and customer.is_waiting_for_register():
		return customer

	return null


func _get_ledger() -> TransactionLedger:
	if ledger_path.is_empty():
		return null

	return get_node_or_null(ledger_path) as TransactionLedger


func _get_item_display_name(item: Node) -> String:
	if item == null:
		return "item"

	var product := item.get("product") as ProductDefinition
	if product != null and not product.display_name.is_empty():
		return product.display_name

	return item.name
