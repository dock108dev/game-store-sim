# gdlint:disable=max-file-lines
## 3D customer NPC that navigates the store, browses items, and makes purchases.
class_name Customer
extends CharacterBody3D

signal despawn_requested(customer: Customer)

enum State {
	ENTERING,
	BROWSING,
	DECIDING,
	PURCHASING,
	WAITING_IN_QUEUE,
	LEAVING,
}

const MOVE_SPEED: float = 2.0
const MOVE_TO_NEXT_SHELF_CHANCE: float = 0.5
const INVESTOR_MAX_MARKET_RATIO: float = 0.8
const TESTED_BONUS: float = 0.25
const DISAPPOINTED_CHANCE: float = 0.05
## Navigation path recalculation interval in seconds.
const NAV_RECALC_INTERVAL: float = 0.2
## Squared arrival radius for direct waypoint-fallback movement (≈0.6m).
const WAYPOINT_ARRIVAL_DIST_SQ: float = 0.36
const NAV_PROGRESS_MIN_DIST_SQ: float = 0.04
const NAV_STALL_SECONDS: float = 8.0
const NAV_TARGET_TIMEOUT_SECONDS: float = 45.0
## Day-1 patience tick scale for WAITING_IN_QUEUE customers. 0.5 doubles their
## effective patience while the player rings up the head-of-queue customer
## manually, so a slow first transaction does not collapse the queue.
const DAY1_QUEUE_PATIENCE_TICK_SCALE: float = 0.5
const STATE_CUE_NAME: StringName = &"StateCue"
const STATE_CUE_SIZE: Vector3 = Vector3(0.18, 0.035, 0.018)
const STATE_CUE_BROWSE: Color = Color(0.357, 0.722, 0.910, 1.0)
const STATE_CUE_QUEUE: Color = Color(0.949, 0.722, 0.110, 1.0)
const STATE_CUE_REGISTER: Color = Color(0.427, 0.812, 0.353, 1.0)
const STATE_CUE_LEAVING: Color = Color(0.898, 0.243, 0.169, 1.0)
const STATE_CUE_NEUTRAL: Color = Color(0.957, 0.914, 0.831, 1.0)
const CONDITION_RANKS: Dictionary = {
	"poor": 0,
	"fair": 1,
	"good": 2,
	"near_mint": 3,
	"mint": 4,
}
const ProductVisualFactoryScript: GDScript = preload(
	"res://game/scripts/visuals/product_visual_factory.gd"
)
const StoreVisualKitScript: GDScript = preload(
	"res://game/scripts/visuals/store_visual_kit.gd"
)
const CustomerVisualProfileScript: GDScript = preload(
	"res://game/scripts/characters/customer_visual_profile.gd"
)

const HELD_ITEM_STATE_NONE: StringName = &"none"
const HELD_ITEM_STATE_SELECTED_CARRIED: StringName = &"selected_carried"
const HELD_ITEM_STATE_SELECTED_QUEUE: StringName = &"selected_queue"
const HELD_ITEM_STATE_SELECTED_CHECKOUT: StringName = &"selected_checkout"
const HELD_ITEM_STATE_SELECTED_SOLD: StringName = &"selected_sold"
const HELD_ITEM_STATE_SELECTED_ABANDONED: StringName = &"selected_abandoned"
const HELD_ITEM_STATE_RETURNED_CARRIED: StringName = &"returned_carried"
const HELD_ITEM_STATE_RETURNED_PRESENTED: StringName = &"returned_presented"
const HELD_ITEM_STATE_RETURNED_ACCEPTED: StringName = &"returned_accepted"
const HELD_ITEM_STATE_RETURNED_REFUSED: StringName = &"returned_refused"
const HELD_ITEM_STATE_TRADE_IN_PRESENTED: StringName = &"trade_in_presented"
const HELD_ITEM_STATE_PAYOUT_RETURNED: StringName = &"payout_returned"
const _HELD_ITEM_KIND_NONE: StringName = &"none"
const _HELD_ITEM_KIND_SELECTED: StringName = &"selected"
const _HELD_ITEM_KIND_RETURNED: StringName = &"returned"
const _HELD_ITEM_KIND_TRADE_IN: StringName = &"trade_in"
const _HELD_ITEM_PROP_NAME: StringName = &"HeldItemProp"
const _HELD_ITEM_PROP_SCALE: Vector3 = Vector3(0.36, 0.36, 0.36)

## Sequential debug counter so the head-of-customer indicator can show a short
## "#3" instead of the 18-digit `get_instance_id()`. Reset by tests via
## `reset_debug_id_counter()`.
static var _next_debug_id: int = 0

var profile: CustomerTypeDefinition = null
var current_state: State = State.ENTERING
var debug_id: int = -1
var patience_timer: float = 0.0
var browse_timer: float = 0.0
## Frame stagger offset assigned by CustomerSystem (0.0 to 1.0).
var stagger_offset: float = 0.0
## Per-frame timing for profiling (set each _physics_process).
var last_script_time_ms: float = 0.0
var last_nav_time_ms: float = 0.0
var last_anim_time_ms: float = 0.0

var _store_controller: StoreController = null
var _inventory_system: InventorySystem = null
var _budget_multiplier: float = 1.0
var _browse_min_multiplier: float = 1.0
var _initial_patience_seconds: float = 0.0
var _visited_slots: Array[Node] = []
var _desired_item: ItemInstance = null
var _desired_item_slot: Node = null
var _current_target_slot: Node = null
var _made_purchase: bool = false
## Set when transitioning to LEAVING; included in EventBus.customer_left (store NPCs).
var _leave_reason: StringName = &"patience_expired"
## True while the head-of-queue customer is parked at the register waiting for
## the player to ring them up (Day-1 manual checkout gate). While true,
## patience does not tick in `_process_purchasing` so a reasonably-paced
## first-time player can complete the sale without the customer abandoning.
## Set by `advance_to_register` based on the day and the first-sale flag.
var _awaiting_player_checkout: bool = false
var _exit_position: Vector3 = Vector3.ZERO
var _register_position: Vector3 = Vector3.ZERO
var _initialized: bool = false
var _time_paused: bool = false
var _nav_recalc_timer: float = 0.0
var _cached_preferred_slots: Array[Node] = []
var _preferred_slots_dirty: bool = true
var _nav_target_kind: StringName = &""
var _nav_target_started_msec: int = 0
var _nav_was_finished: bool = true
var _last_nav_progress_position: Vector3 = Vector3.ZERO
var _last_nav_progress_msec: int = 0
var _nav_stall_reported: bool = false
var _nav_timeout_reported: bool = false
var _register_arrival_reported: bool = false
var _despawn_metric_reported: bool = false
## Direct-movement fallback used when NavigationAgent3D / navmesh cannot resolve
## a path. Covers the BRAINDUMP Day-1 spawn → shelf → checkout → exit chain by
## driving move_and_slide toward the last target set by `_set_navigation_target`.
var _use_waypoint_fallback: bool = false
var _fallback_target: Vector3 = Vector3.ZERO
var _fallback_arrived: bool = true
var _state_cue: MeshInstance3D = null
var _patience_cue: MeshInstance3D = null
var _reaction_cue: MeshInstance3D = null
var _accent_primary: MeshInstance3D = null
var _accent_secondary: MeshInstance3D = null
var _held_item_state: StringName = HELD_ITEM_STATE_NONE
var _held_item_last_terminal_state: StringName = HELD_ITEM_STATE_NONE
var _held_item_kind: StringName = _HELD_ITEM_KIND_NONE
var _held_item_instance_id: String = ""
var _held_item_definition_id: String = ""
var _held_item_condition: String = ""
var _held_item_checkout_pose: bool = false
var _held_item_prop: Node3D = null

@onready var _navigation_agent: NavigationAgent3D = (
	get_node_or_null("NavigationAgent3D") as NavigationAgent3D
)
@onready var _body_mesh: MeshInstance3D = (
	get_node_or_null("BodyMesh") as MeshInstance3D
)
@onready var _head_mesh: MeshInstance3D = (
	get_node_or_null("HeadMesh") as MeshInstance3D
)
@onready var _animation_player: AnimationPlayer = (
	get_node_or_null("AnimationPlayer") as AnimationPlayer
)
@onready var _animator: CustomerAnimator = (
	get_node_or_null("CustomerAnimator") as CustomerAnimator
)
@onready var _state_indicator: Node3D = (
	get_node_or_null("CustomerStateIndicator") as Node3D
)


func _ready() -> void:
	_ensure_state_cue()
	refresh_visual_cues(false)
	_randomize_body_color()
	EventBus.speed_changed.connect(_on_speed_changed)
	if _navigation_agent != null:
		_navigation_agent.velocity_computed.connect(
			_on_velocity_computed
		)


## Sets up the customer with a profile, store, and inventory references.
func initialize(
	p_profile: CustomerTypeDefinition,
	store_controller: StoreController,
	inventory_system: InventorySystem,
	budget_multiplier: float = 1.0,
	browse_min_multiplier: float = 1.0,
) -> void:
	profile = p_profile
	_store_controller = store_controller
	_inventory_system = inventory_system
	_budget_multiplier = budget_multiplier
	_browse_min_multiplier = browse_min_multiplier
	if debug_id < 0:
		debug_id = _next_debug_id
		_next_debug_id += 1
	_initial_patience_seconds = p_profile.patience * 120.0
	patience_timer = _initial_patience_seconds
	_reset_browse_timer()
	_set_state(State.ENTERING)
	_nav_recalc_timer = stagger_offset * NAV_RECALC_INTERVAL
	_preferred_slots_dirty = true
	_cached_preferred_slots.clear()
	_visited_slots.clear()
	_desired_item = null
	_desired_item_slot = null
	_current_target_slot = null
	_made_purchase = false
	clear_held_item_prop(&"initialize")
	_reset_navigation_metrics()
	_leave_reason = &"patience_expired"
	_cache_navigation_targets()
	_detect_navmesh_or_fallback()
	_navigate_to_random_shelf()
	if _animator != null:
		_animator.initialize(_animation_player)
		_animator.play_for_state(State.ENTERING)
	refresh_visual_cues(true)
	if _state_indicator:
		_state_indicator.initialize(self)
	_initialized = true


func _physics_process(delta: float) -> void:
	if not _initialized or _time_paused:
		return
	var t0: int = Time.get_ticks_usec()
	match current_state:
		State.ENTERING:
			_process_entering()
		State.BROWSING:
			_process_browsing(delta)
		State.DECIDING:
			_process_deciding()
		State.PURCHASING:
			_process_purchasing(delta)
		State.WAITING_IN_QUEUE:
			_process_waiting_in_queue(delta)
		State.LEAVING:
			_process_leaving()
	var t1: int = Time.get_ticks_usec()
	_move_along_path(delta)
	_update_navigation_metrics()
	var t2: int = Time.get_ticks_usec()
	last_script_time_ms = float(t1 - t0) / 1000.0
	last_nav_time_ms = float(t2 - t1) / 1000.0
	# Animation cost is driven by AnimationPlayer internally per frame;
	# approximate from the animation update call inside _move_along_path.
	last_anim_time_ms = last_nav_time_ms * 0.15


## Resets the static debug-id counter; intended for tests so labels are
## deterministic across runs.
static func reset_debug_id_counter() -> void:
	_next_debug_id = 0


## Returns the `State` enum key as a String for the given int, or "" when
## `state` is out of range. Single canonical lookup shared by debug consumers
## (`EventLog`, `CustomerStateIndicator`) so the index→name mapping cannot
## drift if a future enum reorder lands.
static func state_name(state: int) -> String:
	var keys: Array = State.keys()
	if state >= 0 and state < keys.size():
		return String(keys[state])
	return ""


## Returns the in-world non-text cue color for a customer FSM state.
static func state_cue_color(state: int) -> Color:
	match state:
		State.BROWSING:
			return STATE_CUE_BROWSE
		State.WAITING_IN_QUEUE:
			return STATE_CUE_QUEUE
		State.PURCHASING:
			return STATE_CUE_REGISTER
		State.LEAVING:
			return STATE_CUE_LEAVING
	return STATE_CUE_NEUTRAL


## Returns the production visual state, profile, patience, and reaction cues.
func get_visual_snapshot() -> Dictionary:
	var profile_id: String = CustomerVisualProfileScript.profile_id(profile)
	var archetype_id: StringName = CustomerVisualProfileScript.archetype_id(profile)
	var accent: Dictionary = CustomerVisualProfileScript.accent_for(profile_id, archetype_id)
	var held_snapshot: Dictionary = get_held_item_snapshot()
	var reaction_intent: StringName = CustomerVisualProfileScript.reaction_intent_for(
		_leave_reason,
		_held_item_state,
		StringName(str(held_snapshot.get("last_terminal_state", HELD_ITEM_STATE_NONE)))
	)
	var visual_state: StringName = _visual_state_for_current_customer(reaction_intent)
	return {
		"fsm_state": current_state,
		"fsm_state_name": state_name(current_state),
		"visual_state": visual_state,
		"visual_flags": _visual_flags_for_current_customer(visual_state),
		"profile_id": profile_id,
		"profile_name": profile.name if profile != null else "",
		"archetype_id": archetype_id,
		"accent_key": accent.get("key", &"casual_shopper"),
		"accent_shape": accent.get("shape", &"soft_pin"),
		"desired_item_present": _desired_item != null,
		"desired_item_instance_id": _desired_item.instance_id if _desired_item != null else "",
		"desired_item_definition_id": _desired_item_definition_id(),
		"queue_ready": current_state == State.WAITING_IN_QUEUE,
		"counter_ready": _awaiting_player_checkout or is_at_register(),
		"awaiting_player_checkout": _awaiting_player_checkout,
		"at_register": is_at_register(),
		"patience_remaining": maxf(patience_timer, 0.0),
		"patience_ratio": _patience_ratio(),
		"leave_reason": _leave_reason,
		"held_item_state": _held_item_state,
		"held_item_last_terminal_state": held_snapshot.get("last_terminal_state", HELD_ITEM_STATE_NONE),
		"reaction_intent": reaction_intent,
		"animator_intent": CustomerVisualProfileScript.intent_for_visual_state(
			visual_state,
			reaction_intent
		),
	}


## Refreshes non-debug in-world meshes and optional animator intent playback.
func refresh_visual_cues(update_animator: bool = true) -> void:
	var snapshot: Dictionary = get_visual_snapshot()
	_update_visual_state_cue(snapshot)
	_update_patience_cue(snapshot)
	_update_archetype_accent(snapshot)
	_update_reaction_cue(snapshot)
	if update_animator and _animator != null:
		_animator.play_for_visual_snapshot(snapshot)


## Returns the item the customer wants to buy, or null.
func get_desired_item() -> ItemInstance:
	return _desired_item


## Returns the shelf slot holding the desired item, or null.
func get_desired_item_slot() -> Node:
	return _desired_item_slot


## Reason code for EventBus.customer_left when this NPC despawns (see _leave_reason).
func get_leave_reason() -> StringName:
	return _leave_reason


## Called by CheckoutSystem when checkout completes (accept or decline).
func complete_purchase(sold: bool = true) -> void:
	_awaiting_player_checkout = false
	_made_purchase = sold
	_despawn_metric_reported = false
	if sold:
		_finish_held_item_prop(HELD_ITEM_STATE_SELECTED_SOLD)
	else:
		_finish_held_item_prop(HELD_ITEM_STATE_SELECTED_ABANDONED)
	_desired_item = null
	_desired_item_slot = null
	_leave_reason = &"purchase_complete" if sold else &"sale_declined"
	refresh_visual_cues(false)
	_transition_to(State.LEAVING)


## Called by RegisterQueue to place this customer in a queue position.
func enter_queue(queue_position: Vector3) -> void:
	_set_state(State.WAITING_IN_QUEUE)
	set_held_item_checkout_pose(false)
	if _animator != null:
		_animator.play_for_state(State.WAITING_IN_QUEUE)
	refresh_visual_cues(true)
	_register_arrival_reported = false
	_set_navigation_target(queue_position, &"queue_slot")


## Called by RegisterQueue when this customer advances to register.
##
## Sets `_awaiting_player_checkout` while the BRAINDUMP Day-1 manual-checkout
## gate is active (Day 1, before the first sale completes). The gate pauses
## patience in `_process_purchasing` until the player rings up the customer at
## the register. After the first sale closes, `first_sale_complete` is set
## and subsequent customers (Day 1 second customer onward, Day 2+) reach the
## register without the gate engaged.
func advance_to_register() -> void:
	_set_state(State.PURCHASING)
	set_held_item_checkout_pose(true)
	if _animator != null:
		_animator.play_for_state(State.PURCHASING)
	refresh_visual_cues(true)
	_register_arrival_reported = false
	_set_navigation_target(_register_position, &"register")
	_awaiting_player_checkout = _is_first_sale_guarantee_active()


## Returns true while the player must press E at the register to ring up
## this customer (Day-1 first-sale manual-checkout gate).
func is_awaiting_player_checkout() -> bool:
	return _awaiting_player_checkout


## Returns true once the customer has parked at the register (navigation
## finished while in PURCHASING). Exposed so the RegisterInteractable can
## decide when to surface the "Press E to ring up" prompt without poking the
## private `_is_navigation_finished` helper.
func is_at_register() -> bool:
	return current_state == State.PURCHASING and _is_navigation_finished()


## Called by CheckoutSystem when the queue is full.
func reject_from_queue() -> void:
	_leave_with(&"patience_expired")


## Called by QueueSystem when queued patience expires.
func abandon_queue() -> void:
	_leave_with(&"queue_abandoned")


## Attaches or updates the selected item prop owned by this customer.
func set_held_selected_item(
	item: ItemInstance, source_slot: Node = null
) -> void:
	if item == null or item.definition == null:
		clear_held_item_prop(&"missing_selected_item")
		return
	_desired_item = item
	if source_slot != null:
		_desired_item_slot = source_slot
	var visual_data: Dictionary = ProductVisualFactoryScript.visual_data_from_item(item)
	_set_held_item_prop(
		_HELD_ITEM_KIND_SELECTED,
		String(item.instance_id),
		String(item.definition.id),
		item.condition,
		visual_data,
	)
	_refresh_held_item_state_for_pose()


## Attaches a scripted returned item prop to the customer.
func set_held_returned_item(item_id: String, condition: StringName = &"used") -> void:
	if item_id.strip_edges().is_empty():
		clear_held_item_prop(&"missing_returned_item")
		return
	_set_held_item_prop(
		_HELD_ITEM_KIND_RETURNED,
		"",
		item_id,
		String(condition),
		_visual_data_for_definition_id(item_id, condition),
	)
	_held_item_checkout_pose = false
	_set_held_item_state(HELD_ITEM_STATE_RETURNED_CARRIED)


## Attaches a scripted trade-in prop in its counter presentation pose.
func set_held_trade_in_item(item_id: String, condition: StringName = &"used") -> void:
	if item_id.strip_edges().is_empty():
		clear_held_item_prop(&"missing_trade_in_item")
		return
	_set_held_item_prop(
		_HELD_ITEM_KIND_TRADE_IN,
		"",
		item_id,
		String(condition),
		_visual_data_for_definition_id(item_id, condition),
	)
	_held_item_checkout_pose = true
	_set_held_item_state(HELD_ITEM_STATE_TRADE_IN_PRESENTED)


## Changes the carried item's queue/checkout pose without replacing the item.
func set_held_item_checkout_pose(enabled: bool) -> void:
	_held_item_checkout_pose = enabled
	_refresh_held_item_state_for_pose()


## Keeps a refused return visible until the customer despawns.
func mark_held_return_refused() -> void:
	if _held_item_kind != _HELD_ITEM_KIND_RETURNED:
		return
	_set_held_item_state(HELD_ITEM_STATE_RETURNED_REFUSED)
	_apply_held_item_transform()
	refresh_visual_cues(true)


## Clears the held prop and records the terminal state for tests/debug displays.
func clear_held_item_prop(reason: StringName = &"") -> void:
	if (
		_held_item_kind == _HELD_ITEM_KIND_SELECTED
		and _held_item_state != HELD_ITEM_STATE_NONE
		and reason != &"initialize"
	):
		_held_item_last_terminal_state = HELD_ITEM_STATE_SELECTED_ABANDONED
	_remove_held_item_prop()
	_held_item_state = HELD_ITEM_STATE_NONE
	_held_item_kind = _HELD_ITEM_KIND_NONE
	_held_item_instance_id = ""
	_held_item_definition_id = ""
	_held_item_condition = ""
	_held_item_checkout_pose = false


## Returns the active held-prop state.
func get_held_item_state() -> StringName:
	return _held_item_state


## Returns the selected inventory instance id currently represented by the prop.
func get_held_item_instance_id() -> String:
	return _held_item_instance_id


## Returns a debug/test snapshot of the held-item visual state.
func get_held_item_snapshot() -> Dictionary:
	return {
		"state": _held_item_state,
		"last_terminal_state": _held_item_last_terminal_state,
		"kind": _held_item_kind,
		"instance_id": _held_item_instance_id,
		"definition_id": _held_item_definition_id,
		"condition": _held_item_condition,
		"has_prop": _held_item_prop != null and is_instance_valid(_held_item_prop),
		"checkout_pose": _held_item_checkout_pose,
	}


func _process_entering() -> void:
	if _is_navigation_finished():
		_transition_to(State.BROWSING)


func _process_browsing(delta: float) -> void:
	patience_timer -= delta
	if patience_timer <= 0.0:
		_transition_to_deciding_or_leaving()
		return
	if not _is_navigation_finished():
		return
	browse_timer -= delta
	if browse_timer > 0.0:
		return
	_evaluate_current_shelf()
	_reset_browse_timer()
	if GameRandom.chance(
		RandomStreamIds.CUSTOMER_BROWSE, MOVE_TO_NEXT_SHELF_CHANCE
	):
		if _navigate_to_random_shelf():
			return
	if _desired_item:
		_transition_to(State.DECIDING)
		return
	if not _navigate_to_random_shelf():
		_leave_with(&"no_matching_item")


func _process_deciding() -> void:
	if not _desired_item:
		_leave_with(&"no_matching_item")
		return
	var willing_to_pay: float = _get_willingness_to_pay()
	var item_price: float = _desired_item.player_set_price
	if item_price <= 0.0:
		item_price = _desired_item.get_current_value()
	if item_price > willing_to_pay:
		_leave_with(&"price_too_high")
		return
	if _is_first_sale_guarantee_active():
		if GameRandom.chance(
			RandomStreamIds.CUSTOMER_PURCHASE,
			Constants.DAY1_PURCHASE_PROBABILITY
		):
			_transition_to(State.PURCHASING)
		else:
			_leave_with(&"no_matching_item")
		return
	var match_quality: float = _calculate_match_quality(_desired_item)
	var buy_chance: float = profile.purchase_probability_base * match_quality
	if _desired_item.tested:
		if GameRandom.chance(
			RandomStreamIds.CUSTOMER_PURCHASE, DISAPPOINTED_CHANCE
		):
			_leave_with(&"no_matching_item")
			return
		buy_chance *= (1.0 + TESTED_BONUS)
	if not GameRandom.chance(RandomStreamIds.CUSTOMER_PURCHASE, buy_chance):
		_leave_with(&"no_matching_item")
		return
	_transition_to(State.PURCHASING)


# The Day 1 tutorial loop must basically guarantee the first sale (BRAINDUMP
# Priority 6). The price ceiling above still applies — an absurd markup loses
# the sale — but the normal profile / match-quality / tested / demo / rental
# multipliers are bypassed so the player isn't randomly punished by a 0.7-base
# customer rolling against a low match score on the very first transaction.
func _is_first_sale_guarantee_active() -> bool:
	if GameManager.get_current_day() != 1:
		return false
	return not GameState.get_flag(&"first_sale_complete")


func _process_purchasing(delta: float) -> void:
	if not _is_navigation_finished():
		return
	_emit_register_arrival_once()
	# BRAINDUMP Day-1 manual checkout: while waiting on the player's E-press,
	# patience does not tick. The gate is cleared in `complete_purchase` /
	# `_leave_with`, so a customer who never gets rung up still leaves on the
	# next state transition (e.g. forced exit on day close).
	if _awaiting_player_checkout:
		return
	patience_timer -= delta
	if patience_timer <= 0.0:
		_leave_with(&"patience_expired")


func _process_waiting_in_queue(delta: float) -> void:
	# Day-1 queue patience scaling: while the player is learning the manual
	# checkout, head-of-queue dwell time can stretch beyond the default
	# patience window. Slowing the queue tick keeps the second/third customer
	# from abandoning before the player rings up the first sale.
	var tick_scale: float = (
		DAY1_QUEUE_PATIENCE_TICK_SCALE
		if _is_first_sale_guarantee_active()
		else 1.0
	)
	patience_timer -= delta * tick_scale
	if patience_timer <= 0.0:
		_leave_with(&"patience_expired")


func _process_leaving() -> void:
	if _is_navigation_finished():
		if _held_item_state == HELD_ITEM_STATE_RETURNED_REFUSED:
			_held_item_last_terminal_state = HELD_ITEM_STATE_RETURNED_REFUSED
		_remove_held_item_prop()
		_held_item_state = HELD_ITEM_STATE_NONE
		_held_item_kind = _HELD_ITEM_KIND_NONE
		if not _despawn_metric_reported:
			_despawn_metric_reported = true
			EventBus.customer_despawn_requested.emit(self)
		despawn_requested.emit(self)


func _transition_to(new_state: State) -> void:
	_set_state(new_state)
	if new_state == State.LEAVING and _animator != null:
		_animator.set_satisfied(_made_purchase)
	if _animator != null:
		_animator.play_for_state(new_state)
	refresh_visual_cues(true)
	match new_state:
		State.PURCHASING:
			if _desired_item != null:
				set_held_selected_item(_desired_item, _desired_item_slot)
			_navigate_to_register()
			var data: Dictionary = _build_customer_data()
			EventBus.customer_ready_to_purchase.emit(data)
		State.LEAVING:
			_navigate_to_exit()


## Single write site for FSM state. Logs every transition in debug builds so the
## customer loop is observable without a UI change (per BRAINDUMP Priority 14).
## §F-106 — `OS.is_debug_build()` gate is the standard production-noise floor:
## release builds skip the print entirely (no string formatting / no IO), so
## the diagnostic carries zero cost in shipped builds. Same gate as §F-108
## interaction-ray telemetry and §F-58 retro_games F3 toggle.
func _set_state(new_state: State) -> void:
	var old_state: State = current_state
	current_state = new_state
	_update_state_cue(new_state)
	refresh_visual_cues(false)
	if OS.is_debug_build():
		print("[Customer %d] %s → %s" % [
			get_instance_id(),
			State.keys()[old_state],
			State.keys()[new_state],
		])
	EventBus.customer_state_changed.emit(self, new_state)


func _ensure_state_cue() -> MeshInstance3D:
	if _state_cue != null and is_instance_valid(_state_cue):
		return _state_cue
	if _body_mesh == null:
		_body_mesh = get_node_or_null("BodyMesh") as MeshInstance3D
	if _body_mesh == null:
		return null
	var existing: MeshInstance3D = (
		_body_mesh.get_node_or_null(NodePath(STATE_CUE_NAME)) as MeshInstance3D
	)
	if existing != null:
		_state_cue = existing
	else:
		_state_cue = MeshInstance3D.new()
		_state_cue.name = STATE_CUE_NAME
		var mesh := BoxMesh.new()
		mesh.size = STATE_CUE_SIZE
		_state_cue.mesh = mesh
		_body_mesh.add_child(_state_cue)
	_state_cue.position = Vector3(0.0, 0.24, 0.135)
	_state_cue.rotation_degrees = Vector3.ZERO
	return _state_cue


func _update_state_cue(state: State) -> void:
	var cue: MeshInstance3D = _ensure_state_cue()
	if cue == null:
		return
	var material := _cue_material(cue)
	material.albedo_color = state_cue_color(state)
	material.roughness = 0.72
	cue.visible = true


func _update_visual_state_cue(snapshot: Dictionary) -> void:
	var cue: MeshInstance3D = _ensure_state_cue()
	if cue == null:
		return
	var visual_state: StringName = StringName(str(snapshot.get("visual_state", "")))
	var material := _cue_material(cue)
	material.albedo_color = state_cue_color(current_state)
	material.emission_enabled = true
	material.emission = _visual_state_color(visual_state)
	material.emission_energy_multiplier = 0.24
	material.roughness = 0.72
	cue.position = _visual_state_cue_position(visual_state)
	cue.scale = _visual_state_cue_scale(visual_state)
	cue.set_meta("visual_state", String(visual_state))
	cue.visible = true


func _ensure_patience_cue() -> MeshInstance3D:
	if _patience_cue != null and is_instance_valid(_patience_cue):
		return _patience_cue
	if _body_mesh == null:
		_body_mesh = get_node_or_null("BodyMesh") as MeshInstance3D
	if _body_mesh == null:
		return null
	var existing: MeshInstance3D = (
		_body_mesh.get_node_or_null("PatienceCue") as MeshInstance3D
	)
	if existing != null:
		_patience_cue = existing
	else:
		_patience_cue = MeshInstance3D.new()
		_patience_cue.name = "PatienceCue"
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.20, 0.024, 0.018)
		_patience_cue.mesh = mesh
		_body_mesh.add_child(_patience_cue)
	_patience_cue.position = Vector3(0.0, 0.30, 0.135)
	return _patience_cue


func _update_patience_cue(snapshot: Dictionary) -> void:
	var cue: MeshInstance3D = _ensure_patience_cue()
	if cue == null:
		return
	var ratio: float = float(snapshot.get("patience_ratio", 0.0))
	cue.scale = Vector3(maxf(ratio, 0.08), 1.0, 1.0)
	var material := _cue_material(cue)
	if ratio < 0.25:
		var angry_accent: Dictionary = CustomerVisualProfileScript.ACCENTS.get(
			&"angry_return_customer",
			CustomerVisualProfileScript.ACCENT_DEFAULT
		) as Dictionary
		material.albedo_color = angry_accent.get("primary_color", STATE_CUE_LEAVING) as Color
	elif ratio < 0.55:
		material.albedo_color = STATE_CUE_QUEUE
	else:
		material.albedo_color = STATE_CUE_REGISTER
	material.emission_enabled = ratio < 0.25
	material.emission = material.albedo_color
	material.emission_energy_multiplier = 0.35
	material.roughness = 0.74
	cue.set_meta("patience_ratio", ratio)
	cue.visible = true


func _ensure_reaction_cue() -> MeshInstance3D:
	if _reaction_cue != null and is_instance_valid(_reaction_cue):
		return _reaction_cue
	if _head_mesh == null:
		_head_mesh = get_node_or_null("HeadMesh") as MeshInstance3D
	if _head_mesh == null:
		return null
	var existing: MeshInstance3D = (
		_head_mesh.get_node_or_null("ReactionCue") as MeshInstance3D
	)
	if existing != null:
		_reaction_cue = existing
	else:
		_reaction_cue = MeshInstance3D.new()
		_reaction_cue.name = "ReactionCue"
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.16, 0.035, 0.06)
		_reaction_cue.mesh = mesh
		_head_mesh.add_child(_reaction_cue)
	_reaction_cue.position = Vector3(0.0, 0.29, 0.04)
	return _reaction_cue


func _update_reaction_cue(snapshot: Dictionary) -> void:
	var cue: MeshInstance3D = _ensure_reaction_cue()
	if cue == null:
		return
	var reaction_intent: StringName = StringName(str(snapshot.get("reaction_intent", "")))
	if reaction_intent == &"":
		cue.visible = false
		return
	var material := _cue_material(cue)
	material.albedo_color = _reaction_color(reaction_intent)
	material.emission_enabled = true
	material.emission = material.albedo_color
	material.emission_energy_multiplier = 0.45
	material.roughness = 0.66
	cue.rotation_degrees = _reaction_rotation(reaction_intent)
	cue.set_meta("reaction_intent", String(reaction_intent))
	cue.visible = true


func _ensure_accent_part(part_name: String, parent: Node3D) -> MeshInstance3D:
	var existing: MeshInstance3D = parent.get_node_or_null(part_name) as MeshInstance3D
	if existing != null:
		return existing
	var part := MeshInstance3D.new()
	part.name = part_name
	var mesh := BoxMesh.new()
	part.mesh = mesh
	parent.add_child(part)
	return part


func _update_archetype_accent(snapshot: Dictionary) -> void:
	if _body_mesh == null:
		_body_mesh = get_node_or_null("BodyMesh") as MeshInstance3D
	if _body_mesh == null:
		return
	_accent_primary = _ensure_accent_part("ArchetypeAccentPrimary", _body_mesh)
	_accent_secondary = _ensure_accent_part("ArchetypeAccentSecondary", _body_mesh)
	var accent: Dictionary = CustomerVisualProfileScript.accent_for(
		str(snapshot.get("profile_id", "")),
		StringName(str(snapshot.get("archetype_id", "")))
	)
	_configure_accent_mesh(_accent_primary, accent, true)
	_configure_accent_mesh(_accent_secondary, accent, false)


func _configure_accent_mesh(
	part: MeshInstance3D, accent: Dictionary, primary: bool
) -> void:
	var shape: StringName = StringName(str(accent.get("shape", &"soft_pin")))
	var mesh := _box_mesh(part)
	mesh.size = _accent_size(shape, primary)
	part.position = _accent_position(shape, primary)
	part.rotation_degrees = _accent_rotation(shape, primary)
	var material := _cue_material(part)
	var color_value: Variant = accent.get("primary_color", STATE_CUE_BROWSE)
	if not primary:
		color_value = accent.get("secondary_color", STATE_CUE_NEUTRAL)
	material.albedo_color = color_value as Color
	material.emission_enabled = shape == &"neon_cap" or shape == &"gold_lapel"
	material.emission = material.albedo_color
	material.emission_energy_multiplier = 0.28
	material.roughness = 0.70
	part.set_meta("accent_key", String(accent.get("key", &"casual_shopper")))
	part.set_meta("accent_shape", String(shape))
	part.visible = true


func _box_mesh(part: MeshInstance3D) -> BoxMesh:
	var mesh: BoxMesh = part.mesh as BoxMesh
	if mesh == null:
		mesh = BoxMesh.new()
		part.mesh = mesh
	return mesh


func _cue_material(part: MeshInstance3D) -> StandardMaterial3D:
	var material: StandardMaterial3D = part.material_override as StandardMaterial3D
	if material == null:
		material = StandardMaterial3D.new()
		part.material_override = material
	return material


func _visual_state_for_current_customer(reaction_intent: StringName) -> StringName:
	if current_state == State.LEAVING:
		if (
			reaction_intent == CustomerVisualProfileScript.INTENT_SALE
			or reaction_intent == CustomerVisualProfileScript.INTENT_CLEAN_EXCHANGE
			or reaction_intent == CustomerVisualProfileScript.INTENT_PAYOUT_TRADE_IN
			or reaction_intent == CustomerVisualProfileScript.INTENT_ACCEPTED_TRADE_IN
		):
			return CustomerVisualProfileScript.VISUAL_STATE_LEAVING_HAPPY
		return CustomerVisualProfileScript.VISUAL_STATE_LEAVING_UPSET
	if _patience_ratio() < 0.22 and current_state in [
		State.BROWSING,
		State.WAITING_IN_QUEUE,
		State.PURCHASING,
	]:
		return CustomerVisualProfileScript.VISUAL_STATE_ANNOYED
	match current_state:
		State.BROWSING:
			if _desired_item != null:
				return CustomerVisualProfileScript.VISUAL_STATE_NEEDS_HELP
			return CustomerVisualProfileScript.VISUAL_STATE_BROWSING
		State.DECIDING:
			return CustomerVisualProfileScript.VISUAL_STATE_CONSIDERING
		State.WAITING_IN_QUEUE:
			return CustomerVisualProfileScript.VISUAL_STATE_QUEUED
		State.PURCHASING:
			if _awaiting_player_checkout or is_at_register():
				return CustomerVisualProfileScript.VISUAL_STATE_COUNTER
			return CustomerVisualProfileScript.VISUAL_STATE_READY_TO_BUY
	return CustomerVisualProfileScript.VISUAL_STATE_BROWSING


func _visual_flags_for_current_customer(visual_state: StringName) -> Dictionary:
	return {
		"browsing": visual_state == CustomerVisualProfileScript.VISUAL_STATE_BROWSING,
		"needs_help": visual_state == CustomerVisualProfileScript.VISUAL_STATE_NEEDS_HELP,
		"queued": current_state == State.WAITING_IN_QUEUE,
		"considering": current_state == State.DECIDING,
		"annoyed": visual_state == CustomerVisualProfileScript.VISUAL_STATE_ANNOYED,
		"ready_to_buy": (
			current_state == State.PURCHASING
			and visual_state != CustomerVisualProfileScript.VISUAL_STATE_COUNTER
		),
		"counter": visual_state == CustomerVisualProfileScript.VISUAL_STATE_COUNTER,
		"leaving_happy": visual_state == CustomerVisualProfileScript.VISUAL_STATE_LEAVING_HAPPY,
		"leaving_upset": visual_state == CustomerVisualProfileScript.VISUAL_STATE_LEAVING_UPSET,
	}


func _patience_ratio() -> float:
	var max_patience: float = _initial_patience_seconds
	if max_patience <= 0.0 and profile != null:
		max_patience = profile.patience * 120.0
	if max_patience <= 0.0:
		return 0.0
	return clampf(patience_timer / max_patience, 0.0, 1.0)


func _desired_item_definition_id() -> String:
	if _desired_item == null or _desired_item.definition == null:
		return ""
	return String(_desired_item.definition.id)


func _visual_state_color(visual_state: StringName) -> Color:
	match visual_state:
		CustomerVisualProfileScript.VISUAL_STATE_NEEDS_HELP:
			return Color(0.62, 0.82, 1.0, 1.0)
		CustomerVisualProfileScript.VISUAL_STATE_QUEUED:
			return STATE_CUE_QUEUE
		CustomerVisualProfileScript.VISUAL_STATE_CONSIDERING:
			return Color(0.82, 0.62, 0.95, 1.0)
		CustomerVisualProfileScript.VISUAL_STATE_ANNOYED:
			return STATE_CUE_LEAVING
		CustomerVisualProfileScript.VISUAL_STATE_READY_TO_BUY:
			return Color(0.56, 0.88, 0.46, 1.0)
		CustomerVisualProfileScript.VISUAL_STATE_COUNTER:
			return STATE_CUE_REGISTER
		CustomerVisualProfileScript.VISUAL_STATE_LEAVING_HAPPY:
			return Color(0.50, 0.90, 0.40, 1.0)
		CustomerVisualProfileScript.VISUAL_STATE_LEAVING_UPSET:
			return STATE_CUE_LEAVING
	return STATE_CUE_BROWSE


func _visual_state_cue_position(visual_state: StringName) -> Vector3:
	match visual_state:
		CustomerVisualProfileScript.VISUAL_STATE_COUNTER:
			return Vector3(0.0, 0.33, 0.145)
		CustomerVisualProfileScript.VISUAL_STATE_ANNOYED:
			return Vector3(0.0, 0.26, 0.145)
		CustomerVisualProfileScript.VISUAL_STATE_LEAVING_HAPPY, CustomerVisualProfileScript.VISUAL_STATE_LEAVING_UPSET:
			return Vector3(0.0, 0.22, 0.145)
	return Vector3(0.0, 0.24, 0.135)


func _visual_state_cue_scale(visual_state: StringName) -> Vector3:
	match visual_state:
		CustomerVisualProfileScript.VISUAL_STATE_NEEDS_HELP:
			return Vector3(0.72, 1.35, 1.0)
		CustomerVisualProfileScript.VISUAL_STATE_CONSIDERING:
			return Vector3(1.15, 0.85, 1.0)
		CustomerVisualProfileScript.VISUAL_STATE_READY_TO_BUY:
			return Vector3(1.25, 1.0, 1.0)
		CustomerVisualProfileScript.VISUAL_STATE_COUNTER:
			return Vector3(1.35, 1.2, 1.0)
		CustomerVisualProfileScript.VISUAL_STATE_ANNOYED:
			return Vector3(0.95, 1.45, 1.0)
	return Vector3.ONE


func _reaction_color(reaction_intent: StringName) -> Color:
	match reaction_intent:
		CustomerVisualProfileScript.INTENT_SALE, CustomerVisualProfileScript.INTENT_CLEAN_EXCHANGE:
			return Color(0.46, 0.92, 0.38, 1.0)
		CustomerVisualProfileScript.INTENT_BUNDLE_ACCEPTED:
			return Color(0.98, 0.72, 0.22, 1.0)
		CustomerVisualProfileScript.INTENT_TRADE_IN, CustomerVisualProfileScript.INTENT_ACCEPTED_TRADE_IN:
			return Color(0.38, 0.62, 0.90, 1.0)
		CustomerVisualProfileScript.INTENT_PAYOUT_TRADE_IN:
			return Color(0.66, 0.52, 0.96, 1.0)
		CustomerVisualProfileScript.INTENT_PRICE_SHOCK, CustomerVisualProfileScript.INTENT_REFUSED_RETURN:
			return Color(0.92, 0.30, 0.18, 1.0)
		CustomerVisualProfileScript.INTENT_NO_SALE, CustomerVisualProfileScript.INTENT_BUNDLE_REJECTED:
			return Color(0.90, 0.58, 0.24, 1.0)
	return STATE_CUE_LEAVING


func _reaction_rotation(reaction_intent: StringName) -> Vector3:
	match reaction_intent:
		CustomerVisualProfileScript.INTENT_PRICE_SHOCK, CustomerVisualProfileScript.INTENT_REFUSED_RETURN:
			return Vector3(0.0, 0.0, -16.0)
		CustomerVisualProfileScript.INTENT_NO_SALE, CustomerVisualProfileScript.INTENT_BUNDLE_REJECTED:
			return Vector3(0.0, 0.0, 12.0)
	return Vector3.ZERO


func _accent_size(shape: StringName, primary: bool) -> Vector3:
	match shape:
		&"catalog_card":
			return Vector3(0.13, 0.09, 0.024) if primary else Vector3(0.06, 0.09, 0.026)
		&"question_tab":
			return Vector3(0.12, 0.12, 0.025) if primary else Vector3(0.04, 0.16, 0.026)
		&"coupon_strip":
			return Vector3(0.18, 0.042, 0.024) if primary else Vector3(0.045, 0.11, 0.026)
		&"neon_cap":
			return Vector3(0.19, 0.036, 0.028) if primary else Vector3(0.08, 0.05, 0.03)
		&"pennant":
			return Vector3(0.16, 0.055, 0.024) if primary else Vector3(0.055, 0.14, 0.026)
		&"price_tag":
			return Vector3(0.11, 0.14, 0.024) if primary else Vector3(0.08, 0.035, 0.026)
		&"return_slash":
			return Vector3(0.16, 0.045, 0.024) if primary else Vector3(0.04, 0.15, 0.026)
		&"low_badge":
			return Vector3(0.09, 0.08, 0.024) if primary else Vector3(0.13, 0.032, 0.026)
		&"gold_lapel":
			return Vector3(0.10, 0.12, 0.024) if primary else Vector3(0.07, 0.07, 0.026)
	return Vector3(0.11, 0.065, 0.024) if primary else Vector3(0.055, 0.055, 0.026)


func _accent_position(shape: StringName, primary: bool) -> Vector3:
	if shape == &"neon_cap":
		return Vector3(0.0, 0.58, 0.135) if primary else Vector3(0.11, 0.50, 0.14)
	if shape == &"low_badge":
		return Vector3(-0.13, -0.08, 0.145) if primary else Vector3(0.12, -0.10, 0.145)
	return Vector3(-0.105, 0.12, 0.145) if primary else Vector3(0.115, 0.10, 0.146)


func _accent_rotation(shape: StringName, primary: bool) -> Vector3:
	match shape:
		&"coupon_strip":
			return Vector3(0.0, 0.0, -8.0 if primary else 8.0)
		&"pennant":
			return Vector3(0.0, 0.0, 12.0 if primary else -12.0)
		&"price_tag":
			return Vector3(0.0, 0.0, -10.0 if primary else 0.0)
		&"return_slash":
			return Vector3(0.0, 0.0, -28.0 if primary else 28.0)
		&"gold_lapel":
			return Vector3(0.0, 0.0, 18.0 if primary else -18.0)
	return Vector3.ZERO


func _transition_to_deciding_or_leaving() -> void:
	if _desired_item:
		_transition_to(State.DECIDING)
	else:
		_leave_with(&"patience_expired")


func _leave_with(reason: StringName) -> void:
	_awaiting_player_checkout = false
	_despawn_metric_reported = false
	if _held_item_state != HELD_ITEM_STATE_RETURNED_REFUSED:
		_finish_held_item_prop(HELD_ITEM_STATE_SELECTED_ABANDONED)
	_leave_reason = reason
	refresh_visual_cues(false)
	_transition_to(State.LEAVING)


func _set_held_item_prop(
	kind: StringName,
	instance_id: String,
	definition_id: String,
	condition: String,
	visual_data: Dictionary
) -> void:
	var same_prop: bool = (
		_held_item_prop != null
		and is_instance_valid(_held_item_prop)
		and _held_item_kind == kind
		and _held_item_instance_id == instance_id
		and _held_item_definition_id == definition_id
	)
	_held_item_kind = kind
	_held_item_instance_id = instance_id
	_held_item_definition_id = definition_id
	_held_item_condition = condition
	if same_prop:
		_apply_held_item_transform()
		return
	_remove_held_item_prop()
	_held_item_prop = Node3D.new()
	_held_item_prop.name = _HELD_ITEM_PROP_NAME
	_held_item_prop.set_meta("kind", kind)
	_held_item_prop.set_meta("instance_id", instance_id)
	_held_item_prop.set_meta("definition_id", definition_id)
	_held_item_prop.set_meta("condition", condition)
	var visual: Node3D = ProductVisualFactoryScript.create_visual_for_item(visual_data)
	if visual == null:
		visual = StoreVisualKitScript.instantiate(StoreVisualKitScript.GAME_CASE) as Node3D
	if visual == null:
		visual = _make_held_item_fallback_visual()
	if visual != null:
		visual.scale = _HELD_ITEM_PROP_SCALE
		_held_item_prop.add_child(visual)
	add_child(_held_item_prop)
	_apply_held_item_transform()


func _set_held_item_state(state: StringName) -> void:
	_held_item_state = state
	if _is_terminal_held_item_state(state):
		_held_item_last_terminal_state = state
	if _held_item_prop != null and is_instance_valid(_held_item_prop):
		_held_item_prop.set_meta("held_item_state", state)
	refresh_visual_cues(false)


func _refresh_held_item_state_for_pose() -> void:
	match _held_item_kind:
		_HELD_ITEM_KIND_SELECTED:
			if _held_item_checkout_pose:
				_set_held_item_state(HELD_ITEM_STATE_SELECTED_CHECKOUT)
			elif current_state == State.WAITING_IN_QUEUE:
				_set_held_item_state(HELD_ITEM_STATE_SELECTED_QUEUE)
			else:
				_set_held_item_state(HELD_ITEM_STATE_SELECTED_CARRIED)
		_HELD_ITEM_KIND_RETURNED:
			_set_held_item_state(
				HELD_ITEM_STATE_RETURNED_PRESENTED
				if _held_item_checkout_pose
				else HELD_ITEM_STATE_RETURNED_CARRIED
			)
		_HELD_ITEM_KIND_TRADE_IN:
			_set_held_item_state(HELD_ITEM_STATE_TRADE_IN_PRESENTED)
	_apply_held_item_transform()


func _finish_held_item_prop(terminal_state: StringName) -> void:
	if _held_item_kind == _HELD_ITEM_KIND_NONE:
		return
	if terminal_state == HELD_ITEM_STATE_RETURNED_REFUSED:
		mark_held_return_refused()
		return
	_set_held_item_state(terminal_state)
	_remove_held_item_prop()
	_held_item_state = HELD_ITEM_STATE_NONE
	_held_item_kind = _HELD_ITEM_KIND_NONE
	_held_item_instance_id = ""
	_held_item_definition_id = ""
	_held_item_condition = ""
	_held_item_checkout_pose = false


func _remove_held_item_prop() -> void:
	if _held_item_prop != null and is_instance_valid(_held_item_prop):
		if _held_item_prop.get_parent() != null:
			_held_item_prop.get_parent().remove_child(_held_item_prop)
		_held_item_prop.free()
	_held_item_prop = null
	var existing: Node = get_node_or_null(NodePath(String(_HELD_ITEM_PROP_NAME)))
	if existing != null:
		remove_child(existing)
		existing.free()


func _apply_held_item_transform() -> void:
	if _held_item_prop == null or not is_instance_valid(_held_item_prop):
		return
	if _held_item_state == HELD_ITEM_STATE_RETURNED_REFUSED:
		_held_item_prop.position = Vector3(0.24, 0.92, -0.12)
		_held_item_prop.rotation_degrees = Vector3(-10.0, -18.0, 2.0)
	elif _held_item_checkout_pose:
		_held_item_prop.position = Vector3(0.0, 0.94, -0.28)
		_held_item_prop.rotation_degrees = Vector3(-12.0, 0.0, 0.0)
	else:
		_held_item_prop.position = Vector3(0.28, 0.88, 0.05)
		_held_item_prop.rotation_degrees = Vector3(-8.0, -20.0, 5.0)


func _visual_data_for_definition_id(
	definition_id: String, condition: StringName
) -> Dictionary:
	return {
		"definition_id": definition_id,
		"display_name": ContentRegistry.get_display_name_or(
			StringName(definition_id),
			definition_id.capitalize(),
		),
		"category": "games",
		"condition": String(condition),
		"visual_presentation": "game_case",
	}


func _make_held_item_fallback_visual() -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.22, 0.032, 0.32)
	mesh_instance.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.84, 0.76, 0.58, 1.0)
	material.roughness = 0.75
	mesh_instance.material_override = material
	return mesh_instance


func _is_terminal_held_item_state(state: StringName) -> bool:
	return state in [
		HELD_ITEM_STATE_SELECTED_SOLD,
		HELD_ITEM_STATE_SELECTED_ABANDONED,
		HELD_ITEM_STATE_RETURNED_ACCEPTED,
		HELD_ITEM_STATE_RETURNED_REFUSED,
		HELD_ITEM_STATE_PAYOUT_RETURNED,
	]


func _move_along_path(delta: float) -> void:
	if _use_waypoint_fallback:
		_move_waypoint_fallback()
		return
	if _navigation_agent == null or _is_navigation_finished():
		velocity = Vector3.ZERO
		_update_animator_movement(velocity)
		return
	_nav_recalc_timer -= delta
	var next_pos: Vector3
	if _nav_recalc_timer <= 0.0:
		_nav_recalc_timer = NAV_RECALC_INTERVAL
		next_pos = _navigation_agent.get_next_path_position()
	else:
		# Between recalcs, continue toward current target
		next_pos = _navigation_agent.target_position
	var direction: Vector3 = next_pos - global_position
	direction.y = 0.0
	var dist_sq: float = direction.length_squared()
	if dist_sq < 0.01:
		velocity = Vector3.ZERO
		_update_animator_movement(velocity)
		return
	direction = direction.normalized()
	var desired: Vector3 = direction * MOVE_SPEED
	if _navigation_agent.avoidance_enabled:
		_navigation_agent.set_velocity(desired)
	else:
		velocity = desired
		move_and_slide()
	_update_animator_movement(velocity)


## Drives a customer through `_fallback_target` directly via move_and_slide,
## bypassing NavigationAgent3D when the navmesh is missing or cannot resolve a
## path. Each consecutive `_set_navigation_target` call advances the spawn →
## shelf → checkout → exit chain expected by the Day-1 vertical slice.
func _move_waypoint_fallback() -> void:
	if _fallback_arrived:
		velocity = Vector3.ZERO
		_update_animator_movement(velocity)
		return
	var to_target: Vector3 = _fallback_target - global_position
	to_target.y = 0.0
	var dist_sq: float = to_target.length_squared()
	if dist_sq < WAYPOINT_ARRIVAL_DIST_SQ:
		_fallback_arrived = true
		velocity = Vector3.ZERO
		_update_animator_movement(velocity)
		return
	velocity = to_target.normalized() * MOVE_SPEED
	move_and_slide()
	_update_animator_movement(velocity)


## Forces the customer onto the direct waypoint chain regardless of nav state.
## Call this when authoring a fixture without a navmesh, or when a runtime check
## proves the bake cannot reach the gameplay-critical targets.
func enable_waypoint_fallback() -> void:
	_use_waypoint_fallback = true
	_fallback_arrived = global_position.distance_squared_to(
		_fallback_target
	) < WAYPOINT_ARRIVAL_DIST_SQ


## Engages waypoint fallback when no NavigationAgent3D / NavigationRegion3D with
## a baked mesh is reachable from the current scene tree. Resolves the "navmesh
## absent or broken" gate from the BRAINDUMP Day-1 priority.
##
## §F-94 — Each fallback engagement emits a push_warning so a scene-wiring
## regression (missing NavigationAgent child, missing NavigationRegion sibling,
## empty navmesh after a bad bake) is visible in CI / dev console rather than
## silently degrading every customer in the store to direct-line movement.
## The warning is per-customer rather than once-per-scene because a partial
## regression (e.g. some customers fail to register an agent) would otherwise
## be hidden by the first emission.
func _detect_navmesh_or_fallback() -> void:
	if _navigation_agent == null:
		push_warning(
			(
				"Customer %d: NavigationAgent3D child missing; engaging "
				+ "direct-line waypoint fallback. Scene wiring regression "
				+ "(see §F-94)."
			)
			% get_instance_id()
		)
		enable_waypoint_fallback()
		_emit_navigation_mode_selected(false)
		return
	var region: NavigationRegion3D = _find_navigation_region()
	if region == null:
		push_warning(
			(
				"Customer %d: no NavigationRegion3D ancestor found; "
				+ "engaging direct-line waypoint fallback. Scene wiring "
				+ "regression (see §F-94)."
			)
			% get_instance_id()
		)
		enable_waypoint_fallback()
		_emit_navigation_mode_selected(false)
		return
	var nav_mesh: NavigationMesh = region.navigation_mesh
	if nav_mesh == null or nav_mesh.get_polygon_count() == 0:
		push_warning(
			(
				"Customer %d: NavigationRegion3D has %s; engaging "
				+ "direct-line waypoint fallback. Re-bake the navmesh "
				+ "(see §F-94)."
			)
			% [
				get_instance_id(),
				(
					"no NavigationMesh resource"
					if nav_mesh == null
					else "navmesh with 0 polygons"
				),
			]
		)
		enable_waypoint_fallback()
		_emit_navigation_mode_selected(false)
		return
	_emit_navigation_mode_selected(true)


func _emit_navigation_mode_selected(has_navigation_region: bool) -> void:
	EventBus.customer_navigation_mode_selected.emit({
		"customer_id": get_instance_id(),
		"mode": "waypoint_fallback" if _use_waypoint_fallback else "navigation_agent",
		"has_navigation_agent": _navigation_agent != null,
		"has_navigation_region": has_navigation_region,
	})


func _find_navigation_region() -> NavigationRegion3D:
	var node: Node = get_parent()
	while node != null:
		for child: Node in node.get_children():
			if child is NavigationRegion3D:
				return child as NavigationRegion3D
		node = node.get_parent()
	return null


func _cache_navigation_targets() -> void:
	if not _store_controller:
		return
	var entry: Area3D = _store_controller.get_entry_area()
	if entry:
		_exit_position = entry.global_position
	var register: Area3D = _store_controller.get_register_area()
	if register:
		_register_position = register.global_position


func _navigate_to_random_shelf() -> bool:
	if not _store_controller:
		return false
	var occupied: Array[Node] = _store_controller.get_occupied_slots()
	var unvisited: Array[Node] = []
	for slot: Node in occupied:
		var slot_3d: Node3D = slot as Node3D
		if slot_3d == null:
			continue
		if not CustomerNavConfig.is_customer_position_allowed(
			slot_3d.global_position
		):
			continue
		if slot not in _visited_slots:
			unvisited.append(slot)
	if unvisited.is_empty():
		return false
	var preferred: Array[Node] = _filter_preferred_slots(unvisited)
	var target_pool: Array[Node] = preferred if not preferred.is_empty() else unvisited
	var target_index: int = GameRandom.pick_index(
		RandomStreamIds.CUSTOMER_NAVIGATION, target_pool.size()
	)
	if target_index < 0:
		return false
	var target: Node = target_pool[target_index]
	_current_target_slot = target
	_visited_slots.append(target)
	var target_3d: Node3D = target as Node3D
	if target_3d:
		_set_navigation_target(target_3d.global_position, &"shelf")
	return true


func _navigate_to_register() -> void:
	_register_arrival_reported = false
	_set_navigation_target(_register_position, &"register")


func _navigate_to_exit() -> void:
	_set_navigation_target(_exit_position, &"exit")


func _evaluate_current_shelf() -> void:
	if not _current_target_slot or not _inventory_system:
		return
	_preferred_slots_dirty = true
	var slot_id: String = str(_current_target_slot.get("slot_id"))
	if slot_id.is_empty():
		return
	var location: String = "shelf:%s" % slot_id
	var items: Array[ItemInstance] = (
		_inventory_system.get_items_at_location(location)
	)
	# §F-86 — Pass 12: emits are guarded upstream by `_is_item_desirable`,
	# which rejects `item.definition == null` / null profile, so subscribers
	# (`AmbientMomentsSystem._on_customer_item_spotted`) can rely on a
	# fully-formed (Customer, ItemInstance) payload.
	for item: ItemInstance in items:
		if not _is_item_desirable(item):
			continue
		if not _desired_item:
			_desired_item = item
			_desired_item_slot = _current_target_slot
			EventBus.customer_item_spotted.emit(self, item)
		elif _score_item(item) > _score_item(_desired_item):
			_desired_item = item
			_desired_item_slot = _current_target_slot
			EventBus.customer_item_spotted.emit(self, item)


# gdlint:disable=max-returns
func _is_item_desirable(item: ItemInstance) -> bool:
	if not item.definition or not profile:
		return false
	var item_price: float = item.player_set_price
	if item_price <= 0.0:
		item_price = item.get_current_value()
	if item_price < profile.budget_range[0]:
		return false
	if item_price > profile.budget_range[1] * _budget_multiplier:
		return false
	if _is_bargain_only_buyer():
		var market_value: float = item.get_current_value()
		var ratio: float = profile.max_price_to_market_ratio
		if ratio >= 1.0:
			ratio = INVESTOR_MAX_MARKET_RATIO
		if market_value > 0.0 and item_price > market_value * ratio:
			return false
	var category_match: bool = _matches_categories(item)
	var tag_match: bool = _matches_tags(item)
	if not category_match and not tag_match:
		return GameRandom.chance(
			RandomStreamIds.CUSTOMER_PURCHASE, profile.impulse_buy_chance
		)
	return true


# gdlint:enable=max-returns
func _matches_categories(item: ItemInstance) -> bool:
	if profile.preferred_categories.is_empty():
		return true
	return item.definition.category in profile.preferred_categories


func _matches_tags(item: ItemInstance) -> bool:
	if profile.preferred_tags.is_empty():
		return true
	for tag: String in item.definition.tags:
		if tag in profile.preferred_tags:
			return true
	return false


func _score_item(item: ItemInstance) -> float:
	if not item.definition:
		return 0.0
	var score: float = item.get_current_value()
	if item.definition.category in profile.preferred_categories:
		score *= 1.5
	for tag: String in item.definition.tags:
		if tag in profile.preferred_tags:
			score *= 1.2
			break
	score *= _get_condition_score(item.condition)
	return score


func _get_willingness_to_pay() -> float:
	if not _desired_item or not profile:
		return 0.0
	var budget_max: float = profile.budget_range[1] * _budget_multiplier
	var item_value: float = _desired_item.get_current_value()
	# Lower sensitivity means willing to pay more above market value
	var tolerance: float = 2.0 - profile.price_sensitivity
	var max_acceptable: float = item_value * tolerance
	return minf(budget_max, max_acceptable)


func _is_bargain_only_buyer() -> bool:
	if not profile:
		return false
	return (
		"investor" in profile.id
		or "dealer" in profile.id
		or "reseller" in profile.id
	)


## Returns 0.5-1.5 based on how well item condition matches preference.
func _get_condition_score(item_condition: String) -> float:
	var pref_rank: int = CONDITION_RANKS.get(
		profile.condition_preference, 2
	)
	var item_rank: int = CONDITION_RANKS.get(item_condition, 2)
	var diff: int = item_rank - pref_rank
	if diff >= 0:
		return 1.0 + minf(diff * 0.1, 0.5)
	return maxf(0.5, 1.0 + diff * 0.2)


## Returns match quality 0.5-1.5 based on category, tag, and condition fit.
func _calculate_match_quality(item: ItemInstance) -> float:
	if not item.definition:
		return 0.5
	var quality: float = 1.0
	if _matches_categories(item):
		quality += 0.2
	if _matches_tags(item):
		quality += 0.15
	var cond_score: float = _get_condition_score(item.condition)
	quality *= cond_score
	return clampf(quality, 0.5, 1.5)


## Returns slots containing items matching preferred categories (cached).
func _filter_preferred_slots(slots: Array[Node]) -> Array[Node]:
	if profile.preferred_categories.is_empty() or not _inventory_system:
		return []
	var matched: Array[Node] = []
	if not _preferred_slots_dirty:
		for slot: Node in _cached_preferred_slots:
			if slot in slots:
				matched.append(slot)
		return matched
	_cached_preferred_slots.clear()
	for slot: Node in slots:
		var slot_id: String = str(slot.get("slot_id"))
		if slot_id.is_empty():
			continue
		var location: String = "shelf:%s" % slot_id
		var items: Array[ItemInstance] = (
			_inventory_system.get_items_at_location(location)
		)
		for item: ItemInstance in items:
			if not item.definition:
				continue
			if item.definition.category in profile.preferred_categories:
				_cached_preferred_slots.append(slot)
				break
	_preferred_slots_dirty = false
	for slot: Node in _cached_preferred_slots:
		if slot in slots:
			matched.append(slot)
	return matched


func _reset_browse_timer() -> void:
	browse_timer = GameRandom.randf_range(
		RandomStreamIds.CUSTOMER_BROWSE,
		profile.browse_time_range[0] * _browse_min_multiplier,
		profile.browse_time_range[1]
	)


func _build_customer_data() -> Dictionary:
	return {
		"customer_id": get_instance_id(),
		"profile_id": profile.id if profile else "",
		"profile_name": profile.customer_name if profile else "",
		"desired_item_id": (
			str(_desired_item.instance_id) if _desired_item else ""
		),
	}


func _randomize_body_color() -> void:
	if not _body_mesh or not _head_mesh:
		return
	var base_hue: float = GameRandom.randf(RandomStreamIds.CUSTOMER_APPEARANCE)
	var saturation: float = GameRandom.randf_range(
		RandomStreamIds.CUSTOMER_APPEARANCE, 0.3, 0.7
	)
	var value_v: float = GameRandom.randf_range(
		RandomStreamIds.CUSTOMER_APPEARANCE, 0.5, 0.9
	)
	var body_color := Color.from_hsv(base_hue, saturation, value_v)
	var body_material := StandardMaterial3D.new()
	body_material.albedo_color = body_color
	_body_mesh.material_override = body_material
	var skin_color := Color.from_hsv(
		GameRandom.randf_range(RandomStreamIds.CUSTOMER_APPEARANCE, 0.05, 0.12),
		GameRandom.randf_range(RandomStreamIds.CUSTOMER_APPEARANCE, 0.2, 0.5),
		GameRandom.randf_range(RandomStreamIds.CUSTOMER_APPEARANCE, 0.6, 0.9)
	)
	var skin_material := StandardMaterial3D.new()
	skin_material.albedo_color = skin_color
	_head_mesh.material_override = skin_material
	var pants_color := body_color.darkened(0.3)
	_apply_limb_materials(skin_material, pants_color)


func _apply_limb_materials(
	skin_material: StandardMaterial3D, pants_color: Color
) -> void:
	if _body_mesh == null:
		return
	var pants_material := StandardMaterial3D.new()
	pants_material.albedo_color = pants_color
	for child: Node in _body_mesh.get_children():
		if child is MeshInstance3D:
			var limb: MeshInstance3D = child as MeshInstance3D
			if limb.name.contains("Arm"):
				limb.material_override = skin_material
			elif limb.name.contains("Leg"):
				limb.material_override = pants_material


func _on_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = safe_velocity
	move_and_slide()


func _is_navigation_finished() -> bool:
	if _use_waypoint_fallback:
		return _fallback_arrived
	if _navigation_agent == null:
		return true
	return _navigation_agent.is_navigation_finished()


func _set_navigation_target(target_position: Vector3, target_kind: StringName = &"") -> void:
	if (
		CustomerNavConfig.is_position_in_staff_only_zone(target_position)
		and CustomerNavConfig.is_customer_position_allowed(global_position)
	):
		push_warning(
			"Customer: refusing staff-only navigation target for %s"
			% _resolved_target_kind(target_kind)
		)
		target_position = CustomerNavConfig.sanitize_customer_target(
			target_position, _exit_position
		)
	_fallback_target = target_position
	_fallback_arrived = global_position.distance_squared_to(
		target_position
	) < WAYPOINT_ARRIVAL_DIST_SQ
	if not (_use_waypoint_fallback or _navigation_agent == null):
		_navigation_agent.target_position = target_position
	_begin_navigation_target(target_position, _resolved_target_kind(target_kind))


func _resolved_target_kind(explicit_kind: StringName) -> StringName:
	if not String(explicit_kind).is_empty():
		return explicit_kind
	match current_state:
		State.WAITING_IN_QUEUE:
			return &"queue_slot"
		State.PURCHASING:
			return &"register"
		State.LEAVING:
			return &"exit"
		_:
			return &"shelf"


func _begin_navigation_target(target_position: Vector3, target_kind: StringName) -> void:
	_nav_target_kind = target_kind
	_nav_target_started_msec = Time.get_ticks_msec()
	_nav_was_finished = _is_navigation_finished()
	_last_nav_progress_position = global_position
	_last_nav_progress_msec = _nav_target_started_msec
	_nav_stall_reported = false
	_nav_timeout_reported = false
	EventBus.customer_navigation_target_set.emit({
		"customer_id": get_instance_id(),
		"state": state_name(current_state),
		"target_kind": String(target_kind),
		"target_position": target_position,
		"using_waypoint_fallback": _use_waypoint_fallback,
		"has_navigation_agent": _navigation_agent != null,
	})
	if _nav_was_finished:
		_emit_navigation_completed()


func _reset_navigation_metrics() -> void:
	_nav_target_kind = &""
	_nav_target_started_msec = 0
	_nav_was_finished = true
	_last_nav_progress_position = global_position
	_last_nav_progress_msec = 0
	_nav_stall_reported = false
	_nav_timeout_reported = false
	_register_arrival_reported = false
	_despawn_metric_reported = false


func _update_navigation_metrics() -> void:
	if String(_nav_target_kind).is_empty():
		return
	var now_msec: int = Time.get_ticks_msec()
	var finished: bool = _is_navigation_finished()
	if global_position.distance_squared_to(_last_nav_progress_position) >= NAV_PROGRESS_MIN_DIST_SQ:
		_last_nav_progress_position = global_position
		_last_nav_progress_msec = now_msec
	if finished:
		if not _nav_was_finished:
			_emit_navigation_completed()
		_nav_was_finished = true
		return
	_nav_was_finished = false
	var no_progress_seconds: float = float(now_msec - _last_nav_progress_msec) / 1000.0
	var target_age_seconds: float = float(now_msec - _nav_target_started_msec) / 1000.0
	if not _nav_stall_reported and no_progress_seconds >= NAV_STALL_SECONDS:
		_nav_stall_reported = true
		_emit_navigation_problem(&"stall", no_progress_seconds, target_age_seconds)
	if not _nav_timeout_reported and target_age_seconds >= _navigation_timeout_seconds():
		_nav_timeout_reported = true
		_emit_navigation_problem(&"timeout", no_progress_seconds, target_age_seconds)


func _emit_navigation_completed() -> void:
	EventBus.customer_navigation_completed.emit({
		"customer_id": get_instance_id(),
		"state": state_name(current_state),
		"target_kind": String(_nav_target_kind),
		"elapsed_seconds": _navigation_target_age_seconds(),
		"using_waypoint_fallback": _use_waypoint_fallback,
		"distance_remaining": _navigation_distance_remaining(),
	})


func _emit_navigation_problem(
	failure: StringName, no_progress_seconds: float, target_age_seconds: float
) -> void:
	if _is_expected_manual_checkout_wait():
		return
	EventBus.customer_navigation_stalled.emit({
		"customer_id": get_instance_id(),
		"state": state_name(current_state),
		"target_kind": String(_nav_target_kind),
		"failure": String(failure),
		"elapsed_seconds": target_age_seconds,
		"seconds_without_progress": no_progress_seconds,
		"distance_to_target": _navigation_distance_remaining(),
		"using_waypoint_fallback": _use_waypoint_fallback,
		"position": global_position,
		"target_position": _navigation_target_position(),
	})


func _emit_register_arrival_once() -> void:
	if _register_arrival_reported:
		return
	_register_arrival_reported = true
	EventBus.customer_register_arrival.emit({
		"customer_id": get_instance_id(),
		"awaiting_player_checkout": _awaiting_player_checkout,
		"target": "register",
	})


func _navigation_timeout_seconds() -> float:
	match _nav_target_kind:
		&"queue_slot", &"register":
			return 30.0
		_:
			return NAV_TARGET_TIMEOUT_SECONDS


func _navigation_target_age_seconds() -> float:
	if _nav_target_started_msec <= 0:
		return 0.0
	return float(Time.get_ticks_msec() - _nav_target_started_msec) / 1000.0


func _navigation_distance_remaining() -> float:
	return global_position.distance_to(_navigation_target_position())


func _navigation_target_position() -> Vector3:
	if _use_waypoint_fallback or _navigation_agent == null:
		return _fallback_target
	return _navigation_agent.target_position


func _is_expected_manual_checkout_wait() -> bool:
	return (
		current_state == State.PURCHASING
		and _awaiting_player_checkout
		and _is_navigation_finished()
	)


func _update_animator_movement(current_velocity: Vector3) -> void:
	if _animator == null:
		return
	_animator.update_movement(current_velocity)


func _on_speed_changed(new_speed: float) -> void:
	_time_paused = new_speed <= 0.0
	if _animation_player:
		_animation_player.speed_scale = new_speed if new_speed > 0.0 else 0.0
