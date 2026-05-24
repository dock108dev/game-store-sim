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


func test_load_save_data_preserves_preopening_migration_defaults() -> void:
	StoreSessionState.load_save_data({"day": 1})
	assert_false(StoreSessionState.preopening_complete)

	StoreSessionState.load_save_data({"day": 2})
	assert_true(StoreSessionState.preopening_complete)

	StoreSessionState.load_save_data({"day": 1, "preopening_complete": true})
	assert_true(StoreSessionState.preopening_complete)
