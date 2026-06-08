extends GutTest

const DIALOGUE_PATHS := [
	"res://data/customers/dialogue/help_request.tres",
	"res://data/customers/dialogue/recommendation_request.tres",
	"res://data/customers/dialogue/trade_in_pushback.tres",
	"res://data/customers/dialogue/complaint_return.tres",
	"res://data/customers/dialogue/hidden_thread_probe.tres",
]

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


func test_customer_dialogue_flows_cover_required_conversation_types() -> void:
	var triggers := {}
	for flow in _load_dialogue_flows():
		assert_true(flow.is_valid_flow())
		triggers[flow.trigger] = true

	for trigger in ["help", "recommendation", "trade_in_offer", "complaint", "hidden_probe"]:
		assert_true(triggers.has(trigger), trigger)


func test_customer_dialogue_flows_have_options_responses_and_preview() -> void:
	for flow in _load_dialogue_flows():
		assert_gte(flow.player_options.size(), 3, flow.flow_id)
		assert_gte(flow.response_lines.size(), 3, flow.flow_id)
		assert_false(flow.consequence_key.is_empty(), flow.flow_id)
		assert_string_contains(flow.preview_line(), "->")


func test_hidden_thread_dialogue_probe_is_isolated() -> void:
	for flow in _load_dialogue_flows():
		if flow.flow_id == "hidden_thread_probe":
			assert_true(flow.is_hidden_probe())
			assert_eq(flow.archetype_id, "suspicious_contact")
		else:
			assert_false(flow.is_hidden_probe(), flow.flow_id)


func test_archetype_dialogue_flow_ids_resolve_to_seeded_flows() -> void:
	var flow_ids := {}
	for flow in _load_dialogue_flows():
		flow_ids[flow.flow_id] = true

	for path in ARCHETYPE_PATHS:
		var archetype := load(path) as CustomerArchetype
		assert_not_null(archetype, path)
		assert_false(archetype.dialogue_flow_ids.is_empty(), archetype.archetype_id)
		for flow_id in archetype.dialogue_flow_ids:
			assert_true(flow_ids.has(flow_id), "%s:%s" % [archetype.archetype_id, flow_id])


func _load_dialogue_flows() -> Array[CustomerDialogueFlow]:
	var flows: Array[CustomerDialogueFlow] = []
	for path in DIALOGUE_PATHS:
		var flow := load(path) as CustomerDialogueFlow
		assert_not_null(flow, path)
		flows.append(flow)
	return flows
