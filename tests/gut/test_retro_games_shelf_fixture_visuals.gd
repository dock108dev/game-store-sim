extends GutTest

const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"


func test_product_shelves_have_modular_fixture_rhythm() -> void:
	var root: Node3D = _instantiate_store()
	if root == null:
		return
	for node_path: String in [
		"ReadabilityProps/ProductDisplayRows/ShelfProductBacker",
		"ReadabilityProps/ProductDisplayRows/NewReleaseProductBacker",
	]:
		var backer: MeshInstance3D = root.get_node_or_null(node_path) as MeshInstance3D
		assert_not_null(backer, "Shelf backer missing: %s" % node_path)
		if backer != null:
			var backer_mat: StandardMaterial3D = backer.get_surface_override_material(
				0
			) as StandardMaterial3D
			assert_not_null(backer_mat, "%s must use a shelf backer material" % node_path)
			if backer_mat != null:
				assert_null(
					backer_mat.albedo_texture,
					"%s must read as fixture backing, not product art" % node_path
				)
	for node_path: String in _fixture_rhythm_paths():
		var rail: MeshInstance3D = root.get_node_or_null(node_path) as MeshInstance3D
		assert_not_null(rail, "Shelf rhythm rail/divider missing: %s" % node_path)
		if rail == null:
			continue
		assert_gte(
			_box_world_size(rail).z,
			0.05,
			"%s must have visible fixture thickness, not read as a debug line"
			% node_path
		)
	root.free()


func test_empty_shelf_slots_are_intentional_non_product_gaps() -> void:
	var root: Node3D = _instantiate_store()
	if root == null:
		return
	for node_path: String in [
		"ReadabilityProps/ProductDisplayRows/UsedShelfEmptySlotA",
		"ReadabilityProps/ProductDisplayRows/UsedShelfEmptySlotB",
		"ReadabilityProps/ProductDisplayRows/NewReleaseEmptySlotA",
		"ReadabilityProps/ProductDisplayRows/NewReleaseEmptySlotB",
	]:
		var gap: MeshInstance3D = root.get_node_or_null(node_path) as MeshInstance3D
		assert_not_null(gap, "Intentional empty shelf slot missing: %s" % node_path)
		if gap == null:
			continue
		var gap_mat: StandardMaterial3D = gap.get_surface_override_material(
			0
		) as StandardMaterial3D
		assert_not_null(gap_mat, "%s must use a material" % node_path)
		if gap_mat != null:
			assert_null(
				gap_mat.albedo_texture,
				"%s must be an empty slot marker, not another product cover"
				% node_path
			)
	root.free()


func test_shelf_spine_runs_have_varied_stocking_rhythm() -> void:
	var root: Node3D = _instantiate_store()
	if root == null:
		return
	var spine_root: Node = root.get_node_or_null("ReadabilityProps/ShelfSpineRuns")
	assert_not_null(spine_root, "ShelfSpineRuns must exist")
	if spine_root == null:
		root.free()
		return
	var texture_keys: Dictionary = {}
	var width_buckets: Dictionary = {}
	var row_buckets: Dictionary = {}
	var product_spines: int = 0
	for child: Node in spine_root.get_children():
		var spine: MeshInstance3D = child as MeshInstance3D
		if spine == null:
			continue
		width_buckets[roundi(_box_world_size(spine).x * 100.0)] = true
		row_buckets[roundi(_scene_position(spine).y * 10.0)] = true
		var mat: StandardMaterial3D = spine.get_surface_override_material(
			0
		) as StandardMaterial3D
		if spine.is_in_group(&"product_display"):
			product_spines += 1
			assert_not_null(mat, "%s must have product material" % spine.name)
			if mat != null:
				assert_not_null(
					mat.albedo_texture,
					"%s must use named product art, not a flat color stripe"
					% spine.name
				)
				texture_keys[mat.albedo_texture] = true
	assert_gte(product_spines, 10, "Shelf spine runs need dense named product rhythm")
	assert_gte(texture_keys.size(), 4, "Shelf spines must vary across named products")
	assert_gte(width_buckets.size(), 3, "Shelf spines must vary case widths")
	assert_gte(row_buckets.size(), 2, "Shelf spines must occupy more than one row")
	root.free()


func test_shelf_product_dressing_stays_clear_of_main_path() -> void:
	var root: Node3D = _instantiate_store()
	if root == null:
		return
	for node_path: String in [
		"ReadabilityProps/ProductDisplayRows",
		"ReadabilityProps/ShelfFaceDressing",
		"ReadabilityProps/ShelfSpineRuns",
	]:
		var shelf_root: Node = root.get_node_or_null(node_path)
		assert_not_null(shelf_root, "Shelf product dressing root missing: %s" % node_path)
		if shelf_root == null:
			continue
		for child: Node in shelf_root.get_children():
			var prop: MeshInstance3D = child as MeshInstance3D
			if prop == null:
				continue
			assert_lte(
				_scene_position(prop).z,
				-9.20,
				"%s/%s must stay on the wall fixture, clear of the main path"
				% [node_path, prop.name]
			)
	root.free()


func test_cart_racks_are_merchandised_fixture_walls() -> void:
	var root: Node3D = _instantiate_store()
	if root == null:
		return
	for rack_path: String in ["CartRackLeft", "CartRackRight"]:
		var rack: Node3D = root.get_node_or_null(rack_path) as Node3D
		assert_not_null(rack, "%s must exist" % rack_path)
		if rack == null:
			continue
		var rack_mesh: MeshInstance3D = rack.get_node_or_null("RackMesh") as MeshInstance3D
		assert_not_null(rack_mesh, "%s/RackMesh must exist" % rack_path)
		if rack_mesh != null and rack_mesh.mesh is BoxMesh:
			assert_lte(
				(rack_mesh.mesh as BoxMesh).size.z,
				0.22,
				"%s/RackMesh must read as a back panel, not a deep slab" % rack_path
			)
		var merch_root: Node = rack.get_node_or_null("MerchandisingRows")
		assert_not_null(merch_root, "%s must expose authored merch rows" % rack_path)
		if merch_root == null:
			continue
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
			if mesh_node.is_in_group(&"product_display"):
				var mat: StandardMaterial3D = mesh_node.get_surface_override_material(
					0
				) as StandardMaterial3D
				assert_not_null(mat, "%s/%s must use a product material" % [rack_path, child_name])
				if mat != null:
					material_keys[mat] = true
		assert_gte(role_counts["featured"], 3, "%s top row must feature front-facing games" % rack_path)
		assert_gte(role_counts["spine"], 4, "%s middle row must carry spine-facing stock" % rack_path)
		assert_gte(role_counts["stock"], 2, "%s bottom row must read as larger stock" % rack_path)
		assert_gte(role_counts["empty"], 1, "%s must show intentional empty shelf states" % rack_path)
		assert_gte(role_counts["lip"], 3, "%s must repeat lips across rows" % rack_path)
		assert_gte(role_counts["divider"], 3, "%s must repeat dividers across bays" % rack_path)
		assert_gte(role_counts["price"], 2, "%s must include price-tag rhythm" % rack_path)
		assert_gte(material_keys.size(), 4, "%s product facings must vary title templates" % rack_path)
	root.free()


func test_store_restock_shelf_keeps_objective_target_inside_merch_fixture() -> void:
	var root: Node3D = _instantiate_store()
	if root == null:
		return
	var shelf: Node3D = root.get_node_or_null("StoreSessionRestockShelf") as Node3D
	assert_not_null(shelf, "StoreSessionRestockShelf must exist")
	if shelf == null:
		root.free()
		return
	assert_not_null(
		shelf.get_node_or_null("Interactable"),
		"StoreSessionRestockShelf/Interactable must remain the stocking target"
	)
	var frame: Node = shelf.get_node_or_null("MerchandisingFrame")
	assert_not_null(frame, "StoreSessionRestockShelf must have a merchandised shelf frame")
	if frame == null:
		root.free()
		return
	for node_path: String in [
		"BackPanel",
		"UpperShelfBoard",
		"MiddleShelfLip",
		"BottomShelfLip",
		"LeftDivider",
		"RightDivider",
		"RestockEmptyGhost",
		"RestockPriceTag",
	]:
		assert_not_null(
			frame.get_node_or_null(node_path),
			"StoreSessionRestockShelf/MerchandisingFrame/%s must exist" % node_path
		)
	var product_facings: int = 0
	for child: Node in frame.get_children():
		if child.is_in_group(&"product_display"):
			product_facings += 1
	assert_gte(product_facings, 2, "Store-session restock shelf must show featured product facings")
	assert_false(
		_has_area_descendant(frame),
		"Store-session restock shelf merchandising frame must stay visual-only"
	)
	root.free()


func test_store_restock_shelf_table_is_grounded_with_visible_supports() -> void:
	var root: Node3D = _instantiate_store()
	if root == null:
		return
	var shelf: Node3D = root.get_node_or_null("StoreSessionRestockShelf") as Node3D
	assert_not_null(shelf, "StoreSessionRestockShelf must exist")
	if shelf == null:
		root.free()
		return
	var board: MeshInstance3D = shelf.get_node_or_null("ShelfBoard") as MeshInstance3D
	assert_not_null(board, "StoreSessionRestockShelf/ShelfBoard must exist")
	if board == null:
		root.free()
		return
	var board_bottom: float = _scene_position(board).y - _box_world_size(board).y * 0.5
	var support_count: int = 0
	for node_path: String in [
		"TableLegFrontLeft",
		"TableLegFrontRight",
		"TableLegBackLeft",
		"TableLegBackRight",
		"TableFrontApron",
	]:
		var support: MeshInstance3D = shelf.get_node_or_null(node_path) as MeshInstance3D
		assert_not_null(support, "Restock display support missing: %s" % node_path)
		if support == null:
			continue
		support_count += 1
		var support_size: Vector3 = _box_world_size(support)
		var support_pos: Vector3 = _scene_position(support)
		if node_path.begins_with("TableLeg"):
			assert_lte(
				support_pos.y - support_size.y * 0.5,
				0.05,
				"%s must reach the floor so the display table does not float" % node_path
			)
		assert_lte(
			support_pos.y + support_size.y * 0.5,
			board_bottom + 0.10,
			"%s must tuck under the table surface" % node_path
		)
	assert_gte(support_count, 5, "Restock display must have four legs and a front apron")
	root.free()


func _fixture_rhythm_paths() -> Array[String]:
	return [
		"ReadabilityProps/ProductDisplayRows/ShelfProductLip",
		"ReadabilityProps/ProductDisplayRows/ShelfProductLowerLip",
		"ReadabilityProps/ProductDisplayRows/ShelfProductBaseLip",
		"ReadabilityProps/ProductDisplayRows/NewReleaseProductLip",
		"ReadabilityProps/ProductDisplayRows/NewReleaseProductLowerLip",
		"ReadabilityProps/ProductDisplayRows/NewReleaseProductBaseLip",
		"ReadabilityProps/ProductDisplayRows/ShelfProductLeftDivider",
		"ReadabilityProps/ProductDisplayRows/ShelfProductRightDivider",
		"ReadabilityProps/ProductDisplayRows/NewReleaseLeftDivider",
		"ReadabilityProps/ProductDisplayRows/NewReleaseRightDivider",
	]


func _instantiate_store() -> Node3D:
	var scene: PackedScene = load(SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return null
	var root: Node3D = scene.instantiate() as Node3D
	assert_not_null(root, "retro_games.tscn must instantiate as Node3D")
	return root


func _box_world_size(mesh_inst: MeshInstance3D) -> Vector3:
	var box: BoxMesh = mesh_inst.mesh as BoxMesh
	if box == null:
		return Vector3.ZERO
	var basis_scale: Vector3 = _scene_transform(mesh_inst).basis.get_scale()
	return Vector3(
		box.size.x * absf(basis_scale.x),
		box.size.y * absf(basis_scale.y),
		box.size.z * absf(basis_scale.z),
	)


func _scene_position(node: Node3D) -> Vector3:
	return _scene_transform(node).origin


func _scene_transform(node: Node3D) -> Transform3D:
	var scene_transform: Transform3D = node.transform
	var cursor: Node = node.get_parent()
	while cursor is Node3D:
		scene_transform = (cursor as Node3D).transform * scene_transform
		cursor = cursor.get_parent()
	return scene_transform


func _has_area_descendant(root: Node) -> bool:
	for child: Node in root.get_children():
		if child is Area3D:
			return true
		if _has_area_descendant(child):
			return true
	return false
