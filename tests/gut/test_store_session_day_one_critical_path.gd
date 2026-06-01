## Day-1 critical-path smoke test for the Shelf Life store_session.
##
## Covers the linear objective chain enforced by `StoreSessionController`:
##   PREOPENING_TRAINING → TALK_TO_CUSTOMER → BACK_ROOM_INVENTORY
##   → STOCK_SHELF → END_DAY → SUMMARY → DAY_2
## Each stage enables exactly one critical-path interactable; close-day
## remains gated until every required predecessor is complete.
##
## Also enforces the layout/alignment guarantees needed for the proximity
## prompt to fire from a normal conversational distance: Interactable
## Area3Ds anchored to their parent Node3D, customer reachable from open
## floor near the counter, day-end trigger sitting on the register.
##
## NOTE: tests instantiate retro_games.tscn directly without the wider
## autoload tree (GameManager scene swap, GameWorld systems). The
## StoreSessionController's `_apply_store_session_strip` runs in `_ready()` and
## fires `EventBus.objective_changed`, which is routed via the autoload
## EventBus, not the parent StoreController — so we exercise the controller
## state directly rather than driving signals through the full HUD.
extends GutTest

const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"
const HUD_SCENE_PATH: String = "res://game/scenes/ui/hud.tscn"
const RegisterScreenStateScript: GDScript = preload(
	"res://game/scripts/store_session/register_screen_state.gd"
)
const _STORE_ID: StringName = &"retro_games"
const _SALE_GAME_ID: String = "neo_ignite_motorway_kings_loose"
const _RETURN_GAME_ID: String = "neo_ignite_motorway_kings_westside_loose"
const _BUNDLE_CONTROLLER_ID: String = "neo_ignite_controller_standard"
const _DAY_ONE_UNLOCK_IDS: Array[StringName] = [
	&"employee_register_access",
	&"employee_stocking_trained",
	&"employee_closing_certified",
	&"extended_hours_unlock",
]
# Maximum allowed offset between an Interactable's authored origin and its
# parent Node3D origin. Anything past this is treated as visible-vs-trigger
# drift, which the prompt-alignment fix is supposed to eliminate.
const _ALIGNMENT_THRESHOLD_M: float = 0.05

var _root: Node3D = null
var _saved_state: GameManager.State
var _saved_current_day: int
var _saved_tier: StringName
var _toast_with_id_emissions: Array = []


func before_each() -> void:
	_saved_state = GameManager.current_state
	_saved_current_day = GameManager.get_current_day()
	_saved_tier = DifficultySystemSingleton.get_current_tier_id()
	DifficultySystemSingleton.set_tier(&"normal")
	GameManager.set_current_day(1)
	_register_day_one_unlock_entries()
	UnlockSystemSingleton.initialize()
	# Reset InputFocus and ModalQueue between tests so a leaked frame /
	# active-queue entry from a prior test (e.g. a freed summary panel
	# whose `_exit_tree` auto-popped but ran after this test's scene was
	# already mid-load) doesn't bleed into the assertions below.
	InputFocus._reset_for_tests()
	ModalQueue._reset_for_tests()
	_toast_with_id_emissions.clear()
	EventBus.toast_requested_with_id.connect(_on_toast_requested_with_id)
	var scene: PackedScene = load(SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load for the smoke test")
	if scene == null:
		return
	_root = scene.instantiate() as Node3D
	add_child(_root)
	# Wait one frame so _ready / call_deferred(_open_day)
	# settle before tests inspect controller state.
	await get_tree().process_frame
	await get_tree().process_frame
	# Most legacy tests in this file target the store-hours Day 1 chain, so
	# their shared fixture skips preopening. The full-route test below reloads
	# a fresh scene and walks preopening through real Interactable paths.
	_dismiss_vic_note_for_test()
	_complete_preopening_for_test()
	await get_tree().process_frame


## Dismisses a visible Vic note panel when a test explicitly enters a later-day
## note gate. Day 1 normally has no note to dismiss.
func _dismiss_vic_note_for_test() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	var panel: ManagerNotePanel = controller.get("_vic_note_panel") as ManagerNotePanel
	if panel == null:
		return
	if not panel.visible:
		return
	panel.close()
	panel.note_dismissed.emit()


func _complete_preopening_for_test() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	if bool(StoreSessionState.preopening_complete):
		return
	controller.call("force_start_real_day_for_tests")
	await get_tree().process_frame


func _register_day_one_unlock_entries() -> void:
	var display_names: Dictionary = {
		"employee_register_access": "Register Access",
		"employee_stocking_trained": "Stocking Certification",
		"employee_closing_certified": "Closing Certification",
		"extended_hours_unlock": "Extended Business Hours",
	}
	for unlock_id: StringName in _DAY_ONE_UNLOCK_IDS:
		var raw_id: String = String(unlock_id)
		if ContentRegistry.exists(raw_id):
			continue
		(
			ContentRegistry
			. register_entry(
				{
					"id": raw_id,
					"display_name": String(display_names.get(raw_id, raw_id)),
				},
				"unlock"
			)
		)


## Mirrors the runtime "player presses Close Day" path. Calls the panel's
## confirm handler so it closes (popping its CTX_MODAL frame) and emits
## `day_close_confirmed` in the same call — the controller's listener
## then advances the day exactly as it would in gameplay.
func _press_close_day_confirm(controller: Node) -> void:
	var panel: CanvasLayer = controller.get("_close_day_panel") as CanvasLayer
	if panel == null:
		EventBus.day_close_confirmed.emit()
		return
	panel.call("_on_confirm_pressed")


func after_each() -> void:
	# Reset the autoload focus/queue stacks BEFORE freeing the scene, so
	# each panel's `_exit_tree` sees an empty CTX_MODAL frame and skips
	# the safety-net push_error. Reversing this order (free first, reset
	# second) produces a cascade of `[ModalPanel] ... freed with
	# unreleased InputFocus push` lines at suite teardown that GUT counts
	# as errors — see `modal_panel.gd::_exit_tree`.
	ModalQueue._reset_for_tests()
	InputFocus._reset_for_tests()
	if is_instance_valid(_root):
		_root.free()
	_root = null
	# StoreSessionState is a global autoload that persists across tests; without
	# this reset the summary-continue test below leaves day=2 behind and
	# subsequent tests see an empty `_active_event` for day 2 (day_02.json
	# has no customer events), which causes the chain-advance early-return
	# to fire and the chain stage to never leave talk_to_customer.
	StoreSessionState.reset_new_run()
	UnlockSystemSingleton.initialize()
	GameManager.current_state = _saved_state
	GameManager.set_current_day(_saved_current_day)
	DifficultySystemSingleton.set_tier(_saved_tier)
	if EventBus.toast_requested_with_id.is_connected(_on_toast_requested_with_id):
		EventBus.toast_requested_with_id.disconnect(_on_toast_requested_with_id)


func _on_toast_requested_with_id(
	toast_id: StringName,
	message: String,
	category: StringName,
	duration: float
) -> void:
	_toast_with_id_emissions.append([toast_id, message, category, duration])


# ── Layout: customer is at the register, day-end is on the counter ──────────


func test_customer_is_staged_at_the_register() -> void:
	var customer: Node3D = _root.get_node_or_null("StoreSessionDayOneCustomer") as Node3D
	assert_not_null(customer, "StoreSessionDayOneCustomer must be authored under the store root")
	if customer == null:
		return
	var checkout: Node3D = _root.get_node_or_null("Checkout") as Node3D
	assert_not_null(checkout, "Checkout fixture must be present so the customer can stand at it")
	if checkout == null:
		return
	var horiz_distance: float = (
		Vector2(customer.global_position.x, customer.global_position.z)
		. distance_to(Vector2(checkout.global_position.x, checkout.global_position.z))
	)
	# Threshold sized for "at the left end of the counter" placement: the
	# customer is offset off-axis from the counter so the player has clear
	# walking space on every side, but still reads as part of the checkout
	# zone visually.
	assert_lt(
		horiz_distance,
		2.5,
		"Customer must be within 2.5 m of the Checkout counter (got %.2f m)" % horiz_distance
	)


func test_day_end_trigger_sits_on_the_register_counter() -> void:
	var trigger: Node3D = _root.get_node_or_null("StoreSessionDayEndTrigger") as Node3D
	assert_not_null(trigger, "StoreSessionDayEndTrigger must be authored under the store root")
	if trigger == null:
		return
	var checkout: Node3D = _root.get_node_or_null("Checkout") as Node3D
	if checkout == null:
		return
	var horiz_distance: float = (
		Vector2(trigger.global_position.x, trigger.global_position.z)
		. distance_to(Vector2(checkout.global_position.x, checkout.global_position.z))
	)
	assert_lt(
		horiz_distance,
		0.5,
		"StoreSessionDayEndTrigger must sit at the Checkout counter (got %.2f m)" % horiz_distance
	)


# ── Alignment: every store_session Interactable is anchored to its parent root ───────


func test_store_interactables_have_aligned_trigger_volumes() -> void:
	for parent_name: String in [
		"StoreSessionDayOneCustomer",
		"StoreSessionBackroomPickup",
		"StoreSessionRestockShelf",
		"StoreSessionDayEndTrigger",
		"StoreSessionHiddenClue",
	]:
		var parent: Node3D = _root.get_node_or_null(parent_name) as Node3D
		assert_not_null(parent, "%s must exist under the store root" % parent_name)
		if parent == null:
			continue
		var interactable: Node3D = parent.get_node_or_null("Interactable") as Node3D
		assert_not_null(interactable, "%s must own an Interactable child" % parent_name)
		if interactable == null:
			continue
		var drift: float = parent.global_position.distance_to(interactable.global_position)
		assert_lt(
			drift,
			_ALIGNMENT_THRESHOLD_M,
			(
				(
					"%s/Interactable must share its parent's world position (drift "
					+ "%.3f m exceeds %.2f m threshold)"
				)
				% [parent_name, drift, _ALIGNMENT_THRESHOLD_M]
			)
		)


# ── Stage gating: only the active stage's target is enabled ─────────────────


func test_stage_talk_to_customer_enables_only_the_customer() -> void:
	# At day start the customer is the active beat. The console-stack
	# flavor object is also enabled (always-on ambient flavor — see
	# `_apply_objective_gating`), but it's not on the critical path,
	# so the helper filters it out and we still expect a singleton list.
	var enabled: PackedStringArray = _stage_critical_path_targets()
	assert_eq(
		Array(enabled),
		["StoreSessionDayOneCustomer"],
		"On day start, only the customer must be the active critical-path beat"
	)


func test_day_one_start_emits_opening_toast() -> void:
	var found: bool = false
	for params: Array in _toast_with_id_emissions:
		if params.size() < 4:
			continue
		if params[0] != &"store_day1_started":
			continue
		var message: String = String(params[1])
		found = (
			message == "Store open for customers."
			and params[2] == &"info"
			and float(params[3]) > 0.0
		)
		if found:
			break
	assert_true(
		found,
		"Day 1 start must emit a short status toast, not objective instructions"
	)


func test_customer_decision_display_does_not_apply_choice_effects() -> void:
	var controller: StoreSessionController = _store_session_controller() as StoreSessionController
	if controller == null:
		return
	var starting_cash: int = StoreSessionState.cash

	await _open_customer_decision_from_interactable()

	var decision: DecisionCardPanel = controller.get("_decision_panel") as DecisionCardPanel
	assert_not_null(decision, "Customer interaction must open the decision card")
	if decision == null:
		return
	assert_true(decision.visible)
	assert_eq(StoreSessionState.cash, starting_cash)
	assert_eq(int(controller.get("_resolved_events_today")), 0)
	assert_false(bool(controller.is_objective_completed(&"talk_to_customer")))


func test_first_customer_locks_while_decision_and_result_are_active() -> void:
	var controller: StoreSessionController = _store_session_controller() as StoreSessionController
	if controller == null:
		return
	_seed_salable_day_one_inventory()
	var customer: Interactable = _store_interactable("StoreSessionDayOneCustomer")
	assert_not_null(customer, "Day 1 customer interactable must exist")
	if customer == null:
		return
	assert_true(customer.enabled)
	assert_true(customer.can_interact())

	await _open_customer_decision_from_interactable()

	var decision: DecisionCardPanel = controller.get("_decision_panel") as DecisionCardPanel
	assert_not_null(decision, "Customer interaction must open the decision card")
	if decision == null:
		return
	assert_true(decision.visible)
	assert_false(controller.can_interact_customer())
	assert_false(customer.can_interact())
	assert_false(customer.enabled)

	controller.on_store_customer_interacted()
	await get_tree().process_frame
	assert_true(decision.visible, "Duplicate interaction must not replace the decision card")

	_press_choice(decision, &"clean_exchange")
	await get_tree().process_frame
	var result: ModalPanel = controller.get("_customer_result_panel") as ModalPanel
	assert_not_null(result, "Choosing a customer option must open the result panel")
	if result == null:
		return
	assert_true(result.visible)
	assert_false(controller.can_interact_customer())
	assert_false(customer.can_interact())
	assert_false(customer.enabled)

	controller.on_store_customer_interacted()
	await get_tree().process_frame
	assert_true(result.visible, "Duplicate interaction must not close or replace the result panel")

	_acknowledge_customer_result(result)
	await get_tree().process_frame
	assert_eq(String(controller.current_stage()), "back_room_inventory")
	assert_false(customer.can_interact())


func test_duplicate_customer_result_acknowledgement_is_idempotent() -> void:
	var controller: StoreSessionController = _store_session_controller() as StoreSessionController
	if controller == null:
		return
	var fixture: Dictionary = _seed_salable_day_one_inventory()
	var economy: EconomySystem = fixture.get("economy", null) as EconomySystem
	assert_not_null(economy)
	if economy == null:
		return

	await _open_customer_decision_from_interactable()
	var event_id: StringName = StringName(
		str((controller.get("_active_event") as Dictionary).get("id", ""))
	)
	var decision: DecisionCardPanel = controller.get("_decision_panel") as DecisionCardPanel
	assert_not_null(decision)
	if decision == null:
		return
	_press_choice(decision, &"clean_exchange")
	await get_tree().process_frame
	var result: ModalPanel = controller.get("_customer_result_panel") as ModalPanel
	assert_not_null(result)
	if result == null:
		return
	_acknowledge_customer_result(result)
	await get_tree().process_frame
	var cash_after_ack: float = economy.get_cash()
	var customers_after_ack: int = int(controller.get("_customers_helped_today"))
	var sales_after_ack: int = int(controller.get("_sales_completed_today"))

	controller._on_customer_result_acknowledged(event_id, &"clean_exchange")
	await get_tree().process_frame

	assert_almost_eq(economy.get_cash(), cash_after_ack, 0.01)
	assert_eq(int(controller.get("_customers_helped_today")), customers_after_ack)
	assert_eq(int(controller.get("_sales_completed_today")), sales_after_ack)
	assert_eq(int(controller.get("_resolved_events_today")), 1)
	assert_eq(String(controller.current_stage()), "back_room_inventory")


func test_full_day_one_route_reaches_summary_and_day_two() -> void:
	await _reload_preopening_route_scene()
	var controller: StoreSessionController = _store_session_controller() as StoreSessionController
	assert_not_null(controller, "Fresh route scene must expose the store_session controller")
	if controller == null:
		return
	var route_fixture: Dictionary = _seed_salable_day_one_inventory()
	var economy: EconomySystem = route_fixture.get("economy", null) as EconomySystem
	assert_not_null(economy, "Route fixture must expose the visible economy wallet")
	if economy == null:
		return
	watch_signals(EventBus)

	assert_false(StoreSessionState.preopening_complete)
	assert_eq(String(controller.current_stage()), "training_talk_manager")
	var register_screen = _register_screen_state()
	assert_not_null(register_screen, "Route scene must expose the persistent register screen")
	if register_screen == null:
		return
	assert_false(register_screen is Interactable, "Register screen must stay non-interactive")
	assert_eq(register_screen.current_state(), RegisterScreenStateScript.STATE_INACTIVE)
	_assert_route_target("StoreSessionDayOneCustomer", "Talk to Manager")
	_assert_right_panel_header("FIRST DAY")
	await _interact_route_target("StoreSessionDayOneCustomer", "Talk to Manager")

	_assert_route_target("StoreSessionDayEndTrigger", "Check Register")
	assert_eq(String(controller.current_stage()), "training_check_register")
	assert_eq(register_screen.current_state(), RegisterScreenStateScript.STATE_READY)
	assert_eq(register_screen.display_text(), "REGISTER\nREADY")
	await _interact_route_target("StoreSessionDayEndTrigger", "Check Register")

	_assert_route_target("StoreSessionBackroomPickup", "Inspect Starter Stock Box")
	assert_eq(String(controller.current_stage()), "training_back_room_inventory")
	assert_eq(register_screen.current_state(), RegisterScreenStateScript.STATE_BACKROOM)
	assert_eq(register_screen.display_text(), "BACK\nROOM")
	await _interact_route_target("StoreSessionBackroomPickup", "Inspect Starter Stock Box")
	assert_signal_emitted_with_parameters(
		EventBus,
		"store_backroom_count_changed",
		[StoreSessionController._BACKROOM_DELIVERY_QUANTITY]
	)

	_assert_route_target("StoreSessionRestockShelf", "Place item 1 of 3 on Starter Display")
	assert_eq(String(controller.current_stage()), "training_stock_shelf")
	await _interact_route_target("StoreSessionRestockShelf", "Place item 1 of 3 on Starter Display")
	assert_false(StoreSessionState.preopening_complete)
	assert_true(StoreSessionState.carrying_stock)
	_assert_route_target("StoreSessionRestockShelf", "Place item 2 of 3 on Starter Display")
	await _interact_route_target("StoreSessionRestockShelf", "Place item 2 of 3 on Starter Display")
	assert_false(StoreSessionState.preopening_complete)
	assert_true(StoreSessionState.carrying_stock)
	_assert_route_target("StoreSessionRestockShelf", "Place item 3 of 3 on Starter Display")
	await _interact_route_target("StoreSessionRestockShelf", "Place item 3 of 3 on Starter Display")
	assert_true(StoreSessionState.preopening_complete)
	assert_false(StoreSessionState.carrying_stock)
	assert_eq(String(controller.current_stage()), "talk_to_customer")
	_assert_route_target("StoreSessionDayOneCustomer", "Talk to customer")
	_assert_right_panel_header_prefix("DAY 1")

	_assert_close_day_blocked(controller, "Talk to the customer first.")
	await _open_customer_decision_from_interactable()
	assert_eq(register_screen.current_state(), RegisterScreenStateScript.STATE_TRANSACTION)
	assert_eq(register_screen.display_text(), "TRANS\nREADY")
	var decision: DecisionCardPanel = controller.get("_decision_panel") as DecisionCardPanel
	assert_not_null(decision, "Customer interaction must open the authored decision modal")
	if decision == null:
		return
	assert_true(decision.visible)
	assert_eq(InputFocus.current(), InputFocus.CTX_MODAL)
	assert_eq(
		String((controller.get("_active_event") as Dictionary).get("id", "")),
		"day01_wrong_console_parent"
	)
	_press_choice(decision, &"clean_exchange")
	await get_tree().process_frame
	assert_eq(register_screen.current_state(), RegisterScreenStateScript.STATE_TRANSACTION)
	assert_eq(register_screen.current_amount(), 15)
	assert_eq(register_screen.display_text(), "SALE\n$15")

	var result: ModalPanel = controller.get("_customer_result_panel") as ModalPanel
	assert_not_null(result, "Choosing an authored option must open the result modal")
	if result == null:
		return
	assert_true(result.visible)
	assert_eq(InputFocus.current(), InputFocus.CTX_MODAL)
	assert_eq(StoreSessionState.input_mode, StoreSessionState.INPUT_MODE_CUSTOMER_RESULT)
	assert_eq(String(controller.current_stage()), "talk_to_customer")
	assert_false(bool(controller.is_objective_completed(&"talk_to_customer")))
	_acknowledge_customer_result(result)
	await get_tree().process_frame

	assert_ne(InputFocus.current(), InputFocus.CTX_MODAL)
	assert_eq(StoreSessionState.input_mode, StoreSessionState.INPUT_MODE_GAMEPLAY)
	assert_true(bool(controller.is_objective_completed(&"talk_to_customer")))
	assert_eq(register_screen.current_state(), RegisterScreenStateScript.STATE_BACKROOM)
	assert_eq(register_screen.display_text(), "BACK\nROOM")
	assert_eq(controller.customer_exit_state(), StoreSessionController.CUSTOMER_EXIT_IN_PROGRESS)
	assert_signal_emitted(EventBus, "item_sold")
	assert_signal_emitted(EventBus, "customer_purchased")
	var sold_params: Array = get_signal_parameters(EventBus, "item_sold", 0)
	assert_ne(str(sold_params[0]), _SALE_GAME_ID)
	assert_true(str(sold_params[0]).begins_with(_SALE_GAME_ID))
	assert_eq(float(sold_params[1]), 15.0)
	assert_eq(str(sold_params[2]), "cartridges")
	var purchased_params: Array = get_signal_parameters(EventBus, "customer_purchased", 0)
	assert_eq(purchased_params[0], _STORE_ID)
	assert_eq(purchased_params[1], StringName(str(sold_params[0])))
	assert_eq(float(purchased_params[2]), 15.0)
	assert_false(String(purchased_params[3]).is_empty())
	assert_signal_emitted_with_parameters(EventBus, "store_shelf_count_changed", [2])
	assert_signal_emitted_with_parameters(EventBus, "store_backroom_count_changed", [1])
	_assert_right_panel_stat("Customers", "1")
	_assert_right_panel_stat("Sales", "1")
	_assert_route_target("StoreSessionBackroomPickup", "Inspect Starter Stock Box")
	_assert_close_day_blocked(controller, "Inspect the Starter Stock Box first.")

	await _interact_route_target("StoreSessionBackroomPickup", "Inspect Starter Stock Box")
	assert_true(StoreSessionState.carrying_stock)
	assert_eq(register_screen.current_state(), RegisterScreenStateScript.STATE_STOCKING)
	assert_eq(register_screen.display_text(), "STOCK\nTABLE")
	assert_signal_emitted_with_parameters(
		EventBus,
		"store_backroom_count_changed",
		[StoreSessionController._BACKROOM_DELIVERY_QUANTITY + 1]
	)
	_assert_route_target("StoreSessionRestockShelf", "Place item 1 of 3 on Starter Display")
	_assert_close_day_blocked(controller, "Stock the Starter Display before closing.")

	await _interact_route_target("StoreSessionRestockShelf", "Place item 1 of 3 on Starter Display")
	assert_true(StoreSessionState.carrying_stock)
	assert_signal_emitted_with_parameters(EventBus, "store_shelf_count_changed", [3])
	assert_signal_emitted_with_parameters(EventBus, "store_backroom_count_changed", [3])
	_assert_route_target("StoreSessionRestockShelf", "Place item 2 of 3 on Starter Display")

	await _interact_route_target("StoreSessionRestockShelf", "Place item 2 of 3 on Starter Display")
	assert_true(StoreSessionState.carrying_stock)
	assert_signal_emitted_with_parameters(EventBus, "store_shelf_count_changed", [4])
	assert_signal_emitted_with_parameters(EventBus, "store_backroom_count_changed", [2])
	_assert_route_target("StoreSessionRestockShelf", "Place item 3 of 3 on Starter Display")

	await _interact_route_target("StoreSessionRestockShelf", "Place item 3 of 3 on Starter Display")
	assert_false(StoreSessionState.carrying_stock)
	var expected_shelf_count: int = StoreSessionController._BACKROOM_DELIVERY_QUANTITY + 2
	assert_signal_emitted_with_parameters(
		EventBus,
		"store_shelf_count_changed",
		[expected_shelf_count]
	)
	assert_signal_emitted_with_parameters(EventBus, "store_backroom_count_changed", [1])
	assert_eq(_spawned_shelf_item_count(), expected_shelf_count)
	_assert_right_panel_stat("Shelf", "%d / %d" % [expected_shelf_count, expected_shelf_count + 1])
	_assert_right_panel_stat("Stockroom", "1")
	_assert_route_target("StoreSessionDayEndTrigger", "Close day")
	assert_eq(register_screen.current_state(), RegisterScreenStateScript.STATE_CLOSE_READY)
	assert_eq(register_screen.display_text(), "CLOSE\nDAY")
	assert_ne(register_screen.display_text(), "REGISTER\nREADY")

	await _interact_route_target("StoreSessionDayEndTrigger", "Close day")
	var close_day_panel: CanvasLayer = controller.get("_close_day_panel") as CanvasLayer
	assert_not_null(close_day_panel, "Close-day request must open the confirmation modal")
	if close_day_panel == null:
		return
	assert_true(close_day_panel.visible)
	assert_eq(InputFocus.current(), InputFocus.CTX_MODAL)
	_press_close_day_confirm(controller)
	await get_tree().process_frame
	await get_tree().process_frame
	assert_eq(register_screen.current_state(), RegisterScreenStateScript.STATE_INACTIVE)
	assert_eq(register_screen.display_text(), "CLOSED")

	var summary_panel: DaySummaryPanel = controller.get("_summary_panel") as DaySummaryPanel
	assert_not_null(summary_panel, "Close-day confirm must open the summary")
	if summary_panel == null:
		return
	assert_true(summary_panel.visible)
	assert_eq(InputFocus.current(), InputFocus.CTX_MODAL)
	assert_signal_emitted_with_parameters(EventBus, "store_objective_completed", [&"close_day"])
	var metrics: RichTextLabel = summary_panel.get("_metrics_label") as RichTextLabel
	assert_not_null(metrics)
	if metrics != null:
		assert_string_contains(metrics.text, "Starting Cash:[/b] $500")
		assert_string_contains(metrics.text, "Sales:[/b] $15")
		assert_string_contains(metrics.text, "Rent (review only):[/b] -$50")
		assert_string_contains(metrics.text, "Profit after rent:[/b] -$35")
		assert_string_contains(metrics.text, "Ending Cash:[/b] $515")
	_assert_summary_label(summary_panel, "_customers_helped_label", "Customers Helped: 1")
	_assert_summary_label(summary_panel, "_items_stocked_label", "Items Stocked: 3")
	_assert_summary_label(summary_panel, "_sales_completed_label", "Sales Completed: 1")
	_assert_summary_label(
		summary_panel,
		"_shelf_inventory_label",
		"Shelf Inventory: %d" % expected_shelf_count
	)
	_assert_summary_label(summary_panel, "_backroom_inventory_label", "Back Room Inventory: 1")
	var review_button: Button = summary_panel.get("_review_inventory_button") as Button
	var audit_details: VBoxContainer = summary_panel.get("_audit_details") as VBoxContainer
	assert_not_null(review_button, "Summary must expose Review Inventory")
	assert_not_null(audit_details, "Summary must own inventory audit detail rows")
	if review_button != null and audit_details != null:
		assert_false(audit_details.visible)
		review_button.pressed.emit()
		assert_true(audit_details.visible)
		_assert_summary_label(
			summary_panel,
			"_audit_shelf_label",
			"  • On-shelf count at close: %d" % expected_shelf_count
		)
		_assert_summary_label(
			summary_panel,
			"_audit_backroom_label",
			"  • Back room remaining at close: 1"
		)

	var reinvest_button: Button = summary_panel.get("_reinvest_button") as Button
	var reinvest_status: Label = summary_panel.get("_reinvest_status_label") as Label
	assert_not_null(reinvest_button, "Summary must expose the reorder action")
	assert_not_null(reinvest_status, "Summary must expose reorder status copy")
	if reinvest_button != null and reinvest_status != null:
		assert_false(reinvest_button.disabled, "Reorder must be affordable after the sale route")
		assert_string_contains(reinvest_button.text, "$20")
		assert_string_contains(reinvest_status.text, "2 more used games arrive next shift")
		reinvest_button.pressed.emit()
		await get_tree().process_frame
		assert_true(reinvest_button.disabled, "Applied reorder must disable the button")
		assert_string_contains(reinvest_status.text, "Ordered 2 extra used games")
		assert_almost_eq(economy.get_cash(), 495.0, 0.01)
		assert_eq(int(controller.get("_pending_extra_delivery_quantity")), 2)

	var continue_button: Button = summary_panel.get("_continue_button") as Button
	assert_not_null(continue_button, "Summary must expose Continue")
	if continue_button == null:
		return
	watch_signals(EventBus)
	continue_button.pressed.emit()
	await get_tree().process_frame

	assert_eq(StoreSessionState.day, 2)
	assert_eq(GameManager.get_current_day(), 2)
	assert_eq(
		int(controller.get("_current_delivery_quantity")),
		StoreSessionController._BACKROOM_DELIVERY_QUANTITY
		+ StoreSessionController._REORDER_EXTRA_QUANTITY
	)
	assert_ne(InputFocus.current(), InputFocus.CTX_MODAL)
	assert_signal_emitted_with_parameters(EventBus, "day_started", [2])
	assert_eq(String(controller.current_stage()), "talk_to_customer")
	assert_eq(
		String((controller.get("_active_event") as Dictionary).get("id", "")),
		"day02_trade_in_dispute"
	)


func test_customer_choice_opens_result_before_next_stage() -> void:
	var controller: Node = _store_session_controller()
	assert_not_null(controller)
	if controller == null:
		return

	controller.on_store_customer_interacted()
	await get_tree().process_frame
	var decision: DecisionCardPanel = controller.get("_decision_panel") as DecisionCardPanel
	assert_not_null(decision)
	if decision == null:
		return
	var buttons: Array = decision.get("_choice_buttons") as Array
	assert_gt(buttons.size(), 0, "Decision card must render the customer choices")
	(buttons[0] as Button).pressed.emit()
	await get_tree().process_frame

	var result: ModalPanel = controller.get("_customer_result_panel") as ModalPanel
	assert_not_null(result)
	if result == null:
		return
	assert_true(result.visible, "Customer result must pause after the choice")
	assert_eq(StoreSessionState.input_mode, StoreSessionState.INPUT_MODE_CUSTOMER_RESULT)
	assert_eq(
		controller.current_stage(),
		controller.STAGE_TALK_TO_CUSTOMER,
		"Customer result must not advance the objective until Continue"
	)
	assert_false(
		bool(controller.is_objective_completed(&"talk_to_customer")),
		"Customer objective must wait for result acknowledgement"
	)
	var acknowledgement: Label = result.get("_acknowledgement_label") as Label
	assert_not_null(acknowledgement)
	if acknowledgement != null:
		assert_false(
			acknowledgement.text.contains("$"),
			"Result acknowledgement must not be the cash evidence surface"
		)
	assert_null(
		result.get("_consequences_box"),
		"Result acknowledgement must not render consequence rows"
	)

	var continue_button: Button = result.get("_continue_button") as Button
	assert_not_null(continue_button)
	if continue_button == null:
		return
	watch_signals(EventBus)
	continue_button.pressed.emit()
	await get_tree().process_frame

	assert_false(result.visible)
	assert_signal_not_emitted(
		EventBus, "item_sold", "Missing real stock must not emit a false item_sold signal"
	)
	assert_signal_not_emitted(
		EventBus,
		"customer_purchased",
		"Missing real stock must not emit a false customer_purchased signal"
	)
	assert_eq(StoreSessionState.cash, 0, "Missing real stock must not book positive sale cash")
	assert_eq(
		StoreSessionState.reputation,
		0,
		"Missing real stock must not book positive reputation from a failed sale"
	)
	assert_eq(StoreSessionState.input_mode, StoreSessionState.INPUT_MODE_GAMEPLAY)
	assert_eq(
		Array(_stage_critical_path_targets()),
		["StoreSessionBackroomPickup"],
		"Continue must return control on the next Day 1 objective"
	)
	assert_true(bool(controller.is_objective_completed(&"talk_to_customer")))


func test_customer_choice_with_missing_stock_fails_closed() -> void:
	var controller: Node = _store_session_controller()
	assert_not_null(controller)
	if controller == null:
		return
	_seed_day_one_inventory_systems()
	watch_signals(EventBus)

	controller._on_choice_selected(&"clean_exchange", _choice_effects(controller, &"clean_exchange"))
	await get_tree().process_frame

	assert_signal_not_emitted(EventBus, "item_sold")
	assert_signal_not_emitted(EventBus, "customer_purchased")
	assert_eq(StoreSessionState.cash, 0)
	assert_eq(StoreSessionState.reputation, 0)
	var transactions: Array = controller.get("_customer_inventory_transactions") as Array
	assert_gt(transactions.size(), 0)
	var transaction: Dictionary = transactions.back() as Dictionary
	assert_false(bool(transaction.get("ok", true)))
	var failures: Array = transaction.get("failed", []) as Array
	assert_gt(failures.size(), 0)
	assert_eq(str((failures[0] as Dictionary).get("reason", "")), "missing_matching_stock")


func test_customer_choice_with_unsupported_inventory_op_fails_closed() -> void:
	var controller: Node = _store_session_controller()
	assert_not_null(controller)
	if controller == null:
		return
	_seed_day_one_inventory_systems()
	var effects: Dictionary = {
		"cash": 20,
		"reputation": 2,
		"manager_trust": 1,
		"requires_inventory_success": true,
		"inventory": [{"op": "unsupported", "store_id": String(_STORE_ID)}],
	}
	watch_signals(EventBus)

	controller._on_choice_selected(&"clean_exchange", effects)
	await get_tree().process_frame

	assert_signal_not_emitted(EventBus, "item_sold")
	assert_signal_not_emitted(EventBus, "customer_purchased")
	assert_eq(StoreSessionState.cash, 0)
	assert_eq(StoreSessionState.reputation, 0)
	assert_eq(StoreSessionState.manager_trust, 0)
	var transactions: Array = controller.get("_customer_inventory_transactions") as Array
	assert_gt(transactions.size(), 0)
	var transaction: Dictionary = transactions.back() as Dictionary
	assert_false(bool(transaction.get("ok", true)))
	var failures: Array = transaction.get("failed", []) as Array
	assert_gt(failures.size(), 0)
	assert_eq(str((failures[0] as Dictionary).get("reason", "")), "unsupported_operation")


func test_chain_walks_customer_then_back_room_then_stock_then_close() -> void:
	# Linear chain: TALK_TO_CUSTOMER → BACK_ROOM_INVENTORY → STOCK_SHELF
	# → END_DAY. After each step's interaction completes, exactly one
	# downstream interactable should be the active critical-path beat —
	# never skipping ahead, never overlapping. Close-day is the last
	# link: it stays disabled until every required predecessor is done
	# AND the time gate has cleared, so the player cannot close the day
	# at 9 AM by walking straight to the register.
	var controller: Node = _store_session_controller()
	assert_not_null(controller)
	if controller == null:
		return
	assert_false(
		UnlockSystemSingleton.is_unlocked(&"employee_register_access"),
		"Register access must not be pre-granted at day start"
	)
	assert_false(
		UnlockSystemSingleton.is_unlocked(&"employee_stocking_trained"),
		"Stocking certification must not be pre-granted at day start"
	)

	# Customer step → completes talk_to_customer, advances to BACK_ROOM_INVENTORY.
	controller._on_choice_selected(&"clean_exchange", {})
	await get_tree().process_frame
	assert_eq(
		Array(_stage_critical_path_targets()),
		["StoreSessionBackroomPickup"],
		"After resolving the customer, the back-room beat must be active"
	)
	assert_true(
		bool(controller.is_objective_completed(&"talk_to_customer")),
		"talk_to_customer must be marked complete"
	)
	assert_true(
		UnlockSystemSingleton.is_unlocked(&"employee_register_access"),
		"Customer/register resolution must grant register access"
	)
	assert_false(
		UnlockSystemSingleton.is_unlocked(&"employee_stocking_trained"),
		"Customer/register resolution must not grant stocking certification"
	)

	# Back-room step → completes back_room_inventory, advances to STOCK_SHELF.
	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	assert_eq(
		Array(_stage_critical_path_targets()),
		["StoreSessionRestockShelf"],
		"After the back-room check, the stock-shelf beat must be active"
	)
	assert_true(bool(controller.is_objective_completed(&"back_room_inventory")))
	assert_false(
		UnlockSystemSingleton.is_unlocked(&"employee_stocking_trained"),
		"Inventory check must not grant stocking certification"
	)

	# Stock step → completes stock_shelf, advances to END_DAY. In the test
	# environment there is no TimeSystem, so the auto-jump-to-close-time
	# is a no-op and the day-end trigger becomes the next valid E-press.
	# Production play has the chain's accumulated time costs (30+30+60 =
	# 120 min) finish at ~11 AM and `_jump_to_close_time_if_early` advances
	# the clock to 17:00 so the close-day prompt is immediately reachable.
	controller.on_store_restock_interacted()
	await get_tree().process_frame
	assert_eq(
		Array(_stage_critical_path_targets()),
		["StoreSessionDayEndTrigger"],
		"After stocking the shelf, the day-end trigger must be active"
	)
	assert_true(bool(controller.is_objective_completed(&"stock_shelf")))
	assert_true(
		UnlockSystemSingleton.is_unlocked(&"employee_stocking_trained"),
		"Shelf interaction must grant stocking certification after it succeeds"
	)
	assert_eq(
		String(controller.get("_stage")),
		"end_day",
		"Stage must end at STAGE_END_DAY after all required objectives"
	)


func test_pregranted_unlocks_do_not_skip_day_one_objectives() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	UnlockSystemSingleton.grant_unlock(&"employee_register_access")
	UnlockSystemSingleton.grant_unlock(&"employee_stocking_trained")
	UnlockSystemSingleton.grant_unlock(&"employee_closing_certified")
	controller._apply_objective_gating()

	assert_eq(
		String(controller.get("_stage")),
		"talk_to_customer",
		"Pregranted employee unlocks must not advance the Day 1 stage"
	)
	assert_eq(
		Array(_stage_critical_path_targets()),
		["StoreSessionDayOneCustomer"],
		"Pregranted employee unlocks must not enable later Day 1 targets"
	)
	assert_false(
		bool(controller.can_interact_day_end()),
		"Pregranted closing certification must not unlock the Day 1 close trigger"
	)


func test_day_one_unlock_grants_emit_unlock_toasts() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	watch_signals(EventBus)

	controller._on_choice_selected(&"clean_exchange", {})
	await get_tree().process_frame
	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	controller.on_store_restock_interacted()
	await get_tree().process_frame
	controller._on_day_close_confirmed()
	await get_tree().process_frame

	var emissions: Array = get_signal_parameters_all(EventBus, "toast_requested_with_id")
	assert_true(
		_toast_id_seen(emissions, &"unlock_employee_register_access"),
		"Register access grant must emit an unlock toast with a matching id"
	)
	assert_true(
		_toast_id_seen(emissions, &"unlock_employee_stocking_trained"),
		"Stocking certification grant must emit an unlock toast with a matching id"
	)
	assert_true(
		_toast_id_seen(emissions, &"unlock_employee_closing_certified"),
		"Closing certification grant must emit an unlock toast with a matching id"
	)
	assert_false(
		_toast_id_seen(emissions, &"unlock_extended_hours_unlock"),
		"Day 1 must not emit an extended-hours unlock toast"
	)


func test_console_stack_is_ambient_flavor_not_a_chain_step() -> void:
	# Tone rule: the console stack is not the mystery objective. It is
	# always interactable (until inspected), and inspecting it never
	# advances the active chain. Inspecting at TALK_TO_CUSTOMER stage
	# leaves the stage on TALK_TO_CUSTOMER.
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	var pre_stage: String = String(controller.get("_stage"))
	controller.on_store_hidden_clue_interacted()
	await get_tree().process_frame
	assert_eq(
		String(controller.get("_stage")),
		pre_stage,
		"Inspecting the console stack must not advance the chain"
	)
	assert_false(
		bool(controller.is_objective_completed(&"talk_to_customer")),
		"Inspecting the console stack must not flip a chain objective complete"
	)


func test_close_day_is_locked_at_day_start() -> void:
	# Belt-and-suspenders: the day-end trigger must be disabled at fresh
	# day start regardless of where the player walks. The 9 AM
	# close-day bug fired because the FSM jumped to END_DAY on
	# single-event days; this test fails fast if that regression returns.
	var enabled: PackedStringArray = _enabled_store_critical_path_targets()
	assert_false(
		Array(enabled).has("StoreSessionDayEndTrigger"),
		(
			"Day-end trigger must be disabled at day start (not enabled until "
			+ "all required objectives complete). Enabled list: %s" % str(enabled)
		)
	)


func test_store_prompt_copy_uses_plain_action_language() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	assert_eq(_interaction_label(_store_interactable("StoreSessionDayOneCustomer")), "Talk to customer")
	assert_eq(
		_interaction_label(_store_interactable("StoreSessionBackroomPickup")), "Inspect Starter Stock Box"
	)
	assert_eq(_interaction_label(_store_interactable("StoreSessionRestockShelf")), "Stock Starter Display")
	assert_eq(_interaction_label(_store_interactable("StoreSessionDayEndTrigger")), "Close day")


func test_future_stage_disabled_reasons_name_next_prerequisite() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	assert_eq(String(controller.day_end_disabled_reason()), "Talk to the customer first.")

	controller._on_choice_selected(&"clean_exchange", {})
	await get_tree().process_frame
	assert_eq(String(controller.day_end_disabled_reason()), "Inspect the Starter Stock Box first.")

	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	assert_eq(
		String(controller.day_end_disabled_reason()), "Stock the Starter Display before closing."
	)


func test_repeated_customer_choice_does_not_double_apply_effects() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	var economy: EconomySystem = EconomySystem.new()
	add_child_autofree(economy)
	economy.initialize(500.0)

	controller._on_choice_selected(&"upsell_bundle", {"cash": 18})
	await get_tree().process_frame
	controller._on_choice_selected(&"upsell_bundle", {"cash": 18})
	await get_tree().process_frame

	assert_almost_eq(
		economy.get_cash(),
		518.0,
		0.01,
		"Repeated customer choice dispatch must not credit cash twice"
	)
	assert_eq(
		int(controller.get("_resolved_events_today")),
		1,
		"Repeated customer choice dispatch must not count two resolved events"
	)


func test_repeated_backroom_and_restock_presses_are_idempotent() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	controller._on_choice_selected(&"clean_exchange", {})
	await get_tree().process_frame

	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	assert_eq(
		String(controller.current_stage()),
		"stock_shelf",
		"Repeated back-room presses must leave the chain at the shelf beat"
	)
	var completed: Dictionary = controller.get("_completed_objectives") as Dictionary
	assert_true(completed.has(&"back_room_inventory"))
	assert_eq(
		completed.size(), 2, "Repeated back-room presses must not add extra completion entries"
	)

	controller.on_store_restock_interacted()
	await get_tree().process_frame
	controller.on_store_restock_interacted()
	await get_tree().process_frame
	assert_eq(
		String(controller.current_stage()),
		"end_day",
		"Repeated shelf presses must leave the chain at close-day"
	)
	assert_true(completed.has(&"stock_shelf"))
	assert_eq(completed.size(), 3, "Repeated shelf presses must not add extra completion entries")


func test_repeated_close_day_request_does_not_push_second_modal() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	controller._on_choice_selected(&"clean_exchange", {})
	await get_tree().process_frame
	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	controller.on_store_restock_interacted()
	await get_tree().process_frame

	controller.on_store_day_end_requested()
	await get_tree().process_frame
	var depth_after_first: int = InputFocus.depth()
	controller.on_store_day_end_requested()
	await get_tree().process_frame

	assert_eq(
		InputFocus.depth(),
		depth_after_first,
		"Repeated close-day requests while the modal is open must not push twice"
	)
	var close_day_panel: CanvasLayer = controller.get("_close_day_panel") as CanvasLayer
	if close_day_panel != null:
		close_day_panel.call("close")


func test_fp_close_day_hint_hidden_until_close_day_unlocked() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	var scene: PackedScene = load(HUD_SCENE_PATH)
	assert_not_null(scene, "HUD scene must load")
	if scene == null:
		return
	var hud: CanvasLayer = scene.instantiate() as CanvasLayer
	add_child_autofree(hud)
	hud.set_fp_mode(true)
	var hint: Label = hud.get_node_or_null("FpCloseDayHint") as Label
	assert_not_null(hint, "FP close-day hint must be created in FP mode")
	if hint == null:
		return
	assert_false(
		hint.visible, "F4 close-day hint must stay hidden while required objectives remain"
	)

	controller._on_choice_selected(&"clean_exchange", {})
	await get_tree().process_frame
	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	controller.on_store_restock_interacted()
	await get_tree().process_frame
	hud._refresh_close_day_hint_state()

	assert_true(
		hint.visible,
		"F4 close-day hint may appear only after the physical close-day trigger unlocks"
	)


func test_hidden_clue_does_not_expose_active_prompt_during_chain() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	var clue: Interactable = _store_interactable("StoreSessionHiddenClue")
	assert_not_null(clue, "StoreSessionHiddenClue/Interactable must exist")
	if clue == null:
		return
	assert_false(clue.enabled, "Hidden clue must not steal the customer prompt")
	assert_false(clue.can_interact(), "Hidden clue must never be an active Day-1 prompt")
	assert_eq(clue.get_disabled_reason(), "")

	controller._on_choice_selected(&"clean_exchange", {})
	await get_tree().process_frame
	assert_false(clue.enabled, "Hidden clue must not steal the back-room prompt")

	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	assert_false(clue.enabled, "Hidden clue must not steal the shelf prompt")

	controller.on_store_restock_interacted()
	await get_tree().process_frame
	assert_false(clue.enabled, "Hidden clue must not compete with close-day")


func test_invalid_objective_target_path_fails_closed_with_diagnostic() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	var objectives: Array = controller.get("_objectives") as Array
	assert_false(objectives.is_empty(), "Pre-condition: objective table exists")
	if objectives.is_empty():
		return
	objectives[0]["target_path"] = "MissingObjectiveTarget/Interactable"
	controller.set("_stage", StoreSessionController.STAGE_TALK_TO_CUSTOMER)
	controller._apply_objective_gating()

	assert_eq(
		Array(_enabled_store_critical_path_targets()),
		[],
		"Invalid active target path must leave store_session critical-path targets disabled"
	)
	var indicator: Interactable = _register_status_indicator()
	assert_not_null(indicator, "Register status indicator precondition")
	if indicator != null:
		assert_false(
			indicator.enabled, "Invalid active target path must not leave passive hints focusable"
		)
	var snap: Dictionary = controller.get_state_snapshot()
	assert_string_contains(
		String(snap.get("objective_target_diagnostic", "")), "MissingObjectiveTarget/Interactable"
	)


func test_state_snapshot_reports_close_day_blocked_until_chain_done() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	var snap: Dictionary = controller.get_state_snapshot()
	assert_false(
		bool(snap.get("can_close_day", true)),
		"Snapshot must report can_close_day=false at day start"
	)
	assert_ne(
		String(snap.get("close_day_reason", "")),
		"",
		"Snapshot must surface a non-empty close_day_reason while blocked"
	)


func test_state_snapshot_exposes_stage_and_completed_growing_through_chain() -> void:
	var controller: Node = _store_session_controller()
	assert_not_null(controller)
	if controller == null:
		return

	var snap_start: Dictionary = controller.get_state_snapshot()
	assert_eq(
		String(snap_start.get("stage", "")),
		String(controller.get("_stage")),
		"Snapshot stage must match controller._stage as a String"
	)
	var completed_start: Dictionary = snap_start.get("completed_objectives", {}) as Dictionary
	assert_eq(
		completed_start.size(), 0, "completed_objectives must start empty before any chain step"
	)

	controller._on_choice_selected(&"clean_exchange", {})
	await get_tree().process_frame
	var completed_after_customer: Dictionary = (
		controller.get_state_snapshot().get("completed_objectives", {}) as Dictionary
	)
	assert_true(
		completed_after_customer.has(&"talk_to_customer"),
		"completed_objectives must contain talk_to_customer after the customer step"
	)

	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	var completed_after_backroom: Dictionary = (
		controller.get_state_snapshot().get("completed_objectives", {}) as Dictionary
	)
	assert_eq(
		completed_after_backroom.size(),
		completed_after_customer.size() + 1,
		"completed_objectives must grow by one after the back-room step"
	)
	assert_true(completed_after_backroom.has(&"back_room_inventory"))

	controller.on_store_restock_interacted()
	await get_tree().process_frame
	var snap_end: Dictionary = controller.get_state_snapshot()
	var completed_after_stock: Dictionary = snap_end.get("completed_objectives", {}) as Dictionary
	assert_eq(
		completed_after_stock.size(),
		completed_after_backroom.size() + 1,
		"completed_objectives must grow by one after the stock-shelf step"
	)
	assert_true(completed_after_stock.has(&"stock_shelf"))
	assert_eq(
		String(snap_end.get("stage", "")),
		"end_day",
		"Snapshot stage must reach end_day after all required objectives complete"
	)


func test_state_snapshot_mirrors_store_session_state_fields() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	var snap: Dictionary = controller.get_state_snapshot()
	assert_eq(
		int(snap.get("day", -1)), StoreSessionState.day, "Snapshot day must mirror StoreSessionState.day"
	)
	assert_eq(
		int(snap.get("cash", -1)), StoreSessionState.cash, "Snapshot cash must mirror StoreSessionState.cash"
	)
	assert_eq(
		bool(snap.get("carrying_stock", true)),
		StoreSessionState.carrying_stock,
		"Snapshot carrying_stock must mirror StoreSessionState.carrying_stock"
	)


func test_session_progress_snapshot_exposes_objective_customer_carry_and_prompt() -> void:
	var controller: StoreSessionController = _store_session_controller() as StoreSessionController
	if controller == null:
		return

	var start: Dictionary = controller.get_session_progress_snapshot()
	assert_eq(str(start.get("stage", "")), "talk_to_customer")
	var start_objective: Dictionary = start.get("objective", {}) as Dictionary
	assert_eq(str(start_objective.get("id", "")), "talk_to_customer")
	assert_eq(str(start_objective.get("target_path", "")), "StoreSessionDayOneCustomer/Interactable")
	var start_customer: Dictionary = start.get("customer", {}) as Dictionary
	assert_eq(str(start_customer.get("event_id", "")), "day01_wrong_console_parent")
	assert_eq(str(start_customer.get("exit_state", "")), String(StoreSessionController.CUSTOMER_EXIT_NOT_STARTED))
	var start_carry: Dictionary = start.get("carry", {}) as Dictionary
	assert_false(bool(start_carry.get("carrying_stock", true)))
	var start_prompt: Dictionary = start.get("visible_prompt", {}) as Dictionary
	assert_eq(str(start_prompt.get("label", "")), "Talk to customer")

	controller._on_choice_selected(&"clean_exchange", {})
	await get_tree().process_frame
	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame

	var carrying: Dictionary = controller.get_session_progress_snapshot()
	assert_eq(str(carrying.get("stage", "")), "stock_shelf")
	var carry: Dictionary = carrying.get("carry", {}) as Dictionary
	assert_true(bool(carry.get("carrying_stock", false)))
	assert_eq(int(carry.get("remaining", 0)), StoreSessionController._BACKROOM_DELIVERY_QUANTITY)
	var prompt: Dictionary = carrying.get("visible_prompt", {}) as Dictionary
	assert_eq(str(prompt.get("target_path", "")), "StoreSessionRestockShelf/Interactable")
	assert_string_contains(str(prompt.get("label", "")), "Place item 1")


func test_state_snapshot_is_json_serializable() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	# Walk the chain so completed_objectives is non-empty when serializing.
	controller._on_choice_selected(&"clean_exchange", {})
	await get_tree().process_frame
	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	var snap: Dictionary = controller.get_state_snapshot()
	var encoded: String = JSON.stringify(snap)
	assert_ne(encoded, "", "Snapshot must JSON-encode to a non-empty string")
	var parsed: Variant = JSON.parse_string(encoded)
	assert_true(parsed is Dictionary, "JSON-encoded snapshot must round-trip back to a Dictionary")


# ── Helpers ─────────────────────────────────────────────────────────────────


func _store_session_controller() -> Node:
	return get_tree().get_first_node_in_group("store_session_controller")


func _store_interactable(parent_name: String) -> Interactable:
	if _root == null:
		return null
	return _root.get_node_or_null("%s/Interactable" % parent_name) as Interactable


func _interaction_label(target: Interactable) -> String:
	if target == null:
		return ""
	return target.get_prompt_label()


func _production_day_cycle_fixture() -> Dictionary:
	var time := TimeSystem.new()
	add_child_autofree(time)
	time.initialize()
	time.current_day = 1

	var economy := EconomySystem.new()
	add_child_autofree(economy)
	economy.initialize(500.0)

	var staff := StaffSystem.new()
	add_child_autofree(staff)

	var progression := ProgressionSystem.new()
	add_child_autofree(progression)

	var ending_eval := EndingEvaluatorSystem.new()
	add_child_autofree(ending_eval)
	ending_eval.initialize()

	var perf_report := PerformanceReportSystem.new()
	add_child_autofree(perf_report)
	perf_report.initialize()

	var day_cycle := DayCycleController.new()
	add_child_autofree(day_cycle)
	day_cycle.initialize(time, economy, staff, progression, ending_eval, perf_report)
	return {
		"controller": day_cycle,
		"time": time,
	}


## GUT's `get_signal_parameters` returns the params of one emission and
## crashes if the index runs past the end. Use `get_signal_emit_count` as
## the loop bound so the helper stays safe even when no emissions have
## been captured yet. Multiple emits land on the same channel during a
## single frame (rail updates, toasts, etc.) — collect all matching
## emissions so message-content assertions can scan the whole batch.
func get_signal_parameters_all(emitter: Object, signal_name: String) -> Array:
	var out: Array = []
	var count: int = get_signal_emit_count(emitter, signal_name)
	for idx: int in range(count):
		var params: Variant = get_signal_parameters(emitter, signal_name, idx)
		if params != null:
			out.append(params)
	return out


func _toast_id_seen(emissions: Array, expected_id: StringName) -> bool:
	return _signal_first_arg_seen(emissions, expected_id)


func _signal_first_arg_seen(emissions: Array, expected_id: StringName) -> bool:
	for params: Array in emissions:
		if params.size() > 0 and params[0] == expected_id:
			return true
	return false


## Returns the names of the store_session day-1 critical-path parents whose
## Interactable child is currently enabled. Stable across iterations so an
## `assert_eq(Array(...), [...])` matches predictably. Includes the
## ambient-flavor StoreSessionHiddenClue, which is always-on until inspected.
func _enabled_store_critical_path_targets() -> PackedStringArray:
	var out: PackedStringArray = []
	for parent_name: String in [
		"StoreSessionDayOneCustomer",
		"StoreSessionHiddenClue",
		"StoreSessionBackroomPickup",
		"StoreSessionRestockShelf",
		"StoreSessionDayEndTrigger",
	]:
		var parent: Node = _root.get_node_or_null(parent_name)
		if parent == null:
			continue
		var interactable: Node = parent.get_node_or_null("Interactable")
		if interactable is Interactable and (interactable as Interactable).enabled:
			out.append(parent_name)
	return out


## Like `_enabled_store_critical_path_targets`, but filters out the
## always-on StoreSessionHiddenClue flavor object so chain-progression assertions
## can match a singleton list against the active stage's target.
func _stage_critical_path_targets() -> PackedStringArray:
	var out: PackedStringArray = []
	for parent_name: String in _enabled_store_critical_path_targets():
		if parent_name == "StoreSessionHiddenClue":
			continue
		out.append(parent_name)
	return out


func _reload_preopening_route_scene() -> void:
	ModalQueue._reset_for_tests()
	InputFocus._reset_for_tests()
	if is_instance_valid(_root):
		_root.free()
	_root = null
	StoreSessionState.reset_new_run()
	StoreSessionState.preopening_complete = false
	GameManager.set_current_day(1)
	UnlockSystemSingleton.initialize()
	var scene: PackedScene = load(SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load for the full route")
	if scene == null:
		return
	_root = scene.instantiate() as Node3D
	add_child(_root)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame


func _seed_salable_day_one_inventory() -> Dictionary:
	var fixture: Dictionary = _seed_day_one_inventory_systems()
	var inventory: InventorySystem = fixture.get("inventory", null) as InventorySystem
	var data_loader: DataLoader = fixture.get("data_loader", null) as DataLoader
	if inventory == null or data_loader == null:
		return fixture
	var definition: ItemDefinition = data_loader.get_item(_SALE_GAME_ID)
	assert_not_null(definition, "Route sale fixture must seed the Day 1 sale item")
	if definition == null:
		return fixture
	var item: ItemInstance = ItemInstance.create(definition, "good", 0, definition.base_price)
	item.current_location = "shelf:day_one_route"
	inventory.add_item(_STORE_ID, item)
	fixture["item"] = item
	return fixture


func _seed_bundle_day_one_inventory() -> Dictionary:
	var fixture: Dictionary = _seed_salable_day_one_inventory()
	var inventory: InventorySystem = fixture.get("inventory", null) as InventorySystem
	var data_loader: DataLoader = fixture.get("data_loader", null) as DataLoader
	if inventory == null or data_loader == null:
		return fixture
	var definition: ItemDefinition = data_loader.get_item(_BUNDLE_CONTROLLER_ID)
	assert_not_null(definition, "Bundle sale fixture must seed the add-on controller")
	if definition == null:
		return fixture
	var item: ItemInstance = ItemInstance.create(definition, "good", 0, definition.base_price)
	item.current_location = "shelf:day_one_bundle_controller"
	inventory.add_item(_STORE_ID, item)
	fixture["bundle_item"] = item
	return fixture


func _seed_day_one_inventory_systems() -> Dictionary:
	var data_loader: DataLoader = DataLoader.new()
	add_child_autofree(data_loader)
	_seed_route_item_definitions(data_loader)
	var inventory: InventorySystem = InventorySystem.new()
	add_child_autofree(inventory)
	inventory.initialize(data_loader)
	var economy: EconomySystem = EconomySystem.new()
	add_child_autofree(economy)
	economy.initialize(500.0)
	return {
		"data_loader": data_loader,
		"inventory": inventory,
		"economy": economy,
	}


func _seed_route_item_definitions(data_loader: DataLoader) -> void:
	var items: Dictionary = {}
	items[_SALE_GAME_ID] = _route_item_definition(
		_SALE_GAME_ID,
		"Motorway Kings",
		&"cartridges",
		22.0
	)
	items[_RETURN_GAME_ID] = _route_item_definition(
		_RETURN_GAME_ID,
		"Motorway Kings: Westside",
		&"cartridges",
		32.0
	)
	items[_BUNDLE_CONTROLLER_ID] = _route_item_definition(
		_BUNDLE_CONTROLLER_ID,
		"Neo Ignite Controller",
		&"accessories",
		24.0
	)
	data_loader.set("_items", items)


func _route_item_definition(
	definition_id: String,
	display_name: String,
	category: StringName,
	base_price: float
) -> ItemDefinition:
	var definition: ItemDefinition = ItemDefinition.new()
	definition.id = definition_id
	definition.item_name = display_name
	definition.store_type = _STORE_ID
	definition.category = category
	definition.base_price = base_price
	definition.rarity = "common"
	return definition


func _assert_route_target(parent_name: String, expected_label: String) -> void:
	assert_eq(
		Array(_stage_critical_path_targets()),
		[parent_name],
		"Only %s must be active on this route step" % parent_name
	)
	var controller: StoreSessionController = _store_session_controller() as StoreSessionController
	assert_not_null(controller, "Route target assertion requires store_session controller")
	if controller != null:
		assert_eq(
			controller.active_objective_target_node_path(),
			parent_name,
			"Controller active target must drive the route target"
		)
		assert_eq(
			controller.active_objective_prompt_label(),
			expected_label,
			"Controller prompt copy must match the active interactable"
		)
		assert_true(
			controller.should_show_active_objective_highlight(),
			"Controller highlight visibility must be true for the active route target"
		)
	var interactable: Interactable = _store_interactable(parent_name)
	assert_not_null(interactable, "%s/Interactable must exist" % parent_name)
	if interactable == null:
		return
	assert_true(interactable.enabled, "%s must be enabled" % parent_name)
	assert_true(interactable.can_interact(), "%s must accept interaction" % parent_name)
	assert_eq(interactable.get_prompt_label(), expected_label)


func _interact_route_target(parent_name: String, expected_label: String) -> void:
	_assert_route_target(parent_name, expected_label)
	var interactable: Interactable = _store_interactable(parent_name)
	if interactable == null:
		return
	interactable.interact()
	await get_tree().process_frame
	var controller: StoreSessionController = _store_session_controller() as StoreSessionController
	if controller != null:
		_ack_first_minute_detail(controller)
		await get_tree().process_frame


func _open_customer_decision_from_interactable() -> void:
	await _interact_route_target("StoreSessionDayOneCustomer", "Talk to customer")
	await get_tree().process_frame


func _press_choice(decision: DecisionCardPanel, choice_id: StringName) -> void:
	var button: Button = _choice_button(decision, choice_id)
	assert_not_null(button, "Choice button %s must exist" % String(choice_id))
	if button == null:
		return
	button.pressed.emit()


func _choice_button(decision: DecisionCardPanel, choice_id: StringName) -> Button:
	var controller: Node = _store_session_controller()
	if controller == null:
		return null
	var event_data: Dictionary = controller.get("_active_event") as Dictionary
	var choices: Array = event_data.get("choices", []) as Array
	var buttons: Array = decision.get("_choice_buttons") as Array
	for idx: int in range(choices.size()):
		var choice: Dictionary = choices[idx] as Dictionary
		if StringName(str(choice.get("id", ""))) == choice_id and idx < buttons.size():
			return buttons[idx] as Button
	return null


func _choice_effects(controller: Node, choice_id: StringName) -> Dictionary:
	var event_data: Dictionary = controller.get("_active_event") as Dictionary
	var choices: Array = event_data.get("choices", []) as Array
	for choice_variant: Variant in choices:
		if choice_variant is not Dictionary:
			continue
		var choice: Dictionary = choice_variant as Dictionary
		if StringName(str(choice.get("id", ""))) != choice_id:
			continue
		return (choice.get("effects", {}) as Dictionary).duplicate(true)
	return {}


func _acknowledge_customer_result(result: ModalPanel) -> void:
	var continue_button: Button = result.get("_continue_button") as Button
	assert_not_null(continue_button, "Customer result must expose Continue")
	if continue_button == null:
		return
	continue_button.pressed.emit()


# Kept local because manual route manifests assert line numbers in this file; see cleanup report.
func _ack_first_minute_detail(controller: StoreSessionController) -> void:
	var panel: ModalPanel = controller.get("_first_minute_detail_panel") as ModalPanel
	if panel == null or not panel.visible:
		return
	var button: Button = panel.get("_confirm_button") as Button
	assert_not_null(button, "First-minute detail panel must expose a confirm button")
	if button != null:
		button.pressed.emit()


func _assert_close_day_blocked(controller: StoreSessionController, expected_reason: String) -> void:
	assert_false(bool(controller.can_interact_day_end()))
	assert_eq(String(controller.day_end_disabled_reason()), expected_reason)
	assert_false(
		Array(_stage_critical_path_targets()).has("StoreSessionDayEndTrigger"),
		"Close-day trigger must not be active before prerequisites are complete"
	)


func _assert_right_panel_header(expected: String) -> void:
	var panel: StoreStatusPanel = StoreSessionHUD.get_right_panel()
	assert_not_null(panel, "Store status panel must exist")
	if panel == null:
		return
	assert_eq(panel.get_header_text(), expected)


func _assert_right_panel_header_prefix(expected_prefix: String) -> void:
	var panel: StoreStatusPanel = StoreSessionHUD.get_right_panel()
	assert_not_null(panel, "Store status panel must exist")
	if panel == null:
		return
	assert_true(
		panel.get_header_text().begins_with(expected_prefix),
		"Right-panel header must begin with %s" % expected_prefix
	)


func _assert_right_panel_stat(stat_name: String, expected: String) -> void:
	var panel: StoreStatusPanel = StoreSessionHUD.get_right_panel()
	assert_not_null(panel, "Store status panel must exist")
	if panel == null:
		return
	assert_eq(panel.get_stat_value(stat_name), expected)


func _assert_empty_shelf_overlay_visible(expected: bool) -> void:
	var shelf: Node = _root.get_node_or_null("StoreSessionRestockShelf")
	assert_not_null(shelf, "StoreSessionRestockShelf must exist")
	if shelf == null:
		return
	var overlay: Node3D = shelf.get_node_or_null("EmptyOverlay") as Node3D
	assert_not_null(overlay, "StoreSessionRestockShelf must expose EmptyOverlay")
	if overlay == null:
		return
	assert_eq(overlay.visible, expected)


func _spawned_shelf_item_count() -> int:
	var shelf: Node = _root.get_node_or_null("StoreSessionRestockShelf")
	if shelf == null:
		return 0
	var count: int = 0
	for child: Node in shelf.get_children():
		if String(child.name).begins_with("StoreShelfItem"):
			count += 1
	return count


func _assert_summary_label(
	panel: DaySummaryPanel,
	property_name: String,
	expected: String
) -> void:
	var label: Label = panel.get(property_name) as Label
	assert_not_null(label, "Summary panel must expose %s" % property_name)
	if label == null:
		return
	assert_eq(label.text, expected)


# ── Stocking target label and carry-state contract ─────────────────────────
# The stock_shelf objective copy must name the specific destination ("starter
# display table"), not a generic plural. Generic copy ("the shelves") drove
# players toward unrelated meshes (ConsoleShelf etc.) that have no
# interactable, where the disabled-reason then echoed the same generic
# label and read as nonsense. The carry flag on StoreSessionState lets the rail
# suppress its right-side chip while the player is navigating to the table
# without an interactable in focus.


func test_stock_shelf_label_names_the_starter_display_table() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	var stock_entry: Dictionary = {}
	for entry: Dictionary in controller.get("_objectives"):
		if String(entry.get("stage", "")) == "stock_shelf":
			stock_entry = entry
			break
	assert_false(stock_entry.is_empty(), "stock_shelf entry must exist in _objectives")
	var label: String = String(stock_entry.get("label", ""))
	assert_string_contains(
		label,
		"starter display table",
		(
			"stock_shelf label must name the specific destination "
			+ "('starter display table'); got: '%s'" % label
		)
	)
	assert_false(
		label.contains("the shelves"),
		"stock_shelf label must not use the generic plural 'the shelves'"
	)


func test_carrying_flag_clear_at_day_start() -> void:
	# Fresh day starts with the carry flag clear so the rail does not
	# suppress the action chip before the player has done anything.
	assert_false(
		StoreSessionState.carrying_stock, "StoreSessionState.carrying_stock must be false at fresh day start"
	)


func test_carrying_flag_set_after_backroom_pickup() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	# Walk the chain to the back-room beat first.
	controller._on_choice_selected(&"clean_exchange", {})
	await get_tree().process_frame
	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	assert_true(
		StoreSessionState.carrying_stock, "carrying_stock must flip true after the back-room pickup"
	)


func test_stock_box_visually_disappears_after_pickup_fade() -> void:
	# Phase Theme contract: the back room must not look identical before
	# and after pickup. The pickup branch fades over ~0.4 s and then flips
	# `visible = false`; this test waits past the fade window and asserts
	# the StockBox + StockBoxLabel are no longer visible.
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	var pickup: Node = _root.get_node_or_null("StoreSessionBackroomPickup")
	assert_not_null(pickup, "StoreSessionBackroomPickup must exist")
	var stock_box: Node3D = pickup.get_node_or_null("StockBox") as Node3D
	var stock_label: Node3D = pickup.get_node_or_null("StockBoxLabel") as Node3D
	assert_not_null(stock_box, "StoreSessionBackroomPickup/StockBox must exist")
	assert_not_null(stock_label, "StoreSessionBackroomPickup/StockBoxLabel must exist")
	assert_true(
		stock_box.visible and stock_label.visible,
		"Pre-condition: StockBox + label visible at day start"
	)
	# Walk through the customer beat so the back-room stage is active.
	controller._on_choice_selected(&"clean_exchange", {})
	await get_tree().process_frame
	controller.on_store_stockroom_pickup_interacted()
	# Wait past the 0.4 s fade so the tween-completion callback runs and
	# the visible flag flips. Use a real scene-tree timer so the test
	# advances tween state on the same beat as runtime gameplay.
	await get_tree().create_timer(0.6).timeout
	assert_false(stock_box.visible, "StockBox must be invisible after the pickup fade completes")
	assert_false(
		stock_label.visible, "StockBoxLabel must be invisible after the pickup fade completes"
	)


func test_carried_stock_marker_and_carry_hud_follow_pickup_restock_and_new_run_reset() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	var scene: PackedScene = load(HUD_SCENE_PATH)
	assert_not_null(scene, "HUD scene must load")
	if scene == null:
		return
	var hud: CanvasLayer = scene.instantiate() as CanvasLayer
	add_child_autofree(hud)
	await get_tree().process_frame
	var carry_label: Label = hud.get_node_or_null("CarryHUD/StoreSessionCarryLabel") as Label
	var carry_icon: ColorRect = hud.get_node_or_null("CarryHUD/StoreSessionCarryIcon") as ColorRect
	assert_not_null(carry_label, "HUD carry label must exist")
	assert_not_null(carry_icon, "HUD carry icon must exist")
	if carry_label == null or carry_icon == null:
		return
	var pickup: Node = _root.get_node_or_null("StoreSessionBackroomPickup")
	assert_not_null(pickup, "StoreSessionBackroomPickup must exist")
	if pickup == null:
		return
	var stock_box: Node3D = pickup.get_node_or_null("StockBox") as Node3D
	var open_box: Node3D = pickup.get_node_or_null("StockBoxOpen") as Node3D
	assert_not_null(stock_box, "StoreSessionBackroomPickup/StockBox must exist")
	assert_not_null(open_box, "StoreSessionBackroomPickup/StockBoxOpen must exist")
	if stock_box == null or open_box == null:
		return
	var marker: Node3D = _root.find_child("StoreCarriedStockMarker", true, false) as Node3D
	assert_not_null(marker, "A carried stock marker must be owned by the store_session controller")
	if marker == null:
		return
	assert_false(marker.visible, "Carried stock marker must start hidden")
	assert_false(carry_label.visible, "Carry HUD label must start hidden")
	assert_false(carry_icon.visible, "Carry HUD icon must start hidden")

	controller._on_choice_selected(&"clean_exchange", {})
	await get_tree().process_frame
	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame

	marker = _root.find_child("StoreCarriedStockMarker", true, false) as Node3D
	assert_not_null(marker, "Carried stock marker must remain discoverable after camera attach")
	if marker == null:
		return
	assert_true(StoreSessionState.carrying_stock, "Back-room pickup must set carry state")
	assert_true(marker.visible, "Carried stock marker must show while stock is carried")
	assert_false(stock_box.visible, "Closed pickup box must hide while carried stock is active")
	assert_true(open_box.visible, "Opened pickup box must show while carried stock is active")
	var marker_label: Label3D = marker.get_node_or_null("StarterStockBoxLabel") as Label3D
	assert_not_null(marker_label, "Carried marker must name the same starter stock box as the HUD")
	if marker_label != null:
		assert_eq(marker_label.text, "STARTER STOCK BOX")
	assert_true(carry_label.visible, "Carry HUD label must show while stock is carried")
	assert_eq(carry_label.text, "Carrying: Starter Stock Box")
	assert_true(carry_icon.visible, "Carry HUD icon must show while stock is carried")
	assert_true(
		marker.get_parent() is Camera3D,
		"Carried stock marker must attach to the view camera for first-person readability"
	)
	assert_gt(marker.position.x, 0.25, "Marker must sit to the right of the reticle")
	assert_lt(marker.position.y, -0.20, "Marker must sit below the reticle")
	assert_lt(marker.position.z, -0.50, "Marker must sit in front of the camera")

	controller.on_store_restock_interacted()
	await get_tree().process_frame
	assert_false(StoreSessionState.carrying_stock, "Restocking must clear carry state")
	assert_false(marker.visible, "Carried stock marker must clear after shelf stocking")
	assert_false(carry_label.visible, "Carry HUD label must clear after shelf stocking")
	assert_false(carry_icon.visible, "Carry HUD icon must clear after shelf stocking")

	StoreSessionState.carrying_stock = true
	EventBus.store_carry_changed.emit("Starter Stock Box")
	await get_tree().process_frame
	assert_true(marker.visible, "Pre-condition: marker can show before a new-run reset")
	assert_true(carry_label.visible, "Pre-condition: HUD can show before a new-run reset")
	GameManager.begin_new_run()
	await get_tree().process_frame
	assert_false(StoreSessionState.carrying_stock, "New-run reset must clear carry state")
	assert_false(marker.visible, "Carried stock marker must clear on new-run reset")
	assert_false(carry_label.visible, "Carry HUD label must clear on new-run reset")
	assert_false(carry_icon.visible, "Carry HUD icon must clear on new-run reset")


## Back-room pickup must surface a "Shipment checked" toast that names the
## actual delivery quantity, so the player gets an explicit textual cue
## both that the back-room beat resolved AND how many items they just
## uncovered. The numeric token must match the runtime count emitted on
## `store_backroom_count_changed`, not a hardcoded literal. Pickup is a
## transient event confirmation — it routes through `toast_requested`
## (auto-dismissing card on layer 45), not the persistent HUD label
## channel. The persistent carry *state* is driven separately by
## `store_carry_changed`.
func test_backroom_pickup_emits_shipment_checked_toast() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	# Walk to the back-room beat first so the pickup actually fires.
	controller._on_choice_selected(&"clean_exchange", {})
	await get_tree().process_frame
	watch_signals(EventBus)
	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	assert_signal_emitted(
		EventBus,
		"toast_requested",
		"Back-room pickup must emit toast_requested for the player feedback card"
	)
	# The toast must name (a) the "Shipment checked" beat phrasing and
	# (b) the runtime delivery quantity, taken from the same const that
	# drives `store_backroom_count_changed`. Match both so a future copy
	# tweak can rephrase the surrounding sentence without dropping either
	# half of the contract.
	# `_BACKROOM_DELIVERY_QUANTITY` is a class-level const on
	# `StoreSessionController` — `Object.get()` only resolves properties, so
	# read the const directly through the class symbol instead.
	var expected_count: int = StoreSessionController._BACKROOM_DELIVERY_QUANTITY
	var found_shipment_message: bool = false
	for params: Array in get_signal_parameters_all(EventBus, "toast_requested"):
		if params.is_empty():
			continue
		var msg: String = String(params[0])
		if msg.contains("Shipment checked") and msg.contains(str(expected_count)):
			found_shipment_message = true
			break
	assert_true(
		found_shipment_message,
		(
			(
				"toast_requested must include a 'Shipment checked. %d ...' "
				+ "message naming the runtime delivery quantity"
			)
			% expected_count
		)
	)


func test_store_restock_spawns_catalog_backed_product_visuals() -> void:
	var controller: Node = _store_session_controller()
	assert_not_null(controller, "Store session controller must exist")
	if controller == null:
		return
	controller.call("_reset_restock_shelf_visuals")

	var spawned: int = int(
		controller.call("_spawn_visible_shelf_items", StoreSessionController._BACKROOM_DELIVERY_QUANTITY)
	)

	assert_eq(
		spawned,
		StoreSessionController._BACKROOM_DELIVERY_QUANTITY,
		"Store-session restock display table must spawn the sparse starter count"
	)
	var shelf: Node = _root.get_node_or_null("StoreSessionRestockShelf")
	assert_not_null(shelf, "StoreSessionRestockShelf must exist")
	if shelf == null:
		return
	var case_count: int = 0
	var console_count: int = 0
	for child: Node in shelf.get_children():
		if not String(child.name).begins_with("StoreShelfItem"):
			continue
		var item := child as Node3D
		assert_not_null(item, "StoreShelfItem must be a Node3D")
		if item == null:
			continue
		var product_kind: String = str(item.get_meta("product_visual_kind", ""))
		if product_kind == "game_case":
			case_count += 1
			var designed_root: Node = item.get_node_or_null("ProductVisualCaseRoot")
			assert_not_null(
				designed_root,
				"Store-session restock game item must include its case template child"
			)
			if designed_root == null:
				continue
			assert_not_null(
				designed_root.get_node_or_null("FrontPanel"),
				"Store-session restock game item must include a front panel"
			)
			assert_not_null(
				designed_root.get_node_or_null("PlatformStripe"),
				"Store-session restock game item must include a platform stripe"
			)
		elif product_kind == "console_box":
			console_count += 1
			assert_not_null(
				item.get_node_or_null("ProductVisualConsoleBoxRoot"),
				"Store-session restock console item must include its console-box template child"
			)
		assert_gt(
			item.position.y,
			1.0,
			"Store-session restock product visuals must sit on the display table"
		)
	assert_eq(
		console_count,
		1,
		"Starter display table should include exactly one catalog-backed console visual"
	)
	assert_eq(
		case_count,
		2,
		"Starter display table should include exactly two catalog-backed game visuals"
	)


## Acceptance: the pickup toast AND the carry HUD signal must fire on the
## same call stack as the pickup interaction so there is no visible gap
## between the back-room item disappearing and the carry indicator appearing.
func test_pickup_toast_and_carry_changed_emit_in_same_call() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	controller._on_choice_selected(&"clean_exchange", {})
	await get_tree().process_frame
	watch_signals(EventBus)
	controller.on_store_stockroom_pickup_interacted()
	# No `await` here — both signals must have fired synchronously inside
	# `on_store_stockroom_pickup_interacted` before the test returns control
	# to the scene tree.
	assert_signal_emitted(
		EventBus,
		"toast_requested",
		"toast_requested must fire synchronously on pickup, not deferred"
	)
	assert_signal_emitted(
		EventBus,
		"store_carry_changed",
		(
			"store_carry_changed must fire synchronously on pickup so the carry "
			+ "indicator appears in the same frame as the pickup toast"
		)
	)


func test_carrying_flag_cleared_after_stocking_shelf() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	controller._on_choice_selected(&"clean_exchange", {})
	await get_tree().process_frame
	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	assert_true(StoreSessionState.carrying_stock, "Pre-condition: carrying after backroom pickup")
	controller.on_store_restock_interacted()
	await get_tree().process_frame
	assert_false(
		StoreSessionState.carrying_stock, "carrying_stock must clear after the player stocks the shelf"
	)


# ── Today checklist signal contract ────────────────────────────────────────
# Every chain advance must emit `EventBus.store_objective_completed(id)` so
# the StoreStatusPanel can flip the matching row to ✓ and collapse it.


func test_completing_customer_step_emits_store_objective_completed() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	watch_signals(EventBus)
	controller._on_choice_selected(&"clean_exchange", {})
	await get_tree().process_frame
	assert_signal_emitted_with_parameters(
		EventBus,
		"store_objective_completed",
		[&"talk_to_customer"]
	)


func test_completing_back_room_step_emits_store_objective_completed() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	controller._on_choice_selected(&"clean_exchange", {})
	await get_tree().process_frame
	watch_signals(EventBus)
	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	assert_signal_emitted_with_parameters(
		EventBus,
		"store_objective_completed",
		[&"back_room_inventory"]
	)


func test_completing_stock_shelf_step_emits_store_objective_completed() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	controller._on_choice_selected(&"clean_exchange", {})
	await get_tree().process_frame
	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	watch_signals(EventBus)
	controller.on_store_restock_interacted()
	await get_tree().process_frame
	assert_signal_emitted_with_parameters(
		EventBus,
		"store_objective_completed",
		[&"stock_shelf"]
	)


func test_close_day_request_emits_store_objective_completed() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	# Walk the chain to END_DAY first so the close-day gate is satisfied.
	controller._on_choice_selected(&"clean_exchange", {})
	await get_tree().process_frame
	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	controller.on_store_restock_interacted()
	await get_tree().process_frame
	watch_signals(EventBus)
	# E-press now opens the CloseDayConfirmationPanel via the EventBus
	# signal contract; the close-day objective ticks only after the player
	# presses "Close Day" (which emits day_close_confirmed). Drive the
	# confirm side through the panel so CTX_MODAL push/pop stays balanced.
	controller.on_store_day_end_requested()
	await get_tree().process_frame
	_press_close_day_confirm(controller)
	await get_tree().process_frame
	assert_signal_emitted_with_parameters(
		EventBus,
		"store_objective_completed",
		[&"close_day"]
	)
	assert_true(
		UnlockSystemSingleton.is_unlocked(&"employee_closing_certified"),
		"Close-day confirm must grant closing certification"
	)
	assert_false(
		UnlockSystemSingleton.is_unlocked(&"extended_hours_unlock"),
		"Basic Day 1 completion must not grant extended hours"
	)


# ── Close-time watcher fires through the toast channel ─────────────────────
# AC: closing time is a time-limited alert that auto-dismisses, so it routes
# through `toast_requested` (top-right card with auto-fade), not the
# persistent `notification_requested` HUD label. The persistent rail copy
# ("Close the day at the register.") is what stays on screen until the
# player closes out — the toast only needs to land once.


func test_entering_end_day_emits_close_time_toast() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	# Advance through customer + back room first, then watch signals so
	# only the stock_shelf -> end_day transition's toast is captured.
	controller._on_choice_selected(&"clean_exchange", {})
	await get_tree().process_frame
	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	watch_signals(EventBus)
	controller.on_store_restock_interacted()
	await get_tree().process_frame
	assert_eq(
		String(controller.get("_stage")),
		"end_day",
		"Pre-condition: stage advances to end_day after stocking the shelf"
	)
	var found_close_time_toast: bool = false
	for params: Array in get_signal_parameters_all(EventBus, "toast_requested"):
		if params.size() < 1:
			continue
		var msg: String = String(params[0])
		if msg.to_lower().contains("closing time"):
			found_close_time_toast = true
			break
	assert_true(
		found_close_time_toast,
		(
			"Entering end_day must emit a toast_requested whose message names "
			+ "'closing time' so the player knows the day's wrap-up is ready."
		)
	)


func test_objective_rail_uses_specified_copy_for_each_chain_stage() -> void:
	# AC: every chain entry's rail label matches the BRAINDUMP-specified
	# copy. This test reads the controller's _OBJECTIVES table directly so
	# a copy regression fails fast without having to walk the chain.
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	var expected: Dictionary = {
		"talk_to_customer": "Talk to the customer at the register.",
		"back_room_inventory": "Check the back room delivery.",
		"stock_shelf": "Place all 3 starter items on the starter display table.",
		"end_day": "Close the day at the register.",
	}
	for entry: Dictionary in controller.get("_objectives"):
		var stage_id: String = String(entry.get("stage", ""))
		if not expected.has(stage_id):
			continue
		assert_eq(
			String(entry.get("label", "")),
			String(expected[stage_id]),
			"Rail label for stage '%s' must match the BRAINDUMP copy" % stage_id
		)


func test_current_stage_getter_reports_active_stage() -> void:
	# Public read-only accessor used by debug overlay + audits. Must track
	# the private `_stage` field one-for-one.
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	assert_eq(
		String(controller.current_stage()),
		String(controller.get("_stage")),
		"current_stage() must mirror the private _stage field"
	)
	controller._on_choice_selected(&"clean_exchange", {})
	await get_tree().process_frame
	assert_eq(
		String(controller.current_stage()),
		"back_room_inventory",
		"current_stage() must reflect the chain advance after the customer beat"
	)


# ── Day-summary continue: close before next playable shift ─────────────────
# `_on_summary_continue` must pop CTX_MODAL via `_summary_panel.close()`
# before it starts the next shift. If the pop is deferred (or absent),
# gameplay would resume with a stale summary modal frame on the focus stack.


func test_summary_continue_pops_modal_focus_before_starting_next_day() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	# Walk the full chain so close-day is unlocked, then open the summary.
	controller._on_choice_selected(&"clean_exchange", {})
	await get_tree().process_frame
	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	controller.on_store_restock_interacted()
	await get_tree().process_frame
	# E-press now opens the close-day confirmation modal; the summary
	# panel only renders after the player confirms via day_close_confirmed.
	# Drive the confirm side through the panel so the CTX_MODAL frame the
	# panel pushed in show_with_reason() pops cleanly before the summary
	# panel pushes its own frame.
	controller.on_store_day_end_requested()
	await get_tree().process_frame
	_press_close_day_confirm(controller)
	await get_tree().process_frame

	var panel: DaySummaryPanel = controller.get("_summary_panel") as DaySummaryPanel
	assert_not_null(panel, "Summary panel must be spawned by the controller")
	if panel == null:
		return
	assert_true(
		bool(panel.get("_focus_pushed")),
		"Pre-condition: summary panel owns the CTX_MODAL frame after open"
	)

	controller._on_summary_continue()
	await get_tree().process_frame

	# `_focus_pushed` is the panel-local invariant: false iff close() has
	# popped the CTX_MODAL frame this panel owns. Checking the global
	# InputFocus.current() here would be flaky against frames leaked by
	# other tests in the suite (those get auto-popped on _exit_tree but
	# may still be on the stack mid-test).
	assert_false(
		bool(panel.get("_focus_pushed")),
		(
			"_on_summary_continue must pop the panel's CTX_MODAL frame so the "
			+ "next shift can resume gameplay input cleanly"
		)
	)
	assert_ne(
		InputFocus.current(),
		InputFocus.CTX_MODAL,
		"Continue must leave modal focus before the next playable shift starts"
	)
	assert_eq(StoreSessionState.day, 2)
	assert_eq(String(controller.current_stage()), "talk_to_customer")


func test_summary_continue_starts_day2_gameplay_with_authored_event() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	controller._on_choice_selected(&"clean_exchange", {})
	await get_tree().process_frame
	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	controller.on_store_restock_interacted()
	await get_tree().process_frame
	controller.on_store_day_end_requested()
	await get_tree().process_frame
	_press_close_day_confirm(controller)
	await get_tree().process_frame

	watch_signals(EventBus)
	controller._on_summary_continue()
	await get_tree().process_frame

	assert_null(ModalQueue.active_panel(), "Continue must not open a placeholder modal")
	assert_eq(StoreSessionState.day, 2, "Continue must advance the persistent store loop to Day 2")
	assert_signal_emitted_with_parameters(
		EventBus,
		"day_started",
		[2]
	)
	assert_eq(String(controller.get("_stage")), "talk_to_customer")
	assert_eq(
		String((controller.get("_active_event") as Dictionary).get("id", "")),
		"day02_trade_in_dispute",
		"Day 2 should use the authored trade-in customer event, not a preview stop"
	)


# ── Right-panel spawn ───────────────────────────────────────────────────────


func test_store_controller_spawns_right_panel_on_ready() -> void:
	# The controller's _ensure_panels must add a StoreStatusPanel into the UI
	# tree so the right side has the merged store-stats + today-checklist
	# surface in place of the suppressed MomentsTray.
	var panel: Node = get_tree().get_first_node_in_group("store_status_panel")
	assert_not_null(panel, "StoreSessionController must spawn a StoreStatusPanel into the UI tree")


## ── Sale-signal emission contract ──────────────────────────────────────────
## The HUD's "Sold Today" and "Customers Served" counters increment only on
## EventBus.item_sold and EventBus.customer_purchased respectively. The store_session
## decision-card path bypasses the production checkout pipeline, so the
## controller has to emit those signals itself only when a positive cash
## outcome removed concrete stock. Refunds, no-sale outcomes, and unresolved
## inventory must not tick the counters.


func test_stocked_sale_choice_emits_item_sold_with_inventory_instance() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	var fixture: Dictionary = _seed_salable_day_one_inventory()
	var item: ItemInstance = fixture.get("item", null) as ItemInstance
	assert_not_null(item)
	if item == null:
		return
	watch_signals(EventBus)
	controller._on_choice_selected(
		&"clean_exchange", _choice_effects(controller, &"clean_exchange")
	)
	await get_tree().process_frame
	assert_signal_emitted_with_parameters(
		EventBus, "item_sold", [String(item.instance_id), 15.0, "cartridges"]
	)


func test_stocked_sale_choice_emits_customer_purchased_with_inventory_instance() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	var fixture: Dictionary = _seed_salable_day_one_inventory()
	var item: ItemInstance = fixture.get("item", null) as ItemInstance
	assert_not_null(item)
	if item == null:
		return
	watch_signals(EventBus)
	controller._on_choice_selected(
		&"clean_exchange", _choice_effects(controller, &"clean_exchange")
	)
	await get_tree().process_frame
	var params: Array = get_signal_parameters(EventBus, "customer_purchased", 0)
	assert_false(String(params[3]).is_empty())
	assert_signal_emitted_with_parameters(
		EventBus,
		"customer_purchased",
		[_STORE_ID, StringName(item.instance_id), 15.0, params[3]]
	)


func test_sale_choice_credits_visible_wallet_once() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	var fixture: Dictionary = _seed_salable_day_one_inventory()
	var economy: EconomySystem = fixture.get("economy", null) as EconomySystem
	assert_not_null(economy)
	if economy == null:
		return

	controller._on_choice_selected(
		&"clean_exchange", _choice_effects(controller, &"clean_exchange")
	)
	await get_tree().process_frame

	assert_almost_eq(
		economy.get_cash(),
		515.0,
		0.01,
		"Store-session sale choice must credit the EconomySystem wallet exactly once"
	)
	var transactions: Array[Dictionary] = economy.transaction_history
	assert_eq(transactions.size(), 1, "Store-session sale choice must create one economy transaction")
	assert_eq(
		int(transactions[0].get("day", 0)),
		1,
		"Store-session sale transaction day must match the visible Day 1 state"
	)


func test_clean_exchange_sale_reconciles_visible_shelf_from_inventory_delta() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	_seed_salable_day_one_inventory()
	assert_eq(int(controller.call("_spawn_visible_shelf_items", 2)), 2)
	watch_signals(EventBus)

	controller._on_choice_selected(
		&"clean_exchange", _choice_effects(controller, &"clean_exchange")
	)
	await get_tree().process_frame

	var transactions: Array = controller.get("_customer_inventory_transactions") as Array
	assert_gt(transactions.size(), 0, "Sale choice must record an inventory transaction")
	var transaction: Dictionary = transactions.back() as Dictionary
	var counts: Dictionary = transaction.get("store_inventory_counts", {}) as Dictionary
	assert_eq(int(counts.get("applied_shelf_removed_quantity", -1)), 1)
	assert_eq(_spawned_shelf_item_count(), 1)
	assert_signal_emitted_with_parameters(EventBus, "store_shelf_count_changed", [1])
	assert_signal_emitted_with_parameters(EventBus, "store_backroom_count_changed", [1])
	_assert_right_panel_stat("Shelf", "1 / 2")
	_assert_empty_shelf_overlay_visible(false)


func test_clean_exchange_presents_room_outcome_before_summary() -> void:
	var controller: StoreSessionController = _store_session_controller() as StoreSessionController
	if controller == null:
		return
	var screen = _register_screen_state()
	assert_not_null(screen)
	if screen == null:
		return
	_seed_salable_day_one_inventory()
	assert_eq(int(controller.call("_spawn_visible_shelf_items", 2)), 2)

	controller.on_store_customer_interacted()
	await get_tree().process_frame
	var decision: DecisionCardPanel = controller.get("_decision_panel") as DecisionCardPanel
	assert_not_null(decision, "Clean exchange must start from the authored decision card")
	if decision == null:
		return
	_press_choice(decision, &"clean_exchange")
	await get_tree().process_frame

	assert_eq(StoreSessionState.cash, 15)
	assert_eq(StoreSessionState.reputation, 2)
	assert_eq(StoreSessionState.manager_trust, 2)
	assert_eq(screen.current_state(), RegisterScreenStateScript.STATE_TRANSACTION)
	assert_eq(screen.current_amount(), 15)
	assert_eq(screen.display_text(), "SALE\n$15")

	var transactions: Array = controller.get("_customer_inventory_transactions") as Array
	assert_gt(transactions.size(), 0, "Clean exchange must record the stock movement")
	var transaction: Dictionary = transactions.back() as Dictionary
	var counts: Dictionary = transaction.get("store_inventory_counts", {}) as Dictionary
	assert_true(bool(transaction.get("ok", false)))
	assert_eq(int(counts.get("applied_shelf_removed_quantity", -1)), 1)
	assert_eq(int(counts.get("applied_backroom_created_quantity", -1)), 1)

	var anchor: Node3D = (
		_root.get_node_or_null("checkout_counter/StoreSessionCustomerCounterAnchor") as Node3D
	)
	assert_not_null(anchor, "Clean exchange must keep the shared counter item readable")
	if anchor != null:
		assert_eq(str(anchor.get_meta("counter_state", "")), "clean_exchange")
		assert_eq(int(anchor.get_meta("settled_amount", 0)), 15)
		assert_true(bool(anchor.get_meta("inventory_ok", false)))
		var shared_item: Node3D = anchor.get_node_or_null("SharedCustomerItem") as Node3D
		assert_not_null(shared_item, "Clean exchange must keep the counter item visible")
		if shared_item != null:
			assert_true(shared_item.visible)

	var shelf_gap: Node3D = (
		_root.get_node_or_null("StoreSessionRestockShelf/CleanExchangeShelfGap") as Node3D
	)
	assert_not_null(shelf_gap, "Clean exchange must mark the shelf copy that left")
	if shelf_gap != null:
		assert_true(shelf_gap.visible)
		assert_eq(str(shelf_gap.get_meta("outcome", "")), "clean_exchange")

	var returned_copy: Node3D = (
		_root.get_node_or_null("StoreSessionBackroomPickup/CleanExchangeReturnedCopy") as Node3D
	)
	assert_not_null(returned_copy, "Clean exchange must show the returned copy in back room")
	if returned_copy != null:
		assert_true(returned_copy.visible)
		assert_eq(
			str(returned_copy.get_meta("definition_id", "")),
			_RETURN_GAME_ID
		)
		assert_eq(str(returned_copy.get_meta("location", "")), "backroom")
		assert_not_null(returned_copy.get_node_or_null("ReturnedCopyLabel"))

	var customer: Node3D = _root.get_node_or_null("StoreSessionDayOneCustomer") as Node3D
	assert_not_null(customer, "Clean exchange must keep the customer readable before exit")
	if customer != null:
		assert_eq(str(customer.get_meta("exit_reaction", "")), "relieved")
		assert_not_null(customer.get_node_or_null("CleanExchangeReliefCue"))

	var summary_before: DaySummaryPanel = controller.get("_summary_panel") as DaySummaryPanel
	assert_true(
		summary_before == null or not summary_before.visible,
		"Clean exchange outcome must appear before day summary opens"
	)
	var result: ModalPanel = controller.get("_customer_result_panel") as ModalPanel
	assert_not_null(result, "Clean exchange must wait for result acknowledgement")
	if result == null:
		return
	_acknowledge_customer_result(result)
	await get_tree().process_frame

	assert_eq(_spawned_shelf_item_count(), 1)
	assert_not_null(
		_root.get_node_or_null("StoreSessionBackroomPickup/CleanExchangeReturnedCopy"),
		"Returned copy must persist into the back-room objective"
	)
	var summary_after: DaySummaryPanel = controller.get("_summary_panel") as DaySummaryPanel
	assert_true(summary_after == null or not summary_after.visible)
	assert_eq(String(controller.current_stage()), "back_room_inventory")


func test_bundle_sale_reconciles_two_visible_shelf_items_from_inventory_delta() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	_seed_bundle_day_one_inventory()
	assert_eq(int(controller.call("_spawn_visible_shelf_items", 2)), 2)
	watch_signals(EventBus)

	controller._on_choice_selected(
		&"upsell_bundle", _choice_effects(controller, &"upsell_bundle")
	)
	await get_tree().process_frame

	var transactions: Array = controller.get("_customer_inventory_transactions") as Array
	assert_gt(transactions.size(), 0, "Bundle choice must record an inventory transaction")
	var transaction: Dictionary = transactions.back() as Dictionary
	var counts: Dictionary = transaction.get("store_inventory_counts", {}) as Dictionary
	assert_eq(int(counts.get("applied_shelf_removed_quantity", -1)), 2)
	assert_eq(_spawned_shelf_item_count(), 0)
	assert_signal_emitted_with_parameters(EventBus, "store_shelf_count_changed", [0])
	assert_signal_emitted_with_parameters(EventBus, "store_backroom_count_changed", [1])
	_assert_right_panel_stat("Shelf", "0 / 1")
	_assert_empty_shelf_overlay_visible(true)


func test_bundle_sale_presents_distinct_room_outcome_before_summary() -> void:
	var controller: StoreSessionController = _store_session_controller() as StoreSessionController
	if controller == null:
		return
	var screen = _register_screen_state()
	assert_not_null(screen)
	if screen == null:
		return
	_seed_bundle_day_one_inventory()
	assert_eq(int(controller.call("_spawn_visible_shelf_items", 2)), 2)

	controller.on_store_customer_interacted()
	await get_tree().process_frame
	var decision: DecisionCardPanel = controller.get("_decision_panel") as DecisionCardPanel
	assert_not_null(decision, "Bundle sale must start from the authored decision card")
	if decision == null:
		return
	watch_signals(EventBus)
	_press_choice(decision, &"upsell_bundle")
	await get_tree().process_frame

	assert_eq(StoreSessionState.cash, 18)
	assert_eq(StoreSessionState.reputation, 1)
	assert_eq(StoreSessionState.manager_trust, 0)
	assert_eq(screen.current_state(), RegisterScreenStateScript.STATE_TRANSACTION)
	assert_eq(screen.current_amount(), 18)
	assert_eq(screen.display_text(), "SALE\n$18")

	var transactions: Array = controller.get("_customer_inventory_transactions") as Array
	assert_gt(transactions.size(), 0, "Bundle sale must record the stock movement")
	var transaction: Dictionary = transactions.back() as Dictionary
	var counts: Dictionary = transaction.get("store_inventory_counts", {}) as Dictionary
	assert_true(bool(transaction.get("ok", false)))
	assert_eq(int(counts.get("applied_shelf_removed_quantity", -1)), 2)
	assert_eq(int(counts.get("applied_backroom_created_quantity", -1)), 1)

	var anchor: Node3D = (
		_root.get_node_or_null("checkout_counter/StoreSessionCustomerCounterAnchor") as Node3D
	)
	assert_not_null(anchor, "Bundle sale must keep the shared counter anchor readable")
	if anchor != null:
		assert_eq(str(anchor.get_meta("counter_state", "")), "bundle")
		assert_ne(str(anchor.get_meta("counter_state", "")), "clean_exchange")
		assert_eq(int(anchor.get_meta("settled_amount", 0)), 18)
		assert_true(bool(anchor.get_meta("inventory_ok", false)))
		assert_eq(int(anchor.get_meta("sale_side_stock_removed", 0)), 2)
		var stack: Node3D = anchor.get_node_or_null("BundleItemStack") as Node3D
		assert_not_null(stack, "Bundle sale must present a bundled-item counter stack")
		if stack != null:
			assert_eq(int(stack.get_meta("item_count", 0)), 2)
			assert_not_null(stack.get_node_or_null("BundleGameItem"))
			assert_not_null(stack.get_node_or_null("BundleControllerItem"))
		var shared_item: Node3D = anchor.get_node_or_null("SharedCustomerItem") as Node3D
		assert_not_null(shared_item, "Bundle state must still own the shared item node")
		if shared_item != null:
			assert_false(shared_item.visible, "Bundle stack must replace the single shared item")

	var game_gap: Node3D = _root.get_node_or_null("StoreSessionRestockShelf/BundleGameShelfGap") as Node3D
	var controller_gap: Node3D = (
		_root.get_node_or_null("StoreSessionRestockShelf/BundleControllerShelfGap") as Node3D
	)
	assert_not_null(game_gap, "Bundle sale must mark the game copy that left")
	assert_not_null(controller_gap, "Bundle sale must mark the controller that left")
	if game_gap != null:
		assert_eq(str(game_gap.get_meta("outcome", "")), "bundle")
		assert_eq(str(game_gap.get_meta("item_role", "")), "game")
	if controller_gap != null:
		assert_eq(str(controller_gap.get_meta("outcome", "")), "bundle")
		assert_eq(str(controller_gap.get_meta("item_role", "")), "controller")
	assert_null(_root.get_node_or_null("StoreSessionRestockShelf/CleanExchangeShelfGap"))

	var returned_copy: Node3D = _root.get_node_or_null("StoreSessionBackroomPickup/BundleReturnedCopy") as Node3D
	assert_not_null(returned_copy, "Bundle sale must show the returned copy in back room")
	if returned_copy != null:
		assert_eq(str(returned_copy.get_meta("definition_id", "")), _RETURN_GAME_ID)
		assert_eq(str(returned_copy.get_meta("location", "")), "backroom")
		assert_not_null(returned_copy.get_node_or_null("BundleReturnedCopyLabel"))
	assert_null(_root.get_node_or_null("StoreSessionBackroomPickup/CleanExchangeReturnedCopy"))

	var customer: Node3D = _root.get_node_or_null("StoreSessionDayOneCustomer") as Node3D
	assert_not_null(customer, "Bundle sale must keep the customer readable before exit")
	if customer != null:
		assert_eq(str(customer.get_meta("exit_reaction", "")), "pressured_bundle")
		assert_not_null(customer.get_node_or_null("BundlePressureCue"))
	var result: ModalPanel = controller.get("_customer_result_panel") as ModalPanel
	assert_not_null(result, "Bundle sale result must wait for acknowledgement")
	if result == null:
		return
	_acknowledge_customer_result(result)
	await get_tree().process_frame

	assert_eq(_spawned_shelf_item_count(), 0)
	assert_signal_emitted(EventBus, "item_sold")
	assert_signal_emitted(EventBus, "customer_purchased")
	_assert_right_panel_stat("Sales", "1")
	_assert_right_panel_stat("Customers", "1")
	_assert_right_panel_stat("Reputation", "+1")
	_assert_right_panel_stat("Trust", "0")


func test_close_day_summary_uses_economy_cash_accounting() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	_seed_salable_day_one_inventory()

	controller._on_choice_selected(&"clean_exchange", _choice_effects(controller, &"clean_exchange"))
	await get_tree().process_frame
	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	controller.on_store_restock_interacted()
	await get_tree().process_frame
	controller.on_store_day_end_requested()
	await get_tree().process_frame
	_press_close_day_confirm(controller)
	await get_tree().process_frame
	await get_tree().process_frame

	var summary_panel: DaySummaryPanel = controller.get("_summary_panel") as DaySummaryPanel
	assert_not_null(summary_panel, "Close-day confirm must create the store_session summary panel")
	if summary_panel == null:
		return
	var metrics: RichTextLabel = summary_panel.get("_metrics_label") as RichTextLabel
	assert_not_null(metrics, "Summary panel must own the money metrics label")
	if metrics == null:
		return
	var text: String = metrics.text
	assert_string_contains(text, "Starting Cash:[/b] $500")
	assert_string_contains(text, "Sales:[/b] $15")
	assert_string_contains(text, "Rent (review only):[/b] -$50")
	assert_string_contains(text, "Profit after rent:[/b] -$35")
	assert_string_contains(text, "Ending Cash:[/b] $515")


func test_zero_cash_choice_does_not_emit_sale_signals() -> void:
	# clean_exchange has cash: 0 in the day-1 event JSON. No sale happened —
	# the HUD counters must not tick.
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	watch_signals(EventBus)
	controller._on_choice_selected(&"clean_exchange", {"cash": 0})
	await get_tree().process_frame
	assert_signal_not_emitted(EventBus, "item_sold")
	assert_signal_not_emitted(EventBus, "customer_purchased")


func test_negative_cash_choice_does_not_emit_sale_signals() -> void:
	# Refund-style outcomes (negative cash delta) are not sales.
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	watch_signals(EventBus)
	controller._on_choice_selected(&"refuse_return", {"cash": -5})
	await get_tree().process_frame
	assert_signal_not_emitted(EventBus, "item_sold")
	assert_signal_not_emitted(EventBus, "customer_purchased")


func test_refused_return_marks_loss_without_sale_or_stock_movement() -> void:
	var controller: StoreSessionController = _store_session_controller() as StoreSessionController
	if controller == null:
		return
	var screen = _register_screen_state()
	assert_not_null(screen)
	if screen == null:
		return
	var initial_shelf_count: int = int(controller.get("_shelf_stock_count"))

	controller.on_store_customer_interacted()
	await get_tree().process_frame
	var decision: DecisionCardPanel = controller.get("_decision_panel") as DecisionCardPanel
	assert_not_null(decision, "Refused-return path must open from the customer decision card")
	if decision == null:
		return

	watch_signals(EventBus)
	_press_choice(decision, &"refuse_return")
	await get_tree().process_frame

	assert_eq(StoreSessionState.cash, 0)
	assert_eq(StoreSessionState.daily_cash_delta, 0)
	assert_eq(StoreSessionState.reputation, -3)
	assert_eq(StoreSessionState.manager_trust, -2)
	assert_true(bool(StoreSessionState.flags.get(&"parent_refused_return", false)))
	assert_true(StoreSessionState.hidden_thread_signals_seen.has(&"parent_refused_return_risk"))
	assert_eq(int(controller.get("_shelf_stock_count")), initial_shelf_count)
	assert_eq(_spawned_shelf_item_count(), 0)
	assert_signal_not_emitted(EventBus, "item_sold")
	assert_signal_not_emitted(EventBus, "customer_purchased")
	assert_signal_not_emitted(EventBus, "store_shelf_count_changed")
	assert_eq(screen.current_state(), RegisterScreenStateScript.STATE_NO_SALE)
	assert_eq(screen.display_text(), "NO SALE")
	_assert_right_panel_stat("Sales", "0")
	_assert_right_panel_stat("Customers", "0")
	_assert_right_panel_stat("Reputation", "-3")
	_assert_right_panel_stat("Trust", "-2")

	var anchor: Node3D = (
		_root.get_node_or_null("checkout_counter/StoreSessionCustomerCounterAnchor") as Node3D
	)
	assert_not_null(anchor, "Refused return must keep the shared counter anchor readable")
	if anchor != null:
		assert_eq(str(anchor.get_meta("counter_state", "")), "refused")
		var customer_item: Node3D = anchor.get_node_or_null("SharedCustomerItem") as Node3D
		assert_not_null(customer_item, "Counter anchor must still own the shared item node")
		if customer_item != null:
			assert_false(customer_item.visible, "Refused state must not read as an item sold")

	var result: ModalPanel = controller.get("_customer_result_panel") as ModalPanel
	assert_not_null(result, "Refused-return result must wait for acknowledgement")
	if result == null:
		return
	_acknowledge_customer_result(result)
	await get_tree().process_frame

	assert_signal_not_emitted(EventBus, "item_sold")
	assert_signal_not_emitted(EventBus, "customer_purchased")
	var refusal_toast_seen: bool = false
	for params: Array in get_signal_parameters_all(EventBus, "toast_requested"):
		if params.size() < 3:
			continue
		if String(params[0]).contains("left upset") and params[1] == &"reputation_down":
			refusal_toast_seen = true
			break
	assert_true(refusal_toast_seen, "Refused return must show negative no-sale feedback")

	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	controller.on_store_restock_interacted()
	await get_tree().process_frame
	controller.on_store_day_end_requested()
	await get_tree().process_frame
	_press_close_day_confirm(controller)
	await get_tree().process_frame
	await get_tree().process_frame

	var summary_panel: DaySummaryPanel = controller.get("_summary_panel") as DaySummaryPanel
	assert_not_null(summary_panel, "Refused-return route must still reach summary")
	if summary_panel == null:
		return
	var metrics: RichTextLabel = summary_panel.get("_metrics_label") as RichTextLabel
	assert_not_null(metrics, "Summary must own money metrics")
	if metrics != null:
		assert_string_contains(metrics.text, "Sales:[/b] $0")
		assert_string_contains(metrics.text, "Profit after rent:[/b] -$50")
	_assert_summary_label(summary_panel, "_customers_helped_label", "Customers Helped: 1")
	_assert_summary_label(summary_panel, "_sales_completed_label", "Sales Completed: 0")
	_assert_summary_label(summary_panel, "_items_stocked_label", "Items Stocked: 3")


func test_disabled_reason_at_stock_shelf_does_not_echo_generic_shelves() -> void:
	# AC 3: the disabled-reason for wrong interactable presses while the
	# player is on the stock_shelf stage must not echo a legacy generic
	# 'on the shelves' copy. Walking to the stock_shelf stage and asking
	# for any other beat's disabled reason returns the controller's
	# "Working on: <stock label>" — the post-fix label should name the
	# specific shelf destination.
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	# Advance through customer + back room so the active stage is stock_shelf.
	controller._on_choice_selected(&"clean_exchange", {})
	await get_tree().process_frame
	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	assert_eq(
		String(controller.get("_stage")), "stock_shelf", "Pre-condition: stage is stock_shelf"
	)
	# Asking for the customer beat's disabled reason while in stock_shelf
	# routes through `_disabled_reason_for_stage` and returns "Working on:
	# <stock label>". The post-fix copy must name the specific shelf.
	var reason: String = String(controller.customer_disabled_reason())
	assert_string_contains(
		reason,
		"Starter Display",
		"Disabled-reason must name the specific destination; got: '%s'" % reason
	)
	assert_false(
		reason.contains("on the shelves"),
		"Disabled-reason must not echo the legacy generic plural 'on the shelves'"
	)


# ── Register status indicator: stage-aware passive hint ────────────────────
# A raycast-only Interactable on the checkout counter that returns false from
# can_interact() and surfaces a muted disabled-reason during the back-room
# and stocking phases. StoreSessionDayOneCustomer and StoreSessionDayEndTrigger keep owning
# their stages — the indicator stays empty during STAGE_TALK_TO_CUSTOMER and
# STAGE_END_DAY so the active interactable's prompt is what the player sees.


func _register_status_indicator() -> Interactable:
	if _root == null:
		return null
	return _root.get_node_or_null("checkout_counter/RegisterStatusIndicator") as Interactable


func _register_screen_state():
	if _root == null:
		return null
	var screen: Node = _root.get_node_or_null("Checkout/Register/RegisterScreenState")
	if screen == null or screen.get_script() != RegisterScreenStateScript:
		return null
	return screen


func test_register_status_indicator_is_authored_under_checkout_counter() -> void:
	var indicator: Interactable = _register_status_indicator()
	assert_not_null(
		indicator, "checkout_counter/RegisterStatusIndicator must exist in retro_games.tscn"
	)
	if indicator == null:
		return
	assert_true(
		indicator is RegisterStatusIndicator,
		"checkout_counter/RegisterStatusIndicator must use the " + "RegisterStatusIndicator script"
	)


func test_register_status_indicator_never_lets_e_fire() -> void:
	# Acceptance: passive hint only — E never resolves on this node, so the
	# customer/back-room/stock/close beats keep their existing dispatchers.
	var indicator: Interactable = _register_status_indicator()
	if indicator == null:
		return
	assert_false(
		indicator.can_interact(), "RegisterStatusIndicator.can_interact() must always return false"
	)


func test_register_status_indicator_is_raycast_only() -> void:
	# proximity_radius = 0 prevents the indicator from competing with
	# StoreSessionDayEndTrigger's 3.25 m proximity zone; the player must aim at the
	# register face to see the hint, not just walk near the counter.
	var indicator: Interactable = _register_status_indicator()
	if indicator == null:
		return
	assert_eq(
		indicator.proximity_radius,
		0.0,
		"RegisterStatusIndicator must be raycast-only (proximity_radius == 0)"
	)


func test_register_status_indicator_silent_during_talk_to_customer() -> void:
	# Day 1 opens on STAGE_TALK_TO_CUSTOMER — StoreSessionDayOneCustomer owns that
	# beat. The indicator returns "" so the HUD does not double up a hint
	# alongside the customer's "Help the customer" prompt.
	var controller: Node = _store_session_controller()
	var indicator: Interactable = _register_status_indicator()
	if controller == null or indicator == null:
		return
	assert_eq(
		String(controller.current_stage()),
		"talk_to_customer",
		"Pre-condition: day starts at STAGE_TALK_TO_CUSTOMER"
	)
	assert_eq(
		indicator.get_disabled_reason(),
		"",
		"Indicator must be silent while StoreSessionDayOneCustomer owns the beat"
	)


func test_register_status_indicator_hints_back_room_during_back_room_stage() -> void:
	# Acceptance: during STAGE_BACK_ROOM_INVENTORY, aiming at the register
	# shows 'Inspect the Starter Stock Box first.'
	var controller: Node = _store_session_controller()
	var indicator: Interactable = _register_status_indicator()
	if controller == null or indicator == null:
		return
	controller._on_choice_selected(&"clean_exchange", {})
	await get_tree().process_frame
	assert_eq(
		String(controller.current_stage()),
		"back_room_inventory",
		"Pre-condition: stage is back_room_inventory after the customer beat"
	)
	assert_eq(
		indicator.get_disabled_reason(),
		"Inspect the Starter Stock Box first.",
		"Indicator must point the player at the back room during the " + "back-room stage"
	)


func test_register_status_indicator_hints_shelf_during_stock_stage() -> void:
	# Acceptance: during STAGE_STOCK_SHELF, aiming at the register shows
	# 'Stock the Starter Display before closing.'
	var controller: Node = _store_session_controller()
	var indicator: Interactable = _register_status_indicator()
	if controller == null or indicator == null:
		return
	controller._on_choice_selected(&"clean_exchange", {})
	await get_tree().process_frame
	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	assert_eq(
		String(controller.current_stage()),
		"stock_shelf",
		"Pre-condition: stage is stock_shelf after the back-room beat"
	)
	assert_eq(
		indicator.get_disabled_reason(),
		"Stock the Starter Display before closing.",
		"Indicator must point the player at the shelf during the stock stage"
	)


func test_register_status_indicator_silent_during_end_day() -> void:
	# Acceptance: during STAGE_END_DAY the indicator shows nothing —
	# StoreSessionDayEndTrigger's "Close the day" prompt is the active beat.
	var controller: Node = _store_session_controller()
	var indicator: Interactable = _register_status_indicator()
	if controller == null or indicator == null:
		return
	controller._on_choice_selected(&"clean_exchange", {})
	await get_tree().process_frame
	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	controller.on_store_restock_interacted()
	await get_tree().process_frame
	assert_eq(
		String(controller.current_stage()),
		"end_day",
		"Pre-condition: stage is end_day after the chain completes"
	)
	assert_eq(
		indicator.get_disabled_reason(),
		"",
		"Indicator must be silent so StoreSessionDayEndTrigger owns the close-day beat"
	)


func test_register_status_indicator_stays_enabled_across_stages() -> void:
	# The objective gating sweep disables every Interactable in the store
	# before re-enabling the active stage's target. The indicator must
	# survive that sweep on every stage, otherwise the InteractionRay
	# raycast would skip the disabled node and the hint would never
	# render. Walks the chain and asserts enabled at each stop.
	var controller: Node = _store_session_controller()
	var indicator: Interactable = _register_status_indicator()
	if controller == null or indicator == null:
		return
	assert_true(indicator.enabled, "Indicator must be enabled at STAGE_TALK_TO_CUSTOMER")
	controller._on_choice_selected(&"clean_exchange", {})
	await get_tree().process_frame
	assert_true(indicator.enabled, "Indicator must stay enabled at STAGE_BACK_ROOM_INVENTORY")
	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	assert_true(indicator.enabled, "Indicator must stay enabled at STAGE_STOCK_SHELF")
	controller.on_store_restock_interacted()
	await get_tree().process_frame
	assert_true(indicator.enabled, "Indicator must stay enabled at STAGE_END_DAY")


func test_register_status_indicator_does_not_break_close_day_path() -> void:
	# Regression guard: StoreSessionDayEndTrigger must keep working with the
	# indicator added. Walk the chain and assert close-day still resolves
	# without a phantom block from the new node.
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	controller._on_choice_selected(&"clean_exchange", {})
	await get_tree().process_frame
	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	controller.on_store_restock_interacted()
	await get_tree().process_frame
	var trigger: Interactable = (
		_root.get_node_or_null("StoreSessionDayEndTrigger/Interactable") as Interactable
	)
	assert_not_null(trigger, "StoreSessionDayEndTrigger/Interactable must still exist")
	if trigger == null:
		return
	assert_true(trigger.enabled, "StoreSessionDayEndTrigger must be enabled at STAGE_END_DAY")
	assert_true(
		trigger.can_interact(),
		"StoreSessionDayEndTrigger.can_interact() must still gate true at STAGE_END_DAY"
	)


# ── Objective rail multi-step payload contract ────────────────────────────
# `_update_objective_rail()` emits `EventBus.objective_changed` with a
# `steps` array describing every entry in `_OBJECTIVES`. Each step is
# {text, state} where state is 'completed' | 'active' | 'future'. This is
# the data side of the multi-step rail render (the rendering side is the
# follow-on ObjectiveRail change).

const _EXPECTED_STEP_LABELS: Array[String] = [
	"Talk to the customer at the register.",
	"Check the back room delivery.",
	"Place all 3 starter items on the starter display table.",
	"Close the day at the register.",
]


func _latest_steps_payload(controller: Node) -> Array:
	watch_signals(EventBus)
	controller._update_objective_rail()
	var emissions: Array = get_signal_parameters_all(EventBus, "objective_changed")
	if emissions.is_empty():
		return []
	var payload: Dictionary = emissions[emissions.size() - 1][0] as Dictionary
	return payload.get("steps", []) as Array


func _step_states(steps: Array) -> Array:
	var out: Array = []
	for step: Dictionary in steps:
		out.append(String(step.get("state", "")))
	return out


func _step_texts(steps: Array) -> Array:
	var out: Array = []
	for step: Dictionary in steps:
		out.append(String(step.get("text", "")))
	return out


func test_steps_payload_present_with_four_entries() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	var steps: Array = _latest_steps_payload(controller)
	assert_eq(steps.size(), 4, "objective_changed payload must carry a 4-entry steps array")
	assert_eq(
		_step_texts(steps),
		_EXPECTED_STEP_LABELS,
		"steps[].text must mirror the _OBJECTIVES labels in chain order"
	)


func test_steps_active_state_tracks_current_stage() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	# Day starts at STAGE_TALK_TO_CUSTOMER after the Vic note dismiss.
	var steps: Array = _latest_steps_payload(controller)
	assert_eq(
		_step_states(steps),
		["active", "future", "future", "future"],
		"At day start, only the customer step must be 'active'"
	)


func test_steps_completed_state_tracks_completed_objectives() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	# Complete the customer beat → step 0 'completed', step 1 'active'.
	controller._on_choice_selected(&"clean_exchange", {})
	await get_tree().process_frame
	var steps: Array = _latest_steps_payload(controller)
	assert_eq(
		_step_states(steps),
		["completed", "active", "future", "future"],
		"After the customer beat, only the back-room step must be 'active'"
	)
	# Complete the back-room and stock beats → only close_day stays active.
	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	controller.on_store_restock_interacted()
	await get_tree().process_frame
	steps = _latest_steps_payload(controller)
	assert_eq(
		_step_states(steps),
		["completed", "completed", "completed", "active"],
		"At STAGE_END_DAY every required predecessor must be 'completed'"
	)


func test_steps_all_future_during_vic_note_phase() -> void:
	# Force the controller back into the pre-chain Vic-note phase and
	# re-emit the rail. Pre-chain has no completed objectives and no chain
	# row active, so every entry must read 'future'.
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	controller.set("_stage", StoreSessionController.STAGE_VIC_NOTE)
	(controller.get("_completed_objectives") as Dictionary).clear()
	var steps: Array = _latest_steps_payload(controller)
	assert_eq(
		_step_states(steps),
		["future", "future", "future", "future"],
		"During STAGE_VIC_NOTE every step must read 'future'"
	)


# ── Shift-note derived from completion state ──────────────────────────────
# `_on_day_close_confirmed` reads `_completed_objectives` to decide which
# narrative variant goes into the summary's shift_note. If every required
# step was completed the baseline "you made it through" copy fires; when any
# required step is missing the note must clearly name the skipped work
# (BRAINDUMP rule: closing early must surface what the player skipped).


func _mark_all_required_complete(controller: Node) -> void:
	var completed: Dictionary = controller.get("_completed_objectives") as Dictionary
	completed[&"talk_to_customer"] = true
	completed[&"back_room_inventory"] = true
	completed[&"stock_shelf"] = true


func test_shift_note_uses_baseline_when_all_required_complete() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	(controller.get("_completed_objectives") as Dictionary).clear()
	_mark_all_required_complete(controller)
	var note: String = String(controller._build_shift_note())
	assert_true(
		note.contains("made it through"),
		"All-complete day must use the baseline 'made it through' copy; got: '%s'" % note
	)
	assert_false(
		note.begins_with("You closed without"),
		"Baseline note must not name skipped work; got: '%s'" % note
	)


func test_shift_note_names_skipped_backroom() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	(controller.get("_completed_objectives") as Dictionary).clear()
	var completed: Dictionary = controller.get("_completed_objectives") as Dictionary
	completed[&"talk_to_customer"] = true
	completed[&"stock_shelf"] = true
	var note: String = String(controller._build_shift_note())
	assert_true(
		note.contains("back room delivery"),
		"Skipped back-room must be named in the shift note; got: '%s'" % note
	)
	assert_true(
		note.begins_with("You closed without"),
		"Skip-branch copy must begin with 'You closed without'; got: '%s'" % note
	)


func test_shift_note_names_skipped_customer() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	(controller.get("_completed_objectives") as Dictionary).clear()
	var completed: Dictionary = controller.get("_completed_objectives") as Dictionary
	completed[&"back_room_inventory"] = true
	completed[&"stock_shelf"] = true
	var note: String = String(controller._build_shift_note())
	assert_true(
		note.contains("customer at the register"),
		"Skipped customer must be named in the shift note; got: '%s'" % note
	)


func test_shift_note_joins_multiple_skipped_steps() -> void:
	# All three required steps skipped — the note must enumerate every one
	# so the summary cannot read as a clean wrap-up.
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	(controller.get("_completed_objectives") as Dictionary).clear()
	var note: String = String(controller._build_shift_note())
	assert_true(
		note.contains("customer at the register"),
		"Multi-skip note must name the customer step; got: '%s'" % note
	)
	assert_true(
		note.contains("back room delivery"),
		"Multi-skip note must name the back-room step; got: '%s'" % note
	)
	assert_true(
		note.contains("used shelf"),
		"Multi-skip note must name the stock-shelf step; got: '%s'" % note
	)


func test_on_day_close_confirmed_spawns_summary_only_once() -> void:
	# BRAINDUMP modal-discipline rule: a re-emit of `day_close_confirmed`
	# (production `DayCycleController` listener firing alongside the store_session
	# controller, or a stray double-press) must not produce a second
	# summary modal. The controller's `_summary_spawned` guard plus
	# ModalQueue's panel-instance dedup are the two layers being verified.
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	# Walk the chain to END_DAY so the close-day gate is satisfied.
	controller._on_choice_selected(&"clean_exchange", {})
	await get_tree().process_frame
	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	controller.on_store_restock_interacted()
	await get_tree().process_frame
	watch_signals(EventBus)
	# First confirm — spawns the summary modal.
	controller._on_day_close_confirmed()
	await get_tree().process_frame
	var panel: DaySummaryPanel = controller.get("_summary_panel") as DaySummaryPanel
	assert_not_null(panel, "Summary panel must be spawned on first confirm")
	if panel == null:
		return
	var depth_after_first: int = InputFocus.depth()
	# Second confirm — must early-out, leaving the modal stack untouched.
	controller._on_day_close_confirmed()
	await get_tree().process_frame
	assert_eq(
		InputFocus.depth(),
		depth_after_first,
		"Repeat _on_day_close_confirmed must not push a second CTX_MODAL frame"
	)
	assert_eq(
		ModalQueue.pending_count(),
		0,
		"Repeat _on_day_close_confirmed must not enqueue a second summary"
	)
	assert_signal_emit_count(
		EventBus,
		"unlock_granted",
		1,
		"Repeated close confirm must not emit a duplicate closing-certification grant"
	)
	assert_true(
		_signal_first_arg_seen(
			get_signal_parameters_all(EventBus, "unlock_granted"), &"employee_closing_certified"
		),
		"First close confirm must grant closing certification"
	)


func test_store_close_confirm_does_not_run_production_day_summary() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	var fixture: Dictionary = _production_day_cycle_fixture()
	var day_cycle: DayCycleController = fixture["controller"] as DayCycleController
	var time: TimeSystem = fixture["time"] as TimeSystem
	GameManager.current_state = GameManager.State.GAMEPLAY

	controller._on_choice_selected(&"clean_exchange", {})
	await get_tree().process_frame
	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	controller.on_store_restock_interacted()
	await get_tree().process_frame
	assert_true(
		bool(controller.can_interact_day_end()),
		"Precondition: store_session close-day must be available after required work"
	)

	watch_signals(EventBus)
	controller.on_store_day_end_requested()
	await get_tree().process_frame
	_press_close_day_confirm(controller)
	await get_tree().process_frame

	var summary_panel: DaySummaryPanel = controller.get("_summary_panel") as DaySummaryPanel
	assert_not_null(summary_panel, "Store-session summary panel must exist after confirm")
	if summary_panel == null:
		return
	assert_true(
		bool(summary_panel.get("_focus_pushed")),
		"Store-session summary must own the active modal focus after confirm"
	)
	assert_same(
		ModalQueue.active_panel(),
		summary_panel,
		"Store-session close confirm must leave the store_session summary as the only active modal"
	)
	assert_eq(ModalQueue.pending_count(), 0, "Store-session close confirm must not enqueue a second summary")
	assert_false(
		day_cycle._awaiting_acknowledgement,
		"Production day cycle must not await acknowledgement during store_session close"
	)
	assert_true(
		UnlockSystemSingleton.is_unlocked(&"employee_closing_certified"),
		"Store-session close must grant closing certification after store_session summary processing"
	)
	assert_false(
		UnlockSystemSingleton.is_unlocked(&"extended_hours_unlock"),
		"Store-session close must not grant extended hours"
	)
	assert_ne(
		GameManager.current_state,
		GameManager.State.DAY_SUMMARY,
		"Store-session close confirm must not enter the production day-summary state"
	)
	assert_eq(
		time.current_day, 1, "Production day cycle must not advance the day during store_session close"
	)
	assert_signal_not_emitted(
		EventBus, "day_closed", "Store-session close confirm must not emit the production day_closed payload"
	)


func test_store_close_confirm_reemit_keeps_production_day_cycle_idle() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	var fixture: Dictionary = _production_day_cycle_fixture()
	var day_cycle: DayCycleController = fixture["controller"] as DayCycleController
	GameManager.current_state = GameManager.State.GAMEPLAY

	controller._on_choice_selected(&"clean_exchange", {})
	await get_tree().process_frame
	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	controller.on_store_restock_interacted()
	await get_tree().process_frame
	controller.on_store_day_end_requested()
	await get_tree().process_frame
	_press_close_day_confirm(controller)
	await get_tree().process_frame
	var depth_after_first: int = InputFocus.depth()

	watch_signals(EventBus)
	EventBus.day_close_confirmed.emit()
	await get_tree().process_frame

	assert_eq(
		InputFocus.depth(),
		depth_after_first,
		"Re-emitted close confirmation must not push another modal frame"
	)
	var summary_panel: DaySummaryPanel = controller.get("_summary_panel") as DaySummaryPanel
	assert_same(
		ModalQueue.active_panel(),
		summary_panel,
		"Re-emitted close confirmation must leave the same store_session summary active"
	)
	assert_eq(
		ModalQueue.pending_count(),
		0,
		"Re-emitted close confirmation must not enqueue duplicate summaries"
	)
	assert_false(
		day_cycle._awaiting_acknowledgement,
		"Production day cycle must remain idle after duplicate store_session confirm"
	)
	assert_signal_not_emitted(
		EventBus, "day_closed", "Duplicate store_session confirm must not emit production day_closed"
	)


func test_close_day_summary_uses_dynamic_shift_note() -> void:
	# Drive the full chain to END_DAY, confirm close, and verify the summary
	# payload's shift_note tracks `_completed_objectives` rather than the
	# legacy hardcoded literal.
	var controller: Node = _store_session_controller()
	if controller == null:
		return
	controller._on_choice_selected(&"clean_exchange", {})
	await get_tree().process_frame
	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	controller.on_store_restock_interacted()
	await get_tree().process_frame
	controller.on_store_day_end_requested()
	await get_tree().process_frame
	_press_close_day_confirm(controller)
	await get_tree().process_frame
	var panel: DaySummaryPanel = controller.get("_summary_panel") as DaySummaryPanel
	assert_not_null(panel, "Summary panel must be spawned")
	if panel == null:
		return
	var note_label: Label = panel.get("_note_label") as Label
	assert_not_null(note_label, "Summary panel must own a _note_label")
	if note_label == null:
		return
	assert_true(
		note_label.text.contains("made it through"),
		"Completed-chain summary must render the baseline shift_note; got: '%s'" % note_label.text
	)


# ── ModalQueue depth invariant during the full Day-1 chain ────────────────
# Walks the chain through every modal open/close the player triggers
# (decision card → close-day confirm → summary) and asserts the
# `one blocking modal at a time` invariant via the panel-local
# `_focus_pushed` field and ModalQueue's own bookkeeping.
#
# We deliberately avoid absolute `InputFocus.depth()` / CTX_MODAL-frame
# count assertions: StoreSessionController parents its modal panels under
# `_ui_root()`, which falls back to `/root` in headless tests. The in-
# process GUT runner does not garbage-collect panels created by prior
# tests' (now-freed) controllers, so leaked listeners can push extra
# CTX_MODAL frames onto a globally-shared stack while still leaving the
# *current* controller's modal contract intact. Mirrors the existing
# `test_summary_continue_pops_modal_focus_before_starting_next_day` choice
# to assert against panel-local invariants for the same reason.


func test_modal_queue_depth_never_exceeds_one_during_day1() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return

	# Day starts at TALK_TO_CUSTOMER. ModalQueue must be idle from this
	# controller's perspective — `before_each` resets it.
	assert_eq(
		ModalQueue.pending_count(), 0, "[day_start] ModalQueue must start with no pending entries"
	)

	# Player E on customer → DecisionCardPanel enqueues at DAY_SUMMARY
	# priority and dispatches synchronously (queue was idle).
	controller.on_store_customer_interacted()
	await get_tree().process_frame
	var decision_panel: DecisionCardPanel = (
		controller.get("_decision_panel") as DecisionCardPanel
	)
	assert_not_null(decision_panel, "Controller must own _decision_panel")
	if decision_panel == null:
		return
	assert_same(
		ModalQueue.active_panel(),
		decision_panel,
		"[decision_card_open] Decision card must be the active ModalQueue entry"
	)
	assert_true(
		bool(decision_panel.get("_focus_pushed")),
		"[decision_card_open] Decision card must own a CTX_MODAL frame"
	)
	assert_eq(
		ModalQueue.pending_count(),
		0,
		"[decision_card_open] No panel may be queued behind the decision card"
	)

	# Pick a choice via the panel's button handler so the runtime
	# emit+close sequence runs: emits choice_selected, queues the customer
	# result, then closes the decision card and hands ModalQueue to the
	# result panel.
	decision_panel._on_choice_pressed(&"clean_exchange", {})
	await get_tree().process_frame
	assert_false(
		bool(decision_panel.get("_focus_pushed")),
		"[after_choice] Decision card must release its CTX_MODAL frame on close"
	)
	var result_panel: ModalPanel = controller.get("_customer_result_panel") as ModalPanel
	assert_not_null(result_panel, "Controller must own _customer_result_panel")
	if result_panel == null:
		return
	assert_same(
		ModalQueue.active_panel(),
		result_panel,
		"[after_choice] Customer result must be active after decision close"
	)
	assert_eq(ModalQueue.pending_count(), 0, "[after_choice] ModalQueue pending must stay at 0")
	var result_continue: Button = result_panel.get("_continue_button") as Button
	assert_not_null(result_continue, "Customer result must own Continue")
	if result_continue == null:
		return
	result_continue.pressed.emit()
	await get_tree().process_frame
	assert_null(
		ModalQueue.active_panel(), "[after_result] ModalQueue must drain to idle after Continue"
	)
	assert_eq(ModalQueue.pending_count(), 0, "[after_result] ModalQueue pending must stay at 0")

	# Back-room and restock are non-modal interactions; queue stays idle.
	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	assert_null(
		ModalQueue.active_panel(),
		"[after_backroom] ModalQueue must remain idle through back-room pickup"
	)
	assert_eq(ModalQueue.pending_count(), 0, "[after_backroom] ModalQueue pending must stay at 0")

	controller.on_store_restock_interacted()
	await get_tree().process_frame
	assert_null(
		ModalQueue.active_panel(), "[after_restock] ModalQueue must remain idle through restocking"
	)
	assert_eq(ModalQueue.pending_count(), 0, "[after_restock] ModalQueue pending must stay at 0")

	# Player E on the day-end trigger -> CloseDayConfirmationPanel opens through
	# ModalQueue and owns the active CTX_MODAL frame until confirm.
	controller.on_store_day_end_requested()
	await get_tree().process_frame
	var close_day_panel: CanvasLayer = controller.get("_close_day_panel") as CanvasLayer
	assert_not_null(close_day_panel, "Controller must own _close_day_panel")
	if close_day_panel == null:
		return
	assert_true(
		bool(close_day_panel.get("_focus_pushed")),
		"[close_day_open] Close-day confirmation panel must own a CTX_MODAL frame"
	)
	assert_same(
		ModalQueue.active_panel(),
		close_day_panel,
		"[close_day_open] Close-day confirmation panel must be the active ModalQueue entry"
	)

	# Confirm → close-day panel pops its frame, then DaySummaryPanel
	# enqueues at DAY_SUMMARY priority and dispatches synchronously. The
	# hand-off must end with summary as the sole active modal — the
	# close-day frame released before the summary's push.
	_press_close_day_confirm(controller)
	await get_tree().process_frame
	assert_false(
		bool(close_day_panel.get("_focus_pushed")),
		"[summary_open] Close-day panel must have released its frame after confirm"
	)
	var summary_panel: DaySummaryPanel = controller.get("_summary_panel") as DaySummaryPanel
	assert_not_null(summary_panel, "Controller must own _summary_panel after confirm")
	if summary_panel == null:
		return
	assert_true(
		bool(summary_panel.get("_focus_pushed")),
		"[summary_open] Summary panel must own the CTX_MODAL frame after confirm"
	)
	assert_same(
		ModalQueue.active_panel(),
		summary_panel,
		"[summary_open] Summary panel must be the active ModalQueue entry"
	)


# ── HUD snapshot golden path ───────────────────────────────────────────────
# Captures `get_state_snapshot()` at each of the 4 chain phases and asserts
# the fields the HUD view-model reads (stage, completed_objectives,
# carrying_stock, can_close_day) match the expected progression. Locks the
# snapshot contract so a refactor of the underlying private fields cannot
# silently shift HUD readings.


func test_hud_snapshot_golden_path() -> void:
	var controller: Node = _store_session_controller()
	if controller == null:
		return

	# Phase 1 — TALK_TO_CUSTOMER.
	var snap_1: Dictionary = controller.get_state_snapshot()
	assert_eq(
		String(snap_1.get("stage", "")),
		"talk_to_customer",
		"Phase 1 stage must be talk_to_customer"
	)
	var completed_1: Dictionary = snap_1.get("completed_objectives", {}) as Dictionary
	assert_eq(completed_1.size(), 0, "Phase 1 completed_objectives must be empty")
	assert_false(
		bool(snap_1.get("carrying_stock", true)),
		"Phase 1 carrying_stock must be false at day start"
	)
	assert_false(
		bool(snap_1.get("can_close_day", true)),
		"Phase 1 can_close_day must be false (chain not started)"
	)

	# Phase 2 — BACK_ROOM_INVENTORY (after customer beat).
	controller._on_choice_selected(&"clean_exchange", {})
	await get_tree().process_frame
	var snap_2: Dictionary = controller.get_state_snapshot()
	assert_eq(
		String(snap_2.get("stage", "")),
		"back_room_inventory",
		"Phase 2 stage must be back_room_inventory"
	)
	var completed_2: Dictionary = snap_2.get("completed_objectives", {}) as Dictionary
	assert_true(
		completed_2.has(&"talk_to_customer"),
		"Phase 2 completed_objectives must include talk_to_customer"
	)
	assert_eq(completed_2.size(), 1, "Phase 2 completed_objectives must contain exactly one entry")
	assert_false(
		bool(snap_2.get("carrying_stock", true)),
		"Phase 2 carrying_stock must remain false before pickup"
	)
	assert_false(bool(snap_2.get("can_close_day", true)), "Phase 2 can_close_day must be false")

	# Phase 3 — STOCK_SHELF (after back-room pickup; carry flag flips).
	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame
	var snap_3: Dictionary = controller.get_state_snapshot()
	assert_eq(String(snap_3.get("stage", "")), "stock_shelf", "Phase 3 stage must be stock_shelf")
	var completed_3: Dictionary = snap_3.get("completed_objectives", {}) as Dictionary
	assert_true(
		completed_3.has(&"talk_to_customer"),
		"Phase 3 completed_objectives must keep talk_to_customer"
	)
	assert_true(
		completed_3.has(&"back_room_inventory"),
		"Phase 3 completed_objectives must include back_room_inventory"
	)
	assert_true(
		bool(snap_3.get("carrying_stock", false)),
		"Phase 3 carrying_stock must flip true after back-room pickup"
	)
	assert_false(
		bool(snap_3.get("can_close_day", true)),
		"Phase 3 can_close_day must still be false (shelf not stocked)"
	)

	# Phase 4 — END_DAY (after restock; carry clears, close-day unlocks).
	controller.on_store_restock_interacted()
	await get_tree().process_frame
	var snap_4: Dictionary = controller.get_state_snapshot()
	assert_eq(String(snap_4.get("stage", "")), "end_day", "Phase 4 stage must be end_day")
	var completed_4: Dictionary = snap_4.get("completed_objectives", {}) as Dictionary
	assert_true(
		completed_4.has(&"talk_to_customer"),
		"Phase 4 completed_objectives must keep talk_to_customer"
	)
	assert_true(
		completed_4.has(&"back_room_inventory"),
		"Phase 4 completed_objectives must keep back_room_inventory"
	)
	assert_true(
		completed_4.has(&"stock_shelf"), "Phase 4 completed_objectives must include stock_shelf"
	)
	assert_false(
		bool(snap_4.get("carrying_stock", true)),
		"Phase 4 carrying_stock must clear after stocking the shelf"
	)
	assert_true(
		bool(snap_4.get("can_close_day", false)),
		"Phase 4 can_close_day must be true once every required objective is done at end_day"
	)
