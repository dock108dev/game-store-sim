## Verifies the debug-only reference-corner camera comparison scene.
extends GutTest

const COMPARISON_SCENE_PATH: String = (
	"res://game/scenes/debug/reference_corner_camera_comparison.tscn"
)
const ComparisonScript: GDScript = preload(
	"res://game/scenes/debug/reference_corner_camera_comparison.gd"
)

const MODE_FIRST_PERSON: int = 0
const MODE_FIXED_ANGLE: int = 1
const MODE_COUNTER_FOCUS: int = 2

var _comparison: Node = null


func before_each() -> void:
	_clear_registered_cameras()
	CameraAuthority._reset_for_tests()
	var scene: PackedScene = load(COMPARISON_SCENE_PATH)
	assert_not_null(scene, "Camera comparison scene must load")
	if scene == null:
		return
	_comparison = scene.instantiate()
	assert_not_null(_comparison, "Scene root must use the comparison script")
	if _comparison == null:
		return
	assert_eq(_comparison.get_script(), ComparisonScript)
	add_child_autofree(_comparison)


func after_each() -> void:
	_clear_registered_cameras()
	CameraAuthority._reset_for_tests()
	_comparison = null


func test_scene_builds_three_comparison_modes() -> void:
	if _comparison == null:
		return
	var names: PackedStringArray = _comparison.get_mode_names()
	assert_eq(names.size(), 3)
	assert_eq(names[0], "first_person")
	assert_eq(names[1], "fixed_angle")
	assert_eq(names[2], "counter_focus")

	for mode: int in [
		MODE_FIRST_PERSON,
		MODE_FIXED_ANGLE,
		MODE_COUNTER_FOCUS,
	]:
		var cam: Camera3D = _comparison.get_camera_for_mode(mode)
		assert_not_null(cam, "Every comparison mode must expose a Camera3D")
		if cam != null:
			assert_true(cam.is_in_group(&"cameras"))


func test_mode_selection_routes_through_camera_authority() -> void:
	if _comparison == null:
		return
	var expectations: Array[Dictionary] = [
		{
			"mode": MODE_FIRST_PERSON,
			"source": &"player_fp",
		},
		{
			"mode": MODE_FIXED_ANGLE,
			"source": &"fixed_angle",
		},
		{
			"mode": MODE_COUNTER_FOCUS,
			"source": &"counter_focus",
		},
	]
	for expectation: Dictionary in expectations:
		var mode: int = int(expectation["mode"])
		var source: StringName = expectation["source"]
		assert_true(_comparison.select_mode(mode))
		assert_eq(CameraAuthority.current(), _comparison.get_camera_for_mode(mode))
		assert_eq(CameraAuthority.current_source(), source)
		assert_true(CameraAuthority.assert_single_active())


func test_fixed_angle_mode_reuses_store_player_controller_camera() -> void:
	if _comparison == null:
		return
	var store_root: Node3D = _comparison.get_store_root()
	assert_not_null(store_root)
	if store_root == null:
		return
	var controller: PlayerController = (
		store_root.get_node_or_null("PlayerController") as PlayerController
	)
	assert_not_null(controller)
	if controller == null:
		return
	var controller_camera: Camera3D = controller.get_camera()
	assert_eq(
		_comparison.get_camera_for_mode(MODE_FIXED_ANGLE),
		controller_camera
	)
	assert_eq(controller.process_mode, Node.PROCESS_MODE_DISABLED)
	assert_eq(
		int(controller_camera.projection),
		int(Camera3D.PROJECTION_ORTHOGONAL)
	)
	assert_almost_eq(controller_camera.size, 11.0, 0.001)


func test_visual_evidence_rows_cover_reference_corner() -> void:
	if _comparison == null:
		return
	var rows: Array[Dictionary] = _comparison.get_visual_evidence_rows()
	assert_eq(rows.size(), 3)
	for row: Dictionary in rows:
		assert_eq(row.get("scope", ""), "reference_corner")
		assert_true(String(row.get("camera_path", "")).contains("Camera"))
		assert_true(String(row.get("suggested_filename", "")).ends_with(".png"))
		var anchors: Array = row.get("anchors", [])
		assert_gt(anchors.size(), 0)
		for anchor: String in anchors:
			assert_not_null(
				_comparison.get_store_root().get_node_or_null(NodePath(anchor)),
				"Evidence anchor must exist in the store scene: %s" % anchor
			)


func test_comparison_scene_is_not_normal_gameplay_entrypoint() -> void:
	var project_text: String = FileAccess.get_file_as_string("res://project.godot")
	assert_true(project_text.contains(
		'run/main_scene="res://game/scenes/bootstrap/boot.tscn"'
	))
	assert_false(
		project_text.contains(COMPARISON_SCENE_PATH),
		"Comparison scene must only run when intentionally opened"
	)


func _clear_registered_cameras() -> void:
	if get_tree() == null:
		return
	for node: Node in get_tree().get_nodes_in_group(&"cameras"):
		if not is_instance_valid(node):
			continue
		if node is Camera3D:
			(node as Camera3D).clear_current()
