class_name StoreMerchandisingLabels
extends RefCounted

const CONFIG_PATH: String = "res://game/content/stores/retro_games.json"
const STORE_DEFINITIONS_PATH: String = "res://game/content/stores/store_definitions.json"


## Resolves a store merchandising label from store/content data.
static func resolve(context: Dictionary, config_override: Dictionary = {}) -> Dictionary:
	var config: Dictionary = _config(config_override)
	var labels: Array = config.get("merchandising_labels", []) as Array
	var best: Dictionary = {}
	var best_score: int = -1
	for label_variant: Variant in labels:
		if label_variant is not Dictionary:
			continue
		var label: Dictionary = label_variant as Dictionary
		if not _matches_context(label, context):
			continue
		if not _availability_matches(label, context, config):
			continue
		var score: int = _score(label, context)
		if score > best_score:
			best = label
			best_score = score
	if best.is_empty():
		return {}
	var resolved: Dictionary = best.duplicate(true)
	resolved["source"] = "store_config.merchandising_labels"
	return resolved


## Returns every configured merchandising label for a store id.
static func labels_for_store(
	store_id: StringName, config_override: Dictionary = {}
) -> Array[Dictionary]:
	var config: Dictionary = _config(config_override)
	var result: Array[Dictionary] = []
	for label_variant: Variant in config.get("merchandising_labels", []) as Array:
		if label_variant is not Dictionary:
			continue
		var label: Dictionary = label_variant as Dictionary
		if StringName(str(label.get("store_id", ""))) != store_id:
			continue
		var resolved: Dictionary = label.duplicate(true)
		resolved["source"] = "store_config.merchandising_labels"
		result.append(resolved)
	return result


static func display_text(label: Dictionary) -> String:
	return str(label.get("display_text", "")).strip_edges()


static func _config(config_override: Dictionary) -> Dictionary:
	if not config_override.is_empty():
		return config_override
	if GameManager.data_loader != null:
		var loaded: Dictionary = GameManager.data_loader.get_retro_games_config()
		if not loaded.is_empty():
			return loaded
	var data: Variant = DataLoader.load_json(CONFIG_PATH)
	if data is Dictionary:
		return data as Dictionary
	return {}


static func _matches_context(label: Dictionary, context: Dictionary) -> bool:
	if StringName(str(label.get("store_id", ""))) != StringName(str(context.get("store_id", ""))):
		return false
	var phase: String = str(context.get("phase", "any"))
	var label_phase: String = str(label.get("phase", "any"))
	if label_phase != "any" and phase != label_phase:
		return false
	for key: String in ["surface", "role", "fixture_id", "service_id", "collection_id"]:
		var requested: String = str(context.get(key, ""))
		var configured: String = str(label.get(key, ""))
		if not requested.is_empty() and not configured.is_empty() and requested != configured:
			return false
	var category_id: String = str(context.get("category_id", ""))
	if not category_id.is_empty():
		var categories: Array = label.get("category_ids", []) as Array
		if not categories.has(category_id):
			return false
	return true


static func _availability_matches(
	label: Dictionary, _context: Dictionary, config: Dictionary
) -> bool:
	var rule: Dictionary = label.get("availability_rule", {}) as Dictionary
	if rule.is_empty():
		return true
	var store: Dictionary = _store_definition(StringName(str(label.get("store_id", ""))))
	if rule.has("requires_allowed_category"):
		var category: String = str(rule.get("requires_allowed_category", ""))
		if not (store.get("allowed_categories", []) as Array).has(category):
			return false
	if str(rule.get("requires_any_inventory_from", "")) == "store.starting_inventory":
		if (store.get("starting_inventory", []) as Array).is_empty():
			return false
	if rule.has("requires_store_mechanic_any"):
		var mechanics: Array = store.get("unique_mechanics", []) as Array
		var found: bool = false
		for mechanic: Variant in rule.get("requires_store_mechanic_any", []) as Array:
			if mechanics.has(str(mechanic)):
				found = true
				break
		if not found:
			return false
	if str(rule.get("requires_system", "")) == "holds":
		if int(config.get("max_hold_slots", 0)) <= 0:
			return false
	if rule.has("requires_collection"):
		var collection_id: String = str(rule.get("requires_collection", ""))
		if not _has_collection(config, collection_id):
			return false
	return true


static func _store_definition(store_id: StringName) -> Dictionary:
	if ContentRegistry.exists(String(store_id)):
		var registry_entry: Dictionary = ContentRegistry.get_entry(store_id)
		if not registry_entry.is_empty():
			return registry_entry
	var data: Variant = DataLoader.load_json(STORE_DEFINITIONS_PATH)
	if data is not Dictionary:
		return {}
	for entry_variant: Variant in (data as Dictionary).get("entries", []) as Array:
		if entry_variant is not Dictionary:
			continue
		var entry: Dictionary = entry_variant as Dictionary
		if StringName(str(entry.get("id", ""))) == store_id:
			return entry
	return {}


static func _has_collection(config: Dictionary, collection_id: String) -> bool:
	for entry_variant: Variant in config.get("merchandising_collections", []) as Array:
		if entry_variant is not Dictionary:
			continue
		if str((entry_variant as Dictionary).get("collection_id", "")) == collection_id:
			return true
	return false


static func _score(label: Dictionary, context: Dictionary) -> int:
	var score: int = int(label.get("priority", 0))
	for key: String in ["surface", "role", "fixture_id", "service_id", "collection_id"]:
		if str(label.get(key, "")) == str(context.get(key, "")):
			score += 10
	if str(label.get("phase", "")) == str(context.get("phase", "")):
		score += 5
	if (label.get("category_ids", []) as Array).has(str(context.get("category_id", ""))):
		score += 10
	return score
