extends GutTest

const PLAYER_SCENE := "res://scenes/player/player_controller.tscn"
const REQUIRED_ACTIONS := [
	"move_forward",
	"move_back",
	"move_left",
	"move_right",
	"interact",
]

var _player: CharacterBody3D


func before_each() -> void:
	_player = load(PLAYER_SCENE).instantiate()
	add_child_autofree(_player)


func test_player_scene_has_collision_shape() -> void:
	var shape := _player.get_node_or_null("CollisionShape3D") as CollisionShape3D
	assert_not_null(shape)
	assert_not_null(shape.shape)


func test_player_scene_has_current_camera() -> void:
	var camera := _player.get_node_or_null("Head/Camera3D") as Camera3D
	assert_not_null(camera)
	assert_true(camera.current)
	assert_almost_eq(camera.fov, 72.0, 0.001)


func test_player_camera_feel_has_comfort_bounds_and_summary() -> void:
	var state: Dictionary = _player.call("get_camera_feel_state")
	var summary: String = _player.call("get_camera_feel_summary_text")

	assert_eq(state.get("comfort_fov"), 72.0)
	assert_eq(state.get("min_fov"), 66.0)
	assert_eq(state.get("max_fov"), 76.0)
	assert_lte(state.get("move_fov_boost"), 2.0)
	assert_lte(state.get("bob_amplitude"), 0.018)
	assert_string_contains(summary, "Movement bob")
	assert_string_contains(summary, "Held item sway")
	assert_string_contains(summary, "Workstation transition")
	assert_string_contains(summary, "Comfort FOV")


func test_player_camera_motion_adds_bounded_bob_and_fov_boost() -> void:
	var head := _player.get_node("Head") as Node3D
	var camera := _player.get_node("Head/Camera3D") as Camera3D
	var base_position := head.position

	_player.call("_update_camera_feel", 0.25, 1.0)
	var state: Dictionary = _player.call("get_camera_feel_state")
	var head_offset := state.get("head_offset") as Vector3

	assert_gt(state.get("motion_weight"), 0.0)
	assert_gt(camera.fov, 72.0)
	assert_lte(camera.fov, 76.0)
	assert_ne(head.position, base_position)
	assert_lte(absf(head_offset.x), 0.008)
	assert_lte(absf(head_offset.y), 0.018)
	assert_almost_eq(head_offset.z, 0.0, 0.001)


func test_player_modal_camera_settles_for_workstation_focus() -> void:
	var head := _player.get_node("Head") as Node3D
	var camera := _player.get_node("Head/Camera3D") as Camera3D
	var base_position := head.position

	assert_eq(_player.open_settings_panel(), "")
	_player.call("_update_camera_feel", 0.25, 1.0)
	var state: Dictionary = _player.call("get_camera_feel_state")
	var head_offset := state.get("head_offset") as Vector3

	assert_gt(state.get("workstation_focus_weight"), 0.0)
	assert_lt(camera.fov, 72.0)
	assert_gte(camera.fov, 66.0)
	assert_lt(head.position.y, base_position.y)
	assert_lte(absf(head_offset.x), 0.001)
	assert_lte(absf(head_offset.y), 0.012)


func test_interaction_raycast_is_configured() -> void:
	var raycast := _player.get_node_or_null("Head/Camera3D/InteractionRaycast") as RayCast3D
	assert_not_null(raycast)
	assert_true(raycast.enabled)
	assert_true(raycast.collide_with_areas)
	assert_eq(raycast.target_position, Vector3(0, 0, -3))


func test_interaction_prompt_exists() -> void:
	assert_not_null(_player.get_node_or_null("InteractionPrompt"))


func test_pricing_panel_exists() -> void:
	var pricing_panel := _player.get_node_or_null("PricingPanel") as PricingPanel
	assert_not_null(pricing_panel)
	assert_false(pricing_panel.visible)


func test_register_checkout_panel_exists() -> void:
	var register_checkout_panel := _player.get_node_or_null("RegisterCheckoutPanel")
	assert_not_null(register_checkout_panel)
	assert_false(register_checkout_panel.visible)


func test_day_summary_panel_exists() -> void:
	var day_summary_panel := _player.get_node_or_null("DaySummaryPanel")
	assert_not_null(day_summary_panel)
	assert_false(day_summary_panel.visible)


func test_trade_in_offer_panel_exists() -> void:
	var trade_in_offer_panel := _player.get_node_or_null("TradeInOfferPanel") as TradeInOfferPanel
	assert_not_null(trade_in_offer_panel)
	assert_false(trade_in_offer_panel.visible)


func test_settings_panel_exists() -> void:
	var settings_panel := _player.get_node_or_null("SettingsPanel") as SettingsPanel
	assert_not_null(settings_panel)
	assert_false(settings_panel.visible)


func test_pause_menu_panel_exists() -> void:
	var pause_menu_panel := _player.get_node_or_null("PauseMenuPanel")
	assert_not_null(pause_menu_panel)
	assert_false(pause_menu_panel.visible)


func test_save_slot_panel_exists() -> void:
	var save_slot_panel := _player.get_node_or_null("SaveSlotPanel")
	assert_not_null(save_slot_panel)
	assert_false(save_slot_panel.visible)


func test_keyboard_input_actions_exist() -> void:
	for action in REQUIRED_ACTIONS:
		assert_true(InputMap.has_action(action), "%s should exist" % action)


func test_keyboard_input_actions_have_events() -> void:
	for action in REQUIRED_ACTIONS:
		assert_gt(InputMap.action_get_events(action).size(), 0, "%s should have input events" % action)


func test_player_has_hold_anchor() -> void:
	var hold_anchor := _player.get_node_or_null("Head/Camera3D/HoldAnchor") as Node3D
	assert_not_null(hold_anchor)
	assert_lte(hold_anchor.position.z, -1.0)
	assert_gt(hold_anchor.position.x, 0.0)
	assert_lt(hold_anchor.position.y, -0.35)


func test_player_can_pick_up_item() -> void:
	var item: Node3D = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(item)

	assert_true(_player.pick_up_item(item))

	var hold_anchor := _player.get_node("Head/Camera3D/HoldAnchor") as Node3D
	var collision_shape := item.get_node("CollisionShape3D") as CollisionShape3D
	assert_eq(_player.get_held_item(), item)
	assert_eq(_player.get_held_item_count(), 1)
	assert_eq(_player.get_held_items(), [item])
	assert_eq(item.get_parent(), hold_anchor)
	assert_eq(item.get("location_id"), "held")
	assert_true(item.get_meta("carry_is_active"))
	assert_almost_eq(absf(item.rotation.y), PI, 0.001)
	assert_almost_eq(item.scale.x, 0.45, 0.001)
	assert_true(collision_shape.disabled)


func test_player_can_hold_multiple_items_up_to_capacity() -> void:
	var first_item := _make_used_game("item_used_star_trader_001")
	var second_item := _make_used_game("item_used_star_trader_002")
	var third_item := _make_used_game("item_used_star_trader_003")
	var fourth_item := _make_used_game("item_used_star_trader_004")

	assert_true(_player.pick_up_item(first_item))
	assert_true(_player.pick_up_item(second_item))
	assert_true(_player.pick_up_item(third_item))

	assert_eq(_player.get_held_item_count(), 3)
	assert_eq(_player.get_held_item(), third_item)
	assert_eq(_player.get_held_items(), [first_item, second_item, third_item])
	assert_false(_player.can_pick_up_item(fourth_item))
	assert_false(_player.pick_up_item(fourth_item))

	var hold_anchor := _player.get_node("Head/Camera3D/HoldAnchor") as Node3D
	for item in [first_item, second_item, third_item]:
		var collision_shape := item.get_node("CollisionShape3D") as CollisionShape3D
		assert_eq(item.get_parent(), hold_anchor)
		assert_eq(item.get("location_id"), "held")
		assert_true(collision_shape.disabled)


func test_player_carry_stack_fans_items_without_blocking_center() -> void:
	var first_item := _make_used_game("item_used_star_trader_001")
	var second_item := _make_used_game("item_used_star_trader_002")
	var third_item := _make_used_game("item_used_star_trader_003")

	assert_true(_player.pick_up_item(first_item))
	assert_true(_player.pick_up_item(second_item))
	assert_true(_player.pick_up_item(third_item))

	assert_lt(first_item.position.x, second_item.position.x)
	assert_lt(second_item.position.x, third_item.position.x)
	assert_gt(first_item.position.y, second_item.position.y)
	assert_gt(second_item.position.y, third_item.position.y)
	assert_lt(first_item.position.z, second_item.position.z)
	assert_lt(second_item.position.z, third_item.position.z)
	assert_lte(absf(third_item.position.x), 0.02)
	assert_lte(third_item.position.y, 0.01)
	assert_lte(third_item.position.z, -0.04)
	assert_lte(first_item.position.y, 0.095)
	assert_lte(first_item.scale.x, 0.401)


func test_player_carry_presentation_has_depth_active_focus_and_motion() -> void:
	var first_item := _make_used_game("item_used_star_trader_001")
	var second_item := _make_used_game("item_used_star_trader_002")
	var third_item := _make_used_game("item_used_star_trader_003")

	assert_true(_player.pick_up_item(first_item))
	assert_true(_player.pick_up_item(second_item))
	assert_true(_player.pick_up_item(third_item))

	assert_eq(first_item.get_meta("carry_depth"), 2.0)
	assert_eq(second_item.get_meta("carry_depth"), 1.0)
	assert_eq(third_item.get_meta("carry_depth"), 0.0)
	assert_false(first_item.get_meta("carry_is_active"))
	assert_false(second_item.get_meta("carry_is_active"))
	assert_true(third_item.get_meta("carry_is_active"))
	assert_lt(first_item.scale.x, second_item.scale.x)
	assert_lt(second_item.scale.x, third_item.scale.x)
	assert_gt(absf(first_item.rotation.z), absf(third_item.rotation.z))

	var active_base_position := third_item.get_meta("carry_base_position") as Vector3
	var active_base_rotation := third_item.get_meta("carry_base_rotation") as Vector3
	_player.call("_update_held_item_motion", 0.25, 1.0)

	assert_ne(third_item.position.y, active_base_position.y)
	assert_ne(third_item.position.x, active_base_position.x)
	assert_ne(third_item.rotation.z, active_base_rotation.z)
	assert_lte(absf(third_item.position.x), 0.02)
	assert_lte(third_item.position.y, 0.02)
	assert_lte(third_item.position.z, -0.04)


func test_player_places_held_item_in_display_slot() -> void:
	var rack: Node3D = load("res://scenes/props/placeholder_shelf.tscn").instantiate()
	add_child_autofree(rack)
	var slot := rack.get_node("ShelfSlot001") as ShelfSlot

	var item: Node3D = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(item)

	assert_true(_player.pick_up_item(item))
	assert_true(_player.place_held_item(slot))

	var collision_shape := item.get_node("CollisionShape3D") as CollisionShape3D
	assert_null(_player.get_held_item())
	assert_eq(_player.get_held_item_count(), 0)
	assert_eq(slot.get_occupied_item(), item)
	assert_eq(item.get("location_id"), "shelf_slot_001")
	assert_eq(item.rotation, Vector3.ZERO)
	assert_almost_eq(item.scale.x, 0.56, 0.001)
	assert_almost_eq(item.scale.y, 0.56, 0.001)
	assert_almost_eq(item.scale.z, 0.56, 0.001)
	assert_false(collision_shape.disabled)


func test_player_places_top_held_item_and_keeps_remaining_stack() -> void:
	var rack: Node3D = load("res://scenes/props/placeholder_shelf.tscn").instantiate()
	add_child_autofree(rack)
	var slot := rack.get_node("ShelfSlot001") as ShelfSlot

	var first_item := _make_used_game("item_used_star_trader_001")
	var second_item := _make_used_game("item_used_star_trader_002")

	assert_true(_player.pick_up_item(first_item))
	assert_true(_player.pick_up_item(second_item))
	assert_true(_player.place_held_item(slot))

	var first_collision_shape := first_item.get_node("CollisionShape3D") as CollisionShape3D
	var second_collision_shape := second_item.get_node("CollisionShape3D") as CollisionShape3D
	var hold_anchor := _player.get_node("Head/Camera3D/HoldAnchor") as Node3D

	assert_eq(slot.get_occupied_item(), second_item)
	assert_eq(second_item.get("location_id"), "shelf_slot_001")
	assert_false(second_collision_shape.disabled)
	assert_eq(_player.get_held_item_count(), 1)
	assert_eq(_player.get_held_item(), first_item)
	assert_eq(first_item.get_parent(), hold_anchor)
	assert_eq(first_item.get("location_id"), "held")
	assert_false(second_item.has_meta("carry_is_active"))
	assert_true(first_item.get_meta("carry_is_active"))
	assert_true(first_collision_shape.disabled)


func test_player_requires_held_item_for_pricing() -> void:
	assert_eq(_player.open_pricing_for_held_item(), "Hold an item to price it.")


func test_player_opens_pricing_for_held_item() -> void:
	var item: Node3D = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(item)

	assert_true(_player.pick_up_item(item))
	assert_eq(_player.open_pricing_for_held_item(), "")

	var pricing_panel := _player.get_node("PricingPanel") as PricingPanel
	assert_true(pricing_panel.is_open())
	assert_eq(pricing_panel.get_active_item(), item)
	assert_true(_player.is_pricing_open())


func test_player_held_item_prompt_prices_used_item() -> void:
	var item: Node3D = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(item)

	assert_true(_player.pick_up_item(item))
	assert_eq(_player.get_held_item_interaction_prompt(), "Click Price Star Trader")


func test_player_rejects_fixed_price_held_item() -> void:
	var item: Node3D = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
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
	add_child_autofree(item)

	assert_true(_player.pick_up_item(item))
	assert_eq(_player.get_held_item_interaction_prompt(), "Fixed Price Item")
	assert_eq(_player.open_pricing_for_held_item(), "This item cannot be priced.")


func test_player_opens_register_checkout() -> void:
	var rack: Node3D = load("res://scenes/props/placeholder_shelf.tscn").instantiate()
	var customer: SimpleBuyerCustomer = load("res://scenes/customers/simple_buyer_customer.tscn").instantiate()
	var register: RegisterWorkstation = load("res://scenes/props/register_workstation.tscn").instantiate()
	var ledger := TransactionLedger.new()
	var item: Node3D = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(rack)
	add_child_autofree(customer)
	add_child_autofree(register)
	add_child_autofree(ledger)

	var slot := rack.get_node("ShelfSlot001") as ShelfSlot
	assert_true(slot.place_item(item))
	assert_true(customer.claim_item_from_slot(slot))
	register.customer_path = register.get_path_to(customer)
	register.ledger_path = register.get_path_to(ledger)

	assert_eq(_player.open_register_checkout(register), "")

	var register_checkout_panel := _player.get_node("RegisterCheckoutPanel")
	assert_true(register_checkout_panel.is_open())
	assert_eq(register_checkout_panel.get_active_register(), register)
	assert_string_contains(register_checkout_panel.cart_label.text, "Star Trader")
	assert_true(_player.is_register_checkout_open())


func test_player_opens_and_closes_pause_menu_from_cancel_action() -> void:
	var event := InputEventAction.new()
	event.action = "ui_cancel"
	event.pressed = true

	_player._unhandled_input(event)
	assert_true(_player.is_pause_menu_open())

	_player._unhandled_input(event)
	assert_false(_player.is_pause_menu_open())


func test_player_pause_menu_opens_settings_save_slots_main_menu_and_quit() -> void:
	assert_eq(_player.open_pause_menu(), "")
	var pause_menu := _player.get_node("PauseMenuPanel")
	assert_true(pause_menu.request_settings())
	assert_true(_player.is_settings_open())

	_player.call("_close_active_modal")
	assert_false(_player.is_settings_open())

	assert_eq(_player.open_pause_menu(), "")
	assert_true(pause_menu.request_save_load())
	assert_true(_player.is_save_slot_open())

	_player.call("_close_active_modal")
	assert_false(_player.is_save_slot_open())

	assert_eq(_player.open_main_menu(), "")
	assert_true(_player.is_pause_menu_open())
	assert_true(pause_menu.is_main_menu_mode())

	assert_true(pause_menu.request_quit())
	assert_true(_player.has_quit_request())


func test_player_opens_save_slot_panel() -> void:
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(session)

	assert_eq(_player.open_save_slot_panel(session), "")
	assert_true(_player.is_save_slot_open())

	var save_slot_panel := _player.get_node("SaveSlotPanel")
	assert_true(save_slot_panel.is_open())
	assert_eq(save_slot_panel.get_transition_state(), "open")


func test_player_look_settings_update_sensitivity_and_invert() -> void:
	_player.set_mouse_sensitivity(0.0035)
	_player.set_invert_look(true)

	assert_almost_eq(_player.get_mouse_sensitivity(), 0.0035, 0.00001)
	assert_true(_player.get_invert_look())


func test_player_opens_day_summary() -> void:
	var session: Node = load("res://scripts/systems/store_session.gd").new()
	add_child_autofree(session)

	assert_eq(_player.open_day_summary(session), "")

	var day_summary_panel := _player.get_node("DaySummaryPanel")
	assert_true(day_summary_panel.is_open())
	assert_eq(day_summary_panel.get_active_session(), session)
	assert_true(_player.is_day_summary_open())


func test_player_opens_trade_in_offer() -> void:
	var register: RegisterWorkstation = load("res://scenes/props/register_workstation.tscn").instantiate()
	var customer: SimpleTradeInCustomer = load("res://scenes/customers/simple_trade_in_customer.tscn").instantiate()
	add_child_autofree(register)
	add_child_autofree(customer)

	assert_eq(_player.open_trade_in_offer(register, customer), "")

	var trade_in_offer_panel := _player.get_node("TradeInOfferPanel") as TradeInOfferPanel
	assert_true(trade_in_offer_panel.is_open())
	assert_eq(trade_in_offer_panel.get_active_customer(), customer)
	assert_true(_player.is_trade_in_offer_open())


func _make_used_game(instance_id: String) -> Node3D:
	var item: Node3D = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	item.set("instance_id", instance_id)
	add_child_autofree(item)
	return item
