extends GutTest

const StarterDetailBuilderScript: GDScript = preload(
	"res://game/scripts/visuals/starter_detail_builder.gd"
)
const StoreVisualStyleScript: GDScript = preload("res://game/scripts/visuals/store_visual_style.gd")
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


func test_shared_style_exposes_zone_family_recipes_and_independent_roles() -> void:
	for family: StringName in [
		StoreVisualStyleScript.FAMILY_MALL_THRESHOLD_GLASS,
		StoreVisualStyleScript.FAMILY_MALL_THRESHOLD_METAL,
		StoreVisualStyleScript.FAMILY_MALL_THRESHOLD_TILE,
		StoreVisualStyleScript.FAMILY_SALES_FLOOR_WARM,
		StoreVisualStyleScript.FAMILY_WOOD_LAMINATE,
		StoreVisualStyleScript.FAMILY_DARK_DEVICE_PLASTIC,
		StoreVisualStyleScript.FAMILY_STOCKROOM_COOL_METAL,
		StoreVisualStyleScript.FAMILY_CARDBOARD,
		StoreVisualStyleScript.FAMILY_PAPER,
		StoreVisualStyleScript.FAMILY_PRICE_TAG_WARM,
		StoreVisualStyleScript.FAMILY_RUBBER,
		StoreVisualStyleScript.FAMILY_AMBER_SIGNAGE,
		StoreVisualStyleScript.FAMILY_SHADOW_ACCENT,
		StoreVisualStyleScript.FAMILY_PRODUCT_ACCENT_BLUE,
		StoreVisualStyleScript.FAMILY_PRODUCT_ACCENT_TEAL,
	]:
		assert_true(
			StoreVisualStyleScript.material_family_ids().has(family),
			"Shared style family missing: %s" % family
		)
		assert_not_null(
			StoreVisualStyleScript.material_for_family(family),
			"Shared style family must build material: %s" % family
		)

	var stockroom_recipe: Dictionary = StoreVisualStyleScript.surface_recipe(
		StoreVisualStyleScript.RECIPE_STOCKROOM
	)
	var checkout_recipe: Dictionary = StoreVisualStyleScript.surface_recipe(
		StoreVisualStyleScript.RECIPE_CHECKOUT
	)
	var product_recipe: Dictionary = StoreVisualStyleScript.surface_recipe(
		StoreVisualStyleScript.RECIPE_PRODUCT
	)
	assert_eq(
		StoreVisualStyleScript.family_for_token(stockroom_recipe.get("panel", &"") as StringName),
		StoreVisualStyleScript.FAMILY_STOCKROOM_COOL_METAL
	)
	assert_eq(
		StoreVisualStyleScript.family_for_token(checkout_recipe.get("device", &"") as StringName),
		StoreVisualStyleScript.FAMILY_DARK_DEVICE_PLASTIC
	)
	assert_eq(
		StoreVisualStyleScript.family_for_token(product_recipe.get("price_tag", &"") as StringName),
		StoreVisualStyleScript.FAMILY_PRICE_TAG_WARM
	)
	assert_eq(
		StoreVisualStyleScript.role_for_token(product_recipe.get("price_tag", &"") as StringName),
		StoreVisualStyleScript.ROLE_LABEL
	)

	var node := MeshInstance3D.new()
	add_child_autofree(node)
	StoreVisualStyleScript.apply_metadata(
		node,
		StoreVisualStyleScript.FAMILY_WOOD_LAMINATE,
		StoreVisualStyleScript.ROLE_PANEL,
		&"test.wood.panel"
	)
	StoreVisualStyleScript.apply_metadata(
		node,
		StoreVisualStyleScript.FAMILY_SHADOW_ACCENT,
		StoreVisualStyleScript.ROLE_SEAM,
		&"test.shadow.seam"
	)
	assert_eq(
		node.get_meta("starter_material_family"),
		StoreVisualStyleScript.FAMILY_SHADOW_ACCENT
	)
	assert_eq(node.get_meta("starter_detail_role"), StoreVisualStyleScript.ROLE_SEAM)


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


func test_runtime_shell_material_families_stay_distinguishable() -> void:
	await _load_store()
	var shell: Node3D = _shell()
	if shell == null:
		return
	var expected_families: Dictionary = {
		"EntryThreshold": StoreVisualStyleScript.FAMILY_MALL_THRESHOLD_TILE,
		"FrontDoorPushPlate": StoreVisualStyleScript.FAMILY_MALL_THRESHOLD_METAL,
		"StarterGlassDoorBlocker/Visual": StoreVisualStyleScript.FAMILY_MALL_THRESHOLD_GLASS,
		"StarterFloor": StoreVisualStyleScript.FAMILY_SALES_FLOOR_WARM,
		"CheckoutCounterTop": StoreVisualStyleScript.FAMILY_WOOD_LAMINATE,
		"CheckoutRegisterDrawer": StoreVisualStyleScript.FAMILY_DARK_DEVICE_PLASTIC,
		"CheckoutCustomerFloorMat": StoreVisualStyleScript.FAMILY_RUBBER,
		"StockroomExpandedBackWallPanel": StoreVisualStyleScript.FAMILY_STOCKROOM_COOL_METAL,
		"StockroomSupplyBox00": StoreVisualStyleScript.FAMILY_CARDBOARD,
		"StockroomSupplyLabel00": StoreVisualStyleScript.FAMILY_PAPER,
		"StarterUsedShelfPriceTag00": StoreVisualStyleScript.FAMILY_PRICE_TAG_WARM,
		"CheckoutQueueRopeFront": StoreVisualStyleScript.FAMILY_RUBBER,
		"ShelfWallCoolReadPanel": StoreVisualStyleScript.FAMILY_STOCKROOM_COOL_METAL,
		"ShelfWallCategoryPlaque": StoreVisualStyleScript.FAMILY_PRODUCT_ACCENT_BLUE,
		"ShelfWallFeatureFacing": StoreVisualStyleScript.FAMILY_PRODUCT_ACCENT_PURPLE,
		"ShelfWallAccentTopRail": StoreVisualStyleScript.FAMILY_PRODUCT_ACCENT_TEAL,
		"StockroomExpandedAisleShadow": StoreVisualStyleScript.FAMILY_SHADOW_ACCENT,
	}
	var family_counts: Dictionary = {}
	var color_buckets: Dictionary = {}
	for path: String in expected_families:
		var node: Node = shell.get_node_or_null(path)
		assert_not_null(node, "%s must exist for material-family validation" % path)
		if node == null:
			continue
		var family: StringName = StarterDetailBuilderScript.material_family_for_node(node)
		assert_eq(family, expected_families[path], "%s material family drifted" % path)
		family_counts[family] = int(family_counts.get(family, 0)) + 1
		var material: StandardMaterial3D = _material_for_node(node)
		assert_not_null(material, "%s must carry a StandardMaterial3D" % path)
		if material != null:
			var bucket: String = _color_bucket(material.albedo_color)
			color_buckets[bucket] = int(color_buckets.get(bucket, 0)) + 1

	assert_gte(family_counts.size(), 12, "Generated shell must not collapse to one material")
	assert_gte(color_buckets.size(), 6, "Generated shell must keep distinct color families")
	for bucket: String in ["warm", "cool", "amber", "dark", "paper", "blue"]:
		assert_true(color_buckets.has(bucket), "Generated shell missing %s color family" % bucket)
	for bucket: String in ["brown", "blue", "gray", "purple"]:
		assert_lte(
			int(color_buckets.get(bucket, 0)),
			5,
			"Generated shell must not collapse into all-%s visual noise" % bucket
		)
	assert_gte(
		_count_product_accent_families(family_counts),
		3,
		"Generated shell must keep saturated product accent families distinguishable"
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


func _material_for_node(node: Node) -> StandardMaterial3D:
	var mesh_instance: MeshInstance3D = node as MeshInstance3D
	if mesh_instance == null and node != null:
		mesh_instance = node.get_node_or_null("Visual") as MeshInstance3D
	if mesh_instance == null:
		return null
	return mesh_instance.material_override as StandardMaterial3D


func _color_bucket(color: Color) -> String:
	var bucket: String = "warm"
	if color.a < 0.2:
		bucket = "glass"
	else:
		var max_channel: float = maxf(color.r, maxf(color.g, color.b))
		var min_channel: float = minf(color.r, minf(color.g, color.b))
		if max_channel - min_channel < 0.08:
			bucket = "gray" if max_channel > 0.18 else "dark"
		elif max_channel < 0.18:
			bucket = "dark"
		elif color.r > 0.80 and color.g > 0.55 and color.b < 0.55:
			bucket = "amber"
		elif color.r > 0.80 and color.g > 0.80 and color.b > 0.65:
			bucket = "paper"
		elif color.r > color.g and color.g > color.b and max_channel < 0.70:
			bucket = "warm"
		elif color.b > color.r + 0.18 and color.b > color.g + 0.08:
			bucket = "blue" if color.b > color.g else "cool"
		elif color.b > color.r + 0.06 and color.b >= color.g:
			bucket = "cool"
		elif color.b > 0.25 and color.r > 0.20 and color.g < 0.18:
			bucket = "purple"
		elif max_channel - min_channel > 0.18 and max_channel > 0.25:
			bucket = "saturated"
		else:
			bucket = "brown" if color.r > color.b else "warm"
	return bucket


func _count_product_accent_families(family_counts: Dictionary) -> int:
	var count: int = 0
	for family: StringName in family_counts:
		if String(family).begins_with("product_accent_"):
			count += 1
	return count


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
