extends GutTest

var _item: Node


func before_each() -> void:
	_item = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(_item)


func test_used_game_item_has_product_data() -> void:
	assert_not_null(_item.product)
	assert_eq(_item.product.product_id, "used_star_trader")
	assert_eq(_item.product.display_name, "Star Trader")
	assert_eq(_item.product.platform, "Orbit 64")
	assert_eq(_item.product.condition, "good")
	assert_eq(_item.product.market_value_cents, 2499)


func test_used_game_item_initializes_price() -> void:
	assert_eq(_item.current_price_cents, 2199)


func test_used_game_item_has_location() -> void:
	assert_eq(_item.location_id, "shelf_slot_001")


func test_used_game_prompt_uses_product_name() -> void:
	assert_eq(_item.get_interaction_prompt(), "E Inspect Star Trader")


func test_used_game_inspect_text_is_product_backed() -> void:
	var text: String = _item.interact()
	assert_string_contains(text, "Star Trader")
	assert_string_contains(text, "Orbit 64")
	assert_string_contains(text, "Market $24.99")
	assert_string_contains(text, "Price $21.99")
	assert_string_contains(text, "shelf_slot_001")


func test_product_definition_describes_retail_fields() -> void:
	var product := load("res://data/products/used_star_trader.tres") as ProductDefinition
	var description := product.describe()
	assert_string_contains(description, "Star Trader")
	assert_string_contains(description, "Orbit 64")
	assert_string_contains(description, "Good")
	assert_string_contains(description, "Market $24.99")
