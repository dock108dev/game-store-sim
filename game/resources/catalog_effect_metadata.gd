## Validates catalog-facing effect claims against owned gameplay read paths.
class_name CatalogEffectMetadata
extends RefCounted

const TYPE_CAPACITY: String = "capacity"
const TYPE_QUEUE_CAPACITY: String = "queue_capacity"
const TYPE_BROWSE_DEMAND: String = "browse_demand"
const TYPE_TRUST: String = "trust"
const TYPE_EFFICIENCY: String = "efficiency"
const TYPE_VISIBILITY_RISK: String = "visibility_risk"
const TYPE_COSMETIC: String = "cosmetic"
const TYPE_SERVICE: String = "service"

const COSMETIC_LABEL: String = "Cosmetic only"

const _ALLOWED_SOURCES_BY_TYPE: Dictionary = {
	TYPE_CAPACITY: ["slot_count", "FixtureDefinition.slot_count"],
	TYPE_QUEUE_CAPACITY: [
		"RegisterQueue.MAX_QUEUE_SIZE",
		"QueueSystem.bind_queue_markers",
		"authored_queue_markers",
	],
	TYPE_BROWSE_DEMAND: [
		"StoreCustomizationSystem.get_spawn_weight_bonus",
		"StoreCustomizationSystem.get_demand_multiplier",
		"CustomerSpawnEligibility.get_profile_spawn_weight",
		"PlatformSystem.get_hype",
		"PlatformSystem.is_shortage",
	],
	TYPE_TRUST: [
		"StoreCustomizationSystem.get_morning_note_hint",
		"ManagerRelationshipManager.apply_trust_delta",
	],
	TYPE_EFFICIENCY: [
		"StaffDefinition.effect_type",
		"StaffSystem",
		"PlayerCheckout._get_checkout_duration",
	],
	TYPE_VISIBILITY_RISK: [
		"EventBus.display_exposes_weird_inventory",
		"StoreCustomizationSystem.featured_category_changed",
		"RandomEventEffects.apply_shoplifting",
	],
	TYPE_COSMETIC: [
		"visual_only",
		"StoreCustomizationSystem.design_selection",
	],
	TYPE_SERVICE: [
		"register_required",
		"BuildModeSystem.validate_register_exists",
		"PlayerCheckout",
	],
}

const _OWNER_BY_SOURCE: Dictionary = {
	"slot_count": "FixtureDefinition",
	"FixtureDefinition.slot_count": "FixtureDefinition",
	"RegisterQueue.MAX_QUEUE_SIZE": "RegisterQueue",
	"QueueSystem.bind_queue_markers": "QueueSystem",
	"authored_queue_markers": "QueueSystem",
	"StoreCustomizationSystem.get_spawn_weight_bonus": "StoreCustomizationSystem",
	"StoreCustomizationSystem.get_demand_multiplier": "StoreCustomizationSystem",
	"CustomerSpawnEligibility.get_profile_spawn_weight": "CustomerSystem",
	"PlatformSystem.get_hype": "PlatformSystem",
	"PlatformSystem.is_shortage": "PlatformSystem",
	"StoreCustomizationSystem.get_morning_note_hint": "StoreCustomizationSystem",
	"ManagerRelationshipManager.apply_trust_delta": "ManagerRelationshipManager",
	"StaffDefinition.effect_type": "StaffSystem",
	"StaffSystem": "StaffSystem",
	"PlayerCheckout._get_checkout_duration": "PlayerCheckout",
	"EventBus.display_exposes_weird_inventory": "HiddenThreadSystem",
	"StoreCustomizationSystem.featured_category_changed": "StoreCustomizationSystem",
	"RandomEventEffects.apply_shoplifting": "RandomEventEffects",
	"visual_only": "Visual layer",
	"StoreCustomizationSystem.design_selection": "StoreCustomizationSystem",
	"register_required": "BuildModeSystem",
	"BuildModeSystem.validate_register_exists": "BuildModeSystem",
	"PlayerCheckout": "PlayerCheckout",
}

const _CLAIM_KEYWORDS_BY_TYPE: Dictionary = {
	TYPE_CAPACITY: ["capacity", "slot", "slots"],
	TYPE_QUEUE_CAPACITY: ["queue"],
	TYPE_BROWSE_DEMAND: ["browse", "demand", "spawn", "hype", "shortage"],
	TYPE_TRUST: ["trust"],
	TYPE_EFFICIENCY: ["efficiency", "efficient", "faster", "speed"],
	TYPE_VISIBILITY_RISK: ["risk", "theft", "visibility", "visible"],
}

const _UNSUPPORTED_KEYWORDS: Array[String] = ["discount", "discounts"]


## Returns catalog effects as dictionaries with type, source, owner, and label.
static func normalize_effects(
	raw_effects: Array, fallback_cosmetic: bool = false
) -> Array[Dictionary]:
	var normalized: Array[Dictionary] = []
	for raw: Variant in raw_effects:
		if raw is not Dictionary:
			continue
		var effect: Dictionary = (raw as Dictionary).duplicate(true)
		var type_name: String = str(effect.get("type", ""))
		var source: String = str(effect.get("source", ""))
		if not effect.has("owner") and _OWNER_BY_SOURCE.has(source):
			effect["owner"] = _OWNER_BY_SOURCE[source]
		if not effect.has("label") or str(effect.get("label", "")).is_empty():
			effect["label"] = _default_label(type_name)
		normalized.append(effect)
	if normalized.is_empty() and fallback_cosmetic:
		normalized.append(cosmetic_effect())
	return normalized


## Returns a visual-only effect entry for decorative design options.
static func cosmetic_effect() -> Dictionary:
	return {
		"type": TYPE_COSMETIC,
		"source": "StoreCustomizationSystem.design_selection",
		"owner": "StoreCustomizationSystem",
		"label": COSMETIC_LABEL,
	}


## Returns display labels without deriving any gameplay values.
static func labels_for_effects(effects: Array[Dictionary]) -> PackedStringArray:
	var labels: PackedStringArray = []
	for effect: Dictionary in effects:
		var label: String = str(effect.get("label", "")).strip_edges()
		if not label.is_empty():
			labels.append(label)
	if labels.is_empty():
		labels.append(COSMETIC_LABEL)
	return labels


## Validates that advertised metadata points at known gameplay owners.
static func validate_effects(
	effects: Array[Dictionary], context_id: String = ""
) -> Array[String]:
	var errors: Array[String] = []
	if effects.is_empty():
		errors.append(_prefix(context_id, "missing effect metadata"))
		return errors
	for effect: Dictionary in effects:
		var type_name: String = str(effect.get("type", ""))
		var source: String = str(effect.get("source", ""))
		if not _ALLOWED_SOURCES_BY_TYPE.has(type_name):
			errors.append(_prefix(context_id, "unsupported effect type '%s'" % type_name))
			continue
		if source.is_empty():
			errors.append(_prefix(context_id, "effect '%s' missing source" % type_name))
			continue
		var allowed: Array = _ALLOWED_SOURCES_BY_TYPE[type_name] as Array
		if not allowed.has(source):
			errors.append(
				_prefix(
					context_id,
					"effect '%s' uses unowned source '%s'" % [type_name, source]
				)
			)
	return errors


## Validates effect rows and rejects unsupported claims in summary text.
static func validate_advertised_effects(
	summary: String, effects: Array[Dictionary], context_id: String = ""
) -> Array[String]:
	var errors: Array[String] = validate_effects(effects, context_id)
	var text: String = summary.to_lower()
	for effect: Dictionary in effects:
		text += " " + str(effect.get("label", "")).to_lower()
	for keyword: String in _UNSUPPORTED_KEYWORDS:
		if text.contains(keyword):
			errors.append(_prefix(context_id, "unsupported advertised '%s' effect" % keyword))
	for type_name: String in _CLAIM_KEYWORDS_BY_TYPE:
		var claims_type: bool = false
		for keyword: String in _CLAIM_KEYWORDS_BY_TYPE[type_name]:
			if text.contains(keyword):
				claims_type = true
				break
		if claims_type and not _has_effect_type(effects, type_name):
			errors.append(
				_prefix(context_id, "advertises '%s' without a mapped effect" % type_name)
			)
	return errors


static func _has_effect_type(effects: Array[Dictionary], type_name: String) -> bool:
	for effect: Dictionary in effects:
		if str(effect.get("type", "")) == type_name:
			return true
	return false


static func _default_label(type_name: String) -> String:
	if type_name == TYPE_COSMETIC:
		return COSMETIC_LABEL
	return type_name.capitalize()


static func _prefix(context_id: String, message: String) -> String:
	if context_id.is_empty():
		return message
	return "%s: %s" % [context_id, message]
