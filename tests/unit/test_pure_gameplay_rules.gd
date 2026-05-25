## Focused unit coverage for pure gameplay rule contracts.
extends GutTest


const STORE_ID: StringName = &"rule_store"
const ITEM_ID: String = "rule_item"

var _economy: EconomySystem
var _inventory: InventorySystem
var _data_loader: DataLoader
var _objective_payloads: Array[Dictionary] = []
var _objective_updates: Array[Dictionary] = []


func before_each() -> void:
	_economy = EconomySystem.new()
	add_child_autofree(_economy)
	_economy._current_cash = 100.0

	_data_loader = DataLoader.new()
	add_child_autofree(_data_loader)
	_register_test_item()
	_inventory = InventorySystem.new()
	add_child_autofree(_inventory)
	_inventory.initialize(_data_loader)

	_objective_payloads = []
	_objective_updates = []
	if not EventBus.objective_changed.is_connected(_on_objective_changed):
		EventBus.objective_changed.connect(_on_objective_changed)
	if not EventBus.objective_updated.is_connected(_on_objective_updated):
		EventBus.objective_updated.connect(_on_objective_updated)
	_reset_objective_director()


func after_each() -> void:
	if EventBus.objective_changed.is_connected(_on_objective_changed):
		EventBus.objective_changed.disconnect(_on_objective_changed)
	if EventBus.objective_updated.is_connected(_on_objective_updated):
		EventBus.objective_updated.disconnect(_on_objective_updated)
	_reset_objective_director()


func test_money_deltas_classification_and_non_negative_rules() -> void:
	_economy.add_cash(40.0, "sale")
	assert_almost_eq(_economy.get_cash(), 140.0, 0.01)

	assert_true(_economy.deduct_cash(25.0, "supply order"))
	assert_almost_eq(_economy.get_cash(), 115.0, 0.01)

	assert_false(_economy.deduct_cash(500.0, "too expensive"))
	assert_almost_eq(
		_economy.get_cash(), 115.0, 0.01,
		"Rejected deductions must leave cash non-negative and unchanged"
	)

	_economy.add_cash(-10.0, "invalid credit")
	assert_false(_economy.deduct_cash(-5.0, "invalid debit"))
	assert_almost_eq(
		_economy.get_cash(), 115.0, 0.01,
		"Negative transaction inputs must not invert signs or change cash"
	)

	var summary: Dictionary = _economy.get_daily_summary()
	assert_almost_eq(float(summary.get("total_revenue", 0.0)), 40.0, 0.01)
	assert_almost_eq(float(summary.get("total_expenses", 0.0)), 25.0, 0.01)
	assert_almost_eq(float(summary.get("net_profit", 0.0)), 15.0, 0.01)

	var history: Array[Dictionary] = _economy.transaction_history
	assert_eq(history.size(), 2)
	assert_eq(
		int(history[0].get("type", -1)),
		EconomySystem.TransactionType.REVENUE
	)
	assert_almost_eq(float(history[0].get("amount", 0.0)), 40.0, 0.01)
	assert_eq(
		int(history[1].get("type", -1)),
		EconomySystem.TransactionType.EXPENSE
	)
	assert_almost_eq(float(history[1].get("amount", 0.0)), 25.0, 0.01)


func test_inventory_add_remove_assign_unassign_and_stock_counts() -> void:
	var first_item: ItemInstance = _make_item()
	var second_item: ItemInstance = _make_item()

	_inventory.add_item(STORE_ID, first_item)
	_inventory.add_item(STORE_ID, second_item)
	assert_eq(_inventory.get_item_count(), 2)
	assert_eq(_inventory.get_stock(STORE_ID).size(), 2)
	assert_eq(_inventory.get_backroom_items_for_store(String(STORE_ID)).size(), 2)

	assert_true(
		_inventory.assign_to_shelf(
			STORE_ID, first_item.instance_id, &"front_slot"
		)
	)
	assert_eq(
		_inventory.get_shelf_item(STORE_ID, &"front_slot"),
		first_item
	)
	assert_eq(_inventory.get_shelf_items_for_store(String(STORE_ID)).size(), 1)
	assert_eq(_inventory.get_backroom_items_for_store(String(STORE_ID)).size(), 1)

	_inventory.move_item(String(first_item.instance_id), "backroom")
	assert_null(_inventory.get_shelf_item(STORE_ID, &"front_slot"))
	assert_eq(_inventory.get_shelf_items_for_store(String(STORE_ID)).size(), 0)
	assert_eq(_inventory.get_backroom_items_for_store(String(STORE_ID)).size(), 2)

	assert_true(_inventory.remove_item(String(second_item.instance_id)))
	assert_eq(_inventory.get_item_count(), 1)
	assert_eq(_inventory.get_stock(STORE_ID).size(), 1)
	assert_false(_inventory.remove_item(String(second_item.instance_id)))
	assert_eq(
		_inventory.get_item_count(), 1,
		"Removing a missing item must not drive stock negative"
	)


func test_objective_state_transitions_emit_expected_payloads() -> void:
	EventBus.day_started.emit(1)
	assert_eq(
		_last_objective_text(),
		"Read Vic's morning note",
		"Day 1 starts with the pre-chain note objective"
	)

	EventBus.manager_note_dismissed.emit("vic_day01")
	assert_eq(_last_objective_text(), "Talk to the customer at the register.")

	EventBus.customer_interacted.emit(null)
	assert_eq(_last_objective_text(), "Check the back room delivery.")

	EventBus.placement_mode_entered.emit()
	assert_eq(_last_objective_text(), "Stock the starter display table.")

	EventBus.item_stocked.emit("starter_item", "front_slot")
	assert_eq(_last_objective_text(), "Close the day at the register.")

	var last_update: Dictionary = _objective_updates[_objective_updates.size() - 1]
	assert_eq(last_update.get("next_action", ""), "Press F4 to end the day")
	assert_eq(last_update.get("input_hint", ""), "F4")
	assert_eq(
		ObjectiveDirector._day1_step_index,
		ObjectiveDirector.DAY1_STEP_CLOSE_DAY,
		"The objective chain should end at the close-day state"
	)


func test_save_schema_migration_handles_old_and_current_payloads() -> void:
	var save_manager := SaveManager.new()
	add_child_autofree(save_manager)

	var old_payload: Dictionary = {
		SaveManager.SCHEMA_VERSION_KEY: 1,
		SaveManager.LEGACY_SCHEMA_VERSION_KEY: 1,
		"owned_stores": ["retro_games"],
		"save_metadata": {
			"day": 2,
			"cash": 175.0,
			"store_type": "retro_games",
		},
		"economy": {"player_cash": 175.0},
	}
	var old_result: Dictionary = save_manager.migrate_save_data(old_payload)
	assert_true(bool(old_result.get("ok", false)))
	var migrated: Dictionary = old_result.get("data", {}) as Dictionary
	assert_eq(
		int(migrated.get(SaveManager.SCHEMA_VERSION_KEY, 0)),
		SaveManager.CURRENT_SAVE_VERSION
	)
	assert_eq(
		int(migrated.get(SaveManager.LEGACY_SCHEMA_VERSION_KEY, 0)),
		SaveManager.CURRENT_SAVE_VERSION
	)
	assert_false(migrated.has("owned_stores"))
	assert_eq(
		(migrated.get("owned_slots", {}) as Dictionary).get("0", ""),
		"retro_games"
	)
	assert_eq(
		(migrated.get("save_metadata", {}) as Dictionary).get(
			"active_store_id", ""
		),
		"retro_games"
	)
	assert_has(migrated, "reputation")

	var current_payload: Dictionary = {
		SaveManager.SCHEMA_VERSION_KEY: SaveManager.CURRENT_SAVE_VERSION,
		SaveManager.LEGACY_SCHEMA_VERSION_KEY: SaveManager.CURRENT_SAVE_VERSION,
		"owned_slots": {"0": "retro_games"},
		"save_metadata": {"day": 5, "cash": 300.0},
		"reputation": {"scores": {}, "tiers": {}, "tier_locks": {}},
	}
	var current_result: Dictionary = save_manager.migrate_save_data(current_payload)
	assert_true(bool(current_result.get("ok", false)))
	var current_migrated: Dictionary = current_result.get("data", {}) as Dictionary
	assert_eq(
		int(current_migrated.get(SaveManager.SCHEMA_VERSION_KEY, 0)),
		SaveManager.CURRENT_SAVE_VERSION
	)
	assert_eq(
		(current_migrated.get("owned_slots", {}) as Dictionary).get("0", ""),
		"retro_games"
	)
	assert_almost_eq(
		float(
			(current_migrated.get("save_metadata", {}) as Dictionary).get(
				"cash", 0.0
			)
		),
		300.0,
		0.01
	)


func _register_test_item() -> void:
	var item_definition := ItemDefinition.new()
	item_definition.id = ITEM_ID
	item_definition.item_name = "Rule Item"
	item_definition.store_type = STORE_ID
	item_definition.category = &"games"
	item_definition.base_price = 20.0
	item_definition.rarity = "common"
	_data_loader._items[ITEM_ID] = item_definition


func _make_item() -> ItemInstance:
	var definition: ItemDefinition = _data_loader.get_item(ITEM_ID)
	var item: ItemInstance = ItemInstance.create(
		definition, "good", 1, definition.base_price
	)
	item.current_location = "backroom"
	return item


func _on_objective_changed(payload: Dictionary) -> void:
	_objective_payloads.append(payload.duplicate(true))


func _on_objective_updated(payload: Dictionary) -> void:
	_objective_updates.append(payload.duplicate(true))


func _last_objective_text() -> String:
	assert_gt(_objective_payloads.size(), 0, "Expected objective_changed emit")
	var payload: Dictionary = _objective_payloads[_objective_payloads.size() - 1]
	return str(payload.get("text", payload.get("objective", "")))


func _reset_objective_director() -> void:
	ObjectiveDirector._current_day = 0
	ObjectiveDirector._stocked = false
	ObjectiveDirector._sold = false
	ObjectiveDirector._loop_completed = false
	ObjectiveDirector._loop_completed_today = false
	ObjectiveDirector._day1_step_index = -1
	ObjectiveDirector._waiting_for_note_dismiss = false
	ObjectiveDirector._last_payload_hash = ""
