extends GutTest

const StoreSessionTestHelpers := preload("res://tests/automation/store_session_test_helpers.gd")
const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"
const ROUTE_NODE_PATHS: Array[String] = [
	"StoreSessionDayOneCustomer",
	"StoreSessionDayEndTrigger",
	"StoreSessionBackroomPickup",
	"StoreSessionRestockShelf",
]
const ROUTE_INTERACTABLE_PATHS: Array[String] = [
	"StoreSessionDayOneCustomer/Interactable",
	"StoreSessionDayEndTrigger/Interactable",
	"StoreSessionBackroomPickup/Interactable",
	"StoreSessionRestockShelf/Interactable",
]
const EXIT_INTERACTABLE_PATH: String = "EntranceDoor/Interactable"
const PASSIVE_HINT_INTERACTABLE_PATHS: Array[String] = [
	"checkout_counter/RegisterStatusIndicator",
]

var _root: Node3D = null
var _saved_state: GameManager.State
var _saved_day: int


func before_each() -> void:
	_saved_state = GameManager.current_state
	_saved_day = GameManager.get_current_day()
	GameManager.current_state = GameManager.State.STORE_VIEW
	GameManager.set_current_day(1)
	StoreSessionState.reset_new_run()
	InputFocus._reset_for_tests()
	ModalQueue._reset_for_tests()
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
	if is_instance_valid(_root):
		_root.free()
	_root = null
	StoreSessionState.reset_new_run()
	GameManager.current_state = _saved_state
	GameManager.set_current_day(_saved_day)


func test_first_day_training_route_completes_through_reachable_interactables() -> void:
	var controller: StoreSessionController = _controller()
	if controller == null:
		return

	_assert_target_reachable("StoreSessionDayOneCustomer")
	_assert_only_route_target_enabled("StoreSessionDayOneCustomer/Interactable")
	await _interact("StoreSessionDayOneCustomer/Interactable")
	assert_eq(controller.current_stage(), StoreSessionController.STAGE_TRAINING_CHECK_REGISTER)

	_assert_target_reachable("StoreSessionDayEndTrigger")
	_assert_only_route_target_enabled("StoreSessionDayEndTrigger/Interactable")
	await _interact("StoreSessionDayEndTrigger/Interactable")
	assert_eq(controller.current_stage(), StoreSessionController.STAGE_TRAINING_BACK_ROOM)

	_assert_target_reachable("StoreSessionBackroomPickup")
	_assert_only_route_target_enabled("StoreSessionBackroomPickup/Interactable")
	await _interact("StoreSessionBackroomPickup/Interactable")
	assert_eq(controller.current_stage(), StoreSessionController.STAGE_TRAINING_STOCK_SHELF)
	assert_true(StoreSessionState.carrying_stock, "Stockroom pickup must set carrying state")

	_assert_target_reachable("StoreSessionRestockShelf")
	_assert_only_route_target_enabled("StoreSessionRestockShelf/Interactable")
	for index: int in range(StoreSessionController._BACKROOM_DELIVERY_QUANTITY):
		var shelf: Interactable = _interactable("StoreSessionRestockShelf/Interactable")
		assert_not_null(shelf, "Restock interactable must exist")
		if shelf == null:
			return
		assert_eq(
			shelf.get_prompt_label(),
			"Place item %d of %d on Starter Display"
			% [index + 1, StoreSessionController._BACKROOM_DELIVERY_QUANTITY]
		)
		await _interact("StoreSessionRestockShelf/Interactable")

	assert_eq(controller.current_stage(), StoreSessionController.STAGE_TALK_TO_CUSTOMER)
	assert_true(StoreSessionState.preopening_complete)
	assert_false(StoreSessionState.carrying_stock)
	assert_eq(
		int(controller.get("_shelf_stock_count")),
		StoreSessionController._BACKROOM_DELIVERY_QUANTITY
	)
	assert_eq(int(controller.get("_carried_stock_remaining")), 0)
	_assert_only_route_target_enabled("StoreSessionDayOneCustomer/Interactable")

	var exit_target: Interactable = _interactable(EXIT_INTERACTABLE_PATH)
	assert_not_null(exit_target, "Exit interactable must exist")
	if exit_target == null:
		return
	_assert_exit_reachable_from_player_bounds()
	GameManager.current_state = GameManager.State.GAMEPLAY
	InputHelper.lock_cursor()
	exit_target.interact()
	assert_eq(GameManager.current_state, GameManager.State.MALL_OVERVIEW)
	assert_false(InputHelper.is_cursor_locked(), "Exit interaction must release the cursor")


func test_stockroom_batch_edges_do_not_mutate_out_of_order() -> void:
	var controller: StoreSessionController = _controller()
	if controller == null:
		return
	watch_signals(EventBus)

	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	assert_false(StoreSessionState.carrying_stock, "Wrong-stage pickup must not start carrying")
	assert_eq(int(controller.get("_carried_stock_remaining")), 0)
	assert_signal_emitted(EventBus, "notification_requested")

	await _advance_to_training_backroom(controller)
	var before_pickup_notifications: int = get_signal_emit_count(EventBus, "notification_requested")
	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	StoreSessionTestHelpers.acknowledge_first_minute_detail(controller)
	await get_tree().process_frame
	assert_true(StoreSessionState.carrying_stock)
	assert_eq(
		int(controller.get("_carried_stock_remaining")),
		StoreSessionController._BACKROOM_DELIVERY_QUANTITY
	)
	assert_eq(
		int(controller.get("_current_delivery_quantity")),
		StoreSessionController._BACKROOM_DELIVERY_QUANTITY
	)

	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	assert_true(
		StoreSessionState.carrying_stock,
		"Duplicate pickup while carrying must preserve carry state"
	)
	assert_eq(
		int(controller.get("_carried_stock_remaining")),
		StoreSessionController._BACKROOM_DELIVERY_QUANTITY
	)
	assert_gt(
		get_signal_emit_count(EventBus, "notification_requested"),
		before_pickup_notifications,
		"Duplicate pickup should surface blocked-state copy without advancing"
	)

	for _index: int in range(StoreSessionController._BACKROOM_DELIVERY_QUANTITY):
		controller.on_store_restock_interacted(false)
		await get_tree().process_frame

	assert_false(StoreSessionState.carrying_stock, "Final placement must clear carrying state")
	assert_eq(int(controller.get("_carried_stock_remaining")), 0)
	assert_eq(int(controller.get("_unplaced_delivery_count")), 0)
	assert_eq(
		int(controller.get("_shelf_stock_count")),
		StoreSessionController._BACKROOM_DELIVERY_QUANTITY
	)

	var shelf_count: int = int(controller.get("_shelf_stock_count"))
	controller.on_store_restock_interacted(false)
	await get_tree().process_frame
	assert_eq(
		int(controller.get("_shelf_stock_count")),
		shelf_count,
		"Exhausted delivery must not add stock"
	)
	assert_false(StoreSessionState.carrying_stock)


func test_route_prompt_contracts_match_raycast_proximity_and_blocking_rules() -> void:
	var exit_target: Interactable = _interactable("EntranceDoor/Interactable")
	var manager: Interactable = _interactable("StoreSessionDayOneCustomer/Interactable")
	var register: Interactable = _interactable("StoreSessionDayEndTrigger/Interactable")
	var pickup: Interactable = _interactable("StoreSessionBackroomPickup/Interactable")
	var shelf: Interactable = _interactable("StoreSessionRestockShelf/Interactable")
	for target: Interactable in [exit_target, manager, register, pickup, shelf]:
		assert_not_null(target, "Route prompt target must exist")
	if exit_target == null or manager == null or register == null or pickup == null or shelf == null:
		return

	assert_eq(exit_target.proximity_radius, 0.0, "Mall exit must stay raycast-only")
	assert_gte(manager.proximity_radius, 3.0)
	assert_gte(register.proximity_radius, 3.0)
	assert_between(pickup.proximity_radius, 1.1, 1.5)
	assert_gte(shelf.proximity_radius, 3.0)
	assert_gt(pickup.proximity_facing_dot, manager.proximity_facing_dot)

	var ray := preload("res://game/scripts/player/interaction_ray.gd").new()
	add_child_autofree(ray)
	InputFocus.push_context(InputFocus.CTX_STORE_GAMEPLAY)
	assert_false(ray.call("_interaction_blocked"))
	EventBus.panel_opened.emit("inventory")
	assert_true(ray.call("_interaction_blocked"), "Open panels must block route interaction")
	EventBus.panel_closed.emit("inventory")
	InputFocus.push_context(InputFocus.CTX_MODAL)
	assert_true(ray.call("_interaction_blocked"), "Non-gameplay focus must block route interaction")
	InputFocus._reset_for_tests()


func test_readability_layout_does_not_add_out_of_scope_systems_or_panels() -> void:
	var forbidden_classes: Array = [
		CustomerSystem,
		CustomerNPC,
		NPCSpawnerSystem,
		EconomySystem,
		SaveManager,
		InventorySystem,
		InventoryPanel,
		SaveLoadPanel,
		BackRoomInventoryPanel,
		PricingPanel,
		TradeInPanel,
		OrderPanel,
		StaffPanel,
		CheckoutPanel,
	]
	for node: Node in _walk(_root):
		for forbidden_class: Variant in forbidden_classes:
			assert_false(
				is_instance_of(node, forbidden_class),
				"Store-session layout must not add out-of-scope runtime systems or panels: %s"
				% node.get_path()
			)

	var shell: Node = _root.get_node_or_null("ExpandableStoreShell")
	assert_not_null(shell, "Generated shell must exist")
	if shell == null:
		return
	for node: Node in _walk(shell):
		assert_false(node is Control, "Generated 3D shell must not introduce new UI controls")
		assert_false(
			node is Interactable,
			"Generated shell dressing must not add new gameplay prompt owners"
		)


func _controller() -> StoreSessionController:
	if _root == null:
		return null
	var controller: StoreSessionController = (
		_root.get_node_or_null("StoreSessionController") as StoreSessionController
	)
	assert_not_null(controller, "StoreSessionController must exist")
	return controller


func _interactable(path: String) -> Interactable:
	if _root == null:
		return null
	return _root.get_node_or_null(path) as Interactable


func _interact(path: String) -> void:
	var target: Interactable = _interactable(path)
	assert_not_null(target, "%s must exist" % path)
	if target == null:
		return
	assert_true(target.enabled, "%s must be enabled before interaction" % path)
	assert_true(target.can_interact(), "%s must be actionable before interaction" % path)
	target.interact()
	await get_tree().process_frame
	var controller: StoreSessionController = _controller()
	if controller != null:
		StoreSessionTestHelpers.acknowledge_first_minute_detail(controller)
		await get_tree().process_frame


func _advance_to_training_backroom(controller: StoreSessionController) -> void:
	controller.on_store_customer_interacted()
	await get_tree().process_frame
	StoreSessionTestHelpers.acknowledge_first_minute_detail(controller)
	await get_tree().process_frame
	controller.on_store_register_interacted()
	await get_tree().process_frame
	StoreSessionTestHelpers.acknowledge_first_minute_detail(controller)
	await get_tree().process_frame
	assert_eq(controller.current_stage(), StoreSessionController.STAGE_TRAINING_BACK_ROOM)


func _assert_only_route_target_enabled(active_path: String) -> void:
	for path: String in ROUTE_INTERACTABLE_PATHS:
		var target: Interactable = _interactable(path)
		assert_not_null(target, "%s must exist" % path)
		if target == null:
			continue
		assert_eq(target.enabled, path == active_path, "%s active-state mismatch" % path)
	var exit_target: Interactable = _interactable(EXIT_INTERACTABLE_PATH)
	assert_not_null(exit_target, "Exit interactable must exist")
	if exit_target != null:
		assert_true(exit_target.enabled, "Exit remains available without owning objective progress")
	var expected_actionable: Array[String] = [active_path, EXIT_INTERACTABLE_PATH]
	expected_actionable.sort()
	var actionable: Array[String] = _actionable_enabled_interactable_paths()
	actionable.sort()
	assert_eq(
		actionable,
		expected_actionable,
		"Only the current route target and bounded exit may accept player interaction"
	)
	for passive_path: String in PASSIVE_HINT_INTERACTABLE_PATHS:
		var passive: Interactable = _interactable(passive_path)
		assert_not_null(passive, "%s must exist as passive hint coverage" % passive_path)
		if passive != null:
			assert_true(passive.enabled, "%s may stay raycast-visible for hint copy" % passive_path)
			assert_false(passive.can_interact(), "%s must not accept E-presses" % passive_path)


func _actionable_enabled_interactable_paths() -> Array[String]:
	var paths: Array[String] = []
	for node: Node in _walk(_root):
		if not (node is Interactable):
			continue
		var interactable: Interactable = node as Interactable
		if interactable.enabled and interactable.can_interact():
			paths.append(str(_root.get_path_to(interactable)))
	return paths


func _assert_target_reachable(node_path: String) -> void:
	var target: Node3D = _root.get_node_or_null(node_path) as Node3D
	assert_not_null(target, "%s must exist" % node_path)
	if target == null:
		return
	var bounds: Dictionary = _player_bounds()
	assert_between(
		target.global_position.x,
		bounds["min"].x,
		bounds["max"].x,
		"%s reachable X" % node_path
	)
	assert_between(
		target.global_position.z,
		bounds["min"].z,
		bounds["max"].z,
		"%s reachable Z" % node_path
	)


func _assert_exit_reachable_from_player_bounds() -> void:
	var exit_target: Node3D = _root.get_node_or_null("EntranceDoor") as Node3D
	assert_not_null(exit_target, "EntranceDoor must exist")
	if exit_target == null:
		return
	var bounds: Dictionary = _player_bounds()
	var stand_point := Vector3(
		clampf(exit_target.global_position.x, bounds["min"].x, bounds["max"].x),
		exit_target.global_position.y,
		clampf(exit_target.global_position.z, bounds["min"].z, bounds["max"].z)
	)
	assert_lte(
		Vector2(stand_point.x, stand_point.z).distance_to(
			Vector2(exit_target.global_position.x, exit_target.global_position.z)
		),
		1.0,
		"Exit prompt must stay reachable from the playable front bound"
	)


func _player_bounds() -> Dictionary:
	var spawn: Marker3D = _root.get_node_or_null("PlayerEntrySpawn") as Marker3D
	assert_not_null(spawn, "PlayerEntrySpawn must exist")
	if spawn == null:
		return {"min": Vector3.ZERO, "max": Vector3.ZERO}
	return {
		"min": spawn.get_meta("bounds_min", Vector3.ZERO) as Vector3,
		"max": spawn.get_meta("bounds_max", Vector3.ZERO) as Vector3,
	}


func _walk(root: Node) -> Array[Node]:
	var nodes: Array[Node] = []
	if root == null:
		return nodes
	nodes.append(root)
	for child: Node in root.get_children():
		nodes.append_array(_walk(child))
	return nodes
