extends Resource
class_name AlphaBalanceProfile

const STARTING_CASH_CENTS := 50000
const DAILY_RENT_RESERVE_CENTS := 800
const DAILY_UTILITIES_RESERVE_CENTS := 200
const DAILY_OVERHEAD_TARGET_MAX_CENTS := 1200
const STARTER_SUPPLIER_LOT_COST_CENTS := 3000
const STARTER_SUPPLIER_DELIVERY_DAYS := 1
const DISC_RESURFACING_PRICE_CENTS := 599
const DISC_RESURFACING_COST_CENTS := 125
const CARTRIDGE_CLEANING_PRICE_CENTS := 799
const CARTRIDGE_CLEANING_COST_CENTS := 175
const CONSOLE_TEST_PRICE_CENTS := 1199
const CONSOLE_TEST_COST_CENTS := 300
const PRICE_RANGE_LOW_MULTIPLIER := 0.85
const PRICE_RANGE_HIGH_LOW_DEMAND := 1.00
const PRICE_RANGE_HIGH_MEDIUM_DEMAND := 1.05
const PRICE_RANGE_HIGH_HIGH_DEMAND := 1.12
const BUYER_TOLERANCE_LOW_DEMAND := 0.95
const BUYER_TOLERANCE_MEDIUM_DEMAND := 1.05
const BUYER_TOLERANCE_HIGH_DEMAND := 1.15

const UPGRADE_COSTS := {
	"upgrade_fixture_peg_wall": 7500,
	"upgrade_category_accessories": 5000,
	"upgrade_service_cleaning_tools": 9000,
	"upgrade_computer_analytics": 7500,
	"upgrade_signage_staff_picks": 4500,
	"upgrade_backroom_storage": 9000,
	"upgrade_store_expansion": 26000,
}


static func get_price_range_low_cents(market_value_cents: int) -> int:
	return int(round(maxi(0, market_value_cents) * PRICE_RANGE_LOW_MULTIPLIER))


static func get_price_range_high_cents(market_value_cents: int, demand_tier: String) -> int:
	return int(round(maxi(0, market_value_cents) * get_price_range_high_multiplier(demand_tier)))


static func get_price_range_high_multiplier(demand_tier: String) -> float:
	var normalized := demand_tier.strip_edges().to_lower()
	if normalized == "high":
		return PRICE_RANGE_HIGH_HIGH_DEMAND
	if normalized == "low":
		return PRICE_RANGE_HIGH_LOW_DEMAND
	return PRICE_RANGE_HIGH_MEDIUM_DEMAND


static func get_upgrade_cost_cents(upgrade_id: String, fallback_cents: int = 0) -> int:
	if UPGRADE_COSTS.has(upgrade_id):
		return int(UPGRADE_COSTS[upgrade_id])
	return fallback_cents


static func get_daily_overhead_cents() -> int:
	return DAILY_RENT_RESERVE_CENTS + DAILY_UTILITIES_RESERVE_CENTS


static func get_alpha_balance_summary_lines() -> Array[String]:
	return [
		"Alpha balance:",
		"Starting cash %s; daily overhead %s; starter lot %s due in %d day" % [
			_format_money(STARTING_CASH_CENTS),
			_format_money(get_daily_overhead_cents()),
			_format_money(STARTER_SUPPLIER_LOT_COST_CENTS),
			STARTER_SUPPLIER_DELIVERY_DAYS,
		],
		"Services: disc resurfacing %s revenue / %s cost; pricing range %d%%-%d%% by demand" % [
			_format_money(DISC_RESURFACING_PRICE_CENTS),
			_format_money(DISC_RESURFACING_COST_CENTS),
			int(round(PRICE_RANGE_LOW_MULTIPLIER * 100.0)),
			int(round(PRICE_RANGE_HIGH_HIGH_DEMAND * 100.0)),
		],
		"Upgrade costs are tuned for early goals before the %s store expansion." % _format_money(
			get_upgrade_cost_cents("upgrade_store_expansion")
		),
	]


static func _format_money(cents: int) -> String:
	return "$%0.2f" % (cents / 100.0)
