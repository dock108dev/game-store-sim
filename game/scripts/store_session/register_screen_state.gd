class_name RegisterScreenState
extends Node3D

const STATE_INACTIVE: StringName = &"inactive"
const STATE_READY: StringName = &"ready"
const STATE_TRANSACTION: StringName = &"transaction"
const STATE_SETTLED: StringName = &"settled"
const STATE_NO_SALE: StringName = &"no_sale"
const STATE_BACKROOM: StringName = &"backroom"
const STATE_STOCKING: StringName = &"stocking"
const STATE_CLOSE_READY: StringName = &"close_ready"

const DISPLAY_FONT_SIZE: int = 44
const DISPLAY_OUTLINE_SIZE: int = 4
const DISPLAY_COLOR_INACTIVE: Color = Color(0.16, 0.32, 0.18, 1.0)
const DISPLAY_COLOR_READY: Color = Color(0.54, 0.92, 0.46, 1.0)
const DISPLAY_COLOR_TRANSACTION: Color = Color(0.42, 0.86, 0.78, 1.0)
const DISPLAY_COLOR_SETTLED: Color = Color(1.0, 0.84, 0.38, 1.0)
const DISPLAY_COLOR_NO_SALE: Color = Color(0.94, 0.60, 0.28, 1.0)
const DISPLAY_COLOR_ROUTING: Color = Color(0.70, 0.68, 0.48, 1.0)
const DISPLAY_COLOR_CLOSE_READY: Color = Color(1.0, 0.88, 0.42, 1.0)

@export var screen_mesh_path: NodePath = ^"../RegisterScreen"
@export var display_label_path: NodePath = ^"StateLabel"
@export var receipt_slip_path: NodePath = ^"../../PrintedReceiptSlip"

var _state: StringName = STATE_INACTIVE
var _amount: int = 0
var _display_text: String = "CLOSED"
var _screen_mesh: MeshInstance3D = null
var _display_label: Label3D = null
var _receipt_slip: MeshInstance3D = null


func _ready() -> void:
	_resolve_nodes()
	set_state(STATE_INACTIVE)


## Sets the persistent semantic register-screen state. Unknown states fail
## closed to inactive so scene-only tests and partial runtime loads stay safe.
func set_state(state: StringName, amount: int = 0) -> void:
	var next_state: StringName = _normalized_state(state)
	_state = next_state
	_amount = _amount_for_state(_state, amount)
	_display_text = _text_for_state(_state, _amount)
	_apply_visual_state()


## Shows an in-progress transaction amount on the register display.
func show_transaction(amount: int) -> void:
	if amount > 0:
		set_state(STATE_TRANSACTION, amount)
	else:
		set_state(STATE_NO_SALE)


## Leaves a persistent receipt or no-sale result after customer resolution.
func settle(amount: int) -> void:
	if amount > 0:
		set_state(STATE_SETTLED, amount)
	else:
		set_state(STATE_NO_SALE)


## Returns the current semantic register-screen state.
func current_state() -> StringName:
	return _state


## Returns the amount currently shown by transaction or settled states.
func current_amount() -> int:
	return _amount


## Returns the exact label text currently shown on the display surface.
func display_text() -> String:
	return _display_text


func _resolve_nodes() -> void:
	_screen_mesh = get_node_or_null(screen_mesh_path) as MeshInstance3D
	_display_label = get_node_or_null(display_label_path) as Label3D
	_receipt_slip = get_node_or_null(receipt_slip_path) as MeshInstance3D


func _normalized_state(state: StringName) -> StringName:
	match state:
		STATE_INACTIVE, STATE_READY, STATE_TRANSACTION, STATE_SETTLED, STATE_NO_SALE:
			return state
		STATE_BACKROOM, STATE_STOCKING, STATE_CLOSE_READY:
			return state
		_:
			return STATE_INACTIVE


func _amount_for_state(state: StringName, amount: int) -> int:
	if state == STATE_TRANSACTION or state == STATE_SETTLED:
		return maxi(amount, 0)
	return 0


func _text_for_state(state: StringName, amount: int) -> String:
	var text: String = "CLOSED"
	match state:
		STATE_READY:
			text = "REGISTER\nREADY"
		STATE_TRANSACTION:
			if amount > 0:
				text = "SALE\n$%d" % amount
			else:
				text = "TRANS\nREADY"
		STATE_SETTLED:
			text = "RECEIPT\n$%d" % amount
		STATE_NO_SALE:
			text = "NO SALE"
		STATE_BACKROOM:
			text = "BACK\nROOM"
		STATE_STOCKING:
			text = "STOCK\nTABLE"
		STATE_CLOSE_READY:
			text = "CLOSE\nDAY"
	return text


func _apply_visual_state() -> void:
	if _display_label != null:
		_display_label.font_size = DISPLAY_FONT_SIZE
		_display_label.outline_size = DISPLAY_OUTLINE_SIZE
		_display_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_display_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_display_label.text = _display_text
		_display_label.modulate = _color_for_state(_state)
	if _screen_mesh != null:
		_screen_mesh.material_override = _material_for_state(_state)
	if _receipt_slip != null:
		_receipt_slip.visible = _state == STATE_SETTLED and _amount > 0


func _color_for_state(state: StringName) -> Color:
	var color: Color = DISPLAY_COLOR_INACTIVE
	match state:
		STATE_READY:
			color = DISPLAY_COLOR_READY
		STATE_TRANSACTION:
			color = DISPLAY_COLOR_TRANSACTION
		STATE_SETTLED:
			color = DISPLAY_COLOR_SETTLED
		STATE_NO_SALE:
			color = DISPLAY_COLOR_NO_SALE
		STATE_BACKROOM, STATE_STOCKING:
			color = DISPLAY_COLOR_ROUTING
		STATE_CLOSE_READY:
			color = DISPLAY_COLOR_CLOSE_READY
	return color


func _material_for_state(state: StringName) -> StandardMaterial3D:
	var color: Color = _color_for_state(state)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(color.r * 0.35, color.g * 0.35, color.b * 0.35, 1.0)
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = _emission_energy_for_state(state)
	return material


func _emission_energy_for_state(state: StringName) -> float:
	var energy: float = 0.25
	match state:
		STATE_READY:
			energy = 1.0
		STATE_TRANSACTION:
			energy = 1.35
		STATE_SETTLED:
			energy = 1.55
		STATE_NO_SALE:
			energy = 0.85
		STATE_BACKROOM, STATE_STOCKING:
			energy = 0.65
		STATE_CLOSE_READY:
			energy = 1.45
	return energy
