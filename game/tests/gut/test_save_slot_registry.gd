extends GutTest

const SaveSlotRegistryScript := preload("res://scripts/save/save_slot_registry.gd")

var _save_dirs: Array[String] = []


func after_each() -> void:
	for save_dir in _save_dirs:
		_remove_save_dir(save_dir)
	_save_dirs.clear()


func test_save_slot_registry_creates_new_game_slot_with_metadata() -> void:
	var registry = _make_registry()

	assert_true(registry.create_new_game_slot("slot_1"))
	assert_true(registry.has_slot("slot_1"))

	var slots: Array = registry.list_slots()
	var metadata: Dictionary = registry.get_slot_metadata("slot_1")
	assert_eq(slots.size(), 1)
	assert_eq(metadata.get("slot_id"), "slot_1")
	assert_eq(metadata.get("label"), "Slot 1")
	assert_eq(int(metadata.get("version")), 1)
	assert_eq(int(metadata.get("day_number")), 1)
	assert_string_contains(str(metadata.get("summary_text", "")), "Day 1")
	assert_string_contains(registry.get_save_slot_summary_text(), "Slot 1")


func test_save_slot_registry_blocks_accidental_overwrite_and_allows_explicit_overwrite() -> void:
	var registry = _make_registry()
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	session.cash_cents = 12345

	assert_true(registry.save_slot("slot_2", session))
	session.cash_cents = 22222
	assert_false(registry.save_slot("slot_2", session))
	assert_true(registry.overwrite_slot("slot_2", session))

	var data: Dictionary = registry.continue_slot("slot_2")
	var metadata: Dictionary = registry.get_slot_metadata("slot_2")
	assert_eq(int(data.get("cash_cents")), 22222)
	assert_eq(int(metadata.get("cash_cents")), 22222)
	assert_eq(metadata.get("label"), "Slot 2")
	session.free()


func test_save_slot_registry_deletes_slots_and_returns_empty_continue_data() -> void:
	var registry = _make_registry()
	assert_true(registry.create_new_game_slot("slot_3"))
	assert_true(registry.has_slot("slot_3"))

	assert_true(registry.delete_slot("slot_3"))
	assert_false(registry.has_slot("slot_3"))
	assert_true(registry.continue_slot("slot_3").is_empty())
	assert_false(registry.delete_slot("slot_3"))


func test_save_slot_registry_metadata_counts_inventory_and_transactions() -> void:
	var registry = _make_registry()
	var data := {
		"version": 1,
		"day_number": 4,
		"day_phase": StoreSession.DAY_PHASE_REPORT,
		"cash_cents": 44444,
		"reputation_score": 95,
		"inventory_items": [{"instance_id": "item_001"}, {"instance_id": "item_002"}],
		"transactions": [{"transaction_id": "sale_001"}],
	}

	var metadata: Dictionary = registry.build_metadata("slot_1", data)
	assert_eq(metadata.get("inventory_count"), 2)
	assert_eq(metadata.get("transaction_count"), 1)
	assert_eq(metadata.get("reputation_score"), 95)
	assert_string_contains(str(metadata.get("summary_text", "")), "Day 4")


func _make_registry():
	var registry = SaveSlotRegistryScript.new()
	var save_dir := "user://gut_save_slots_%d" % Time.get_ticks_usec()
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
