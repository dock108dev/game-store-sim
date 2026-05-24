class_name FirstDayCustomerInteractable
extends StoreSessionInteractableBase


func _ready() -> void:
	display_name = "customer"
	prompt_text = "Talk to"
	action_verb = "Talk"
	interaction_type = InteractionType.CUSTOMER
	interactable_id = &"customer_wrong_console_parent"
	# Store session day-1 has exactly one customer at a known location, so the
	# precision-raycast model is overkill. Opt into the proximity+facing
	# fallback (interaction_ray.gd::_find_best_proximity_target) with a
	# generous 2.75 m reach and a wide ~70° facing cone so the prompt
	# fires at normal conversational distance without pixel hunting.
	proximity_radius = 3.4
	proximity_facing_dot = 0.22
	super._ready()


func can_interact(_actor: Node = null) -> bool:
	var controller: StoreSessionController = _controller()
	if controller == null:
		return false
	return controller.can_interact_customer()


func get_disabled_reason(_actor: Node = null) -> String:
	var controller: StoreSessionController = _controller()
	if controller == null:
		return "Customer flow unavailable."
	return controller.customer_disabled_reason()


func interact(by: Node = null) -> void:
	if not can_interact(by):
		return
	super.interact(by)
	EventBus.customer_interacted.emit(self)
	get_tree().call_group("store_session_controller", "on_store_customer_interacted")
