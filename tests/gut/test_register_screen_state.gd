extends GutTest

const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"
const RegisterScreenStateScript: GDScript = preload(
	"res://game/scripts/store_session/register_screen_state.gd"
)

var _root: Node3D = null


func before_each() -> void:
	await _load_store(false)


func after_each() -> void:
	if is_instance_valid(_root):
		_root.free()
	_root = null
	StoreSessionState.reset_new_run()
	InputFocus._reset_for_tests()
	ModalQueue._reset_for_tests()


func test_register_screen_state_defaults_without_runtime_systems() -> void:
	var screen = RegisterScreenStateScript.new()
	add_child(screen)
	await get_tree().process_frame

	assert_eq(screen.current_state(), RegisterScreenStateScript.STATE_INACTIVE)
	assert_eq(screen.current_amount(), 0)
	assert_eq(screen.display_text(), "CLOSED")

	screen.set_state(&"unknown_state", 30)
	assert_eq(screen.current_state(), RegisterScreenStateScript.STATE_INACTIVE)
	assert_eq(screen.display_text(), "CLOSED")

	screen.free()


func test_register_screen_state_is_authored_on_checkout_register() -> void:
	var screen = _screen()
	assert_not_null(screen, "Checkout/Register/RegisterScreenState must exist")
	if screen == null:
		return
	assert_eq(screen.get_script(), RegisterScreenStateScript)
	assert_false(screen is Interactable, "Register screen state must not be an interactable")
	assert_eq(screen.current_state(), RegisterScreenStateScript.STATE_INACTIVE)
	assert_eq(screen.display_text(), "CLOSED")


func test_training_register_check_sets_screen_ready_then_backroom_detour() -> void:
	var controller: StoreSessionController = _controller()
	var screen = _screen()
	if controller == null or screen == null:
		return

	assert_eq(String(controller.current_stage()), "training_talk_manager")
	assert_eq(screen.current_state(), RegisterScreenStateScript.STATE_INACTIVE)

	controller.on_store_customer_interacted()
	await get_tree().process_frame
	assert_eq(String(controller.current_stage()), "training_check_register")
	assert_eq(screen.current_state(), RegisterScreenStateScript.STATE_READY)
	assert_eq(screen.display_text(), "READY")

	controller.on_store_register_interacted()
	await get_tree().process_frame
	assert_eq(String(controller.current_stage()), "training_back_room_inventory")
	assert_eq(screen.current_state(), RegisterScreenStateScript.STATE_BACKROOM)
	assert_eq(screen.display_text(), "BACK\nROOM")


func test_customer_sale_sets_transaction_then_receipt_state() -> void:
	await _load_store(true)
	var controller: StoreSessionController = _controller()
	var screen = _screen()
	if controller == null or screen == null:
		return

	assert_eq(String(controller.current_stage()), "talk_to_customer")
	assert_eq(screen.current_state(), RegisterScreenStateScript.STATE_READY)

	controller.on_store_customer_interacted()
	await get_tree().process_frame
	assert_eq(screen.current_state(), RegisterScreenStateScript.STATE_TRANSACTION)
	assert_eq(screen.current_amount(), 0)
	assert_eq(screen.display_text(), "SALE\nOPEN")
	var decision: DecisionCardPanel = controller.get("_decision_panel") as DecisionCardPanel
	assert_not_null(decision, "Customer interaction must open a decision card")
	if decision == null:
		return
	decision._on_choice_pressed(&"clean_exchange", {"cash": 15})
	await get_tree().process_frame
	assert_eq(screen.current_state(), RegisterScreenStateScript.STATE_TRANSACTION)
	assert_eq(screen.current_amount(), 15)
	assert_eq(screen.display_text(), "SALE\n$15")

	var result: ModalPanel = controller.get("_customer_result_panel") as ModalPanel
	assert_not_null(result, "Customer sale must show a result before settling")
	if result == null:
		return
	var button: Button = result.get("_continue_button") as Button
	assert_not_null(button, "Customer result must expose Continue")
	if button == null:
		return
	button.pressed.emit()
	await get_tree().process_frame
	await get_tree().process_frame

	assert_eq(screen.current_state(), RegisterScreenStateScript.STATE_BACKROOM)
	assert_eq(screen.current_amount(), 0)
	assert_eq(screen.display_text(), "BACK\nROOM")


func test_customer_no_sale_sets_non_sale_state() -> void:
	await _load_store(true)
	var controller: StoreSessionController = _controller()
	var screen = _screen()
	if controller == null or screen == null:
		return

	controller.on_store_customer_interacted()
	await get_tree().process_frame
	var decision: DecisionCardPanel = controller.get("_decision_panel") as DecisionCardPanel
	assert_not_null(decision, "Customer interaction must open a decision card")
	if decision == null:
		return
	decision._on_choice_pressed(&"refuse_return", {"cash": 0})
	await get_tree().process_frame
	assert_eq(screen.current_state(), RegisterScreenStateScript.STATE_NO_SALE)
	assert_eq(screen.current_amount(), 0)
	assert_eq(screen.display_text(), "NO SALE")
	var result: ModalPanel = controller.get("_customer_result_panel") as ModalPanel
	if result == null:
		return
	for _idx: int in range(3):
		if result.visible:
			break
		await get_tree().process_frame
	var button: Button = result.get("_continue_button") as Button
	if button == null:
		return
	button.pressed.emit()
	for _idx: int in range(3):
		if screen.current_state() == RegisterScreenStateScript.STATE_BACKROOM:
			break
		await get_tree().process_frame

	assert_eq(screen.current_state(), RegisterScreenStateScript.STATE_BACKROOM)
	assert_eq(screen.current_amount(), 0)
	assert_eq(screen.display_text(), "BACK\nROOM")


func _load_store(preopening_complete: bool) -> void:
	if is_instance_valid(_root):
		_root.free()
	_root = null
	StoreSessionState.reset_new_run()
	StoreSessionState.preopening_complete = preopening_complete
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


func _screen():
	if _root == null:
		return null
	var screen: Node = _root.get_node_or_null("Checkout/Register/RegisterScreenState")
	if screen == null or screen.get_script() != RegisterScreenStateScript:
		return null
	return screen


func _controller() -> StoreSessionController:
	if _root == null:
		return null
	return _root.get_node_or_null("StoreSessionController") as StoreSessionController
