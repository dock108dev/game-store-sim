## Writes structured scenario reports into the repo-local artifact tree.
class_name ScenarioArtifactWriter
extends RefCounted

const ARTIFACTS_SCRIPT: GDScript = preload("res://game/scripts/core/automation_artifacts.gd")


## Persists a JSON run report and records it in the aggregate artifact manifest.
func write_run_report(result: Dictionary) -> Dictionary:
	var scenario_id: String = str(result.get("scenario_id", "unknown"))
	var run_id: String = str(result.get("run_id", "run"))
	var dir_path: String = ARTIFACTS_SCRIPT.report_dir("scenario", scenario_id)
	var dir_result: Dictionary = ARTIFACTS_SCRIPT.ensure_artifact_dir(dir_path)
	if not bool(dir_result.get("ok", false)):
		return dir_result
	var path: String = ARTIFACTS_SCRIPT.join_path([dir_path, "%s-run.json" % run_id])
	return ARTIFACTS_SCRIPT.write_recorded_json(
		path,
		result,
		"scenario_report",
		scenario_id,
		"scenario",
		"json",
		"cannot write report"
	)
