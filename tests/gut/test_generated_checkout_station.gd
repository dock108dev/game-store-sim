extends GutTest

const StoreVisualKitScript: GDScript = preload("res://game/scripts/visuals/store_visual_kit.gd")

const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"
const COUNTER_TOP_Y: float = 0.83
const SUPPORT_TOLERANCE: float = 0.035
const SERVICE_SPOT_TOLERANCE: float = 0.08
const STARTER_CHECKOUT_COMPONENT_PATHS: Dictionary = {
	StoreVisualKitScript.STARTER_CHECKOUT_COUNTER: "CheckoutCounterTop",
	StoreVisualKitScript.STARTER_REGISTER_TERMINAL: "CheckoutKitRegisterMonitor",
	StoreVisualKitScript.STARTER_CARD_READER: "CheckoutKitCardReader",
	StoreVisualKitScript.STARTER_RECEIPT_PRINTER: "CheckoutKitReceiptPrinter",
}
const CHECKOUT_KIT_PROP_PATHS: Array[String] = [
	"CheckoutKitCounterRegister",
	"CheckoutKitRegisterMonitor",
	"CheckoutKitReceiptPrinter",
	"CheckoutKitCardReader",
	"CheckoutKitBarcodeScanner",
	"CheckoutKitPaperStack",
	"CheckoutKitTapeRoll",
	"CheckoutKitManagerClipboard",
]
const CHECKOUT_READINESS_INDICATORS: Array[Dictionary] = [
	{
		"indicator": "CheckoutCashDrawerReadyLight",
		"anchor": "CheckoutRegisterCashSlot",
	},
	{
		"indicator": "CheckoutPrinterReadyLight",
		"anchor": "CheckoutReceiptPrinterBody",
	},
	{
		"indicator": "CheckoutScannerReadyLight",
		"anchor": "CheckoutBarcodeScanner",
	},
]

var _root: Node3D = null
var _saved_state: GameManager.State


func before_each() -> void:
	_saved_state = GameManager.current_state
	GameManager.current_state = GameManager.State.STORE_VIEW
	StoreSessionState.reset_new_run()
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
	GameManager.current_state = _saved_state


func test_generated_checkout_station_has_one_counter_supported_device_cluster() -> void:
	var shell: Node3D = _shell()
	if shell == null:
		return
	assert_eq(
		shell.find_children("CheckoutCounterTop", "MeshInstance3D", true, false).size(),
		1,
		"Generated checkout must expose one clear counter top volume"
	)
	for required: String in [
		"CheckoutCounterTop",
		"CheckoutCustomerSidePanel",
		"CheckoutEmployeeSidePanel",
		"CheckoutLeftSidePanel",
		"CheckoutRightSidePanel",
		"CheckoutRegisterDrawer",
		"CheckoutRegisterScreen",
		"CheckoutReceiptPrinterBody",
		"CheckoutReceiptPaperRoll",
		"CheckoutReceiptSlip",
		"CheckoutCashDrawerReadyLight",
		"CheckoutPrinterReadyLight",
		"CheckoutScannerReadyLight",
		"CheckoutCardReader",
		"CheckoutBarcodeScanner",
		"CheckoutCustomerPaymentDisplay",
		"CheckoutCustomerPaymentDisplayScreen",
		"CheckoutCounterCableRun",
		"CheckoutScannerCable",
		"CheckoutBaggingSurface",
		"CheckoutBagStack",
		"CheckoutManagerFloorMat",
		"CheckoutCustomerFloorMat",
	]:
		var node: Node3D = shell.get_node_or_null(required) as Node3D
		assert_not_null(node, "Generated checkout station detail missing: %s" % required)
		if node != null:
			assert_false(
				_has_interaction_descendant(node),
				"%s must remain a visual-only station detail" % required
			)


func test_generated_checkout_kit_props_are_visual_only_station_details() -> void:
	var shell: Node3D = _shell()
	if shell == null:
		return
	for prop_path: String in CHECKOUT_KIT_PROP_PATHS:
		var prop: Node3D = shell.get_node_or_null(prop_path) as Node3D
		assert_not_null(prop, "Generated checkout kit prop missing: %s" % prop_path)
		if prop == null:
			continue
		assert_true(
			bool(prop.get_meta("checkout_station_visual_only", false)),
			"%s must be marked as checkout visual dressing" % prop_path
		)
		assert_false(
			_has_interaction_descendant(prop),
			"%s must not add register gameplay, collision, or prompts" % prop_path
		)


func test_generated_checkout_station_uses_named_reusable_starter_components() -> void:
	var shell: Node3D = _shell()
	if shell == null:
		return
	var components: Array[Dictionary] = StoreVisualKitScript.starter_checkout_station_components()
	assert_eq(components.size(), STARTER_CHECKOUT_COMPONENT_PATHS.size())
	for component: Dictionary in components:
		var component_id: StringName = component.get("concept_id", &"") as StringName
		var visual_id: StringName = component.get("visual_id", &"") as StringName
		var path: String = str(STARTER_CHECKOUT_COMPONENT_PATHS.get(component_id, ""))
		assert_false(path.is_empty(), "%s must have a generated station node" % component_id)
		assert_true(StoreVisualKitScript.has_visual(visual_id), "%s visual must resolve" % component_id)
		assert_true(
			bool(component.get("day_one_default", false)),
			"%s must stay in the Day 1 checkout kit" % component_id
		)
		if path.is_empty():
			continue
		var node: Node3D = shell.get_node_or_null(path) as Node3D
		assert_not_null(node, "Generated checkout component missing: %s" % path)
		if node == null:
			continue
		assert_eq(node.get_meta("starter_checkout_component_id", &""), component_id)
		assert_eq(node.get_meta("starter_checkout_visual_id", &""), visual_id)
		assert_true(
			bool(node.get_meta("checkout_station_visual_only", false)),
			"%s must be marked visual-only" % path
		)
		assert_false(
			_has_interaction_descendant(node),
			"%s must not own checkout gameplay surfaces" % path
		)


func test_generated_checkout_device_family_keeps_register_screen_primary() -> void:
	var shell: Node3D = _shell()
	if shell == null:
		return
	var drawer_mat: Material = _material(shell, "CheckoutRegisterDrawer")
	var screen_mat: Material = _material(shell, "CheckoutRegisterScreen")
	assert_not_null(drawer_mat, "Register drawer must have the shared dark device material")
	assert_not_null(screen_mat, "Register screen must have the shared screen material")
	for device_path: String in [
		"CheckoutRegisterCashSlot",
		"CheckoutRegisterNeck",
		"CheckoutRegisterScreenBezel",
		"CheckoutRegisterKeypad",
		"CheckoutReceiptPrinterBody",
		"CheckoutCardReader",
		"CheckoutBarcodeScanner",
		"CheckoutCustomerPaymentDisplay",
	]:
		assert_eq(
			_material(shell, device_path),
			drawer_mat,
			"%s must share the drawer's dark device material" % device_path
		)
	assert_eq(
		_material(shell, "CheckoutCustomerPaymentDisplayScreen"),
		screen_mat,
		"Customer display and register screen must share the restrained screen material"
	)


func test_generated_checkout_readiness_indicators_stay_subordinate() -> void:
	var shell: Node3D = _shell()
	if shell == null:
		return
	for cue: Dictionary in CHECKOUT_READINESS_INDICATORS:
		var indicator_path: String = cue["indicator"] as String
		var anchor_path: String = cue["anchor"] as String
		var indicator: MeshInstance3D = shell.get_node_or_null(indicator_path) as MeshInstance3D
		var anchor: Node3D = shell.get_node_or_null(anchor_path) as Node3D
		assert_not_null(indicator, "Generated readiness indicator missing: %s" % indicator_path)
		assert_not_null(anchor, "Generated readiness anchor missing: %s" % anchor_path)
		if indicator == null:
			continue
		assert_true(
			bool(indicator.get_meta("checkout_station_visual_only", false)),
			"%s must be marked visual-only" % indicator_path
		)
		assert_false(
			_has_interaction_descendant(indicator),
			"%s must not add register gameplay or collision" % indicator_path
		)
		assert_lte(
			maxf(_box_size(indicator).x, maxf(_box_size(indicator).y, _box_size(indicator).z)),
			0.08,
			"%s must remain smaller than the physical register target" % indicator_path
		)
		if anchor != null:
			assert_lte(
				_xz_distance(indicator.global_position, anchor.global_position),
				0.22,
				"%s must sit on its checkout device" % indicator_path
			)


func test_generated_checkout_props_stay_on_counter_and_define_both_sides() -> void:
	var shell: Node3D = _shell()
	if shell == null:
		return
	var counter_top: MeshInstance3D = shell.get_node_or_null("CheckoutCounterTop") as MeshInstance3D
	assert_not_null(counter_top, "Generated checkout counter top must exist")
	if counter_top == null:
		return
	var counter_size: Vector3 = _box_size(counter_top)
	for prop_path: String in [
		"CheckoutReceiptPrinterBody",
		"CheckoutCardReader",
		"CheckoutBarcodeScanner",
		"CheckoutCounterCableRun",
		"CheckoutScannerCable",
		"CheckoutBaggingSurface",
	]:
		var prop: MeshInstance3D = shell.get_node_or_null(prop_path) as MeshInstance3D
		assert_not_null(prop, "Counter-supported prop missing: %s" % prop_path)
		if prop == null:
			continue
		assert_almost_eq(_box_bottom_y(prop), COUNTER_TOP_Y, SUPPORT_TOLERANCE, prop_path)
		assert_between(
			prop.position.x,
			counter_top.position.x - counter_size.x * 0.5,
			counter_top.position.x + counter_size.x * 0.5,
			"%s must stay within the counter width" % prop_path
		)
		assert_between(
			prop.position.z,
			counter_top.position.z - counter_size.z * 0.5,
			counter_top.position.z + counter_size.z * 0.5,
			"%s must stay within the counter depth" % prop_path
		)
	var manager_mat: Node3D = shell.get_node_or_null("CheckoutManagerFloorMat") as Node3D
	var customer_mat: Node3D = shell.get_node_or_null("CheckoutCustomerFloorMat") as Node3D
	assert_not_null(manager_mat, "Manager side floor mat must exist")
	assert_not_null(customer_mat, "Customer side floor mat must exist")
	if manager_mat != null and customer_mat != null:
		assert_lt(manager_mat.position.z, counter_top.position.z)
		assert_gt(customer_mat.position.z, counter_top.position.z)


func test_generated_checkout_service_stop_anchors_actor_prompt_and_queue() -> void:
	var shell: Node3D = _shell()
	if shell == null:
		return
	var actor: Node3D = _root.get_node_or_null("StoreSessionDayOneCustomer") as Node3D
	var prompt_owner: Interactable = (
		_root.get_node_or_null("StoreSessionDayOneCustomer/Interactable") as Interactable
	)
	var customer_mat: Node3D = shell.get_node_or_null("CheckoutCustomerFloorMat") as Node3D
	var service_mat: Node3D = (
		_root.get_node_or_null("Checkout/StoreSessionCustomerFloorMat") as Node3D
	)
	var queue_head: Marker3D = _root.get_node_or_null("QueueMarker1") as Marker3D
	var checkout: Node3D = _root.get_node_or_null("checkout_counter") as Node3D
	assert_not_null(actor, "Shared manager/customer actor must exist")
	assert_not_null(prompt_owner, "Shared actor prompt owner must remain on the actor")
	assert_not_null(customer_mat, "Generated customer-side service mat must exist")
	assert_not_null(service_mat, "Authored service mat must remain aligned for reset/exit flow")
	assert_not_null(queue_head, "Queue head marker must exist")
	assert_not_null(checkout, "Checkout gameplay anchor must exist")
	if (
		actor == null
		or prompt_owner == null
		or customer_mat == null
		or service_mat == null
		or queue_head == null
		or checkout == null
	):
		return
	assert_eq(
		prompt_owner.get_parent(),
		actor,
		"Manager/customer prompt must stay on the shared actor"
	)
	assert_lte(
		_xz_distance(actor.global_position, customer_mat.global_position),
		SERVICE_SPOT_TOLERANCE,
		"Generated service mat must sit under the shared actor"
	)
	assert_lte(
		_xz_distance(actor.global_position, service_mat.global_position),
		SERVICE_SPOT_TOLERANCE,
		"Authored service mat must follow the compact checkout station"
	)
	assert_lte(
		_xz_distance(actor.global_position, queue_head.global_position),
		SERVICE_SPOT_TOLERANCE,
		"Queue head must share the customer-side service stop"
	)
	assert_gt(
		actor.global_position.z,
		checkout.global_position.z,
		"Shared actor must remain on the customer side of the checkout station"
	)


func _shell() -> Node3D:
	assert_not_null(_root, "Store scene must instantiate")
	if _root == null:
		return null
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	assert_not_null(shell, "Boot must generate the expandable store shell")
	return shell


func _has_interaction_descendant(node: Node) -> bool:
	if (
		node is Area3D
		or node is CollisionShape3D
		or node is PhysicsBody3D
		or node is NavigationObstacle3D
		or node is Interactable
	):
		return true
	for child: Node in node.get_children():
		if _has_interaction_descendant(child):
			return true
	return false


func _material(parent: Node, node_path: String) -> Material:
	var mesh: MeshInstance3D = parent.get_node_or_null(node_path) as MeshInstance3D
	if mesh == null:
		return null
	return mesh.material_override


func _box_size(node: MeshInstance3D) -> Vector3:
	var box: BoxMesh = node.mesh as BoxMesh
	if box == null:
		return Vector3.ZERO
	return box.size


func _box_bottom_y(node: MeshInstance3D) -> float:
	return node.position.y - _box_size(node).y * 0.5


func _xz_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x, a.z).distance_to(Vector2(b.x, b.z))
