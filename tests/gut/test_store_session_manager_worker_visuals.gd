extends GutTest

const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"
const WORKER_ONLY_PARTS: Array[String] = [
	"ApronPanel",
	"Badge",
	"NameTag",
	"Lanyard",
	"KeyRing",
	"KeyA",
	"KeyB",
	"Clipboard",
	"ClipboardPaper",
]

var _root: Node3D


func before_each() -> void:
	StoreSessionState.reset_new_run()
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


func after_each() -> void:
	ModalQueue._reset_for_tests()
	InputFocus._reset_for_tests()
	if is_instance_valid(_root):
		_root.free()
	_root = null
	StoreSessionState.reset_new_run()


func test_manager_worker_visuals_include_readable_staff_cues() -> void:
	var proxy: Node3D = _manager_proxy()
	assert_not_null(proxy, "Manager proxy must exist")
	if proxy == null:
		return
	for part_name: String in [
		"Body",
		"Head",
		"HairCap",
		"ArmLeft",
		"ArmRight",
		"ApronPanel",
		"Badge",
		"NameTag",
		"KeyRing",
		"KeyA",
		"KeyB",
		"Clipboard",
		"ClipboardPaper",
	]:
		var part: MeshInstance3D = proxy.get_node_or_null(part_name) as MeshInstance3D
		assert_not_null(part, "Manager worker cue missing: %s" % part_name)
		if part == null:
			continue
		assert_true(part.visible, "%s must be visible during the manager briefing" % part_name)


func test_manager_worker_visuals_are_visual_only() -> void:
	var proxy: Node3D = _manager_proxy()
	assert_not_null(proxy, "Manager proxy must exist")
	if proxy == null:
		return
	assert_false(
		_has_interaction_descendant(proxy),
		"Manager worker cues must not add prompts, collision, or navigation blockers"
	)
	for part_name: String in WORKER_ONLY_PARTS:
		var part: Node = proxy.get_node_or_null(part_name)
		assert_not_null(part, "Worker cue must exist: %s" % part_name)
		if part != null:
			assert_null(part.get_script(), "%s must not run behavior scripts" % part_name)


func test_customer_proxy_does_not_inherit_worker_only_cues() -> void:
	var customer_proxy: Node3D = _customer_proxy()
	assert_not_null(customer_proxy, "Customer proxy must exist")
	if customer_proxy == null:
		return
	for part_name: String in WORKER_ONLY_PARTS:
		var part: Node3D = customer_proxy.get_node_or_null(part_name) as Node3D
		assert_not_null(part, "Customer proxy should own configurable part %s" % part_name)
		if part != null:
			assert_false(part.visible, "%s must stay hidden on the customer actor" % part_name)


func test_manager_worker_materials_separate_body_badge_keys_and_clipboard() -> void:
	var proxy: Node3D = _manager_proxy()
	assert_not_null(proxy, "Manager proxy must exist")
	if proxy == null:
		return
	var body_color: Color = _part_color(proxy, "Body")
	var apron_color: Color = _part_color(proxy, "ApronPanel")
	var badge_color: Color = _part_color(proxy, "Badge")
	var key_color: Color = _part_color(proxy, "KeyA")
	var clipboard_color: Color = _part_color(proxy, "Clipboard")
	var paper_color: Color = _part_color(proxy, "ClipboardPaper")

	assert_gt(_color_distance(body_color, apron_color), 0.12, "Apron must separate from torso")
	assert_gt(_color_distance(apron_color, badge_color), 0.55, "Badge must read against apron")
	assert_gt(_color_distance(apron_color, key_color), 0.45, "Keys must read against apron")
	assert_gt(
		_color_distance(clipboard_color, paper_color),
		0.55,
		"Clipboard paper must read against the board"
	)


func test_manager_worker_cues_face_customer_service_spot() -> void:
	var manager: Node3D = _root.get_node_or_null("StoreSessionManager") as Node3D
	var service_spot: Node3D = _root.get_node_or_null("Checkout/StoreSessionCustomerFloorMat") as Node3D
	var proxy: Node3D = _manager_proxy()
	assert_not_null(manager, "Manager actor must exist")
	assert_not_null(service_spot, "Customer service spot must exist")
	assert_not_null(proxy, "Manager proxy must exist")
	if manager == null or service_spot == null or proxy == null:
		return

	assert_gt(
		manager.to_local(service_spot.global_position).z,
		0.0,
		"Manager front must face the customer service spot"
	)
	for part_name: String in ["ApronPanel", "Badge", "KeyA", "Clipboard"]:
		var part: Node3D = proxy.get_node_or_null(part_name) as Node3D
		assert_not_null(part, "Facing cue missing: %s" % part_name)
		if part != null:
			assert_gt(part.position.z, 0.0, "%s must sit on the service-facing side" % part_name)


func _manager_proxy() -> Node3D:
	if _root == null:
		return null
	return _root.get_node_or_null("StoreSessionManager/ManagerProxy") as Node3D


func _customer_proxy() -> Node3D:
	if _root == null:
		return null
	return _root.get_node_or_null("StoreSessionDayOneCustomer/CustomerProxy") as Node3D


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


func _part_color(proxy: Node, part_name: String) -> Color:
	var part: MeshInstance3D = proxy.get_node_or_null(part_name) as MeshInstance3D
	if part == null:
		return Color.BLACK
	var material: StandardMaterial3D = part.material_override as StandardMaterial3D
	if material == null:
		return Color.BLACK
	return material.albedo_color


func _color_distance(a: Color, b: Color) -> float:
	return absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b)
