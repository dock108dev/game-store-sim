extends GutTest

var _panel: PricingPanel
var _item: Node


func before_each() -> void:
	_panel = load("res://scenes/ui/pricing_panel.tscn").instantiate()
	add_child_autofree(_panel)
	_item = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(_item)


func test_pricing_panel_starts_hidden() -> void:
	assert_false(_panel.visible)
	assert_false(_panel.is_open())


func test_pricing_panel_opens_with_product_fields() -> void:
	assert_true(_panel.open_for_item(_item))

	assert_true(_panel.is_open())
	assert_eq(_panel.get_active_item(), _item)
	assert_eq(_panel.get_draft_price_cents(), 2199)
	assert_string_contains(_panel.title_label.text, "Star Trader")
	assert_string_contains(_panel.details_label.text, "Orbit 64")
	assert_string_contains(_panel.details_label.text, "Good")
	assert_string_contains(_panel.details_label.text, "Cost: $9.00")
	assert_string_contains(_panel.details_label.text, "Market: $24.99")
	assert_eq(_panel.price_label.text, "$21.99")


func test_pricing_panel_rejects_non_product_item() -> void:
	var plain_node := Node.new()
	add_child_autofree(plain_node)

	assert_false(_panel.open_for_item(plain_node))
	assert_false(_panel.is_open())


func test_pricing_panel_increments_and_decrements_draft_price() -> void:
	_panel.open_for_item(_item)

	_panel.increase_price()
	assert_eq(_panel.get_draft_price_cents(), 2299)
	assert_eq(_panel.price_label.text, "$22.99")

	_panel.decrease_price()
	_panel.decrease_price()
	assert_eq(_panel.get_draft_price_cents(), 2099)
	assert_eq(_panel.price_label.text, "$20.99")


func test_pricing_panel_clamps_price() -> void:
	_panel.min_price_cents = 1999
	_panel.max_price_cents = 2299
	_panel.open_for_item(_item)

	_panel.increase_price()
	_panel.increase_price()
	assert_eq(_panel.get_draft_price_cents(), 2299)

	_panel.decrease_price()
	_panel.decrease_price()
	_panel.decrease_price()
	_panel.decrease_price()
	assert_eq(_panel.get_draft_price_cents(), 1999)


func test_pricing_panel_apply_updates_item_price() -> void:
	_panel.open_for_item(_item)
	_panel.increase_price()

	assert_true(_panel.apply_price())
	assert_eq(_item.get("current_price_cents"), 2299)
	assert_false(_panel.is_open())


func test_pricing_panel_cancel_keeps_original_item_price() -> void:
	_panel.open_for_item(_item)
	_panel.increase_price()
	_panel.increase_price()

	assert_true(_panel.cancel_price())
	assert_eq(_item.get("current_price_cents"), 2199)
	assert_false(_panel.is_open())
