extends SceneTree

const DEFAULT_WIDTH := 1280
const DEFAULT_HEIGHT := 720
const PACKET_09_SCENE := "res://scenes/world/art_benchmark/packet_09_inside_out_art_spike.tscn"


func _init() -> void:
	call_deferred("_capture")


func _arg_value(args: PackedStringArray, name: String, fallback: String) -> String:
	var index := args.find(name)
	if index == -1 or index + 1 >= args.size():
		return fallback
	return args[index + 1]


func _capture() -> void:
	var args := OS.get_cmdline_user_args()
	var output := _arg_value(args, "--output", "res://../artifacts/validation/latest/screenshots/packet_09_inside_out_art_spike.png")
	var width := _arg_value(args, "--width", str(DEFAULT_WIDTH)).to_int()
	var height := _arg_value(args, "--height", str(DEFAULT_HEIGHT)).to_int()
	var view := _arg_value(args, "--view", "inside_out")

	DisplayServer.window_set_size(Vector2i(width, height))
	root.size = Vector2i(width, height)

	var scene: Node = load(PACKET_09_SCENE).instantiate()
	root.add_child(scene)

	await process_frame
	await process_frame
	_select_view(scene, view)
	await process_frame
	await process_frame

	var image := root.get_texture().get_image()
	image.resize(width, height, Image.INTERPOLATE_NEAREST)

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


func _select_view(scene: Node, view: String) -> void:
	for camera in _collect_cameras(scene):
		camera.current = false

	var camera_name := "InsideOutHeroCamera"
	match view:
		"starter_setup":
			camera_name = "ShelfDensityCamera"
		"shelf_density":
			camera_name = "ShelfDensityCamera"
		"storefront_frame":
			camera_name = "StorefrontFrameCamera"

	var camera := scene.get_node_or_null("Packet09ArtRoot/BenchmarkCameras/%s" % camera_name) as Camera3D
	if camera != null:
		camera.current = true


func _collect_cameras(node: Node) -> Array[Camera3D]:
	var cameras: Array[Camera3D] = []
	if node is Camera3D:
		cameras.append(node as Camera3D)
	for child in node.get_children():
		cameras.append_array(_collect_cameras(child))
	return cameras
