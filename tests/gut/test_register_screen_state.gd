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
	assert_eq(screen.current_amount(), 0)
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
	var receipt: Node = _root.get_node_or_null("Checkout/PrintedReceiptSlip")
	assert_not_null(receipt, "Checkout must own a visual receipt slip")
	if receipt != null:
		assert_false(receipt is Interactable, "Receipt slip must stay visual-only")


func test_register_screen_visual_contract_for_all_states() -> void:
	var fixture: Dictionary = _register_screen_fixture()
	add_child(fixture.get("root") as Node)
	await get_tree().process_frame
	var screen: RegisterScreenState = fixture.get("screen") as RegisterScreenState
	var label: Label3D = fixture.get("label") as Label3D
	var receipt: Node = fixture.get("receipt") as Node

	_assert_screen_visual(
		fixture,
		RegisterScreenStateScript.STATE_INACTIVE,
		0,
		"CLOSED",
		RegisterScreenStateScript.DISPLAY_COLOR_INACTIVE,
		0.25,
		false
	)
	assert_eq(label.font_size, RegisterScreenStateScript.DISPLAY_FONT_SIZE)
	assert_eq(label.outline_size, RegisterScreenStateScript.DISPLAY_OUTLINE_SIZE)

	screen.set_state(RegisterScreenStateScript.STATE_READY)
	_assert_screen_visual(
		fixture,
		RegisterScreenStateScript.STATE_READY,
		0,
		"REGISTER\nREADY",
		RegisterScreenStateScript.DISPLAY_COLOR_READY,
		1.0,
		false
	)

	screen.set_state(RegisterScreenStateScript.STATE_TRANSACTION)
	_assert_screen_visual(
		fixture,
		RegisterScreenStateScript.STATE_TRANSACTION,
		0,
		"TRANS\nREADY",
		RegisterScreenStateScript.DISPLAY_COLOR_TRANSACTION,
		1.35,
		false
	)

	screen.show_transaction(15)
	_assert_screen_visual(
		fixture,
		RegisterScreenStateScript.STATE_TRANSACTION,
		15,
		"SALE\n$15",
		RegisterScreenStateScript.DISPLAY_COLOR_TRANSACTION,
		1.35,
		false
	)

	screen.settle(15)
	_assert_screen_visual(
		fixture,
		RegisterScreenStateScript.STATE_SETTLED,
		15,
		"RECEIPT\n$15",
		RegisterScreenStateScript.DISPLAY_COLOR_SETTLED,
		1.55,
		true
	)
	assert_false(receipt is Interactable, "Receipt feedback must not become an interactable")

	screen.settle(0)
	_assert_screen_visual(
		fixture,
		RegisterScreenStateScript.STATE_NO_SALE,
		0,
		"NO SALE",
		RegisterScreenStateScript.DISPLAY_COLOR_NO_SALE,
		0.85,
		false
	)

	screen.set_state(RegisterScreenStateScript.STATE_BACKROOM)
	_assert_screen_visual(
		fixture,
		RegisterScreenStateScript.STATE_BACKROOM,
		0,
		"BACK\nROOM",
		RegisterScreenStateScript.DISPLAY_COLOR_ROUTING,
		0.65,
		false
	)

	screen.set_state(RegisterScreenStateScript.STATE_STOCKING)
	_assert_screen_visual(
		fixture,
		RegisterScreenStateScript.STATE_STOCKING,
		0,
		"STOCK\nTABLE",
		RegisterScreenStateScript.DISPLAY_COLOR_ROUTING,
		0.65,
		false
	)

	screen.set_state(RegisterScreenStateScript.STATE_CLOSE_READY)
	_assert_screen_visual(
		fixture,
		RegisterScreenStateScript.STATE_CLOSE_READY,
		0,
		"CLOSE\nDAY",
		RegisterScreenStateScript.DISPLAY_COLOR_CLOSE_READY,
		1.45,
		false
	)

	screen.set_state(&"missing_state", 90)
	_assert_screen_visual(
		fixture,
		RegisterScreenStateScript.STATE_INACTIVE,
		0,
		"CLOSED",
		RegisterScreenStateScript.DISPLAY_COLOR_INACTIVE,
		0.25,
		false
	)

	(fixture.get("root") as Node).free()


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
	assert_eq(screen.display_text(), "REGISTER\nREADY")

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
	assert_eq(screen.display_text(), "TRANS\nREADY")
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


func _register_screen_fixture() -> Dictionary:
	var checkout := Node3D.new()
	checkout.name = "Checkout"
	var register := Node3D.new()
	register.name = "Register"
	checkout.add_child(register)
	var mesh := MeshInstance3D.new()
	mesh.name = "RegisterScreen"
	register.add_child(mesh)
	var screen: RegisterScreenState = RegisterScreenStateScript.new() as RegisterScreenState
	screen.name = "RegisterScreenState"
	register.add_child(screen)
	var label := Label3D.new()
	label.name = "StateLabel"
	screen.add_child(label)
	var receipt := MeshInstance3D.new()
	receipt.name = "PrintedReceiptSlip"
	checkout.add_child(receipt)
	return {
		"root": checkout,
		"screen": screen,
		"label": label,
		"mesh": mesh,
		"receipt": receipt,
	}


func _assert_screen_visual(
	fixture: Dictionary,
	expected_state: StringName,
	expected_amount: int,
	expected_text: String,
	expected_color: Color,
	expected_energy: float,
	expected_receipt_visible: bool
) -> void:
	var screen: RegisterScreenState = fixture.get("screen") as RegisterScreenState
	var label: Label3D = fixture.get("label") as Label3D
	var mesh: MeshInstance3D = fixture.get("mesh") as MeshInstance3D
	var receipt: MeshInstance3D = fixture.get("receipt") as MeshInstance3D
	assert_not_null(screen)
	assert_not_null(label)
	assert_not_null(mesh)
	assert_not_null(receipt)
	if screen == null or label == null or mesh == null or receipt == null:
		return
	assert_eq(screen.current_state(), expected_state)
	assert_eq(screen.current_amount(), expected_amount)
	assert_eq(screen.display_text(), expected_text)
	assert_eq(label.text, expected_text)
	assert_eq(label.modulate, expected_color)
	assert_eq(receipt.visible, expected_receipt_visible)
	var material: StandardMaterial3D = mesh.material_override as StandardMaterial3D
	assert_not_null(material, "Register screen must own a state material override")
	if material == null:
		return
	var expected_albedo := Color(
		expected_color.r * 0.35,
		expected_color.g * 0.35,
		expected_color.b * 0.35,
		1.0
	)
	assert_true(material.emission_enabled)
	assert_eq(material.emission, expected_color)
	assert_true(material.albedo_color.is_equal_approx(expected_albedo))
	assert_almost_eq(material.emission_energy_multiplier, expected_energy, 0.001)


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
