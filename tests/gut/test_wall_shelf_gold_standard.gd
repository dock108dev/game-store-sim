extends GutTest

const WALL_SHELF_PATH: String = (
	"res://game/scenes/stores/fixtures/retail_wall_shelf.tscn"
)


func test_wall_shelf_scene_has_designed_retail_rhythm() -> void:
	var root: Node3D = _instantiate_wall_shelf()
	for required_path: String in [
		"ShelfMesh",
		"LeftSideCap",
		"RightSideCap",
		"BottomTrim",
		"ShelfBoard1",
		"ShelfBoard2",
		"ShelfBoard3",
		"ShelfLabelBacking",
		"ShelfLabelText",
		"MerchandisingRows",
	]:
		assert_not_null(
			root.get_node_or_null(required_path),
			"RetailWallShelf must include %s" % required_path
		)


func test_wall_shelf_label_matches_subordinate_sign_vocabulary() -> void:
	var root: Node3D = _instantiate_wall_shelf()
	var label: Label3D = root.get_node_or_null("ShelfLabelText") as Label3D
	assert_not_null(label, "RetailWallShelf must include a shelf label")
	if label == null:
		return
	assert_eq(label.modulate, Color(1, 0.92, 0.55, 1))
	assert_eq(label.outline_modulate, Color(0.05, 0.05, 0.05, 1))
	assert_gte(label.outline_size, 6)
	assert_false(label.shaded)
	assert_false(label.double_sided)
	assert_lte(
		float(label.font_size) * label.pixel_size,
		0.07,
		"Shelf label must stay subordinate to zone-header signage"
	)


func test_wall_shelf_merchandising_rows_are_visual_only() -> void:
	var merch_root: Node = _get_merchandising_root()
	for child: Node in merch_root.get_children():
		assert_false(
			child is Area3D,
			"RetailWallShelf merchandising rows must stay visual-only"
		)


func test_wall_shelf_uses_front_spine_stock_and_empty_rhythm() -> void:
	var merch_root: Node = _get_merchandising_root()
	var role_counts := {
		"featured": 0,
		"spine": 0,
		"stock": 0,
		"empty": 0,
		"lip": 0,
		"divider": 0,
		"price": 0,
	}
	var material_keys: Dictionary = {}
	for child: Node in merch_root.get_children():
		var mesh_node: MeshInstance3D = child as MeshInstance3D
		if mesh_node == null:
			continue
		var child_name: String = String(mesh_node.name)
		_count_merchandising_role(child_name, role_counts)
		var mat: StandardMaterial3D = mesh_node.get_surface_override_material(
			0
		) as StandardMaterial3D
		assert_not_null(mat, "%s must use an authored material" % child_name)
		if mesh_node.is_in_group(&"product_display") and mat != null:
			material_keys[mat] = true
		if child_name.contains("EmptyGhost") and mat != null:
			assert_null(
				mat.albedo_texture,
				"%s must read as an intentional gap, not product art" % child_name
			)

	assert_gte(role_counts["featured"], 3)
	assert_gte(role_counts["spine"], 4)
	assert_gte(role_counts["stock"], 2)
	assert_gte(role_counts["empty"], 2)
	assert_gte(role_counts["lip"], 3)
	assert_gte(role_counts["divider"], 3)
	assert_gte(role_counts["price"], 2)
	assert_gte(material_keys.size(), 4)


func _instantiate_wall_shelf() -> Node3D:
	var packed: PackedScene = load(WALL_SHELF_PATH) as PackedScene
	assert_not_null(packed, "Retail wall shelf scene must load")
	var root: Node3D = packed.instantiate() as Node3D
	assert_not_null(root, "Retail wall shelf scene must instantiate as Node3D")
	add_child_autofree(root)
	return root


func _get_merchandising_root() -> Node:
	var root: Node3D = _instantiate_wall_shelf()
	var merch_root: Node = root.get_node_or_null("MerchandisingRows")
	assert_not_null(merch_root, "RetailWallShelf must expose visual merch rows")
	return merch_root


func _count_merchandising_role(child_name: String, role_counts: Dictionary) -> void:
	if child_name.begins_with("FeaturedFront"):
		role_counts["featured"] += 1
	if child_name.begins_with("MiddleSpine"):
		role_counts["spine"] += 1
	if child_name.begins_with("BottomStock"):
		role_counts["stock"] += 1
	if child_name.contains("EmptyGhost"):
		role_counts["empty"] += 1
	if child_name.ends_with("FrontLip"):
		role_counts["lip"] += 1
	if child_name.ends_with("Divider"):
		role_counts["divider"] += 1
	if child_name.ends_with("PriceTag"):
		role_counts["price"] += 1
