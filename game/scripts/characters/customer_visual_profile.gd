class_name CustomerVisualProfile
extends RefCounted

## Read-only customer visual mapping for production cues.

const INTENT_BROWSE_SCAN: StringName = &"browse_scan"
const INTENT_COMPARE_THINK: StringName = &"compare_think"
const INTENT_QUEUE_WAIT: StringName = &"queue_wait"
const INTENT_COUNTER_READY: StringName = &"counter_ready"
const INTENT_LEAVE_SATISFIED: StringName = &"leave_satisfied"
const INTENT_LEAVE_FRUSTRATED: StringName = &"leave_frustrated"
const INTENT_PRICE_SHOCK: StringName = &"react_price_shock"
const INTENT_TRADE_IN: StringName = &"react_trade_in"
const INTENT_SALE: StringName = &"react_sale"
const INTENT_NO_SALE: StringName = &"react_no_sale"
const INTENT_BUNDLE_ACCEPTED: StringName = &"react_bundle_accepted"
const INTENT_BUNDLE_REJECTED: StringName = &"react_bundle_rejected"
const INTENT_CLEAN_EXCHANGE: StringName = &"react_clean_exchange"
const INTENT_REFUSED_RETURN: StringName = &"react_refused_return"
const INTENT_ACCEPTED_TRADE_IN: StringName = &"react_accepted_trade_in"
const INTENT_PAYOUT_TRADE_IN: StringName = &"react_payout_trade_in"

const VISUAL_STATE_BROWSING: StringName = &"browsing"
const VISUAL_STATE_NEEDS_HELP: StringName = &"needs_help"
const VISUAL_STATE_QUEUED: StringName = &"queued"
const VISUAL_STATE_CONSIDERING: StringName = &"considering"
const VISUAL_STATE_ANNOYED: StringName = &"annoyed"
const VISUAL_STATE_READY_TO_BUY: StringName = &"ready_to_buy"
const VISUAL_STATE_COUNTER: StringName = &"counter"
const VISUAL_STATE_LEAVING_HAPPY: StringName = &"leaving_happy"
const VISUAL_STATE_LEAVING_UPSET: StringName = &"leaving_upset"

const ACCENT_DEFAULT: Dictionary = {
	"key": &"casual_shopper",
	"label": "Casual Shopper",
	"primary_color": Color(0.357, 0.722, 0.910, 1.0),
	"secondary_color": Color(0.78, 0.90, 0.96, 1.0),
	"shape": &"soft_pin",
}

const ACCENTS: Dictionary = {
	&"collector": {
		"key": &"collector",
		"label": "Collector",
		"primary_color": Color(0.95, 0.72, 0.24, 1.0),
		"secondary_color": Color(0.50, 0.32, 0.10, 1.0),
		"shape": &"catalog_card",
	},
	&"confused_parent": {
		"key": &"confused_parent",
		"label": "Parent",
		"primary_color": Color(0.44, 0.82, 0.82, 1.0),
		"secondary_color": Color(0.92, 0.82, 0.52, 1.0),
		"shape": &"question_tab",
	},
	&"bargain_hunter": {
		"key": &"bargain_hunter",
		"label": "Bargain Hunter",
		"primary_color": Color(0.42, 0.78, 0.34, 1.0),
		"secondary_color": Color(0.94, 0.82, 0.28, 1.0),
		"shape": &"coupon_strip",
	},
	&"hype_teen": {
		"key": &"hype_teen",
		"label": "Hype Teen",
		"primary_color": Color(0.98, 0.34, 0.72, 1.0),
		"secondary_color": Color(0.32, 0.82, 1.0, 1.0),
		"shape": &"neon_cap",
	},
	&"sports_regular": {
		"key": &"sports_regular",
		"label": "Sports Regular",
		"primary_color": Color(0.22, 0.46, 0.88, 1.0),
		"secondary_color": Color(0.94, 0.94, 0.94, 1.0),
		"shape": &"pennant",
	},
	&"reseller": {
		"key": &"reseller",
		"label": "Reseller",
		"primary_color": Color(0.12, 0.12, 0.13, 1.0),
		"secondary_color": Color(0.86, 0.78, 0.42, 1.0),
		"shape": &"price_tag",
	},
	&"casual_shopper": ACCENT_DEFAULT,
	&"angry_return_customer": {
		"key": &"angry_return_customer",
		"label": "Angry Return",
		"primary_color": Color(0.90, 0.24, 0.17, 1.0),
		"secondary_color": Color(0.16, 0.10, 0.08, 1.0),
		"shape": &"return_slash",
	},
	&"shady_regular": {
		"key": &"shady_regular",
		"label": "Shady Regular",
		"primary_color": Color(0.38, 0.28, 0.50, 1.0),
		"secondary_color": Color(0.10, 0.12, 0.10, 1.0),
		"shape": &"low_badge",
	},
	&"vip_customer": {
		"key": &"vip_customer",
		"label": "VIP",
		"primary_color": Color(1.0, 0.84, 0.36, 1.0),
		"secondary_color": Color(0.25, 0.16, 0.06, 1.0),
		"shape": &"gold_lapel",
	},
}


static func profile_id(profile: CustomerTypeDefinition) -> String:
	if profile == null:
		return ""
	return profile.id


static func archetype_id(profile: CustomerTypeDefinition) -> StringName:
	if profile == null:
		return &""
	if profile.archetype_id != &"":
		return profile.archetype_id
	return inferred_archetype_from_profile_id(profile.id)


static func inferred_archetype_from_profile_id(profile_id_value: String) -> StringName:
	var key: String = profile_id_value.to_lower()
	if key == "vip_customer" or key.contains("vip"):
		return &"vip_customer"
	if key.contains("collector"):
		return &"collector"
	if key.contains("parent"):
		return &"confused_parent"
	if key.contains("bargain"):
		return &"bargain_hunter"
	if key.contains("hype") or key.contains("teen"):
		return &"hype_teen"
	if key.contains("sports"):
		return &"sports_regular"
	if key.contains("reseller") or key.contains("dealer"):
		return &"reseller"
	if key.contains("angry") or key.contains("return"):
		return &"angry_return_customer"
	if key.contains("shady"):
		return &"shady_regular"
	if key.contains("casual") or key.contains("browser") or key.contains("window"):
		return &"casual_shopper"
	return &"casual_shopper"


static func accent_for(
	profile_id_value: String, archetype_id_value: StringName
) -> Dictionary:
	var key: StringName = archetype_id_value
	if key == &"":
		key = inferred_archetype_from_profile_id(profile_id_value)
	var accent: Dictionary = ACCENTS.get(key, ACCENT_DEFAULT) as Dictionary
	return accent.duplicate(true)


static func reaction_intent_for(
	leave_reason: StringName, held_state: StringName, terminal_state: StringName
) -> StringName:
	if held_state == &"trade_in_presented":
		return INTENT_TRADE_IN
	match terminal_state:
		&"selected_sold":
			return INTENT_SALE
		&"selected_abandoned":
			return INTENT_NO_SALE
		&"returned_accepted":
			return INTENT_CLEAN_EXCHANGE
		&"returned_refused":
			return INTENT_REFUSED_RETURN
		&"payout_returned":
			return INTENT_PAYOUT_TRADE_IN
	match leave_reason:
		&"purchase_complete":
			return INTENT_SALE
		&"sale_declined", &"no_matching_item":
			return INTENT_NO_SALE
		&"price_too_high":
			return INTENT_PRICE_SHOCK
		&"queue_abandoned", &"patience_expired":
			return INTENT_LEAVE_FRUSTRATED
	return &""


static func intent_for_visual_state(
	visual_state: StringName, reaction_intent: StringName
) -> StringName:
	if reaction_intent != &"":
		return reaction_intent
	match visual_state:
		VISUAL_STATE_BROWSING, VISUAL_STATE_NEEDS_HELP:
			return INTENT_BROWSE_SCAN
		VISUAL_STATE_CONSIDERING:
			return INTENT_COMPARE_THINK
		VISUAL_STATE_QUEUED, VISUAL_STATE_ANNOYED:
			return INTENT_QUEUE_WAIT
		VISUAL_STATE_COUNTER:
			return INTENT_COUNTER_READY
		VISUAL_STATE_READY_TO_BUY:
			return INTENT_COUNTER_READY
		VISUAL_STATE_LEAVING_HAPPY:
			return INTENT_LEAVE_SATISFIED
		VISUAL_STATE_LEAVING_UPSET:
			return INTENT_LEAVE_FRUSTRATED
	return &"idle"
