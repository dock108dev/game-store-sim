extends Node
class_name StoreSession

@export var day_number: int = 1
@export var starting_cash_cents: int = 50000
@export var ledger_path: NodePath
@export var inventory_root_path: NodePath

var cash_cents: int = 0
var is_day_closed: bool = false


func _ready() -> void:
	if cash_cents == 0:
		cash_cents = starting_cash_cents


func apply_sale(transaction: Dictionary) -> void:
	cash_cents += int(transaction.get("sale_price_cents", 0))


func apply_trade_in(transaction: Dictionary) -> void:
	cash_cents -= int(transaction.get("trade_in_cost_cents", 0))


func end_day() -> void:
	is_day_closed = true


func get_cash_cents() -> int:
	if cash_cents == 0:
		return starting_cash_cents

	return cash_cents


func get_sale_count() -> int:
	var ledger := _get_ledger()
	if ledger == null:
		return 0

	return ledger.get_sale_count()


func get_total_revenue_cents() -> int:
	var ledger := _get_ledger()
	if ledger == null:
		return 0

	return ledger.get_total_revenue_cents()


func get_total_cost_cents() -> int:
	var total := 0
	for transaction in get_transactions():
		if str(transaction.get("type", "sale")) == "sale":
			total += int(transaction.get("cost_basis_cents", 0))
	return total


func get_total_profit_cents() -> int:
	var ledger := _get_ledger()
	if ledger == null:
		return 0

	return ledger.get_total_profit_cents()


func get_trade_in_count() -> int:
	var ledger := _get_ledger()
	if ledger == null:
		return 0

	return ledger.get_trade_in_count()


func get_total_trade_in_cost_cents() -> int:
	var ledger := _get_ledger()
	if ledger == null:
		return 0

	return ledger.get_total_trade_in_cost_cents()


func get_transactions() -> Array[Dictionary]:
	var ledger := _get_ledger()
	if ledger == null:
		return []

	return ledger.get_transactions()


func get_last_transaction() -> Dictionary:
	var transactions := get_transactions()
	if transactions.is_empty():
		return {}

	return transactions[transactions.size() - 1]


func get_active_inventory_items() -> Array[Node]:
	var items: Array[Node] = []
	var root := _get_inventory_root()
	if root == null:
		return items

	_collect_active_inventory_items(root, items)
	return items


func get_inventory_summary_text() -> String:
	var counts := {}
	for item in get_active_inventory_items():
		var product := item.get("product") as ProductDefinition
		if product == null:
			continue

		var key := product.display_name
		counts[key] = int(counts.get(key, 0)) + 1

	if counts.is_empty():
		return "Inventory: none"

	var lines: Array[String] = ["Inventory:"]
	var names := counts.keys()
	names.sort()
	for name in names:
		lines.append("%s x%d" % [name, int(counts[name])])
	return "\n".join(lines)


func get_status_label() -> String:
	if is_day_closed:
		return "Day closed"

	return "Day open"


func get_summary_text() -> String:
	return "Day %d\nCash: %s\nSales: %d\nTrade-ins: %d\nRevenue: %s\nCost: %s\nTrade spend: %s\nProfit: %s\n%s" % [
		day_number,
		format_money(get_cash_cents()),
		get_sale_count(),
		get_trade_in_count(),
		format_money(get_total_revenue_cents()),
		format_money(get_total_cost_cents()),
		format_money(get_total_trade_in_cost_cents()),
		format_money(get_total_profit_cents()),
		get_status_label(),
	]


func format_money(cents: int) -> String:
	return "$%0.2f" % (cents / 100.0)


func _get_ledger() -> TransactionLedger:
	if ledger_path.is_empty():
		return null

	return get_node_or_null(ledger_path) as TransactionLedger


func _get_inventory_root() -> Node:
	if inventory_root_path.is_empty():
		return get_parent()

	return get_node_or_null(inventory_root_path)


func _collect_active_inventory_items(node: Node, items: Array[Node]) -> void:
	var product := node.get("product") as ProductDefinition
	if product != null:
		var location_id := str(node.get("location_id"))
		if location_id != "sold" and not location_id.begins_with("customer:"):
			items.append(node)

	for child in node.get_children():
		_collect_active_inventory_items(child, items)
