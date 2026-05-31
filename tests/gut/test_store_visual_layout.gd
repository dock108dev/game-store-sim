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
	assert_eq(placements.size(), 16)

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
	assert_eq(int(visual_counts.get(StoreVisualKitScript.REGISTER, 0)), 1)
	assert_eq(int(visual_counts.get(StoreVisualKitScript.CARD_READER, 0)), 1)
	assert_eq(int(visual_counts.get(StoreVisualKitScript.RECEIPT_PRINTER, 0)), 1)
	assert_eq(int(visual_counts.get(StoreVisualKitScript.ACRYLIC_STAND, 0)), 1)
	assert_eq(int(visual_counts.get(StoreVisualKitScript.CONTROLLER_BIN_PROP, 0)), 1)
	assert_eq(int(visual_counts.get(StoreVisualKitScript.REPAIR_TESTING_MAT, 0)), 1)
	assert_eq(int(visual_counts.get(StoreVisualKitScript.CLIPBOARD, 0)), 1)
	assert_eq(int(visual_counts.get(StoreVisualKitScript.TAPED_BOX_LABEL, 0)), 1)
	assert_eq(int(visual_counts.get(StoreVisualKitScript.SECURITY_TAG_BLOCK, 0)), 1)
	assert_eq(
		product_item_ids,
		PackedStringArray(
			[
				"console_neo_ignite",
				"neo_ignite_motorway_kings_loose",
				"neo_ignite_kingdom_embers_loose",
				"neo_ignite_torque_force_3_loose",
				"neo_ignite_gridiron_2005_loose",
			]
		)
	)

	for product_item_id: String in product_item_ids:
		var product_placement: Dictionary = {}
		for placement: Dictionary in placements:
			if str(placement.get("product_item_id", "")) == product_item_id:
				product_placement = placement
				break
		assert_true(bool(product_placement.get("show_price_tag", false)))
		assert_eq(str(product_placement.get("route_role", "")), "starter_sale_item")


func test_retro_games_starter_layout_declares_sparse_first_delivery_contract() -> void:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	var first_delivery_ids: PackedStringArray = catalog.call(
		"get_product_item_ids",
		StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT,
		StoreVisualLayoutScript.STOCK_STATE_FIRST_DELIVERY,
	)
	var reserve_ids: PackedStringArray = catalog.call(
		"get_product_item_ids",
		StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT,
		StoreVisualLayoutScript.STOCK_STATE_RESERVE,
	)
	assert_eq(first_delivery_ids, StoreSessionController.starter_first_delivery_item_ids())
	assert_eq(reserve_ids, StoreSessionController.starter_reserve_item_ids())

	var first_delivery: Array[Dictionary] = catalog.call(
		"get_product_placements",
		StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT,
		StoreVisualLayoutScript.STOCK_STATE_FIRST_DELIVERY,
	)
	for index: int in range(first_delivery.size()):
		assert_eq(int(first_delivery[index].get("delivery_index", -1)), index)


func test_starter_fixture_layout_matches_generated_shell_anchor_contract() -> void:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	var display_table: Dictionary = catalog.call(
		"get_fixture_placement",
		StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT,
		"starter_display_table",
	)
	var checkout_counter: Dictionary = catalog.call(
		"get_fixture_placement",
		StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT,
		"starter_checkout_counter",
	)
	assert_eq(display_table.get("position"), [-4.10, 0.0, -1.20])
	assert_eq(display_table.get("rotation_degrees"), [0.0, -8.0, 0.0])
	assert_eq(checkout_counter.get("position"), [5.65, 0.0, 6.15])
	assert_eq(checkout_counter.get("rotation_degrees"), [0.0, 0.0, 0.0])


func test_starter_checkout_layout_declares_named_device_pieces() -> void:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	for component: Dictionary in StoreVisualKitScript.starter_checkout_station_components():
		var fixture_id: String = str(component.get("concept_id", ""))
		var placement: Dictionary = catalog.call(
			"get_fixture_placement",
			StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT,
			fixture_id,
		)
		assert_false(placement.is_empty(), "%s must be placed in the starter layout" % fixture_id)
		assert_eq(
			StringName(str(placement.get("visual_id", ""))),
			component.get("visual_id", &"") as StringName
		)
		assert_true(bool(placement.get("starter_owned", false)))
		if fixture_id != "starter_checkout_counter":
			assert_true(bool(placement.get("visual_only", false)))
			assert_eq(str(placement.get("parent_fixture_id", "")), "starter_checkout_counter")


func test_starter_layout_places_small_display_prop_kit() -> void:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	for component: Dictionary in StoreVisualKitScript.starter_small_display_prop_components():
		var fixture_id: String = str(component.get("concept_id", ""))
		var placement: Dictionary = catalog.call(
			"get_fixture_placement",
			StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT,
			fixture_id,
		)
		assert_false(placement.is_empty(), "%s must be placed in the starter layout" % fixture_id)
		assert_eq(
			StringName(str(placement.get("visual_id", ""))),
			component.get("visual_id", &"") as StringName
		)
		assert_true(bool(placement.get("starter_owned", false)))
		assert_true(bool(placement.get("visual_only", false)))
		assert_false(str(placement.get("zone", "")).is_empty())


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
