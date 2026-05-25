## Renders advisory visual review reports as human-readable Markdown.
class_name AdvisoryReviewMarkdown
extends RefCounted

const SEVERITY_INFO: String = "info"
const SEVERITY_LOW: String = "low"
const SEVERITY_MEDIUM: String = "medium"
const SEVERITY_HIGH: String = "high"


## Returns the Markdown summary for a report payload.
static func markdown_report(report: Dictionary) -> String:
	var lines: PackedStringArray = PackedStringArray()
	var source: Dictionary = report.get("source_manifest", {}) as Dictionary
	var findings: Array = report.get("findings", []) as Array
	lines.append("# Advisory Visual Review")
	lines.append("- Status: %s" % str(report.get("review_status", "")))
	lines.append("- Verdict: %s" % str(report.get("overall_advisory_verdict", "")))
	lines.append("- Highest severity: %s" % str(report.get("highest_severity", "")))
	lines.append("- Source: `%s`" % str(source.get("path", "")))
	lines.append("- Advisory only: %s" % str(report.get("advisory_only", false)))
	lines.append("")
	lines.append("## Highest-Severity Findings")
	var highest: String = str(report.get("highest_severity", SEVERITY_INFO))
	var wrote_highest: bool = false
	for finding_variant: Variant in findings:
		var finding: Dictionary = finding_variant as Dictionary
		if str(finding.get("severity", "")) == highest:
			lines.append(_finding_line(finding))
			wrote_highest = true
	if not wrote_highest:
		lines.append("- No advisory findings recorded.")
	lines.append("")
	lines.append("## Counts")
	var counts: Dictionary = report.get("finding_counts", {}) as Dictionary
	lines.append("- Reviewed beats or frames: %d" % int(report.get("reviewed_count", 0)))
	lines.append("- Findings: %d" % int(counts.get("total", 0)))
	for severity: String in [SEVERITY_HIGH, SEVERITY_MEDIUM, SEVERITY_LOW, SEVERITY_INFO]:
		lines.append("- %s: %d" % [severity, int(counts.get(severity, 0))])
	lines.append("")
	lines.append("## Findings By Beat Or Frame")
	if findings.is_empty():
		lines.append("- No beat-scoped findings.")
	else:
		var groups: Dictionary = _findings_by_beat(findings)
		for beat_id: String in groups.keys():
			lines.append("### %s" % beat_id)
			for finding: Dictionary in groups[beat_id]:
				lines.append(_finding_line(finding))
	return "\n".join(lines) + "\n"


static func _finding_line(finding: Dictionary) -> String:
	var target: String = str(finding.get("artifact_path", ""))
	var frame: String = str(finding.get("frame_reference", ""))
	if not frame.is_empty():
		target = "%s @ %s" % [target, frame]
	return "- [%s] `%s` %s -> %s. Action: %s. Artifact: `%s`" % [
		str(finding.get("severity", "")),
		str(finding.get("criterion_id", "")),
		str(finding.get("observation", "")),
		str(finding.get("recommendation", "")),
		str(finding.get("next_human_action", "")),
		target,
	]


static func _findings_by_beat(findings: Array) -> Dictionary:
	var groups: Dictionary = {}
	for finding_variant: Variant in findings:
		var finding: Dictionary = finding_variant as Dictionary
		var key: String = str(finding.get("beat", "manifest"))
		if key.is_empty():
			key = "manifest"
		if not groups.has(key):
			groups[key] = []
		(groups[key] as Array).append(finding)
	return groups
