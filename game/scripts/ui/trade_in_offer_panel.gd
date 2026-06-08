extends CanvasLayer
class_name TradeInOfferPanel

const UIComponents := preload("res://scripts/ui/ui_component_library.gd")

@onready var title_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var modal_root: Control = $CenterContainer
@onready var details_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/DetailsLabel
@onready var appraisal_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/AppraisalLabel
@onready var risk_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/RiskLabel
@onready var offer_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/OfferLabel
@onready var status_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/StatusLabel
@onready var decrease_offer_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/OfferAdjustRow/DecreaseOfferButton
@onready var increase_offer_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/OfferAdjustRow/IncreaseOfferButton
@onready var accept_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionRow/AcceptButton
@onready var store_credit_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionRow/StoreCreditButton
@onready var decline_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionRow/DeclineButton
@onready var close_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionRow/CloseButton

const OFFER_STEP_CENTS := 100

var _register: RegisterWorkstation = null
var _customer: SimpleTradeInCustomer = null
var _draft_offer_cents: int = 0
var _transition_state: String = "closed"
var _requested_mouse_mode: int = Input.MOUSE_MODE_CAPTURED


func _ready() -> void:
	hide()
	UIComponents.apply_modal_language(modal_root, UIComponents.SURFACE_TRADE_IN)
	decrease_offer_button.pressed.connect(decrease_offer)
	increase_offer_button.pressed.connect(increase_offer)
	accept_button.pressed.connect(accept_offer)
	store_credit_button.pressed.connect(accept_store_credit)
	decline_button.pressed.connect(decline_offer)
	close_button.pressed.connect(close)


func _unhandled_input(event: InputEvent) -> void:
	if not is_open():
		return

	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func open_for_trade_in(register: RegisterWorkstation, customer: SimpleTradeInCustomer) -> bool:
	if register == null or customer == null or not customer.is_waiting_for_trade_in():
		return false

	_register = register
	_customer = customer
	_draft_offer_cents = customer.get_offer_cents()
	status_label.text = "Review the offer."
	_update_labels()
	_set_offer_buttons_enabled(true)
	_enter_modal(accept_button)
	return true


func is_open() -> bool:
	return visible and _register != null and _customer != null


func get_active_customer() -> SimpleTradeInCustomer:
	return _customer


func get_transition_state() -> String:
	return _transition_state


func get_requested_mouse_mode() -> int:
	return _requested_mouse_mode


func has_modal_focus() -> bool:
	var focus_owner := get_viewport().gui_get_focus_owner()
	return focus_owner != null and is_ancestor_of(focus_owner)


func get_draft_offer_cents() -> int:
	return _draft_offer_cents


func has_ui_component_language() -> bool:
	return modal_root.get_meta("ui_language_tokens", []).has(UIComponents.TOKEN_MODAL) \
		and modal_root.get_meta("ui_language_tokens", []).has(UIComponents.TOKEN_RECEIPT) \
		and accept_button.get_meta("ui_component", "") == UIComponents.TOKEN_BUTTON \
		and status_label.get_meta("ui_component", "") == UIComponents.TOKEN_LIST


func increase_offer() -> bool:
	return _adjust_offer(OFFER_STEP_CENTS)


func decrease_offer() -> bool:
	return _adjust_offer(-OFFER_STEP_CENTS)


func accept_offer() -> bool:
	if not is_open():
		return false

	status_label.text = _register.accept_trade_in(_customer, _draft_offer_cents)
	_set_offer_buttons_enabled(false)
	close_button.grab_focus()
	return true


func accept_store_credit() -> bool:
	if not is_open():
		return false

	status_label.text = _register.accept_trade_in_store_credit(
		_customer,
		_customer.get_store_credit_offer_cents()
	)
	_set_offer_buttons_enabled(false)
	close_button.grab_focus()
	return true


func decline_offer() -> bool:
	if not is_open():
		return false

	status_label.text = _register.decline_trade_in(_customer)
	_set_offer_buttons_enabled(false)
	close_button.grab_focus()
	return true


func close() -> bool:
	if not is_open():
		return false

	_register = null
	_customer = null
	_exit_modal()
	return true


func _enter_modal(default_focus: Control) -> void:
	show()
	_requested_mouse_mode = Input.MOUSE_MODE_VISIBLE
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_transition_state = "open"
	if default_focus != null:
		default_focus.grab_focus()


func _exit_modal() -> void:
	_release_modal_focus()
	hide()
	_requested_mouse_mode = Input.MOUSE_MODE_CAPTURED
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_transition_state = "closed"


func _release_modal_focus() -> void:
	var focus_owner := get_viewport().gui_get_focus_owner()
	if focus_owner != null and is_ancestor_of(focus_owner):
		focus_owner.release_focus()


func _update_labels() -> void:
	var item := _customer.get_trade_item()
	var product := item.get("product") as ProductDefinition
	title_label.text = "Trade-In Review"

	if product == null:
		details_label.text = "Unknown item"
		offer_label.text = "Trade-in offers unavailable"
		_update_adjust_buttons()
		return

	details_label.text = "%s\nPlatform: %s\nCondition: %s\nCompleteness: %s\nDemand: %s\nMarket: $%0.2f" % [
		product.display_name,
		product.platform,
		product.condition.capitalize(),
		product.completeness.capitalize(),
		product.demand_tier.capitalize(),
		product.market_value_cents / 100.0,
	]
	appraisal_label.text = "Authenticity: %s\nMarket value: $%0.2f\nProjected margin: $%0.2f\nDemand: %s" % [
		_get_authenticity_confidence(item),
		product.market_value_cents / 100.0,
		_get_projected_margin_cents(product) / 100.0,
		product.demand_tier.capitalize(),
	]
	risk_label.text = "Risk notes: %s" % _get_risk_notes(item, product)
	offer_label.text = "Cash offer: $%0.2f  |  Store credit: $%0.2f" % [
		_draft_offer_cents / 100.0,
		_customer.get_store_credit_offer_cents() / 100.0,
	]
	if status_label.text.is_empty() or status_label.text == "Review the offer.":
		status_label.text = "Review the offer."
	_update_adjust_buttons()


func _adjust_offer(delta_cents: int) -> bool:
	if not is_open():
		return false

	_draft_offer_cents = clampi(
		_draft_offer_cents + delta_cents,
		1,
		_customer.get_max_offer_cents()
	)
	status_label.text = "Counter offer: $%0.2f" % (_draft_offer_cents / 100.0)
	_update_labels()
	return true


func _set_offer_buttons_enabled(is_enabled: bool) -> void:
	accept_button.disabled = not is_enabled
	store_credit_button.disabled = not is_enabled
	decline_button.disabled = not is_enabled
	_update_adjust_buttons()


func _update_adjust_buttons() -> void:
	if _customer == null:
		return

	var controls_enabled := not accept_button.disabled
	decrease_offer_button.disabled = not controls_enabled or _draft_offer_cents <= 1
	increase_offer_button.disabled = not controls_enabled or _draft_offer_cents >= _customer.get_max_offer_cents()


func _get_authenticity_confidence(item: Node) -> String:
	if item == null:
		return "Unknown"

	if item.has_method("has_serial_mismatch") and bool(item.call("has_serial_mismatch")):
		return "Low"

	var serial_id := str(item.get("serial_id")).strip_edges()
	if serial_id.is_empty():
		return "Medium"

	return "High"


func _get_projected_margin_cents(product: ProductDefinition) -> int:
	if product == null:
		return 0

	return product.market_value_cents - _draft_offer_cents


func _get_risk_notes(item: Node, product: ProductDefinition) -> String:
	var notes: Array[String] = []
	if item != null and item.has_method("has_serial_mismatch") and bool(item.call("has_serial_mismatch")):
		notes.append("serial mismatch")
	elif item != null and str(item.get("serial_id")).strip_edges().is_empty():
		notes.append("serial untracked")

	if product != null:
		if product.demand_tier == "low":
			notes.append("low demand")
		if product.condition == "fair" or product.condition == "poor":
			notes.append("%s condition" % product.condition)
		if product.completeness != "complete":
			notes.append("%s copy" % product.completeness)

	if notes.is_empty():
		return "standard buyback risk"

	return ", ".join(notes)
