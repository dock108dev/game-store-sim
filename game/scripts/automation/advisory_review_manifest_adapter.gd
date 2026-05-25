## Normalizes visual review manifest dialects into beat/frame records.
class_name AdvisoryReviewManifestAdapter
extends RefCounted

const AutomationArtifactsScript: GDScript = preload(
	"res://game/scripts/core/automation_artifacts.gd"
)

const KIND_STORE_VISUAL_SWEEP: String = "store_visual_sweep"
const KIND_MANUAL_ROUTE: String = "manual_day1_loop_route"
const KIND_GALLERY: String = "visual_gallery"
const KIND_VIDEO: String = "video_review"
const KIND_UNKNOWN: String = "unknown"

const DESIGN_CATEGORIES: Array[String] = [
	"visual_hierarchy",
	"route_readability",
	"signage_text_readability",
	"object_grounding",
	"placeholder_looking_geometry",
	"component_consistency",
	"excessive_visual_noise",
]


## Returns the manifest kind handled by the advisory report builder.
static func classify_manifest(manifest: Dictionary) -> String:
	var artifact_type: String = str(manifest.get("artifact_type", ""))
	if artifact_type == KIND_MANUAL_ROUTE:
		return KIND_MANUAL_ROUTE
	if artifact_type == KIND_STORE_VISUAL_SWEEP:
		return KIND_STORE_VISUAL_SWEEP
	if artifact_type == KIND_GALLERY:
		return KIND_GALLERY
	if artifact_type == KIND_VIDEO or artifact_type == "scenario_video":
		return KIND_VIDEO
	if manifest.has("video_path") or manifest.has("frames"):
		return KIND_VIDEO
	if manifest.has("gallery_id") and manifest.has("items") and manifest.has("state_beats"):
		return KIND_GALLERY
	if manifest.has("acceptance_target") and manifest.has("beats"):
		return KIND_STORE_VISUAL_SWEEP
	return KIND_UNKNOWN


## Normalizes supported manifest shapes into beat or frame review records.
static func normalize_manifest(manifest_path: String, manifest: Dictionary) -> Dictionary:
	var kind: String = classify_manifest(manifest)
	var source_dir: String = manifest_path.get_base_dir()
	var artifact_dir: String = _artifact_dir_for_manifest(manifest, source_dir)
	var normalized: Dictionary = {
		"manifest_kind": kind,
		"source_path": manifest_path,
		"source_dir": source_dir,
		"artifact_dir": artifact_dir,
		"schema_version": int(manifest.get("schema_version", 0)),
		"acceptance_target": str(manifest.get("acceptance_target", "")),
		"route_id": str(manifest.get("route_id", "")),
		"gallery_id": str(manifest.get("gallery_id", "")),
		"scenario_id": str(manifest.get("scenario_id", manifest.get("scenario", ""))),
		"criteria": _string_array(manifest.get("review_criteria", [])),
		"design_failure_criteria": _string_array(manifest.get("design_failure_criteria", [])),
		"design_categories": DESIGN_CATEGORIES.duplicate(),
		"beats": [],
	}
	match kind:
		KIND_STORE_VISUAL_SWEEP:
			normalized["beats"] = _normalize_sweep_beats(manifest, artifact_dir)
		KIND_MANUAL_ROUTE:
			normalized["beats"] = _normalize_manual_route_beats(manifest, artifact_dir)
		KIND_GALLERY:
			normalized["beats"] = _normalize_gallery_beats(manifest, artifact_dir)
		KIND_VIDEO:
			normalized["beats"] = _normalize_video_frames(manifest, artifact_dir)
		_:
			normalized["beats"] = []
	return normalized


static func _normalize_sweep_beats(manifest: Dictionary, artifact_dir: String) -> Array[Dictionary]:
	var captures: Array = manifest.get("captures", []) as Array
	var beats: Array[Dictionary] = []
	for beat_variant: Variant in manifest.get("beats", []) as Array:
		var beat: Dictionary = beat_variant as Dictionary
		var capture: Dictionary = _capture_for_beat(
			captures,
			str(beat.get("name", "")),
			str(beat.get("filename", ""))
		)
		var path: String = str(capture.get("path", ""))
		if path.is_empty():
			path = _resolve_path(artifact_dir, str(beat.get("filename", "")))
		beats.append(_normalized_record({
			"id": str(beat.get("name", "")),
			"index": int(beat.get("index", 0)),
			"label": str(beat.get("label", "")),
			"kind": "beat",
			"artifact_path": path,
			"scope": str(beat.get("scope", "")),
			"review_target": str(beat.get("review_target", "")),
			"expected_condition": str(beat.get("local_action", beat.get("next_destination", ""))),
			"criteria": _string_array(manifest.get("review_criteria", [])),
			"capture_result": capture,
		}))
	return beats


static func _normalize_manual_route_beats(
	manifest: Dictionary, artifact_dir: String
) -> Array[Dictionary]:
	var beats: Array[Dictionary] = []
	var capture_dir: String = str(manifest.get("capture_dir", ""))
	if capture_dir.is_empty():
		capture_dir = artifact_dir
	for beat_variant: Variant in manifest.get("beats", []) as Array:
		var beat: Dictionary = beat_variant as Dictionary
		var capture: Dictionary = beat.get("capture_result", {}) as Dictionary
		var path: String = str(capture.get("path", ""))
		if path.is_empty():
			path = _resolve_path(capture_dir, str(beat.get("filename", "")))
		beats.append(_normalized_record({
			"id": str(beat.get("beat_name", "")),
			"index": int(beat.get("index", 0)),
			"label": str(beat.get("label", "")),
			"kind": "beat",
			"artifact_path": path,
			"scope": "first_run_route",
			"review_target": str(beat.get("expected_stage", "")),
			"expected_condition": str(beat.get("active_prompt", "")),
			"criteria": _string_array(beat.get("automated_route_assertions", [])),
			"capture_result": capture,
		}))
	return beats


static func _normalize_gallery_beats(
	manifest: Dictionary, artifact_dir: String
) -> Array[Dictionary]:
	var captures: Array = manifest.get("captures", []) as Array
	var beats: Array[Dictionary] = []
	for beat_variant: Variant in manifest.get("state_beats", []) as Array:
		var beat: Dictionary = beat_variant as Dictionary
		var capture: Dictionary = _capture_for_beat(
			captures,
			str(beat.get("id", "")),
			str(beat.get("filename", ""))
		)
		var path: String = str(capture.get("path", ""))
		if path.is_empty():
			path = _resolve_path(artifact_dir, str(beat.get("filename", "")))
		beats.append(_normalized_record({
			"id": str(beat.get("id", "")),
			"index": beats.size() + 1,
			"label": str(beat.get("id", "")).capitalize().replace("_", " "),
			"kind": "beat",
			"artifact_path": path,
			"scope": "gallery",
			"review_target": str(beat.get("state", "")),
			"expected_condition": "Gallery state should be readable as secondary visual context.",
			"criteria": _string_array(manifest.get("review_flag_catalog", [])),
			"capture_result": capture,
		}))
	return beats


static func _normalize_video_frames(
	manifest: Dictionary, artifact_dir: String
) -> Array[Dictionary]:
	var video_path: String = _resolve_path(
		artifact_dir,
		str(manifest.get("video_path", manifest.get("movie_artifact", "")))
	)
	var frames: Array = manifest.get("frames", []) as Array
	if frames.is_empty():
		frames = [{"frame": int(manifest.get("frame", 0)), "id": "video"}]
	var beats: Array[Dictionary] = []
	for frame_variant: Variant in frames:
		var frame: Dictionary = frame_variant as Dictionary
		var frame_id: String = str(
			frame.get("id", "frame_%d" % int(frame.get("frame", beats.size() + 1)))
		)
		beats.append(_normalized_record({
			"id": frame_id,
			"index": beats.size() + 1,
			"label": str(frame.get("label", frame_id)),
			"kind": "frame",
			"artifact_path": video_path,
			"frame_reference": _frame_reference(frame),
			"scope": str(frame.get("scope", "video")),
			"review_target": str(frame.get("review_target", "")),
			"expected_condition": str(frame.get("expected_condition", "")),
			"criteria": _string_array(manifest.get("review_criteria", [])),
			"capture_result": {"ok": FileAccess.file_exists(video_path), "path": video_path},
		}))
	return beats


static func _normalized_record(values: Dictionary) -> Dictionary:
	var scope: String = str(values.get("scope", ""))
	return {
		"id": str(values.get("id", "")),
		"index": int(values.get("index", 0)),
		"label": str(values.get("label", "")),
		"kind": str(values.get("kind", "beat")),
		"artifact_path": str(values.get("artifact_path", "")),
		"frame_reference": str(values.get("frame_reference", "")),
		"scope": scope,
		"review_target": str(values.get("review_target", "")),
		"expected_condition": str(values.get("expected_condition", "")),
		"criteria": values.get("criteria", []),
		"capture_result": values.get("capture_result", {}),
		"secondary_context": scope == "gallery" or scope == "full_store",
	}


static func _capture_for_beat(captures: Array, beat_id: String, filename: String) -> Dictionary:
	for capture_variant: Variant in captures:
		var capture: Dictionary = capture_variant as Dictionary
		if str(capture.get("beat", "")) == beat_id:
			return capture
		if str(capture.get("filename", "")) == filename:
			return capture
	return {}


static func _artifact_dir_for_manifest(manifest: Dictionary, source_dir: String) -> String:
	var manifest_dir: String = str(manifest.get("artifact_dir", ""))
	if manifest_dir.is_empty():
		manifest_dir = str(manifest.get("capture_dir", ""))
	if manifest_dir.is_empty():
		return source_dir
	return manifest_dir


static func _resolve_path(base_dir: String, path: String) -> String:
	if path.is_empty():
		return ""
	if path.begins_with("/") or path.begins_with("user://") or path.begins_with("res://") \
			or path.contains(":/"):
		return path
	return AutomationArtifactsScript.join_path([base_dir, path])


static func _frame_reference(frame: Dictionary) -> String:
	if frame.has("time_seconds"):
		return "%.2fs" % float(frame.get("time_seconds", 0.0))
	if frame.has("frame"):
		return "frame %d" % int(frame.get("frame", 0))
	return ""


static func _string_array(value: Variant) -> Array[String]:
	var out: Array[String] = []
	if value is Array:
		for item: Variant in value:
			out.append(str(item))
	return out
