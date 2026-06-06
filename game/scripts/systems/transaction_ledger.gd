extends Node
class_name TransactionLedger

var _transactions: Array[Dictionary] = []


func record_sale(customer_id: String, item: Node) -> Dictionary:
	if item == null:
		return {}

	var product := item.get("product") as ProductDefinition
	if product == null:
		return {}

	var sale_price_cents := int(item.get("current_price_cents"))
	var transaction := {
		"transaction_id": "sale_%03d" % (_transactions.size() + 1),
		"customer_id": customer_id,
		"item_instance_id": str(item.get("instance_id")),
		"product_id": product.product_id,
		"display_name": product.display_name,
		"sale_price_cents": sale_price_cents,
		"cost_basis_cents": product.cost_basis_cents,
		"profit_cents": sale_price_cents - product.cost_basis_cents,
	}
	_transactions.append(transaction)
	return transaction


func get_transactions() -> Array[Dictionary]:
	return _transactions.duplicate(true)


func get_sale_count() -> int:
	return _transactions.size()


func get_total_revenue_cents() -> int:
	var total := 0
	for transaction in _transactions:
		total += int(transaction.get("sale_price_cents", 0))
	return total


func get_total_profit_cents() -> int:
	var total := 0
	for transaction in _transactions:
		total += int(transaction.get("profit_cents", 0))
	return total
