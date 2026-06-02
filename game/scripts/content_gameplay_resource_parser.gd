class_name ContentGameplayResourceParser


static func parse_market_event(data: Dictionary) -> MarketEventDefinition:
	if not data.has("id") or not data.has("event_type"):
		push_error(
			"ContentParser: market event missing required fields: %s"
			% [data]
		)
		return null
	var e := MarketEventDefinition.new()
	e.id = str(data["id"])
	e.name = str(data.get("name", ""))
	e.description = str(data.get("description", ""))
	e.event_type = str(data["event_type"])
	e.magnitude = float(data.get("magnitude", 1.0))
	e.duration_days = int(data.get("duration_days", 5))
	e.announcement_days = int(data.get("announcement_days", 2))
	e.ramp_up_days = int(data.get("ramp_up_days", 1))
	e.ramp_down_days = int(data.get("ramp_down_days", 1))
	e.cooldown_days = int(data.get("cooldown_days", 15))
	e.weight = float(data.get("weight", 1.0))
	e.announcement_text = str(data.get("announcement_text", ""))
	e.active_text = str(data.get("active_text", ""))
	if data.has("target_tags"):
		e.target_tags = PackedStringArray(data["target_tags"])
	if data.has("target_categories"):
		e.target_categories = PackedStringArray(
			data["target_categories"]
		)
	if data.has("target_store_types"):
		e.target_store_types = PackedStringArray(
			data["target_store_types"]
		)
	return e


static func parse_random_event(data: Dictionary) -> RandomEventDefinition:
	if not data.has("id"):
		push_error(
			"ContentParser: random event missing required fields: %s"
			% [data]
		)
		return null
	var e := RandomEventDefinition.new()
	e.id = str(data["id"])
	e.display_name = str(data.get("display_name", data.get("name", "")))
	e.name = e.display_name
	e.description = str(data.get("description", ""))
	e.trigger_probability = float(
		data.get("trigger_probability", data.get("probability_weight", 1.0))
	)
	e.effect_type = str(data.get("effect_type", ""))
	e.effect_target = str(data.get("effect_target", ""))
	e.effect_magnitude = float(data.get("effect_magnitude", 1.0))
	e.duration_days = int(data.get("duration_days", 1))
	e.severity = str(data.get("severity", "medium"))
	e.cooldown_days = int(data.get("cooldown_days", 10))
	e.probability_weight = e.trigger_probability
	e.target_category = str(data.get("target_category", ""))
	e.target_item_id = str(data.get("target_item_id", ""))
	e.notification_text = str(data.get("notification_text", ""))
	e.resolution_text = str(data.get("resolution_text", ""))
	e.toast_message = str(data.get("toast_message", ""))
	e.time_window_start = int(data.get("time_window_start", -1))
	e.time_window_end = int(data.get("time_window_end", -1))
	e.bulk_order_quantity = int(data.get("bulk_order_quantity", 3))
	e.bulk_order_price_multiplier = float(
		data.get("bulk_order_price_multiplier", 1.2)
	)
	return e


static func parse_staff(data: Dictionary) -> StaffDefinition:
	if not data.has("id") or not data.has("name"):
		push_error(
			"ContentParser: staff missing required fields: %s" % [data]
		)
		return null
	var d := StaffDefinition.new()
	d.staff_id = str(data["id"])
	d.display_name = str(data["name"])
	d.skill_level = clampi(int(data.get("skill_level", 1)), 1, 3)
	d.daily_wage = float(data.get("daily_wage", 20.0))
	d.hire_cost = float(data.get("hire_cost", 0.0))
	d.morale = float(
		data.get("morale_start", StaffDefinition.DEFAULT_MORALE)
	)
	d.morale_decay_per_day = float(
		data.get(
			"morale_decay_per_day",
			StaffDefinition.DEFAULT_MORALE_DECAY,
		)
	)
	d.skill_bonus = float(data.get("skill_bonus", 0.0))
	d.description = str(data.get("description", ""))
	var role_str: String = str(data.get("role", "cashier")).to_lower()
	match role_str:
		"stocker":
			d.role = StaffDefinition.StaffRole.STOCKER
		"greeter":
			d.role = StaffDefinition.StaffRole.GREETER
		"cashier":
			d.role = StaffDefinition.StaffRole.CASHIER
		_:
			push_warning(
				"ContentParser: staff '%s' has unknown role '%s', defaulting to CASHIER"
				% [d.staff_id, role_str]
			)
			d.role = StaffDefinition.StaffRole.CASHIER
	return d


static func parse_milestone(data: Dictionary) -> MilestoneDefinition:
	var has_name: bool = data.has("display_name") or data.has("name")
	if not data.has("id") or not has_name:
		push_error(
			"ContentParser: milestone missing required fields: %s"
			% [data]
		)
		return null
	var m := MilestoneDefinition.new()
	m.id = str(data["id"])
	m.display_name = str(data.get("display_name", data.get("name", "")))
	m.description = str(data.get("description", ""))
	m.is_visible = bool(data.get("is_visible", true))
	m.tier = str(data.get("tier", ""))
	m.trigger_type = str(data.get("trigger_type", ""))
	m.trigger_threshold = float(
		data.get("trigger_threshold", data.get("threshold", 0.0))
	)
	m.trigger_stat_key = str(
		data.get("trigger_stat_key", data.get("condition_type", ""))
	)
	m.reward_type = str(data.get("reward_type", "none"))
	m.reward_value = float(data.get("reward_value", 0.0))
	var raw_unlock: Variant = data.get("unlock_id")
	m.unlock_id = str(raw_unlock) if raw_unlock != null else ""
	m.min_day = int(data.get("min_day", 0))
	m.min_manager_trust_tier_index = int(
		data.get("min_manager_trust_tier_index", 0)
	)
	return m


static func parse_upgrade(data: Dictionary) -> UpgradeDefinition:
	if not data.has("id") or not data.has("display_name"):
		push_error(
			"ContentParser: upgrade missing required fields: %s"
			% [data]
		)
		return null
	var u := UpgradeDefinition.new()
	u.id = str(data["id"])
	u.display_name = str(data["display_name"])
	u.description = str(data.get("description", ""))
	u.cost = float(data.get("cost", 0.0))
	u.rep_required = float(
		data.get("rep_required", data.get("reputation_requirement", 0.0))
	)
	var raw_store_type: Variant = data.get("store_type", "")
	u.store_type = "" if raw_store_type == null else str(raw_store_type)
	u.effect_type = str(data.get("effect_type", ""))
	u.effect_value = float(data.get("effect_value", 0.0))
	u.one_time = bool(data.get("one_time", true))
	return u


static func parse_supplier(data: Dictionary) -> SupplierDefinition:
	if not data.has("id") or not data.has("display_name"):
		push_error(
			"ContentParser: supplier missing required fields: %s"
			% [data]
		)
		return null
	var s := SupplierDefinition.new()
	s.id = str(data["id"])
	s.display_name = str(data["display_name"])
	s.tier = int(data.get("tier", 1))
	s.store_type = str(data.get("store_type", ""))
	s.reliability_rate = float(data.get("reliability_rate", 1.0))
	if data.has("lead_time_days"):
		var lt: Variant = data["lead_time_days"]
		if lt is Dictionary:
			s.lead_time_min = int(lt.get("min", 1))
			s.lead_time_max = int(lt.get("max", 2))
	if data.has("unlock_condition"):
		var uc: Variant = data["unlock_condition"]
		if uc is Dictionary:
			s.unlock_condition = uc
	if data.has("catalog"):
		var cat: Array[Dictionary] = []
		for entry: Variant in data["catalog"]:
			if entry is Dictionary:
				cat.append(entry)
		s.catalog = cat
	return s


static func parse_unlock(data: Dictionary) -> UnlockDefinition:
	if not data.has("id") or not data.has("display_name"):
		push_error(
			"ContentParser: unlock missing required fields: %s"
			% [data]
		)
		return null
	var u := UnlockDefinition.new()
	u.id = str(data["id"])
	u.display_name = str(data["display_name"])
	u.description = str(data.get("description", ""))
	u.effect_type = str(data.get("effect_type", ""))
	if not u.is_valid_effect_type():
		push_error(
			"ContentParser: unlock '%s' has invalid effect_type '%s'"
			% [u.id, u.effect_type]
		)
		return null
	var target: Variant = data.get("effect_target")
	u.effect_target = str(target) if target != null else ""
	var value: Variant = data.get("effect_value")
	u.effect_value = float(value) if value != null else 0.0
	u.unlock_message = str(data.get("unlock_message", ""))
	return u


static func parse_economy_config(data: Dictionary) -> EconomyConfig:
	var c := EconomyConfig.new()
	c.starting_cash = float(data.get("starting_cash", 500.0))
	c.daily_rent_base = float(
		data.get("daily_rent_base", data.get("daily_rent", 30.0))
	)
	if data.has("daily_rent_multipliers"):
		var raw: Variant = data["daily_rent_multipliers"]
		if raw is Dictionary:
			c.daily_rent_multipliers = raw
	if data.has("rarity_multipliers"):
		c.rarity_multipliers = _parse_float_array(data, "rarity_multipliers")
	if data.has("condition_multipliers"):
		c.condition_multipliers = _parse_float_array(
			data, "condition_multipliers"
		)
	c.haggle_floor_ratio = float(data.get("haggle_floor_ratio", 0.5))
	c.haggle_max_rounds = int(data.get("haggle_max_rounds", 3))
	if data.has("reputation_tiers"):
		c.reputation_tiers = data["reputation_tiers"]
	if data.has("markup_ranges"):
		c.markup_ranges = data["markup_ranges"]
	if data.has("demand_modifiers"):
		c.demand_modifiers = data["demand_modifiers"]
	if data.has("daily_rent_per_size"):
		c.daily_rent_per_size = data["daily_rent_per_size"]
	if data.has("supplier_tiers"):
		var tiers: Array[Dictionary] = []
		for t: Variant in data["supplier_tiers"]:
			if t is Dictionary:
				tiers.append(t)
		c.supplier_tiers = tiers
	if data.has("price_ratio_reputation_deltas"):
		c.price_ratio_reputation_deltas = (
			data["price_ratio_reputation_deltas"]
		)
	if data.has("reputation_decay"):
		c.reputation_decay = data["reputation_decay"]
	return c


static func parse_ambient_moment(data: Dictionary) -> AmbientMomentDefinition:
	if not data.has("id"):
		push_error(
			"ContentParser: ambient moment missing 'id': %s" % [data]
		)
		return null
	var m := AmbientMomentDefinition.new()
	m.id = str(data["id"])
	m.name = str(data.get("name", ""))
	m.category = str(data.get("category", "any"))
	m.trigger_category = str(data.get("trigger_category", ""))
	m.trigger_value = str(data.get("trigger_value", ""))
	m.display_type = StringName(str(data.get("display_type", "toast")))
	m.flavor_text = str(data.get("flavor_text", ""))
	m.audio_cue_id = StringName(str(data.get("audio_cue_id", "")))
	m.scheduling_weight = float(data.get("scheduling_weight", 1.0))
	m.cooldown_days = int(data.get("cooldown_days", 1))
	m.store_id = str(data.get("store_id", ""))
	m.season_id = str(data.get("season_id", ""))
	m.min_day = int(data.get("min_day", 0))
	m.max_day = int(data.get("max_day", 0))
	m.duration_seconds = float(data.get("duration_seconds", 8.0))
	return m


static func _parse_float_array(data: Dictionary, key: String) -> Array[float]:
	if not data.has(key):
		return []
	var arr: Array[float] = []
	for val: Variant in data[key]:
		arr.append(float(val))
	return arr
