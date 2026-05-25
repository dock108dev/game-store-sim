## Tests for isolated persistence path routing.
extends GutTest

const SettingsScript: GDScript = preload("res://game/autoload/settings.gd")
const MainMenuScript: GDScript = preload("res://game/scenes/ui/main_menu.gd")
const PATH_PROVIDER: String = "res://game/autoload/user_data_paths.gd"
const FORBIDDEN_PERSISTENCE_LITERALS: Array[String] = [
	"user://save_slot_",
	"user://save_index.cfg",
	"user://backups/",
	"user://settings.cfg",
	"user://tutorial_progress.cfg",
]


func after_each() -> void:
	UserDataPaths.cleanup_active_test_run()
	UserDataPaths.reset_for_normal_play()


func test_default_paths_match_normal_profile_shape() -> void:
	UserDataPaths.reset_for_normal_play()

	assert_eq(UserDataPaths.save_dir(), UserDataPaths.DEFAULT_SAVE_DIR)
	assert_eq(UserDataPaths.backup_dir(), UserDataPaths.DEFAULT_BACKUP_DIR)
	assert_eq(
		UserDataPaths.slot_index_path(),
		UserDataPaths.DEFAULT_SLOT_INDEX_PATH
	)
	assert_eq(UserDataPaths.settings_path(), UserDataPaths.DEFAULT_SETTINGS_PATH)
	assert_eq(
		UserDataPaths.tutorial_progress_path(),
		UserDataPaths.DEFAULT_TUTORIAL_PROGRESS_PATH
	)
	assert_eq(
		UserDataPaths.save_slot_path(2),
		UserDataPaths.DEFAULT_SLOT_PATHS.get(2)
	)


func test_test_run_paths_resolve_under_isolated_root() -> void:
	var err: Error = UserDataPaths.configure_test_run("run_a", true)
	assert_eq(err, OK)

	assert_eq(UserDataPaths.get_automation_root(), "user://test_runs/run_a")
	assert_eq(UserDataPaths.get_test_run_id(), "run_a")
	assert_eq(UserDataPaths.save_dir(), "user://test_runs/run_a/")
	assert_eq(UserDataPaths.backup_dir(), "user://test_runs/run_a/backups/")
	assert_eq(
		UserDataPaths.slot_index_path(),
		"user://test_runs/run_a/save_index.cfg"
	)
	assert_eq(
		UserDataPaths.settings_path(),
		"user://test_runs/run_a/settings.cfg"
	)
	assert_eq(
		UserDataPaths.tutorial_progress_path(),
		"user://test_runs/run_a/tutorial_progress.cfg"
	)
	assert_eq(
		UserDataPaths.save_slot_path(3),
		"user://test_runs/run_a/save_slot_3.json"
	)


func test_cleanup_removes_only_active_test_run_root() -> void:
	var normal_snapshot: Dictionary = _file_snapshot(
		UserDataPaths.DEFAULT_SLOT_PATHS.get(0)
	)
	var err: Error = UserDataPaths.configure_test_run("cleanup_paths", true)
	assert_eq(err, OK)
	var root: String = UserDataPaths.get_automation_root()
	_write_text(UserDataPaths.settings_path(), "[display]\n")

	assert_eq(UserDataPaths.cleanup_active_test_run(), OK)

	assert_false(DirAccess.dir_exists_absolute(root))
	assert_eq(
		_file_snapshot(UserDataPaths.DEFAULT_SLOT_PATHS.get(0)),
		normal_snapshot
	)
	assert_eq(
		UserDataPaths.configure_automation_root("user://", true),
		ERR_INVALID_PARAMETER
	)
	assert_eq(
		UserDataPaths.configure_automation_root("user://settings.cfg", true),
		ERR_INVALID_PARAMETER
	)


func test_two_test_runs_do_not_share_persistence_state() -> void:
	assert_eq(UserDataPaths.configure_test_run("run_one", true), OK)
	_write_text(UserDataPaths.save_slot_path(0), "{\"marker\":\"one\"}")
	var run_one_slot: String = UserDataPaths.save_slot_path(0)

	assert_eq(UserDataPaths.configure_test_run("run_two", true), OK)
	assert_false(FileAccess.file_exists(UserDataPaths.save_slot_path(0)))
	_write_text(UserDataPaths.save_slot_path(0), "{\"marker\":\"two\"}")
	var run_two_slot: String = UserDataPaths.save_slot_path(0)

	assert_ne(run_one_slot, run_two_slot)
	assert_true(FileAccess.file_exists(run_one_slot))
	assert_true(FileAccess.file_exists(run_two_slot))
	assert_eq(_read_text(run_one_slot), "{\"marker\":\"one\"}")
	assert_eq(_read_text(run_two_slot), "{\"marker\":\"two\"}")
	assert_eq(UserDataPaths.configure_test_run("run_one", false), OK)
	assert_eq(UserDataPaths.cleanup_active_test_run(), OK)
	assert_eq(UserDataPaths.configure_test_run("run_two", false), OK)
	assert_eq(UserDataPaths.cleanup_active_test_run(), OK)


func test_fresh_test_root_uses_defaults_without_profile_fallback() -> void:
	assert_eq(UserDataPaths.configure_test_run("fresh_state", true), OK)

	var settings = SettingsScript.new()
	settings.settings_path = UserDataPaths.settings_path()
	add_child_autofree(settings)
	assert_eq(settings.locale, "en")
	assert_eq(settings.tutorial_skip, false)

	var tutorial := TutorialSystem.new()
	add_child_autofree(tutorial)
	tutorial.initialize(false)
	assert_true(tutorial.tutorial_active)
	assert_eq(tutorial.current_step, TutorialSystem.TutorialStep.WELCOME)

	var save_manager := SaveManager.new()
	assert_eq(save_manager.get_all_slot_metadata(), {})
	save_manager.free()


func test_new_game_tutorial_progress_writes_to_test_root() -> void:
	var default_snapshot: Dictionary = _file_snapshot(
		UserDataPaths.DEFAULT_TUTORIAL_PROGRESS_PATH
	)
	assert_eq(UserDataPaths.configure_test_run("fresh_tutorial_write", true), OK)

	var tutorial := TutorialSystem.new()
	add_child_autofree(tutorial)
	tutorial.initialize(true)

	assert_true(
		FileAccess.file_exists(UserDataPaths.tutorial_progress_path()),
		"New-game tutorial progress should be written under the active test root"
	)
	assert_eq(
		_file_snapshot(UserDataPaths.DEFAULT_TUTORIAL_PROGRESS_PATH),
		default_snapshot,
		"Isolated tutorial writes must not touch the normal profile path"
	)


func test_corrupt_test_run_save_preview_is_ignored_without_fallback() -> void:
	assert_eq(UserDataPaths.configure_test_run("corrupt_preview", true), OK)
	_write_text(UserDataPaths.save_slot_path(0), "{broken")

	var menu: Control = MainMenuScript.new()
	assert_eq(menu._read_slot_info(UserDataPaths.save_slot_path(0)), {})
	menu.free()


func test_production_persistence_paths_go_through_provider() -> void:
	var offenders: Array[String] = []
	_scan_gd_files("res://game", offenders)

	assert_eq(offenders, [])


func _scan_gd_files(dir_path: String, offenders: Array[String]) -> void:
	var dir: DirAccess = DirAccess.open(dir_path)
	assert_not_null(dir, "Directory must open: %s" % dir_path)
	if dir == null:
		return
	dir.list_dir_begin()
	var entry: String = dir.get_next()
	while not entry.is_empty():
		var path: String = "%s/%s" % [dir_path, entry]
		if dir.current_is_dir():
			_scan_gd_files(path, offenders)
		elif entry.ends_with(".gd") and path != PATH_PROVIDER:
			_scan_file_for_persistence_literals(path, offenders)
		entry = dir.get_next()
	dir.list_dir_end()


func _scan_file_for_persistence_literals(
	path: String, offenders: Array[String]
) -> void:
	var source: String = _read_text(path)
	for literal: String in FORBIDDEN_PERSISTENCE_LITERALS:
		if source.contains(literal):
			offenders.append("%s contains %s" % [path, literal])


func _write_text(path: String, text: String) -> void:
	var dir_path: String = path.get_base_dir()
	if not dir_path.is_empty():
		DirAccess.make_dir_recursive_absolute(dir_path)
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	assert_not_null(file, "File must open for write: %s" % path)
	if file == null:
		return
	file.store_string(text)
	file.close()


func _read_text(path: String) -> String:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var text: String = file.get_as_text()
	file.close()
	return text


func _file_snapshot(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"exists": false}
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"exists": true, "length": -1}
	var length: int = file.get_length()
	file.close()
	return {"exists": true, "length": length}
