extends GutTest


func test_suspicious_event_log_starts_empty() -> void:
	var log: Node = load("res://scripts/narrative/suspicious_event_log.gd").new()
	add_child_autofree(log)

	assert_eq(log.get_event_count(), 0)
	assert_eq(log.get_events(), [])
	assert_eq(log.get_summary_text(), "Suspicious events: none")


func test_suspicious_event_log_records_event_flags() -> void:
	var log: Node = load("res://scripts/narrative/suspicious_event_log.gd").new()
	add_child_autofree(log)

	var event: Dictionary = log.flag_event("serial_mismatch_001", "Serial mismatch", "register", "high", {
		"item_instance_id": "item_001",
	})

	assert_eq(event.get("event_id"), "serial_mismatch_001")
	assert_eq(event.get("title"), "Serial mismatch")
	assert_eq(event.get("source"), "register")
	assert_eq(event.get("severity"), "high")
	assert_true(log.has_event("serial_mismatch_001"))
	assert_eq(log.get_event_count(), 1)
	assert_eq(log.get_event("serial_mismatch_001").get("metadata").get("item_instance_id"), "item_001")


func test_suspicious_event_log_deduplicates_event_ids() -> void:
	var log: Node = load("res://scripts/narrative/suspicious_event_log.gd").new()
	add_child_autofree(log)

	log.flag_event("supplier_note_001", "Supplier note", "backroom", "medium")
	log.flag_event("supplier_note_001", "Duplicate supplier note", "backroom", "high")

	assert_eq(log.get_event_count(), 1)
	assert_eq(log.get_event("supplier_note_001").get("title"), "Supplier note")
	assert_eq(log.get_event("supplier_note_001").get("severity"), "medium")


func test_suspicious_event_log_normalizes_invalid_input() -> void:
	var log: Node = load("res://scripts/narrative/suspicious_event_log.gd").new()
	add_child_autofree(log)

	assert_true(log.flag_event("", "Missing id").is_empty())
	var event: Dictionary = log.flag_event("  odd_trade_001  ", "", "trade-in", "urgent")

	assert_eq(event.get("event_id"), "odd_trade_001")
	assert_eq(event.get("title"), "odd_trade_001")
	assert_eq(event.get("severity"), "low")
