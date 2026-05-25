## Shared helpers for ScenarioRunner runtime bookkeeping.
class_name ScenarioRuntimeHelpers
extends RefCounted

const AutomationArtifactsScript: GDScript = preload(
	"res://game/scripts/core/automation_artifacts.gd"
)
const BUS_SIGNAL_ARGS: Dictionary = {
	&"store_ready": [&"store_id"],
	&"store_failed": [&"store_id", &"reason"],
	&"scene_ready": [&"scene_name"],
	&"store_entered": [&"store_id"],
	&"store_exited": [&"store_id"],
	&"active_store_changed": [&"store_id"],
	&"first_sale_completed": [&"store_id", &"item_id", &"price"],
	&"customer_purchased": [&"store_id", &"item_id", &"price", &"customer_id"],
	&"item_price_set": [&"store_id", &"item_id", &"price", &"ratio"],
	&"stock_changed": [&"store_id", &"item_id", &"new_quantity"],
	&"day_closed": [&"day", &"summary"],
	&"day_close_confirmation_requested": [&"reason"],
}


## Returns the base result shape shared by direct and catalog scenario runs.
static func base_result(
	scenario_id: String, options: Dictionary, reason: String = ""
) -> Dictionary:
	var seed_text: String = str(options.get("seed", "automation_default"))
	var fresh: bool = bool(options.get("fresh_save", false))
	var run_id: String = (
		"%s_%s_%s"
		% [
			AutomationArtifactsScript.sanitize_slug(scenario_id),
			AutomationArtifactsScript.sanitize_slug(seed_text),
			"fresh" if fresh else "existing",
		]
	)
	return {
		"scenario_id": scenario_id,
		"run_id": run_id,
		"run_id_policy": "scenario_seed_and_fresh_save",
		"seed": seed_text,
		"ok": reason.is_empty(),
		"summary": reason,
		"started_msec": Time.get_ticks_msec(),
		"ended_msec": 0,
		"elapsed_msec": 0,
		"failed_step_index": -1,
		"failed_step": {},
		"last_successful_step": {},
		"steps": [],
		"events": [],
		"captures": {},
	}


## Connects a bus signal and records its arguments when it fires.
static func connect_bus_signal(
	bus: Object,
	signal_name: StringName,
	box: Dictionary,
	seen_bus: Array[Dictionary],
	connections: Array[Dictionary]
) -> Callable:
	var arity: int = _signal_arity(bus, signal_name)
	var callable: Callable
	match arity:
		0:
			callable = func() -> void: _record_signal(signal_name, [], box, seen_bus)
		1:
			callable = func(a: Variant) -> void: _record_signal(signal_name, [a], box, seen_bus)
		2:
			callable = func(a: Variant, b: Variant) -> void:
				_record_signal(signal_name, [a, b], box, seen_bus)
		3:
			callable = func(a: Variant, b: Variant, c: Variant) -> void:
				_record_signal(signal_name, [a, b, c], box, seen_bus)
		4:
			callable = func(a: Variant, b: Variant, c: Variant, d: Variant) -> void:
				_record_signal(signal_name, [a, b, c, d], box, seen_bus)
		_:
			callable = func(a: Variant, b: Variant, c: Variant, d: Variant, e: Variant) -> void:
				_record_signal(signal_name, [a, b, c, d, e], box, seen_bus)
	bus.connect(signal_name, callable)
	connections.append({"object": bus, "signal": signal_name, "callable": callable})
	return callable


## Returns true when signal arguments satisfy a named or positional match.
static func matches_signal_args(
	signal_name: StringName, actual_args: Array, expected: Dictionary
) -> bool:
	for key: Variant in expected.keys():
		var actual: Variant = _signal_arg_value(signal_name, actual_args, key)
		if actual != expected[key]:
			return false
	return true


## Returns assertion step counts from the scenario result built so far.
static func assertion_counts(result: Dictionary) -> Dictionary:
	var counts: Dictionary = {"total": 0, "passed": 0, "failed": 0}
	for step_variant: Variant in result.get("steps", []) as Array:
		var step: Dictionary = step_variant as Dictionary
		if str(step.get("type", "")) != "assert_node":
			continue
		counts["total"] = int(counts["total"]) + 1
		if bool(step.get("ok", false)):
			counts["passed"] = int(counts["passed"]) + 1
		else:
			counts["failed"] = int(counts["failed"]) + 1
	return counts


## Returns the current scene name for screenshot metadata.
static func current_scene_name(tree: SceneTree) -> String:
	if tree == null or tree.current_scene == null:
		return ""
	return String(tree.current_scene.name)


## Returns the newest matching audit entry from a recent entry list.
static func find_recent_audit(
	entries: Array[Dictionary], checkpoint: StringName, status: String
) -> Dictionary:
	for i: int in range(entries.size() - 1, -1, -1):
		var entry: Dictionary = entries[i]
		if entry.get("checkpoint", &"") == checkpoint and str(entry.get("status", "")) == status:
			return entry
	return {}


static func _record_signal(
	signal_name: StringName, args: Array, box: Dictionary, seen_bus: Array[Dictionary]
) -> void:
	box["done"] = true
	box["args"] = args
	seen_bus.append({"signal": String(signal_name), "args": args})


static func _signal_arg_value(signal_name: StringName, actual_args: Array, key: Variant) -> Variant:
	if key is int:
		return actual_args[key] if int(key) < actual_args.size() else null
	var names: Array = BUS_SIGNAL_ARGS.get(signal_name, [])
	var index: int = names.find(StringName(str(key)))
	if index >= 0 and index < actual_args.size():
		return actual_args[index]
	return null


static func _signal_arity(object: Object, signal_name: StringName) -> int:
	for info: Dictionary in object.get_signal_list():
		if StringName(str(info.get("name", ""))) == signal_name:
			return (info.get("args", []) as Array).size()
	return 0
