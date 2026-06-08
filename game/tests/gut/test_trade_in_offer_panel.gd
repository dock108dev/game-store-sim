extends GutTest

const UIComponents := preload("res://scripts/ui/ui_component_library.gd")

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
	assert_true(_panel.has_ui_component_language())
	assert_true(UIComponents.audit_modal_accessibility(_panel.modal_root).get("passes"))
	assert_true(_panel.open_for_trade_in(_register, _customer))

	assert_true(_panel.is_open())
	assert_eq(_panel.get_active_customer(), _customer)
	assert_string_contains(_panel.details_label.text, "Moon Escape")
	assert_string_contains(_panel.details_label.text, "Condition: Fair")
	assert_string_contains(_panel.details_label.text, "Completeness: Loose")
	assert_string_contains(_panel.details_label.text, "Demand: Low")
	assert_string_contains(_panel.details_label.text, "Market: $18.99")
	assert_string_contains(_panel.appraisal_label.text, "Authenticity: Medium")
	assert_string_contains(_panel.appraisal_label.text, "Projected margin: $11.39")
	assert_string_contains(_panel.appraisal_label.text, "Demand: Low")
	assert_string_contains(_panel.risk_label.text, "serial untracked")
	assert_string_contains(_panel.risk_label.text, "low demand")
	assert_string_contains(_panel.risk_label.text, "fair condition")
	assert_string_contains(_panel.risk_label.text, "loose copy")
	assert_eq(_panel.offer_label.text, "Cash offer: $7.60  |  Store credit: $9.50")
	assert_eq(_panel.get_draft_offer_cents(), 760)
	assert_false(_panel.decrease_offer_button.disabled)
	assert_false(_panel.increase_offer_button.disabled)
	assert_false(_panel.accept_button.disabled)
	assert_false(_panel.store_credit_button.disabled)
	assert_false(_panel.decline_button.disabled)


func test_trade_in_offer_panel_transition_controls_mouse_and_focus() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	assert_eq(_panel.get_transition_state(), "closed")
	assert_true(_panel.open_for_trade_in(_register, _customer))

	assert_eq(_panel.get_transition_state(), "open")
	assert_eq(_panel.get_requested_mouse_mode(), Input.MOUSE_MODE_VISIBLE)
	assert_true(_panel.has_modal_focus())
	assert_eq(get_viewport().gui_get_focus_owner(), _panel.accept_button)

	assert_true(_panel.decline_offer())
	assert_eq(get_viewport().gui_get_focus_owner(), _panel.close_button)
	assert_true(_panel.close())

	assert_eq(_panel.get_transition_state(), "closed")
	assert_eq(_panel.get_requested_mouse_mode(), Input.MOUSE_MODE_CAPTURED)
	assert_false(_panel.has_modal_focus())


func test_trade_in_offer_panel_adjusts_counter_offer() -> void:
	assert_true(_panel.open_for_trade_in(_register, _customer))

	assert_true(_panel.increase_offer())

	assert_eq(_panel.get_draft_offer_cents(), 860)
	assert_eq(_panel.offer_label.text, "Cash offer: $8.60  |  Store credit: $9.50")
	assert_string_contains(_panel.appraisal_label.text, "Projected margin: $10.39")
	assert_string_contains(_panel.status_label.text, "Counter offer: $8.60")

	assert_true(_panel.decrease_offer())

	assert_eq(_panel.get_draft_offer_cents(), 760)
	assert_eq(_panel.offer_label.text, "Cash offer: $7.60  |  Store credit: $9.50")


func test_trade_in_offer_panel_accepts_offer() -> void:
	_panel.open_for_trade_in(_register, _customer)

	assert_true(_panel.accept_offer())

	assert_string_contains(_panel.status_label.text, "Bought Moon Escape")
	assert_true(_panel.accept_button.disabled)
	assert_true(_panel.store_credit_button.disabled)
	assert_true(_panel.decline_button.disabled)
	assert_eq(_ledger.get_trade_in_count(), 1)
	assert_eq(_session.get_cash_cents(), 49240)
	assert_eq(_receiving_box.get_child_count(), 1)


func test_trade_in_offer_panel_accepts_adjusted_counter_offer() -> void:
	_panel.open_for_trade_in(_register, _customer)
	_panel.increase_offer()

	assert_true(_panel.accept_offer())

	assert_string_contains(_panel.status_label.text, "Bought Moon Escape")
	assert_string_contains(_panel.status_label.text, "$8.60")
	assert_eq(_ledger.get_trade_in_count(), 1)
	assert_eq(_ledger.get_total_trade_in_cost_cents(), 860)
	assert_eq(_session.get_cash_cents(), 49140)
	assert_true(_panel.decrease_offer_button.disabled)
	assert_true(_panel.increase_offer_button.disabled)


func test_trade_in_offer_panel_accepts_store_credit() -> void:
	_panel.open_for_trade_in(_register, _customer)

	assert_true(_panel.accept_store_credit())

	assert_string_contains(_panel.status_label.text, "Bought Moon Escape")
	assert_string_contains(_panel.status_label.text, "$9.50 store credit")
	assert_eq(_ledger.get_trade_in_count(), 1)
	assert_eq(_ledger.get_total_trade_in_cost_cents(), 0)
	assert_eq(_ledger.get_total_trade_in_credit_cents(), 950)
	assert_eq(_session.get_cash_cents(), 50000)
	assert_eq(_receiving_box.get_child(0).get("cost_basis_cents"), 950)
	assert_true(_panel.accept_button.disabled)
	assert_true(_panel.store_credit_button.disabled)
	assert_true(_panel.decline_button.disabled)


func test_trade_in_offer_panel_declines_offer() -> void:
	_panel.open_for_trade_in(_register, _customer)

	assert_true(_panel.decline_offer())

	assert_string_contains(_panel.status_label.text, "Declined Moon Escape")
	assert_true(_panel.accept_button.disabled)
	assert_true(_panel.store_credit_button.disabled)
	assert_true(_panel.decline_button.disabled)
	assert_eq(_customer.state, SimpleTradeInCustomer.STATE_TRADE_DECLINED)
	assert_eq(_ledger.get_trade_in_count(), 0)
	assert_eq(_session.get_cash_cents(), 50000)


func test_trade_in_offer_panel_close_hides_panel() -> void:
	_panel.open_for_trade_in(_register, _customer)

	assert_true(_panel.close())

	assert_false(_panel.is_open())
	assert_false(_panel.visible)
