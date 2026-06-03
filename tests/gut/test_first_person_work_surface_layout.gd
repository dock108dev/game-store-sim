## Pins first-person HUD and docked work panels to reserved screen regions so
## shelf/register work remains physically visible behind compact UI.
extends GutTest

const _VIEWPORT_SIZE: Vector2 = Vector2(1280.0, 720.0)
const _HUD_SCENE: PackedScene = preload("res://game/scenes/ui/hud.tscn")
const _CHECKOUT_SCENE: PackedScene = preload("res://game/scenes/ui/checkout_panel.tscn")
const _PRICING_SCENE: PackedScene = preload("res://game/scenes/ui/pricing_panel.tscn")
const _RAIL_SCENE: PackedScene = preload("res://game/scenes/ui/objective_rail.tscn")
const WorkSurfaceLayout = preload("res://game/scripts/ui/work_surface_layout.gd")

var _saved_state: GameManager.State


func before_each() -> void:
	_saved_state = GameManager.current_state
	GameManager.current_state = GameManager.State.STORE_VIEW
	if InputFocus != null:
		InputFocus._reset_for_tests()
	EventBus.fp_mode_changed.emit(false)
	EventBus.interactable_unfocused.emit()
	EventBus.store_carry_changed.emit("")


func after_each() -> void:
	GameManager.current_state = _saved_state
	if InputFocus != null:
		InputFocus._reset_for_tests()
	EventBus.fp_mode_changed.emit(false)
	EventBus.interactable_unfocused.emit()
	EventBus.store_carry_changed.emit("")


func test_first_person_hud_slots_stay_outside_work_surface() -> void:
	var work_rect: Rect2 = WorkSurfaceLayout.first_person_work_rect(_VIEWPORT_SIZE)
	for slot_name: StringName in [
		&"cash",
		&"time",
		&"close_day",
		&"sentence",
		&"carry",
		&"prompt",
	]:
		var slot_rect: Rect2 = WorkSurfaceLayout.hud_slot_rect(slot_name, _VIEWPORT_SIZE)
		assert_false(
			WorkSurfaceLayout.rects_overlap(work_rect, slot_rect),
			"%s slot must not overlap first-person work rect %s; got %s"
			% [String(slot_name), str(work_rect), str(slot_rect)]
		)


func test_docked_work_panel_reservations_stay_outside_work_surface() -> void:
	var work_rect: Rect2 = WorkSurfaceLayout.first_person_work_rect(_VIEWPORT_SIZE)
	for panel_name: StringName in [
		WorkSurfaceLayout.PANEL_CHECKOUT,
		WorkSurfaceLayout.PANEL_PRICING,
		WorkSurfaceLayout.PANEL_INVENTORY,
		WorkSurfaceLayout.PANEL_FIXTURE_CATALOG,
		WorkSurfaceLayout.PANEL_CUSTOMIZATION,
	]:
		var panel_rect: Rect2 = WorkSurfaceLayout.panel_reserved_rect(
			panel_name, _VIEWPORT_SIZE
		)
		assert_false(
			WorkSurfaceLayout.rects_overlap(work_rect, panel_rect),
			"%s reservation must not overlap work rect %s; got %s"
			% [String(panel_name), str(work_rect), str(panel_rect)]
		)


func test_fp_close_day_hint_uses_top_right_reserved_slot() -> void:
	var hud: CanvasLayer = _HUD_SCENE.instantiate() as CanvasLayer
	add_child_autofree(hud)

	hud.set_fp_mode(true)

	var hint: Label = hud.get_node_or_null("FpCloseDayHint") as Label
	assert_not_null(hint, "FP close-day hint must exist")
	if hint == null:
		return
	var expected: Rect2 = WorkSurfaceLayout.FP_CLOSE_DAY_RECT
	assert_eq(hint.anchor_top, 0.0, "Close-day hint must anchor to the top band")
	assert_eq(hint.anchor_bottom, 0.0, "Close-day hint must anchor to the top band")
	assert_eq(hint.offset_left, expected.position.x)
	assert_eq(hint.offset_top, expected.position.y)
	assert_eq(hint.offset_right, expected.position.x + expected.size.x)
	assert_eq(hint.offset_bottom, expected.position.y + expected.size.y)


func test_pricing_panel_has_obvious_close_button() -> void:
	var pricing: PricingPanel = _PRICING_SCENE.instantiate() as PricingPanel
	add_child_autofree(pricing)

	pricing._open_empty()
	assert_true(pricing.is_open(), "Pricing panel should open for the close-path check")
	pricing._close_button.pressed.emit()

	assert_false(pricing.is_open(), "Pricing close button must close the panel")


func test_pricing_panel_close_preserves_first_person_focus() -> void:
	var pricing: PricingPanel = _PRICING_SCENE.instantiate() as PricingPanel
	add_child_autofree(pricing)
	InputFocus.push_context(InputFocus.CTX_STORE_GAMEPLAY)
	var baseline_depth: int = InputFocus.depth()

	pricing._open_empty()
	pricing.close(true)

	assert_eq(
		InputFocus.depth(),
		baseline_depth,
		"Non-modal pricing must not add or remove InputFocus frames"
	)
	assert_eq(
		InputFocus.current(),
		InputFocus.CTX_STORE_GAMEPLAY,
		"Closing non-modal pricing must leave first-person control on top"
	)


func test_opening_checkout_closes_pricing_before_claiming_modal_focus() -> void:
	var pricing: PricingPanel = _PRICING_SCENE.instantiate() as PricingPanel
	var checkout: CheckoutPanel = _CHECKOUT_SCENE.instantiate() as CheckoutPanel
	add_child_autofree(pricing)
	add_child_autofree(checkout)
	InputFocus.push_context(InputFocus.CTX_STORE_GAMEPLAY)

	pricing._open_empty()
	checkout.show_checkout([{
		"item_name": "Test Cart",
		"condition": "Good",
		"price": 12.0,
	}])

	assert_false(
		pricing.is_open(),
		"Opening checkout must close the sibling pricing panel"
	)
	assert_true(checkout.is_open(), "Checkout must remain open after arbitration")
	assert_eq(
		InputFocus.current(),
		InputFocus.CTX_MODAL,
		"Checkout must claim modal focus after sibling docked panels close"
	)


func test_work_panel_conflict_contract_matches_current_focus_categories() -> void:
	assert_true(
		WorkSurfaceLayout.panels_conflict(
			WorkSurfaceLayout.PANEL_CHECKOUT,
			WorkSurfaceLayout.PANEL_PRICING
		),
		"Checkout and pricing are mutually exclusive docked work panels"
	)
	assert_true(
		WorkSurfaceLayout.claims_modal_focus(WorkSurfaceLayout.PANEL_CHECKOUT),
		"Checkout must claim modal focus"
	)
	assert_true(
		WorkSurfaceLayout.claims_modal_focus(WorkSurfaceLayout.PANEL_INVENTORY),
		"Inventory must claim modal focus"
	)
	assert_false(
		WorkSurfaceLayout.claims_modal_focus(WorkSurfaceLayout.PANEL_PRICING),
		"Pricing remains non-modal; panel_opened blocks world interaction instead"
	)


func test_objective_rail_hides_in_fp_while_prompt_keeps_priority() -> void:
	var rail: CanvasLayer = _RAIL_SCENE.instantiate() as CanvasLayer
	add_child_autofree(rail)

	EventBus.objective_changed.emit({
		"text": "Stock the shelf.",
		"action": "Open inventory",
		"key": "I",
	})
	EventBus.fp_mode_changed.emit(true)
	EventBus.store_carry_changed.emit("Starter Box")

	assert_false(
		rail.visible,
		"FP mode must hide the full-width ObjectiveRail"
	)

	EventBus.interactable_focused_disabled.emit("Shelf is full")
	assert_false(
		rail.visible,
		"Disabled focused prompts belong to InteractionPrompt, not ObjectiveRail"
	)

	EventBus.interactable_focused.emit("Stock shelf")
	assert_false(
		rail.visible,
		"Actionable focused prompts must not resurface ObjectiveRail in FP mode"
	)

	InputFocus.push_context(InputFocus.CTX_MODAL)
	assert_false(rail.visible, "Modal dimming must not resurface the hidden FP rail")
	assert_true(rail.is_modal_dim_active(), "Rail must enter modal-dim state")
