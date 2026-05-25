extends GutTest

const METRICS_SCRIPT: GDScript = preload(
	"res://game/scripts/automation/npc_soak_metrics.gd"
)

var _metrics: Node


func before_each() -> void:
	_metrics = METRICS_SCRIPT.new()
	add_child_autofree(_metrics)
	_metrics.call("start")


func after_each() -> void:
	if _metrics != null:
		_metrics.call("stop")


func test_counts_lifecycle_queue_navigation_and_pool_events() -> void:
	var customer := Node.new()
	add_child_autofree(customer)
	var customer_id: int = customer.get_instance_id()
	EventBus.customer_entered.emit({"customer_id": customer_id})
	EventBus.customer_state_changed.emit(customer, Customer.State.BROWSING)
	EventBus.customer_ready_to_purchase.emit({"customer_id": customer_id})
	EventBus.customer_register_arrival.emit({
		"customer_id": customer_id,
		"awaiting_player_checkout": true,
	})
	EventBus.customer_reached_checkout.emit(customer)
	EventBus.queue_enqueue_result.emit({
		"customer_id": customer_id,
		"result": "success",
		"queue_size": 1,
		"max_queue_size": 3,
	})
	EventBus.checkout_queue_ready.emit(customer)
	EventBus.checkout_completed.emit(customer)
	EventBus.customer_despawn_requested.emit(customer)
	EventBus.customer_left.emit({
		"customer_id": customer_id,
		"reason": "purchase_complete",
	})
	EventBus.customer_navigation_target_set.emit({
		"customer_id": customer_id,
		"target_kind": "register",
		"using_waypoint_fallback": false,
	})
	EventBus.customer_navigation_completed.emit({
		"customer_id": customer_id,
		"target_kind": "register",
	})
	EventBus.npc_pool_changed.emit({
		"reason": "spawn_success",
		"active_count": 1,
		"pooled_count": 9,
		"capacity": 8,
	})
	EventBus.npc_despawned.emit(&"npc_1")
	var snapshot: Dictionary = _metrics.call("snapshot")
	var counters: Dictionary = snapshot.get("counters", {}) as Dictionary
	var gauges: Dictionary = snapshot.get("gauges", {}) as Dictionary
	assert_eq(int(counters.get("customer_entered_total", 0)), 1)
	assert_eq(int(counters.get("queue_enqueue_success_total", 0)), 1)
	assert_eq(int(counters.get("navigation_completed_total", 0)), 1)
	assert_eq(int(counters.get("shopper_spawn_success_total", 0)), 1)
	assert_eq(int(gauges.get("customer_lifecycle_balance", -1)), 0)


func test_reports_navigation_failure_reason() -> void:
	EventBus.customer_navigation_stalled.emit({
		"customer_id": 44,
		"state": "PURCHASING",
		"target_kind": "register",
		"failure": "timeout",
	})
	var snapshot: Dictionary = _metrics.call("snapshot")
	var counters: Dictionary = snapshot.get("counters", {}) as Dictionary
	var reasons: Array = snapshot.get("fail_reasons", []) as Array
	assert_eq(int(counters.get("navigation_timeout_total", 0)), 1)
	assert_eq(int(counters.get("pathfinding_failure_total", 0)), 1)
	assert_true(str(reasons[0]).contains("navigation timeout"))
