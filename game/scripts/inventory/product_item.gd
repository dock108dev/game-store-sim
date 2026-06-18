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
	_set_node_visible("CoverLabelMesh", bool(_visual_profile.get("show_cover", true)))
	_set_node_visible("SpineStripeMesh", bool(_visual_profile.get("show_spine", true)))
	_set_node_visible("PlatformBandMesh", bool(_visual_profile.get("show_platform_band", true)))
	_set_node_visible("PriceStickerMesh", bool(_visual_profile.get("show_price_sticker", true)))
	_apply_mesh_material("CaseMesh", _visual_profile.get("case_body_color", Color(0.035, 0.055, 0.07, 1.0)))
	_apply_mesh_material("CoverLabelMesh", _visual_profile.get("cover_base_color", Color(0.22, 0.74, 0.62, 1.0)))
	_apply_mesh_material("SpineStripeMesh", _visual_profile.get("platform_color", Color(0.96, 0.82, 0.38, 1.0)))
	_apply_mesh_material("PlatformBandMesh", _visual_profile.get("platform_color", Color(0.16, 0.32, 0.92, 1.0)))
	_apply_mesh_material("PriceStickerMesh", _visual_profile.get("price_sticker_color", Color(0.98, 0.9, 0.62, 1.0)))

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


func _set_condition_cue_box(
	node_name: String,
	is_visible: bool,
	size: Vector3,
	position: Vector3,
	color: Color
) -> void:
	_set_variant_box(node_name, is_visible, size, position, color)


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
