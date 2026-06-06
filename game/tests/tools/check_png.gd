extends SceneTree

const DEFAULT_MIN_UNIQUE_COLORS := 8


func _init() -> void:
	call_deferred("_check")


func _arg_value(args: PackedStringArray, name: String, fallback: String) -> String:
	var index := args.find(name)
	if index == -1 or index + 1 >= args.size():
		return fallback
	return args[index + 1]


func _fail(message: String) -> void:
	push_error(message)
	quit(1)


func _check() -> void:
	var args := OS.get_cmdline_user_args()
	var image_path := _arg_value(args, "--image", "")
	var expected_width := _arg_value(args, "--width", "1280").to_int()
	var expected_height := _arg_value(args, "--height", "720").to_int()
	var min_unique_colors := _arg_value(args, "--min-unique-colors", str(DEFAULT_MIN_UNIQUE_COLORS)).to_int()

	if image_path.is_empty():
		_fail("Missing --image path")
		return
	if not FileAccess.file_exists(image_path):
		_fail("Screenshot does not exist: %s" % image_path)
		return

	var image := Image.load_from_file(image_path)
	if image == null:
		_fail("Could not load screenshot: %s" % image_path)
		return
	if image.get_width() != expected_width or image.get_height() != expected_height:
		_fail("Screenshot dimensions were %sx%s, expected %sx%s" % [
			image.get_width(),
			image.get_height(),
			expected_width,
			expected_height,
		])
		return

	var colors := {}
	var step_x: int = maxi(1, int(expected_width / 64))
	var step_y: int = maxi(1, int(expected_height / 36))
	for y in range(0, expected_height, step_y):
		for x in range(0, expected_width, step_x):
			colors[image.get_pixel(x, y).to_rgba32()] = true
			if colors.size() >= min_unique_colors:
				print("Screenshot check passed: %s (%sx%s, %s+ sampled colors)" % [
					image_path,
					expected_width,
					expected_height,
					min_unique_colors,
				])
				quit(0)
				return

	_fail("Screenshot appears blank or too low variance: %s sampled colors" % colors.size())
