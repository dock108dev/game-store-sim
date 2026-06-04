extends GutTest

const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"
const CUE_ROOT: String = "ExpandableStoreShell/OnboardingRouteCues"
const MAX_RECOVERY_SEGMENT: float = 6.80

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


func test_generated_route_root_does_not_emit_floor_geometry() -> void:
	var cue_root: Node3D = _cue_root()
	if cue_root == null:
		return
	assert_eq(
		str(cue_root.get_meta("route_cue_role", "")),
		"fixture_authored_route",
		"Route guidance must be carried by authored fixtures, not floor quads"
	)
	assert_true(bool(cue_root.get_meta("visual_only", false)), "Route root must stay visual-only")
	assert_eq(cue_root.get_child_count(), 0, "Route cue root must not emit floor-wear meshes")
	assert_eq(_count_mesh_descendants(cue_root), 0, "Route cue root must not hide mesh helpers")
	assert_false(_has_interaction_descendant(cue_root), "Route cue root must not carry interactions")


func test_checkout_stockroom_and_shelf_cues_form_recoverable_physical_route() -> void:
	var cue_root: Node3D = _cue_root()
	var checkout: Node3D = _root.get_node_or_null("StoreSessionManager") as Node3D
	var register: Node3D = _root.get_node_or_null("StoreSessionDayEndTrigger") as Node3D
	var stockroom: Node3D = _root.get_node_or_null("StoreSessionBackroomPickup") as Node3D
	var shelf: Node3D = _root.get_node_or_null("StoreSessionRestockShelf") as Node3D
	var stockroom_threshold: Node3D = (
		_root.get_node_or_null("ExpandableStoreShell/StockroomDoorStaffCard") as Node3D
	)
	var checkout_rope: Node3D = (
		_root.get_node_or_null("ExpandableStoreShell/CheckoutQueueRopeFront") as Node3D
	)
	var starter_card: Node3D = (
		_root.get_node_or_null("ExpandableStoreShell/StarterDisplayShelfEdgeCard") as Node3D
	)
	if (
		cue_root == null
		or checkout == null
		or register == null
		or stockroom == null
		or shelf == null
		or stockroom_threshold == null
		or checkout_rope == null
		or starter_card == null
	):
		return

	var route_points: Array[Vector3] = [
		checkout.global_position,
		register.global_position,
		checkout_rope.global_position,
		stockroom_threshold.global_position,
		stockroom.global_position,
		stockroom_threshold.global_position,
		starter_card.global_position,
		shelf.global_position,
	]
	for i: int in range(route_points.size() - 1):
		assert_lte(
			_xz_distance(route_points[i], route_points[i + 1]),
			MAX_RECOVERY_SEGMENT,
			"First-run route cue segment %d must stay visually recoverable" % i
		)


func _cue_root() -> Node3D:
	assert_not_null(_root, "Store scene must instantiate")
	if _root == null:
		return null
	var cue_root: Node3D = _root.get_node_or_null(CUE_ROOT) as Node3D
	assert_not_null(cue_root, "Generated shell must include first-run floor cue root")
	return cue_root


func _has_interaction_descendant(node: Node) -> bool:
	if node is Area3D or node is CollisionShape3D or node is Interactable:
		return true
	for child: Node in node.get_children():
		if _has_interaction_descendant(child):
			return true
	return false


func _count_mesh_descendants(node: Node) -> int:
	var count := 1 if node is MeshInstance3D else 0
	for child: Node in node.get_children():
		count += _count_mesh_descendants(child)
	return count


func _xz_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x, a.z).distance_to(Vector2(b.x, b.z))
