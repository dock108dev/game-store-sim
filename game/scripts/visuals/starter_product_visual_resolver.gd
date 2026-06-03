## Resolves starter product metadata for generated store visuals.
class_name StarterProductVisualResolver
extends RefCounted

const VISUAL_EXTRA_KEYS: Array[String] = [
	"box_art_key",
	"platform_visual_id",
	"visual_alias_id",
	"visual_presentation",
	"visual_variant_id",
	"case_shape_override",
	"cartridge_shape_override",
	"console_box_shape_override",
	"package_finish",
	"package_wear_level",
]
const PHYSICAL_TAG_EXTRA_KEYS: Array[String] = [
	"physical_tag_profile",
	"condition_grade",
	"condition_grades",
	"edition_badge",
	"authenticity_badge",
	"sleeve_style",
	"protector_style",
	"sticker_shape",
	"tag_shape",
	"tag_color_override",
	"platform_tag_override",
	"staff_pick",
	"sale",
	"clearance",
	"trade_in_base",
]

const STARTER_PRODUCT_FALLBACKS: Dictionary = {
	"console_neo_ignite":
	{
		"display_name": "Neo Ignite Console (Working)",
		"category": "consoles",
		"platform_id": "neo_ignite",
		"platform_visual_id": "neo_ignite_disc_tower",
		"console_box_shape_override": "tower_box",
		"price_cents": 11900,
	},
	"neo_ignite_motorway_kings_loose":
	{
		"display_name": "Motorway Kings",
		"category": "cartridges",
		"platform_id": "neo_ignite",
		"platform_visual_id": "neo_ignite_disc_tower",
		"box_art_key": "motorway_kings_neo_ignite",
		"visual_presentation": "game_case",
		"price_cents": 1600,
	},
	"neo_ignite_kingdom_embers_loose":
	{
		"display_name": "Kingdom of Embers",
		"category": "cartridges",
		"platform_id": "neo_ignite",
		"platform_visual_id": "neo_ignite_disc_tower",
		"box_art_key": "kingdom_embers_neo_ignite",
		"visual_presentation": "game_case",
		"case_shape_override": "long_cardboard_box",
		"price_cents": 1800,
	},
	"neo_ignite_torque_force_3_loose":
	{
		"display_name": "Torque Force 3",
		"category": "cartridges",
		"platform_id": "neo_ignite",
		"platform_visual_id": "neo_ignite_disc_tower",
		"visual_presentation": "cartridge",
		"cartridge_shape_override": "wide_cart",
		"price_cents": 1100,
	},
	"neo_ignite_gridiron_2005_loose":
	{
		"display_name": "Gridiron Season 2005",
		"category": "cartridges",
		"platform_id": "neo_ignite",
		"platform_visual_id": "neo_ignite_disc_tower",
		"visual_presentation": "cartridge",
		"cartridge_shape_override": "mini_card",
		"price_cents": 500,
	},
}


## Resolves visual metadata from DataLoader, ContentRegistry, then starter fallbacks.
static func visual_data_for_item_id(item_id: String) -> Dictionary:
	var definition: ItemDefinition = null
	if GameManager.data_loader:
		definition = GameManager.data_loader.get_item(item_id)
	if definition:
		var definition_data: Dictionary = _from_definition(definition)
		return _merge_starter_defaults(item_id, definition_data, "data_loader")

	var item_key: StringName = StringName(item_id)
	if ContentRegistry.exists(item_id):
		var entry: Dictionary = ContentRegistry.get_entry(item_key)
		if not entry.is_empty():
			var entry_data: Dictionary = _from_entry(item_id, entry)
			return _merge_starter_defaults(item_id, entry_data, "content_registry")

	if STARTER_PRODUCT_FALLBACKS.has(item_id):
		var fallback: Dictionary = (STARTER_PRODUCT_FALLBACKS[item_id] as Dictionary).duplicate(true)
		fallback["definition_id"] = item_id
		fallback["visual_resolution_source"] = "starter_fallback"
		return fallback

	return {
		"definition_id": item_id,
		"display_name": item_id,
		"category": "",
		"platform_id": "",
		"price_cents": 0,
		"visual_resolution_source": "unknown_fallback",
	}


static func _merge_starter_defaults(
	item_id: String, resolved: Dictionary, source: String
) -> Dictionary:
	var data: Dictionary = {}
	if STARTER_PRODUCT_FALLBACKS.has(item_id):
		data = (STARTER_PRODUCT_FALLBACKS[item_id] as Dictionary).duplicate(true)
	for key: Variant in resolved:
		data[key] = resolved[key]
	data["definition_id"] = str(data.get("definition_id", item_id))
	data["visual_resolution_source"] = source
	return data


static func _from_definition(definition: ItemDefinition) -> Dictionary:
	var display_price: float = (
		definition.used_price if definition.used_price > 0.0 else definition.base_price
	)
	var data: Dictionary = {
		"definition_id": definition.id,
		"display_name": definition.item_name,
		"category": String(definition.category),
		"rarity": definition.rarity,
		"rarity_tier": definition.rarity_tier,
		"condition": "good",
		"condition_tier": ItemDefinition.condition_to_tier("good"),
		"condition_range": definition.condition_range,
		"condition_tier_range": definition.condition_tier_range,
		"tags": definition.tags,
		"product_set_name": definition.product_set_name,
		"appreciates": definition.appreciates,
		"depreciates": definition.depreciates,
		"decay_profile": String(definition.decay_profile),
		"platform": definition.platform,
		"platform_id": String(definition.platform_id),
		"region": definition.region,
		"suspicious_chance": definition.suspicious_chance,
		"supply_constrained": definition.supply_constrained,
		"launch_window_start_day": definition.launch_window_start_day,
		"launch_window_end_day": definition.launch_window_end_day,
		"price_cents": int(round(display_price * 100.0)),
	}
	if definition.extra is Dictionary:
		_copy_visual_extra(data, definition.extra)
		_copy_physical_tag_extra(data, definition.extra)
	return data


static func _from_entry(item_id: String, entry: Dictionary) -> Dictionary:
	var display_price: float = float(entry.get("used_price", entry.get("base_price", 0.0)))
	var data: Dictionary = {
		"definition_id": str(entry.get("id", item_id)),
		"display_name": str(entry.get("item_name", item_id)),
		"category": str(entry.get("category", "")),
		"rarity": str(entry.get("rarity", "common")),
		"rarity_tier": ItemDefinition.rarity_to_tier(str(entry.get("rarity", "common"))),
		"condition": "good",
		"condition_tier": ItemDefinition.condition_to_tier("good"),
		"condition_range": entry.get("condition_range", PackedStringArray()),
		"condition_tier_range": _condition_tier_range_from_entry(entry),
		"tags": entry.get("tags", PackedStringArray()),
		"product_set_name": str(entry.get("product_set_name", "")),
		"appreciates": bool(entry.get("appreciates", false)),
		"depreciates": bool(entry.get("depreciates", false)),
		"decay_profile": str(entry.get("decay_profile", "standard")),
		"platform": str(entry.get("platform", "")),
		"platform_id": str(entry.get("platform_id", "")),
		"region": str(entry.get("region", "")),
		"suspicious_chance": float(entry.get("suspicious_chance", 0.0)),
		"supply_constrained": bool(entry.get("supply_constrained", false)),
		"launch_window_start_day": int(entry.get("launch_window_start_day", 0)),
		"launch_window_end_day": int(entry.get("launch_window_end_day", 0)),
		"price_cents": int(round(display_price * 100.0)),
	}
	_copy_visual_extra(data, entry)
	_copy_physical_tag_extra(data, entry)
	return data


static func _copy_visual_extra(target: Dictionary, source: Dictionary) -> void:
	for key: String in VISUAL_EXTRA_KEYS:
		if source.has(key):
			target[key] = source[key]


static func _copy_physical_tag_extra(target: Dictionary, source: Dictionary) -> void:
	for key: String in PHYSICAL_TAG_EXTRA_KEYS:
		if source.has(key):
			target[key] = source[key]


static func _condition_tier_range_from_entry(entry: Dictionary) -> Vector2:
	if not entry.has("condition_range"):
		return Vector2.ZERO
	var labels: PackedStringArray = ItemDefinition._normalize_string_name_array(
		entry["condition_range"]
	)
	if labels.is_empty():
		return Vector2.ZERO
	return Vector2(
		ItemDefinition.condition_to_tier(labels[0]),
		ItemDefinition.condition_to_tier(labels[labels.size() - 1])
	)
