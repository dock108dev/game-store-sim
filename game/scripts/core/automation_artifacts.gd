## Resolves and records repo-local automation artifacts.
class_name AutomationArtifacts
extends RefCounted

const ENV_ARTIFACT_DIR: String = "MALLCORE_ARTIFACT_DIR"
const ENV_WORKSPACE: String = "GITHUB_WORKSPACE"
const MANIFEST_RELATIVE_PATH: String = "manifests/artifact_manifest.json"
const STATUS_GENERATED: String = "generated"
const STATUS_MISSING: String = "missing"
const _SCHEMA_VERSION: int = 1
const _MAX_SLUG_LENGTH: int = 64


## Returns the artifact root using env, CI workspace, repo, then Godot user fallback.
static func artifact_root() -> String:
	var configured: String = _clean_root(OS.get_environment(ENV_ARTIFACT_DIR))
	if not configured.is_empty():
		return configured
	var workspace: String = _clean_root(OS.get_environment(ENV_WORKSPACE))
	if not workspace.is_empty():
		return join_path([workspace, "artifacts"])
	var repo_root: String = _clean_root(ProjectSettings.globalize_path("res://"))
	if not repo_root.is_empty():
		return join_path([repo_root, "artifacts"])
	return "user://artifacts"


## Returns an artifact-root-relative path resolved to a writable path.
static func artifact_path(relative_path: String = "") -> String:
	return join_path([artifact_root(), relative_path])


## Joins path parts without allowing empty segments to introduce duplicate slashes.
static func join_path(parts: Array) -> String:
	var out: String = ""
	for raw_part: Variant in parts:
		var part: String = str(raw_part).strip_edges()
		if part.is_empty():
			continue
		if out.is_empty():
			out = _trim_trailing_slashes(part)
		else:
			out = "%s/%s" % [_trim_trailing_slashes(out), _trim_leading_slashes(part)]
	return out


## Ensures an artifact directory exists and returns path details.
static func ensure_artifact_dir(relative_or_full_path: String = "") -> Dictionary:
	var path: String = relative_or_full_path
	if path.is_empty():
		path = artifact_root()
	elif not _is_full_path(path):
		path = artifact_path(path)
	var dir_err: int = DirAccess.make_dir_recursive_absolute(path)
	if dir_err != OK and dir_err != ERR_ALREADY_EXISTS:
		return _error("Cannot create %s (err=%d)" % [path, dir_err])
	return {
		"ok": true,
		"path": path,
		"relative_path": relative_path_for(path),
		"absolute_path": absolute_path(path),
	}


## Returns the stable artifact subpath map used by automation and CI upload rules.
static func artifact_subpaths() -> Dictionary:
	return {
		"logs": "logs",
		"gut_logs": "logs/gut",
		"static_validation_logs": "logs/static-validation",
		"scenario_logs": "logs/scenario",
		"scenario_screenshots": "screenshots/scenario",
		"visual_sweep_screenshots": "screenshots/visual_sweep",
		"gallery_screenshots": "screenshots/gallery",
		"scenario_reports": "reports/scenario",
		"visual_sweep_reports": "reports/visual_sweep",
		"junit": "junit",
		"scenario_videos": "videos/scenario",
		"manifests": "manifests",
		"artifact_manifest": MANIFEST_RELATIVE_PATH,
	}


## Returns a suite log directory under artifacts/logs.
static func log_dir(suite: String = "") -> String:
	if suite.is_empty():
		return artifact_path("logs")
	return artifact_path(join_path(["logs", sanitize_slug(suite)]))


## Returns the JUnit XML path for a suite.
static func junit_path(suite: String) -> String:
	return artifact_path(join_path(["junit", "%s.xml" % sanitize_slug(suite)]))


## Returns a report directory for a suite and optional scenario.
static func report_dir(suite: String, scenario: String = "") -> String:
	if scenario.is_empty():
		return artifact_path(join_path(["reports", sanitize_slug(suite)]))
	return artifact_path(join_path(["reports", sanitize_slug(suite), sanitize_slug(scenario)]))


## Returns a scenario screenshot directory.
static func scenario_screenshot_dir(scenario: String) -> String:
	return artifact_path(join_path(["screenshots/scenario", sanitize_slug(scenario)]))


## Returns a visual sweep screenshot directory.
static func visual_sweep_screenshot_dir(suite: String) -> String:
	return artifact_path(join_path(["screenshots/visual_sweep", sanitize_slug(suite)]))


## Returns a gallery screenshot directory.
static func gallery_dir(gallery: String) -> String:
	return artifact_path(join_path(["screenshots/gallery", sanitize_slug(gallery)]))


## Returns a scenario video path.
static func scenario_video_path(scenario: String, extension: String = "avi") -> String:
	var clean_extension: String = sanitize_slug(extension).replace("_", "")
	if clean_extension.is_empty():
		clean_extension = "avi"
	return artifact_path(join_path(["videos/scenario", "%s.%s" % [
		sanitize_slug(scenario),
		clean_extension,
	]]))


## Returns the aggregate artifact manifest path.
static func manifest_path() -> String:
	return artifact_path(MANIFEST_RELATIVE_PATH)


## Converts a full artifact path into an artifact-root-relative path when possible.
static func relative_path_for(path: String) -> String:
	var clean_path: String = _clean_root(path)
	var root: String = _clean_root(artifact_root())
	if clean_path == root:
		return ""
	if clean_path.begins_with("%s/" % root):
		return clean_path.substr(root.length() + 1)
	return _trim_leading_slashes(clean_path)


## Returns a globalized filesystem path for Godot virtual paths.
static func absolute_path(path: String) -> String:
	if path.begins_with("user://") or path.begins_with("res://"):
		return ProjectSettings.globalize_path(path)
	return path


## Records a generated artifact in the aggregate manifest.
static func record_artifact(
	artifact_type: String,
	path: String,
	scenario: String = "",
	suite: String = "",
	capture_mode: String = "",
	generation_status: String = STATUS_GENERATED
) -> Dictionary:
	var manifest_dir_result: Dictionary = ensure_artifact_dir("manifests")
	if not bool(manifest_dir_result.get("ok", false)):
		return manifest_dir_result
	var manifest: Dictionary = _load_manifest()
	var entry: Dictionary = _entry(
		artifact_type,
		path,
		scenario,
		suite,
		capture_mode,
		generation_status
	)
	_upsert_entry(manifest, entry)
	return _write_manifest(manifest)


## Records an expected artifact that was not produced.
static func record_missing_artifact(
	artifact_type: String,
	relative_path: String,
	scenario: String = "",
	suite: String = "",
	capture_mode: String = ""
) -> Dictionary:
	return record_artifact(
		artifact_type,
		artifact_path(relative_path),
		scenario,
		suite,
		capture_mode,
		STATUS_MISSING
	)


## Writes JSON artifact payloads after ensuring the destination directory exists.
static func write_json(
	path: String,
	payload: Dictionary,
	error_prefix: String = "Cannot write JSON"
) -> Dictionary:
	var dir_result: Dictionary = ensure_artifact_dir(path.get_base_dir())
	if not bool(dir_result.get("ok", false)):
		return dir_result
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return _error("%s: %s" % [error_prefix, path])
	file.store_string(JSON.stringify(payload, "\t"))
	file.close()
	return {"ok": true, "path": path}


## Writes a JSON payload and records it in the aggregate artifact manifest.
static func write_recorded_json(
	path: String,
	payload: Dictionary,
	artifact_type: String,
	scenario: String = "",
	suite: String = "",
	capture_mode: String = "json",
	error_prefix: String = "Cannot write JSON"
) -> Dictionary:
	var write_result: Dictionary = write_json(path, payload, error_prefix)
	if not bool(write_result.get("ok", false)):
		write_result["path"] = path
		return write_result
	var manifest_result: Dictionary = record_artifact(
		artifact_type,
		path,
		scenario,
		suite,
		capture_mode
	)
	if not bool(manifest_result.get("ok", false)):
		return manifest_result
	return {
		"ok": true,
		"path": path,
		"absolute_path": absolute_path(path),
		"relative_path": relative_path_for(path),
	}


## Sanitizes one path segment for suite, scenario, and file stems.
static func sanitize_slug(raw: String, max_length: int = _MAX_SLUG_LENGTH) -> String:
	var lowered: String = raw.strip_edges().to_lower()
	var sanitized: String = ""
	var previous_was_separator: bool = false
	for i: int in range(lowered.length()):
		var codepoint: int = lowered.unicode_at(i)
		var allowed: bool = (codepoint >= 0x30 and codepoint <= 0x39) \
			or (codepoint >= 0x61 and codepoint <= 0x7A)
		var separator: bool = codepoint == 0x20 or codepoint == 0x2D \
			or codepoint == 0x5F or codepoint == 0x2F or codepoint == 0x5C
		if allowed:
			sanitized += char(codepoint)
			previous_was_separator = false
		elif separator and not previous_was_separator:
			sanitized += "_"
			previous_was_separator = true
	if sanitized.ends_with("_"):
		sanitized = sanitized.substr(0, sanitized.length() - 1)
	if sanitized.is_empty():
		sanitized = "default"
	if max_length > 0 and sanitized.length() > max_length:
		sanitized = sanitized.substr(0, max_length)
	return sanitized


## Sanitizes a filename stem while preserving the older screenshot fallback.
static func sanitize_filename_slug(
	raw: String,
	max_length: int = _MAX_SLUG_LENGTH,
	fallback: String = "screenshot"
) -> String:
	var lowered: String = raw.get_basename().to_lower()
	var sanitized: String = ""
	for i: int in range(lowered.length()):
		var codepoint: int = lowered.unicode_at(i)
		if (codepoint >= 0x30 and codepoint <= 0x39) \
				or (codepoint >= 0x61 and codepoint <= 0x7A) \
				or codepoint == 0x5F:
			sanitized += char(codepoint)
		elif codepoint == 0x20 or codepoint == 0x2D:
			sanitized += "_"
	if sanitized.is_empty():
		sanitized = fallback
	if max_length > 0 and sanitized.length() > max_length:
		sanitized = sanitized.substr(0, max_length)
	return sanitized


static func _entry(
	artifact_type: String,
	path: String,
	scenario: String,
	suite: String,
	capture_mode: String,
	generation_status: String
) -> Dictionary:
	return {
		"type": artifact_type,
		"scenario": scenario,
		"suite": suite,
		"relative_path": relative_path_for(path),
		"absolute_path": absolute_path(path),
		"size": _file_size(path),
		"capture_mode": capture_mode,
		"generation_status": generation_status,
		"generated_at": _timestamp(),
	}


static func _load_manifest() -> Dictionary:
	var path: String = manifest_path()
	if not FileAccess.file_exists(path):
		return _blank_manifest()
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _blank_manifest()
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed is Dictionary:
		var manifest: Dictionary = parsed as Dictionary
		if not manifest.has("artifacts") or not (manifest["artifacts"] is Array):
			manifest["artifacts"] = []
		return manifest
	return _blank_manifest()


static func _blank_manifest() -> Dictionary:
	return {
		"schema_version": _SCHEMA_VERSION,
		"artifact_root": absolute_path(artifact_root()),
		"artifacts": [],
		"updated_at": _timestamp(),
	}


static func _upsert_entry(manifest: Dictionary, entry: Dictionary) -> void:
	var artifacts: Array = manifest.get("artifacts", []) as Array
	for i: int in range(artifacts.size()):
		var existing: Dictionary = artifacts[i] as Dictionary
		if str(existing.get("relative_path", "")) == str(entry.get("relative_path", "")) \
				and str(existing.get("type", "")) == str(entry.get("type", "")):
			artifacts[i] = entry
			manifest["updated_at"] = _timestamp()
			manifest["artifact_root"] = absolute_path(artifact_root())
			return
	artifacts.append(entry)
	manifest["artifacts"] = artifacts
	manifest["updated_at"] = _timestamp()
	manifest["artifact_root"] = absolute_path(artifact_root())


static func _write_manifest(manifest: Dictionary) -> Dictionary:
	var path: String = manifest_path()
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return _error("Cannot write artifact manifest: %s" % path)
	file.store_string(JSON.stringify(manifest, "\t"))
	file.close()
	return {
		"ok": true,
		"path": path,
		"absolute_path": absolute_path(path),
		"relative_path": relative_path_for(path),
	}


static func _file_size(path: String) -> int:
	if not FileAccess.file_exists(path):
		return 0
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return 0
	var size: int = int(file.get_length())
	file.close()
	return size


static func _timestamp() -> String:
	var d: Dictionary = Time.get_datetime_dict_from_system()
	return "%04d-%02d-%02dT%02d:%02d:%02d" % [
		int(d.get("year", 0)),
		int(d.get("month", 0)),
		int(d.get("day", 0)),
		int(d.get("hour", 0)),
		int(d.get("minute", 0)),
		int(d.get("second", 0)),
	]


static func _is_full_path(path: String) -> bool:
	return path.begins_with("/") or path.begins_with("user://") \
		or path.begins_with("res://") or path.contains(":/")


static func _clean_root(path: String) -> String:
	return _trim_trailing_slashes(path.strip_edges())


static func _trim_trailing_slashes(path: String) -> String:
	var out: String = path
	while out.length() > 1 and out.ends_with("/") and not out.ends_with("://"):
		out = out.substr(0, out.length() - 1)
	return out


static func _trim_leading_slashes(path: String) -> String:
	var out: String = path
	while out.begins_with("/"):
		out = out.substr(1)
	return out


static func _error(message: String) -> Dictionary:
	return {
		"ok": false,
		"error": message,
	}
