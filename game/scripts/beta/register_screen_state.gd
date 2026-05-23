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
	_amount = maxi(amount, 0)
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


func _text_for_state(state: StringName, amount: int) -> String:
	match state:
		STATE_READY:
			return "READY"
		STATE_TRANSACTION:
			if amount > 0:
				return "SALE\n$%d" % amount
			return "SALE\nOPEN"
		STATE_SETTLED:
			return "RECEIPT\n$%d" % amount
		STATE_NO_SALE:
			return "NO SALE"
		STATE_BACKROOM:
			return "BACK\nROOM"
		STATE_STOCKING:
			return "STOCK\nSHELF"
		STATE_CLOSE_READY:
			return "CLOSE\nDAY"
		_:
			return "CLOSED"


func _apply_visual_state() -> void:
	if _display_label != null:
		_display_label.text = _display_text
		_display_label.modulate = _color_for_state(_state)
	if _screen_mesh != null:
		_screen_mesh.material_override = _material_for_state(_state)
	if _receipt_slip != null:
		_receipt_slip.visible = _state == STATE_SETTLED and _amount > 0


func _color_for_state(state: StringName) -> Color:
	match state:
		STATE_READY:
			return Color(0.48, 0.95, 0.42, 1.0)
		STATE_TRANSACTION:
			return Color(0.38, 0.88, 1.0, 1.0)
		STATE_SETTLED:
			return Color(1.0, 0.84, 0.38, 1.0)
		STATE_NO_SALE:
			return Color(1.0, 0.65, 0.28, 1.0)
		STATE_BACKROOM, STATE_STOCKING:
			return Color(0.72, 0.70, 0.52, 1.0)
		STATE_CLOSE_READY:
			return Color(0.98, 0.88, 0.42, 1.0)
		_:
			return Color(0.18, 0.36, 0.18, 1.0)


func _material_for_state(state: StringName) -> StandardMaterial3D:
	var color: Color = _color_for_state(state)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(color.r * 0.35, color.g * 0.35, color.b * 0.35, 1.0)
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 1.25 if state != STATE_INACTIVE else 0.25
	return material
