extends GutTest

const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"
const FIRST_EVENT_ID: String = "day01_wrong_console_parent"
const SECOND_EVENT_ID: String = "repeat_customer_sale"

var _root: Node3D = null
var _saved_state: GameManager.State
var _saved_day: int


func before_each() -> void:
	_saved_state = GameManager.current_state
	_saved_day = GameManager.get_current_day()
	GameManager.current_state = GameManager.State.STORE_VIEW
	GameManager.set_current_day(1)
	StoreSessionState.reset_new_run()
	StoreSessionState.preopening_complete = true
	InputFocus._reset_for_tests()
	ModalQueue._reset_for_tests()
	_register_unlock_entries()
	var scene: PackedScene = load(SCENE_PATH)
	assert_not_null(scene, "Retro Games scene must load")
	if scene == null:
		return
	_root = scene.instantiate() as Node3D
	add_child(_root)
	await get_tree().process_frame
	await get_tree().process_frame


func after_each() -> void:
	ModalQueue._reset_for_tests()
	InputFocus._reset_for_tests()
	if is_instance_valid(_root):
		_root.free()
	_root = null
	StoreSessionState.reset_new_run()
	UnlockSystemSingleton.initialize()
	GameManager.current_state = _saved_state
	GameManager.set_current_day(_saved_day)


func test_two_customer_events_resolve_in_order_before_close_day() -> void:
	var controller: StoreSessionController = _controller()
	if controller == null:
		return
	await _configure_two_customer_day(controller)

	assert_eq(String((controller.get("_active_event") as Dictionary).get("id", "")), FIRST_EVENT_ID)
	assert_eq(int(controller.get("_current_event_index")), 0)
	assert_eq(int(controller.get("_resolved_events_today")), 0)
	assert_eq(Array(_stage_critical_path_targets()), ["StoreSessionDayOneCustomer"])

	await _choose_customer_option(&"refuse_return")
	await _acknowledge_customer_result()
	assert_eq(String(controller.current_stage()), "back_room_inventory")
	assert_eq(int(controller.get("_current_event_index")), 0)
	assert_eq(int(controller.get("_resolved_events_today")), 1)

	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	controller.on_store_restock_interacted()
	await get_tree().process_frame

	assert_eq(String(controller.current_stage()), "talk_to_customer")
	assert_eq(String((controller.get("_active_event") as Dictionary).get("id", "")), SECOND_EVENT_ID)
	assert_eq(int(controller.get("_current_event_index")), 1)
	assert_eq(int(controller.get("_resolved_events_today")), 1)
	assert_false(controller.can_interact_day_end())
	assert_eq(Array(_stage_critical_path_targets()), ["StoreSessionDayOneCustomer"])

	await _choose_customer_option(&"no_sale")
	await _acknowledge_customer_result()

	assert_eq(String(controller.current_stage()), "end_day")
	assert_eq(int(controller.get("_current_event_index")), 1)
	assert_eq(int(controller.get("_resolved_events_today")), 2)
	assert_true(controller.can_interact_day_end())
	assert_eq(Array(_stage_critical_path_targets()), ["StoreSessionDayEndTrigger"])

	controller.on_store_day_end_requested()
	await get_tree().process_frame
	_press_close_day_confirm(controller)
	await get_tree().process_frame
	await get_tree().process_frame

	var summary_panel: DaySummaryPanel = controller.get("_summary_panel") as DaySummaryPanel
	assert_not_null(summary_panel, "Two-customer route must still open the day summary")
	if summary_panel == null:
		return
	_assert_summary_label(summary_panel, "_customers_helped_label", "Customers Helped: 2")
	_assert_summary_label(summary_panel, "_items_stocked_label", "Items Stocked: 3")
	_assert_summary_label(summary_panel, "_sales_completed_label", "Sales Completed: 0")


func test_authored_next_shift_customer_uses_result_acknowledgement_path() -> void:
	var controller: StoreSessionController = _controller()
	if controller == null:
		return

	controller.call("_start_day", 2)
	await get_tree().process_frame

	assert_eq(
		String((controller.get("_active_event") as Dictionary).get("id", "")),
		"day02_trade_in_dispute"
	)
	assert_eq(String(controller.current_stage()), "talk_to_customer")

	await _choose_customer_option(&"offer_partial")

	var result: ModalPanel = controller.get("_customer_result_panel") as ModalPanel
	assert_not_null(result, "Authored Day 2 choice must open the customer result panel")
	if result == null:
		return
	assert_true(result.visible, "Authored Day 2 result must stay visible until acknowledged")
	assert_eq(String(controller.current_stage()), "talk_to_customer")

	await _acknowledge_customer_result()
	assert_eq(
		String(controller.current_stage()),
		"back_room_inventory",
		"Authored Day 2 result acknowledgement must advance through the same store-work loop"
	)


func test_repeat_customer_with_empty_shelf_routes_to_no_stock_result() -> void:
	var controller: StoreSessionController = _controller()
	if controller == null:
		return
	await _configure_two_customer_day(controller)

	await _choose_customer_option(&"refuse_return")
	await _acknowledge_customer_result()
	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	controller.set("_shelf_stock_count", 0)
	controller.set("_carried_stock_remaining", 0)
	StoreSessionState.carrying_stock = false
	controller.call("_complete_current_objective")
	await get_tree().process_frame

	var active_event: Dictionary = controller.get("_active_event") as Dictionary
	assert_eq(String(active_event.get("title", "")), "Empty Shelf")
	assert_eq(_choice_ids(active_event), [&"no_stock_apology"])
	assert_false(controller.can_interact_day_end())
	watch_signals(EventBus)

	await _choose_customer_option(&"no_stock_apology")
	await _acknowledge_customer_result()

	assert_signal_not_emitted(EventBus, "item_sold")
	assert_signal_not_emitted(EventBus, "customer_purchased")
	assert_eq(StoreSessionState.cash, 0)
	assert_eq(String(controller.current_stage()), "end_day")
	assert_eq(int(controller.get("_resolved_events_today")), 2)


func _configure_two_customer_day(controller: StoreSessionController) -> void:
	var first_event: Dictionary = (controller.get("_active_event") as Dictionary).duplicate(true)
	var second_event: Dictionary = (
		controller.call("_build_repeatable_shift_customer_event", 1) as Dictionary
	).duplicate(true)
	second_event["id"] = SECOND_EVENT_ID
	controller.set("_events_by_day", {1: [first_event, second_event]})
	controller.call("_start_day", 1)
	await get_tree().process_frame


func _choose_customer_option(choice_id: StringName) -> void:
	var controller: StoreSessionController = _controller()
	if controller == null:
		return
	controller.on_store_customer_interacted()
	await get_tree().process_frame
	var decision: DecisionCardPanel = controller.get("_decision_panel") as DecisionCardPanel
	assert_not_null(decision, "Decision card must open before selecting a choice")
	if decision == null:
		return
	var button: Button = _choice_button(decision, choice_id)
	assert_not_null(button, "Choice button %s must exist" % String(choice_id))
	if button == null:
		return
	button.pressed.emit()
	await get_tree().process_frame


func _acknowledge_customer_result() -> void:
	var controller: StoreSessionController = _controller()
	if controller == null:
		return
	var result: ModalPanel = controller.get("_customer_result_panel") as ModalPanel
	assert_not_null(result, "Customer result must exist before acknowledgement")
	if result == null:
		return
	var button: Button = result.get("_continue_button") as Button
	assert_not_null(button, "Customer result must own Continue")
	if button == null:
		return
	button.pressed.emit()
	await get_tree().process_frame


func _press_close_day_confirm(controller: Node) -> void:
	var panel: CanvasLayer = controller.get("_close_day_panel") as CanvasLayer
	if panel == null:
		EventBus.day_close_confirmed.emit()
		return
	panel.call("_on_confirm_pressed")


func _assert_summary_label(summary_panel: DaySummaryPanel, field: String, expected: String) -> void:
	var label: Label = summary_panel.get(field) as Label
	assert_not_null(label, "Summary must own %s" % field)
	if label == null:
		return
	assert_eq(label.text, expected)


func _choice_button(decision: DecisionCardPanel, choice_id: StringName) -> Button:
	var event_data: Dictionary = _controller().get("_active_event") as Dictionary
	var choices: Array = event_data.get("choices", []) as Array
	var buttons: Array = decision.get("_choice_buttons") as Array
	for idx: int in range(choices.size()):
		var choice: Dictionary = choices[idx] as Dictionary
		if StringName(str(choice.get("id", ""))) == choice_id and idx < buttons.size():
			return buttons[idx] as Button
	return null


func _choice_ids(event_data: Dictionary) -> Array[StringName]:
	var ids: Array[StringName] = []
	for choice_variant: Variant in event_data.get("choices", []) as Array:
		if choice_variant is Dictionary:
			ids.append(StringName(str((choice_variant as Dictionary).get("id", ""))))
	return ids


func _stage_critical_path_targets() -> PackedStringArray:
	var enabled := PackedStringArray()
	for parent_name: String in [
		"StoreSessionDayOneCustomer",
		"StoreSessionBackroomPickup",
		"StoreSessionRestockShelf",
		"StoreSessionDayEndTrigger",
	]:
		var interactable := _interactable(parent_name)
		if interactable != null and interactable.enabled:
			enabled.append(parent_name)
	return enabled


func _interactable(parent_name: String) -> Interactable:
	if _root == null:
		return null
	return _root.get_node_or_null("%s/Interactable" % parent_name) as Interactable


func _controller() -> StoreSessionController:
	return get_tree().get_first_node_in_group("store_session_controller") as StoreSessionController


func _register_unlock_entries() -> void:
	var display_names: Dictionary = {
		"employee_register_access": "Register Access",
		"employee_stocking_trained": "Stocking Certification",
		"employee_closing_certified": "Closing Certification",
	}
	for unlock_id: StringName in [
		&"employee_register_access",
		&"employee_stocking_trained",
		&"employee_closing_certified",
	]:
		var raw_id: String = String(unlock_id)
		if ContentRegistry.exists(raw_id):
			continue
		ContentRegistry.register_entry(
			{
				"id": raw_id,
				"display_name": String(display_names.get(raw_id, raw_id)),
			},
			"unlock"
		)
