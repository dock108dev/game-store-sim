extends CanvasLayer
class_name SaveSlotPanel

const UIComponents := preload("res://scripts/ui/ui_component_library.gd")
const SaveSlotRegistryScript := preload("res://scripts/save/save_slot_registry.gd")

@onready var modal_root: Control = $CenterContainer
@onready var title_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var slot_list_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/SlotListLabel
@onready var metadata_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/MetadataLabel
@onready var status_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/StatusLabel
@onready var slot_1_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/SlotRow/Slot1Button
@onready var slot_2_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/SlotRow/Slot2Button
@onready var slot_3_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/SlotRow/Slot3Button
@onready var new_game_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionGrid/NewGameButton
@onready var continue_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionGrid/ContinueButton
@onready var overwrite_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionGrid/OverwriteButton
@onready var delete_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ActionGrid/DeleteButton
@onready var close_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CloseButton

var _registry = SaveSlotRegistryScript.new()
var _active_session: StoreSession = null
var _selected_slot_id: String = "slot_1"
var _last_loaded_data: Dictionary = {}
var _status_text: String = "Select a save slot."
var _transition_state: String = "closed"
var _requested_mouse_mode: int = Input.MOUSE_MODE_CAPTURED


func _ready() -> void:
	hide()
	UIComponents.apply_modal_language(modal_root, UIComponents.SURFACE_SAVE_LOAD)
	slot_1_button.pressed.connect(func() -> void: select_slot("slot_1"))
	slot_2_button.pressed.connect(func() -> void: select_slot("slot_2"))
	slot_3_button.pressed.connect(func() -> void: select_slot("slot_3"))
	new_game_button.pressed.connect(create_new_game)
	continue_button.pressed.connect(continue_selected_slot)
	overwrite_button.pressed.connect(overwrite_selected_slot)
	delete_button.pressed.connect(delete_selected_slot)
	close_button.pressed.connect(close)
	refresh_slots()


func open_for_session(session: StoreSession, registry: RefCounted = null) -> bool:
	_active_session = session
	if registry != null:
		_registry = registry
	refresh_slots()
	_enter_modal(close_button)
	return true


func close() -> bool:
	if not is_open():
		return false

	_active_session = null
	_exit_modal()
	return true


func is_open() -> bool:
	return visible


func select_slot(slot_id: String) -> bool:
	var normalized_id := _normalize_slot_id(slot_id)
	if normalized_id.is_empty():
		return false

	_selected_slot_id = normalized_id
	_status_text = "Selected %s." % _slot_label(_selected_slot_id)
	refresh_slots()
	return true


func create_new_game() -> bool:
	if _registry.create_new_game_slot(_selected_slot_id, false):
		_status_text = "New game saved to %s." % _slot_label(_selected_slot_id)
		refresh_slots()
		return true

	_status_text = "%s already has a save. Use overwrite to replace it." % _slot_label(_selected_slot_id)
	refresh_slots()
	return false


func continue_selected_slot() -> bool:
	_last_loaded_data = _registry.continue_slot(_selected_slot_id)
	if _last_loaded_data.is_empty():
		_status_text = "No save in %s." % _slot_label(_selected_slot_id)
		refresh_slots()
		return false

	_status_text = "Continue ready from %s." % _slot_label(_selected_slot_id)
	refresh_slots()
	return true


func overwrite_selected_slot() -> bool:
	if _active_session == null:
		_status_text = "No active session to save."
		refresh_slots()
		return false

	if _registry.overwrite_slot(_selected_slot_id, _active_session):
		_status_text = "Overwrote %s." % _slot_label(_selected_slot_id)
		refresh_slots()
		return true

	_status_text = "Could not overwrite %s." % _slot_label(_selected_slot_id)
	refresh_slots()
	return false


func delete_selected_slot() -> bool:
	if _registry.delete_slot(_selected_slot_id):
		_last_loaded_data = {}
		_status_text = "Deleted %s." % _slot_label(_selected_slot_id)
		refresh_slots()
		return true

	_status_text = "No save to delete in %s." % _slot_label(_selected_slot_id)
	refresh_slots()
	return false


func refresh_slots() -> void:
	title_label.text = "Save / Load"
	slot_list_label.text = _registry.get_save_slot_summary_text()
	metadata_label.text = _format_selected_metadata()
	status_label.text = _status_text

	for button in [slot_1_button, slot_2_button, slot_3_button]:
		var button_slot_id := _normalize_slot_id(button.name.replace("Button", "").replace("Slot", "slot_"))
		button.button_pressed = button_slot_id == _selected_slot_id


func get_selected_slot_id() -> String:
	return _selected_slot_id


func get_last_loaded_data() -> Dictionary:
	return _last_loaded_data.duplicate(true)


func get_status_text() -> String:
	return _status_text


func get_transition_state() -> String:
	return _transition_state


func get_requested_mouse_mode() -> int:
	return _requested_mouse_mode


func get_registry() -> RefCounted:
	return _registry


func has_modal_focus() -> bool:
	var focus_owner := get_viewport().gui_get_focus_owner()
	return focus_owner != null and is_ancestor_of(focus_owner)


func has_ui_component_language() -> bool:
	return modal_root.get_meta("ui_surface", "") == UIComponents.SURFACE_SAVE_LOAD \
		and modal_root.get_meta("ui_accessibility_requirements", {}).get("min_body_font_size", 0) >= UIComponents.MIN_BODY_FONT_SIZE \
		and close_button.get_meta("ui_component", "") == UIComponents.TOKEN_BUTTON


func has_accessibility_floor() -> bool:
	var audit: Dictionary = UIComponents.audit_modal_accessibility(modal_root)
	return bool(audit.get("passes", false))


func _format_selected_metadata() -> String:
	var metadata: Dictionary = _registry.get_slot_metadata(_selected_slot_id)
	if metadata.is_empty():
		return "%s: Empty" % _slot_label(_selected_slot_id)

	return "%s\nDay %d / %s\nCash %s / Reputation %d\nInventory %d / Transactions %d" % [
		str(metadata.get("label", _slot_label(_selected_slot_id))),
		int(metadata.get("day_number", 1)),
		str(metadata.get("day_phase", "setup")).capitalize(),
		_format_money(int(metadata.get("cash_cents", 0))),
		int(metadata.get("reputation_score", 100)),
		int(metadata.get("inventory_count", 0)),
		int(metadata.get("transaction_count", 0)),
	]


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


func _normalize_slot_id(slot_id: String) -> String:
	var stripped := slot_id.strip_edges().to_lower()
	if stripped in ["slot_1", "slot1", "1"]:
		return "slot_1"
	if stripped in ["slot_2", "slot2", "2"]:
		return "slot_2"
	if stripped in ["slot_3", "slot3", "3"]:
		return "slot_3"
	return stripped


func _slot_label(slot_id: String) -> String:
	if slot_id == "slot_1":
		return "Slot 1"
	if slot_id == "slot_2":
		return "Slot 2"
	if slot_id == "slot_3":
		return "Slot 3"
	return slot_id.capitalize()


func _format_money(cents: int) -> String:
	return "$%0.2f" % (float(cents) / 100.0)
