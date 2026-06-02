class_name ContentCatalogResourceParser

const CatalogEffectMetadataScript: GDScript = preload(
	"res://game/resources/catalog_effect_metadata.gd"
)

const _ITEM_FIELD_ALIASES: Dictionary = {
	"item_name": ["item_name", "display_name", "name"],
	"base_price": ["base_price", "base_value"],
	"condition_range": [
		"condition_range", "condition_variants",
	],
	"icon_path": ["icon_path", "icon"],
	"product_set_name": ["set_name", "set"],
}

const _ITEM_KNOWN_KEYS: Array[String] = [
	"id", "item_name", "description", "category", "subcategory",
	"store_type", "base_price", "rarity", "condition_range",
	"condition_value_multipliers", "icon_path", "tags", "product_set_name",
	"depreciates", "appreciates", "release_day",
	"brand", "product_line", "generation",
	"lifecycle_phase", "launch_day", "depreciation_rate",
	"min_value_ratio", "launch_demand_multiplier", "launch_spike_days",
	"monthly_depreciation_rate",
	"launch_spike_eligible", "launch_spike_multiplier", "supplier_tier",
	"platform", "platform_id", "region",
	"suspicious_chance",
	"launch_window_start_day", "launch_window_end_day",
	"supply_constrained", "decay_profile", "edition_year", "edition_series",
	"sequel_of",
	"used_price",
]


static func parse_item(data: Dictionary) -> ItemDefinition:
	var normalized: Dictionary = _normalize_item_data(data)
	if not normalized.has("id") or not normalized.has("base_price"):
		push_error("ContentParser: item missing required fields: %s" % [data])
		return null
	var price_val: float = float(normalized.get("base_price", 0.0))
	if price_val < 0.0:
		push_error(
			"ContentParser: item '%s' has out-of-range base_price %s (must be >= 0)"
			% [str(normalized.get("id", "unknown")), price_val]
		)
		return null
	var item := ItemDefinition.new()
	item.id = str(normalized["id"])
	var item_name_raw: String = str(normalized.get("item_name", ""))
	item.item_name = item_name_raw
	item.description = str(normalized.get("description", ""))
	item.category = StringName(str(normalized.get("category", "")))
	item.subcategory = str(normalized.get("subcategory", ""))
	item.store_type = StringName(str(normalized.get("store_type", "")))
	item.base_price = price_val
	item.rarity = str(normalized.get("rarity", "common"))
	item.icon_path = str(normalized.get("icon_path", ""))
	item.product_set_name = str(normalized.get("product_set_name", ""))
	item.depreciates = bool(normalized.get("depreciates", false))
	item.appreciates = bool(normalized.get("appreciates", false))
	item.release_day = int(normalized.get("release_day", 0))
	item.brand = str(normalized.get("brand", ""))
	item.product_line = str(normalized.get("product_line", ""))
	item.generation = int(normalized.get("generation", 0))
	item.lifecycle_phase = str(normalized.get("lifecycle_phase", ""))
	item.launch_day = int(normalized.get("launch_day", 0))
	item.depreciation_rate = float(normalized.get("depreciation_rate", 0.0))
	item.min_value_ratio = float(normalized.get("min_value_ratio", 0.1))
	item.launch_demand_multiplier = float(
		normalized.get("launch_demand_multiplier", 1.0)
	)
	item.launch_spike_days = int(normalized.get("launch_spike_days", 0))
	item.monthly_depreciation_rate = float(
		normalized.get("monthly_depreciation_rate", 0.0)
	)
	item.launch_spike_eligible = bool(
		normalized.get("launch_spike_eligible", false)
	)
	item.launch_spike_multiplier = float(
		normalized.get("launch_spike_multiplier", 1.0)
	)
	item.supplier_tier = int(normalized.get("supplier_tier", 0))
	item.platform = str(normalized.get("platform", ""))
	item.platform_id = StringName(str(normalized.get("platform_id", "")))
	item.launch_window_start_day = int(
		normalized.get("launch_window_start_day", 0)
	)
	item.launch_window_end_day = int(
		normalized.get("launch_window_end_day", 0)
	)
	item.supply_constrained = bool(
		normalized.get("supply_constrained", false)
	)
	item.decay_profile = StringName(
		str(normalized.get("decay_profile", "standard"))
	)
	item.edition_year = int(normalized.get("edition_year", 0))
	item.edition_series = StringName(
		str(normalized.get("edition_series", ""))
	)
	item.sequel_of = str(normalized.get("sequel_of", ""))
	item.used_price = float(normalized.get("used_price", 0.0))
	item.region = str(normalized.get("region", ""))
	item.suspicious_chance = float(normalized.get("suspicious_chance", 0.0))
	if normalized.has("condition_range"):
		item.condition_range = _normalize_condition_labels(
			normalized["condition_range"]
		)
	if normalized.has("condition_value_multipliers"):
		item.condition_value_multipliers = (
			normalized["condition_value_multipliers"]
		)
	if normalized.has("tags"):
		item.tags = ItemDefinition._normalize_string_name_array(
			normalized["tags"]
		)
	var extra: Dictionary = {}
	for key: String in normalized:
		if key not in _ITEM_KNOWN_KEYS:
			extra[key] = normalized[key]
	if not extra.is_empty():
		item.extra = extra
	return item


static func parse_store(data: Dictionary) -> StoreDefinition:
	if not data.has("id") or not data.has("name"):
		push_error(
			"ContentParser: store missing required fields: %s" % [data]
		)
		return null
	var store := StoreDefinition.new()
	store.id = str(data["id"])
	store.store_name = str(data["name"])
	store.store_type = StringName(str(data.get("store_type", "")))
	store.description = str(data.get("description", ""))
	store.scene_path = str(data.get("scene_path", ""))
	store.inventory_type = StringName(str(data.get("inventory_type", "")))
	store.interaction_set_id = StringName(str(data.get("interaction_set_id", "")))
	store.tutorial_context_id = StringName(str(data.get("tutorial_context_id", "")))
	store.size_category = str(data.get("size_category", "small"))
	store.starting_budget = float(data.get("starting_budget", 5000.0))
	store.fixture_slots = int(data.get("fixture_slots", 6))
	store.max_employees = int(data.get("max_employees", 2))
	store.shelf_capacity = int(data.get("shelf_capacity", 0))
	store.backroom_capacity = int(data.get("backroom_capacity", 0))
	store.daily_rent = float(data.get("daily_rent", 0.0))
	store.base_foot_traffic = float(data.get("base_foot_traffic", 0.0))
	store.ambient_sound = str(data.get("ambient_sound", ""))
	store.music = str(data.get("music", ""))
	if data.has("allowed_categories"):
		store.allowed_categories = PackedStringArray(
			data["allowed_categories"]
		)
	if data.has("starting_inventory"):
		store.starting_inventory = PackedStringArray(
			data["starting_inventory"]
		)
	if data.has("starter_inventory"):
		var starter_entries: Array[Dictionary] = []
		for entry: Variant in data["starter_inventory"]:
			if entry is Dictionary:
				starter_entries.append((entry as Dictionary).duplicate(true))
		store.starter_inventory = starter_entries
	if data.has("fixtures"):
		var arr: Array[Dictionary] = []
		for f: Variant in data["fixtures"]:
			if f is Dictionary:
				arr.append(f)
		store.fixtures = arr
	if data.has("available_supplier_tiers"):
		var tiers: Array[int] = []
		for t: Variant in data["available_supplier_tiers"]:
			tiers.append(int(t))
		store.available_supplier_tiers = tiers
	if data.has("unique_mechanics"):
		store.unique_mechanics = PackedStringArray(
			data["unique_mechanics"]
		)
	if data.has("aesthetic_tags"):
		store.aesthetic_tags = PackedStringArray(data["aesthetic_tags"])
	if data.has("upgrade_ids"):
		var upgrade_ids: Array[StringName] = []
		for raw_upgrade_id: Variant in data["upgrade_ids"]:
			upgrade_ids.append(StringName(str(raw_upgrade_id)))
		store.upgrade_ids = upgrade_ids
	if data.has("recommended_markup"):
		var m: Variant = data["recommended_markup"]
		if m is Dictionary:
			store.recommended_markup_optimal_min = float(
				m.get("optimal_min", 0.0)
			)
			store.recommended_markup_optimal_max = float(
				m.get("optimal_max", 0.0)
			)
			store.recommended_markup_max_viable = float(
				m.get("max_viable", 0.0)
			)
	return store


static func parse_customer(data: Dictionary) -> CustomerTypeDefinition:
	if not data.has("id") or not data.has("name"):
		push_error(
			"ContentParser: customer missing required fields: %s"
			% [data]
		)
		return null
	var p := CustomerTypeDefinition.new()
	p.id = str(data["id"])
	p.customer_name = str(data["name"])
	p.description = str(data.get("description", ""))
	p.patience = float(data.get("patience", 0.5))
	p.price_sensitivity = float(data.get("price_sensitivity", 0.5))
	p.impulse_buy_chance = float(data.get("impulse_buy_chance", 0.1))
	p.condition_preference = str(data.get("condition_preference", "good"))
	p.purchase_probability_base = float(
		data.get("purchase_probability_base", 0.5)
	)
	p.visit_frequency = str(data.get("visit_frequency", "medium"))
	p.max_price_to_market_ratio = float(
		data.get("max_price_to_market_ratio", 1.0)
	)
	p.snack_purchase_probability = float(
		data.get("snack_purchase_probability", 0.0)
	)
	p.leaves_if_unavailable = bool(
		data.get("leaves_if_unavailable", false)
	)
	p.dialogue_pool = str(data.get("dialogue_pool", ""))
	p.model_path = str(data.get("model", data.get("model_path", "")))
	if data.has("store_types"):
		p.store_types = PackedStringArray(data["store_types"])
	if data.has("store_affinity"):
		var affinity: Array[StringName] = []
		for raw_store_id: Variant in data["store_affinity"]:
			affinity.append(StringName(str(raw_store_id)))
		p.store_affinity = affinity
	if data.has("preferred_categories"):
		p.preferred_categories = PackedStringArray(data["preferred_categories"])
	if data.has("preferred_tags"):
		p.preferred_tags = PackedStringArray(data["preferred_tags"])
	if data.has("preferred_rarities"):
		p.preferred_rarities = PackedStringArray(data["preferred_rarities"])
	if data.has("mood_tags"):
		p.mood_tags = PackedStringArray(data["mood_tags"])
	p.budget_range = _parse_float_array(data, "budget_range")
	p.spending_range = _parse_float_array(data, "spending_range")
	p.browse_time_range = _parse_float_array(data, "browse_time_range")
	if data.has("typical_rental_count"):
		var arr: Array[int] = []
		for val: Variant in data["typical_rental_count"]:
			arr.append(int(val))
		p.typical_rental_count = arr
	p.spawn_weight = float(data.get("spawn_weight", _derive_spawn_weight(data)))
	if data.has("platform_affinities"):
		var affinities: Array[StringName] = []
		for raw_platform_id: Variant in data["platform_affinities"]:
			affinities.append(StringName(str(raw_platform_id)))
		p.platform_affinities = affinities
	p.shortage_sensitivity = float(data.get("shortage_sensitivity", 0.0))
	p.archetype_id = StringName(str(data.get("archetype_id", "")))
	return p


static func parse_fixture(data: Dictionary) -> FixtureDefinition:
	var has_name: bool = data.has("name") or data.has("display_name")
	var has_price: bool = (
		data.has("price") or data.has("cost")
		or data.has("purchase_cost")
	)
	if not data.has("id") or not has_name or not has_price:
		push_error(
			"ContentParser: fixture missing required fields: %s"
			% [data]
		)
		return null
	var f := FixtureDefinition.new()
	f.id = str(data["id"])
	f.display_name = str(data.get("display_name", data.get("name", "")))
	f.name = f.display_name
	f.cost = float(data.get(
		"cost", data.get("price", data.get("purchase_cost", 0.0))
	))
	f.price = f.cost
	f.description = str(data.get("description", ""))
	f.slot_count = int(data.get("slot_count", data.get("item_capacity", 0)))
	f.rotation_support = bool(data.get("rotation_support", false))
	f.unlock_rep = float(data.get("unlock_rep", 0.0))
	f.unlock_day = int(data.get("unlock_day", 0))
	f.requires_wall = bool(data.get("requires_wall", false))
	f.visual_category = str(data.get("visual_category", ""))
	f.scene_path = str(data.get("scene_path", ""))
	f.catalog_category = str(data.get("catalog_category", f.visual_category))
	f.catalog_sort = int(data.get("catalog_sort", 0))
	f.silhouette = str(data.get("silhouette", ""))
	f.capacity_label = str(data.get("capacity_label", ""))
	f.effect_summary = str(data.get("effect_summary", ""))
	f.owned_limit = int(data.get("owned_limit", 0))
	if data.get("effects", []) is Array:
		var effects: Array = data.get("effects", []) as Array
		f.effects.assign(CatalogEffectMetadataScript.normalize_effects(effects))
	_parse_fixture_unlock(f, data)
	_parse_fixture_store_types(f, data)
	_parse_fixture_footprint(f, data)
	f.tier_data = _build_tier_data(f)
	return f


static func _normalize_item_data(data: Dictionary) -> Dictionary:
	var normalized: Dictionary = data.duplicate(true)
	for canonical_key: String in _ITEM_FIELD_ALIASES:
		if normalized.has(canonical_key):
			continue
		var aliases: Array = _ITEM_FIELD_ALIASES[canonical_key]
		for alias_key: String in aliases:
			if normalized.has(alias_key):
				normalized[canonical_key] = normalized[alias_key]
				break
	for canonical_key: String in _ITEM_FIELD_ALIASES:
		var aliases: Array = _ITEM_FIELD_ALIASES[canonical_key]
		for alias_key: String in aliases:
			if alias_key == canonical_key:
				continue
			normalized.erase(alias_key)
	return normalized


static func _normalize_condition_labels(values: Variant) -> PackedStringArray:
	var incoming: Array[String] = []
	if values is PackedStringArray:
		for value: String in values:
			incoming.append(value)
	elif values is Array:
		for value: Variant in values:
			incoming.append(str(value))
	var normalized: PackedStringArray = PackedStringArray()
	for label: String in ItemDefinition.CONDITION_ORDER:
		if label in incoming:
			normalized.append(label)
	return normalized


static func _parse_float_array(data: Dictionary, key: String) -> Array[float]:
	if not data.has(key):
		return []
	var arr: Array[float] = []
	for val: Variant in data[key]:
		arr.append(float(val))
	return arr


static func _derive_spawn_weight(data: Dictionary) -> float:
	if not data.has("spawn_weight_by_hour"):
		return 1.0
	var raw_weights: Variant = data["spawn_weight_by_hour"]
	if raw_weights is not Dictionary:
		return 1.0
	var total_weight: float = 0.0
	for raw_value: Variant in (raw_weights as Dictionary).values():
		total_weight += float(raw_value)
	return maxf(total_weight, 1.0)


static func _parse_fixture_unlock(
	f: FixtureDefinition, data: Dictionary
) -> void:
	f.unlock_condition = {}
	if f.unlock_rep > 0:
		f.unlock_condition["reputation"] = f.unlock_rep
	if f.unlock_day > 0:
		f.unlock_condition["day"] = f.unlock_day
	if data.has("unlock_condition"):
		var uc: Variant = data["unlock_condition"]
		if uc is Dictionary:
			f.unlock_condition.merge(uc, false)
			if f.unlock_condition.has("reputation"):
				f.unlock_rep = float(f.unlock_condition["reputation"])
			if f.unlock_condition.has("day"):
				f.unlock_day = int(f.unlock_condition["day"])


static func _parse_fixture_store_types(
	f: FixtureDefinition, data: Dictionary
) -> void:
	var restriction: String = str(data.get("store_type_restriction", ""))
	f.store_type_restriction = restriction
	if not restriction.is_empty():
		f.store_types = PackedStringArray([restriction])
		f.category = "store_specific"
	elif data.has("store_type_affinity"):
		var affinity: Array = data["store_type_affinity"]
		var is_universal: bool = (
			affinity.size() == 1 and str(affinity[0]) == "universal"
		)
		if is_universal:
			f.store_types = PackedStringArray()
			f.category = "universal"
		else:
			f.store_types = PackedStringArray(affinity)
			if not f.store_types.is_empty():
				f.store_type_restriction = str(f.store_types[0])
			f.category = "store_specific"
	elif data.has("store_types"):
		f.store_types = PackedStringArray(data["store_types"])
		if not f.store_types.is_empty():
			f.category = "store_specific"
		else:
			f.category = "universal"
	else:
		f.category = str(data.get("category", "universal"))


static func _parse_fixture_footprint(
	f: FixtureDefinition, data: Dictionary
) -> void:
	if data.has("footprint_cells") and data["footprint_cells"] is Array:
		var parsed: Array[Vector2i] = []
		var max_x: int = 0
		var max_y: int = 0
		for cell: Variant in data["footprint_cells"]:
			if cell is Array and (cell as Array).size() >= 2:
				var v := Vector2i(int(cell[0]), int(cell[1]))
				parsed.append(v)
				max_x = maxi(max_x, v.x)
				max_y = maxi(max_y, v.y)
		f.footprint_cells = parsed
		f.grid_size = Vector2i(max_x + 1, max_y + 1)
	elif data.has("grid_size") and data["grid_size"] is Array:
		var gs: Array = data["grid_size"]
		if gs.size() >= 2:
			f.grid_size = Vector2i(int(gs[0]), int(gs[1]))
		f.footprint_cells = _grid_size_to_cells(f.grid_size)
	elif data.has("grid_width") and data.has("grid_depth"):
		f.grid_size = Vector2i(
			int(data["grid_width"]), int(data["grid_depth"])
		)
		f.footprint_cells = _grid_size_to_cells(f.grid_size)


static func _grid_size_to_cells(size: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for x: int in range(size.x):
		for y: int in range(size.y):
			cells.append(Vector2i(x, y))
	return cells


static func _build_tier_data(f: FixtureDefinition) -> Dictionary:
	var tiers: Dictionary = {}
	for tier: int in [
		FixtureDefinition.TierLevel.BASIC,
		FixtureDefinition.TierLevel.IMPROVED,
		FixtureDefinition.TierLevel.PREMIUM,
	]:
		tiers[tier] = {
			"slot_count": f.get_slots_for_tier(tier),
			"purchase_prob_bonus": f.get_purchase_prob_bonus(tier),
		}
	return tiers
