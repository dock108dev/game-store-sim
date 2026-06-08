extends Node
class_name StoreSession

const CategoryDemandPolicy := preload("res://scripts/economy/category_demand.gd")
const DailyReportPolicy := preload("res://scripts/economy/daily_report.gd")
const MarketDriftPolicy := preload("res://scripts/economy/market_drift.gd")

@export var day_number: int = 1
@export var starting_cash_cents: int = 50000
@export var ledger_path: NodePath
@export var inventory_root_path: NodePath
@export var receiving_box_path: NodePath
@export var fixture_placement_manager_path: NodePath

const DEFAULT_FIXTURE_CATALOG_PATHS := [
	"res://data/fixtures/game_display_rack.tres",
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
var supplier_orders: Array[Dictionary] = []
var preorder_deposits: Array[Dictionary] = []
var release_allocations: Array[Dictionary] = []
var launch_events: Array[Dictionary] = []
var reputation_score: int = 100


func _ready() -> void:
	if cash_cents == 0:
		cash_cents = starting_cash_cents


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


func end_day() -> void:
	is_day_closed = true


func start_next_day() -> Dictionary:
	if not is_day_closed:
		return {}

	day_number += 1
	is_day_closed = false
	var delivered_orders := _deliver_due_supplier_orders()
	var resolved_launches := _process_due_launches()
	return {
		"day_number": day_number,
		"delivered_orders": delivered_orders,
		"delivered_count": delivered_orders.size(),
		"launch_events": resolved_launches,
		"launch_event_count": resolved_launches.size(),
	}


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
	return "\n".join(lines)


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
	return CategoryDemandPolicy.get_summary_text()


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
		return "Release allocations: none"

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
		lines.append("%s x%d %s %s due day %d" % [
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
		lines.append("Cart: 1 lot / %d items" % item_count)
		lines.append("Cost: %s reserved on order" % format_money(int(lot.get("cost_cents"))))
		lines.append("Delivery: due day %d (%d day)" % [
			day_number + delivery_days,
			delivery_days,
		])
		lines.append("Storage: %s" % _get_supplier_lot_storage_requirement(lot))
		lines.append("Receiving: %s" % _get_supplier_lot_receiving_expectation(lot))

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
		and get_cash_cents() >= int(fixture.get("cost_cents"))


func order_fixture(fixture_id: String) -> Dictionary:
	var fixture: Resource = get_fixture_definition(fixture_id)
	if fixture == null or not bool(fixture.get("placeable")):
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
		lines.append("Order %s %s for storage placement" % [
			str(fixture.get("display_name")),
			format_money(int(fixture.get("cost_cents"))),
		])

	var pending := get_pending_fixture_orders()
	if pending.is_empty():
		lines.append("Pending storage placement: none")
	else:
		lines.append("Pending storage placement:")
		for order in pending:
			lines.append("%s %s slots:%s" % [
				str(order.get("display_name", "Fixture")),
				format_money(int(order.get("cost_cents", 0))),
				str(order.get("slot_category", "unassigned")),
			])

	var placed := get_placed_fixture_orders()
	if not placed.is_empty():
		lines.append("Placed storage fixtures:")
		for order in placed:
			lines.append("%s placed" % str(order.get("display_name", "Fixture")))

	return "\n".join(lines)


func get_status_label() -> String:
	if is_day_closed:
		return "Day closed"

	return "Day open"


func get_summary_text() -> String:
	return "Day %d - %s\nCash: %s | Reputation: %d\nSales: %d | Trade-ins: %d | Preorders: %d | Services: %d | Release allocations: %d | Launch events: %d\nRevenue: %s | Cost: %s | Profit: %s\nTrade cash: %s | Store credit: %s\nPreorder deposits: %s | Services revenue: %s | Services profit: %s\nAllocation cost: %s | Launch cash: %s | Launch profit: %s" % [
		day_number,
		get_status_label(),
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
	reputation_score = clampi(reputation_score + reputation_delta, 0, 100)
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
	match str(release.get("demand_tier")).to_lower():
		"high":
			return 2
		"medium":
			return 1
		"low":
			return 0
		_:
			return 1


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
