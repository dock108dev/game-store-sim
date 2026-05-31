extends GutTest

const StarterDetailBuilderScript: GDScript = preload(
	"res://game/scripts/visuals/starter_detail_builder.gd"
)
const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"

var _root: Node3D = null
var _saved_state: GameManager.State


func before_each() -> void:
	_saved_state = GameManager.current_state
	GameManager.current_state = GameManager.State.STORE_VIEW
	StoreSessionState.reset_new_run()


func after_each() -> void:
	if is_instance_valid(_root):
		_root.free()
	_root = null
	StoreSessionState.reset_new_run()
	GameManager.current_state = _saved_state


func test_shared_material_vocabulary_exposes_starter_families() -> void:
	var expected: Array[StringName] = [
		StarterDetailBuilderScript.FAMILY_WOOD_LAMINATE,
		StarterDetailBuilderScript.FAMILY_DARK_DEVICE_PLASTIC,
		StarterDetailBuilderScript.FAMILY_CARDBOARD,
		StarterDetailBuilderScript.FAMILY_PAPER,
		StarterDetailBuilderScript.FAMILY_PRICE_TAG_WARM,
		StarterDetailBuilderScript.FAMILY_STOCKROOM_COOL_METAL,
		StarterDetailBuilderScript.FAMILY_RUBBER,
		StarterDetailBuilderScript.FAMILY_SHADOW_ACCENT,
	]
	var actual: Array[StringName] = StarterDetailBuilderScript.material_family_ids()
	assert_eq(actual.size(), expected.size(), "Starter detail vocabulary should stay small")
	for family: StringName in expected:
		assert_true(actual.has(family), "Starter detail family missing: %s" % family)
		var material: StandardMaterial3D = StarterDetailBuilderScript.material_for(family)
		assert_not_null(material, "%s must build a material" % family)
		if material != null:
			assert_eq(StringName(material.resource_name), family)
	assert_between(
		StarterDetailBuilderScript.PRODUCT_PANEL_OFFSET,
		0.001,
		0.006,
		"Product-scale overlays need tiny offsets"
	)
	assert_between(
		StarterDetailBuilderScript.SURFACE_OFFSET,
		StarterDetailBuilderScript.MIN_DETAIL_THICKNESS,
		StarterDetailBuilderScript.MAX_DETAIL_THICKNESS,
		"Fixture-scale detail offsets should stay in the shared thickness range"
	)


func test_box_detail_builder_marks_visual_only_family_and_role() -> void:
	var root := Node3D.new()
	add_child_autofree(root)
	var detail: MeshInstance3D = StarterDetailBuilderScript.add_box_detail(
		root,
		"ShelfLip",
		Vector3.ZERO,
		Vector3(0.48, 0.035, 0.055),
		StarterDetailBuilderScript.FAMILY_WOOD_LAMINATE,
		StarterDetailBuilderScript.ROLE_LIP
	)
	assert_not_null(detail, "Builder should create a MeshInstance3D")
	if detail == null:
		return
	assert_true(bool(detail.get_meta("starter_visual_only", false)))
	assert_eq(
		detail.get_meta("starter_material_family"),
		StarterDetailBuilderScript.FAMILY_WOOD_LAMINATE
	)
	assert_eq(detail.get_meta("starter_detail_role"), StarterDetailBuilderScript.ROLE_LIP)
	assert_true(detail.mesh is BoxMesh, "Starter details should stay primitive and cheap")
	assert_false(_has_interaction_descendant(detail), "Starter details should not add gameplay")


func test_runtime_starter_details_keep_shared_material_families() -> void:
	await _load_store()
	var shell: Node3D = _shell()
	if shell == null:
		return
	_assert_family(shell, "CheckoutCounterTop", StarterDetailBuilderScript.FAMILY_WOOD_LAMINATE)
	_assert_family(
		shell, "CheckoutRegisterDrawer", StarterDetailBuilderScript.FAMILY_DARK_DEVICE_PLASTIC
	)
	_assert_family(shell, "CheckoutCustomerFloorMat", StarterDetailBuilderScript.FAMILY_RUBBER)
	_assert_family(
		shell, "StarterUsedShelfPriceTag00", StarterDetailBuilderScript.FAMILY_PRICE_TAG_WARM
	)
	_assert_family(
		shell, "StarterDisplayTableFrontLip", StarterDetailBuilderScript.FAMILY_WOOD_LAMINATE
	)
	_assert_family(
		shell, "StockroomReceivingTableLegA", StarterDetailBuilderScript.FAMILY_STOCKROOM_COOL_METAL
	)
	_assert_family(shell, "StockroomSupplyBox00", StarterDetailBuilderScript.FAMILY_CARDBOARD)
	_assert_family(shell, "StockroomSupplyLabel00", StarterDetailBuilderScript.FAMILY_PAPER)
	var price_tags: Array[Node] = shell.find_children("ProductPriceTag", "MeshInstance3D", true, false)
	assert_gt(price_tags.size(), 0, "Starter product visuals should expose warm price tags")
	if not price_tags.is_empty():
		assert_eq(
			StarterDetailBuilderScript.material_family_for_node(price_tags[0]),
			StarterDetailBuilderScript.FAMILY_PRICE_TAG_WARM
		)


func _load_store() -> void:
	var scene: PackedScene = load(SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	_root = scene.instantiate() as Node3D
	assert_not_null(_root, "retro_games.tscn must instantiate")
	if _root == null:
		return
	add_child(_root)
	await get_tree().process_frame
	await get_tree().process_frame


func _shell() -> Node3D:
	assert_not_null(_root, "Store scene must instantiate")
	if _root == null:
		return null
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	assert_not_null(shell, "Runtime shell must be generated")
	return shell


func _assert_family(shell: Node3D, path: String, expected: StringName) -> void:
	var node: Node = shell.get_node_or_null(path)
	assert_not_null(node, "%s must exist" % path)
	if node == null:
		return
	assert_eq(
		StarterDetailBuilderScript.material_family_for_node(node),
		expected,
		"%s should use starter material family %s" % [path, expected]
	)


func _has_interaction_descendant(node: Node) -> bool:
	for child: Node in node.get_children():
		if (
			child is Area3D
			or child is CollisionShape3D
			or child is CollisionObject3D
			or child is PhysicsBody3D
			or child is NavigationObstacle3D
			or child is Interactable
		):
			return true
		if _has_interaction_descendant(child):
			return true
	return false
