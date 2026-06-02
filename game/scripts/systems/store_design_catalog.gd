## Shared catalog for store design options shown by build/design UI.
class_name StoreDesignCatalog
extends RefCounted

const CatalogEffectMetadataScript: GDScript = preload(
	"res://game/resources/catalog_effect_metadata.gd"
)

const _OPTIONS: Array[Dictionary] = [
		{
			"id": "floor_tile_cream",
			"category": &"surfaces",
			"selection_key": "floor",
			"payload_group": "surfaces",
			"payload_field": "floor_material_id",
			"name": "Cream Tile",
			"surface": "Floor",
			"zone": "sales_floor",
			"role": "surface",
			"size": [12, 8],
			"facing": "up",
			"cost": 35.0,
			"color": Color(0.86, 0.82, 0.70),
			"effect_summary": "Cosmetic only",
			"effects": [{"type": "cosmetic", "source": "StoreCustomizationSystem.design_selection"}],
		},
	{
			"id": "wall_warm_white",
			"category": &"surfaces",
			"selection_key": "wall",
			"payload_group": "surfaces",
			"payload_field": "wall_material_id",
			"name": "Warm Wall",
			"surface": "Wall",
			"zone": "perimeter_walls",
			"role": "surface",
			"size": [12, 3],
			"facing": "inward",
			"cost": 45.0,
			"color": Color(0.82, 0.78, 0.66),
			"default_selected": true,
			"effect_summary": "Cosmetic only",
			"effects": [{"type": "cosmetic", "source": "StoreCustomizationSystem.design_selection"}],
		},
		{
			"id": "paint_muted_gold",
			"category": &"surfaces",
			"selection_key": "paint",
			"payload_group": "surfaces",
			"payload_field": "paint_id",
			"name": "Muted Gold Paint",
			"surface": "Paint",
			"zone": "accent_wall",
			"role": "surface",
			"size": [4, 3],
			"facing": "inward",
			"cost": 30.0,
			"color": Color(0.72, 0.52, 0.24),
			"effect_summary": "Cosmetic only",
			"effects": [{"type": "cosmetic", "source": "StoreCustomizationSystem.design_selection"}],
		},
		{
			"id": "rubber_stockroom",
			"category": &"stockroom",
			"selection_key": "stockroom",
			"payload_group": "stockroom",
			"payload_field": "style_id",
			"name": "Rubber Utility",
			"surface": "Stockroom",
			"zone": "stockroom",
			"role": "back_of_house",
			"size": [4, 3],
			"facing": "front",
			"cost": 60.0,
			"color": Color(0.22, 0.24, 0.25),
			"unlock_day": 3,
			"effect_summary": "Cosmetic only",
			"effects": [{"type": "cosmetic", "source": "StoreCustomizationSystem.design_selection"}],
	},
	{
			"id": "warm_panel_light",
			"category": &"lighting",
			"selection_key": "lighting",
			"payload_group": "lighting",
			"payload_field": "preset_id",
			"name": "Warm Panels",
			"surface": "Ceiling",
			"zone": "sales_floor",
			"role": "lighting",
			"size": [12, 8],
			"facing": "down",
			"cost": 95.0,
			"color": Color(0.96, 0.82, 0.42),
			"effect_summary": "Cosmetic only",
			"effects": [{"type": "cosmetic", "source": "StoreCustomizationSystem.design_selection"}],
		},
	{
			"id": "trade_window_sign",
			"category": &"signage",
			"selection_key": "signage",
			"payload_group": "signage",
			"payload_field": "storefront_sign_id",
			"name": "Trade Sign",
			"surface": "Wall sign",
			"zone": "front_wall",
			"role": "wayfinding",
			"size": [3, 1],
			"facing": "entry",
			"cost": 25.0,
			"color": Color(0.80, 0.34, 0.24),
			"effect_summary": "Cosmetic only",
			"effects": [{"type": "cosmetic", "source": "StoreCustomizationSystem.design_selection"}],
		},
	{
			"id": "counter_entry_mat",
			"category": &"decor",
			"selection_key": "decor",
			"payload_group": "decor",
			"payload_field": "active_set_id",
			"name": "Entry Mat",
			"surface": "Decor",
			"zone": "entry",
			"role": "decor",
			"size": [2, 1],
			"facing": "entry",
			"cost": 20.0,
			"color": Color(0.20, 0.32, 0.42),
			"effect_summary": "Cosmetic only",
			"effects": [{"type": "cosmetic", "source": "StoreCustomizationSystem.design_selection"}],
		},
		{
			"id": "counter_laminate_black",
			"category": &"counters",
			"selection_key": "counter",
			"payload_group": "counter",
			"payload_field": "counter_style_id",
			"name": "Black Laminate",
			"surface": "Counter",
			"zone": "checkout",
			"role": "service",
			"size": [3, 1],
			"facing": "customer",
			"cost": 70.0,
			"color": Color(0.08, 0.08, 0.09),
			"effect_summary": "Cosmetic only",
			"effects": [{"type": "cosmetic", "source": "StoreCustomizationSystem.design_selection"}],
		},
		{
			"id": "shelf_oak_trim",
			"category": &"shelves",
			"selection_key": "shelf",
			"payload_group": "shelf",
			"payload_field": "shelf_style_id",
			"name": "Oak Shelf Trim",
			"surface": "Shelf",
			"zone": "sales_floor",
			"role": "fixture_finish",
			"size": [2, 1],
			"facing": "aisle",
			"cost": 40.0,
			"color": Color(0.50, 0.31, 0.16),
			"effect_summary": "Cosmetic only",
			"effects": [{"type": "cosmetic", "source": "StoreCustomizationSystem.design_selection"}],
		},
		{
			"id": "register_compact_ivory",
			"category": &"counters",
			"selection_key": "register",
			"payload_group": "register",
			"payload_field": "register_style_id",
			"name": "Compact Ivory",
			"surface": "Register",
			"zone": "checkout",
			"role": "service",
			"size": [1, 1],
			"facing": "customer",
			"cost": 55.0,
			"color": Color(0.88, 0.84, 0.72),
			"effect_summary": "Cosmetic only",
			"effects": [{"type": "cosmetic", "source": "StoreCustomizationSystem.design_selection"}],
		},
	]


## Returns all store-design options with normalized effect metadata.
static func all_options() -> Array[Dictionary]:
	var options: Array[Dictionary] = []
	for raw: Dictionary in _OPTIONS:
		options.append(_normalized_option(raw))
	return options


## Returns design options in one catalog category.
static func options_for_category(category: StringName) -> Array[Dictionary]:
	var options: Array[Dictionary] = []
	for option: Dictionary in all_options():
		if option.get("category", &"") == category:
			options.append(option)
	return options


## Returns one design option by id, or an empty dictionary when missing.
static func get_option(option_id: String) -> Dictionary:
	for option: Dictionary in all_options():
		if str(option.get("id", "")) == option_id:
			return option
	return {}


## Returns validation errors for all catalog options.
static func validate_catalog() -> Array[String]:
	var errors: Array[String] = []
	for option: Dictionary in all_options():
		var effects: Array[Dictionary] = []
		effects.assign(option.get("effects", []))
		errors.append_array(
			CatalogEffectMetadataScript.validate_advertised_effects(
				str(option.get("effect_summary", "")),
				effects,
				str(option.get("id", ""))
			)
		)
	return errors


static func _normalized_option(raw: Dictionary) -> Dictionary:
	var option: Dictionary = raw.duplicate(true)
	var raw_effects: Array = option.get("effects", []) as Array
	option["effects"] = CatalogEffectMetadataScript.normalize_effects(raw_effects, true)
	return option
