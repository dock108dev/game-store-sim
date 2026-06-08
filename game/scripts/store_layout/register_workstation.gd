extends "res://scripts/interaction/interactable.gd"
class_name RegisterWorkstation

@export var customer_path: NodePath
@export var customer_manager_path: NodePath
@export var trade_in_customer_path: NodePath
@export var preorder_customer_path: NodePath
@export var service_customer_path: NodePath
@export var receiving_box_path: NodePath
@export var ledger_path: NodePath
@export var store_session_path: NodePath
@export var tax_rate_basis_points: int = 0
@export var default_cash_tender_cents: int = 5000
@export var tender_method: String = "Cash"

var _last_checkout_ui_state: Dictionary = {}


func get_interaction_prompt() -> String:
	var customer := _get_waiting_customer()
	if customer != null:
		var item: Node = customer.get_checkout_item()
		return "Click Ring Up %s" % _get_item_display_name(item)

	var trade_in_customer := _get_waiting_trade_in_customer()
	if trade_in_customer != null:
		var trade_item: Node = trade_in_customer.get_trade_item()
		return "Click Review Trade-In %s" % _get_item_display_name(trade_item)

	var preorder_customer := _get_waiting_preorder_customer()
	if preorder_customer != null:
		return "Click Take Preorder %s" % preorder_customer.get_release_name()

	var service_customer := _get_waiting_service_customer()
	if service_customer != null:
		return "Click Complete %s" % str(service_customer.get("service_name"))

	return "Register Workstation"


func get_interaction_prompt_for_actor(_actor: Node) -> String:
	return get_interaction_prompt()


func interact() -> String:
	return _complete_waiting_sale()


func interact_with_actor(_actor: Node) -> String:
	var customer := _get_waiting_customer()
	if customer != null:
		if _actor != null and _actor.has_method("open_register_checkout"):
			return str(_actor.open_register_checkout(self))
		return _complete_waiting_sale()

	var trade_in_customer := _get_waiting_trade_in_customer()
	if trade_in_customer != null and _actor != null and _actor.has_method("open_trade_in_offer"):
		return str(_actor.open_trade_in_offer(self, trade_in_customer))

	var preorder_customer := _get_waiting_preorder_customer()
	if preorder_customer != null and _actor != null and _actor.has_method("open_register_checkout"):
		return str(_actor.open_register_checkout(self))

	var service_customer := _get_waiting_service_customer()
	if service_customer != null and _actor != null and _actor.has_method("open_register_checkout"):
		return str(_actor.open_register_checkout(self))

	return _complete_waiting_sale()


func has_active_checkout() -> bool:
	var state := get_checkout_ui_state()
	var transaction_type := str(state.get("transaction_type", "idle"))
	return transaction_type == "sale" \
		or transaction_type == "preorder_deposit" \
		or transaction_type == "service"


func get_checkout_ui_state() -> Dictionary:
	var customer := _get_waiting_customer()
	if customer != null:
		return _build_sale_checkout_state(customer)

	var trade_in_customer := _get_waiting_trade_in_customer()
	if trade_in_customer != null:
		return _build_trade_in_referral_state(trade_in_customer)

	var preorder_customer := _get_waiting_preorder_customer()
	if preorder_customer != null:
		return _build_preorder_checkout_state(preorder_customer)

	var service_customer := _get_waiting_service_customer()
	if service_customer != null:
		return _build_service_checkout_state(service_customer)

	if not _last_checkout_ui_state.is_empty():
		return _last_checkout_ui_state.duplicate(true)

	return _build_idle_checkout_state()


func get_last_checkout_ui_state() -> Dictionary:
	return _last_checkout_ui_state.duplicate(true)


func complete_active_checkout() -> String:
	var customer := _get_waiting_customer()
	if customer != null:
		return _complete_sale(customer)

	var preorder_customer := _get_waiting_preorder_customer()
	if preorder_customer != null:
		return _complete_preorder(preorder_customer)

	var service_customer := _get_waiting_service_customer()
	if service_customer != null:
		return _complete_service(service_customer)

	return "No checkout waiting at the register."


func _complete_waiting_sale() -> String:
	var customer := _get_waiting_customer()
	if customer == null:
		return _complete_waiting_trade_in()

	return _complete_sale(customer)


func _complete_sale(customer: SimpleBuyerCustomer) -> String:
	var state := _build_sale_checkout_state(customer)

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

	var message := "Sold %s for $%0.2f. Profit $%0.2f." % [
		str(transaction.get("display_name", "item")),
		int(transaction.get("sale_price_cents", 0)) / 100.0,
		int(transaction.get("profit_cents", 0)) / 100.0,
	]
	_store_completed_checkout_state(state, message)
	return message


func _complete_waiting_trade_in() -> String:
	var customer := _get_waiting_trade_in_customer()
	if customer == null:
		return _complete_waiting_preorder()

	return accept_trade_in(customer)


func accept_trade_in(customer: SimpleTradeInCustomer, offer_cents: int = -1) -> String:
	return _accept_trade_in_with_tender(customer, offer_cents, "cash")


func accept_trade_in_store_credit(customer: SimpleTradeInCustomer, credit_cents: int = -1) -> String:
	return _accept_trade_in_with_tender(customer, credit_cents, "store_credit")


func _accept_trade_in_with_tender(
	customer: SimpleTradeInCustomer,
	offer_cents: int,
	tender_type: String
) -> String:
	if customer == null or not customer.is_waiting_for_trade_in():
		return "No trade-in waiting at the register."

	var item: Node = customer.get_trade_item()
	var ledger := _get_ledger()
	var receiving_box := _get_receiving_box()
	if item == null or ledger == null or receiving_box == null:
		return "Register is not ready to complete a trade-in."

	var final_offer_cents := offer_cents
	if final_offer_cents < 0:
		if tender_type == "store_credit":
			final_offer_cents = customer.get_store_credit_offer_cents()
		else:
			final_offer_cents = customer.get_offer_cents()
	final_offer_cents = maxi(1, final_offer_cents)

	var transaction := ledger.record_trade_in(
		str(customer.get("customer_id")),
		item,
		final_offer_cents,
		tender_type
	)
	if transaction.is_empty():
		return "Register could not record the trade-in."

	item.set("cost_basis_cents", final_offer_cents)
	var acquired_item := customer.complete_trade_in(receiving_box)
	if acquired_item == null:
		return "Register could not receive the trade-in item."

	var store_session := _get_store_session()
	if store_session != null:
		store_session.apply_trade_in(transaction)

	var display_name := str(transaction.get("display_name", "item"))
	if tender_type == "store_credit":
		return "Bought %s trade-in for $%0.2f store credit." % [
			display_name,
			final_offer_cents / 100.0,
		]

	return "Bought %s trade-in for $%0.2f cash." % [display_name, final_offer_cents / 100.0]


func decline_trade_in(customer: SimpleTradeInCustomer) -> String:
	if customer == null or not customer.is_waiting_for_trade_in():
		return "No trade-in waiting at the register."

	if customer.decline_trade_in():
		return "Declined %s trade-in." % _get_item_display_name(customer.get_trade_item())

	return "Could not decline trade-in."


func _complete_waiting_preorder() -> String:
	var customer := _get_waiting_preorder_customer()
	if customer == null:
		return _complete_waiting_service()

	return _complete_preorder(customer)


func _complete_preorder(customer: SimplePreorderCustomer) -> String:
	var state := _build_preorder_checkout_state(customer)
	var ledger := _get_ledger()
	if ledger == null:
		return "Register is not ready to record a preorder."

	var release := customer.get_release()
	var deposit_cents := customer.get_deposit_cents()
	var transaction := ledger.record_preorder_deposit(customer.customer_id, release, deposit_cents)
	if transaction.is_empty():
		return "Register could not record the preorder."

	var store_session := _get_store_session()
	if store_session != null and store_session.has_method("apply_preorder_deposit"):
		store_session.apply_preorder_deposit(transaction)

	customer.complete_preorder()
	var message := "Took %s preorder deposit for %s." % [
		"$%0.2f" % (deposit_cents / 100.0),
		str(transaction.get("display_name", "release")),
	]
	_store_completed_checkout_state(state, message)
	return message


func _complete_waiting_service() -> String:
	var customer := _get_waiting_service_customer()
	if customer == null:
		return "No customer waiting at the register."

	return _complete_service(customer)


func _complete_service(customer: Node) -> String:
	var state := _build_service_checkout_state(customer)
	var ledger := _get_ledger()
	if ledger == null:
		return "Register is not ready to record a service."

	var transaction := ledger.record_service(customer)
	if transaction.is_empty():
		return "Register could not record the service."

	var store_session := _get_store_session()
	if store_session != null and store_session.has_method("apply_service"):
		store_session.apply_service(transaction)

	customer.call("complete_service")
	var message := "Completed %s for %s. Profit $%0.2f." % [
		str(transaction.get("display_name", "service")),
		str(transaction.get("item_name", "item")),
		int(transaction.get("profit_cents", 0)) / 100.0,
	]
	_store_completed_checkout_state(state, message)
	return message


func _build_sale_checkout_state(customer: SimpleBuyerCustomer) -> Dictionary:
	var item: Node = customer.get_checkout_item()
	var product := item.get("product") as ProductDefinition if item != null else null
	var display_name := _get_item_display_name(item)
	var sale_price_cents := int(item.get("current_price_cents")) if item != null else 0
	var cost_basis_cents := int(item.get("cost_basis_cents")) if item != null else 0
	if cost_basis_cents <= 0 and product != null:
		cost_basis_cents = product.cost_basis_cents

	return _build_checkout_state({
		"transaction_type": "sale",
		"title": "Register Checkout",
		"customer_id": str(customer.get("customer_id")),
		"cart_lines": [
			{
				"line_type": "sale",
				"label": display_name,
				"quantity": 1,
				"unit_price_cents": sale_price_cents,
				"line_total_cents": sale_price_cents,
				"cost_basis_cents": cost_basis_cents,
			},
		],
		"subtotal_cents": sale_price_cents,
		"confirmation": "Ready to sell %s." % display_name,
		"sale_confirmation": "Awaiting checkout confirmation.",
	})


func _build_preorder_checkout_state(customer: SimplePreorderCustomer) -> Dictionary:
	var deposit_cents := customer.get_deposit_cents()
	return _build_checkout_state({
		"transaction_type": "preorder_deposit",
		"title": "Preorder Deposit",
		"customer_id": customer.customer_id,
		"cart_lines": [
			{
				"line_type": "preorder_deposit",
				"label": "%s deposit" % customer.get_release_name(),
				"quantity": 1,
				"unit_price_cents": deposit_cents,
				"line_total_cents": deposit_cents,
			},
		],
		"subtotal_cents": deposit_cents,
		"preorder_line": "%s deposit" % customer.get_release_name(),
		"confirmation": "Ready to take preorder deposit.",
		"sale_confirmation": "Deposit is not counted as sale revenue.",
	})


func _build_service_checkout_state(customer: Node) -> Dictionary:
	var price_cents := int(customer.call("get_price_cents")) if customer.has_method("get_price_cents") else 0
	var cost_cents := int(customer.call("get_cost_cents")) if customer.has_method("get_cost_cents") else 0
	var service_name := str(customer.get("service_name"))
	var item_name := str(customer.get("item_name"))
	return _build_checkout_state({
		"transaction_type": "service",
		"title": "Service Checkout",
		"customer_id": str(customer.get("customer_id")),
		"cart_lines": [
			{
				"line_type": "service",
				"label": service_name,
				"quantity": 1,
				"unit_price_cents": price_cents,
				"line_total_cents": price_cents,
				"service_cost_cents": cost_cents,
				"profit_cents": price_cents - cost_cents,
			},
		],
		"subtotal_cents": price_cents,
		"service_line": "%s for %s" % [service_name, item_name],
		"confirmation": "Ready to complete service.",
		"sale_confirmation": "Service revenue will be tracked separately.",
	})


func _build_trade_in_referral_state(customer: SimpleTradeInCustomer) -> Dictionary:
	var item: Node = customer.get_trade_item()
	return _build_checkout_state({
		"transaction_type": "trade_in_referral",
		"title": "Trade-In Appraisal",
		"customer_id": str(customer.get("customer_id")),
		"cart_lines": [],
		"subtotal_cents": 0,
		"confirmation": "Open trade-in appraisal for %s." % _get_item_display_name(item),
		"sale_confirmation": "Trade-ins use the appraisal panel.",
	})


func _build_idle_checkout_state() -> Dictionary:
	return _build_checkout_state({
		"transaction_type": "idle",
		"title": "Register Checkout",
		"customer_id": "",
		"cart_lines": [],
		"subtotal_cents": 0,
		"confirmation": "No checkout waiting.",
		"sale_confirmation": "",
	})


func _build_checkout_state(input: Dictionary) -> Dictionary:
	var subtotal_cents := int(input.get("subtotal_cents", 0))
	var tax_cents := int(round(float(subtotal_cents * maxi(0, tax_rate_basis_points)) / 10000.0))
	var total_cents := subtotal_cents + tax_cents
	var tendered_cents := total_cents
	if str(input.get("transaction_type", "")) == "sale" and tender_method.to_lower() == "cash":
		tendered_cents = maxi(total_cents, default_cash_tender_cents)

	var state := input.duplicate(true)
	state["surface"] = "register"
	state["subtotal_cents"] = subtotal_cents
	state["tax_cents"] = tax_cents
	state["total_cents"] = total_cents
	state["tender_method"] = tender_method
	state["tendered_cents"] = tendered_cents
	state["change_due_cents"] = maxi(0, tendered_cents - total_cents)
	state["return_placeholder"] = "Returns: not available in this build."
	state["transaction_feedback"] = str(state.get("confirmation", ""))
	state["completed"] = false
	state["has_active_checkout"] = has_checkout_type(str(state.get("transaction_type", "")))
	return state


func has_checkout_type(transaction_type: String) -> bool:
	return transaction_type == "sale" \
		or transaction_type == "preorder_deposit" \
		or transaction_type == "service"


func _store_completed_checkout_state(state: Dictionary, message: String) -> void:
	var completed_state := state.duplicate(true)
	completed_state["completed"] = true
	completed_state["confirmation"] = message
	completed_state["sale_confirmation"] = message
	completed_state["transaction_feedback"] = message
	completed_state["has_active_checkout"] = false
	_last_checkout_ui_state = completed_state


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


func _get_waiting_preorder_customer() -> SimplePreorderCustomer:
	if preorder_customer_path.is_empty():
		return null

	var customer := get_node_or_null(preorder_customer_path) as SimplePreorderCustomer
	if customer != null and customer.has_method("is_waiting_for_preorder") and customer.is_waiting_for_preorder():
		return customer

	return null


func _get_waiting_service_customer() -> Node:
	if service_customer_path.is_empty():
		return null

	var customer := get_node_or_null(service_customer_path)
	if (
		customer != null
		and customer.has_method("is_waiting_for_service")
		and bool(customer.call("is_waiting_for_service"))
	):
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
