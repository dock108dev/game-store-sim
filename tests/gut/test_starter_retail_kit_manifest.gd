extends GutTest

const StarterRetailKitManifestScript: GDScript = preload(
	"res://game/scripts/visuals/starter_retail_kit_manifest.gd"
)
const StoreVisualKitScript: GDScript = preload("res://game/scripts/visuals/store_visual_kit.gd")

const FIXTURE_CATALOG_PATH: String = "res://game/content/fixtures.json"
const VISUAL_LAYOUT_PATH: String = "res://game/content/visuals/store_visual_layouts.json"

const EXPECTED_CONCEPTS: Array[StringName] = [
	&"starter_checkout_counter",
	&"starter_register_terminal",
	&"starter_card_reader",
	&"starter_receipt_printer",
	&"starter_wall_shelf",
	&"starter_gondola_shelf",
	&"starter_display_table",
	&"starter_stockroom_shelf",
	&"starter_receiving_table",
	&"starter_game_case",
	&"starter_cartridge",
	&"starter_console_box",
	&"starter_price_tag",
	&"starter_shelf_label",
	&"starter_acrylic_stand",
	&"starter_controller_bin",
	&"starter_repair_testing_mat",
	&"starter_clipboard_intake_slip",
	&"starter_taped_box_label",
	&"starter_security_tag_block",
]


func test_manifest_covers_named_starter_kit_concepts() -> void:
	var concepts: Array[StringName] = StarterRetailKitManifestScript.concept_ids()
	for concept_id: StringName in EXPECTED_CONCEPTS:
		assert_true(concepts.has(concept_id), "%s must be covered by the manifest" % concept_id)
	assert_eq(concepts.size(), EXPECTED_CONCEPTS.size())


func test_manifest_keeps_concept_visual_layout_and_build_ids_separate() -> void:
	for concept_id: StringName in EXPECTED_CONCEPTS:
		var entry: Dictionary = StarterRetailKitManifestScript.entry(concept_id)
		assert_true(String(concept_id).begins_with("starter_"))
		assert_false(str(entry.get("owner_scope", "")).is_empty())
		assert_false(str(entry.get("canonical_path", "")).is_empty())
		var visual_id: String = str(entry.get("store_visual_id", ""))
		var layout_fixture_id: String = str(entry.get("layout_fixture_id", ""))
		var build_fixture_id: String = str(entry.get("build_fixture_id", ""))
		if not visual_id.is_empty():
			assert_false(visual_id.begins_with("starter_"))
		if not layout_fixture_id.is_empty():
			assert_true(layout_fixture_id.begins_with("starter_"))
		if not build_fixture_id.is_empty():
			assert_false(build_fixture_id.begins_with("starter_"))


func test_manifest_visual_mappings_resolve_to_reusable_sources() -> void:
	for concept_id: StringName in EXPECTED_CONCEPTS:
		var entry: Dictionary = StarterRetailKitManifestScript.entry(concept_id)
		var visual_id: StringName = StringName(str(entry.get("store_visual_id", "")))
		if not String(visual_id).is_empty():
			assert_true(StoreVisualKitScript.has_visual(visual_id), "%s visual must resolve" % concept_id)
		for raw_variant: Variant in entry.get("variant_visual_ids", []):
			var variant_id: StringName = raw_variant as StringName
			assert_true(
				StoreVisualKitScript.has_visual(variant_id),
				"%s variant %s must resolve" % [concept_id, variant_id]
			)
		var path: String = str(entry.get("canonical_path", ""))
		assert_true(
			ResourceLoader.exists(path) or FileAccess.file_exists(path),
			"%s canonical path must exist: %s" % [concept_id, path]
		)


func test_product_defaults_have_separate_manifest_entries() -> void:
	var game_case: Dictionary = StarterRetailKitManifestScript.entry(&"starter_game_case")
	var cartridge: Dictionary = StarterRetailKitManifestScript.entry(&"starter_cartridge")

	assert_eq(str(game_case.get("source_kind", "")), "product_visual_factory")
	assert_eq(str(cartridge.get("source_kind", "")), "product_visual_factory")
	assert_ne(
		game_case.get("store_visual_id", &"") as StringName,
		cartridge.get("store_visual_id", &"") as StringName,
		"Case and cartridge starter defaults must remain separate visual concepts"
	)
	assert_true(
		(cartridge.get("variant_visual_ids", []) as Array).has(
			StoreVisualKitScript.GLTF_CARTRIDGE_N64
		)
	)


func test_label_and_price_tag_concepts_route_to_visual_kit_without_build_fixtures() -> void:
	var price_tag: Dictionary = StarterRetailKitManifestScript.entry(&"starter_price_tag")
	var shelf_label: Dictionary = StarterRetailKitManifestScript.entry(&"starter_shelf_label")

	assert_eq(price_tag.get("store_visual_id", &"") as StringName, StoreVisualKitScript.PRICE_TAG)
	assert_true(
		(price_tag.get("variant_visual_ids", []) as Array).has(
			StoreVisualKitScript.PRODUCT_PRICE_TAG
		)
	)
	assert_eq(price_tag.get("build_fixture_id", &"") as StringName, &"")
	assert_eq(shelf_label.get("store_visual_id", &"") as StringName, StoreVisualKitScript.SHELF_LABEL)
	assert_eq(shelf_label.get("build_fixture_id", &"") as StringName, &"")


func test_small_display_prop_concepts_route_to_visual_only_kit_pieces() -> void:
	var expected_visuals: Dictionary = {
		&"starter_acrylic_stand": StoreVisualKitScript.ACRYLIC_STAND,
		&"starter_controller_bin": StoreVisualKitScript.CONTROLLER_BIN_PROP,
		&"starter_repair_testing_mat": StoreVisualKitScript.REPAIR_TESTING_MAT,
		&"starter_clipboard_intake_slip": StoreVisualKitScript.CLIPBOARD,
		&"starter_taped_box_label": StoreVisualKitScript.TAPED_BOX_LABEL,
		&"starter_security_tag_block": StoreVisualKitScript.SECURITY_TAG_BLOCK,
	}
	for concept_id: StringName in expected_visuals.keys():
		var entry: Dictionary = StarterRetailKitManifestScript.entry(concept_id)
		assert_eq(
			entry.get("store_visual_id", &"") as StringName,
			expected_visuals.get(concept_id, &"") as StringName
		)
		assert_eq(entry.get("build_fixture_id", &"") as StringName, &"")
		assert_false(str(entry.get("canonical_path", "")).is_empty())


func test_layout_owned_starter_fixtures_match_manifest_routes() -> void:
	var placements_by_fixture_id: Dictionary = _starter_layout_placements_by_fixture_id()
	for concept_id: StringName in [
		&"starter_checkout_counter",
		&"starter_register_terminal",
		&"starter_card_reader",
		&"starter_receipt_printer",
		&"starter_display_table",
	]:
		var entry: Dictionary = StarterRetailKitManifestScript.entry(concept_id)
		var layout_fixture_id: String = str(entry.get("layout_fixture_id", ""))
		var placement: Dictionary = placements_by_fixture_id.get(layout_fixture_id, {})
		assert_false(placement.is_empty(), "%s must exist in the starter layout" % layout_fixture_id)
		assert_eq(str(placement.get("visual_id", "")), str(entry.get("store_visual_id", "")))
		var build_fixture_id: String = str(entry.get("build_fixture_id", ""))
		if not build_fixture_id.is_empty():
			assert_eq(str(placement.get("fixture_type", "")), build_fixture_id)
		else:
			assert_true(bool(placement.get("visual_only", false)))
		assert_true(bool(placement.get("starter_owned", false)))


func test_build_fixture_catalog_has_no_starter_prefixed_duplicates() -> void:
	var build_fixture_ids: PackedStringArray = _build_fixture_ids()
	for fixture_id: String in build_fixture_ids:
		assert_false(
			fixture_id.begins_with("starter_"),
			"Starter-owned instances must not become build fixture definitions"
		)
	for concept_id: StringName in EXPECTED_CONCEPTS:
		var entry: Dictionary = StarterRetailKitManifestScript.entry(concept_id)
		var build_fixture_id: String = str(entry.get("build_fixture_id", ""))
		if build_fixture_id.is_empty():
			continue
		assert_true(
			build_fixture_ids.has(build_fixture_id),
			"%s build fixture %s must exist" % [concept_id, build_fixture_id]
		)


func test_alias_tables_do_not_promote_visual_only_props_to_build_fixtures() -> void:
	var visual_aliases: Dictionary = StarterRetailKitManifestScript.starter_visual_aliases()
	var build_aliases: Dictionary = StarterRetailKitManifestScript.starter_build_fixture_aliases()
	for concept_id: StringName in EXPECTED_CONCEPTS:
		if visual_aliases.has(concept_id):
			var visual_id: StringName = visual_aliases.get(concept_id, &"") as StringName
			assert_true(StoreVisualKitScript.has_visual(visual_id))
		var entry: Dictionary = StarterRetailKitManifestScript.entry(concept_id)
		var build_fixture_id: String = str(entry.get("build_fixture_id", ""))
		assert_eq(build_aliases.has(concept_id), not build_fixture_id.is_empty())
	for visual_only_id: StringName in [
		&"starter_card_reader",
		&"starter_receipt_printer",
		&"starter_game_case",
		&"starter_cartridge",
		&"starter_console_box",
		&"starter_price_tag",
		&"starter_shelf_label",
		&"starter_acrylic_stand",
		&"starter_controller_bin",
		&"starter_repair_testing_mat",
		&"starter_clipboard_intake_slip",
		&"starter_taped_box_label",
		&"starter_security_tag_block",
	]:
		assert_false(build_aliases.has(visual_only_id))


func _starter_layout_placements_by_fixture_id() -> Dictionary:
	var raw: Variant = DataLoader.load_json(VISUAL_LAYOUT_PATH)
	assert_true(raw is Dictionary, "store visual layouts must load")
	var placements_by_fixture_id: Dictionary = {}
	for entry_value: Variant in (raw as Dictionary).get("entries", []):
		var layout_entry: Dictionary = entry_value as Dictionary
		if str(layout_entry.get("layout_id", "")) != "retro_games_starter_small":
			continue
		for placement_value: Variant in layout_entry.get("placements", []):
			var placement: Dictionary = placement_value as Dictionary
			var fixture_id: String = str(placement.get("fixture_id", ""))
			if not fixture_id.is_empty():
				placements_by_fixture_id[fixture_id] = placement
	return placements_by_fixture_id


func _build_fixture_ids() -> PackedStringArray:
	var raw: Variant = DataLoader.load_json(FIXTURE_CATALOG_PATH)
	assert_true(raw is Dictionary, "fixtures.json must load")
	var fixture_ids := PackedStringArray()
	for entry_value: Variant in (raw as Dictionary).get("entries", []):
		var fixture_entry: Dictionary = entry_value as Dictionary
		fixture_ids.append(str(fixture_entry.get("id", "")))
	return fixture_ids
