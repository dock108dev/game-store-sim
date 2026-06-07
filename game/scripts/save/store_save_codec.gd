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
		"fixture_orders": session.get_pending_fixture_orders(),
		"supplier_orders": session.get_pending_supplier_orders(),
		"preorder_deposits": session.get_preorder_deposits(),
		"release_allocations": session.get_release_allocations(),
		"launch_events": session.get_launch_events(),
		"reputation_score": session.get_reputation_score(),
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
	session.reputation_score = int(data.get("reputation_score", session.reputation_score))

	var transactions_value: Variant = data.get("transactions", [])
	if typeof(transactions_value) == TYPE_ARRAY:
		var transactions: Array = transactions_value
		ledger.replace_transactions(transactions)

	if inventory_root != null:
		var items_value: Variant = data.get("inventory_items", [])
		if typeof(items_value) == TYPE_ARRAY:
			var items: Array = items_value
			_restore_existing_item_state(inventory_root, items)

	var fixture_orders_value: Variant = data.get("fixture_orders", [])
	if typeof(fixture_orders_value) == TYPE_ARRAY:
		var fixture_orders: Array = fixture_orders_value
		session.replace_fixture_orders(fixture_orders)

	var supplier_orders_value: Variant = data.get("supplier_orders", [])
	if typeof(supplier_orders_value) == TYPE_ARRAY:
		var supplier_orders: Array = supplier_orders_value
		session.replace_supplier_orders(supplier_orders)

	var preorder_deposits_value: Variant = data.get("preorder_deposits", [])
	if typeof(preorder_deposits_value) == TYPE_ARRAY and session.has_method("replace_preorder_deposits"):
		var preorder_deposits: Array = preorder_deposits_value
		session.replace_preorder_deposits(preorder_deposits)

	var release_allocations_value: Variant = data.get("release_allocations", [])
	if typeof(release_allocations_value) == TYPE_ARRAY and session.has_method("replace_release_allocations"):
		var release_allocations: Array = release_allocations_value
		session.replace_release_allocations(release_allocations)

	var launch_events_value: Variant = data.get("launch_events", [])
	if typeof(launch_events_value) == TYPE_ARRAY and session.has_method("replace_launch_events"):
		var launch_events: Array = launch_events_value
		session.replace_launch_events(launch_events)

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
