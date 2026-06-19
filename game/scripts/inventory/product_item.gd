extends "res://scripts/interaction/interactable.gd"

const ProductVisualRulesScript := preload("res://scripts/inventory/product_visual_rules.gd")

@export var product: ProductDefinition
@export var instance_id: String = ""
@export var current_price_cents: int = 0
@export var cost_basis_cents: int = 0
@export var location_id: String = "receiving_box_001"
@export var serial_id: String = ""
@export var expected_serial_id: String = ""
@export var suspicious_event_id: String = ""

var _default_collision_layer: int = 1
var _default_collision_mask: int = 1
var _is_hovered: bool = false
var _visual_profile: Dictionary = {}


func _ready() -> void:
	_default_collision_layer = collision_layer
	_default_collision_mask = collision_mask
	_set_hover_highlight_visible(_is_hovered)

	if product == null:
		return

	display_name = product.display_name
	if current_price_cents <= 0:
		current_price_cents = product.suggested_price_cents
	if cost_basis_cents <= 0:
		cost_basis_cents = product.cost_basis_cents
	if location_id.strip_edges().is_empty():
		location_id = product.default_location_id
	apply_product_visuals()


func get_visual_profile() -> Dictionary:
	if _visual_profile.is_empty() and product != null:
		_visual_profile = ProductVisualRulesScript.build_profile(product)
	return _visual_profile.duplicate(true)


func apply_product_visuals() -> void:
	if product == null:
		return

	_visual_profile = ProductVisualRulesScript.build_profile(product)

	_apply_box_mesh_size("CaseMesh", _visual_profile.get("case_size", Vector3(0.24, 0.34, 0.04)))
	_apply_collision_size(_visual_profile.get("case_size", Vector3(0.24, 0.34, 0.04)))
	_apply_cover_panel_geometry()
	_set_node_visible("CoverLabelMesh", bool(_visual_profile.get("show_cover", true)))
	_set_node_visible("SpineStripeMesh", bool(_visual_profile.get("show_spine", true)))
	_set_node_visible("PlatformBandMesh", bool(_visual_profile.get("show_platform_band", true)))
	_set_node_visible("PriceStickerMesh", bool(_visual_profile.get("show_price_sticker", true)))
	_apply_mesh_material("CaseMesh", _visual_profile.get("case_body_color", Color(0.035, 0.055, 0.07, 1.0)))
	_apply_mesh_material("CoverLabelMesh", _visual_profile.get("cover_base_color", Color(0.22, 0.74, 0.62, 1.0)))
	_apply_mesh_material("SpineStripeMesh", _visual_profile.get("platform_color", Color(0.96, 0.82, 0.38, 1.0)))
	_apply_mesh_material("PlatformBandMesh", _visual_profile.get("platform_color", Color(0.16, 0.32, 0.92, 1.0)))
	_apply_mesh_material("PriceStickerMesh", _visual_profile.get("price_sticker_color", Color(0.98, 0.9, 0.62, 1.0)))
	_apply_base_packaging_layers()

	var container_variant := str(_visual_profile.get("container_variant", ""))
	var media_variant := str(_visual_profile.get("media_variant", ""))
	var state_variant := str(_visual_profile.get("state_variant", ""))
	var show_cover_detail := bool(_visual_profile.get("show_cover", true))

	_set_variant_box(
		"MediaVariantMesh",
		media_variant != "" and media_variant != ProductVisualRulesScript.VARIANT_SERVICE_TICKET,
		_visual_profile.get("media_size", Vector3(0.08, 0.08, 0.012)),
		_visual_profile.get("media_position", Vector3(-0.035, 0.112, -0.044)),
		_get_variant_color(media_variant)
	)
	_set_variant_box(
		"BoxVariantMesh",
		container_variant == ProductVisualRulesScript.VARIANT_BOX,
		_visual_profile.get("box_size", Vector3(0.22, 0.09, 0.025)),
		_visual_profile.get("box_position", Vector3(0.0, 0.062, -0.037)),
		Color(0.52, 0.58, 0.64, 1.0)
	)
	_set_variant_box(
		"SealWrapMesh",
		state_variant == ProductVisualRulesScript.VARIANT_SEALED,
		_visual_profile.get("seal_size", Vector3(0.255, 0.355, 0.014)),
		_visual_profile.get("seal_position", Vector3(0.0, 0.17, -0.039)),
		Color(0.8, 0.95, 1.0, 0.36)
	)
	_set_variant_box(
		"LooseVariantMesh",
		state_variant == ProductVisualRulesScript.VARIANT_LOOSE,
		_visual_profile.get("loose_size", Vector3(0.11, 0.05, 0.016)),
		_visual_profile.get("loose_position", Vector3(0.0, 0.068, -0.04)),
		Color(0.9, 0.78, 0.36, 1.0)
	)
	_set_variant_box(
		"ServiceTicketVariantMesh",
		container_variant == ProductVisualRulesScript.VARIANT_SERVICE_TICKET,
		_visual_profile.get("service_ticket_size", Vector3(0.18, 0.24, 0.012)),
		_visual_profile.get("service_ticket_position", Vector3(0.0, 0.18, -0.04)),
		Color(0.98, 0.93, 0.72, 1.0)
	)
	_set_variant_box(
		"GenreAccentMesh",
		bool(_visual_profile.get("show_genre_accent", true)),
		Vector3(0.165, 0.035, 0.014),
		Vector3(0.006, 0.09, -0.056),
		_visual_profile.get("genre_color", Color(0.72, 0.62, 0.5, 1.0))
	)
	_set_variant_box(
		"CoverHeroShapeMesh",
		show_cover_detail,
		Vector3(0.078, 0.078, 0.014),
		Vector3(-0.042, 0.208, -0.058),
		_visual_profile.get("genre_accent_color", Color(0.88, 0.8, 0.62, 1.0))
	)
	_set_variant_box(
		"CoverDetailLineA",
		show_cover_detail,
		Vector3(0.118, 0.012, 0.014),
		Vector3(0.022, 0.248, -0.059),
		_visual_profile.get("platform_accent_color", Color(0.78, 0.92, 1.0, 1.0))
	)
	_set_variant_box(
		"CoverDetailLineB",
		show_cover_detail,
		Vector3(0.088, 0.012, 0.014),
		Vector3(0.036, 0.152, -0.059),
		_visual_profile.get("platform_accent_color", Color(0.78, 0.92, 1.0, 1.0))
	)
	_set_variant_box(
		"UsedStickerMesh",
		bool(_visual_profile.get("show_used_sticker", false)),
		Vector3(0.086, 0.036, 0.016),
		Vector3(-0.044, 0.074, -0.061),
		_visual_profile.get("used_sticker_color", Color(0.98, 0.82, 0.36, 1.0))
	)
	_apply_cover_art_layers()
	_apply_retail_box_layers()
	_apply_duplicate_stack_layers()

	var condition_cues := _visual_profile.get("condition_cues", []) as Array
	_set_condition_cue_box(
		"ScratchCueMesh",
		condition_cues.has(ProductVisualRulesScript.CUE_SCRATCHES),
		Vector3(0.16, 0.012, 0.01),
		Vector3(0.0, 0.185, -0.052),
		Color(0.74, 0.77, 0.74, 1.0)
	)
	_set_condition_cue_box(
		"MissingManualCueMesh",
		condition_cues.has(ProductVisualRulesScript.CUE_MISSING_MANUAL),
		Vector3(0.06, 0.078, 0.012),
		Vector3(0.07, 0.19, -0.054),
		Color(0.98, 0.88, 0.58, 1.0)
	)
	_set_condition_cue_box(
		"LooseMediaCueMesh",
		condition_cues.has(ProductVisualRulesScript.CUE_LOOSE_MEDIA),
		Vector3(0.105, 0.028, 0.012),
		Vector3(-0.025, 0.055, -0.055),
		Color(0.88, 0.62, 0.3, 1.0)
	)
	_set_condition_cue_box(
		"DamagedLabelCueMesh",
		condition_cues.has(ProductVisualRulesScript.CUE_DAMAGED_LABEL),
		Vector3(0.082, 0.034, 0.012),
		Vector3(-0.055, 0.275, -0.056),
		Color(0.45, 0.2, 0.16, 1.0)
	)
	_set_condition_cue_box(
		"ResealCueMesh",
		condition_cues.has(ProductVisualRulesScript.CUE_RESEALED),
		Vector3(0.19, 0.018, 0.012),
		Vector3(0.0, 0.31, -0.057),
		Color(0.75, 0.95, 1.0, 0.56)
	)
	_set_condition_cue_box(
		"SerialRiskCueMesh",
		condition_cues.has(ProductVisualRulesScript.CUE_SERIAL_RISK) or has_serial_mismatch(),
		Vector3(0.052, 0.052, 0.013),
		Vector3(0.082, 0.075, -0.058),
		Color(0.95, 0.28, 0.18, 1.0)
	)
	_apply_case_title_label()
	_apply_case_price_label()
	_apply_used_sticker_label()
	_apply_price_tag_label()


func get_price_tag_lines() -> Array[String]:
	if product == null:
		return []

	var lines: Array[String] = [
		_get_category_label(product.category),
		"%s $%0.2f" % [product.platform, current_price_cents / 100.0],
	]
	var badges := _get_price_tag_badges()
	if not badges.is_empty():
		lines.append(" ".join(badges))

	return lines


func get_case_price_label_text() -> String:
	if product == null:
		return ""
	return "%s $%0.2f" % [_get_condition_label(), current_price_cents / 100.0]


func get_interaction_prompt() -> String:
	return _get_inspect_prompt()


func get_interaction_prompt_for_actor(actor: Node) -> String:
	if _can_actor_pick_up(actor):
		return "Click Pick Up %s" % product.display_name

	return _get_inspect_prompt()


func interact_with_actor(actor: Node) -> String:
	if _can_actor_pick_up(actor):
		if actor.pick_up_item(self):
			return "Picked up %s" % product.display_name

	return interact()


func set_held() -> void:
	location_id = "held"
	set_collision_enabled(false)


func set_stocked(slot_id: String) -> void:
	location_id = slot_id
	set_collision_enabled(true)


func set_customer_held(customer_id: String) -> void:
	location_id = "customer:%s" % customer_id
	set_collision_enabled(false)


func set_sold() -> void:
	location_id = "sold"
	set_collision_enabled(false)


func set_hovered(is_hovered: bool) -> void:
	_is_hovered = is_hovered
	_set_hover_highlight_visible(_is_hovered)
	if product != null:
		_apply_price_tag_label()


func is_hovered() -> bool:
	return _is_hovered


func has_serial_mismatch() -> bool:
	return not serial_id.strip_edges().is_empty() \
		and not expected_serial_id.strip_edges().is_empty() \
		and serial_id.strip_edges() != expected_serial_id.strip_edges()


func get_serial_status_text() -> String:
	if serial_id.strip_edges().is_empty():
		return "Serial untracked"

	if has_serial_mismatch():
		return "Serial mismatch %s expected %s" % [
			serial_id.strip_edges(),
			expected_serial_id.strip_edges(),
		]

	return "Serial %s" % serial_id.strip_edges()


func get_suspicious_event_id() -> String:
	if not suspicious_event_id.strip_edges().is_empty():
		return suspicious_event_id.strip_edges()

	if not instance_id.strip_edges().is_empty():
		return "serial_mismatch_%s" % instance_id.strip_edges()

	return "serial_mismatch_unknown_item"


func flag_serial_mismatch(event_log: Node) -> Dictionary:
	if not has_serial_mismatch():
		return {}

	if event_log == null or not event_log.has_method("flag_event"):
		return {}

	var product_id := ""
	var product_name := display_name
	if product != null:
		product_id = product.product_id
		product_name = product.display_name

	return event_log.flag_event(
		get_suspicious_event_id(),
		"Mismatched serial for %s" % product_name,
		"inventory",
		"medium",
		{
			"instance_id": instance_id,
			"product_id": product_id,
			"serial_id": serial_id.strip_edges(),
			"expected_serial_id": expected_serial_id.strip_edges(),
			"location_id": location_id,
		}
	)


func set_collision_enabled(is_enabled: bool) -> void:
	collision_layer = _default_collision_layer if is_enabled else 0
	collision_mask = _default_collision_mask if is_enabled else 0

	for child in find_children("*", "CollisionShape3D", true, false):
		var shape := child as CollisionShape3D
		shape.disabled = not is_enabled


func _set_hover_highlight_visible(is_visible: bool) -> void:
	var highlight := get_node_or_null("HoverHighlight") as Node3D
	if highlight != null:
		highlight.visible = is_visible


func _set_node_visible(node_name: String, is_visible: bool) -> void:
	var node := get_node_or_null(node_name) as Node3D
	if node != null:
		node.visible = is_visible


func _apply_box_mesh_size(node_name: String, size: Vector3) -> void:
	var node := get_node_or_null(node_name) as MeshInstance3D
	if node == null:
		return

	var box_mesh := node.mesh as BoxMesh
	if box_mesh == null:
		return

	var local_mesh := box_mesh.duplicate() as BoxMesh
	local_mesh.size = size
	node.mesh = local_mesh
	node.position.y = size.y / 2.0


func _apply_collision_size(size: Vector3) -> void:
	var collision_shape := get_node_or_null("CollisionShape3D") as CollisionShape3D
	if collision_shape == null:
		return

	var box_shape := collision_shape.shape as BoxShape3D
	if box_shape == null:
		return

	var local_shape := box_shape.duplicate() as BoxShape3D
	local_shape.size = Vector3(size.x + 0.02, size.y + 0.02, size.z + 0.015)
	collision_shape.shape = local_shape
	collision_shape.position.y = local_shape.size.y / 2.0


func _apply_cover_panel_geometry() -> void:
	var case_size: Vector3 = _visual_profile.get("case_size", Vector3(0.24, 0.34, 0.04))
	var container_variant := str(_visual_profile.get("container_variant", ""))
	var cover_size := Vector3(case_size.x * 0.74, case_size.y * 0.74, 0.01)
	var cover_position := Vector3(0.0, case_size.y * 0.56, _front_z(0.006))

	if container_variant == ProductVisualRulesScript.VARIANT_BOX:
		cover_size = Vector3(case_size.x * 0.72, case_size.y * 0.62, 0.012)
		cover_position = Vector3(0.0, case_size.y * 0.55, _front_z(0.008))
	elif container_variant == ProductVisualRulesScript.VARIANT_LOOSE:
		cover_size = Vector3(case_size.x * 0.7, case_size.y * 0.7, 0.008)
		cover_position = Vector3(0.0, case_size.y * 0.55, _front_z(0.005))

	_set_mesh_box_geometry("CoverLabelMesh", cover_size, cover_position)

	if container_variant == ProductVisualRulesScript.VARIANT_CASE:
		_set_mesh_box_geometry(
			"SpineStripeMesh",
			Vector3(case_size.x * 0.115, case_size.y * 0.88, 0.012),
			Vector3(-case_size.x * 0.43, case_size.y * 0.56, _front_z(0.011))
		)
		_set_mesh_box_geometry(
			"PlatformBandMesh",
			Vector3(case_size.x * 0.68, case_size.y * 0.078, 0.012),
			Vector3(case_size.x * 0.05, case_size.y * 0.92, _front_z(0.012))
		)
		_set_mesh_box_geometry(
			"PriceStickerMesh",
			Vector3(case_size.x * 0.22, case_size.y * 0.112, 0.012),
			Vector3(case_size.x * 0.28, case_size.y * 0.22, _front_z(0.014))
		)
	elif container_variant == ProductVisualRulesScript.VARIANT_BOX:
		_set_mesh_box_geometry(
			"PlatformBandMesh",
			Vector3(case_size.x * 0.82, case_size.y * 0.095, 0.012),
			Vector3(0.0, case_size.y * 0.88, _front_z(0.014))
		)
		_set_mesh_box_geometry(
			"PriceStickerMesh",
			Vector3(case_size.x * 0.2, case_size.y * 0.13, 0.012),
			Vector3(case_size.x * 0.31, case_size.y * 0.2, _front_z(0.016))
		)


func _set_mesh_box_geometry(node_name: String, size: Vector3, position: Vector3) -> void:
	var node := get_node_or_null(node_name) as MeshInstance3D
	if node == null:
		return

	var box_mesh := node.mesh as BoxMesh
	if box_mesh == null:
		return

	var local_mesh := box_mesh.duplicate() as BoxMesh
	local_mesh.size = size
	node.mesh = local_mesh
	node.position = position


func _apply_mesh_material(node_name: String, color: Color) -> void:
	var node := get_node_or_null(node_name) as MeshInstance3D
	if node == null:
		return

	var mesh := node.mesh as BoxMesh
	if mesh == null:
		return

	var local_mesh := mesh.duplicate() as BoxMesh
	local_mesh.material = _make_material(color)
	node.mesh = local_mesh


func _set_variant_box(
	node_name: String,
	is_visible: bool,
	size: Vector3,
	position: Vector3,
	color: Color
) -> void:
	var node := _get_or_create_variant_node(node_name)
	node.visible = is_visible
	node.position = position

	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = _make_material(color)
	node.mesh = mesh


func _set_variant_disc(
	node_name: String,
	is_visible: bool,
	radius: float,
	height: float,
	position: Vector3,
	color: Color
) -> void:
	var node := _get_or_create_variant_node(node_name)
	node.visible = is_visible
	node.position = position
	node.rotation_degrees = Vector3(90.0, 0.0, 0.0)

	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 24
	mesh.material = _make_material(color)
	node.mesh = mesh


func _set_condition_cue_box(
	node_name: String,
	is_visible: bool,
	size: Vector3,
	position: Vector3,
	color: Color
) -> void:
	_set_variant_box(node_name, is_visible, size, position, color)


func _apply_base_packaging_layers() -> void:
	var container_variant := str(_visual_profile.get("container_variant", ""))
	var is_case := container_variant == ProductVisualRulesScript.VARIANT_CASE
	var is_box := container_variant == ProductVisualRulesScript.VARIANT_BOX
	var case_size: Vector3 = _visual_profile.get("case_size", Vector3(0.24, 0.34, 0.04))
	var edge_color: Color = _visual_profile.get("platform_accent_color", Color(0.86, 0.9, 0.92, 1.0))
	var shadow_color := Color(0.01, 0.014, 0.018, 1.0)

	_set_variant_box(
		"CaseTopBevelMesh",
		is_case,
		Vector3(case_size.x * 0.9, 0.012, 0.013),
		Vector3(0.0, case_size.y - 0.012, _front_z(0.015)),
		edge_color
	)
	_set_variant_box(
		"CaseBottomBevelMesh",
		is_case,
		Vector3(case_size.x * 0.9, 0.01, 0.013),
		Vector3(0.0, 0.013, _front_z(0.015)),
		shadow_color
	)
	_set_variant_box(
		"CaseRightBevelMesh",
		is_case,
		Vector3(0.012, case_size.y * 0.84, 0.013),
		Vector3(case_size.x * 0.45, case_size.y * 0.52, _front_z(0.015)),
		edge_color.darkened(0.18)
	)
	_set_variant_box(
		"CaseSpineHingeMesh",
		is_case,
		Vector3(0.012, case_size.y * 0.86, 0.014),
		Vector3(-case_size.x * 0.49, case_size.y * 0.54, _front_z(0.017)),
		shadow_color
	)
	_set_variant_box(
		"CaseInnerCoverPanelMesh",
		is_case,
		Vector3(case_size.x * 0.64, case_size.y * 0.61, 0.012),
		Vector3(case_size.x * 0.06, case_size.y * 0.51, _front_z(0.018)),
		_visual_profile.get("cover_base_color", Color(0.2, 0.5, 0.6, 1.0)).darkened(0.12)
	)
	_set_variant_box(
		"BoxSidePanelMesh",
		is_box,
		Vector3(case_size.x * 0.08, case_size.y * 0.86, 0.014),
		Vector3(-case_size.x * 0.45, case_size.y * 0.52, _front_z(0.018)),
		_visual_profile.get("platform_color", Color(0.02, 0.43, 0.42, 1.0))
	)
	_set_variant_box(
		"BoxTopFlapMesh",
		is_box,
		Vector3(case_size.x * 0.76, 0.014, 0.014),
		Vector3(case_size.x * 0.04, case_size.y * 0.96, _front_z(0.018)),
		edge_color
	)


func _apply_cover_art_layers() -> void:
	var container_variant := str(_visual_profile.get("container_variant", ""))
	var is_case := container_variant == ProductVisualRulesScript.VARIANT_CASE
	var art_key := str(_visual_profile.get("product_art_key", ""))
	var genre_id := str(_visual_profile.get("genre_id", ""))
	var case_size: Vector3 = _visual_profile.get("case_size", Vector3(0.24, 0.34, 0.04))
	var front_z := _front_z(0.03)
	var sports := is_case and (art_key == "footy_2002" or genre_id == ProductVisualRulesScript.GENRE_SPORTS)
	var adventure := is_case and (art_key == "critter_quest_ii" or genre_id == ProductVisualRulesScript.GENRE_RPG_ADVENTURE)
	var platform_accent: Color = _visual_profile.get("platform_accent_color", Color(0.98, 0.9, 0.72, 1.0))

	_set_variant_box(
		"CoverFieldStripeA",
		sports,
		Vector3(case_size.x * 0.58, 0.01, 0.012),
		Vector3(case_size.x * 0.05, case_size.y * 0.6, front_z),
		Color(0.92, 0.98, 0.9, 1.0)
	)
	_set_variant_box(
		"CoverFieldStripeB",
		sports,
		Vector3(0.01, case_size.y * 0.36, 0.012),
		Vector3(case_size.x * 0.07, case_size.y * 0.5, front_z - 0.001),
		Color(0.92, 0.98, 0.9, 1.0)
	)
	_set_variant_disc(
		"CoverSportsBallMesh",
		sports,
		case_size.x * 0.085,
		0.01,
		Vector3(case_size.x * 0.18, case_size.y * 0.58, front_z - 0.002),
		Color(0.96, 0.96, 0.92, 1.0)
	)
	_set_variant_box(
		"CoverSportsPlayerBodyMesh",
		sports,
		Vector3(case_size.x * 0.11, case_size.y * 0.24, 0.012),
		Vector3(-case_size.x * 0.1, case_size.y * 0.52, front_z - 0.003),
		Color(0.045, 0.06, 0.055, 1.0)
	)
	_set_variant_disc(
		"CoverSportsPlayerHeadMesh",
		sports,
		case_size.x * 0.046,
		0.01,
		Vector3(-case_size.x * 0.1, case_size.y * 0.68, front_z - 0.004),
		Color(0.045, 0.06, 0.055, 1.0)
	)
	_set_variant_box(
		"CoverAdventureHorizonMesh",
		adventure,
		Vector3(case_size.x * 0.58, case_size.y * 0.09, 0.012),
		Vector3(case_size.x * 0.04, case_size.y * 0.4, front_z),
		Color(0.22, 0.18, 0.34, 1.0)
	)
	_set_variant_disc(
		"CoverCritterBodyMesh",
		adventure,
		case_size.x * 0.13,
		0.012,
		Vector3(-case_size.x * 0.06, case_size.y * 0.58, front_z - 0.003),
		Color(0.98, 0.72, 0.32, 1.0)
	)
	_set_variant_box(
		"CoverCritterEarA",
		adventure,
		Vector3(case_size.x * 0.048, case_size.y * 0.105, 0.012),
		Vector3(-case_size.x * 0.14, case_size.y * 0.72, front_z - 0.004),
		Color(0.98, 0.72, 0.32, 1.0)
	)
	_set_variant_box(
		"CoverCritterEarB",
		adventure,
		Vector3(case_size.x * 0.048, case_size.y * 0.105, 0.012),
		Vector3(case_size.x * 0.02, case_size.y * 0.72, front_z - 0.004),
		Color(0.98, 0.72, 0.32, 1.0)
	)
	_set_variant_box(
		"CoverQuestGemMesh",
		adventure,
		Vector3(case_size.x * 0.12, case_size.y * 0.12, 0.012),
		Vector3(case_size.x * 0.2, case_size.y * 0.57, front_z - 0.004),
		platform_accent
	)
	_set_variant_box(
		"CoverSequelMarkerMesh",
		art_key == "critter_quest_ii",
		Vector3(case_size.x * 0.16, case_size.y * 0.055, 0.012),
		Vector3(case_size.x * 0.22, case_size.y * 0.78, front_z - 0.005),
		Color(0.98, 0.94, 0.52, 1.0)
	)


func _apply_retail_box_layers() -> void:
	var container_variant := str(_visual_profile.get("container_variant", ""))
	var media_variant := str(_visual_profile.get("media_variant", ""))
	var is_box := container_variant == ProductVisualRulesScript.VARIANT_BOX
	var is_console := is_box and media_variant == ProductVisualRulesScript.VARIANT_CONSOLE
	var is_controller := is_box and media_variant == ProductVisualRulesScript.VARIANT_CONTROLLER
	var is_accessory := is_box and media_variant == ProductVisualRulesScript.VARIANT_ACCESSORY
	var case_size: Vector3 = _visual_profile.get("case_size", Vector3(0.26, 0.18, 0.07))
	var front_z := _front_z(0.034)
	var platform_color: Color = _visual_profile.get("platform_color", Color(0.02, 0.43, 0.42, 1.0))
	var platform_accent: Color = _visual_profile.get("platform_accent_color", Color(0.98, 0.9, 0.72, 1.0))

	_set_variant_box(
		"RetailBoxFrontPanelMesh",
		is_box,
		Vector3(case_size.x * 0.64, case_size.y * 0.5, 0.012),
		Vector3(case_size.x * 0.06, case_size.y * 0.51, front_z),
		Color(0.94, 0.86, 0.68, 1.0)
	)
	_set_variant_box(
		"RetailBoxHandleMesh",
		is_console,
		Vector3(case_size.x * 0.28, case_size.y * 0.04, 0.012),
		Vector3(0.0, case_size.y * 1.03, front_z - 0.004),
		platform_accent.darkened(0.12)
	)
	_set_variant_box(
		"ConsoleRenderBodyMesh",
		is_console,
		Vector3(case_size.x * 0.36, case_size.y * 0.13, 0.016),
		Vector3(-case_size.x * 0.08, case_size.y * 0.54, front_z - 0.006),
		Color(0.05, 0.07, 0.075, 1.0)
	)
	_set_variant_disc(
		"ConsoleRenderLensMesh",
		is_console,
		case_size.x * 0.045,
		0.012,
		Vector3(case_size.x * 0.11, case_size.y * 0.55, front_z - 0.009),
		platform_color
	)
	_set_variant_box(
		"ControllerRenderGripA",
		is_controller,
		Vector3(case_size.x * 0.16, case_size.y * 0.22, 0.014),
		Vector3(-case_size.x * 0.16, case_size.y * 0.5, front_z - 0.006),
		Color(0.05, 0.07, 0.085, 1.0)
	)
	_set_variant_box(
		"ControllerRenderGripB",
		is_controller,
		Vector3(case_size.x * 0.16, case_size.y * 0.22, 0.014),
		Vector3(case_size.x * 0.16, case_size.y * 0.5, front_z - 0.006),
		Color(0.05, 0.07, 0.085, 1.0)
	)
	_set_variant_box(
		"ControllerRenderBridge",
		is_controller,
		Vector3(case_size.x * 0.36, case_size.y * 0.12, 0.014),
		Vector3(0.0, case_size.y * 0.55, front_z - 0.008),
		Color(0.05, 0.07, 0.085, 1.0)
	)
	_set_variant_box(
		"AccessoryCableLoopA",
		is_accessory,
		Vector3(case_size.x * 0.38, case_size.y * 0.055, 0.012),
		Vector3(0.0, case_size.y * 0.6, front_z - 0.006),
		Color(0.06, 0.07, 0.075, 1.0)
	)
	_set_variant_box(
		"AccessoryCablePlugA",
		is_accessory,
		Vector3(case_size.x * 0.1, case_size.y * 0.12, 0.014),
		Vector3(-case_size.x * 0.18, case_size.y * 0.48, front_z - 0.008),
		platform_color.darkened(0.2)
	)
	_set_variant_box(
		"AccessoryCablePlugB",
		is_accessory,
		Vector3(case_size.x * 0.1, case_size.y * 0.12, 0.014),
		Vector3(case_size.x * 0.18, case_size.y * 0.48, front_z - 0.008),
		platform_color.darkened(0.2)
	)


func _apply_duplicate_stack_layers() -> void:
	var container_variant := str(_visual_profile.get("container_variant", ""))
	var is_starter_launch := product != null \
		and (product.product_id == "new_footy_2002" or product.product_id == "new_critter_quest_ii")
	var show_stack := container_variant == ProductVisualRulesScript.VARIANT_CASE and is_starter_launch
	var case_size: Vector3 = _visual_profile.get("case_size", Vector3(0.24, 0.34, 0.04))
	var body_color: Color = _visual_profile.get("case_body_color", Color(0.04, 0.05, 0.06, 1.0))

	_set_variant_box(
		"DuplicateCaseBackA",
		show_stack,
		case_size,
		Vector3(0.018, case_size.y / 2.0 + 0.006, 0.035),
		body_color.darkened(0.08)
	)
	_set_variant_box(
		"DuplicateCaseBackB",
		show_stack,
		case_size,
		Vector3(0.036, case_size.y / 2.0 + 0.012, 0.07),
		body_color.darkened(0.16)
	)
	_set_variant_box(
		"DuplicateStackSpineStripe",
		show_stack,
		Vector3(case_size.x * 0.1, case_size.y * 0.82, 0.012),
		Vector3(-case_size.x * 0.43 + 0.036, case_size.y * 0.54 + 0.012, 0.047),
		_visual_profile.get("platform_color", Color(0.02, 0.43, 0.42, 1.0))
	)


func _apply_case_title_label() -> void:
	if product == null:
		return

	var title := product.display_name
	if title.length() > 18:
		title = title.substr(0, 18)
	_apply_case_label(
		"CaseTitleLabel",
		title.to_upper(),
		bool(_visual_profile.get("show_cover", true)),
		Vector3(0.0, 0.292, -0.073),
		0.00155,
		9,
		Color(0.98, 0.96, 0.84, 1.0)
	)


func _apply_case_price_label() -> void:
	_apply_case_label(
		"CasePriceLabel",
		get_case_price_label_text(),
		bool(_visual_profile.get("show_price_sticker", true)),
		Vector3(0.065, 0.075, -0.074),
		0.00132,
		7,
		Color(0.05, 0.06, 0.065, 1.0)
	)


func _apply_used_sticker_label() -> void:
	_apply_case_label(
		"UsedStickerLabel",
		"USED",
		bool(_visual_profile.get("show_used_sticker", false)),
		Vector3(-0.044, 0.074, -0.076),
		0.0014,
		8,
		Color(0.05, 0.055, 0.04, 1.0)
	)


func _apply_case_label(
	node_name: String,
	text: String,
	is_visible: bool,
	position: Vector3,
	pixel_size: float,
	font_size: int,
	color: Color
) -> void:
	var label := _get_or_create_case_label(node_name)
	label.visible = is_visible and not text.strip_edges().is_empty()
	label.text = text
	label.position = position
	label.rotation = Vector3.ZERO
	label.pixel_size = pixel_size
	label.font_size = font_size
	label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	label.no_depth_test = true
	label.modulate = color
	label.outline_size = 1
	label.outline_modulate = Color(0.0, 0.0, 0.0, 1.0)


func _get_or_create_case_label(node_name: String) -> Label3D:
	var existing := get_node_or_null(node_name) as Label3D
	if existing != null:
		return existing

	var label := Label3D.new()
	label.name = node_name
	label.visible = false
	add_child(label)
	return label


func _apply_price_tag_label() -> void:
	var label := _get_or_create_price_tag_label()
	var lines := get_price_tag_lines()
	label.visible = _is_hovered and not lines.is_empty()
	label.text = "\n".join(lines)
	label.position = Vector3(0.0, 0.372, -0.07)
	label.rotation = Vector3.ZERO
	label.pixel_size = 0.00235
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.modulate = Color(1.0, 0.92, 0.58, 1.0)
	label.outline_size = 2
	label.outline_modulate = Color(0.02, 0.025, 0.03, 1.0)
	_apply_price_tag_card(lines)


func _apply_price_tag_card(lines: Array[String]) -> void:
	var is_visible := _is_hovered and not lines.is_empty()
	var extra_lines: int = maxi(0, lines.size() - 2)
	var card_height := 0.104 + float(extra_lines) * 0.032

	_set_variant_box(
		"ProductTagBackerMesh",
		is_visible,
		Vector3(0.31, card_height, 0.012),
		Vector3(0.0, 0.364, -0.078),
		Color(0.055, 0.07, 0.078, 1.0)
	)
	_set_variant_box(
		"ProductTagCategoryStripeMesh",
		is_visible,
		Vector3(0.27, 0.024, 0.014),
		Vector3(0.0, 0.41, -0.087),
		_get_price_tag_stripe_color()
	)
	_set_variant_box(
		"ProductTagPinMesh",
		is_visible,
		Vector3(0.035, 0.035, 0.015),
		Vector3(-0.13, 0.416, -0.089),
		Color(0.98, 0.9, 0.62, 1.0)
	)


func _get_or_create_price_tag_label() -> Label3D:
	var existing := get_node_or_null("ProductTagLabel") as Label3D
	if existing != null:
		return existing

	var label := Label3D.new()
	label.name = "ProductTagLabel"
	label.visible = false
	add_child(label)
	return label


func _get_price_tag_badges() -> Array[String]:
	var badges: Array[String] = []
	if product == null:
		return badges

	if product.category == "new_game":
		badges.append("PREORDER")

	if product.demand_tier == "high" and (product.rarity == "rare" or product.rarity == "collector" or product.rarity == "launch"):
		badges.append("STAFF")

	if current_price_cents > 0 and current_price_cents < product.suggested_price_cents:
		badges.append("SALE")

	if product.market_value_cents > 0 and current_price_cents <= int(round(product.market_value_cents * 0.8)):
		badges.append("BARGAIN")

	return badges


func _get_price_tag_stripe_color() -> Color:
	if product == null:
		return Color(0.98, 0.9, 0.62, 1.0)

	match product.category:
		"new_game":
			return Color(0.62, 0.74, 0.92, 1.0)
		"hardware":
			return Color(0.7, 0.72, 0.74, 1.0)
		"accessory":
			return Color(0.58, 0.82, 0.68, 1.0)
		"service":
			return Color(0.88, 0.7, 0.36, 1.0)
		_:
			return Color(0.98, 0.9, 0.62, 1.0)


func _get_condition_label() -> String:
	if product == null:
		return ""
	if product.category == "new_game" or product.condition == "new":
		return "New"
	if product.category == "used_game":
		return "Used"
	if product.condition == "refurbished":
		return "Refurb"
	if product.category == "hardware" or product.category == "accessory":
		return "Used"
	return product.condition.strip_edges().capitalize()


func _get_category_label(category: String) -> String:
	return category.strip_edges().capitalize()


func _get_or_create_variant_node(node_name: String) -> MeshInstance3D:
	var existing := get_node_or_null(node_name) as MeshInstance3D
	if existing != null:
		return existing

	var node := MeshInstance3D.new()
	node.name = node_name
	node.visible = false
	add_child(node)
	return node


func _front_z(offset: float) -> float:
	var case_size: Vector3 = _visual_profile.get("case_size", Vector3(0.24, 0.34, 0.04))
	return -case_size.z / 2.0 - offset


func _make_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	if color.a < 1.0:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return material


func _get_variant_color(variant: String) -> Color:
	match variant:
		ProductVisualRulesScript.VARIANT_DISC:
			return Color(0.86, 0.9, 0.92, 1.0)
		ProductVisualRulesScript.VARIANT_CARTRIDGE:
			return Color(0.18, 0.22, 0.28, 1.0)
		ProductVisualRulesScript.VARIANT_CONSOLE:
			return Color(0.1, 0.12, 0.16, 1.0)
		ProductVisualRulesScript.VARIANT_CONTROLLER:
			return Color(0.12, 0.2, 0.32, 1.0)
		ProductVisualRulesScript.VARIANT_ACCESSORY:
			return Color(0.25, 0.38, 0.34, 1.0)
		_:
			return Color(0.7, 0.72, 0.74, 1.0)


func _get_inspect_prompt() -> String:
	if product == null:
		return super.get_interaction_prompt()

	return "Click Inspect %s" % product.display_name


func interact() -> String:
	if product == null:
		return super.interact()

	return "%s - Price $%0.2f - Location %s - %s" % [
		product.describe(),
		current_price_cents / 100.0,
		location_id,
		get_serial_status_text(),
	]


func _can_actor_pick_up(actor: Node) -> bool:
	if product == null:
		return false

	if location_id != "receiving_box_001":
		return false

	if actor == null or not actor.has_method("can_pick_up_item"):
		return false

	return actor.can_pick_up_item(self)
