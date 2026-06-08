extends GutTest


func test_customer_feedback_bubble_shows_tone_and_truncates_text() -> void:
	var bubble := CustomerFeedbackBubble.new()
	add_child_autofree(bubble)
	bubble.max_characters = 12

	bubble.show_feedback("This message is intentionally long", CustomerFeedbackBubble.TONE_WARNING)

	assert_true(bubble.visible)
	assert_eq(bubble.tone, CustomerFeedbackBubble.TONE_WARNING)
	assert_lte(bubble.text.length(), 12)
	assert_eq(bubble.modulate, Color(1.0, 0.78, 0.38, 1.0))

	bubble.clear_feedback()

	assert_false(bubble.visible)
	assert_eq(bubble.text, "")


func test_customer_scenes_have_feedback_bubbles() -> void:
	for scene_path in [
		"res://scenes/customers/simple_buyer_customer.tscn",
		"res://scenes/customers/simple_trade_in_customer.tscn",
		"res://scenes/customers/simple_preorder_customer.tscn",
		"res://scenes/customers/simple_service_customer.tscn",
		"res://scenes/customers/suspicious_customer.tscn",
	]:
		var customer: Node = load(scene_path).instantiate()
		add_child_autofree(customer)
		var bubble := customer.get_node_or_null("FeedbackBubble") as CustomerFeedbackBubble
		assert_not_null(bubble)
		assert_gt(bubble.position.y, 1.5)


func test_buyer_feedback_bubble_reacts_to_purchase_intent_and_price_refusal() -> void:
	var customer: SimpleBuyerCustomer = load("res://scenes/customers/simple_buyer_customer.tscn").instantiate()
	var item: Node3D = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(customer)
	add_child_autofree(item)

	assert_true(customer.would_buy_item(item))
	assert_eq(customer.get_feedback_summary().get("tone"), CustomerFeedbackBubble.TONE_POSITIVE)
	assert_string_contains(str(customer.get_feedback_summary().get("text")), "Interested")

	item.set("current_price_cents", 4000)
	assert_false(customer.would_buy_item(item))
	assert_eq(customer.get_feedback_summary().get("tone"), CustomerFeedbackBubble.TONE_WARNING)
	assert_string_contains(str(customer.get_feedback_summary().get("text")), "expensive")


func test_special_customer_feedback_bubbles_react_to_outcomes() -> void:
	var trade_customer: SimpleTradeInCustomer = load("res://scenes/customers/simple_trade_in_customer.tscn").instantiate()
	add_child_autofree(trade_customer)
	assert_eq(trade_customer.get_feedback_summary().get("tone"), CustomerFeedbackBubble.TONE_INFO)
	trade_customer.decline_trade_in()
	assert_eq(trade_customer.get_feedback_summary().get("tone"), CustomerFeedbackBubble.TONE_WARNING)
	assert_string_contains(str(trade_customer.get_feedback_summary().get("text")), "No deal")

	var preorder_customer: SimplePreorderCustomer = load("res://scenes/customers/simple_preorder_customer.tscn").instantiate()
	add_child_autofree(preorder_customer)
	preorder_customer.complete_preorder()
	assert_eq(preorder_customer.get_feedback_summary().get("tone"), CustomerFeedbackBubble.TONE_POSITIVE)
	assert_string_contains(str(preorder_customer.get_feedback_summary().get("text")), "Preorder")

	var service_customer: SimpleServiceCustomer = load("res://scenes/customers/simple_service_customer.tscn").instantiate()
	add_child_autofree(service_customer)
	service_customer.complete_service()
	assert_eq(service_customer.get_feedback_summary().get("tone"), CustomerFeedbackBubble.TONE_POSITIVE)
	assert_string_contains(str(service_customer.get_feedback_summary().get("text")), "Service")

	var suspicious_customer: SuspiciousCustomer = load("res://scenes/customers/suspicious_customer.tscn").instantiate()
	add_child_autofree(suspicious_customer)
	assert_eq(suspicious_customer.get_feedback_summary().get("tone"), CustomerFeedbackBubble.TONE_SUSPICIOUS)
	suspicious_customer.interact()
	assert_string_contains(str(suspicious_customer.get_feedback_summary().get("text")), "quiet")
