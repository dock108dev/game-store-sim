## Seeds user://gut_temp_directory/gut_editor_config.json when absent.
##
## GutBottomPanel._ready() loads this path during headless imports. Creating it
## before a run prevents the editor plugin from emitting a CI-gated error.
extends SceneTree


func _init() -> void:
	var dir_path := "user://gut_temp_directory"
	var config_path := dir_path + "/gut_editor_config.json"
	DirAccess.make_dir_recursive_absolute(dir_path)
	if not FileAccess.file_exists(config_path):
		var file := FileAccess.open(config_path, FileAccess.WRITE)
		if file:
			file.store_string("{}")
	quit(0)
