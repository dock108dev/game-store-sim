extends GutTest

var _panel: Node
var _session: Node
var _ledger: TransactionLedger


func before_each() -> void:
	_panel = load("res://scenes/ui/day_summary_panel.tscn").instantiate()
	_session = load("res://scripts/systems/store_session.gd").new()
	_ledger = TransactionLedger.new()
	add_child_autofree(_panel)
	add_child_autofree(_ledger)
	add_child_autofree(_session)
	_session.ledger_path = _session.get_path_to(_ledger)


func test_day_summary_panel_starts_hidden() -> void:
	assert_false(_panel.visible)
	assert_false(_panel.is_open())


func test_day_summary_panel_opens_with_cash_and_sales_fields() -> void:
	assert_true(_panel.open_for_session(_session))

	assert_true(_panel.is_open())
	assert_eq(_panel.get_active_session(), _session)
	assert_string_contains(_panel.title_label.text, "Backroom Computer")
	assert_string_contains(_panel.summary_label.text, "Cash: $500.00")
	assert_string_contains(_panel.summary_label.text, "Sales: 0")
	assert_eq(_panel.last_sale_label.text, "Recent activity: none")
	assert_eq(_panel.status_label.text, "Day open")
	assert_false(_panel.end_day_button.disabled)


func test_day_summary_panel_includes_recent_sale_activity() -> void:
	var item: Node = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(item)
	var transaction := _ledger.record_sale("customer_001", item)
	_session.apply_sale(transaction)

	assert_true(_panel.open_for_session(_session))

	assert_string_contains(_panel.summary_label.text, "Cash: $521.99")
	assert_string_contains(_panel.summary_label.text, "Revenue: $21.99")
	assert_string_contains(_panel.summary_label.text, "Profit: $12.99")
	assert_string_contains(_panel.last_sale_label.text, "Recent activity:")
	assert_string_contains(_panel.last_sale_label.text, "Sale Star Trader $21.99 profit $12.99")


func test_day_summary_panel_includes_recent_trade_in_activity() -> void:
	var customer: SimpleTradeInCustomer = load("res://scenes/customers/simple_trade_in_customer.tscn").instantiate()
	add_child_autofree(customer)
	var transaction := _ledger.record_trade_in("trade_seller_001", customer.get_trade_item(), 760)
	_session.apply_trade_in(transaction)

	assert_true(_panel.open_for_session(_session))

	assert_string_contains(_panel.summary_label.text, "Trade-ins: 1")
	assert_string_contains(_panel.summary_label.text, "Trade cash: $7.60")
	assert_string_contains(_panel.summary_label.text, "Store credit: $0.00")
	assert_string_contains(_panel.last_sale_label.text, "Trade-in Moon Escape offer $7.60")


func test_day_summary_panel_includes_store_credit_trade_in_activity() -> void:
	var customer: SimpleTradeInCustomer = load("res://scenes/customers/simple_trade_in_customer.tscn").instantiate()
	add_child_autofree(customer)
	var transaction := _ledger.record_trade_in(
		"trade_seller_001",
		customer.get_trade_item(),
		950,
		"store_credit"
	)
	_session.apply_trade_in(transaction)

	assert_true(_panel.open_for_session(_session))

	assert_string_contains(_panel.summary_label.text, "Trade-ins: 1")
	assert_string_contains(_panel.summary_label.text, "Trade cash: $0.00")
	assert_string_contains(_panel.summary_label.text, "Store credit: $9.50")
	assert_string_contains(_panel.last_sale_label.text, "Trade-in Moon Escape credit $9.50")


func test_day_summary_panel_includes_inventory_summary() -> void:
	var item: Node = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(item)
	_session.inventory_root_path = _session.get_path_to(item.get_parent())

	assert_true(_panel.open_for_session(_session))

	assert_string_contains(_panel.inventory_label.text, "Inventory:")
	assert_string_contains(_panel.inventory_label.text, "Star Trader x1")


func test_day_summary_panel_includes_reorder_suggestions() -> void:
	var root := Node3D.new()
	var sold_item: Node = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	var active_item: Node = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(root)
	root.add_child(active_item)
	add_child_autofree(sold_item)
	_session.inventory_root_path = _session.get_path_to(root)
	_ledger.record_sale("customer_001", sold_item)

	assert_true(_panel.open_for_session(_session))

	assert_string_contains(_panel.reorder_label.text, "Reorder suggestions:")
	assert_string_contains(_panel.reorder_label.text, "Restock Star Trader")


func test_day_summary_panel_end_day_updates_status() -> void:
	assert_true(_panel.open_for_session(_session))

	assert_true(_panel.end_day())

	assert_true(_session.is_day_closed)
	assert_eq(_panel.status_label.text, "Day closed")
	assert_true(_panel.end_day_button.disabled)


func test_day_summary_panel_close_hides_panel() -> void:
	assert_true(_panel.open_for_session(_session))

	assert_true(_panel.close())

	assert_false(_panel.visible)
	assert_false(_panel.is_open())
