extends Node
class_name StoreSession

const CategoryDemandPolicy := preload("res://scripts/economy/category_demand.gd")
const AlphaBalancePolicy := preload("res://scripts/economy/alpha_balance_profile.gd")
const DailyReportPolicy := preload("res://scripts/economy/daily_report.gd")
const MarketDriftPolicy := preload("res://scripts/economy/market_drift.gd")
const ClueSurfaceCatalogPolicy := preload("res://scripts/narrative/clue_surface_catalog.gd")
const HiddenChoiceCatalogPolicy := preload("res://scripts/narrative/hidden_choice_catalog.gd")
const HiddenConsequenceRulesPolicy := preload("res://scripts/narrative/hidden_consequence_rules.gd")

const DAY_PHASE_OPENING := "opening"
const DAY_PHASE_SETUP := "setup"
const DAY_PHASE_CUSTOMER_HOURS := "customer_hours"
const DAY_PHASE_CLOSING := "closing"
const DAY_PHASE_REPORT := "report"
const DAY_PHASE_TOMORROW_PLANNING := "tomorrow_planning"
const DAILY_RENT_RESERVE_CENTS := AlphaBalancePolicy.DAILY_RENT_RESERVE_CENTS
const DAILY_UTILITIES_RESERVE_CENTS := AlphaBalancePolicy.DAILY_UTILITIES_RESERVE_CENTS
const DAILY_PAYROLL_PLACEHOLDER_CENTS := 0
const DAILY_REPAIRS_PLACEHOLDER_CENTS := 0
const DAILY_SHRINKAGE_PLACEHOLDER_CENTS := 0
const STORAGE_LOCATION_ID := "backstock_shelf_001"
const BASE_STORAGE_CAPACITY := 6
const UPGRADED_STORAGE_CAPACITY := 12
const EXPANDED_STORAGE_CAPACITY := 18
const EXPANDED_PLACEMENT_BOUNDS_MIN := Vector3(-7.2, 0.0, -5.4)
const EXPANDED_PLACEMENT_BOUNDS_MAX := Vector3(7.2, 0.0, 5.9)
const EXPANDED_CUSTOMER_PLAYABLE_MIN := Vector3(-8.0, 0.0, -6.2)
const EXPANDED_CUSTOMER_PLAYABLE_MAX := Vector3(8.0, 0.0, 6.4)
const EXPANDED_QUEUE_SPACING := Vector3(0.0, 0.0, -1.0)
const SERVICE_BENCH_CATALOG := [
	{
		"service_id": "disc_resurfacing",
		"service_name": "Disc Resurfacing",
		"item_name": "Scratched Orbit Disc",
		"bench_id": "backroom_service_bench",
		"parts": ["resurfacing_pad", "cleaning_solution", "paper_sleeve"],
		"price_cents": AlphaBalancePolicy.DISC_RESURFACING_PRICE_CENTS,
		"cost_cents": AlphaBalancePolicy.DISC_RESURFACING_COST_CENTS,
		"turnaround_minutes": 10,
	},
	{
		"service_id": "cartridge_cleaning",
		"service_name": "Cartridge Cleaning",
		"item_name": "Dusty Cart",
		"bench_id": "backroom_service_bench",
		"parts": ["contact_cleaner", "lint_swab"],
		"price_cents": AlphaBalancePolicy.CARTRIDGE_CLEANING_PRICE_CENTS,
		"cost_cents": AlphaBalancePolicy.CARTRIDGE_CLEANING_COST_CENTS,
		"turnaround_minutes": 15,
		"requires_upgrade_id": "upgrade_service_cleaning_tools",
	},
	{
		"service_id": "console_test",
		"service_name": "Console Test",
		"item_name": "Trade-in Console",
		"bench_id": "backroom_service_bench",
		"parts": ["test_cable", "diagnostic_card"],
		"price_cents": AlphaBalancePolicy.CONSOLE_TEST_PRICE_CENTS,
		"cost_cents": AlphaBalancePolicy.CONSOLE_TEST_COST_CENTS,
		"turnaround_minutes": 20,
		"placeholder": true,
	},
]
const MANAGEMENT_DESK_TASKS := [
	{
		"task_id": "supplier_messages",
		"label": "Supplier messages",
		"category": "records",
		"desk_id": "backroom_management_desk",
		"summary": "Review supplier notes, due orders, receiving issues, and optional hidden records.",
	},
	{
		"task_id": "bill_review",
		"label": "Bill review",
		"category": "bills",
		"desk_id": "backroom_management_desk",
		"summary": "Review rent reserve, utilities, operating expenses, and reserved obligations.",
	},
	{
		"task_id": "inventory_search",
		"label": "Inventory search",
		"category": "inventory",
		"desk_id": "backroom_management_desk",
		"summary": "Search active inventory, backstock, receiving stock, and reorder gaps.",
	},
	{
		"task_id": "report_review",
		"label": "Report review",
		"category": "reports",
		"desk_id": "backroom_management_desk",
		"summary": "Review the daily report, cash movement, reputation changes, and tomorrow notes.",
	},
	{
		"task_id": "preorder_planning",
		"label": "Preorder planning",
		"category": "releases",
		"desk_id": "backroom_management_desk",
		"summary": "Review preorder obligations, release allocations, due days, and launch shortages.",
	},
	{
		"task_id": "upgrade_ordering",
		"label": "Upgrade ordering",
		"category": "upgrades",
		"desk_id": "backroom_management_desk",
		"summary": "Review available upgrades and place upgrade orders from the management desk.",
	},
]
const DECORATION_CATALOG := [
	{
		"decoration_id": "decor_wall_paint_savepoint_blue",
		"label": "Savepoint Blue Wall Paint",
		"category": "wall_paint",
		"surface": "sales_floor_walls",
		"cost_cents": 4000,
		"clutter_points": 0,
		"effect": "Strengthens store identity without adding floor clutter.",
	},
	{
		"decoration_id": "decor_floor_warm_wood",
		"label": "Warm Wood Floor",
		"category": "floor_material",
		"surface": "sales_floor_floor",
		"cost_cents": 6500,
		"clutter_points": 0,
		"effect": "Warmer retail floor finish for the sales area.",
	},
	{
		"decoration_id": "decor_poster_launch_set",
		"label": "Launch Poster Set",
		"category": "poster",
		"surface": "front_wall",
		"cost_cents": 2500,
		"clutter_points": 1,
		"effect": "Adds new-release flavor and a small featured-marketing hook.",
	},
	{
		"decoration_id": "decor_signage_counter_refresh",
		"label": "Counter Signage Refresh",
		"category": "signage",
		"surface": "register_counter",
		"cost_cents": 3500,
		"clutter_points": 1,
		"effect": "Clarifies register identity without changing checkout rules.",
	},
	{
		"decoration_id": "decor_light_track_warm",
		"label": "Warm Track Lights",
		"category": "light",
		"surface": "ceiling",
		"cost_cents": 5000,
		"clutter_points": 0,
		"effect": "Improves fixture readability and store tone.",
	},
	{
		"decoration_id": "decor_controller_display_prop",
		"label": "Controller Display Prop",
		"category": "display_prop",
		"surface": "sales_floor_fixture",
		"cost_cents": 3000,
		"clutter_points": 1,
		"effect": "Adds accessory flavor near displays.",
	},
	{
		"decoration_id": "decor_small_clutter_budget",
		"label": "Small Clutter Budget",
		"category": "clutter_budget",
		"surface": "whole_store",
		"cost_cents": 1500,
		"clutter_points": -2,
		"effect": "Raises the safe prop budget for future small clutter.",
	},
]
const BASE_CLUTTER_BUDGET_POINTS := 4
const UPGRADE_CATALOG := [
	{
		"upgrade_id": "upgrade_fixture_peg_wall",
		"label": "Accessory Peg Wall",
		"category": "fixture",
		"cost_cents": AlphaBalancePolicy.UPGRADE_COSTS["upgrade_fixture_peg_wall"],
		"unlocks": "Accessory fixture orders",
	},
	{
		"upgrade_id": "upgrade_category_accessories",
		"label": "Accessory Category License",
		"category": "category",
		"cost_cents": AlphaBalancePolicy.UPGRADE_COSTS["upgrade_category_accessories"],
		"unlocks": "Accessory stocking and customer demand",
	},
	{
		"upgrade_id": "upgrade_service_cleaning_tools",
		"label": "Service Cleaning Tools",
		"category": "service_tool",
		"cost_cents": AlphaBalancePolicy.UPGRADE_COSTS["upgrade_service_cleaning_tools"],
		"unlocks": "Cartridge cleaning and controller testing",
	},
	{
		"upgrade_id": "upgrade_computer_analytics",
		"label": "Computer Analytics",
		"category": "computer_tool",
		"cost_cents": AlphaBalancePolicy.UPGRADE_COSTS["upgrade_computer_analytics"],
		"unlocks": "Advanced demand and margin views",
	},
	{
		"upgrade_id": "upgrade_signage_staff_picks",
		"label": "Staff Picks Signage",
		"category": "signage",
		"cost_cents": AlphaBalancePolicy.UPGRADE_COSTS["upgrade_signage_staff_picks"],
		"unlocks": "Featured shelf marketing",
	},
	{
		"upgrade_id": "upgrade_backroom_storage",
		"label": "Backroom Storage Bay",
		"category": "storage",
		"cost_cents": AlphaBalancePolicy.UPGRADE_COSTS["upgrade_backroom_storage"],
		"unlocks": "More backstock and receiving capacity",
	},
	{
		"upgrade_id": "upgrade_store_expansion",
		"label": "Starter Store Expansion",
		"category": "expansion",
		"cost_cents": AlphaBalancePolicy.UPGRADE_COSTS["upgrade_store_expansion"],
		"requires_upgrade_id": "upgrade_backroom_storage",
		"unlocks": "Larger sales floor footprint",
	},
]
const DAY_STRUCTURE := [
	{
		"phase": DAY_PHASE_OPENING,
		"label": "Opening",
		"purpose": "Post overnight bills, deliveries, launch events, and daily setup notes.",
	},
	{
		"phase": DAY_PHASE_SETUP,
		"label": "Setup",
		"purpose": "Price incoming stock, place fixtures, review orders, and prepare shelves before traffic.",
	},
	{
		"phase": DAY_PHASE_CUSTOMER_HOURS,
		"label": "Customer hours",
		"purpose": "Serve buyers, trade-ins, preorders, service pickups, and optional suspicious encounters.",
	},
	{
		"phase": DAY_PHASE_CLOSING,
		"label": "Closing",
		"purpose": "Stop new customer work, finish counter tasks, and close the register.",
	},
	{
		"phase": DAY_PHASE_REPORT,
		"label": "Report",
		"purpose": "Review sales, trade-ins, services, launch outcomes, reputation, losses, and bills.",
	},
	{
		"phase": DAY_PHASE_TOMORROW_PLANNING,
		"label": "Tomorrow planning",
		"purpose": "Plan deliveries, release allocations, reorder needs, and setup priorities for the next day.",
	},
]
const ONBOARDING_STEPS := [
	{
		"step_id": "receiving",
		"label": "Receiving",
		"instruction": "Pick up incoming games from receiving before serving the rush.",
	},
	{
		"step_id": "pricing",
		"label": "Pricing",
		"instruction": "Set a fair price while the game is in hand.",
	},
	{
		"step_id": "stocking",
		"label": "Stocking",
		"instruction": "Place priced games on a matching display slot.",
	},
	{
		"step_id": "checkout",
		"label": "Checkout",
		"instruction": "Ring up waiting buyers at the register.",
	},
	{
		"step_id": "trade_in",
		"label": "Trade-in",
		"instruction": "Review condition, market value, and offer before accepting.",
	},
	{
		"step_id": "computer",
		"label": "Backroom Computer",
		"instruction": "Review reports, releases, services, storage, and upgrade planning.",
	},
	{
		"step_id": "ordering",
		"label": "Ordering",
		"instruction": "Order supplier lots so new stock arrives in receiving.",
	},
	{
		"step_id": "closing",
		"label": "Closing",
		"instruction": "End the day, read the report, and plan tomorrow.",
	},
]

@export var day_number: int = 1
@export var day_phase: String = DAY_PHASE_SETUP
@export var starting_cash_cents: int = AlphaBalancePolicy.STARTING_CASH_CENTS
@export var ledger_path: NodePath
@export var inventory_root_path: NodePath
@export var receiving_box_path: NodePath
@export var fixture_placement_manager_path: NodePath
@export var evidence_storage_path: NodePath
@export var customer_manager_path: NodePath

const DEFAULT_FIXTURE_CATALOG_PATHS := [
	"res://data/fixtures/game_display_rack.tres",
	"res://data/fixtures/wall_shelf.tres",
	"res://data/fixtures/accessory_peg_wall.tres",
	"res://data/fixtures/bargain_bin.tres",
	"res://data/fixtures/locked_case.tres",
	"res://data/fixtures/counter_rack.tres",
	"res://data/fixtures/demo_kiosk.tres",
	"res://data/fixtures/new_release_wall.tres",
	"res://data/fixtures/backroom_rack.tres",
]
const DEFAULT_SUPPLIER_LOT_PATHS := [
	"res://data/suppliers/used_game_starter_lot.tres",
]
const DEFAULT_RELEASE_CALENDAR_PATHS := [
	"res://data/releases/neon_skyline_launch.tres",
	"res://data/releases/pocket_farm_dx_launch.tres",
	"res://data/releases/skycart_grand_prix_launch.tres",
]

var cash_cents: int = 0
var is_day_closed: bool = false
var fixture_orders: Array[Dictionary] = []
var placed_fixtures: Array[Dictionary] = []
var fixture_slot_categories: Dictionary = {}
var purchased_decorations: Array[Dictionary] = []
var supplier_orders: Array[Dictionary] = []
var receiving_batches: Array[Dictionary] = []
var storage_movements: Array[Dictionary] = []
var service_tickets: Array[Dictionary] = []
var management_reviews: Array[Dictionary] = []
var preorder_deposits: Array[Dictionary] = []
var release_allocations: Array[Dictionary] = []
var launch_events: Array[Dictionary] = []
var operating_expenses: Array[Dictionary] = []
var reputation_events: Array[Dictionary] = []
var purchased_upgrades: Array[Dictionary] = []
var hidden_thread_choice_records: Array[Dictionary] = []
var hidden_thread_consequence_events: Array[Dictionary] = []
var supplier_access_score: int = 50
var customer_trust_score: int = 50
var inspection_risk_score: int = 0
var hidden_story_state: String = "none"
var reputation_score: int = 100


func _ready() -> void:
	if cash_cents == 0:
		cash_cents = starting_cash_cents
	_apply_progression_effects()


func apply_sale(transaction: Dictionary) -> void:
	cash_cents += int(transaction.get("sale_price_cents", 0))


func apply_trade_in(transaction: Dictionary) -> void:
	cash_cents -= int(transaction.get(
		"trade_in_cash_cents",
		transaction.get("trade_in_cost_cents", 0)
	))


func apply_preorder_deposit(transaction: Dictionary) -> void:
	cash_cents += int(transaction.get("deposit_cents", 0))
	if str(transaction.get("type", "")) == "preorder_deposit":
		preorder_deposits.append(transaction.duplicate(true))


func apply_service(transaction: Dictionary) -> void:
	cash_cents += int(transaction.get("service_price_cents", 0))
	_mark_service_ticket_picked_up(transaction)


func end_day() -> void:
	if is_day_closed:
		return

	_apply_end_day_cash_pressure()
	day_phase = DAY_PHASE_REPORT
	is_day_closed = true


func start_next_day() -> Dictionary:
	if not is_day_closed:
		return {}

	day_number += 1
	is_day_closed = false
	day_phase = DAY_PHASE_OPENING
	var delivered_orders := _deliver_due_supplier_orders()
	var resolved_launches := _process_due_launches()
	day_phase = DAY_PHASE_SETUP
	return {
		"day_number": day_number,
		"day_phase": day_phase,
		"day_phase_label": get_day_phase_label(),
		"day_structure": get_day_structure(),
		"opening_summary": _format_opening_summary(delivered_orders, resolved_launches),
		"delivered_orders": delivered_orders,
		"delivered_count": delivered_orders.size(),
		"launch_events": resolved_launches,
		"launch_event_count": resolved_launches.size(),
	}


func start_customer_hours() -> bool:
	if is_day_closed:
		return false

	day_phase = DAY_PHASE_CUSTOMER_HOURS
	return true


func begin_closing() -> bool:
	if is_day_closed:
		return false

	day_phase = DAY_PHASE_CLOSING
	return true


func begin_tomorrow_planning() -> bool:
	if not is_day_closed:
		return false

	day_phase = DAY_PHASE_TOMORROW_PLANNING
	return true


func get_day_phase() -> String:
	return day_phase


func get_day_phase_label(phase: String = "") -> String:
	var target_phase := phase
	if target_phase.is_empty():
		target_phase = day_phase

	for row in DAY_STRUCTURE:
		if str(row.get("phase", "")) == target_phase:
			return str(row.get("label", target_phase.capitalize()))
	return target_phase.capitalize()


func get_day_structure() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for row in DAY_STRUCTURE:
		rows.append(row.duplicate(true))
	return rows


func get_day_structure_text() -> String:
	var lines: Array[String] = ["Day structure:"]
	for row in DAY_STRUCTURE:
		lines.append("%s: %s" % [
			str(row.get("label", "")),
			str(row.get("purpose", "")),
		])
	return "\n".join(lines)


func get_tomorrow_planning_text() -> String:
	return "Tomorrow planning: %s" % "; ".join(DailyReportPolicy.get_tomorrow_recommendations(self))


func get_onboarding_steps() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var found_next := false
	for step in ONBOARDING_STEPS:
		var row: Dictionary = step.duplicate(true)
		var completed := _is_onboarding_step_complete(str(row.get("step_id", "")))
		row["complete"] = completed
		if completed:
			row["status"] = "done"
		elif not found_next:
			row["status"] = "next"
			found_next = true
		else:
			row["status"] = "later"
		rows.append(row)
	return rows


func get_onboarding_summary_text(max_steps: int = 8) -> String:
	var lines: Array[String] = ["Owner checklist:"]
	var count := 0
	for step in get_onboarding_steps():
		if max_steps > 0 and count >= max_steps:
			break
		lines.append("%s - %s: %s" % [
			_get_onboarding_status_label(str(step.get("status", "later"))),
			str(step.get("label", "Step")),
			str(step.get("instruction", "")),
		])
		count += 1
	return "\n".join(lines)


func get_daily_cash_pressure_rules() -> Array[Dictionary]:
	return [
		{
			"expense_id": "rent_reserve",
			"label": "Rent reserve",
			"category": "rent",
			"amount_cents": DAILY_RENT_RESERVE_CENTS,
			"due_timing": "daily close reserve",
		},
		{
			"expense_id": "utilities_reserve",
			"label": "Utilities",
			"category": "bill",
			"amount_cents": DAILY_UTILITIES_RESERVE_CENTS,
			"due_timing": "daily close reserve",
		},
		{
			"expense_id": "payroll_placeholder",
			"label": "Payroll placeholder",
			"category": "payroll",
			"amount_cents": DAILY_PAYROLL_PLACEHOLDER_CENTS,
			"due_timing": "owner-operated placeholder",
		},
		{
			"expense_id": "repairs_placeholder",
			"label": "Repairs placeholder",
			"category": "repairs",
			"amount_cents": DAILY_REPAIRS_PLACEHOLDER_CENTS,
			"due_timing": "future maintenance hook",
		},
		{
			"expense_id": "shrinkage_placeholder",
			"label": "Shrinkage placeholder",
			"category": "shrinkage",
			"amount_cents": DAILY_SHRINKAGE_PLACEHOLDER_CENTS,
			"due_timing": "future loss hook",
		},
	]


func get_daily_cash_pressure_cents() -> int:
	var total := 0
	for rule in get_daily_cash_pressure_rules():
		total += int(rule.get("amount_cents", 0))
	return total


func get_operating_expenses() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for expense in operating_expenses:
		rows.append(expense.duplicate(true))
	return rows


func replace_operating_expenses(expenses: Array) -> void:
	operating_expenses.clear()
	for expense in expenses:
		if typeof(expense) == TYPE_DICTIONARY:
			var row: Dictionary = expense
			operating_expenses.append(row.duplicate(true))


func get_operating_expenses_total_cents(day: int = 0) -> int:
	var total := 0
	for expense in operating_expenses:
		if day > 0 and int(expense.get("day_number", 0)) != day:
			continue
		total += int(expense.get("amount_cents", 0))
	return total


func get_reserved_obligations_cents() -> int:
	var total := 0
	for order in get_pending_supplier_orders():
		total += int(order.get("cost_cents", 0))
	for order in get_pending_fixture_orders():
		total += int(order.get("cost_cents", 0))
	for allocation in release_allocations:
		if str(allocation.get("status", "committed")) == "committed":
			total += int(allocation.get("total_cost_cents", 0))
	return total


func get_cash_pressure_summary_text() -> String:
	var lines: Array[String] = ["Cash pressure:"]
	lines.append("Daily overhead due at close: %s" % format_money(get_daily_cash_pressure_cents()))
	for rule in get_daily_cash_pressure_rules():
		lines.append("%s: %s (%s)" % [
			str(rule.get("label", "Expense")),
			format_money(int(rule.get("amount_cents", 0))),
			str(rule.get("due_timing", "daily")),
		])
	lines.append("Supplier terms: current starter lots are prepaid; receiving/storage time is the constraint")
	lines.append("Reserved obligations: %s" % format_money(get_reserved_obligations_cents()))
	if operating_expenses.is_empty():
		lines.append("Posted operating expenses: none")
	else:
		lines.append("Posted operating expenses: %s total" % format_money(get_operating_expenses_total_cents()))
	return "\n".join(lines)


func get_upgrade_catalog() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for upgrade in UPGRADE_CATALOG:
		rows.append(upgrade.duplicate(true))
	return rows


func get_purchased_upgrades() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for upgrade in purchased_upgrades:
		rows.append(upgrade.duplicate(true))
	return rows


func replace_purchased_upgrades(upgrades: Array) -> void:
	purchased_upgrades.clear()
	for upgrade in upgrades:
		if typeof(upgrade) == TYPE_DICTIONARY:
			var row: Dictionary = upgrade
			purchased_upgrades.append(row.duplicate(true))
	_apply_progression_effects()


func has_upgrade(upgrade_id: String) -> bool:
	for upgrade in purchased_upgrades:
		if str(upgrade.get("upgrade_id", "")) == upgrade_id:
			return true
	return false


func get_available_upgrades() -> Array[Dictionary]:
	var upgrades: Array[Dictionary] = []
	for upgrade in UPGRADE_CATALOG:
		var upgrade_id := str(upgrade.get("upgrade_id", ""))
		if has_upgrade(upgrade_id):
			continue
		if not _upgrade_requirements_met(upgrade):
			continue
		upgrades.append(upgrade.duplicate(true))
	return upgrades


func can_purchase_upgrade(upgrade_id: String) -> bool:
	if is_day_closed or has_upgrade(upgrade_id):
		return false
	var upgrade := _get_upgrade_definition(upgrade_id)
	if upgrade.is_empty() or not _upgrade_requirements_met(upgrade):
		return false
	return get_cash_cents() >= int(upgrade.get("cost_cents", 0))


func purchase_upgrade(upgrade_id: String) -> Dictionary:
	if not can_purchase_upgrade(upgrade_id):
		return {}

	var upgrade := _get_upgrade_definition(upgrade_id)
	cash_cents = get_cash_cents() - int(upgrade.get("cost_cents", 0))
	var purchase := upgrade.duplicate(true)
	purchase["purchased_day"] = day_number
	purchase["status"] = "purchased"
	purchased_upgrades.append(purchase)
	_apply_progression_effects()
	return purchase.duplicate(true)


func get_upgrade_summary_text() -> String:
	var lines: Array[String] = ["Upgrades:"]
	if purchased_upgrades.is_empty():
		lines.append("Purchased: none")
	else:
		var purchased_labels: Array[String] = []
		for upgrade in purchased_upgrades:
			purchased_labels.append(str(upgrade.get("label", upgrade.get("upgrade_id", "upgrade"))))
		lines.append("Purchased: %s" % ", ".join(purchased_labels))

	var available := get_available_upgrades()
	if available.is_empty():
		lines.append("Available: none")
	else:
		lines.append("Available:")
		for upgrade in available:
			lines.append("%s %s (%s) unlocks %s" % [
				str(upgrade.get("label", "Upgrade")),
				format_money(int(upgrade.get("cost_cents", 0))),
				str(upgrade.get("category", "upgrade")),
				str(upgrade.get("unlocks", "new option")),
			])

	var locked: Array[String] = []
	for upgrade in UPGRADE_CATALOG:
		if has_upgrade(str(upgrade.get("upgrade_id", ""))):
			continue
		if not _upgrade_requirements_met(upgrade):
			locked.append(str(upgrade.get("label", "Upgrade")))
	if not locked.is_empty():
		lines.append("Locked: %s" % ", ".join(locked))
	lines.append(get_store_expansion_summary_text())
	return "\n".join(lines)


func has_store_expansion() -> bool:
	return has_upgrade("upgrade_store_expansion")


func get_store_expansion_summary_text() -> String:
	if has_store_expansion():
		return "Store expansion: expanded footprint, storage %d cases, wider placement bounds, clearer queue/travel lanes" % get_storage_capacity()
	if has_upgrade("upgrade_backroom_storage"):
		return "Store expansion: available after purchase; current storage %d cases, starter footprint active" % get_storage_capacity()
	return "Store expansion: locked until Backroom Storage Bay; starter footprint active"


func get_cash_cents() -> int:
	if cash_cents == 0:
		return starting_cash_cents

	return cash_cents


func get_sale_count() -> int:
	var ledger := _get_ledger()
	if ledger == null:
		return 0

	return ledger.get_sale_count()


func get_total_revenue_cents() -> int:
	var ledger := _get_ledger()
	if ledger == null:
		return 0

	return ledger.get_total_revenue_cents()


func get_total_cost_cents() -> int:
	var total := 0
	for transaction in get_transactions():
		var transaction_type := str(transaction.get("type", "sale"))
		if transaction_type == "sale":
			total += int(transaction.get("cost_basis_cents", 0))
		elif transaction_type == "service":
			total += int(transaction.get("service_cost_cents", 0))
	return total


func get_total_profit_cents() -> int:
	var ledger := _get_ledger()
	if ledger == null:
		return 0

	return ledger.get_total_profit_cents()


func get_trade_in_count() -> int:
	var ledger := _get_ledger()
	if ledger == null:
		return 0

	return ledger.get_trade_in_count()


func get_total_trade_in_cost_cents() -> int:
	var ledger := _get_ledger()
	if ledger == null:
		return 0

	return ledger.get_total_trade_in_cost_cents()


func get_total_trade_in_credit_cents() -> int:
	var ledger := _get_ledger()
	if ledger == null:
		return 0

	return ledger.get_total_trade_in_credit_cents()


func get_preorder_deposit_count() -> int:
	if not preorder_deposits.is_empty():
		return preorder_deposits.size()

	var ledger := _get_ledger()
	if ledger == null or not ledger.has_method("get_preorder_deposit_count"):
		return 0

	return ledger.get_preorder_deposit_count()


func get_service_count() -> int:
	var ledger := _get_ledger()
	if ledger == null or not ledger.has_method("get_service_count"):
		return 0

	return ledger.get_service_count()


func get_total_service_revenue_cents() -> int:
	var ledger := _get_ledger()
	if ledger == null or not ledger.has_method("get_total_service_revenue_cents"):
		return 0

	return ledger.get_total_service_revenue_cents()


func get_total_service_cost_cents() -> int:
	var ledger := _get_ledger()
	if ledger == null or not ledger.has_method("get_total_service_cost_cents"):
		return 0

	return ledger.get_total_service_cost_cents()


func get_total_service_profit_cents() -> int:
	var ledger := _get_ledger()
	if ledger == null or not ledger.has_method("get_total_service_profit_cents"):
		return 0

	return ledger.get_total_service_profit_cents()


func get_service_catalog() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for service in SERVICE_BENCH_CATALOG:
		var row: Dictionary = service.duplicate(true)
		row["available"] = _service_requirements_met(row)
		rows.append(row)
	return rows


func get_service_tickets() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for ticket in service_tickets:
		rows.append(ticket.duplicate(true))
	return rows


func replace_service_tickets(tickets: Array) -> void:
	service_tickets.clear()
	for ticket in tickets:
		if typeof(ticket) == TYPE_DICTIONARY:
			var row: Dictionary = ticket
			service_tickets.append(row.duplicate(true))


func can_start_service_ticket(service_id: String = "disc_resurfacing") -> bool:
	return not is_day_closed and not _get_service_definition(service_id).is_empty()


func start_service_ticket(service_id: String = "disc_resurfacing") -> Dictionary:
	if not can_start_service_ticket(service_id):
		return {}

	var service := _get_service_definition(service_id)
	var ticket := {
		"ticket_id": "service_ticket_%03d" % (service_tickets.size() + 1),
		"service_id": str(service.get("service_id", service_id)),
		"service_name": str(service.get("service_name", "Service")),
		"item_name": str(service.get("item_name", "item")),
		"bench_id": str(service.get("bench_id", "backroom_service_bench")),
		"parts": (service.get("parts", []) as Array).duplicate(true),
		"price_cents": int(service.get("price_cents", 0)),
		"cost_cents": int(service.get("cost_cents", 0)),
		"turnaround_minutes": int(service.get("turnaround_minutes", 0)),
		"started_day": day_number,
		"progress_percent": 0,
		"status": "queued",
	}
	service_tickets.append(ticket)
	return ticket.duplicate(true)


func get_active_service_ticket() -> Dictionary:
	for ticket in service_tickets:
		var status := str(ticket.get("status", "queued"))
		if status == "queued" or status == "in_progress" or status == "ready_for_pickup":
			return ticket.duplicate(true)
	return {}


func can_work_service_ticket() -> bool:
	if is_day_closed:
		return false
	for ticket in service_tickets:
		var status := str(ticket.get("status", "queued"))
		if status == "queued" or status == "in_progress":
			return true
	return false


func work_service_ticket(ticket_id: String = "") -> Dictionary:
	if not can_work_service_ticket():
		return {}

	var index := _find_service_ticket_index(ticket_id, true)
	if index < 0:
		return {}

	var ticket := service_tickets[index]
	var status := str(ticket.get("status", "queued"))
	if status == "queued":
		ticket["status"] = "in_progress"
		ticket["progress_percent"] = 50
	elif status == "in_progress":
		ticket["status"] = "ready_for_pickup"
		ticket["progress_percent"] = 100
		ticket["ready_day"] = day_number
	service_tickets[index] = ticket
	return ticket.duplicate(true)


func get_service_bench_summary_text() -> String:
	var lines: Array[String] = ["Service bench:"]
	lines.append("Bench: Backroom service bench / backroom_service_bench")
	lines.append("Capabilities:")
	for service in get_service_catalog():
		var availability := "available" if bool(service.get("available", false)) else "locked"
		if bool(service.get("placeholder", false)):
			availability = "placeholder"
		lines.append("%s: %s (%s, %dm, parts %d)" % [
			str(service.get("service_name", "Service")),
			availability,
			format_money(int(service.get("price_cents", 0))),
			int(service.get("turnaround_minutes", 0)),
			(service.get("parts", []) as Array).size(),
		])
	if service_tickets.is_empty():
		lines.append("Tickets: none")
	else:
		lines.append("Tickets:")
		for ticket in service_tickets:
			lines.append("%s %s for %s - %s %d%%" % [
				str(ticket.get("ticket_id", "service_ticket")),
				str(ticket.get("service_name", "Service")),
				str(ticket.get("item_name", "item")),
				str(ticket.get("status", "queued")),
				int(ticket.get("progress_percent", 0)),
			])
			lines.append("Parts: %s" % ", ".join(ticket.get("parts", []) as Array))
	lines.append("Pickup: complete ready service work at the register with the customer")
	return "\n".join(lines)


func get_management_desk_tasks() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for task in MANAGEMENT_DESK_TASKS:
		var row: Dictionary = task.duplicate(true)
		row["status"] = "reviewed" if _has_management_review(str(row.get("task_id", ""))) else "pending"
		rows.append(row)
	return rows


func get_management_reviews() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for review in management_reviews:
		rows.append(review.duplicate(true))
	return rows


func replace_management_reviews(reviews: Array) -> void:
	management_reviews.clear()
	for review in reviews:
		if typeof(review) == TYPE_DICTIONARY:
			var row: Dictionary = review
			management_reviews.append(row.duplicate(true))


func can_review_management_task(task_id: String = "") -> bool:
	if is_day_closed:
		return false
	var task := _get_management_task_definition(task_id)
	if task.is_empty() and task_id.is_empty():
		task = _get_next_pending_management_task()
	if task.is_empty():
		return false
	return not _has_management_review(str(task.get("task_id", "")))


func review_management_task(task_id: String = "") -> Dictionary:
	var task := _get_management_task_definition(task_id)
	if task.is_empty() and task_id.is_empty():
		task = _get_next_pending_management_task()
	if task.is_empty() or not can_review_management_task(str(task.get("task_id", ""))):
		return {}

	var review := {
		"review_id": "management_review_%03d" % (management_reviews.size() + 1),
		"task_id": str(task.get("task_id", "")),
		"label": str(task.get("label", "Management task")),
		"category": str(task.get("category", "management")),
		"desk_id": str(task.get("desk_id", "backroom_management_desk")),
		"summary": str(task.get("summary", "")),
		"reviewed_day": day_number,
		"status": "reviewed",
	}
	management_reviews.append(review)
	return review.duplicate(true)


func can_purchase_management_upgrade(upgrade_id: String = "upgrade_computer_analytics") -> bool:
	return can_purchase_upgrade(upgrade_id)


func purchase_management_upgrade(upgrade_id: String = "upgrade_computer_analytics") -> Dictionary:
	if not can_purchase_management_upgrade(upgrade_id):
		return {}

	var purchase := purchase_upgrade(upgrade_id)
	if purchase.is_empty():
		return {}
	purchase["desk_id"] = "backroom_management_desk"
	purchase["order_status"] = "ordered"
	return purchase.duplicate(true)


func get_management_desk_summary_text() -> String:
	var lines: Array[String] = ["Management desk:"]
	lines.append("Desk: Backroom management desk / backroom_management_desk")
	lines.append("Tasks:")
	for task in get_management_desk_tasks():
		lines.append("%s - %s: %s" % [
			str(task.get("label", "Task")),
			str(task.get("status", "pending")),
			str(task.get("summary", "")),
		])
	lines.append("Supplier messages: review supplier notes, hidden records, and %d pending orders" % get_pending_supplier_orders().size())
	lines.append("Bills: due at close %s, reserved obligations %s" % [
		format_money(get_daily_cash_pressure_cents()),
		format_money(get_reserved_obligations_cents()),
	])
	lines.append("Inventory search: %d active items; %s" % [
		get_active_inventory_items().size(),
		get_reorder_suggestions_text().replace("\n", " / "),
	])
	lines.append("Report review: %s" % ("closed-day report ready" if is_day_closed else "day still open"))
	lines.append("Preorder planning: %d deposits, %d allocations, %d launch events" % [
		get_preorder_deposit_count(),
		get_release_allocation_count(),
		get_launch_event_count(),
	])
	var available := get_available_upgrades()
	if available.is_empty():
		lines.append("Upgrade ordering: no available upgrades")
	else:
		var next_upgrade := available[0]
		lines.append("Upgrade ordering: next %s %s; computer analytics %s" % [
			str(next_upgrade.get("label", "Upgrade")),
			format_money(int(next_upgrade.get("cost_cents", 0))),
			"purchased" if has_upgrade("upgrade_computer_analytics") else "available",
		])
	if management_reviews.is_empty():
		lines.append("Recent desk review: none")
	else:
		var recent := management_reviews[management_reviews.size() - 1]
		lines.append("Recent desk review: %s %s day %d" % [
			str(recent.get("label", "Task")),
			str(recent.get("status", "reviewed")),
			int(recent.get("reviewed_day", day_number)),
		])
	return "\n".join(lines)


func get_security_placeholder_summary_text() -> String:
	var storage := _get_evidence_storage()
	if storage != null and storage.has_method("get_security_zone_summary_text"):
		return str(storage.call("get_security_zone_summary_text"))

	return "Security placeholders:\nCash safe - placeholder / backroom_safe / Cash storage\nHigh-value storage - placeholder / backroom_high_value_shelf / High-value stock hold\nSuspicious goods isolation - placeholder / backroom_evidence_locker / Quarantine suspicious items\nSecurity footage - placeholder / backroom_security_monitor / Review camera clips\nSecurity records: none\nStatus: placeholders only; no active hidden objective or register action"


func get_hidden_clue_surface_summary_text() -> String:
	return ClueSurfaceCatalogPolicy.get_summary_text(_get_hidden_clue_surface_context())


func get_hidden_thread_choice_options() -> Array[Dictionary]:
	return HiddenChoiceCatalogPolicy.evaluate_context(_get_hidden_choice_context())


func get_hidden_thread_choice_summary_text() -> String:
	return HiddenChoiceCatalogPolicy.get_summary_text(
		_get_hidden_choice_context(),
		get_hidden_thread_choice_records()
	)


func record_hidden_thread_choice(choice_id: String, subject_id: String = "", metadata: Dictionary = {}) -> Dictionary:
	var record: Dictionary = HiddenChoiceCatalogPolicy.build_choice_record(choice_id, subject_id, metadata)
	if record.is_empty():
		return {}

	var record_id := str(record.get("choice_record_id", "")).strip_edges()
	for existing in hidden_thread_choice_records:
		if str(existing.get("choice_record_id", "")) == record_id:
			return existing.duplicate(true)

	record["recorded_day"] = day_number
	hidden_thread_choice_records.append(record)
	_apply_hidden_thread_consequence(record)
	return record.duplicate(true)


func get_hidden_thread_choice_records() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for record in hidden_thread_choice_records:
		rows.append(record.duplicate(true))
	return rows


func replace_hidden_thread_choice_records(records: Array) -> void:
	hidden_thread_choice_records.clear()
	for record_value in records:
		if typeof(record_value) == TYPE_DICTIONARY:
			var record: Dictionary = record_value
			hidden_thread_choice_records.append(record.duplicate(true))


func get_hidden_thread_consequence_events() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for event in hidden_thread_consequence_events:
		rows.append(event.duplicate(true))
	return rows


func replace_hidden_thread_consequence_events(events: Array) -> void:
	hidden_thread_consequence_events.clear()
	for event_value in events:
		if typeof(event_value) == TYPE_DICTIONARY:
			var event: Dictionary = event_value
			hidden_thread_consequence_events.append(event.duplicate(true))


func get_hidden_consequence_summary_text() -> String:
	var lines: Array[String] = [
		HiddenConsequenceRulesPolicy.get_summary_text(get_hidden_thread_consequence_events()),
		"Hidden state: supplier access %d, customer trust %d, inspection risk %d, story %s" % [
			supplier_access_score,
			customer_trust_score,
			inspection_risk_score,
			hidden_story_state,
		],
	]
	return "\n".join(lines)


func can_ignore_hidden_thread_for_progression() -> bool:
	return true


func is_hidden_thread_blocking_retail_loop() -> bool:
	return false


func get_hidden_optionality_summary_text() -> String:
	return "\n".join([
		"Hidden optionality guard:",
		"Progression required: no",
		"Retail loop blocked: no",
		"Normal work remains available: receiving, pricing, stocking, register, ordering, storage, services, reports, and day progression",
	])


func replace_hidden_consequence_state(
	supplier_access: int,
	customer_trust: int,
	inspection_risk: int,
	story_state: String
) -> void:
	supplier_access_score = supplier_access
	customer_trust_score = customer_trust
	inspection_risk_score = inspection_risk
	hidden_story_state = story_state


func record_security_placeholder(placeholder_id: String, reference_id: String = "", notes: String = "") -> Dictionary:
	var storage := _get_evidence_storage()
	if storage == null or not storage.has_method("record_security_placeholder"):
		return {}

	var record: Dictionary = storage.call("record_security_placeholder", placeholder_id, reference_id, notes)
	return record


func get_total_preorder_deposit_cents() -> int:
	if not preorder_deposits.is_empty():
		var total := 0
		for preorder in preorder_deposits:
			total += int(preorder.get("deposit_cents", 0))
		return total

	var ledger := _get_ledger()
	if ledger == null or not ledger.has_method("get_total_preorder_deposit_cents"):
		return 0

	return ledger.get_total_preorder_deposit_cents()


func get_transactions() -> Array[Dictionary]:
	var ledger := _get_ledger()
	if ledger == null:
		return []

	return ledger.get_transactions()


func get_last_transaction() -> Dictionary:
	var transactions := get_transactions()
	if transactions.is_empty():
		return {}

	return transactions[transactions.size() - 1]


func get_recent_activity_text(max_entries: int = 4) -> String:
	var transactions := get_transactions()
	if transactions.is_empty():
		return "Recent activity: none"

	var lines: Array[String] = ["Recent activity:"]
	var index := transactions.size() - 1
	var remaining := max_entries
	while index >= 0 and remaining > 0:
		lines.append(_format_transaction_line(transactions[index]))
		index -= 1
		remaining -= 1

	return "\n".join(lines)


func get_active_inventory_items() -> Array[Node]:
	var items: Array[Node] = []
	var root := _get_inventory_root()
	if root == null:
		return items

	_collect_active_inventory_items(root, items)
	return items


func get_inventory_summary_text() -> String:
	var counts := {}
	for item in get_active_inventory_items():
		var product := item.get("product") as ProductDefinition
		if product == null:
			continue

		var key := product.display_name
		counts[key] = int(counts.get(key, 0)) + 1

	if counts.is_empty():
		return "Inventory: none"

	var lines: Array[String] = ["Inventory:"]
	var names := counts.keys()
	names.sort()
	for name in names:
		lines.append("%s x%d" % [name, int(counts[name])])
	lines.append(get_storage_workflow_summary_text())
	return "\n".join(lines)


func get_storage_movements() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for movement in storage_movements:
		rows.append(movement.duplicate(true))
	return rows


func replace_storage_movements(movements: Array) -> void:
	storage_movements.clear()
	for movement in movements:
		if typeof(movement) == TYPE_DICTIONARY:
			var row: Dictionary = movement
			storage_movements.append(row.duplicate(true))


func get_storage_capacity() -> int:
	if has_store_expansion():
		return EXPANDED_STORAGE_CAPACITY
	if has_upgrade("upgrade_backroom_storage"):
		return UPGRADED_STORAGE_CAPACITY
	return BASE_STORAGE_CAPACITY


func get_storage_status_counts() -> Dictionary:
	var counts := {
		"receiving": 0,
		"backstock": 0,
		"shelf": 0,
		"other": 0,
	}
	for item in get_active_inventory_items():
		var location_id := str(item.get("location_id"))
		if _is_receiving_location(location_id):
			counts["receiving"] = int(counts["receiving"]) + 1
		elif _is_storage_location(location_id):
			counts["backstock"] = int(counts["backstock"]) + 1
		elif location_id.begins_with("shelf_slot"):
			counts["shelf"] = int(counts["shelf"]) + 1
		else:
			counts["other"] = int(counts["other"]) + 1
	return counts


func get_storage_workflow_summary_text() -> String:
	var counts := get_storage_status_counts()
	var backstock_count := int(counts.get("backstock", 0))
	var capacity := get_storage_capacity()
	var overflow := maxi(0, backstock_count - capacity)
	var lines: Array[String] = ["Storage workflow:"]
	lines.append("Storage shelf: Backroom backstock shelf / %s" % STORAGE_LOCATION_ID)
	lines.append("Capacity: %d cases%s" % [
		capacity,
		" (store expansion)" if has_store_expansion() else " (expanded)" if has_upgrade("upgrade_backroom_storage") else "",
	])
	lines.append("Receiving ready: %d" % int(counts.get("receiving", 0)))
	lines.append("Backstock: %d stored / %d capacity / %d overflow" % [
		backstock_count,
		capacity,
		overflow,
	])
	lines.append("Sales floor shelf: %d" % int(counts.get("shelf", 0)))
	if storage_movements.is_empty():
		lines.append("Recent storage move: none")
	else:
		var last_movement := storage_movements[storage_movements.size() - 1]
		lines.append("Recent storage move: %s %s from %s to %s" % [
			str(last_movement.get("action", "moved")),
			str(last_movement.get("display_name", "item")),
			str(last_movement.get("from_location", "unknown")),
			str(last_movement.get("to_location", "unknown")),
		])
	return "\n".join(lines)


func can_store_receiving_item() -> bool:
	return not is_day_closed \
		and _find_first_inventory_item_by_locations(["receiving_box_001", "receiving_box"]) != null


func store_receiving_item_to_backstock() -> Dictionary:
	if not can_store_receiving_item():
		return {}

	var item := _find_first_inventory_item_by_locations(["receiving_box_001", "receiving_box"])
	var shelf := _get_or_create_storage_shelf()
	if item == null or shelf == null:
		return {}

	var from_location := str(item.get("location_id"))
	_reparent_inventory_item(item, shelf)
	item.set("location_id", STORAGE_LOCATION_ID)
	_position_storage_item(item, _count_product_children(shelf) - 1)
	return _record_storage_movement(item, "stored", from_location, STORAGE_LOCATION_ID)


func can_retrieve_backstock_item() -> bool:
	return not is_day_closed \
		and _find_first_inventory_item_by_locations([STORAGE_LOCATION_ID, "storage", "backroom"]) != null \
		and _get_receiving_box() != null


func retrieve_backstock_item_to_receiving() -> Dictionary:
	if not can_retrieve_backstock_item():
		return {}

	var item := _find_first_inventory_item_by_locations([STORAGE_LOCATION_ID, "storage", "backroom"])
	var receiving_box := _get_receiving_box()
	if item == null or receiving_box == null:
		return {}

	var from_location := str(item.get("location_id"))
	_reparent_inventory_item(item, receiving_box)
	item.set("location_id", "receiving_box_001")
	_position_delivered_item(item, _count_product_children(receiving_box) - 1)
	return _record_storage_movement(item, "retrieved", from_location, "receiving_box_001")


func get_reorder_suggestions_text() -> String:
	var sold_counts := {}
	var active_counts := {}
	var display_names := {}

	for transaction in get_transactions():
		if str(transaction.get("type", "sale")) != "sale":
			continue

		var product_id := str(transaction.get("product_id", ""))
		if product_id.is_empty():
			continue

		sold_counts[product_id] = int(sold_counts.get(product_id, 0)) + 1
		display_names[product_id] = str(transaction.get("display_name", product_id))

	for item in get_active_inventory_items():
		var product := item.get("product") as ProductDefinition
		if product == null or product.product_id.is_empty():
			continue

		active_counts[product.product_id] = int(active_counts.get(product.product_id, 0)) + 1
		display_names[product.product_id] = product.display_name

	var product_ids := sold_counts.keys()
	product_ids.sort()
	var lines: Array[String] = ["Reorder suggestions:"]
	for product_id in product_ids:
		var sold_count := int(sold_counts[product_id])
		var active_count := int(active_counts.get(product_id, 0))
		if active_count <= sold_count:
			lines.append("Restock %s (sold %d, active %d)" % [
				str(display_names.get(product_id, product_id)),
				sold_count,
				active_count,
			])

	if lines.size() == 1:
		return "Reorder suggestions: none"

	return "\n".join(lines)


func get_category_demand_summary_text() -> String:
	var lines: Array[String] = CategoryDemandPolicy.get_summary_lines()
	lines.append(CategoryDemandPolicy.get_tuning_summary_text())
	lines.append(get_layout_effect_summary_text())
	for line in get_active_inventory_demand_tuning_lines(3):
		lines.append(line)
	return "\n".join(lines)


func get_active_inventory_demand_tuning_lines(max_items: int = 3) -> Array[String]:
	var lines: Array[String] = []
	var seen_products := {}
	for item in get_active_inventory_items():
		if lines.size() >= max_items:
			break
		var product := item.get("product") as ProductDefinition
		if product == null or seen_products.has(product.product_id):
			continue

		seen_products[product.product_id] = true
		var context := {
			"shelf_visibility": _get_item_shelf_visibility(item),
			"marketing": _get_item_marketing_signal(item, product),
			"event": _get_day_demand_event(),
			"customer_archetype": "regular",
			"layout": _get_layout_demand_signal_for_item(item, product),
			"price_cents": int(item.get("current_price_cents")),
		}
		lines.append(CategoryDemandPolicy.get_context_summary_line(product, context))
	return lines


func get_market_drift_summary_text() -> String:
	var products: Array[ProductDefinition] = []
	for item in get_active_inventory_items():
		var product := item.get("product") as ProductDefinition
		if product != null:
			products.append(product)

	return MarketDriftPolicy.format_summary_for_products(products, day_number)


func get_daily_report_text() -> String:
	return DailyReportPolicy.format_report(self)


func get_available_fixture_definitions() -> Array[Resource]:
	var fixtures: Array[Resource] = []
	for path in DEFAULT_FIXTURE_CATALOG_PATHS:
		var fixture := load(path) as Resource
		if fixture != null:
			fixtures.append(fixture)
	return fixtures


func get_available_supplier_lots() -> Array[Resource]:
	var lots: Array[Resource] = []
	for path in DEFAULT_SUPPLIER_LOT_PATHS:
		var lot := load(path) as Resource
		if lot != null:
			lots.append(lot)
	return lots


func get_release_calendar() -> Array[Resource]:
	var releases: Array[Resource] = []
	for path in DEFAULT_RELEASE_CALENDAR_PATHS:
		var release := load(path) as Resource
		if release != null:
			releases.append(release)

	releases.sort_custom(func(a: Resource, b: Resource) -> bool:
		var day_a := int(a.get("release_day"))
		var day_b := int(b.get("release_day"))
		if day_a == day_b:
			return str(a.get("product_name")) < str(b.get("product_name"))
		return day_a < day_b
	)
	return releases


func get_upcoming_releases(include_released: bool = false) -> Array[Resource]:
	var upcoming: Array[Resource] = []
	for release in get_release_calendar():
		if include_released or int(release.get("release_day")) >= day_number:
			upcoming.append(release)
	return upcoming


func get_release_calendar_text(max_entries: int = 3) -> String:
	var upcoming := get_upcoming_releases(false)
	if upcoming.is_empty():
		return "Release calendar: no upcoming launches"

	var lines: Array[String] = ["Release calendar:"]
	var remaining := max_entries
	for release in upcoming:
		if remaining <= 0:
			break
		if release.has_method("format_calendar_line"):
			lines.append(release.call("format_calendar_line", day_number))
		else:
			lines.append("Day %d: %s - %s - MSRP %s" % [
				int(release.get("release_day")),
				str(release.get("product_name")),
				str(release.get("platform")),
				format_money(int(release.get("suggested_price_cents"))),
			])
		if release.has_method("format_planning_line"):
			lines.append("Plan: %s" % str(release.call("format_planning_line", day_number)))
		remaining -= 1

	return "\n".join(lines)


func get_release_by_id(release_id: String) -> Resource:
	for release in get_release_calendar():
		if str(release.get("release_id")) == release_id:
			return release
	return null


func get_preorder_summary_text() -> String:
	var preorders := get_preorder_deposits()
	if preorders.is_empty():
		return "Preorders: none"

	var lines: Array[String] = ["Preorders:"]
	for preorder in preorders:
		var status := str(preorder.get("status", "pending"))
		if status == "fulfilled":
			lines.append("%s preorder fulfilled day %d for %s" % [
				str(preorder.get("product_name", preorder.get("display_name", "Release"))),
				int(preorder.get("fulfilled_day", preorder.get("release_day", 0))),
				str(preorder.get("customer_id", "customer")),
			])
		elif status == "missed":
			lines.append("%s preorder missed day %d for %s" % [
				str(preorder.get("product_name", preorder.get("display_name", "Release"))),
				int(preorder.get("missed_day", preorder.get("release_day", 0))),
				str(preorder.get("customer_id", "customer")),
			])
		else:
			lines.append("%s deposit %s due day %d for %s" % [
				str(preorder.get("product_name", preorder.get("display_name", "Release"))),
				format_money(int(preorder.get("deposit_cents", 0))),
				int(preorder.get("release_day", 0)),
				str(preorder.get("customer_id", "customer")),
			])
	return "\n".join(lines)


func get_preorder_deposits() -> Array[Dictionary]:
	var preorders: Array[Dictionary] = []
	if not preorder_deposits.is_empty():
		for preorder in preorder_deposits:
			preorders.append(preorder.duplicate(true))
		return preorders

	for transaction in get_transactions():
		if str(transaction.get("type", "")) == "preorder_deposit":
			preorders.append(transaction.duplicate(true))
	return preorders


func replace_preorder_deposits(preorders: Array) -> void:
	preorder_deposits.clear()
	for preorder in preorders:
		if typeof(preorder) == TYPE_DICTIONARY:
			var row: Dictionary = preorder
			preorder_deposits.append(row.duplicate(true))


func can_commit_release_allocation(release_id: String, quantity: int = 1) -> bool:
	var release := get_release_by_id(release_id)
	if release == null or is_day_closed:
		return false
	if quantity <= 0 or int(release.get("release_day")) <= day_number:
		return false

	var wholesale_cost_cents := int(release.get("wholesale_cost_cents"))
	var allocation_limit := int(release.get("allocation_limit"))
	var remaining_allocation := allocation_limit - get_release_allocation_quantity(release_id)
	return wholesale_cost_cents > 0 \
		and allocation_limit > 0 \
		and quantity <= remaining_allocation \
		and get_cash_cents() >= wholesale_cost_cents * quantity


func commit_release_allocation(release_id: String, quantity: int = 1) -> Dictionary:
	var release := get_release_by_id(release_id)
	if release == null or not can_commit_release_allocation(release_id, quantity):
		return {}

	var wholesale_cost_cents := int(release.get("wholesale_cost_cents"))
	var total_cost_cents := wholesale_cost_cents * quantity
	cash_cents = get_cash_cents() - total_cost_cents
	var allocation := {
		"allocation_id": "release_allocation_%03d" % (release_allocations.size() + 1),
		"release_id": str(release.get("release_id")),
		"product_name": str(release.get("product_name")),
		"display_name": str(release.get("product_name")),
		"platform": str(release.get("platform")),
		"release_day": int(release.get("release_day")),
		"quantity": quantity,
		"wholesale_cost_cents": wholesale_cost_cents,
		"total_cost_cents": total_cost_cents,
		"status": "committed",
	}
	release_allocations.append(allocation)
	return allocation.duplicate(true)


func get_release_allocations() -> Array[Dictionary]:
	var allocations: Array[Dictionary] = []
	for allocation in release_allocations:
		allocations.append(allocation.duplicate(true))
	return allocations


func replace_release_allocations(allocations: Array) -> void:
	release_allocations.clear()
	for allocation in allocations:
		if typeof(allocation) == TYPE_DICTIONARY:
			var row: Dictionary = allocation
			release_allocations.append(row.duplicate(true))


func get_release_allocation_count() -> int:
	var total := 0
	for allocation in release_allocations:
		total += int(allocation.get("quantity", 0))
	return total


func get_release_allocation_quantity(release_id: String) -> int:
	var total := 0
	for allocation in release_allocations:
		if str(allocation.get("release_id", "")) == release_id:
			total += int(allocation.get("quantity", 0))
	return total


func get_total_release_allocation_cost_cents() -> int:
	var total := 0
	for allocation in release_allocations:
		total += int(allocation.get("total_cost_cents", 0))
	return total


func get_launch_events() -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	for event in launch_events:
		events.append(event.duplicate(true))
	return events


func replace_launch_events(events: Array) -> void:
	launch_events.clear()
	for event in events:
		if typeof(event) == TYPE_DICTIONARY:
			var row: Dictionary = event
			launch_events.append(row.duplicate(true))


func get_launch_event_count() -> int:
	return launch_events.size()


func get_total_launch_revenue_cents() -> int:
	var total := 0
	for event in launch_events:
		total += int(event.get("cash_received_cents", 0))
	return total


func get_total_launch_profit_cents() -> int:
	var total := 0
	for event in launch_events:
		total += int(event.get("gross_profit_cents", 0))
	return total


func get_reputation_score() -> int:
	return reputation_score


func get_reputation_events() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for event in reputation_events:
		rows.append(event.duplicate(true))
	return rows


func replace_reputation_events(events: Array) -> void:
	reputation_events.clear()
	for event in events:
		if typeof(event) == TYPE_DICTIONARY:
			var row: Dictionary = event
			reputation_events.append(row.duplicate(true))


func record_reputation_event(
	event_id: String,
	label: String,
	category: String,
	delta: int,
	metadata: Dictionary = {}
) -> Dictionary:
	if event_id.is_empty():
		event_id = "reputation_event_%03d" % (reputation_events.size() + 1)

	for event in reputation_events:
		if str(event.get("event_id", "")) == event_id:
			return event.duplicate(true)

	reputation_score = clampi(reputation_score + delta, 0, 100)
	var event := {
		"event_id": event_id,
		"label": label,
		"category": category,
		"delta": delta,
		"day_number": day_number,
		"reputation_score": reputation_score,
		"metadata": metadata.duplicate(true),
	}
	reputation_events.append(event)
	return event.duplicate(true)


func record_pricing_fairness(product_name: String, price_cents: int, market_value_cents: int) -> Dictionary:
	var limit := int(roundi(market_value_cents * 1.20))
	if market_value_cents <= 0:
		return record_reputation_event(
			"pricing_unknown_%03d" % (reputation_events.size() + 1),
			"Pricing unknown market value",
			"pricing",
			0,
			{"product_name": product_name, "price_cents": price_cents}
		)
	if price_cents > limit:
		return record_reputation_event(
			"pricing_high_%s_%d" % [product_name.to_snake_case(), day_number],
			"Over-market pricing for %s" % product_name,
			"pricing",
			-3,
			{"product_name": product_name, "price_cents": price_cents, "market_value_cents": market_value_cents}
		)
	return record_reputation_event(
		"pricing_fair_%s_%d" % [product_name.to_snake_case(), day_number],
		"Fair pricing for %s" % product_name,
		"pricing",
		1,
		{"product_name": product_name, "price_cents": price_cents, "market_value_cents": market_value_cents}
	)


func record_wait_time(customer_id: String, wait_seconds: float) -> Dictionary:
	if wait_seconds > 60.0:
		return record_reputation_event(
			"wait_long_%s_%d" % [customer_id, day_number],
			"Long register wait",
			"wait_time",
			-2,
			{"customer_id": customer_id, "wait_seconds": wait_seconds}
		)
	return record_reputation_event(
		"wait_ok_%s_%d" % [customer_id, day_number],
		"Prompt register service",
		"wait_time",
		1,
		{"customer_id": customer_id, "wait_seconds": wait_seconds}
	)


func record_preorder_outcome(product_name: String, fulfilled: bool) -> Dictionary:
	var delta := 3 if fulfilled else -5
	var label := "Preorder fulfilled" if fulfilled else "Preorder missed"
	return record_reputation_event(
		"preorder_%s_%s_%d" % ["fulfilled" if fulfilled else "missed", product_name.to_snake_case(), day_number],
		"%s: %s" % [label, product_name],
		"preorder",
		delta,
		{"product_name": product_name, "fulfilled": fulfilled}
	)


func record_service_outcome(service_name: String, success: bool) -> Dictionary:
	var delta := 2 if success else -4
	var label := "Service completed" if success else "Service failed"
	return record_reputation_event(
		"service_%s_%s_%d" % ["success" if success else "failed", service_name.to_snake_case(), day_number],
		"%s: %s" % [label, service_name],
		"service",
		delta,
		{"service_name": service_name, "success": success}
	)


func record_return_handling(outcome: String) -> Dictionary:
	var normalized := outcome.to_snake_case()
	var delta := 0
	var label := "Return handled"
	match normalized:
		"accepted_fairly":
			delta = 2
			label = "Fair return accepted"
		"rejected_unfairly":
			delta = -4
			label = "Unfair return rejection"
		_:
			delta = 0
	return record_reputation_event(
		"return_%s_%d" % [normalized, day_number],
		label,
		"returns",
		delta,
		{"outcome": normalized}
	)


func record_suspicious_choice(choice: String) -> Dictionary:
	var normalized := choice.to_snake_case()
	var delta := 0
	var label := "Suspicious choice recorded"
	match normalized:
		"accepted_suspicious_cash":
			delta = -5
			label = "Accepted suspicious cash"
		"documented_and_declined":
			delta = 2
			label = "Documented and declined suspicious offer"
		_:
			delta = 0
	return record_reputation_event(
		"suspicious_%s_%d" % [normalized, day_number],
		label,
		"suspicious",
		delta,
		{"choice": normalized}
	)


func record_stock_variety(category_count: int) -> Dictionary:
	if category_count >= 3:
		return record_reputation_event(
			"stock_variety_good_%d" % day_number,
			"Good stock variety",
			"stock_variety",
			2,
			{"category_count": category_count}
		)
	return record_reputation_event(
		"stock_variety_low_%d" % day_number,
		"Low stock variety",
		"stock_variety",
		-2,
		{"category_count": category_count}
	)


func get_reputation_summary_text(max_entries: int = 5) -> String:
	var lines: Array[String] = ["Reputation: %d" % reputation_score]
	if reputation_events.is_empty():
		lines.append("Reputation events: none")
		return "\n".join(lines)

	lines.append("Reputation events:")
	var start_index := maxi(0, reputation_events.size() - max_entries)
	for index in range(start_index, reputation_events.size()):
		var event := reputation_events[index]
		var delta := int(event.get("delta", 0))
		var delta_text := "+%d" % delta if delta > 0 else str(delta)
		lines.append("%s %s (%s)" % [
			str(event.get("label", "Event")),
			delta_text,
			str(event.get("category", "general")),
		])
	return "\n".join(lines)


func get_launch_summary_text() -> String:
	if launch_events.is_empty():
		return "Launch events: none"

	var lines: Array[String] = ["Launch events:"]
	for event in launch_events:
		lines.append("%s launch: preorders %d/%d, queue %d/%d, missed %d, cash %s, reputation %d" % [
			str(event.get("product_name", "Release")),
			int(event.get("preorder_fulfilled", 0)),
			int(event.get("preorder_count", 0)),
			int(event.get("launch_queue_fulfilled", 0)),
			int(event.get("launch_queue_demand", 0)),
			int(event.get("missed_demand", 0)),
			format_money(int(event.get("cash_received_cents", 0))),
			int(event.get("reputation_score", reputation_score)),
		])
	return "\n".join(lines)


func get_release_allocation_summary_text() -> String:
	if release_allocations.is_empty():
		return "Release allocations: none committed; use the backroom computer to reserve stock before launch day"

	var quantity_by_release := {}
	var cost_by_release := {}
	var names_by_release := {}
	var days_by_release := {}
	var status_by_release := {}
	for allocation in release_allocations:
		var release_id := str(allocation.get("release_id", ""))
		if release_id.is_empty():
			continue
		var current_quantity := int(quantity_by_release.get(release_id, 0))
		var current_cost := int(cost_by_release.get(release_id, 0))
		quantity_by_release[release_id] = current_quantity + int(allocation.get("quantity", 0))
		cost_by_release[release_id] = current_cost + int(allocation.get("total_cost_cents", 0))
		names_by_release[release_id] = str(allocation.get(
			"product_name",
			allocation.get("display_name", release_id)
		))
		days_by_release[release_id] = int(allocation.get("release_day", 0))
		status_by_release[release_id] = str(allocation.get("status", "committed"))

	var release_ids := quantity_by_release.keys()
	release_ids.sort()
	var lines: Array[String] = ["Release allocations:"]
	for release_id in release_ids:
		var status := str(status_by_release.get(release_id, "committed"))
		var status_label := "launched" if status == "launched" else "committed"
		lines.append("%s x%d %s %s due day %d; receiving holds launch stock until you stock the new-release wall" % [
			str(names_by_release.get(release_id, release_id)),
			int(quantity_by_release[release_id]),
			status_label,
			format_money(int(cost_by_release.get(release_id, 0))),
			int(days_by_release.get(release_id, 0)),
		])
	return "\n".join(lines)


func get_supplier_lot(lot_id: String) -> Resource:
	for lot in get_available_supplier_lots():
		if str(lot.get("lot_id")) == lot_id:
			return lot
	return null


func can_order_supplier_lot(lot_id: String) -> bool:
	var lot: Resource = get_supplier_lot(lot_id)
	return not is_day_closed \
		and lot != null \
		and int(lot.get("cost_cents")) > 0 \
		and get_cash_cents() >= int(lot.get("cost_cents"))


func order_supplier_lot(lot_id: String) -> Dictionary:
	var lot: Resource = get_supplier_lot(lot_id)
	if lot == null:
		return {}
	if is_day_closed or get_cash_cents() < int(lot.get("cost_cents")):
		return {}

	var cost_cents := int(lot.get("cost_cents"))
	var delivery_days := maxi(1, int(lot.get("delivery_days")))
	cash_cents = get_cash_cents() - cost_cents
	var product_paths: Array = lot.get("product_paths") as Array
	var order := {
		"order_id": "supplier_order_%03d" % (supplier_orders.size() + 1),
		"lot_id": str(lot.get("lot_id")),
		"supplier_id": str(lot.get("supplier_id")),
		"display_name": str(lot.get("display_name")),
		"category_label": _get_supplier_lot_category_label(lot),
		"cost_cents": cost_cents,
		"ordered_day": day_number,
		"due_day": day_number + delivery_days,
		"item_count": product_paths.size(),
		"delivery_days": delivery_days,
		"storage_requirement": _get_supplier_lot_storage_requirement(lot),
		"receiving_expectation": _get_supplier_lot_receiving_expectation(lot),
		"status": "pending_delivery",
	}
	supplier_orders.append(order)
	return order.duplicate(true)


func get_pending_supplier_orders() -> Array[Dictionary]:
	var orders: Array[Dictionary] = []
	for order in supplier_orders:
		if str(order.get("status", "")) == "pending_delivery":
			orders.append(order.duplicate(true))
	return orders


func get_delivered_supplier_orders() -> Array[Dictionary]:
	var orders: Array[Dictionary] = []
	for order in supplier_orders:
		if str(order.get("status", "")) == "delivered":
			orders.append(order.duplicate(true))
	return orders


func get_receiving_batches() -> Array[Dictionary]:
	var batches: Array[Dictionary] = []
	for batch in receiving_batches:
		batches.append(batch.duplicate(true))
	return batches


func get_pending_receiving_batches() -> Array[Dictionary]:
	var batches: Array[Dictionary] = []
	for batch in receiving_batches:
		if str(batch.get("status", "")) != "completed":
			batches.append(batch.duplicate(true))
	return batches


func replace_receiving_batches(batches: Array) -> void:
	receiving_batches.clear()
	for batch in batches:
		if typeof(batch) == TYPE_DICTIONARY:
			var row: Dictionary = batch
			receiving_batches.append(row.duplicate(true))


func open_receiving_batch(batch_id: String) -> Dictionary:
	var index := _find_receiving_batch_index(batch_id)
	if index < 0:
		return {}

	var batch := receiving_batches[index]
	if str(batch.get("box_status", "")) == "sealed":
		batch["box_status"] = "opened"
		batch["status"] = "opened"
		receiving_batches[index] = batch
	return batch.duplicate(true)


func check_receiving_invoice(batch_id: String) -> Dictionary:
	var index := _find_receiving_batch_index(batch_id)
	if index < 0:
		return {}

	var batch := receiving_batches[index]
	if str(batch.get("box_status", "")) == "sealed":
		batch["box_status"] = "opened"
	batch["invoice_status"] = "checked"
	batch["invoice_variance"] = int(batch.get("received_count", 0)) - int(batch.get("expected_count", 0))
	batch["status"] = "invoice_checked"
	receiving_batches[index] = batch
	return batch.duplicate(true)


func sort_receiving_batch(batch_id: String, destination: String = "price_stock") -> Dictionary:
	var index := _find_receiving_batch_index(batch_id)
	if index < 0:
		return {}

	var batch := receiving_batches[index]
	if str(batch.get("box_status", "")) == "sealed":
		batch["box_status"] = "opened"
	if str(batch.get("invoice_status", "")) != "checked":
		batch["invoice_status"] = "checked"
		batch["invoice_variance"] = int(batch.get("received_count", 0)) - int(batch.get("expected_count", 0))
	batch["sorting_status"] = "sorted"
	batch["sort_destination"] = destination
	batch["status"] = "completed"
	receiving_batches[index] = batch
	return batch.duplicate(true)


func replace_supplier_orders(orders: Array) -> void:
	supplier_orders.clear()
	for order in orders:
		if typeof(order) == TYPE_DICTIONARY:
			var row: Dictionary = order
			supplier_orders.append(row.duplicate(true))


func get_supplier_order_summary_text() -> String:
	var lines: Array[String] = ["Receiving orders:"]
	for lot in get_available_supplier_lots():
		var item_count := 0
		if lot.has_method("get_item_count"):
			item_count = int(lot.call("get_item_count"))
		var delivery_days := maxi(1, int(lot.get("delivery_days")))
		lines.append("Order %s %s (%d items to receiving, day +%d)" % [
			str(lot.get("display_name")),
			format_money(int(lot.get("cost_cents"))),
			item_count,
			delivery_days,
		])
		lines.append("Category: %s" % _get_supplier_lot_category_label(lot))
		if lot.has_method("get_order_note"):
			lines.append("Supplier note: %s" % str(lot.call("get_order_note")))
		lines.append("Cart: 1 lot / %d items" % item_count)
		lines.append("Cost: %s reserved on order" % format_money(int(lot.get("cost_cents"))))
		lines.append("Delivery: due day %d (%d day)" % [
			day_number + delivery_days,
			delivery_days,
		])
		lines.append("Storage: %s" % _get_supplier_lot_storage_requirement(lot))
		lines.append("Receiving: %s" % _get_supplier_lot_receiving_expectation(lot))
		if lot.has_method("get_invoice_note"):
			lines.append("Invoice: %s" % str(lot.call("get_invoice_note")))
		if lot.has_method("get_shelf_plan"):
			lines.append("Shelf plan: %s" % str(lot.call("get_shelf_plan")))

	var pending := get_pending_supplier_orders()
	if pending.is_empty():
		lines.append("Pending receiving: none")
	else:
		lines.append("Pending receiving:")
		for order in pending:
			lines.append("%s due to receiving day %d (%d items)" % [
				str(order.get("display_name", "Supplier lot")),
				int(order.get("due_day", day_number + 1)),
				int(order.get("item_count", 0)),
			])
			lines.append("Delivery state: pending delivery")
			lines.append("Cost reserved: %s" % format_money(int(order.get("cost_cents", 0))))
			lines.append("Storage needed: %s" % str(order.get("storage_requirement", "Receiving box intake")))
			lines.append("Receiving expectation: %s" % str(order.get("receiving_expectation", "Physical stock appears in receiving")))
			lines.append("Next action: open the receiving box, check the invoice, then sort cases for pricing")

	var delivered := get_delivered_supplier_orders()
	if not delivered.is_empty():
		lines.append("Receiving box:")
		for order in delivered:
			lines.append("%s delivered to receiving day %d" % [
				str(order.get("display_name", "Supplier lot")),
				int(order.get("delivered_day", day_number)),
			])
			lines.append("Delivery state: delivered")
			lines.append("%d items ready for pickup, pricing, and stocking" % int(order.get("item_count", 0)))
			lines.append("Next action: physically pick up cases from receiving before placing them on fixtures")

	lines.append(get_receiving_workflow_summary_text())
	return "\n".join(lines)


func get_receiving_workflow_summary_text() -> String:
	var lines: Array[String] = ["Receiving workflow:"]
	lines.append("Delivery point: Backroom receiving mat / receiving_box_001")
	lines.append("Sort lanes: price, stock, storage")
	if receiving_batches.is_empty():
		lines.append("Pending receiving work: none")
		return "\n".join(lines)

	for batch in receiving_batches:
		lines.append("%s %s" % [
			str(batch.get("display_name", "Supplier lot")),
			str(batch.get("batch_id", "receiving_batch")),
		])
		lines.append("Box: %s" % str(batch.get("box_status", "sealed")))
		lines.append("Invoice: %s expected %d received %d variance %d" % [
			str(batch.get("invoice_status", "unchecked")),
			int(batch.get("expected_count", 0)),
			int(batch.get("received_count", 0)),
			int(batch.get("invoice_variance", 0)),
		])
		lines.append("Sorting: %s -> %s" % [
			str(batch.get("sorting_status", "waiting")),
			str(batch.get("sort_destination", "unsorted")),
		])
		lines.append("Receiving state: %s" % str(batch.get("status", "pending_receiving")))
	return "\n".join(lines)


func _get_supplier_lot_category_label(lot: Resource) -> String:
	if lot != null and lot.has_method("get_category_label"):
		return str(lot.call("get_category_label"))
	return "General stock"


func _get_supplier_lot_storage_requirement(lot: Resource) -> String:
	if lot != null and lot.has_method("get_storage_requirement"):
		return str(lot.call("get_storage_requirement"))
	return "Receiving box intake before floor placement"


func _get_supplier_lot_receiving_expectation(lot: Resource) -> String:
	if lot != null and lot.has_method("get_receiving_expectation"):
		return str(lot.call("get_receiving_expectation"))
	return "Physical stock appears in receiving for pickup and placement"


func get_fixture_definition(fixture_id: String) -> Resource:
	for fixture in get_available_fixture_definitions():
		if str(fixture.get("fixture_id")) == fixture_id:
			return fixture
	return null


func can_order_fixture(fixture_id: String) -> bool:
	var fixture: Resource = get_fixture_definition(fixture_id)
	return fixture != null \
		and bool(fixture.get("placeable")) \
		and _fixture_requirements_met(fixture) \
		and get_cash_cents() >= int(fixture.get("cost_cents"))


func order_fixture(fixture_id: String) -> Dictionary:
	var fixture: Resource = get_fixture_definition(fixture_id)
	if fixture == null or not bool(fixture.get("placeable")) or not _fixture_requirements_met(fixture):
		return {}
	if get_cash_cents() < int(fixture.get("cost_cents")):
		return {}

	var cost_cents := int(fixture.get("cost_cents"))
	cash_cents = get_cash_cents() - cost_cents
	var order := {
		"order_id": "fixture_order_%03d" % (fixture_orders.size() + 1),
		"fixture_id": str(fixture.get("fixture_id")),
		"display_name": str(fixture.get("display_name")),
		"category": str(fixture.get("category")),
		"slot_category": str(fixture.get("default_slot_category")),
		"slot_count": int(fixture.get("slot_count")),
		"placement_zone": str(fixture.get("placement_zone")),
		"footprint_size": fixture.get("footprint_size"),
		"gameplay_tags": Array(fixture.get("gameplay_tags")),
		"requires_upgrade_id": str(fixture.get("requires_upgrade_id")),
		"cost_cents": cost_cents,
		"status": "pending_placement",
	}
	fixture_orders.append(order)
	var placement_manager := _get_fixture_placement_manager()
	if placement_manager != null and placement_manager.has_method("show_ghost_for_order"):
		placement_manager.show_ghost_for_order(order)
	return order.duplicate(true)


func get_pending_fixture_orders() -> Array[Dictionary]:
	var orders: Array[Dictionary] = []
	for order in fixture_orders:
		if str(order.get("status", "")) == "pending_placement":
			orders.append(order.duplicate(true))
	return orders


func can_place_pending_fixture() -> bool:
	if is_day_closed or get_pending_fixture_orders().is_empty():
		return false

	var placement_manager := _get_fixture_placement_manager()
	return placement_manager != null \
		and placement_manager.has_method("can_confirm_current_placement") \
		and placement_manager.can_confirm_current_placement()


func can_adjust_pending_fixture_placement() -> bool:
	if is_day_closed or get_pending_fixture_orders().is_empty():
		return false

	var placement_manager := _get_fixture_placement_manager()
	return placement_manager != null \
		and placement_manager.has_method("is_ghost_visible") \
		and placement_manager.is_ghost_visible()


func can_cancel_pending_fixture_placement() -> bool:
	return can_adjust_pending_fixture_placement()


func can_undo_pending_fixture_placement() -> bool:
	if not can_adjust_pending_fixture_placement():
		return false

	var placement_manager := _get_fixture_placement_manager()
	return placement_manager != null \
		and placement_manager.has_method("can_undo_adjustment") \
		and placement_manager.can_undo_adjustment()


func move_pending_fixture_placement(delta_x: int, delta_z: int) -> bool:
	if not can_adjust_pending_fixture_placement():
		return false

	var placement_manager := _get_fixture_placement_manager()
	return placement_manager.has_method("move_ghost_by_grid") \
		and placement_manager.move_ghost_by_grid(delta_x, delta_z)


func rotate_pending_fixture_placement(clockwise: bool = true) -> bool:
	if not can_adjust_pending_fixture_placement():
		return false

	var placement_manager := _get_fixture_placement_manager()
	return placement_manager.has_method("rotate_ghost") \
		and placement_manager.rotate_ghost(clockwise)


func snap_pending_fixture_placement() -> bool:
	if not can_adjust_pending_fixture_placement():
		return false

	var placement_manager := _get_fixture_placement_manager()
	return placement_manager.has_method("snap_ghost_to_grid") \
		and placement_manager.snap_ghost_to_grid()


func undo_pending_fixture_placement() -> bool:
	if not can_undo_pending_fixture_placement():
		return false

	var placement_manager := _get_fixture_placement_manager()
	return placement_manager.has_method("undo_last_adjustment") \
		and placement_manager.undo_last_adjustment()


func cancel_pending_fixture_placement() -> Dictionary:
	if not can_cancel_pending_fixture_placement():
		return {}

	var placement_manager := _get_fixture_placement_manager()
	var order_index := _find_fixture_order_index(str(placement_manager.get_current_order_id()))
	if order_index == -1:
		return {}

	var order := fixture_orders[order_index]
	cash_cents = get_cash_cents() + int(order.get("cost_cents", 0))
	order["status"] = "canceled"
	order["canceled_day"] = day_number
	fixture_orders[order_index] = order
	if placement_manager.has_method("cancel_current_placement"):
		placement_manager.cancel_current_placement()
	else:
		placement_manager.hide_ghost()
	return order.duplicate(true)


func place_pending_fixture(parent: Node = null) -> Dictionary:
	if not can_place_pending_fixture():
		return {}

	var placement_manager := _get_fixture_placement_manager()
	var order_index := _find_fixture_order_index(str(placement_manager.get_current_order_id()))
	if order_index == -1:
		return {}

	var order := fixture_orders[order_index]
	var fixture := get_fixture_definition(str(order.get("fixture_id", "")))
	if fixture == null:
		return {}

	var scene_path := str(fixture.get("scene_path"))
	if scene_path.is_empty():
		return {}

	var fixture_parent := parent
	if fixture_parent == null:
		fixture_parent = _get_inventory_root()
	if fixture_parent == null:
		fixture_parent = get_parent()
	if fixture_parent == null:
		return {}

	var placed_node := placement_manager.confirm_current_placement(fixture_parent, scene_path) as Node3D
	if placed_node == null:
		return {}

	order["status"] = "placed"
	order["placed_node_path"] = str(placed_node.get_path())
	order["placed_position"] = placed_node.global_position
	order["placed_rotation_y"] = placed_node.global_rotation.y
	fixture_orders[order_index] = order
	_apply_fixture_category_to_node(placed_node, order)
	placed_fixtures.append(order.duplicate(true))
	return order.duplicate(true)


func get_placed_fixture_orders() -> Array[Dictionary]:
	var orders: Array[Dictionary] = []
	for order in fixture_orders:
		if str(order.get("status", "")) == "placed":
			orders.append(order.duplicate(true))
	return orders


func replace_fixture_orders(orders: Array) -> void:
	fixture_orders.clear()
	placed_fixtures.clear()
	fixture_slot_categories.clear()
	for order in orders:
		if typeof(order) == TYPE_DICTIONARY:
			var row: Dictionary = order
			fixture_orders.append(row.duplicate(true))
			if str(row.get("status", "")) == "placed":
				placed_fixtures.append(row.duplicate(true))


func get_fixture_order_summary_text() -> String:
	var fixtures := get_available_fixture_definitions()
	var lines: Array[String] = ["Storage fixtures:"]
	for fixture in fixtures:
		var locked_note := ""
		if not _fixture_requirements_met(fixture):
			locked_note = " locked:%s" % str(fixture.get("requires_upgrade_id"))
		lines.append("Order %s %s for storage placement (%s, slots:%d, zone:%s%s)" % [
			str(fixture.get("display_name")),
			format_money(int(fixture.get("cost_cents"))),
			str(fixture.get("category")),
			int(fixture.get("slot_count")),
			str(fixture.get("placement_zone")),
			locked_note,
		])

	var pending := get_pending_fixture_orders()
	if pending.is_empty():
		lines.append("Pending storage placement: none")
	else:
		lines.append("Pending storage placement:")
		for order in pending:
			lines.append("%s %s slots:%s count:%d zone:%s" % [
				str(order.get("display_name", "Fixture")),
				format_money(int(order.get("cost_cents", 0))),
				str(order.get("slot_category", "unassigned")),
				int(order.get("slot_count", 0)),
				str(order.get("placement_zone", "sales_floor")),
			])
		var placement_manager := _get_fixture_placement_manager()
		if placement_manager != null and placement_manager.has_method("get_placement_summary_text"):
			lines.append(str(placement_manager.get_placement_summary_text()))
			if placement_manager.has_method("get_placement_issue"):
				var issue := str(placement_manager.get_placement_issue())
				if not issue.is_empty():
					lines.append("Placement issue: %s" % issue)

	var placed := get_placed_fixture_orders()
	if not placed.is_empty():
		lines.append("Placed storage fixtures:")
		for order in placed:
			var assigned_category := str(order.get("assigned_category", order.get("slot_category", "")))
			lines.append("%s placed category:%s" % [
				str(order.get("display_name", "Fixture")),
				assigned_category,
			])
	lines.append(get_fixture_category_assignment_summary_text())

	return "\n".join(lines)


func can_assign_fixture_category(order_id: String, category: String) -> bool:
	if is_day_closed:
		return false

	var order_index := _find_fixture_order_index(order_id)
	if order_index == -1:
		return false

	var order := fixture_orders[order_index]
	if not ["pending_placement", "placed"].has(str(order.get("status", ""))):
		return false

	return _get_assignable_fixture_categories(order).has(_normalize_fixture_category(category))


func assign_fixture_category(order_id: String, category: String) -> Dictionary:
	var normalized_category := _normalize_fixture_category(category)
	if not can_assign_fixture_category(order_id, normalized_category):
		return {}

	var order_index := _find_fixture_order_index(order_id)
	var order := fixture_orders[order_index]
	order["assigned_category"] = normalized_category
	order["slot_category"] = normalized_category
	order["category_assigned_day"] = day_number
	fixture_orders[order_index] = order

	var placed_node := _get_placed_fixture_node(order)
	if placed_node != null:
		_apply_fixture_category_to_node(placed_node, order)

	_refresh_placed_fixture_cache()
	return order.duplicate(true)


func can_assign_first_fixture_category(category: String = "new_game") -> bool:
	var order := _get_first_assignable_fixture_order(category)
	return not order.is_empty()


func assign_first_fixture_category(category: String = "new_game") -> Dictionary:
	var order := _get_first_assignable_fixture_order(category)
	if order.is_empty():
		return {}

	return assign_fixture_category(str(order.get("order_id", "")), category)


func get_fixture_slot_categories() -> Dictionary:
	return fixture_slot_categories.duplicate(true)


func get_fixture_category_assignment_summary_text() -> String:
	var lines: Array[String] = ["Fixture category assignments:"]
	var assigned := false
	for order in fixture_orders:
		var assigned_category := str(order.get("assigned_category", ""))
		if assigned_category.is_empty():
			continue
		assigned = true
		lines.append("%s -> %s (%d slots)" % [
			str(order.get("display_name", "Fixture")),
			assigned_category,
			int(order.get("slot_count", 0)),
		])
	if not assigned:
		lines.append("none")
	return "\n".join(lines)


func get_decoration_catalog() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for decoration in DECORATION_CATALOG:
		rows.append(decoration.duplicate(true))
	return rows


func get_purchased_decorations() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for decoration in purchased_decorations:
		rows.append(decoration.duplicate(true))
	return rows


func replace_purchased_decorations(decorations: Array) -> void:
	purchased_decorations.clear()
	for decoration in decorations:
		if typeof(decoration) == TYPE_DICTIONARY:
			var row: Dictionary = decoration
			purchased_decorations.append(row.duplicate(true))


func has_decoration(decoration_id: String) -> bool:
	for decoration in purchased_decorations:
		if str(decoration.get("decoration_id", "")) == decoration_id:
			return true
	return false


func can_apply_decoration(decoration_id: String) -> bool:
	if is_day_closed or has_decoration(decoration_id):
		return false

	var decoration := _get_decoration_definition(decoration_id)
	if decoration.is_empty():
		return false

	var clutter_after := get_used_clutter_budget_points() + int(decoration.get("clutter_points", 0))
	return get_cash_cents() >= int(decoration.get("cost_cents", 0)) \
		and clutter_after <= get_clutter_budget_points()


func apply_decoration(decoration_id: String) -> Dictionary:
	if not can_apply_decoration(decoration_id):
		return {}

	var decoration := _get_decoration_definition(decoration_id)
	cash_cents = get_cash_cents() - int(decoration.get("cost_cents", 0))
	var purchase := decoration.duplicate(true)
	purchase["applied_day"] = day_number
	purchase["status"] = "applied"
	purchased_decorations.append(purchase)
	return purchase.duplicate(true)


func get_clutter_budget_points() -> int:
	var budget := BASE_CLUTTER_BUDGET_POINTS
	for decoration in purchased_decorations:
		var points := int(decoration.get("clutter_points", 0))
		if points < 0:
			budget += abs(points)
	return budget


func get_used_clutter_budget_points() -> int:
	var used := 0
	for decoration in purchased_decorations:
		used += max(0, int(decoration.get("clutter_points", 0)))
	return used


func get_decoration_summary_text() -> String:
	var lines: Array[String] = ["Decorations:"]
	lines.append("Clutter budget: %d used / %d safe points" % [
		get_used_clutter_budget_points(),
		get_clutter_budget_points(),
	])
	if purchased_decorations.is_empty():
		lines.append("Applied: none")
	else:
		var applied_labels: Array[String] = []
		for decoration in purchased_decorations:
			applied_labels.append(str(decoration.get("label", "Decoration")))
		lines.append("Applied: %s" % ", ".join(applied_labels))

	lines.append("Available:")
	for decoration in DECORATION_CATALOG:
		var lock_text := "applied" if has_decoration(str(decoration.get("decoration_id", ""))) else "ready"
		lines.append("%s %s (%s/%s, clutter %d, %s): %s" % [
			str(decoration.get("label", "Decoration")),
			format_money(int(decoration.get("cost_cents", 0))),
			str(decoration.get("category", "decor")),
			str(decoration.get("surface", "store")),
			int(decoration.get("clutter_points", 0)),
			lock_text,
			str(decoration.get("effect", "")),
		])
	return "\n".join(lines)


func get_layout_effects() -> Dictionary:
	var tag_counts := _get_placed_fixture_tag_counts()
	var customer_metrics := _get_customer_layout_metrics()
	var visibility_count := int(tag_counts.get("browse_visibility", 0)) \
		+ int(tag_counts.get("wall_visibility", 0)) \
		+ int(tag_counts.get("launch_visibility", 0)) \
		+ int(tag_counts.get("register_visibility", 0))
	var impulse_count := int(tag_counts.get("impulse_browse", 0)) \
		+ int(tag_counts.get("checkout_impulse", 0))
	if has_decoration("decor_poster_launch_set"):
		visibility_count += 1
	if has_decoration("decor_signage_counter_refresh") or has_decoration("decor_controller_display_prop"):
		impulse_count += 1

	var theft_risk_state := _get_theft_risk_state(tag_counts)
	var queue_state := str(customer_metrics.get("queue_state", "unwired"))
	var travel_state := str(customer_metrics.get("travel_state", "unknown"))
	var layout_signal := _get_layout_signal(queue_state, travel_state, theft_risk_state, visibility_count, impulse_count)

	return {
		"layout_signal": layout_signal,
		"visibility_fixture_count": visibility_count,
		"impulse_fixture_count": impulse_count,
		"launch_visibility_count": int(tag_counts.get("launch_visibility", 0)),
		"queue_state": queue_state,
		"queue_spacing": float(customer_metrics.get("queue_spacing", 0.0)),
		"travel_state": travel_state,
		"average_travel_distance": float(customer_metrics.get("average_travel_distance", 0.0)),
		"theft_risk_state": theft_risk_state,
		"path_issue_count": (customer_metrics.get("path_issues", []) as Array).size(),
	}


func get_layout_effect_summary_text() -> String:
	var effects := get_layout_effects()
	return "Layout effects: %s, visibility %d, impulse %d, queue %s, travel %s %0.1fm, theft %s" % [
		str(effects.get("layout_signal", "balanced")),
		int(effects.get("visibility_fixture_count", 0)),
		int(effects.get("impulse_fixture_count", 0)),
		str(effects.get("queue_state", "unwired")),
		str(effects.get("travel_state", "unknown")),
		float(effects.get("average_travel_distance", 0.0)),
		str(effects.get("theft_risk_state", "standard_placeholder")),
	]


func _fixture_requirements_met(fixture: Resource) -> bool:
	if fixture == null:
		return false

	var required_upgrade_id := str(fixture.get("requires_upgrade_id"))
	return required_upgrade_id.is_empty() or has_upgrade(required_upgrade_id)


func _normalize_fixture_category(category: String) -> String:
	return category.strip_edges().to_lower()


func _get_assignable_fixture_categories(order: Dictionary) -> Array[String]:
	var fixture := get_fixture_definition(str(order.get("fixture_id", "")))
	var categories: Array[String] = []
	if fixture != null:
		for category in Array(fixture.get("accepted_product_categories")):
			_append_unique_string(categories, _normalize_fixture_category(str(category)))
		_append_unique_string(categories, _normalize_fixture_category(str(fixture.get("default_slot_category"))))
	_append_unique_string(categories, _normalize_fixture_category(str(order.get("slot_category", ""))))
	return categories


func _append_unique_string(values: Array[String], value: String) -> void:
	if value.is_empty() or values.has(value):
		return
	values.append(value)


func _get_first_assignable_fixture_order(category: String) -> Dictionary:
	var normalized_category := _normalize_fixture_category(category)
	for order in fixture_orders:
		if str(order.get("status", "")) != "placed":
			continue
		if _get_assignable_fixture_categories(order).has(normalized_category):
			return order.duplicate(true)
	for order in fixture_orders:
		if str(order.get("status", "")) != "pending_placement":
			continue
		if _get_assignable_fixture_categories(order).has(normalized_category):
			return order.duplicate(true)
	return {}


func _get_placed_fixture_node(order: Dictionary) -> Node3D:
	var path_text := str(order.get("placed_node_path", ""))
	if path_text.is_empty():
		return null
	return get_node_or_null(NodePath(path_text)) as Node3D


func _apply_fixture_category_to_node(fixture_node: Node, order: Dictionary) -> void:
	if fixture_node == null:
		return

	var category := _normalize_fixture_category(str(order.get("assigned_category", order.get("slot_category", ""))))
	if category.is_empty():
		return

	var slots: Array[Node] = []
	_collect_shelf_slots(fixture_node, slots)
	for slot in slots:
		if slot.has_method("assign_category"):
			slot.assign_category(category)
		else:
			slot.set("accepted_category", category)

		var slot_id := str(slot.get("slot_id"))
		if slot_id.is_empty():
			slot_id = slot.name
		fixture_slot_categories[slot_id] = category


func _collect_shelf_slots(node: Node, slots: Array[Node]) -> void:
	if node is ShelfSlot:
		slots.append(node)
	for child in node.get_children():
		_collect_shelf_slots(child, slots)


func _refresh_placed_fixture_cache() -> void:
	placed_fixtures.clear()
	for order in fixture_orders:
		if str(order.get("status", "")) == "placed":
			placed_fixtures.append(order.duplicate(true))


func _get_decoration_definition(decoration_id: String) -> Dictionary:
	for decoration in DECORATION_CATALOG:
		if str(decoration.get("decoration_id", "")) == decoration_id:
			return decoration.duplicate(true)
	return {}


func get_status_label() -> String:
	if is_day_closed:
		return "Day closed"

	return "Day open"


func get_summary_text() -> String:
	return "Day %d - %s | Phase: %s\nCash: %s | Reputation: %d\nSales: %d | Trade-ins: %d | Preorders: %d | Services: %d | Release allocations: %d | Launch events: %d\nRevenue: %s | Cost: %s | Profit: %s\nTrade cash: %s | Store credit: %s\nPreorder deposits: %s | Services revenue: %s | Services profit: %s\nAllocation cost: %s | Launch cash: %s | Launch profit: %s\nOperating expenses: %s | Reserved obligations: %s" % [
		day_number,
		get_status_label(),
		get_day_phase_label(),
		format_money(get_cash_cents()),
		get_reputation_score(),
		get_sale_count(),
		get_trade_in_count(),
		get_preorder_deposit_count(),
		get_service_count(),
		get_release_allocation_count(),
		get_launch_event_count(),
		format_money(get_total_revenue_cents()),
		format_money(get_total_cost_cents()),
		format_money(get_total_profit_cents()),
		format_money(get_total_trade_in_cost_cents()),
		format_money(get_total_trade_in_credit_cents()),
		format_money(get_total_preorder_deposit_cents()),
		format_money(get_total_service_revenue_cents()),
		format_money(get_total_service_profit_cents()),
		format_money(get_total_release_allocation_cost_cents()),
		format_money(get_total_launch_revenue_cents()),
		format_money(get_total_launch_profit_cents()),
		format_money(get_operating_expenses_total_cents()),
		format_money(get_reserved_obligations_cents()),
	]


func format_money(cents: int) -> String:
	return "$%0.2f" % (cents / 100.0)


func _format_transaction_line(transaction: Dictionary) -> String:
	var display_name := str(transaction.get("display_name", "item"))
	match str(transaction.get("type", "sale")):
		"trade_in":
			var tender_type := str(transaction.get("tender_type", "cash"))
			if tender_type == "store_credit":
				return "Trade-in %s credit %s" % [
					display_name,
					format_money(int(transaction.get("trade_in_credit_cents", 0))),
				]

			return "Trade-in %s offer %s" % [
				display_name,
				format_money(int(transaction.get(
					"trade_in_cash_cents",
					transaction.get("trade_in_cost_cents", 0)
				))),
			]
		"preorder_deposit":
			return "Preorder %s deposit %s" % [
				display_name,
				format_money(int(transaction.get("deposit_cents", 0))),
			]
		"service":
			return "Service %s for %s %s profit %s" % [
				display_name,
				str(transaction.get("item_name", "item")),
				format_money(int(transaction.get("service_price_cents", 0))),
				format_money(int(transaction.get("profit_cents", 0))),
			]
		_:
			return "Sale %s %s profit %s" % [
				display_name,
				format_money(int(transaction.get("sale_price_cents", 0))),
				format_money(int(transaction.get("profit_cents", 0))),
			]


func _get_item_shelf_visibility(item: Node) -> String:
	var location_id := str(item.get("location_id"))
	if location_id.begins_with("shelf_slot"):
		var fixture_category := _get_fixture_category_for_slot(location_id)
		match fixture_category:
			"new_game", "new_release", "launch_title":
				return "endcap"
			"bargain":
				return "low"
			"backstock":
				return "backroom"
		return "front"
	if location_id.begins_with("customer:"):
		return "front"
	if _is_receiving_location(location_id) or location_id == "held":
		return "standard"
	if _is_storage_location(location_id):
		return "backroom"
	return "standard"


func _get_item_marketing_signal(item: Node, product: ProductDefinition) -> String:
	var fixture_category := _get_fixture_category_for_slot(str(item.get("location_id")))
	var current_price := int(item.get("current_price_cents"))
	if product.market_value_cents > 0 and current_price > 0 and current_price <= int(product.market_value_cents * 0.9):
		return "sale_tag"
	if not fixture_category.is_empty() and fixture_category == _normalize_fixture_category(product.category):
		return "featured"
	if fixture_category in ["new_game", "new_release", "launch_title"] and product.category == "new_game":
		return "featured"
	if fixture_category in ["high_value", "rare_game", "collector_item"]:
		return "staff_pick"
	if fixture_category == "bargain":
		return "sale_tag"
	if product.rarity in ["rare", "collector", "launch"]:
		return "staff_pick"
	return "none"


func _get_fixture_category_for_slot(slot_id: String) -> String:
	return _normalize_fixture_category(str(fixture_slot_categories.get(slot_id, "")))


func _get_day_demand_event() -> String:
	for release in get_upcoming_releases(false):
		if int(release.get("release_day")) == day_number:
			return "launch_day"
	if day_number % 6 == 0:
		return "weekend"
	return "normal"


func _get_layout_demand_signal_for_item(item: Node, product: ProductDefinition) -> String:
	var location_id := str(item.get("location_id"))
	var fixture_category := _get_fixture_category_for_slot(location_id)
	if fixture_category == "bargain" or fixture_category == "impulse":
		return "impulse"
	if fixture_category in ["high_value", "rare_game", "collector_item"] and not _has_placed_fixture_tag("theft_risk_placeholder"):
		return "risky"
	if product != null and product.risk_level in ["medium", "high"] and not _has_placed_fixture_tag("theft_risk_placeholder"):
		return "risky"

	return str(get_layout_effects().get("layout_signal", "balanced"))


func _get_placed_fixture_tag_counts() -> Dictionary:
	var counts := {}
	for order in get_placed_fixture_orders():
		var fixture := get_fixture_definition(str(order.get("fixture_id", "")))
		if fixture == null:
			continue

		var tags: PackedStringArray = fixture.get("gameplay_tags")
		for tag in tags:
			var key := str(tag)
			counts[key] = int(counts.get(key, 0)) + 1
	return counts


func _has_placed_fixture_tag(tag: String) -> bool:
	return int(_get_placed_fixture_tag_counts().get(tag, 0)) > 0


func _get_theft_risk_state(tag_counts: Dictionary) -> String:
	if int(tag_counts.get("theft_risk_placeholder", 0)) > 0:
		return "guarded_placeholder"

	for item in get_active_inventory_items():
		var product := item.get("product") as ProductDefinition
		if product == null:
			continue
		if product.risk_level in ["medium", "high"] or product.risk_tags.has("serial_check"):
			return "open_placeholder"

	return "standard_placeholder"


func _get_layout_signal(
	queue_state: String,
	travel_state: String,
	theft_risk_state: String,
	visibility_count: int,
	impulse_count: int
) -> String:
	if queue_state in ["blocked", "tight"]:
		return "crowded"
	if travel_state == "long":
		return "long_walk"
	if theft_risk_state == "open_placeholder":
		return "risky"
	if impulse_count > 0:
		return "impulse"
	if visibility_count > 0 or queue_state == "clear" or travel_state == "efficient":
		return "efficient"
	return "balanced"


func _get_customer_layout_metrics() -> Dictionary:
	var manager := _get_customer_manager()
	if manager == null:
		return {
			"queue_state": "unwired",
			"queue_spacing": 0.0,
			"travel_state": "unknown",
			"average_travel_distance": 0.0,
			"path_issues": [],
		}

	var issues := manager.validate_customer_paths() if manager.has_method("validate_customer_paths") else []
	var queue_spacing := manager.register_queue_spacing.length()
	var minimum_queue_spacing := manager.minimum_queue_spacing_distance
	var queue_state := "clear"
	if not issues.is_empty():
		queue_state = "blocked"
	elif queue_spacing < minimum_queue_spacing:
		queue_state = "tight"
	elif queue_spacing < minimum_queue_spacing * 1.15:
		queue_state = "usable"

	var travel_distance := _get_average_customer_travel_distance(manager)
	var travel_state := "normal"
	if travel_distance <= 0.0:
		travel_state = "unknown"
	elif travel_distance <= 8.5:
		travel_state = "efficient"
	elif travel_distance >= 12.0:
		travel_state = "long"

	return {
		"queue_state": queue_state,
		"queue_spacing": queue_spacing,
		"travel_state": travel_state,
		"average_travel_distance": travel_distance,
		"path_issues": issues,
	}


func _get_average_customer_travel_distance(manager: CustomerManager) -> float:
	var customers := manager.get_customers()
	if customers.is_empty():
		return 0.0

	var total := 0.0
	var count := 0
	for index in range(customers.size()):
		var browse_position := manager._browse_position_for_index(index)
		var queue_position := manager._queue_position_for_index(index)
		for slot_path in manager.display_slot_paths:
			var slot := manager.get_node_or_null(slot_path) as Node3D
			if slot == null:
				continue
			total += browse_position.distance_to(slot.global_position) + slot.global_position.distance_to(queue_position)
			count += 1

	if count == 0:
		return 0.0
	return total / float(count)


func _apply_progression_effects() -> void:
	if not has_store_expansion():
		return

	var placement_manager := _get_fixture_placement_manager()
	if placement_manager != null:
		placement_manager.set("placement_bounds_min", EXPANDED_PLACEMENT_BOUNDS_MIN)
		placement_manager.set("placement_bounds_max", EXPANDED_PLACEMENT_BOUNDS_MAX)

	var customer_manager := _get_customer_manager()
	if customer_manager != null:
		customer_manager.playable_min = EXPANDED_CUSTOMER_PLAYABLE_MIN
		customer_manager.playable_max = EXPANDED_CUSTOMER_PLAYABLE_MAX
		customer_manager.register_queue_spacing = EXPANDED_QUEUE_SPACING
		customer_manager.minimum_queue_spacing_distance = minf(
			customer_manager.minimum_queue_spacing_distance,
			EXPANDED_QUEUE_SPACING.length()
		)
		if customer_manager.has_method("assign_customer_path_points"):
			customer_manager.assign_customer_path_points()


func _get_ledger() -> TransactionLedger:
	if ledger_path.is_empty():
		return null

	return get_node_or_null(ledger_path) as TransactionLedger


func _get_inventory_root() -> Node:
	if inventory_root_path.is_empty():
		return get_parent()

	return get_node_or_null(inventory_root_path)


func _get_receiving_box() -> Node:
	if receiving_box_path.is_empty():
		var root := _get_inventory_root()
		if root != null:
			return root.get_node_or_null("ReceivingBox")
		return null

	return get_node_or_null(receiving_box_path)


func _get_evidence_storage() -> Node:
	if evidence_storage_path.is_empty():
		return null

	return get_node_or_null(evidence_storage_path)


func _get_hidden_clue_surface_context() -> Dictionary:
	var context := {
		"has_supplier_order": not supplier_orders.is_empty(),
		"has_receiving_batch": not receiving_batches.is_empty(),
		"has_supplier_message": false,
		"has_serial_mismatch": false,
		"has_suspicious_customer": false,
		"has_security_footage_placeholder": true,
		"has_evidence_storage": false,
	}

	var first_order := _get_first_supplier_order_or_batch()
	if not first_order.is_empty():
		context["has_supplier_order"] = true
		context["supplier_email_subject"] = str(first_order.get("order_id", first_order.get("batch_id", "")))
	if not receiving_batches.is_empty():
		context["has_receiving_batch"] = true
		context["receiving_invoice_subject"] = str(receiving_batches[0].get("batch_id", "receiving_batch"))

	var supplier_message := _find_first_node_with_methods(["get_message_text", "flag_supplier_message"])
	if supplier_message != null:
		context["has_supplier_message"] = true
		context["supplier_note_subject"] = str(supplier_message.call("get_suspicious_event_id")) if supplier_message.has_method("get_suspicious_event_id") else supplier_message.name

	var serial_subject := _get_first_serial_mismatch_subject()
	if not serial_subject.is_empty():
		context["has_serial_mismatch"] = true
		context["serial_lookup_subject"] = serial_subject

	var suspicious_customer := _find_first_node_with_methods(["get_encounter_text", "flag_encounter"])
	if suspicious_customer != null:
		context["has_suspicious_customer"] = true
		context["customer_comment_subject"] = str(suspicious_customer.call("get_suspicious_event_id")) if suspicious_customer.has_method("get_suspicious_event_id") else suspicious_customer.name

	var storage := _get_evidence_storage()
	if storage != null:
		context["has_evidence_storage"] = true
		context["backroom_artifact_subject"] = "evidence_storage"
		context["security_clip_subject"] = "security_footage"

	return context


func _get_hidden_choice_context() -> Dictionary:
	var context := _get_hidden_clue_surface_context()
	context["has_clue_surface"] = _has_available_clue_surface(context)
	context["can_report_issue"] = bool(context.get("has_clue_surface", false)) \
		and bool(context.get("has_evidence_storage", false))
	context["has_supplier_thread"] = bool(context.get("has_supplier_message", false)) \
		or bool(context.get("has_supplier_order", false)) \
		or bool(context.get("has_receiving_batch", false))
	return context


func _apply_hidden_thread_consequence(choice_record: Dictionary) -> Dictionary:
	var event: Dictionary = HiddenConsequenceRulesPolicy.build_consequence_event(choice_record)
	if event.is_empty():
		return {}

	var consequence_id := str(event.get("consequence_id", "")).strip_edges()
	for existing in hidden_thread_consequence_events:
		if str(existing.get("consequence_id", "")) == consequence_id:
			return existing.duplicate(true)

	event["recorded_day"] = day_number
	hidden_thread_consequence_events.append(event)

	cash_cents += int(event.get("cash_delta_cents", 0))
	supplier_access_score = clampi(supplier_access_score + int(event.get("supplier_access_delta", 0)), 0, 100)
	customer_trust_score = clampi(customer_trust_score + int(event.get("customer_trust_delta", 0)), 0, 100)
	inspection_risk_score = clampi(inspection_risk_score + int(event.get("inspection_risk_delta", 0)), 0, 100)
	hidden_story_state = str(event.get("story_state", hidden_story_state))

	var reputation_delta := int(event.get("reputation_delta", 0))
	if reputation_delta != 0:
		record_reputation_event(
			"hidden_%s" % consequence_id,
			str(event.get("label", "Hidden consequence")),
			"hidden_thread",
			reputation_delta
		)

	return event.duplicate(true)


func _has_available_clue_surface(context: Dictionary) -> bool:
	for surface in ClueSurfaceCatalogPolicy.evaluate_context(context):
		if str(surface.get("status", "")) == "available":
			return true
	return false


func _get_first_supplier_order_or_batch() -> Dictionary:
	if not supplier_orders.is_empty():
		return supplier_orders[0].duplicate(true)
	if not receiving_batches.is_empty():
		return receiving_batches[0].duplicate(true)
	return {}


func _get_first_serial_mismatch_subject() -> String:
	for item in get_active_inventory_items():
		if item.has_method("has_serial_mismatch") and bool(item.call("has_serial_mismatch")):
			if item.has_method("get_suspicious_event_id"):
				return str(item.call("get_suspicious_event_id"))
			return item.name
	return ""


func _find_first_node_with_methods(methods: Array[String]) -> Node:
	var root := _get_inventory_root()
	if root == null:
		return null
	return _find_first_node_with_methods_recursive(root, methods)


func _find_first_node_with_methods_recursive(node: Node, methods: Array[String]) -> Node:
	var has_all_methods := true
	for method in methods:
		if not node.has_method(method):
			has_all_methods = false
			break
	if has_all_methods:
		return node

	for child in node.get_children():
		var match_node := _find_first_node_with_methods_recursive(child, methods)
		if match_node != null:
			return match_node

	return null


func _get_customer_manager() -> CustomerManager:
	if customer_manager_path.is_empty():
		return null

	return get_node_or_null(customer_manager_path) as CustomerManager


func _get_or_create_storage_shelf() -> Node:
	var root := _get_inventory_root()
	if root == null:
		return null

	var shelf := root.get_node_or_null("BackstockShelf")
	if shelf != null:
		return shelf

	var shelf_node := Node3D.new()
	shelf_node.name = "BackstockShelf"
	root.add_child(shelf_node)
	return shelf_node


func _is_receiving_location(location_id: String) -> bool:
	return location_id == "receiving_box_001" or location_id == "receiving_box"


func _is_storage_location(location_id: String) -> bool:
	return location_id == STORAGE_LOCATION_ID or location_id == "storage" or location_id == "backroom"


func _get_fixture_placement_manager() -> Node:
	if fixture_placement_manager_path.is_empty():
		return null

	return get_node_or_null(fixture_placement_manager_path)


func _find_fixture_order_index(order_id: String) -> int:
	if order_id.is_empty():
		return -1

	for index in range(fixture_orders.size()):
		if str(fixture_orders[index].get("order_id", "")) == order_id:
			return index
	return -1


func _get_upgrade_definition(upgrade_id: String) -> Dictionary:
	for upgrade in UPGRADE_CATALOG:
		if str(upgrade.get("upgrade_id", "")) == upgrade_id:
			return upgrade.duplicate(true)
	return {}


func _upgrade_requirements_met(upgrade: Dictionary) -> bool:
	var required_upgrade_id := str(upgrade.get("requires_upgrade_id", ""))
	return required_upgrade_id.is_empty() or has_upgrade(required_upgrade_id)


func _get_service_definition(service_id: String) -> Dictionary:
	for service in SERVICE_BENCH_CATALOG:
		if str(service.get("service_id", "")) == service_id and _service_requirements_met(service):
			return service.duplicate(true)
	return {}


func _service_requirements_met(service: Dictionary) -> bool:
	var required_upgrade_id := str(service.get("requires_upgrade_id", ""))
	return required_upgrade_id.is_empty() or has_upgrade(required_upgrade_id)


func _get_management_task_definition(task_id: String) -> Dictionary:
	for task in MANAGEMENT_DESK_TASKS:
		if str(task.get("task_id", "")) == task_id:
			return task.duplicate(true)
	return {}


func _get_next_pending_management_task() -> Dictionary:
	for task in MANAGEMENT_DESK_TASKS:
		if not _has_management_review(str(task.get("task_id", ""))):
			return task.duplicate(true)
	return {}


func _has_management_review(task_id: String) -> bool:
	if task_id.is_empty():
		return false
	for review in management_reviews:
		if str(review.get("task_id", "")) == task_id:
			return true
	return false


func _find_service_ticket_index(ticket_id: String = "", allow_first_workable: bool = false) -> int:
	for index in range(service_tickets.size()):
		var ticket := service_tickets[index]
		if not ticket_id.is_empty() and str(ticket.get("ticket_id", "")) == ticket_id:
			return index
		if allow_first_workable and ticket_id.is_empty():
			var status := str(ticket.get("status", "queued"))
			if status == "queued" or status == "in_progress":
				return index
	return -1


func _mark_service_ticket_picked_up(transaction: Dictionary) -> void:
	var service_id := str(transaction.get("service_id", ""))
	if service_id.is_empty():
		return

	for index in range(service_tickets.size()):
		var ticket := service_tickets[index]
		if str(ticket.get("service_id", "")) != service_id:
			continue
		var status := str(ticket.get("status", "queued"))
		if status != "ready_for_pickup" and status != "in_progress" and status != "queued":
			continue
		ticket["status"] = "picked_up"
		ticket["progress_percent"] = 100
		ticket["pickup_day"] = day_number
		ticket["transaction_id"] = str(transaction.get("transaction_id", ""))
		service_tickets[index] = ticket
		return


func _is_onboarding_step_complete(step_id: String) -> bool:
	match step_id:
		"receiving":
			return _has_inventory_left_receiving()
		"pricing":
			return _has_repriced_inventory()
		"stocking":
			return _has_stocked_inventory()
		"checkout":
			return get_sale_count() > 0
		"trade_in":
			return get_trade_in_count() > 0
		"computer":
			return not release_allocations.is_empty() \
				or not supplier_orders.is_empty() \
				or not fixture_orders.is_empty() \
				or not purchased_upgrades.is_empty() \
				or not operating_expenses.is_empty()
		"ordering":
			return not supplier_orders.is_empty()
		"closing":
			return is_day_closed or not operating_expenses.is_empty()
	return false


func _get_onboarding_status_label(status: String) -> String:
	match status:
		"done":
			return "Done"
		"next":
			return "Next"
	return "Later"


func _has_inventory_left_receiving() -> bool:
	for item in get_active_inventory_items():
		var location_id := str(item.get("location_id"))
		if not _is_receiving_location(location_id):
			return true
	return false


func _has_repriced_inventory() -> bool:
	for item in get_active_inventory_items():
		var product := item.get("product") as ProductDefinition
		if product == null:
			continue
		if int(item.get("current_price_cents")) != product.suggested_price_cents:
			return true
	return false


func _has_stocked_inventory() -> bool:
	for item in get_active_inventory_items():
		if str(item.get("location_id")).begins_with("shelf_slot"):
			return true
	return false


func _format_opening_summary(delivered_orders: Array[Dictionary], resolved_launches: Array[Dictionary]) -> String:
	return "Opening day %d: %d deliveries, %d launch events, setup ready" % [
		day_number,
		delivered_orders.size(),
		resolved_launches.size(),
	]


func _apply_end_day_cash_pressure() -> void:
	if _has_operating_expenses_for_day(day_number):
		return

	var total := 0
	for rule in get_daily_cash_pressure_rules():
		var amount := int(rule.get("amount_cents", 0))
		if amount <= 0:
			continue

		var expense := {
			"expense_id": str(rule.get("expense_id", "expense")),
			"label": str(rule.get("label", "Expense")),
			"category": str(rule.get("category", "operating")),
			"amount_cents": amount,
			"day_number": day_number,
			"status": "posted",
		}
		operating_expenses.append(expense)
		total += amount

	if total > 0:
		cash_cents = get_cash_cents() - total


func _has_operating_expenses_for_day(day: int) -> bool:
	for expense in operating_expenses:
		if int(expense.get("day_number", 0)) == day:
			return true
	return false


func _process_due_launches() -> Array[Dictionary]:
	var resolved: Array[Dictionary] = []
	for release in get_release_calendar():
		if int(release.get("release_day")) != day_number:
			continue
		var release_id := str(release.get("release_id"))
		if _has_launch_event(release_id):
			continue

		var event := _resolve_launch_event(release)
		if event.is_empty():
			continue
		launch_events.append(event)
		resolved.append(event.duplicate(true))

	return resolved


func _resolve_launch_event(release: Resource) -> Dictionary:
	var release_id := str(release.get("release_id"))
	var preorder_indexes := _get_pending_preorder_indexes(release_id)
	var allocation_quantity := _get_committed_release_allocation_quantity(release_id)
	var preorder_count := preorder_indexes.size()
	var launch_queue_demand := _get_launch_queue_demand(release)
	var suggested_price_cents := int(release.get("suggested_price_cents"))
	var wholesale_cost_cents := int(release.get("wholesale_cost_cents"))

	var remaining_allocated := allocation_quantity
	var preorder_fulfilled := mini(preorder_count, remaining_allocated)
	remaining_allocated -= preorder_fulfilled
	var queue_fulfilled := mini(launch_queue_demand, remaining_allocated)
	remaining_allocated -= queue_fulfilled

	var missed_preorders := preorder_count - preorder_fulfilled
	var missed_queue := launch_queue_demand - queue_fulfilled
	var missed_demand := missed_preorders + missed_queue
	var fulfilled_count := preorder_fulfilled + queue_fulfilled
	var preorder_balance_cents := _get_preorder_balance_cents(
		preorder_indexes,
		preorder_fulfilled,
		suggested_price_cents
	)
	var queue_revenue_cents := queue_fulfilled * suggested_price_cents
	var cash_received_cents := preorder_balance_cents + queue_revenue_cents
	var booked_sale_value_cents := fulfilled_count * suggested_price_cents
	var fulfilled_cost_cents := fulfilled_count * wholesale_cost_cents
	var gross_profit_cents := booked_sale_value_cents - fulfilled_cost_cents
	var reputation_delta := -missed_demand * 5

	cash_cents = get_cash_cents() + cash_received_cents
	if reputation_delta != 0:
		record_reputation_event(
			"launch_missed_%s_day_%d" % [release_id, day_number],
			"Missed launch demand for %s" % str(release.get("product_name")),
			"preorder",
			reputation_delta,
			{"release_id": release_id, "missed_demand": missed_demand}
		)
	_mark_preorders_for_launch(preorder_indexes, preorder_fulfilled)
	_mark_allocations_launched(release_id, fulfilled_count, remaining_allocated)

	return {
		"event_id": "launch_event_%03d" % (launch_events.size() + 1),
		"release_id": release_id,
		"product_name": str(release.get("product_name")),
		"display_name": str(release.get("product_name")),
		"platform": str(release.get("platform")),
		"release_day": day_number,
		"allocation_quantity": allocation_quantity,
		"preorder_count": preorder_count,
		"preorder_fulfilled": preorder_fulfilled,
		"launch_queue_demand": launch_queue_demand,
		"launch_queue_fulfilled": queue_fulfilled,
		"surplus_quantity": remaining_allocated,
		"missed_demand": missed_demand,
		"cash_received_cents": cash_received_cents,
		"booked_sale_value_cents": booked_sale_value_cents,
		"fulfilled_cost_cents": fulfilled_cost_cents,
		"gross_profit_cents": gross_profit_cents,
		"reputation_delta": reputation_delta,
		"reputation_score": reputation_score,
		"status": "resolved",
	}


func _has_launch_event(release_id: String) -> bool:
	for event in launch_events:
		if str(event.get("release_id", "")) == release_id:
			return true
	return false


func _get_pending_preorder_indexes(release_id: String) -> Array[int]:
	var indexes: Array[int] = []
	for index in range(preorder_deposits.size()):
		var preorder := preorder_deposits[index]
		if str(preorder.get("release_id", "")) != release_id:
			continue
		if str(preorder.get("status", "pending")) != "pending":
			continue
		indexes.append(index)
	return indexes


func _get_committed_release_allocation_quantity(release_id: String) -> int:
	var total := 0
	for allocation in release_allocations:
		if str(allocation.get("release_id", "")) != release_id:
			continue
		if str(allocation.get("status", "committed")) != "committed":
			continue
		total += int(allocation.get("quantity", 0))
	return total


func _get_launch_queue_demand(release: Resource) -> int:
	var demand := 1
	match str(release.get("demand_tier")).to_lower():
		"high":
			demand = 2
		"medium":
			demand = 1
		"low":
			demand = 0
		_:
			demand = 1

	var effects := get_layout_effects()
	var launch_visibility := int(effects.get("launch_visibility_count", 0))
	if launch_visibility > 0 or has_decoration("decor_poster_launch_set"):
		demand += 1

	var layout_signal := str(effects.get("layout_signal", "balanced"))
	if layout_signal in ["crowded", "long_walk", "risky"]:
		demand -= 1

	return maxi(0, demand)


func _get_preorder_balance_cents(
	preorder_indexes: Array[int],
	fulfilled_count: int,
	suggested_price_cents: int
) -> int:
	var total := 0
	for offset in range(mini(fulfilled_count, preorder_indexes.size())):
		var preorder := preorder_deposits[preorder_indexes[offset]]
		var deposit_cents := int(preorder.get("deposit_cents", 0))
		total += maxi(0, suggested_price_cents - deposit_cents)
	return total


func _mark_preorders_for_launch(preorder_indexes: Array[int], fulfilled_count: int) -> void:
	for offset in range(preorder_indexes.size()):
		var index := preorder_indexes[offset]
		var preorder := preorder_deposits[index]
		if offset < fulfilled_count:
			preorder["status"] = "fulfilled"
			preorder["fulfilled_day"] = day_number
		else:
			preorder["status"] = "missed"
			preorder["missed_day"] = day_number
		preorder_deposits[index] = preorder


func _mark_allocations_launched(
	release_id: String,
	fulfilled_count: int,
	surplus_quantity: int
) -> void:
	for index in range(release_allocations.size()):
		var allocation := release_allocations[index]
		if str(allocation.get("release_id", "")) != release_id:
			continue
		if str(allocation.get("status", "committed")) != "committed":
			continue

		allocation["status"] = "launched"
		allocation["launched_day"] = day_number
		allocation["fulfilled_quantity"] = fulfilled_count
		allocation["surplus_quantity"] = surplus_quantity
		release_allocations[index] = allocation


func _collect_active_inventory_items(node: Node, items: Array[Node]) -> void:
	var product := node.get("product") as ProductDefinition
	if product != null:
		var location_id := str(node.get("location_id"))
		if location_id != "sold" and not location_id.begins_with("customer:"):
			items.append(node)

	for child in node.get_children():
		_collect_active_inventory_items(child, items)


func _find_first_inventory_item_by_locations(location_ids: Array[String]) -> Node:
	for item in get_active_inventory_items():
		if location_ids.has(str(item.get("location_id"))):
			return item
	return null


func _reparent_inventory_item(item: Node, new_parent: Node) -> void:
	if item == null or new_parent == null or item.get_parent() == new_parent:
		return

	var old_parent := item.get_parent()
	if old_parent != null:
		old_parent.remove_child(item)
	new_parent.add_child(item)


func _position_storage_item(item: Node, slot_index: int) -> void:
	var item_3d := item as Node3D
	if item_3d == null:
		return

	var column := slot_index % 4
	var row := slot_index / 4
	item_3d.position = Vector3(-0.45 + (column * 0.3), 0.18 + (row * 0.16), -0.2)
	item_3d.rotation_degrees = Vector3(0.0, 12.0, 0.0)


func _record_storage_movement(item: Node, action: String, from_location: String, to_location: String) -> Dictionary:
	var product := item.get("product") as ProductDefinition
	var movement := {
		"movement_id": "storage_move_%03d" % (storage_movements.size() + 1),
		"day_number": day_number,
		"action": action,
		"instance_id": str(item.get("instance_id")),
		"product_id": product.product_id if product != null else "",
		"display_name": product.display_name if product != null else "Inventory item",
		"from_location": from_location,
		"to_location": to_location,
	}
	storage_movements.append(movement)
	return movement.duplicate(true)


func _deliver_due_supplier_orders() -> Array[Dictionary]:
	var delivered: Array[Dictionary] = []
	for index in range(supplier_orders.size()):
		var order := supplier_orders[index]
		if str(order.get("status", "")) != "pending_delivery":
			continue
		if int(order.get("due_day", day_number + 1)) > day_number:
			continue

		var items := _spawn_supplier_order_items(order)
		if items.is_empty():
			continue

		order["status"] = "delivered"
		order["delivered_day"] = day_number
		order["delivered_count"] = items.size()
		_record_receiving_batch(order, items.size())
		supplier_orders[index] = order
		delivered.append(order.duplicate(true))

	return delivered


func _spawn_supplier_order_items(order: Dictionary) -> Array[Node]:
	var receiving_box := _get_receiving_box()
	if receiving_box == null:
		return []

	var lot := get_supplier_lot(str(order.get("lot_id", "")))
	if lot == null:
		return []

	var item_scene_path := str(lot.get("item_scene_path"))
	var item_scene := load(item_scene_path) as PackedScene
	if item_scene == null:
		return []

	var product_paths: Array = lot.get("product_paths") as Array
	var spawned: Array[Node] = []
	var existing_product_count := _count_product_children(receiving_box)
	for product_path_value in product_paths:
		var product_path := str(product_path_value)
		var product := load(product_path) as ProductDefinition
		if product == null:
			continue

		var item := item_scene.instantiate() as Node3D
		if item == null:
			continue

		item.set("product", product)
		item.set("instance_id", "%s_item_%03d" % [
			str(order.get("order_id", "supplier_order")),
			spawned.size() + 1,
		])
		item.set("location_id", "receiving_box_001")
		var slot_index := existing_product_count + spawned.size()
		item.name = "DeliveredUsedGame%03d" % (slot_index + 1)
		receiving_box.add_child(item)
		_position_delivered_item(item, slot_index)
		spawned.append(item)

	return spawned


func _count_product_children(node: Node) -> int:
	var product_count := 0
	for child in node.get_children():
		var product := child.get("product") as ProductDefinition
		if product != null:
			product_count += 1
	return product_count


func _position_delivered_item(item: Node3D, slot_index: int) -> void:
	var x_positions := [-0.34, -0.11, 0.12, 0.35]
	var column := slot_index % x_positions.size()
	var row := int(slot_index / x_positions.size())
	item.position = Vector3(float(x_positions[column]), 0.2, 0.12 + float(row) * 0.13)
	item.rotation.y = deg_to_rad(-8.0 + float(column) * 5.0)


func _record_receiving_batch(order: Dictionary, received_count: int) -> void:
	if _find_receiving_batch_index(str(order.get("order_id", ""))) >= 0:
		return

	var expected_count := int(order.get("item_count", received_count))
	receiving_batches.append({
		"batch_id": str(order.get("order_id", "receiving_batch_%03d" % (receiving_batches.size() + 1))),
		"order_id": str(order.get("order_id", "")),
		"lot_id": str(order.get("lot_id", "")),
		"display_name": str(order.get("display_name", "Supplier lot")),
		"delivery_point": "receiving_box_001",
		"delivered_day": day_number,
		"expected_count": expected_count,
		"received_count": received_count,
		"box_status": "sealed",
		"invoice_status": "unchecked",
		"invoice_variance": received_count - expected_count,
		"sorting_status": "waiting",
		"sort_destination": "unsorted",
		"status": "pending_receiving",
	})


func _find_receiving_batch_index(batch_id: String) -> int:
	for index in range(receiving_batches.size()):
		var batch := receiving_batches[index]
		if str(batch.get("batch_id", "")) == batch_id or str(batch.get("order_id", "")) == batch_id:
			return index
	return -1
