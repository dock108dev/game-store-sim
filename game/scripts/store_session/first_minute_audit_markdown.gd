## Markdown writer for the first-minute screenshot audit artifact.
class_name FirstMinuteAuditMarkdown
extends RefCounted

const AutomationArtifactsScript: GDScript = preload(
	"res://game/scripts/core/automation_artifacts.gd"
)


## Writes first-minute audit Markdown with the punch list before raw beat details.
static func write(path: String, artifact: Dictionary, suite: String) -> Dictionary:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "error": "Cannot write first-minute audit Markdown: %s" % path}
	var lines: PackedStringArray = PackedStringArray()
	lines.append("# First-Minute Screenshot Audit")
	lines.append("")
	lines.append("Run id: %s" % str(artifact.get("run_id", "")))
	lines.append("Route: %s" % str(artifact.get("route_id", "")))
	lines.append("")
	_append_punch_list(lines, artifact.get("punch_list", []) as Array)
	lines.append("")
	lines.append("## Audit Beats")
	lines.append("")
	for beat_variant: Variant in artifact.get("beats", []):
		_append_beat(lines, beat_variant as Dictionary)
	file.store_string("\n".join(lines))
	file.close()
	AutomationArtifactsScript.record_artifact(
		"report", path, suite, "first_minute_audit", "markdown"
	)
	return {"ok": true, "path": path}


static func _append_punch_list(lines: PackedStringArray, punch: Array) -> void:
	lines.append("## Punch List")
	lines.append("")
	if punch.is_empty():
		lines.append("No actionable FAIL, MISSING, or KNOWN_FAIL records.")
		return
	lines.append(
		"| Beat | Status | Severity | Owner | Category | Acceptance | Screenshot | Notes |"
	)
	lines.append("|---|---:|---:|---|---|---|---|---|")
	for item_variant: Variant in punch:
		var item: Dictionary = item_variant as Dictionary
		lines.append(
			(
				"| %s | %s | %s | %s | %s | %s | `%s` | %s |"
				% [
					_md(str(item.get("label", ""))),
					_md(str(item.get("status", ""))),
					_md(str(item.get("severity", ""))),
					_md(str(item.get("owner", ""))),
					_md(str(item.get("category", ""))),
					_md(str(item.get("acceptance", ""))),
					_md(str(item.get("screenshot_path", ""))),
					_md(str(item.get("notes", ""))),
				]
			)
		)


static func _append_beat(lines: PackedStringArray, beat: Dictionary) -> void:
	lines.append(
		"### %02d %s" % [int(beat.get("target_timestamp_sec", 0)), str(beat.get("label", ""))]
	)
	lines.append("- Status: %s" % str(beat.get("status", "")))
	lines.append("- Screenshot: `%s`" % str(beat.get("screenshot_path", "")))
	lines.append("- Route state: `%s`" % str(beat.get("route_state", {})))
	lines.append("- HUD state: `%s`" % str(beat.get("hud_state", {})))
	lines.append("- Prompt state: `%s`" % str(beat.get("prompt_state", {})))
	lines.append("- Interaction target: `%s`" % str(beat.get("interaction_target", {})))
	lines.append("")


static func _md(value: String) -> String:
	return value.replace("|", "\\|").replace("\n", " ")
