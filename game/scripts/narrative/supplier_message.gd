extends "res://scripts/interaction/interactable.gd"
class_name SupplierMessage

@export var message_id: String = ""
@export var supplier_id: String = ""
@export var subject: String = ""
@export_multiline var body: String = ""
@export var severity: String = "low"
@export var suspicious_event_id: String = ""


func _ready() -> void:
	if display_name == "Interactable":
		display_name = "Supplier Message"


func get_interaction_prompt() -> String:
	return "Click Read %s" % display_name


func interact() -> String:
	return get_message_text()


func get_message_text() -> String:
	var lines: Array[String] = []
	if not subject.strip_edges().is_empty():
		lines.append(subject.strip_edges())
	if not supplier_id.strip_edges().is_empty():
		lines.append("Supplier: %s" % supplier_id.strip_edges())
	if not message_id.strip_edges().is_empty():
		lines.append("Message: %s" % message_id.strip_edges())
	if not body.strip_edges().is_empty():
		lines.append(body.strip_edges())

	if lines.is_empty():
		return inspect_text

	return " - ".join(lines)


func get_suspicious_event_id() -> String:
	if not suspicious_event_id.strip_edges().is_empty():
		return suspicious_event_id.strip_edges()

	if not message_id.strip_edges().is_empty():
		return "supplier_message_%s" % message_id.strip_edges()

	return "supplier_message_unknown"


func flag_supplier_message(event_log: Node) -> Dictionary:
	if event_log == null or not event_log.has_method("flag_event"):
		return {}

	return event_log.flag_event(
		get_suspicious_event_id(),
		subject.strip_edges() if not subject.strip_edges().is_empty() else display_name,
		"supplier_message",
		severity,
		{
			"message_id": message_id.strip_edges(),
			"supplier_id": supplier_id.strip_edges(),
			"body": body.strip_edges(),
		}
	)
