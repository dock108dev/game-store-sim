## Shared first-person HUD and docked-panel layout reservation contract.
class_name WorkSurfaceLayout
extends RefCounted

const PANEL_CHECKOUT: StringName = &"checkout"
const PANEL_PRICING: StringName = &"pricing"
const PANEL_INVENTORY: StringName = &"inventory"
const PANEL_FIXTURE_CATALOG: StringName = &"fixture_catalog"
const PANEL_CUSTOMIZATION: StringName = &"customization"
const PANEL_DAY_SUMMARY: StringName = &"day_summary"

const HUD_TOP_RESERVED: float = 64.0
const HUD_BOTTOM_RESERVED: float = 220.0
const LEFT_DOCK_RESERVED: float = 540.0
const RIGHT_DOCK_RESERVED: float = 380.0

const FP_CASH_RECT: Rect2 = Rect2(16.0, 8.0, 204.0, 24.0)
const FP_TIME_RECT: Rect2 = Rect2(-160.0, 32.0, 320.0, 24.0)
const FP_CLOSE_DAY_RECT: Rect2 = Rect2(-208.0, 8.0, 192.0, 24.0)
const FP_SENTENCE_RECT: Rect2 = Rect2(-300.0, -96.0, 600.0, 28.0)
const FP_CARRY_RECT: Rect2 = Rect2(16.0, -200.0, 344.0, 32.0)
const INTERACTION_PROMPT_RECT: Rect2 = Rect2(-376.0, -200.0, 360.0, 40.0)
const OBJECTIVE_RAIL_RECT: Rect2 = Rect2(0.0, -148.0, 1.0, 148.0)

const CHECKOUT_PANEL_WIDTH: float = 320.0
const PRICING_PANEL_WIDTH: float = 340.0
const PRICING_PANEL_HEIGHT: float = 480.0
const INVENTORY_PANEL_WIDTH: float = 420.0
const FIXTURE_CATALOG_WIDTH: float = 500.0


## Returns the central world-space work zone kept clear of persistent HUD and
## docked panel reservations for first-person shelf/register work.
static func first_person_work_rect(viewport_size: Vector2) -> Rect2:
	var width: float = maxf(
		0.0, viewport_size.x - LEFT_DOCK_RESERVED - RIGHT_DOCK_RESERVED
	)
	var height: float = maxf(
		0.0, viewport_size.y - HUD_TOP_RESERVED - HUD_BOTTOM_RESERVED
	)
	return Rect2(LEFT_DOCK_RESERVED, HUD_TOP_RESERVED, width, height)


## Returns the authored screen rectangle for a known first-person HUD slot.
static func hud_slot_rect(slot_name: StringName, viewport_size: Vector2) -> Rect2:
	match slot_name:
		&"cash":
			return FP_CASH_RECT
		&"time":
			return _center_x(FP_TIME_RECT, viewport_size)
		&"close_day":
			return _right_anchor(FP_CLOSE_DAY_RECT, viewport_size)
		&"sentence":
			return _center_x(_bottom_anchor(FP_SENTENCE_RECT, viewport_size), viewport_size)
		&"carry":
			return _bottom_anchor(FP_CARRY_RECT, viewport_size)
		&"prompt":
			return _right_anchor(_bottom_anchor(INTERACTION_PROMPT_RECT, viewport_size), viewport_size)
		&"objective_rail":
			return Rect2(
				0.0,
				viewport_size.y + OBJECTIVE_RAIL_RECT.position.y,
				viewport_size.x,
				OBJECTIVE_RAIL_RECT.size.y
			)
		_:
			return Rect2()


## Returns the reserved screen rectangle for panels that affect first-person
## work-surface visibility.
static func panel_reserved_rect(panel_name: StringName, viewport_size: Vector2) -> Rect2:
	match panel_name:
		PANEL_CHECKOUT:
			return Rect2(
				viewport_size.x - CHECKOUT_PANEL_WIDTH,
				0.0,
				CHECKOUT_PANEL_WIDTH,
				viewport_size.y
			)
		PANEL_PRICING:
			return Rect2(
				viewport_size.x - PRICING_PANEL_WIDTH,
				(viewport_size.y - PRICING_PANEL_HEIGHT) * 0.5,
				PRICING_PANEL_WIDTH,
				PRICING_PANEL_HEIGHT
			)
		PANEL_INVENTORY:
			return Rect2(0.0, 0.0, INVENTORY_PANEL_WIDTH, viewport_size.y)
		PANEL_FIXTURE_CATALOG:
			return Rect2(20.0, 60.0, FIXTURE_CATALOG_WIDTH, viewport_size.y - 80.0)
		PANEL_CUSTOMIZATION:
			return Rect2(
				viewport_size.x - RIGHT_DOCK_RESERVED,
				0.0,
				RIGHT_DOCK_RESERVED,
				viewport_size.y
			)
		PANEL_DAY_SUMMARY:
			return Rect2(Vector2.ZERO, viewport_size)
		_:
			return Rect2()


## True when a panel is a docked work panel that should not stack with another
## docked work panel in the same first-person flow.
static func is_docked_work_panel(panel_name: StringName) -> bool:
	return [
		PANEL_CHECKOUT,
		PANEL_PRICING,
		PANEL_INVENTORY,
		PANEL_FIXTURE_CATALOG,
		PANEL_CUSTOMIZATION,
	].has(panel_name)


## Returns whether opening one panel should close the other under the docked
## first-person work-panel mutual-exclusion rule.
static func panels_conflict(opened: StringName, current: StringName) -> bool:
	if opened == current:
		return false
	return is_docked_work_panel(opened) and is_docked_work_panel(current)


## Returns whether the panel owns modal focus instead of only using the legacy
## panel-open interaction block.
static func claims_modal_focus(panel_name: StringName) -> bool:
	return [
		PANEL_CHECKOUT,
		PANEL_INVENTORY,
		PANEL_DAY_SUMMARY,
	].has(panel_name)


## Returns true when two rectangles have positive-area overlap.
static func rects_overlap(left: Rect2, right: Rect2) -> bool:
	return left.intersects(right, false)


static func _bottom_anchor(rect: Rect2, viewport_size: Vector2) -> Rect2:
	return Rect2(
		rect.position.x,
		viewport_size.y + rect.position.y,
		rect.size.x,
		rect.size.y
	)


static func _right_anchor(rect: Rect2, viewport_size: Vector2) -> Rect2:
	return Rect2(
		viewport_size.x + rect.position.x,
		rect.position.y,
		rect.size.x,
		rect.size.y
	)


static func _center_x(rect: Rect2, viewport_size: Vector2) -> Rect2:
	return Rect2(
		(viewport_size.x * 0.5) + rect.position.x,
		rect.position.y,
		rect.size.x,
		rect.size.y
	)
