extends StaticBody3D
class_name SimplePreorderCustomer

const STATE_WAITING_FOR_PREORDER := "waiting_for_preorder"
const STATE_PREORDER_COMPLETE := "preorder_complete"

@export var customer_id: String = "preorder_customer_001"
@export var release: Resource
@export var deposit_cents: int = 500

var state: String = STATE_WAITING_FOR_PREORDER


func get_interaction_prompt() -> String:
	if state == STATE_PREORDER_COMPLETE:
		return "Preorder Complete"

	var release_name := get_release_name()
	if not release_name.is_empty():
		return "Preorder Customer: %s" % release_name

	return "Preorder Customer"


func interact() -> String:
	if state == STATE_PREORDER_COMPLETE:
		return "Preorder already recorded."

	if release == null:
		return "Customer has no preorder request."

	return "Wants to preorder %s for %s deposit." % [
		get_release_name(),
		_format_money(get_deposit_cents()),
	]


func is_waiting_for_preorder() -> bool:
	return state == STATE_WAITING_FOR_PREORDER and release != null


func get_release() -> Resource:
	return release


func get_release_name() -> String:
	if release == null:
		return ""

	return str(release.get("product_name"))


func get_deposit_cents() -> int:
	return maxi(1, deposit_cents)


func complete_preorder() -> bool:
	if not is_waiting_for_preorder():
		return false

	state = STATE_PREORDER_COMPLETE
	return true


func _format_money(cents: int) -> String:
	return "$%0.2f" % (cents / 100.0)
