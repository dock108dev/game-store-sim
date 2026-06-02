extends GutTest

const RegisterTransactionViewModelScript: GDScript = preload(
	"res://game/scripts/store_session/register_transaction_view_model.gd"
)


func test_fallback_display_fills_empty_lines_and_safe_customer() -> void:
	var model: Dictionary = RegisterTransactionViewModelScript.make_snapshot(
		RegisterTransactionViewModelScript.STATE_FALLBACK_DISPLAY,
		RegisterTransactionViewModelScript.SOURCE_FALLBACK,
		RegisterTransactionViewModelScript.KIND_FALLBACK_DISPLAY,
		{
			"customer_name": "",
			"item_lines": [],
			"metadata": {"source": "test"},
		}
	)

	assert_eq(model.get("customer_name"), "Customer")
	assert_eq(model.get("state"), RegisterTransactionViewModelScript.STATE_FALLBACK_DISPLAY)
	assert_eq((model.get("item_lines") as Array).size(), 1)
	assert_true(bool((model.get("metadata") as Dictionary).get("empty_lines_fallback", false)))
	var line: Dictionary = (model.get("item_lines") as Array)[0] as Dictionary
	assert_eq(line.get("role"), RegisterTransactionViewModelScript.ROLE_DISPLAY_ONLY)


func test_store_choice_zero_cash_trade_in_is_receipt_not_refusal() -> void:
	var model: Dictionary = RegisterTransactionViewModelScript.from_store_session_choice(
		_event(),
		_trade_in_choice("offer_partial", 0),
		_trade_in_effects(0),
	)

	assert_eq(model.get("state"), RegisterTransactionViewModelScript.STATE_RECEIPT)
	assert_eq(model.get("kind"), RegisterTransactionViewModelScript.KIND_TRADE_IN)
	assert_eq(float(model.get("cash_delta")), 0.0)
	assert_eq(float(model.get("payout")), 0.0)
	assert_eq(model.get("refusal_reason"), "")


func test_store_choice_negative_cash_preserves_payout() -> void:
	var model: Dictionary = RegisterTransactionViewModelScript.from_store_session_choice(
		_event(),
		_trade_in_choice("accept_full_value", -8),
		_trade_in_effects(-8),
	)

	assert_eq(model.get("state"), RegisterTransactionViewModelScript.STATE_RECEIPT)
	assert_eq(model.get("kind"), RegisterTransactionViewModelScript.KIND_PAYOUT)
	assert_eq(float(model.get("cash_delta")), -8.0)
	assert_eq(float(model.get("payout")), 8.0)
	assert_true(_has_role(model, RegisterTransactionViewModelScript.ROLE_DAMAGED_TRADE_IN))


func test_store_choice_refusal_is_explicit_not_cash_inferred() -> void:
	var choice: Dictionary = {
		"id": "refuse_return",
		"label": "Decline the exchange.",
		"result": {
			"headline": "Exchange Refused",
			"acknowledgement": "No sale logged.",
			"tone": "negative",
		},
	}
	var effects: Dictionary = {
		"cash": 0,
		"flags": {"parent_refused_return": true},
		"inventory": [{"op": "no_inventory_change", "reason": "return_refused"}],
	}
	var model: Dictionary = RegisterTransactionViewModelScript.from_store_session_choice(
		_event(),
		choice,
		effects,
	)

	assert_eq(model.get("state"), RegisterTransactionViewModelScript.STATE_REFUSED)
	assert_eq(model.get("kind"), RegisterTransactionViewModelScript.KIND_REFUSED)
	assert_eq(model.get("refusal_reason"), "No sale logged.")
	assert_true(_has_role(model, RegisterTransactionViewModelScript.ROLE_REFUSED_ITEM))


func _event() -> Dictionary:
	return {
		"id": "day02_trade_in_dispute",
		"customer_name": "Collector Guy",
		"customer_archetype": "regular_collector",
		"title": "The Scratched Disc",
	}


func _trade_in_choice(choice_id: String, cash: int) -> Dictionary:
	return {
		"id": choice_id,
		"label": "Process the trade-in.",
		"result": {
			"headline": "Trade-In Logged",
			"acknowledgement": "Trade-in logged.",
			"tone": "positive",
			"consequences": [{"label": "Money", "text": "%d cash delta." % cash}],
		},
	}


func _trade_in_effects(cash: int) -> Dictionary:
	return {
		"cash": cash,
		"inventory": [
			{
				"op": "create_item",
				"definition_id": "neo_ignite_shadow_mandate_loose",
				"condition": "good",
				"quantity": 2,
				"reason": "trade_in_full_value",
			},
			{
				"op": "create_item",
				"definition_id": "neo_ignite_biomaze_descent_loose",
				"condition": "poor",
				"location": "back_room_damaged_bin",
				"quantity": 1,
				"reason": "trade_in_damaged_disc",
			},
		],
	}


func _has_role(model: Dictionary, role: StringName) -> bool:
	for line_variant: Variant in model.get("item_lines", []) as Array:
		var line: Dictionary = line_variant as Dictionary
		if line != null and line.get("role") == role:
			return true
	return false
