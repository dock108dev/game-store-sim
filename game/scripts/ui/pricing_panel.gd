extends CanvasLayer
class_name PricingPanel

@export var price_step_cents: int = 100
@export var min_price_cents: int = 99
@export var max_price_cents: int = 99999

@onready var title_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var details_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/DetailsLabel
@onready var price_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/PriceRow/PriceLabel
@onready var decrement_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/PriceRow/DecreaseButton
@onready var increment_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/PriceRow/IncreaseButton
@onready var apply_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionRow/ApplyButton
@onready var cancel_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionRow/CancelButton

var _item: Node = null
var _draft_price_cents: int = 0
var _original_price_cents: int = 0


func _ready() -> void:
	hide()
	decrement_button.pressed.connect(decrease_price)
	increment_button.pressed.connect(increase_price)
	apply_button.pressed.connect(apply_price)
	cancel_button.pressed.connect(cancel_price)


func _unhandled_input(event: InputEvent) -> void:
	if not is_open():
		return

	if event.is_action_pressed("ui_cancel"):
		cancel_price()
		get_viewport().set_input_as_handled()


func open_for_item(item: Node) -> bool:
	if not _can_price_item(item):
		return false

	_item = item
	_original_price_cents = int(item.get("current_price_cents"))
	_draft_price_cents = clampi(_original_price_cents, min_price_cents, max_price_cents)
	_update_labels()
	show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	return true


func is_open() -> bool:
	return visible and _item != null


func get_active_item() -> Node:
	return _item


func get_draft_price_cents() -> int:
	return _draft_price_cents


func increase_price() -> void:
	if not is_open():
		return

	_draft_price_cents = clampi(_draft_price_cents + price_step_cents, min_price_cents, max_price_cents)
	_update_labels()


func decrease_price() -> void:
	if not is_open():
		return

	_draft_price_cents = clampi(_draft_price_cents - price_step_cents, min_price_cents, max_price_cents)
	_update_labels()


func apply_price() -> bool:
	if not is_open():
		return false

	_item.set("current_price_cents", _draft_price_cents)
	_close()
	return true


func cancel_price() -> bool:
	if not is_open():
		return false

	_item.set("current_price_cents", _original_price_cents)
	_close()
	return true


func _close() -> void:
	_item = null
	_draft_price_cents = 0
	_original_price_cents = 0
	hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _can_price_item(item: Node) -> bool:
	if item == null:
		return false

	var product := item.get("product") as ProductDefinition
	return product != null and product.player_priceable


func _update_labels() -> void:
	var product := _item.get("product") as ProductDefinition
	if product == null:
		return

	title_label.text = "Price %s" % product.display_name
	details_label.text = "Platform: %s\nCondition: %s\nCompleteness: %s\nCost: $%0.2f\nMarket: $%0.2f" % [
		product.platform,
		product.condition.capitalize(),
		product.completeness.capitalize(),
		product.cost_basis_cents / 100.0,
		product.market_value_cents / 100.0,
	]
	price_label.text = "$%0.2f" % (_draft_price_cents / 100.0)
