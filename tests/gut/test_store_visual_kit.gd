extends GutTest

const StoreVisualKitScript: GDScript = preload("res://game/scripts/visuals/store_visual_kit.gd")
const MeshBoundsUtil: GDScript = preload("res://game/scripts/visuals/mesh_bounds_util.gd")
const RETAIL_WALL_SHELF_PATH: String = (
	"res://game/scenes/stores/fixtures/retail_wall_shelf.tscn"
)
const RETAIL_GONDOLA_SHELF_PATH: String = (
	"res://game/scenes/stores/fixtures/retail_gondola_shelf.tscn"
)
const GAME_CASE_FIXTURE_PATH: String = "res://game/scenes/stores/fixtures/game_case.tscn"
const CONSOLE_BOX_FIXTURE_PATH: String = "res://game/scenes/stores/fixtures/console_box.tscn"
const PROP_CONSOLE_BOX_PATH: String = "res://game/scenes/stores/fixtures/prop_console_box.tscn"


func test_required_visual_ids_resolve_to_existing_scenes() -> void:
	var required_ids: Array[StringName] = StoreVisualKitScript.required_ids()
	assert_gte(required_ids.size(), 8, "Store kit should expose reusable visual primitives")
	for id: StringName in required_ids:
		var path: String = StoreVisualKitScript.scene_path(id)
		var source_type: StringName = StoreVisualKitScript.source_type(id)
		assert_ne(source_type, &"missing", "%s should resolve to a source" % id)
		if source_type == &"scene":
			assert_ne(path, "", "%s should resolve to a scene path" % id)
			assert_true(ResourceLoader.exists(path), "%s should exist at %s" % [id, path])


func test_validate_reports_clean_visual_registry() -> void:
	var result: Dictionary = StoreVisualKitScript.validate()
	assert_true(bool(result.get("ok", false)), "Store visual kit should validate cleanly")
	assert_eq(result.get("missing", []), [], "Store visual kit should not miss scenes")


func test_starter_store_scope_stays_small_and_expandable() -> void:
	var starter_ids: Array[StringName] = StoreVisualKitScript.starter_store_ids()
	assert_between(
		starter_ids.size(),
		7,
		21,
		"Starter kit should stay small: fixtures, checkout pieces, and small display props"
	)
	for id: StringName in [
		StoreVisualKitScript.WALL_SHELF,
		StoreVisualKitScript.FLOOR_RACK,
		StoreVisualKitScript.DISPLAY_TABLE,
		StoreVisualKitScript.CHECKOUT_COUNTER,
		StoreVisualKitScript.STOCKROOM_SHELF,
		StoreVisualKitScript.GAME_CASE,
		StoreVisualKitScript.CONSOLE_BOX,
		StoreVisualKitScript.REGISTER,
		StoreVisualKitScript.CARD_READER,
		StoreVisualKitScript.RECEIPT_PRINTER,
		StoreVisualKitScript.PRICE_TAG,
		StoreVisualKitScript.SHELF_LABEL,
		StoreVisualKitScript.SIGN_SHELF_LABEL,
		StoreVisualKitScript.ACRYLIC_STAND,
		StoreVisualKitScript.CONTROLLER_BIN_PROP,
		StoreVisualKitScript.REPAIR_TESTING_MAT,
		StoreVisualKitScript.CLIPBOARD,
		StoreVisualKitScript.TAPED_BOX_LABEL,
		StoreVisualKitScript.SECURITY_TAG_BLOCK,
	]:
		assert_true(starter_ids.has(id), "Starter kit should include %s" % id)


func test_starter_store_visuals_instantiate_as_nodes() -> void:
	for id: StringName in StoreVisualKitScript.starter_store_ids():
		var visual: Node = StoreVisualKitScript.instantiate(id)
		assert_not_null(visual, "%s should instantiate" % id)
		if visual == null:
			continue
		assert_ne(str(visual.name), "", "%s should instantiate with a visible node name" % id)
		visual.free()


func test_reusable_price_tag_kit_pieces_cover_shelf_and_product_scale() -> void:
	var shelf_tag: MeshInstance3D = StoreVisualKitScript.instantiate(
		StoreVisualKitScript.PRICE_TAG
	) as MeshInstance3D
	assert_not_null(shelf_tag, "Shelf-scale price tag should instantiate")
	if shelf_tag != null:
		add_child_autofree(shelf_tag)
		assert_eq(shelf_tag.name, "PriceTag")
		assert_eq(str(shelf_tag.get_meta("store_visual_id", "")), "price_tag")
		assert_false(_has_interaction_descendant(shelf_tag))
		var shelf_mesh: BoxMesh = shelf_tag.mesh as BoxMesh
		assert_not_null(shelf_mesh)
		if shelf_mesh != null:
			assert_eq(shelf_mesh.size, Vector3(0.28, 0.08, 0.018))

	var product_tag: MeshInstance3D = StoreVisualKitScript.instantiate_product_price_tag(1499)
	assert_not_null(product_tag, "Product-scale price tag should instantiate")
	if product_tag != null:
		add_child_autofree(product_tag)
		assert_eq(product_tag.name, "ProductPriceTag")
		assert_eq(str(product_tag.get_meta("store_visual_id", "")), "product_price_tag")
		assert_eq(int(product_tag.get_meta("price_cents", -1)), 1499)
		var product_mesh: BoxMesh = product_tag.mesh as BoxMesh
		assert_not_null(product_mesh)
		if product_mesh != null:
			assert_eq(product_mesh.size, Vector3(0.070, 0.026, 0.006))


func test_reusable_shelf_label_accepts_context_text_without_build_fixture() -> void:
	var label: Node3D = StoreVisualKitScript.instantiate_shelf_label("USED GAMES")
	assert_not_null(label, "Reusable shelf label should instantiate")
	if label == null:
		return
	add_child_autofree(label)
	assert_eq(label.name, "ShelfLabel")
	assert_false(_has_interaction_descendant(label))
	var label_text: Label3D = label.get_node_or_null("LabelText") as Label3D
	assert_not_null(label_text)
	if label_text != null:
		assert_eq(label_text.text, "USED GAMES")

	var sign_label: Node3D = StoreVisualKitScript.instantiate(
		StoreVisualKitScript.SIGN_SHELF_LABEL
	) as Node3D
	assert_not_null(sign_label, "Sign shelf label variant should instantiate")
	if sign_label != null:
		add_child_autofree(sign_label)
		var sign_text: Label3D = sign_label.get_node_or_null("LabelText") as Label3D
		assert_not_null(sign_text)
		if sign_text != null:
			assert_eq(sign_text.text, "SHELF")


func test_retail_shelf_fixtures_use_reusable_price_tag_instances() -> void:
	var wall: Node3D = StoreVisualKitScript.instantiate(StoreVisualKitScript.WALL_SHELF) as Node3D
	assert_not_null(wall, "Wall shelf should instantiate")
	if wall != null:
		for node_path: String in [
			"MerchandisingRows/TopPriceTag",
			"MerchandisingRows/MiddlePriceTag",
		]:
			_assert_reusable_price_tag(wall, node_path)
		wall.free()

	var gondola: Node3D = StoreVisualKitScript.instantiate(StoreVisualKitScript.FLOOR_RACK) as Node3D
	assert_not_null(gondola, "Gondola shelf should instantiate")
	if gondola != null:
		for node_path: String in [
			"MerchandisingRows/FrontLabelTagA",
			"MerchandisingRows/FrontLabelTagB",
			"MerchandisingRows/BackLabelTagA",
			"MerchandisingRows/BackLabelTagB",
		]:
			_assert_reusable_price_tag(gondola, node_path)
		gondola.free()


func test_wall_shelf_default_uses_polished_retail_fixture() -> void:
	assert_eq(
		StoreVisualKitScript.scene_path(StoreVisualKitScript.WALL_SHELF),
		RETAIL_WALL_SHELF_PATH
	)
	var visual: Node3D = StoreVisualKitScript.instantiate(StoreVisualKitScript.WALL_SHELF) as Node3D
	assert_not_null(visual, "Wall shelf visual should instantiate")
	if visual == null:
		return
	assert_eq(visual.name, "RetailWallShelf")
	for required_path: String in [
		"ShelfMesh",
		"LeftSideCap",
		"RightSideCap",
		"ShelfLabelBacking",
		"MerchandisingRows",
	]:
		assert_not_null(
			visual.get_node_or_null(required_path),
			"Default wall shelf visual must include %s" % required_path
		)
	visual.free()


func test_floor_rack_default_uses_polished_gondola_fixture() -> void:
	assert_eq(
		StoreVisualKitScript.scene_path(StoreVisualKitScript.FLOOR_RACK),
		RETAIL_GONDOLA_SHELF_PATH
	)
	var visual: Node3D = StoreVisualKitScript.instantiate(StoreVisualKitScript.FLOOR_RACK) as Node3D
	assert_not_null(visual, "Floor rack visual should instantiate")
	if visual == null:
		return
	assert_eq(visual.name, "RetailGondolaShelf")
	for required_path: String in [
		"GondolaMesh",
		"CenterSpine",
		"TopShelfFront",
		"TopShelfBack",
		"MerchandisingRows/FrontShelfLip",
		"MerchandisingRows/BackShelfLip",
	]:
		assert_not_null(
			visual.get_node_or_null(required_path),
			"Default floor rack visual must include %s" % required_path
		)
	visual.free()


func test_console_box_default_uses_visual_only_retail_prop() -> void:
	assert_eq(
		StoreVisualKitScript.scene_path(StoreVisualKitScript.CONSOLE_BOX),
		PROP_CONSOLE_BOX_PATH
	)
	var visual: Node3D = StoreVisualKitScript.instantiate(
		StoreVisualKitScript.CONSOLE_BOX
	) as Node3D
	assert_not_null(visual, "Console box prop should instantiate")
	if visual == null:
		return
	assert_eq(visual.name, "PropConsoleBox")
	assert_true(bool(visual.get_meta("visual_only", false)))
	assert_false(
		_has_interaction_descendant(visual),
		"StoreVisualKit console prop must stay visual-only with no collision"
	)
	for required_path: String in [
		"BoxBody",
		"LidFlapTop",
		"FrontBrandingBand",
		"FrontIconPanel",
		"SideSpineLabel",
		"TopFlapSeam",
		"BottomFlapSeam",
		"ControllerBarSilhouette",
		"CableSilhouetteA",
	]:
		assert_not_null(
			visual.get_node_or_null(required_path),
			"Generic console box visual must include %s" % required_path
		)
	assert_gte(
		_count_mesh_descendants(visual),
		10,
		"Generic console box must be assembled from merchandise details"
	)

	var game_case: Node3D = (load(GAME_CASE_FIXTURE_PATH) as PackedScene).instantiate() as Node3D
	add_child_autofree(game_case)
	var console_bounds: AABB = MeshBoundsUtil.visual_bounds(visual)
	var case_bounds: AABB = MeshBoundsUtil.visual_bounds(game_case)
	assert_gt(
		console_bounds.size.x,
		case_bounds.size.x * 1.8,
		"Console box should read wider than game cases on displays"
	)
	assert_gt(
		console_bounds.size.z,
		case_bounds.size.z * 4.0,
		"Console box should have packaging depth unlike a flat game case"
	)
	visual.free()


func test_console_box_gameplay_fixture_retains_collision_split() -> void:
	var packed: PackedScene = load(CONSOLE_BOX_FIXTURE_PATH) as PackedScene
	assert_not_null(packed, "Gameplay console fixture scene must load")
	if packed == null:
		return
	var fixture: Node3D = packed.instantiate() as Node3D
	add_child_autofree(fixture)
	assert_eq(fixture.name, "ConsoleBox")
	for required_path: String in [
		"BoxBody",
		"LidFlapTop",
		"FrontBrandingBand",
		"SideSpineLabel",
		"ControllerBarSilhouette",
	]:
		assert_not_null(
			fixture.get_node_or_null(required_path),
			"Gameplay console fixture must keep visual detail %s" % required_path
		)
	var body: StaticBody3D = fixture.get_node_or_null("StaticBody3D") as StaticBody3D
	assert_not_null(body, "Gameplay console fixture keeps blocker collision")
	if body != null:
		assert_eq(body.collision_layer, 2)
		assert_eq(body.collision_mask, 0)


func test_starter_checkout_station_components_map_to_reusable_visuals() -> void:
	var components: Array[Dictionary] = StoreVisualKitScript.starter_checkout_station_components()
	assert_eq(components.size(), 4)
	var expected_visuals: Dictionary = {
		StoreVisualKitScript.STARTER_CHECKOUT_COUNTER: StoreVisualKitScript.CHECKOUT_COUNTER,
		StoreVisualKitScript.STARTER_REGISTER_TERMINAL: StoreVisualKitScript.REGISTER,
		StoreVisualKitScript.STARTER_CARD_READER: StoreVisualKitScript.CARD_READER,
		StoreVisualKitScript.STARTER_RECEIPT_PRINTER: StoreVisualKitScript.RECEIPT_PRINTER,
	}
	for component: Dictionary in components:
		var component_id: StringName = component.get("concept_id", &"") as StringName
		var visual_id: StringName = component.get("visual_id", &"") as StringName
		assert_eq(visual_id, expected_visuals.get(component_id, &""))
		assert_true(StoreVisualKitScript.has_visual(visual_id), "%s visual must resolve" % component_id)
		assert_true(bool(component.get("day_one_default", false)))


func test_starter_stockroom_shelf_instantiates_visual_only_storage_kit() -> void:
	var visual: Node3D = StoreVisualKitScript.instantiate(
		StoreVisualKitScript.STOCKROOM_SHELF
	) as Node3D
	assert_not_null(visual, "Starter stockroom shelf should instantiate")
	if visual == null:
		return
	assert_true(bool(visual.get_meta("visual_only", false)))
	for component: Dictionary in StoreVisualKitScript.starter_stockroom_shelf_components():
		var component_name: String = str(component.get("name", ""))
		var child: Node = visual.find_child(component_name, true, false)
		assert_not_null(child, "Stockroom shelf kit missing %s" % component_name)
		if child == null:
			continue
		assert_false(
			_has_interaction_descendant(child),
			"%s must stay visual-only with no interaction or physics descendants" % component_name
		)
	assert_gte(_count_children_with_prefix(visual, "StockroomSupplyBox"), 5)
	visual.free()


func test_starter_small_display_prop_components_are_visual_only() -> void:
	var expected_categories: Array[StringName] = [
		&"acrylic_stand",
		&"controller_bin",
		&"repair_testing_mat",
		&"clipboard_intake_slip",
		&"taped_box_label",
		&"security_tag_block",
	]
	var components: Array[Dictionary] = StoreVisualKitScript.starter_small_display_prop_components()
	assert_eq(components.size(), expected_categories.size())
	for component: Dictionary in components:
		var visual_id: StringName = component.get("visual_id", &"") as StringName
		var category: StringName = component.get("category", &"") as StringName
		assert_true(expected_categories.has(category), "%s category should be covered" % category)
		assert_true(StoreVisualKitScript.has_visual(visual_id), "%s visual must resolve" % visual_id)
		assert_true(bool(component.get("day_one_default", false)))
		var visual: Node3D = StoreVisualKitScript.instantiate(visual_id) as Node3D
		assert_not_null(visual, "%s should instantiate" % visual_id)
		if visual == null:
			continue
		add_child_autofree(visual)
		assert_true(bool(visual.get_meta("visual_only", false)))
		assert_eq(visual.get_meta("small_display_prop_category"), category)
		assert_false(
			_has_interaction_descendant(visual),
			"%s must stay visual-only with no interaction or physics descendants" % visual_id
		)
		assert_gte(
			_count_mesh_descendants(visual),
			2,
			"%s should include readable low-poly detail" % visual_id
		)


func test_decorative_controller_bin_stays_separate_from_gameplay_fixture_slots() -> void:
	var visual: Node3D = StoreVisualKitScript.instantiate(
		StoreVisualKitScript.CONTROLLER_BIN_PROP
	) as Node3D
	assert_not_null(visual, "Decorative controller bin should instantiate")
	if visual == null:
		return
	add_child_autofree(visual)
	assert_eq(visual.name, "PropControllerBin")
	assert_true(bool(visual.get_meta("visual_only", false)))
	assert_eq(str(visual.get_meta("small_display_prop_category", "")), "controller_bin")
	assert_eq(
		str(visual.get_meta("decorative_variant_for", "")),
		"res://game/scenes/stores/fixtures/controller_bin.tscn"
	)
	assert_false(
		_has_interaction_descendant(visual),
		"Decorative controller bin should not inherit gameplay collision or shelf slots"
	)
	assert_false(
		_has_controller_bin_slot_metadata(visual),
		"Decorative controller bin should not expose controller_bin_* shelf slots"
	)


func test_starter_shell_prop_visuals_are_library_backed() -> void:
	var starter_shell_ids: Array[StringName] = StoreVisualKitScript.starter_shell_prop_ids()
	assert_gte(
		starter_shell_ids.size(),
		12,
		"Starter shell prop kit should cover checkout, shelf, and stockroom objects"
	)
	for id: StringName in starter_shell_ids:
		var visual: Node = StoreVisualKitScript.instantiate(id)
		assert_not_null(visual, "%s should instantiate from the visual kit" % id)
		if visual == null:
			continue
		assert_ne(str(visual.name), "", "%s should instantiate with a visible node name" % id)
		visual.free()


func _count_children_with_prefix(parent: Node, prefix: String) -> int:
	var total := 0
	for child: Node in parent.get_children():
		if str(child.name).begins_with(prefix):
			total += 1
		total += _count_children_with_prefix(child, prefix)
	return total


func _count_mesh_descendants(parent: Node) -> int:
	var total := 0
	if parent is MeshInstance3D:
		total += 1
	for child: Node in parent.get_children():
		total += _count_mesh_descendants(child)
	return total


func _has_interaction_descendant(root: Node) -> bool:
	if (
		root is Area3D
		or root is CollisionObject3D
		or root is CollisionShape3D
		or root is NavigationObstacle3D
		or root is Interactable
	):
		return true
	for child: Node in root.get_children():
		if _has_interaction_descendant(child):
			return true
	return false


func _has_controller_bin_slot_metadata(root: Node) -> bool:
	if str(root.get("slot_id")).begins_with("controller_bin_"):
		return true
	for child: Node in root.get_children():
		if _has_controller_bin_slot_metadata(child):
			return true
	return false


func _assert_reusable_price_tag(root: Node, node_path: String) -> void:
	var tag: MeshInstance3D = root.get_node_or_null(node_path) as MeshInstance3D
	assert_not_null(tag, "%s should be a reusable price tag" % node_path)
	if tag == null:
		return
	assert_eq(str(tag.get_meta("store_visual_id", "")), "price_tag")
	var mesh: BoxMesh = tag.mesh as BoxMesh
	assert_not_null(mesh, "%s should keep the shared price tag mesh" % node_path)
