extends Resource
class_name HiddenChoiceCatalog

const CHOICES := [
	{
		"choice_id": "ignore",
		"label": "Ignore for now",
		"stance": "passive",
		"signal": "always",
		"summary": "Leave the anomaly alone and continue normal retail work.",
		"follow_up": "No immediate action; clue remains optional.",
	},
	{
		"choice_id": "document",
		"label": "Document evidence",
		"stance": "cautious",
		"signal": "has_clue_surface",
		"summary": "Record the clue, serial, comment, invoice, or artifact without escalating.",
		"follow_up": "Creates a record for later reporting or isolation.",
	},
	{
		"choice_id": "sell_as_normal",
		"label": "Sell as normal",
		"stance": "retail",
		"signal": "has_serial_mismatch",
		"summary": "Keep the item in ordinary sales flow despite the anomaly.",
		"follow_up": "Consequences are deferred to the next hidden-thread slice.",
	},
	{
		"choice_id": "isolate_goods",
		"label": "Isolate goods",
		"stance": "protective",
		"signal": "has_evidence_storage",
		"summary": "Move suspicious goods toward the backroom evidence or isolation shelf.",
		"follow_up": "Prepares a quarantine path without blocking other stock.",
	},
	{
		"choice_id": "report_issue",
		"label": "Report issue",
		"stance": "formal",
		"signal": "can_report_issue",
		"summary": "Prepare a report path for suspicious inventory, supplier terms, or cash pressure.",
		"follow_up": "Escalation consequences are deferred until consequence rules exist.",
	},
	{
		"choice_id": "accept_cash_offer",
		"label": "Accept cash offer",
		"stance": "risky",
		"signal": "has_suspicious_customer",
		"summary": "Accept the suspicious cash-buyer path as a recorded choice.",
		"follow_up": "Cash/reputation/inspection effects are handled in the consequence slice.",
	},
	{
		"choice_id": "reject_goods",
		"label": "Reject goods",
		"stance": "defensive",
		"signal": "has_supplier_message",
		"summary": "Reject suspicious goods or terms before they become normal stock.",
		"follow_up": "Supplier relationship effects are deferred to consequence handling.",
	},
	{
		"choice_id": "follow_up_supplier",
		"label": "Follow up supplier",
		"stance": "investigate",
		"signal": "has_supplier_thread",
		"summary": "Contact the supplier about invoice, email, provenance, or off-manifest clues.",
		"follow_up": "Keeps the thread in backroom records without forcing a customer-facing step.",
	},
]


static func get_choice_catalog() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for choice in CHOICES:
		rows.append(choice.duplicate(true))
	return rows


static func get_choice(choice_id: String) -> Dictionary:
	var normalized_id := choice_id.strip_edges()
	for choice in CHOICES:
		if str(choice.get("choice_id", "")) == normalized_id:
			return choice.duplicate(true)
	return {}


static func evaluate_context(context: Dictionary = {}) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for choice in CHOICES:
		var row: Dictionary = choice.duplicate(true)
		row["status"] = _get_status_for_choice(choice, context)
		rows.append(row)
	return rows


static func build_choice_record(choice_id: String, subject_id: String = "", metadata: Dictionary = {}) -> Dictionary:
	var choice := get_choice(choice_id)
	if choice.is_empty():
		return {}

	var normalized_subject := subject_id.strip_edges()
	if normalized_subject.is_empty():
		normalized_subject = str(metadata.get("subject_id", "thread")).strip_edges()
	if normalized_subject.is_empty():
		normalized_subject = "thread"

	return {
		"choice_record_id": "%s_%s" % [choice_id, normalized_subject],
		"choice_id": choice_id,
		"label": str(choice.get("label", choice_id)),
		"stance": str(choice.get("stance", "")),
		"subject_id": normalized_subject,
		"summary": str(choice.get("summary", "")),
		"follow_up": str(choice.get("follow_up", "")),
		"metadata": metadata.duplicate(true),
	}


static func get_summary_text(context: Dictionary = {}, records: Array[Dictionary] = []) -> String:
	var lines: Array[String] = ["Hidden choice paths:"]
	for choice in evaluate_context(context):
		lines.append("%s - %s / %s: %s" % [
			str(choice.get("label", "Choice")),
			str(choice.get("status", "waiting")),
			str(choice.get("stance", "")),
			str(choice.get("summary", "")),
		])

	if records.is_empty():
		lines.append("Recorded choices: none")
	else:
		lines.append("Recorded choices:")
		for record in records:
			lines.append("%s day %d: %s -> %s" % [
				str(record.get("choice_record_id", "choice")),
				int(record.get("recorded_day", 0)),
				str(record.get("label", "Choice")),
				str(record.get("follow_up", "")),
			])

	lines.append("Status: choice paths only; consequences deferred")
	return "\n".join(lines)


static func _get_status_for_choice(choice: Dictionary, context: Dictionary) -> String:
	var signal_id := str(choice.get("signal", "")).strip_edges()
	if signal_id.is_empty() or signal_id == "always":
		return "available"
	return "available" if bool(context.get(signal_id, false)) else "waiting"
