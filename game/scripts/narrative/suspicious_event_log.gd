extends Node
class_name SuspiciousEventLog

const VALID_SEVERITIES := ["low", "medium", "high"]

var _events: Array[Dictionary] = []


func flag_event(
	event_id: String,
	title: String,
	source: String = "",
	severity: String = "low",
	metadata: Dictionary = {}
) -> Dictionary:
	var normalized_id := event_id.strip_edges()
	if normalized_id.is_empty():
		return {}

	var existing := get_event(normalized_id)
	if not existing.is_empty():
		return existing

	var event := {
		"event_id": normalized_id,
		"title": title if not title.strip_edges().is_empty() else normalized_id,
		"source": source,
		"severity": _normalize_severity(severity),
		"metadata": metadata.duplicate(true),
	}
	_events.append(event)
	return event.duplicate(true)


func has_event(event_id: String) -> bool:
	return not get_event(event_id).is_empty()


func get_event(event_id: String) -> Dictionary:
	var normalized_id := event_id.strip_edges()
	for event in _events:
		if str(event.get("event_id", "")) == normalized_id:
			return event.duplicate(true)

	return {}


func get_events() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for event in _events:
		rows.append(event.duplicate(true))
	return rows


func get_event_count() -> int:
	return _events.size()


func clear_events() -> void:
	_events.clear()


func get_summary_text() -> String:
	if _events.is_empty():
		return "Suspicious events: none"

	var lines: Array[String] = ["Suspicious events:"]
	for event in _events:
		lines.append("%s [%s] %s" % [
			str(event.get("event_id", "")),
			str(event.get("severity", "low")),
			str(event.get("title", "")),
		])

	return "\n".join(lines)


func _normalize_severity(severity: String) -> String:
	var normalized := severity.strip_edges().to_lower()
	if VALID_SEVERITIES.has(normalized):
		return normalized

	return "low"
