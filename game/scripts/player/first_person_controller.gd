extends CharacterBody3D

@export var move_speed: float = 4.5
@export var mouse_sensitivity: float = 0.0025
@export var invert_look: bool = false
@export var max_held_items: int = 3
@export var comfort_fov: float = 72.0

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var hold_anchor: Node3D = $Head/Camera3D/HoldAnchor
@onready var pricing_panel: PricingPanel = $PricingPanel
@onready var register_checkout_panel: Node = $RegisterCheckoutPanel
@onready var day_summary_panel: Node = $DaySummaryPanel
@onready var trade_in_offer_panel: TradeInOfferPanel = $TradeInOfferPanel
@onready var settings_panel: SettingsPanel = $SettingsPanel
@onready var interaction_audio: Node = $InteractionAudioFeedback
@onready var presentation_microfeedback: Node = $PresentationMicrofeedback

const CARRY_BASE_SCALE := 0.45
const CARRY_DEPTH_SCALE_STEP := 0.025
const CARRY_BOB_AMPLITUDE := 0.008
const CARRY_IDLE_SETTLE := 0.004
const CARRY_MOVE_BOB_SPEED := 7.0
const CARRY_IDLE_BOB_SPEED := 2.5
const CARRY_SWAY_AMPLITUDE := 0.014
const CARRY_FORWARD_SWAY := 0.004
const CARRY_SWAY_ROTATION := 0.025
const CAMERA_BOB_AMPLITUDE := 0.018
const CAMERA_SWAY_AMPLITUDE := 0.008
const CAMERA_MOVE_FOV_BOOST := 2.0
const CAMERA_WORKSTATION_FOV_REDUCTION := 4.0
const CAMERA_WORKSTATION_SETTLE_Y := 0.012
const CAMERA_MIN_FOV := 66.0
const CAMERA_MAX_FOV := 76.0

var _look_pitch: float = 0.0
var _held_items: Array[Node3D] = []
var _held_item_bob_time: float = 0.0
var _camera_feel_time: float = 0.0
var _camera_motion_weight: float = 0.0
var _camera_workstation_focus_weight: float = 0.0
var _head_base_position: Vector3 = Vector3.ZERO


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_head_base_position = head.position
	camera.fov = clampf(comfort_fov, CAMERA_MIN_FOV, CAMERA_MAX_FOV)


func _unhandled_input(event: InputEvent) -> void:
	if _is_modal_open():
		if event.is_action_pressed("ui_cancel"):
			_close_active_modal()
		return

	if event.is_action_pressed("ui_cancel"):
		open_settings_panel()
		return

	if event is InputEventMouseButton and event.pressed:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		var look_direction := -1.0 if invert_look else 1.0
		_look_pitch = clampf(_look_pitch - event.relative.y * mouse_sensitivity * look_direction, -1.35, 1.35)
		head.rotation.x = _look_pitch


func _physics_process(delta: float) -> void:
	if _is_modal_open():
		if not is_on_floor():
			velocity += get_gravity() * delta

		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		_update_camera_feel(delta, 0.0)
		_update_held_item_motion(delta, 0.0)
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var move_direction := (global_transform.basis * Vector3(input_vector.x, 0.0, input_vector.y)).normalized()

	velocity.x = move_direction.x * move_speed
	velocity.z = move_direction.z * move_speed

	move_and_slide()
	_update_camera_feel(delta, input_vector.length())
	_update_held_item_motion(delta, input_vector.length())


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
		play_interaction_audio("error")
		return false

	var parent := item.get_parent()
	if parent != null:
		parent.remove_child(item)

	hold_anchor.add_child(item)
	_held_items.append(item)

	if item.has_method("set_held"):
		item.set_held()

	_arrange_held_items()
	play_interaction_audio("pickup")
	play_presentation_feedback("item_settle")
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
		play_interaction_audio("shelf_bump")
		return false

	var item := get_held_item()
	if slot.place_item(item):
		_held_items.erase(item)
		_clear_held_item_presentation(item)
		_arrange_held_items()
		play_interaction_audio("stock")
		play_presentation_feedback("item_settle")
		return true

	play_interaction_audio("shelf_bump")
	play_presentation_feedback("invalid_action")
	return false


func is_pricing_open() -> bool:
	return pricing_panel != null and pricing_panel.is_open()


func is_register_checkout_open() -> bool:
	return register_checkout_panel != null and register_checkout_panel.is_open()


func is_day_summary_open() -> bool:
	return day_summary_panel != null and day_summary_panel.is_open()


func is_trade_in_offer_open() -> bool:
	return trade_in_offer_panel != null and trade_in_offer_panel.is_open()


func is_settings_open() -> bool:
	return settings_panel != null and settings_panel.is_open()


func open_settings_panel() -> String:
	if settings_panel == null:
		return "Settings unavailable."

	if settings_panel.open_for_player(self):
		return ""

	return "Settings unavailable."


func get_mouse_sensitivity() -> float:
	return mouse_sensitivity


func set_mouse_sensitivity(value: float) -> void:
	mouse_sensitivity = clampf(value, 0.0005, 0.01)


func get_invert_look() -> bool:
	return invert_look


func set_invert_look(value: bool) -> void:
	invert_look = value


func get_camera_feel_state() -> Dictionary:
	return {
		"comfort_fov": comfort_fov,
		"camera_fov": camera.fov if camera != null else comfort_fov,
		"motion_weight": _camera_motion_weight,
		"workstation_focus_weight": _camera_workstation_focus_weight,
		"head_offset": head.position - _head_base_position if head != null else Vector3.ZERO,
		"bob_amplitude": CAMERA_BOB_AMPLITUDE,
		"sway_amplitude": CAMERA_SWAY_AMPLITUDE,
		"move_fov_boost": CAMERA_MOVE_FOV_BOOST,
		"workstation_fov_reduction": CAMERA_WORKSTATION_FOV_REDUCTION,
		"min_fov": CAMERA_MIN_FOV,
		"max_fov": CAMERA_MAX_FOV,
	}


func get_camera_feel_summary_text() -> String:
	return "Camera feel baseline:\nMovement bob - subtle head offset below reticle\nHeld item sway - bounded stack motion while walking\nWorkstation transition - modal focus settles camera and lowers FOV\nComfort FOV - %.1f base, %.1f-%.1f bounded range" % [
		comfort_fov,
		CAMERA_MIN_FOV,
		CAMERA_MAX_FOV,
	]


func open_pricing_for_held_item() -> String:
	var held_item := get_held_item()
	if held_item == null:
		return "Hold an item to price it."

	if pricing_panel == null:
		return "Pricing panel unavailable."

	if pricing_panel.open_for_item(held_item):
		play_interaction_audio("button_click")
		return ""

	play_interaction_audio("error")
	return "This item cannot be priced."


func open_register_checkout(register: RegisterWorkstation) -> String:
	if register_checkout_panel == null:
		return "Register checkout unavailable."

	if register_checkout_panel.open_for_register(register):
		play_interaction_audio("register")
		return ""

	play_interaction_audio("error")
	return "No checkout waiting at the register."


func open_day_summary(store_session: Node) -> String:
	if day_summary_panel == null:
		return "Backroom summary unavailable."

	if day_summary_panel.open_for_session(store_session):
		play_interaction_audio("computer_click")
		return ""

	play_interaction_audio("error")
	return "Backroom summary unavailable."


func open_trade_in_offer(register: RegisterWorkstation, customer: SimpleTradeInCustomer) -> String:
	if trade_in_offer_panel == null:
		return "Trade-in review unavailable."

	if trade_in_offer_panel.open_for_trade_in(register, customer):
		play_interaction_audio("register")
		return ""

	play_interaction_audio("error")
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

	return "Click Price %s" % product.display_name


func interact_with_held_item() -> String:
	return open_pricing_for_held_item()


func play_interaction_audio(cue_id: String) -> bool:
	if interaction_audio == null or not interaction_audio.has_method("play_cue"):
		return false
	return bool(interaction_audio.call("play_cue", cue_id))


func play_interaction_audio_for_result(result: String) -> bool:
	if result.is_empty():
		return false

	var lower_result := result.to_lower()
	if lower_result.contains("sold") or lower_result.contains("preorder") or lower_result.contains("service complete"):
		return play_interaction_audio("cash_drawer")
	if lower_result.contains("unavailable") or lower_result.contains("cannot") or lower_result.contains("no "):
		return play_interaction_audio("error")
	if lower_result.contains("box"):
		return play_interaction_audio("box_open")
	if lower_result.contains("placed") or lower_result.contains("stocked"):
		return play_interaction_audio("place")
	return play_interaction_audio("button_click")


func play_presentation_feedback(effect_id: String) -> bool:
	if presentation_microfeedback == null or not presentation_microfeedback.has_method("trigger_effect"):
		return false
	return bool(presentation_microfeedback.call("trigger_effect", effect_id))


func play_presentation_feedback_for_result(result: String) -> bool:
	if result.is_empty() or presentation_microfeedback == null:
		return false
	if not presentation_microfeedback.has_method("effect_for_result") or not presentation_microfeedback.has_method("trigger_effect"):
		return false

	var effect_id := str(presentation_microfeedback.call("effect_for_result", result))
	return bool(presentation_microfeedback.call("trigger_effect", effect_id))


func _is_modal_open() -> bool:
	return is_pricing_open() \
		or is_register_checkout_open() \
		or is_day_summary_open() \
		or is_trade_in_offer_open() \
		or is_settings_open()


func _close_active_modal() -> void:
	if is_pricing_open():
		pricing_panel.cancel_price()
		return

	if is_register_checkout_open():
		register_checkout_panel.close()
		return

	if is_day_summary_open():
		day_summary_panel.close()
		return

	if is_trade_in_offer_open():
		trade_in_offer_panel.close()
		return

	if is_settings_open():
		settings_panel.close()


func _arrange_held_items() -> void:
	for index in range(_held_items.size()):
		var item := _held_items[index]
		if item == null:
			continue

		var offset := float(index - (_held_items.size() - 1))
		var depth := absf(offset)
		var carry_position := Vector3(
			offset * 0.11,
			(depth * 0.052) - 0.015,
			-0.045 + (depth * -0.06)
		)
		var carry_rotation := Vector3(
			deg_to_rad(-8.0 + depth * 2.0),
			PI + (offset * 0.16),
			deg_to_rad(offset * -4.0)
		)
		item.transform = Transform3D(Basis.from_euler(carry_rotation), carry_position)
		item.scale = _get_held_item_silhouette_scale(item, depth)
		item.set_meta("carry_base_position", carry_position)
		item.set_meta("carry_base_rotation", carry_rotation)
		item.set_meta("carry_depth", depth)
		item.set_meta("carry_is_active", index == _held_items.size() - 1)
		item.set_meta("carry_bob_phase", depth * 0.55)


func _update_camera_feel(delta: float, movement_amount: float) -> void:
	if head == null or camera == null:
		return

	var movement := clampf(movement_amount, 0.0, 1.0)
	var modal_focus := 1.0 if _is_modal_open() else 0.0
	var motion_lerp := minf(delta * 8.0, 1.0)
	var focus_lerp := minf(delta * 10.0, 1.0)
	_camera_motion_weight = lerpf(_camera_motion_weight, movement, motion_lerp)
	_camera_workstation_focus_weight = lerpf(_camera_workstation_focus_weight, modal_focus, focus_lerp)

	_camera_feel_time += delta * lerpf(1.8, 8.0, _camera_motion_weight)
	var active_motion := _camera_motion_weight * (1.0 - _camera_workstation_focus_weight)
	var bob_offset := sin(_camera_feel_time) * CAMERA_BOB_AMPLITUDE * active_motion
	var sway_offset := sin(_camera_feel_time * 0.55) * CAMERA_SWAY_AMPLITUDE * active_motion
	var settle_offset := CAMERA_WORKSTATION_SETTLE_Y * _camera_workstation_focus_weight
	head.position = _head_base_position + Vector3(sway_offset, bob_offset - settle_offset, 0.0)

	var target_fov := comfort_fov \
		+ (CAMERA_MOVE_FOV_BOOST * active_motion) \
		- (CAMERA_WORKSTATION_FOV_REDUCTION * _camera_workstation_focus_weight)
	camera.fov = clampf(lerpf(camera.fov, target_fov, minf(delta * 6.0, 1.0)), CAMERA_MIN_FOV, CAMERA_MAX_FOV)


func _update_held_item_motion(delta: float, movement_amount: float) -> void:
	if _held_items.is_empty():
		return

	var movement := clampf(movement_amount, 0.0, 1.0)
	var bob_speed := lerpf(CARRY_IDLE_BOB_SPEED, CARRY_MOVE_BOB_SPEED, movement)
	var bob_strength := lerpf(0.0015, CARRY_BOB_AMPLITUDE, movement)
	var settle_offset := CARRY_IDLE_SETTLE * (1.0 - movement)
	_held_item_bob_time += delta * bob_speed

	for item in _held_items:
		if item == null:
			continue

		var base_position := item.get_meta("carry_base_position", item.position) as Vector3
		var base_rotation := item.get_meta("carry_base_rotation", item.rotation) as Vector3
		var phase := float(item.get_meta("carry_bob_phase", 0.0))
		var bob_offset := sin(_held_item_bob_time + phase) * bob_strength
		var sway_offset := sin((_held_item_bob_time * 0.72) + phase) * CARRY_SWAY_AMPLITUDE * movement
		var forward_sway := cos((_held_item_bob_time * 0.68) + phase) * CARRY_FORWARD_SWAY * movement
		var roll_sway := sin(_held_item_bob_time + phase) * CARRY_SWAY_ROTATION * movement
		item.position = base_position + Vector3(sway_offset, bob_offset - settle_offset, forward_sway)
		item.rotation = base_rotation + Vector3(0.0, 0.0, roll_sway)


func _get_held_item_silhouette_scale(item: Node3D, depth: float) -> Vector3:
	var scale_factor := CARRY_BASE_SCALE - (depth * CARRY_DEPTH_SCALE_STEP)
	var product := item.get("product") as ProductDefinition
	if product != null and product.category != "used_game":
		scale_factor -= 0.025

	scale_factor = clampf(scale_factor, 0.38, CARRY_BASE_SCALE)
	return Vector3(scale_factor, scale_factor, scale_factor)


func _clear_held_item_presentation(item: Node3D) -> void:
	if item == null:
		return

	for key in ["carry_base_position", "carry_base_rotation", "carry_depth", "carry_is_active", "carry_bob_phase"]:
		if item.has_meta(key):
			item.remove_meta(key)
