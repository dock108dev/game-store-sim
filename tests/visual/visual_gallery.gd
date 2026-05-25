## Internal art-review gallery for authored assets, UI states, and camera sweeps.
class_name VisualGallery
extends Node3D

const AutomationArtifactsScript: GDScript = preload(
	"res://game/scripts/core/automation_artifacts.gd"
)
const VisualGalleryManifestScript: GDScript = preload(
	"res://tests/visual/visual_gallery_manifest.gd"
)
const ProductVisualFactoryScript: GDScript = preload(
	"res://game/scripts/visuals/product_visual_factory.gd"
)
const StoreVisualKitScript: GDScript = preload(
	"res://game/scripts/visuals/store_visual_kit.gd"
)
const CharacterVisualFactoryScript: GDScript = preload(
	"res://game/scripts/visuals/store_session_character_visual_factory.gd"
)
const StoreVisualScopeProfileScript: GDScript = preload(
	"res://game/scripts/store_session/store_visual_scope_profile.gd"
)
const StoreVisualSweepScript: GDScript = preload(
	"res://game/scripts/store_session/store_visual_sweep.gd"
)

var _items_root: Node3D = null
var _ui_layer: CanvasLayer = null
var _spawned_by_id: Dictionary = {}


func _ready() -> void:
	build_gallery()

static func manifest_items() -> Array[Dictionary]:
	return VisualGalleryManifestScript.items()

static func camera_views() -> Dictionary:
	return VisualGalleryManifestScript.camera_views()

static func movie_artifact_path() -> String:
	return VisualGalleryManifestScript.movie_artifact_path()


func build_gallery() -> void:
	_clear_gallery()
	_spawned_by_id.clear()
	_items_root = Node3D.new()
	_items_root.name = "GalleryItems"
	add_child(_items_root)
	_add_lighting()
	_add_camera()
	_add_ui_layer()
	for item: Dictionary in manifest_items():
		var node: Node = _spawn_item(item)
		if node == null:
			node = Node3D.new()
			node.set_meta("spawn_error", true)
		node.name = str(item["id"])
		node.set_meta("gallery_item", item.duplicate(true))
		_spawned_by_id[str(item["id"])] = node
		if node is Node3D and (item.get("tags", []) as Array).has("interactive"):
			_add_collision(node as Node3D)
		if node is Node3D:
			_items_root.add_child(node)
			(node as Node3D).position = _grid_position(item)
		else:
			_ui_layer.add_child(node)


func audit_gallery() -> Dictionary:
	var failures: Array[String] = []
	var flags: Array[Dictionary] = []
	var loaded_items: Array[Dictionary] = []
	for item: Dictionary in manifest_items():
		var item_id: String = str(item.get("id", ""))
		var node: Node = _spawned_by_id.get(item_id, null) as Node
		_validate_schema(item, failures)
		if node == null:
			failures.append("%s did not spawn" % item_id)
			continue
		_validate_loaded_item(item, node, failures, flags)
		loaded_items.append(_loaded_item_row(item, node))
	return {
		"ok": failures.is_empty(),
		"gallery_id": VisualGalleryManifestScript.GALLERY_ID,
		"groups": VisualGalleryManifestScript.GROUP_ORDER,
		"loaded_items": loaded_items,
		"camera_views": camera_views(),
		"visual_scope_profile": StoreVisualScopeProfileScript.scope_manifest(),
		"review_flag_catalog": VisualGalleryManifestScript.REVIEW_FLAG_TYPES,
		"review_flags": flags,
		"failures": failures,
		"movie_artifact": movie_artifact_path(),
	}


func write_review_artifacts(allow_placeholder := true) -> Dictionary:
	var captures: Array[Dictionary] = []
	for beat: Dictionary in VisualGalleryManifestScript.screenshot_beats():
		var result: Dictionary = StoreVisualSweepScript.save_viewport_png(
			get_viewport(),
			AutomationArtifactsScript.gallery_dir(VisualGalleryManifestScript.GALLERY_ID),
			str(beat.get("filename", "")),
			allow_placeholder
		)
		result["beat"] = str(beat.get("id", ""))
		result["state"] = str(beat.get("state", ""))
		captures.append(result)
	var audit: Dictionary = audit_gallery()
	var manifest_path: String = AutomationArtifactsScript.join_path([
		AutomationArtifactsScript.report_dir("gallery", VisualGalleryManifestScript.GALLERY_ID),
		VisualGalleryManifestScript.REVIEW_MANIFEST_FILENAME,
	])
	var write_result: Dictionary = AutomationArtifactsScript.write_recorded_json(
		manifest_path,
		{
			"gallery_id": VisualGalleryManifestScript.GALLERY_ID,
			"groups": VisualGalleryManifestScript.GROUP_ORDER,
			"items": _serializable_items(),
			"camera_views": camera_views(),
			"state_beats": VisualGalleryManifestScript.screenshot_beats(),
			"captures": captures,
			"review_flag_catalog": VisualGalleryManifestScript.REVIEW_FLAG_TYPES,
			"review_flags": audit.get("review_flags", []),
			"visual_scope_profile": audit.get("visual_scope_profile", {}),
			"movie_artifact": movie_artifact_path(),
		},
		"gallery_report",
		VisualGalleryManifestScript.GALLERY_ID,
		"gallery",
		"manifest",
		"Cannot write gallery review manifest"
	)
	if not bool(write_result.get("ok", false)):
		return write_result
	write_result["captures"] = captures
	return write_result


func spawned_node_for(item_id: String) -> Node:
	return _spawned_by_id.get(item_id, null) as Node

func _spawn_item(item: Dictionary) -> Node:
	match str(item["spawn_mode"]):
		"character_factory":
			var character := Node3D.new()
			CharacterVisualFactoryScript.configure_customer_proxy(character, true)
			return character
		"product_factory":
			return ProductVisualFactoryScript.create_visual_for_item({
				"id": "neo_ignite_motorway_kings_loose",
				"display_name": "Motorway Kings",
				"category": "cartridges",
				"platform_id": "neo_ignite",
				"box_art_key": "motorway_kings_neo_ignite",
			})
		"store_visual_kit":
			return StoreVisualKitScript.instantiate(_kit_id(str(item["id"])))
		"stock_room_cluster":
			return _stock_room_cluster()
		"sign_label":
			return _sign_label()
		"hud_panel":
			return _hud_panel(item)
		"button_control":
			return _button_control(item)
		"icon_control":
			return _icon_control(item)
		"dialogue_panel":
			return _dialogue_panel(item)
		_:
			return _storefront_reference()


func _kit_id(item_id: String) -> StringName:
	match item_id:
		"wall_shelf":
			return StoreVisualKitScript.WALL_SHELF
		"register_terminal":
			return StoreVisualKitScript.REGISTER
	return StoreVisualKitScript.DISPLAY_TABLE


func _stock_room_cluster() -> Node3D:
	var root := Node3D.new()
	root.add_child(StoreVisualKitScript.instantiate(StoreVisualKitScript.STOCK_BOX))
	var truck: Node3D = StoreVisualKitScript.instantiate(StoreVisualKitScript.HAND_TRUCK) as Node3D
	if truck != null:
		truck.position = Vector3(0.75, 0.0, 0.0)
		root.add_child(truck)
	_add_collision(root)
	return root


func _storefront_reference() -> Node3D:
	var root := Node3D.new()
	_add_box(root, "Facade", Vector3(2.8, 1.8, 0.12), Vector3.ZERO, Color(0.45, 0.28, 0.18))
	_add_box(root, "Window", Vector3(0.8, 0.75, 0.04), Vector3(-0.55, 0.25, 0.08), Color(0.35, 0.68, 0.86))
	_add_box(root, "Door", Vector3(0.65, 1.25, 0.05), Vector3(0.65, -0.25, 0.09), Color(0.20, 0.14, 0.10))
	var label := Label3D.new()
	label.name = "StorefrontSign"
	label.text = "RETRO GAMES"
	label.font_size = 42
	label.pixel_size = 0.006
	label.position = Vector3(0.0, 0.72, 0.16)
	root.add_child(label)
	return root


func _sign_label() -> Node3D:
	var root := Node3D.new()
	_add_box(root, "SignBacker", Vector3(1.1, 0.42, 0.04), Vector3.ZERO, Color(0.12, 0.09, 0.06))
	var label := Label3D.new()
	label.name = "ReadableSignText"
	label.text = "QUEUE HERE"
	label.font_size = 38
	label.pixel_size = 0.0045
	label.position = Vector3(0.0, 0.0, 0.04)
	root.add_child(label)
	return root


func _hud_panel(item: Dictionary) -> Control:
	var panel := PanelContainer.new()
	panel.position = _ui_position(item)
	panel.size = Vector2(260.0, 88.0)
	var label := Label.new()
	label.text = "$275  Day 1  8:00 AM"
	label.add_theme_font_size_override("font_size", 18)
	panel.add_child(label)
	return panel


func _button_control(item: Dictionary) -> Button:
	var button := Button.new()
	button.text = "Confirm"
	button.position = _ui_position(item)
	button.size = Vector2(180.0, 48.0)
	button.disabled = false
	return button


func _icon_control(item: Dictionary) -> Control:
	var root := PanelContainer.new()
	root.position = _ui_position(item)
	root.size = Vector2(80.0, 80.0)
	var label := Label.new()
	label.text = "$"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 40)
	root.add_child(label)
	return root


func _dialogue_panel(item: Dictionary) -> Control:
	var panel := PanelContainer.new()
	panel.position = _ui_position(item)
	panel.size = Vector2(360.0, 118.0)
	var text := Label.new()
	text.text = "Vic\nPick a lane and keep the counter visible."
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(text)
	return panel


func _add_lighting() -> void:
	var key := DirectionalLight3D.new()
	key.name = "GalleryKeyLight"
	key.rotation = Vector3(deg_to_rad(-42.0), deg_to_rad(-28.0), 0.0)
	key.light_energy = 2.6
	add_child(key)
	var fill := OmniLight3D.new()
	fill.name = "GalleryFillLight"
	fill.position = Vector3(0.0, 4.0, 5.0)
	fill.light_energy = 1.2
	fill.omni_range = 22.0
	add_child(fill)


func _add_camera() -> void:
	var camera := Camera3D.new()
	camera.name = "GalleryCamera"
	camera.position = Vector3(0.0, 5.0, 12.0)
	camera.rotation = Vector3(deg_to_rad(-24.0), 0.0, 0.0)
	camera.fov = 62.0
	camera.current = true
	add_child(camera)


func _add_ui_layer() -> void:
	_ui_layer = CanvasLayer.new()
	_ui_layer.name = "GalleryUILayer"
	add_child(_ui_layer)


func _grid_position(item: Dictionary) -> Vector3:
	var grid: Dictionary = item.get("grid_placement", {}) as Dictionary
	return Vector3(
		(float(grid.get("column", 0)) - 1.0) * 3.1 + 0.35,
		0.0,
		float(grid.get("row", 0)) * -2.7 - 0.25
	)


func _ui_position(item: Dictionary) -> Vector2:
	var grid: Dictionary = item.get("grid_placement", {}) as Dictionary
	return Vector2(32.0 + float(grid.get("column", 0)) * 300.0, 430.0)


func _add_box(root: Node3D, name: String, size: Vector3, position: Vector3, color: Color) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.position = position
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	mesh_instance.material_override = material
	root.add_child(mesh_instance)


func _add_collision(root: Node3D) -> void:
	var area := Area3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.4, 1.0, 1.0)
	shape.shape = box
	area.add_child(shape)
	root.add_child(area)


func _validate_schema(item: Dictionary, failures: Array[String]) -> void:
	for field: String in VisualGalleryManifestScript.REQUIRED_ITEM_FIELDS:
		if not item.has(field):
			failures.append("%s missing %s" % [str(item.get("id", "unknown")), field])


func _validate_loaded_item(
	item: Dictionary,
	node: Node,
	failures: Array[String],
	flags: Array[Dictionary]
) -> void:
	var item_id: String = str(item["id"])
	if node is Node3D and (node as Node3D).global_position.is_equal_approx(Vector3.ZERO):
		failures.append("%s is unintentionally at origin" % item_id)
	if not _has_visual_surface(node):
		failures.append("%s has no mesh or UI surface" % item_id)
	if (item.get("tags", []) as Array).has("interactive") and not _has_collision(node):
		failures.append("%s interactive visual has no collision" % item_id)
	if (item.get("tags", []) as Array).has("readable_text") and not _has_readable_text(node):
		failures.append("%s readable text is missing" % item_id)
	if (item.get("tags", []) as Array).has("product_box") and not _has_designed_product_surface(node):
		failures.append("%s product box lacks designed surfaces" % item_id)
	_append_review_flags(item, node, flags)


func _append_review_flags(item: Dictionary, node: Node, flags: Array[Dictionary]) -> void:
	var scale: Vector3 = Vector3.ONE
	if node is Node3D:
		scale = (node as Node3D).scale
		if scale.x > 4.0 or scale.y > 4.0 or scale.z > 4.0:
			flags.append(_flag(item, "scale_outlier", "Scale exceeds gallery bounds"))
		if _lowest_visual_y(node) > 0.35:
			flags.append(_flag(item, "floating_prop", "Visual appears above its review floor"))
	if not _has_material_family(node):
		flags.append(_flag(item, "inconsistent_material_family", "No inspectable material family"))
	if (item.get("tags", []) as Array).has("readable_text") and not _has_readable_text(node):
		flags.append(_flag(item, "unreadable_signage", "Required readable text is absent"))
	if (item.get("tags", []) as Array).has("product_box") and not _has_designed_product_surface(node):
		flags.append(_flag(item, "placeholder_like_geometry", "Product surface lacks authored panels"))
	if (item.get("tags", []) as Array).has("ui") and not _has_ui_style_surface(node):
		flags.append(_flag(item, "mismatched_ui_component_styling", "UI surface lacks panel or button styling"))


func _flag(item: Dictionary, flag: String, reason: String) -> Dictionary:
	return {"item_id": str(item.get("id", "")), "group": str(item.get("group", "")),
		"flag": flag, "reason": reason}


func _has_visual_surface(node: Node) -> bool:
	if node is MeshInstance3D or node is Control:
		return true
	for child: Node in node.get_children():
		if _has_visual_surface(child):
			return true
	return false


func _has_collision(node: Node) -> bool:
	if node is CollisionShape3D or node is CollisionObject3D:
		return true
	for child: Node in node.get_children():
		if _has_collision(child):
			return true
	return false


func _has_readable_text(node: Node) -> bool:
	if node is Label3D:
		return (node as Label3D).text.strip_edges().length() >= 3
	if node is Label:
		return (node as Label).text.strip_edges().length() >= 3
	if node is Button:
		return (node as Button).text.strip_edges().length() >= 3
	for child: Node in node.get_children():
		if _has_readable_text(child):
			return true
	return false


func _has_designed_product_surface(node: Node) -> bool:
	return _descendant_named(node, "FrontPanel") != null \
		and _descendant_named(node, "TitleLabel") != null \
		and _descendant_named(node, "PlatformStripe") != null


func _has_material_family(node: Node) -> bool:
	if node is Control:
		return true
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		return mesh_instance.material_override != null or mesh_instance.mesh != null
	for child: Node in node.get_children():
		if _has_material_family(child):
			return true
	return false


func _has_ui_style_surface(node: Node) -> bool:
	if node is PanelContainer or node is Button:
		return true
	for child: Node in node.get_children():
		if _has_ui_style_surface(child):
			return true
	return false


func _lowest_visual_y(node: Node) -> float:
	var lowest: float = INF
	if node is MeshInstance3D:
		lowest = minf(lowest, (node as MeshInstance3D).global_position.y)
	for child: Node in node.get_children():
		lowest = minf(lowest, _lowest_visual_y(child))
	if lowest == INF:
		return 0.0
	return lowest


func _descendant_named(node: Node, node_name: String) -> Node:
	if node.name == node_name:
		return node
	for child: Node in node.get_children():
		var found: Node = _descendant_named(child, node_name)
		if found != null:
			return found
	return null


func _loaded_item_row(item: Dictionary, node: Node) -> Dictionary:
	return {
		"id": str(item["id"]),
		"display_name": str(item["display_name"]),
		"group": str(item["group"]),
		"source": str(item["source"]),
		"spawn_mode": str(item["spawn_mode"]),
		"states": item.get("states", []),
		"tags": item.get("tags", []),
		"camera_config": item.get("camera_config", {}),
		"grid_placement": item.get("grid_placement", {}),
		"visual_scope_mode": str(item.get("visual_scope_mode", "")),
		"runtime_visibility": _runtime_visibility(item),
		"node_path": str(node.get_path()),
	}


func _runtime_visibility(item: Dictionary) -> Dictionary:
	var runtime: String = "visible"
	if str(item.get("group", "")) == "storefronts":
		runtime = "reference_only"
	return {"authored_full": "visible", "store_session_runtime": runtime,
		"store_session_reference_visible": "visible"}


func _serializable_items() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for item: Dictionary in manifest_items():
		var row: Dictionary = item.duplicate(true)
		row["runtime_visibility"] = _runtime_visibility(item)
		rows.append(row)
	return rows


func _clear_gallery() -> void:
	for child: Node in get_children():
		child.queue_free()
