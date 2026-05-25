extends GutTest

const StoreVisualKitScript: GDScript = preload("res://game/scripts/visuals/store_visual_kit.gd")
const StoreVisualLayoutScript: GDScript = preload(
	"res://game/scripts/visuals/store_visual_layout.gd"
)


func test_default_layout_catalog_loads_retro_games_starter_layout() -> void:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	assert_eq(str(catalog.get("load_error")), "")
	assert_true(
		catalog.call("has_layout", StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT),
		"Retro Games starter layout should be registered"
	)


func test_retro_games_starter_layout_stays_small_and_uses_kit_visuals() -> void:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	var starter_ids: Array[StringName] = StoreVisualKitScript.starter_store_ids()
	var placements: Array[Dictionary] = catalog.call(
		"get_placements", StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT
	)
	assert_eq(placements.size(), 5)

	var visual_counts: Dictionary = {}
	var product_item_ids: PackedStringArray = []
	for placement: Dictionary in placements:
		var visual_id: StringName = StringName(str(placement.get("visual_id", "")))
		var product_item_id: String = str(placement.get("product_item_id", ""))
		if product_item_id.is_empty():
			assert_true(starter_ids.has(visual_id), "%s should come from starter kit" % visual_id)
			visual_counts[visual_id] = int(visual_counts.get(visual_id, 0)) + 1
		else:
			product_item_ids.append(product_item_id)

	assert_eq(int(visual_counts.get(StoreVisualKitScript.DISPLAY_TABLE, 0)), 1)
	assert_eq(int(visual_counts.get(StoreVisualKitScript.CHECKOUT_COUNTER, 0)), 1)
	assert_eq(
		product_item_ids,
		PackedStringArray(
			[
				"console_neo_ignite",
				"neo_ignite_motorway_kings_loose",
				"neo_ignite_kingdom_embers_loose",
			]
		)
	)


func test_layout_catalog_does_not_expose_legacy_visual_apply_path() -> void:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	assert_false(
		catalog.has_method("apply_to"),
		"StoreLayoutRuntime is the SSOT for turning layout data into nodes"
	)


func test_unlock_gated_layout_entries_apply_only_when_unlock_is_active() -> void:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	var locked: Array[Dictionary] = catalog.call(
		"get_placements", StoreVisualLayoutScript.RETRO_GAMES_GROWTH_LAYOUT
	)
	assert_eq(locked.size(), 0)

	var unlocked: Array[Dictionary] = (
		catalog
		. call(
			"get_placements",
			StoreVisualLayoutScript.RETRO_GAMES_GROWTH_LAYOUT,
			[&"upgrade:store_expansion"] as Array[StringName],
		)
	)
	assert_eq(unlocked.size(), 1)
	assert_eq(StringName(str(unlocked[0].get("visual_id", ""))), StoreVisualKitScript.QUEUE_LANE)
