## Verifies that retro_games.tscn ships debug-only geometry hidden by default
## so a missed _ready() / NavZoneInteractable._apply_debug_visibility() call
## cannot leak debug visuals into normal gameplay.
extends GutTest

const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"
const SHOW_DEBUG_MESHES_SETTING: String = "mallcore/debug/show_nav_zone_meshes"
const SCREENSHOT_MODE_SETTING: String = "mallcore/test/screenshot_mode"

var _prior_show_debug_meshes: Variant
var _prior_screenshot_mode: Variant


func before_each() -> void:
	_prior_show_debug_meshes = ProjectSettings.get_setting(
		SHOW_DEBUG_MESHES_SETTING, false
	)
	_prior_screenshot_mode = ProjectSettings.get_setting(
		SCREENSHOT_MODE_SETTING, false
	)
	ProjectSettings.set_setting(SHOW_DEBUG_MESHES_SETTING, false)
	ProjectSettings.set_setting(SCREENSHOT_MODE_SETTING, false)


func after_each() -> void:
	ProjectSettings.set_setting(
		SHOW_DEBUG_MESHES_SETTING, _prior_show_debug_meshes
	)
	ProjectSettings.set_setting(SCREENSHOT_MODE_SETTING, _prior_screenshot_mode)


func _instantiate_without_tree() -> Node3D:
	var scene: PackedScene = load(SCENE_PATH)
	assert_not_null(scene, "Retro Games scene must load")
	if scene == null:
		return null
	# instantiate() builds the node tree but does NOT add it to the SceneTree,
	# so @onready vars and _ready() have not yet executed and visibility values
	# reflect what is saved in the .tscn file.
	return scene.instantiate() as Node3D


func test_no_billboard_debug_labels_in_scene() -> void:
	var root: Node3D = _instantiate_without_tree()
	if root == null:
		return
	assert_null(
		root.get_node_or_null("DebugLabels"),
		"DebugLabels Node3D must not exist — giant floating world labels are removed"
	)
	root.free()


func test_slot_placeholder_meshes_visible_false_in_scene() -> void:
	var root: Node3D = _instantiate_without_tree()
	if root == null:
		return
	var meshes: Array[MeshInstance3D] = []
	_collect_named(root, "PlaceholderMesh", meshes)
	assert_gt(meshes.size(), 0, "Scene must contain PlaceholderMesh slot markers")
	for mesh: MeshInstance3D in meshes:
		assert_false(
			mesh.visible,
			"%s must default to visible=false; placement mode opts in" % mesh.name
		)
	root.free()


func test_nav_zone_debug_meshes_visible_false_in_scene() -> void:
	var root: Node3D = _instantiate_without_tree()
	if root == null:
		return
	var nav_zones: Node = root.get_node_or_null("NavZones")
	assert_not_null(nav_zones, "NavZones container must exist")
	if nav_zones == null:
		root.free()
		return
	var found: int = 0
	for zone: Node in nav_zones.get_children():
		var debug_mesh: MeshInstance3D = zone.get_node_or_null("DebugMesh") as MeshInstance3D
		if debug_mesh == null:
			continue
		found += 1
		assert_false(
			debug_mesh.visible,
			"NavZones/%s/DebugMesh must default to visible=false in the scene file" % zone.name
		)
	assert_gt(found, 0, "At least one NavZones/*/DebugMesh node must exist")
	root.free()


func test_debug_visuals_stay_hidden_after_ready_by_default() -> void:
	var root: Node3D = _instantiate_without_tree()
	if root == null:
		return
	add_child(root)
	_assert_nav_zone_debug_meshes_visible(root, false, "remain hidden by default")
	root.queue_free()


func test_debug_visuals_show_only_with_explicit_opt_in() -> void:
	if not OS.is_debug_build():
		return
	ProjectSettings.set_setting(SHOW_DEBUG_MESHES_SETTING, true)
	var root: Node3D = _instantiate_without_tree()
	if root == null:
		return
	add_child(root)
	_assert_nav_zone_debug_meshes_visible(root, true, "show with explicit opt-in")
	root.queue_free()


func test_screenshot_mode_keeps_debug_visuals_hidden() -> void:
	ProjectSettings.set_setting(SHOW_DEBUG_MESHES_SETTING, true)
	ProjectSettings.set_setting(SCREENSHOT_MODE_SETTING, true)
	var root: Node3D = _instantiate_without_tree()
	if root == null:
		return
	add_child(root)
	_assert_nav_zone_debug_meshes_visible(root, false, "stay hidden in screenshots")
	root.queue_free()


func _assert_nav_zone_debug_meshes_visible(
	root: Node3D, expected_visible: bool, reason: String
) -> void:
	var nav_zones: Node = root.get_node_or_null("NavZones")
	assert_not_null(nav_zones, "NavZones container must exist")
	if nav_zones == null:
		return
	for zone: Node in nav_zones.get_children():
		var dm: MeshInstance3D = zone.get_node_or_null("DebugMesh") as MeshInstance3D
		if dm == null:
			continue
		assert_eq(
			dm.visible,
			expected_visible,
			"NavZones/%s/DebugMesh must %s" % [zone.name, reason]
		)


func _collect_named(node: Node, target_name: String, out: Array[MeshInstance3D]) -> void:
	if node.name == target_name and node is MeshInstance3D:
		out.append(node)
	for child: Node in node.get_children():
		_collect_named(child, target_name, out)
