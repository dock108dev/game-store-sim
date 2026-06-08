extends RefCounted
class_name StoreSaveCodec

const CURRENT_SAVE_VERSION := 2
const MIN_SUPPORTED_SAVE_VERSION := 1
const SAVE_SCHEMA_ID := "game_store_sim.store_save"

const ARRAY_DEFAULT_KEYS := [
	"transactions",
	"fixture_orders",
	"supplier_orders",
	"receiving_batches",
	"storage_movements",
	"service_tickets",
	"management_reviews",
	"preorder_deposits",
	"release_allocations",
	"launch_events",
	"operating_expenses",
	"reputation_events",
	"purchased_upgrades",
	"purchased_decorations",
	"hidden_thread_choices",
	"hidden_thread_consequences",
	"inventory_items",
	"migration_history",
]

var last_error: String = ""
var last_migration_messages: Array[String] = []


func create_save_data(session: StoreSession) -> Dictionary:
	if session == null:
		return {}

	var data: Dictionary = {
		"version": CURRENT_SAVE_VERSION,
		"schema_id": SAVE_SCHEMA_ID,
		"migration_history": [],
		"day_number": session.day_number,
		"day_phase": session.get_day_phase(),
		"cash_cents": session.get_cash_cents(),
		"is_day_closed": session.is_day_closed,
		"transactions": session.get_transactions(),
		"fixture_orders": session.get_pending_fixture_orders(),
		"supplier_orders": session.get_pending_supplier_orders(),
		"receiving_batches": session.get_receiving_batches(),
		"storage_movements": session.get_storage_movements(),
		"service_tickets": session.get_service_tickets(),
		"management_reviews": session.get_management_reviews(),
		"preorder_deposits": session.get_preorder_deposits(),
		"release_allocations": session.get_release_allocations(),
		"launch_events": session.get_launch_events(),
		"operating_expenses": session.get_operating_expenses(),
		"reputation_events": session.get_reputation_events(),
		"purchased_upgrades": session.get_purchased_upgrades(),
		"purchased_decorations": session.get_purchased_decorations(),
		"hidden_thread_choices": session.get_hidden_thread_choice_records(),
		"hidden_thread_consequences": session.get_hidden_thread_consequence_events(),
		"hidden_supplier_access_score": session.supplier_access_score,
		"hidden_customer_trust_score": session.customer_trust_score,
		"hidden_inspection_risk_score": session.inspection_risk_score,
		"hidden_story_state": session.hidden_story_state,
		"reputation_score": session.get_reputation_score(),
		"inventory_items": _serialize_inventory_items(session.get_active_inventory_items()),
	}
	return data


func encode_to_json(data: Dictionary) -> String:
	return JSON.stringify(data)


func decode_from_json(json_text: String) -> Dictionary:
	last_error = ""
	last_migration_messages.clear()

	var parser := JSON.new()
	var parse_error := parser.parse(json_text)
	if parse_error != OK:
		last_error = "Save data is not valid JSON object data."
		return {}

	var parsed: Variant = parser.data
	if typeof(parsed) != TYPE_DICTIONARY:
		last_error = "Save data is not valid JSON object data."
		return {}

	var parsed_dictionary: Dictionary = parsed
	return migrate_save_data(parsed_dictionary)


func migrate_save_data(data: Dictionary) -> Dictionary:
	last_error = ""
	last_migration_messages.clear()
	if data.is_empty():
		last_error = "Save data is empty."
		return {}

	var migrated := data.duplicate(true)
	var version := int(migrated.get("version", MIN_SUPPORTED_SAVE_VERSION))
	if version < MIN_SUPPORTED_SAVE_VERSION:
		last_error = "Save version %d is no longer supported." % version
		return {}
	if version > CURRENT_SAVE_VERSION:
		last_error = "Save version %d is newer than this build supports." % version
		return {}

	if version == 1:
		migrated["version"] = CURRENT_SAVE_VERSION
		migrated["schema_id"] = SAVE_SCHEMA_ID
		_ensure_array_defaults(migrated)
		_ensure_scalar_defaults(migrated)
		var history: Array = migrated.get("migration_history", [])
		history.append("v1_to_v2_defaults")
		migrated["migration_history"] = history
		last_migration_messages.append("Migrated save data from version 1 to version 2.")
	else:
		migrated["schema_id"] = str(migrated.get("schema_id", SAVE_SCHEMA_ID))
		_ensure_array_defaults(migrated)
		_ensure_scalar_defaults(migrated)

	return migrated


func get_last_error() -> String:
	return last_error


func get_last_migration_messages() -> Array[String]:
	return last_migration_messages.duplicate()


func get_migration_policy_summary_text() -> String:
	return "Save migration policy:\nCurrent version %d\nSupports versions %d-%d\nVersion 1 saves migrate with default arrays, schema id, reputation, hidden-thread scores, and migration history\nFuture or malformed saves fail closed with last_error" % [
		CURRENT_SAVE_VERSION,
		MIN_SUPPORTED_SAVE_VERSION,
		CURRENT_SAVE_VERSION,
	]


func restore_into_existing_scene(
	session: StoreSession,
	ledger: TransactionLedger,
	inventory_root: Node,
	data: Dictionary
) -> bool:
	if session == null or ledger == null or data.is_empty():
		return false

	var save_data := migrate_save_data(data)
	if save_data.is_empty():
		return false

	session.day_number = int(save_data.get("day_number", session.day_number))
	session.day_phase = str(save_data.get("day_phase", session.day_phase))
	session.cash_cents = int(save_data.get("cash_cents", session.starting_cash_cents))
	session.is_day_closed = bool(save_data.get("is_day_closed", false))
	session.reputation_score = int(save_data.get("reputation_score", session.reputation_score))

	var transactions_value: Variant = save_data.get("transactions", [])
	if typeof(transactions_value) == TYPE_ARRAY:
		var transactions: Array = transactions_value
		ledger.replace_transactions(transactions)

	if inventory_root != null:
		var items_value: Variant = save_data.get("inventory_items", [])
		if typeof(items_value) == TYPE_ARRAY:
			var items: Array = items_value
			_restore_existing_item_state(inventory_root, items)

	var fixture_orders_value: Variant = save_data.get("fixture_orders", [])
	if typeof(fixture_orders_value) == TYPE_ARRAY:
		var fixture_orders: Array = fixture_orders_value
		session.replace_fixture_orders(fixture_orders)

	var supplier_orders_value: Variant = save_data.get("supplier_orders", [])
	if typeof(supplier_orders_value) == TYPE_ARRAY:
		var supplier_orders: Array = supplier_orders_value
		session.replace_supplier_orders(supplier_orders)

	var receiving_batches_value: Variant = save_data.get("receiving_batches", [])
	if typeof(receiving_batches_value) == TYPE_ARRAY and session.has_method("replace_receiving_batches"):
		var receiving_batches: Array = receiving_batches_value
		session.replace_receiving_batches(receiving_batches)

	var storage_movements_value: Variant = save_data.get("storage_movements", [])
	if typeof(storage_movements_value) == TYPE_ARRAY and session.has_method("replace_storage_movements"):
		var storage_movements: Array = storage_movements_value
		session.replace_storage_movements(storage_movements)

	var service_tickets_value: Variant = save_data.get("service_tickets", [])
	if typeof(service_tickets_value) == TYPE_ARRAY and session.has_method("replace_service_tickets"):
		var service_tickets: Array = service_tickets_value
		session.replace_service_tickets(service_tickets)

	var management_reviews_value: Variant = save_data.get("management_reviews", [])
	if typeof(management_reviews_value) == TYPE_ARRAY and session.has_method("replace_management_reviews"):
		var management_reviews: Array = management_reviews_value
		session.replace_management_reviews(management_reviews)

	var preorder_deposits_value: Variant = save_data.get("preorder_deposits", [])
	if typeof(preorder_deposits_value) == TYPE_ARRAY and session.has_method("replace_preorder_deposits"):
		var preorder_deposits: Array = preorder_deposits_value
		session.replace_preorder_deposits(preorder_deposits)

	var release_allocations_value: Variant = save_data.get("release_allocations", [])
	if typeof(release_allocations_value) == TYPE_ARRAY and session.has_method("replace_release_allocations"):
		var release_allocations: Array = release_allocations_value
		session.replace_release_allocations(release_allocations)

	var launch_events_value: Variant = save_data.get("launch_events", [])
	if typeof(launch_events_value) == TYPE_ARRAY and session.has_method("replace_launch_events"):
		var launch_events: Array = launch_events_value
		session.replace_launch_events(launch_events)

	var operating_expenses_value: Variant = save_data.get("operating_expenses", [])
	if typeof(operating_expenses_value) == TYPE_ARRAY and session.has_method("replace_operating_expenses"):
		var operating_expenses: Array = operating_expenses_value
		session.replace_operating_expenses(operating_expenses)

	var reputation_events_value: Variant = save_data.get("reputation_events", [])
	if typeof(reputation_events_value) == TYPE_ARRAY and session.has_method("replace_reputation_events"):
		var reputation_events: Array = reputation_events_value
		session.replace_reputation_events(reputation_events)

	var purchased_upgrades_value: Variant = save_data.get("purchased_upgrades", [])
	if typeof(purchased_upgrades_value) == TYPE_ARRAY and session.has_method("replace_purchased_upgrades"):
		var purchased_upgrades: Array = purchased_upgrades_value
		session.replace_purchased_upgrades(purchased_upgrades)

	var purchased_decorations_value: Variant = save_data.get("purchased_decorations", [])
	if typeof(purchased_decorations_value) == TYPE_ARRAY and session.has_method("replace_purchased_decorations"):
		var purchased_decorations: Array = purchased_decorations_value
		session.replace_purchased_decorations(purchased_decorations)

	var hidden_thread_choices_value: Variant = save_data.get("hidden_thread_choices", [])
	if typeof(hidden_thread_choices_value) == TYPE_ARRAY and session.has_method("replace_hidden_thread_choice_records"):
		var hidden_thread_choices: Array = hidden_thread_choices_value
		session.replace_hidden_thread_choice_records(hidden_thread_choices)

	var hidden_thread_consequences_value: Variant = save_data.get("hidden_thread_consequences", [])
	if typeof(hidden_thread_consequences_value) == TYPE_ARRAY and session.has_method("replace_hidden_thread_consequence_events"):
		var hidden_thread_consequences: Array = hidden_thread_consequences_value
		session.replace_hidden_thread_consequence_events(hidden_thread_consequences)

	if session.has_method("replace_hidden_consequence_state"):
		session.replace_hidden_consequence_state(
			int(save_data.get("hidden_supplier_access_score", session.supplier_access_score)),
			int(save_data.get("hidden_customer_trust_score", session.customer_trust_score)),
			int(save_data.get("hidden_inspection_risk_score", session.inspection_risk_score)),
			str(save_data.get("hidden_story_state", session.hidden_story_state))
		)

	return true


func _ensure_array_defaults(data: Dictionary) -> void:
	for key in ARRAY_DEFAULT_KEYS:
		if typeof(data.get(key, [])) != TYPE_ARRAY:
			data[key] = []
		elif not data.has(key):
			data[key] = []


func _ensure_scalar_defaults(data: Dictionary) -> void:
	data["day_number"] = int(data.get("day_number", 1))
	data["day_phase"] = str(data.get("day_phase", StoreSession.DAY_PHASE_SETUP))
	data["cash_cents"] = int(data.get("cash_cents", 0))
	data["is_day_closed"] = bool(data.get("is_day_closed", false))
	data["reputation_score"] = int(data.get("reputation_score", 100))
	data["hidden_supplier_access_score"] = int(data.get("hidden_supplier_access_score", 50))
	data["hidden_customer_trust_score"] = int(data.get("hidden_customer_trust_score", 50))
	data["hidden_inspection_risk_score"] = int(data.get("hidden_inspection_risk_score", 0))
	data["hidden_story_state"] = str(data.get("hidden_story_state", "none"))


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
