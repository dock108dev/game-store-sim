extends GutTest

const StoreVisualKitScript: GDScript = preload("res://game/scripts/visuals/store_visual_kit.gd")


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
		9,
		"Starter kit should stay small: register/counter, display table, and purchasable props"
	)
	for id: StringName in [
		StoreVisualKitScript.DISPLAY_TABLE,
		StoreVisualKitScript.CHECKOUT_COUNTER,
		StoreVisualKitScript.GAME_CASE,
		StoreVisualKitScript.CONSOLE_BOX,
		StoreVisualKitScript.REGISTER,
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
