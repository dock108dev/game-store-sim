extends GutTest

const GALLERY_SCENE: PackedScene = preload("res://tests/visual/visual_gallery.tscn")
const GalleryScript: GDScript = preload("res://tests/visual/visual_gallery.gd")
const GalleryManifestScript: GDScript = preload(
	"res://tests/visual/visual_gallery_manifest.gd"
)
const StoreVisualScopeProfileScript: GDScript = preload(
	"res://game/scripts/store_session/store_visual_scope_profile.gd"
)

const TEST_ROOT: String = "user://visual_gallery_test_artifacts"
const EXPECTED_GROUPS: Array[String] = [
	"characters",
	"products",
	"storefronts",
	"fixtures",
	"registers",
	"stock_room",
	"signage",
	"hud",
	"buttons",
	"icons",
	"dialogue",
]
const EXPECTED_CAMERA_VIEWS: Array[String] = [
	"front",
	"side",
	"topish_gameplay",
	"close_up",
	"normal_gameplay_zoom",
	"small_viewport",
	"large_viewport",
]

var _saved_artifact_env: String = ""
var _saved_workspace_env: String = ""


func before_each() -> void:
	_saved_artifact_env = OS.get_environment("MALLCORE_ARTIFACT_DIR")
	_saved_workspace_env = OS.get_environment("GITHUB_WORKSPACE")
	OS.set_environment("MALLCORE_ARTIFACT_DIR", TEST_ROOT)
	OS.set_environment("GITHUB_WORKSPACE", "")


func after_each() -> void:
	OS.set_environment("MALLCORE_ARTIFACT_DIR", _saved_artifact_env)
	OS.set_environment("GITHUB_WORKSPACE", _saved_workspace_env)


func test_gallery_scene_loads_required_manifest_groups() -> void:
	var gallery: Node = _make_gallery()
	var audit: Dictionary = gallery.call("audit_gallery") as Dictionary

	assert_true(bool(audit.get("ok", false)), JSON.stringify(audit.get("failures", [])))
	assert_eq(audit.get("groups", []) as Array, EXPECTED_GROUPS)
	assert_eq(str(audit.get("gallery_id", "")), GalleryManifestScript.GALLERY_ID)
	var loaded: Array = audit.get("loaded_items", []) as Array
	assert_eq(loaded.size(), EXPECTED_GROUPS.size())
	for group: String in EXPECTED_GROUPS:
		assert_true(_has_loaded_group(loaded, group), "Gallery missing group %s" % group)


func test_gallery_items_share_required_manifest_shape() -> void:
	for item: Dictionary in GalleryScript.manifest_items():
		for field: String in GalleryManifestScript.REQUIRED_ITEM_FIELDS:
			assert_true(item.has(field), "%s missing %s" % [str(item.get("id", "")), field])
		assert_false(str(item.get("id", "")).is_empty())
		assert_false(str(item.get("display_name", "")).is_empty())
		assert_true(EXPECTED_GROUPS.has(str(item.get("group", ""))))
		assert_false(str(item.get("source", "")).is_empty())
		assert_false(str(item.get("spawn_mode", "")).is_empty())
		assert_gt((item.get("states", []) as Array).size(), 0)
		assert_true(item.get("tags", []) is Array)
		assert_true(item.get("camera_config", {}) is Dictionary)
		assert_true(item.get("grid_placement", {}) is Dictionary)
		assert_eq(
			str(item.get("visual_scope_mode", "")),
			StoreVisualScopeProfileScript.MODE_AUTHORED_FULL_LABEL
		)


func test_camera_cycle_covers_review_and_viewport_views() -> void:
	var views: Dictionary = GalleryScript.camera_views()
	for view_name: String in EXPECTED_CAMERA_VIEWS:
		assert_true(views.has(view_name), "Missing camera view %s" % view_name)
	assert_true((views.get("front", {}) as Dictionary).has("position"))
	assert_true((views.get("small_viewport", {}) as Dictionary).has("viewport"))
	assert_true((views.get("large_viewport", {}) as Dictionary).has("viewport"))

	for item: Dictionary in GalleryScript.manifest_items():
		var config: Dictionary = item.get("camera_config", {}) as Dictionary
		for view_name: String in EXPECTED_CAMERA_VIEWS:
			assert_true((config.get("views", []) as Array).has(view_name))
		assert_gte(float(config.get("cycle_seconds", 0.0)), 3.0)


func test_gallery_audit_proves_loaded_visual_contracts() -> void:
	var gallery: Node = _make_gallery()
	var audit: Dictionary = gallery.call("audit_gallery") as Dictionary
	var loaded: Array = audit.get("loaded_items", []) as Array

	assert_true(bool(audit.get("ok", false)), JSON.stringify(audit.get("failures", [])))
	assert_gt(loaded.size(), 0)
	for row: Dictionary in loaded:
		assert_false(str(row.get("node_path", "")).is_empty())
		assert_false(str(row.get("spawn_mode", "")).is_empty())
		assert_true(row.get("states", []) is Array)
		assert_true(row.get("tags", []) is Array)
		assert_true(row.get("camera_config", {}) is Dictionary)
		assert_true(row.get("grid_placement", {}) is Dictionary)
		assert_true(row.get("runtime_visibility", {}) is Dictionary)

	var product: Node = gallery.call("spawned_node_for", "retro_game_case") as Node
	assert_not_null(product)
	assert_not_null(_descendant_named(product, "FrontPanel"))
	assert_not_null(_descendant_named(product, "TitleLabel"))
	assert_not_null(_descendant_named(product, "PlatformStripe"))
	assert_not_null(_descendant_named(gallery.call("spawned_node_for", "wall_shelf"), "CollisionShape3D"))
	assert_not_null(_descendant_named(gallery.call("spawned_node_for", "queue_sign"), "ReadableSignText"))


func test_gallery_artifact_manifest_records_screenshots_and_review_contract() -> void:
	var gallery: Node = _make_gallery()
	var result: Dictionary = gallery.call("write_review_artifacts", true) as Dictionary

	assert_true(bool(result.get("ok", false)), str(result.get("error", "")))
	assert_true(FileAccess.file_exists(str(result.get("path", ""))))
	for capture: Dictionary in result.get("captures", []) as Array:
		assert_true(bool(capture.get("ok", false)), str(capture.get("error", "")))
		assert_true(FileAccess.file_exists(str(capture.get("path", ""))))
		assert_false(str(capture.get("beat", "")).is_empty())
		assert_false(str(capture.get("state", "")).is_empty())

	var payload: Dictionary = _read_json(str(result.get("path", "")))
	assert_eq(str(payload.get("gallery_id", "")), GalleryManifestScript.GALLERY_ID)
	assert_eq(payload.get("groups", []) as Array, EXPECTED_GROUPS)
	assert_eq((payload.get("state_beats", []) as Array).size(), 4)
	assert_eq(str(payload.get("movie_artifact", "")), GalleryScript.movie_artifact_path())
	for flag_type: String in GalleryManifestScript.REVIEW_FLAG_TYPES:
		assert_true((payload.get("review_flag_catalog", []) as Array).has(flag_type))
	var scope: Dictionary = payload.get("visual_scope_profile", {}) as Dictionary
	assert_true(
		(scope.get("modes", []) as Array).has(
			StoreVisualScopeProfileScript.MODE_AUTHORED_FULL_LABEL
		)
	)


func test_movie_scenario_uses_visual_gallery_scene() -> void:
	var source: String = _read_text("res://tests/movie_scenarios/movie_scenario_runner.gd")
	assert_string_contains(source, "gallery_walkthrough_smoke")
	assert_string_contains(source, "res://tests/visual/visual_gallery.tscn")


func test_headless_runner_can_generate_gallery_artifacts() -> void:
	var source: String = _read_text("res://tests/visual/run_visual_gallery.gd")
	assert_string_contains(source, "res://tests/visual/visual_gallery.tscn")
	assert_string_contains(source, "write_review_artifacts")
	assert_string_contains(source, "quit(0)")


func _make_gallery() -> Node:
	var gallery: Node = GALLERY_SCENE.instantiate()
	add_child_autofree(gallery)
	return gallery


func _has_loaded_group(loaded: Array, group: String) -> bool:
	for row: Dictionary in loaded:
		if str(row.get("group", "")) == group:
			return true
	return false


func _descendant_named(node: Node, node_name: String) -> Node:
	if node == null:
		return null
	if node.name == node_name:
		return node
	for child: Node in node.get_children():
		var found: Node = _descendant_named(child, node_name)
		if found != null:
			return found
	return null


func _read_json(path: String) -> Dictionary:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	assert_not_null(file)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	assert_true(parsed is Dictionary)
	return parsed as Dictionary


func _read_text(path: String) -> String:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	assert_not_null(file)
	if file == null:
		return ""
	var text: String = file.get_as_text()
	file.close()
	return text
