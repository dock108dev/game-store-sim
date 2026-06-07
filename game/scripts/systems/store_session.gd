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


func end_day() -> void:
	is_day_closed = true


func start_next_day() -> Dictionary:
	if not is_day_closed:
		return {}

	day_number += 1
	is_day_closed = false
	var delivered_orders := _deliver_due_supplier_orders()
	return {
		"day_number": day_number,
		"delivered_orders": delivered_orders,
		"delivered_count": delivered_orders.size(),
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
		if str(transaction.get("type", "sale")) == "sale":
			total += int(transaction.get("cost_basis_cents", 0))
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
	if quantity <= 0 or int(release.get("release_day")) < day_number:
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


func get_release_allocation_summary_text() -> String:
	if release_allocations.is_empty():
		return "Release allocations: none"

	var quantity_by_release := {}
	var cost_by_release := {}
	var names_by_release := {}
	var days_by_release := {}
	for allocation in release_allocations:
		var release_id := str(allocation.get("release_id", ""))
		if release_id.is_empty():
			continue
		quantity_by_release[release_id] = int(quantity_by_release.get(release_id, 0)) + int(allocation.get("quantity", 0))
		cost_by_release[release_id] = int(cost_by_release.get(release_id, 0)) + int(allocation.get("total_cost_cents", 0))
		names_by_release[release_id] = str(allocation.get("product_name", allocation.get("display_name", release_id)))
		days_by_release[release_id] = int(allocation.get("release_day", 0))

	var release_ids := quantity_by_release.keys()
	release_ids.sort()
	var lines: Array[String] = ["Release allocations:"]
	for release_id in release_ids:
		lines.append("%s x%d committed %s due day %d" % [
			str(names_by_release.get(release_id, release_id)),
			int(quantity_by_release[release_id]),
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
		"cost_cents": cost_cents,
		"ordered_day": day_number,
		"due_day": day_number + delivery_days,
		"item_count": product_paths.size(),
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
	var lines: Array[String] = ["Supplier orders:"]
	for lot in get_available_supplier_lots():
		var item_count := 0
		if lot.has_method("get_item_count"):
			item_count = int(lot.call("get_item_count"))
		lines.append("Order %s %s (%d items, day +%d)" % [
			str(lot.get("display_name")),
			format_money(int(lot.get("cost_cents"))),
			item_count,
			maxi(1, int(lot.get("delivery_days"))),
		])

	var pending := get_pending_supplier_orders()
	if pending.is_empty():
		lines.append("Pending delivery: none")
	else:
		lines.append("Pending delivery:")
		for order in pending:
			lines.append("%s due day %d (%d items)" % [
				str(order.get("display_name", "Supplier lot")),
				int(order.get("due_day", day_number + 1)),
				int(order.get("item_count", 0)),
			])

	var delivered := get_delivered_supplier_orders()
	if not delivered.is_empty():
		lines.append("Delivered lots:")
		for order in delivered:
			lines.append("%s delivered day %d" % [
				str(order.get("display_name", "Supplier lot")),
				int(order.get("delivered_day", day_number)),
			])

	return "\n".join(lines)


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
	var lines: Array[String] = ["Fixtures:"]
	for fixture in fixtures:
		lines.append("Order %s %s" % [
			str(fixture.get("display_name")),
			format_money(int(fixture.get("cost_cents"))),
		])

	var pending := get_pending_fixture_orders()
	if pending.is_empty():
		lines.append("Pending placement: none")
	else:
		lines.append("Pending placement:")
		for order in pending:
			lines.append("%s %s slots:%s" % [
				str(order.get("display_name", "Fixture")),
				format_money(int(order.get("cost_cents", 0))),
				str(order.get("slot_category", "unassigned")),
			])

	var placed := get_placed_fixture_orders()
	if not placed.is_empty():
		lines.append("Placed fixtures:")
		for order in placed:
			lines.append("%s placed" % str(order.get("display_name", "Fixture")))

	return "\n".join(lines)


func get_status_label() -> String:
	if is_day_closed:
		return "Day closed"

	return "Day open"


func get_summary_text() -> String:
	return "Day %d\nCash: %s\nSales: %d\nTrade-ins: %d\nPreorders: %d\nRelease allocations: %d\nRevenue: %s\nCost: %s\nTrade cash: %s\nStore credit: %s\nPreorder deposits: %s\nAllocation cost: %s\nProfit: %s\n%s" % [
		day_number,
		format_money(get_cash_cents()),
		get_sale_count(),
		get_trade_in_count(),
		get_preorder_deposit_count(),
		get_release_allocation_count(),
		format_money(get_total_revenue_cents()),
		format_money(get_total_cost_cents()),
		format_money(get_total_trade_in_cost_cents()),
		format_money(get_total_trade_in_credit_cents()),
		format_money(get_total_preorder_deposit_cents()),
		format_money(get_total_release_allocation_cost_cents()),
		format_money(get_total_profit_cents()),
		get_status_label(),
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
