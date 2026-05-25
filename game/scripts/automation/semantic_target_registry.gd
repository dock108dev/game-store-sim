## Resolves scenario target definitions to live scene nodes.
class_name SemanticTargetRegistry
extends RefCounted

const META_SEMANTIC_TARGET: StringName = &"semantic_target"
const META_TARGET_KIND: StringName = &"scenario_target_kind"
const FIELD_SEMANTIC_ID: String = "semantic_id"
const FIELD_KIND: String = "kind"
const FIELD_INTERACTABLE_ID: String = "interactable_id"
const FIELD_GROUPS: String = "groups"
const FIELD_FALLBACK_OBJECTIVE_IDS: String = "fallback_objective_ids"
const FIELD_FALLBACK_NAMES: String = "fallback_names"
const FIELD_FALLBACK_PATHS: String = "fallback_paths"

const CANONICAL_TARGETS: Dictionary = {
	&"player": {
		FIELD_KIND: "actor",
		FIELD_GROUPS: ["player"],
		FIELD_FALLBACK_PATHS: ["PlayerController", "Player"],
	},
	&"player.entry_spawn": {
		FIELD_KIND: "spawn",
		FIELD_GROUPS: ["spawn.player"],
		FIELD_FALLBACK_PATHS: ["PlayerEntrySpawn"],
	},
	&"shelf.starter_display": {
		FIELD_KIND: "interactable",
		FIELD_INTERACTABLE_ID: "shelf.starter_display",
		FIELD_GROUPS: ["interactable", "interactables"],
		FIELD_FALLBACK_OBJECTIVE_IDS: ["training_stock_shelf", "stock_shelf"],
		FIELD_FALLBACK_PATHS: ["StoreSessionRestockShelf/Interactable"],
	},
	&"shelf.slot.001": {
		FIELD_KIND: "shelf_slot",
		FIELD_INTERACTABLE_ID: "shelf.slot.001",
		FIELD_GROUPS: ["interactable", "interactables", "shelf_slot"],
		FIELD_FALLBACK_NAMES: ["Shelf_001"],
	},
	&"shelf.slot.002": {
		FIELD_KIND: "shelf_slot",
		FIELD_INTERACTABLE_ID: "shelf.slot.002",
		FIELD_GROUPS: ["interactable", "interactables", "shelf_slot"],
		FIELD_FALLBACK_NAMES: ["Shelf_002"],
	},
	&"shelf.slot.003": {
		FIELD_KIND: "shelf_slot",
		FIELD_INTERACTABLE_ID: "shelf.slot.003",
		FIELD_GROUPS: ["interactable", "interactables", "shelf_slot"],
		FIELD_FALLBACK_NAMES: ["Shelf_003"],
	},
	&"register.main": {
		FIELD_KIND: "interactable",
		FIELD_INTERACTABLE_ID: "register.main",
		FIELD_GROUPS: ["interactable", "interactables"],
		FIELD_FALLBACK_OBJECTIVE_IDS: ["check_register", "close_day"],
		FIELD_FALLBACK_PATHS: ["StoreSessionDayEndTrigger/Interactable"],
	},
	&"register.counter_area": {
		FIELD_KIND: "area",
		FIELD_GROUPS: ["area.register", "register_area"],
		FIELD_FALLBACK_PATHS: ["RegisterArea"],
	},
	&"tutorial.panel": {
		FIELD_KIND: "ui_panel",
		FIELD_GROUPS: ["ui.panel", "ui.tutorial_panel"],
		FIELD_FALLBACK_NAMES: ["TutorialPanel"],
	},
	&"store_session.controller": {
		FIELD_KIND: "controller",
		FIELD_GROUPS: ["store_session.controller", "store_session_controller"],
		FIELD_FALLBACK_PATHS: ["StoreSessionController"],
	},
	&"store_session.panel.customer_result": {
		FIELD_KIND: "ui_panel",
		FIELD_GROUPS: ["ui.panel", "store_session.panel", "store_session.panel.customer_result"],
	},
	&"store_session.panel.close_day_confirmation": {
		FIELD_KIND: "ui_panel",
		FIELD_GROUPS: ["ui.panel", "store_session.panel", "store_session.panel.close_day_confirmation"],
	},
	&"store_session.panel.debug_overlay": {
		FIELD_KIND: "ui_panel",
		FIELD_GROUPS: ["ui.panel", "store_session.panel", "store_session.panel.debug_overlay"],
	},
	&"store_session.backroom_pickup": {
		FIELD_KIND: "interactable",
		FIELD_INTERACTABLE_ID: "store_session.backroom_pickup",
		FIELD_GROUPS: ["interactable", "interactables"],
		FIELD_FALLBACK_OBJECTIVE_IDS: ["check_back_room_inventory", "back_room_inventory"],
		FIELD_FALLBACK_PATHS: ["StoreSessionBackroomPickup/Interactable"],
	},
	&"store_session.day_one_customer": {
		FIELD_KIND: "interactable_actor",
		FIELD_INTERACTABLE_ID: "store_session.day_one_customer",
		FIELD_GROUPS: ["interactable", "interactables"],
		FIELD_FALLBACK_OBJECTIVE_IDS: ["talk_to_manager", "talk_to_customer"],
		FIELD_FALLBACK_PATHS: ["StoreSessionDayOneCustomer/Interactable"],
	},
	&"store_session.day_end": {
		FIELD_KIND: "interactable",
		FIELD_INTERACTABLE_ID: "store_session.day_end",
		FIELD_GROUPS: ["interactable", "interactables"],
		FIELD_FALLBACK_OBJECTIVE_IDS: ["check_register", "close_day"],
		FIELD_FALLBACK_PATHS: ["StoreSessionDayEndTrigger/Interactable"],
	},
	&"store_session.hidden_clue": {
		FIELD_KIND: "interactable",
		FIELD_INTERACTABLE_ID: "store_session.hidden_clue",
		FIELD_GROUPS: ["interactable", "interactables"],
		FIELD_FALLBACK_PATHS: ["StoreSessionHiddenClue/Interactable", "StoreSessionHiddenClue"],
	},
}

var _last_error: String = ""


## Resolves a target id, selector dictionary, node path, or node name against `root`.
func resolve(target: Variant, root: Node) -> Dictionary:
	_last_error = ""
	if root == null or not is_instance_valid(root):
		return _error("root_missing", target, [])
	var selector: Dictionary = _selector_from_target(target)
	if selector.is_empty():
		return _error("target_selector_invalid", target, [])
	for candidates: Array[Dictionary] in [
		_candidates_by_semantic(selector, root),
		_candidates_by_interactable_id(selector, root),
		_candidates_by_objectives(selector, root),
		_candidates_by_groups(selector, root),
		_candidates_by_names(selector, root),
		_candidates_by_paths(selector, root),
	]:
		if candidates.is_empty():
			continue
		var resolved: Dictionary = _resolve_candidates(selector, candidates, target)
		if bool(resolved.get("ok", false)):
			return resolved
		if not str(resolved.get("reason", "")).begins_with("target_not_found"):
			return resolved
	return _error("target_not_found", target, [])


## Returns the most recent resolution failure.
func get_last_error() -> String:
	return _last_error


## Returns canonical target ids available before live scene lookup.
func canonical_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	for id: StringName in CANONICAL_TARGETS.keys():
		ids.append(String(id))
	ids.sort()
	return ids


static func normalize(value: Variant) -> String:
	var text: String = str(value).strip_edges().to_lower()
	for token: String in [" ", "-", "/", "\\"]:
		text = text.replace(token, "_")
	while text.contains("__"):
		text = text.replace("__", "_")
	return text.trim_prefix("_").trim_suffix("_")


func _selector_from_target(target: Variant) -> Dictionary:
	var selector: Dictionary = {}
	if target is Dictionary:
		selector = (target as Dictionary).duplicate(true)
	else:
		selector[FIELD_SEMANTIC_ID] = String(target)
	var semantic_id := StringName(str(selector.get(FIELD_SEMANTIC_ID, "")))
	if CANONICAL_TARGETS.has(semantic_id):
		var merged: Dictionary = (CANONICAL_TARGETS[semantic_id] as Dictionary).duplicate(true)
		_merge_selector_arrays(merged, selector)
		for key: Variant in selector.keys():
			if not _is_array_field(str(key)):
				merged[key] = selector[key]
		merged[FIELD_SEMANTIC_ID] = String(semantic_id)
		return merged
	if semantic_id != &"" and not selector.has(FIELD_INTERACTABLE_ID):
		selector[FIELD_INTERACTABLE_ID] = String(semantic_id)
	return selector


func _merge_selector_arrays(base: Dictionary, overlay: Dictionary) -> void:
	for field: String in [
		FIELD_GROUPS, FIELD_FALLBACK_OBJECTIVE_IDS, FIELD_FALLBACK_NAMES, FIELD_FALLBACK_PATHS
	]:
		var values: Array = []
		for value: Variant in base.get(field, []):
			if not values.has(value):
				values.append(value)
		for value: Variant in overlay.get(field, []):
			if not values.has(value):
				values.append(value)
		if not values.is_empty():
			base[field] = values


func _is_array_field(field: String) -> bool:
	return [
		FIELD_GROUPS,
		FIELD_FALLBACK_OBJECTIVE_IDS,
		FIELD_FALLBACK_NAMES,
		FIELD_FALLBACK_PATHS,
	].has(field)


func _candidates_by_semantic(selector: Dictionary, root: Node) -> Array[Dictionary]:
	var semantic_id: String = str(selector.get(FIELD_SEMANTIC_ID, "")).strip_edges()
	if semantic_id.is_empty():
		return []
	var candidates: Array[Dictionary] = []
	for node: Node in _walk(root):
		if node.has_meta(String(META_SEMANTIC_TARGET)) \
				and str(node.get_meta(String(META_SEMANTIC_TARGET))) == semantic_id:
			candidates.append(_candidate(node, &"semantic_id", semantic_id))
	return candidates


func _candidates_by_interactable_id(selector: Dictionary, root: Node) -> Array[Dictionary]:
	var target_id: String = str(selector.get(FIELD_INTERACTABLE_ID, "")).strip_edges()
	if target_id.is_empty():
		return []
	var candidates: Array[Dictionary] = []
	for node: Node in _interactable_nodes(root):
		var interactable := node as Interactable
		if String(interactable.resolve_interactable_id()) == target_id:
			candidates.append(_candidate(interactable, &"interactable_id", target_id))
	return candidates


func _candidates_by_objectives(selector: Dictionary, root: Node) -> Array[Dictionary]:
	var ids: Array = []
	for key: String in [
		FIELD_SEMANTIC_ID,
		"objective_id",
		"objective_stage",
		FIELD_FALLBACK_OBJECTIVE_IDS,
	]:
		var value: Variant = selector.get(key)
		if value is Array:
			ids.append_array(value as Array)
		elif value != null and not str(value).is_empty():
			ids.append(value)
	if ids.is_empty():
		return []
	var candidates: Array[Dictionary] = []
	for controller: Node in _store_session_controllers(root):
		if not controller.has_method("get_semantic_objective_targets"):
			continue
		var entries: Array = controller.call("get_semantic_objective_targets") as Array
		for entry_value: Variant in entries:
			if not (entry_value is Dictionary):
				continue
			var entry: Dictionary = entry_value as Dictionary
			if not _objective_matches(entry, ids):
				continue
			var node: Node = _resolve_objective_path(controller, str(entry.get("target_path", "")))
			if node == null:
				continue
			candidates.append(_candidate(node, &"objective", str(entry.get("id", "")), entry))
	return candidates


func _candidates_by_groups(selector: Dictionary, root: Node) -> Array[Dictionary]:
	var groups: Array = selector.get(FIELD_GROUPS, []) as Array
	var candidates: Array[Dictionary] = []
	for group_value: Variant in groups:
		var group: StringName = StringName(str(group_value))
		for node: Node in root.get_tree().get_nodes_in_group(group):
			if _is_descendant_or_same(node, root):
				candidates.append(_candidate(node, &"group", String(group)))
	return candidates


func _candidates_by_names(selector: Dictionary, root: Node) -> Array[Dictionary]:
	var names: Array = selector.get(FIELD_FALLBACK_NAMES, []) as Array
	var semantic_id: String = str(selector.get(FIELD_SEMANTIC_ID, "")).strip_edges()
	if not semantic_id.is_empty():
		names.append(semantic_id)
	var candidates: Array[Dictionary] = []
	for node: Node in _walk(root):
		for name_value: Variant in names:
			if normalize(node.name) == normalize(name_value):
				candidates.append(_candidate(node, &"name", str(name_value)))
				break
		if node is Interactable:
			var interactable := node as Interactable
			var aliases: Array[String] = [
				normalize(interactable.display_name),
				normalize("%s %s" % [interactable.action_verb, interactable.display_name]),
			]
			for name_value: Variant in names:
				if aliases.has(normalize(name_value)):
					candidates.append(_candidate(interactable, &"name", str(name_value)))
					break
	return candidates


func _candidates_by_paths(selector: Dictionary, root: Node) -> Array[Dictionary]:
	var paths: Array = selector.get(FIELD_FALLBACK_PATHS, []) as Array
	var candidates: Array[Dictionary] = []
	for path_value: Variant in paths:
		var node: Node = _resolve_node_path(root, str(path_value))
		if node != null:
			candidates.append(_candidate(node, &"path", str(path_value)))
	return candidates


func _resolve_candidates(
	selector: Dictionary, candidates: Array[Dictionary], target: Variant
) -> Dictionary:
	var unique: Array[Dictionary] = []
	var seen: Dictionary = {}
	for entry: Dictionary in candidates:
		var node: Node = entry.get("node") as Node
		if node == null or not is_instance_valid(node):
			continue
		if not _matches_kind(node, str(selector.get(FIELD_KIND, ""))):
			continue
		var key: String = str(node.get_instance_id())
		if seen.has(key):
			continue
		seen[key] = true
		unique.append(entry)
	if unique.is_empty():
		return _error("target_not_found", target, [])
	if unique.size() > 1:
		return _error("ambiguous_target", target, unique)
	return _resolved(unique[0], selector)


func _resolved(entry: Dictionary, selector: Dictionary) -> Dictionary:
	var node: Node = entry.get("node") as Node
	var interactable: Interactable = node as Interactable
	if interactable == null:
		interactable = Interactable.from_collider(node)
	var result: Dictionary = {
		"ok": true,
		"id": StringName(str(selector.get(FIELD_SEMANTIC_ID, entry.get("match", "")))),
		"source": entry.get("source", &""),
		"match": str(entry.get("match", "")),
		"node": node,
		"interactable": interactable,
		"scene_path": node.get_path(),
		"display_name": "",
		"action_verb": "",
		"interaction_type": -1,
		"can_interact": true,
		"disabled_reason": "",
	}
	if entry.has("objective"):
		var objective: Dictionary = entry.get("objective", {}) as Dictionary
		result["objective"] = objective
		result["objective_id"] = StringName(str(objective.get("id", "")))
		result["objective_stage"] = StringName(str(objective.get("stage", "")))
		result["display_name"] = str(objective.get("prompt_display_name", ""))
		result["action_verb"] = str(objective.get("action_verb", ""))
	if interactable != null:
		result["interactable"] = interactable
		result["interaction_area"] = interactable.get_interaction_area()
		result["display_name"] = str(result.get("display_name", interactable.display_name))
		if str(result["display_name"]).is_empty():
			result["display_name"] = interactable.display_name
		result["action_verb"] = str(result.get("action_verb", interactable.action_verb))
		if str(result["action_verb"]).is_empty():
			result["action_verb"] = interactable.action_verb
		result["interaction_type"] = interactable.interaction_type
		result["can_interact"] = interactable.enabled and interactable.can_interact()
		result["disabled_reason"] = interactable.get_disabled_reason()
	return result


func _candidate(
	node: Node,
	source: StringName,
	match_value: String,
	objective: Dictionary = {}
) -> Dictionary:
	return {
		"node": node,
		"source": source,
		"match": match_value,
		"objective": objective,
	}


func _error(reason: String, target: Variant, candidates: Array[Dictionary]) -> Dictionary:
	var candidate_paths: Array[String] = []
	for entry: Dictionary in candidates:
		var node: Node = entry.get("node") as Node
		if node != null and is_instance_valid(node):
			candidate_paths.append(str(node.get_path()))
	_last_error = "%s: %s" % [reason, str(target)]
	if not candidate_paths.is_empty():
		_last_error += " matched %s" % str(candidate_paths)
	return {
		"ok": false,
		"reason": _last_error,
		"candidates": candidate_paths,
		"available_ids": Array(canonical_ids()),
	}


func _objective_matches(entry: Dictionary, ids: Array) -> bool:
	var objective_id: String = str(entry.get("id", ""))
	var objective_stage: String = str(entry.get("stage", ""))
	for id_value: Variant in ids:
		var expected: String = str(id_value)
		if expected == objective_id or expected == objective_stage:
			return true
	return false


func _resolve_objective_path(controller: Node, target_path: String) -> Node:
	if target_path.is_empty():
		return null
	var parent: Node = controller.get_parent()
	if parent != null:
		var parent_target: Node = parent.get_node_or_null(NodePath(target_path))
		if parent_target != null:
			return parent_target
	return controller.get_node_or_null(NodePath(target_path))


func _resolve_node_path(root: Node, path: String) -> Node:
	if path.is_empty():
		return null
	if path.begins_with("/root/"):
		return root.get_tree().root.get_node_or_null(NodePath(path.trim_prefix("/root/")))
	var from_root: Node = root.get_node_or_null(NodePath(path))
	if from_root != null:
		return from_root
	if root.get_tree().current_scene != null:
		return root.get_tree().current_scene.get_node_or_null(NodePath(path))
	return null


func _interactable_nodes(root: Node) -> Array[Node]:
	var nodes: Array[Node] = []
	for node: Node in root.get_tree().get_nodes_in_group(&"interactable"):
		if node is Interactable and _is_descendant_or_same(node, root):
			nodes.append(node)
	if nodes.is_empty():
		for node: Node in _walk(root):
			if node is Interactable:
				nodes.append(node)
	return nodes


func _store_session_controllers(root: Node) -> Array[Node]:
	var nodes: Array[Node] = []
	for node: Node in root.get_tree().get_nodes_in_group(&"store_session_controller"):
		if _is_descendant_or_same(node, root) or _is_descendant_or_same(root, node):
			nodes.append(node)
	for node: Node in _walk(root):
		if node.has_method("get_semantic_objective_targets") and not nodes.has(node):
			nodes.append(node)
	return nodes


func _walk(root: Node) -> Array[Node]:
	var nodes: Array[Node] = [root]
	var index: int = 0
	while index < nodes.size():
		for child: Node in nodes[index].get_children():
			nodes.append(child)
		index += 1
	return nodes


func _matches_kind(node: Node, kind: String) -> bool:
	if kind.is_empty():
		return true
	if kind in ["interactable", "interactable_actor", "shelf_slot"]:
		return Interactable.from_collider(node) != null
	if kind == "actor" or kind == "spawn" or kind == "area":
		return node is Node3D
	if kind == "ui_panel" or kind == "utility_panel":
		return node is CanvasLayer or node is Control
	return true


func _is_descendant_or_same(node: Node, ancestor: Node) -> bool:
	if node == ancestor:
		return true
	var current: Node = node
	while current != null:
		if current == ancestor:
			return true
		current = current.get_parent()
	return false
