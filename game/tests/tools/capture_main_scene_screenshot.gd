extends SceneTree

const DEFAULT_WIDTH := 1280
const DEFAULT_HEIGHT := 720
const MAIN_SCENE := "res://scenes/world/graybox_store.tscn"


func _init() -> void:
	call_deferred("_capture")


func _arg_value(args: PackedStringArray, name: String, fallback: String) -> String:
	var index := args.find(name)
	if index == -1 or index + 1 >= args.size():
		return fallback
	return args[index + 1]


func _capture() -> void:
	var args := OS.get_cmdline_user_args()
	var output := _arg_value(args, "--output", "res://../artifacts/validation/latest/screenshots/main_scene.png")
	var width := _arg_value(args, "--width", str(DEFAULT_WIDTH)).to_int()
	var height := _arg_value(args, "--height", str(DEFAULT_HEIGHT)).to_int()
	var scenario := _arg_value(args, "--scenario", "main_scene")

	DisplayServer.window_set_size(Vector2i(width, height))
	root.size = Vector2i(width, height)

	var scene: Node = load(MAIN_SCENE).instantiate()
	root.add_child(scene)

	await process_frame
	await process_frame
	await process_frame
	_prepare_scenario(scene, scenario)
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


func _prepare_scenario(scene: Node, scenario: String) -> void:
	match scenario:
		"receiving_area":
			_set_camera(scene, Vector3(-4.2, 1.8, 2.65), Vector3(-4.45, 0.55, 3.9))
		"register_counter":
			_set_camera(scene, Vector3(0.6, 1.7, -3.6), Vector3(2.2, 1.05, -2.4))
		"customer_queue":
			_prepare_customer_queue(scene)
			_set_camera(scene, Vector3(0.0, 1.7, -4.05), Vector3(1.0, 0.9, -3.3))
		"trade_in_offer":
			_prepare_trade_in_offer(scene)
			_set_camera(scene, Vector3(0.6, 1.7, -3.6), Vector3(2.2, 1.05, -2.4))
		"backroom_summary":
			_prepare_backroom_summary(scene)
			_set_camera(scene, Vector3(4.1, 1.55, 3.15), Vector3(4.65, 0.85, 4.35))
		"fixture_ghost":
			_prepare_fixture_ghost(scene)
			_set_camera(scene, Vector3(-2.55, 1.65, 2.75), Vector3(-0.8, 0.75, 2.15))
		"fixture_invalid_ghost":
			_prepare_fixture_invalid_ghost(scene)
			_set_camera(scene, Vector3(4.6, 1.65, 2.75), Vector3(6.25, 0.75, 2.15))
		"fixture_rotated_ghost":
			_prepare_fixture_rotated_ghost(scene)
			_set_camera(scene, Vector3(-2.55, 1.65, 2.75), Vector3(-0.55, 0.75, 2.4))
		_:
			_set_camera(scene, Vector3(0.0, 2.0, -4.7), Vector3(0.0, 1.0, 1.5))


func _prepare_customer_queue(scene: Node) -> void:
	var manager := scene.get_node_or_null("CustomerManager")
	if manager == null:
		return

	_stock_receiving_item(scene, "PlaceholderUsedGame", "GameDisplayRack/ShelfSlot001")
	_stock_receiving_item(scene, "PlaceholderUsedGame002", "GameDisplayRack/ShelfSlot002")
	if manager.has_method("process_customer_claims"):
		manager.process_customer_claims()
	_advance_managed_customers(manager, 5.0)


func _prepare_backroom_summary(scene: Node) -> void:
	var ledger := scene.get_node_or_null("TransactionLedger")
	var session := scene.get_node_or_null("StoreSession")
	var player := scene.get_node_or_null("PlayerController")
	var item := scene.get_node_or_null("ReceivingBox/PlaceholderUsedGame")
	if ledger == null or session == null or player == null or item == null:
		return

	var transaction: Dictionary = ledger.record_sale("customer_001", item)
	session.apply_sale(transaction)
	if player.has_method("open_day_summary"):
		player.open_day_summary(session)


func _prepare_trade_in_offer(scene: Node) -> void:
	var player := scene.get_node_or_null("PlayerController")
	var register := scene.get_node_or_null("RegisterWorkstation")
	var customer := scene.get_node_or_null("TradeInCustomer")
	if player == null or register == null or customer == null:
		return

	if player.has_method("open_trade_in_offer"):
		player.open_trade_in_offer(register, customer)


func _prepare_fixture_ghost(scene: Node) -> void:
	var session := scene.get_node_or_null("StoreSession")
	if session == null or not session.has_method("order_fixture"):
		return

	session.order_fixture("fixture_game_display_rack")


func _prepare_fixture_invalid_ghost(scene: Node) -> void:
	_prepare_fixture_ghost(scene)
	var manager := scene.get_node_or_null("FixturePlacementManager")
	if manager == null or not manager.has_method("set_ghost_position"):
		return

	manager.set_ghost_position(Vector3(6.25, 0.04, 2.15))


func _prepare_fixture_rotated_ghost(scene: Node) -> void:
	_prepare_fixture_ghost(scene)
	var manager := scene.get_node_or_null("FixturePlacementManager")
	if manager == null:
		return

	if manager.has_method("rotate_ghost"):
		manager.rotate_ghost()
	if manager.has_method("move_ghost_by_grid"):
		manager.move_ghost_by_grid(1, 1)


func _stock_receiving_item(scene: Node, item_name: String, slot_path: String) -> void:
	var item := scene.get_node_or_null("ReceivingBox/%s" % item_name) as Node3D
	var slot := scene.get_node_or_null(slot_path)
	if item == null or slot == null or not slot.has_method("place_item"):
		return

	slot.place_item(item)


func _advance_managed_customers(manager: Node, seconds: float) -> void:
	if not manager.has_method("get_customers"):
		return

	var step := 0.1
	var steps := int(ceil(seconds / step))
	for _index in range(steps):
		for customer in manager.get_customers():
			customer._process(step)


func _set_camera(scene: Node, position: Vector3, target: Vector3) -> void:
	var active_camera := Camera3D.new()
	scene.add_child(active_camera)
	active_camera.global_position = position
	active_camera.look_at(target, Vector3.UP)
	active_camera.current = true
