## Pure helpers for serializing store-design selections into save payloads.
class_name StoreDesignPayload
extends RefCounted

const StoreDesignCatalogScript: GDScript = preload(
	"res://game/scripts/systems/store_design_catalog.gd"
)


## Returns a blank store-design payload for the active save schema.
static func empty_payload(schema_version: int) -> Dictionary:
	return {
		"schema": schema_version,
		"surfaces": {},
		"lighting": {},
		"signage": {},
		"decor": {},
		"stockroom": {},
		"counter": {},
		"shelf": {},
		"register": {},
		"selections": {},
	}


## Returns a payload containing catalog defaults.
static func payload_with_defaults(schema_version: int) -> Dictionary:
	var payload: Dictionary = empty_payload(schema_version)
	for option: Dictionary in StoreDesignCatalogScript.all_options():
		if bool(option.get("default_selected", false)):
			apply_option_to_payload(payload, option)
	return payload


## Converts either current or old selection-only data to the current payload.
static func normalize_store_payload(
	raw_payload: Dictionary, schema_version: int
) -> Dictionary:
	var selections: Variant = raw_payload.get("selections", {})
	if selections is Dictionary:
		return payload_from_selections(selections as Dictionary, schema_version)
	var payload: Dictionary = empty_payload(schema_version)
	for group: String in [
		"surfaces", "lighting", "signage", "decor", "stockroom",
		"counter", "shelf", "register",
	]:
		var raw_group: Variant = raw_payload.get(group, {})
		if raw_group is Dictionary:
			payload[group] = (raw_group as Dictionary).duplicate(true)
	payload["selections"] = _recover_selections(payload)
	return payload


## Builds a current payload from a flat selection-key to option-id map.
static func payload_from_selections(
	raw_selections: Dictionary, schema_version: int
) -> Dictionary:
	var payload: Dictionary = empty_payload(schema_version)
	for key: Variant in raw_selections:
		var option: Dictionary = StoreDesignCatalogScript.get_option(
			str(raw_selections[key])
		)
		if option.is_empty():
			continue
		apply_option_to_payload(payload, option)
	return payload


## Applies one catalog option to an existing payload in place.
static func apply_option_to_payload(payload: Dictionary, option: Dictionary) -> void:
	var selection_key: StringName = StringName(str(option.get("selection_key", "")))
	var option_id: StringName = StringName(str(option.get("id", "")))
	var group_name: String = str(option.get("payload_group", ""))
	var field_name: String = str(option.get("payload_field", ""))
	if selection_key.is_empty() or option_id.is_empty():
		return
	var selections: Dictionary = payload.get("selections", {}) as Dictionary
	selections[selection_key] = option_id
	payload["selections"] = selections
	if group_name.is_empty() or field_name.is_empty():
		return
	var group_payload: Dictionary = payload.get(group_name, {}) as Dictionary
	group_payload[field_name] = String(option_id)
	group_payload["zone"] = str(option.get("zone", ""))
	group_payload["role"] = str(option.get("role", ""))
	group_payload["size"] = (option.get("size", []) as Array).duplicate()
	group_payload["facing"] = str(option.get("facing", ""))
	group_payload["color"] = _color_to_array(option.get("color", Color.WHITE))
	payload[group_name] = group_payload


static func _recover_selections(payload: Dictionary) -> Dictionary:
	var recovered: Dictionary = {}
	for option: Dictionary in StoreDesignCatalogScript.all_options():
		var group_name: String = str(option.get("payload_group", ""))
		var field_name: String = str(option.get("payload_field", ""))
		if group_name.is_empty() or field_name.is_empty():
			continue
		var group_payload: Dictionary = payload.get(group_name, {}) as Dictionary
		if str(group_payload.get(field_name, "")) == str(option.get("id", "")):
			recovered[StringName(str(option.get("selection_key", "")))] = (
				StringName(str(option.get("id", "")))
			)
	return recovered


static func _color_to_array(value: Variant) -> Array[float]:
	var color: Color = Color.WHITE
	if value is Color:
		color = value
	return [color.r, color.g, color.b, color.a]
