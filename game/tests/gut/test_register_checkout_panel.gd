extends GutTest

const UIComponents := preload("res://scripts/ui/ui_component_library.gd")

var _panel: Node
var _register: RegisterWorkstation
var _customer: SimpleBuyerCustomer
var _ledger: TransactionLedger
var _session: StoreSession
var _item: Node3D


func before_each() -> void:
	var rack: Node3D = load("res://scenes/props/placeholder_shelf.tscn").instantiate()
	_customer = load("res://scenes/customers/simple_buyer_customer.tscn").instantiate()
	_register = load("res://scenes/props/register_workstation.tscn").instantiate()
	_panel = load("res://scenes/ui/register_checkout_panel.tscn").instantiate()
	_ledger = TransactionLedger.new()
	_session = load("res://scripts/systems/store_session.gd").new()
	_item = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(rack)
	add_child_autofree(_customer)
	add_child_autofree(_register)
	add_child_autofree(_panel)
	add_child_autofree(_ledger)
	add_child_autofree(_session)

	var slot := rack.get_node("ShelfSlot001") as ShelfSlot
	assert_true(slot.place_item(_item))
	assert_true(_customer.claim_item_from_slot(slot))

	_session.ledger_path = _session.get_path_to(_ledger)
	_register.customer_path = _register.get_path_to(_customer)
	_register.ledger_path = _register.get_path_to(_ledger)
	_register.store_session_path = _register.get_path_to(_session)


func test_register_checkout_panel_starts_hidden_with_ui_language() -> void:
	assert_false(_panel.visible)
	assert_false(_panel.is_open())
	assert_true(_panel.has_ui_component_language())
	assert_true(UIComponents.audit_modal_accessibility(_panel.modal_root).get("passes"))


func test_register_checkout_panel_alpha_layout_is_readable() -> void:
	var panel_container := _panel.get_node("CenterContainer/PanelContainer") as Control
	assert_gte(panel_container.custom_minimum_size.x, 640.0)
	assert_gte(panel_container.custom_minimum_size.y, 500.0)
	assert_gte(_font_size(_panel.title_label), 24)
	assert_gte(_font_size(_panel.cart_label), 18)
	assert_gte(_font_size(_panel.totals_label), 18)
	assert_gte(_font_size(_panel.tender_label), 18)
	assert_gte(_font_size(_panel.return_label), 18)
	assert_gte(_font_size(_panel.status_label), 18)
	assert_gte(_panel.confirm_button.custom_minimum_size.x, 150.0)
	assert_gte(_panel.confirm_button.custom_minimum_size.y, 48.0)
	assert_gte(_panel.close_button.custom_minimum_size.x, 130.0)
	assert_gte(_panel.close_button.custom_minimum_size.y, 48.0)


func test_register_checkout_panel_opens_with_receipt_fields() -> void:
	_register.default_cash_tender_cents = 5000

	assert_true(_panel.open_for_register(_register))

	assert_true(_panel.is_open())
	assert_eq(_panel.get_active_register(), _register)
	assert_string_contains(_panel.title_label.text, "Register Checkout")
	assert_string_contains(_panel.cart_label.text, "Star Trader x1")
	assert_string_contains(_panel.totals_label.text, "Subtotal $21.99")
	assert_string_contains(_panel.totals_label.text, "Tax $0.00")
	assert_string_contains(_panel.totals_label.text, "Total $21.99")
	assert_string_contains(_panel.tender_label.text, "Cash tendered $50.00")
	assert_string_contains(_panel.tender_label.text, "Change due $28.01")
	assert_string_contains(_panel.return_label.text, "Returns: register review handles refund")
	assert_string_contains(_panel.return_label.text, "receiving review")
	assert_false(_panel.confirm_button.disabled)


func test_register_checkout_panel_transition_controls_mouse_and_focus() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	assert_eq(_panel.get_transition_state(), "closed")
	assert_true(_panel.open_for_register(_register))

	assert_eq(_panel.get_transition_state(), "open")
	assert_eq(_panel.get_requested_mouse_mode(), Input.MOUSE_MODE_VISIBLE)
	assert_true(_panel.has_modal_focus())
	assert_eq(get_viewport().gui_get_focus_owner(), _panel.confirm_button)

	assert_true(_panel.close())

	assert_eq(_panel.get_transition_state(), "closed")
	assert_eq(_panel.get_requested_mouse_mode(), Input.MOUSE_MODE_CAPTURED)
	assert_false(_panel.has_modal_focus())


func test_register_checkout_panel_confirm_completes_sale_and_disables_action() -> void:
	assert_true(_panel.open_for_register(_register))

	assert_true(_panel.confirm_checkout())

	assert_eq(_ledger.get_sale_count(), 1)
	assert_eq(_session.get_cash_cents(), 52199)
	assert_eq(_item.get("location_id"), "sold")
	assert_false(_customer.is_waiting_for_register())
	assert_true(_panel.confirm_button.disabled)
	assert_eq(get_viewport().gui_get_focus_owner(), _panel.close_button)
	assert_string_contains(_panel.status_label.text, "Sold Star Trader")
	assert_string_contains(_panel.status_label.text, "Profit")


func test_register_checkout_panel_confirms_return_and_disables_action() -> void:
	var customer: SimpleReturnCustomer = load("res://scenes/customers/simple_return_customer.tscn").instantiate()
	var receiving_box := Node3D.new()
	add_child_autofree(customer)
	add_child_autofree(receiving_box)
	_register.customer_path = NodePath("")
	_register.return_customer_path = _register.get_path_to(customer)
	_register.receiving_box_path = _register.get_path_to(receiving_box)

	assert_true(_panel.open_for_register(_register))
	assert_string_contains(_panel.title_label.text, "Return Review")
	assert_string_contains(_panel.cart_label.text, "Solar Ferry")
	assert_string_contains(_panel.cart_label.text, "Return: Solar Ferry refund $21.99")
	assert_string_contains(_panel.tender_label.text, "Refund due $21.99")
	assert_string_contains(_panel.tender_label.text, "Disposition inspect_restock")

	assert_true(_panel.confirm_checkout())

	assert_eq(_ledger.get_return_count(), 1)
	assert_eq(_ledger.get_total_return_refund_cents(), 2199)
	assert_eq(_session.get_cash_cents(), 47801)
	assert_eq(receiving_box.get_child_count(), 1)
	assert_false(customer.is_waiting_for_return())
	assert_true(_panel.confirm_button.disabled)
	assert_string_contains(_panel.status_label.text, "Returned Solar Ferry")


func _font_size(control: Control) -> int:
	return int(control.get("theme_override_font_sizes/font_size"))
