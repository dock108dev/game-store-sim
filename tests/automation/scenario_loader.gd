## Loads and validates scenario fixtures by stable scenario id.
class_name ScenarioLoader
extends RefCounted

const SCENARIO_DIR: String = "res://tests/automation/scenarios"
const VALID_COMMANDS: Array[String] = [
	"wait_audit",
	"wait_bus",
	"emit_bus",
	"enter_store",
	"route_scene",
	"wait_node",
	"call_node",
	"assert_node",
	"advance_frames",
	"time_speed",
	"time_step",
	"move_to_target",
	"aim_at_target",
	"focus_target",
	"interact_target",
	"capture",
	"screenshot",
	"run_economy_loop",
	"run_save_reload_smoke",
	"run_long_day_soak",
	"finish",
]
const CAPTURE_MODES: Array[String] = ["state", "screenshot"]
const SAFE_ID_CHARS: String = "abcdefghijklmnopqrstuvwxyz0123456789_"

const ASSERTIONS_SCRIPT: GDScript = preload("res://tests/automation/scenario_assertions.gd")


## Returns sorted ids for all fixture files in the scenario directory.
func available_scenario_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	for path: String in _scenario_files():
		var parsed: Dictionary = _read_json(path)
		if bool(parsed.get("ok", false)):
			var data: Dictionary = parsed.get("data", {}) as Dictionary
			var id: String = str(data.get("id", ""))
			if _is_safe_id(id):
				ids.append(id)
	ids.sort()
	return ids


## Loads one scenario by id. CLI file paths are intentionally unsupported.
func load_by_id(scenario_id: String) -> Dictionary:
	if not _is_safe_id(scenario_id):
		return _error(
			"invalid scenario id '%s'" % scenario_id,
			{"available_scenario_ids": Array(available_scenario_ids())}
		)
	for path: String in _scenario_files():
		var parsed: Dictionary = _read_json(path)
		if not bool(parsed.get("ok", false)):
			return parsed
		var data: Dictionary = parsed.get("data", {}) as Dictionary
		if str(data.get("id", "")) == scenario_id:
			var validation: Dictionary = validate(data, path)
			if not bool(validation.get("ok", false)):
				return validation
			data["source_path"] = path
			return {"ok": true, "scenario": data}
	return _error(
		"unknown scenario id '%s'" % scenario_id,
		{"available_scenario_ids": Array(available_scenario_ids())}
	)


## Validates fixture schema and command configuration before execution.
func validate(scenario: Dictionary, source_path: String = "") -> Dictionary:
	var errors: Array[String] = []
	var id: String = str(scenario.get("id", ""))
	if not _is_safe_id(id):
		errors.append("scenario id must use lowercase letters, numbers, and underscores")
	if not scenario.has("steps") or not (scenario["steps"] is Array):
		errors.append("scenario steps must be an array")
	else:
		var steps: Array = scenario.get("steps", []) as Array
		for index: int in range(steps.size()):
			if not (steps[index] is Dictionary):
				errors.append("step %d must be an object" % index)
				continue
			errors.append_array(_validate_step(steps[index] as Dictionary, index))
	if not errors.is_empty():
		return _error(
			"scenario fixture validation failed", {"source_path": source_path, "errors": errors}
		)
	return {"ok": true}


func _validate_step(step: Dictionary, index: int) -> Array[String]:
	var errors: Array[String] = []
	var prefix: String = "step %d" % index
	var command: String = str(step.get("type", ""))
	if command.is_empty():
		errors.append("%s missing type" % prefix)
	elif not VALID_COMMANDS.has(command):
		errors.append("%s unknown command '%s'" % [prefix, command])
	if str(step.get("id", "")).is_empty():
		errors.append("%s missing id" % prefix)
	if int(step.get("timeout_frames", 1)) <= 0:
		errors.append("%s timeout_frames must be positive" % prefix)
	match command:
		"wait_audit":
			if str(step.get("checkpoint", "")).is_empty():
				errors.append("%s missing checkpoint" % prefix)
			var status: String = str(step.get("status", "PASS"))
			if status != "PASS" and status != "FAIL":
				errors.append("%s audit status must be PASS or FAIL" % prefix)
		"wait_bus", "emit_bus":
			if str(step.get("signal", "")).is_empty():
				errors.append("%s missing signal" % prefix)
		"enter_store":
			if str(step.get("store_id", "")).is_empty():
				errors.append("%s missing store_id" % prefix)
		"route_scene":
			if str(step.get("scene_path", "")).is_empty():
				errors.append("%s missing scene_path" % prefix)
		"wait_node":
			if str(step.get("target", "")).is_empty():
				errors.append("%s missing target" % prefix)
		"call_node", "assert_node":
			if str(step.get("target", "")).is_empty():
				errors.append("%s missing target" % prefix)
			if str(step.get("method", "")).is_empty():
				errors.append("%s missing method" % prefix)
		"advance_frames":
			if int(step.get("count", 0)) <= 0:
				errors.append("%s count must be positive" % prefix)
		"time_speed":
			if not step.has("tier"):
				errors.append("%s missing tier" % prefix)
		"time_step":
			if float(step.get("minutes", 0.0)) <= 0.0:
				errors.append("%s minutes must be positive" % prefix)
		"move_to_target", "aim_at_target", "focus_target", "interact_target":
			errors.append_array(_validate_target_definition(step, prefix))
		"capture":
			var mode: String = str(step.get("mode", ""))
			if not CAPTURE_MODES.has(mode):
				errors.append("%s unsupported capture mode '%s'" % [prefix, mode])
		"screenshot":
			if str(step.get("label", "")).is_empty():
				errors.append("%s missing label" % prefix)
		"run_long_day_soak":
			if step.has("profile") and str(step.get("profile", "")).is_empty():
				errors.append("%s profile must not be empty" % prefix)
			if step.has("profile_overrides"):
				if not (step["profile_overrides"] is Dictionary):
					errors.append("%s profile_overrides must be an object" % prefix)
				else:
					var overrides: Dictionary = step["profile_overrides"] as Dictionary
					if (
						overrides.has("equivalent_gameplay_minutes")
						and float(overrides.get("equivalent_gameplay_minutes", 0.0)) <= 0.0
					):
						errors.append("%s equivalent_gameplay_minutes must be positive" % prefix)
	if command == "assert_node":
		if not (step.get("assert", {}) is Dictionary):
			errors.append("%s invalid assertion" % prefix)
		else:
			var assertion_errors: Array[String] = ASSERTIONS_SCRIPT.validate(
				step.get("assert", {}) as Dictionary
			)
			for assertion_error: String in assertion_errors:
				errors.append("%s %s" % [prefix, assertion_error])
	return errors


func _validate_target_definition(step: Dictionary, prefix: String) -> Array[String]:
	var errors: Array[String] = []
	if not step.has("target"):
		errors.append("%s missing target" % prefix)
		return errors
	var target: Variant = step.get("target")
	if target is String or target is StringName:
		if str(target).strip_edges().is_empty():
			errors.append("%s target must not be empty" % prefix)
		return errors
	if not (target is Dictionary):
		errors.append("%s target must be a semantic id or object" % prefix)
		return errors
	var selector: Dictionary = target as Dictionary
	var supported_fields: Array[String] = [
		"semantic_id",
		"kind",
		"interactable_id",
		"groups",
		"objective_id",
		"objective_stage",
		"fallback_objective_ids",
		"fallback_names",
		"fallback_paths",
	]
	var has_selector: bool = false
	for field: String in supported_fields:
		if selector.has(field):
			has_selector = true
			break
	if not has_selector:
		errors.append("%s target has no semantic selector fields" % prefix)
	for string_field: String in [
		"semantic_id", "kind", "interactable_id", "objective_id", "objective_stage"
	]:
		if (
			selector.has(string_field)
			and str(selector.get(string_field, "")).strip_edges().is_empty()
		):
			errors.append("%s target %s must not be empty" % [prefix, string_field])
	for array_field: String in [
		"groups", "fallback_objective_ids", "fallback_names", "fallback_paths"
	]:
		if not selector.has(array_field):
			continue
		if not (selector[array_field] is Array):
			errors.append("%s target %s must be an array" % [prefix, array_field])
			continue
		var values: Array = selector[array_field] as Array
		for value: Variant in values:
			if str(value).strip_edges().is_empty():
				errors.append("%s target %s contains an empty value" % [prefix, array_field])
	return errors


func _scenario_files() -> PackedStringArray:
	var files := PackedStringArray()
	var dir: DirAccess = DirAccess.open(SCENARIO_DIR)
	if dir == null:
		return files
	dir.list_dir_begin()
	var name: String = dir.get_next()
	while not name.is_empty():
		if not dir.current_is_dir() and name.ends_with(".json"):
			files.append("%s/%s" % [SCENARIO_DIR, name])
		name = dir.get_next()
	dir.list_dir_end()
	files.sort()
	return files


func _read_json(path: String) -> Dictionary:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _error("cannot read scenario fixture", {"source_path": path})
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not (parsed is Dictionary):
		return _error("scenario fixture root must be an object", {"source_path": path})
	return {"ok": true, "data": parsed}


func _is_safe_id(id: String) -> bool:
	if id.is_empty():
		return false
	for i: int in range(id.length()):
		if not SAFE_ID_CHARS.contains(id.substr(i, 1)):
			return false
	return true


func _error(message: String, context: Dictionary = {}) -> Dictionary:
	return {"ok": false, "error": message, "context": context}
