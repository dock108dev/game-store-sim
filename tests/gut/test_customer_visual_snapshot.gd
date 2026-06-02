extends GutTest

const StoreSessionCharacterVisualFactoryScript: GDScript = preload(
	"res://game/scripts/visuals/store_session_character_visual_factory.gd"
)
const CustomerVisualProfileScript: GDScript = preload(
	"res://game/scripts/characters/customer_visual_profile.gd"
)


func test_visual_snapshot_exposes_state_profile_patience_and_readiness() -> void:
	var customer: Customer = _make_customer("retro_confused_parent", &"confused_parent")
	var item: ItemInstance = _make_item("starter_case")
	customer._desired_item = item
	customer.current_state = Customer.State.BROWSING
	customer.patience_timer = 36.0
	customer._initial_patience_seconds = 120.0

	var snapshot: Dictionary = customer.get_visual_snapshot()

	assert_eq(snapshot.get("fsm_state_name"), "BROWSING")
	assert_eq(snapshot.get("profile_id"), "retro_confused_parent")
	assert_eq(snapshot.get("archetype_id"), &"confused_parent")
	assert_eq(snapshot.get("visual_state"), CustomerVisualProfileScript.VISUAL_STATE_NEEDS_HELP)
	assert_true(bool(snapshot.get("desired_item_present")))
	assert_eq(snapshot.get("desired_item_definition_id"), "starter_case")
	assert_almost_eq(float(snapshot.get("patience_ratio")), 0.3, 0.001)
	assert_false(bool(snapshot.get("queue_ready")))
	assert_false(bool(snapshot.get("counter_ready")))


func test_visual_snapshot_reports_queue_counter_and_leaving_reactions() -> void:
	var customer: Customer = _make_customer("retro_hype_teen", &"hype_teen")
	customer.current_state = Customer.State.WAITING_IN_QUEUE
	customer.patience_timer = 12.0
	customer._initial_patience_seconds = 120.0
	var queued: Dictionary = customer.get_visual_snapshot()
	assert_eq(queued.get("visual_state"), CustomerVisualProfileScript.VISUAL_STATE_ANNOYED)
	assert_true(bool(queued.get("queue_ready")))

	customer.complete_purchase(true)
	var sold: Dictionary = customer.get_visual_snapshot()
	assert_eq(sold.get("reaction_intent"), CustomerVisualProfileScript.INTENT_SALE)
	assert_eq(sold.get("visual_state"), CustomerVisualProfileScript.VISUAL_STATE_LEAVING_HAPPY)

	var declined: Customer = _make_customer("retro_bargain_hunter", &"bargain_hunter")
	declined.complete_purchase(false)
	var no_sale: Dictionary = declined.get_visual_snapshot()
	assert_eq(no_sale.get("reaction_intent"), CustomerVisualProfileScript.INTENT_NO_SALE)
	assert_eq(no_sale.get("visual_state"), CustomerVisualProfileScript.VISUAL_STATE_LEAVING_UPSET)


func test_customer_refresh_creates_non_text_accent_state_patience_and_reaction_cues() -> void:
	var customer: Customer = _make_customer("vip_customer", &"vip_customer")
	customer.current_state = Customer.State.DECIDING
	customer.patience_timer = 80.0
	customer._initial_patience_seconds = 100.0
	customer.refresh_visual_cues(false)

	var body: Node = customer.get_node_or_null("BodyMesh")
	assert_not_null(body)
	if body == null:
		return
	for part_name: String in [
		"StateCue",
		"PatienceCue",
		"ArchetypeAccentPrimary",
		"ArchetypeAccentSecondary",
	]:
		var part: MeshInstance3D = body.get_node_or_null(part_name) as MeshInstance3D
		assert_not_null(part, "Cue mesh exists: %s" % part_name)
		if part != null:
			assert_null(part.get_script(), "Cue mesh is visual-only: %s" % part_name)

	var accent: MeshInstance3D = (
		body.get_node_or_null("ArchetypeAccentPrimary") as MeshInstance3D
	)
	assert_eq(str(accent.get_meta("accent_key", "")), "vip_customer")

	customer.complete_purchase(false)
	var reaction: MeshInstance3D = (
		customer.get_node_or_null("HeadMesh/ReactionCue") as MeshInstance3D
	)
	assert_not_null(reaction)
	if reaction != null:
		assert_true(reaction.visible)
		assert_eq(
			str(reaction.get_meta("reaction_intent", "")),
			String(CustomerVisualProfileScript.INTENT_NO_SALE)
		)


func test_all_runtime_archetype_accents_are_distinct() -> void:
	var entries: Array[Dictionary] = [
		{"profile": "retro_collector", "archetype": &"collector"},
		{"profile": "retro_parent", "archetype": &"confused_parent"},
		{"profile": "retro_bargain_hunter", "archetype": &"bargain_hunter"},
		{"profile": "retro_hype_teen", "archetype": &"hype_teen"},
		{"profile": "retro_sports_crossover", "archetype": &"sports_regular"},
		{"profile": "retro_reseller", "archetype": &""},
		{"profile": "customer_casual_browser", "archetype": &""},
		{"profile": "retro_angry_return", "archetype": &"angry_return_customer"},
		{"profile": "retro_shady_regular", "archetype": &"shady_regular"},
		{"profile": "vip_customer", "archetype": &""},
	]
	var seen_signatures: Dictionary = {}
	for entry: Dictionary in entries:
		var accent: Dictionary = CustomerVisualProfileScript.accent_for(
			str(entry.get("profile", "")),
			StringName(str(entry.get("archetype", "")))
		)
		var signature: String = "%s:%s" % [
			str(accent.get("key", "")),
			str(accent.get("shape", "")),
		]
		assert_false(
			seen_signatures.has(signature),
			"Accent signature must be distinct: %s" % signature
		)
		seen_signatures[signature] = true


func test_animator_supports_production_visual_intents() -> void:
	var fixture: Dictionary = _make_animator()
	var animator: CustomerAnimator = fixture.get("animator") as CustomerAnimator
	var player: AnimationPlayer = fixture.get("player") as AnimationPlayer
	for intent: StringName in [
		CustomerVisualProfileScript.INTENT_BROWSE_SCAN,
		CustomerVisualProfileScript.INTENT_COMPARE_THINK,
		CustomerVisualProfileScript.INTENT_QUEUE_WAIT,
		CustomerVisualProfileScript.INTENT_COUNTER_READY,
		CustomerVisualProfileScript.INTENT_LEAVE_SATISFIED,
		CustomerVisualProfileScript.INTENT_LEAVE_FRUSTRATED,
		CustomerVisualProfileScript.INTENT_PRICE_SHOCK,
		CustomerVisualProfileScript.INTENT_TRADE_IN,
		CustomerVisualProfileScript.INTENT_SALE,
		CustomerVisualProfileScript.INTENT_NO_SALE,
		CustomerVisualProfileScript.INTENT_BUNDLE_ACCEPTED,
		CustomerVisualProfileScript.INTENT_BUNDLE_REJECTED,
		CustomerVisualProfileScript.INTENT_CLEAN_EXCHANGE,
		CustomerVisualProfileScript.INTENT_REFUSED_RETURN,
		CustomerVisualProfileScript.INTENT_ACCEPTED_TRADE_IN,
		CustomerVisualProfileScript.INTENT_PAYOUT_TRADE_IN,
	]:
		assert_true(animator.supports_intent(intent), "Intent supported: %s" % intent)
		animator.play_intent(intent)
		assert_eq(player.current_animation, String(intent))
		assert_eq(animator.get_current_intent(), intent)


func test_store_session_customer_accent_parts_are_visual_only() -> void:
	var proxy := Node3D.new()
	add_child_autofree(proxy)

	StoreSessionCharacterVisualFactoryScript.configure_customer_proxy(
		proxy,
		false,
		"retro_shady_regular",
		&"shady_regular"
	)

	var primary: MeshInstance3D = (
		proxy.get_node_or_null("ArchetypeAccentPrimary") as MeshInstance3D
	)
	var secondary: MeshInstance3D = (
		proxy.get_node_or_null("ArchetypeAccentSecondary") as MeshInstance3D
	)
	assert_not_null(primary)
	assert_not_null(secondary)
	if primary == null or secondary == null:
		return
	assert_true(primary.visible)
	assert_true(secondary.visible)
	assert_eq(str(primary.get_meta("accent_key", "")), "shady_regular")
	assert_null(primary.get_script())
	assert_null(secondary.get_script())
	assert_false(_has_interaction_descendant(proxy))

	StoreSessionCharacterVisualFactoryScript.configure_customer_proxy(proxy, true)
	assert_false(primary.visible, "Manager proxy hides customer accents")


func _make_customer(profile_id: String, archetype_id: StringName) -> Customer:
	var customer := Customer.new()
	var body := MeshInstance3D.new()
	body.name = "BodyMesh"
	customer.add_child(body)
	var head := MeshInstance3D.new()
	head.name = "HeadMesh"
	customer.add_child(head)
	add_child_autofree(customer)
	customer.profile = _make_profile(profile_id, archetype_id)
	customer._initial_patience_seconds = 120.0
	customer.patience_timer = 120.0
	customer.refresh_visual_cues(false)
	return customer


func _make_profile(profile_id: String, archetype_id: StringName) -> CustomerTypeDefinition:
	var profile := CustomerTypeDefinition.new()
	profile.id = profile_id
	profile.customer_name = profile_id.capitalize()
	profile.archetype_id = archetype_id
	profile.patience = 1.0
	profile.budget_range = [0.0, 100.0]
	return profile


func _make_item(item_id: String) -> ItemInstance:
	var definition := ItemDefinition.new()
	definition.id = item_id
	definition.item_name = item_id.capitalize()
	definition.category = "games"
	definition.base_price = 20.0
	definition.rarity = "common"
	definition.tags = PackedStringArray([])
	definition.condition_range = PackedStringArray(["good"])
	definition.store_type = "retro_games"
	return ItemInstance.create_from_definition(definition, "good")


func _make_animator() -> Dictionary:
	var root := Node3D.new()
	add_child_autofree(root)
	var body := MeshInstance3D.new()
	body.name = "BodyMesh"
	root.add_child(body)
	for arm_name: String in ["LeftArm", "RightArm"]:
		var arm := MeshInstance3D.new()
		arm.name = arm_name
		body.add_child(arm)
		var hand := MeshInstance3D.new()
		hand.name = "%sHand" % arm_name.trim_suffix("Arm")
		arm.add_child(hand)
	var head := MeshInstance3D.new()
	head.name = "HeadMesh"
	root.add_child(head)
	var collision := CollisionShape3D.new()
	collision.name = "CollisionShape3D"
	root.add_child(collision)
	var player := AnimationPlayer.new()
	player.name = "AnimationPlayer"
	root.add_child(player)
	var animator := CustomerAnimator.new()
	animator.name = "CustomerAnimator"
	root.add_child(animator)
	animator.initialize(player)
	return {"animator": animator, "player": player}


func _has_interaction_descendant(node: Node) -> bool:
	if (
		node is Area3D
		or node is CollisionShape3D
		or node is PhysicsBody3D
		or node is NavigationObstacle3D
		or node is Interactable
	):
		return true
	for child: Node in node.get_children():
		if _has_interaction_descendant(child):
			return true
	return false
