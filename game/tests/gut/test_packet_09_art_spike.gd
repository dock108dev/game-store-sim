extends GutTest

const PACKET_09_SCENE := "res://scenes/world/art_benchmark/packet_09_inside_out_art_spike.tscn"
const PACKET_09_CAPTURE_TOOL := "res://tests/tools/capture_packet_09_art_spike_screenshot.gd"


func test_packet_09_spike_scene_loads_with_required_review_anchors() -> void:
	var scene := _instantiate_scene(PACKET_09_SCENE)
	add_child_autofree(scene)
	await get_tree().process_frame

	for node_path in [
		"Packet09ArtRoot",
		"Packet09ArtRoot/ReferenceRuleMarkers",
		"Packet09ArtRoot/MallCorridorVisibleThroughGlass",
		"Packet09ArtRoot/StorefrontGlassSystem/ChunkyStorefrontFascia",
		"Packet09ArtRoot/StorefrontGlassSystem/BacklitGames4UFasciaPanel",
		"Packet09ArtRoot/StorefrontGlassSystem/FramedOpenGlassDoor",
		"Packet09ArtRoot/InteriorFirstFifteenFeet",
		"Packet09ArtRoot/DropCeilingGridWithFluorescents",
		"Packet09ArtRoot/SlatwallProductBayDenseCaseRows",
		"Packet09ArtRoot/CheckoutDisplayCaseAnchor",
		"Packet09ArtRoot/AttachedRetailSignageAndPriceLanguage",
		"Packet09ArtRoot/BenchmarkCameras/InsideOutHeroCamera",
		"Packet09ArtRoot/BenchmarkCameras/ShelfDensityCamera",
		"Packet09ArtRoot/BenchmarkCameras/StorefrontFrameCamera",
	]:
		assert_not_null(scene.get_node_or_null(node_path), node_path)


func test_packet_09_spike_records_reference_sources_and_rules() -> void:
	var scene := _instantiate_scene(PACKET_09_SCENE)
	add_child_autofree(scene)
	await get_tree().process_frame

	var markers := scene.get_node("Packet09ArtRoot/ReferenceRuleMarkers")
	var source_folders: PackedStringArray = markers.get_meta("source_folders")
	var rules: PackedStringArray = markers.get_meta("visual_rules")

	assert_true(source_folders.has("inspiration"))
	assert_true(source_folders.has("new_real_inspiration"))
	assert_string_contains(" ".join(rules), "drop ceiling")
	assert_string_contains(" ".join(rules), "orderly case rows")
	assert_string_contains(" ".join(rules), "less text")
	assert_string_contains(" ".join(rules), "inside-looking-out")


func test_packet_09_spike_uses_bitmap_signs_not_loose_3d_text() -> void:
	var scene := _instantiate_scene(PACKET_09_SCENE)
	add_child_autofree(scene)
	await get_tree().process_frame

	var labels: Array[Label3D] = []
	var text_meshes: Array[MeshInstance3D] = []
	var bitmap_signs: Array[Node] = []
	_collect_labels(scene, labels)
	_collect_text_mesh_instances(scene, text_meshes)
	_collect_name_contains(scene, "Bitmap", bitmap_signs)

	assert_eq(labels.size(), 0)
	assert_eq(text_meshes.size(), 0)
	assert_gte(bitmap_signs.size(), 8)


func test_packet_09_spike_keeps_walls_clean_of_random_promo_clutter() -> void:
	var scene := _instantiate_scene(PACKET_09_SCENE)
	add_child_autofree(scene)
	await get_tree().process_frame

	var random_promo_panels: Array[Node] = []
	var window_decals: Array[Node] = []
	_collect_name_contains(scene, "PromoWallPanel", random_promo_panels)
	_collect_name_contains(scene, "WindowDecal", window_decals)

	assert_eq(random_promo_panels.size(), 0)
	assert_lte(window_decals.size(), 2)


func test_packet_09_spike_has_retail_density_and_material_breaks() -> void:
	var scene := _instantiate_scene(PACKET_09_SCENE)
	add_child_autofree(scene)
	await get_tree().process_frame

	var product_facings: Array[Node] = []
	var price_stickers: Array[Node] = []
	var ceiling_details: Array[Node] = []
	var glass_nodes: Array[Node] = []
	_collect_name_contains(scene, "DenseCaseFacing", product_facings)
	_collect_name_contains(scene, "YellowPriceSticker", price_stickers)
	_collect_name_contains(scene, "CeilingGridRunner", ceiling_details)
	_collect_name_contains(scene, "Glass", glass_nodes)

	assert_gte(product_facings.size(), 80)
	assert_gte(price_stickers.size(), 20)
	assert_gte(ceiling_details.size(), 9)
	assert_gte(glass_nodes.size(), 8)


func test_packet_09_capture_tool_exists_outside_main_validation_gate() -> void:
	assert_true(FileAccess.file_exists(PACKET_09_CAPTURE_TOOL))
	var capture_text := FileAccess.get_file_as_string(PACKET_09_CAPTURE_TOOL)
	assert_string_contains(capture_text, "packet_09_inside_out_art_spike.tscn")
	assert_string_contains(capture_text, "packet_09_inside_out_art_spike.png")


func _instantiate_scene(scene_path: String) -> Node:
	var packed := load(scene_path) as PackedScene
	assert_not_null(packed, scene_path)
	var instance := packed.instantiate()
	assert_not_null(instance, scene_path)
	return instance


func _collect_labels(node: Node, found: Array[Label3D]) -> void:
	if node is Label3D and (node as Label3D).is_visible_in_tree():
		found.append(node as Label3D)
	for child in node.get_children():
		_collect_labels(child, found)


func _collect_text_mesh_instances(node: Node, found: Array[MeshInstance3D]) -> void:
	if node is MeshInstance3D and (node as MeshInstance3D).mesh is TextMesh:
		found.append(node as MeshInstance3D)
	for child in node.get_children():
		_collect_text_mesh_instances(child, found)


func _collect_name_contains(node: Node, pattern: String, found: Array[Node]) -> void:
	if node.name.contains(pattern):
		found.append(node)
	for child in node.get_children():
		_collect_name_contains(child, pattern, found)
