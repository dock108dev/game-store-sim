## Projects StoreCustomizationSystem poster/category state into store dressing.
class_name StoreCustomizationPhysicalAdapter
extends Node

const POSTER_NONE: StringName = &""
const FEATURED_NONE: StringName = &""
const SHELL_NAME: StringName = &"ExpandableStoreShell"
const DRESSING_ROOT_NAME: StringName = &"CustomizationDressing"
const POSTER_ROOT_NAME: StringName = &"CustomizationPoster"
const FEATURED_ROOT_NAME: StringName = &"CustomizationFeaturedDisplay"

const POSTER_VISUALS: Dictionary = {
	&"": {
		"title": "",
		"subtitle": "",
		"face_color": Color(0.18, 0.17, 0.15, 1.0),
		"accent_color": Color(0.30, 0.28, 0.24, 1.0),
		"emission_color": Color(0.0, 0.0, 0.0, 1.0),
		"emission_energy": 0.0,
		"visible_content": false,
	},
	&"new_releases": {
		"title": "NEW THIS WEEK",
		"subtitle": "Fresh drops. First pick.",
		"face_color": Color(0.62, 0.12, 0.10, 1.0),
		"accent_color": Color(0.95, 0.68, 0.24, 1.0),
		"emission_color": Color(0.95, 0.28, 0.18, 1.0),
		"emission_energy": 0.28,
		"visible_content": true,
	},
	&"retro_revival": {
		"title": "RETRO REVIVAL",
		"subtitle": "Old carts. New stories.",
		"face_color": Color(0.22, 0.13, 0.42, 1.0),
		"accent_color": Color(0.24, 0.72, 0.42, 1.0),
		"emission_color": Color(0.44, 0.22, 0.86, 1.0),
		"emission_energy": 0.22,
		"visible_content": true,
	},
	&"family_fun": {
		"title": "FAMILY FUN",
		"subtitle": "Easy picks for every player.",
		"face_color": Color(0.12, 0.42, 0.30, 1.0),
		"accent_color": Color(0.28, 0.62, 0.88, 1.0),
		"emission_color": Color(0.20, 0.62, 0.42, 1.0),
		"emission_energy": 0.18,
		"visible_content": true,
	},
}

const FEATURED_VISUALS: Dictionary = {
	&"": {
		"kit_id": "neutral_featured_display",
		"header": "",
		"subheader": "",
		"shelf_label": "",
		"accent_color": Color(0.35, 0.32, 0.24, 1.0),
		"props": [],
		"visible_content": false,
	},
	&"new_console_hype": {
		"kit_id": "featured_vecforce_hd_spotlight",
		"header": "VecForce HD Spotlight",
		"subheader": "New platform buzz, demo reels, and launch chatter",
		"shelf_label": "Ask Staff About Holds",
		"accent_color": Color(0.25, 0.68, 0.92, 1.0),
		"props": ["VecForce Display Shell", "Controller Pair", "Launch Case Stack"],
		"visible_content": true,
	},
	&"old_gen_clearance": {
		"kit_id": "featured_old_gen_back_catalog",
		"header": "Old-Gen Back Catalog",
		"subheader": "Earlier systems, familiar libraries",
		"shelf_label": "Neo Ignite / Canopy Wave",
		"accent_color": Color(0.14, 0.62, 0.54, 1.0),
		"props": ["Neo Ignite Shell", "Canopy Wave Shell", "Back Catalog Rows"],
		"visible_content": true,
	},
	&"used_bundles": {
		"kit_id": "featured_used_starter_sets",
		"header": "Used Starter Sets",
		"subheader": "Consoles, controllers, and games grouped for browsing",
		"shelf_label": "Checked-In Sets",
		"accent_color": Color(0.24, 0.56, 0.48, 1.0),
		"props": ["Console Tray", "Wrapped Case Groups", "Loose Cartridge Cup"],
		"visible_content": true,
	},
	&"sports_games": {
		"kit_id": "featured_sports_shelf",
		"header": "Sports Shelf",
		"subheader": "Football, soccer, racing, and arcade competition",
		"shelf_label": "Annual Classics",
		"accent_color": Color(0.22, 0.58, 0.38, 1.0),
		"props": ["Sports Faceouts", "Racing Case Row", "Platform Fit Card"],
		"visible_content": true,
	},
	&"accessories": {
		"kit_id": "featured_accessory_wall",
		"header": "Accessory Wall",
		"subheader": "Controllers, cables, adapters, and memory cards",
		"shelf_label": "Match ports before checkout",
		"accent_color": Color(0.78, 0.62, 0.24, 1.0),
		"props": ["Controller Bin", "Cable Peg Strip", "Memory Card Packs"],
		"visible_content": true,
	},
	&"family_friendly": {
		"kit_id": "featured_family_friendly_games",
		"header": "Family-Friendly Games",
		"subheader": "Bright picks for group play and easy starts",
		"shelf_label": "Party Picks / Adventure Shelf",
		"accent_color": Color(0.28, 0.62, 0.76, 1.0),
		"props": ["Party Game Faceouts", "Adventure Case Row", "Console Match Card"],
		"visible_content": true,
	},
}

var _store_root: Node = null
var _dressing_root: Node3D = null
var _poster_root: Node3D = null
var _featured_root: Node3D = null
var _featured_stage: Node3D = null


func _ready() -> void:
	_connect_system_signals()
	refresh_from_system()


## Configures the store root and creates stable generated-shell dressing nodes.
func configure(store_root: Node, dressing_root: Node3D = null) -> void:
	_store_root = store_root
	_dressing_root = dressing_root
	if _store_root != null and not _store_root.child_entered_tree.is_connected(
		_on_store_child_entered_tree
	):
		_store_root.child_entered_tree.connect(_on_store_child_entered_tree)
	_connect_system_signals()
	_ensure_dressing_roots()
	refresh_from_system()


## Re-applies the current StoreCustomizationSystem state to physical dressing.
func refresh_from_system() -> void:
	var system: Node = _customization_system()
	if system == null:
		reset_dressing()
		return
	apply_poster(system.get("current_poster_id") as StringName)
	apply_featured_category(system.get("current_featured_category") as StringName)


## Applies one poster state to the active generated-shell poster group.
func apply_poster(poster_id: StringName) -> void:
	_ensure_dressing_roots()
	if _poster_root == null:
		return
	var visual: Dictionary = get_poster_visual(poster_id)
	var visible_content: bool = bool(visual.get("visible_content", false))
	_poster_root.set_meta("active_poster_id", poster_id)
	_poster_root.set_meta("visual_source", "store_customization_system")
	_set_mesh_material(
		_poster_root.get_node_or_null("PosterFace") as MeshInstance3D,
		visual.get("face_color") as Color,
		visual.get("emission_color") as Color,
		float(visual.get("emission_energy", 0.0))
	)
	_set_mesh_material(
		_poster_root.get_node_or_null("PosterAccentTop") as MeshInstance3D,
		visual.get("accent_color") as Color
	)
	_set_mesh_material(
		_poster_root.get_node_or_null("PosterAccentBottom") as MeshInstance3D,
		visual.get("accent_color") as Color
	)
	_set_label(
		_poster_root.get_node_or_null("PosterTitleLabel") as Label3D,
		str(visual.get("title", "")),
		visible_content
	)
	_set_label(
		_poster_root.get_node_or_null("PosterSubtitleLabel") as Label3D,
		str(visual.get("subtitle", "")),
		visible_content
	)
	for node_name: String in ["PosterFace", "PosterAccentTop", "PosterAccentBottom"]:
		var node: Node3D = _poster_root.get_node_or_null(node_name) as Node3D
		if node != null:
			node.visible = visible_content


## Applies one featured-category state to the generated-shell display kit.
func apply_featured_category(category: StringName) -> void:
	_ensure_dressing_roots()
	if _featured_root == null:
		return
	var visual: Dictionary = get_featured_visual(category)
	var visible_content: bool = bool(visual.get("visible_content", false))
	var hint: StringName = _morning_note_hint()
	_featured_root.set_meta("active_featured_category", category)
	_featured_root.set_meta("active_featured_kit", str(visual.get("kit_id", "")))
	_featured_root.set_meta("morning_note_hint", hint)
	_featured_root.set_meta(
		"matches_morning_note_hint", hint != FEATURED_NONE and hint == category
	)
	_set_mesh_material(
		_featured_root.get_node_or_null("HeaderSign") as MeshInstance3D,
		visual.get("accent_color") as Color,
		visual.get("accent_color") as Color,
		0.18 if visible_content else 0.0
	)
	_set_label(
		_featured_root.get_node_or_null("CategoryLabel") as Label3D,
		str(visual.get("header", "")),
		visible_content
	)
	_set_label(
		_featured_root.get_node_or_null("SubheaderLabel") as Label3D,
		str(visual.get("subheader", "")),
		visible_content
	)
	_set_label(
		_featured_root.get_node_or_null("ShelfLabel") as Label3D,
		str(visual.get("shelf_label", "")),
		visible_content
	)
	_apply_featured_props(visual.get("props", []) as Array, visual.get("accent_color") as Color)
	_update_featured_light(visual.get("accent_color") as Color, visible_content)


## Clears poster and featured dressing without touching gameplay state.
func reset_dressing() -> void:
	apply_poster(POSTER_NONE)
	apply_featured_category(FEATURED_NONE)


## Returns a defensive copy of one poster visual mapping.
func get_poster_visual(poster_id: StringName) -> Dictionary:
	return (
		(POSTER_VISUALS.get(poster_id, POSTER_VISUALS[POSTER_NONE]) as Dictionary)
		.duplicate(true)
	)


## Returns a defensive copy of one featured display visual mapping.
func get_featured_visual(category: StringName) -> Dictionary:
	return (
		(FEATURED_VISUALS.get(category, FEATURED_VISUALS[FEATURED_NONE]) as Dictionary)
		.duplicate(true)
	)


func _connect_system_signals() -> void:
	var system: Node = _customization_system()
	if system == null:
		return
	var poster_signal := Signal(system, "poster_changed")
	if not poster_signal.is_connected(_on_poster_changed):
		poster_signal.connect(_on_poster_changed)
	var featured_signal := Signal(system, "featured_category_changed")
	if not featured_signal.is_connected(_on_featured_category_changed):
		featured_signal.connect(_on_featured_category_changed)


func _ensure_dressing_roots() -> void:
	var shell: Node3D = _shell()
	if shell == null:
		return
	if _dressing_root == null:
		_dressing_root = shell.get_node_or_null(String(DRESSING_ROOT_NAME)) as Node3D
	if _dressing_root == null:
		_dressing_root = Node3D.new()
		_dressing_root.name = DRESSING_ROOT_NAME
		_dressing_root.set_meta("visual_source", "store_customization_physical_adapter")
		_dressing_root.set_meta("visual_only", true)
		shell.add_child(_dressing_root)
	if _poster_root == null:
		_poster_root = _dressing_root.get_node_or_null(String(POSTER_ROOT_NAME)) as Node3D
	if _poster_root == null:
		_poster_root = _build_poster_root()
		_dressing_root.add_child(_poster_root)
	if _featured_root == null:
		_featured_root = _dressing_root.get_node_or_null(String(FEATURED_ROOT_NAME)) as Node3D
	if _featured_root == null:
		_featured_root = _build_featured_root()
		_dressing_root.add_child(_featured_root)
	_featured_stage = _featured_root.get_node_or_null("ProductStage") as Node3D


func _build_poster_root() -> Node3D:
	var root := Node3D.new()
	root.name = POSTER_ROOT_NAME
	root.position = Vector3(-3.85, 2.25, -9.92)
	root.set_meta("visual_only", true)
	_add_box(
		root, "PosterFrame", Vector3.ZERO, Vector3(2.05, 1.32, 0.055),
		Color(0.08, 0.07, 0.06, 1.0)
	)
	_add_box(
		root, "PosterFace", Vector3(0.0, 0.0, 0.035),
		Vector3(1.88, 1.12, 0.035), Color(0.18, 0.17, 0.15, 1.0)
	)
	_add_box(
		root, "PosterAccentTop", Vector3(0.0, 0.49, 0.065),
		Vector3(1.88, 0.14, 0.045), Color(0.30, 0.28, 0.24, 1.0)
	)
	_add_box(
		root, "PosterAccentBottom", Vector3(0.0, -0.49, 0.065),
		Vector3(1.88, 0.10, 0.045), Color(0.30, 0.28, 0.24, 1.0)
	)
	_add_label(root, "PosterTitleLabel", "", Vector3(0.0, 0.12, 0.095), 42)
	_add_label(root, "PosterSubtitleLabel", "", Vector3(0.0, -0.25, 0.095), 20)
	return root


func _build_featured_root() -> Node3D:
	var root := Node3D.new()
	root.name = FEATURED_ROOT_NAME
	root.position = Vector3(-4.10, 0.80, -1.20)
	root.rotation_degrees = Vector3(0.0, -8.0, 0.0)
	root.set_meta("visual_only", true)
	_add_box(
		root, "BaseFixture", Vector3(0.0, -0.20, 0.0),
		Vector3(2.55, 0.82, 0.95), Color(0.16, 0.12, 0.09, 1.0)
	)
	_add_box(
		root, "HeaderSign", Vector3(0.0, 0.95, -0.35),
		Vector3(2.25, 0.42, 0.08), Color(0.35, 0.32, 0.24, 1.0)
	)
	_add_label(root, "CategoryLabel", "", Vector3(0.0, 0.99, -0.405), 24)
	_add_label(root, "SubheaderLabel", "", Vector3(0.0, 0.78, -0.405), 12)
	_add_label(root, "ShelfLabel", "", Vector3(0.0, 0.22, -0.50), 14)
	var stage := Node3D.new()
	stage.name = "ProductStage"
	stage.position = Vector3(0.0, 0.20, 0.0)
	stage.set_meta("visual_only", true)
	root.add_child(stage)
	var light := OmniLight3D.new()
	light.name = "AccentLight"
	light.position = Vector3(0.0, 0.90, 0.20)
	light.light_energy = 0.0
	light.omni_range = 2.4
	root.add_child(light)
	return root


func _apply_featured_props(prop_labels: Array, accent_color: Color) -> void:
	if _featured_stage == null:
		return
	for child: Node in _featured_stage.get_children():
		_featured_stage.remove_child(child)
		child.free()
	for index: int in range(prop_labels.size()):
		var prop_root := Node3D.new()
		prop_root.name = "FeaturedProp%02d" % index
		prop_root.position = Vector3(-0.62 + float(index) * 0.62, 0.05, 0.0)
		prop_root.set_meta("prop_label", str(prop_labels[index]))
		prop_root.set_meta("visual_only", true)
		_add_box(
			prop_root, "PropBody", Vector3.ZERO,
			Vector3(0.42, 0.26, 0.34), accent_color.darkened(0.22)
		)
		_add_box(
			prop_root, "PropFace", Vector3(0.0, 0.02, -0.18),
			Vector3(0.34, 0.18, 0.035), accent_color
		)
		_add_label(
			prop_root, "PropLabel", str(prop_labels[index]), Vector3(0.0, 0.17, -0.205), 9
		)
		_featured_stage.add_child(prop_root)


func _update_featured_light(accent_color: Color, visible_content: bool) -> void:
	var light: OmniLight3D = _featured_root.get_node_or_null("AccentLight") as OmniLight3D
	if light != null:
		light.light_color = accent_color
		light.light_energy = 0.35 if visible_content else 0.0
	var shell: Node3D = _shell()
	if shell == null:
		return
	var shell_light: MeshInstance3D = shell.get_node_or_null(
		"DisplayTableUndershelfPracticalSource"
	) as MeshInstance3D
	if shell_light != null:
		_set_mesh_material(
			shell_light, accent_color, accent_color, 0.38 if visible_content else 0.0
		)


func _add_box(
	parent: Node3D, node_name: String, position: Vector3, size: Vector3, color: Color
) -> MeshInstance3D:
	var box := BoxMesh.new()
	box.size = size
	var mesh := MeshInstance3D.new()
	mesh.name = node_name
	mesh.mesh = box
	mesh.position = position
	mesh.material_override = _material(color)
	mesh.set_meta("visual_only", true)
	parent.add_child(mesh)
	return mesh


func _add_label(
	parent: Node3D, node_name: String, text: String, position: Vector3, font_size: int
) -> Label3D:
	var label := Label3D.new()
	label.name = node_name
	label.text = text
	label.position = position
	label.pixel_size = 0.006
	label.font_size = font_size
	label.modulate = Color(0.96, 0.92, 0.80, 1.0)
	label.outline_size = 5
	label.outline_modulate = Color(0.05, 0.04, 0.03, 1.0)
	label.double_sided = false
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.visible = false
	label.set_meta("caller_owned_text", true)
	label.set_meta("visual_only", true)
	parent.add_child(label)
	return label


func _set_label(label: Label3D, text: String, visible_content: bool) -> void:
	if label == null:
		return
	label.text = text
	label.visible = visible_content


func _set_mesh_material(
	mesh: MeshInstance3D,
	albedo: Color,
	emission: Color = Color.TRANSPARENT,
	emission_energy: float = 0.0
) -> void:
	if mesh == null:
		return
	mesh.material_override = _material(albedo, emission, emission_energy)


func _material(
	albedo: Color, emission: Color = Color.TRANSPARENT, emission_energy: float = 0.0
) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = albedo
	material.roughness = 0.78
	if emission_energy > 0.0:
		material.emission_enabled = true
		material.emission = emission
		material.emission_energy_multiplier = emission_energy
	return material


func _shell() -> Node3D:
	if _store_root == null:
		return null
	return _store_root.get_node_or_null(String(SHELL_NAME)) as Node3D


func _customization_system() -> Node:
	if not is_inside_tree():
		return null
	return get_tree().root.get_node_or_null("StoreCustomizationSystem")


func _morning_note_hint() -> StringName:
	var system: Node = _customization_system()
	if system == null or not system.has_method("get_morning_note_hint"):
		return FEATURED_NONE
	return system.call("get_morning_note_hint") as StringName


func _on_poster_changed(poster_id: StringName) -> void:
	apply_poster(poster_id)


func _on_featured_category_changed(category: StringName) -> void:
	apply_featured_category(category)


func _on_store_child_entered_tree(child: Node) -> void:
	if child.name != SHELL_NAME:
		return
	_ensure_dressing_roots()
	refresh_from_system()
