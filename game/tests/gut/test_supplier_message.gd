extends GutTest

var _message: Node


func before_each() -> void:
	_message = load("res://scenes/props/supplier_message.tscn").instantiate()
	add_child_autofree(_message)


func test_supplier_message_has_metadata() -> void:
	assert_eq(_message.message_id, "msg_supplier_lot_a17")
	assert_eq(_message.supplier_id, "North Dock Wholesale")
	assert_eq(_message.subject, "Receiving discrepancy")
	assert_eq(_message.severity, "medium")
	assert_eq(_message.get_suspicious_event_id(), "supplier_message_lot_a17")


func test_supplier_message_prompt_reads_as_note() -> void:
	assert_eq(_message.get_interaction_prompt(), "E Read Supplier Note")


func test_supplier_message_inspect_text_contains_artifact_details() -> void:
	var text: String = _message.interact()

	assert_string_contains(text, "Receiving discrepancy")
	assert_string_contains(text, "North Dock Wholesale")
	assert_string_contains(text, "msg_supplier_lot_a17")
	assert_string_contains(text, "one case serial does not match")


func test_supplier_message_flags_hidden_event() -> void:
	var log: Node = load("res://scripts/narrative/suspicious_event_log.gd").new()
	add_child_autofree(log)

	var event: Dictionary = _message.flag_supplier_message(log)

	assert_eq(event.get("event_id"), "supplier_message_lot_a17")
	assert_eq(event.get("title"), "Receiving discrepancy")
	assert_eq(event.get("source"), "supplier_message")
	assert_eq(event.get("severity"), "medium")
	assert_eq(event.get("metadata").get("message_id"), "msg_supplier_lot_a17")
	assert_eq(event.get("metadata").get("supplier_id"), "North Dock Wholesale")
	assert_true(log.has_event("supplier_message_lot_a17"))


func test_supplier_message_has_visible_note_mesh_and_collision() -> void:
	assert_not_null(_message.get_node_or_null("NoteMesh"))
	var collision_shape := _message.get_node_or_null("CollisionShape3D") as CollisionShape3D
	assert_not_null(collision_shape)
	assert_false(collision_shape.disabled)
