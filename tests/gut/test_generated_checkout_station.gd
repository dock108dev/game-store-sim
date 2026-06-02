extends GutTest

const StoreVisualKitScript: GDScript = preload(
	"res://game/scripts/visuals/store_visual_kit.gd"
)
const StoreVisualLayoutScript: GDScript = preload(
	"res://game/scripts/visuals/store_visual_layout.gd"
)
const VisualValueUtilScript: GDScript = preload("res://game/scripts/visuals/visual_value_util.gd")

const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"
const COUNTER_TOP_Y: float = 0.83
const SUPPORT_TOLERANCE: float = 0.035
const SERVICE_SPOT_TOLERANCE: float = 0.08
const STARTER_CHECKOUT_COMPONENT_PATHS: Dictionary = {
	StoreVisualKitScript.STARTER_CHECKOUT_COUNTER: "CheckoutCounterTop",
	StoreVisualKitScript.STARTER_REGISTER_TERMINAL: "CheckoutRegisterScreen",
	StoreVisualKitScript.STARTER_CARD_READER: "CheckoutCardReader",
	StoreVisualKitScript.STARTER_RECEIPT_PRINTER: "CheckoutReceiptPrinterBody",
}
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
const CHECKOUT_STATION_DETAIL_PATHS: Array[String] = [
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
	"CheckoutCounterPaperStack",
	"CheckoutManagerFloorMat",
	"CheckoutCustomerFloorMat",
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
	for required: String in CHECKOUT_STATION_DETAIL_PATHS:
		var node: Node3D = shell.get_node_or_null(required) as Node3D
		assert_not_null(node, "Generated checkout station detail missing: %s" % required)
		if node != null:
			assert_true(
				bool(node.get_meta("checkout_station_visual_only", false)),
				"%s must be marked as generated visual-only checkout dressing" % required
			)
			assert_false(
				_has_interaction_descendant(node),
				"%s must remain a visual-only station detail" % required
			)


func test_generated_checkout_station_sits_front_right_and_faces_service_lane() -> void:
	var shell: Node3D = _shell()
	if shell == null:
		return
	var counter_top: MeshInstance3D = shell.get_node_or_null("CheckoutCounterTop") as MeshInstance3D
	var customer_panel: MeshInstance3D = (
		shell.get_node_or_null("CheckoutCustomerSidePanel") as MeshInstance3D
	)
	var employee_panel: MeshInstance3D = (
		shell.get_node_or_null("CheckoutEmployeeSidePanel") as MeshInstance3D
	)
	var customer_mat: Node3D = shell.get_node_or_null("CheckoutCustomerFloorMat") as Node3D
	var queue_head: Marker3D = _root.get_node_or_null("QueueMarker1") as Marker3D
	assert_not_null(counter_top, "Generated checkout counter top must exist")
	assert_not_null(customer_panel, "Generated checkout must keep a customer-side face")
	assert_not_null(employee_panel, "Generated checkout must keep a staff-side face")
	assert_not_null(customer_mat, "Generated customer-side service mat must exist")
	assert_not_null(queue_head, "Queue head must exist")
	if (
		counter_top == null
		or customer_panel == null
		or employee_panel == null
		or customer_mat == null
		or queue_head == null
	):
		return
	assert_gt(counter_top.global_position.x, 0.0, "Checkout station must sit on store right")
	assert_gt(counter_top.global_position.z, 0.0, "Checkout station must sit toward the front")
	assert_gt(
		customer_panel.global_position.z,
		counter_top.global_position.z,
		"Customer side must face the front service lane"
	)
	assert_lt(
		employee_panel.global_position.z,
		counter_top.global_position.z,
		"Staff side must stay behind the customer-facing counter face"
	)
	assert_gt(
		customer_mat.global_position.z,
		counter_top.global_position.z,
		"Customer service mat must be on the service-lane side"
	)
	assert_lte(
		_xz_distance(customer_mat.global_position, queue_head.global_position),
		SERVICE_SPOT_TOLERANCE,
		"Queue head must align to the customer-side service lane"
	)


func test_generated_checkout_component_nodes_are_visual_only_station_details() -> void:
	var shell: Node3D = _shell()
	if shell == null:
		return
	for prop_path: String in STARTER_CHECKOUT_COMPONENT_PATHS.values():
		var prop: Node3D = shell.get_node_or_null(prop_path) as Node3D
		assert_not_null(prop, "Generated checkout component node missing: %s" % prop_path)
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
	var screen: MeshInstance3D = shell.get_node_or_null("CheckoutRegisterScreen") as MeshInstance3D
	var printer: MeshInstance3D = (
		shell.get_node_or_null("CheckoutReceiptPrinterBody") as MeshInstance3D
	)
	var reader: MeshInstance3D = shell.get_node_or_null("CheckoutCardReader") as MeshInstance3D
	var customer_display: MeshInstance3D = (
		shell.get_node_or_null("CheckoutCustomerPaymentDisplay") as MeshInstance3D
	)
	if screen != null and printer != null and reader != null and customer_display != null:
		var screen_area: float = _box_size(screen).x * _box_size(screen).y
		assert_gt(
			screen_area,
			_box_size(printer).x * _box_size(printer).y,
			"Register screen must remain visually larger than the receipt printer"
		)
		assert_gt(
			screen_area,
			_box_size(reader).x * _box_size(reader).y,
			"Register screen must remain visually larger than the card reader"
		)
		assert_gt(
			screen_area,
			_box_size(customer_display).x * _box_size(customer_display).y,
			"Customer display must stay subordinate to the register screen"
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
		"CheckoutBaggingSurface",
		"CheckoutBagStack",
		"CheckoutCounterPaperStack",
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


func test_generated_checkout_details_stay_inside_contract_footprints_and_face_service_sides(
) -> void:
	var shell: Node3D = _shell()
	if shell == null:
		return
	var station: Dictionary = _checkout_station_contract()
	var counter_top: MeshInstance3D = shell.get_node_or_null("CheckoutCounterTop") as MeshInstance3D
	assert_false(station.is_empty(), "Checkout station contract must be available")
	assert_not_null(counter_top, "Generated checkout counter top must exist")
	if station.is_empty() or counter_top == null:
		return
	for raw_device: Variant in station.get("device_footprints", []):
		var device: Dictionary = raw_device as Dictionary
		var required_nodes: Array = device.get("required_nodes", []) as Array
		var expected: Vector3 = VisualValueUtilScript.vector3_from_exact_array(
			device.get("position", []), Vector3.ZERO
		)
		var footprint_size: Vector3 = VisualValueUtilScript.vector3_from_exact_array(
			(device.get("footprint", {}) as Dictionary).get("size", []), Vector3.ZERO
		)
		var facing_side: String = str(device.get("facing_side", ""))
		for raw_path: Variant in required_nodes:
			var path: String = str(raw_path)
			var node_name: String = path.get_file()
			var prop: Node3D = shell.get_node_or_null(node_name) as Node3D
			assert_not_null(prop, "Contract node missing from generated shell: %s" % path)
			if prop == null:
				continue
			assert_lte(absf(prop.position.x - expected.x), footprint_size.x * 0.5, path)
			assert_lte(absf(prop.position.z - expected.z), footprint_size.z * 0.5, path)
			if facing_side == "staff":
				assert_lt(prop.position.z, counter_top.position.z, "%s must face the staff side" % path)
			elif facing_side == "customer":
				assert_gt(
					prop.position.z, counter_top.position.z, "%s must face the customer side" % path
				)


func test_generated_checkout_clutter_stays_inside_bounded_counter_cluster() -> void:
	var shell: Node3D = _shell()
	if shell == null:
		return
	var station: Dictionary = _checkout_station_contract()
	var clutter: Dictionary = station.get("clutter_cluster", {}) as Dictionary
	assert_false(clutter.is_empty(), "Checkout clutter contract must be available")
	if clutter.is_empty():
		return
	var expected: Vector3 = VisualValueUtilScript.vector3_from_exact_array(
		clutter.get("position", []), Vector3.ZERO
	)
	var footprint_size: Vector3 = VisualValueUtilScript.vector3_from_exact_array(
		(clutter.get("footprint", {}) as Dictionary).get("size", []), Vector3.ZERO
	)
	var checked_count: int = 0
	for raw_path: Variant in clutter.get("required_nodes", []):
		var path: String = str(raw_path)
		var node_name: String = path.get_file()
		var prop: MeshInstance3D = shell.get_node_or_null(node_name) as MeshInstance3D
		assert_not_null(prop, "Required clutter node missing: %s" % path)
		if prop == null:
			continue
		checked_count += 1
		assert_lte(absf(prop.position.x - expected.x), footprint_size.x * 0.5, path)
		assert_lte(absf(prop.position.z - expected.z), footprint_size.z * 0.5, path)
		assert_true(
			bool(prop.get_meta("checkout_station_visual_only", false)),
			"%s must stay generated visual-only clutter" % path
		)
	for raw_path: Variant in clutter.get("allowed_optional_nodes", []):
		var path: String = str(raw_path)
		var prop: MeshInstance3D = shell.get_node_or_null(path.get_file()) as MeshInstance3D
		if prop == null:
			continue
		checked_count += 1
		assert_lte(absf(prop.position.x - expected.x), footprint_size.x * 0.5, path)
		assert_lte(absf(prop.position.z - expected.z), footprint_size.z * 0.5, path)
	assert_gte(checked_count, 4, "Generated checkout clutter cluster must be bounded")


func test_generated_checkout_clutter_does_not_create_single_countertop_noise_band() -> void:
	var shell: Node3D = _shell()
	if shell == null:
		return
	var secondary_paths: Array[String] = [
		"CheckoutCounterCableRun",
		"CheckoutScannerCable",
		"CheckoutBaggingSurface",
		"CheckoutBagStack",
		"CheckoutBarcodeScanner",
		"CheckoutCustomerPaymentDisplay",
		"CheckoutCounterPaperStack",
	]
	var min_top_y: float = INF
	var max_top_y: float = -INF
	for path: String in secondary_paths:
		var prop: MeshInstance3D = shell.get_node_or_null(path) as MeshInstance3D
		assert_not_null(prop, "Secondary checkout detail missing: %s" % path)
		if prop == null:
			continue
		var top_y: float = prop.position.y + _box_size(prop).y * 0.5
		min_top_y = minf(min_top_y, top_y)
		max_top_y = maxf(max_top_y, top_y)
	assert_gte(
		max_top_y - min_top_y,
		0.15,
		"Secondary checkout details must not form one same-height band"
	)


func test_generated_checkout_station_does_not_displace_active_register_anchor() -> void:
	var shell: Node3D = _shell()
	if shell == null:
		return
	var register: Interactable = (
		_root.get_node_or_null("checkout_counter/Interactable") as Interactable
	)
	assert_not_null(register, "Active register prompt must remain authored")
	if register == null:
		return
	assert_eq(register.get_parent().name, &"checkout_counter")
	assert_false(_is_ancestor(shell, register), "Generated shell must not own the register prompt")
	for detail_path: String in CHECKOUT_STATION_DETAIL_PATHS:
		var detail: Node3D = shell.get_node_or_null(detail_path) as Node3D
		if detail == null or detail_path == "CheckoutCounterTop":
			continue
		assert_gt(
			detail.global_position.distance_to(register.global_position),
			0.16,
			"%s must not sit on the active register prompt origin" % detail_path
		)

func test_generated_checkout_manager_prompt_stands_on_employee_side() -> void:
	var shell: Node3D = _shell()
	if shell == null:
		return
	var manager: Node3D = _root.get_node_or_null("StoreSessionManager") as Node3D
	var prompt_owner: Interactable = (
		_root.get_node_or_null("StoreSessionManager/Interactable") as Interactable
	)
	var manager_mat: Node3D = shell.get_node_or_null("CheckoutManagerFloorMat") as Node3D
	var checkout: Node3D = _root.get_node_or_null("checkout_counter") as Node3D
	assert_not_null(manager, "Manager actor must exist")
	assert_not_null(prompt_owner, "Manager prompt owner must remain on the manager actor")
	assert_not_null(manager_mat, "Generated manager-side service mat must exist")
	assert_not_null(checkout, "Checkout gameplay anchor must exist")
	if manager == null or prompt_owner == null or manager_mat == null or checkout == null:
		return
	assert_eq(prompt_owner.get_parent(), manager, "Manager prompt must stay on the manager actor")
	assert_lte(
		_xz_distance(manager.global_position, manager_mat.global_position),
		SERVICE_SPOT_TOLERANCE,
		"Manager actor must stand on the staff-side checkout mat"
	)
	assert_lt(
		manager.global_position.z,
		checkout.global_position.z,
		"Manager actor must remain on the staff side of the checkout station"
	)


func test_generated_checkout_customer_service_stop_anchors_customer_actor_and_queue() -> void:
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
	assert_not_null(actor, "Customer actor must exist")
	assert_not_null(prompt_owner, "Customer prompt owner must remain on the customer actor")
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
		"Customer prompt must stay on the customer actor"
	)
	assert_lte(
		_xz_distance(actor.global_position, customer_mat.global_position),
		SERVICE_SPOT_TOLERANCE,
		"Generated service mat must sit under the customer actor"
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
		"Customer actor must remain on the customer side of the checkout station"
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

func _checkout_station_contract() -> Dictionary:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	var contract: Dictionary = catalog.call(
		"get_physical_contract", StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT
	)
	for raw_station: Variant in contract.get("checkout_station_contracts", []):
		if raw_station is not Dictionary:
			continue
		var station: Dictionary = raw_station as Dictionary
		if str(station.get("station_id", "")) == "front_right_checkout_station":
			return station
	return {}

func _is_ancestor(candidate: Node, node: Node) -> bool:
	var current: Node = node.get_parent()
	while current != null:
		if current == candidate:
			return true
		current = current.get_parent()
	return false
