extends Resource
class_name ClueSurfaceCatalog

const CLUE_SURFACES := [
	{
		"surface_id": "receiving_invoice",
		"label": "Receiving invoice",
		"type": "invoice",
		"location": "Backroom receiving mat",
		"signal": "has_receiving_batch",
		"rules": ["suspicious_supplier", "serial_mismatch"],
		"summary": "Invoice count, variance, and serial notes can point to a receiving anomaly.",
	},
	{
		"surface_id": "supplier_note",
		"label": "Supplier note",
		"type": "note",
		"location": "Receiving box",
		"signal": "has_supplier_message",
		"rules": ["suspicious_supplier"],
		"summary": "Loose supplier paperwork can hint at quiet terms or off-manifest stock.",
	},
	{
		"surface_id": "serial_lookup",
		"label": "Serial lookup",
		"type": "lookup",
		"location": "Records tab",
		"signal": "has_serial_mismatch",
		"rules": ["serial_mismatch", "counterfeit_goods"],
		"summary": "Serial lookup gives a nonblocking way to compare recorded and expected item IDs.",
	},
	{
		"surface_id": "supplier_email",
		"label": "Supplier email",
		"type": "email",
		"location": "Management desk",
		"signal": "has_supplier_order",
		"rules": ["suspicious_supplier", "impossible_provenance"],
		"summary": "Supplier email context can explain order terms, no-return language, and provenance gaps.",
	},
	{
		"surface_id": "customer_comment",
		"label": "Customer comment",
		"type": "comment",
		"location": "Sales floor conversation",
		"signal": "has_suspicious_customer",
		"rules": ["cash_buyer"],
		"summary": "Customer comments can expose cash, bulk, or no-receipt pressure without forcing a response.",
	},
	{
		"surface_id": "security_clip",
		"label": "Security clip",
		"type": "security_clip",
		"location": "Backroom security monitor",
		"signal": "has_security_footage_placeholder",
		"rules": ["hidden_storage"],
		"summary": "Security clips are placeholder review surfaces for suspicious handling or hidden storage.",
	},
	{
		"surface_id": "backroom_artifact",
		"label": "Backroom artifact",
		"type": "artifact",
		"location": "Evidence shelf",
		"signal": "has_evidence_storage",
		"rules": ["counterfeit_goods", "hidden_storage"],
		"summary": "Stored artifacts preserve optional clue context for later reporting or isolation choices.",
	},
]


static func get_surface_catalog() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for surface in CLUE_SURFACES:
		rows.append(surface.duplicate(true))
	return rows


static func get_surface(surface_id: String) -> Dictionary:
	var normalized_id := surface_id.strip_edges()
	for surface in CLUE_SURFACES:
		if str(surface.get("surface_id", "")) == normalized_id:
			return surface.duplicate(true)
	return {}


static func evaluate_context(context: Dictionary = {}) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for surface in CLUE_SURFACES:
		var row: Dictionary = surface.duplicate(true)
		row["status"] = _get_status_for_surface(surface, context)
		row["subject_id"] = _get_subject_for_surface(surface, context)
		rows.append(row)
	return rows


static func build_surface_record(surface_id: String, subject_id: String = "", metadata: Dictionary = {}) -> Dictionary:
	var surface := get_surface(surface_id)
	if surface.is_empty():
		return {}

	var normalized_subject := subject_id.strip_edges()
	if normalized_subject.is_empty():
		normalized_subject = str(metadata.get("subject_id", "surface")).strip_edges()
	if normalized_subject.is_empty():
		normalized_subject = "surface"

	return {
		"record_id": "%s_%s" % [surface_id, normalized_subject],
		"surface_id": surface_id,
		"label": str(surface.get("label", surface_id)),
		"type": str(surface.get("type", "")),
		"location": str(surface.get("location", "")),
		"rules": (surface.get("rules", []) as Array).duplicate(true),
		"metadata": metadata.duplicate(true),
	}


static func get_summary_text(context: Dictionary = {}) -> String:
	var lines: Array[String] = ["Hidden clue surfaces:"]
	for surface in evaluate_context(context):
		var subject := str(surface.get("subject_id", "")).strip_edges()
		var subject_text := "" if subject.is_empty() else " / %s" % subject
		lines.append("%s - %s / %s%s: %s" % [
			str(surface.get("label", "Clue")),
			str(surface.get("status", "waiting")),
			str(surface.get("location", "Backroom")),
			subject_text,
			str(surface.get("summary", "")),
		])
	lines.append("Status: clue surfaces only; no active hidden objective")
	return "\n".join(lines)


static func _get_status_for_surface(surface: Dictionary, context: Dictionary) -> String:
	var signal_id := str(surface.get("signal", "")).strip_edges()
	if signal_id.is_empty() or signal_id == "always":
		return "available"
	return "available" if bool(context.get(signal_id, false)) else "waiting"


static func _get_subject_for_surface(surface: Dictionary, context: Dictionary) -> String:
	var surface_id := str(surface.get("surface_id", ""))
	var subject_key := "%s_subject" % surface_id
	return str(context.get(subject_key, "")).strip_edges()
