## Builds visual-only physical product tags from existing item metadata.
class_name ProductPhysicalTagBuilder
extends RefCounted

const SOURCE: String = "product_physical_tag_builder"
const ROOT_NAME: StringName = &"PhysicalTagRoot"

const _MAX_TIER: int = 4
const _PANEL_DEPTH: float = 0.002
const _TAG_SIZE: Vector3 = Vector3(0.026, 0.014, _PANEL_DEPTH)
const _SLEEVE_SIZE: Vector3 = Vector3(0.110, 0.122, 0.003)

const _CONDITION_VISUALS: Dictionary = {
	"poor": {
		"grade": "P",
		"sleeve": "creased_paper_sleeve",
		"protector": "none",
		"wear_overlay": "heavy_scuffs",
		"color": Color(0.62, 0.50, 0.38, 0.86),
	},
	"fair": {
		"grade": "F",
		"sleeve": "matte_used_sleeve",
		"protector": "none",
		"wear_overlay": "edge_nicks",
		"color": Color(0.72, 0.66, 0.55, 0.74),
	},
	"good": {
		"grade": "G",
		"sleeve": "clear_poly_sleeve",
		"protector": "thin_clear_wrap",
		"wear_overlay": "light_rub",
		"color": Color(0.78, 0.84, 0.82, 0.42),
	},
	"near_mint": {
		"grade": "NM",
		"sleeve": "rigid_clear_sleeve",
		"protector": "soft_shell",
		"wear_overlay": "none",
		"color": Color(0.70, 0.88, 0.96, 0.38),
	},
	"mint": {
		"grade": "M",
		"sleeve": "sealed_crystal_sleeve",
		"protector": "hard_shell",
		"wear_overlay": "none",
		"color": Color(0.92, 0.96, 1.0, 0.42),
	},
}

const _RARITY_VISUALS: Dictionary = {
	"common": {
		"label": "",
		"sticker": "paper_dot",
		"shape": "circle",
		"trim": "none",
		"color": Color(0.86, 0.86, 0.78, 1.0),
	},
	"uncommon": {
		"label": "U",
		"sticker": "corner_slash",
		"shape": "diagonal_tab",
		"trim": "green_edge",
		"color": Color(0.42, 0.72, 0.55, 1.0),
	},
	"rare": {
		"label": "R",
		"sticker": "metallic_starburst",
		"shape": "starburst",
		"trim": "silver_edge",
		"color": Color(0.70, 0.76, 0.84, 1.0),
	},
	"very_rare": {
		"label": "VR",
		"sticker": "holo_shield",
		"shape": "shield",
		"trim": "prismatic_rim",
		"color": Color(0.55, 0.76, 0.95, 1.0),
	},
	"legendary": {
		"label": "L",
		"sticker": "embossed_certificate",
		"shape": "notched_certificate",
		"trim": "gold_rim",
		"color": Color(0.96, 0.76, 0.28, 1.0),
	},
}

const _KIND_PLACEMENTS: Dictionary = {
	"game_case": {
		"rarity": Vector3(0.050, 0.054, 0.066),
		"condition": Vector3(0.048, -0.054, 0.067),
		"platform": Vector3(-0.056, 0.034, 0.068),
		"metadata": Vector3(-0.040, -0.056, 0.069),
		"sleeve": Vector3(0.0, 0.0, 0.061),
	},
	"cartridge": {
		"rarity": Vector3(0.034, 0.028, 0.034),
		"condition": Vector3(0.036, -0.020, 0.035),
		"platform": Vector3(0.000, 0.032, 0.036),
		"metadata": Vector3(-0.036, -0.020, 0.037),
		"sleeve": Vector3(0.0, 0.0, 0.032),
	},
	"console_box": {
		"rarity": Vector3(0.074, 0.060, 0.088),
		"condition": Vector3(0.068, -0.052, 0.089),
		"platform": Vector3(-0.084, 0.000, 0.090),
		"metadata": Vector3(-0.045, -0.052, 0.091),
		"sleeve": Vector3(0.0, 0.0, 0.082),
	},
}


## Adds a derived, visual-only physical tag subtree under the product root.
static func apply_physical_tags(root: Node3D, item: Dictionary) -> void:
	if root == null:
		return
	clear_physical_tags(root)
	if item.is_empty():
		return
	var spec: Dictionary = build_physical_tag_spec(item)
	var tag_root := Node3D.new()
	tag_root.name = ROOT_NAME
	tag_root.set_meta("visual_source", SOURCE)
	tag_root.set_meta("physical_tag_spec", spec)
	root.add_child(tag_root)
	_apply_spec(tag_root, spec)


## Derives physical tag display metadata without mutating source item data.
static func build_physical_tag_spec(item: Dictionary) -> Dictionary:
	var product_kind: String = _product_kind_for(item)
	var rarity_label: String = _rarity_label_for(item)
	var condition_label: String = _condition_label_for(item)
	var rarity_tier: int = clampi(
		int(item.get("rarity_tier", ItemDefinition.rarity_to_tier(rarity_label))),
		0,
		_MAX_TIER
	)
	var condition_tier: int = clampi(
		int(item.get("condition_tier", ItemDefinition.condition_to_tier(condition_label))),
		0,
		_MAX_TIER
	)
	var condition_profile: Dictionary = _CONDITION_VISUALS[condition_label]
	var rarity_profile: Dictionary = _RARITY_VISUALS[rarity_label]
	var protection_score: int = maxi(condition_tier, rarity_tier)
	var protector_style: String = _protector_for_score(protection_score)
	var metadata_tags: Array[Dictionary] = _metadata_tags_for(item, product_kind)
	return {
		"schema": "physical_tag_spec.v1",
		"definition_id": str(item.get("definition_id", "")),
		"instance_id": str(item.get("instance_id", "")),
		"product_kind": product_kind,
		"condition": {
			"label": condition_label,
			"tier": condition_tier,
			"sleeve": str(condition_profile.get("sleeve", "")),
			"wear_overlay": str(condition_profile.get("wear_overlay", "")),
			"grade_badge": str(condition_profile.get("grade", "")),
		},
		"rarity": {
			"label": rarity_label,
			"tier": rarity_tier,
			"sticker": str(rarity_profile.get("sticker", "")),
			"shape": str(rarity_profile.get("shape", "")),
			"trim": str(rarity_profile.get("trim", "")),
		},
		"platform": _platform_spec_for(item),
		"metadata_tags": metadata_tags,
		"protector": {
			"style": protector_style,
			"score": protection_score,
			"opacity": 0.10 + float(protection_score) * 0.055,
			"edge_thickness": 0.0015 + float(protection_score) * 0.0008,
		},
		"placements": _KIND_PLACEMENTS.get(product_kind, _KIND_PLACEMENTS["game_case"]),
	}


static func clear_physical_tags(root: Node3D) -> void:
	if root == null:
		return
	var existing: Node = root.get_node_or_null(NodePath(String(ROOT_NAME)))
	if existing != null:
		root.remove_child(existing)
		existing.free()


static func _apply_spec(parent: Node3D, spec: Dictionary) -> void:
	var placements: Dictionary = spec.get("placements", {}) as Dictionary
	var condition: Dictionary = spec.get("condition", {}) as Dictionary
	var rarity: Dictionary = spec.get("rarity", {}) as Dictionary
	var platform: Dictionary = spec.get("platform", {}) as Dictionary
	var protector: Dictionary = spec.get("protector", {}) as Dictionary
	_add_box(
		parent,
		"ConditionSleeve",
		placements.get("sleeve", Vector3.ZERO),
		_sleeve_size_for(str(spec.get("product_kind", "game_case"))),
		_CONDITION_VISUALS[str(condition.get("label", "good"))].get("color", Color.WHITE),
		{"physical_tag_kind": "condition_sleeve", "sleeve": condition.get("sleeve", "")}
	)
	_add_labeled_badge(
		parent,
		"ConditionGradeBadge",
		"ConditionGradeLabel",
		str(condition.get("grade_badge", "")),
		placements.get("condition", Vector3.ZERO),
		Color(0.96, 0.92, 0.76, 1.0),
		{
			"physical_tag_kind": "condition",
			"condition": condition.get("label", ""),
			"condition_tier": condition.get("tier", 0),
		}
	)
	_add_labeled_badge(
		parent,
		"RaritySticker",
		"RarityStickerLabel",
		str(rarity.get("label", "")).left(2).to_upper(),
		placements.get("rarity", Vector3.ZERO),
		_RARITY_VISUALS[str(rarity.get("label", "common"))].get("color", Color.WHITE),
		{
			"physical_tag_kind": "rarity",
			"rarity": rarity.get("label", ""),
			"rarity_tier": rarity.get("tier", 0),
			"sticker": rarity.get("sticker", ""),
		}
	)
	_add_labeled_badge(
		parent,
		"PlatformPhysicalTag",
		"PlatformPhysicalTagLabel",
		str(platform.get("label", "")),
		placements.get("platform", Vector3.ZERO),
		Color(0.40, 0.62, 0.78, 1.0),
		{
			"physical_tag_kind": "platform",
			"platform_id": platform.get("platform_id", ""),
			"tag_shape": platform.get("tag_shape", ""),
		}
	)
	_add_metadata_tags(parent, spec)
	if str(protector.get("style", "none")) != "none":
		_add_protector(parent, spec)
	_add_wear_edges(parent, spec)


static func _add_metadata_tags(parent: Node3D, spec: Dictionary) -> void:
	var placements: Dictionary = spec.get("placements", {}) as Dictionary
	var base_position: Vector3 = placements.get("metadata", Vector3.ZERO)
	var tags: Array = spec.get("metadata_tags", [])
	for index: int in range(tags.size()):
		var tag: Dictionary = tags[index]
		var name_suffix: String = _pascal_case(str(tag.get("kind", "tag")))
		_add_labeled_badge(
			parent,
			"MetadataTag%s" % name_suffix,
			"MetadataTag%sLabel" % name_suffix,
			str(tag.get("label", "")),
			base_position + Vector3(0.0, float(index) * 0.022, 0.001 * float(index)),
			tag.get("color", Color(0.88, 0.78, 0.58, 1.0)),
			{"physical_tag_kind": str(tag.get("kind", "")), "shape": str(tag.get("shape", ""))}
		)


static func _add_protector(parent: Node3D, spec: Dictionary) -> void:
	var protector: Dictionary = spec.get("protector", {}) as Dictionary
	var placements: Dictionary = spec.get("placements", {}) as Dictionary
	var color := Color(0.82, 0.95, 1.0, float(protector.get("opacity", 0.18)))
	_add_box(
		parent,
		"ProtectorShell",
		placements.get("sleeve", Vector3.ZERO) + Vector3(0.0, 0.0, 0.006),
		_sleeve_size_for(str(spec.get("product_kind", "game_case"))) + Vector3(0.010, 0.010, 0.001),
		color,
		{"physical_tag_kind": "protector", "protector_style": protector.get("style", "")}
	)
	if int(protector.get("score", 0)) < 3:
		return
	for corner: Dictionary in [
		{"name": "ProtectorCornerTopLeft", "offset": Vector3(-0.050, 0.055, 0.010)},
		{"name": "ProtectorCornerTopRight", "offset": Vector3(0.050, 0.055, 0.010)},
	]:
		_add_box(
			parent,
			str(corner["name"]),
			placements.get("sleeve", Vector3.ZERO) + (corner["offset"] as Vector3),
			Vector3(0.020, 0.010, _PANEL_DEPTH),
			color,
			{"physical_tag_kind": "protector_corner", "protector_style": protector.get("style", "")}
		)


static func _add_wear_edges(parent: Node3D, spec: Dictionary) -> void:
	var condition: Dictionary = spec.get("condition", {}) as Dictionary
	var condition_tier: int = int(condition.get("tier", 2))
	var count: int = clampi(4 - condition_tier, 0, 4)
	if count == 0:
		return
	var base: Vector3 = (spec.get("placements", {}) as Dictionary).get("sleeve", Vector3.ZERO)
	for index: int in range(count):
		_add_box(
			parent,
			"WearOverlayEdge%d" % index,
			base + Vector3(-0.066 + float(index) * 0.044, -0.096, 0.012),
			Vector3(0.024, 0.006, _PANEL_DEPTH),
			Color(0.25, 0.20, 0.15, 0.72),
			{"physical_tag_kind": "wear_overlay", "condition": condition.get("label", "")}
		)


static func _add_labeled_badge(
	parent: Node3D,
	badge_name: String,
	label_name: String,
	label_text: String,
	position: Vector3,
	color: Color,
	meta: Dictionary
) -> void:
	_add_box(parent, badge_name, position, _TAG_SIZE, color, meta)
	if label_text.is_empty():
		return
	var badge: Node = parent.get_node_or_null(NodePath(badge_name))
	if badge != null:
		badge.set_meta("physical_tag_label_node", label_name)
		badge.set_meta("physical_tag_label", label_text)


static func _add_box(
	parent: Node3D,
	name: String,
	position: Vector3,
	size: Vector3,
	color: Color,
	meta: Dictionary
) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = name
	node.position = position
	var mesh := BoxMesh.new()
	mesh.size = size
	node.mesh = mesh
	node.material_override = _material(color)
	_apply_meta(node, meta)
	parent.add_child(node)
	return node


static func _apply_meta(node: Node, meta: Dictionary) -> void:
	node.set_meta("visual_source", SOURCE)
	for key: Variant in meta:
		node.set_meta(str(key), meta[key])


static func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.78
	if color.a < 1.0:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.set_meta("store_material_family", &"paper")
	material.set_meta("starter_material_family", &"paper")
	material.set_meta("starter_detail_role", &"label")
	return material


static func _metadata_tags_for(item: Dictionary, product_kind: String) -> Array[Dictionary]:
	var tags: Array[Dictionary] = []
	if float(item.get("suspicious_chance", 0.0)) > 0.0:
		tags.append(
			_metadata_tag("inspection", "Inspect", "round_seal", Color(0.74, 0.82, 0.70, 1.0))
		)
	if bool(item.get("supply_constrained", false)):
		tags.append(
			_metadata_tag("limited_supply", "Limited", "seal_band", Color(0.72, 0.30, 0.22, 1.0))
		)
	if (
		str(item.get("decay_profile", "")) == "collector_market"
		or bool(item.get("appreciates", false))
	):
		tags.append(
			_metadata_tag(
				"collector_market", "Collector", "ticket_notch", Color(0.36, 0.30, 0.46, 1.0)
			)
		)
	if bool(item.get("depreciates", false)) or str(item.get("decay_profile", "")) == "annual_sports":
		tags.append(_metadata_tag("clearance", "Mark", "markdown_tab", Color(0.90, 0.66, 0.22, 1.0)))
	if not str(item.get("region", "")).is_empty():
		tags.append(
			_metadata_tag(
				"region",
				str(item.get("region", "")).left(4),
				"region_chip",
				Color(0.46, 0.58, 0.76, 1.0)
			)
		)
	if not str(item.get("product_set_name", "")).is_empty():
		tags.append(_metadata_tag("product_set", "Set", "set_badge", Color(0.52, 0.42, 0.74, 1.0)))
	for tag: String in _tag_strings(item):
		match tag:
			"trade_in", "trade-in", "used_trade":
				tags.append(_metadata_tag("trade_in", "Trade", "hang_tag", Color(0.70, 0.55, 0.32, 1.0)))
			"staff_pick", "staff-pick":
				tags.append(_metadata_tag("staff_pick", "Pick", "staff_tab", Color(0.22, 0.58, 0.48, 1.0)))
			"sale", "clearance":
				tags.append(_metadata_tag("sale", "Sale", "sale_flag", Color(0.86, 0.32, 0.24, 1.0)))
			"sealed":
				tags.append(_metadata_tag("sealed", "Seal", "seal_band", Color(0.66, 0.80, 0.92, 1.0)))
	var grades: Array[String] = _strings_from_variant(item.get("condition_grades", []))
	if grades.has("Sealed"):
		tags.append(
			_metadata_tag(
				"protective_case", "Case", "protector_chip", Color(0.70, 0.88, 0.96, 1.0)
			)
		)
	if float(item.get("trade_in_base", 0.0)) > 0.0:
		tags.append(_metadata_tag("trade_in", "Trade", "hang_tag", Color(0.70, 0.55, 0.32, 1.0)))
	return _unique_limited_tags(tags, _metadata_limit(product_kind))


static func _metadata_tag(kind: String, label: String, shape: String, color: Color) -> Dictionary:
	return {"kind": kind, "label": label, "shape": shape, "color": color}


static func _unique_limited_tags(tags: Array[Dictionary], limit: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var seen: Dictionary = {}
	for tag: Dictionary in tags:
		var kind: String = str(tag.get("kind", ""))
		if seen.has(kind):
			continue
		seen[kind] = true
		result.append(tag)
		if result.size() >= limit:
			break
	return result


static func _metadata_limit(product_kind: String) -> int:
	if product_kind == "console_box":
		return 4
	if product_kind == "cartridge":
		return 2
	return 3


static func _platform_spec_for(item: Dictionary) -> Dictionary:
	var platform_id: String = str(item.get("platform_id", "")).strip_edges()
	var label: String = platform_id.left(3).to_upper()
	if platform_id.is_empty():
		label = "ID"
	match platform_id:
		"neo_ignite":
			return {
				"platform_id": platform_id,
				"tag_shape": "vertical_ignition_tab",
				"accent_family": "neo_ignite",
				"label": "NI",
			}
		"canopy_wave":
			return {
				"platform_id": platform_id,
				"tag_shape": "handle_tab",
				"accent_family": "canopy_wave",
				"label": "CW",
			}
	return {
		"platform_id": platform_id,
		"tag_shape": "plain_rectangle",
		"accent_family": "neutral",
		"label": label,
	}


static func _protector_for_score(score: int) -> String:
	if score >= 4:
		return "hard_shell"
	if score == 3:
		return "soft_shell"
	if score == 2:
		return "thin_clear_wrap"
	return "none"


static func _product_kind_for(item: Dictionary) -> String:
	var raw: String = str(item.get("product_visual_kind", "")).strip_edges()
	if raw in _KIND_PLACEMENTS:
		return raw
	if str(item.get("category", "")) == "console":
		return "console_box"
	if str(item.get("visual_presentation", "")) == "cartridge":
		return "cartridge"
	return "game_case"


static func _rarity_label_for(item: Dictionary) -> String:
	var label: String = str(item.get("rarity", "common")).strip_edges().to_lower()
	if label in _RARITY_VISUALS:
		return label
	return "common"


static func _condition_label_for(item: Dictionary) -> String:
	var label: String = str(item.get("condition", "good")).strip_edges().to_lower()
	if label in _CONDITION_VISUALS:
		return label
	return "good"


static func _tag_strings(item: Dictionary) -> Array[String]:
	var values: Array[String] = _strings_from_variant(item.get("tags", []))
	if bool(item.get("staff_pick", false)):
		values.append("staff_pick")
	if bool(item.get("sale", false)) or bool(item.get("clearance", false)):
		values.append("sale")
	return values


static func _strings_from_variant(raw: Variant) -> Array[String]:
	var values: Array[String] = []
	if raw is PackedStringArray:
		for value: String in raw:
			values.append(value)
	elif raw is Array:
		for value: Variant in raw:
			values.append(str(value))
	return values


static func _sleeve_size_for(product_kind: String) -> Vector3:
	if product_kind == "console_box":
		return Vector3(0.150, 0.120, 0.004)
	if product_kind == "cartridge":
		return Vector3(0.096, 0.066, 0.004)
	return _SLEEVE_SIZE


static func _pascal_case(value: String) -> String:
	var output: String = ""
	for part: String in value.split("_", false):
		output += part.capitalize()
	return output
