## Tests NPC performance optimizations: navigation throttling, stagger offsets,
## preferred slot caching, and PerformanceManager NPC profiling.
extends GutTest


# --- PerformanceManager NPC profiling ---


var _perf: PerformanceManager


func before_each() -> void:
	_perf = PerformanceManager.new()
	add_child_autofree(_perf)
	_perf.initialize()


func test_npc_stats_default_zeroes() -> void:
	var stats: Dictionary = _perf.get_npc_performance_stats()
	assert_eq(
		stats.get("avg_total_ms", -1.0), 0.0,
		"NPC stats should start at zero"
	)
	assert_eq(
		stats.get("sample_count", -1), 0,
		"No valid samples initially"
	)
	assert_eq(
		stats.get("peak_npc_count", -1), 0,
		"NPC peak count should start at zero"
	)


func test_record_npc_frame_updates_stats() -> void:
	_perf.record_npc_frame(0.5, 0.3, 0.1, 4)
	var stats: Dictionary = _perf.get_npc_performance_stats()
	assert_gt(
		stats.get("avg_total_ms", 0.0) as float, 0.0,
		"After recording a frame, avg total should be > 0"
	)
	assert_eq(
		stats.get("sample_count", 0) as int, 1,
		"Should have 1 valid sample"
	)
	assert_almost_eq(
		stats.get("avg_npc_count", 0.0) as float, 4.0, 0.01,
		"NPC count average should reflect recorded samples"
	)
	assert_eq(
		stats.get("latest_npc_count", 0) as int, 4,
		"Latest NPC count should reflect the last recorded sample"
	)


func test_record_npc_frame_peak_tracking() -> void:
	_perf.record_npc_frame(0.1, 0.1, 0.05, 2)
	_perf.record_npc_frame(1.0, 0.8, 0.2, 8)
	_perf.record_npc_frame(0.2, 0.15, 0.05, 3)
	var stats: Dictionary = _perf.get_npc_performance_stats()
	assert_almost_eq(
		stats.get("peak_total_ms", 0.0) as float, 2.0, 0.01,
		"Peak should be the sum of the largest frame (1.0+0.8+0.2)"
	)


func test_npc_stats_included_in_performance_stats() -> void:
	_perf.record_npc_frame(0.5, 0.3, 0.1, 4)
	var stats: Dictionary = _perf.get_performance_stats()
	assert_true(
		stats.has("npc_avg_total_ms"),
		"Performance stats should include npc_avg_total_ms"
	)
	assert_true(
		stats.has("npc_peak_total_ms"),
		"Performance stats should include npc_peak_total_ms"
	)
	assert_true(
		stats.has("npc_peak_count"),
		"Performance stats should include npc_peak_count"
	)
	assert_true(
		stats.has("memory_static_bytes"),
		"Performance stats should include memory_static_bytes"
	)
	assert_true(
		stats.has("soak_sample_count"),
		"Performance stats should include soak_sample_count"
	)


# --- Customer navigation throttling constants ---


func test_nav_recalc_interval_is_positive() -> void:
	assert_gt(
		Customer.NAV_RECALC_INTERVAL, 0.0,
		"NAV_RECALC_INTERVAL must be positive"
	)
	assert_lte(
		Customer.NAV_RECALC_INTERVAL, 0.5,
		"NAV_RECALC_INTERVAL should not exceed 500ms for responsiveness"
	)


# --- Stagger offset distribution ---


func test_stagger_offsets_are_distributed() -> void:
	var offsets: Array[float] = []
	var slots: int = CustomerSystem.STAGGER_SLOTS
	for i: int in range(slots):
		offsets.append(float(i) / float(slots))
	for i: int in range(slots - 1):
		assert_lt(
			offsets[i], offsets[i + 1],
			"Stagger offsets should be monotonically increasing"
		)
	assert_gte(
		offsets[0], 0.0,
		"First stagger offset should be >= 0"
	)
	assert_lt(
		offsets[slots - 1], 1.0,
		"Last stagger offset should be < 1.0"
	)


func test_stagger_slots_matches_max_customers() -> void:
	assert_gte(
		CustomerSystem.STAGGER_SLOTS,
		CustomerSystem.MAX_CUSTOMERS_MEDIUM,
		"Stagger slots should cover at least the max customer count"
	)


# --- PerformanceManager NPC sample window ---


func test_npc_sample_window_rolling() -> void:
	for i: int in range(PerformanceManager.NPC_SAMPLE_WINDOW + 10):
		_perf.record_npc_frame(0.1, 0.1, 0.05, 1)
	var stats: Dictionary = _perf.get_npc_performance_stats()
	var avg: float = stats.get("avg_total_ms", 0.0) as float
	assert_almost_eq(
		avg, 0.25, 0.01,
		"After filling window, avg should reflect consistent values"
	)


# --- Customer profiling fields exist and are initialized ---


func test_customer_profiling_fields_default() -> void:
	var customer: Customer = Customer.new()
	assert_eq(
		customer.last_script_time_ms, 0.0,
		"Script time should default to 0"
	)
	assert_eq(
		customer.last_nav_time_ms, 0.0,
		"Nav time should default to 0"
	)
	assert_eq(
		customer.last_anim_time_ms, 0.0,
		"Anim time should default to 0"
	)
	assert_eq(
		customer.stagger_offset, 0.0,
		"Stagger offset should default to 0"
	)
	customer.free()


# --- PerformanceManager soak observation ---


func test_soak_observation_reset_clears_accumulator() -> void:
	_perf.begin_soak_observation({}, 1000)
	_perf.record_npc_frame(1.0, 1.0, 1.0, 5)
	_perf.sample_soak_observation(60.0, 2000)

	_perf.reset_soak_observation()
	var snapshot: Dictionary = _perf.get_soak_observation_snapshot()
	var memory: Dictionary = snapshot.get("memory", {}) as Dictionary

	assert_false(bool(snapshot.get("running", true)))
	assert_eq(int(snapshot.get("sample_count", -1)), 0)
	assert_eq(int(memory.get("delta_bytes", -1)), 0)


func test_soak_sampling_computes_memory_growth_and_npc_counts() -> void:
	_perf.begin_soak_observation({}, 1024)
	_perf.record_npc_frame(0.6, 0.4, 0.2, 6)
	var snapshot: Dictionary = _perf.sample_soak_observation(120.0, 4096)
	var memory: Dictionary = snapshot.get("memory", {}) as Dictionary
	var npc: Dictionary = snapshot.get("npc", {}) as Dictionary

	assert_eq(int(snapshot.get("sample_count", 0)), 1)
	assert_eq(int(memory.get("delta_bytes", 0)), 3072)
	assert_almost_eq(
		float(memory.get("growth_kb_per_min", 0.0)), 1.5, 0.01,
		"3 KiB growth across two minutes should be 1.5 KiB/min"
	)
	assert_eq(int(npc.get("peak_count", 0)), 6)


func test_soak_threshold_classification_passes_and_fails() -> void:
	_perf.begin_soak_observation({
		"min_elapsed_seconds": 60.0,
		"max_memory_growth_kb_per_min": 1.0,
	}, 1024)
	_perf.sample_soak_observation(120.0, 2048)
	var passing: Dictionary = _perf.end_soak_observation(120.0, 2048)
	var passing_classification: Dictionary = (
		passing.get("classification", {}) as Dictionary
	)

	assert_true(bool(passing_classification.get("passed", false)))

	_perf.begin_soak_observation({
		"min_elapsed_seconds": 180.0,
		"max_memory_growth_kb_per_min": 1.0,
	}, 1024)
	var failing: Dictionary = _perf.end_soak_observation(60.0, 4096)
	var classification: Dictionary = failing.get("classification", {}) as Dictionary
	var reasons: Array = classification.get("fail_reasons", []) as Array

	assert_false(bool(classification.get("passed", true)))
	assert_true(reasons.has("elapsed_seconds_below_min"))
	assert_true(reasons.has("memory_growth_above_max"))


func test_soak_snapshot_json_shape() -> void:
	var snapshot: Dictionary = _perf.begin_soak_observation({}, 2048)
	snapshot = _perf.sample_soak_observation(30.0, 3072)
	var json_text: String = JSON.stringify(snapshot)
	var parsed: Variant = JSON.parse_string(json_text)

	assert_true(parsed is Dictionary)
	assert_true(snapshot.has("running"))
	assert_true(snapshot.has("elapsed_seconds"))
	assert_true(snapshot.has("sample_count"))
	assert_true(snapshot.has("thresholds"))
	assert_true(snapshot.has("fps"))
	assert_true(snapshot.has("npc"))
	assert_true(snapshot.has("memory"))
	assert_true(snapshot.has("cache"))
	assert_true(snapshot.has("store_switch"))
	assert_true(snapshot.has("counters"))
	assert_true(snapshot.has("classification"))
