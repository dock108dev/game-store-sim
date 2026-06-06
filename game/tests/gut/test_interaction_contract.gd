extends GutTest


func test_register_workstation_is_interactable() -> void:
	var register: Node = load("res://scenes/props/register_workstation.tscn").instantiate()
	add_child_autofree(register)

	assert_true(register.has_method("get_interaction_prompt"))
	assert_true(register.has_method("interact"))
	assert_string_contains(register.get_interaction_prompt(), "Register Workstation")
	assert_string_contains(register.interact(), "Register placeholder")


func test_interactable_base_returns_prompt_and_inspect_text() -> void:
	var interactable: Node = load("res://scripts/interaction/interactable.gd").new()
	interactable.display_name = "Test Object"
	interactable.inspect_text = "Inspection result"
	add_child_autofree(interactable)

	assert_eq(interactable.get_interaction_prompt(), "E Inspect Test Object")
	assert_eq(interactable.interact(), "Inspection result")


func test_interaction_prompt_show_and_hide() -> void:
	var prompt: Node = load("res://scenes/ui/interaction_prompt.tscn").instantiate()
	add_child_autofree(prompt)

	prompt.show_prompt("E Inspect Test")
	assert_true(prompt.visible)
	assert_eq(prompt.label.text, "E Inspect Test")

	prompt.hide_prompt()
	assert_false(prompt.visible)
