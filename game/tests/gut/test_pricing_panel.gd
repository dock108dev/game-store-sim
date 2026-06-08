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
	assert_false(_panel.apply_matching_check_box.button_pressed)
	assert_string_contains(_panel.apply_matching_check_box.text, "Star Trader")


func test_pricing_panel_transition_controls_mouse_and_focus() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	assert_eq(_panel.get_transition_state(), "closed")
	assert_true(_panel.open_for_item(_item))

	assert_eq(_panel.get_transition_state(), "open")
	assert_eq(_panel.get_requested_mouse_mode(), Input.MOUSE_MODE_VISIBLE)
	assert_true(_panel.has_modal_focus())
	assert_eq(get_viewport().gui_get_focus_owner(), _panel.apply_button)

	assert_true(_panel.cancel_price())

	assert_eq(_panel.get_transition_state(), "closed")
	assert_eq(_panel.get_requested_mouse_mode(), Input.MOUSE_MODE_CAPTURED)
	assert_false(_panel.has_modal_focus())


func test_pricing_panel_rejects_non_product_item() -> void:
	var plain_node := Node.new()
	add_child_autofree(plain_node)

	assert_false(_panel.open_for_item(plain_node))
	assert_false(_panel.is_open())


func test_pricing_panel_rejects_fixed_price_product() -> void:
	var fixed_price_item := _make_fixed_price_item()
	add_child_autofree(fixed_price_item)

	assert_false(_panel.open_for_item(fixed_price_item))
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


func test_pricing_panel_apply_defaults_to_single_item() -> void:
	var matching_item: Node = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(matching_item)

	_panel.open_for_item(_item)
	_panel.increase_price()

	assert_true(_panel.apply_price())
	assert_eq(_item.get("current_price_cents"), 2299)
	assert_eq(matching_item.get("current_price_cents"), 2199)


func test_pricing_panel_apply_matching_updates_active_matching_items() -> void:
	var matching_item: Node = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	var sold_item: Node = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	var customer_item: Node = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(matching_item)
	add_child_autofree(sold_item)
	add_child_autofree(customer_item)
	sold_item.set("location_id", "sold")
	customer_item.set("location_id", "customer:customer_001")

	_panel.open_for_item(_item)
	_panel.apply_matching_check_box.button_pressed = true
	_panel.increase_price()

	assert_eq(_panel.get_matching_priceable_items().size(), 2)
	assert_true(_panel.apply_price())
	assert_eq(_item.get("current_price_cents"), 2299)
	assert_eq(matching_item.get("current_price_cents"), 2299)
	assert_eq(sold_item.get("current_price_cents"), 2199)
	assert_eq(customer_item.get("current_price_cents"), 2199)


func test_pricing_panel_cancel_keeps_original_item_price() -> void:
	_panel.open_for_item(_item)
	_panel.increase_price()
	_panel.increase_price()

	assert_true(_panel.cancel_price())
	assert_eq(_item.get("current_price_cents"), 2199)
	assert_false(_panel.is_open())


func _make_fixed_price_item() -> Node:
	var item: Node = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	var product := ProductDefinition.new()
	product.product_id = "new_orbit_racer"
	product.display_name = "New Orbit Racer"
	product.category = "new_game"
	product.platform = "Orbit 64"
	product.condition = "new"
	product.completeness = "sealed"
	product.cost_basis_cents = 3200
	product.market_value_cents = 5999
	product.suggested_price_cents = 5999
	product.player_priceable = false
	item.set("product", product)
	item.set("current_price_cents", 5999)
	return item
