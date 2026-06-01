extends GutTest

const PanelScript: GDScript = preload(
	"res://game/scripts/store_session/first_minute_detail_panel.gd"
)
const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"
const DETAIL_MANAGER_BRIEFING: StringName = &"manager_briefing"
const DETAIL_REGISTER_CHECK: StringName = &"register_check"
const DETAIL_BACKROOM_INVENTORY: StringName = &"backroom_inventory"
const MANAGER_COMPLETE_MESSAGE: String = (
	"Manager walkthrough complete. Register access unlocked."
)
const REGISTER_COMPLETE_MESSAGE: String = (
	"Register ready. Customers can be handled from the checkout lane."
)
const BACKROOM_COMPLETE_MESSAGE: String = (
	"Back room inventory checked. Pick up the starter stock box."
)
const MANAGER_BRIEFING_BODY: String = (
	"Today you’ll learn the opening routine: check the register, verify back room "
	+ "stock, stock the starter display, then handle your first customer."
)
const REGISTER_CHECK_BODY: String = (
	"Cash drawer: Ready\n\n"
	+ "Scanner: Ready\n\n"
	+ "Receipt printer: Ready\n\n"
	+ "Checkout lane: Ready"
)
const BACKROOM_INVENTORY_BODY: String = (
	"Starter Stock Box found.\n\n"
	+ "Contains 3 starter display items."
)

var _root: Node3D = null


func before_each() -> void:
	StoreSessionState.reset_new_run()
	InputFocus._reset_for_tests()
	ModalQueue._reset_for_tests()


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


func test_panel_only_supports_first_minute_details() -> void:
	var panel: ModalPanel = PanelScript.new() as ModalPanel
	add_child_autofree(panel)

	assert_true(bool(panel.call("supports_detail", DETAIL_MANAGER_BRIEFING)))
	assert_true(bool(panel.call("supports_detail", DETAIL_REGISTER_CHECK)))
	assert_true(bool(panel.call("supports_detail", DETAIL_BACKROOM_INVENTORY)))
	assert_false(bool(panel.call("supports_detail", &"future_tutorial")))
	assert_false(bool(panel.call("show_detail", &"future_tutorial", {})))
	assert_false(panel.visible)
	assert_false(ModalQueue.is_busy())


func test_detail_panels_share_modal_chrome_and_type_scale() -> void:
	var snapshots: Array[Dictionary] = []
	for detail_id: StringName in [
		DETAIL_MANAGER_BRIEFING,
		DETAIL_REGISTER_CHECK,
		DETAIL_BACKROOM_INVENTORY,
	]:
		var panel: ModalPanel = PanelScript.new() as ModalPanel
		add_child_autofree(panel)
		assert_true(bool(panel.call("show_detail", detail_id, _payload_for_detail(detail_id))))
		await get_tree().process_frame
		var root_panel: PanelContainer = panel.get_node("Blocker/Panel") as PanelContainer
		var content: VBoxContainer = root_panel.get_node("Content") as VBoxContainer
		var style: StyleBoxFlat = root_panel.get_theme_stylebox("panel") as StyleBoxFlat
		var button: Button = panel.get("_confirm_button") as Button
		snapshots.append(
			{
				"tag_size": (panel.get("_tag_label") as Label).get_theme_font_size("font_size"),
				"title_size": (panel.get("_title_label") as Label).get_theme_font_size("font_size"),
				"body_size":
				(panel.get("_body_label") as RichTextLabel).get_theme_font_size(
					"normal_font_size"
				),
				"spacing": content.get_theme_constant("separation"),
				"button_height": button.custom_minimum_size.y,
				"border": style.border_width_left,
				"corner": style.corner_radius_top_left,
			}
		)
		panel.close()
		ModalQueue._reset_for_tests()
		InputFocus._reset_for_tests()
	for idx: int in range(1, snapshots.size()):
		assert_eq(snapshots[idx], snapshots[0], "Detail panel chrome must stay shared")


func test_passive_details_do_not_use_modal_dimming_or_mouse_blocking() -> void:
	for detail_id: StringName in [DETAIL_MANAGER_BRIEFING, DETAIL_BACKROOM_INVENTORY]:
		var panel: ModalPanel = PanelScript.new() as ModalPanel
		add_child_autofree(panel)
		assert_true(bool(panel.call("show_detail", detail_id, _payload_for_detail(detail_id))))
		await get_tree().process_frame
		var blocker: ColorRect = panel.get("_blocker") as ColorRect
		assert_not_null(blocker, "Detail panel must expose its blocker")
		if blocker != null:
			assert_eq(
				blocker.mouse_filter,
				Control.MOUSE_FILTER_IGNORE,
				"Passive details must not block pointer interaction"
			)
			assert_almost_eq(
				blocker.color.a, 0.0, 0.001,
				"Passive details must not add a full-screen dim layer"
			)
		assert_ne(InputFocus.current(), InputFocus.CTX_MODAL)
		panel.close()
		ModalQueue._reset_for_tests()


func test_register_detail_keeps_blocking_modal_treatment() -> void:
	var panel: ModalPanel = PanelScript.new() as ModalPanel
	add_child_autofree(panel)
	assert_true(
		bool(panel.call("show_detail", DETAIL_REGISTER_CHECK, _payload_for_detail(DETAIL_REGISTER_CHECK)))
	)
	await get_tree().process_frame
	var blocker: ColorRect = panel.get("_blocker") as ColorRect
	assert_not_null(blocker, "Register detail must expose its blocker")
	if blocker != null:
		assert_eq(blocker.mouse_filter, Control.MOUSE_FILTER_STOP)
		assert_gt(blocker.color.a, 0.4, "Blocking details must still dim the scene")
	assert_eq(InputFocus.current(), InputFocus.CTX_MODAL)


func test_manager_detail_ack_completes_once_and_then_toasts() -> void:
	await _load_store()
	var controller: StoreSessionController = _controller()
	if controller == null:
		return
	EventBus.objective_completed.connect(_on_objective_completed)
	EventBus.toast_requested.connect(_on_toast_requested)
	watch_signals(EventBus)

	controller.on_store_customer_interacted()
	await get_tree().process_frame
	var panel: ModalPanel = _detail_panel(controller)
	assert_true(panel.visible)
	assert_eq((panel.get("_title_label") as Label).text, "Manager Briefing")
	assert_eq((panel.get("_body_label") as RichTextLabel).text, MANAGER_BRIEFING_BODY)
	assert_eq(_visible_button_texts(panel), ["Continue"])
	assert_ne(InputFocus.current(), InputFocus.CTX_MODAL)
	assert_eq(String(controller.current_stage()), "training_talk_manager")
	assert_false(controller.is_objective_completed(&"talk_to_manager"))
	assert_signal_not_emitted(EventBus, "objective_completed")

	_ack(panel)
	_ack(panel)
	await get_tree().process_frame

	assert_false(panel.visible)
	assert_eq(String(controller.current_stage()), "training_check_register")
	assert_true(controller.is_objective_completed(&"talk_to_manager"))
	assert_signal_emit_count(EventBus, "objective_completed", 1)
	assert_signal_emit_count(EventBus, "toast_requested", 1)
	assert_eq(_completed_labels(), [MANAGER_COMPLETE_MESSAGE])
	assert_eq(_toast_labels(), [MANAGER_COMPLETE_MESSAGE])


func test_register_detail_blocks_focus_until_ack() -> void:
	await _load_store()
	var controller: StoreSessionController = _controller()
	if controller == null:
		return
	await _complete_first_minute_detail(controller, DETAIL_MANAGER_BRIEFING)
	EventBus.toast_requested.connect(_on_toast_requested)
	watch_signals(EventBus)

	controller.on_store_register_interacted()
	await get_tree().process_frame
	await get_tree().process_frame
	var panel: ModalPanel = _detail_panel(controller)
	assert_true(panel.visible)
	assert_eq(panel.call("active_detail_id"), DETAIL_REGISTER_CHECK)
	assert_eq((panel.get("_title_label") as Label).text, "Register Check")
	assert_eq((panel.get("_body_label") as RichTextLabel).text, REGISTER_CHECK_BODY)
	assert_eq(_visible_button_texts(panel), ["Register ready"])
	assert_eq(InputFocus.current(), InputFocus.CTX_MODAL)
	assert_eq(String(controller.current_stage()), "training_check_register")

	_send_action(panel, &"interact")
	_send_action(panel, &"ui_cancel")
	await get_tree().process_frame

	assert_true(panel.visible)
	assert_eq(String(controller.current_stage()), "training_check_register")
	assert_false(controller.is_objective_completed(&"check_register"))
	assert_signal_not_emitted(EventBus, "objective_completed")

	_ack(panel)
	_ack(panel)
	await get_tree().process_frame

	assert_false(panel.visible)
	assert_ne(InputFocus.current(), InputFocus.CTX_MODAL)
	assert_eq(String(controller.current_stage()), "training_back_room_inventory")
	assert_true(controller.is_objective_completed(&"check_register"))
	assert_signal_emit_count(EventBus, "objective_completed", 1)
	assert_signal_emit_count(EventBus, "toast_requested", 1)
	assert_eq(_toast_labels(), [REGISTER_COMPLETE_MESSAGE])


func test_backroom_detail_defers_carry_state_until_ack() -> void:
	await _load_store()
	var controller: StoreSessionController = _controller()
	if controller == null:
		return
	await _complete_first_minute_detail(controller, DETAIL_MANAGER_BRIEFING)
	await _complete_first_minute_detail(controller, DETAIL_REGISTER_CHECK)
	watch_signals(EventBus)

	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	var panel: ModalPanel = _detail_panel(controller)
	assert_true(panel.visible)
	assert_eq(panel.call("active_detail_id"), DETAIL_BACKROOM_INVENTORY)
	assert_eq((panel.get("_title_label") as Label).text, "Back Room Inventory")
	var body_text: String = (panel.get("_body_label") as RichTextLabel).text
	assert_eq(body_text, BACKROOM_INVENTORY_BODY)
	assert_false(body_text.contains("Expected"))
	assert_false(body_text.contains("Actual"))
	assert_false(body_text.contains("Discrepancy"))
	assert_false(body_text.contains("SKU"))
	assert_eq(_visible_button_texts(panel), ["Pick up box"])
	assert_ne(InputFocus.current(), InputFocus.CTX_MODAL)
	assert_eq(String(controller.current_stage()), "training_back_room_inventory")
	assert_false(StoreSessionState.carrying_stock)

	_ack(panel)
	_ack(panel)
	await get_tree().process_frame

	assert_false(panel.visible)
	assert_eq(String(controller.current_stage()), "training_stock_shelf")
	assert_true(StoreSessionState.carrying_stock)
	assert_eq(
		int(controller.get("_carried_stock_remaining")),
		StoreSessionController._BACKROOM_DELIVERY_QUANTITY
	)
	assert_signal_emit_count(EventBus, "objective_completed", 1)
	assert_signal_emit_count(EventBus, "toast_requested", 1)
	assert_eq(_completed_labels(), [BACKROOM_COMPLETE_MESSAGE])
	assert_eq(_toast_labels(), [BACKROOM_COMPLETE_MESSAGE])


func _load_store() -> void:
	var scene: PackedScene = load(SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	_root = scene.instantiate() as Node3D
	add_child(_root)
	for _idx: int in range(3):
		await get_tree().process_frame


func _controller() -> StoreSessionController:
	if _root == null:
		return null
	return _root.get_node_or_null("StoreSessionController") as StoreSessionController


func _detail_panel(controller: StoreSessionController) -> ModalPanel:
	return controller.get("_first_minute_detail_panel") as ModalPanel


func _complete_first_minute_detail(
	controller: StoreSessionController, detail_id: StringName
) -> void:
	match detail_id:
		DETAIL_MANAGER_BRIEFING:
			controller.on_store_customer_interacted()
		DETAIL_REGISTER_CHECK:
			controller.on_store_register_interacted()
		DETAIL_BACKROOM_INVENTORY:
			controller.on_store_stockroom_pickup_interacted()
		_:
			return
	await get_tree().process_frame
	var panel: ModalPanel = _detail_panel(controller)
	assert_not_null(panel, "First-minute detail panel must exist")
	if panel == null:
		return
	assert_eq(panel.call("active_detail_id"), detail_id)
	_ack(panel)
	await get_tree().process_frame


func _ack(panel: ModalPanel) -> void:
	var button: Button = panel.get("_confirm_button") as Button
	assert_not_null(button, "First-minute detail panel must expose a confirm button")
	if button != null:
		button.pressed.emit()


func _send_action(panel: ModalPanel, action: StringName) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	panel.call("_unhandled_input", event)


func _payload_for_detail(detail_id: StringName) -> Dictionary:
	match detail_id:
		DETAIL_MANAGER_BRIEFING:
			return {
				"tag": "PREOPENING",
				"title": "Manager Briefing",
				"body": MANAGER_BRIEFING_BODY,
				"confirm_label": "Continue",
			}
		DETAIL_REGISTER_CHECK:
			return {
				"tag": "REGISTER CHECK",
				"title": "Register Check",
				"body": REGISTER_CHECK_BODY,
				"confirm_label": "Register ready",
			}
		DETAIL_BACKROOM_INVENTORY:
			return {
				"tag": "BACK ROOM",
				"title": "Back Room Inventory",
				"body": BACKROOM_INVENTORY_BODY,
				"confirm_label": "Pick up box",
			}
	return {}


func _completed_labels() -> Array[String]:
	var labels: Array[String] = []
	for idx: int in range(get_signal_emit_count(EventBus, "objective_completed")):
		var params: Array = get_signal_parameters(EventBus, "objective_completed", idx)
		labels.append(str(params[1]))
	return labels


func _toast_labels() -> Array[String]:
	var labels: Array[String] = []
	for idx: int in range(get_signal_emit_count(EventBus, "toast_requested")):
		var params: Array = get_signal_parameters(EventBus, "toast_requested", idx)
		labels.append(str(params[0]))
	return labels


func _visible_button_texts(root: Node) -> Array[String]:
	var labels: Array[String] = []
	for button: Button in _buttons_under(root):
		if button.visible and not button.disabled:
			labels.append(button.text)
	return labels


func _buttons_under(root: Node) -> Array[Button]:
	var buttons: Array[Button] = []
	for child: Node in root.get_children():
		if child is Button:
			buttons.append(child as Button)
		buttons.append_array(_buttons_under(child))
	return buttons


func _on_objective_completed(_objective_id: StringName, _label: String) -> void:
	pass


func _on_toast_requested(_message: String, _kind: StringName, _duration: float) -> void:
	pass
