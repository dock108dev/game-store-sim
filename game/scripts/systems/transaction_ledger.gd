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
	var cost_basis_cents := int(item.get("cost_basis_cents"))
	if cost_basis_cents <= 0:
		cost_basis_cents = product.cost_basis_cents
	var transaction := {
		"transaction_id": "sale_%03d" % (_transactions.size() + 1),
		"type": "sale",
		"customer_id": customer_id,
		"item_instance_id": str(item.get("instance_id")),
		"product_id": product.product_id,
		"display_name": product.display_name,
		"sale_price_cents": sale_price_cents,
		"cost_basis_cents": cost_basis_cents,
		"profit_cents": sale_price_cents - cost_basis_cents,
	}
	_transactions.append(transaction)
	return transaction


func record_trade_in(customer_id: String, item: Node, offer_cents: int) -> Dictionary:
	if item == null:
		return {}

	var product := item.get("product") as ProductDefinition
	if product == null:
		return {}

	var transaction := {
		"transaction_id": "trade_in_%03d" % (_transactions.size() + 1),
		"type": "trade_in",
		"customer_id": customer_id,
		"item_instance_id": str(item.get("instance_id")),
		"product_id": product.product_id,
		"display_name": product.display_name,
		"trade_in_cost_cents": offer_cents,
	}
	_transactions.append(transaction)
	return transaction


func get_transactions() -> Array[Dictionary]:
	return _transactions.duplicate(true)


func replace_transactions(transactions: Array) -> void:
	_transactions.clear()
	for transaction in transactions:
		if typeof(transaction) == TYPE_DICTIONARY:
			var row: Dictionary = transaction
			_transactions.append(row.duplicate(true))


func get_sale_count() -> int:
	var total := 0
	for transaction in _transactions:
		if str(transaction.get("type", "sale")) == "sale":
			total += 1
	return total


func get_trade_in_count() -> int:
	var total := 0
	for transaction in _transactions:
		if str(transaction.get("type", "")) == "trade_in":
			total += 1
	return total


func get_total_revenue_cents() -> int:
	var total := 0
	for transaction in _transactions:
		if str(transaction.get("type", "sale")) == "sale":
			total += int(transaction.get("sale_price_cents", 0))
	return total


func get_total_profit_cents() -> int:
	var total := 0
	for transaction in _transactions:
		if str(transaction.get("type", "sale")) == "sale":
			total += int(transaction.get("profit_cents", 0))
	return total


func get_total_trade_in_cost_cents() -> int:
	var total := 0
	for transaction in _transactions:
		if str(transaction.get("type", "")) == "trade_in":
			total += int(transaction.get("trade_in_cost_cents", 0))
	return total
