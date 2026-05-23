## Passive register-side hint for beats owned elsewhere in the store.
class_name RegisterStatusIndicator
extends BetaDayOneInteractableBase


func _ready() -> void:
	display_name = "register"
	prompt_text = ""
	action_verb = "Check"
	interactable_id = &"register_status_hint"
	# Raycast-only so this hint never steals focus from the active beat owner.
	proximity_radius = 0.0
	super._ready()


func can_interact(_actor: Node = null) -> bool:
	return false


func get_disabled_reason(_actor: Node = null) -> String:
	var controller: BetaDayOneController = _controller()
	if controller == null:
		return ""
	match controller.current_stage():
		BetaDayOneController.STAGE_BACK_ROOM_INVENTORY:
			return "Check the back room first."
		BetaDayOneController.STAGE_STOCK_SHELF:
			return "Stock the used games shelf before closing."
		_:
			return ""
