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
		"carry_stack":
			_prepare_carry_stack(scene)
		"receiving_area":
			_set_camera(scene, Vector3(-4.2, 1.8, 2.65), Vector3(-4.45, 0.55, 3.9))
		"supplier_message":
			_hide_node(scene, "PlayerController")
			_set_camera(scene, Vector3(-3.0, 0.95, 2.85), Vector3(-3.15, 0.34, 3.45))
		"suspicious_customer":
			_hide_node(scene, "PlayerController")
			_set_camera(scene, Vector3(-2.35, 1.45, -4.45), Vector3(-0.82, 0.82, -3.45))
		"register_counter":
			_set_camera(scene, Vector3(0.6, 1.7, -3.6), Vector3(2.2, 1.05, -2.4))
		"customer_queue":
			_prepare_customer_queue(scene)
			_hide_node(scene, "PlayerController")
			_set_camera(scene, Vector3(0.35, 2.05, -5.15), Vector3(-0.2, 0.9, -3.55))
		"trade_in_offer":
			_prepare_trade_in_offer(scene)
			_set_camera(scene, Vector3(-0.15, 1.65, -4.55), Vector3(0.7, 0.95, -3.15))
		"preorder_deposit":
			_prepare_preorder_deposit(scene)
			_set_camera(scene, Vector3(0.6, 1.7, -3.6), Vector3(2.2, 1.05, -2.4))
		"service_request":
			_prepare_service_request(scene)
			_set_camera(scene, Vector3(0.6, 1.7, -3.6), Vector3(2.2, 1.05, -2.4))
		"backroom_summary":
			_prepare_backroom_summary(scene)
			_set_camera(scene, Vector3(4.1, 1.55, 3.15), Vector3(4.65, 0.85, 4.35))
		"release_calendar":
			_prepare_release_calendar(scene)
			_set_camera(scene, Vector3(4.1, 1.55, 3.15), Vector3(4.65, 0.85, 4.35))
		"release_allocation":
			_prepare_release_allocation(scene)
			_set_camera(scene, Vector3(4.1, 1.55, 3.15), Vector3(4.65, 0.85, 4.35))
		"launch_day":
			_prepare_launch_day(scene)
			_set_camera(scene, Vector3(4.1, 1.55, 3.15), Vector3(4.65, 0.85, 4.35))
		"supplier_delivery":
			_prepare_supplier_delivery(scene)
			_set_camera(scene, Vector3(-3.0, 1.25, 2.65), Vector3(-3.35, 0.34, 3.45))
		"storefront_entry":
			_hide_node(scene, "CustomerManager")
			_hide_node(scene, "TradeInCustomer")
			_hide_node(scene, "PreorderCustomer")
			_hide_node(scene, "ServiceCustomer")
			_hide_node(scene, "ReturnCustomer")
			_hide_node(scene, "SuspiciousCustomer")
			_hide_node(scene, "PlayerController")
			_set_camera(scene, Vector3(-2.65, 1.48, -11.65), Vector3(0.0, 1.45, -5.86))
		"stocked_aisle":
			_prepare_customer_queue(scene)
			_hide_node(scene, "PlayerController")
			_set_camera(scene, Vector3(-5.15, 1.72, -0.25), Vector3(-3.35, 0.95, 4.65))
		"catalog_design_cues":
			_hide_node(scene, "PlayerController")
			_hide_node(scene, "BackroomComputer")
			_hide_node(scene, "BackroomManagementBoard")
			_hide_node(scene, "ManagementBoardLabelPanel")
			_hide_node(scene, "ManagementDeskPad")
			_hide_node(scene, "ManagementKeyboard")
			_hide_node(scene, "ManagementTaskCard")
			_hide_node(scene, "OfficeFileBoxA")
			_hide_node(scene, "OfficeFileBoxB")
			_hide_node(scene, "OfficeSupplierNote")
			_hide_node(scene, "OfficeBillStack")
			_set_camera(scene, Vector3(3.55, 1.15, 5.55), Vector3(4.55, 0.98, 3.95))
		"upgrade_preview":
			_hide_node(scene, "PlayerController")
			_hide_node(scene, "AccessoryPegWall")
			_hide_node(scene, "ControllerDisplayStand")
			_hide_node(scene, "RightWallControllerPosterPanel")
			_prepare_fixture_ghost(scene)
			_set_camera(scene, Vector3(6.8, 1.12, 2.55), Vector3(5.95, 1.05, 1.18))
		"fixture_ghost":
			_prepare_fixture_ghost(scene)
			_set_camera(scene, Vector3(-2.55, 1.65, 2.75), Vector3(-0.8, 0.75, 2.15))
		"fixture_invalid_ghost":
			_prepare_fixture_invalid_ghost(scene)
			_set_camera(scene, Vector3(4.6, 1.65, 2.75), Vector3(6.25, 0.75, 2.15))
		"fixture_rotated_ghost":
			_prepare_fixture_rotated_ghost(scene)
			_set_camera(scene, Vector3(-2.55, 1.65, 2.75), Vector3(-0.55, 0.75, 2.4))
		"fixture_placed":
			_prepare_fixture_placed(scene)
			_set_camera(scene, Vector3(-2.8, 1.55, 0.75), Vector3(-0.8, 0.82, 2.15))
		_:
			_set_camera(scene, Vector3(-2.65, 1.62, -11.25), Vector3(0.0, 1.45, -5.86))


func _prepare_customer_queue(scene: Node) -> void:
	var manager := scene.get_node_or_null("CustomerManager")
	if manager == null:
		return

	_stock_receiving_item(scene, "PlaceholderUsedGame", "GameDisplayRack/ShelfSlot001")
	_stock_receiving_item(scene, "PlaceholderUsedGame002", "GameDisplayRack/ShelfSlot002")
	if manager.has_method("process_customer_claims"):
		manager.process_customer_claims()
	_advance_managed_customers(manager, 5.0)


func _prepare_carry_stack(scene: Node) -> void:
	_hide_node(scene, "CustomerManager")
	_hide_node(scene, "TradeInCustomer")
	_hide_node(scene, "PreorderCustomer")
	_hide_node(scene, "ServiceCustomer")
	_hide_node(scene, "SuspiciousCustomer")

	var player := scene.get_node_or_null("PlayerController")
	if player == null or not player.has_method("pick_up_item"):
		return

	for item_name in ["PlaceholderUsedGame", "PlaceholderUsedGame002", "PlaceholderUsedGame003"]:
		var item := scene.get_node_or_null("ReceivingBox/%s" % item_name) as Node3D
		if item != null:
			player.pick_up_item(item)

	_show_overlay_message(scene, "Carrying 3 used games")


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


func _prepare_release_calendar(scene: Node) -> void:
	var session := scene.get_node_or_null("StoreSession")
	var player := scene.get_node_or_null("PlayerController")
	if session == null or player == null:
		return

	_open_day_summary_tab(player, session, "releases")


func _prepare_release_allocation(scene: Node) -> void:
	var session := scene.get_node_or_null("StoreSession")
	var player := scene.get_node_or_null("PlayerController")
	if session == null or player == null:
		return

	if session.has_method("commit_release_allocation"):
		session.commit_release_allocation("release_neon_skyline", 1)
	_open_day_summary_tab(player, session, "releases")


func _prepare_launch_day(scene: Node) -> void:
	var ledger := scene.get_node_or_null("TransactionLedger")
	var session := scene.get_node_or_null("StoreSession")
	var player := scene.get_node_or_null("PlayerController")
	if ledger == null or session == null or player == null:
		return

	var release := load("res://data/releases/neon_skyline_launch.tres")
	var preorder: Dictionary = ledger.record_preorder_deposit("preorder_customer_001", release, 500)
	session.apply_preorder_deposit(preorder)
	session.commit_release_allocation("release_neon_skyline", 4)
	session.end_day()
	session.start_next_day()
	session.end_day()
	session.start_next_day()
	_open_day_summary_tab(player, session, "reports")
	if session.has_method("get_launch_summary_text"):
		_show_overlay_message(scene, session.get_launch_summary_text())


func _prepare_trade_in_offer(scene: Node) -> void:
	var player := scene.get_node_or_null("PlayerController")
	var register := scene.get_node_or_null("RegisterWorkstation")
	var customer := scene.get_node_or_null("TradeInCustomer")
	if player == null or register == null or customer == null:
		return

	if player.has_method("open_trade_in_offer"):
		player.open_trade_in_offer(register, customer)


func _prepare_preorder_deposit(scene: Node) -> void:
	_hide_node(scene, "PlayerController")
	var register := scene.get_node_or_null("RegisterWorkstation")
	var trade_customer := scene.get_node_or_null("TradeInCustomer")
	if register == null:
		return

	if trade_customer != null and trade_customer.has_method("decline_trade_in"):
		trade_customer.decline_trade_in()
	var message := str(register.interact())
	_show_overlay_message(scene, message)


func _prepare_service_request(scene: Node) -> void:
	_hide_node(scene, "PlayerController")
	_hide_node(scene, "CustomerManager")
	_hide_node(scene, "SuspiciousCustomer")
	var register := scene.get_node_or_null("RegisterWorkstation")
	var trade_customer := scene.get_node_or_null("TradeInCustomer")
	var preorder_customer := scene.get_node_or_null("PreorderCustomer")
	if register == null:
		return

	if trade_customer != null and trade_customer.has_method("decline_trade_in"):
		trade_customer.decline_trade_in()
	if preorder_customer != null and preorder_customer.has_method("complete_preorder"):
		preorder_customer.complete_preorder()

	var message := str(register.interact())
	_show_overlay_message(scene, message)


func _prepare_supplier_delivery(scene: Node) -> void:
	_hide_node(scene, "PlayerController")
	_hide_node(scene, "CustomerManager")
	_hide_node(scene, "TradeInCustomer")
	_hide_node(scene, "SuspiciousCustomer")
	var session := scene.get_node_or_null("StoreSession")
	if session == null:
		return
	if not session.has_method("order_supplier_lot") or not session.has_method("start_next_day"):
		return

	session.order_supplier_lot("supplier_lot_used_games_001")
	session.end_day()
	session.start_next_day()


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


func _prepare_fixture_placed(scene: Node) -> void:
	_prepare_fixture_ghost(scene)
	var session := scene.get_node_or_null("StoreSession")
	if session == null or not session.has_method("place_pending_fixture"):
		return

	session.place_pending_fixture()


func _open_day_summary_tab(player: Node, session: Node, tab_id: String) -> void:
	if not player.has_method("open_day_summary"):
		return

	player.open_day_summary(session)
	var panel: Node = player.get("day_summary_panel") as Node
	if panel == null:
		panel = player.get_node_or_null("DaySummaryPanel")
	if panel != null and panel.has_method("set_active_tab"):
		panel.set_active_tab(tab_id)
		panel.call_deferred("set_active_tab", tab_id)


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


func _hide_node(scene: Node, node_path: NodePath) -> void:
	var node := scene.get_node_or_null(node_path) as Node3D
	if node != null:
		node.visible = false


func _show_overlay_message(scene: Node, text: String) -> void:
	var layer := CanvasLayer.new()
	scene.add_child(layer)

	var label := Label.new()
	layer.add_child(label)
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color.WHITE)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.07, 0.07, 0.78)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	label.add_theme_stylebox_override("normal", style)

	label.anchor_left = 0.28
	label.anchor_right = 0.72
	label.anchor_top = 0.88
	label.anchor_bottom = 0.94
	label.offset_left = 0.0
	label.offset_right = 0.0
	label.offset_top = 0.0
	label.offset_bottom = 0.0


func _set_camera(scene: Node, position: Vector3, target: Vector3) -> void:
	var active_camera := Camera3D.new()
	scene.add_child(active_camera)
	active_camera.global_position = position
	active_camera.look_at(target, Vector3.UP)
	active_camera.current = true
