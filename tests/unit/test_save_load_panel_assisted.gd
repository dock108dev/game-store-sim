## Tests for SaveLoadPanel Assisted badge display in slot rows.
extends GutTest


const _SCENE: PackedScene = preload(
	"res://game/scenes/ui/save_load_panel.tscn"
)

const _TEST_SLOT: int = 3

var _panel: SaveLoadPanel
var _save_manager: SaveManager


func before_each() -> void:
	var path_err: Error = UserDataPaths.configure_test_run(
		"save_load_panel_assisted",
		true
	)
	assert_eq(path_err, OK, "test setup must isolate save paths")

	_panel = _SCENE.instantiate() as SaveLoadPanel
	add_child_autofree(_panel)

	_save_manager = SaveManager.new()
	add_child_autofree(_save_manager)

	_panel.save_manager = _save_manager


func after_each() -> void:
	UserDataPaths.cleanup_active_test_run()
	UserDataPaths.reset_for_normal_play()


func _write_mock_save(
	used_downgrade: bool,
	slot: int = _TEST_SLOT,
	day: int = 7,
	cash: float = 3000.0,
	owned_stores: Array[String] = ["retro_games"]
) -> void:
	DirAccess.make_dir_recursive_absolute(UserDataPaths.save_dir())
	var path: String = UserDataPaths.save_slot_path(slot)
	var mock_data: Dictionary = {
		"save_version": SaveManager.CURRENT_SAVE_VERSION,
		"save_metadata": {
			"day": day,
			"cash": cash,
			"owned_stores": owned_stores,
			"saved_at": "2026-01-01T00:00:00",
			"used_difficulty_downgrade": used_downgrade,
		},
		"difficulty": {
			"current_tier": "easy",
			"used_difficulty_downgrade": used_downgrade,
		},
	}
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(mock_data))
		file.close()


func _find_assisted_label_in_slot_row(row: Node) -> Label:
	for child: Node in row.get_children():
		var assisted: Label = _find_assisted_label_recursive(child)
		if assisted:
			return assisted
	return null


func _find_assisted_label_recursive(node: Node) -> Label:
	for child: Node in node.get_children():
		if child is Label and (child as Label).text == "Assisted":
			return child as Label
		var found: Label = _find_assisted_label_recursive(child)
		if found:
			return found
	return null


func _row_has_label_text(row: Node, text: String) -> bool:
	for child: Node in row.get_children():
		if child is Label and (child as Label).text == text:
			return true
		if _row_has_label_text(child, text):
			return true
	return false


func _find_action_button_in_slot_row(row: Node) -> Button:
	for child: Node in row.get_children():
		if child is Button:
			return child as Button
		var found: Button = _find_action_button_in_slot_row(child)
		if found:
			return found
	return null


func _find_row_with_label(text: String) -> Node:
	for row: Node in _panel._slot_container.get_children():
		if _row_has_label_text(row, text):
			return row
	return null


## Assisted badge appears in the slot row when used_difficulty_downgrade is true.
func test_assisted_badge_shown_when_flag_is_true() -> void:
	_write_mock_save(true)
	_panel.open_load()

	var slot_container: VBoxContainer = _panel._slot_container
	var assisted_found: Array = [false]
	for row: Node in slot_container.get_children():
		var label: Label = _find_assisted_label_in_slot_row(row)
		if label:
			assisted_found[0] = true
			break

	assert_true(
		assisted_found[0],
		"Assisted badge should appear in slot row when used_difficulty_downgrade is true"
	)


## No Assisted badge when used_difficulty_downgrade is false.
func test_assisted_badge_absent_when_flag_is_false() -> void:
	_write_mock_save(false)
	_panel.open_load()

	var slot_container: VBoxContainer = _panel._slot_container
	var assisted_found: Array = [false]
	for row: Node in slot_container.get_children():
		var label: Label = _find_assisted_label_in_slot_row(row)
		if label:
			assisted_found[0] = true
			break

	assert_false(
		assisted_found[0],
		"Assisted badge should not appear when used_difficulty_downgrade is false"
	)


## Assisted badge has a non-empty tooltip text.
func test_assisted_badge_has_tooltip() -> void:
	_write_mock_save(true)
	_panel.open_load()

	var slot_container: VBoxContainer = _panel._slot_container
	var assisted_label: Label = null
	for row: Node in slot_container.get_children():
		var label: Label = _find_assisted_label_in_slot_row(row)
		if label:
			assisted_label = label
			break

	assert_not_null(
		assisted_label,
		"Assisted label must exist to check tooltip"
	)
	if assisted_label:
		assert_true(
			assisted_label.tooltip_text.length() > 0,
			"Assisted badge must have a non-empty tooltip"
		)


func test_load_panel_shows_preview_metadata_for_occupied_slot() -> void:
	_write_mock_save(false, _TEST_SLOT, 12, 9876.0, ["sports", "retro_games"])

	_panel.open_load()

	assert_not_null(
		_find_row_with_label("Day 12 — $9876 — 2 stores"),
		"Occupied slot should show day, cash, and owned store count"
	)


func test_load_panel_shows_empty_slot_for_unoccupied_slot() -> void:
	_panel.open_load()

	assert_not_null(
		_find_row_with_label("Empty Slot"),
		"Unoccupied slots should show Empty Slot"
	)


func test_empty_slots_are_disabled_in_load_mode() -> void:
	_panel.open_load()

	var disabled_empty_rows: int = 0
	for row: Node in _panel._slot_container.get_children():
		if not _row_has_label_text(row, "Empty Slot"):
			continue
		var button: Button = _find_action_button_in_slot_row(row)
		assert_not_null(button, "Empty slot rows should still render an action button")
		if button and button.disabled:
			disabled_empty_rows += 1

	assert_eq(
		disabled_empty_rows,
		SaveManager.MAX_MANUAL_SLOTS + 1,
		"Auto-save plus all manual empty slots should be disabled in load mode"
	)


func test_occupied_save_slot_requires_overwrite_confirmation() -> void:
	_write_mock_save(false, _TEST_SLOT)
	watch_signals(_panel)

	_panel.open_save()
	var row: Node = _find_row_with_label("Day 7 — $3000 — 1 stores")
	assert_not_null(row, "Occupied manual slot should render in save mode")
	if row == null:
		return
	var button: Button = _find_action_button_in_slot_row(row)
	assert_not_null(button, "Occupied save row should have an action button")
	if button == null:
		return

	button.pressed.emit()
	assert_true(_panel._confirm_dialog.visible)
	assert_signal_not_emitted(
		_panel,
		"save_requested",
		"Occupied save slot must wait for overwrite confirmation"
	)

	_panel._confirm_yes.pressed.emit()
	assert_signal_emitted(
		_panel,
		"save_requested",
		"Overwrite confirmation should emit save_requested"
	)


## Assisted badge uses MOUSE_FILTER_PASS to receive hover events for tooltip.
func test_assisted_badge_mouse_filter_pass() -> void:
	_write_mock_save(true)
	_panel.open_load()

	var slot_container: VBoxContainer = _panel._slot_container
	var assisted_label: Label = null
	for row: Node in slot_container.get_children():
		var label: Label = _find_assisted_label_in_slot_row(row)
		if label:
			assisted_label = label
			break

	assert_not_null(
		assisted_label,
		"Assisted label must exist to check mouse_filter"
	)
	if assisted_label:
		assert_eq(
			assisted_label.mouse_filter,
			Control.MOUSE_FILTER_PASS,
			"Assisted badge must use MOUSE_FILTER_PASS to show tooltip on hover"
		)
