extends GutTest

var _customer: Node


func before_each() -> void:
	_customer = load("res://scenes/customers/suspicious_customer.tscn").instantiate()
	add_child_autofree(_customer)


func test_suspicious_customer_has_metadata() -> void:
	assert_eq(_customer.customer_id, "suspicious_customer_001")
	assert_eq(_customer.encounter_id, "cash_buyer_bulk_request_001")
	assert_eq(_customer.subject, "Bulk cash buyer")
	assert_eq(_customer.severity, "medium")
	assert_eq(_customer.get_suspicious_event_id(), "cash_buyer_bulk_request_001")


func test_suspicious_customer_prompt_reads_as_optional_talk() -> void:
	assert_eq(_customer.get_interaction_prompt(), "E Talk To Cash Buyer")


func test_suspicious_customer_interaction_text_contains_hidden_clues() -> void:
	var text: String = _customer.interact()

	assert_string_contains(text, "Bulk cash buyer")
	assert_string_contains(text, "Orbit 64")
	assert_string_contains(text, "without receipts")
	assert_string_contains(text, "North Dock Wholesale")


func test_suspicious_customer_flags_event_and_stores_evidence() -> void:
	var log: Node = load("res://scripts/narrative/suspicious_event_log.gd").new()
	var storage: Node = load("res://scripts/narrative/evidence_storage.gd").new()
	add_child_autofree(log)
	add_child_autofree(storage)

	var event: Dictionary = _customer.flag_encounter(log, storage)
	var evidence: Dictionary = storage.get_evidence("cash_buyer_bulk_request_001")

	assert_eq(event.get("event_id"), "cash_buyer_bulk_request_001")
	assert_eq(event.get("title"), "Bulk cash buyer")
	assert_eq(event.get("source"), "suspicious_customer")
	assert_eq(event.get("severity"), "medium")
	assert_eq(event.get("metadata").get("customer_id"), "suspicious_customer_001")
	assert_eq(event.get("metadata").get("encounter_id"), "cash_buyer_bulk_request_001")
	assert_eq(evidence.get("evidence_id"), "cash_buyer_bulk_request_001")
	assert_eq(evidence.get("source"), "suspicious_customer")
	assert_true(log.has_event("cash_buyer_bulk_request_001"))
	assert_true(storage.has_evidence("cash_buyer_bulk_request_001"))


func test_suspicious_customer_flagging_is_idempotent() -> void:
	var log: Node = load("res://scripts/narrative/suspicious_event_log.gd").new()
	var storage: Node = load("res://scripts/narrative/evidence_storage.gd").new()
	add_child_autofree(log)
	add_child_autofree(storage)

	_customer.flag_encounter(log, storage)
	_customer.flag_encounter(log, storage)

	assert_eq(log.get_event_count(), 1)
	assert_eq(storage.get_evidence_count(), 1)


func test_suspicious_customer_has_visible_mesh_and_collision() -> void:
	assert_not_null(_customer.get_node_or_null("BodyMesh"))
	assert_not_null(_customer.get_node_or_null("HeadMesh"))
	assert_not_null(_customer.get_node_or_null("NoteMesh"))

	var collision_shape := _customer.get_node_or_null("CollisionShape3D") as CollisionShape3D
	assert_not_null(collision_shape)
	assert_false(collision_shape.disabled)
