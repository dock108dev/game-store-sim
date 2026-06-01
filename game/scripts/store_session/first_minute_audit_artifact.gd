## Builds the first-minute screenshot audit contract for the Day 1 store route.
class_name FirstMinuteAuditArtifact
extends RefCounted

const AutomationArtifactsScript: GDScript = preload(
	"res://game/scripts/core/automation_artifacts.gd"
)
const ManualRouteScript: GDScript = preload(
	"res://game/scripts/store_session/manual_day_one_route_capture.gd"
)
const StoreVisualSweepScript: GDScript = preload(
	"res://game/scripts/store_session/store_visual_sweep.gd"
)
const FirstMinuteAuditMarkdownScript: GDScript = preload(
	"res://game/scripts/store_session/first_minute_audit_markdown.gd"
)
const FirstMinuteAuditRouteContractScript: GDScript = preload(
	"res://game/scripts/store_session/first_minute_audit_route_contract.gd"
)

const ARTIFACT_TYPE: String = "first_minute_screenshot_audit"
const ARTIFACT_SUITE: String = "retro_games_day_one"
const ARTIFACT_RELATIVE_DIR: String = "first_minute_audit/retro_games_day_one"
const CAPTURE_DIR_NAME: String = "captures"
const JSON_FILENAME: String = "first_minute_audit.json"
const MARKDOWN_FILENAME: String = "first_minute_audit.md"
const SCHEMA_VERSION: int = 1
const STATUS_PENDING: String = "PENDING"
const STATUS_FAIL: String = "FAIL"
const STATUS_KNOWN_FAIL: String = "KNOWN_FAIL"
const STATUS_MISSING: String = "MISSING"
const ACTIONABLE_STATUSES: Array[String] = [STATUS_FAIL, STATUS_MISSING, STATUS_KNOWN_FAIL]


## Returns the normalized first-minute audit payload without writing files.
static func build_artifact(
	run_id: String = "", capture_results: Dictionary = {}, review_records: Dictionary = {}
) -> Dictionary:
	var resolved_run_id: String = _run_id(run_id)
	var run_dir: String = _run_dir(resolved_run_id)
	var capture_dir: String = "%s/%s" % [run_dir, CAPTURE_DIR_NAME]
	var beats: Array[Dictionary] = audit_beats(capture_dir, capture_results, review_records)
	return {
		"schema_version": SCHEMA_VERSION,
		"artifact_type": ARTIFACT_TYPE,
		"route_id": ARTIFACT_SUITE,
		"run_id": resolved_run_id,
		"artifact_dir": run_dir,
		"capture_dir": capture_dir,
		"json_path": "%s/%s" % [run_dir, JSON_FILENAME],
		"markdown_path": "%s/%s" % [run_dir, MARKDOWN_FILENAME],
		"capture_policy":
		{
			"timebox_seconds": 60,
			"requires_close_day_summary": false,
			"optional_when_reached_status": STATUS_PENDING,
			"source_strengths":
			[
				"StoreVisualSweep.rows() screenshot review metadata",
				"ManualDayOneRouteCapture.route_beats() route-state expectations",
			],
		},
		"punch_list": punch_list(beats),
		"beats": beats,
	}


## Returns the ordered audit beats with screenshot, route, HUD, prompt, and review fields.
static func audit_beats(
	capture_dir: String = "", capture_results: Dictionary = {}, review_records: Dictionary = {}
) -> Array[Dictionary]:
	var resolved_capture_dir: String = capture_dir
	if resolved_capture_dir.is_empty():
		resolved_capture_dir = "%s/%s" % [_run_dir(_run_id("")), CAPTURE_DIR_NAME]
	var manual_beats: Dictionary = _manual_beats_by_name()
	var visual_rows: Dictionary = _visual_rows_by_name()
	var out: Array[Dictionary] = []
	for spec: Dictionary in FirstMinuteAuditRouteContractScript.beat_specs():
		out.append(
			_build_beat(
				spec,
				manual_beats,
				visual_rows,
				resolved_capture_dir,
				capture_results,
				review_records
			)
		)
	return out


## Returns canonical actionable records for failed, missing, and known-fail beats.
static func punch_list(beats: Array[Dictionary]) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for beat: Dictionary in beats:
		var status: String = str(beat.get("status", ""))
		if not ACTIONABLE_STATUSES.has(status):
			continue
		out.append(
			{
				"beat_id": str(beat.get("beat_id", "")),
				"label": str(beat.get("label", "")),
				"status": status,
				"category": str(beat.get("category", "")),
				"severity": str(beat.get("severity", "")),
				"owner": str(beat.get("owner", "")),
				"acceptance": str(beat.get("acceptance", "")),
				"screenshot_path": str(beat.get("screenshot_path", "")),
				"summary": str(beat.get("summary", "")),
				"notes": str(beat.get("notes", "")),
			}
		)
	return out


## Writes JSON and Markdown artifacts under the canonical first-minute audit root.
static func write_artifact(
	run_id: String = "", capture_results: Dictionary = {}, review_records: Dictionary = {}
) -> Dictionary:
	var artifact: Dictionary = build_artifact(run_id, capture_results, review_records)
	var dir_result: Dictionary = AutomationArtifactsScript.ensure_artifact_dir(
		str(artifact.get("artifact_dir", ""))
	)
	if not bool(dir_result.get("ok", false)):
		return dir_result
	var capture_dir_result: Dictionary = AutomationArtifactsScript.ensure_artifact_dir(
		str(artifact.get("capture_dir", ""))
	)
	if not bool(capture_dir_result.get("ok", false)):
		return capture_dir_result
	var json_result: Dictionary = AutomationArtifactsScript.write_recorded_json(
		str(artifact.get("json_path", "")),
		artifact,
		"report",
		ARTIFACT_SUITE,
		"first_minute_audit",
		"json",
		"Cannot write first-minute audit JSON"
	)
	if not bool(json_result.get("ok", false)):
		return json_result
	var markdown_result: Dictionary = FirstMinuteAuditMarkdownScript.write(
		str(artifact.get("markdown_path", "")), artifact, ARTIFACT_SUITE
	)
	if not bool(markdown_result.get("ok", false)):
		return markdown_result
	return {
		"ok": true,
		"json_path": json_result.get("path", ""),
		"markdown_path": markdown_result.get("path", ""),
		"run_id": artifact.get("run_id", ""),
	}


static func _build_beat(
	spec: Dictionary,
	manual_beats: Dictionary,
	visual_rows: Dictionary,
	capture_dir: String,
	capture_results: Dictionary,
	review_records: Dictionary
) -> Dictionary:
	var beat_id: String = str(spec.get("beat_id", ""))
	var manual: Dictionary = manual_beats.get(str(spec.get("manual_beat", "")), {}) as Dictionary
	var visual: Dictionary = visual_rows.get(str(spec.get("visual_row", "")), {}) as Dictionary
	var review: Dictionary = review_records.get(beat_id, {}) as Dictionary
	var capture: Dictionary = capture_results.get(beat_id, {}) as Dictionary
	var filename: String = str(spec.get("filename", ""))
	var status: String = str(review.get("status", STATUS_PENDING))
	var screenshot_path: String = str(capture.get("path", ""))
	if screenshot_path.is_empty():
		screenshot_path = "%s/%s" % [capture_dir, filename]
	return {
		"beat_id": beat_id,
		"label": str(spec.get("label", "")),
		"status": status,
		"screenshot_path": screenshot_path,
		"target_timestamp_sec": int(spec.get("target_timestamp_sec", 0)),
		"required_within_first_minute": bool(spec.get("required", true)),
		"reach_policy": str(spec.get("reach_policy", "required")),
		"route_state": _route_state(spec, manual, visual),
		"hud_state": _hud_state(manual),
		"prompt_state": _prompt_state(spec, manual, visual),
		"interaction_target": _interaction_target(spec, visual),
		"visual_review_verdicts": _visual_review_verdicts(review, visual),
		"category": str(spec.get("category", "")),
		"severity": str(spec.get("severity", "")),
		"owner": str(spec.get("owner", "")),
		"acceptance": str(spec.get("acceptance", "")),
		"summary": str(review.get("summary", "")),
		"notes": str(review.get("notes", "")),
	}


static func _route_state(spec: Dictionary, manual: Dictionary, visual: Dictionary) -> Dictionary:
	return {
		"expected_stage":
		_first_non_empty(
			[
				spec.get("expected_stage", ""),
				manual.get("expected_stage", ""),
				visual.get("active_route_stage", ""),
			]
		),
		"expected_objective":
		_first_non_empty(
			[
				spec.get("expected_objective", ""),
				manual.get("expected_objective", ""),
			]
		),
		"next_expected_beat":
		_first_non_empty(
			[
				spec.get("next_expected_beat", ""),
				manual.get("next_expected_beat", ""),
				visual.get("next_expected_beat", ""),
			]
		),
	}


static func _hud_state(manual: Dictionary) -> Dictionary:
	return manual.get("hud_right_panel", {}) as Dictionary


static func _prompt_state(spec: Dictionary, manual: Dictionary, visual: Dictionary) -> Dictionary:
	return {
		"active_prompt":
		_first_non_empty(
			[
				spec.get("active_prompt", ""),
				manual.get("active_prompt", ""),
				visual.get("active_prompt", ""),
			]
		),
		"prompt_owner": str(spec.get("prompt_owner", "")),
	}


static func _interaction_target(spec: Dictionary, visual: Dictionary) -> Dictionary:
	var context: Dictionary = visual.get("action_context", {}) as Dictionary
	return {
		"target":
		_first_non_empty([spec.get("interaction_target", ""), context.get("active_target", "")]),
		"destination":
		_first_non_empty([spec.get("destination", ""), visual.get("next_destination", "")]),
	}


static func _visual_review_verdicts(review: Dictionary, visual: Dictionary) -> Dictionary:
	return {
		"review_status": str(review.get("visual_review_status", STATUS_PENDING)),
		"screenshot_matches_state": bool(review.get("screenshot_matches_state", false)),
		"route_readability": str(review.get("route_readability", STATUS_PENDING)),
		"hud_readability": str(review.get("hud_readability", STATUS_PENDING)),
		"prompt_readability": str(review.get("prompt_readability", STATUS_PENDING)),
		"visual_strengths": _visual_strengths(visual),
		"design_checks": visual.get("design_checks", StoreVisualSweepScript.route_design_checks()),
	}


static func _visual_strengths(visual: Dictionary) -> Array[String]:
	if visual.is_empty():
		return []
	var strengths: Array[String] = []
	strengths.append("primary surface: %s" % str(visual.get("primary_work_surface_target", "")))
	strengths.append("route anchor: %s" % str(visual.get("route_anchor", "")))
	strengths.append("local action: %s" % str(visual.get("local_action", "")))
	return strengths


static func _manual_beats_by_name() -> Dictionary:
	var out: Dictionary = {}
	for beat: Dictionary in ManualRouteScript.route_beats():
		out[str(beat.get("beat_name", ""))] = beat
	return out


static func _visual_rows_by_name() -> Dictionary:
	var out: Dictionary = {}
	for row: Dictionary in StoreVisualSweepScript.rows():
		out[str(row.get("name", ""))] = row
	return out


static func _first_non_empty(values: Array) -> String:
	for value: Variant in values:
		var text: String = str(value)
		if not text.strip_edges().is_empty():
			return text
	return ""


static func _run_id(run_id: String) -> String:
	if run_id.strip_edges().is_empty():
		return "first_minute_audit"
	return AutomationArtifactsScript.sanitize_slug(run_id)


static func _run_dir(run_id: String) -> String:
	return AutomationArtifactsScript.artifact_path(
		AutomationArtifactsScript.join_path([ARTIFACT_RELATIVE_DIR, run_id])
	)
