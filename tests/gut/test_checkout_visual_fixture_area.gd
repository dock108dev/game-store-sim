extends GutTest

const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"
const SUPPORT_TOLERANCE: float = 0.04
const REGISTER_SCREEN_MIN_EMISSION: float = 1.2
const CHECKOUT_SIGN_MAX_WIDTH: float = 1.6
const CUSTOMER_CUE_MAX_AXIS: float = 0.72
const CURATED_COUNTER_DRESSING_PATHS: Array[String] = [
	"ReadabilityProps/CheckoutCounterDressing/ServicePolicyPlaque",
	"ReadabilityProps/CheckoutCounterDressing/TradeCreditTicket",
	"ReadabilityProps/CheckoutCounterDressing/CoinReturnTray",
	"ReadabilityProps/CheckoutCounterDressing/StickerLabelRoll",
	"ReadabilityProps/CheckoutCounterDressing/CounterReceiptPen",
]
const CHECKOUT_FIXTURE_DETAIL_PATHS: Array[String] = [
	"Checkout/CounterCustomerServicePanel",
	"Checkout/CounterCustomerRail",
	"Checkout/StaffToeRecess",
	"Checkout/CheckoutSignSupportLeft",
	"Checkout/CheckoutSignSupportRight",
	"Checkout/PrintedReceiptSlip",
	"Checkout/Register/CheckoutDetails/CardReaderCable",
]
const SIGN_FRAME_PATHS: Array[String] = [
	"Checkout/Register/CheckoutSignBacking",
	"Checkout/Register/CheckoutSignTopTrim",
	"Checkout/Register/CheckoutSignBottomTrim",
	"Checkout/Register/CheckoutSignLeftTrim",
	"Checkout/Register/CheckoutSignRightTrim",
]

var _root: Node3D = null


func before_all() -> void:
	var scene: PackedScene = load(SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene != null:
		_root = scene.instantiate() as Node3D
		add_child(_root)


func after_all() -> void:
	if is_instance_valid(_root):
		_root.free()
	_root = null


func test_checkout_gameplay_anchors_remain_authored() -> void:
	var register: Node = _root.get_node_or_null("checkout_counter/Interactable")
	assert_not_null(register, "Live checkout register interactable must remain authored")
	assert_true(register is RegisterInteractable)
	assert_not_null(
		_root.get_node_or_null("checkout_counter/RegisterStatusIndicator"),
		"Register status indicator must stay separate from visual dressing"
	)
	assert_not_null(_root.get_node_or_null("RegisterArea"))
	for i: int in range(3):
		var marker: Marker3D = _root.get_node_or_null("QueueMarker%d" % (i + 1))
		assert_not_null(marker, "QueueMarker%d must remain authored" % (i + 1))
		if marker != null:
			assert_true(marker.is_in_group("queue_markers"))


func test_open_queue_lane_fixture_preserves_marker_capacity_alignment() -> void:
	var lane: Node = _root.get_node_or_null("FrontLaneQueue/LaneFixture")
	assert_not_null(lane, "Store must instance the reusable open queue lane fixture")
	assert_null(
		_root.get_node_or_null("FrontLaneQueue/QueuePrompt"),
		"Queue lane must not compete with the active interaction prompt"
	)
	var markers: Array[Marker3D] = []
	for i: int in range(RegisterQueue.MAX_QUEUE_SIZE):
		var marker_name: String = "QueueMarker%d" % (i + 1)
		var marker: Marker3D = _root.get_node_or_null(marker_name) as Marker3D
		assert_not_null(marker, "%s must remain authored" % marker_name)
		if marker == null:
			continue
		assert_true(
			marker.is_in_group("queue_markers"),
			"%s must stay in the queue_markers group" % marker_name
		)
		markers.append(marker)
	assert_eq(
		markers.size(),
		RegisterQueue.MAX_QUEUE_SIZE,
		"Authored queue markers must match current queue capacity"
	)
	for i: int in range(markers.size()):
		var mat: MeshInstance3D = _root.get_node_or_null(
			"FrontLaneQueue/LaneFixture/QueueMat%02d" % (i + 1)
		) as MeshInstance3D
		assert_not_null(mat, "Queue floor mat %d must exist" % (i + 1))
		if mat == null:
			continue
		assert_lte(
			mat.global_position.distance_to(markers[i].global_position),
			0.12,
			"Queue mat %d must align with its queue marker" % (i + 1)
		)


func test_checkout_visual_composition_has_counter_register_printer_and_card_reader() -> void:
	for node_path: String in CHECKOUT_FIXTURE_DETAIL_PATHS:
		var detail: MeshInstance3D = _root.get_node_or_null(node_path) as MeshInstance3D
		assert_not_null(detail, "Checkout visual detail missing: %s" % node_path)
		if detail != null:
			assert_not_null(detail.mesh, "%s must carry authored geometry" % node_path)
			assert_false(
				_has_interaction_descendant(detail),
				"%s must stay visual-only and not duplicate register gameplay" % node_path
			)
	for required_path: String in [
		"Checkout/CounterMesh",
		"Checkout/Register/RegisterMesh",
		"Checkout/Register/RegisterScreen",
		"Checkout/Register/CheckoutDetails/CardTerminal",
		"Checkout/ReceiptPrinter",
		"Checkout/PrintedReceiptSlip",
		"Checkout/Register/CheckoutSign",
	]:
		assert_not_null(
			_root.get_node_or_null(required_path),
			"Checkout composition missing required anchor: %s" % required_path
		)


func test_curated_checkout_counter_dressing_is_visible_and_supported() -> void:
	var counter_top: MeshInstance3D = (
		_root.get_node_or_null("Checkout/CounterTop") as MeshInstance3D
	)
	assert_not_null(counter_top, "Checkout/CounterTop must exist")
	if counter_top == null:
		return
	var counter_top_y: float = _box_top_y(counter_top)
	var counter_position: Vector3 = counter_top.global_position
	var counter_size: Vector3 = _box_world_size(counter_top)
	for node_path: String in CURATED_COUNTER_DRESSING_PATHS:
		var prop: MeshInstance3D = _root.get_node_or_null(node_path) as MeshInstance3D
		assert_not_null(prop, "Curated checkout prop missing: %s" % node_path)
		if prop == null:
			continue
		assert_true(_is_visible_in_tree(prop), "%s must be visible in normal gameplay" % node_path)
		assert_not_null(
			prop.get_surface_override_material(0), "%s must carry a material" % node_path
		)
		assert_almost_eq(
			_box_bottom_y(prop),
			counter_top_y,
			SUPPORT_TOLERANCE,
			"%s must rest on the checkout counter top" % node_path
		)
		assert_between(
			prop.global_position.x,
			counter_position.x - counter_size.x * 0.5,
			counter_position.x + counter_size.x * 0.5,
			"%s must stay within the counter width" % node_path
		)
		assert_between(
			prop.global_position.z,
			counter_position.z - counter_size.z * 0.5,
			counter_position.z + counter_size.z * 0.5,
			"%s must stay within the counter depth" % node_path
		)


func test_checkout_sign_is_finished_without_mirrored_back_text() -> void:
	var sign: Label3D = _root.get_node_or_null("Checkout/Register/CheckoutSign") as Label3D
	assert_not_null(sign, "Checkout sign must exist")
	if sign != null:
		assert_false(sign.double_sided, "Checkout sign must not mirror text from behind")
	for node_path: String in SIGN_FRAME_PATHS:
		var frame: MeshInstance3D = _root.get_node_or_null(node_path) as MeshInstance3D
		assert_not_null(frame, "Checkout sign frame missing: %s" % node_path)
		if frame != null:
			assert_not_null(
				frame.get_surface_override_material(0),
				"%s must have a finished material" % node_path
			)
	var backing: MeshInstance3D = (
		_root.get_node_or_null("Checkout/Register/CheckoutSignBacking") as MeshInstance3D
	)
	if backing != null:
		assert_lte(
			_box_world_size(backing).x,
			CHECKOUT_SIGN_MAX_WIDTH,
			"Checkout sign must stay counter-scaled rather than becoming a large panel"
		)


func test_checkout_cue_hierarchy_keeps_sign_and_register_primary() -> void:
	var sign: Label3D = _root.get_node_or_null("Checkout/Register/CheckoutSign") as Label3D
	var screen: MeshInstance3D = (
		_root.get_node_or_null("Checkout/Register/RegisterScreen") as MeshInstance3D
	)
	var customer_mat: MeshInstance3D = (
		_root.get_node_or_null("Checkout/BetaCustomerFloorMat") as MeshInstance3D
	)
	var service_spot: MeshInstance3D = (
		_root.get_node_or_null("ReadabilityProps/CheckoutCounterDressing/CustomerServiceSpotMat")
		as MeshInstance3D
	)
	assert_not_null(sign, "Checkout sign must exist")
	assert_not_null(screen, "Register screen must exist")
	assert_not_null(customer_mat, "Customer standing mark must exist")
	assert_not_null(service_spot, "Customer service spot must exist")
	if sign != null and screen != null:
		assert_gt(
			sign.global_position.y,
			screen.global_position.y + 0.5,
			"Checkout sign must sit above the register glow in the visual hierarchy"
		)
	if screen != null:
		var screen_mat: StandardMaterial3D = screen.get_surface_override_material(0)
		assert_not_null(screen_mat, "Register screen must keep its material")
		if screen_mat != null:
			assert_true(screen_mat.emission_enabled)
			assert_gte(
				screen_mat.emission_energy_multiplier,
				REGISTER_SCREEN_MIN_EMISSION,
				"Register screen glow must remain a primary checkout cue"
			)
	for floor_cue: MeshInstance3D in [customer_mat, service_spot]:
		if floor_cue == null:
			continue
		var size: Vector3 = _mesh_world_size(floor_cue)
		assert_lte(
			maxf(size.x, size.z),
			CUSTOMER_CUE_MAX_AXIS,
			"%s must stay a supporting floor cue, not a dominant panel" % floor_cue.name
		)


func _has_interaction_descendant(node: Node) -> bool:
	if node is Area3D or node is CollisionShape3D:
		return true
	for child: Node in node.get_children():
		if _has_interaction_descendant(child):
			return true
	return false


func _is_visible_in_tree(node: Node3D) -> bool:
	var cursor: Node = node
	while cursor != null and cursor != _root:
		if cursor is Node3D and not (cursor as Node3D).visible:
			return false
		cursor = cursor.get_parent()
	return node.visible


func _box_top_y(node: MeshInstance3D) -> float:
	var size: Vector3 = _box_world_size(node)
	return node.global_position.y + size.y * 0.5


func _box_bottom_y(node: MeshInstance3D) -> float:
	var size: Vector3 = _box_world_size(node)
	return node.global_position.y - size.y * 0.5


func _box_world_size(node: MeshInstance3D) -> Vector3:
	if not (node.mesh is BoxMesh):
		return Vector3.ZERO
	var box: BoxMesh = node.mesh as BoxMesh
	var scale: Vector3 = node.global_transform.basis.get_scale()
	return Vector3(
		box.size.x * absf(scale.x), box.size.y * absf(scale.y), box.size.z * absf(scale.z)
	)


func _mesh_world_size(node: MeshInstance3D) -> Vector3:
	var scale: Vector3 = node.global_transform.basis.get_scale()
	if node.mesh is BoxMesh:
		var box: BoxMesh = node.mesh as BoxMesh
		return Vector3(
			box.size.x * absf(scale.x), box.size.y * absf(scale.y), box.size.z * absf(scale.z)
		)
	if node.mesh is PlaneMesh:
		var plane: PlaneMesh = node.mesh as PlaneMesh
		return Vector3(plane.size.x * absf(scale.x), 0.0, plane.size.y * absf(scale.z))
	return Vector3.ZERO
