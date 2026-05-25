## Deterministic save-reload smoke proof for the first playable store loop.
class_name SaveReloadSmokeRunner
extends Node

const SCENARIO_ID: String = "save_reload_smoke"
const STORE_ID_RAW: String = "retro_games"
const SHELF_SLOT_ID: StringName = &"save_reload_shelf_slot_001"
const SAVE_SLOT: int = 1
const CORRUPT_SLOT: int = 3
const STARTING_CASH: float = 100.0
const SALE_PRICE: float = 42.0
const BASE_PRICE: float = 40.0
const CATEGORY: StringName = &"cartridges"
const ITEM_DEFINITION_ID: String = "save_reload_cart_001"
const ITEM_INSTANCE_ID: StringName = &"save_reload_cart_001_instance"
const RESTOCK_INSTANCE_ID: StringName = &"save_reload_restock_001_instance"
const FLOAT_EPSILON: float = 0.001

var _data_loader: DataLoader
var _economy: EconomySystem
var _inventory: InventorySystem
var _time: TimeSystem
var _store_state: StoreStateManager
var _tutorial: TutorialSystem
var _save_manager: SaveManager
var _register: RegisterInteractable
var _customer: Customer
var _slot: FakeShelfSlot
var _events: Array[Dictionary] = []
var _failures: Array[String] = []
var _failure_signals: Array[Dictionary] = []
var _saved_settings_path: String = ""
var _settings_path_overridden: bool = false


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


## Runs the smoke flow and returns a scenario-report-ready snapshot.
func run() -> Dictionary:
	_reset()
	var result: Dictionary = _run()
	_cleanup()
	return result


func _run() -> Dictionary:
	_prepare_isolated_paths()
	_data_loader = DataLoader.new()
	add_child(_data_loader)
	_data_loader.load_all_content()

	var store_id: StringName = ContentRegistry.resolve(STORE_ID_RAW)
	_check(not store_id.is_empty(), "resolved store id must exist")
	if not _failures.is_empty():
		return _build_result(store_id, {}, {}, {}, {}, false)

	_configure_run_state(store_id)
	_create_systems(store_id)
	_connect_observers()

	var item: ItemInstance = _make_item(ITEM_INSTANCE_ID)
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

	_customer = _make_customer(item, _slot)
	_register = RegisterInteractable.new()
	add_child(_register)

	_customer.advance_to_register()
	EventBus.customer_ready_to_purchase.emit({
		"customer_id": _customer.get_instance_id(),
		"profile_id": "save_reload_customer_profile",
		"profile_name": "Save Reload Customer",
		"desired_item_id": String(ITEM_INSTANCE_ID),
	})
	_check(_customer.is_awaiting_player_checkout(), "customer must wait for checkout")
	_check(_register.can_interact(), "register must accept the controlled customer")

	var cash_before: float = _economy.get_cash()
	var shelf_before: int = _inventory.get_shelf_items_for_store(String(store_id)).size()
	_register.interact()
	var cash_after: float = _economy.get_cash()
	var shelf_after: int = _inventory.get_shelf_items_for_store(String(store_id)).size()

	StoreSessionState.flags[&"stock_shelf"] = true
	StoreSessionState.flags[&"sale_complete"] = true
	GameState.set_flag(&"first_sale_complete", true)

	_check(_signal_index("item_stocked") >= 0, "item_stocked must fire")
	_check(_signal_index("item_sold") >= 0, "item_sold must fire")
	_check(_signal_index("customer_purchased") >= 0, "customer_purchased must fire")
	_check(_signal_index("item_sold") < _signal_index("customer_purchased"), "sale signals must be ordered")
	_check(_slot.remove_count == 1, "visual shelf slot must remove exactly once")
	_check(_inventory.get_item(String(ITEM_INSTANCE_ID)) == null, "sold item must leave inventory")
	_check(shelf_after == shelf_before - 1, "shelf stock must decrease by one")
	_check(_near(cash_after, cash_before + SALE_PRICE), "cash must increase by sale price")

	var save_ok: bool = _save_manager.save_game(SAVE_SLOT)
	_check(save_ok, "save_game must succeed")
	var save_checks: Dictionary = _verify_save_file(store_id, cash_after)

	var guard_checks: Dictionary = _verify_failure_guards()
	var reload_checks: Dictionary = _verify_reload(store_id, cash_after)
	var checkpoint_metadata: Dictionary = {
		"checkpoints": ["store_ui_open", "stock_shelf", "sale_complete", "save_reload"],
	}

	var deltas: Dictionary = {
		"money_delta": cash_after - cash_before,
		"stock_delta": shelf_after - shelf_before,
		"cash_before": cash_before,
		"cash_after": cash_after,
		"shelf_before": shelf_before,
		"shelf_after": shelf_after,
	}
	return _build_result(
		store_id,
		deltas,
		save_checks,
		guard_checks,
		reload_checks,
		_failures.is_empty() and bool(reload_checks.get("ok", false))
	).merged({"report_metadata": checkpoint_metadata}, true)


func _configure_run_state(store_id: StringName) -> void:
	GameManager.set_current_day(1)
	GameManager.current_store_id = store_id
	GameManager.owned_stores = [store_id]
	GameState.set_active_store(store_id)
	GameState.day = 1
	GameState.money = int(STARTING_CASH)
	GameState.set_flag(&"first_sale_complete", false)
	StoreSessionState.reset_new_run()
	StoreSessionState.preopening_complete = true
	StoreSessionState.flags[&"store_ui_open"] = true
	EventBus.active_store_changed.emit(store_id)


func _create_systems(store_id: StringName) -> void:
	_economy = EconomySystem.new()
	add_child(_economy)
	_economy.initialize(STARTING_CASH)

	_inventory = InventorySystem.new()
	add_child(_inventory)
	_inventory.initialize(_data_loader)
	_economy.set_inventory_system(_inventory)

	_time = TimeSystem.new()
	add_child(_time)
	_time.initialize()
	_time.current_day = 1

	_store_state = StoreStateManager.new()
	add_child(_store_state)
	_store_state.initialize(_inventory, _economy)
	_store_state.register_slot_ownership(0, store_id)
	_store_state.set_store_name(store_id, ContentRegistry.get_display_name(store_id))
	_store_state.set_active_store(store_id, false)

	_tutorial = TutorialSystem.new()
	add_child(_tutorial)
	_tutorial.tutorial_completed = true
	_tutorial.tutorial_active = false
	_tutorial.current_step = TutorialSystem.TutorialStep.FINISHED

	_save_manager = SaveManager.new()
	add_child(_save_manager)
	_save_manager.initialize(_economy, _inventory, _time)
	_save_manager.set_store_state_manager(_store_state)
	_save_manager.set_tutorial_system(_tutorial)


func _verify_save_file(store_id: StringName, expected_cash: float) -> Dictionary:
	var path: String = _save_manager._get_slot_path(SAVE_SLOT)
	var raw: Dictionary = _read_json_file(path)
	var metadata: Dictionary = raw.get("save_metadata", {}) as Dictionary
	var slot_index: Dictionary = _save_manager.get_all_slot_metadata()
	var slot_meta: Dictionary = slot_index.get(SAVE_SLOT, {}) as Dictionary
	var checks: Dictionary = {
		"slot": SAVE_SLOT,
		"path": path,
		"file_exists": FileAccess.file_exists(path),
		"slot_index_path": UserDataPaths.slot_index_path(),
		"slot_index_exists": FileAccess.file_exists(UserDataPaths.slot_index_path()),
		"slot_index_has_slot": slot_index.has(SAVE_SLOT),
		"schema_version": int(raw.get(SaveManager.SCHEMA_VERSION_KEY, -1)),
		"legacy_schema_version": int(raw.get(SaveManager.LEGACY_SCHEMA_VERSION_KEY, -1)),
		"metadata": metadata.duplicate(true),
		"slot_metadata": slot_meta.duplicate(true),
	}
	_check(bool(checks["file_exists"]), "save file must exist before reload")
	_check(bool(checks["slot_index_has_slot"]), "slot index must include saved slot")
	_check(
		int(checks["schema_version"]) == SaveManager.CURRENT_SAVE_VERSION,
		"save schema version must be current"
	)
	_check(str(metadata.get("active_store_id", "")) == String(store_id), "active store must persist in metadata")
	_check(_near(float(metadata.get("cash", 0.0)), expected_cash), "metadata cash must match sale result")
	_check(int(metadata.get("day", 0)) == 1, "metadata day must persist")
	return checks


func _verify_failure_guards() -> Dictionary:
	var pre_cash: float = _economy.get_cash()
	var pre_day: int = _time.current_day
	var missing_ok: bool = not _save_manager.load_game(2)
	_write_corrupt_save(CORRUPT_SLOT)
	var corrupt_ok: bool = not _save_manager.load_game(CORRUPT_SLOT)
	var state_recovered: bool = (
		_near(_economy.get_cash(), pre_cash)
		and _time.current_day == pre_day
		and _save_manager.slot_exists(SAVE_SLOT)
	)
	_check(missing_ok, "missing slot must fail load")
	_check(corrupt_ok, "corrupt slot must fail load")
	_check(state_recovered, "failed reload guards must leave state recoverable")
	return {
		"missing_slot_failed": missing_ok,
		"corrupt_slot_failed": corrupt_ok,
		"state_recovered": state_recovered,
		"failure_signals": _failure_signals.duplicate(true),
	}


func _verify_reload(store_id: StringName, expected_cash: float) -> Dictionary:
	var fresh: Dictionary = _create_reload_systems()
	var fresh_manager: SaveManager = fresh["save_manager"] as SaveManager
	var loaded: bool = fresh_manager.load_game(SAVE_SLOT)
	var fresh_economy: EconomySystem = fresh["economy"] as EconomySystem
	var fresh_inventory: InventorySystem = fresh["inventory"] as InventorySystem
	var fresh_time: TimeSystem = fresh["time"] as TimeSystem
	var fresh_tutorial: TutorialSystem = fresh["tutorial"] as TutorialSystem
	var fresh_store_state: StoreStateManager = fresh["store_state"] as StoreStateManager
	var session: Dictionary = StoreSessionState.get_session_snapshot()
	var inventory_save: Dictionary = fresh_inventory.get_save_data()
	var economy_save: Dictionary = fresh_economy.get_save_data()
	var basic_interaction: Dictionary = _perform_post_reload_interaction(fresh_inventory, store_id)
	var checks: Dictionary = {
		"ok": loaded,
		"money_persisted": _near(fresh_economy.get_cash(), expected_cash),
		"day_persisted": fresh_time.current_day == 1,
		"sold_item_absent": fresh_inventory.get_item(String(ITEM_INSTANCE_ID)) == null,
		"empty_shelf_target_persisted": _empty_target_matches(inventory_save, store_id),
		"sale_count_persisted": int(economy_save.get("items_sold_today", 0)) == 1,
		"daily_revenue_persisted": _near(float(economy_save.get("daily_revenue_total", 0.0)), SALE_PRICE),
		"tutorial_completed_persisted": fresh_tutorial.tutorial_completed,
		"session_flags_persisted": bool((session.get("flags", {}) as Dictionary).get(&"sale_complete", false)),
		"preopening_persisted": bool(session.get("preopening_complete", false)),
		"active_store_persisted": fresh_store_state.active_store_id == store_id,
		"post_reload_basic_interaction": basic_interaction,
	}
	for key: String in [
		"ok",
		"money_persisted",
		"day_persisted",
		"sold_item_absent",
		"empty_shelf_target_persisted",
		"sale_count_persisted",
		"daily_revenue_persisted",
		"tutorial_completed_persisted",
		"session_flags_persisted",
		"preopening_persisted",
		"active_store_persisted",
	]:
		_check(bool(checks.get(key, false)), "reload check failed: %s" % key)
	_check(bool(basic_interaction.get("ok", false)), "post-reload interaction must succeed")
	return checks


func _create_reload_systems() -> Dictionary:
	var fresh_economy := EconomySystem.new()
	add_child(fresh_economy)
	fresh_economy.initialize(0.0)

	var fresh_inventory := InventorySystem.new()
	add_child(fresh_inventory)
	fresh_inventory.initialize(_data_loader)
	fresh_economy.set_inventory_system(fresh_inventory)

	var fresh_time := TimeSystem.new()
	add_child(fresh_time)
	fresh_time.initialize()

	var fresh_store_state := StoreStateManager.new()
	add_child(fresh_store_state)
	fresh_store_state.initialize(fresh_inventory, fresh_economy)

	var fresh_tutorial := TutorialSystem.new()
	add_child(fresh_tutorial)

	var fresh_manager := SaveManager.new()
	add_child(fresh_manager)
	fresh_manager.initialize(fresh_economy, fresh_inventory, fresh_time)
	fresh_manager.set_store_state_manager(fresh_store_state)
	fresh_manager.set_tutorial_system(fresh_tutorial)

	return {
		"economy": fresh_economy,
		"inventory": fresh_inventory,
		"time": fresh_time,
		"store_state": fresh_store_state,
		"tutorial": fresh_tutorial,
		"save_manager": fresh_manager,
	}


func _perform_post_reload_interaction(
	inventory: InventorySystem, store_id: StringName
) -> Dictionary:
	var restock_item: ItemInstance = _make_item(RESTOCK_INSTANCE_ID)
	restock_item.current_location = "backroom"
	inventory.add_item(store_id, restock_item)
	var assigned: bool = inventory.assign_to_shelf(
		store_id, RESTOCK_INSTANCE_ID, SHELF_SLOT_ID
	)
	return {
		"ok": assigned and inventory.get_shelf_item(store_id, SHELF_SLOT_ID) != null,
		"action": "restock_after_reload",
		"shelf_slot_id": String(SHELF_SLOT_ID),
	}


func _make_item(instance_id: StringName) -> ItemInstance:
	var definition := ItemDefinition.new()
	definition.id = ITEM_DEFINITION_ID
	definition.item_name = "Memory Lane Quest"
	definition.category = CATEGORY
	definition.base_price = BASE_PRICE
	definition.rarity = "common"
	definition.store_type = StringName(STORE_ID_RAW)
	definition.tags = PackedStringArray(["cozy", "quest", "starter"])
	definition.condition_range = PackedStringArray(["good"])
	_data_loader._items[ITEM_DEFINITION_ID] = definition
	var item: ItemInstance = ItemInstance.create(definition, "good", 0, BASE_PRICE)
	item.instance_id = instance_id
	item.player_set_price = SALE_PRICE
	item.current_location = "backroom"
	return item


func _make_customer(item: ItemInstance, slot: Node) -> Customer:
	var profile := CustomerTypeDefinition.new()
	profile.id = "save_reload_customer_profile"
	profile.customer_name = "Save Reload Customer"
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


func _connect_observers() -> void:
	EventBus.item_stocked.connect(_on_item_stocked)
	EventBus.item_sold.connect(_on_item_sold)
	EventBus.customer_purchased.connect(_on_customer_purchased)
	EventBus.customer_state_changed.connect(_on_customer_state_changed)
	EventBus.save_load_failed.connect(_on_save_load_failed)


func _cleanup() -> void:
	_disconnect(EventBus.item_stocked, _on_item_stocked)
	_disconnect(EventBus.item_sold, _on_item_sold)
	_disconnect(EventBus.customer_purchased, _on_customer_purchased)
	_disconnect(EventBus.customer_state_changed, _on_customer_state_changed)
	_disconnect(EventBus.save_load_failed, _on_save_load_failed)
	_restore_settings_path()
	for child: Node in get_children():
		child.queue_free()


func _reset() -> void:
	_events.clear()
	_failures.clear()
	_failure_signals.clear()
	_saved_settings_path = ""
	_settings_path_overridden = false


func _prepare_isolated_paths() -> void:
	if UserDataPaths != null:
		DirAccess.make_dir_recursive_absolute(UserDataPaths.save_dir())
		DirAccess.make_dir_recursive_absolute(UserDataPaths.backup_dir())
	if Settings != null and UserDataPaths != null:
		_saved_settings_path = Settings.settings_path
		Settings.settings_path = UserDataPaths.settings_path()
		_settings_path_overridden = true


func _restore_settings_path() -> void:
	if _settings_path_overridden and Settings != null:
		Settings.settings_path = _saved_settings_path
	_settings_path_overridden = false


func _build_result(
	store_id: StringName,
	deltas: Dictionary,
	save_checks: Dictionary,
	guard_checks: Dictionary,
	reload_checks: Dictionary,
	ok: bool
) -> Dictionary:
	return {
		"ok": ok,
		"scenario_id": SCENARIO_ID,
		"resolved_store_id": String(store_id),
		"item_id": String(ITEM_INSTANCE_ID),
		"money_delta": float(deltas.get("money_delta", 0.0)),
		"stock_delta": int(deltas.get("stock_delta", 0)),
		"signal_evidence": _events.duplicate(true),
		"save_checks": save_checks.duplicate(true),
		"failure_guards": guard_checks.duplicate(true),
		"reload_checks": reload_checks.duplicate(true),
		"failures": _failures.duplicate(),
	}


func _on_item_stocked(item_id: String, shelf_slot_id: String) -> void:
	_record_event("item_stocked", {"item_id": item_id, "shelf_slot_id": shelf_slot_id})


func _on_item_sold(item_id: String, price: float, category: String) -> void:
	_record_event("item_sold", {"item_id": item_id, "price": price, "category": category})


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
	_record_event("customer_completed", {"leave_reason": String(_customer.get_leave_reason())})


func _on_save_load_failed(slot: int, reason: String) -> void:
	_failure_signals.append({"slot": slot, "reason": reason})


func _record_event(name: String, data: Dictionary) -> void:
	_events.append({"name": name, "index": _events.size(), "data": data})


func _signal_index(name: String) -> int:
	for event: Dictionary in _events:
		if str(event.get("name", "")) == name:
			return int(event.get("index", -1))
	return -1


func _empty_target_matches(inventory_save: Dictionary, store_id: StringName) -> bool:
	var targets_by_store: Dictionary = inventory_save.get("empty_shelf_targets", {}) as Dictionary
	var targets: Dictionary = targets_by_store.get(String(store_id), {}) as Dictionary
	return str(targets.get(String(SHELF_SLOT_ID), "")) == ITEM_DEFINITION_ID


func _write_corrupt_save(slot: int) -> void:
	var file: FileAccess = FileAccess.open(_save_manager._get_slot_path(slot), FileAccess.WRITE)
	if file == null:
		_check(false, "corrupt save fixture must be writable")
		return
	file.store_string("{{corrupt")
	file.close()


func _read_json_file(path: String) -> Dictionary:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed is Dictionary:
		return parsed as Dictionary
	return {}


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _near(actual: float, expected: float) -> bool:
	return absf(actual - expected) <= FLOAT_EPSILON


func _disconnect(signal_ref: Signal, callable: Callable) -> void:
	if signal_ref.is_connected(callable):
		signal_ref.disconnect(callable)
