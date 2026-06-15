extends GutTest

const SUPPLIER_DIR := "res://data/suppliers"
const EXPECTED_SUPPLIER_LOT_COUNT := 4


func test_supplier_lot_has_orderable_used_game_products() -> void:
	var lot := load("res://data/suppliers/used_game_starter_lot.tres") as Resource

	assert_not_null(lot)
	assert_eq(lot.get("lot_id"), "supplier_lot_used_games_001")
	assert_eq(lot.get("supplier_id"), "North Dock Wholesale")
	assert_eq(lot.get("display_name"), "Used Game Starter Lot")
	assert_eq(lot.call("get_category_label"), "Used games")
	assert_eq(lot.get("cost_cents"), 3000)
	assert_eq(lot.get("delivery_days"), 1)
	assert_eq(lot.call("get_item_count"), 3)
	assert_eq(lot.call("get_storage_requirement"), "Receiving station intake, then display rack or backstock shelf")
	assert_string_contains(
		lot.call("get_receiving_expectation"),
		"physical cases in the backroom receiving station"
	)
	assert_string_contains(lot.call("get_order_note"), "mixed crate")
	assert_string_contains(lot.call("get_invoice_note"), "Count three cases")
	assert_string_contains(lot.call("get_shelf_plan"), "eye-level used wall")
	assert_not_null(load(str(lot.get("item_scene_path"))) as PackedScene)

	for product_path in lot.get("product_paths"):
		var product := load(str(product_path)) as ProductDefinition
		assert_not_null(product)
		assert_eq(product.category, "used_game")


func test_supplier_lots_cover_full_first_catalog_lanes() -> void:
	var lots := _load_supplier_lots()
	var lot_ids := {}
	var category_labels := {}
	var supplier_ids := {}

	assert_gte(lots.size(), EXPECTED_SUPPLIER_LOT_COUNT)
	for lot in lots:
		var lot_id := str(lot.get("lot_id"))
		assert_false(lot_ids.has(lot_id), "Duplicate supplier lot: %s" % lot_id)
		lot_ids[lot_id] = true
		supplier_ids[str(lot.get("supplier_id"))] = true
		category_labels[str(lot.call("get_category_label"))] = true
		assert_gt(int(lot.get("cost_cents")), 0)
		assert_gt(int(lot.get("delivery_days")), 0)
		assert_gt(int(lot.call("get_item_count")), 0)
		assert_false(str(lot.call("get_storage_requirement")).strip_edges().is_empty())
		assert_false(str(lot.call("get_receiving_expectation")).strip_edges().is_empty())
		assert_false(str(lot.call("get_order_note")).strip_edges().is_empty())
		assert_false(str(lot.call("get_invoice_note")).strip_edges().is_empty())
		assert_false(str(lot.call("get_shelf_plan")).strip_edges().is_empty())
		assert_not_null(load(str(lot.get("item_scene_path"))) as PackedScene)
		for product_path in lot.get("product_paths"):
			var product := load(str(product_path)) as ProductDefinition
			assert_not_null(product, "Supplier product path should resolve: %s" % product_path)
			assert_true(product.player_priceable)

	assert_true(supplier_ids.has("North Dock Wholesale"))
	assert_true(supplier_ids.has("Clear Cart Distribution"))
	assert_true(supplier_ids.has("Shelf Pin Supply"))
	assert_true(supplier_ids.has("Harbor Bin Exchange"))
	assert_true(category_labels.has("Used games"))
	assert_true(category_labels.has("New releases"))
	assert_true(category_labels.has("Accessories and hardware"))
	assert_true(category_labels.has("Used backstock"))


func _load_supplier_lots() -> Array[Resource]:
	var lots: Array[Resource] = []
	var dir := DirAccess.open(SUPPLIER_DIR)
	assert_not_null(dir)
	if dir == null:
		return lots

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while not file_name.is_empty():
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var lot := load("%s/%s" % [SUPPLIER_DIR, file_name]) as Resource
			if lot != null:
				lots.append(lot)
		file_name = dir.get_next()
	dir.list_dir_end()
	return lots
