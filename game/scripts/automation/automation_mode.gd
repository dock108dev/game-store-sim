class_name AutomationMode
extends RefCounted


## Returns true only while an automation/test runner has explicitly armed
## deterministic runtime control.
static func is_enabled() -> bool:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var root: Window = tree.root
	if root == null:
		return false
	var runner: Node = root.get_node_or_null("AutomationRunner")
	if (
		runner != null
		and runner.has_method("should_take_over_boot")
		and bool(runner.call("should_take_over_boot"))
	):
		return true
	var random: Node = root.get_node_or_null("GameRandom")
	if (
		random != null
		and random.has_method("is_test_mode")
		and bool(random.call("is_test_mode"))
	):
		return true
	return false
