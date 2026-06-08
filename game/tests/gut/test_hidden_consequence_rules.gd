extends GutTest

const HiddenConsequenceRulesPolicy := preload("res://scripts/narrative/hidden_consequence_rules.gd")


func test_hidden_consequence_rules_cover_stop_10_effect_channels() -> void:
	var catalog := HiddenConsequenceRulesPolicy.get_consequence_catalog()
	var choice_ids: Array[String] = []
	for row in catalog:
		choice_ids.append(str(row.get("choice_id", "")))
		assert_true(row.has("cash_delta_cents"))
		assert_true(row.has("reputation_delta"))
		assert_true(row.has("supplier_access_delta"))
		assert_true(row.has("customer_trust_delta"))
		assert_true(row.has("inspection_risk_delta"))
		assert_true(row.has("story_state"))

	assert_eq(catalog.size(), 8)
	assert_true(choice_ids.has("accept_cash_offer"))
	assert_true(choice_ids.has("report_issue"))
	assert_true(choice_ids.has("follow_up_supplier"))


func test_hidden_consequence_rules_build_events_from_choices() -> void:
	var event := HiddenConsequenceRulesPolicy.build_consequence_event({
		"choice_record_id": "accept_cash_offer_cash_buyer_bulk_request_001",
		"choice_id": "accept_cash_offer",
		"subject_id": "cash_buyer_bulk_request_001",
	})

	assert_eq(event.get("consequence_id"), "consequence_accept_cash_offer_cash_buyer_bulk_request_001")
	assert_eq(event.get("label"), "Accepted suspicious cash")
	assert_eq(event.get("cash_delta_cents"), 1200)
	assert_eq(event.get("reputation_delta"), -5)
	assert_eq(event.get("inspection_risk_delta"), 4)
	assert_eq(event.get("story_state"), "cash_accepted")


func test_hidden_consequence_rules_summary_lists_state_effects() -> void:
	var summary := HiddenConsequenceRulesPolicy.get_summary_text([
		HiddenConsequenceRulesPolicy.build_consequence_event({
			"choice_record_id": "document_serial_mismatch_item_used_star_trader_003",
			"choice_id": "document",
		})
	])

	assert_string_contains(summary, "Hidden consequences:")
	assert_string_contains(summary, "Documented evidence")
	assert_string_contains(summary, "rep +1")
	assert_string_contains(summary, "inspection -1")
