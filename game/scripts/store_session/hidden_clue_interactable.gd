class_name HiddenClueInteractable
extends StoreSessionInteractableBase


func _ready() -> void:
	# Grounded copy — the player decides whether the stack is interesting.
	# The UI never labels this "odd" / "strange" / "mysterious"; flavor
	# text inside the controller's interact handler does the work.
	display_name = "console stack"
	prompt_text = "Inspect"
	action_verb = "Inspect"
	interaction_type = InteractionType.ITEM
	interactable_id = &"store_session.hidden_clue"
	proximity_radius = 2.25
	proximity_facing_dot = 0.4
	super._ready()


func can_interact(_actor: Node = null) -> bool:
	var controller: StoreSessionController = _controller()
	if controller == null:
		return false
	return controller.can_interact_hidden_clue()


func get_disabled_reason(_actor: Node = null) -> String:
	var controller: StoreSessionController = _controller()
	if controller == null:
		return ""
	return controller.hidden_clue_disabled_reason()


func interact(by: Node = null) -> void:
	_interact_and_call_controller(by, &"on_store_hidden_clue_interacted")
