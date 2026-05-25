extends GutTest

const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"

var _root: Node3D
var _completed_feedback: Array[String] = []
var _toast_feedback: Array[String] = []


func before_each() -> void:
	StoreSessionState.reset_new_run()
	InputFocus._reset_for_tests()
	ModalQueue._reset_for_tests()
	_completed_feedback.clear()
	_toast_feedback.clear()
	var scene: PackedScene = load(SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	_root = scene.instantiate() as Node3D
	add_child(_root)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame


func after_each() -> void:
	ModalQueue._reset_for_tests()
	InputFocus._reset_for_tests()
	if EventBus.objective_completed.is_connected(_on_objective_completed):
		EventBus.objective_completed.disconnect(_on_objective_completed)
	if EventBus.toast_requested.is_connected(_on_toast_requested):
		EventBus.toast_requested.disconnect(_on_toast_requested)
	if is_instance_valid(_root):
		_root.free()
	_root = null
	StoreSessionState.reset_new_run()


func test_new_game_enters_preopening_training_before_day_one() -> void:
	var controller: Node = _controller()
	assert_not_null(controller)
	if controller == null:
		return
	assert_false(StoreSessionState.preopening_complete)
	assert_eq(
		String(controller.current_stage()),
		"training_talk_manager",
		"New Game must start with the pre-opening manager beat, not real Day 1"
	)
	assert_eq(Array(_active_targets()), ["StoreSessionDayOneCustomer"])


func test_manager_prompt_and_objective_identify_checkout_manager() -> void:
	var controller: Node = _controller()
	assert_not_null(controller)
	if controller == null:
		return
	var customer: Interactable = _customer_interactable()
	assert_not_null(customer, "Manager beat must use the reachable customer proxy")
	if customer == null:
		return

	assert_eq(customer.display_name, "manager")
	assert_eq(customer.prompt_text, "Talk to")
	assert_eq(customer.action_verb, "Talk")
	assert_eq(Array(_active_targets()), ["StoreSessionDayOneCustomer"])

	var snapshot: Dictionary = controller.get_state_snapshot()
	assert_eq(str(snapshot.get("active_objective_id", "")), "talk_to_manager")
	assert_eq(str(snapshot.get("active_objective_label", "")), "Talk to the manager at checkout.")
	assert_eq(str(snapshot.get("active_objective_action", "")), "Talk to manager")
	assert_true(_proxy_part_visible("Badge"))
	assert_true(_proxy_part_visible("Clipboard"))


func test_training_walks_required_mechanics_then_opens_store() -> void:
	var controller: Node = _controller()
	if controller == null:
		return
	watch_signals(EventBus)
	controller.on_store_customer_interacted()
	await get_tree().process_frame
	assert_eq(String(controller.current_stage()), "training_check_register")
	assert_eq(Array(_active_targets()), ["StoreSessionDayEndTrigger"])

	controller.on_store_register_interacted()
	await get_tree().process_frame
	assert_eq(String(controller.current_stage()), "training_back_room_inventory")
	assert_eq(Array(_active_targets()), ["StoreSessionBackroomPickup"])

	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	assert_eq(String(controller.current_stage()), "training_stock_shelf")
	assert_true(StoreSessionState.carrying_stock)
	assert_eq(Array(_active_targets()), ["StoreSessionRestockShelf"])

	controller.on_store_restock_interacted()
	await get_tree().process_frame
	assert_signal_emitted_with_parameters(EventBus, "store_shelf_count_changed", [3])
	assert_signal_emitted_with_parameters(EventBus, "store_backroom_count_changed", [0])
	assert_eq(int(controller.get("_shelf_stock_count")), 3)
	assert_eq(_spawned_shelf_item_count(), 3)
	assert_true(StoreSessionState.preopening_complete)
	assert_eq(String(controller.current_stage()), "talk_to_customer")
	assert_false(StoreSessionState.carrying_stock)
	assert_eq(Array(_active_targets()), ["StoreSessionDayOneCustomer"])


func test_role_prompt_copy_changes_between_training_and_customer_stages() -> void:
	var controller: Node = _controller()
	if controller == null:
		return
	controller.on_store_customer_interacted()
	await get_tree().process_frame
	controller.on_store_register_interacted()
	await get_tree().process_frame
	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	controller.on_store_restock_interacted()
	await get_tree().process_frame

	var customer: Interactable = _customer_interactable()
	assert_not_null(customer)
	if customer == null:
		return
	assert_eq(String(controller.current_stage()), "talk_to_customer")
	assert_eq(customer.display_name, "customer")
	assert_eq(customer.prompt_text, "Talk to")
	assert_eq(customer.action_verb, "Talk")
	var customer_snapshot: Dictionary = controller.get_state_snapshot()
	assert_eq(str(customer_snapshot.get("active_objective_id", "")), "talk_to_customer")
	assert_eq(
		str(customer_snapshot.get("active_objective_label", "")),
		"Talk to the customer at the register."
	)
	assert_eq(str(customer_snapshot.get("active_objective_action", "")), "Talk to the customer")
	assert_false(_proxy_part_visible("Badge"))
	assert_false(_proxy_part_visible("Clipboard"))


func test_manager_completion_feedback_is_short() -> void:
	var controller: Node = _controller()
	if controller == null:
		return
	EventBus.objective_completed.connect(_on_objective_completed)
	EventBus.toast_requested.connect(_on_toast_requested)

	controller.on_store_customer_interacted()
	await get_tree().process_frame

	assert_true(_completed_feedback.has("Manager walkthrough complete."))
	assert_true(_toast_feedback.has("Manager walkthrough complete."))
	assert_false(
		_toast_feedback.has(
			"Morning. Before we unlock the doors, I need to show you how this place works."
		)
	)


func test_stocking_training_shelf_transitions_to_real_day_one_customer() -> void:
	var controller: Node = _controller()
	if controller == null:
		return
	watch_signals(EventBus)

	controller.on_store_customer_interacted()
	await get_tree().process_frame
	controller.on_store_register_interacted()
	await get_tree().process_frame
	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	controller.on_store_restock_interacted()
	await get_tree().process_frame

	assert_true(StoreSessionState.preopening_complete)
	assert_signal_emitted(
		EventBus,
		"run_state_changed",
		"Opening the store must notify HUD surfaces that preopening is complete"
	)
	assert_eq(String(controller.current_stage()), "talk_to_customer")
	assert_eq(Array(_active_targets()), ["StoreSessionDayOneCustomer"])
	assert_true(
		StoreSessionHUD.get_right_panel().get_header_text().begins_with("DAY 1 —"),
		"Right panel must switch from first-day training to Day 1 store-hours copy"
	)


func test_manager_proxy_uses_shaped_readable_silhouette() -> void:
	var proxy: Node = _root.get_node_or_null("StoreSessionDayOneCustomer/CustomerProxy")
	assert_not_null(proxy, "Training manager/customer proxy must exist")
	if proxy == null:
		return
	var body: MeshInstance3D = proxy.get_node_or_null("Body") as MeshInstance3D
	var head: MeshInstance3D = proxy.get_node_or_null("Head") as MeshInstance3D
	var arm_left: MeshInstance3D = proxy.get_node_or_null("ArmLeft") as MeshInstance3D
	var arm_right: MeshInstance3D = proxy.get_node_or_null("ArmRight") as MeshInstance3D

	assert_not_null(body, "Proxy must include Body for a readable silhouette")
	assert_not_null(head, "Proxy must include Head for a readable silhouette")
	assert_not_null(arm_left, "Proxy must include ArmLeft for a readable silhouette")
	assert_not_null(arm_right, "Proxy must include ArmRight for a readable silhouette")
	if body != null:
		assert_true(body.mesh is CapsuleMesh, "Body must use the shaped NPC visual path")
		assert_false(body.mesh is BoxMesh, "Body must not regress to the old box placeholder")
	if head != null:
		assert_true(head.mesh is SphereMesh, "Head must use a rounded NPC visual path")
	if arm_left != null:
		assert_true(arm_left.mesh is CapsuleMesh, "ArmLeft must use the shaped NPC visual path")
	if arm_right != null:
		assert_true(arm_right.mesh is CapsuleMesh, "ArmRight must use the shaped NPC visual path")


func test_manager_proxy_has_clerk_detail_props() -> void:
	var proxy: Node = _root.get_node_or_null("StoreSessionDayOneCustomer/CustomerProxy")
	assert_not_null(proxy, "Training manager/customer proxy must exist")
	if proxy == null:
		return
	for part_name: String in ["Badge", "Clipboard"]:
		var part: MeshInstance3D = proxy.get_node_or_null(part_name) as MeshInstance3D
		assert_not_null(part, "Proxy must include %s so it reads as a store clerk" % part_name)
		if part != null:
			assert_true(part.mesh is BoxMesh)


func _controller() -> Node:
	return get_tree().get_first_node_in_group("store_session_controller")


func _customer_interactable() -> Interactable:
	var controller: Node = _controller()
	var store_root: Node = _root
	if controller != null and controller.get_parent() != null:
		store_root = controller.get_parent()
	if store_root == null:
		return null
	return store_root.get_node_or_null("StoreSessionDayOneCustomer/Interactable") as Interactable


func _proxy_part_visible(part_name: String) -> bool:
	var part: Node3D = (
		_root.get_node_or_null("StoreSessionDayOneCustomer/CustomerProxy/%s" % part_name) as Node3D
	)
	return part != null and part.visible


func _on_objective_completed(_objective_id: StringName, label: String) -> void:
	_completed_feedback.append(label)


func _on_toast_requested(message: String, _category: StringName, _duration: float) -> void:
	_toast_feedback.append(message)


func _spawned_shelf_item_count() -> int:
	var shelf: Node = _root.get_node_or_null("StoreSessionRestockShelf")
	if shelf == null:
		return 0
	var count: int = 0
	for child: Node in shelf.get_children():
		if str(child.name).begins_with("StoreShelfItem"):
			count += 1
	return count


func _active_targets() -> PackedStringArray:
	var names := PackedStringArray()
	var controller: Node = _controller()
	var store_root: Node = _root
	if controller != null and controller.get_parent() != null:
		store_root = controller.get_parent()
	for node_name: String in [
		"StoreSessionDayOneCustomer",
		"StoreSessionBackroomPickup",
		"StoreSessionRestockShelf",
		"StoreSessionDayEndTrigger",
	]:
		var interactable: Interactable = (
			store_root.get_node_or_null("%s/Interactable" % node_name) as Interactable
		)
		if interactable != null and interactable.enabled:
			names.append(node_name)
	names.sort()
	return names
