extends GutTest


func test_register_workstation_is_interactable() -> void:
	var register: Node = load("res://scenes/props/register_workstation.tscn").instantiate()
	add_child_autofree(register)

	assert_true(register.has_method("get_interaction_prompt"))
	assert_true(register.has_method("interact"))
	assert_string_contains(register.get_interaction_prompt(), "Register Workstation")
	assert_string_contains(register.interact(), "No customer waiting")


func test_backroom_computer_is_interactable() -> void:
	var computer: Node = load("res://scenes/props/backroom_computer.tscn").instantiate()
	add_child_autofree(computer)

	assert_true(computer.has_method("get_interaction_prompt"))
	assert_true(computer.has_method("interact"))
	assert_eq(computer.get_interaction_prompt(), "Click View Backroom Computer")
	assert_string_contains(computer.interact(), "unavailable")


func test_register_screen_has_visible_support() -> void:
	var register: Node3D = load("res://scenes/props/register_workstation.tscn").instantiate()
	add_child_autofree(register)

	var base_mesh := register.get_node("BaseMesh") as MeshInstance3D
	var post_mesh := register.get_node("ScreenPostMesh") as MeshInstance3D
	var screen_mesh := register.get_node("ScreenMesh") as MeshInstance3D

	var base_top: float = base_mesh.position.y + (base_mesh.mesh.size.y / 2.0)
	var post_bottom: float = post_mesh.position.y - (post_mesh.mesh.size.y / 2.0)
	var post_top: float = post_mesh.position.y + (post_mesh.mesh.size.y / 2.0)
	var screen_bottom: float = screen_mesh.position.y - (screen_mesh.mesh.size.y / 2.0)

	assert_almost_eq(post_bottom, base_top, 0.01)
	assert_gte(post_top, screen_bottom - 0.03)


func test_register_completes_waiting_customer_sale() -> void:
	var rack: Node3D = load("res://scenes/props/placeholder_shelf.tscn").instantiate()
	var customer: SimpleBuyerCustomer = load("res://scenes/customers/simple_buyer_customer.tscn").instantiate()
	var register: RegisterWorkstation = load("res://scenes/props/register_workstation.tscn").instantiate()
	var ledger := TransactionLedger.new()
	var session: Node = load("res://scripts/systems/store_session.gd").new()
	var item: Node3D = load("res://scenes/props/placeholder_used_game.tscn").instantiate()
	add_child_autofree(rack)
	add_child_autofree(customer)
	add_child_autofree(register)
	add_child_autofree(ledger)
	add_child_autofree(session)

	var slot := rack.get_node("ShelfSlot001") as ShelfSlot
	assert_true(slot.place_item(item))
	assert_true(customer.claim_item_from_slot(slot))

	session.ledger_path = session.get_path_to(ledger)
	register.customer_path = register.get_path_to(customer)
	register.ledger_path = register.get_path_to(ledger)
	register.store_session_path = register.get_path_to(session)

	assert_eq(register.get_interaction_prompt(), "Click Ring Up Star Trader")

	var message := register.interact()
	assert_string_contains(message, "Sold Star Trader")
	assert_string_contains(message, "Profit $")
	assert_eq(ledger.get_sale_count(), 1)
	assert_eq(ledger.get_total_revenue_cents(), 2199)
	assert_eq(ledger.get_total_profit_cents(), 1299)
	assert_eq(session.get_cash_cents(), 52199)
	assert_eq(item.get("location_id"), "sold")
	assert_false(item.visible)
	assert_false(customer.is_waiting_for_register())


func test_register_completes_waiting_service_customer() -> void:
	var register: RegisterWorkstation = load("res://scenes/props/register_workstation.tscn").instantiate()
	var ledger := TransactionLedger.new()
	var session: StoreSession = load("res://scripts/systems/store_session.gd").new()
	var customer: Node = load("res://scenes/customers/simple_service_customer.tscn").instantiate()
	add_child_autofree(register)
	add_child_autofree(ledger)
	add_child_autofree(session)
	add_child_autofree(customer)

	session.ledger_path = session.get_path_to(ledger)
	register.service_customer_path = register.get_path_to(customer)
	register.ledger_path = register.get_path_to(ledger)
	register.store_session_path = register.get_path_to(session)

	assert_eq(register.get_interaction_prompt(), "Click Complete Disc Resurfacing")

	var message := register.interact()
	assert_string_contains(message, "Completed Disc Resurfacing")
	assert_string_contains(message, "Scratched Orbit Disc")
	assert_eq(ledger.get_service_count(), 1)
	assert_eq(session.get_service_count(), 1)
	assert_eq(session.get_total_service_revenue_cents(), 499)
	assert_eq(session.get_total_service_cost_cents(), 100)
	assert_eq(session.get_total_service_profit_cents(), 399)
	assert_eq(session.get_cash_cents(), 50499)
	assert_false(customer.call("is_waiting_for_service"))


func test_backroom_computer_opens_actor_summary_panel() -> void:
	var computer: Node = load("res://scenes/props/backroom_computer.tscn").instantiate()
	var session: Node = load("res://scripts/systems/store_session.gd").new()
	var actor := _SummaryActor.new()
	add_child_autofree(computer)
	add_child_autofree(session)
	add_child_autofree(actor)

	computer.store_session_path = computer.get_path_to(session)

	assert_eq(computer.interact_with_actor(actor), "")
	assert_eq(actor.opened_session, session)


func test_interactable_base_returns_prompt_and_inspect_text() -> void:
	var interactable: Node = load("res://scripts/interaction/interactable.gd").new()
	interactable.display_name = "Test Object"
	interactable.inspect_text = "Inspection result"
	add_child_autofree(interactable)

	assert_eq(interactable.get_interaction_prompt(), "Click Inspect Test Object")
	assert_eq(interactable.interact(), "Inspection result")


func test_interaction_prompt_show_and_hide() -> void:
	var prompt: Node = load("res://scenes/ui/interaction_prompt.tscn").instantiate()
	add_child_autofree(prompt)

	prompt.show_prompt("Click Inspect Test")
	assert_true(prompt.visible)
	assert_true(prompt.reticle.visible)
	assert_eq(prompt.label.text, "Click Inspect Test")

	prompt.hide_prompt()
	assert_false(prompt.visible)


func test_interaction_raycast_ignores_empty_interaction_messages() -> void:
	var script: Script = load("res://scripts/interaction/interaction_raycast.gd")
	var raycast: RayCast3D = script.new()
	var prompt: Node = load("res://scenes/ui/interaction_prompt.tscn").instantiate()
	var interactable := _SilentInteractable.new()
	add_child_autofree(raycast)
	add_child_autofree(prompt)
	add_child_autofree(interactable)

	raycast._prompt = prompt
	raycast._current_interactable = interactable

	var event := InputEventAction.new()
	event.action = "interact"
	event.pressed = true
	raycast._unhandled_input(event)

	assert_false(prompt.visible)


func test_interaction_raycast_uses_held_item_fallback_prompt() -> void:
	var script: Script = load("res://scripts/interaction/interaction_raycast.gd")
	var raycast: RayCast3D = script.new()
	var prompt: Node = load("res://scenes/ui/interaction_prompt.tscn").instantiate()
	var actor := _HeldItemActor.new()
	add_child_autofree(actor)
	actor.add_child(raycast)
	add_child_autofree(prompt)

	raycast._prompt = prompt
	raycast._physics_process(0.016)

	assert_true(prompt.visible)
	assert_true(prompt.reticle.visible)
	assert_eq(prompt.label.text, "Click Price Star Trader")

	var event := InputEventAction.new()
	event.action = "interact"
	event.pressed = true
	raycast._unhandled_input(event)

	assert_eq(actor.price_count, 1)

	var click_event := InputEventMouseButton.new()
	click_event.button_index = MOUSE_BUTTON_LEFT
	click_event.pressed = true
	raycast._unhandled_input(click_event)

	assert_eq(actor.price_count, 2)


class _SilentInteractable:
	extends Node

	func get_interaction_prompt() -> String:
		return "Click Silent"

	func interact() -> String:
		return ""


class _HeldItemActor:
	extends Node

	var price_count: int = 0

	func is_holding_item() -> bool:
		return true

	func get_held_item_interaction_prompt() -> String:
		return "Click Price Star Trader"

	func interact_with_held_item() -> String:
		price_count += 1
		return ""


class _SummaryActor:
	extends Node

	var opened_session: Node = null

	func open_day_summary(session: Node) -> String:
		opened_session = session
		return ""
