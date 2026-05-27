extends GutTest

const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"
const PROMPT_SCENE_PATH: String = "res://game/scenes/ui/interaction_prompt.tscn"
const EVENT_ID: String = "day01_wrong_console_parent"
const RegisterScreenStateScript: GDScript = preload(
	"res://game/scripts/store_session/register_screen_state.gd"
)
const REQUIRED_VISIBLE_ZONE_IDENTITY_PATHS: Array[String] = [
	"ReadabilityProps/ZoneIdentity/StarterTableFrontFootprint",
	"ReadabilityProps/ZoneIdentity/StarterTableLeftGuide",
	"ReadabilityProps/ZoneIdentity/StarterTableRightGuide",
	"ReadabilityProps/ZoneIdentity/BackroomDoorThreshold",
	"ReadabilityProps/ZoneIdentity/BackroomThresholdLeftGuide",
	"ReadabilityProps/ZoneIdentity/BackroomThresholdRightGuide",
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
	GameManager.current_state = _saved_state
	GameManager.set_current_day(_saved_day)


func test_day_one_prompts_are_visible_only_on_the_active_beat() -> void:
	var controller: StoreSessionController = _controller()
	if controller == null:
		return

	_assert_active_prompt("StoreSessionDayOneCustomer", "Talk to customer")
	_assert_inactive("StoreSessionBackroomPickup")
	_assert_inactive("StoreSessionRestockShelf")
	_assert_inactive("StoreSessionDayEndTrigger")

	await _choose_customer_option(&"refuse_return")
	await _acknowledge_customer_result()
	_assert_active_prompt("StoreSessionBackroomPickup", "Check back room inventory")
	_assert_inactive("StoreSessionDayOneCustomer")
	_assert_inactive("StoreSessionRestockShelf")
	_assert_inactive("StoreSessionDayEndTrigger")

	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	_assert_active_prompt("StoreSessionRestockShelf", "Place item 1 of 3 on starter display table")
	assert_true(StoreSessionState.carrying_stock, "Back-room pickup must set carrying state")

	controller.on_store_restock_interacted(false)
	await get_tree().process_frame
	_assert_active_prompt("StoreSessionRestockShelf", "Place item 2 of 3 on starter display table")

	controller.on_store_restock_interacted(false)
	await get_tree().process_frame
	_assert_active_prompt("StoreSessionRestockShelf", "Place item 3 of 3 on starter display table")

	controller.on_store_restock_interacted(false)
	await get_tree().process_frame
	_assert_active_prompt("StoreSessionDayEndTrigger", "Close day")
	_assert_inactive("StoreSessionBackroomPickup")
	_assert_inactive("StoreSessionRestockShelf")


func test_decision_modal_opens_from_customer_interaction_with_authored_data() -> void:
	var prompt: CanvasLayer = load(PROMPT_SCENE_PATH).instantiate() as CanvasLayer
	add_child_autofree(prompt)
	EventBus.interactable_focused.emit("[E] Talk to customer")
	assert_true(
		(prompt.get_node("PanelContainer") as PanelContainer).visible,
		"Precondition: interaction prompt is visible before the modal opens"
	)

	var controller: StoreSessionController = _controller()
	if controller == null:
		return
	controller.on_store_customer_interacted()
	await get_tree().process_frame

	var decision: DecisionCardPanel = controller.get("_decision_panel") as DecisionCardPanel
	assert_not_null(decision, "Customer interaction must own a decision modal")
	if decision == null:
		return
	assert_true(decision.visible, "Customer interaction must open the decision modal")
	assert_eq(InputFocus.current(), InputFocus.CTX_MODAL)
	assert_eq(
		String((controller.get("_active_event") as Dictionary).get("id", "")),
		EVENT_ID,
		"Decision modal must be sourced from the Day 1 customer event"
	)
	assert_eq((decision.get("_title_label") as Label).text, "Wrong Platform")
	assert_string_contains(
		(decision.get("_body_label") as RichTextLabel).text,
		"sealed copy",
		"Modal body must render the authored customer-event body copy"
	)
	var buttons: Array = decision.get("_choice_buttons") as Array
	assert_eq(buttons.size(), 3, "All three customer choices must render")
	assert_eq(get_viewport().gui_get_focus_owner(), buttons[0])

	await get_tree().create_timer(0.2).timeout
	assert_false(
		(prompt.get_node("PanelContainer") as PanelContainer).visible,
		"Interaction prompt must be suppressed while the decision modal owns focus"
	)


func test_clean_exchange_result_acknowledges_without_modal_leak() -> void:
	await _assert_choice_result_flow(&"clean_exchange", "Exchange Accepted")


func test_upsell_bundle_result_acknowledges_without_modal_leak() -> void:
	await _assert_choice_result_flow(&"upsell_bundle", "Bundle Sold")


func test_refuse_return_result_acknowledges_without_modal_leak() -> void:
	await _assert_choice_result_flow(&"refuse_return", "Exchange Refused")


func test_customer_exit_state_tracks_acknowledged_walk_hidden_and_reset() -> void:
	var controller: StoreSessionController = _controller()
	if controller == null:
		return
	var customer: Node3D = _root.get_node_or_null("StoreSessionDayOneCustomer") as Node3D
	assert_not_null(customer, "StoreSessionDayOneCustomer must remain authored")
	if customer == null:
		return
	var states: Array[StringName] = []
	controller.customer_exit_state_changed.connect(
		func(state: StringName) -> void:
			states.append(state)
	)

	assert_eq(
		controller.customer_exit_state(),
		StoreSessionController.CUSTOMER_EXIT_NOT_STARTED,
		"Customer exit starts idle before the result is acknowledged"
	)

	await _choose_customer_option(&"refuse_return")
	assert_eq(
		controller.customer_exit_state(),
		StoreSessionController.CUSTOMER_EXIT_NOT_STARTED,
		"Selecting a choice must not start exit before the result Continue"
	)

	await _acknowledge_customer_result()
	assert_true(
		states.has(StoreSessionController.CUSTOMER_EXIT_RESULT_ACKNOWLEDGED),
		"Continue must record result acknowledgement before the exit walk"
	)
	assert_true(
		states.has(StoreSessionController.CUSTOMER_EXIT_IN_PROGRESS),
		"Continue must record the customer exit walk as in progress"
	)
	assert_lt(
		states.find(StoreSessionController.CUSTOMER_EXIT_RESULT_ACKNOWLEDGED),
		states.find(StoreSessionController.CUSTOMER_EXIT_IN_PROGRESS),
		"Exit state order must distinguish acknowledgement from walk start"
	)
	assert_eq(
		controller.customer_exit_state(),
		StoreSessionController.CUSTOMER_EXIT_IN_PROGRESS,
		"Exit walk state must be inspectable without waiting on tween duration"
	)
	_assert_active_prompt("StoreSessionBackroomPickup", "Check back room inventory")
	_assert_inactive("StoreSessionDayOneCustomer")

	controller.call("_finalize_customer_exit", customer)
	assert_eq(
		controller.customer_exit_state(),
		StoreSessionController.CUSTOMER_EXIT_EXITED,
		"Finalized exit must mark the customer hidden"
	)
	assert_true(controller.is_customer_exit_complete())
	assert_false(customer.visible, "Finalized exit must hide the customer proxy")

	controller.call("_reset_scene_for_day", 2)
	assert_eq(
		controller.customer_exit_state(),
		StoreSessionController.CUSTOMER_EXIT_NOT_STARTED,
		"Day reset must clear the prior customer exit state"
	)
	assert_false(controller.is_customer_exit_complete())
	assert_true(customer.visible, "Day reset must restore the customer proxy")


func test_day_start_clears_unresolved_customer_visuals_and_register_state() -> void:
	var controller: StoreSessionController = _controller()
	var screen = _screen()
	if controller == null or screen == null:
		return

	controller.on_store_customer_interacted()
	await get_tree().process_frame
	var decision: DecisionCardPanel = controller.get("_decision_panel") as DecisionCardPanel
	assert_not_null(decision, "Customer decision must open before selecting a choice")
	if decision == null:
		return
	var button: Button = _choice_button(decision, &"refuse_return")
	assert_not_null(button, "Refused-return choice must exist")
	if button == null:
		return
	button.pressed.emit()
	await get_tree().process_frame

	var result: ModalPanel = controller.get("_customer_result_panel") as ModalPanel
	assert_not_null(result, "Customer result must be visible before day reset")
	if result == null:
		return
	assert_true(result.visible)
	assert_eq(StoreSessionState.input_mode, StoreSessionState.INPUT_MODE_CUSTOMER_RESULT)
	assert_eq(screen.current_state(), RegisterScreenStateScript.STATE_NO_SALE)
	assert_eq(_customer_counter_anchor_count(), 1)

	controller.call("_start_day", 2)
	await get_tree().process_frame

	assert_false(result.visible)
	assert_false(decision.visible)
	assert_ne(InputFocus.current(), InputFocus.CTX_MODAL)
	assert_eq(StoreSessionState.input_mode, StoreSessionState.INPUT_MODE_GAMEPLAY)
	assert_eq(_customer_counter_anchor_count(), 0)
	assert_eq(screen.current_state(), RegisterScreenStateScript.STATE_READY)
	assert_eq(String(controller.current_stage()), "talk_to_customer")


func test_restock_requires_carrying_and_repeated_stocking_does_not_duplicate() -> void:
	var controller: StoreSessionController = _controller()
	if controller == null:
		return
	await _choose_customer_option(&"refuse_return")
	await _acknowledge_customer_result()
	controller.set("_stage", StoreSessionController.STAGE_STOCK_SHELF)
	StoreSessionState.carrying_stock = false

	controller.on_store_restock_interacted()
	await get_tree().process_frame
	assert_false(
		bool(controller.is_objective_completed(&"stock_shelf")),
		"Stocking must fail closed when the player is not carrying stock"
	)
	assert_eq(_spawned_shelf_item_count(), 0, "No shelf stock may appear without carry state")

	StoreSessionState.carrying_stock = true
	controller.on_store_restock_interacted()
	await get_tree().process_frame
	var first_count: int = _spawned_shelf_item_count()
	assert_gt(first_count, 0, "Successful stocking must spawn visible shelf items")
	controller.on_store_restock_interacted()
	await get_tree().process_frame
	assert_eq(
		_spawned_shelf_item_count(),
		first_count,
		"Repeated stocking input must not duplicate visible shelf items"
	)


func test_summary_continue_starts_next_shift_with_content_or_generated_customer() -> void:
	var controller: StoreSessionController = _controller()
	if controller == null:
		return
	controller._on_choice_selected(&"refuse_return", {"cash": 0, "reputation": -3})
	await get_tree().process_frame
	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	controller.on_store_restock_interacted()
	await get_tree().process_frame
	controller.set("_events_by_day", {1: controller.get("_day_events")})
	controller._on_day_close_confirmed()
	await get_tree().process_frame

	var summary: DaySummaryPanel = controller.get("_summary_panel") as DaySummaryPanel
	assert_not_null(summary, "Close day must open the summary panel")
	if summary == null:
		return
	assert_true(summary.visible)
	assert_eq((summary.get("_title_label") as Label).text, "Day 1 Summary")
	assert_string_contains((summary.get("_metrics_label") as RichTextLabel).text, "Sales:")
	assert_eq((summary.get("_continue_button") as Button).text, "Continue to next day")

	(summary.get("_continue_button") as Button).pressed.emit()
	await get_tree().process_frame

	assert_eq(StoreSessionState.day, 2)
	assert_eq(GameManager.get_current_day(), 2)
	assert_ne(InputFocus.current(), InputFocus.CTX_MODAL)
	assert_eq(String(controller.current_stage()), "talk_to_customer")
	assert_eq(
		String((controller.get("_active_event") as Dictionary).get("id", "")),
		"repeat_shift_customer_day_02",
		"Continue must generate playable Day 2 store work when authored content is absent"
	)

	controller.call("_start_day", 3)
	await get_tree().process_frame
	assert_eq(StoreSessionState.day, 3)
	assert_eq(
		String((controller.get("_active_event") as Dictionary).get("id", "")),
		"repeat_shift_customer_day_03",
		"Days without authored events must generate a normal customer so the loop repeats"
	)
	await _choose_customer_option(&"fair_sale")
	await _acknowledge_customer_result()
	assert_eq(
		String(controller.current_stage()),
		"back_room_inventory",
		"Generated normal customer events must advance into the same store-work loop"
	)
	assert_gt(StoreSessionState.daily_cash_delta, 0, "Generated customer sale must add daily cash")


func test_reinvest_order_charges_once_and_delivery_consumes_once() -> void:
	var controller: StoreSessionController = _controller()
	if controller == null:
		return
	StoreSessionState.cash = 100
	controller.set("_stage", StoreSessionController.STAGE_END_DAY)
	controller.call("_on_day_close_confirmed")
	await get_tree().process_frame
	var summary: DaySummaryPanel = controller.get("_summary_panel") as DaySummaryPanel
	assert_not_null(summary, "End-day confirmation must open the summary")
	if summary == null:
		return

	controller.call("_on_summary_reinvest", StoreSessionController._REORDER_OPTION_ID)
	await get_tree().process_frame
	assert_eq(StoreSessionState.cash, 80)
	assert_eq(int(controller.get("_pending_extra_delivery_quantity")), 2)

	controller.call("_on_summary_reinvest", StoreSessionController._REORDER_OPTION_ID)
	await get_tree().process_frame
	assert_eq(StoreSessionState.cash, 80, "A second press must not charge again")
	assert_eq(
		int(controller.get("_pending_extra_delivery_quantity")),
		StoreSessionController._REORDER_EXTRA_QUANTITY
	)

	controller.call("_on_summary_continue")
	await get_tree().process_frame
	assert_eq(StoreSessionState.day, 2)
	assert_eq(
		int(controller.get("_current_delivery_quantity")),
		StoreSessionController._BACKROOM_DELIVERY_QUANTITY
		+ StoreSessionController._REORDER_EXTRA_QUANTITY
	)
	assert_eq(int(controller.get("_pending_extra_delivery_quantity")), 0)

	controller.call("_start_day", 3)
	await get_tree().process_frame
	assert_eq(
		int(controller.get("_current_delivery_quantity")),
		StoreSessionController._BACKROOM_DELIVERY_QUANTITY
	)


func test_required_zone_labels_props_and_debug_surfaces_are_validation_ready() -> void:
	for path: String in REQUIRED_VISIBLE_ZONE_IDENTITY_PATHS:
		var zone_identity: Node3D = _root.get_node_or_null(path) as Node3D
		assert_not_null(zone_identity, "%s must exist" % path)
		if zone_identity != null:
			assert_true(zone_identity.visible, "%s must be visible" % path)

	var props: Node = _root.get_node_or_null("ReadabilityProps")
	assert_not_null(props, "ReadabilityProps must ship with the Day 1 scene")
	if props != null:
		for path: String in [
			"DayOneRouteMarkers",
			"WallPosters",
			"CartRackProductStacks",
		]:
			var prop_node: Node = props.get_node_or_null(path)
			assert_not_null(prop_node, "ReadabilityProps/%s must exist" % path)
		var posters: Node3D = props.get_node_or_null("WallPosters") as Node3D
		assert_true(
			posters != null and posters.visible,
			"ReadabilityProps/WallPosters must remain visible store_session context"
		)
		var floor_display: Node3D = props.get_node_or_null("FloorDisplayIsland") as Node3D
		assert_not_null(floor_display, "ReadabilityProps/FloorDisplayIsland must remain authored")
		if floor_display != null:
			assert_false(
				floor_display.visible,
				"ReadabilityProps/FloorDisplayIsland must stay deferred in store_session review scope"
			)

	var debug_overlay: CanvasLayer = _controller().get("_debug_overlay") as CanvasLayer
	assert_not_null(debug_overlay, "Store debug overlay must be available for QA capture mode")
	if debug_overlay != null:
		var panel: PanelContainer = debug_overlay.get("_panel") as PanelContainer
		assert_not_null(panel, "Debug overlay must own a panel")
		if panel != null:
			assert_false(panel.visible, "Debug overlay must be hidden by default")


func test_new_game_reset_clears_day_cash_flags_and_carry_state() -> void:
	StoreSessionState.day = 2
	StoreSessionState.cash = 99
	StoreSessionState.carrying_stock = true
	StoreSessionState.flags[&"choice_refuse_return"] = true
	GameManager.begin_new_run()

	assert_eq(StoreSessionState.day, 1)
	assert_eq(StoreSessionState.cash, 0)
	assert_false(StoreSessionState.carrying_stock)
	assert_true(StoreSessionState.flags.is_empty(), "New Game reset must clear prior run flags")
	assert_eq(GameManager.get_current_day(), 1)


func _assert_choice_result_flow(choice_id: StringName, expected_headline: String) -> void:
	var anchor_before: Node3D = _customer_counter_anchor()
	assert_not_null(
		anchor_before,
		"Customer beat must show the shared counter item before the decision opens"
	)
	if anchor_before != null:
		assert_true(anchor_before.visible)
		assert_false(anchor_before is Interactable, "Counter item must not become a prompt target")
		assert_eq(_customer_counter_anchor_count(), 1, "Customer flow must own one counter item")
		assert_eq(str(anchor_before.get_meta("counter_state", "")), "pending")
		_assert_counter_anchor_receipt_visible(anchor_before)
	await _choose_customer_option(choice_id)
	var controller: StoreSessionController = _controller()
	var result: ModalPanel = controller.get("_customer_result_panel") as ModalPanel
	assert_not_null(result, "Customer choice must open a result screen")
	if result == null:
		return
	var anchor_after_choice: Node3D = _customer_counter_anchor()
	assert_not_null(anchor_after_choice, "Choice result must update the same shared counter item")
	if anchor_after_choice != null:
		if anchor_before != null:
			assert_eq(anchor_after_choice.get_instance_id(), anchor_before.get_instance_id())
		assert_true(anchor_after_choice.visible)
		assert_eq(str(anchor_after_choice.get_meta("counter_state", "")), _expected_counter_state(choice_id))
		assert_eq(_customer_counter_anchor_count(), 1, "Choice result must not spawn per-choice props")
	assert_true(result.visible)
	_assert_acknowledgement_panel_quiet(result, expected_headline)
	assert_eq(StoreSessionState.input_mode, StoreSessionState.INPUT_MODE_CUSTOMER_RESULT)
	assert_eq(controller.current_stage(), StoreSessionController.STAGE_TALK_TO_CUSTOMER)

	await _acknowledge_customer_result()
	await get_tree().process_frame
	assert_eq(_customer_counter_anchor_count(), 0, "Settled customer outcome must clear the counter item")
	assert_false(result.visible, "Acknowledgement must close the customer result")
	assert_eq(StoreSessionState.input_mode, StoreSessionState.INPUT_MODE_GAMEPLAY)
	assert_ne(InputFocus.current(), InputFocus.CTX_MODAL)
	assert_eq(controller.current_stage(), StoreSessionController.STAGE_BACK_ROOM_INVENTORY)
	_assert_active_prompt("StoreSessionBackroomPickup", "Check back room inventory")


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


func _choice_button(decision: DecisionCardPanel, choice_id: StringName) -> Button:
	var event_data: Dictionary = _controller().get("_active_event") as Dictionary
	var choices: Array = event_data.get("choices", []) as Array
	var buttons: Array = decision.get("_choice_buttons") as Array
	for idx: int in range(choices.size()):
		var choice: Dictionary = choices[idx] as Dictionary
		if StringName(str(choice.get("id", ""))) == choice_id and idx < buttons.size():
			return buttons[idx] as Button
	return null


func _assert_acknowledgement_panel_quiet(result: ModalPanel, expected_headline: String) -> void:
	assert_eq((result.get("_title_label") as Label).text, expected_headline)
	assert_null(
		result.get("_consequences_box"),
		"Customer result must not render cash, inventory, or reputation rows"
	)
	var acknowledgement: Label = result.get("_acknowledgement_label") as Label
	assert_not_null(acknowledgement, "Customer result must show concise acknowledgement copy")
	if acknowledgement == null:
		return
	assert_gt(acknowledgement.text.length(), 0)
	assert_lt(acknowledgement.text.length(), 96)
	for disallowed: String in ["$", "Inventory", "Reputation", "manager trust"]:
		assert_false(
			acknowledgement.text.contains(disallowed),
			"Acknowledgement copy must stay secondary to room and HUD evidence"
		)


func _assert_active_prompt(parent_name: String, expected_label: String) -> void:
	var interactable: Interactable = _interactable(parent_name)
	assert_not_null(interactable, "%s/Interactable must exist" % parent_name)
	if interactable == null:
		return
	assert_true(interactable.enabled, "%s must be enabled for the active beat" % parent_name)
	assert_true(interactable.can_interact(), "%s must accept interaction" % parent_name)
	assert_eq(interactable.get_prompt_label(), expected_label)


func _assert_inactive(parent_name: String) -> void:
	var interactable: Interactable = _interactable(parent_name)
	assert_not_null(interactable, "%s/Interactable must exist" % parent_name)
	if interactable == null:
		return
	assert_false(interactable.enabled, "%s must not expose a prompt outside its beat" % parent_name)


func _interactable(parent_name: String) -> Interactable:
	if _root == null:
		return null
	return _root.get_node_or_null("%s/Interactable" % parent_name) as Interactable


func _controller() -> StoreSessionController:
	return get_tree().get_first_node_in_group("store_session_controller") as StoreSessionController


func _customer_counter_anchor() -> Node3D:
	if _root == null:
		return null
	return _root.get_node_or_null("checkout_counter/StoreSessionCustomerCounterAnchor") as Node3D


func _customer_counter_anchor_count() -> int:
	if _root == null:
		return 0
	var checkout: Node = _root.get_node_or_null("checkout_counter")
	if checkout == null:
		return 0
	var count: int = 0
	for child: Node in checkout.get_children():
		if child.name == &"StoreSessionCustomerCounterAnchor":
			count += 1
	return count


func _screen():
	if _root == null:
		return null
	var screen: Node = _root.get_node_or_null("Checkout/Register/RegisterScreenState")
	if screen == null or screen.get_script() != RegisterScreenStateScript:
		return null
	return screen


func _assert_counter_anchor_receipt_visible(anchor: Node3D) -> void:
	var receipt: MeshInstance3D = anchor.get_node_or_null("SharedReceiptSlip") as MeshInstance3D
	assert_not_null(receipt, "Shared counter item must include the visible receipt surface")
	if receipt != null:
		assert_true(receipt.visible)


func _expected_counter_state(choice_id: StringName) -> String:
	match choice_id:
		&"upsell_bundle":
			return "bundle"
		&"refuse_return":
			return "refused"
		_:
			return "clean_exchange"


func _spawned_shelf_item_count() -> int:
	var shelf: Node = _root.get_node_or_null("StoreSessionRestockShelf")
	if shelf == null:
		return 0
	var count: int = 0
	for child: Node in shelf.get_children():
		if String(child.name).begins_with("StoreShelfItem"):
			count += 1
	return count


func _register_unlock_entries() -> void:
	var display_names: Dictionary = {
		"employee_register_access": "Register Access",
		"employee_stocking_trained": "Stocking Certification",
		"employee_closing_certified": "Closing Certification",
	}
	for unlock_id: String in display_names.keys():
		if ContentRegistry.exists(unlock_id):
			continue
		ContentRegistry.register_entry(
			{"id": unlock_id, "display_name": String(display_names[unlock_id])},
			"unlock"
		)
	UnlockSystemSingleton.initialize()
