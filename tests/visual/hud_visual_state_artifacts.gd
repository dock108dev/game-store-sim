## Artifact writer for the HUD notification visual-state surface.
class_name HUDVisualStateArtifacts
extends RefCounted

const AutomationArtifactsScript: GDScript = preload(
	"res://game/scripts/core/automation_artifacts.gd"
)
const StoreVisualSweepScript: GDScript = preload(
	"res://game/scripts/store_session/store_visual_sweep.gd"
)

const METADATA_SCHEMA_VERSION: int = 1
const SURFACE_ID: String = "hud_notification_states"
const BASELINE_ROOT: String = "res://tests/baselines/hud_notification_states"
const BASELINE_MANIFEST_PATH: String = BASELINE_ROOT + "/baseline_manifest.json"


## Captures the rendered state and writes adjacent visual-state metadata.
static func capture_state(
	viewport: Viewport,
	state_id: String,
	viewport_size: Vector2i,
	layout_report: Dictionary,
	allow_placeholder: bool = false
) -> Dictionary:
	var filename := "%s_%dx%d.png" % [state_id, viewport_size.x, viewport_size.y]
	var dir_path: String = AutomationArtifactsScript.visual_sweep_screenshot_dir(SURFACE_ID)
	var result: Dictionary = StoreVisualSweepScript.save_viewport_png(
		viewport, dir_path, filename, allow_placeholder
	)
	var metadata_path: String = "%s/%s.json" % [
		dir_path,
		StoreVisualSweepScript.sanitize_slug(filename.get_basename()),
	]
	var baseline: Dictionary = soft_baseline_status(state_id, viewport_size, filename)
	if bool(result.get("ok", false)):
		var metadata := _capture_metadata(
			result, metadata_path, state_id, viewport_size, layout_report, baseline
		)
		var write_result: Dictionary = AutomationArtifactsScript.write_recorded_json(
			metadata_path,
			metadata,
			"visual_state_metadata",
			SURFACE_ID,
			"visual_sweep",
			"json",
			"Cannot write metadata"
		)
		if not bool(write_result.get("ok", false)):
			return write_result
		result["metadata_path"] = metadata_path
		result["metadata"] = metadata
	else:
		AutomationArtifactsScript.record_missing_artifact(
			"visual_state_screenshot",
			AutomationArtifactsScript.relative_path_for(str(result.get("path", ""))),
			SURFACE_ID,
			"visual_sweep",
			"viewport"
		)
	return result


## Returns the soft baseline status for a state/resolution capture.
static func soft_baseline_status(
	state_id: String, viewport_size: Vector2i, filename: String
) -> Dictionary:
	var path := "%s/%s/%dx%d/%s" % [
		BASELINE_ROOT,
		StoreVisualSweepScript.sanitize_slug(state_id),
		viewport_size.x,
		viewport_size.y,
		StoreVisualSweepScript.sanitize_slug(filename.get_basename()) + ".png",
	]
	var present := FileAccess.file_exists(path)
	return {
		"mode": "soft",
		"path": path,
		"present": present,
		"status": "present" if present else "missing_soft_baseline",
	}


## Reads the checked-in soft baseline manifest.
static func baseline_manifest() -> Dictionary:
	var file := FileAccess.open(BASELINE_MANIFEST_PATH, FileAccess.READ)
	if file == null:
		return {"ok": false, "error": "missing baseline manifest"}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed is not Dictionary:
		return {"ok": false, "error": "baseline manifest must be a JSON object"}
	var manifest := parsed as Dictionary
	manifest["ok"] = true
	return manifest


static func _capture_metadata(
	result: Dictionary,
	metadata_path: String,
	state_id: String,
	viewport_size: Vector2i,
	layout_report: Dictionary,
	baseline: Dictionary
) -> Dictionary:
	var placeholder: bool = bool(result.get("placeholder", false))
	return {
		"schema_version": METADATA_SCHEMA_VERSION,
		"visual_surface_id": SURFACE_ID,
		"state_id": state_id,
		"screenshot_path": str(result.get("path", "")),
		"metadata_path": metadata_path,
		"resolution": {"width": viewport_size.x, "height": viewport_size.y},
		"capture_width": int(result.get("width", 0)),
		"capture_height": int(result.get("height", 0)),
		"render_environment": {
			"display_server": DisplayServer.get_name(),
			"rendering_method": str(ProjectSettings.get_setting("rendering/renderer/rendering_method", "")),
			"engine_version": Engine.get_version_info(),
		},
		"placeholder": placeholder,
		"non_acceptance_evidence": placeholder,
		"baseline": baseline,
		"layout_report": layout_report,
	}
