extends GutTest

var _panel: TradeInOfferPanel
var _register: RegisterWorkstation
var _customer: SimpleTradeInCustomer
var _receiving_box: Node3D
var _ledger: TransactionLedger
var _session: Node


func before_each() -> void:
	_panel = load("res://scenes/ui/trade_in_offer_panel.tscn").instantiate()
	_register = load("res://scenes/props/register_workstation.tscn").instantiate()
	_customer = load("res://scenes/customers/simple_trade_in_customer.tscn").instantiate()
	_receiving_box = Node3D.new()
	_ledger = TransactionLedger.new()
	_session = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(_panel)
	add_child_autofree(_register)
	add_child_autofree(_customer)
	add_child_autofree(_receiving_box)
	add_child_autofree(_ledger)
	add_child_autofree(_session)

	_session.ledger_path = _session.get_path_to(_ledger)
	_register.trade_in_customer_path = _register.get_path_to(_customer)
	_register.receiving_box_path = _register.get_path_to(_receiving_box)
	_register.ledger_path = _register.get_path_to(_ledger)
	_register.store_session_path = _register.get_path_to(_session)


func test_trade_in_offer_panel_opens_with_condition_market_and_offer() -> void:
	assert_true(_panel.open_for_trade_in(_register, _customer))

	assert_true(_panel.is_open())
	assert_eq(_panel.get_active_customer(), _customer)
	assert_string_contains(_panel.details_label.text, "Moon Escape")
	assert_string_contains(_panel.details_label.text, "Condition: Fair")
	assert_string_contains(_panel.details_label.text, "Demand: Low")
	assert_string_contains(_panel.details_label.text, "Market: $18.99")
	assert_eq(_panel.offer_label.text, "Cash offer: $7.60")
	assert_false(_panel.accept_button.disabled)
	assert_false(_panel.decline_button.disabled)


func test_trade_in_offer_panel_accepts_offer() -> void:
	_panel.open_for_trade_in(_register, _customer)

	assert_true(_panel.accept_offer())

	assert_string_contains(_panel.status_label.text, "Bought Moon Escape")
	assert_true(_panel.accept_button.disabled)
	assert_true(_panel.decline_button.disabled)
	assert_eq(_ledger.get_trade_in_count(), 1)
	assert_eq(_session.get_cash_cents(), 49240)
	assert_eq(_receiving_box.get_child_count(), 1)


func test_trade_in_offer_panel_declines_offer() -> void:
	_panel.open_for_trade_in(_register, _customer)

	assert_true(_panel.decline_offer())

	assert_string_contains(_panel.status_label.text, "Declined Moon Escape")
	assert_true(_panel.accept_button.disabled)
	assert_true(_panel.decline_button.disabled)
	assert_eq(_customer.state, SimpleTradeInCustomer.STATE_TRADE_DECLINED)
	assert_eq(_ledger.get_trade_in_count(), 0)
	assert_eq(_session.get_cash_cents(), 50000)


func test_trade_in_offer_panel_close_hides_panel() -> void:
	_panel.open_for_trade_in(_register, _customer)

	assert_true(_panel.close())

	assert_false(_panel.is_open())
	assert_false(_panel.visible)
