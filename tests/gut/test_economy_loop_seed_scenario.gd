extends GutTest

const RUNNER_SCRIPT: GDScript = preload("res://tests/automation/scenario_runner.gd")
const SCENARIO_ID: String = "economy_loop_seed_001"
const SALE_PRICE: float = 42.0
const STARTING_CASH: float = 100.0
const FLOAT_EPSILON: float = 0.001

var _saved_day: int = 1
var _saved_store_id: StringName = &""
var _saved_first_sale_complete: bool = false


func before_each() -> void:
	_saved_day = GameManager.get_current_day()
	_saved_store_id = GameManager.current_store_id
	_saved_first_sale_complete = GameState.get_flag(&"first_sale_complete")


func after_each() -> void:
	GameManager.set_current_day(_saved_day)
	GameManager.current_store_id = _saved_store_id
	GameState.set_flag(&"first_sale_complete", _saved_first_sale_complete)


func test_seeded_economy_loop_scenario_reports_one_complete_sale() -> void:
	var runner: Node = RUNNER_SCRIPT.new()
	add_child_autofree(runner)
	var result: Dictionary = await runner.call(
		"run_by_id",
		SCENARIO_ID,
		{"seed": "unit_seed", "fresh_save": true}
	)

	assert_true(bool(result.get("ok", false)), str(result.get("summary", "")))
	var captures: Dictionary = result.get("captures", {}) as Dictionary
	var report: Dictionary = captures.get("economy_loop_report", {}) as Dictionary

	assert_eq(str(report.get("resolved_store_id", "")), "retro_games")
	assert_eq(str(report.get("item_id", "")), "loop_seed_cart_001_instance")
	assert_almost_eq(
		float(report.get("money_delta", 0.0)),
		SALE_PRICE,
		FLOAT_EPSILON,
		"Money delta should equal the controlled sale price"
	)
	assert_eq(int(report.get("stock_delta", 0)), -1)
	assert_eq(str(report.get("customer_outcome", "")), "purchase_complete")
	assert_true(_event_order_is_strict(report))

	var save_data: Dictionary = report.get("economy_save_data", {}) as Dictionary
	assert_almost_eq(
		float(save_data.get("player_cash", 0.0)),
		STARTING_CASH + SALE_PRICE,
		FLOAT_EPSILON
	)
	assert_almost_eq(
		float(save_data.get("daily_revenue_total", 0.0)),
		SALE_PRICE,
		FLOAT_EPSILON
	)
	assert_eq(int(save_data.get("items_sold_today", 0)), 1)
	assert_eq((save_data.get("daily_transactions", []) as Array).size(), 1)

	var guards: Dictionary = report.get("setup_guards", {}) as Dictionary
	assert_true(bool(guards.get("desired_item_present", false)))
	assert_true(bool(guards.get("shelf_slot_present", false)))
	assert_true(bool(guards.get("duplicate_attempt_blocked", false)))
	assert_true((report.get("failures", []) as Array).is_empty())

	var run_report: Dictionary = result.get("report", {}) as Dictionary
	assert_true(bool(run_report.get("ok", false)))
	assert_true(FileAccess.file_exists(str(run_report.get("path", ""))))


func _event_order_is_strict(report: Dictionary) -> bool:
	var indexes: Dictionary = {}
	for event_variant: Variant in report.get("signal_evidence", []) as Array:
		var event: Dictionary = event_variant as Dictionary
		indexes[str(event.get("name", ""))] = int(event.get("index", -1))
	return (
		indexes.has("item_sold")
		and indexes.has("customer_purchased")
		and indexes.has("customer_completed")
		and int(indexes["item_sold"]) < int(indexes["customer_purchased"])
		and int(indexes["customer_purchased"]) < int(indexes["customer_completed"])
	)
