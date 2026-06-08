extends RayCast3D

@export var prompt_path: NodePath

var _current_interactable: Node = null
var _prompt: Node = null
var _using_actor_fallback: bool = false


func _ready() -> void:
	_prompt = get_node_or_null(prompt_path)


func _physics_process(_delta: float) -> void:
	force_raycast_update()

	var collider := get_collider()
	if collider != null and collider.has_method("get_interaction_prompt"):
		_set_current_interactable(collider)
		_using_actor_fallback = false
		if _prompt != null and _prompt.has_method("show_prompt"):
			_prompt.show_prompt(_get_prompt_text(collider))
		return

	_set_current_interactable(null)
	if _show_actor_fallback_prompt():
		return

	if _prompt != null and _prompt.has_method("hide_prompt"):
		_prompt.hide_prompt()


func _unhandled_input(event: InputEvent) -> void:
	if not _is_primary_interaction_pressed(event):
		return

	var result := ""
	if _using_actor_fallback:
		var actor := _get_actor()
		if actor != null and actor.has_method("interact_with_held_item"):
			result = str(actor.interact_with_held_item())
	elif _current_interactable == null:
		return
	elif _current_interactable.has_method("interact_with_actor"):
		result = str(_current_interactable.interact_with_actor(_get_actor()))
	elif _current_interactable.has_method("interact"):
		result = str(_current_interactable.interact())

	if not result.is_empty() and _prompt != null and _prompt.has_method("show_message"):
		_prompt.show_message(result)


func _is_primary_interaction_pressed(event: InputEvent) -> bool:
	if event.is_action_pressed("interact"):
		return true

	var mouse_event := event as InputEventMouseButton
	return mouse_event != null \
		and mouse_event.pressed \
		and mouse_event.button_index == MOUSE_BUTTON_LEFT


func _get_prompt_text(interactable: Node) -> String:
	if interactable.has_method("get_interaction_prompt_for_actor"):
		return str(interactable.get_interaction_prompt_for_actor(_get_actor()))

	return str(interactable.get_interaction_prompt())


func _get_actor() -> Node:
	var node: Node = self
	while node != null:
		if node.has_method("is_holding_item"):
			return node
		node = node.get_parent()

	return null


func _set_current_interactable(interactable: Node) -> void:
	if _current_interactable == interactable:
		return

	_set_hovered(_current_interactable, false)
	_current_interactable = interactable
	_set_hovered(_current_interactable, true)


func _set_hovered(interactable: Node, is_hovered: bool) -> void:
	if interactable != null and interactable.has_method("set_hovered"):
		interactable.set_hovered(is_hovered)


func _show_actor_fallback_prompt() -> bool:
	_using_actor_fallback = false

	var actor := _get_actor()
	if actor == null or not actor.has_method("get_held_item_interaction_prompt"):
		return false

	var prompt_text := str(actor.get_held_item_interaction_prompt())
	if prompt_text.is_empty():
		return false

	_using_actor_fallback = true
	if _prompt != null and _prompt.has_method("show_prompt"):
		_prompt.show_prompt(prompt_text)

	return true
