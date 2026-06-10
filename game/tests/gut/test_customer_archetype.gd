extends GutTest

const ARCHETYPE_PATHS := [
	"res://data/customers/archetypes/browser.tres",
	"res://data/customers/archetypes/target_buyer.tres",
	"res://data/customers/archetypes/parent_gift_buyer.tres",
	"res://data/customers/archetypes/collector.tres",
	"res://data/customers/archetypes/trade_in_seller.tres",
	"res://data/customers/archetypes/return_customer.tres",
	"res://data/customers/archetypes/service_customer.tres",
	"res://data/customers/archetypes/regular.tres",
	"res://data/customers/archetypes/suspicious_contact.tres",
]


func test_customer_archetype_data_has_required_roles() -> void:
	var roles := {}
	for archetype in _load_archetypes():
		assert_true(archetype.is_valid_archetype())
		roles[archetype.role] = true

	for role in ["browse", "buy", "preorder", "trade_in", "return", "service", "regular", "suspicious"]:
		assert_true(roles.has(role), role)


func test_customer_archetype_data_has_unique_ids_and_tuning_ranges() -> void:
	var ids := {}
	for archetype in _load_archetypes():
		assert_false(ids.has(archetype.archetype_id), archetype.archetype_id)
		ids[archetype.archetype_id] = true
		assert_gte(archetype.price_sensitivity, 0.5)
		assert_lte(archetype.price_sensitivity, 1.5)
		assert_gte(archetype.patience_seconds, 5.0)
		assert_false(archetype.preferred_categories.is_empty(), archetype.archetype_id)
		assert_false(archetype.visual_cue.is_empty(), archetype.archetype_id)
		assert_false(archetype.default_feedback.is_empty(), archetype.archetype_id)
		assert_eq(archetype.get_alpha_copy_lines().size(), 4, archetype.archetype_id)
		for line in archetype.get_alpha_copy_lines():
			assert_gte(line.length(), 24, "%s:%s" % [archetype.archetype_id, line])

	assert_eq(ids.size(), 9)


func test_alpha_customer_copy_is_role_specific_and_non_placeholder() -> void:
	var blocked_fragments := ["Just looking", "Looking for this one", "Can you fix this?", "Cash, no receipt"]
	for archetype in _load_archetypes():
		var combined := " ".join(archetype.get_alpha_copy_lines())
		assert_string_contains(combined, "." if archetype.archetype_id != "regular" else "?")
		for fragment in blocked_fragments:
			assert_false(combined.contains(fragment), "%s still contains %s" % [archetype.archetype_id, fragment])
		assert_false(combined.to_lower().contains("placeholder"), archetype.archetype_id)


func test_suspicious_archetype_is_hidden_thread_contact_only() -> void:
	for archetype in _load_archetypes():
		if archetype.archetype_id == "suspicious_contact":
			assert_true(archetype.is_hidden_thread_contact())
			assert_eq(archetype.role, "suspicious")
		else:
			assert_false(archetype.is_hidden_thread_contact(), archetype.archetype_id)


func test_customer_scenes_are_wired_to_role_archetypes() -> void:
	var buyer: SimpleBuyerCustomer = load("res://scenes/customers/simple_buyer_customer.tscn").instantiate()
	var trade_customer: SimpleTradeInCustomer = load("res://scenes/customers/simple_trade_in_customer.tscn").instantiate()
	var preorder_customer: SimplePreorderCustomer = load("res://scenes/customers/simple_preorder_customer.tscn").instantiate()
	var service_customer: SimpleServiceCustomer = load("res://scenes/customers/simple_service_customer.tscn").instantiate()
	var return_customer: SimpleReturnCustomer = load("res://scenes/customers/simple_return_customer.tscn").instantiate()
	var suspicious_customer: SuspiciousCustomer = load("res://scenes/customers/suspicious_customer.tscn").instantiate()
	add_child_autofree(buyer)
	add_child_autofree(trade_customer)
	add_child_autofree(preorder_customer)
	add_child_autofree(service_customer)
	add_child_autofree(return_customer)
	add_child_autofree(suspicious_customer)

	assert_eq(buyer.archetype.archetype_id, "target_buyer")
	assert_eq(trade_customer.archetype.archetype_id, "trade_in_seller")
	assert_eq(preorder_customer.archetype.archetype_id, "collector")
	assert_eq(service_customer.archetype.archetype_id, "service_customer")
	assert_eq(return_customer.archetype.archetype_id, "return_customer")
	assert_eq(suspicious_customer.archetype.archetype_id, "suspicious_contact")
	assert_string_contains(suspicious_customer.get_archetype_summary(), "Suspicious Contact")


func _load_archetypes() -> Array[CustomerArchetype]:
	var archetypes: Array[CustomerArchetype] = []
	for path in ARCHETYPE_PATHS:
		var archetype := load(path) as CustomerArchetype
		assert_not_null(archetype, path)
		archetypes.append(archetype)
	return archetypes
