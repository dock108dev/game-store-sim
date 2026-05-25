## Drives player-like movement, aim, focus, and interaction by semantic target.
class_name SemanticInputDriver
extends Node

signal target_focus_started(target_id: StringName)
signal target_focused(target_id: StringName, target: Interactable)
signal target_interacted(target_id: StringName, target: Interactable)
signal target_failed(target_id: StringName, reason: String)

const REGISTRY_SCRIPT: GDScript = preload("res://game/scripts/automation/semantic_target_registry.gd")
const DEFAULT_OPTIONS: Dictionary = {
	"timeout_sec": 2.0,
	"stand_distance": 1.6,
	"camera_height": 1.7,
	"aim_y_offset": 0.0,
	"require_can_interact": true,
	"allow_direct_hover_seam": false,
	"dispatch_input_action": true,
	"require_store_gameplay_focus": true,
}

var _registry: RefCounted = REGISTRY_SCRIPT.new()
var _last_error: String = ""
var _last_resolved: Dictionary = {}


## Resolves a target id or selector against the active scene tree.
func resolve_target(target: Variant) -> Dictionary:
	_last_error = ""
	var root: Node = _resolution_root()
	var resolved: Dictionary = _registry.resolve(target, root)
	if not bool(resolved.get("ok", false)):
		_last_error = str(resolved.get("reason", "target_not_found"))
		return resolved
	_last_resolved = _with_pose(resolved, _options({}))
	return _last_resolved.duplicate()


## Moves the store player body to the computed interaction stand position.
func move_to_target(target: Variant, options: Dictionary = {}) -> bool:
	var opts: Dictionary = _options(options)
	var resolved: Dictionary = _resolve_for_action(target, opts, false)
	if resolved.is_empty():
		return false
	var player: Node3D = _store_player()
	if player == null:
		return _fail(_target_id(target), "player_missing")
	var stand: Vector3 = resolved.get("stand_position", player.global_position) as Vector3
	player.global_position = stand
	player.set_physics_process(false)
	return true


## Rotates the store player and camera so the center ray points at the target.
func aim_at_target(target: Variant, options: Dictionary = {}) -> bool:
	var opts: Dictionary = _options(options)
	var resolved: Dictionary = _resolve_for_action(target, opts, false)
	if resolved.is_empty():
		return false
	var player: Node3D = _store_player()
	var camera: Camera3D = _store_camera(player)
	if player == null:
		return _fail(_target_id(target), "player_missing")
	if camera == null:
		return _fail(_target_id(target), "camera_missing")
	_apply_aim(player, camera, resolved.get("aim_position", Vector3.ZERO) as Vector3)
	return true


## Moves, aims, and waits until InteractionRay hovers the requested target.
func focus_target(target: Variant, options: Dictionary = {}) -> bool:
	var target_id: StringName = _target_id(target)
	target_focus_started.emit(target_id)
	var opts: Dictionary = _options(options)
	if not _store_gameplay_focus_allowed(opts):
		return _fail(target_id, "input_focus_blocked: current=%s" % String(InputFocus.current()))
	var resolved: Dictionary = _resolve_for_action(target, opts, true)
	if resolved.is_empty():
		return false
	var interactable: Interactable = resolved.get("interactable") as Interactable
	if interactable == null:
		return _fail(target_id, "target_not_interactable")
	var player: Node3D = _store_player()
	var camera: Camera3D = _store_camera(player)
	var ray: Node = _interaction_ray(player)
	if player == null:
		return _fail(target_id, "player_missing")
	if camera == null:
		return _fail(target_id, "camera_missing")
	if ray == null:
		return _fail(target_id, "interaction_ray_missing")
	if not move_to_target(target, opts):
		return false
	if not aim_at_target(target, opts):
		return false
	if player.has_method("set_current_interactable"):
		player.call("set_current_interactable", interactable)
	if bool(opts.get("allow_direct_hover_seam", false)) and ray.has_method("_set_hovered_target"):
		ray.call("_set_hovered_target", interactable)
		target_focused.emit(target_id, interactable)
		return true
	var deadline: int = Time.get_ticks_msec() + int(float(opts.get("timeout_sec")) * 1000.0)
	while Time.get_ticks_msec() <= deadline:
		await get_tree().physics_frame
		if ray.has_method("_update_raycast"):
			ray.call("_update_raycast")
		if ray.has_method("get_hovered_target") and ray.call("get_hovered_target") == interactable:
			target_focused.emit(target_id, interactable)
			return true
	return _fail(target_id, "focus_timeout: %s" % _ray_debug(ray))


## Focuses a semantic target and dispatches the existing interact input path.
func interact_target(target: Variant, options: Dictionary = {}) -> bool:
	var opts: Dictionary = _options(options)
	var target_id: StringName = _target_id(target)
	if not await focus_target(target, opts):
		return false
	var player: Node3D = _store_player()
	var ray: Node = _interaction_ray(player)
	var resolved: Dictionary = _last_resolved
	var interactable: Interactable = resolved.get("interactable") as Interactable
	if ray == null:
		return _fail(target_id, "interaction_ray_missing")
	if interactable == null:
		return _fail(target_id, "target_not_interactable")
	if ray.has_method("get_hovered_target") and ray.call("get_hovered_target") != interactable:
		return _fail(target_id, "hover_mismatch")
	if bool(opts.get("dispatch_input_action", true)):
		_dispatch_interact(ray)
	await get_tree().process_frame
	target_interacted.emit(target_id, interactable)
	return true


## Returns the most recent driver failure reason.
func get_last_error() -> String:
	return _last_error


## Returns the most recent resolved target snapshot.
func get_last_resolved() -> Dictionary:
	return _last_resolved.duplicate()


func _resolve_for_action(target: Variant, opts: Dictionary, require_enabled: bool) -> Dictionary:
	var root: Node = _resolution_root()
	var resolved: Dictionary = _registry.resolve(target, root)
	if not bool(resolved.get("ok", false)):
		_last_error = str(resolved.get("reason", "target_not_found"))
		target_failed.emit(_target_id(target), _last_error)
		return {}
	resolved = _with_pose(resolved, opts)
	_last_resolved = resolved.duplicate()
	var interactable: Interactable = resolved.get("interactable") as Interactable
	if require_enabled and bool(opts.get("require_can_interact", true)):
		if interactable == null:
			return {}
		if not interactable.enabled or not interactable.can_interact(_store_player()):
			var reason: String = interactable.get_disabled_reason(_store_player()).strip_edges()
			if reason.is_empty():
				reason = "no disabled reason"
			_fail(_target_id(target), "target_disabled: %s" % reason)
			return {}
	return resolved


func _with_pose(resolved: Dictionary, opts: Dictionary) -> Dictionary:
	var node: Node3D = resolved.get("node") as Node3D
	var interactable: Interactable = resolved.get("interactable") as Interactable
	if interactable != null and interactable.get_interaction_area() != null:
		node = interactable.get_interaction_area()
	if node == null:
		return resolved
	var aim: Vector3 = node.global_position
	aim.y += _aim_y_offset(resolved, opts)
	var player: Node3D = _store_player()
	var stand: Vector3 = aim
	if player != null:
		var flat_to_player := Vector3(
			player.global_position.x - aim.x,
			0.0,
			player.global_position.z - aim.z
		)
		if flat_to_player.length_squared() < 0.0001:
			var target_node: Node3D = resolved.get("node") as Node3D
			flat_to_player = target_node.global_transform.basis.z if target_node != null else Vector3.BACK
			flat_to_player.y = 0.0
		flat_to_player = flat_to_player.normalized()
		var distance: float = _stand_distance(opts)
		stand = aim + flat_to_player * distance
		stand.y = player.global_position.y
		if player is StorePlayerBody:
			var body := player as StorePlayerBody
			stand.x = clampf(stand.x, body.bounds_min.x, body.bounds_max.x)
			stand.z = clampf(stand.z, body.bounds_min.z, body.bounds_max.z)
	resolved["global_position"] = node.global_position
	resolved["aim_position"] = aim
	resolved["stand_position"] = stand
	resolved["ray_distance"] = _ray_distance()
	return resolved


func _apply_aim(player: Node3D, camera: Camera3D, aim_position: Vector3) -> void:
	var to_target: Vector3 = aim_position - camera.global_position
	var flat := Vector3(to_target.x, 0.0, to_target.z)
	if flat.length_squared() > 0.0001:
		player.rotation.y = atan2(-flat.x, -flat.z)
		player.force_update_transform()
	var horizontal_distance: float = maxf(0.001, flat.length())
	var pitch: float = atan2(to_target.y, horizontal_distance)
	camera.rotation.x = clampf(pitch, -StorePlayerBody.PITCH_LIMIT_RAD, StorePlayerBody.PITCH_LIMIT_RAD)
	camera.force_update_transform()


func _dispatch_interact(ray: Node) -> void:
	var event := InputEventAction.new()
	event.action = &"interact"
	event.pressed = true
	if ray.has_method("_unhandled_input"):
		ray.call("_unhandled_input", event)


func _options(options: Dictionary) -> Dictionary:
	var opts: Dictionary = DEFAULT_OPTIONS.duplicate(true)
	for key: Variant in options.keys():
		opts[key] = options[key]
	return opts


func _aim_y_offset(resolved: Dictionary, opts: Dictionary) -> float:
	if opts.has("aim_y_offset") and not is_zero_approx(float(opts.get("aim_y_offset"))):
		return float(opts.get("aim_y_offset"))
	var objective: Dictionary = {}
	if resolved.has("objective"):
		objective = resolved.get("objective", {}) as Dictionary
	if objective.has("highlight_y_offset"):
		return float(objective.get("highlight_y_offset"))
	match int(resolved.get("interaction_type", -1)):
		Interactable.InteractionType.CUSTOMER:
			return 1.4
		Interactable.InteractionType.REGISTER:
			return 0.7
		Interactable.InteractionType.SHELF_SLOT:
			return 1.0
		Interactable.InteractionType.BACKROOM:
			return 1.1
		_:
			return 0.8


func _stand_distance(opts: Dictionary) -> float:
	var requested: float = float(opts.get("stand_distance", DEFAULT_OPTIONS["stand_distance"]))
	var ray_limit: float = maxf(0.25, _ray_distance() - 0.25)
	return minf(requested, ray_limit)


func _ray_distance() -> float:
	var ray: Node = _interaction_ray(_store_player())
	if ray != null:
		var value: Variant = ray.get("ray_distance")
		if value != null:
			return float(value)
	return 2.5


func _resolution_root() -> Node:
	var tree: SceneTree = get_tree()
	if tree == null:
		return self
	var scene: Node = tree.current_scene
	if scene != null and _root_has_gameplay_targets(scene):
		return scene
	if get_parent() != null:
		return get_parent()
	if scene != null:
		return scene
	return tree.root


func _root_has_gameplay_targets(root: Node) -> bool:
	var tree: SceneTree = get_tree()
	if tree == null or root == null:
		return false
	for group: StringName in [&"player", &"interactable", &"store_session_controller"]:
		for node: Node in tree.get_nodes_in_group(group):
			if _is_descendant_or_same(node, root):
				return true
	return false


func _store_player() -> Node3D:
	var tree: SceneTree = get_tree()
	if tree == null:
		return null
	for node: Node in tree.get_nodes_in_group(&"player"):
		if node is Node3D:
			return node as Node3D
	var root: Node = _resolution_root()
	for name: String in ["Player", "PlayerController"]:
		var found: Node = root.find_child(name, true, false)
		if found is Node3D:
			return found as Node3D
	return null


func _store_camera(player: Node3D) -> Camera3D:
	if player != null:
		var child: Node = player.get_node_or_null("StoreCamera")
		if child is Camera3D:
			return child as Camera3D
	if CameraManager != null and CameraManager.active_camera is Camera3D:
		return CameraManager.active_camera
	return null


func _interaction_ray(player: Node3D) -> Node:
	var tree: SceneTree = get_tree()
	if tree != null:
		var grouped: Node = tree.get_first_node_in_group(&"interaction_ray")
		if grouped != null:
			return grouped
	if player != null:
		var ray: Node = player.find_child("InteractionRay", true, false)
		if ray != null:
			return ray
	return null


func _store_gameplay_focus_allowed(opts: Dictionary) -> bool:
	if not bool(opts.get("require_store_gameplay_focus", true)):
		return true
	return InputFocus.current() == InputFocus.CTX_STORE_GAMEPLAY


func _target_id(target: Variant) -> StringName:
	if target is Dictionary:
		return StringName(str((target as Dictionary).get("semantic_id", "")))
	return StringName(str(target))


func _ray_debug(ray: Node) -> String:
	if ray != null and ray.has_method("get_targeting_debug"):
		return str(ray.call("get_targeting_debug"))
	return "{}"


func _is_descendant_or_same(node: Node, ancestor: Node) -> bool:
	if node == ancestor:
		return true
	var current: Node = node
	while current != null:
		if current == ancestor:
			return true
		current = current.get_parent()
	return false


func _fail(target_id: StringName, reason: String) -> bool:
	_last_error = reason
	target_failed.emit(target_id, reason)
	return false
