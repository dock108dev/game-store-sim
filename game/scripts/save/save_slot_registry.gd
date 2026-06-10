extends RefCounted
class_name SaveSlotRegistry

const StoreSaveCodecScript := preload("res://scripts/save/store_save_codec.gd")

const DEFAULT_SAVE_DIRECTORY := "user://saves"
const SLOT_EXTENSION := ".json"

var save_directory: String = DEFAULT_SAVE_DIRECTORY
var _codec: StoreSaveCodec = StoreSaveCodecScript.new()


func set_save_directory(path: String) -> void:
	if path.strip_edges().is_empty():
		save_directory = DEFAULT_SAVE_DIRECTORY
		return

	save_directory = path.strip_edges()


func create_new_game_slot(slot_id: String, overwrite: bool = false) -> bool:
	var session := StoreSession.new()
	var saved := save_slot(slot_id, session, overwrite)
	session.free()
	return saved


func save_slot(slot_id: String, session: StoreSession, overwrite: bool = false) -> bool:
	var normalized_id := _normalize_slot_id(slot_id)
	if session == null or normalized_id.is_empty():
		return false
	if has_slot(normalized_id) and not overwrite:
		return false
	if not _ensure_save_directory():
		return false

	var data := _codec.create_save_data(session)
	if data.is_empty():
		return false

	var metadata := build_metadata(normalized_id, data)
	data["slot_metadata"] = metadata
	data["saved_at_unix"] = metadata.get("saved_at_unix", 0)

	var file := FileAccess.open(_slot_path(normalized_id), FileAccess.WRITE)
	if file == null:
		return false

	file.store_string(_codec.encode_to_json(data))
	return true


func overwrite_slot(slot_id: String, session: StoreSession) -> bool:
	return save_slot(slot_id, session, true)


func delete_slot(slot_id: String) -> bool:
	var normalized_id := _normalize_slot_id(slot_id)
	if normalized_id.is_empty() or not has_slot(normalized_id):
		return false

	return DirAccess.remove_absolute(ProjectSettings.globalize_path(_slot_path(normalized_id))) == OK


func continue_slot(slot_id: String) -> Dictionary:
	var normalized_id := _normalize_slot_id(slot_id)
	if normalized_id.is_empty() or not has_slot(normalized_id):
		return {}

	var json_text := FileAccess.get_file_as_string(_slot_path(normalized_id))
	return _codec.decode_from_json(json_text)


func has_slot(slot_id: String) -> bool:
	var normalized_id := _normalize_slot_id(slot_id)
	if normalized_id.is_empty():
		return false

	return FileAccess.file_exists(_slot_path(normalized_id))


func list_slots() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var directory := DirAccess.open(save_directory)
	if directory == null:
		return rows

	directory.list_dir_begin()
	var file_name := directory.get_next()
	while not file_name.is_empty():
		if not directory.current_is_dir() and file_name.ends_with(SLOT_EXTENSION):
			var data := _codec.decode_from_json(FileAccess.get_file_as_string("%s/%s" % [save_directory, file_name]))
			var metadata := data.get("slot_metadata", {}) as Dictionary
			if not metadata.is_empty():
				rows.append(metadata)
		file_name = directory.get_next()
	directory.list_dir_end()

	rows.sort_custom(func(first: Dictionary, second: Dictionary) -> bool:
		return str(first.get("slot_id", "")) < str(second.get("slot_id", ""))
	)
	return rows


func get_slot_metadata(slot_id: String) -> Dictionary:
	var data := continue_slot(slot_id)
	if data.is_empty():
		return {}

	return data.get("slot_metadata", {}) as Dictionary


func build_metadata(slot_id: String, data: Dictionary) -> Dictionary:
	var normalized_id := _normalize_slot_id(slot_id)
	var inventory_items := data.get("inventory_items", []) as Array
	var transactions := data.get("transactions", []) as Array
	var day_number := int(data.get("day_number", 1))
	var cash_cents := int(data.get("cash_cents", 0))
	var day_phase := str(data.get("day_phase", "setup"))
	return {
		"slot_id": normalized_id,
		"label": _slot_label(normalized_id),
		"version": int(data.get("version", 1)),
		"day_number": day_number,
		"day_phase": day_phase,
		"cash_cents": cash_cents,
		"reputation_score": int(data.get("reputation_score", 100)),
		"inventory_count": inventory_items.size(),
		"transaction_count": transactions.size(),
		"saved_at_unix": int(Time.get_unix_time_from_system()),
		"summary_text": "%s - Day %d, %s, cash %s" % [
			_slot_label(normalized_id),
			day_number,
			day_phase.capitalize(),
			_format_money(cash_cents),
		],
	}


func get_save_slot_summary_text() -> String:
	var rows := list_slots()
	if rows.is_empty():
		return "Save slots:\nNo saves yet."

	var lines: Array[String] = ["Save slots:"]
	for row in rows:
		lines.append(str(row.get("summary_text", "")))
	return "\n".join(lines)


func _ensure_save_directory() -> bool:
	return DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(save_directory)) == OK


func _slot_path(slot_id: String) -> String:
	return "%s/%s%s" % [save_directory, _normalize_slot_id(slot_id), SLOT_EXTENSION]


func _normalize_slot_id(slot_id: String) -> String:
	var stripped := slot_id.strip_edges().to_lower()
	var result := ""
	for index in stripped.length():
		var character := stripped.substr(index, 1)
		if (character >= "a" and character <= "z") or (character >= "0" and character <= "9"):
			result += character
		elif character == "_" or character == "-":
			result += character

	return result


func _slot_label(slot_id: String) -> String:
	var normalized_id := _normalize_slot_id(slot_id)
	if normalized_id.begins_with("slot_"):
		return "Slot %s" % normalized_id.trim_prefix("slot_")
	if normalized_id.begins_with("slot"):
		return "Slot %s" % normalized_id.trim_prefix("slot")
	return normalized_id.capitalize()


func _format_money(cents: int) -> String:
	return "$%0.2f" % (float(cents) / 100.0)
