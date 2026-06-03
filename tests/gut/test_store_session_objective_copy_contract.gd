extends GutTest

const StoreSessionTestHelpers := preload("res://tests/automation/store_session_test_helpers.gd")
const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"
const MANAGER_COMPLETE_MESSAGE: String = (
	"Manager walkthrough complete. Register access unlocked."
)
const REGISTER_COMPLETE_MESSAGE: String = (
	"Register ready. Customers can be handled from the checkout lane."
)
const BACKROOM_COMPLETE_MESSAGE: String = (
	"Back room inventory checked. Pick up the starter stock box."
)
const DISPLAY_COMPLETE_MESSAGE: String = (
	"Starter display stocked. Store is ready for the first customer."
)

var _root: Node3D = null
var _saved_state: GameManager.State
var _saved_show_rail: bool


func before_each() -> void:
	_saved_state = GameManager.current_state
	_saved_show_rail = Settings.show_objective_rail
	GameManager.current_state = GameManager.State.STORE_VIEW
	Settings.show_objective_rail = true
	StoreSessionState.reset_new_run()
	InputFocus._reset_for_tests()
	ModalQueue._reset_for_tests()
	EventBus.fp_mode_changed.emit(false)
	EventBus.interactable_unfocused.emit()
	var scene: PackedScene = load(SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	_root = scene.instantiate() as Node3D
	add_child(_root)
	for _idx: int in range(3):
		await get_tree().process_frame


func after_each() -> void:
	ModalQueue._reset_for_tests()
	InputFocus._reset_for_tests()
	EventBus.fp_mode_changed.emit(false)
	EventBus.interactable_unfocused.emit()
	if is_instance_valid(_root):
		_root.free()
	_root = null
	StoreSessionState.reset_new_run()
	GameManager.current_state = _saved_state
	Settings.show_objective_rail = _saved_show_rail


func test_training_objective_rows_keep_copy_prompt_target_and_result_aligned() -> void:
	var controller: StoreSessionController = _controller()
	if controller == null:
		return
	var rows: Array[Dictionary] = controller.get_semantic_objective_targets()
	for objective_id: String in _expected_rows().keys():
		var row: Dictionary = _objective_row(rows, objective_id)
		assert_false(row.is_empty(), "Training row must exist: %s" % objective_id)
		_assert_objective_row(row, _expected_rows()[objective_id] as Dictionary)


func test_active_training_payload_matches_current_required_action() -> void:
	var controller: StoreSessionController = _controller()
	if controller == null:
		return
	_assert_active_payload(controller, _expected_rows()["talk_to_manager"] as Dictionary)

	controller.on_store_manager_interacted()
	await get_tree().process_frame
	_ack_detail(controller)
	await get_tree().process_frame
	_assert_active_payload(controller, _expected_rows()["check_register"] as Dictionary)

	controller.on_store_register_interacted()
	await get_tree().process_frame
	_ack_detail(controller)
	await get_tree().process_frame
	_assert_active_payload(
		controller,
		_expected_rows()["check_back_room_inventory"] as Dictionary
	)

	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	_ack_detail(controller)
	await get_tree().process_frame
	_assert_active_payload(controller, _expected_rows()["training_stock_shelf"] as Dictionary)


func test_first_person_hidden_objective_rail_tracks_training_stage_copy() -> void:
	var controller: StoreSessionController = _controller()
	if controller == null:
		return
	var rail: CanvasLayer = _make_rail()
	controller.call("_update_objective_rail")
	EventBus.fp_mode_changed.emit(true)

	_assert_rail_payload(
		rail,
		_expected_rows()["talk_to_manager"] as Dictionary,
		"manager beat"
	)

	controller.on_store_manager_interacted()
	await get_tree().process_frame
	StoreSessionTestHelpers.assert_acknowledge_first_minute_detail(self, controller)
	await get_tree().process_frame
	_assert_rail_payload(
		rail,
		_expected_rows()["check_register"] as Dictionary,
		"register beat"
	)
	_assert_rail_not_showing(
		rail,
		"Talk to the manager at checkout for opening instructions.",
		"manager copy must not remain after the manager detail is acknowledged"
	)

	controller.on_store_register_interacted()
	await get_tree().process_frame
	StoreSessionTestHelpers.assert_acknowledge_first_minute_detail(self, controller)
	await get_tree().process_frame
	_assert_rail_payload(
		rail,
		_expected_rows()["check_back_room_inventory"] as Dictionary,
		"back-room beat"
	)
	_assert_rail_not_showing(
		rail,
		"Open the register and confirm the checkout lane is ready.",
		"register copy must not remain after the register detail is acknowledged"
	)

	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	StoreSessionTestHelpers.assert_acknowledge_first_minute_detail(self, controller)
	await get_tree().process_frame
	_assert_rail_payload(
		rail,
		_expected_rows()["training_stock_shelf"] as Dictionary,
		"starter-display beat",
		false
	)
	_assert_rail_not_showing(
		rail,
		"Check the back room inventory and pick up the starter stock box.",
		"back-room copy must not remain after starter stock is picked up"
	)

	controller.on_store_restock_interacted()
	await get_tree().process_frame
	_assert_rail_text(
		rail,
		"Talk to the customer at the register.",
		"real-day customer beat"
	)
	_assert_rail_not_showing(
		rail,
		"Place all 3 starter items on the starter display table.",
		"stocking copy must not remain after the starter display is stocked"
	)


func _assert_objective_row(row: Dictionary, expected: Dictionary) -> void:
	assert_eq(str(row.get("stage", "")), str(expected.get("stage", "")))
	assert_eq(str(row.get("label", "")), str(expected.get("label", "")))
	assert_eq(str(row.get("action", "")), str(expected.get("action", "")))
	assert_false(str(row.get("explanation", "")).is_empty())
	assert_eq(str(row.get("target_path", "")), str(expected.get("target_path", "")))
	assert_eq(_row_prompt_label(row), str(expected.get("row_prompt_label", "")))
	assert_eq(str(row.get("result_summary", "")), str(expected.get("result_summary", "")))


func _assert_active_payload(controller: StoreSessionController, expected: Dictionary) -> void:
	var snapshot: Dictionary = controller.get_state_snapshot()
	assert_eq(str(snapshot.get("stage", "")), str(expected.get("stage", "")))
	assert_eq(str(snapshot.get("active_objective_label", "")), str(expected.get("label", "")))
	assert_eq(str(snapshot.get("active_objective_action", "")), str(expected.get("action", "")))
	assert_eq(
		str(snapshot.get("active_objective_target_path", "")),
		str(expected.get("target_path", ""))
	)
	assert_eq(
		str(snapshot.get("active_objective_prompt_label", "")),
		str(expected.get("active_prompt_label", ""))
	)
	assert_eq(
		str(snapshot.get("active_objective_result_summary", "")),
		str(expected.get("result_summary", ""))
	)
	assert_eq(Array(_active_targets()), [str(expected.get("target_owner", ""))])


func _assert_rail_payload(
	rail: CanvasLayer,
	expected: Dictionary,
	context: String,
	expect_action_chip: bool = true
) -> void:
	assert_false(
		rail.visible,
		"ObjectiveRail must stay hidden in FP mode for %s" % context
	)
	_assert_rail_text(rail, str(expected.get("label", "")), context)
	if expect_action_chip:
		assert_eq(
			rail._action_label.text,
			str(expected.get("action", "")),
			"ObjectiveRail action must match %s" % context
		)


func _assert_rail_text(rail: CanvasLayer, expected: String, context: String) -> void:
	assert_eq(
		rail._objective_label.text,
		expected,
		"ObjectiveRail label must match %s" % context
	)


func _assert_rail_not_showing(rail: CanvasLayer, stale_text: String, context: String) -> void:
	assert_ne(rail._objective_label.text, stale_text, context)


func _expected_rows() -> Dictionary:
	return {
		"talk_to_manager":
		{
			"stage": "training_talk_manager",
			"label": "Talk to the manager at checkout for opening instructions.",
			"action": "Get the opening routine from the manager",
			"target_path": "StoreSessionManager/Interactable",
			"target_owner": "StoreSessionManager",
			"row_prompt_label": "Talk to Manager",
			"active_prompt_label": "Talk to Manager",
			"result_summary": MANAGER_COMPLETE_MESSAGE,
		},
		"check_register":
		{
			"stage": "training_check_register",
			"label": "Open the register and confirm the checkout lane is ready.",
			"action": "Verify the register before customers arrive",
			"target_path": "StoreSessionDayEndTrigger/Interactable",
			"target_owner": "StoreSessionDayEndTrigger",
			"row_prompt_label": "Check Register",
			"active_prompt_label": "Check Register",
			"result_summary": REGISTER_COMPLETE_MESSAGE,
		},
		"check_back_room_inventory":
		{
			"stage": "training_back_room_inventory",
			"label": "Check the back room inventory and pick up the starter stock box.",
			"action": "Find the starter stock box in the back room",
			"target_path": "StoreSessionBackroomPickup/Interactable",
			"target_owner": "StoreSessionBackroomPickup",
			"row_prompt_label": "Inspect Starter Stock Box",
			"active_prompt_label": "Inspect Starter Stock Box",
			"result_summary": BACKROOM_COMPLETE_MESSAGE,
		},
		"training_stock_shelf":
		{
			"stage": "training_stock_shelf",
			"label": "Place all 3 starter items on the starter display table.",
			"action": "Stock the display with the starter box",
			"target_path": "StoreSessionRestockShelf/Interactable",
			"target_owner": "StoreSessionRestockShelf",
			"row_prompt_label": "Stock Starter Display",
			"active_prompt_label": "Place item 1 of 3 on Starter Display",
			"result_summary": DISPLAY_COMPLETE_MESSAGE,
		},
	}


func _objective_row(rows: Array[Dictionary], objective_id: String) -> Dictionary:
	for row: Dictionary in rows:
		if str(row.get("id", "")) == objective_id:
			return row
	return {}


func _row_prompt_label(row: Dictionary) -> String:
	return Interactable.compose_prompt_label(
		str(row.get("prompt_text", "")),
		str(row.get("prompt_display_name", ""))
	)


func _controller() -> StoreSessionController:
	if _root == null:
		return null
	return _root.get_node_or_null("StoreSessionController") as StoreSessionController


func _make_rail() -> CanvasLayer:
	var rail: CanvasLayer = preload(
		"res://game/scenes/ui/objective_rail.tscn"
	).instantiate() as CanvasLayer
	add_child_autofree(rail)
	return rail


func _ack_detail(controller: StoreSessionController) -> void:
	var panel: ModalPanel = controller.get("_first_minute_detail_panel") as ModalPanel
	assert_not_null(panel, "First-minute detail panel must exist")
	if panel == null:
		return
	var button: Button = panel.get("_confirm_button") as Button
	assert_not_null(button, "First-minute detail panel must expose a confirm button")
	if button != null:
		button.pressed.emit()


func _active_targets() -> PackedStringArray:
	var active: PackedStringArray = []
	for path: String in [
		"StoreSessionManager/Interactable",
		"StoreSessionDayOneCustomer/Interactable",
		"StoreSessionDayEndTrigger/Interactable",
		"StoreSessionBackroomPickup/Interactable",
		"StoreSessionRestockShelf/Interactable",
	]:
		var interactable: Interactable = _root.get_node_or_null(path) as Interactable
		if interactable != null and interactable.enabled and interactable.can_interact():
			active.append(path.get_slice("/", 0))
	active.sort()
	return active
