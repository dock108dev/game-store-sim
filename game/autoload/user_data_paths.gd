## Provides persistence paths for normal play and isolated test runs.
extends Node

const DEFAULT_SAVE_DIR: String = "user://"
const DEFAULT_BACKUP_DIR: String = "user://backups/"
const DEFAULT_SLOT_INDEX_PATH: String = "user://save_index.cfg"
const DEFAULT_SETTINGS_PATH: String = "user://settings.cfg"
const DEFAULT_TUTORIAL_PROGRESS_PATH: String = "user://tutorial_progress.cfg"
const DEFAULT_SLOT_PATHS: Dictionary = {
	0: "user://save_slot_0.json",
	1: "user://save_slot_1.json",
	2: "user://save_slot_2.json",
	3: "user://save_slot_3.json",
}
const TEST_RUNS_ROOT: String = "user://test_runs/"

var _automation_root: String = ""
var _test_run_id: String = ""


## Routes save, settings, and tutorial-progress files under an isolated test root.
func configure_automation_root(root_path: String, clear_existing: bool) -> Error:
	var normalized: String = resolve_test_run_root(root_path)
	if normalized.is_empty():
		return ERR_INVALID_PARAMETER
	if not _is_test_run_root(normalized):
		return ERR_INVALID_PARAMETER
	if clear_existing:
		var clear_error: Error = _remove_tree(normalized)
		if clear_error != OK and clear_error != ERR_DOES_NOT_EXIST:
			return clear_error
	var make_error: Error = DirAccess.make_dir_recursive_absolute(normalized)
	if make_error != OK:
		return make_error
	_automation_root = normalized
	_test_run_id = _extract_test_run_id(normalized)
	return OK


## Routes persistence under user://test_runs/<run_id>/.
func configure_test_run(run_id: String, clear_existing: bool) -> Error:
	var sanitized: String = sanitize_run_id(run_id)
	if sanitized.is_empty():
		return ERR_INVALID_PARAMETER
	return configure_automation_root(test_run_root(sanitized), clear_existing)


## Resolves a run id or test-run root to a canonical user://test_runs/<id> root.
func resolve_test_run_root(root_or_run_id: String) -> String:
	var trimmed: String = _normalize_root(root_or_run_id)
	if trimmed.is_empty():
		return ""
	if trimmed.begins_with(TEST_RUNS_ROOT):
		return trimmed
	if trimmed.begins_with("user://"):
		return ""
	var sanitized: String = sanitize_run_id(trimmed)
	if sanitized.is_empty():
		return ""
	return test_run_root(sanitized)


## Returns the canonical root for a test run id.
func test_run_root(run_id: String) -> String:
	var sanitized: String = sanitize_run_id(run_id)
	if sanitized.is_empty():
		return ""
	return "%s%s" % [TEST_RUNS_ROOT, sanitized]


## Converts external run ids into filesystem-safe directory names.
func sanitize_run_id(raw: String) -> String:
	var out: String = ""
	var trimmed: String = raw.strip_edges()
	for i: int in trimmed.length():
		var ch: String = trimmed.substr(i, 1).to_lower()
		var code: int = ch.unicode_at(0)
		if (code >= 48 and code <= 57) or (code >= 97 and code <= 122):
			out += ch
		elif ch == "_" or ch == "-":
			out += ch
		else:
			out += "_"
	while out.begins_with("_"):
		out = out.substr(1)
	while out.ends_with("_"):
		out = out.substr(0, out.length() - 1)
	return out.substr(0, 96)


## Removes the active test-run root and leaves normal user:// paths untouched.
func cleanup_active_test_run() -> Error:
	if _automation_root.is_empty():
		return ERR_DOES_NOT_EXIST
	if not _is_test_run_root(_automation_root):
		return ERR_INVALID_PARAMETER
	var cleanup_error: Error = _remove_tree(_automation_root)
	if cleanup_error == OK or cleanup_error == ERR_DOES_NOT_EXIST:
		reset_for_normal_play()
		return OK
	return cleanup_error


## Restores the default production user:// paths.
func reset_for_normal_play() -> void:
	_automation_root = ""
	_test_run_id = ""


## Returns true when persistence is routed to an isolated automation root.
func is_automation_root_enabled() -> bool:
	return not _automation_root.is_empty()


## Returns the active isolated root, or an empty string in normal play.
func get_automation_root() -> String:
	return _automation_root


## Returns the active test run id, or an empty string in normal play.
func get_test_run_id() -> String:
	return _test_run_id


## Returns the directory that contains save slots and the slot index.
func save_dir() -> String:
	if _automation_root.is_empty():
		return DEFAULT_SAVE_DIR
	return "%s/" % _automation_root


## Returns the directory used for migration backups.
func backup_dir() -> String:
	if _automation_root.is_empty():
		return DEFAULT_BACKUP_DIR
	return "%s/backups/" % _automation_root


## Returns the path for the save-slot index file.
func slot_index_path() -> String:
	if _automation_root.is_empty():
		return DEFAULT_SLOT_INDEX_PATH
	return "%s/save_index.cfg" % _automation_root


## Returns the save-file path for the requested slot number.
func save_slot_path(slot: int) -> String:
	return "%ssave_slot_%d.json" % [save_dir(), slot]


## Returns the active settings path.
func settings_path() -> String:
	if _automation_root.is_empty():
		return DEFAULT_SETTINGS_PATH
	return "%s/settings.cfg" % _automation_root


## Returns the active tutorial-progress path.
func tutorial_progress_path() -> String:
	if _automation_root.is_empty():
		return DEFAULT_TUTORIAL_PROGRESS_PATH
	return "%s/tutorial_progress.cfg" % _automation_root


func _normalize_root(root_path: String) -> String:
	var trimmed: String = root_path.strip_edges()
	while trimmed.length() > "user://".length() and trimmed.ends_with("/"):
		trimmed = trimmed.substr(0, trimmed.length() - 1)
	return trimmed


func _is_test_run_root(path: String) -> bool:
	if not path.begins_with(TEST_RUNS_ROOT):
		return false
	var run_id: String = _extract_test_run_id(path)
	return not run_id.is_empty() and not run_id.contains("/") and run_id != ".."


func _extract_test_run_id(path: String) -> String:
	return path.trim_prefix(TEST_RUNS_ROOT)


func _remove_tree(path: String) -> Error:
	if not DirAccess.dir_exists_absolute(path):
		return ERR_DOES_NOT_EXIST
	var dir: DirAccess = DirAccess.open(path)
	if dir == null:
		return DirAccess.get_open_error()
	dir.list_dir_begin()
	var entry: String = dir.get_next()
	while not entry.is_empty():
		if entry == "." or entry == "..":
			entry = dir.get_next()
			continue
		var child_path: String = "%s/%s" % [path, entry]
		var err: Error = OK
		if dir.current_is_dir():
			err = _remove_tree(child_path)
		else:
			err = DirAccess.remove_absolute(child_path)
		if err != OK and err != ERR_DOES_NOT_EXIST:
			dir.list_dir_end()
			return err
		entry = dir.get_next()
	dir.list_dir_end()
	return DirAccess.remove_absolute(path)
