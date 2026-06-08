extends Resource
class_name HiddenConsequenceRules

const CONSEQUENCES := {
	"ignore": {
		"label": "Ignored anomaly",
		"cash_delta_cents": 0,
		"reputation_delta": 0,
		"supplier_access_delta": 0,
		"customer_trust_delta": 0,
		"inspection_risk_delta": 1,
		"story_state": "ignored",
	},
	"document": {
		"label": "Documented evidence",
		"cash_delta_cents": 0,
		"reputation_delta": 1,
		"supplier_access_delta": 0,
		"customer_trust_delta": 1,
		"inspection_risk_delta": -1,
		"story_state": "documented",
	},
	"sell_as_normal": {
		"label": "Sold despite anomaly",
		"cash_delta_cents": 0,
		"reputation_delta": -2,
		"supplier_access_delta": 0,
		"customer_trust_delta": -1,
		"inspection_risk_delta": 2,
		"story_state": "sold_as_normal",
	},
	"isolate_goods": {
		"label": "Isolated suspicious goods",
		"cash_delta_cents": 0,
		"reputation_delta": 1,
		"supplier_access_delta": 0,
		"customer_trust_delta": 0,
		"inspection_risk_delta": -2,
		"story_state": "isolated",
	},
	"report_issue": {
		"label": "Reported issue",
		"cash_delta_cents": 0,
		"reputation_delta": 2,
		"supplier_access_delta": -2,
		"customer_trust_delta": 1,
		"inspection_risk_delta": -3,
		"story_state": "reported",
	},
	"accept_cash_offer": {
		"label": "Accepted suspicious cash",
		"cash_delta_cents": 1200,
		"reputation_delta": -5,
		"supplier_access_delta": 0,
		"customer_trust_delta": -2,
		"inspection_risk_delta": 4,
		"story_state": "cash_accepted",
	},
	"reject_goods": {
		"label": "Rejected suspicious goods",
		"cash_delta_cents": 0,
		"reputation_delta": 1,
		"supplier_access_delta": -1,
		"customer_trust_delta": 1,
		"inspection_risk_delta": -1,
		"story_state": "goods_rejected",
	},
	"follow_up_supplier": {
		"label": "Followed up supplier",
		"cash_delta_cents": 0,
		"reputation_delta": 0,
		"supplier_access_delta": 1,
		"customer_trust_delta": 0,
		"inspection_risk_delta": -1,
		"story_state": "supplier_follow_up",
	},
}


static func get_consequence_catalog() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for choice_id in CONSEQUENCES.keys():
		var row: Dictionary = (CONSEQUENCES[choice_id] as Dictionary).duplicate(true)
		row["choice_id"] = choice_id
		rows.append(row)
	return rows


static func get_consequence(choice_id: String) -> Dictionary:
	var normalized_id := choice_id.strip_edges()
	if not CONSEQUENCES.has(normalized_id):
		return {}

	var row: Dictionary = (CONSEQUENCES[normalized_id] as Dictionary).duplicate(true)
	row["choice_id"] = normalized_id
	return row


static func build_consequence_event(choice_record: Dictionary) -> Dictionary:
	var choice_id := str(choice_record.get("choice_id", "")).strip_edges()
	var consequence := get_consequence(choice_id)
	if consequence.is_empty():
		return {}

	var choice_record_id := str(choice_record.get("choice_record_id", choice_id)).strip_edges()
	if choice_record_id.is_empty():
		choice_record_id = choice_id

	return {
		"consequence_id": "consequence_%s" % choice_record_id,
		"choice_record_id": choice_record_id,
		"choice_id": choice_id,
		"label": str(consequence.get("label", choice_id)),
		"cash_delta_cents": int(consequence.get("cash_delta_cents", 0)),
		"reputation_delta": int(consequence.get("reputation_delta", 0)),
		"supplier_access_delta": int(consequence.get("supplier_access_delta", 0)),
		"customer_trust_delta": int(consequence.get("customer_trust_delta", 0)),
		"inspection_risk_delta": int(consequence.get("inspection_risk_delta", 0)),
		"story_state": str(consequence.get("story_state", choice_id)),
		"subject_id": str(choice_record.get("subject_id", "")),
	}


static func get_summary_text(events: Array[Dictionary] = []) -> String:
	var lines: Array[String] = ["Hidden consequences:"]
	if events.is_empty():
		lines.append("Recent consequences: none")
	else:
		for event in events:
			lines.append("%s cash %+d rep %+d supplier %+d trust %+d inspection %+d state %s" % [
				str(event.get("label", "Consequence")),
				int(event.get("cash_delta_cents", 0)),
				int(event.get("reputation_delta", 0)),
				int(event.get("supplier_access_delta", 0)),
				int(event.get("customer_trust_delta", 0)),
				int(event.get("inspection_risk_delta", 0)),
				str(event.get("story_state", "")),
			])
	return "\n".join(lines)
