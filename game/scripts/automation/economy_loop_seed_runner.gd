## Deterministic proof runner for the seeded economy-loop scenario.
class_name EconomyLoopSeedRunner
extends Node

const SCENARIO_ID: String = "economy_loop_seed_001"
const STORE_ID_RAW: String = "retro_games"
const SHELF_SLOT_ID: StringName = &"seed_shelf_slot_001"
const STARTING_CASH: float = 100.0
const SALE_PRICE: float = 42.0
const BASE_PRICE: float = 40.0
const CATEGORY: StringName = &"cartridges"
const ITEM_DEFINITION_ID: String = "loop_seed_cart_001"
const ITEM_INSTANCE_ID: StringName = &"loop_seed_cart_001_instance"
const FLOAT_EPSILON: float = 0.001

var _data_loader: DataLoader = null
var _economy: EconomySystem = null
var _inventory: InventorySystem = null
var _register: RegisterInteractable = null
var _customer: Customer = null
var _slot: FakeShelfSlot = null
var _events: Array[Dictionary] = []
var _failures: Array[String] = []


class FakeShelfSlot:
	extends Node3D

	var slot_id: StringName = &""
	var held_item_id: StringName = &""
	var remove_count: int = 0

	func remove_item() -> StringName:
		var removed: StringName = held_item_id
		held_item_id = &""
		remove_count += 1
		return removed

	func is_occupied() -> bool:
		return not held_item_id.is_empty()


## Runs the seeded sale proof and returns a scenario-report-ready snapshot.
func run() -> Dictionary:
	_reset()
	var result: Dictionary = _run()
	_cleanup()
	return result


func _run() -> Dictionary:
	_data_loader = DataLoader.new()
	add_child(_data_loader)
	_data_loader.load_all_content()

	var store_id: StringName = ContentRegistry.resolve(STORE_ID_RAW)
	_check(not store_id.is_empty(), "resolved store id must exist")
	_check(
		store_id != EconomySystem.STORE_SESSION_COUNTER_ONLY_STORE_ID,
		"resolved store id must credit economy revenue"
	)
	if not _failures.is_empty():
		return _build_result(store_id, null, {}, {}, false)

	_configure_day(store_id)
	_connect_observers()

	_economy = EconomySystem.new()
	add_child(_economy)
	_economy.initialize(STARTING_CASH)

	_inventory = InventorySystem.new()
	add_child(_inventory)
	_inventory.initialize(_data_loader)
	_economy.set_inventory_system(_inventory)

	var item: ItemInstance = _make_item()
	var stock_before: int = _inventory.get_stock(store_id).size()
	_inventory.add_item(store_id, item)
	_check(_inventory.get_stock(store_id).size() == stock_before + 1, "item must seed into stock")

	_slot = FakeShelfSlot.new()
	_slot.slot_id = SHELF_SLOT_ID
	_slot.held_item_id = ITEM_INSTANCE_ID
	add_child(_slot)

	var assigned: bool = _inventory.assign_to_shelf(store_id, ITEM_INSTANCE_ID, SHELF_SLOT_ID)
	_check(assigned, "seeded item must assign to shelf")
	_check(_inventory.get_shelf_item(store_id, SHELF_SLOT_ID) == item, "shelf must hold seeded item")
	_check(not _slot.held_item_id.is_empty(), "visual shelf slot must start occupied")

	_customer = _make_customer(item, _slot)
	_register = RegisterInteractable.new()
	add_child(_register)

	_customer.advance_to_register()
	EventBus.customer_ready_to_purchase.emit({
		"customer_id": _customer.get_instance_id(),
		"profile_id": "loop_seed_customer_profile",
		"profile_name": "Seed Loop Customer",
		"desired_item_id": String(ITEM_INSTANCE_ID),
	})
	_check(_customer.is_awaiting_player_checkout(), "customer must wait for manual checkout")
	_check(_register.can_interact(), "register must accept the controlled customer")

	var cash_before: float = _economy.get_cash()
	var shelf_before: int = _inventory.get_shelf_items_for_store(String(store_id)).size()
	_register.interact()
	var cash_after: float = _economy.get_cash()
	var shelf_after: int = _inventory.get_shelf_items_for_store(String(store_id)).size()
	var save_data: Dictionary = _economy.get_save_data()
	var inventory_save: Dictionary = _inventory.get_save_data()

	_check(_signal_index("item_sold") >= 0, "item_sold must fire")
	_check(_signal_index("customer_purchased") >= 0, "customer_purchased must fire")
	_check(
		_signal_index("item_sold") < _signal_index("customer_purchased"),
		"item_sold must precede customer_purchased"
	)
	_check(
		_signal_index("customer_purchased") < _signal_index("customer_completed"),
		"customer completion must follow purchase"
	)
	_check(_slot.remove_count == 1, "visual shelf slot must remove exactly once")
	_check(not _slot.is_occupied(), "visual shelf slot must be empty after sale")
	_check(_inventory.get_item(String(ITEM_INSTANCE_ID)) == null, "sold item must leave inventory")
	_check(_inventory.get_shelf_item(store_id, SHELF_SLOT_ID) == null, "shelf assignment must clear")
	_check(_empty_target_matches(inventory_save, store_id), "empty shelf target must be remembered")
	_check(shelf_after == shelf_before - 1, "shelf stock must decrease by one")
	_check(_inventory.get_stock(store_id).size() >= 0, "stock must never be negative")
	_check(cash_after >= 0.0, "cash must never be negative")
	_check(_near(cash_after, cash_before + SALE_PRICE), "cash must increase by sale price")
	_check(_near(float(save_data.get("daily_revenue_total", 0.0)), SALE_PRICE), "daily revenue must match sale")
	_check(int(save_data.get("items_sold_today", 0)) == 1, "items sold today must be one")
	_check(_daily_summary_matches(_economy.get_daily_summary()), "daily summary must show one sale")
	_check(_save_transactions_match(save_data), "save transactions must show one sale")
	_check(
		_near(_economy.get_store_daily_revenue(String(store_id)), SALE_PRICE),
		"store revenue must use the resolved store id"
	)
	_check(_customer.get_leave_reason() == &"purchase_complete", "customer must complete purchase")

	var duplicate_cash: float = _economy.get_cash()
	var duplicate_event_count: int = _events.size()
	_register.interact()
	_check(_near(_economy.get_cash(), duplicate_cash), "duplicate interaction must not add cash")
	_check(_events.size() == duplicate_event_count, "duplicate interaction must not emit sale signals")

	var deltas: Dictionary = {
		"money_delta": cash_after - cash_before,
		"stock_delta": shelf_after - shelf_before,
		"cash_before": cash_before,
		"cash_after": cash_after,
		"shelf_before": shelf_before,
		"shelf_after": shelf_after,
	}
	return _build_result(store_id, item, deltas, save_data, _failures.is_empty())


func _configure_day(store_id: StringName) -> void:
	GameManager.set_current_day(1)
	GameManager.current_store_id = store_id
	GameState.set_flag(&"first_sale_complete", false)
	EventBus.active_store_changed.emit(store_id)


func _connect_observers() -> void:
	EventBus.item_stocked.connect(_on_item_stocked)
	EventBus.item_sold.connect(_on_item_sold)
	EventBus.customer_purchased.connect(_on_customer_purchased)
	EventBus.customer_state_changed.connect(_on_customer_state_changed)


func _cleanup() -> void:
	_disconnect(EventBus.item_stocked, _on_item_stocked)
	_disconnect(EventBus.item_sold, _on_item_sold)
	_disconnect(EventBus.customer_purchased, _on_customer_purchased)
	_disconnect(EventBus.customer_state_changed, _on_customer_state_changed)
	for child: Node in get_children():
		child.queue_free()


func _reset() -> void:
	_events.clear()
	_failures.clear()


func _make_item() -> ItemInstance:
	var definition := ItemDefinition.new()
	definition.id = ITEM_DEFINITION_ID
	definition.item_name = "Pixel Pantry Quest"
	definition.category = CATEGORY
	definition.base_price = BASE_PRICE
	definition.rarity = "common"
	definition.store_type = StringName(STORE_ID_RAW)
	definition.tags = PackedStringArray(["cozy", "quest", "starter"])
	definition.condition_range = PackedStringArray(["good"])
	var item: ItemInstance = ItemInstance.create(definition, "good", 0, BASE_PRICE)
	item.instance_id = ITEM_INSTANCE_ID
	item.player_set_price = SALE_PRICE
	item.current_location = "backroom"
	return item


func _make_customer(item: ItemInstance, slot: Node) -> Customer:
	var profile := CustomerTypeDefinition.new()
	profile.id = "loop_seed_customer_profile"
	profile.customer_name = "Seed Loop Customer"
	profile.budget_range = [SALE_PRICE, SALE_PRICE]
	profile.patience = 1.0
	profile.price_sensitivity = 0.5
	profile.preferred_categories = PackedStringArray([String(CATEGORY)])
	profile.preferred_tags = PackedStringArray(["cozy"])
	profile.condition_preference = "good"
	profile.browse_time_range = [1.0, 1.0]
	profile.purchase_probability_base = 1.0
	profile.impulse_buy_chance = 0.0
	profile.max_price_to_market_ratio = 1.0
	profile.mood_tags = PackedStringArray(["focused"])
	var customer: Customer = preload("res://game/scenes/characters/customer.tscn").instantiate()
	add_child(customer)
	customer.profile = profile
	customer.patience_timer = 120.0
	customer._desired_item = item
	customer._desired_item_slot = slot
	customer._use_waypoint_fallback = true
	customer._fallback_arrived = true
	return customer


func _daily_summary_matches(summary: Dictionary) -> bool:
	return (
		_near(float(summary.get("total_revenue", 0.0)), SALE_PRICE)
		and _near(float(summary.get("total_expenses", 0.0)), 0.0)
		and _near(float(summary.get("net_profit", 0.0)), SALE_PRICE)
		and int(summary.get("transaction_count", 0)) == 1
		and int(summary.get("items_sold", 0)) == 1
	)


func _save_transactions_match(save_data: Dictionary) -> bool:
	var transactions: Array = save_data.get("daily_transactions", [])
	if transactions.size() != 1:
		return false
	var txn: Dictionary = transactions[0] as Dictionary
	return (
		_near(float(txn.get("amount", 0.0)), SALE_PRICE)
		and int(txn.get("day", 0)) == 1
		and int(txn.get("type", -1)) == EconomySystem.TransactionType.REVENUE
		and int(txn.get("timestamp", -1)) == 0
	)


func _empty_target_matches(inventory_save: Dictionary, store_id: StringName) -> bool:
	var targets_by_store: Dictionary = inventory_save.get("empty_shelf_targets", {}) as Dictionary
	var targets: Dictionary = targets_by_store.get(String(store_id), {}) as Dictionary
	return str(targets.get(String(SHELF_SLOT_ID), "")) == ITEM_DEFINITION_ID


func _build_result(
	store_id: StringName,
	item: ItemInstance,
	deltas: Dictionary,
	save_data: Dictionary,
	ok: bool
) -> Dictionary:
	return {
		"ok": ok,
		"scenario_id": SCENARIO_ID,
		"resolved_store_id": String(store_id),
		"item_id": String(ITEM_INSTANCE_ID if item == null else item.instance_id),
		"money_delta": float(deltas.get("money_delta", 0.0)),
		"stock_delta": int(deltas.get("stock_delta", 0)),
		"customer_outcome": String(_customer.get_leave_reason()) if _customer != null else "",
		"signal_evidence": _events.duplicate(true),
		"economy_save_data": save_data.duplicate(true),
		"setup_guards": {
			"desired_item_present": item != null,
			"shelf_slot_present": _slot != null,
			"duplicate_attempt_blocked": _duplicate_attempt_blocked(),
		},
		"failures": _failures.duplicate(),
	}


func _duplicate_attempt_blocked() -> bool:
	return _events.size() >= 4 and _signal_count("customer_purchased") == 1


func _on_item_stocked(item_id: String, shelf_slot_id: String) -> void:
	_record_event("item_stocked", {
		"item_id": item_id,
		"shelf_slot_id": shelf_slot_id,
	})


func _on_item_sold(item_id: String, price: float, category: String) -> void:
	_record_event("item_sold", {
		"item_id": item_id,
		"price": price,
		"category": category,
	})


func _on_customer_purchased(
	store_id: StringName,
	item_id: StringName,
	price: float,
	customer_id: StringName
) -> void:
	_record_event("customer_purchased", {
		"store_id": String(store_id),
		"item_id": String(item_id),
		"price": price,
		"customer_id": String(customer_id),
	})


func _on_customer_state_changed(customer: Node, new_state: int) -> void:
	if customer != _customer or new_state != Customer.State.LEAVING:
		return
	_record_event("customer_completed", {
		"leave_reason": String(_customer.get_leave_reason()),
	})


func _record_event(name: String, data: Dictionary) -> void:
	_events.append({
		"name": name,
		"index": _events.size(),
		"data": data,
	})


func _signal_index(name: String) -> int:
	for event: Dictionary in _events:
		if str(event.get("name", "")) == name:
			return int(event.get("index", -1))
	return -1


func _signal_count(name: String) -> int:
	var count: int = 0
	for event: Dictionary in _events:
		if str(event.get("name", "")) == name:
			count += 1
	return count


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _near(actual: float, expected: float) -> bool:
	return absf(actual - expected) <= FLOAT_EPSILON


func _disconnect(signal_ref: Signal, callable: Callable) -> void:
	if signal_ref.is_connected(callable):
		signal_ref.disconnect(callable)
