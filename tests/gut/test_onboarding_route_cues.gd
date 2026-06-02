extends GutTest

const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"
const CUE_ROOT: String = "ExpandableStoreShell/OnboardingRouteCues"
const MAX_CUE_AXIS: float = 0.82
const MAX_CUE_ALPHA: float = 0.42
const MAX_RECOVERY_SEGMENT: float = 3.20

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


func test_generated_route_cues_are_subtle_floor_wear_not_interactables() -> void:
	var cue_root: Node3D = _cue_root()
	if cue_root == null:
		return
	assert_eq(cue_root.get_child_count(), 10, "First-run recovery cues should stay sparse")
	for cue: Node in cue_root.get_children():
		var mesh_instance: MeshInstance3D = cue as MeshInstance3D
		assert_not_null(mesh_instance, "%s must be a visual floor cue" % cue.name)
		if mesh_instance == null:
			continue
		assert_eq(str(mesh_instance.get_meta("route_cue_role", "")), "floor_wear")
		assert_false(
			_has_interaction_descendant(mesh_instance), "%s must stay visual-only" % cue.name
		)
		assert_lte(
			_longest_box_axis(mesh_instance),
			MAX_CUE_AXIS,
			"%s must not read as route paint" % cue.name
		)
		assert_lte(
			_material_alpha(mesh_instance),
			MAX_CUE_ALPHA,
			"%s must stay below prompt priority" % cue.name
		)


func test_checkout_stockroom_and_shelf_cues_form_recoverable_physical_route() -> void:
	var cue_root: Node3D = _cue_root()
	var checkout: Node3D = _root.get_node_or_null("StoreSessionManager") as Node3D
	var register: Node3D = _root.get_node_or_null("StoreSessionDayEndTrigger") as Node3D
	var stockroom: Node3D = _root.get_node_or_null("StoreSessionBackroomPickup") as Node3D
	var shelf: Node3D = _root.get_node_or_null("StoreSessionRestockShelf") as Node3D
	var stockroom_threshold: Node3D = (
		_root.get_node_or_null("ExpandableStoreShell/StockroomFloorTape") as Node3D
	)
	if (
		cue_root == null
		or checkout == null
		or register == null
		or stockroom == null
		or shelf == null
		or stockroom_threshold == null
	):
		return

	var route_points: Array[Vector3] = [
		checkout.global_position,
		register.global_position,
		_cue(cue_root, "CheckoutBackroomFloorWear00").global_position,
		_cue(cue_root, "CheckoutBackroomFloorWear01").global_position,
		_cue(cue_root, "CheckoutBackroomFloorWear02").global_position,
		stockroom_threshold.global_position,
		_cue(cue_root, "StockroomInteriorFloorWear00").global_position,
		_cue(cue_root, "StockroomInteriorFloorWear01").global_position,
		_cue(cue_root, "StockroomInteriorFloorWear02").global_position,
		stockroom.global_position,
		_cue(cue_root, "StockroomInteriorFloorWear02").global_position,
		_cue(cue_root, "StockroomInteriorFloorWear01").global_position,
		_cue(cue_root, "StockroomInteriorFloorWear00").global_position,
		stockroom_threshold.global_position,
		_cue(cue_root, "StockroomShelfFloorWear00").global_position,
		_cue(cue_root, "StockroomShelfFloorWear01").global_position,
		_cue(cue_root, "StockroomShelfFloorWear02").global_position,
		_cue(cue_root, "StarterShelfLocalFloorWear").global_position,
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


func _cue(cue_root: Node, cue_name: String) -> Node3D:
	var cue: Node3D = cue_root.get_node_or_null(cue_name) as Node3D
	assert_not_null(cue, "Missing first-run floor cue: %s" % cue_name)
	return cue


func _has_interaction_descendant(node: Node) -> bool:
	if node is Area3D or node is CollisionShape3D or node is Interactable:
		return true
	for child: Node in node.get_children():
		if _has_interaction_descendant(child):
			return true
	return false


func _longest_box_axis(mesh_instance: MeshInstance3D) -> float:
	var box: BoxMesh = mesh_instance.mesh as BoxMesh
	if box == null:
		return 0.0
	return maxf(box.size.x, box.size.z)


func _material_alpha(mesh_instance: MeshInstance3D) -> float:
	var material: StandardMaterial3D = mesh_instance.material_override as StandardMaterial3D
	if material == null:
		return 1.0
	return material.albedo_color.a


func _xz_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x, a.z).distance_to(Vector2(b.x, b.z))
