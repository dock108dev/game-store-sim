extends GutTest

const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"

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


func test_runtime_storefront_door_uses_lightweight_proportions() -> void:
	var shell: Node3D = _shell()
	if shell == null:
		return
	var left_frame: Node3D = shell.get_node_or_null("FrontDoorFrameLeft") as Node3D
	var right_frame: Node3D = shell.get_node_or_null("FrontDoorFrameRight") as Node3D
	var top_frame: Node3D = shell.get_node_or_null("FrontDoorFrameTop") as Node3D
	var glass: Node3D = shell.get_node_or_null("StarterGlassDoorBlocker") as Node3D
	var push_plate: Node3D = shell.get_node_or_null("FrontDoorPushPlate") as Node3D
	var threshold: Node3D = shell.get_node_or_null("EntryThreshold") as Node3D
	for node: Node3D in [left_frame, right_frame, top_frame, glass, push_plate, threshold]:
		assert_not_null(node, "Generated storefront node must exist")
	if (
		left_frame == null
		or right_frame == null
		or top_frame == null
		or glass == null
		or push_plate == null
		or threshold == null
	):
		return

	for jamb: Node3D in [left_frame, right_frame]:
		var jamb_size: Vector3 = _box_size(jamb)
		assert_lte(jamb_size.x, 0.045, "Door jambs must stay visually slim")
		assert_lte(jamb_size.z, 0.07, "Door jamb depth must not read as a wall pier")
		assert_lte(jamb_size.y, 2.55, "Door jambs must stay below ceiling scale")
	var top_size: Vector3 = _box_size(top_frame)
	assert_lte(top_size.y, 0.05, "Door header must be a trim rail, not a beam")
	assert_lte(top_size.z, 0.07, "Door header depth must match the light jambs")
	assert_lte(top_size.x, 1.98, "Door header must not over-span the storefront")

	var glass_size: Vector3 = _box_size(glass)
	assert_lte(glass_size.x, 1.70, "Glass should cue a door without filling the whole opening")
	assert_lte(glass_size.y, 1.95, "Glass should stay below full-wall height")
	assert_lte(glass_size.z, 0.025, "Glass should read as a light pane")

	var push_plate_size: Vector3 = _box_size(push_plate)
	assert_lte(push_plate_size.x, 0.045, "Push plate must stay subordinate to the door pane")
	assert_lte(push_plate_size.y, 0.26, "Push plate must not become a gold sign")
	assert_lte(push_plate_size.z, 0.025, "Push plate depth must stay trim-like")

	var threshold_size: Vector3 = _box_size(threshold)
	assert_lte(threshold_size.x, 1.96, "Threshold width must match the door system")
	assert_lte(threshold_size.y, 0.025, "Threshold must stay flush with the floor")
	assert_lte(threshold_size.z, 0.20, "Threshold depth must not become an entry platform")


func test_runtime_storefront_materials_stay_with_the_shell_palette() -> void:
	var shell: Node3D = _shell()
	if shell == null:
		return
	var frame_mat: StandardMaterial3D = _material_for(
		shell.get_node_or_null("FrontDoorFrameLeft") as Node3D
	)
	var glass_mat: StandardMaterial3D = _material_for(
		shell.get_node_or_null("StarterGlassDoorBlocker") as Node3D
	)
	var push_plate_mat: StandardMaterial3D = _material_for(
		shell.get_node_or_null("FrontDoorPushPlate") as Node3D
	)
	var threshold_mat: StandardMaterial3D = _material_for(
		shell.get_node_or_null("EntryThreshold") as Node3D
	)
	for material: StandardMaterial3D in [frame_mat, glass_mat, push_plate_mat, threshold_mat]:
		assert_not_null(material, "Generated storefront material must exist")
	if frame_mat == null or glass_mat == null or push_plate_mat == null or threshold_mat == null:
		return

	assert_between(
		_brightest_channel(frame_mat.albedo_color),
		0.20,
		0.28,
		"Frame material must stay readable without becoming a dark wall outline"
	)
	assert_between(
		glass_mat.albedo_color.a,
		0.08,
		0.13,
		"Glass alpha must be readable without darkening the sales floor"
	)
	assert_ne(
		glass_mat.transparency,
		BaseMaterial3D.TRANSPARENCY_DISABLED,
		"Glass material must keep transparency enabled"
	)
	assert_lte(
		_brightest_channel(push_plate_mat.albedo_color),
		0.64,
		"Push plate metal must stay muted beside checkout and shelf anchors"
	)
	assert_lte(
		_brightest_channel(threshold_mat.albedo_color),
		0.46,
		"Threshold material must stay subordinate to route targets"
	)


func test_runtime_storefront_stays_behind_entry_and_checkout_sightlines() -> void:
	var shell: Node3D = _shell()
	if shell == null:
		return
	var threshold: Node3D = shell.get_node_or_null("EntryThreshold") as Node3D
	var glass: Node3D = shell.get_node_or_null("StarterGlassDoorBlocker") as Node3D
	var checkout: Node3D = _root.get_node_or_null("checkout_counter") as Node3D
	var shelf: Node3D = _root.get_node_or_null("StoreSessionRestockShelf") as Node3D
	var stockroom: Node3D = _root.get_node_or_null("StoreSessionBackroomPickup") as Node3D
	var interactable: Interactable = (
		_root.get_node_or_null("EntranceDoor/Interactable") as Interactable
	)
	var interaction_area: Area3D = null if interactable == null else interactable.get_interaction_area()
	for node: Node in [threshold, glass, checkout, shelf, stockroom, interactable]:
		assert_not_null(node, "Sightline contract node must exist")
	if (
		threshold == null
		or glass == null
		or checkout == null
		or shelf == null
		or stockroom == null
		or interactable == null
	):
		return

	var threshold_front_z: float = threshold.position.z - _box_size(threshold).z * 0.5
	assert_gt(
		threshold_front_z,
		9.35,
		"Door threshold must stay at the storefront edge, behind first route targets"
	)
	assert_gt(
		threshold_front_z - checkout.global_position.z,
		3.0,
		"Door visuals must not crowd the checkout sightline"
	)
	assert_gt(
		threshold_front_z - shelf.global_position.z,
		7.0,
		"Door visuals must not occlude the starter shelf route"
	)
	assert_gt(
		threshold_front_z - stockroom.global_position.z,
		15.0,
		"Door visuals must not occlude the stockroom route"
	)
	assert_true(interactable.enabled, "Entrance door interactable must remain enabled")
	assert_false(
		_is_visible(_root.get_node_or_null("EntranceDoor/DoorMesh") as Node3D),
		"Authored door mesh must stay hidden when the generated storefront is active"
	)
	assert_false(
		_is_visible(_root.get_node_or_null("EntranceDoor/StaticBody3D") as Node3D),
		"Authored door body must stay hidden when the generated storefront is active"
	)
	assert_eq(
		interactable.get_prompt_label(),
		"Exit to Mall",
		"Runtime door prompt must not add competing door wording"
	)
	assert_eq(
		interactable.proximity_radius,
		0.0,
		"Entrance exit must stay reticle-gated instead of proximity-gated"
	)
	assert_not_null(interaction_area, "Entrance door must expose an interaction hit area")
	if interaction_area == null:
		return
	assert_lte(
		interaction_area.global_position.z,
		glass.global_position.z,
		"Door hit area must stay on the camera-facing side of generated glass"
	)


func _shell() -> Node3D:
	assert_not_null(_root, "retro_games root must be instantiated")
	if _root == null:
		return null
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	assert_not_null(shell, "ExpandableStoreShell must be generated")
	return shell


func _box_size(node: Node3D) -> Vector3:
	if node == null:
		return Vector3.ZERO
	var mesh_instance: MeshInstance3D = node as MeshInstance3D
	if mesh_instance == null:
		mesh_instance = node.get_node_or_null("Visual") as MeshInstance3D
	if mesh_instance == null:
		return Vector3.ZERO
	var box_mesh: BoxMesh = mesh_instance.mesh as BoxMesh
	if box_mesh == null:
		return Vector3.ZERO
	return box_mesh.size


func _material_for(node: Node3D) -> StandardMaterial3D:
	if node == null:
		return null
	var mesh_instance: MeshInstance3D = node as MeshInstance3D
	if mesh_instance == null:
		mesh_instance = node.get_node_or_null("Visual") as MeshInstance3D
	if mesh_instance == null:
		return null
	return mesh_instance.material_override as StandardMaterial3D


func _brightest_channel(color: Color) -> float:
	return maxf(color.r, maxf(color.g, color.b))


func _is_visible(node: Node3D) -> bool:
	return node != null and node.visible
