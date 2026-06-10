extends Resource
class_name SuspicionRules

const RISK_RULES := [
	{
		"rule_id": "serial_mismatch",
		"label": "Serial mismatch",
		"severity": "high",
		"score": 40,
		"source": "inventory",
		"summary": "Recorded serial does not match expected product serial metadata.",
	},
	{
		"rule_id": "suspicious_supplier",
		"label": "Suspicious supplier",
		"severity": "medium",
		"score": 25,
		"source": "supplier_message",
		"summary": "Supplier message or invoice language suggests a receiving anomaly.",
	},
	{
		"rule_id": "cash_buyer",
		"label": "Cash buyer",
		"severity": "medium",
		"score": 30,
		"source": "customer",
		"summary": "Customer requests quiet cash handling, bulk goods, or off-register terms.",
	},
	{
		"rule_id": "impossible_provenance",
		"label": "Impossible provenance",
		"severity": "high",
		"score": 45,
		"source": "records",
		"summary": "Item history, paperwork, or timing cannot match a plausible retail source.",
	},
	{
		"rule_id": "counterfeit_goods",
		"label": "Counterfeit goods",
		"severity": "high",
		"score": 50,
		"source": "inventory",
		"summary": "Authenticity or condition cues indicate fake, resealed, or altered goods.",
	},
	{
		"rule_id": "hidden_storage",
		"label": "Hidden storage",
		"severity": "medium",
		"score": 20,
		"source": "backroom",
		"summary": "Suspicious goods are isolated, hidden, or moved to security storage.",
	},
]


static func get_rule_catalog() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for rule in RISK_RULES:
		rows.append(rule.duplicate(true))
	return rows


static func get_rule(rule_id: String) -> Dictionary:
	var normalized_id := rule_id.strip_edges()
	for rule in RISK_RULES:
		if str(rule.get("rule_id", "")) == normalized_id:
			return rule.duplicate(true)
	return {}


static func evaluate_metadata(metadata: Dictionary) -> Array[Dictionary]:
	var flags: Array[Dictionary] = []
	if _has_serial_mismatch(metadata):
		flags.append(_build_flag("serial_mismatch", metadata))
	if _has_suspicious_supplier_signal(metadata):
		flags.append(_build_flag("suspicious_supplier", metadata))
	if _has_cash_buyer_signal(metadata):
		flags.append(_build_flag("cash_buyer", metadata))
	if _has_impossible_provenance_signal(metadata):
		flags.append(_build_flag("impossible_provenance", metadata))
	if _has_counterfeit_signal(metadata):
		flags.append(_build_flag("counterfeit_goods", metadata))
	if _has_hidden_storage_signal(metadata):
		flags.append(_build_flag("hidden_storage", metadata))
	return flags


static func evaluate_product_item(item: Node) -> Array[Dictionary]:
	if item == null:
		return []

	var product := item.get("product") as ProductDefinition
	var metadata := {
		"source": "inventory",
		"instance_id": str(item.get("instance_id")),
		"serial_id": str(item.get("serial_id")),
		"expected_serial_id": str(item.get("expected_serial_id")),
		"location_id": str(item.get("location_id")),
		"serial_mismatch": item.has_method("has_serial_mismatch") and bool(item.call("has_serial_mismatch")),
	}
	if product != null:
		metadata["product_id"] = product.product_id
		metadata["authenticity"] = product.authenticity
		metadata["risk_level"] = product.risk_level
		metadata["risk_tags"] = product.risk_tags.duplicate()
	return evaluate_metadata(metadata)


static func evaluate_supplier_message(message: Node) -> Array[Dictionary]:
	if message == null:
		return []

	return evaluate_metadata({
		"source": "supplier_message",
		"message_id": str(message.get("message_id")),
		"supplier_id": str(message.get("supplier_id")),
		"subject": str(message.get("subject")),
		"body": str(message.get("body")),
		"severity": str(message.get("severity")),
		"suspicious_event_id": str(message.call("get_suspicious_event_id")) if message.has_method("get_suspicious_event_id") else "",
	})


static func evaluate_customer(customer: Node) -> Array[Dictionary]:
	if customer == null:
		return []

	return evaluate_metadata({
		"source": "customer",
		"customer_id": str(customer.get("customer_id")),
		"encounter_id": str(customer.call("get_suspicious_event_id")) if customer.has_method("get_suspicious_event_id") else "",
		"subject": str(customer.get("subject")),
		"dialogue_text": str(customer.get("dialogue_text")),
		"severity": str(customer.get("severity")),
	})


static func score_flags(flags: Array[Dictionary]) -> int:
	var total := 0
	for flag in flags:
		total += int(flag.get("score", 0))
	return total


static func get_highest_severity(flags: Array[Dictionary]) -> String:
	var highest := "low"
	for flag in flags:
		var severity := str(flag.get("severity", "low"))
		if _severity_rank(severity) > _severity_rank(highest):
			highest = severity
	return highest


static func build_event_for_flag(flag: Dictionary, subject_id: String = "", metadata: Dictionary = {}) -> Dictionary:
	if flag.is_empty():
		return {}

	var rule_id := str(flag.get("rule_id", ""))
	var normalized_subject := subject_id.strip_edges()
	if normalized_subject.is_empty():
		normalized_subject = str(flag.get("subject_id", "subject")).strip_edges()
	if normalized_subject.is_empty():
		normalized_subject = "subject"

	var merged_metadata: Dictionary = (flag.get("metadata", {}) as Dictionary).duplicate(true)
	for key in metadata.keys():
		merged_metadata[key] = metadata[key]
	merged_metadata["rule_id"] = rule_id

	return {
		"event_id": "%s_%s" % [rule_id, normalized_subject],
		"title": str(flag.get("label", rule_id)),
		"source": str(flag.get("source", "")),
		"severity": str(flag.get("severity", "low")),
		"metadata": merged_metadata,
	}


static func get_summary_text() -> String:
	var lines: Array[String] = ["Suspicion rules:"]
	for rule in RISK_RULES:
		lines.append("%s [%s/%d]: %s" % [
			str(rule.get("label", "Rule")),
			str(rule.get("severity", "low")),
			int(rule.get("score", 0)),
			str(rule.get("summary", "")),
		])
	return "\n".join(lines)


static func _build_flag(rule_id: String, metadata: Dictionary) -> Dictionary:
	var rule := get_rule(rule_id)
	if rule.is_empty():
		return {}

	var flag := rule.duplicate(true)
	flag["metadata"] = metadata.duplicate(true)
	flag["subject_id"] = _subject_id_from_metadata(metadata)
	return flag


static func _subject_id_from_metadata(metadata: Dictionary) -> String:
	for key in ["instance_id", "message_id", "encounter_id", "customer_id", "supplier_id", "location_id"]:
		var value := str(metadata.get(key, "")).strip_edges()
		if not value.is_empty():
			return value
	return "subject"


static func _has_serial_mismatch(metadata: Dictionary) -> bool:
	if bool(metadata.get("serial_mismatch", false)):
		return true

	var serial_id := str(metadata.get("serial_id", "")).strip_edges()
	var expected_serial_id := str(metadata.get("expected_serial_id", "")).strip_edges()
	return not serial_id.is_empty() and not expected_serial_id.is_empty() and serial_id != expected_serial_id


static func _has_suspicious_supplier_signal(metadata: Dictionary) -> bool:
	var source := str(metadata.get("source", "")).to_lower()
	var text := _metadata_text(metadata)
	var severity := str(metadata.get("severity", "")).to_lower()
	return source == "supplier_message" \
		and (severity in ["medium", "high"] or _contains_any(text, ["discrepancy", "off manifest", "missing", "serial", "cash", "quiet", "no returns", "mismatch"]))


static func _has_cash_buyer_signal(metadata: Dictionary) -> bool:
	var text := _metadata_text(metadata)
	return _contains_any(text, ["cash buyer", "bulk cash", "keep it quiet", "off register", "no receipt"])


static func _has_impossible_provenance_signal(metadata: Dictionary) -> bool:
	var provenance := str(metadata.get("provenance_status", "")).to_lower()
	var text := _metadata_text(metadata)
	return bool(metadata.get("impossible_provenance", false)) \
		or provenance in ["impossible", "impossible_timing", "unverified", "unverifiable", "contradictory"] \
		or _contains_any(text, ["not yet released", "impossible provenance", "stolen shipment"])


static func _has_counterfeit_signal(metadata: Dictionary) -> bool:
	var authenticity := str(metadata.get("authenticity", "")).to_lower()
	var risk_tags: Variant = metadata.get("risk_tags", [])
	if authenticity in ["counterfeit", "fake", "needs_review", "uncertain"]:
		return true
	if risk_tags is Array or risk_tags is PackedStringArray:
		for tag in risk_tags:
			if str(tag).to_lower() in ["counterfeit", "fake", "reseal", "serial_check"]:
				return true
	return false


static func _has_hidden_storage_signal(metadata: Dictionary) -> bool:
	var location_id := str(metadata.get("location_id", "")).to_lower()
	var zone_id := str(metadata.get("zone_id", "")).to_lower()
	var security_zone := str(metadata.get("security_zone", "")).to_lower()
	return bool(metadata.get("hidden_storage", false)) \
		or location_id in ["suspicious_goods_isolation", "backroom_evidence_locker", "hidden_storage"] \
		or zone_id in ["suspicious_goods_isolation", "backroom_evidence_locker", "hidden_storage"] \
		or security_zone in ["suspicious_goods_isolation", "backroom_evidence_locker", "hidden_storage"]


static func _metadata_text(metadata: Dictionary) -> String:
	var parts: Array[String] = []
	for key in ["subject", "body", "dialogue_text", "notes", "source"]:
		parts.append(str(metadata.get(key, "")))
	return " ".join(parts).to_lower()


static func _contains_any(text: String, needles: Array[String]) -> bool:
	for needle in needles:
		if text.find(needle.to_lower()) >= 0:
			return true
	return false


static func _severity_rank(severity: String) -> int:
	match severity:
		"high":
			return 3
		"medium":
			return 2
		_:
			return 1
