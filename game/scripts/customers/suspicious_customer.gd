extends "res://scripts/interaction/interactable.gd"
class_name SuspiciousCustomer

@export var customer_id: String = "suspicious_customer_001"
@export var encounter_id: String = "cash_buyer_bulk_request_001"
@export var subject: String = "Bulk cash buyer"
@export_multiline var dialogue_text: String = ""
@export var severity: String = "medium"
@export var event_log_path: NodePath
@export var evidence_storage_path: NodePath


func _ready() -> void:
	if display_name == "Interactable":
		display_name = "Cash Buyer"
	if inspect_text == "Nothing interesting yet." and not dialogue_text.strip_edges().is_empty():
		inspect_text = dialogue_text.strip_edges()
	show_customer_feedback("Cash?", CustomerFeedbackBubble.TONE_SUSPICIOUS)


func get_interaction_prompt() -> String:
	return "Click Talk To %s" % display_name


func interact() -> String:
	flag_encounter()
	show_customer_feedback("Keep it quiet.", CustomerFeedbackBubble.TONE_SUSPICIOUS)
	return get_encounter_text()


func show_customer_feedback(message: String, tone: String = CustomerFeedbackBubble.TONE_INFO) -> void:
	var bubble := _feedback_bubble()
	if bubble != null:
		bubble.show_feedback(message, tone)


func get_feedback_summary() -> Dictionary:
	var bubble := _feedback_bubble()
	if bubble == null:
		return {}

	return bubble.get_feedback_summary()


func get_encounter_text() -> String:
	var lines: Array[String] = []
	if not subject.strip_edges().is_empty():
		lines.append(subject.strip_edges())
	if not dialogue_text.strip_edges().is_empty():
		lines.append(dialogue_text.strip_edges())
	if not customer_id.strip_edges().is_empty():
		lines.append("Customer: %s" % customer_id.strip_edges())

	if lines.is_empty():
		return inspect_text

	return " - ".join(lines)


func get_suspicious_event_id() -> String:
	if not encounter_id.strip_edges().is_empty():
		return encounter_id.strip_edges()

	return "suspicious_customer_%s" % customer_id.strip_edges()


func flag_encounter(event_log: Node = null, evidence_storage: Node = null) -> Dictionary:
	var metadata := _metadata()
	var event := _flag_event(event_log, metadata)
	_store_evidence(evidence_storage, metadata)
	return event


func _flag_event(event_log: Node, metadata: Dictionary) -> Dictionary:
	var target_log := event_log
	if target_log == null and not event_log_path.is_empty():
		target_log = get_node_or_null(event_log_path)

	if target_log == null or not target_log.has_method("flag_event"):
		return {}

	return target_log.flag_event(
		get_suspicious_event_id(),
		subject.strip_edges() if not subject.strip_edges().is_empty() else display_name,
		"suspicious_customer",
		severity,
		metadata
	)


func _store_evidence(evidence_storage: Node, metadata: Dictionary) -> Dictionary:
	var target_storage := evidence_storage
	if target_storage == null and not evidence_storage_path.is_empty():
		target_storage = get_node_or_null(evidence_storage_path)

	if target_storage == null or not target_storage.has_method("store_evidence"):
		return {}

	return target_storage.store_evidence(
		get_suspicious_event_id(),
		subject.strip_edges() if not subject.strip_edges().is_empty() else display_name,
		"suspicious_customer",
		metadata
	)


func _metadata() -> Dictionary:
	return {
		"customer_id": customer_id.strip_edges(),
		"encounter_id": get_suspicious_event_id(),
		"subject": subject.strip_edges(),
		"dialogue_text": dialogue_text.strip_edges(),
	}


func _feedback_bubble() -> CustomerFeedbackBubble:
	return get_node_or_null("FeedbackBubble") as CustomerFeedbackBubble
