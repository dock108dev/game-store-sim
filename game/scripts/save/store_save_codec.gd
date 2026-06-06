extends RefCounted
class_name StoreSaveCodec


func create_save_data(session: StoreSession) -> Dictionary:
	if session == null:
		return {}

	var data: Dictionary = {
		"version": 1,
		"day_number": session.day_number,
		"cash_cents": session.get_cash_cents(),
		"is_day_closed": session.is_day_closed,
		"transactions": session.get_transactions(),
		"inventory_items": _serialize_inventory_items(session.get_active_inventory_items()),
	}
	return data


func encode_to_json(data: Dictionary) -> String:
	return JSON.stringify(data)


func decode_from_json(json_text: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(json_text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}

	var parsed_dictionary: Dictionary = parsed
	return parsed_dictionary


func restore_into_existing_scene(
	session: StoreSession,
	ledger: TransactionLedger,
	inventory_root: Node,
	data: Dictionary
) -> bool:
	if session == null or ledger == null or data.is_empty():
		return false

	session.day_number = int(data.get("day_number", session.day_number))
	session.cash_cents = int(data.get("cash_cents", session.starting_cash_cents))
	session.is_day_closed = bool(data.get("is_day_closed", false))

	var transactions_value: Variant = data.get("transactions", [])
	if typeof(transactions_value) == TYPE_ARRAY:
		var transactions: Array = transactions_value
		ledger.replace_transactions(transactions)

	if inventory_root != null:
		var items_value: Variant = data.get("inventory_items", [])
		if typeof(items_value) == TYPE_ARRAY:
			var items: Array = items_value
			_restore_existing_item_state(inventory_root, items)

	return true


func _serialize_inventory_items(items: Array[Node]) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for item in items:
		var product := item.get("product") as ProductDefinition
		if product == null:
			continue

		rows.append({
			"instance_id": str(item.get("instance_id")),
			"product_id": product.product_id,
			"display_name": product.display_name,
			"condition": product.condition,
			"current_price_cents": int(item.get("current_price_cents")),
			"cost_basis_cents": int(item.get("cost_basis_cents")),
			"location_id": str(item.get("location_id")),
		})

	return rows


func _restore_existing_item_state(root: Node, item_rows: Array) -> void:
	var items_by_id := {}
	_index_items_by_instance_id(root, items_by_id)

	for row_value in item_rows:
		if typeof(row_value) != TYPE_DICTIONARY:
			continue

		var row: Dictionary = row_value
		var instance_id := str(row.get("instance_id", ""))
		if instance_id.is_empty() or not items_by_id.has(instance_id):
			continue

		var item := items_by_id[instance_id] as Node
		item.set("current_price_cents", int(row.get("current_price_cents", item.get("current_price_cents"))))
		item.set("cost_basis_cents", int(row.get("cost_basis_cents", item.get("cost_basis_cents"))))
		item.set("location_id", str(row.get("location_id", item.get("location_id"))))


func _index_items_by_instance_id(node: Node, items_by_id: Dictionary) -> void:
	var product := node.get("product") as ProductDefinition
	if product != null:
		var instance_id := str(node.get("instance_id"))
		if not instance_id.is_empty():
			items_by_id[instance_id] = node

	for child in node.get_children():
		_index_items_by_instance_id(child, items_by_id)
