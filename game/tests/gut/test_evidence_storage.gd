extends GutTest

var _storage: Node


func before_each() -> void:
	_storage = load("res://scripts/narrative/evidence_storage.gd").new()
	add_child_autofree(_storage)


func test_evidence_storage_starts_empty() -> void:
	assert_eq(_storage.get_evidence_count(), 0)
	assert_eq(_storage.get_all_evidence(), [])
	assert_eq(_storage.get_summary_text(), "Evidence stored: none")


func test_evidence_storage_records_evidence() -> void:
	var evidence: Dictionary = _storage.store_evidence(" serial_001 ", "Serial mismatch", "inventory", {
		"instance_id": "item_001",
	})

	assert_eq(evidence.get("evidence_id"), "serial_001")
	assert_eq(evidence.get("title"), "Serial mismatch")
	assert_eq(evidence.get("source"), "inventory")
	assert_eq(evidence.get("metadata").get("instance_id"), "item_001")
	assert_true(_storage.has_evidence("serial_001"))
	assert_eq(_storage.get_evidence_count(), 1)


func test_evidence_storage_deduplicates_evidence_ids() -> void:
	_storage.store_evidence("supplier_message_lot_a17", "Supplier note", "receiving")
	_storage.store_evidence("supplier_message_lot_a17", "Duplicate supplier note", "backroom")

	assert_eq(_storage.get_evidence_count(), 1)
	assert_eq(_storage.get_evidence("supplier_message_lot_a17").get("title"), "Supplier note")
	assert_eq(_storage.get_evidence("supplier_message_lot_a17").get("source"), "receiving")


func test_evidence_storage_rejects_empty_ids() -> void:
	assert_eq(_storage.store_evidence("", "Missing id"), {})
	assert_eq(_storage.get_evidence_count(), 0)


func test_evidence_storage_can_store_mismatched_serial_item() -> void:
	var item := load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(item)
	item.instance_id = "item_used_star_trader_003"
	item.serial_id = "GST-1047"
	item.expected_serial_id = "GST-003"
	item.suspicious_event_id = "serial_mismatch_item_used_star_trader_003"

	var evidence: Dictionary = _storage.store_from_node(item)

	assert_eq(evidence.get("evidence_id"), "serial_mismatch_item_used_star_trader_003")
	assert_eq(evidence.get("title"), "Star Trader")
	assert_eq(evidence.get("metadata").get("instance_id"), "item_used_star_trader_003")
	assert_eq(evidence.get("metadata").get("serial_id"), "GST-1047")
	assert_eq(evidence.get("metadata").get("expected_serial_id"), "GST-003")
	assert_eq(evidence.get("metadata").get("product"), "used_star_trader")


func test_evidence_storage_ignores_normal_product_items() -> void:
	var item := load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(item)

	assert_eq(_storage.store_from_node(item), {})
	assert_eq(_storage.get_evidence_count(), 0)


func test_evidence_storage_can_store_supplier_message() -> void:
	var message := load("res://scenes/props/supplier_message.tscn").instantiate()
	add_child_autofree(message)

	var evidence: Dictionary = _storage.store_from_node(message)

	assert_eq(evidence.get("evidence_id"), "supplier_message_lot_a17")
	assert_eq(evidence.get("title"), "Receiving discrepancy")
	assert_eq(evidence.get("metadata").get("message_id"), "msg_supplier_lot_a17")
	assert_eq(evidence.get("metadata").get("supplier_id"), "North Dock Wholesale")
