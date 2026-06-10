extends GutTest

const AlphaBalancePolicy := preload("res://scripts/economy/alpha_balance_profile.gd")


func test_alpha_balance_profile_exposes_playable_day_one_targets() -> void:
	assert_eq(AlphaBalancePolicy.STARTING_CASH_CENTS, 50000)
	assert_eq(AlphaBalancePolicy.get_daily_overhead_cents(), 1000)
	assert_lte(
		AlphaBalancePolicy.get_daily_overhead_cents(),
		AlphaBalancePolicy.DAILY_OVERHEAD_TARGET_MAX_CENTS
	)
	assert_eq(AlphaBalancePolicy.STARTER_SUPPLIER_LOT_COST_CENTS, 3000)
	assert_eq(AlphaBalancePolicy.STARTER_SUPPLIER_DELIVERY_DAYS, 1)


func test_alpha_balance_profile_exposes_service_and_pricing_targets() -> void:
	assert_eq(AlphaBalancePolicy.DISC_RESURFACING_PRICE_CENTS, 599)
	assert_eq(AlphaBalancePolicy.DISC_RESURFACING_COST_CENTS, 125)
	assert_eq(
		AlphaBalancePolicy.get_price_range_low_cents(2499),
		2124
	)
	assert_eq(
		AlphaBalancePolicy.get_price_range_high_cents(2499, "medium"),
		2624
	)
	assert_eq(
		AlphaBalancePolicy.get_price_range_high_cents(4999, "high"),
		5599
	)


func test_alpha_balance_profile_tunes_upgrade_costs_for_alpha_progression() -> void:
	assert_eq(AlphaBalancePolicy.get_upgrade_cost_cents("upgrade_signage_staff_picks"), 4500)
	assert_eq(AlphaBalancePolicy.get_upgrade_cost_cents("upgrade_backroom_storage"), 9000)
	assert_eq(AlphaBalancePolicy.get_upgrade_cost_cents("upgrade_store_expansion"), 26000)
	assert_eq(AlphaBalancePolicy.get_upgrade_cost_cents("missing_upgrade", 1234), 1234)
	assert_lt(
		AlphaBalancePolicy.get_upgrade_cost_cents("upgrade_store_expansion"),
		AlphaBalancePolicy.STARTING_CASH_CENTS
	)


func test_alpha_balance_profile_summary_names_player_facing_targets() -> void:
	var summary := "\n".join(AlphaBalancePolicy.get_alpha_balance_summary_lines())

	assert_string_contains(summary, "Alpha balance:")
	assert_string_contains(summary, "Starting cash $500.00")
	assert_string_contains(summary, "daily overhead $10.00")
	assert_string_contains(summary, "starter lot $30.00")
	assert_string_contains(summary, "disc resurfacing $5.99 revenue / $1.25 cost")
	assert_string_contains(summary, "$260.00 store expansion")
