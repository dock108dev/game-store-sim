extends GutTest

const _CATALOG_PATH := "res://game/content/visuals/retro_games_product_visual_catalog.json"
const _EXPECTED_TYPE := "product_visual_catalog_data"
const ProductVisualCatalogScript: GDScript = preload(
	"res://game/scripts/visuals/product_visual_catalog.gd"
)
const ProductVisualFactoryScript: GDScript = preload(
	"res://game/scripts/visuals/product_visual_factory.gd"
)
const _FORBIDDEN_REAL_WORLD_TERMS := [
	"nintendo",
	"playstation",
	"xbox",
	"sony",
	"microsoft",
	"sega",
	"gamecube",
	"wii",
	"switch",
	"psp",
	"dualshock",
]

var _catalog: Dictionary = {}


func before_all() -> void:
	_catalog = _load_catalog()


func test_catalog_declares_visual_only_content_type() -> void:
	assert_eq(_catalog.get("type", ""), _EXPECTED_TYPE)
	assert_eq(_catalog.get("store_id", ""), "retro_games")
	assert_true(
		bool(_catalog.get("resource_contract", {}).get("visual_only", false)),
		"Product visual catalog must stay visual-only"
	)


func test_box_templates_define_reusable_cover_metadata() -> void:
	var templates: Array = _catalog.get("game_box_templates", [])
	assert_between(
		templates.size(), 4, 10, "Catalog should define a focused set of reusable box templates"
	)

	var template_ids: Dictionary = {}
	var display_titles: Dictionary = {}
	var platform_visual_ids: Dictionary = _collect_ids(
		_catalog.get("platform_visual_identities", []), "platform_visual_id"
	)
	for raw_template: Variant in templates:
		assert_true(raw_template is Dictionary, "Each box template must be a Dictionary")
		if raw_template is not Dictionary:
			continue
		var template: Dictionary = raw_template
		var template_id: String = str(template.get("template_id", ""))
		assert_ne(template_id, "", "Box template must expose template_id")
		assert_false(template_ids.has(template_id), "Duplicate box template: %s" % template_id)
		template_ids[template_id] = true
		var display_title: String = str(template.get("display_title", ""))
		assert_ne(display_title, "", "%s must expose display_title" % template_id)
		display_titles[display_title] = true

		for key: String in [
			"display_title",
			"front_color",
			"title_block",
			"simple_symbol",
			"spine_color",
			"spine_label",
			"shelf_display",
		]:
			assert_true(template.has(key), "%s missing %s" % [template_id, key])

		var spine_label: Dictionary = template.get("spine_label", {})
		assert_ne(
			str(spine_label.get("text", "")),
			"",
			"%s must define readable spine title text" % template_id
		)
		assert_ne(
			str(spine_label.get("platform_text", "")),
			"",
			"%s must define readable spine platform text" % template_id
		)
		assert_ne(
			str(spine_label.get("text_color", "")),
			"",
			"%s must define spine label contrast color" % template_id
		)

		var stripe: Dictionary = template.get("platform_stripe", {})
		if not stripe.is_empty():
			var platform_visual_id: String = str(stripe.get("platform_visual_id", ""))
			assert_true(
				platform_visual_ids.has(platform_visual_id),
				"%s references unknown platform visual %s" % [template_id, platform_visual_id]
			)
	assert_between(
		display_titles.size(),
		4,
		9,
		"Catalog should expose a restrained set of distinct fictional product titles"
	)


func test_platform_identities_have_distinct_silhouettes_and_labels() -> void:
	var identities: Array = _catalog.get("platform_visual_identities", [])
	assert_gte(
		identities.size(),
		5,
		"Catalog should cover each canonical retro-games platform visual identity"
	)

	var platform_ids: Dictionary = {}
	var silhouette_shapes: Dictionary = {}
	for raw_identity: Variant in identities:
		assert_true(raw_identity is Dictionary, "Each platform identity must be a Dictionary")
		if raw_identity is not Dictionary:
			continue
		var identity: Dictionary = raw_identity
		var visual_id: String = str(identity.get("platform_visual_id", ""))
		var platform_id: String = str(identity.get("platform_id", ""))
		var used_console_label: String = str(identity.get("used_console_label", ""))
		var shelf_label: String = str(identity.get("shelf_label", ""))
		var silhouette: Dictionary = identity.get("silhouette", {})
		var shape: String = str(silhouette.get("shape", ""))

		assert_ne(visual_id, "", "Platform identity must expose platform_visual_id")
		assert_ne(platform_id, "", "%s must map to a canonical platform_id" % visual_id)
		assert_ne(used_console_label, "", "%s must have a Used Consoles label" % visual_id)
		assert_ne(shelf_label, "", "%s must have a shelf label" % visual_id)
		assert_ne(shape, "", "%s must have a silhouette shape" % visual_id)
		assert_false(
			silhouette_shapes.has(shape),
			"Platform silhouettes must stay distinct; duplicate shape %s" % shape
		)

		platform_ids[platform_id] = true
		silhouette_shapes[shape] = true

	for required_platform: String in [
		"neo_ignite",
		"canopy_wave",
		"vecforce_hd",
		"wave_pocket",
		"ignite_go",
	]:
		assert_true(
			platform_ids.has(required_platform),
			"Missing visual identity for %s" % required_platform
		)


func test_aliases_resolve_to_catalog_visuals() -> void:
	var template_ids: Dictionary = _collect_ids(
		_catalog.get("game_box_templates", []), "template_id"
	)
	var platform_visual_ids: Dictionary = _collect_ids(
		_catalog.get("platform_visual_identities", []), "platform_visual_id"
	)

	for raw_alias: Variant in _catalog.get("visual_aliases", []):
		assert_true(raw_alias is Dictionary, "Each visual alias must be a Dictionary")
		if raw_alias is not Dictionary:
			continue
		var alias: Dictionary = raw_alias
		var box_art_key: String = str(alias.get("box_art_key", ""))
		var platform_visual_id: String = str(alias.get("platform_visual_id", ""))
		assert_true(
			template_ids.has(box_art_key),
			"Alias %s references unknown box art key %s" % [alias.get("alias_id", ""), box_art_key]
		)
		assert_true(
			platform_visual_ids.has(platform_visual_id),
			(
				"Alias %s references unknown platform visual %s"
				% [alias.get("alias_id", ""), platform_visual_id]
			)
		)


func test_runtime_lookup_resolves_known_definition_and_metadata() -> void:
	var catalog: RefCounted = ProductVisualCatalogScript.new()
	catalog.load_from_dictionary(_catalog)

	var by_definition: Dictionary = catalog.find_template_for_item(
		{"definition_id": "neo_ignite_motorway_kings_loose", "category": "cartridge"}
	)
	assert_eq(
		by_definition.get("template_id", ""),
		"motorway_kings_neo_ignite",
		"Known definition IDs must resolve to designed case templates"
	)

	var by_box_art: Dictionary = catalog.find_template_for_item(
		{"box_art_key": "brain_drill_wave_pocket", "category": "cartridge"}
	)
	assert_eq(
		by_box_art.get("template_id", ""),
		"brain_drill_wave_pocket",
		"Explicit box_art_key must win the product visual lookup"
	)


func test_runtime_lookup_normalizes_plural_category_fallbacks() -> void:
	var catalog: RefCounted = ProductVisualCatalogScript.new()
	catalog.load_from_dictionary(_catalog)

	var by_plural_category: Dictionary = catalog.find_template_for_item(
		{"category": "cartridges"}
	)

	assert_eq(
		by_plural_category.get("template_id", ""),
		"motorway_kings_neo_ignite",
		"Plural content categories must resolve through the shared normalizer"
	)


func test_product_visual_factory_builds_case_and_console_nodes() -> void:
	var catalog: RefCounted = ProductVisualCatalogScript.new()
	catalog.load_from_dictionary(_catalog)

	var case_node: Node3D = ProductVisualFactoryScript.create_visual_for_item_with_catalog(
		{
			"definition_id": "neo_ignite_motorway_kings_loose",
			"category": "cartridge",
			"platform_id": "neo_ignite",
			"platform_visual_id": "neo_ignite_disc_tower",
			"box_art_key": "motorway_kings_neo_ignite",
			"visual_alias_id": "starter_motorway_kings",
		},
		catalog
	)
	assert_not_null(case_node, "Known game metadata must build a case node")
	if case_node != null:
		assert_eq(String(case_node.name), "ProductVisualCaseRoot")
		assert_eq(str(case_node.get_meta("platform_id", "")), "neo_ignite")
		assert_eq(
			str(case_node.get_meta("platform_visual_id", "")),
			"neo_ignite_disc_tower"
		)
		assert_eq(
			str(case_node.get_meta("box_art_key", "")),
			"motorway_kings_neo_ignite"
		)
		assert_eq(
			str(case_node.get_meta("visual_alias_id", "")),
			"starter_motorway_kings"
		)
		for child_name: String in [
			"CaseBody",
			"FrontPanel",
			"SpinePanel",
			"SpineTitleLabel",
			"SpinePlatformLabel",
			"PlatformStripe",
			"TitleBlock",
			"SymbolMark",
			"TitleLabel",
			"PlatformLabel",
		]:
			assert_not_null(
				case_node.get_node_or_null(child_name),
				"Designed case missing reusable element %s" % child_name
			)
		var spine_title := case_node.get_node_or_null("SpineTitleLabel") as Label3D
		var spine_platform := case_node.get_node_or_null("SpinePlatformLabel") as Label3D
		assert_not_null(spine_title, "Designed case must expose a readable spine title")
		assert_not_null(spine_platform, "Designed case must expose a readable spine platform")
		if spine_title != null:
			assert_eq(spine_title.text, "MOTORWAY KINGS")
			assert_almost_eq(spine_title.rotation.z, deg_to_rad(90.0), 0.001)
		if spine_platform != null:
			assert_eq(spine_platform.text, "NEO IGNITE")
		case_node.free()

	var priced_node: Node3D = ProductVisualFactoryScript.create_visual_for_item_with_catalog(
		{
			"definition_id": "neo_ignite_kingdom_embers_loose",
			"category": "cartridges",
			"show_price_tag": true,
			"price_cents": 1800,
			"route_role": "starter_sale_item",
		},
		catalog
	)
	assert_not_null(priced_node, "Starter product metadata must build a priced case")
	if priced_node != null:
		assert_eq(str(priced_node.get_meta("definition_id", "")), "neo_ignite_kingdom_embers_loose")
		assert_eq(str(priced_node.get_meta("route_role", "")), "starter_sale_item")
		assert_not_null(priced_node.get_node_or_null("ProductPriceTag"))
		priced_node.free()

	var console_node: Node3D = ProductVisualFactoryScript.create_visual_for_item_with_catalog(
		{"category": "console", "platform_visual_id": "canopy_wave_cube"}, catalog
	)
	assert_not_null(console_node, "Known console metadata must build a console box")
	if console_node != null:
		assert_eq(String(console_node.name), "ProductVisualConsoleBoxRoot")
		for child_name: String in [
			"ConsoleBoxBody",
			"ConsoleColorStripe",
			"ConsoleIconMark",
			"ConsoleSideSpineLabel",
			"ConsoleControllerSilhouette",
			"ConsoleCableSilhouette",
			"ConsolePlatformLabel",
		]:
			assert_not_null(
				console_node.get_node_or_null(child_name),
				"Console box missing reusable element %s" % child_name
			)
		console_node.free()


func test_starter_console_items_use_catalog_backed_console_box_visuals() -> void:
	var catalog: RefCounted = ProductVisualCatalogScript.new()
	catalog.load_from_dictionary(_catalog)

	var console_node: Node3D = ProductVisualFactoryScript.create_visual_for_item_with_catalog(
		{
			"definition_id": "console_neo_ignite",
			"display_name": "Neo Ignite Console (Working)",
			"category": "consoles",
			"platform_id": "neo_ignite",
			"platform_visual_id": "neo_ignite_disc_tower",
			"route_role": "starter_sale_item",
		},
		catalog
	)
	assert_not_null(console_node, "Starter console metadata must build a console box")
	if console_node == null:
		return
	assert_eq(String(console_node.name), "ProductVisualConsoleBoxRoot")
	assert_eq(str(console_node.get_meta("visual_source", "")), "product_visual_factory")
	assert_eq(str(console_node.get_meta("definition_id", "")), "console_neo_ignite")
	assert_eq(str(console_node.get_meta("category", "")), "console")
	assert_eq(str(console_node.get_meta("platform_visual_id", "")), "neo_ignite_disc_tower")
	for child_name: String in [
		"ConsoleBoxBody",
		"ConsoleLabelPlate",
		"ConsoleSideSpineLabel",
		"ConsoleSideSpineStripe",
		"ConsoleBoxTopSeam",
		"ConsoleBoxBottomSeam",
		"ConsoleControllerSilhouette",
		"ConsoleCableSilhouette",
		"ConsolePlatformLabel",
	]:
		assert_not_null(
			console_node.get_node_or_null(child_name),
			"Starter console visual missing catalog-backed element %s" % child_name
		)
	console_node.free()


func test_product_visual_factory_builds_distinct_case_and_cartridge_defaults() -> void:
	var catalog: RefCounted = ProductVisualCatalogScript.new()
	catalog.load_from_dictionary(_catalog)

	var case_node: Node3D = ProductVisualFactoryScript.create_visual_for_item_with_catalog(
		{"category": "cartridge"}, catalog
	)
	var cartridge_node: Node3D = ProductVisualFactoryScript.create_visual_for_item_with_catalog(
		{
			"category": "cartridge",
			"platform_visual_id": "neo_ignite_disc_tower",
			"visual_presentation": "cartridge",
			"display_name": "Loose Starter Cart",
		},
		catalog
	)

	assert_not_null(case_node, "Generic cartridge metadata must build a case fallback")
	assert_not_null(
		cartridge_node,
		"Explicit cartridge presentation must build a loose cartridge fallback"
	)
	if case_node != null and cartridge_node != null:
		assert_eq(String(case_node.name), "ProductVisualCaseRoot")
		assert_eq(String(cartridge_node.name), "ProductVisualCartridgeRoot")
		var case_size: Vector3 = _box_mesh_size(case_node, "CaseBody")
		var cartridge_size: Vector3 = _box_mesh_size(cartridge_node, "CartridgeShell")
		assert_gt(
			case_size.y,
			cartridge_size.y * 1.5,
			"Case fallback must be visibly taller than loose cartridge fallback"
		)
		assert_gt(
			absf(case_size.z - cartridge_size.z),
			0.001,
			"Case and loose cartridge fallbacks must have distinct depth"
		)
		assert_not_null(cartridge_node.get_node_or_null("CartridgeContactStrip"))
		assert_not_null(cartridge_node.get_node_or_null("CartridgeTitleLabel"))
	if case_node != null:
		case_node.free()
	if cartridge_node != null:
		cartridge_node.free()


func test_catalog_metadata_can_request_cartridge_presentation() -> void:
	var catalog: RefCounted = ProductVisualCatalogScript.new()
	catalog.load_from_dictionary(_catalog)

	var node: Node3D = ProductVisualFactoryScript.create_visual_for_item_with_catalog(
		{
			"definition_id": "neo_ignite_gridiron_2005_loose",
			"category": "cartridges",
			"platform_id": "neo_ignite",
			"platform_visual_id": "neo_ignite_disc_tower",
			"visual_presentation": "cartridge",
		},
		catalog
	)

	assert_not_null(node, "Catalog-backed starter item can request cartridge presentation")
	if node != null:
		assert_eq(String(node.name), "ProductVisualCartridgeRoot")
		assert_eq(str(node.get_meta("visual_presentation", "")), "cartridge")
		assert_eq(str(node.get_meta("definition_id", "")), "neo_ignite_gridiron_2005_loose")
		node.free()


func test_case_templates_use_consistent_front_and_spine_facing() -> void:
	var catalog: RefCounted = ProductVisualCatalogScript.new()
	catalog.load_from_dictionary(_catalog)

	var front_case: Node3D = ProductVisualFactoryScript.create_visual_for_item_with_catalog(
		{"box_art_key": "star_pantry_rangers_vecforce_hd", "category": "cartridge"}, catalog
	)
	var spine_case: Node3D = ProductVisualFactoryScript.create_visual_for_item_with_catalog(
		{"box_art_key": "signal_warden_zero_ignite_go", "category": "cartridge"}, catalog
	)

	assert_not_null(front_case, "Front-facing product template must build")
	assert_not_null(spine_case, "Spine-facing product template must build")
	if front_case != null:
		assert_almost_eq(front_case.rotation.y, 0.0, 0.001)
		front_case.free()
	if spine_case != null:
		assert_almost_eq(spine_case.rotation.y, deg_to_rad(82.0), 0.001)
		spine_case.free()


func test_product_cases_spawn_from_wall_shelf_and_display_table_slots() -> void:
	_assert_fixture_slot_renders_case(
		"res://game/scenes/stores/fixtures/retail_wall_shelf.tscn",
		"wall_shelf_1",
		"motorway_kings_neo_ignite"
	)
	_assert_fixture_slot_renders_case(
		"res://game/scenes/stores/fixtures/display_table.tscn",
		"display_table_1",
		"star_pantry_rangers_vecforce_hd"
	)
	_assert_fixture_slot_renders_case(
		"res://game/scenes/stores/fixtures/fixture_display_table.tscn",
		"display_table_2",
		"goblin_kart_canopy_wave"
	)


func test_unknown_visual_metadata_returns_no_designed_node() -> void:
	var catalog: RefCounted = ProductVisualCatalogScript.new()
	catalog.load_from_dictionary(_catalog)

	var node: Node3D = ProductVisualFactoryScript.create_visual_for_item_with_catalog(
		{"box_art_key": "missing_key", "category": "guide"}, catalog
	)
	assert_null(node, "Unknown non-case metadata must leave fallback ownership to caller")


func test_authored_scene_mappings_resolve_or_document_fallbacks() -> void:
	var template_ids: Dictionary = _collect_ids(
		_catalog.get("game_box_templates", []), "template_id"
	)
	var platform_visual_ids: Dictionary = _collect_ids(
		_catalog.get("platform_visual_identities", []), "platform_visual_id"
	)
	var scene: PackedScene = load("res://game/scenes/stores/retro_games.tscn")
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node = scene.instantiate()
	assert_not_null(root, "retro_games.tscn must instantiate")
	if root == null:
		return

	for raw_mapping: Variant in _catalog.get("authored_scene_mappings", []):
		assert_true(raw_mapping is Dictionary, "Scene mappings must be dictionaries")
		if raw_mapping is not Dictionary:
			continue
		var mapping: Dictionary = raw_mapping
		assert_ne(
			str(mapping.get("visual_fallback", "")),
			"",
			"Scene mapping must document its visual-only fallback"
		)
		var node_path: String = str(mapping.get("node_path", ""))
		if node_path != "ShelfSlot":
			assert_not_null(
				root.get_node_or_null(node_path),
				"Mapped authored display node missing: %s" % node_path
			)
		var box_art_key: String = str(mapping.get("box_art_key", ""))
		if not box_art_key.is_empty():
			assert_true(
				template_ids.has(box_art_key),
				"Scene mapping references unknown template %s" % box_art_key
			)
		var platform_visual_id: String = str(mapping.get("platform_visual_id", ""))
		if not platform_visual_id.is_empty():
			assert_true(
				platform_visual_ids.has(platform_visual_id),
				"Scene mapping references unknown platform visual %s" % platform_visual_id
			)
	root.free()


func test_catalog_does_not_introduce_real_world_product_terms() -> void:
	var text: String = _read_catalog_text().to_lower()
	for term: String in _FORBIDDEN_REAL_WORLD_TERMS:
		assert_false(
			text.contains(term),
			"Product visual catalog must not contain real-world product term: %s" % term
		)


func test_canonical_content_loader_accepts_visual_catalog_type() -> void:
	DataLoaderSingleton.clear_for_testing()
	ContentRegistry.clear_for_testing()
	DataLoaderSingleton.load_all_content()
	var errors: Array[String] = DataLoaderSingleton.get_load_errors()
	assert_eq(
		errors.size(),
		0,
		"Canonical content, including visual catalog, must load without errors: %s" % [errors]
	)


func test_catalog_loader_surfaces_load_error_as_warning() -> void:
	var source: String = _read_source_text(
		"res://game/scripts/visuals/product_visual_catalog.gd"
	)
	assert_string_contains(source, "push_warning(catalog.load_error)")
	assert_string_contains(source, "Product visual catalog missing")
	assert_string_contains(source, "Product visual catalog did not parse")


func _load_catalog() -> Dictionary:
	var text: String = _read_catalog_text()
	var parsed: Variant = JSON.parse_string(text)
	assert_true(parsed is Dictionary, "Product visual catalog must parse as a Dictionary")
	if parsed is Dictionary:
		return parsed
	return {}


func _read_catalog_text() -> String:
	var file: FileAccess = FileAccess.open(_CATALOG_PATH, FileAccess.READ)
	assert_not_null(file, "Should open product visual catalog")
	if file == null:
		return ""
	var text: String = file.get_as_text()
	file.close()
	return text


func _read_source_text(path: String) -> String:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	assert_not_null(file, "Source file should open: %s" % path)
	if file == null:
		return ""
	var text: String = file.get_as_text()
	file.close()
	return text


func _collect_ids(entries: Array, id_key: String) -> Dictionary:
	var ids: Dictionary = {}
	for raw_entry: Variant in entries:
		if raw_entry is not Dictionary:
			continue
		var entry: Dictionary = raw_entry
		var id: String = str(entry.get(id_key, ""))
		if id != "":
			ids[id] = true
	return ids


func _box_mesh_size(root: Node, child_name: String) -> Vector3:
	var mesh_instance: MeshInstance3D = root.get_node_or_null(child_name) as MeshInstance3D
	assert_not_null(mesh_instance, "%s must exist" % child_name)
	if mesh_instance == null or mesh_instance.mesh is not BoxMesh:
		return Vector3.ZERO
	var box: BoxMesh = mesh_instance.mesh as BoxMesh
	return box.size


func _assert_fixture_slot_renders_case(
	scene_path: String, slot_id: String, box_art_key: String
) -> void:
	var packed: PackedScene = load(scene_path)
	assert_not_null(packed, "%s must load" % scene_path)
	if packed == null:
		return
	var fixture: Node = packed.instantiate()
	assert_not_null(fixture, "%s must instantiate" % scene_path)
	if fixture == null:
		return
	var slot: ShelfSlot = _find_slot_by_id(fixture, slot_id)
	assert_not_null(slot, "%s must expose slot %s" % [scene_path, slot_id])
	if slot != null:
		var item_data: Dictionary = {
			"instance_id": "%s_case" % slot_id,
			"category": "cartridge",
			"box_art_key": box_art_key,
		}
		var placed: bool = slot.place_item_with_data(item_data)
		assert_true(placed, "%s should accept catalog-backed product cases" % slot_id)
		assert_not_null(slot._item_node, "%s must spawn a product visual" % slot_id)
		if slot._item_node != null:
			assert_eq(String(slot._item_node.name), "ProductVisualCaseRoot")
			assert_not_null(slot._item_node.get_node_or_null("SpineTitleLabel"))
	fixture.free()


func _find_slot_by_id(root: Node, slot_id: String) -> ShelfSlot:
	for child: Node in root.find_children("*", "ShelfSlot", true, false):
		var slot := child as ShelfSlot
		if slot != null and slot.slot_id == slot_id:
			return slot
	return null
