extends Node
class_name EvidenceStorage

var _evidence: Array[Dictionary] = []


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
