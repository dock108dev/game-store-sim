class_name RegisterTransactionViewModel
extends RefCounted

const STATE_PENDING: StringName = &"pending"
const STATE_DECISION: StringName = &"decision"
const STATE_PROCESSING: StringName = &"processing"
const STATE_RECEIPT: StringName = &"receipt"
const STATE_NO_SALE: StringName = &"no_sale"
const STATE_REFUSED: StringName = &"refused"
const STATE_FALLBACK_DISPLAY: StringName = &"fallback_display"

const SOURCE_CHECKOUT: StringName = &"checkout_system"
const SOURCE_STORE_SESSION: StringName = &"store_session_event"
const SOURCE_FALLBACK: StringName = &"fallback_display"

const KIND_SALE: StringName = &"sale"
const KIND_CLEAN_EXCHANGE: StringName = &"clean_exchange"
const KIND_BUNDLE: StringName = &"bundle"
const KIND_TRADE_IN: StringName = &"trade_in"
const KIND_PAYOUT: StringName = &"payout"
const KIND_NO_SALE: StringName = &"no_sale"
const KIND_REFUSED: StringName = &"refused"
const KIND_FALLBACK_DISPLAY: StringName = &"fallback_display"

const ROLE_SOLD_ITEM: StringName = &"sold_item"
const ROLE_BUNDLE_ITEM: StringName = &"bundle_item"
const ROLE_RETURNED_ITEM: StringName = &"returned_item"
const ROLE_TRADE_IN: StringName = &"trade_in"
const ROLE_DAMAGED_TRADE_IN: StringName = &"damaged_trade_in"
const ROLE_REFUSED_ITEM: StringName = &"refused_item"
const ROLE_DISPLAY_ONLY: StringName = &"display_only"


## Returns a complete transaction snapshot with all display-facing keys present.
static func make_snapshot(
	state: StringName,
	source: StringName,
	kind: StringName,
	fields: Dictionary = {}
) -> Dictionary:
	var model: Dictionary = {
		"state": state,
		"source": source,
		"kind": kind,
		"transaction_id": str(fields.get("transaction_id", "")),
		"customer_id": int(fields.get("customer_id", 0)),
		"customer_name": _safe_text(fields.get("customer_name", ""), "Customer"),
		"customer_archetype": str(fields.get("customer_archetype", "")),
		"item_lines": _line_array(fields.get("item_lines", [])),
		"subtotal": float(fields.get("subtotal", 0.0)),
		"discount": maxf(float(fields.get("discount", 0.0)), 0.0),
		"total": maxf(float(fields.get("total", 0.0)), 0.0),
		"payout": maxf(float(fields.get("payout", 0.0)), 0.0),
		"cash_delta": float(fields.get("cash_delta", 0.0)),
		"receipt_title": str(fields.get("receipt_title", "")),
		"receipt_body": str(fields.get("receipt_body", "")),
		"receipt_lines": _receipt_lines(fields.get("receipt_lines", [])),
		"refusal_reason": str(fields.get("refusal_reason", "")),
		"tone": StringName(str(fields.get("tone", "neutral"))),
		"metadata": (fields.get("metadata", {}) as Dictionary).duplicate(true),
	}
	if (model["item_lines"] as Array).is_empty():
		model["item_lines"] = [
			make_item_line({
				"display_name": "Register display only",
				"role": ROLE_DISPLAY_ONLY,
			})
		]
		model["metadata"]["empty_lines_fallback"] = true
	return model


## Builds an item-line dictionary from loose source data while preserving safe fallback copy.
static func make_item_line(fields: Dictionary = {}) -> Dictionary:
	var quantity: int = maxi(1, int(fields.get("quantity", 1)))
	var unit_price: float = float(fields.get("unit_price", fields.get("price", 0.0)))
	var line_total: float = float(fields.get("line_total", unit_price * quantity))
	var item_id: String = str(fields.get("item_id", fields.get("definition_id", "")))
	var display_name: String = str(fields.get("display_name", fields.get("item_name", "")))
	if display_name.strip_edges().is_empty():
		display_name = _display_name_for_item_id(item_id)
	return {
		"item_id": item_id,
		"instance_id": str(fields.get("instance_id", "")),
		"display_name": _safe_text(display_name, "Unknown item"),
		"condition": str(fields.get("condition", "")),
		"quantity": quantity,
		"unit_price": unit_price,
		"line_total": line_total,
		"role": StringName(str(fields.get("role", ROLE_DISPLAY_ONLY))),
	}


## Converts a live inventory item into a normalized display line.
static func line_from_item_instance(
	item: ItemInstance,
	role: StringName,
	unit_price: float,
	line_total: float = NAN
) -> Dictionary:
	if item == null:
		return make_item_line({"role": ROLE_DISPLAY_ONLY})
	var definition: ItemDefinition = item.definition
	return make_item_line({
		"item_id": String(item.definition_id),
		"instance_id": String(item.instance_id),
		"display_name": definition.item_name if definition != null else "",
		"condition": item.condition,
		"unit_price": unit_price,
		"line_total": unit_price if is_nan(line_total) else line_total,
		"role": role,
	})


## Builds the normal checkout snapshot from the checkout owner state.
static func from_checkout(
	state: StringName,
	customer: Customer,
	item_lines: Array[Dictionary],
	cash_delta: float,
	kind: StringName = KIND_SALE,
	fields: Dictionary = {}
) -> Dictionary:
	var total: float = maxf(cash_delta, 0.0)
	if fields.has("total"):
		total = maxf(float(fields.get("total", 0.0)), 0.0)
	var customer_fields: Dictionary = _customer_fields(customer)
	return make_snapshot(state, SOURCE_CHECKOUT, kind, {
		"transaction_id": str(fields.get("transaction_id", "")),
		"customer_id": customer_fields.get("customer_id", 0),
		"customer_name": customer_fields.get("customer_name", "Customer"),
		"customer_archetype": customer_fields.get("customer_archetype", ""),
		"item_lines": item_lines,
		"subtotal": float(fields.get("subtotal", _sum_line_totals(item_lines))),
		"discount": float(fields.get("discount", 0.0)),
		"total": total,
		"payout": maxf(-cash_delta, 0.0),
		"cash_delta": cash_delta,
		"receipt_title": str(fields.get("receipt_title", "")),
		"receipt_body": str(fields.get("receipt_body", "")),
		"receipt_lines": fields.get("receipt_lines", []),
		"refusal_reason": str(fields.get("refusal_reason", "")),
		"tone": StringName(str(fields.get("tone", "neutral"))),
		"metadata": fields.get("metadata", {}),
	})


## Builds a store-session snapshot from the active event, selected choice, and effects.
static func from_store_session_choice(
	event_data: Dictionary,
	choice: Dictionary,
	effects: Dictionary,
	state_override: StringName = &""
) -> Dictionary:
	var result: Dictionary = choice.get("result", {}) as Dictionary
	var kind: StringName = _store_choice_kind(choice, effects)
	var cash_delta: float = float(effects.get("cash", 0.0))
	var state: StringName = state_override
	if state.is_empty():
		state = _state_for_kind(kind, cash_delta)
	var lines: Array[Dictionary] = _store_choice_lines(choice, effects, kind)
	var receipt_lines: PackedStringArray = _consequence_lines(result)
	var transaction_id: String = "%s:%s" % [
		str(event_data.get("id", "")),
		str(choice.get("id", "")),
	]
	return make_snapshot(state, SOURCE_STORE_SESSION, kind, {
		"transaction_id": transaction_id,
		"customer_name": str(event_data.get("customer_name", "Customer")),
		"customer_archetype": str(event_data.get("customer_archetype", "")),
		"item_lines": lines,
		"subtotal": maxf(cash_delta, 0.0),
		"discount": 0.0,
		"total": maxf(cash_delta, 0.0),
		"payout": maxf(-cash_delta, 0.0),
		"cash_delta": cash_delta,
		"receipt_title": str(result.get("headline", "")),
		"receipt_body": str(result.get("acknowledgement", result.get("store_outcome", ""))),
		"receipt_lines": receipt_lines,
		"refusal_reason": _refusal_reason(choice, result, kind),
		"tone": StringName(str(result.get("tone", "neutral"))),
		"metadata": {
			"event_title": str(event_data.get("title", "")),
			"choice_id": str(choice.get("id", "")),
			"choice_label": str(choice.get("label", "")),
			"inventory_blocked": bool(effects.get("inventory_blocked", false)),
		},
	})


## Builds a stable fallback snapshot for missing or currently unavailable source data.
static func fallback_display(reason: String, metadata: Dictionary = {}) -> Dictionary:
	var merged_metadata: Dictionary = metadata.duplicate(true)
	merged_metadata["reason"] = reason
	return make_snapshot(STATE_FALLBACK_DISPLAY, SOURCE_FALLBACK, KIND_FALLBACK_DISPLAY, {
		"customer_name": "Customer",
		"item_lines": [make_item_line({"display_name": reason, "role": ROLE_DISPLAY_ONLY})],
		"receipt_title": "Register",
		"receipt_body": reason,
		"tone": &"neutral",
		"metadata": merged_metadata,
	})


static func _customer_fields(customer: Customer) -> Dictionary:
	if customer == null:
		return {}
	var profile: CustomerTypeDefinition = customer.profile
	if profile == null:
		return {"customer_id": customer.get_instance_id(), "customer_name": "Customer"}
	return {
		"customer_id": customer.get_instance_id(),
		"customer_name": _safe_text(profile.customer_name, "Customer"),
		"customer_archetype": String(profile.archetype_id),
	}


static func _line_array(raw_lines: Variant) -> Array[Dictionary]:
	var lines: Array[Dictionary] = []
	if raw_lines is Array:
		for line_variant: Variant in raw_lines as Array:
			if line_variant is Dictionary:
				lines.append(make_item_line(line_variant as Dictionary))
	return lines


static func _receipt_lines(raw_lines: Variant) -> PackedStringArray:
	var lines := PackedStringArray()
	if raw_lines is PackedStringArray:
		return raw_lines
	if raw_lines is Array:
		for line: Variant in raw_lines as Array:
			lines.append(str(line))
	return lines


static func _store_choice_kind(choice: Dictionary, effects: Dictionary) -> StringName:
	var choice_id: StringName = StringName(str(choice.get("id", "")))
	if choice_id == &"clean_exchange":
		return KIND_CLEAN_EXCHANGE
	if choice_id == &"upsell_bundle":
		return KIND_BUNDLE
	if choice_id == &"refuse_return":
		return KIND_REFUSED
	if float(effects.get("cash", 0.0)) < 0.0:
		return KIND_PAYOUT
	if _has_trade_in_inventory(effects):
		return KIND_TRADE_IN
	if float(effects.get("cash", 0.0)) == 0.0:
		return KIND_NO_SALE
	return KIND_SALE


static func _state_for_kind(kind: StringName, cash_delta: float) -> StringName:
	if kind == KIND_REFUSED:
		return STATE_REFUSED
	if kind == KIND_NO_SALE and is_zero_approx(cash_delta):
		return STATE_NO_SALE
	return STATE_RECEIPT


static func _store_choice_lines(
	choice: Dictionary, effects: Dictionary, kind: StringName
) -> Array[Dictionary]:
	var lines: Array[Dictionary] = []
	var operations: Array = effects.get("inventory", []) as Array
	for operation_variant: Variant in operations:
		if operation_variant is not Dictionary:
			continue
		var operation: Dictionary = operation_variant as Dictionary
		lines.append_array(_lines_for_operation(operation, kind))
	if lines.is_empty():
		lines.append(make_item_line({
			"display_name": str(choice.get("label", "Register outcome")),
			"role": ROLE_REFUSED_ITEM if kind == KIND_REFUSED else ROLE_DISPLAY_ONLY,
		}))
	return lines


static func _lines_for_operation(operation: Dictionary, kind: StringName) -> Array[Dictionary]:
	var op: String = str(operation.get("op", ""))
	var quantity: int = maxi(1, int(operation.get("quantity", 1)))
	var lines: Array[Dictionary] = []
	match op:
		"remove_stock":
			lines.append(_line_for_definition(
				_selector_definition_id(operation),
				quantity,
				ROLE_BUNDLE_ITEM if str(operation.get("reason", "")).contains("controller") else ROLE_SOLD_ITEM
			))
		"create_item":
			lines.append(_line_for_definition(
				str(operation.get("definition_id", "")),
				quantity,
				_role_for_created_item(operation, kind),
				str(operation.get("condition", ""))
			))
		"no_inventory_change":
			lines.append(make_item_line({
				"display_name": _humanized_reason(str(operation.get("reason", "No inventory change"))),
				"quantity": quantity,
				"role": ROLE_REFUSED_ITEM if kind == KIND_REFUSED else ROLE_DISPLAY_ONLY,
			}))
	return lines


static func _line_for_definition(
	definition_id: String,
	quantity: int,
	role: StringName,
	condition: String = ""
) -> Dictionary:
	return make_item_line({
		"item_id": definition_id,
		"display_name": _display_name_for_item_id(definition_id),
		"condition": condition,
		"quantity": quantity,
		"role": role,
	})


static func _role_for_created_item(operation: Dictionary, kind: StringName) -> StringName:
	var reason: String = str(operation.get("reason", ""))
	var location: String = str(operation.get("location", ""))
	var condition: String = str(operation.get("condition", ""))
	if reason.contains("exchange_in"):
		return ROLE_RETURNED_ITEM
	if (
		reason.contains("damaged")
		or location == "back_room_damaged_bin"
		or condition == "poor"
	):
		return ROLE_DAMAGED_TRADE_IN
	if kind == KIND_PAYOUT or kind == KIND_TRADE_IN:
		return ROLE_TRADE_IN
	return ROLE_DISPLAY_ONLY


static func _selector_definition_id(operation: Dictionary) -> String:
	var selector: Dictionary = operation.get("selector", {}) as Dictionary
	return str(selector.get("definition_id", ""))


static func _has_trade_in_inventory(effects: Dictionary) -> bool:
	for operation_variant: Variant in effects.get("inventory", []) as Array:
		if operation_variant is not Dictionary:
			continue
		var reason: String = str((operation_variant as Dictionary).get("reason", ""))
		if reason.contains("trade_in"):
			return true
	return false


static func _consequence_lines(result: Dictionary) -> PackedStringArray:
	var lines := PackedStringArray()
	for consequence_variant: Variant in result.get("consequences", []) as Array:
		if consequence_variant is not Dictionary:
			continue
		var consequence: Dictionary = consequence_variant as Dictionary
		var text: String = str(consequence.get("text", ""))
		if not text.is_empty():
			lines.append(text)
	return lines


static func _refusal_reason(
	choice: Dictionary, result: Dictionary, kind: StringName
) -> String:
	if kind != KIND_REFUSED:
		return ""
	var body: String = str(result.get("acknowledgement", ""))
	if not body.is_empty():
		return body
	return str(choice.get("label", "Transaction refused"))


static func _display_name_for_item_id(item_id: String) -> String:
	if item_id.strip_edges().is_empty():
		return ""
	if ContentRegistry.exists(item_id):
		var definition: ItemDefinition = ContentRegistry.get_item_definition(StringName(item_id))
		if definition != null and not definition.item_name.strip_edges().is_empty():
			return definition.item_name
		return ContentRegistry.get_display_name_or(StringName(item_id), _humanized_reason(item_id))
	return _humanized_reason(item_id)


static func _sum_line_totals(lines: Array[Dictionary]) -> float:
	var total: float = 0.0
	for line: Dictionary in lines:
		total += float(line.get("line_total", 0.0))
	return total


static func _safe_text(value: Variant, fallback: String) -> String:
	var text: String = str(value).strip_edges()
	return fallback if text.is_empty() else text


static func _humanized_reason(value: String) -> String:
	var text: String = value.replace("_", " ").strip_edges()
	if text.is_empty():
		return "Register item"
	return text.capitalize()
