extends SceneTree

const MAIN_SCENE := "res://scenes/world/store_world.tscn"
const THRESHOLDS_MS := {
	"main_scene_resource_load_ms": 5000,
	"main_scene_instantiate_ms": 5000,
	"main_scene_settle_5_frames_ms": 5000,
	"main_scene_60_frames_ms": 5000,
	"ui_panel_cycle_ms": 1500,
	"customer_pathing_100_ticks_ms": 1000,
	"save_codec_roundtrip_ms": 1000,
}

var _metrics := {}
var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var output := _arg_value(args, "--output", "res://../artifacts/performance/latest/alpha-performance-core.json")

	await _measure_main_scene()
	_measure_save_codec_roundtrip()
	_check_thresholds()
	_write_report(output)

	if _failures.is_empty():
		print("Alpha performance core passed: %s" % output)
		quit(0)
	else:
		for failure in _failures:
			push_error(failure)
		quit(1)


func _measure_main_scene() -> void:
	var load_start := Time.get_ticks_usec()
	var packed_scene := load(MAIN_SCENE) as PackedScene
	_metrics["main_scene_resource_load_ms"] = _elapsed_ms(load_start)
	if packed_scene == null:
		_failures.append("Could not load main scene.")
		return

	var instantiate_start := Time.get_ticks_usec()
	var scene := packed_scene.instantiate()
	root.add_child(scene)
	_metrics["main_scene_instantiate_ms"] = _elapsed_ms(instantiate_start)

	var settle_start := Time.get_ticks_usec()
	for _index in range(5):
		await process_frame
	_metrics["main_scene_settle_5_frames_ms"] = _elapsed_ms(settle_start)

	var frame_start := Time.get_ticks_usec()
	for _index in range(60):
		await process_frame
	_metrics["main_scene_60_frames_ms"] = _elapsed_ms(frame_start)

	await _measure_ui_panel_cycle(scene)
	_measure_customer_pathing(scene)

	scene.queue_free()
	await process_frame


func _measure_ui_panel_cycle(scene: Node) -> void:
	var player := scene.get_node_or_null("PlayerController")
	var session := scene.get_node_or_null("StoreSession")
	if player == null:
		_failures.append("Missing PlayerController for UI panel cycle measurement.")
		return

	var panel_start := Time.get_ticks_usec()
	if player.has_method("open_settings_panel"):
		player.open_settings_panel()
		await process_frame
		var settings_panel := player.get_node_or_null("SettingsPanel")
		if settings_panel != null and settings_panel.has_method("close"):
			settings_panel.close()
			await process_frame

	if player.has_method("open_pause_menu"):
		player.open_pause_menu()
		await process_frame
		var pause_menu := player.get_node_or_null("PauseMenuPanel")
		if pause_menu != null and pause_menu.has_method("resume_game"):
			pause_menu.resume_game()
			await process_frame

	if player.has_method("open_save_slot_panel"):
		player.open_save_slot_panel(session)
		await process_frame
		var save_slot_panel := player.get_node_or_null("SaveSlotPanel")
		if save_slot_panel != null and save_slot_panel.has_method("close"):
			save_slot_panel.close()
			await process_frame

	_metrics["ui_panel_cycle_ms"] = _elapsed_ms(panel_start)


func _measure_customer_pathing(scene: Node) -> void:
	var manager := scene.get_node_or_null("CustomerManager")
	var receiving_box := scene.get_node_or_null("ReceivingBox")
	var rack := scene.get_node_or_null("GameDisplayRack")
	if manager == null or receiving_box == null or rack == null:
		_failures.append("Missing customer pathing nodes for performance measurement.")
		return

	var item := receiving_box.get_node_or_null("PlaceholderUsedGame")
	var slot := rack.get_node_or_null("ShelfSlot001")
	if item != null and slot != null and slot.has_method("place_item"):
		slot.place_item(item)

	var path_start := Time.get_ticks_usec()
	for _index in range(100):
		if manager.has_method("process_customer_claims"):
			manager.process_customer_claims()
		if manager.has_method("get_customers"):
			for customer in manager.get_customers():
				customer._process(0.05)
	_metrics["customer_pathing_100_ticks_ms"] = _elapsed_ms(path_start)


func _measure_save_codec_roundtrip() -> void:
	var temp_root := Node3D.new()
	var ledger := TransactionLedger.new()
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	var inventory_root := Node3D.new()
	var item: Node = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	var codec: RefCounted = load("res://scripts/save/store_save_codec.gd").new()
	root.add_child(temp_root)
	temp_root.add_child(ledger)
	temp_root.add_child(session)
	temp_root.add_child(inventory_root)
	inventory_root.add_child(item)

	session.ledger_path = session.get_path_to(ledger)
	session.inventory_root_path = session.get_path_to(inventory_root)
	var transaction := ledger.record_sale("perf_customer_001", item)
	session.apply_sale(transaction)
	item.set("current_price_cents", 2199)
	item.set("location_id", "shelf_slot_001")

	var save_start := Time.get_ticks_usec()
	var data: Dictionary = codec.create_save_data(session)
	var json_text: String = codec.encode_to_json(data)
	var decoded: Dictionary = codec.decode_from_json(json_text)
	codec.restore_into_existing_scene(session, ledger, inventory_root, decoded)
	_metrics["save_codec_roundtrip_ms"] = _elapsed_ms(save_start)
	_metrics["save_codec_json_bytes"] = json_text.length()

	temp_root.queue_free()


func _check_thresholds() -> void:
	for key in THRESHOLDS_MS.keys():
		if not _metrics.has(key):
			_failures.append("Missing alpha performance metric: %s" % key)
			continue
		var value := int(_metrics[key])
		var threshold := int(THRESHOLDS_MS[key])
		if value > threshold:
			_failures.append("%s was %sms, above %sms" % [key, value, threshold])


func _write_report(output: String) -> void:
	var result := DirAccess.make_dir_recursive_absolute(output.get_base_dir())
	if result != OK:
		_failures.append("Could not create performance report directory: %s" % output.get_base_dir())
		return

	var file := FileAccess.open(output, FileAccess.WRITE)
	if file == null:
		_failures.append("Could not open performance report: %s" % output)
		return

	file.store_string(JSON.stringify({
		"metrics": _metrics,
		"thresholds_ms": THRESHOLDS_MS,
		"failures": _failures,
	}, "\t"))


func _arg_value(args: PackedStringArray, name: String, fallback: String) -> String:
	var index := args.find(name)
	if index == -1 or index + 1 >= args.size():
		return fallback
	return args[index + 1]


func _elapsed_ms(start_usec: int) -> int:
	return int(roundi((Time.get_ticks_usec() - start_usec) / 1000.0))
