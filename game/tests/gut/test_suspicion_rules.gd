extends GutTest

const SuspicionRulesPolicy := preload("res://scripts/narrative/suspicion_rules.gd")


func test_suspicion_rules_catalog_covers_stop_10_rule_set() -> void:
	var catalog := SuspicionRulesPolicy.get_rule_catalog()
	var rule_ids: Array[String] = []
	for rule in catalog:
		rule_ids.append(str(rule.get("rule_id", "")))

	assert_eq(catalog.size(), 6)
	assert_true(rule_ids.has("serial_mismatch"))
	assert_true(rule_ids.has("suspicious_supplier"))
	assert_true(rule_ids.has("cash_buyer"))
	assert_true(rule_ids.has("impossible_provenance"))
	assert_true(rule_ids.has("counterfeit_goods"))
	assert_true(rule_ids.has("hidden_storage"))
	assert_string_contains(SuspicionRulesPolicy.get_summary_text(), "Suspicion rules:")


func test_suspicion_rules_evaluate_metadata_and_score_flags() -> void:
	var flags := SuspicionRulesPolicy.evaluate_metadata({
		"instance_id": "item_used_star_trader_003",
		"serial_id": "GST-1047",
		"expected_serial_id": "GST-003",
		"authenticity": "needs_review",
		"risk_tags": ["serial_check"],
	})

	assert_eq(flags.size(), 2)
	assert_eq(flags[0].get("rule_id"), "serial_mismatch")
	assert_eq(flags[1].get("rule_id"), "counterfeit_goods")
	assert_eq(SuspicionRulesPolicy.get_highest_severity(flags), "high")
	assert_eq(SuspicionRulesPolicy.score_flags(flags), 90)


func test_suspicion_rules_evaluate_supplier_customer_provenance_and_storage() -> void:
	var flags := SuspicionRulesPolicy.evaluate_metadata({
		"source": "supplier_message",
		"message_id": "msg_supplier_lot_a17",
		"subject": "Receiving discrepancy",
		"body": "Keep it quiet; one case is off manifest for cash pickup.",
		"severity": "medium",
		"provenance_status": "impossible",
		"location_id": "suspicious_goods_isolation",
	})
	var rule_ids: Array[String] = []
	for flag in flags:
		rule_ids.append(str(flag.get("rule_id", "")))

	assert_true(rule_ids.has("suspicious_supplier"))
	assert_true(rule_ids.has("cash_buyer"))
	assert_true(rule_ids.has("impossible_provenance"))
	assert_true(rule_ids.has("hidden_storage"))


func test_suspicion_rules_evaluate_nodes_without_activating_objectives() -> void:
	var item: StaticBody3D = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	var message: SupplierMessage = load("res://scenes/props/supplier_message.tscn").instantiate()
	var customer: SuspiciousCustomer = load("res://scenes/customers/suspicious_customer.tscn").instantiate()
	add_child_autofree(item)
	add_child_autofree(message)
	add_child_autofree(customer)
	item.set("serial_id", "GST-1047")
	item.set("expected_serial_id", "GST-003")

	assert_eq(SuspicionRulesPolicy.evaluate_product_item(item)[0].get("rule_id"), "serial_mismatch")
	assert_eq(SuspicionRulesPolicy.evaluate_supplier_message(message)[0].get("rule_id"), "suspicious_supplier")
	assert_eq(SuspicionRulesPolicy.evaluate_customer(customer)[0].get("rule_id"), "cash_buyer")


func test_suspicious_event_log_flags_rule_events() -> void:
	var log: SuspiciousEventLog = load("res://scripts/narrative/suspicious_event_log.gd").new()
	add_child_autofree(log)

	var event := log.flag_rule("cash_buyer", "cash_buyer_bulk_request_001", {"customer_id": "cash_buyer_001"})

	assert_eq(event.get("event_id"), "cash_buyer_cash_buyer_bulk_request_001")
	assert_eq(event.get("title"), "Cash buyer")
	assert_eq(event.get("source"), "customer")
	assert_eq(event.get("severity"), "medium")
	assert_eq(event.get("metadata").get("rule_id"), "cash_buyer")
	assert_true(log.get_rule_summary_text().contains("Cash buyer"))

	var updated_event := log.flag_rule("cash_buyer", "cash_buyer_bulk_request_001", {"customer_id": "cash_buyer_002"})
	assert_eq(log.get_event_count(), 1)
	assert_eq(updated_event.get("metadata").get("customer_id"), "cash_buyer_001")
