extends GutTest

const StoreVisualKitScript: GDScript = preload("res://game/scripts/visuals/store_visual_kit.gd")


func test_validate_reports_clean_role_metadata_registry() -> void:
	var result: Dictionary = StoreVisualKitScript.validate()
	assert_true(bool(result.get("ok", false)), "Store visual kit should validate cleanly")
	assert_eq(result.get("missing", []), [], "Store visual kit should not miss assets")
	assert_true(result.has("missing_metadata"), "Validation should report metadata separately")
	assert_eq(
		result.get("missing_metadata", []),
		[],
		"Store visual kit should not miss role metadata"
	)


func test_required_visual_ids_have_role_group_and_source_metadata() -> void:
	for id: StringName in StoreVisualKitScript.required_ids():
		var metadata: Dictionary = StoreVisualKitScript.visual_metadata(id)
		assert_false(metadata.is_empty(), "%s must expose visual metadata" % id)
		assert_false(str(metadata.get("display_name", "")).is_empty(), "%s needs display name" % id)
		assert_false(String(metadata.get("role", &"")).is_empty(), "%s needs primary role" % id)
		assert_gt(
			StoreVisualKitScript.visual_groups(id).size(),
			0,
			"%s needs orthogonal context groups" % id
		)
		assert_ne(
			metadata.get("source_type", &"missing"),
			&"missing",
			"%s needs source metadata" % id
		)


func test_role_lookup_distinguishes_representative_visuals() -> void:
	var representatives: Dictionary = {
		StoreVisualKitScript.ROLE_FIXTURE: StoreVisualKitScript.WALL_SHELF,
		StoreVisualKitScript.ROLE_TOOL: StoreVisualKitScript.BARCODE_SCANNER,
		StoreVisualKitScript.ROLE_PRODUCT: StoreVisualKitScript.GAME_CASE,
		StoreVisualKitScript.ROLE_SIGNAGE: StoreVisualKitScript.PRICE_TAG,
		StoreVisualKitScript.ROLE_DECOR: StoreVisualKitScript.ACRYLIC_STAND,
		StoreVisualKitScript.ROLE_ROUTE_CUE: StoreVisualKitScript.QUEUE_LANE,
		StoreVisualKitScript.ROLE_STOCKROOM: StoreVisualKitScript.STOCKROOM_SHELF,
		StoreVisualKitScript.ROLE_SERVICE: StoreVisualKitScript.REGISTER,
	}
	for raw_role: Variant in representatives:
		var role: StringName = raw_role as StringName
		var id: StringName = representatives.get(role, &"") as StringName
		assert_eq(StoreVisualKitScript.visual_role(id), role)
		assert_true(StoreVisualKitScript.visuals_for_role(role).has(id))
		assert_true(StoreVisualKitScript.has_visual_role(id, role))


func test_group_lookup_keeps_contexts_orthogonal_to_roles() -> void:
	var stockroom_ids: Array[StringName] = StoreVisualKitScript.visuals_in_group(
		StoreVisualKitScript.GROUP_STOCKROOM
	)
	for id: StringName in [
		StoreVisualKitScript.STOCKROOM_SHELF,
		StoreVisualKitScript.STOCK_BOX,
		StoreVisualKitScript.CLIPBOARD,
		StoreVisualKitScript.TAPE_ROLL,
	]:
		assert_true(stockroom_ids.has(id), "Stockroom group should include %s" % id)
	assert_true(
		StoreVisualKitScript.has_visual_group(
			StoreVisualKitScript.TAPED_BOX_LABEL,
			StoreVisualKitScript.ROLE_SIGNAGE
		),
		"Stockroom labels should stay stockroom-primary but signage-filterable"
	)

	var shell_prop_ids: Array[StringName] = StoreVisualKitScript.visuals_in_group(
		StoreVisualKitScript.GROUP_SHELL_PROP
	)
	assert_true(shell_prop_ids.has(StoreVisualKitScript.GLTF_GAME_CASE))
	assert_true(shell_prop_ids.has(StoreVisualKitScript.GLTF_REGISTER_MONITOR))


func test_unknown_visual_metadata_lookups_are_empty_or_false() -> void:
	var unknown: StringName = &"not_a_store_visual"
	assert_eq(StoreVisualKitScript.visual_metadata(unknown), {})
	assert_eq(StoreVisualKitScript.visual_role(unknown), &"")
	assert_eq(StoreVisualKitScript.visual_groups(unknown), [])
	assert_false(StoreVisualKitScript.has_visual_role(unknown, StoreVisualKitScript.ROLE_PRODUCT))
	assert_false(StoreVisualKitScript.has_visual_group(unknown, StoreVisualKitScript.GROUP_STOCKROOM))


func test_instantiated_visuals_receive_semantic_metadata() -> void:
	var scene_visual: Node = StoreVisualKitScript.instantiate(StoreVisualKitScript.REGISTER)
	assert_not_null(scene_visual, "Scene-backed visual should instantiate")
	if scene_visual != null:
		add_child_autofree(scene_visual)
		assert_eq(scene_visual.get_meta("store_visual_id"), StoreVisualKitScript.REGISTER)
		assert_eq(scene_visual.get_meta("store_visual_role"), StoreVisualKitScript.ROLE_SERVICE)
		assert_true(
			(scene_visual.get_meta("store_visual_groups") as Array).has(
				StoreVisualKitScript.GROUP_CHECKOUT
			)
		)
		assert_eq(str(scene_visual.get_meta("store_visual_display_name", "")), "register")

	var procedural_visual: Node = StoreVisualKitScript.instantiate(
		StoreVisualKitScript.BARCODE_SCANNER
	)
	assert_not_null(procedural_visual, "Procedural visual should instantiate")
	if procedural_visual != null:
		add_child_autofree(procedural_visual)
		assert_eq(
			procedural_visual.get_meta("store_visual_id"),
			StoreVisualKitScript.BARCODE_SCANNER
		)
		assert_eq(procedural_visual.get_meta("store_visual_role"), StoreVisualKitScript.ROLE_TOOL)
		assert_true(
			(procedural_visual.get_meta("store_visual_groups") as Array).has(
				StoreVisualKitScript.GROUP_CHECKOUT
			)
		)
