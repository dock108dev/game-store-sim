## Builds simple 3D packaging from visual-only catalog templates.
class_name ProductVisualCaseBuilder
extends RefCounted

const StarterDetailBuilderScript: GDScript = preload(
	"res://game/scripts/visuals/starter_detail_builder.gd"
)
const VisualValueUtilScript: GDScript = preload(
	"res://game/scripts/visuals/visual_value_util.gd"
)

const CASE_ROOT_NAME: StringName = &"ProductVisualCaseRoot"
const CONSOLE_ROOT_NAME: StringName = &"ProductVisualConsoleBoxRoot"
const CARTRIDGE_ROOT_NAME: StringName = &"ProductVisualCartridgeRoot"

const _FALLBACK_CASE_COLOR := Color(0.78, 0.76, 0.68, 1.0)
const _PANEL_OFFSET: float = 0.002


## Builds a reusable game-case node from a catalog template.
static func build_case(template: Dictionary, _catalog: RefCounted) -> Node3D:
	if template.is_empty():
		return null
	var root := Node3D.new()
	root.name = CASE_ROOT_NAME
	root.set_meta("product_visual_kind", "game_case")
	root.set_meta("template_id", str(template.get("template_id", "")))

	var dims: Vector3 = _case_dimensions(template)
	var body := _box("CaseBody", dims, Color(0.08, 0.075, 0.07, 1.0))
	root.add_child(body)
	root.add_child(
		_box(
			"FrontPanel",
			Vector3(dims.x * 0.92, dims.y * 0.82, _PANEL_OFFSET),
			_color(template.get("front_color", ""), _FALLBACK_CASE_COLOR),
			Vector3(0.0, 0.0, dims.z * 0.52)
		)
	)
	root.add_child(
		_box(
			"SpinePanel",
			Vector3(dims.x * 0.12, dims.y * 0.86, _PANEL_OFFSET),
			_color(template.get("spine_color", ""), Color(0.16, 0.15, 0.13)),
			Vector3(-dims.x * 0.47, 0.0, dims.z * 0.54)
		)
	)

	var stripe: Dictionary = VisualValueUtilScript.dictionary(
		template.get("platform_stripe", {})
	)
	root.add_child(
		_box(
			"PlatformStripe",
			Vector3(dims.x * 0.92, dims.y * 0.12, _PANEL_OFFSET),
			_color(stripe.get("fill_color", ""), Color(0.12, 0.13, 0.14)),
			Vector3(0.0, dims.y * 0.36, dims.z * 0.56)
		)
	)
	root.add_child(
		_box(
			"PlatformAccent",
			Vector3(dims.x * 0.92, dims.y * 0.018, _PANEL_OFFSET),
			_color(stripe.get("accent_color", ""), Color(0.8, 0.8, 0.72)),
			Vector3(0.0, dims.y * 0.295, dims.z * 0.57)
		)
	)

	var title: Dictionary = VisualValueUtilScript.dictionary(template.get("title_block", {}))
	root.add_child(
		_box(
			"TitleBlock",
			Vector3(dims.x * 0.76, dims.y * 0.18, _PANEL_OFFSET),
			_color(title.get("fill_color", ""), Color(0.9, 0.8, 0.34)),
			Vector3(0.0, dims.y * 0.16, dims.z * 0.58)
		)
	)
	root.add_child(
		_label(
			"TitleLabel",
			str(title.get("text", template.get("display_title", ""))),
			_color(title.get("text_color", ""), Color(0.08, 0.08, 0.07)),
			32,
			Vector3(0.0, dims.y * 0.16, dims.z * 0.585),
			0.00155
		)
	)
	root.add_child(
		_label(
			"PlatformLabel",
			str(stripe.get("catalog_label", "")),
			Color(0.93, 0.92, 0.86),
			18,
			Vector3(0.0, dims.y * 0.36, dims.z * 0.59),
			0.00125
		)
	)
	_add_spine_labels(root, template, title, stripe, dims)
	_add_case_edge_details(root, dims)

	_add_symbol(root, VisualValueUtilScript.dictionary(template.get("simple_symbol", {})), dims)
	root.add_child(
		_box(
			"RatingBadge",
			Vector3(dims.x * 0.28, dims.y * 0.09, _PANEL_OFFSET),
			Color(0.96, 0.94, 0.84),
			Vector3(dims.x * 0.27, -dims.y * 0.34, dims.z * 0.59)
		)
	)
	root.add_child(
		_label(
			"BadgeLabel",
			str(template.get("rating_badge", "")),
			Color(0.12, 0.10, 0.08),
			14,
			Vector3(dims.x * 0.27, -dims.y * 0.34, dims.z * 0.595),
			0.001
		)
	)

	if str(template.get("case_shape", "")) == "small_handheld_clamshell":
		root.add_child(
			_box(
				"HingeBand",
				Vector3(dims.x * 0.92, dims.y * 0.035, _PANEL_OFFSET),
				Color(0.11, 0.12, 0.13),
				Vector3(0.0, -dims.y * 0.02, dims.z * 0.6)
			)
		)
	if (
		str(
			VisualValueUtilScript.dictionary(
				template.get("shelf_display", {})
			).get("preferred_facing", "front")
		)
		== "spine"
	):
		root.rotation.y = deg_to_rad(82.0)
	return root


## Builds a reusable console-box node from a platform visual identity.
static func build_console_box(identity: Dictionary) -> Node3D:
	if identity.is_empty():
		return null
	var root := Node3D.new()
	root.name = CONSOLE_ROOT_NAME
	root.set_meta("product_visual_kind", "console_box")
	root.set_meta("platform_visual_id", str(identity.get("platform_visual_id", "")))

	var scale_array: Array = identity.get("prop_scale", [1.0, 0.6, 0.6])
	var dims := Vector3(
		clampf(float(scale_array[0]) * 0.26, 0.16, 0.38),
		clampf(float(scale_array[2]) * 0.18, 0.12, 0.32),
		clampf(float(scale_array[1]) * 0.16, 0.08, 0.22)
	)
	root.add_child(
		_box("ConsoleBoxBody", dims, _color(identity.get("body_color", ""), _FALLBACK_CASE_COLOR))
	)
	root.add_child(
		_box(
			"ConsoleColorStripe",
			Vector3(dims.x * 0.86, dims.y * 0.13, _PANEL_OFFSET),
			_color(identity.get("accent_color", ""), Color(0.45, 0.75, 0.9)),
			Vector3(0.0, dims.y * 0.26, dims.z * 0.52)
		)
	)
	root.add_child(
		_box(
			"ConsoleLabelPlate",
			Vector3(dims.x * 0.66, dims.y * 0.20, _PANEL_OFFSET),
			_color(identity.get("label_plate_color", ""), Color(0.92, 0.9, 0.78)),
			Vector3(0.0, 0.0, dims.z * 0.54)
		)
	)
	root.add_child(
		_box(
			"ConsoleIconMark",
			Vector3(dims.x * 0.18, dims.y * 0.18, _PANEL_OFFSET),
			_color(identity.get("accent_color", ""), Color(0.45, 0.75, 0.9)),
			Vector3(-dims.x * 0.29, -dims.y * 0.25, dims.z * 0.56)
		)
	)
	_add_console_box_side_details(root, identity, dims)
	_add_console_box_accessory_silhouette(root, dims)
	root.add_child(
		_label(
			"ConsolePlatformLabel",
			str(identity.get("used_console_label", identity.get("display_label", ""))),
			Color(0.08, 0.09, 0.08),
			20,
			Vector3(0.0, 0.0, dims.z * 0.565),
			0.00125
		)
	)
	_add_console_box_edge_details(root, dims)
	var silhouette: Dictionary = VisualValueUtilScript.dictionary(identity.get("silhouette", {}))
	if str(silhouette.get("shape", "")).contains("handle"):
		root.add_child(
			_box(
				"ConsoleHandleDetail",
				Vector3(dims.x * 0.42, dims.y * 0.035, _PANEL_OFFSET),
				Color(0.18, 0.18, 0.16),
				Vector3(0.0, dims.y * 0.42, dims.z * 0.57)
			)
		)
	return root


## Builds a loose cartridge node from a platform visual identity.
static func build_cartridge(identity: Dictionary, item: Dictionary = {}) -> Node3D:
	var root := Node3D.new()
	root.name = CARTRIDGE_ROOT_NAME
	root.set_meta("product_visual_kind", "cartridge")
	var platform_visual_id: String = str(identity.get("platform_visual_id", ""))
	if not platform_visual_id.is_empty():
		root.set_meta("platform_visual_id", platform_visual_id)

	var dims: Vector3 = _cartridge_dimensions(identity)
	var body_color: Color = _color(identity.get("body_color", ""), Color(0.13, 0.14, 0.13))
	var accent_color: Color = _color(identity.get("accent_color", ""), Color(0.45, 0.75, 0.9))
	root.add_child(_box("CartridgeShell", dims, body_color))
	root.add_child(
		_box(
			"CartridgeLabel",
			Vector3(dims.x * 0.72, dims.y * 0.44, _PANEL_OFFSET),
			_color(identity.get("label_plate_color", ""), Color(0.86, 0.84, 0.72)),
			Vector3(0.0, dims.y * 0.02, dims.z * 0.56)
		)
	)
	root.add_child(
		_box(
			"CartridgeAccentStripe",
			Vector3(dims.x * 0.72, dims.y * 0.08, _PANEL_OFFSET),
			accent_color,
			Vector3(0.0, dims.y * 0.27, dims.z * 0.58)
		)
	)
	root.add_child(
		_box(
			"CartridgeContactStrip",
			Vector3(dims.x * 0.58, dims.y * 0.08, _PANEL_OFFSET),
			Color(0.82, 0.64, 0.30, 1.0),
			Vector3(0.0, -dims.y * 0.42, dims.z * 0.58)
		)
	)
	root.add_child(
		_box(
			"CartridgeTopNotch",
			Vector3(dims.x * 0.22, dims.y * 0.055, _PANEL_OFFSET),
			body_color.darkened(0.18),
			Vector3(0.0, dims.y * 0.42, dims.z * 0.59)
		)
	)
	var label_text: String = str(
		item.get(
			"display_name",
			identity.get("shelf_label", identity.get("display_label", "LOOSE CART"))
		)
	).to_upper()
	root.add_child(
		_label(
			"CartridgeTitleLabel",
			label_text,
			Color(0.08, 0.08, 0.07),
			14,
			Vector3(0.0, dims.y * 0.02, dims.z * 0.59),
			0.00075
		)
	)
	return root


static func _case_dimensions(template: Dictionary) -> Vector3:
	var shelf_display: Dictionary = VisualValueUtilScript.dictionary(
		template.get("shelf_display", {})
	)
	var scale_array: Array = shelf_display.get("scale", [1.0, 1.0, 0.12])
	var width: float = clampf(float(scale_array[0]) * 0.16, 0.08, 0.20)
	var height: float = clampf(float(scale_array[1]) * 0.22, 0.12, 0.28)
	var depth: float = clampf(float(scale_array[2]) * 0.10, 0.008, 0.035)
	match str(template.get("case_shape", "")):
		"compact_square_case":
			height = minf(height, width * 1.45)
		"small_handheld_clamshell":
			depth *= 1.25
		"wide_disc_case":
			width = minf(width * 1.12, 0.20)
			height = minf(height, width * 1.25)
	return Vector3(width, height, depth)


static func _cartridge_dimensions(identity: Dictionary) -> Vector3:
	var scale_array: Array = identity.get("prop_scale", [1.0, 0.55, 0.32])
	var width: float = clampf(float(scale_array[0]) * 0.11, 0.09, 0.15)
	var height: float = clampf(float(scale_array[2]) * 0.075, 0.07, 0.12)
	var depth: float = clampf(float(scale_array[1]) * 0.035, 0.014, 0.035)
	var profile: String = str(
		VisualValueUtilScript.dictionary(identity.get("silhouette", {})).get("profile", "")
	)
	if profile.contains("wide"):
		width = minf(width * 1.18, 0.16)
	if profile.contains("small") or profile.contains("folded"):
		height = minf(height * 0.86, 0.095)
	return Vector3(width, height, depth)


static func _add_spine_labels(
	root: Node3D, template: Dictionary, title: Dictionary, stripe: Dictionary, dims: Vector3
) -> void:
	var spine_label: Dictionary = VisualValueUtilScript.dictionary(
		template.get("spine_label", {})
	)
	var spine_text: String = str(
		spine_label.get("text", title.get("text", template.get("display_title", "")))
	)
	var platform_text: String = str(
		spine_label.get("platform_text", stripe.get("catalog_label", ""))
	)
	var text_color: Color = _color(spine_label.get("text_color", ""), Color(0.96, 0.92, 0.78, 1.0))
	var title_label := _label(
		"SpineTitleLabel",
		spine_text,
		text_color,
		18,
		Vector3(-dims.x * 0.47, 0.0, dims.z * 0.607),
		0.0009
	)
	title_label.rotation.z = deg_to_rad(90.0)
	root.add_child(title_label)

	var platform_label := _label(
		"SpinePlatformLabel",
		platform_text,
		text_color,
		10,
		Vector3(-dims.x * 0.47, dims.y * 0.34, dims.z * 0.609),
		0.00065
	)
	platform_label.rotation.z = deg_to_rad(90.0)
	root.add_child(platform_label)


static func _add_case_edge_details(root: Node3D, dims: Vector3) -> void:
	var seam_z: float = dims.z * 0.602
	var seam_depth: float = StarterDetailBuilderScript.PRODUCT_PANEL_OFFSET
	StarterDetailBuilderScript.add_box_detail(
		root,
		"CaseTopSeam",
		Vector3(0.0, dims.y * 0.455, seam_z),
		Vector3(dims.x * 0.84, dims.y * 0.012, seam_depth),
		StarterDetailBuilderScript.FAMILY_SHADOW_ACCENT,
		StarterDetailBuilderScript.ROLE_SEAM
	)
	StarterDetailBuilderScript.add_box_detail(
		root,
		"CaseBottomSeam",
		Vector3(0.0, -dims.y * 0.455, seam_z),
		Vector3(dims.x * 0.84, dims.y * 0.012, seam_depth),
		StarterDetailBuilderScript.FAMILY_SHADOW_ACCENT,
		StarterDetailBuilderScript.ROLE_SEAM
	)
	StarterDetailBuilderScript.add_box_detail(
		root,
		"CaseSpineFold",
		Vector3(-dims.x * 0.405, 0.0, seam_z + 0.001),
		Vector3(dims.x * 0.018, dims.y * 0.76, seam_depth),
		StarterDetailBuilderScript.FAMILY_SHADOW_ACCENT,
		StarterDetailBuilderScript.ROLE_SEAM
	)


static func _add_console_box_edge_details(root: Node3D, dims: Vector3) -> void:
	var seam_z: float = dims.z * 0.575
	StarterDetailBuilderScript.add_box_detail(
		root,
		"ConsoleBoxTopSeam",
		Vector3(0.0, dims.y * 0.435, seam_z),
		Vector3(dims.x * 0.82, dims.y * 0.014, StarterDetailBuilderScript.PRODUCT_PANEL_OFFSET),
		StarterDetailBuilderScript.FAMILY_SHADOW_ACCENT,
		StarterDetailBuilderScript.ROLE_SEAM
	)
	StarterDetailBuilderScript.add_box_detail(
		root,
		"ConsoleBoxBottomSeam",
		Vector3(0.0, -dims.y * 0.435, seam_z),
		Vector3(dims.x * 0.82, dims.y * 0.014, StarterDetailBuilderScript.PRODUCT_PANEL_OFFSET),
		StarterDetailBuilderScript.FAMILY_SHADOW_ACCENT,
		StarterDetailBuilderScript.ROLE_SEAM
	)
	StarterDetailBuilderScript.add_box_detail(
		root,
		"ConsoleBoxCornerLabel",
		Vector3(dims.x * 0.30, -dims.y * 0.31, seam_z + 0.001),
		Vector3(dims.x * 0.18, dims.y * 0.07, StarterDetailBuilderScript.PRODUCT_PANEL_OFFSET),
		StarterDetailBuilderScript.FAMILY_PAPER,
		StarterDetailBuilderScript.ROLE_LABEL
	)


static func _add_console_box_side_details(
	root: Node3D, identity: Dictionary, dims: Vector3
) -> void:
	var side_x: float = -dims.x * 0.51
	var accent_color: Color = _color(identity.get("accent_color", ""), Color(0.45, 0.75, 0.9))
	StarterDetailBuilderScript.add_box_detail(
		root,
		"ConsoleSideSpineLabel",
		Vector3(side_x, 0.0, 0.0),
		Vector3(StarterDetailBuilderScript.PRODUCT_PANEL_OFFSET, dims.y * 0.56, dims.z * 0.58),
		StarterDetailBuilderScript.FAMILY_PAPER,
		StarterDetailBuilderScript.ROLE_LABEL
	)
	var stripe := _box(
		"ConsoleSideSpineStripe",
		Vector3(StarterDetailBuilderScript.PRODUCT_PANEL_OFFSET, dims.y * 0.12, dims.z * 0.70),
		accent_color,
		Vector3(side_x - 0.001, dims.y * 0.32, 0.0)
	)
	root.add_child(stripe)


static func _add_console_box_accessory_silhouette(root: Node3D, dims: Vector3) -> void:
	var silhouette_color := Color(0.09, 0.095, 0.09, 1.0)
	var front_z: float = dims.z * 0.585
	root.add_child(
		_box(
			"ConsoleControllerSilhouette",
			Vector3(dims.x * 0.30, dims.y * 0.035, _PANEL_OFFSET),
			silhouette_color,
			Vector3(dims.x * 0.20, -dims.y * 0.25, front_z)
		)
	)
	root.add_child(
		_box(
			"ConsoleCableSilhouette",
			Vector3(dims.x * 0.22, dims.y * 0.012, _PANEL_OFFSET),
			silhouette_color,
			Vector3(dims.x * 0.02, -dims.y * 0.24, front_z + 0.001)
		)
	)


static func _add_symbol(root: Node3D, symbol: Dictionary, dims: Vector3) -> void:
	var color: Color = _color(symbol.get("color", ""), Color(0.9, 0.65, 0.25))
	var shape: String = str(symbol.get("shape", ""))
	var center := Vector3(0.0, -dims.y * 0.08, dims.z * 0.595)
	match shape:
		"tilted_wheel_with_three_sparks":
			var wheel := _box(
				"SymbolMark", Vector3(dims.x * 0.24, dims.y * 0.10, _PANEL_OFFSET), color, center
			)
			wheel.rotation.z = deg_to_rad(-18.0)
			root.add_child(wheel)
			for i: int in range(3):
				root.add_child(
					_box(
						"SymbolSpark%d" % i,
						Vector3(dims.x * 0.045, dims.y * 0.045, _PANEL_OFFSET),
						color,
						(
							center
							+ Vector3(
								dims.x * (0.18 + float(i) * 0.05),
								dims.y * (0.10 - float(i) * 0.04),
								0.002
							)
						)
					)
				)
		"three_marbles_orbiting_star":
			root.add_child(
				_box(
					"SymbolMark",
					Vector3(dims.x * 0.16, dims.y * 0.16, _PANEL_OFFSET),
					color,
					center
				)
			)
			for i: int in range(3):
				root.add_child(
					_box(
						"SymbolOrb%d" % i,
						Vector3(dims.x * 0.06, dims.y * 0.06, _PANEL_OFFSET),
						color.lightened(0.18),
						(
							center
							+ Vector3(
								cos(float(i) * TAU / 3.0) * dims.x * 0.18,
								sin(float(i) * TAU / 3.0) * dims.y * 0.13,
								0.002
							)
						)
					)
				)
		"open_notebook_with_lightning_mark":
			root.add_child(
				_box(
					"SymbolPageA",
					Vector3(dims.x * 0.15, dims.y * 0.20, _PANEL_OFFSET),
					Color(0.95, 0.94, 0.86),
					center + Vector3(-dims.x * 0.08, 0.0, 0.0)
				)
			)
			root.add_child(
				_box(
					"SymbolPageB",
					Vector3(dims.x * 0.15, dims.y * 0.20, _PANEL_OFFSET),
					Color(0.95, 0.94, 0.86),
					center + Vector3(dims.x * 0.08, 0.0, 0.0)
				)
			)
			root.add_child(
				_box(
					"SymbolMark",
					Vector3(dims.x * 0.07, dims.y * 0.22, _PANEL_OFFSET),
					color,
					center
				)
			)
		"ringed_star_with_tiny_can":
			root.add_child(
				_box(
					"SymbolMark",
					Vector3(dims.x * 0.16, dims.y * 0.16, _PANEL_OFFSET),
					color,
					center
				)
			)
			root.add_child(
				_box(
					"SymbolRing",
					Vector3(dims.x * 0.34, dims.y * 0.045, _PANEL_OFFSET),
					color.lightened(0.18),
					center + Vector3(0.0, 0.0, 0.002)
				)
			)
			root.add_child(
				_box(
					"SymbolCan",
					Vector3(dims.x * 0.075, dims.y * 0.12, _PANEL_OFFSET),
					Color(0.95, 0.92, 0.78),
					center + Vector3(dims.x * 0.18, -dims.y * 0.11, 0.004)
				)
			)
		"signal_antenna_inside_hex_shield":
			root.add_child(
				_box(
					"SymbolMark",
					Vector3(dims.x * 0.22, dims.y * 0.20, _PANEL_OFFSET),
					color,
					center
				)
			)
			root.add_child(
				_box(
					"SymbolAntenna",
					Vector3(dims.x * 0.035, dims.y * 0.22, _PANEL_OFFSET),
					Color(0.96, 0.94, 0.84),
					center + Vector3(0.0, 0.0, 0.002)
				)
			)
			root.add_child(
				_box(
					"SymbolSignalA",
					Vector3(dims.x * 0.14, dims.y * 0.035, _PANEL_OFFSET),
					color.lightened(0.2),
					center + Vector3(dims.x * 0.12, dims.y * 0.08, 0.004)
				)
			)
			root.add_child(
				_box(
					"SymbolSignalB",
					Vector3(dims.x * 0.20, dims.y * 0.035, _PANEL_OFFSET),
					color.lightened(0.32),
					center + Vector3(dims.x * 0.15, dims.y * 0.15, 0.006)
				)
			)
		_:
			root.add_child(
				_box(
					"SymbolMark",
					Vector3(dims.x * 0.30, dims.y * 0.14, _PANEL_OFFSET),
					color,
					center
				)
			)


static func _box(
	name: String, size: Vector3, color: Color, position: Vector3 = Vector3.ZERO
) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.position = position
	mesh_instance.material_override = _material(color)
	return mesh_instance


static func _label(
	name: String, text: String, color: Color, font_size: int, position: Vector3, pixel_size: float
) -> Label3D:
	var label := Label3D.new()
	label.name = name
	label.text = text
	label.modulate = color
	label.font_size = font_size
	label.pixel_size = pixel_size
	label.no_depth_test = false
	label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.position = position
	return label


static func _material(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.72
	mat.metallic = 0.0
	return mat


static func _color(value: Variant, fallback: Color) -> Color:
	if value is Color:
		return value as Color
	var text: String = str(value)
	if text.is_valid_html_color():
		return Color.html(text)
	return fallback
