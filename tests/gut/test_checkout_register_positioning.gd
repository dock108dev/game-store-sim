extends GutTest

const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"
const CUSTOMER_SIDE_MARGIN: float = 0.08
const SERVICE_SPOT_TOLERANCE: float = 0.08
const QUEUE_MAT_TOLERANCE: float = 0.12
const REGISTER_SCREEN_TRIGGER_MAX_XZ: float = 0.35
const CUSTOMER_REGISTER_MAX_XZ: float = 1.25

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


func test_customer_checkout_target_stays_on_customer_side() -> void:
	var approach: Marker3D = (
		_root.get_node_or_null("CustomerNavConfig/CheckoutApproach") as Marker3D
	)
	var register_area: Area3D = _root.get_node_or_null("RegisterArea") as Area3D
	var service_panel: MeshInstance3D = (
		_root.get_node_or_null("Checkout/CounterCustomerServicePanel") as MeshInstance3D
	)
	var staff_recess: MeshInstance3D = (
		_root.get_node_or_null("Checkout/StaffToeRecess") as MeshInstance3D
	)
	var service_mat: MeshInstance3D = (
		_root.get_node_or_null("Checkout/StoreSessionCustomerFloorMat") as MeshInstance3D
	)
	assert_not_null(approach, "Customer checkout approach must exist")
	assert_not_null(register_area, "RegisterArea must exist")
	assert_not_null(service_panel, "Customer-facing counter panel must exist")
	assert_not_null(staff_recess, "Staff-side toe recess must exist")
	assert_not_null(service_mat, "Customer service floor mat must exist")
	if (
		approach == null
		or register_area == null
		or service_panel == null
		or staff_recess == null
		or service_mat == null
	):
		return
	assert_gt(
		approach.global_position.z,
		service_panel.global_position.z + CUSTOMER_SIDE_MARGIN,
		"CheckoutApproach must stay on the customer side of the counter face"
	)
	assert_gt(
		approach.global_position.z,
		staff_recess.global_position.z + CUSTOMER_SIDE_MARGIN,
		"CheckoutApproach must not drift into staff-side counter space"
	)
	assert_lte(
		_xz_distance(approach.global_position, register_area.global_position),
		SERVICE_SPOT_TOLERANCE,
		"RegisterArea must stay aligned with the customer checkout approach"
	)
	assert_lte(
		_xz_distance(approach.global_position, service_mat.global_position),
		SERVICE_SPOT_TOLERANCE,
		"Customer service floor mat must mark the same checkout stop"
	)


func test_queue_markers_stay_in_visible_customer_lane() -> void:
	var lane: Node = _root.get_node_or_null("FrontLaneQueue/LaneFixture")
	var service_panel: MeshInstance3D = (
		_root.get_node_or_null("Checkout/CounterCustomerServicePanel") as MeshInstance3D
	)
	assert_not_null(lane, "Open queue lane fixture must exist")
	assert_not_null(service_panel, "Customer-facing counter panel must exist")
	if lane == null or service_panel == null:
		return
	for i: int in range(RegisterQueue.MAX_QUEUE_SIZE):
		var marker: Marker3D = _root.get_node_or_null("QueueMarker%d" % (i + 1)) as Marker3D
		var mat: MeshInstance3D = _root.get_node_or_null(
			"FrontLaneQueue/LaneFixture/QueueMat%02d" % (i + 1)
		) as MeshInstance3D
		assert_not_null(marker, "Queue marker %d must exist" % (i + 1))
		assert_not_null(mat, "Queue mat %d must exist" % (i + 1))
		if marker == null or mat == null:
			continue
		assert_gt(
			marker.global_position.z,
			service_panel.global_position.z + CUSTOMER_SIDE_MARGIN,
			"Queue marker %d must remain in customer-side floor space" % (i + 1)
		)
		assert_lte(
			_xz_distance(marker.global_position, mat.global_position),
			QUEUE_MAT_TOLERANCE,
			"Queue mat %d must stay under its gameplay marker" % (i + 1)
		)


func test_store_session_targets_stay_tied_to_register() -> void:
	var customer: Node3D = _root.get_node_or_null("StoreSessionDayOneCustomer") as Node3D
	var trigger: Node3D = _root.get_node_or_null("StoreSessionDayEndTrigger") as Node3D
	var checkout: Node3D = _root.get_node_or_null("Checkout") as Node3D
	var screen: MeshInstance3D = (
		_root.get_node_or_null("Checkout/Register/RegisterScreen") as MeshInstance3D
	)
	var service_mat: MeshInstance3D = (
		_root.get_node_or_null("Checkout/StoreSessionCustomerFloorMat") as MeshInstance3D
	)
	assert_not_null(customer, "Store-session actor must exist")
	assert_not_null(trigger, "Day-end trigger must exist")
	assert_not_null(checkout, "Checkout counter must exist")
	assert_not_null(screen, "Register screen must exist")
	assert_not_null(service_mat, "Customer service floor mat must exist")
	if customer == null or trigger == null or checkout == null or screen == null or service_mat == null:
		return
	assert_lte(
		_xz_distance(customer.global_position, service_mat.global_position),
		SERVICE_SPOT_TOLERANCE,
		"Store-session actor must stand on the visible customer service stop"
	)
	assert_lte(
		_xz_distance(customer.global_position, screen.global_position),
		CUSTOMER_REGISTER_MAX_XZ,
		"Store-session actor must remain visually tied to the register"
	)
	assert_lte(
		_xz_distance(trigger.global_position, screen.global_position),
		REGISTER_SCREEN_TRIGGER_MAX_XZ,
		"Day-end trigger must stay near the visible register screen"
	)
	assert_lte(
		_xz_distance(trigger.global_position, checkout.global_position),
		0.5,
		"Day-end trigger must stay on the checkout counter"
	)


func _xz_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x, a.z).distance_to(Vector2(b.x, b.z))
