## Captures scenario checkpoint screenshots and adjacent metadata artifacts.
class_name ScenarioScreenshotCapture
extends RefCounted

const AutomationArtifactsScript: GDScript = preload(
	"res://game/scripts/core/automation_artifacts.gd"
)
const StoreVisualSweepScript: GDScript = preload(
	"res://game/scripts/store_session/store_visual_sweep.gd"
)

const METADATA_SCHEMA_VERSION: int = 1
const SCENARIO_SUITE: String = "scenario"
const CAPTURE_MODE_VIEWPORT: String = "viewport"
const CAPTURE_MODE_PLACEHOLDER: String = "placeholder"
const NON_ACCEPTANCE_REASON: String = "headless_placeholder"
const EVIDENCE_CHECKPOINTS: Array[String] = [
	"001_main_menu",
	"002_new_game_loaded",
	"003_tutorial_step_1",
	"004_first_movement",
	"005_store_ui_open",
	"006_stock_shelf",
	"007_customer_queue",
	"008_sale_complete",
	"009_save_reload",
]


## Returns the canonical BRAINDUMP evidence checkpoint names.
static func evidence_checkpoint_names() -> Array[String]:
	return EVIDENCE_CHECKPOINTS.duplicate()


## Returns the scenario screenshot directory for a scenario id.
static func scenario_dir(scenario_id: String) -> String:
	return AutomationArtifactsScript.scenario_screenshot_dir(scenario_id)


## Returns the deterministic screenshot filename for a checkpoint.
static func checkpoint_filename(checkpoint: String, index: int = 0) -> String:
	var slug: String = StoreVisualSweepScript.sanitize_slug(checkpoint)
	if _has_numeric_prefix(slug):
		return "%s.png" % slug
	if index > 0:
		return "%03d_%s.png" % [index, slug]
	return "%s.png" % slug


## Captures a viewport screenshot and writes adjacent JSON metadata.
static func capture_viewport(viewport: Viewport, options: Dictionary = {}) -> Dictionary:
	var scenario_id: String = str(options.get("scenario_id", "scenario"))
	var checkpoint: String = str(options.get("checkpoint", options.get("label", "checkpoint")))
	var filename: String = checkpoint_filename(checkpoint, int(options.get("index", 0)))
	var dir_path: String = str(options.get("dir_path", scenario_dir(scenario_id)))
	var intended_path: String = AutomationArtifactsScript.join_path([dir_path, filename])
	var allow_placeholder: bool = bool(options.get("allow_placeholder", false))
	var capture_result: Dictionary = StoreVisualSweepScript.save_viewport_png(
		viewport, dir_path, filename, allow_placeholder
	)
	if not bool(capture_result.get("ok", false)):
		AutomationArtifactsScript.record_missing_artifact(
			"screenshot",
			AutomationArtifactsScript.relative_path_for(intended_path),
			scenario_id,
			SCENARIO_SUITE,
			CAPTURE_MODE_VIEWPORT
		)
		capture_result["filename"] = filename
		capture_result["path"] = intended_path
		return capture_result

	var screenshot_path: String = str(capture_result.get("path", intended_path))
	var metadata_path: String = "%s.json" % screenshot_path.get_basename()
	var metadata: Dictionary = _metadata(capture_result, metadata_path, options)
	var metadata_result: Dictionary = AutomationArtifactsScript.write_recorded_json(
		metadata_path,
		metadata,
		"screenshot_metadata",
		scenario_id,
		SCENARIO_SUITE,
		"json",
		"cannot write screenshot metadata"
	)
	if not bool(metadata_result.get("ok", false)):
		return metadata_result
	_record_screenshot(screenshot_path, scenario_id, metadata)
	capture_result["metadata_path"] = metadata_path
	capture_result["metadata"] = metadata
	return capture_result


static func _metadata(
	capture_result: Dictionary, metadata_path: String, options: Dictionary
) -> Dictionary:
	var placeholder: bool = bool(capture_result.get("placeholder", false))
	var width: int = int(capture_result.get("width", 0))
	var height: int = int(capture_result.get("height", 0))
	var mode: String = CAPTURE_MODE_PLACEHOLDER if placeholder else CAPTURE_MODE_VIEWPORT
	return {
		"schema_version": METADATA_SCHEMA_VERSION,
		"scenario_id": str(options.get("scenario_id", "scenario")),
		"seed": str(options.get("seed", "")),
		"scene": str(options.get("scene", "")),
		"checkpoint": str(options.get("checkpoint", options.get("label", "checkpoint"))),
		"checkpoint_slug": str(capture_result.get("filename", "")).get_basename(),
		"screenshot_path": str(capture_result.get("path", "")),
		"metadata_path": metadata_path,
		"resolution": {"width": width, "height": height},
		"width": width,
		"height": height,
		"commit": _commit(),
		"assertion_counts": options.get("assertion_counts", _blank_assertion_counts()),
		"capture_mode": mode,
		"display_server": DisplayServer.get_name(),
		"placeholder": placeholder,
		"non_acceptance_evidence": placeholder,
		"non_acceptance_reason": NON_ACCEPTANCE_REASON if placeholder else "",
	}


static func _record_screenshot(
	screenshot_path: String, scenario_id: String, metadata: Dictionary
) -> void:
	var capture_mode: String = str(metadata.get("capture_mode", CAPTURE_MODE_VIEWPORT))
	AutomationArtifactsScript.record_artifact(
		"screenshot", screenshot_path, scenario_id, SCENARIO_SUITE, capture_mode
	)


static func _commit() -> String:
	var github_sha: String = OS.get_environment("GITHUB_SHA").strip_edges()
	if not github_sha.is_empty():
		return github_sha
	return "unknown"


static func _blank_assertion_counts() -> Dictionary:
	return {"total": 0, "passed": 0, "failed": 0}


static func _has_numeric_prefix(slug: String) -> bool:
	if slug.length() >= 3 and slug[2] == "_":
		for i: int in range(2):
			var two_digit_codepoint: int = slug.unicode_at(i)
			if two_digit_codepoint < 0x30 or two_digit_codepoint > 0x39:
				return false
		return true
	if slug.length() < 4 or slug[3] != "_":
		return false
	for i: int in range(3):
		var codepoint: int = slug.unicode_at(i)
		if codepoint < 0x30 or codepoint > 0x39:
			return false
	return true
