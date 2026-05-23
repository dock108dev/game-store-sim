extends GutTest


func before_each() -> void:
	BetaRunState.reset_new_run()


func after_each() -> void:
	BetaRunState.reset_new_run()


func test_advance_day_resets_daily_state_and_preserves_run_state() -> void:
	BetaRunState.cash = 42
	BetaRunState.reputation = 3
	BetaRunState.daily_reputation_delta = 2
	BetaRunState.daily_cash_delta = 12
	BetaRunState.manager_trust = 4
	BetaRunState.hidden_thread_score = 1
	BetaRunState.flags[&"choice_clean_exchange"] = true
	BetaRunState.completed_events.append(&"opening_customer")
	BetaRunState.daily_events_resolved.append(&"opening_customer")
	BetaRunState.hidden_thread_signals_seen.append(&"warm_console")
	BetaRunState.preopening_complete = true
	BetaRunState.carrying_stock = true
	BetaRunState.set_input_mode(BetaRunState.INPUT_MODE_DAY_SUMMARY)

	BetaRunState.advance_day()

	assert_eq(BetaRunState.day, 2)
	assert_eq(BetaRunState.daily_reputation_delta, 0)
	assert_eq(BetaRunState.daily_cash_delta, 0)
	assert_true(BetaRunState.daily_events_resolved.is_empty())
	assert_eq(BetaRunState.input_mode, BetaRunState.INPUT_MODE_GAMEPLAY)
	assert_false(BetaRunState.carrying_stock)
	assert_eq(BetaRunState.cash, 42)
	assert_eq(BetaRunState.reputation, 3)
	assert_eq(BetaRunState.manager_trust, 4)
	assert_eq(BetaRunState.hidden_thread_score, 1)
	assert_true(BetaRunState.flags.has(&"choice_clean_exchange"))
	assert_true(BetaRunState.completed_events.has(&"opening_customer"))
	assert_true(BetaRunState.hidden_thread_signals_seen.has(&"warm_console"))
	assert_true(BetaRunState.preopening_complete)


func test_load_save_data_preserves_preopening_migration_defaults() -> void:
	BetaRunState.load_save_data({"day": 1})
	assert_false(BetaRunState.preopening_complete)

	BetaRunState.load_save_data({"day": 2})
	assert_true(BetaRunState.preopening_complete)

	BetaRunState.load_save_data({"day": 1, "preopening_complete": true})
	assert_true(BetaRunState.preopening_complete)
