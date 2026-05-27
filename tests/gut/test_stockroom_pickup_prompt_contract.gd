extends GutTest

const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"

var _root: Node3D = null


func before_each() -> void:
	StoreSessionState.reset_new_run()
	StoreSessionState.preopening_complete = true
	var scene: PackedScene = load(SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	_root = scene.instantiate() as Node3D
	add_child(_root)
	await get_tree().process_frame
	await get_tree().process_frame


func after_each() -> void:
	if is_instance_valid(_root):
		_root.free()
	_root = null
	StoreSessionState.reset_new_run()


func test_pickup_gate_only_opens_at_backroom_stage_without_carry() -> void:
	var controller: Node = _controller()
	if controller == null:
		return
	_set_stage(controller, StoreSessionController.STAGE_BACK_ROOM_INVENTORY, {})
	StoreSessionState.carrying_stock = false
	assert_true(controller.can_interact_pickup(), "Back-room objective should allow pickup")

	_set_stage(controller, StoreSessionController.STAGE_TALK_TO_CUSTOMER, {})
	assert_false(controller.can_interact_pickup(), "Pickup must stay closed before its objective")

	_set_stage(controller, StoreSessionController.STAGE_BACK_ROOM_INVENTORY, {})
	StoreSessionState.carrying_stock = true
	assert_false(controller.can_interact_pickup(), "Pickup must close while stock is carried")

	StoreSessionState.carrying_stock = false
	_set_stage(
		controller,
		StoreSessionController.STAGE_BACK_ROOM_INVENTORY,
		{&"back_room_inventory": true}
	)
	assert_false(controller.can_interact_pickup(), "Completed pickup objective must not reopen")


func test_pickup_disabled_copy_routes_to_current_stage() -> void:
	var controller: Node = _controller()
	if controller == null:
		return
	_set_stage(controller, StoreSessionController.STAGE_TALK_TO_CUSTOMER, {})
	assert_eq(
		controller.pickup_disabled_reason(),
		"Talk to the customer first.",
		"Wrong-stage pickup copy should point back to the current objective"
	)

	_set_stage(controller, StoreSessionController.STAGE_STOCK_SHELF, {})
	StoreSessionState.carrying_stock = true
	assert_eq(
		controller.pickup_disabled_reason(),
		"Stock already in hand. Place it on the starter display table.",
		"Already-carrying copy should be passive and name the active destination"
	)

	StoreSessionState.carrying_stock = false
	_set_stage(
		controller,
		StoreSessionController.STAGE_BACK_ROOM_INVENTORY,
		{&"back_room_inventory": true}
	)
	assert_eq(
		controller.pickup_disabled_reason(),
		"Delivery already checked.",
		"Completed pickup copy should not invite a second pickup"
	)


func test_wrong_stage_pickup_attempt_emits_recovery_without_stock_effects() -> void:
	var controller: Node = _controller()
	if controller == null:
		return
	_set_stage(controller, StoreSessionController.STAGE_TALK_TO_CUSTOMER, {})
	StoreSessionState.carrying_stock = false
	watch_signals(EventBus)

	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame

	assert_false(StoreSessionState.carrying_stock, "Wrong-stage pickup must not set carry state")
	assert_signal_not_emitted(EventBus, "toast_requested")
	assert_signal_not_emitted(EventBus, "store_carry_changed")
	assert_signal_emitted(EventBus, "notification_requested")
	assert_eq(
		get_signal_parameters(EventBus, "notification_requested"),
		["Talk to the customer first."],
		"Wrong-stage pickup attempt should surface concise recovery copy"
	)


func test_duplicate_pickup_attempt_while_carrying_does_not_repeat_effects() -> void:
	var controller: Node = _controller()
	if controller == null:
		return
	_set_stage(controller, StoreSessionController.STAGE_BACK_ROOM_INVENTORY, {})
	watch_signals(EventBus)

	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	var toast_count: int = get_signal_emit_count(EventBus, "toast_requested")
	var carry_count: int = get_signal_emit_count(EventBus, "store_carry_changed")
	var backroom_count: int = get_signal_emit_count(EventBus, "store_backroom_count_changed")
	var completed_count: int = get_signal_emit_count(EventBus, "store_objective_completed")
	var carried_remaining: int = int(controller.get("_carried_stock_remaining"))

	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame

	assert_true(StoreSessionState.carrying_stock, "Duplicate pickup must preserve carry state")
	assert_eq(int(controller.get("_carried_stock_remaining")), carried_remaining)
	assert_eq(get_signal_emit_count(EventBus, "toast_requested"), toast_count)
	assert_eq(get_signal_emit_count(EventBus, "store_carry_changed"), carry_count)
	assert_eq(get_signal_emit_count(EventBus, "store_backroom_count_changed"), backroom_count)
	assert_eq(get_signal_emit_count(EventBus, "store_objective_completed"), completed_count)


func test_completed_pickup_attempt_does_not_start_carry_or_toast() -> void:
	var controller: Node = _controller()
	if controller == null:
		return
	_set_stage(
		controller,
		StoreSessionController.STAGE_BACK_ROOM_INVENTORY,
		{&"back_room_inventory": true}
	)
	StoreSessionState.carrying_stock = false
	watch_signals(EventBus)

	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame

	assert_false(StoreSessionState.carrying_stock, "Completed pickup must not restart carry")
	assert_signal_not_emitted(EventBus, "toast_requested")
	assert_signal_not_emitted(EventBus, "store_carry_changed")
	assert_signal_emitted(EventBus, "notification_requested")
	assert_eq(
		get_signal_parameters(EventBus, "notification_requested"),
		["Delivery already checked."]
	)


func test_pickup_interactable_range_and_facing_stay_local_to_stock_closet() -> void:
	var pickup: StockroomPickupInteractable = (
		_root.get_node_or_null("StoreSessionBackroomPickup/Interactable")
		as StockroomPickupInteractable
	)
	assert_not_null(pickup, "Stock pickup interactable must keep its adapter script")
	if pickup == null:
		return
	assert_between(
		pickup.proximity_radius,
		1.1,
		1.5,
		"Pickup proximity should support nearby use without reaching the sales floor"
	)
	assert_gte(
		pickup.proximity_facing_dot,
		0.5,
		"Pickup proximity should require a deliberate facing angle"
	)


func _controller() -> Node:
	if _root == null:
		return null
	var controller: Node = _root.get_node_or_null("StoreSessionController")
	assert_not_null(controller, "StoreSessionController must exist")
	return controller


func _set_stage(controller: Node, stage: StringName, completed: Dictionary) -> void:
	controller.set("_objectives", controller.get("_day_one_objectives").duplicate(true))
	controller.set("_completed_objectives", completed.duplicate(true))
	controller.set("_stage", stage)
