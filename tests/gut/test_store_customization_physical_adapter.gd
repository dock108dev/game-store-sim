extends GutTest

const AdapterScript: GDScript = preload(
	"res://game/scripts/stores/store_customization_physical_adapter.gd"
)

var _store_root: Node3D = null
var _shell: Node3D = null
var _adapter: Node = null


func before_each() -> void:
	StoreCustomizationSystem.reset_for_testing()
	UnlockSystemSingleton._granted = {}
	UnlockSystemSingleton._valid_ids[&"employee_display_authority"] = true
	_store_root = Node3D.new()
	_store_root.name = "RetroGames"
	add_child(_store_root)
	_shell = Node3D.new()
	_shell.name = "ExpandableStoreShell"
	_store_root.add_child(_shell)
	_add_practical_source()
	_adapter = AdapterScript.new()
	_adapter.name = "StoreCustomizationPhysicalAdapter"
	_store_root.add_child(_adapter)
	_adapter.call("configure", _store_root)


func after_each() -> void:
	if is_instance_valid(_store_root):
		_store_root.free()
	_store_root = null
	_shell = null
	_adapter = null
	StoreCustomizationSystem.reset_for_testing()
	UnlockSystemSingleton._granted = {}


func test_poster_none_and_all_ids_project_to_stable_physical_group() -> void:
	var poster: Node3D = _poster_root()
	assert_not_null(poster, "active poster group must be created under the shell")
	assert_false(_node_visible(poster, "PosterFace"), "none poster must hide the face")
	assert_eq(_label_text(poster, "PosterTitleLabel"), "")

	for poster_id: StringName in StoreCustomizationSystem.POSTER_ORDER:
		StoreCustomizationSystem.set_poster(poster_id)
		var visual: Dictionary = _adapter.call("get_poster_visual", poster_id)
		assert_eq(poster.get_meta("active_poster_id"), poster_id)
		assert_true(_node_visible(poster, "PosterFace"))
		assert_true(_node_visible(poster, "PosterAccentTop"))
		assert_eq(_label_text(poster, "PosterTitleLabel"), str(visual.get("title", "")))
		assert_eq(_label_text(poster, "PosterSubtitleLabel"), str(visual.get("subtitle", "")))
		_assert_mesh_albedo(poster, "PosterFace", visual.get("face_color") as Color)
		_assert_mesh_albedo(poster, "PosterAccentTop", visual.get("accent_color") as Color)

	StoreCustomizationSystem.set_poster(StoreCustomizationSystem.POSTER_NONE)
	assert_false(_node_visible(poster, "PosterFace"), "reset poster must hide content")
	assert_eq(_label_text(poster, "PosterTitleLabel"), "")


func test_featured_category_kits_cover_all_categories_with_safe_props() -> void:
	_grant_display_unlock()
	var featured: Node3D = _featured_root()
	assert_not_null(featured, "featured display dressing must exist")

	for category: StringName in StoreCustomizationSystem.FEATURED_CATEGORY_ORDER:
		StoreCustomizationSystem.set_featured_category(category)
		var visual: Dictionary = _adapter.call("get_featured_visual", category)
		assert_eq(featured.get_meta("active_featured_category"), category)
		assert_eq(featured.get_meta("active_featured_kit"), str(visual.get("kit_id", "")))
		assert_eq(_label_text(featured, "CategoryLabel"), str(visual.get("header", "")))
		assert_eq(_label_text(featured, "ShelfLabel"), str(visual.get("shelf_label", "")))
		assert_gt(_prop_stage(featured).get_child_count(), 0)
		_assert_featured_copy_is_safe(visual)


func test_initial_state_sync_and_signal_driven_updates() -> void:
	_store_root.free()
	StoreCustomizationSystem.set_poster(&"new_releases")
	_grant_display_unlock()
	StoreCustomizationSystem.set_featured_category(&"sports_games")
	_build_store_with_adapter()

	assert_eq(_poster_root().get_meta("active_poster_id"), &"new_releases")
	assert_eq(_featured_root().get_meta("active_featured_category"), &"sports_games")

	StoreCustomizationSystem.set_poster(&"retro_revival")
	StoreCustomizationSystem.set_featured_category(&"accessories")
	assert_eq(_poster_root().get_meta("active_poster_id"), &"retro_revival")
	assert_eq(_featured_root().get_meta("active_featured_category"), &"accessories")


func test_day_started_reset_neutralizes_physical_dressing() -> void:
	_grant_display_unlock()
	StoreCustomizationSystem.set_poster(&"family_fun")
	StoreCustomizationSystem.set_featured_category(&"family_friendly")

	EventBus.day_started.emit(2)

	assert_eq(_poster_root().get_meta("active_poster_id"), StoreCustomizationSystem.POSTER_NONE)
	assert_false(_node_visible(_poster_root(), "PosterFace"))
	assert_eq(
		_featured_root().get_meta("active_featured_category"),
		StoreCustomizationSystem.FEATURED_CATEGORY_NONE
	)
	assert_eq(_prop_stage(_featured_root()).get_child_count(), 0)
	var light: OmniLight3D = _featured_root().get_node("AccentLight") as OmniLight3D
	assert_almost_eq(light.light_energy, 0.0, 0.001)


func test_locked_featured_category_leaves_display_neutral() -> void:
	var result: StringName = StoreCustomizationSystem.cycle_featured_category()
	_adapter.call("refresh_from_system")

	assert_eq(result, StoreCustomizationSystem.FEATURED_CATEGORY_NONE)
	assert_eq(
		_featured_root().get_meta("active_featured_category"),
		StoreCustomizationSystem.FEATURED_CATEGORY_NONE
	)
	assert_eq(_prop_stage(_featured_root()).get_child_count(), 0)


func test_morning_note_hint_is_inferred_from_system_without_effect_logic() -> void:
	_grant_display_unlock()
	StoreCustomizationSystem._set_morning_note_hint_for_testing(&"sports_games")
	StoreCustomizationSystem.set_featured_category(&"sports_games")

	assert_eq(_featured_root().get_meta("morning_note_hint"), &"sports_games")
	assert_true(bool(_featured_root().get_meta("matches_morning_note_hint")))
	var source: String = FileAccess.get_file_as_string(
		"res://game/scripts/stores/store_customization_physical_adapter.gd"
	)
	assert_false(source.contains("get_spawn_weight_bonus"))
	assert_false(source.contains("get_demand_multiplier"))


func _build_store_with_adapter() -> void:
	_store_root = Node3D.new()
	_store_root.name = "RetroGames"
	add_child(_store_root)
	_shell = Node3D.new()
	_shell.name = "ExpandableStoreShell"
	_store_root.add_child(_shell)
	_add_practical_source()
	_adapter = AdapterScript.new()
	_store_root.add_child(_adapter)
	_adapter.call("configure", _store_root)


func _grant_display_unlock() -> void:
	UnlockSystemSingleton._valid_ids[&"employee_display_authority"] = true
	UnlockSystemSingleton._granted[&"employee_display_authority"] = true


func _add_practical_source() -> void:
	var mesh := MeshInstance3D.new()
	mesh.name = "FeaturedDisplayAccentPracticalSource"
	mesh.mesh = BoxMesh.new()
	_shell.add_child(mesh)


func _poster_root() -> Node3D:
	return _shell.get_node(
		"CustomizationDressing/CustomizationPoster"
	) as Node3D


func _featured_root() -> Node3D:
	return _shell.get_node(
		"CustomizationDressing/CustomizationFeaturedDisplay"
	) as Node3D


func _prop_stage(featured: Node3D) -> Node3D:
	return featured.get_node("ProductStage") as Node3D


func _node_visible(parent: Node, path: String) -> bool:
	var node_3d: Node3D = parent.get_node_or_null(path) as Node3D
	return node_3d != null and node_3d.visible


func _label_text(parent: Node, path: String) -> String:
	var label: Label3D = parent.get_node(path) as Label3D
	return label.text


func _assert_mesh_albedo(parent: Node, path: String, expected: Color) -> void:
	var mesh: MeshInstance3D = parent.get_node(path) as MeshInstance3D
	var material: StandardMaterial3D = mesh.material_override as StandardMaterial3D
	assert_not_null(material, "%s must have a generated material" % path)
	if material != null:
		assert_eq(material.albedo_color, expected)


func _assert_featured_copy_is_safe(visual: Dictionary) -> void:
	var text := " ".join([
		str(visual.get("header", "")),
		str(visual.get("subheader", "")),
		str(visual.get("shelf_label", "")),
	]).to_lower()
	for banned: String in [
		"discount",
		"savings",
		"guaranteed",
		"works with everything",
		"kid-safe",
		"approved for all ages",
		"boost",
		"bonus",
	]:
		assert_false(text.contains(banned), "featured copy must avoid '%s'" % banned)
