## Accumulates deterministic runtime-health samples for long soak scenarios.
class_name PerformanceSoakObserver
extends RefCounted

const DEFAULT_THRESHOLDS: Dictionary = {
	"min_elapsed_seconds": 0.0,
	"min_average_fps": 55.0,
	"min_sample_fps": 50.0,
	"max_worst_frame_ms": 50.0,
	"max_npc_avg_total_ms": 4.0,
	"max_npc_peak_total_ms": 12.0,
	"max_memory_growth_kb_per_min": 256.0,
	"max_memory_delta_mb": 128.0,
	"max_store_switch_ms": 500.0,
	"max_warning_count": 0,
}

var _running: bool = false
var _thresholds: Dictionary = DEFAULT_THRESHOLDS.duplicate(true)
var _baseline_memory_bytes: int = 0
var _current_memory_bytes: int = 0
var _peak_memory_bytes: int = 0
var _elapsed_seconds: float = 0.0
var _sample_count: int = 0
var _total_fps: float = 0.0
var _min_sample_fps: float = 0.0
var _worst_frame_ms: float = 0.0
var _total_npc_avg_ms: float = 0.0
var _npc_peak_total_ms: float = 0.0
var _npc_peak_count: int = 0
var _total_npc_count: float = 0.0
var _store_switch_peak_ms: float = 0.0
var _warning_count: int = 0
var _target_fps: float = 60.0
var _cache_stats: Dictionary = {}


## Starts a new soak observation and captures the supplied memory baseline.
func begin(
	baseline_memory_bytes: int,
	threshold_overrides: Dictionary = {}
) -> Dictionary:
	reset()
	_running = true
	_thresholds = DEFAULT_THRESHOLDS.duplicate(true)
	for key: Variant in threshold_overrides.keys():
		if _thresholds.has(key):
			_thresholds[key] = threshold_overrides[key]
	_baseline_memory_bytes = max(0, baseline_memory_bytes)
	_current_memory_bytes = _baseline_memory_bytes
	_peak_memory_bytes = _baseline_memory_bytes
	return snapshot()


## Adds one deterministic sample from an already-built performance snapshot.
func sample(
	stats: Dictionary,
	memory_stats: Dictionary,
	elapsed_seconds: float,
	performance_warning_count: int
) -> Dictionary:
	if not _running:
		return snapshot()
	_elapsed_seconds = maxf(_elapsed_seconds, maxf(elapsed_seconds, 0.0))
	_sample_count += 1

	var fps: float = float(stats.get("average_fps", 0.0))
	_target_fps = float(stats.get("target_fps", _target_fps))
	_total_fps += fps
	if _sample_count == 1:
		_min_sample_fps = fps
	else:
		_min_sample_fps = minf(_min_sample_fps, fps)

	_worst_frame_ms = maxf(
		_worst_frame_ms,
		float(stats.get("worst_frame_ms", 0.0))
	)
	var npc_avg: float = float(stats.get("npc_avg_total_ms", 0.0))
	_total_npc_avg_ms += npc_avg
	_npc_peak_total_ms = maxf(
		_npc_peak_total_ms,
		float(stats.get("npc_peak_total_ms", 0.0))
	)
	_npc_peak_count = maxi(
		_npc_peak_count,
		int(stats.get("npc_peak_count", 0))
	)
	_total_npc_count += float(stats.get("npc_avg_count", 0.0))
	_cache_stats = {
		"entries": int(stats.get("cache_entries", 0)),
		"hit_rate": float(stats.get("cache_hit_rate", 0.0)),
		"hits": int(stats.get("cache_hits", 0)),
		"misses": int(stats.get("cache_misses", 0)),
	}

	_current_memory_bytes = max(0, int(memory_stats.get("static_bytes", 0)))
	_peak_memory_bytes = maxi(
		_peak_memory_bytes,
		int(memory_stats.get("peak_static_bytes", _current_memory_bytes))
	)
	_store_switch_peak_ms = maxf(
		_store_switch_peak_ms,
		float(stats.get("last_store_switch_ms", 0.0))
	)
	_warning_count = max(_warning_count, performance_warning_count)
	return snapshot()


## Stops observation after an optional final sample has already been recorded.
func end() -> Dictionary:
	_running = false
	return snapshot()


## Clears all accumulated samples and restores default thresholds.
func reset() -> void:
	_running = false
	_thresholds = DEFAULT_THRESHOLDS.duplicate(true)
	_baseline_memory_bytes = 0
	_current_memory_bytes = 0
	_peak_memory_bytes = 0
	_elapsed_seconds = 0.0
	_sample_count = 0
	_total_fps = 0.0
	_min_sample_fps = 0.0
	_worst_frame_ms = 0.0
	_total_npc_avg_ms = 0.0
	_npc_peak_total_ms = 0.0
	_npc_peak_count = 0
	_total_npc_count = 0.0
	_store_switch_peak_ms = 0.0
	_warning_count = 0
	_target_fps = 60.0
	_cache_stats = {}


## Returns a JSON-compatible summary of the current soak observation.
func snapshot() -> Dictionary:
	var avg_fps: float = 0.0
	var avg_npc_ms: float = 0.0
	var avg_npc_count: float = 0.0
	if _sample_count > 0:
		avg_fps = _total_fps / float(_sample_count)
		avg_npc_ms = _total_npc_avg_ms / float(_sample_count)
		avg_npc_count = _total_npc_count / float(_sample_count)
	var memory_delta_bytes: int = _current_memory_bytes - _baseline_memory_bytes
	var elapsed_minutes: float = _elapsed_seconds / 60.0
	var growth_kb_per_min: float = 0.0
	if elapsed_minutes > 0.0:
		growth_kb_per_min = (float(memory_delta_bytes) / 1024.0) / elapsed_minutes
	var result: Dictionary = {
		"running": _running,
		"elapsed_seconds": _elapsed_seconds,
		"sample_count": _sample_count,
		"thresholds": _thresholds.duplicate(true),
		"fps": {
			"average": avg_fps,
			"minimum": _min_sample_fps,
			"target": _target_fps,
			"worst_frame_ms": _worst_frame_ms,
		},
		"npc": {
			"avg_total_ms": avg_npc_ms,
			"peak_total_ms": _npc_peak_total_ms,
			"avg_count": avg_npc_count,
			"peak_count": _npc_peak_count,
		},
		"memory": {
			"baseline_bytes": _baseline_memory_bytes,
			"current_bytes": _current_memory_bytes,
			"peak_bytes": _peak_memory_bytes,
			"delta_bytes": memory_delta_bytes,
			"delta_mb": float(memory_delta_bytes) / 1048576.0,
			"growth_kb_per_min": growth_kb_per_min,
		},
		"cache": _cache_stats.duplicate(true),
		"store_switch": {
			"peak_ms": _store_switch_peak_ms,
		},
		"counters": {
			"performance_warnings": _warning_count,
		},
	}
	result["classification"] = classify(result)
	return result


## Classifies a soak snapshot against the active threshold table.
func classify(observation: Dictionary) -> Dictionary:
	var reasons: Array[String] = []
	var thresholds: Dictionary = observation.get("thresholds", _thresholds)
	var fps: Dictionary = observation.get("fps", {})
	var npc: Dictionary = observation.get("npc", {})
	var memory: Dictionary = observation.get("memory", {})
	var store_switch: Dictionary = observation.get("store_switch", {})
	var counters: Dictionary = observation.get("counters", {})

	_add_failure_if(
		reasons,
		float(observation.get("elapsed_seconds", 0.0))
			< float(thresholds.get("min_elapsed_seconds", 0.0)),
		"elapsed_seconds_below_min"
	)
	_add_failure_if(
		reasons,
		float(fps.get("average", 0.0))
			< float(thresholds.get("min_average_fps", 0.0)),
		"average_fps_below_min"
	)
	_add_failure_if(
		reasons,
		float(fps.get("minimum", 0.0))
			< float(thresholds.get("min_sample_fps", 0.0)),
		"sample_fps_below_min"
	)
	_add_failure_if(
		reasons,
		float(fps.get("worst_frame_ms", 0.0))
			> float(thresholds.get("max_worst_frame_ms", INF)),
		"worst_frame_ms_above_max"
	)
	_add_failure_if(
		reasons,
		float(npc.get("avg_total_ms", 0.0))
			> float(thresholds.get("max_npc_avg_total_ms", INF)),
		"npc_average_ms_above_max"
	)
	_add_failure_if(
		reasons,
		float(npc.get("peak_total_ms", 0.0))
			> float(thresholds.get("max_npc_peak_total_ms", INF)),
		"npc_peak_ms_above_max"
	)
	_add_failure_if(
		reasons,
		float(memory.get("growth_kb_per_min", 0.0))
			> float(thresholds.get("max_memory_growth_kb_per_min", INF)),
		"memory_growth_above_max"
	)
	_add_failure_if(
		reasons,
		float(memory.get("delta_mb", 0.0))
			> float(thresholds.get("max_memory_delta_mb", INF)),
		"memory_delta_above_max"
	)
	_add_failure_if(
		reasons,
		float(store_switch.get("peak_ms", 0.0))
			> float(thresholds.get("max_store_switch_ms", INF)),
		"store_switch_ms_above_max"
	)
	_add_failure_if(
		reasons,
		int(counters.get("performance_warnings", 0))
			> int(thresholds.get("max_warning_count", 0)),
		"performance_warning_count_above_max"
	)
	return {
		"passed": reasons.is_empty(),
		"fail_reasons": reasons,
	}


static func _add_failure_if(
	reasons: Array[String],
	failed: bool,
	reason: String
) -> void:
	if failed:
		reasons.append(reason)
