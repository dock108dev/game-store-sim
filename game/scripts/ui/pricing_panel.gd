extends CanvasLayer
class_name PricingPanel

const UIComponents := preload("res://scripts/ui/ui_component_library.gd")

@export var price_step_cents: int = 100
@export var min_price_cents: int = 99
@export var max_price_cents: int = 99999

@onready var title_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var modal_root: Control = $CenterContainer
@onready var details_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/DetailsLabel
@onready var price_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/PriceRow/PriceLabel
@onready var decrement_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/PriceRow/DecreaseButton
@onready var increment_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/PriceRow/IncreaseButton
@onready var apply_matching_check_box: CheckBox = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ApplyMatchingCheckBox
@onready var apply_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionRow/ApplyButton
@onready var cancel_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionRow/CancelButton

var _item: Node = null
var _draft_price_cents: int = 0
var _original_price_cents: int = 0
var _transition_state: String = "closed"
var _requested_mouse_mode: int = Input.MOUSE_MODE_CAPTURED


func _ready() -> void:
	hide()
	UIComponents.apply_modal_language(modal_root, UIComponents.SURFACE_PRICING)
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
	apply_matching_check_box.button_pressed = false
	_update_labels()
	_enter_modal(apply_button)
	return true


func is_open() -> bool:
	return visible and _item != null


func get_active_item() -> Node:
	return _item


func get_transition_state() -> String:
	return _transition_state


func get_requested_mouse_mode() -> int:
	return _requested_mouse_mode


func has_modal_focus() -> bool:
	var focus_owner := get_viewport().gui_get_focus_owner()
	return focus_owner != null and is_ancestor_of(focus_owner)


func get_draft_price_cents() -> int:
	return _draft_price_cents


func has_ui_component_language() -> bool:
	return modal_root.get_meta("ui_language_tokens", []).has(UIComponents.TOKEN_MODAL) \
		and modal_root.get_meta("ui_language_tokens", []).has(UIComponents.TOKEN_ALERT) \
		and apply_button.get_meta("ui_component", "") == UIComponents.TOKEN_BUTTON \
		and title_label.get_meta("ui_component", "") == UIComponents.TOKEN_STAT


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

	if apply_matching_check_box.button_pressed:
		for item in get_matching_priceable_items():
			item.set("current_price_cents", _draft_price_cents)
	else:
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
	_exit_modal()


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
	var cost_basis_cents := int(_item.get("cost_basis_cents"))
	if cost_basis_cents <= 0:
		cost_basis_cents = product.cost_basis_cents
	details_label.text = "Platform: %s\nCondition: %s\nCompleteness: %s\nCost: $%0.2f\nMarket: $%0.2f" % [
		product.platform,
		product.condition.capitalize(),
		product.completeness.capitalize(),
		cost_basis_cents / 100.0,
		product.market_value_cents / 100.0,
	]
	price_label.text = "$%0.2f" % (_draft_price_cents / 100.0)
	apply_matching_check_box.text = "Apply to all %s copies (%d)" % [
		product.display_name,
		get_matching_priceable_items().size(),
	]


func get_matching_priceable_items() -> Array[Node]:
	var matches: Array[Node] = []
	if _item == null:
		return matches

	var product := _item.get("product") as ProductDefinition
	if product == null:
		return matches

	var root := get_tree().current_scene
	if root == null:
		root = get_tree().root

	_collect_matching_priceable_items(root, product.product_id, matches)
	return matches


func _collect_matching_priceable_items(node: Node, product_id: String, matches: Array[Node]) -> void:
	if _is_matching_priceable_item(node, product_id):
		matches.append(node)

	for child in node.get_children():
		_collect_matching_priceable_items(child, product_id, matches)


func _is_matching_priceable_item(node: Node, product_id: String) -> bool:
	var product := node.get("product") as ProductDefinition
	if product == null or product.product_id != product_id or not product.player_priceable:
		return false

	var location_id := str(node.get("location_id"))
	if location_id == "sold" or location_id.begins_with("customer:"):
		return false

	return true
