extends GutTest

const HiddenChoiceCatalogPolicy := preload("res://scripts/narrative/hidden_choice_catalog.gd")


func test_hidden_choice_catalog_covers_stop_10_choice_paths() -> void:
	var catalog := HiddenChoiceCatalogPolicy.get_choice_catalog()
	var choice_ids: Array[String] = []
	for choice in catalog:
		choice_ids.append(str(choice.get("choice_id", "")))

	assert_eq(catalog.size(), 8)
	assert_true(choice_ids.has("ignore"))
	assert_true(choice_ids.has("document"))
	assert_true(choice_ids.has("sell_as_normal"))
	assert_true(choice_ids.has("isolate_goods"))
	assert_true(choice_ids.has("report_issue"))
	assert_true(choice_ids.has("accept_cash_offer"))
	assert_true(choice_ids.has("reject_goods"))
	assert_true(choice_ids.has("follow_up_supplier"))


func test_hidden_choice_catalog_evaluates_context_readiness() -> void:
	var choices := HiddenChoiceCatalogPolicy.evaluate_context({
		"has_clue_surface": true,
		"has_serial_mismatch": true,
		"has_evidence_storage": true,
		"can_report_issue": true,
		"has_suspicious_customer": true,
		"has_supplier_message": true,
		"has_supplier_thread": true,
	})

	for choice in choices:
		assert_eq(choice.get("status"), "available")

	var summary := HiddenChoiceCatalogPolicy.get_summary_text({
		"has_clue_surface": true,
	})
	assert_string_contains(summary, "Ignore for now - available")
	assert_string_contains(summary, "Document evidence - available")
	assert_string_contains(summary, "Accept cash offer - waiting")
	assert_string_contains(summary, "consequences deferred")


func test_hidden_choice_catalog_builds_choice_records() -> void:
	var record := HiddenChoiceCatalogPolicy.build_choice_record(
		"document",
		"serial_mismatch_item_used_star_trader_003",
		{"surface_id": "serial_lookup"}
	)

	assert_eq(record.get("choice_record_id"), "document_serial_mismatch_item_used_star_trader_003")
	assert_eq(record.get("choice_id"), "document")
	assert_eq(record.get("label"), "Document evidence")
	assert_eq(record.get("stance"), "cautious")
	assert_eq(record.get("metadata").get("surface_id"), "serial_lookup")
