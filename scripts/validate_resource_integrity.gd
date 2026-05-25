## Headless Godot validator for launch-critical project paths and resources.
extends SceneTree

const VALIDATOR := "resource-integrity"
const NEXT_COMMAND := "bash scripts/validate_resource_integrity.sh"
const PROJECT_FILE := "res://project.godot"
const TEXT_SCAN_EXTENSIONS := {
	"cfg": true,
	"gdshader": true,
	"import": true,
	"tscn": true,
	"tres": true,
}
const SCAN_ROOTS := [
	"res://game",
	"res://project.godot",
	"res://export_presets.cfg",
	"res://.gutconfig.json",
	"res://.gutconfig.pr-smoke.json",
]

var _errors: Array[String] = []
var _seen_refs: Dictionary = {}


func _init() -> void:
	_validate_project_settings()
	_validate_text_references()
	if _errors.is_empty():
		print("Resource integrity: references OK")
		quit(0)
		return
	for error in _errors:
		push_error(error)
		print(error)
	quit(1)


func _validate_project_settings() -> void:
	var config := ConfigFile.new()
	var load_status := config.load(PROJECT_FILE)
	if load_status != OK:
		_add_error(PROJECT_FILE, "project config failed to parse: %s" % error_string(load_status))
		return

	var main_scene := str(config.get_value("application", "run/main_scene", ""))
	if main_scene.is_empty():
		_add_error(PROJECT_FILE, "application/run/main_scene is empty")
	else:
		_validate_required_path(main_scene, PROJECT_FILE)

	if not config.has_section("autoload"):
		_add_error(PROJECT_FILE, "autoload section missing")
		return

	for autoload_name in config.get_section_keys("autoload"):
		var raw_path := str(config.get_value("autoload", autoload_name, ""))
		var path := _clean_project_path(raw_path)
		if path.is_empty():
			_add_error(PROJECT_FILE, "autoload '%s' has an empty path" % autoload_name)
			continue
		_validate_required_path(path, "autoload:%s" % autoload_name)


func _validate_text_references() -> void:
	var files: Array[String] = []
	for root in SCAN_ROOTS:
		if _is_file(root):
			files.append(root)
		else:
			_scan_files(root, TEXT_SCAN_EXTENSIONS, files)

	var regex := RegEx.new()
	var compile_status := regex.compile("res://[^\\\"'`\\s,\\)\\]\\}]+")
	if compile_status != OK:
		_add_error("RegEx", "reference pattern failed to compile")
		return

	for path in files:
		var text := _read_text(path)
		if text.is_empty():
			continue
		for match_result in regex.search_all(text):
			var resource_path := _trim_reference(match_result.get_string())
			if resource_path.is_empty() or _seen_refs.has(resource_path):
				continue
			_seen_refs[resource_path] = true
			_validate_required_path(resource_path, path)


func _validate_required_path(path: String, owner: String) -> void:
	if not path.begins_with("res://"):
		_add_error(owner, "path must use res:// prefix: %s" % path)
		return
	if path.begins_with("res://.godot/"):
		return
	if _is_file(path) or _is_dir(path) or ResourceLoader.exists(path):
		return
	_add_error(path, "missing path referenced by %s" % owner)


func _scan_files(root: String, extensions: Dictionary, out: Array[String]) -> void:
	var dir := DirAccess.open(root)
	if dir == null:
		if not _is_file(root):
			_add_error(root, "scan root missing")
		return
	dir.list_dir_begin()
	var name := dir.get_next()
	while name != "":
		if name.begins_with("."):
			name = dir.get_next()
			continue
		var full_path := root.path_join(name)
		if dir.current_is_dir():
			_scan_files(full_path, extensions, out)
		else:
			var extension := name.get_extension()
			if extensions.has(extension):
				out.append(full_path)
		name = dir.get_next()
	dir.list_dir_end()


func _clean_project_path(raw_path: String) -> String:
	var path := raw_path.strip_edges()
	if path.begins_with("*"):
		path = path.substr(1)
	return path


func _trim_reference(raw_path: String) -> String:
	var path := raw_path.strip_edges()
	while path.ends_with(".") or path.ends_with(";") or path.ends_with(":"):
		path = path.substr(0, path.length() - 1)
	return path


func _read_text(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_add_error(path, "text file failed to open")
		return ""
	return file.get_as_text()


func _is_file(path: String) -> bool:
	return FileAccess.file_exists(path)


func _is_dir(path: String) -> bool:
	return DirAccess.dir_exists_absolute(path)


func _add_error(path: String, message: String) -> void:
	_errors.append("::error::[%s] %s: %s. Next: %s" % [VALIDATOR, message, path, NEXT_COMMAND])
