extends CharacterBody3D

@export var move_speed: float = 4.5
@export var mouse_sensitivity: float = 0.0025
@export var max_held_items: int = 3

@onready var head: Node3D = $Head
@onready var hold_anchor: Node3D = $Head/Camera3D/HoldAnchor
@onready var pricing_panel: PricingPanel = $PricingPanel
@onready var day_summary_panel: Node = $DaySummaryPanel
@onready var trade_in_offer_panel: TradeInOfferPanel = $TradeInOfferPanel

var _look_pitch: float = 0.0
var _held_items: Array[Node3D] = []


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent) -> void:
	if _is_modal_open():
		if event.is_action_pressed("ui_cancel"):
			_close_active_modal()
		return

	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		return

	if event is InputEventMouseButton and event.pressed:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		_look_pitch = clampf(_look_pitch - event.relative.y * mouse_sensitivity, -1.35, 1.35)
		head.rotation.x = _look_pitch


func _physics_process(delta: float) -> void:
	if _is_modal_open():
		if not is_on_floor():
			velocity += get_gravity() * delta

		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var move_direction := (global_transform.basis * Vector3(input_vector.x, 0.0, input_vector.y)).normalized()

	velocity.x = move_direction.x * move_speed
	velocity.z = move_direction.z * move_speed

	move_and_slide()


func is_holding_item() -> bool:
	return not _held_items.is_empty()


func get_held_item() -> Node3D:
	if _held_items.is_empty():
		return null

	return _held_items[_held_items.size() - 1]


func get_held_items() -> Array[Node3D]:
	return _held_items.duplicate()


func get_held_item_count() -> int:
	return _held_items.size()


func can_pick_up_item(item: Node) -> bool:
	return _held_items.size() < max_held_items and item is Node3D


func pick_up_item(item: Node3D) -> bool:
	if not can_pick_up_item(item):
		return false

	var parent := item.get_parent()
	if parent != null:
		parent.remove_child(item)

	hold_anchor.add_child(item)
	_held_items.append(item)

	if item.has_method("set_held"):
		item.set_held()

	_arrange_held_items()
	return true


func can_place_held_item(slot: Node) -> bool:
	var held_item := get_held_item()
	if held_item == null:
		return false

	if slot == null or not slot.has_method("can_accept"):
		return false

	return slot.can_accept(held_item)


func place_held_item(slot: Node) -> bool:
	if not can_place_held_item(slot):
		return false

	var item := get_held_item()
	if slot.place_item(item):
		_held_items.erase(item)
		_arrange_held_items()
		return true

	return false


func is_pricing_open() -> bool:
	return pricing_panel != null and pricing_panel.is_open()


func is_day_summary_open() -> bool:
	return day_summary_panel != null and day_summary_panel.is_open()


func is_trade_in_offer_open() -> bool:
	return trade_in_offer_panel != null and trade_in_offer_panel.is_open()


func open_pricing_for_held_item() -> String:
	var held_item := get_held_item()
	if held_item == null:
		return "Hold an item to price it."

	if pricing_panel == null:
		return "Pricing panel unavailable."

	if pricing_panel.open_for_item(held_item):
		return ""

	return "This item cannot be priced."


func open_day_summary(store_session: Node) -> String:
	if day_summary_panel == null:
		return "Backroom summary unavailable."

	if day_summary_panel.open_for_session(store_session):
		return ""

	return "Backroom summary unavailable."


func open_trade_in_offer(register: RegisterWorkstation, customer: SimpleTradeInCustomer) -> String:
	if trade_in_offer_panel == null:
		return "Trade-in review unavailable."

	if trade_in_offer_panel.open_for_trade_in(register, customer):
		return ""

	return "Trade-in review unavailable."


func get_held_item_interaction_prompt() -> String:
	var held_item := get_held_item()
	if held_item == null:
		return ""

	var product := held_item.get("product") as ProductDefinition
	if product == null:
		return ""

	if not product.player_priceable:
		return "Fixed Price Item"

	return "E Price %s" % product.display_name


func interact_with_held_item() -> String:
	return open_pricing_for_held_item()


func _is_modal_open() -> bool:
	return is_pricing_open() or is_day_summary_open() or is_trade_in_offer_open()


func _close_active_modal() -> void:
	if is_pricing_open():
		pricing_panel.cancel_price()
		return

	if is_day_summary_open():
		day_summary_panel.close()
		return

	if is_trade_in_offer_open():
		trade_in_offer_panel.close()


func _arrange_held_items() -> void:
	for index in range(_held_items.size()):
		var item := _held_items[index]
		if item == null:
			continue

		var offset := index - (_held_items.size() - 1)
		var carry_position := Vector3(
			offset * 0.08,
			abs(offset) * 0.035,
			abs(offset) * -0.045
		)
		item.transform = Transform3D(Basis(Vector3.UP, PI + (offset * 0.08)), carry_position)
		item.scale = Vector3(0.46, 0.46, 0.46)
