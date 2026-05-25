## Runs an accelerated deterministic mall-day soak over the live gameplay tree.
class_name LongDaySoakRunner
extends Node

const SCENARIO_ID: String = "long_day_soak"
const DEFAULT_PROFILE: String = "standard"
const ENV_SOAK_PROFILE: String = "MALLCORE_SOAK_PROFILE"
const ARTIFACTS_SCRIPT: GDScript = preload("res://game/scripts/core/automation_artifacts.gd")
const METRICS_SCRIPT: GDScript = preload("res://game/scripts/automation/npc_soak_metrics.gd")
const TIME_CONTROLLER_SCRIPT: GDScript = preload(
	"res://game/scripts/systems/time_automation_controller.gd"
)

const PROFILES: Dictionary = {
	"standard":
	{
		"equivalent_gameplay_minutes": 30.0,
		"sample_interval_minutes": 5.0,
		"frames_per_sample": 6,
		"speed_tier": TimeSystem.SpeedTier.ULTRA,
		"target_active_customers": 2,
		"max_pathfinding_failures": 0,
		"max_queue_deadlocks": 0,
		"max_runaway_growth_events": 0,
		"max_interaction_failures": 0,
		"max_unresolved_purchase_intents": 8,
	},
	"nightly":
	{
		"equivalent_gameplay_minutes": 60.0,
		"sample_interval_minutes": 5.0,
		"frames_per_sample": 8,
		"speed_tier": TimeSystem.SpeedTier.ULTRA,
		"target_active_customers": 3,
		"max_pathfinding_failures": 0,
		"max_queue_deadlocks": 0,
		"max_runaway_growth_events": 0,
		"max_interaction_failures": 0,
		"max_unresolved_purchase_intents": 12,
	},
	"release":
	{
		"equivalent_gameplay_minutes": 60.0,
		"sample_interval_minutes": 5.0,
		"frames_per_sample": 8,
		"speed_tier": TimeSystem.SpeedTier.ULTRA,
		"target_active_customers": 3,
		"max_pathfinding_failures": 0,
		"max_queue_deadlocks": 0,
		"max_runaway_growth_events": 0,
		"max_interaction_failures": 0,
		"max_unresolved_purchase_intents": 12,
	},
}

var _samples: Array[Dictionary] = []
var _interaction_failures: int = 0


## Returns supported soak profile names for runner configuration and tests.
static func supported_profiles() -> Array[String]:
	var profiles: Array[String] = []
	for profile_id: String in PROFILES.keys():
		profiles.append(profile_id)
	profiles.sort()
	return profiles


## Resolves a profile plus optional step-level overrides into run config.
static func resolve_profile(profile_id: String, overrides: Dictionary = {}) -> Dictionary:
	var selected: String = profile_id
	if not PROFILES.has(selected):
		selected = DEFAULT_PROFILE
	var config: Dictionary = (PROFILES[selected] as Dictionary).duplicate(true)
	for key: Variant in overrides.keys():
		config[key] = overrides[key]
	config["profile_id"] = selected
	config["nightly_capable"] = (float(config.get("equivalent_gameplay_minutes", 0.0)) >= 60.0)
	return config


static func selected_profile_id(options: Dictionary, step_config: Dictionary) -> String:
	var profile_id: String = str(step_config.get("profile", ""))
	if profile_id.is_empty():
		profile_id = str(options.get("soak_profile", ""))
	if profile_id.is_empty():
		profile_id = OS.get_environment(ENV_SOAK_PROFILE)
	if profile_id.is_empty():
		profile_id = DEFAULT_PROFILE
	return profile_id


## Runs the soak using live TimeSystem, PerformanceManager, and NPC metrics.
func run(options: Dictionary = {}, step_config: Dictionary = {}) -> Dictionary:
	_samples.clear()
	_interaction_failures = 0

	var profile_id: String = selected_profile_id(options, step_config)
	var profile: Dictionary = resolve_profile(profile_id, step_config.get("profile_overrides", {}))
	var result: Dictionary = _base_result(options, profile)
	var time_system: TimeSystem = GameManager.get_time_system()
	var performance: PerformanceManager = _find_performance_manager()
	if time_system == null:
		return _fail(result, ["time_system_missing"])
	if performance == null:
		return _fail(result, ["performance_manager_missing"])

	var active_store_id: StringName = GameManager.get_active_store_id()
	if active_store_id.is_empty():
		return _fail(result, ["active_store_missing"])

	var metrics: Node = METRICS_SCRIPT.new()
	add_child(metrics)
	metrics.call("start")

	var controller = TIME_CONTROLLER_SCRIPT.new()
	add_child(controller)
	controller.initialize(time_system)
	controller.request_speed(profile.get("speed_tier", TimeSystem.SpeedTier.ULTRA))

	_seed_mall_state(active_store_id)
	var threshold_overrides: Dictionary = {
		"min_elapsed_seconds": float(profile.get("equivalent_gameplay_minutes", 0.0)) * 60.0,
	}
	performance.begin_soak_observation(threshold_overrides)

	var advanced_minutes: float = await _advance_soak(
		controller, time_system, performance, profile, active_store_id
	)
	var performance_observation: Dictionary = performance.end_soak_observation(
		advanced_minutes * 60.0
	)
	var metrics_snapshot: Dictionary = metrics.call("stop")
	metrics.queue_free()
	controller.queue_free()

	result["simulation"] = {
		"profile": str(profile.get("profile_id", DEFAULT_PROFILE)),
		"seed": str(options.get("seed", "automation_default")),
		"active_store_id": String(active_store_id),
		"equivalent_gameplay_minutes": advanced_minutes,
		"required_gameplay_minutes": float(profile.get("equivalent_gameplay_minutes", 0.0)),
		"sample_interval_minutes": float(profile.get("sample_interval_minutes", 0.0)),
		"sample_count": _samples.size(),
	}
	result["samples"] = _samples.duplicate(true)
	result["soak_metrics"] = metrics_snapshot
	result["performance_observation"] = performance_observation
	result["threshold_summary"] = _build_threshold_summary(
		profile, advanced_minutes, metrics_snapshot, performance_observation
	)
	result["trend"] = _build_trend_payload(result)
	result["artifact_paths"] = _write_artifacts(result)
	result["ok"] = bool((result["threshold_summary"] as Dictionary).get("passed", false))
	if not bool(result.get("ok", false)):
		result["failures"] = (result["threshold_summary"] as Dictionary).get("failures", [])
		result["summary"] = "long day soak failed"
	else:
		result["summary"] = "long day soak completed"
	return result


func _advance_soak(
	controller: Node,
	time_system: TimeSystem,
	performance: PerformanceManager,
	profile: Dictionary,
	active_store_id: StringName
) -> float:
	var required_minutes: float = float(profile.get("equivalent_gameplay_minutes", 30.0))
	var sample_interval: float = float(profile.get("sample_interval_minutes", 5.0))
	var advanced_minutes: float = 0.0
	while advanced_minutes < required_minutes:
		var remaining: float = required_minutes - advanced_minutes
		var step_minutes: float = minf(sample_interval, remaining)
		var actual: float = controller.step_minutes(step_minutes)
		if actual <= 0.0:
			break
		advanced_minutes += actual
		_ensure_customer_activity(active_store_id, profile)
		await _advance_frames(int(profile.get("frames_per_sample", 6)))
		var observation: Dictionary = performance.sample_soak_observation(advanced_minutes * 60.0)
		_samples.append(_sample_snapshot(advanced_minutes, time_system, observation))
	return advanced_minutes


func _advance_frames(count: int) -> void:
	for _i: int in range(maxi(count, 1)):
		await get_tree().process_frame


func _seed_mall_state(active_store_id: StringName) -> void:
	GameState.set_active_store(active_store_id)
	GameState.set_flag(&"first_sale_complete", true)
	if StoreSessionState != null:
		StoreSessionState.preopening_complete = true
		StoreSessionState.day = GameManager.get_current_day()
	EventBus.active_store_changed.emit(active_store_id)
	EventBus.item_stocked.emit("soak_seed_stock", "soak_seed_shelf")


func _ensure_customer_activity(active_store_id: StringName, profile: Dictionary) -> void:
	var customer_system: CustomerSystem = GameManager.get_customer_system()
	if customer_system == null:
		return
	var target_count: int = int(profile.get("target_active_customers", 0))
	if target_count <= 0:
		return
	var needed: int = target_count - customer_system.get_active_customer_count()
	if needed <= 0:
		return
	var pool: Array[CustomerTypeDefinition] = customer_system.get_spawn_pool()
	if pool.is_empty():
		return
	for _i: int in range(needed):
		var chosen: CustomerTypeDefinition = customer_system.pick_spawn_profile(pool)
		if chosen == null:
			chosen = pool[0]
		customer_system.spawn_customer(chosen, String(active_store_id))


func _sample_snapshot(
	advanced_minutes: float, time_system: TimeSystem, performance_observation: Dictionary
) -> Dictionary:
	var blocker: String = _blocking_reason(get_tree().current_scene)
	if not blocker.is_empty():
		_interaction_failures += 1
	return {
		"gameplay_minutes": advanced_minutes,
		"day": time_system.current_day,
		"clock_minutes": time_system.game_time_minutes,
		"game_state": int(GameManager.current_state),
		"blocking_reason": blocker,
		"performance": performance_observation,
	}


func _build_threshold_summary(
	profile: Dictionary,
	advanced_minutes: float,
	metrics_snapshot: Dictionary,
	performance_observation: Dictionary
) -> Dictionary:
	var counters: Dictionary = metrics_snapshot.get("counters", {}) as Dictionary
	var derived: Dictionary = metrics_snapshot.get("derived", {}) as Dictionary
	var performance_classification: Dictionary = (
		performance_observation.get("classification", {}) as Dictionary
	)
	var failures: Array[String] = []
	_add_failure_if(
		failures,
		advanced_minutes < float(profile.get("equivalent_gameplay_minutes", 0.0)),
		"equivalent_gameplay_minutes_below_min"
	)
	_add_failure_if(failures, not _is_global_state_valid(), "global_state_invalid")
	_add_failure_if(
		failures,
		(
			int(counters.get("pathfinding_failure_total", 0))
			> int(profile.get("max_pathfinding_failures", 0))
		),
		"pathfinding_failures_above_max"
	)
	_add_failure_if(
		failures,
		int(counters.get("queue_deadlock_total", 0)) > int(profile.get("max_queue_deadlocks", 0)),
		"queue_deadlocks_above_max"
	)
	var runaway_total: int = (
		int(counters.get("runaway_customer_growth_total", 0))
		+ int(counters.get("runaway_shopper_growth_total", 0))
		+ int(counters.get("npc_capacity_violation_total", 0))
	)
	_add_failure_if(
		failures,
		runaway_total > int(profile.get("max_runaway_growth_events", 0)),
		"runaway_entity_growth_above_max"
	)
	_add_failure_if(
		failures,
		_interaction_failures > int(profile.get("max_interaction_failures", 0)),
		"interaction_failures_above_max"
	)
	_add_failure_if(
		failures,
		(
			int(derived.get("unresolved_purchase_intents", 0))
			> int(profile.get("max_unresolved_purchase_intents", 0))
		),
		"purchase_failures_above_max"
	)
	for reason: String in metrics_snapshot.get("fail_reasons", []) as Array[String]:
		if not failures.has(reason):
			failures.append(reason)
	for reason: String in performance_classification.get("fail_reasons", []) as Array[String]:
		if not failures.has(reason):
			failures.append(reason)
	return {
		"passed": failures.is_empty(),
		"failures": failures,
		"thresholds":
		{
			"min_equivalent_gameplay_minutes":
			float(profile.get("equivalent_gameplay_minutes", 0.0)),
			"max_pathfinding_failures": int(profile.get("max_pathfinding_failures", 0)),
			"max_queue_deadlocks": int(profile.get("max_queue_deadlocks", 0)),
			"max_runaway_growth_events": int(profile.get("max_runaway_growth_events", 0)),
			"max_interaction_failures": int(profile.get("max_interaction_failures", 0)),
			"max_unresolved_purchase_intents":
			int(profile.get("max_unresolved_purchase_intents", 0)),
			"performance": performance_observation.get("thresholds", {}),
		},
		"observed":
		{
			"equivalent_gameplay_minutes": advanced_minutes,
			"pathfinding_failures": int(counters.get("pathfinding_failure_total", 0)),
			"queue_deadlocks": int(counters.get("queue_deadlock_total", 0)),
			"runaway_growth_events": runaway_total,
			"interaction_failures": _interaction_failures,
			"unresolved_purchase_intents": int(derived.get("unresolved_purchase_intents", 0)),
			"performance_failures": performance_classification.get("fail_reasons", []),
		},
	}


func _build_trend_payload(result: Dictionary) -> Dictionary:
	var simulation: Dictionary = result.get("simulation", {}) as Dictionary
	var metrics: Dictionary = result.get("soak_metrics", {}) as Dictionary
	var observation: Dictionary = result.get("performance_observation", {}) as Dictionary
	return {
		"schema_version": 1,
		"scenario_id": SCENARIO_ID,
		"seed": str(simulation.get("seed", "")),
		"profile": str(simulation.get("profile", "")),
		"equivalent_gameplay_minutes": float(simulation.get("equivalent_gameplay_minutes", 0.0)),
		"sample_count": int(simulation.get("sample_count", 0)),
		"threshold_summary": result.get("threshold_summary", {}),
		"counters": metrics.get("counters", {}),
		"gauges": metrics.get("gauges", {}),
		"derived": metrics.get("derived", {}),
		"performance": observation,
	}


func _write_artifacts(result: Dictionary) -> Dictionary:
	var scenario_id: String = str(result.get("scenario_id", SCENARIO_ID))
	var run_id: String = str(result.get("run_id", "run"))
	var dir_path: String = ARTIFACTS_SCRIPT.report_dir("scenario", scenario_id)
	var paths: Dictionary = {}
	paths["soak_metrics"] = _write_json_artifact(
		dir_path,
		"%s-soak-metrics.json" % run_id,
		result.get("soak_metrics", {}),
		scenario_id,
		"soak_metrics_snapshot"
	)
	paths["threshold_summary"] = _write_json_artifact(
		dir_path,
		"%s-threshold-summary.json" % run_id,
		result.get("threshold_summary", {}),
		scenario_id,
		"soak_threshold_summary"
	)
	paths["soak_log"] = _write_json_artifact(
		dir_path,
		"%s-soak-log.json" % run_id,
		{"samples": _samples.duplicate(true), "trend": result.get("trend", {})},
		scenario_id,
		"soak_sample_log"
	)
	paths["trend"] = _write_json_artifact(
		dir_path, "%s-trend.json" % run_id, result.get("trend", {}), scenario_id, "soak_trend"
	)
	return paths


func _write_json_artifact(
	dir_path: String,
	filename: String,
	payload: Dictionary,
	scenario_id: String,
	artifact_type: String
) -> Dictionary:
	var path: String = ARTIFACTS_SCRIPT.join_path([dir_path, filename])
	return ARTIFACTS_SCRIPT.write_recorded_json(
		path,
		payload,
		artifact_type,
		scenario_id,
		"scenario",
		"json",
		"cannot write soak artifact"
	)


func _base_result(options: Dictionary, profile: Dictionary) -> Dictionary:
	return {
		"scenario_id": str(options.get("scenario_id", SCENARIO_ID)),
		"run_id": str(options.get("run_id", "run")),
		"seed": str(options.get("seed", "automation_default")),
		"profile": profile.duplicate(true),
		"ok": true,
		"summary": "",
		"failures": [],
		"samples": [],
		"soak_metrics": {},
		"performance_observation": {},
		"threshold_summary": {},
		"artifact_paths": {},
	}


func _fail(result: Dictionary, failures: Array[String]) -> Dictionary:
	result["ok"] = false
	result["summary"] = "long day soak unavailable"
	result["failures"] = failures
	result["threshold_summary"] = {"passed": false, "failures": failures}
	result["artifact_paths"] = _write_artifacts(result)
	return result


func _find_performance_manager() -> PerformanceManager:
	if get_tree() == null or get_tree().root == null:
		return null
	var matches: Array[Node] = get_tree().root.find_children("*", "PerformanceManager", true, false)
	if matches.is_empty():
		return null
	return matches[0] as PerformanceManager


func _is_global_state_valid() -> bool:
	var valid_states: Array[int] = [
		GameManager.State.GAMEPLAY,
		GameManager.State.MALL_OVERVIEW,
		GameManager.State.STORE_VIEW,
	]
	return valid_states.has(int(GameManager.current_state))


func _blocking_reason(node: Node) -> String:
	if InputFocus != null and InputFocus.current() == InputFocus.CTX_MODAL:
		return "input_focus_modal"
	if node == null:
		return ""
	if node is AcceptDialog and (node as AcceptDialog).visible:
		return str(node.get_path())
	if node.name == "ErrorPanel" and node is CanvasItem and (node as CanvasItem).visible:
		return str(node.get_path())
	for child: Node in node.get_children():
		var reason: String = _blocking_reason(child)
		if not reason.is_empty():
			return reason
	return ""


static func _add_failure_if(failures: Array[String], failed: bool, reason: String) -> void:
	if failed and not failures.has(reason):
		failures.append(reason)
