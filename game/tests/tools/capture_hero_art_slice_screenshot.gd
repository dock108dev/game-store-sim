extends SceneTree

const DEFAULT_WIDTH := 1600
const DEFAULT_HEIGHT := 900
const HERO_SCENE := "res://scenes/world/art_benchmark/hero_art_slice.tscn"


func _init() -> void:
	call_deferred("_capture")


func _arg_value(args: PackedStringArray, name: String, fallback: String) -> String:
	var index := args.find(name)
	if index == -1 or index + 1 >= args.size():
		return fallback
	return args[index + 1]


func _capture() -> void:
	var args := OS.get_cmdline_user_args()
	var output := _arg_value(args, "--output", "res://../artifacts/validation/latest/screenshots/hero_art_slice.png")
	var width := _arg_value(args, "--width", str(DEFAULT_WIDTH)).to_int()
	var height := _arg_value(args, "--height", str(DEFAULT_HEIGHT)).to_int()

	DisplayServer.window_set_size(Vector2i(width, height))
	root.size = Vector2i(width, height)

	var scene: Node = load(HERO_SCENE).instantiate()
	root.add_child(scene)

	await process_frame
	await process_frame
	await process_frame

	var viewport_texture := root.get_texture()
	if viewport_texture == null:
		push_error("Could not capture hero art slice: viewport texture is unavailable. Run without --headless so Godot creates a render viewport.")
		quit(1)
		return

	var image := viewport_texture.get_image()
	if image == null:
		push_error("Could not capture hero art slice: viewport image is unavailable. Run without --headless so Godot creates a render viewport.")
		quit(1)
		return
	image.resize(width, height, Image.INTERPOLATE_LANCZOS)

	var dir_result := DirAccess.make_dir_recursive_absolute(output.get_base_dir())
	if dir_result != OK:
		push_error("Could not create screenshot output directory: %s" % output.get_base_dir())
		quit(1)
		return

	var save_result := image.save_png(output)
	if save_result != OK:
		push_error("Could not save screenshot to %s" % output)
		quit(1)
		return

	quit(0)
