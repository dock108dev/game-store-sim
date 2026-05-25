## Builds advisory visual review reports from screenshot, route, gallery, or video manifests.
class_name AdvisoryReviewReport
extends RefCounted

const AutomationArtifactsScript: GDScript = preload(
	"res://game/scripts/core/automation_artifacts.gd"
)
const ManifestAdapterScript: GDScript = preload(
	"res://game/scripts/automation/advisory_review_manifest_adapter.gd"
)
const MarkdownScript: GDScript = preload(
	"res://game/scripts/automation/advisory_review_markdown.gd"
)

const SCHEMA_VERSION: int = 1
const REPORT_TYPE: String = "advisory_ai_visual_review"
const JSON_FILENAME: String = "ai_review_report.json"
const MARKDOWN_FILENAME: String = "ai_review_report.md"

const KIND_STORE_VISUAL_SWEEP: String = "store_visual_sweep"
const KIND_MANUAL_ROUTE: String = "manual_day1_loop_route"
const KIND_GALLERY: String = "visual_gallery"
const KIND_VIDEO: String = "video_review"
const KIND_UNKNOWN: String = "unknown"

const STATUS_COMPLETE_NO_FINDINGS: String = "complete_no_findings"
const STATUS_COMPLETE_WITH_FINDINGS: String = "complete_with_findings"
const STATUS_NEEDS_HUMAN_INTERPRETATION: String = "needs_human_interpretation"

const VERDICT_NO_FINDINGS: String = "no_advisory_findings_recorded"
const VERDICT_NEEDS_HUMAN_REVIEW: String = "needs_human_review"
const VERDICT_NEEDS_HUMAN_INTERPRETATION: String = "needs_human_interpretation"

const SEVERITY_INFO: String = "info"
const SEVERITY_LOW: String = "low"
const SEVERITY_MEDIUM: String = "medium"
const SEVERITY_HIGH: String = "high"

const ACTION_INSPECT_ARTIFACT: String = "inspect artifact"
const ACTION_COMPARE_BASELINE: String = "compare baseline"
const ACTION_RERUN_CAPTURE: String = "rerun capture"
const ACTION_FIX_SOURCE_SCENE: String = "fix source scene"
const ACTION_IGNORE_ADVISORY: String = "ignore as advisory"

const CATEGORY_SCHEMA: String = "schema"
const CATEGORY_CAPTURE_QUALITY: String = "capture_quality"
const CATEGORY_VISUAL_HIERARCHY: String = "visual_hierarchy"
const CATEGORY_ROUTE_READABILITY: String = "route_readability"
const CATEGORY_SIGNAGE_TEXT_READABILITY: String = "signage_text_readability"
const CATEGORY_OBJECT_GROUNDING: String = "object_grounding"
const CATEGORY_PLACEHOLDER_GEOMETRY: String = "placeholder_looking_geometry"
const CATEGORY_COMPONENT_CONSISTENCY: String = "component_consistency"
const CATEGORY_EXCESSIVE_VISUAL_NOISE: String = "excessive_visual_noise"

const DESIGN_CATEGORIES: Array[String] = [
	CATEGORY_VISUAL_HIERARCHY,
	CATEGORY_ROUTE_READABILITY,
	CATEGORY_SIGNAGE_TEXT_READABILITY,
	CATEGORY_OBJECT_GROUNDING,
	CATEGORY_PLACEHOLDER_GEOMETRY,
	CATEGORY_COMPONENT_CONSISTENCY,
	CATEGORY_EXCESSIVE_VISUAL_NOISE,
]

const _SEVERITY_RANK: Dictionary = {
	SEVERITY_INFO: 0,
	SEVERITY_LOW: 1,
	SEVERITY_MEDIUM: 2,
	SEVERITY_HIGH: 3,
}


## Returns the manifest kind handled by the advisory report builder.
static func classify_manifest(manifest: Dictionary) -> String:
	return ManifestAdapterScript.classify_manifest(manifest)


## Normalizes supported manifest shapes into beat or frame review records.
static func normalize_manifest(manifest_path: String, manifest: Dictionary) -> Dictionary:
	return ManifestAdapterScript.normalize_manifest(manifest_path, manifest)


## Builds a schema-valid report without writing files.
static func build_empty_report(normalized_manifest: Dictionary) -> Dictionary:
	return _build_report_from_findings(normalized_manifest, [])


## Builds an advisory report and adds deterministic schema/capture-quality findings.
static func build_report(
	normalized_manifest: Dictionary,
	observations: Array = []
) -> Dictionary:
	var findings: Array[Dictionary] = []
	var kind: String = str(normalized_manifest.get("manifest_kind", KIND_UNKNOWN))
	if kind == KIND_UNKNOWN:
		findings.append(
			_schema_finding(
				"manifest",
				"",
				"Manifest shape is not recognized by the advisory review report builder.",
				"Source manifest must identify as a visual sweep, route, gallery, or video manifest.",
				ACTION_INSPECT_ARTIFACT,
				1
			)
		)
	var beats: Array = normalized_manifest.get("beats", []) as Array
	for beat_variant: Variant in beats:
		var beat: Dictionary = beat_variant as Dictionary
		_append_capture_quality_findings(findings, beat)
	for observation: Dictionary in observations:
		findings.append(_finding_from_observation(observation, normalized_manifest, findings.size() + 1))
	return _build_report_from_findings(normalized_manifest, findings)


## Writes JSON and Markdown advisory reports beside the source manifest by default.
static func write_reports(
	manifest_path: String,
	manifest: Dictionary,
	output_dir: String = "",
	observations: Array = []
) -> Dictionary:
	var normalized: Dictionary = normalize_manifest(manifest_path, manifest)
	var report: Dictionary = build_report(normalized, observations)
	var resolved_dir: String = output_dir
	if resolved_dir.is_empty():
		resolved_dir = manifest_path.get_base_dir()
	var dir_result: Dictionary = AutomationArtifactsScript.ensure_artifact_dir(resolved_dir)
	if not bool(dir_result.get("ok", false)):
		return dir_result
	resolved_dir = str(dir_result.get("path", resolved_dir))
	var json_path: String = AutomationArtifactsScript.join_path([resolved_dir, JSON_FILENAME])
	var markdown_path: String = AutomationArtifactsScript.join_path([resolved_dir, MARKDOWN_FILENAME])
	var json_result: Dictionary = AutomationArtifactsScript.write_recorded_json(
		json_path,
		report,
		"advisory_review_report",
		_review_scenario(report),
		_review_suite(report),
		"json",
		"Cannot write advisory review JSON"
	)
	if not bool(json_result.get("ok", false)):
		return json_result
	var markdown_result: Dictionary = _write_markdown(markdown_path, report)
	if not bool(markdown_result.get("ok", false)):
		return markdown_result
	return {
		"ok": true,
		"json_path": json_path,
		"markdown_path": markdown_path,
		"report": report,
	}


static func _build_report_from_findings(
	normalized_manifest: Dictionary,
	findings: Array[Dictionary]
) -> Dictionary:
	var highest: String = _highest_severity(findings)
	var status: String = STATUS_COMPLETE_NO_FINDINGS
	var verdict: String = VERDICT_NO_FINDINGS
	if not findings.is_empty():
		if highest == SEVERITY_INFO:
			status = STATUS_NEEDS_HUMAN_INTERPRETATION
			verdict = VERDICT_NEEDS_HUMAN_INTERPRETATION
		else:
			status = STATUS_COMPLETE_WITH_FINDINGS
			verdict = VERDICT_NEEDS_HUMAN_REVIEW
	var beats: Array = normalized_manifest.get("beats", []) as Array
	return {
		"schema_version": SCHEMA_VERSION,
		"report_type": REPORT_TYPE,
		"source_manifest": {
			"path": str(normalized_manifest.get("source_path", "")),
			"artifact_type": str(normalized_manifest.get("manifest_kind", KIND_UNKNOWN)),
			"schema_version": int(normalized_manifest.get("schema_version", 0)),
			"route_id": str(normalized_manifest.get("route_id", "")),
			"gallery_id": str(normalized_manifest.get("gallery_id", "")),
			"scenario_id": str(normalized_manifest.get("scenario_id", "")),
			"acceptance_target": str(normalized_manifest.get("acceptance_target", "")),
		},
		"advisory_only": true,
		"advisory_policy": (
			"Advisory review surfaces risks for human inspection; it never replaces tests, "
			+ "source manifests, or human acceptance for visual taste."
		),
		"review_status": status,
		"overall_advisory_verdict": verdict,
		"highest_severity": highest,
		"beats_or_frames_reviewed": _reviewed_records(beats),
		"reviewed_count": beats.size(),
		"finding_counts": _finding_counts(findings),
		"design_categories": DESIGN_CATEGORIES.duplicate(),
		"findings": findings,
	}


static func _append_capture_quality_findings(findings: Array[Dictionary], beat: Dictionary) -> void:
	var path: String = str(beat.get("artifact_path", ""))
	var kind: String = str(beat.get("kind", "beat"))
	var capture: Dictionary = beat.get("capture_result", {}) as Dictionary
	var next_id: int = findings.size() + 1
	if not bool(capture.get("ok", true)):
		var error: String = str(capture.get("error", "Capture failed."))
		var criterion: String = "capture_quality.headless_capture_failure"
		if not error.to_lower().contains("headless"):
			criterion = "capture_quality.capture_failed"
		findings.append(
			_capture_finding(
				beat,
				criterion,
				"Capture failed (%s); no visual observation was made." % error,
				"Capture must complete before visual review.",
				ACTION_RERUN_CAPTURE,
				next_id
			)
		)
		next_id += 1
	if bool(capture.get("placeholder", false)):
		findings.append(
			_capture_finding(
				beat,
				"capture_quality.placeholder_artifact",
				"Artifact is marked as a placeholder; no visual observation was made.",
				"Review artifacts must come from a rendered capture, not placeholder evidence.",
				ACTION_RERUN_CAPTURE,
				next_id
			)
		)
		next_id += 1
	if path.is_empty():
		findings.append(
			_schema_finding(
				str(beat.get("id", "")),
				str(beat.get("frame_reference", "")),
				"Artifact path is missing.",
				"Every reviewed beat or frame must point to an artifact path.",
				ACTION_INSPECT_ARTIFACT,
				next_id
			)
		)
		return
	if not FileAccess.file_exists(path):
		var criterion_missing: String = (
			"capture_quality.missing_video"
			if kind == "frame"
			else "capture_quality.missing_image"
		)
		findings.append(
			_capture_finding(
				beat,
				criterion_missing,
				"Expected artifact is missing; no visual observation was made.",
				"Artifact file must exist before advisory interpretation.",
				ACTION_RERUN_CAPTURE,
				next_id
			)
		)
		return
	if kind == "frame":
		var file: FileAccess = FileAccess.open(path, FileAccess.READ)
		if file == null or file.get_length() <= 0:
			findings.append(
				_capture_finding(
					beat,
					"capture_quality.unreadable_video",
					"Video artifact is empty or unreadable; no visual observation was made.",
					"Video artifact must be readable and non-empty.",
					ACTION_RERUN_CAPTURE,
					next_id
				)
			)
		if file != null:
			file.close()
		return
	if path.to_lower().ends_with(".png") and not _has_png_signature(path):
		findings.append(
			_capture_finding(
				beat,
				"capture_quality.unreadable_image",
				"Image artifact is unreadable or corrupt; no visual observation was made.",
				"Image artifact must load as a readable image.",
				ACTION_RERUN_CAPTURE,
				next_id
			)
		)
		return
	var image := Image.new()
	var load_err: int = image.load(path)
	if load_err != OK or image.get_width() <= 0 or image.get_height() <= 0:
		findings.append(
			_capture_finding(
				beat,
				"capture_quality.unreadable_image",
				"Image artifact is unreadable or corrupt; no visual observation was made.",
				"Image artifact must load as a readable image.",
				ACTION_RERUN_CAPTURE,
				next_id
			)
		)


static func _finding_from_observation(
	observation: Dictionary,
	normalized_manifest: Dictionary,
	index: int
) -> Dictionary:
	var beat_id: String = str(observation.get("beat", observation.get("beat_id", "")))
	var beat: Dictionary = _beat_by_id(normalized_manifest.get("beats", []) as Array, beat_id)
	var confidence: float = clampf(float(observation.get("confidence", 0.0)), 0.0, 1.0)
	var severity: String = _valid_severity(str(observation.get("severity", SEVERITY_INFO)))
	var needs_human: bool = (
		confidence < 0.5 or bool(observation.get("needs_human_interpretation", false))
	)
	if needs_human:
		severity = SEVERITY_INFO
	var category: String = _valid_category(str(observation.get("category", "")))
	var finding: Dictionary = {
		"id": _finding_id("visual", index),
		"severity": severity,
		"confidence": confidence,
		"needs_human_interpretation": needs_human,
		"beat": str(beat.get("id", beat_id)),
		"frame": str(observation.get("frame", beat.get("frame_reference", ""))),
		"criterion_id": str(observation.get("criterion_id", category)),
		"category": category,
		"artifact_path": str(observation.get("artifact_path", beat.get("artifact_path", ""))),
		"frame_reference": str(observation.get("frame_reference", beat.get("frame_reference", ""))),
		"observation": str(observation.get("observation", "")),
		"expected_condition": str(
			observation.get("expected_condition", beat.get("expected_condition", ""))
		),
		"recommendation": str(
			observation.get("recommendation", "Inspect the artifact before making a design change.")
		),
		"next_human_action": _valid_action(
			str(observation.get("next_human_action", ACTION_INSPECT_ARTIFACT))
		),
		"visual_observation": true,
		"secondary_context": _is_secondary_context(normalized_manifest, beat, observation),
	}
	if needs_human and finding["recommendation"].is_empty():
		finding["recommendation"] = "Ask a human reviewer to inspect the artifact."
	return finding


static func _capture_finding(
	beat: Dictionary,
	criterion_id: String,
	observation: String,
	expected_condition: String,
	action: String,
	index: int
) -> Dictionary:
	return {
		"id": _finding_id("capture", index),
		"severity": SEVERITY_MEDIUM,
		"confidence": 1.0,
		"needs_human_interpretation": false,
		"beat": str(beat.get("id", "")),
		"frame": str(beat.get("frame_reference", "")),
		"criterion_id": criterion_id,
		"category": CATEGORY_CAPTURE_QUALITY,
		"artifact_path": str(beat.get("artifact_path", "")),
		"frame_reference": str(beat.get("frame_reference", "")),
		"observation": observation,
		"expected_condition": expected_condition,
		"recommendation": "Rerun capture before judging visual quality.",
		"next_human_action": action,
		"visual_observation": false,
		"secondary_context": bool(beat.get("secondary_context", false)),
	}


static func _schema_finding(
	beat_id: String,
	frame_reference: String,
	observation: String,
	expected_condition: String,
	action: String,
	index: int
) -> Dictionary:
	return {
		"id": _finding_id("schema", index),
		"severity": SEVERITY_MEDIUM,
		"confidence": 1.0,
		"needs_human_interpretation": false,
		"beat": beat_id,
		"frame": frame_reference,
		"criterion_id": "schema.required_artifact_reference",
		"category": CATEGORY_SCHEMA,
		"artifact_path": "",
		"frame_reference": frame_reference,
		"observation": observation,
		"expected_condition": expected_condition,
		"recommendation": "Inspect the manifest schema before visual review.",
		"next_human_action": action,
		"visual_observation": false,
		"secondary_context": false,
	}


static func _write_markdown(path: String, report: Dictionary) -> Dictionary:
	var dir_result: Dictionary = AutomationArtifactsScript.ensure_artifact_dir(path.get_base_dir())
	if not bool(dir_result.get("ok", false)):
		return dir_result
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "error": "Cannot write advisory review Markdown: %s" % path}
	file.store_string(markdown_report(report))
	file.close()
	var manifest_result: Dictionary = AutomationArtifactsScript.record_artifact(
		"advisory_review_report",
		path,
		_review_scenario(report),
		_review_suite(report),
		"markdown"
	)
	if not bool(manifest_result.get("ok", false)):
		return manifest_result
	return {"ok": true, "path": path, "absolute_path": AutomationArtifactsScript.absolute_path(path)}


## Returns the Markdown summary for a report payload.
static func markdown_report(report: Dictionary) -> String:
	return MarkdownScript.markdown_report(report)


static func _reviewed_records(beats: Array) -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	for beat_variant: Variant in beats:
		var beat: Dictionary = beat_variant as Dictionary
		records.append({
			"id": str(beat.get("id", "")),
			"kind": str(beat.get("kind", "beat")),
			"artifact_path": str(beat.get("artifact_path", "")),
			"frame_reference": str(beat.get("frame_reference", "")),
			"secondary_context": bool(beat.get("secondary_context", false)),
		})
	return records


static func _finding_counts(findings: Array[Dictionary]) -> Dictionary:
	var counts: Dictionary = {
		"total": findings.size(),
		SEVERITY_HIGH: 0,
		SEVERITY_MEDIUM: 0,
		SEVERITY_LOW: 0,
		SEVERITY_INFO: 0,
	}
	for finding: Dictionary in findings:
		var severity: String = _valid_severity(str(finding.get("severity", SEVERITY_INFO)))
		counts[severity] = int(counts.get(severity, 0)) + 1
	return counts


static func _highest_severity(findings: Array[Dictionary]) -> String:
	var highest: String = SEVERITY_INFO
	for finding: Dictionary in findings:
		var severity: String = _valid_severity(str(finding.get("severity", SEVERITY_INFO)))
		if int(_SEVERITY_RANK.get(severity, 0)) > int(_SEVERITY_RANK.get(highest, 0)):
			highest = severity
	return highest


static func _has_png_signature(path: String) -> bool:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false
	var header: PackedByteArray = file.get_buffer(8)
	file.close()
	if header.size() < 8:
		return false
	return header[0] == 0x89 and header[1] == 0x50 and header[2] == 0x4E \
		and header[3] == 0x47 and header[4] == 0x0D and header[5] == 0x0A \
		and header[6] == 0x1A and header[7] == 0x0A


static func _valid_severity(value: String) -> String:
	if _SEVERITY_RANK.has(value):
		return value
	return SEVERITY_INFO


static func _valid_category(value: String) -> String:
	if DESIGN_CATEGORIES.has(value):
		return value
	return CATEGORY_VISUAL_HIERARCHY


static func _valid_action(value: String) -> String:
	var allowed: Array[String] = [
		ACTION_INSPECT_ARTIFACT,
		ACTION_COMPARE_BASELINE,
		ACTION_RERUN_CAPTURE,
		ACTION_FIX_SOURCE_SCENE,
		ACTION_IGNORE_ADVISORY,
	]
	if allowed.has(value):
		return value
	return ACTION_INSPECT_ARTIFACT


static func _beat_by_id(beats: Array, beat_id: String) -> Dictionary:
	for beat_variant: Variant in beats:
		var beat: Dictionary = beat_variant as Dictionary
		if str(beat.get("id", "")) == beat_id:
			return beat
	return {}


static func _is_secondary_context(
	normalized_manifest: Dictionary,
	beat: Dictionary,
	observation: Dictionary
) -> bool:
	if bool(observation.get("affects_first_run", false)):
		return false
	if str(normalized_manifest.get("manifest_kind", "")) == KIND_GALLERY:
		return true
	if bool(beat.get("secondary_context", false)):
		return true
	return str(beat.get("review_target", "")) == "full_store_context"


static func _finding_id(prefix: String, index: int) -> String:
	return "%s_%03d" % [prefix, index]


static func _review_scenario(report: Dictionary) -> String:
	var source: Dictionary = report.get("source_manifest", {}) as Dictionary
	for key: String in ["route_id", "gallery_id", "scenario_id", "acceptance_target"]:
		var value: String = str(source.get(key, ""))
		if not value.is_empty():
			return value
	return str(source.get("artifact_type", "advisory_review"))


static func _review_suite(report: Dictionary) -> String:
	var source: Dictionary = report.get("source_manifest", {}) as Dictionary
	return str(source.get("artifact_type", "advisory_review"))
