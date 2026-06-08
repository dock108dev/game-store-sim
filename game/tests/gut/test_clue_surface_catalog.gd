extends GutTest

const ClueSurfaceCatalogPolicy := preload("res://scripts/narrative/clue_surface_catalog.gd")


func test_clue_surface_catalog_covers_stop_10_clue_surfaces() -> void:
	var catalog := ClueSurfaceCatalogPolicy.get_surface_catalog()
	var surface_ids: Array[String] = []
	for surface in catalog:
		surface_ids.append(str(surface.get("surface_id", "")))

	assert_eq(catalog.size(), 7)
	assert_true(surface_ids.has("receiving_invoice"))
	assert_true(surface_ids.has("supplier_note"))
	assert_true(surface_ids.has("serial_lookup"))
	assert_true(surface_ids.has("supplier_email"))
	assert_true(surface_ids.has("customer_comment"))
	assert_true(surface_ids.has("security_clip"))
	assert_true(surface_ids.has("backroom_artifact"))


func test_clue_surface_catalog_evaluates_context_readiness() -> void:
	var surfaces := ClueSurfaceCatalogPolicy.evaluate_context({
		"has_receiving_batch": true,
		"has_supplier_message": true,
		"has_serial_mismatch": true,
		"has_supplier_order": true,
		"has_suspicious_customer": true,
		"has_security_footage_placeholder": true,
		"has_evidence_storage": true,
		"serial_lookup_subject": "serial_mismatch_item_used_star_trader_003",
	})

	for surface in surfaces:
		assert_eq(surface.get("status"), "available")

	var summary := ClueSurfaceCatalogPolicy.get_summary_text({
		"has_serial_mismatch": true,
		"serial_lookup_subject": "serial_mismatch_item_used_star_trader_003",
	})
	assert_string_contains(summary, "Serial lookup - available")
	assert_string_contains(summary, "Supplier note - waiting")
	assert_string_contains(summary, "no active hidden objective")


func test_clue_surface_catalog_builds_surface_records() -> void:
	var record := ClueSurfaceCatalogPolicy.build_surface_record(
		"security_clip",
		"clip_backroom_001",
		{"placeholder_id": "security_footage"}
	)

	assert_eq(record.get("record_id"), "security_clip_clip_backroom_001")
	assert_eq(record.get("type"), "security_clip")
	assert_eq(record.get("location"), "Backroom security monitor")
	assert_true((record.get("rules") as Array).has("hidden_storage"))
	assert_eq(record.get("metadata").get("placeholder_id"), "security_footage")
