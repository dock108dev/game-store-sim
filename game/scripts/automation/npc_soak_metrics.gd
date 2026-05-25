class_name NPCSoakMetrics
extends Node

const POLL_INTERVAL_SECONDS: float = 1.0
const QUEUE_DEADLOCK_SECONDS: float = 180.0
const BALANCE_GRACE_SECONDS: float = 10.0
const REPORT_SCRIPT: GDScript = preload(
	"res://game/scripts/automation/npc_soak_metrics_report.gd"
)
const COUNTER_KEYS: Array[String] = [
	"customer_entered_total", "customer_left_total", "customer_ready_to_purchase_total",
	"customer_register_arrival_total", "customer_reached_checkout_total",
	"customer_despawn_requested_total",
	"customer_state_changed_total", "checkout_queue_ready_total", "checkout_completed_total",
	"customer_abandoned_queue_total", "queue_changed_total", "queue_advanced_total",
	"queue_enqueue_attempt_total", "queue_enqueue_success_total", "queue_enqueue_rejected_total",
	"queue_rejected_full_total", "queue_rejected_duplicate_total", "queue_rejected_invalid_total",
	"queue_deadlock_total", "navigation_target_set_total", "navigation_completed_total",
	"navigation_stalled_total", "navigation_timeout_total", "pathfinding_failure_total",
	"navigation_fallback_mode_total", "navigation_agent_mode_total", "shopper_spawn_requested_total",
	"shopper_spawn_success_total", "shopper_spawn_failed_total", "shopper_despawned_total",
	"shopper_instantiated_total", "shopper_acquired_from_pool_total", "shopper_released_to_pool_total",
	"npc_capacity_violation_total", "runaway_customer_growth_total", "runaway_shopper_growth_total",
	"duplicate_customer_id_total",
]

var counters: Dictionary = {}
var tagged_counters: Dictionary = {}
var failure_reasons: Array[String] = []

var _customers: Dictionary = {}
var _queue_state: Dictionary = {}
var _gauges: Dictionary = {}
var _reported_failures: Dictionary = {}
var _running: bool = false
var _poll_elapsed: float = 0.0
var _started_msec: int = 0
var _last_customer_balance_mismatch_msec: int = 0
var _last_shopper_balance_mismatch_msec: int = 0

func start() -> void:
	stop()
	_reset()
	_running = true
	_started_msec = Time.get_ticks_msec()
	_connect_bus()
	set_process(true)
	_poll_gauges()

func stop() -> Dictionary:
	if _running:
		_poll_gauges()
	_running = false
	set_process(false)
	_disconnect_bus()
	return snapshot()

func snapshot() -> Dictionary:
	_poll_gauges()
	return {
		"counters": counters.duplicate(true),
		"tagged_counters": tagged_counters.duplicate(true),
		"gauges": REPORT_SCRIPT.build_gauges(
			counters, _gauges, _customers, _now_seconds()
		),
		"derived": REPORT_SCRIPT.build_derived(counters, tagged_counters, _gauges),
		"fail_reasons": failure_reasons.duplicate(),
	}

func _process(delta: float) -> void:
	if not _running:
		return
	_poll_elapsed += delta
	if _poll_elapsed >= POLL_INTERVAL_SECONDS:
		_poll_elapsed = 0.0
		_poll_gauges()
		_classify_failures()

func _reset() -> void:
	counters = {}
	for key: String in COUNTER_KEYS:
		counters[key] = 0
	tagged_counters = {
		"customer_left_by_reason": {},
		"customer_state_transition_total": {},
		"navigation_target_set_by_kind": {},
		"navigation_completed_by_kind": {},
		"navigation_stalled_by_kind": {},
		"navigation_timeout_by_kind": {},
		"queue_enqueue_result": {},
	}
	_customers.clear()
	_queue_state = {
		"size": 0,
		"processing": false,
		"head_customer_id": "0",
		"last_progress_msec": Time.get_ticks_msec(),
		"max_head_wait_seconds": 0.0,
	}
	_gauges.clear()
	failure_reasons.clear()
	_reported_failures.clear()
	_last_customer_balance_mismatch_msec = 0
	_last_shopper_balance_mismatch_msec = 0

func _connect_bus() -> void:
	_connect(EventBus.customer_entered, _on_customer_entered)
	_connect(EventBus.customer_left, _on_customer_left)
	_connect(EventBus.customer_ready_to_purchase, _on_customer_ready_to_purchase)
	_connect(EventBus.customer_register_arrival, _on_customer_register_arrival)
	_connect(EventBus.customer_reached_checkout, _on_customer_reached_checkout)
	_connect(EventBus.customer_despawn_requested, _on_customer_despawn_requested)
	_connect(EventBus.customer_state_changed, _on_customer_state_changed)
	_connect(EventBus.checkout_queue_ready, _on_checkout_queue_ready)
	_connect(EventBus.checkout_completed, _on_checkout_completed)
	_connect(EventBus.customer_abandoned_queue, _on_customer_abandoned_queue)
	_connect(EventBus.queue_changed, _on_queue_changed)
	_connect(EventBus.queue_advanced, _on_queue_advanced)
	_connect(EventBus.queue_enqueue_result, _on_queue_enqueue_result)
	_connect(EventBus.queue_wait_sample, _on_queue_wait_sample)
	_connect(EventBus.customer_navigation_target_set, _on_navigation_target_set)
	_connect(EventBus.customer_navigation_completed, _on_navigation_completed)
	_connect(EventBus.customer_navigation_stalled, _on_navigation_stalled)
	_connect(EventBus.customer_navigation_mode_selected, _on_navigation_mode_selected)
	_connect(EventBus.spawn_npc_requested, _on_spawn_npc_requested)
	_connect(EventBus.npc_despawned, _on_npc_despawned)
	_connect(EventBus.npc_pool_changed, _on_npc_pool_changed)
	_connect(EventBus.npc_capacity_violation, _on_npc_capacity_violation)

func _disconnect_bus() -> void:
	_disconnect(EventBus.customer_entered, _on_customer_entered)
	_disconnect(EventBus.customer_left, _on_customer_left)
	_disconnect(EventBus.customer_ready_to_purchase, _on_customer_ready_to_purchase)
	_disconnect(EventBus.customer_register_arrival, _on_customer_register_arrival)
	_disconnect(EventBus.customer_reached_checkout, _on_customer_reached_checkout)
	_disconnect(EventBus.customer_despawn_requested, _on_customer_despawn_requested)
	_disconnect(EventBus.customer_state_changed, _on_customer_state_changed)
	_disconnect(EventBus.checkout_queue_ready, _on_checkout_queue_ready)
	_disconnect(EventBus.checkout_completed, _on_checkout_completed)
	_disconnect(EventBus.customer_abandoned_queue, _on_customer_abandoned_queue)
	_disconnect(EventBus.queue_changed, _on_queue_changed)
	_disconnect(EventBus.queue_advanced, _on_queue_advanced)
	_disconnect(EventBus.queue_enqueue_result, _on_queue_enqueue_result)
	_disconnect(EventBus.queue_wait_sample, _on_queue_wait_sample)
	_disconnect(EventBus.customer_navigation_target_set, _on_navigation_target_set)
	_disconnect(EventBus.customer_navigation_completed, _on_navigation_completed)
	_disconnect(EventBus.customer_navigation_stalled, _on_navigation_stalled)
	_disconnect(EventBus.customer_navigation_mode_selected, _on_navigation_mode_selected)
	_disconnect(EventBus.spawn_npc_requested, _on_spawn_npc_requested)
	_disconnect(EventBus.npc_despawned, _on_npc_despawned)
	_disconnect(EventBus.npc_pool_changed, _on_npc_pool_changed)
	_disconnect(EventBus.npc_capacity_violation, _on_npc_capacity_violation)

func _on_customer_entered(data: Dictionary) -> void:
	_inc("customer_entered_total")
	var id: String = _data_customer_id(data)
	var now: float = _now_seconds()
	if _customers.has(id) and bool((_customers[id] as Dictionary).get("active", false)):
		_inc("duplicate_customer_id_total")
		_report_once("duplicate_customer_%s" % id, "duplicate customer id active: %s" % id)
	_customers[id] = {
		"entered_at": now,
		"last_state": "ENTERING",
		"last_state_changed_at": now,
		"active": true,
		"left_at": -1.0,
	}

func _on_customer_left(data: Dictionary) -> void:
	_inc("customer_left_total")
	var reason: String = str(data.get("reason", ""))
	_inc_tag("customer_left_by_reason", reason if not reason.is_empty() else "unknown")
	var id: String = _data_customer_id(data)
	var record: Dictionary = _customer_record(id)
	record["active"] = false
	record["left_at"] = _now_seconds()
	record["leave_reason"] = reason

func _on_customer_ready_to_purchase(data: Dictionary) -> void:
	_inc("customer_ready_to_purchase_total")
	var record: Dictionary = _customer_record(_data_customer_id(data))
	record["ready_to_purchase_at"] = _now_seconds()

func _on_customer_register_arrival(data: Dictionary) -> void:
	_inc("customer_register_arrival_total")
	var record: Dictionary = _customer_record(_data_customer_id(data))
	record["register_arrival_at"] = _now_seconds()
	if bool(data.get("awaiting_player_checkout", false)):
		record["manual_checkout_waiting"] = true

func _on_customer_reached_checkout(customer: Node) -> void:
	_inc("customer_reached_checkout_total")
	_customer_record(_node_id(customer))["reached_checkout_at"] = _now_seconds()

func _on_customer_despawn_requested(customer: Node) -> void:
	_inc("customer_despawn_requested_total")
	_customer_record(_node_id(customer))["despawn_requested_at"] = _now_seconds()

func _on_customer_state_changed(customer: Node, new_state: int) -> void:
	_inc("customer_state_changed_total")
	var id: String = _node_id(customer)
	var record: Dictionary = _customer_record(id)
	var old_state: String = str(record.get("last_state", ""))
	var new_state_name: String = Customer.state_name(new_state)
	if not old_state.is_empty() and old_state != new_state_name:
		_inc_tag("customer_state_transition_total", "%s->%s" % [old_state, new_state_name])
	record["last_state"] = new_state_name
	record["last_state_changed_at"] = _now_seconds()
	record["active"] = true

func _on_checkout_queue_ready(customer: Node) -> void:
	_inc("checkout_queue_ready_total")
	var id: String = _node_id(customer)
	_customer_record(id)["checkout_ready_at"] = _now_seconds()
	_queue_state["processing"] = true
	_queue_state["head_customer_id"] = id
	_mark_queue_progress()

func _on_checkout_completed(customer: Node) -> void:
	_inc("checkout_completed_total")
	_customer_record(_node_id(customer))["checkout_completed_at"] = _now_seconds()
	_queue_state["processing"] = false
	_mark_queue_progress()

func _on_customer_abandoned_queue(customer: Node) -> void:
	_inc("customer_abandoned_queue_total")
	_customer_record(_node_id(customer))["abandoned_queue_at"] = _now_seconds()
	_queue_state["processing"] = false
	_mark_queue_progress()

func _on_queue_changed(queue_size: int) -> void:
	_inc("queue_changed_total")
	_queue_state["size"] = queue_size
	_gauges["queue_size"] = queue_size
	_mark_queue_progress()

func _on_queue_advanced(queue_size: int) -> void:
	_inc("queue_advanced_total")
	_queue_state["size"] = queue_size
	_gauges["queue_size"] = queue_size
	_mark_queue_progress()

func _on_queue_enqueue_result(data: Dictionary) -> void:
	_inc("queue_enqueue_attempt_total")
	var result: String = str(data.get("result", "unknown"))
	_inc_tag("queue_enqueue_result", result)
	if result == "success":
		_inc("queue_enqueue_success_total")
		_mark_queue_progress()
	else:
		_inc("queue_enqueue_rejected_total")
		if result == "full":
			_inc("queue_rejected_full_total")
		elif result == "duplicate":
			_inc("queue_rejected_duplicate_total")
			_report_once("queue_duplicate", "duplicate queue enqueue rejected")
		elif result == "invalid":
			_inc("queue_rejected_invalid_total")

func _on_queue_wait_sample(data: Dictionary) -> void:
	_queue_state["size"] = int(data.get("queue_size", 0))
	_queue_state["head_customer_id"] = str(data.get("head_customer_id", "0"))
	_queue_state["processing"] = bool(data.get("processing", false))
	_queue_state["max_head_wait_seconds"] = maxf(
		float(_queue_state.get("max_head_wait_seconds", 0.0)),
		float(data.get("head_wait_seconds", 0.0))
	)

func _on_navigation_target_set(data: Dictionary) -> void:
	_inc("navigation_target_set_total")
	_inc_tag("navigation_target_set_by_kind", str(data.get("target_kind", "unknown")))
	var record: Dictionary = _customer_record(_data_customer_id(data))
	record["active_nav_target"] = {
		"kind": str(data.get("target_kind", "")),
		"started_at": _now_seconds(),
		"using_waypoint_fallback": bool(data.get("using_waypoint_fallback", false)),
	}

func _on_navigation_completed(data: Dictionary) -> void:
	_inc("navigation_completed_total")
	_inc_tag("navigation_completed_by_kind", str(data.get("target_kind", "unknown")))
	_customer_record(_data_customer_id(data)).erase("active_nav_target")

func _on_navigation_stalled(data: Dictionary) -> void:
	var failure: String = str(data.get("failure", "stall"))
	var kind: String = str(data.get("target_kind", "unknown"))
	if failure == "timeout":
		_inc("navigation_timeout_total")
		_inc_tag("navigation_timeout_by_kind", kind)
	else:
		_inc("navigation_stalled_total")
		_inc_tag("navigation_stalled_by_kind", kind)
	_inc("pathfinding_failure_total")
	_report_once(
		"navigation_%s_%s_%s" % [failure, kind, str(data.get("customer_id", "0"))],
		"navigation %s customer=%s target=%s state=%s" % [
			failure,
			str(data.get("customer_id", "0")),
			kind,
			str(data.get("state", "")),
		]
	)

func _on_navigation_mode_selected(data: Dictionary) -> void:
	if str(data.get("mode", "")) == "waypoint_fallback":
		_inc("navigation_fallback_mode_total")
	else:
		_inc("navigation_agent_mode_total")

func _on_spawn_npc_requested(_archetype_id: StringName, _entry_position: Vector3) -> void:
	_inc("shopper_spawn_requested_total")

func _on_npc_despawned(_npc_id: StringName) -> void:
	_inc("shopper_despawned_total")

func _on_npc_pool_changed(data: Dictionary) -> void:
	match str(data.get("reason", "")):
		"spawn_success":
			_inc("shopper_spawn_success_total")
		"spawn_failed_no_container", "spawn_failed_acquire":
			_inc("shopper_spawn_failed_total")
		"prewarm", "instantiate_dynamic":
			_inc("shopper_instantiated_total")
		"acquire_from_pool":
			_inc("shopper_acquired_from_pool_total")
		"despawn":
			_inc("shopper_released_to_pool_total")
	_gauges["active_shoppers_reported"] = int(data.get("active_count", 0))
	_gauges["pooled_shoppers_reported"] = int(data.get("pooled_count", 0))
	_gauges["shopper_capacity"] = int(data.get("capacity", 0))
	_gauges["shopper_expected_instances"] = (
		int(data.get("prewarmed_instances", 0))
		+ int(data.get("dynamic_instantiates", 0))
	)

func _on_npc_capacity_violation(data: Dictionary) -> void:
	_inc("npc_capacity_violation_total")
	_report_once(
		"npc_capacity_violation",
		"npc capacity violation active=%d capacity=%d" % [
			int(data.get("active_count", 0)),
			int(data.get("capacity", 0)),
		]
	)

func _poll_gauges() -> void:
	if get_tree() == null:
		return
	var customer_system: CustomerSystem = (
		REPORT_SCRIPT.find_node(get_tree().root, "CustomerSystem") as CustomerSystem
	)
	if customer_system != null:
		_gauges["active_customers_reported"] = customer_system.get_active_customer_count()
		_gauges["active_mall_shoppers_reported"] = customer_system.get_active_mall_shopper_count()
		_gauges["customer_capacity"] = int(customer_system.get("_max_customers"))
	var queue_system: QueueSystem = (
		REPORT_SCRIPT.find_node(get_tree().root, "QueueSystem") as QueueSystem
	)
	if queue_system != null:
		_gauges["queue_size"] = queue_system.get_queue_size()
	var spawner: NPCSpawnerSystem = (
		REPORT_SCRIPT.find_node(get_tree().root, "NPCSpawnerSystem") as NPCSpawnerSystem
	)
	if spawner != null:
		_gauges["active_shoppers_reported"] = spawner.get_active_count()
		_gauges["pooled_shoppers_reported"] = spawner.get_pooled_count()

func _classify_failures() -> void:
	var now_msec: int = Time.get_ticks_msec()
	if int(_queue_state.get("size", 0)) > 0:
		var idle_msec: int = now_msec - int(_queue_state.get("last_progress_msec", now_msec))
		var idle_seconds: float = float(idle_msec) / 1000.0
		if idle_seconds > QUEUE_DEADLOCK_SECONDS:
			_inc_once("queue_deadlock_total", "queue_deadlock")
			_report_once("queue_deadlock", "queue deadlock idle_seconds=%.1f" % idle_seconds)
	var customer_capacity: int = int(_gauges.get("customer_capacity", -1))
	var active_customers: int = int(_gauges.get("active_customers_reported", -1))
	if customer_capacity >= 0 and active_customers > customer_capacity:
		_inc_once("runaway_customer_growth_total", "runaway_customer_capacity")
		_report_once(
			"runaway_customer_capacity",
			"active customers exceed capacity: %d > %d" % [active_customers, customer_capacity]
		)
	_classify_balance_error(
		"customer_balance_error",
		"runaway_customer_growth_total",
		"customer_balance_mismatch",
		_last_customer_balance_mismatch_msec
	)
	var shopper_capacity: int = int(_gauges.get("shopper_capacity", -1))
	var active_shoppers: int = int(_gauges.get("active_shoppers_reported", -1))
	if shopper_capacity >= 0 and active_shoppers > shopper_capacity:
		_inc_once("runaway_shopper_growth_total", "runaway_shopper_capacity")
		_report_once(
			"runaway_shopper_capacity",
			"active shoppers exceed capacity: %d > %d" % [active_shoppers, shopper_capacity]
		)
	_classify_balance_error(
		"shopper_balance_error",
		"runaway_shopper_growth_total",
		"shopper_balance_mismatch",
		_last_shopper_balance_mismatch_msec
	)

func _classify_balance_error(
	derived_key: String, counter_key: String, failure_key: String, start_msec: int
) -> void:
	var derived: Dictionary = REPORT_SCRIPT.build_derived(counters, tagged_counters, _gauges)
	var error: int = int(derived.get(derived_key, 0))
	if error == 0:
		if failure_key == "customer_balance_mismatch":
			_last_customer_balance_mismatch_msec = 0
		else:
			_last_shopper_balance_mismatch_msec = 0
		return
	var now_msec: int = Time.get_ticks_msec()
	var tracked_start: int = start_msec if start_msec > 0 else now_msec
	if failure_key == "customer_balance_mismatch":
		_last_customer_balance_mismatch_msec = tracked_start
	else:
		_last_shopper_balance_mismatch_msec = tracked_start
	if float(now_msec - tracked_start) / 1000.0 >= BALANCE_GRACE_SECONDS:
		_inc_once(counter_key, failure_key)
		_report_once(failure_key, "%s persists: %d" % [derived_key, error])

func _customer_record(id: String) -> Dictionary:
	if not _customers.has(id):
		_customers[id] = {
			"entered_at": _now_seconds(),
			"last_state": "",
			"last_state_changed_at": _now_seconds(),
			"active": true,
		}
	return _customers[id]

func _mark_queue_progress() -> void:
	_queue_state["last_progress_msec"] = Time.get_ticks_msec()

func _inc(key: String, amount: int = 1) -> void:
	counters[key] = int(counters.get(key, 0)) + amount

func _inc_once(counter_key: String, once_key: String) -> void:
	if _reported_failures.has("counter_%s" % once_key):
		return
	_reported_failures["counter_%s" % once_key] = true
	_inc(counter_key)

func _inc_tag(group: String, key: String, amount: int = 1) -> void:
	var bucket: Dictionary = tagged_counters.get(group, {})
	bucket[key] = int(bucket.get(key, 0)) + amount
	tagged_counters[group] = bucket

func _report_once(key: String, reason: String) -> void:
	if _reported_failures.has(key):
		return
	_reported_failures[key] = true
	failure_reasons.append(reason)

func _data_customer_id(data: Dictionary) -> String:
	return str(data.get("customer_id", "0"))

func _node_id(node: Node) -> String:
	if node == null or not is_instance_valid(node):
		return "0"
	return str(node.get_instance_id())

func _now_seconds() -> float:
	return float(Time.get_ticks_msec() - _started_msec) / 1000.0

func _connect(signal_ref: Signal, callable: Callable) -> void:
	if not signal_ref.is_connected(callable):
		signal_ref.connect(callable)

func _disconnect(signal_ref: Signal, callable: Callable) -> void:
	if signal_ref.is_connected(callable):
		signal_ref.disconnect(callable)
