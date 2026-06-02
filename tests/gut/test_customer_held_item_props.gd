extends GutTest

const STORE_SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"
const CHECKOUT_PANEL_SCENE: PackedScene = preload("res://game/scenes/ui/checkout_panel.tscn")
const RegisterTransactionViewModelScript: GDScript = preload(
	"res://game/scripts/store_session/register_transaction_view_model.gd"
)

var _saved_first_sale_complete: bool = false
var _saved_day: int = 1
var _store_root: Node3D = null


func before_each() -> void:
	_saved_first_sale_complete = GameState.get_flag(&"first_sale_complete")
	_saved_day = GameManager.get_current_day()
	GameState.set_flag(&"first_sale_complete", true)


func after_each() -> void:
	GameState.set_flag(&"first_sale_complete", _saved_first_sale_complete)
	GameManager.set_current_day(_saved_day)
	if is_instance_valid(_store_root):
		_store_root.free()
	_store_root = null


func test_purchase_intent_attaches_selected_held_item() -> void:
	var customer: Customer = _make_customer()
	var item: ItemInstance = _make_item("counter_case", "Counter Case")
	item.player_set_price = 20.0
	customer._desired_item = item

	customer._process_deciding()

	assert_eq(customer.current_state, Customer.State.PURCHASING)
	var snapshot: Dictionary = customer.get_held_item_snapshot()
	assert_eq(snapshot.get("state"), Customer.HELD_ITEM_STATE_SELECTED_CARRIED)
	assert_eq(snapshot.get("instance_id"), item.instance_id)
	assert_true(bool(snapshot.get("has_prop")))
	assert_eq(_held_prop_count(customer), 1)


func test_duplicate_selected_transition_keeps_single_prop() -> void:
	var customer: Customer = _make_customer()
	var item: ItemInstance = _make_item("single_copy", "Single Copy")

	customer.set_held_selected_item(item)
	customer.set_held_selected_item(item)

	assert_eq(_held_prop_count(customer), 1)
	assert_eq(customer.get_held_item_instance_id(), item.instance_id)


func test_queue_and_checkout_poses_preserve_selected_item() -> void:
	var customer: Customer = _make_customer()
	var item: ItemInstance = _make_item("queue_copy", "Queue Copy")
	customer.set_held_selected_item(item)

	customer.enter_queue(Vector3(1.0, 0.0, 0.0))
	assert_eq(customer.get_held_item_state(), Customer.HELD_ITEM_STATE_SELECTED_QUEUE)
	assert_eq(customer.get_held_item_instance_id(), item.instance_id)

	customer.advance_to_register()
	assert_eq(customer.get_held_item_state(), Customer.HELD_ITEM_STATE_SELECTED_CHECKOUT)
	assert_eq(customer.get_held_item_instance_id(), item.instance_id)
	assert_eq(_held_prop_count(customer), 1)


func test_sale_and_no_sale_clear_selected_prop_with_terminal_state() -> void:
	var sold_customer: Customer = _make_customer()
	sold_customer.set_held_selected_item(_make_item("sold_copy", "Sold Copy"))
	sold_customer.complete_purchase(true)
	var sold_snapshot: Dictionary = sold_customer.get_held_item_snapshot()
	assert_eq(sold_snapshot.get("state"), Customer.HELD_ITEM_STATE_NONE)
	assert_eq(
		sold_snapshot.get("last_terminal_state"),
		Customer.HELD_ITEM_STATE_SELECTED_SOLD
	)
	assert_eq(_held_prop_count(sold_customer), 0)

	var declined_customer: Customer = _make_customer()
	declined_customer.set_held_selected_item(_make_item("declined_copy", "Declined Copy"))
	declined_customer.complete_purchase(false)
	var declined_snapshot: Dictionary = declined_customer.get_held_item_snapshot()
	assert_eq(declined_snapshot.get("state"), Customer.HELD_ITEM_STATE_NONE)
	assert_eq(
		declined_snapshot.get("last_terminal_state"),
		Customer.HELD_ITEM_STATE_SELECTED_ABANDONED
	)
	assert_eq(_held_prop_count(declined_customer), 0)


func test_despawn_cleans_refused_return_prop() -> void:
	var customer: Customer = _make_customer()
	customer.set_held_returned_item("returned_case", &"good")
	customer.set_held_item_checkout_pose(true)
	customer.mark_held_return_refused()

	assert_eq(customer.get_held_item_state(), Customer.HELD_ITEM_STATE_RETURNED_REFUSED)
	assert_eq(_held_prop_count(customer), 1)

	customer.current_state = Customer.State.LEAVING
	customer._process_leaving()

	var snapshot: Dictionary = customer.get_held_item_snapshot()
	assert_eq(snapshot.get("state"), Customer.HELD_ITEM_STATE_NONE)
	assert_eq(
		snapshot.get("last_terminal_state"),
		Customer.HELD_ITEM_STATE_RETURNED_REFUSED
	)
	assert_eq(_held_prop_count(customer), 0)


func test_checkout_bind_synchronizes_mismatched_held_item() -> void:
	var fixture: Dictionary = _make_checkout_fixture()
	var checkout: PlayerCheckout = fixture.get("checkout") as PlayerCheckout
	var inventory: InventorySystem = fixture.get("inventory") as InventorySystem
	var customer: Customer = _make_customer()
	var stale_item: ItemInstance = _make_item("stale_copy", "Stale Copy")
	var transaction_item: ItemInstance = _make_item("transaction_copy", "Transaction Copy")
	inventory._items[transaction_item.instance_id] = transaction_item
	customer.set_held_selected_item(stale_item)
	customer._desired_item = transaction_item

	checkout._begin_checkout(customer)

	assert_eq(customer.get_held_item_instance_id(), transaction_item.instance_id)
	assert_eq(customer.get_held_item_state(), Customer.HELD_ITEM_STATE_SELECTED_CHECKOUT)
	assert_eq(_held_prop_count(customer), 1)


func test_store_session_stages_returned_item_on_customer_and_counter() -> void:
	await _load_store_scene()
	var controller: StoreSessionController = _store_session_controller()
	if controller == null:
		return

	_stage_store_session_event(controller, "day01_wrong_console_parent")
	controller._sync_customer_counter_anchor_for_stage()

	var customer: Node3D = _store_customer()
	var anchor: Node3D = _counter_anchor()
	assert_not_null(customer)
	assert_not_null(anchor)
	if customer == null or anchor == null:
		return
	assert_eq(str(customer.get_meta("held_prop_state", "")), "returned_presented")
	assert_not_null(customer.get_node_or_null("StoreSessionCustomerHeldProp"))
	assert_eq(str(anchor.get_meta("held_prop_state", "")), "returned_presented")


func test_store_session_clean_exchange_clears_returned_customer_prop() -> void:
	await _load_store_scene()
	var controller: StoreSessionController = _store_session_controller()
	if controller == null:
		return

	_stage_store_session_event(controller, "day01_wrong_console_parent")
	controller._sync_customer_counter_anchor_for_stage()
	controller.set(
		"_current_transaction_view_model",
		{"kind": RegisterTransactionViewModelScript.KIND_CLEAN_EXCHANGE}
	)
	controller._update_customer_counter_anchor_for_choice(&"clean_exchange", {"cash": 15})

	var customer: Node3D = _store_customer()
	var anchor: Node3D = _counter_anchor()
	assert_not_null(customer)
	assert_not_null(anchor)
	if customer == null or anchor == null:
		return
	assert_eq(str(customer.get_meta("last_held_prop_state", "")), "returned_accepted")
	assert_eq(str(customer.get_meta("held_prop_state", "")), "none")
	assert_eq(str(customer.get_meta("reaction_intent", "")), "react_clean_exchange")
	assert_null(customer.get_node_or_null("StoreSessionCustomerHeldProp"))
	assert_not_null(customer.get_node_or_null("StoreSessionCustomerReactionCue"))
	assert_eq(str(anchor.get_meta("held_prop_state", "")), "returned_accepted")


func test_store_session_trade_in_payout_clears_presented_prop() -> void:
	await _load_store_scene()
	var controller: StoreSessionController = _store_session_controller()
	if controller == null:
		return

	_stage_store_session_event(controller, "day02_trade_in_dispute")
	controller._sync_customer_counter_anchor_for_stage()
	var customer: Node3D = _store_customer()
	assert_not_null(customer)
	if customer == null:
		return
	assert_eq(str(customer.get_meta("held_prop_state", "")), "trade_in_presented")
	assert_not_null(customer.get_node_or_null("StoreSessionCustomerHeldProp"))

	controller.set(
		"_current_transaction_view_model",
		{
			"kind": RegisterTransactionViewModelScript.KIND_PAYOUT,
			"item_lines": [{
				"item_id": "scratched_trade",
				"role": RegisterTransactionViewModelScript.ROLE_TRADE_IN,
			}],
		}
	)
	controller._update_customer_counter_anchor_for_choice(&"accept_full_value", {"cash": -8})

	assert_eq(str(customer.get_meta("last_held_prop_state", "")), "payout_returned")
	assert_eq(str(customer.get_meta("held_prop_state", "")), "none")
	assert_eq(str(customer.get_meta("reaction_intent", "")), "react_payout_trade_in")
	assert_null(customer.get_node_or_null("StoreSessionCustomerHeldProp"))
	assert_not_null(customer.get_node_or_null("StoreSessionCustomerReactionCue"))
	assert_eq(str(_counter_anchor().get_meta("held_prop_state", "")), "payout_returned")


func test_store_session_bundle_choice_updates_customer_reaction_cue() -> void:
	await _load_store_scene()
	var controller: StoreSessionController = _store_session_controller()
	if controller == null:
		return

	_stage_store_session_event(controller, "day01_wrong_console_parent")
	controller._sync_customer_counter_anchor_for_stage()
	controller.set(
		"_current_transaction_view_model",
		{"kind": RegisterTransactionViewModelScript.KIND_BUNDLE}
	)

	controller._update_customer_counter_anchor_for_choice(&"upsell_bundle", {"cash": 18})
	var customer: Node3D = _store_customer()
	assert_not_null(customer)
	if customer == null:
		return
	assert_eq(str(customer.get_meta("reaction_intent", "")), "react_bundle_accepted")
	assert_not_null(customer.get_node_or_null("StoreSessionCustomerReactionCue"))

	controller._update_customer_counter_anchor_for_choice(&"decline_bundle", {"cash": 0})
	assert_eq(str(customer.get_meta("reaction_intent", "")), "react_bundle_rejected")
	assert_not_null(customer.get_node_or_null("StoreSessionCustomerReactionCue"))


func test_store_session_refused_return_carries_until_exit() -> void:
	await _load_store_scene()
	var controller: StoreSessionController = _store_session_controller()
	if controller == null:
		return

	_stage_store_session_event(controller, "day01_wrong_console_parent")
	controller._sync_customer_counter_anchor_for_stage()
	controller.set(
		"_current_transaction_view_model",
		{"kind": RegisterTransactionViewModelScript.KIND_REFUSED}
	)
	controller._update_customer_counter_anchor_for_choice(
		&"refuse_return",
		{"flags": {"parent_refused_return": true}}
	)

	var customer: Node3D = _store_customer()
	assert_not_null(customer)
	if customer == null:
		return
	assert_eq(str(customer.get_meta("held_prop_state", "")), "returned_refused")
	assert_eq(str(customer.get_meta("reaction_intent", "")), "react_refused_return")
	assert_not_null(customer.get_node_or_null("StoreSessionCustomerHeldProp"))
	assert_not_null(customer.get_node_or_null("StoreSessionCustomerReactionCue"))

	controller._finalize_customer_exit(customer)

	assert_eq(str(customer.get_meta("held_prop_state", "")), "none")
	assert_null(customer.get_node_or_null("StoreSessionCustomerHeldProp"))


func _make_customer() -> Customer:
	var customer := Customer.new()
	add_child_autofree(customer)
	customer.profile = _make_profile()
	return customer


func _make_profile() -> CustomerTypeDefinition:
	var profile := CustomerTypeDefinition.new()
	profile.id = "held_item_buyer"
	profile.customer_name = "Held Item Buyer"
	profile.budget_range = [5.0, 500.0]
	profile.patience = 0.8
	profile.price_sensitivity = 0.5
	profile.preferred_categories = PackedStringArray(["games"])
	profile.preferred_tags = PackedStringArray([])
	profile.condition_preference = "good"
	profile.browse_time_range = [30.0, 60.0]
	profile.purchase_probability_base = 1.0
	profile.impulse_buy_chance = 0.0
	profile.max_price_to_market_ratio = 1.0
	return profile


func _make_item(item_id: String, item_name: String) -> ItemInstance:
	var definition := ItemDefinition.new()
	definition.id = item_id
	definition.item_name = item_name
	definition.category = "games"
	definition.base_price = 20.0
	definition.rarity = "common"
	definition.tags = PackedStringArray([])
	definition.condition_range = PackedStringArray(["poor", "fair", "good", "near_mint"])
	definition.store_type = "retro_games"
	var item: ItemInstance = ItemInstance.create_from_definition(definition, "good")
	item.player_set_price = 20.0
	return item


func _make_checkout_fixture() -> Dictionary:
	var economy := EconomySystem.new()
	add_child_autofree(economy)
	economy.initialize(100.0)
	var inventory := InventorySystem.new()
	add_child_autofree(inventory)
	var customers := CustomerSystem.new()
	add_child_autofree(customers)
	var reputation := ReputationSystem.new()
	reputation.auto_connect_bus = false
	add_child_autofree(reputation)
	var checkout := PlayerCheckout.new()
	add_child_autofree(checkout)
	checkout.initialize(economy, inventory, customers, reputation)
	var panel: CheckoutPanel = CHECKOUT_PANEL_SCENE.instantiate() as CheckoutPanel
	add_child_autofree(panel)
	checkout.set_checkout_panel(panel)
	return {
		"checkout": checkout,
		"inventory": inventory,
	}


func _held_prop_count(customer: Customer) -> int:
	var count: int = 0
	for child: Node in customer.get_children():
		if String(child.name) == "HeldItemProp":
			count += 1
	return count


func _load_store_scene() -> void:
	GameManager.set_current_day(1)
	StoreSessionState.day = 1
	var scene: PackedScene = load(STORE_SCENE_PATH)
	assert_not_null(scene)
	if scene == null:
		return
	_store_root = scene.instantiate() as Node3D
	add_child(_store_root)
	await get_tree().process_frame
	await get_tree().process_frame


func _store_session_controller() -> StoreSessionController:
	if _store_root == null:
		return null
	return get_tree().get_first_node_in_group("store_session_controller") as StoreSessionController


func _stage_store_session_event(controller: StoreSessionController, event_id: String) -> void:
	controller.set("_stage", StoreSessionController.STAGE_TALK_TO_CUSTOMER)
	controller.set("_active_event", {
		"id": event_id,
		"customer_name": "Counter Customer",
		"customer_archetype": "return_customer",
		"title": "Counter Customer",
	})


func _store_customer() -> Node3D:
	if _store_root == null:
		return null
	return _store_root.get_node_or_null("StoreSessionDayOneCustomer") as Node3D


func _counter_anchor() -> Node3D:
	if _store_root == null:
		return null
	return _store_root.get_node_or_null("checkout_counter/StoreSessionCustomerCounterAnchor") as Node3D
