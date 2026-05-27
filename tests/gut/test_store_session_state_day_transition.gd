extends GutTest


func before_each() -> void:
	StoreSessionState.reset_new_run()


func after_each() -> void:
	StoreSessionState.reset_new_run()


func test_advance_day_resets_daily_state_and_preserves_run_state() -> void:
	StoreSessionState.cash = 42
	StoreSessionState.reputation = 3
	StoreSessionState.daily_reputation_delta = 2
	StoreSessionState.daily_cash_delta = 12
	StoreSessionState.manager_trust = 4
	StoreSessionState.hidden_thread_score = 1
	StoreSessionState.flags[&"choice_clean_exchange"] = true
	StoreSessionState.completed_events.append(&"opening_customer")
	StoreSessionState.daily_events_resolved.append(&"opening_customer")
	StoreSessionState.hidden_thread_signals_seen.append(&"warm_console")
	StoreSessionState.preopening_complete = true
	StoreSessionState.carrying_stock = true
	StoreSessionState.set_input_mode(StoreSessionState.INPUT_MODE_DAY_SUMMARY)

	StoreSessionState.advance_day()

	assert_eq(StoreSessionState.day, 2)
	assert_eq(StoreSessionState.daily_reputation_delta, 0)
	assert_eq(StoreSessionState.daily_cash_delta, 0)
	assert_true(StoreSessionState.daily_events_resolved.is_empty())
	assert_eq(StoreSessionState.input_mode, StoreSessionState.INPUT_MODE_GAMEPLAY)
	assert_false(StoreSessionState.carrying_stock)
	assert_eq(StoreSessionState.cash, 42)
	assert_eq(StoreSessionState.reputation, 3)
	assert_eq(StoreSessionState.manager_trust, 4)
	assert_eq(StoreSessionState.hidden_thread_score, 1)
	assert_true(StoreSessionState.flags.has(&"choice_clean_exchange"))
	assert_true(StoreSessionState.completed_events.has(&"opening_customer"))
	assert_true(StoreSessionState.hidden_thread_signals_seen.has(&"warm_console"))
	assert_true(StoreSessionState.preopening_complete)


func test_advance_day_clears_carried_stock_signal() -> void:
	StoreSessionState.carrying_stock = true
	watch_signals(EventBus)

	StoreSessionState.advance_day()

	assert_signal_emitted_with_parameters(EventBus, "store_carry_changed", [""])


func test_load_save_data_preserves_preopening_migration_defaults() -> void:
	StoreSessionState.load_save_data({"day": 1})
	assert_false(StoreSessionState.preopening_complete)

	StoreSessionState.load_save_data({"day": 2})
	assert_true(StoreSessionState.preopening_complete)

	StoreSessionState.load_save_data({"day": 1, "preopening_complete": true})
	assert_true(StoreSessionState.preopening_complete)


func test_load_save_data_syncs_carried_stock_signal() -> void:
	watch_signals(EventBus)

	StoreSessionState.load_save_data({"day": 1, "carrying_stock": true})

	assert_signal_emitted_with_parameters(
		EventBus,
		"store_carry_changed",
		["Starter Stock Box"]
	)

	StoreSessionState.load_save_data({"day": 1, "carrying_stock": false})

	assert_eq(get_signal_parameters(EventBus, "store_carry_changed", 1), [""])


func test_session_snapshot_exposes_copy_safe_progress_state() -> void:
	StoreSessionState.day = 4
	StoreSessionState.cash = 75
	StoreSessionState.reputation = 6
	StoreSessionState.daily_reputation_delta = 2
	StoreSessionState.daily_cash_delta = 25
	StoreSessionState.manager_trust = 3
	StoreSessionState.hidden_thread_score = 1
	StoreSessionState.flags[&"choice_clean_exchange"] = true
	StoreSessionState.completed_events.append(&"opening_customer")
	StoreSessionState.daily_events_resolved.append(&"opening_customer")
	StoreSessionState.hidden_thread_signals_seen.append(&"warm_console")
	StoreSessionState.preopening_complete = true
	StoreSessionState.carrying_stock = true
	StoreSessionState.set_input_mode(StoreSessionState.INPUT_MODE_CUSTOMER_RESULT)

	var snapshot: Dictionary = StoreSessionState.get_session_snapshot()
	assert_eq(int(snapshot.get("day", -1)), 4)
	assert_eq(int(snapshot.get("cash", -1)), 75)
	assert_eq(int(snapshot.get("reputation", -1)), 6)
	assert_eq(int(snapshot.get("daily_reputation_delta", -1)), 2)
	assert_eq(int(snapshot.get("daily_cash_delta", -1)), 25)
	assert_eq(int(snapshot.get("manager_trust", -1)), 3)
	assert_eq(int(snapshot.get("hidden_thread_score", -1)), 1)
	assert_eq(str(snapshot.get("input_mode_name", "")), "customer_result")
	assert_true(bool(snapshot.get("preopening_complete", false)))
	assert_true(bool(snapshot.get("carrying_stock", false)))
	assert_true(bool(snapshot.get("has_carry", false)))
	assert_eq(int(snapshot.get("carried_quantity", 0)), 1)

	var flags: Dictionary = snapshot.get("flags", {}) as Dictionary
	flags[&"choice_clean_exchange"] = false
	assert_true(bool(StoreSessionState.flags.get(&"choice_clean_exchange", false)))
	var completed: Array = snapshot.get("completed_events", []) as Array
	completed.clear()
	assert_true(StoreSessionState.completed_events.has(&"opening_customer"))
