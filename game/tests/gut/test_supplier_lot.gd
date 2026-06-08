extends GutTest


func test_supplier_lot_has_orderable_used_game_products() -> void:
	var lot := load("res://data/suppliers/used_game_starter_lot.tres") as Resource

	assert_not_null(lot)
	assert_eq(lot.get("lot_id"), "supplier_lot_used_games_001")
	assert_eq(lot.get("supplier_id"), "North Dock Wholesale")
	assert_eq(lot.get("display_name"), "Used Game Starter Lot")
	assert_eq(lot.call("get_category_label"), "Used games")
	assert_eq(lot.get("cost_cents"), 2700)
	assert_eq(lot.get("delivery_days"), 1)
	assert_eq(lot.call("get_item_count"), 3)
	assert_eq(lot.call("get_storage_requirement"), "Receiving box intake, then display rack or backstock")
	assert_string_contains(
		lot.call("get_receiving_expectation"),
		"physical cases in the receiving box"
	)
	assert_string_contains(lot.call("get_order_note"), "mixed crate")
	assert_string_contains(lot.call("get_invoice_note"), "Count three cases")
	assert_string_contains(lot.call("get_shelf_plan"), "eye-level used wall")
	assert_not_null(load(str(lot.get("item_scene_path"))) as PackedScene)

	for product_path in lot.get("product_paths"):
		var product := load(str(product_path)) as ProductDefinition
		assert_not_null(product)
		assert_eq(product.category, "used_game")
