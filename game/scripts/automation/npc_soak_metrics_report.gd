## Pure helpers for report-safe NPC soak metrics snapshots.
class_name NPCSoakMetricsReport
extends RefCounted


static func build_gauges(
	counters: Dictionary,
	runtime_gauges: Dictionary,
	customers: Dictionary,
	now_seconds: float
) -> Dictionary:
	var by_state: Dictionary = {}
	var observed: int = 0
	var oldest_customer_age: float = 0.0
	var oldest_state_age: Dictionary = {}
	for id: Variant in customers.keys():
		var record: Dictionary = customers[id]
		if not bool(record.get("active", false)):
			continue
		observed += 1
		var state: String = str(record.get("last_state", "unknown"))
		by_state[state] = int(by_state.get(state, 0)) + 1
		oldest_customer_age = maxf(
			oldest_customer_age,
			now_seconds - float(record.get("entered_at", now_seconds))
		)
		oldest_state_age[state] = maxf(
			float(oldest_state_age.get(state, 0.0)),
			now_seconds - float(record.get("last_state_changed_at", now_seconds))
		)
	var gauges: Dictionary = runtime_gauges.duplicate(true)
	gauges["active_customers_observed"] = observed
	gauges["customer_lifecycle_balance"] = (
		int(counters.get("customer_entered_total", 0))
		- int(counters.get("customer_left_total", 0))
	)
	gauges["customers_by_state"] = by_state
	gauges["oldest_customer_age_seconds"] = oldest_customer_age
	gauges["oldest_state_age_seconds"] = oldest_state_age
	return gauges


static func build_derived(
	counters: Dictionary, tagged_counters: Dictionary, gauges: Dictionary
) -> Dictionary:
	var left_by_reason: Dictionary = tagged_counters.get("customer_left_by_reason", {})
	var ready: int = int(counters.get("customer_ready_to_purchase_total", 0))
	var register_arrivals: int = int(counters.get("customer_register_arrival_total", 0))
	var checkout_completed: int = int(counters.get("checkout_completed_total", 0))
	var purchase_complete: int = int(left_by_reason.get("purchase_complete", 0))
	var lifecycle_balance: int = (
		int(counters.get("customer_entered_total", 0))
		- int(counters.get("customer_left_total", 0))
	)
	var active_reported: int = int(gauges.get("active_customers_reported", lifecycle_balance))
	var shopper_balance: int = (
		int(counters.get("shopper_spawn_success_total", 0))
		- int(counters.get("shopper_despawned_total", 0))
	)
	var active_shoppers: int = int(gauges.get("active_shoppers_reported", shopper_balance))
	return {
		"customer_balance_error": lifecycle_balance - active_reported,
		"shopper_balance_error": shopper_balance - active_shoppers,
		"unresolved_purchase_intents": (
			ready
			- checkout_completed
			- int(left_by_reason.get("patience_expired", 0))
			- int(left_by_reason.get("price_too_high", 0))
			- int(left_by_reason.get("no_matching_item", 0))
		),
		"register_arrival_failure_rate": (
			0.0 if ready == 0 else 1.0 - float(register_arrivals) / float(ready)
		),
		"checkout_completion_rate": (
			0.0 if register_arrivals == 0 else float(checkout_completed) / float(register_arrivals)
		),
		"purchase_completion_mismatch": checkout_completed - purchase_complete,
	}


static func find_node(root: Node, target_class: String) -> Node:
	if root == null:
		return null
	if root.get_class() == target_class or root.is_class(target_class):
		return root
	if target_class == "CustomerSystem" and root is CustomerSystem:
		return root
	if target_class == "QueueSystem" and root is QueueSystem:
		return root
	if target_class == "NPCSpawnerSystem" and root is NPCSpawnerSystem:
		return root
	for child: Node in root.get_children():
		var found: Node = find_node(child, target_class)
		if found != null:
			return found
	return null
