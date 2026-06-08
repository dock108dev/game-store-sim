extends GutTest

const SaveSlotRegistryScript := preload("res://scripts/save/save_slot_registry.gd")

var _panel: Node
var _registry
var _session: StoreSession
var _save_dirs: Array[String] = []


func before_each() -> void:
	_panel = load("res://scenes/ui/save_slot_panel.tscn").instantiate()
	_registry = _make_registry()
	_session = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(_panel)
	add_child_autofree(_session)


func after_each() -> void:
	for save_dir in _save_dirs:
		_remove_save_dir(save_dir)
	_save_dirs.clear()


func test_save_slot_panel_starts_hidden_with_ui_language() -> void:
	assert_false(_panel.visible)
	assert_true(_panel.has_ui_component_language())
	assert_true(_panel.has_accessibility_floor())
	assert_eq(_panel.get_selected_slot_id(), "slot_1")


func test_save_slot_panel_opens_with_mouse_focus_and_slot_metadata() -> void:
	assert_true(_panel.open_for_session(_session, _registry))

	assert_true(_panel.is_open())
	assert_eq(_panel.get_transition_state(), "open")
	assert_eq(_panel.get_requested_mouse_mode(), Input.MOUSE_MODE_VISIBLE)
	assert_true(_panel.has_modal_focus())
	assert_string_contains(_panel.metadata_label.text, "Slot 1: Empty")
	assert_string_contains(_panel.slot_list_label.text, "No saves yet")


func test_save_slot_panel_creates_and_continues_new_game_slot() -> void:
	assert_true(_panel.open_for_session(_session, _registry))

	assert_true(_panel.create_new_game())
	assert_true(_registry.has_slot("slot_1"))
	assert_string_contains(_panel.get_status_text(), "New game saved")
	assert_string_contains(_panel.metadata_label.text, "Day 1")

	assert_true(_panel.continue_selected_slot())
	assert_false(_panel.get_last_loaded_data().is_empty())
	assert_eq(int(_panel.get_last_loaded_data().get("day_number")), 1)
	assert_string_contains(_panel.get_status_text(), "Continue ready")


func test_save_slot_panel_requires_overwrite_for_existing_slot() -> void:
	_session.cash_cents = 11111
	assert_true(_panel.open_for_session(_session, _registry))
	assert_true(_panel.overwrite_selected_slot())

	_session.cash_cents = 22222
	assert_false(_panel.create_new_game())
	assert_string_contains(_panel.get_status_text(), "already has a save")
	assert_true(_panel.overwrite_selected_slot())

	var data: Dictionary = _registry.continue_slot("slot_1")
	assert_eq(int(data.get("cash_cents")), 22222)
	assert_string_contains(_panel.get_status_text(), "Overwrote")


func test_save_slot_panel_deletes_selected_slot() -> void:
	assert_true(_panel.open_for_session(_session, _registry))
	assert_true(_panel.create_new_game())
	assert_true(_panel.delete_selected_slot())

	assert_false(_registry.has_slot("slot_1"))
	assert_true(_panel.get_last_loaded_data().is_empty())
	assert_string_contains(_panel.get_status_text(), "Deleted")


func test_save_slot_panel_closes_to_captured_mouse() -> void:
	assert_true(_panel.open_for_session(_session, _registry))
	assert_true(_panel.close())

	assert_false(_panel.is_open())
	assert_eq(_panel.get_transition_state(), "closed")
	assert_eq(_panel.get_requested_mouse_mode(), Input.MOUSE_MODE_CAPTURED)


func _make_registry():
	var registry = SaveSlotRegistryScript.new()
	var save_dir := "user://gut_save_slot_panel_%d" % Time.get_ticks_usec()
	registry.set_save_directory(save_dir)
	_save_dirs.append(save_dir)
	return registry


func _remove_save_dir(save_dir: String) -> void:
	var absolute_dir := ProjectSettings.globalize_path(save_dir)
	var directory := DirAccess.open(absolute_dir)
	if directory != null:
		directory.list_dir_begin()
		var file_name := directory.get_next()
		while not file_name.is_empty():
			if not directory.current_is_dir():
				DirAccess.remove_absolute("%s/%s" % [absolute_dir, file_name])
			file_name = directory.get_next()
		directory.list_dir_end()
	DirAccess.remove_absolute(absolute_dir)
