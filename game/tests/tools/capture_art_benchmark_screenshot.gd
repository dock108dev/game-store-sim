extends SceneTree

const DEFAULT_WIDTH := 1280
const DEFAULT_HEIGHT := 720
const ART_BENCHMARK_SCENE := "res://scenes/world/art_benchmark/game_shop_art_benchmark.tscn"


func _init() -> void:
	call_deferred("_capture")


func _arg_value(args: PackedStringArray, name: String, fallback: String) -> String:
	var index := args.find(name)
	if index == -1 or index + 1 >= args.size():
		return fallback
	return args[index + 1]


func _capture() -> void:
	var args := OS.get_cmdline_user_args()
	var output := _arg_value(args, "--output", "res://../artifacts/validation/latest/screenshots/art_benchmark_storefront.png")
	var width := _arg_value(args, "--width", str(DEFAULT_WIDTH)).to_int()
	var height := _arg_value(args, "--height", str(DEFAULT_HEIGHT)).to_int()
	var view := _arg_value(args, "--view", "storefront")

	DisplayServer.window_set_size(Vector2i(width, height))
	root.size = Vector2i(width, height)

	var scene: Node = load(ART_BENCHMARK_SCENE).instantiate()
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

	var camera_name := "StorefrontReviewCamera"
	var camera_position := Vector3(-2.85, 1.46, -7.25)
	var camera_target := Vector3(0.0, 1.45, -1.72)
	match view:
		"register":
			camera_name = "RegisterReviewCamera"
			camera_position = Vector3(-2.35, 1.45, -0.82)
			camera_target = Vector3(1.45, 1.05, 0.72)
		"threshold":
			camera_name = "ThresholdReviewCamera"
			camera_position = Vector3(0.65, 1.36, -3.55)
			camera_target = Vector3(0.0, 1.22, -1.55)

	var camera := scene.get_node_or_null("BenchmarkCameras/%s" % camera_name) as Camera3D
	if camera != null:
		camera.global_position = camera_position
		camera.look_at(camera_target, Vector3.UP)
		camera.current = true


func _collect_cameras(node: Node) -> Array[Camera3D]:
	var cameras: Array[Camera3D] = []
	if node is Camera3D:
		cameras.append(node as Camera3D)
	for child in node.get_children():
		cameras.append_array(_collect_cameras(child))
	return cameras
