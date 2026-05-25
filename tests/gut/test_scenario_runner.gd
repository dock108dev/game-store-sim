extends GutTest

const LOADER_SCRIPT: GDScript = preload("res://tests/automation/scenario_loader.gd")
const RUNNER_SCRIPT: GDScript = preload("res://tests/automation/scenario_runner.gd")


class ScenarioProbe:
	extends Node

	var value: int = 7

	func get_value() -> int:
		return value

	func get_payload() -> Dictionary:
		return {"ready": true, "count": value}

	func mark_called() -> String:
		value = 9
		return "called"


func test_catalog_lists_stable_scenario_slots() -> void:
	var loader = LOADER_SCRIPT.new()
	var ids: PackedStringArray = loader.available_scenario_ids()

	assert_true(ids.has("fresh_install_smoke"))
	assert_true(ids.has("tutorial_full"))
	assert_true(ids.has("economy_loop_seed_001"))
	assert_true(ids.has("save_reload_smoke"))
	assert_true(ids.has("bad_state_resistance"))
	assert_true(ids.has("layout_torture"))
	assert_true(ids.has("long_day_soak"))


func test_unknown_scenario_reports_available_ids() -> void:
	var loader = LOADER_SCRIPT.new()
	var result: Dictionary = loader.load_by_id("missing_scenario")
	var context: Dictionary = result.get("context", {}) as Dictionary
	var available: Array = context.get("available_scenario_ids", []) as Array

	assert_false(bool(result.get("ok", true)))
	assert_string_contains(str(result.get("error", "")), "unknown scenario id")
	assert_true(available.has("fresh_install_smoke"))


func test_loader_rejects_invalid_step_schema_before_execution() -> void:
	var loader = LOADER_SCRIPT.new()
	var result: Dictionary = (
		loader
		. validate(
			{
				"id": "invalid_fixture",
				"steps":
				[
					{"id": "bad_command", "type": "unknown"},
					{
						"id": "missing_target",
						"type": "call_node",
						"method": "get_value",
					},
					{
						"id": "bad_assertion",
						"type": "assert_node",
						"target": "/root/Probe",
						"method": "get_value",
						"assert": {"mode": "near", "expected": 1},
					},
					{"id": "bad_capture", "type": "capture", "mode": "movie"},
				],
			}
		)
	)
	var errors: Array = (result.get("context", {}) as Dictionary).get("errors", []) as Array
	var joined: String = "\n".join(PackedStringArray(errors))

	assert_false(bool(result.get("ok", true)))
	assert_string_contains(joined, "unknown command")
	assert_string_contains(joined, "missing target")
	assert_string_contains(joined, "unsupported assertion mode")
	assert_string_contains(joined, "unsupported capture mode")


func test_long_day_soak_fixture_uses_accelerated_runner_step() -> void:
	var loader = LOADER_SCRIPT.new()
	var result: Dictionary = loader.load_by_id("long_day_soak")
	var scenario: Dictionary = result.get("scenario", {}) as Dictionary
	var steps: Array = scenario.get("steps", []) as Array
	var found_soak_step: bool = false

	assert_true(bool(result.get("ok", false)), str(result.get("error", "")))
	for step: Dictionary in steps:
		if str(step.get("type", "")) == "run_long_day_soak":
			found_soak_step = true
			break
	assert_true(found_soak_step)


func test_protected_outcome_signal_emit_fails_without_override() -> void:
	var runner: Node = _runner()
	var result: Dictionary = await (
		runner
		. call(
			"run",
			{
				"id": "protected_emit_test",
				"steps":
				[
					{
						"id": "emit_store_ready",
						"type": "emit_bus",
						"signal": "store_ready",
						"args": ["retro_games"],
					},
				],
			}
		)
	)

	assert_false(bool(result.get("ok", true)))
	assert_string_contains(str(result.get("summary", "")), "protected outcome signal")
	assert_eq(int(result.get("failed_step_index", -1)), 0)


func test_wait_bus_timeout_disconnects_temporary_listener() -> void:
	var before: int = EventBus.get_signal_connection_list("day_acknowledged").size()
	var runner: Node = _runner()
	var result: Dictionary = await (
		runner
		. call(
			"run",
			{
				"id": "wait_timeout_test",
				"steps":
				[
					{
						"id": "wait_for_day_ack",
						"type": "wait_bus",
						"signal": "day_acknowledged",
						"timeout_frames": 1,
					},
				],
			}
		)
	)
	var after: int = EventBus.get_signal_connection_list("day_acknowledged").size()

	assert_false(bool(result.get("ok", true)))
	assert_eq(after, before)
	assert_string_contains(str(result.get("summary", "")), "last_successful_step")


func test_wait_bus_matches_named_signal_arguments() -> void:
	var runner: Node = _runner()
	var pending: Variant = (
		runner
		. call(
			"run",
			{
				"id": "wait_match_test",
				"steps":
				[
					{
						"id": "wait_for_store",
						"type": "wait_bus",
						"signal": "store_ready",
						"match": {"store_id": "retro_games"},
						"timeout_frames": 30,
					},
				],
			},
			{"allow_outcome_signal_emit": true}
		)
	)

	await get_tree().process_frame
	EventBus.store_ready.emit(&"retro_games")
	var result: Dictionary = await pending

	assert_true(bool(result.get("ok", false)))
	assert_eq(
		str((result.get("last_successful_step", {}) as Dictionary).get("id", "")), "wait_for_store"
	)


func test_wait_audit_observes_recent_checkpoint() -> void:
	AuditLog.clear()
	AuditLog.pass_check(&"scenario_recent_checkpoint", "from=test")
	var runner: Node = _runner()
	var result: Dictionary = await (
		runner
		. call(
			"run",
			{
				"id": "audit_recent_test",
				"steps":
				[
					{
						"id": "wait_recent",
						"type": "wait_audit",
						"checkpoint": "scenario_recent_checkpoint",
						"status": "PASS",
						"timeout_frames": 2,
					},
				],
			}
		)
	)

	assert_true(bool(result.get("ok", false)))


func test_wait_audit_times_out_when_checkpoint_missing() -> void:
	AuditLog.clear()
	var runner: Node = _runner()
	var result: Dictionary = await (
		runner
		. call(
			"run",
			{
				"id": "audit_timeout_test",
				"steps":
				[
					{
						"id": "wait_missing",
						"type": "wait_audit",
						"checkpoint": "scenario_missing_checkpoint",
						"status": "PASS",
						"timeout_frames": 1,
					},
				],
			}
		)
	)

	assert_false(bool(result.get("ok", true)))
	assert_string_contains(str(result.get("summary", "")), "AUDIT PASS")


func test_call_assert_and_capture_node_state() -> void:
	var probe := ScenarioProbe.new()
	probe.name = "ScenarioProbe"
	get_tree().root.add_child(probe)
	var runner: Node = _runner()
	var result: Dictionary = await (
		runner
		. call(
			"run",
			{
				"id": "node_state_test",
				"steps":
				[
					{
						"id": "call_probe",
						"type": "call_node",
						"target": "/root/ScenarioProbe",
						"method": "mark_called",
					},
					{
						"id": "assert_probe",
						"type": "assert_node",
						"target": "/root/ScenarioProbe",
						"method": "get_value",
						"assert": {"mode": "equals", "expected": 9},
					},
					{
						"id": "capture_probe",
						"type": "capture",
						"mode": "state",
						"label": "payload",
						"target": "/root/ScenarioProbe",
						"method": "get_payload",
					},
				],
			},
			{"seed": "unit_seed", "fresh_save": true}
		)
	)
	probe.queue_free()

	assert_true(bool(result.get("ok", false)))
	assert_eq(str(result.get("run_id", "")), "node_state_test_unit_seed_fresh")
	assert_eq(
		((result.get("captures", {}) as Dictionary).get("payload", {}) as Dictionary).get(
			"count", 0
		),
		9
	)
	var metrics: Dictionary = result.get("soak_metrics", {}) as Dictionary
	assert_true(metrics.has("counters"), "Scenario result must include soak counters")
	assert_true(metrics.has("gauges"), "Scenario result must include soak gauges")
	assert_true(metrics.has("fail_reasons"), "Scenario result must include soak fail reasons")
	var report: Dictionary = result.get("report", {}) as Dictionary
	var report_body: Dictionary = _read_json_file(str(report.get("path", "")))
	assert_true(report_body.has("soak_metrics"))


func test_screenshot_step_writes_checkpoint_metadata() -> void:
	var runner: Node = _runner()
	var result: Dictionary = await (
		runner
		. call(
			"run",
			{
				"id": "screenshot_step_test",
				"steps":
				[
					{
						"id": "capture_store_ui",
						"type": "screenshot",
						"label": "store_ui_open",
						"checkpoint_index": 5,
						"allow_placeholder": true,
						"timeout_frames": 30,
					},
				],
			},
			{"seed": "runner_seed"}
		)
	)

	assert_true(bool(result.get("ok", false)), str(result.get("summary", "")))
	var capture: Dictionary = (
		(result.get("captures", {}) as Dictionary).get("store_ui_open", {}) as Dictionary
	)
	assert_eq(str(capture.get("filename", "")), "005_store_ui_open.png")
	assert_true(FileAccess.file_exists(str(capture.get("path", ""))))
	assert_true(FileAccess.file_exists(str(capture.get("metadata_path", ""))))
	var metadata: Dictionary = _read_json_file(str(capture.get("metadata_path", "")))
	assert_eq(str(metadata.get("scenario_id", "")), "screenshot_step_test")
	assert_eq(str(metadata.get("seed", "")), "runner_seed")
	assert_eq(str(metadata.get("checkpoint_slug", "")), "005_store_ui_open")


func _runner() -> Node:
	var runner: Node = RUNNER_SCRIPT.new()
	add_child_autofree(runner)
	return runner


func _read_json_file(path: String) -> Dictionary:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	assert_not_null(file, "JSON file must open: %s" % path)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	assert_true(parsed is Dictionary)
	if not (parsed is Dictionary):
		return {}
	return parsed as Dictionary
