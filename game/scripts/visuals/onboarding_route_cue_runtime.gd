## Visual-only route cue owner for first-run store-session onboarding.
##
## Route guidance is intentionally expressed through authored store fixtures
## (manager station, door hardware, shelves, and stockroom dressing), not floor
## paint or semi-transparent helper quads. This root exists so the onboarding
## visual layer has one owner without emitting debug-like geometry.
class_name OnboardingRouteCueRuntime
extends RefCounted

const ROOT_NAME: StringName = &"OnboardingRouteCues"


static func apply(shell: Node3D) -> void:
	if shell == null:
		return
	var root: Node3D = shell.get_node_or_null(NodePath(ROOT_NAME)) as Node3D
	if root == null:
		root = Node3D.new()
		root.name = ROOT_NAME
		shell.add_child(root)
	for child: Node in root.get_children():
		child.free()
	root.set_meta("route_cue_role", "fixture_authored_route")
	root.set_meta("visual_only", true)
