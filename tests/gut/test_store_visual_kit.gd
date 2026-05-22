extends GutTest

const StoreVisualKitScript: GDScript = preload("res://game/scripts/visuals/store_visual_kit.gd")


func test_required_visual_ids_resolve_to_existing_scenes() -> void:
	var required_ids: Array[StringName] = StoreVisualKitScript.required_ids()
	assert_gte(required_ids.size(), 8, "Store kit should expose reusable visual primitives")
	for id: StringName in required_ids:
		var path: String = StoreVisualKitScript.scene_path(id)
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
		6,
		8,
		"Starter kit should stay small: shelf, register/counter, stockroom, and a few props"
	)
	for id: StringName in [
		StoreVisualKitScript.WALL_SHELF,
		StoreVisualKitScript.CHECKOUT_COUNTER,
		StoreVisualKitScript.STOCKROOM_TABLE,
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
