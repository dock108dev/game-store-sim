extends CanvasLayer
class_name RegisterCheckoutPanel

const UIComponents := preload("res://scripts/ui/ui_component_library.gd")

@onready var modal_root: Control = $CenterContainer
@onready var title_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var cart_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CartLabel
@onready var totals_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TotalsLabel
@onready var tender_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TenderLabel
@onready var return_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ReturnLabel
@onready var status_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/StatusLabel
@onready var confirm_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionRow/ConfirmButton
@onready var close_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionRow/CloseButton

var _register: RegisterWorkstation = null
var _state: Dictionary = {}
var _transition_state: String = "closed"
var _requested_mouse_mode: int = Input.MOUSE_MODE_CAPTURED


func _ready() -> void:
	hide()
	UIComponents.apply_modal_language(modal_root, UIComponents.SURFACE_REGISTER)
	confirm_button.pressed.connect(confirm_checkout)
	close_button.pressed.connect(close)


func _unhandled_input(event: InputEvent) -> void:
	if not is_open():
		return

	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func open_for_register(register: RegisterWorkstation) -> bool:
	if register == null:
		return false

	var state := register.get_checkout_ui_state()
	if not bool(state.get("has_active_checkout", false)):
		return false

	_register = register
	_state = state
	_update_labels()
	confirm_button.disabled = false
	_enter_modal(confirm_button)
	return true


func is_open() -> bool:
	return visible and _register != null


func get_active_register() -> RegisterWorkstation:
	return _register


func get_transition_state() -> String:
	return _transition_state


func get_requested_mouse_mode() -> int:
	return _requested_mouse_mode


func get_checkout_state() -> Dictionary:
	return _state.duplicate(true)


func has_modal_focus() -> bool:
	var focus_owner := get_viewport().gui_get_focus_owner()
	return focus_owner != null and is_ancestor_of(focus_owner)


func has_ui_component_language() -> bool:
	return modal_root.get_meta("ui_language_tokens", []).has(UIComponents.TOKEN_RECEIPT) \
		and cart_label.get_meta("ui_component", "") == UIComponents.TOKEN_LIST \
		and confirm_button.get_meta("ui_component", "") == UIComponents.TOKEN_BUTTON \
		and title_label.get_meta("ui_component", "") == UIComponents.TOKEN_STAT


func confirm_checkout() -> bool:
	if not is_open():
		return false

	var message := _register.complete_active_checkout()
	var completed_state := _register.get_last_checkout_ui_state()
	if completed_state.is_empty():
		completed_state = _state.duplicate(true)
		completed_state["transaction_feedback"] = message
		completed_state["sale_confirmation"] = message
		completed_state["completed"] = true
	_state = completed_state
	_update_labels()
	confirm_button.disabled = true
	close_button.grab_focus()
	return true


func close() -> bool:
	if not is_open():
		return false

	_register = null
	_state = {}
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
	title_label.text = str(_state.get("title", "Register Checkout"))
	cart_label.text = _format_cart_lines()
	totals_label.text = "Subtotal %s\nTax %s\nTotal %s" % [
		_format_money(int(_state.get("subtotal_cents", 0))),
		_format_money(int(_state.get("tax_cents", 0))),
		_format_money(int(_state.get("total_cents", 0))),
	]
	tender_label.text = "%s tendered %s\nChange due %s" % [
		str(_state.get("tender_method", "Cash")),
		_format_money(int(_state.get("tendered_cents", 0))),
		_format_money(int(_state.get("change_due_cents", 0))),
	]
	if str(_state.get("transaction_type", "")) == "return":
		tender_label.text = "Refund due %s\nDisposition %s" % [
			_format_money(int(_state.get("refund_due_cents", 0))),
			str(_state.get("return_disposition", "receiving review")),
		]
	return_label.text = str(_state.get("return_placeholder", "Returns: not available in this build."))
	status_label.text = str(_state.get("transaction_feedback", "Awaiting checkout confirmation."))


func _format_cart_lines() -> String:
	var rows: Array[String] = []
	for line in _state.get("cart_lines", []):
		var row: Dictionary = line
		rows.append("%s x%d  %s" % [
			str(row.get("label", "Item")),
			int(row.get("quantity", 1)),
			_format_money(int(row.get("line_total_cents", 0))),
		])

	var service_line := str(_state.get("service_line", ""))
	if not service_line.is_empty():
		rows.append("Service: %s" % service_line)

	var preorder_line := str(_state.get("preorder_line", ""))
	if not preorder_line.is_empty():
		rows.append("Preorder: %s" % preorder_line)

	var return_line := str(_state.get("return_line", ""))
	if not return_line.is_empty():
		rows.append("Return: %s" % return_line)

	if rows.is_empty():
		rows.append("No checkout lines.")

	return "\n".join(rows)


func _format_money(cents: int) -> String:
	if cents < 0:
		return "-$%0.2f" % (abs(cents) / 100.0)
	return "$%0.2f" % (cents / 100.0)
