extends Node
class_name EvidenceStorage

const SECURITY_PLACEHOLDERS := [
	{
		"placeholder_id": "cash_safe",
		"label": "Cash safe",
		"zone_id": "backroom_safe",
		"purpose": "Cash storage",
	},
	{
		"placeholder_id": "high_value_storage",
		"label": "High-value storage",
		"zone_id": "backroom_high_value_shelf",
		"purpose": "High-value stock hold",
	},
	{
		"placeholder_id": "suspicious_goods_isolation",
		"label": "Suspicious goods isolation",
		"zone_id": "backroom_evidence_locker",
		"purpose": "Quarantine suspicious items",
	},
	{
		"placeholder_id": "security_footage",
		"label": "Security footage",
		"zone_id": "backroom_security_monitor",
		"purpose": "Review camera clips",
	},
]

var _evidence: Array[Dictionary] = []
var _security_records: Array[Dictionary] = []


func store_evidence(
	evidence_id: String,
	title: String,
	source: String = "",
	metadata: Dictionary = {}
) -> Dictionary:
	var normalized_id := evidence_id.strip_edges()
	if normalized_id.is_empty():
		return {}

	var existing := get_evidence(normalized_id)
	if not existing.is_empty():
		return existing

	var evidence := {
		"evidence_id": normalized_id,
		"title": title if not title.strip_edges().is_empty() else normalized_id,
		"source": source,
		"metadata": metadata.duplicate(true),
	}
	_evidence.append(evidence)
	return evidence.duplicate(true)


func store_from_node(node: Node) -> Dictionary:
	if node == null:
		return {}

	if not node.has_method("get_suspicious_event_id"):
		return {}

	if node.has_method("has_serial_mismatch") and not node.call("has_serial_mismatch"):
		return {}

	var evidence_id := str(node.call("get_suspicious_event_id"))
	var title := _title_for_node(node)
	var source := node.get_path().get_concatenated_names()
	var metadata := _metadata_for_node(node)
	return store_evidence(evidence_id, title, source, metadata)


func has_evidence(evidence_id: String) -> bool:
	return not get_evidence(evidence_id).is_empty()


func get_evidence(evidence_id: String) -> Dictionary:
	var normalized_id := evidence_id.strip_edges()
	for evidence in _evidence:
		if str(evidence.get("evidence_id", "")) == normalized_id:
			return evidence.duplicate(true)

	return {}


func get_all_evidence() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for evidence in _evidence:
		rows.append(evidence.duplicate(true))
	return rows


func get_evidence_count() -> int:
	return _evidence.size()


func clear_evidence() -> void:
	_evidence.clear()


func get_security_placeholders() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for placeholder in SECURITY_PLACEHOLDERS:
		var row: Dictionary = placeholder.duplicate(true)
		row["status"] = "recorded" if _has_security_record(str(row.get("placeholder_id", ""))) else "placeholder"
		rows.append(row)
	return rows


func get_security_records() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for record in _security_records:
		rows.append(record.duplicate(true))
	return rows


func record_security_placeholder(placeholder_id: String, reference_id: String = "", notes: String = "") -> Dictionary:
	var placeholder := _get_security_placeholder(placeholder_id)
	if placeholder.is_empty():
		return {}

	var record := {
		"record_id": "security_record_%03d" % (_security_records.size() + 1),
		"placeholder_id": str(placeholder.get("placeholder_id", "")),
		"label": str(placeholder.get("label", "Security placeholder")),
		"zone_id": str(placeholder.get("zone_id", "backroom_security")),
		"purpose": str(placeholder.get("purpose", "")),
		"reference_id": reference_id.strip_edges(),
		"notes": notes.strip_edges(),
		"status": "recorded",
	}
	_security_records.append(record)
	return record.duplicate(true)


func get_security_zone_summary_text() -> String:
	var lines: Array[String] = ["Security placeholders:"]
	for placeholder in get_security_placeholders():
		lines.append("%s - %s / %s / %s" % [
			str(placeholder.get("label", "Security")),
			str(placeholder.get("status", "placeholder")),
			str(placeholder.get("zone_id", "backroom_security")),
			str(placeholder.get("purpose", "")),
		])
	if _security_records.is_empty():
		lines.append("Security records: none")
	else:
		lines.append("Security records:")
		for record in _security_records:
			lines.append("%s %s -> %s" % [
				str(record.get("record_id", "security_record")),
				str(record.get("label", "Security")),
				str(record.get("reference_id", "")),
			])
	lines.append("Status: placeholders only; no active hidden objective or register action")
	return "\n".join(lines)


func get_summary_text() -> String:
	if _evidence.is_empty():
		return "Evidence stored: none"

	var lines: Array[String] = ["Evidence stored:"]
	for evidence in _evidence:
		lines.append("%s %s" % [
			str(evidence.get("evidence_id", "")),
			str(evidence.get("title", "")),
		])

	return "\n".join(lines)


func _get_security_placeholder(placeholder_id: String) -> Dictionary:
	var normalized_id := placeholder_id.strip_edges()
	for placeholder in SECURITY_PLACEHOLDERS:
		if str(placeholder.get("placeholder_id", "")) == normalized_id:
			return placeholder.duplicate(true)
	return {}


func _has_security_record(placeholder_id: String) -> bool:
	for record in _security_records:
		if str(record.get("placeholder_id", "")) == placeholder_id:
			return true
	return false


func _title_for_node(node: Node) -> String:
	if node.get("subject") != null and not str(node.get("subject")).strip_edges().is_empty():
		return str(node.get("subject")).strip_edges()

	if node.get("display_name") != null and not str(node.get("display_name")).strip_edges().is_empty():
		return str(node.get("display_name")).strip_edges()

	return node.name


func _metadata_for_node(node: Node) -> Dictionary:
	var metadata := {
		"node_name": node.name,
	}

	for property_name in [
		"instance_id",
		"product",
		"serial_id",
		"expected_serial_id",
		"location_id",
		"message_id",
		"supplier_id",
		"customer_id",
		"encounter_id",
		"subject",
		"body",
		"dialogue_text",
		"severity",
	]:
		var value = node.get(property_name)
		if value == null:
			continue

		if value is Resource and value.get("product_id") != null:
			metadata[property_name] = value.get("product_id")
		else:
			metadata[property_name] = value

	return metadata
