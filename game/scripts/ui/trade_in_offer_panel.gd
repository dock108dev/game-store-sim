extends CanvasLayer
class_name TradeInOfferPanel

@onready var title_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var details_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/DetailsLabel
@onready var offer_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/OfferLabel
@onready var status_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/StatusLabel
@onready var accept_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionRow/AcceptButton
@onready var decline_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionRow/DeclineButton
@onready var close_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionRow/CloseButton

var _register: RegisterWorkstation = null
var _customer: SimpleTradeInCustomer = null


func _ready() -> void:
	hide()
	accept_button.pressed.connect(accept_offer)
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
	_update_labels()
	_set_offer_buttons_enabled(true)
	show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	return true


func is_open() -> bool:
	return visible and _register != null and _customer != null


func get_active_customer() -> SimpleTradeInCustomer:
	return _customer


func accept_offer() -> bool:
	if not is_open():
		return false

	status_label.text = _register.accept_trade_in(_customer)
	_set_offer_buttons_enabled(false)
	return true


func decline_offer() -> bool:
	if not is_open():
		return false

	status_label.text = _register.decline_trade_in(_customer)
	_set_offer_buttons_enabled(false)
	return true


func close() -> bool:
	if not is_open():
		return false

	_register = null
	_customer = null
	hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	return true


func _update_labels() -> void:
	var item := _customer.get_trade_item()
	var product := item.get("product") as ProductDefinition
	title_label.text = "Trade-In Review"
	status_label.text = "Review the offer."

	if product == null:
		details_label.text = "Unknown item"
		offer_label.text = "Cash offer unavailable"
		return

	details_label.text = "%s\nPlatform: %s\nCondition: %s\nCompleteness: %s\nDemand: %s\nMarket: $%0.2f" % [
		product.display_name,
		product.platform,
		product.condition.capitalize(),
		product.completeness.capitalize(),
		product.demand_tier.capitalize(),
		product.market_value_cents / 100.0,
	]
	offer_label.text = "Cash offer: $%0.2f" % (_customer.get_offer_cents() / 100.0)


func _set_offer_buttons_enabled(is_enabled: bool) -> void:
	accept_button.disabled = not is_enabled
	decline_button.disabled = not is_enabled
