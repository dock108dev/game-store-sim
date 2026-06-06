extends CharacterBody3D

@export var move_speed: float = 4.5
@export var mouse_sensitivity: float = 0.0025

@onready var head: Node3D = $Head
@onready var hold_anchor: Node3D = $Head/Camera3D/HoldAnchor
@onready var pricing_panel: PricingPanel = $PricingPanel

var _look_pitch: float = 0.0
var _held_item: Node3D = null


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent) -> void:
	if is_pricing_open():
		if event.is_action_pressed("ui_cancel"):
			pricing_panel.cancel_price()
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
	if is_pricing_open():
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
	return _held_item != null


func get_held_item() -> Node3D:
	return _held_item


func can_pick_up_item(item: Node) -> bool:
	return _held_item == null and item is Node3D


func pick_up_item(item: Node3D) -> bool:
	if not can_pick_up_item(item):
		return false

	var parent := item.get_parent()
	if parent != null:
		parent.remove_child(item)

	hold_anchor.add_child(item)
	item.transform = Transform3D(Basis(Vector3.UP, PI), Vector3.ZERO)
	item.scale = Vector3(0.68, 0.68, 0.68)
	_held_item = item

	if item.has_method("set_held"):
		item.set_held()

	return true


func can_place_held_item(slot: Node) -> bool:
	if _held_item == null:
		return false

	if slot == null or not slot.has_method("can_accept"):
		return false

	return slot.can_accept(_held_item)


func place_held_item(slot: Node) -> bool:
	if not can_place_held_item(slot):
		return false

	var item := _held_item
	if slot.place_item(item):
		_held_item = null
		return true

	return false


func is_pricing_open() -> bool:
	return pricing_panel != null and pricing_panel.is_open()


func open_pricing_for_held_item() -> String:
	if _held_item == null:
		return "Hold an item to price it."

	if pricing_panel == null:
		return "Pricing panel unavailable."

	if pricing_panel.open_for_item(_held_item):
		return ""

	return "This item cannot be priced."


func get_held_item_interaction_prompt() -> String:
	if _held_item == null:
		return ""

	var product := _held_item.get("product") as ProductDefinition
	if product == null:
		return ""

	if not product.player_priceable:
		return "Fixed Price Item"

	return "E Price %s" % product.display_name


func interact_with_held_item() -> String:
	return open_pricing_for_held_item()
