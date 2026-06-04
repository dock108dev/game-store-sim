## Visual-only low-poly detail builders for repeated retail props.
class_name RetailDetailBuilder
extends RefCounted

const StoreVisualKitScript: GDScript = preload("res://game/scripts/visuals/store_visual_kit.gd")
const StarterDetailBuilderScript: GDScript = preload(
	"res://game/scripts/visuals/starter_detail_builder.gd"
)

const DETAIL_PRICE_TAG: StringName = &"retail_detail_price_tag"
const DETAIL_SALE_STICKER: StringName = &"retail_detail_sale_sticker"
const DETAIL_SHELF_TALKER: StringName = &"retail_detail_shelf_talker"
const DETAIL_POSTER_CARD: StringName = &"retail_detail_poster_card"
const DETAIL_CABLE_HOOK: StringName = &"retail_detail_cable_hook"
const DETAIL_RECEIPT_SLIP: StringName = &"retail_detail_receipt_slip"
const DETAIL_LABEL_PLATE: StringName = &"retail_detail_label_plate"
const DETAIL_QUEUE_STANCHION_ROPE: StringName = &"retail_detail_queue_stanchion_rope"
const DETAIL_WINDOW_DECAL: StringName = &"retail_detail_window_decal"
const DETAIL_HOURS_PLAQUE: StringName = &"retail_detail_hours_plaque"
const DETAIL_FLOOR_MAT: StringName = &"retail_detail_floor_mat"
const DETAIL_STOCKROOM_LABEL: StringName = &"retail_detail_stockroom_label"
const DETAIL_CONDITION_STICKER: StringName = &"retail_detail_condition_sticker"
const DETAIL_PROTECTIVE_SLEEVE: StringName = &"retail_detail_protective_sleeve"
const DETAIL_DISPLAY_PLACARD: StringName = &"retail_detail_display_placard"

const GROUP_CUSTOMIZATION: StringName = &"customization"
const GROUP_BUILD_MODE: StringName = &"build_mode"

const _DETAIL_SPECS: Dictionary = {
	DETAIL_PRICE_TAG:
	{
		"name": "RetailPriceTag",
		"display_name": "price tag",
		"role": StoreVisualKitScript.ROLE_SIGNAGE,
		"groups":
		[
			StoreVisualKitScript.GROUP_PRICING,
			StoreVisualKitScript.GROUP_RETAIL_FLOOR,
			StoreVisualKitScript.GROUP_PRODUCT_DISPLAY,
		],
		"family": StarterDetailBuilderScript.FAMILY_PRICE_TAG_WARM,
	},
	DETAIL_SALE_STICKER:
	{
		"name": "RetailSaleSticker",
		"display_name": "sale sticker",
		"role": StoreVisualKitScript.ROLE_SIGNAGE,
		"groups":
		[
			StoreVisualKitScript.GROUP_PRICING,
			StoreVisualKitScript.GROUP_RETAIL_FLOOR,
			StoreVisualKitScript.GROUP_PRODUCT_DISPLAY,
		],
		"family": StarterDetailBuilderScript.FAMILY_PRICE_TAG_WARM,
	},
	DETAIL_SHELF_TALKER:
	{
		"name": "RetailShelfTalker",
		"display_name": "shelf talker",
		"role": StoreVisualKitScript.ROLE_SIGNAGE,
		"groups":
		[
			StoreVisualKitScript.GROUP_PRICING,
			StoreVisualKitScript.GROUP_RETAIL_FLOOR,
			StoreVisualKitScript.GROUP_PRODUCT_DISPLAY,
		],
		"family": StarterDetailBuilderScript.FAMILY_PAPER,
	},
	DETAIL_POSTER_CARD:
	{
		"name": "RetailPosterCard",
		"display_name": "poster card",
		"role": StoreVisualKitScript.ROLE_SIGNAGE,
		"groups": [StoreVisualKitScript.GROUP_WAYFINDING, StoreVisualKitScript.GROUP_RETAIL_FLOOR],
		"family": StarterDetailBuilderScript.FAMILY_PAPER,
	},
	DETAIL_CABLE_HOOK:
	{
		"name": "RetailCableHook",
		"display_name": "cable hook",
		"role": StoreVisualKitScript.ROLE_TOOL,
		"groups": [StoreVisualKitScript.GROUP_CHECKOUT, StoreVisualKitScript.GROUP_RETAIL_FLOOR],
		"family": StarterDetailBuilderScript.FAMILY_STOCKROOM_COOL_METAL,
	},
	DETAIL_RECEIPT_SLIP:
	{
		"name": "RetailReceiptSlip",
		"display_name": "receipt slip",
		"role": StoreVisualKitScript.ROLE_SIGNAGE,
		"groups": [StoreVisualKitScript.GROUP_CHECKOUT, StoreVisualKitScript.GROUP_RETAIL_FLOOR],
		"family": StarterDetailBuilderScript.FAMILY_PAPER,
	},
	DETAIL_LABEL_PLATE:
	{
		"name": "RetailLabelPlate",
		"display_name": "label plate",
		"role": StoreVisualKitScript.ROLE_SIGNAGE,
		"groups": [GROUP_CUSTOMIZATION, GROUP_BUILD_MODE, StoreVisualKitScript.GROUP_RETAIL_FLOOR],
		"family": StarterDetailBuilderScript.FAMILY_PAPER,
	},
	DETAIL_QUEUE_STANCHION_ROPE:
	{
		"name": "RetailQueueStanchionRope",
		"display_name": "queue stanchion and rope",
		"role": StoreVisualKitScript.ROLE_ROUTE_CUE,
		"groups":
		[
			StoreVisualKitScript.GROUP_CHECKOUT,
			StoreVisualKitScript.GROUP_RETAIL_FLOOR,
			StoreVisualKitScript.GROUP_WAYFINDING,
		],
		"family": StarterDetailBuilderScript.FAMILY_RUBBER,
	},
	DETAIL_WINDOW_DECAL:
	{
		"name": "RetailWindowDecal",
		"display_name": "window decal",
		"role": StoreVisualKitScript.ROLE_SIGNAGE,
		"groups": [StoreVisualKitScript.GROUP_WAYFINDING, StoreVisualKitScript.GROUP_RETAIL_FLOOR],
		"family": StarterDetailBuilderScript.FAMILY_PAPER,
	},
	DETAIL_HOURS_PLAQUE:
	{
		"name": "RetailHoursPlaque",
		"display_name": "hours plaque",
		"role": StoreVisualKitScript.ROLE_SIGNAGE,
		"groups": [StoreVisualKitScript.GROUP_WAYFINDING, StoreVisualKitScript.GROUP_RETAIL_FLOOR],
		"family": StarterDetailBuilderScript.FAMILY_PAPER,
	},
	DETAIL_FLOOR_MAT:
	{
		"name": "RetailFloorMat",
		"display_name": "floor mat",
		"role": StoreVisualKitScript.ROLE_DECOR,
		"groups":
		[
			StoreVisualKitScript.GROUP_RETAIL_FLOOR,
			StoreVisualKitScript.GROUP_WAYFINDING,
			GROUP_BUILD_MODE,
		],
		"family": StarterDetailBuilderScript.FAMILY_RUBBER,
	},
	DETAIL_STOCKROOM_LABEL:
	{
		"name": "RetailStockroomLabel",
		"display_name": "stockroom label",
		"role": StoreVisualKitScript.ROLE_STOCKROOM,
		"groups": [StoreVisualKitScript.GROUP_STOCKROOM, StoreVisualKitScript.GROUP_BACK_OF_HOUSE],
		"family": StarterDetailBuilderScript.FAMILY_PAPER,
	},
	DETAIL_CONDITION_STICKER:
	{
		"name": "RetailConditionSticker",
		"display_name": "condition sticker",
		"role": StoreVisualKitScript.ROLE_SIGNAGE,
		"groups":
		[
			StoreVisualKitScript.GROUP_PRICING,
			StoreVisualKitScript.GROUP_PRODUCT_DISPLAY,
			StoreVisualKitScript.GROUP_RETAIL_FLOOR,
		],
		"family": StarterDetailBuilderScript.FAMILY_PRICE_TAG_WARM,
	},
	DETAIL_PROTECTIVE_SLEEVE:
	{
		"name": "RetailProtectiveSleeve",
		"display_name": "protective sleeve",
		"role": StoreVisualKitScript.ROLE_DECOR,
		"groups":
		[StoreVisualKitScript.GROUP_PRODUCT_DISPLAY, StoreVisualKitScript.GROUP_RETAIL_FLOOR],
		"family": StarterDetailBuilderScript.FAMILY_PAPER,
	},
	DETAIL_DISPLAY_PLACARD:
	{
		"name": "RetailDisplayPlacard",
		"display_name": "display placard",
		"role": StoreVisualKitScript.ROLE_SIGNAGE,
		"groups":
		[
			StoreVisualKitScript.GROUP_PRODUCT_DISPLAY,
			StoreVisualKitScript.GROUP_RETAIL_FLOOR,
			GROUP_CUSTOMIZATION,
		],
		"family": StarterDetailBuilderScript.FAMILY_PAPER,
	},
}


## Returns all reusable retail detail IDs.
static func detail_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for raw_id: Variant in _DETAIL_SPECS.keys():
		ids.append(raw_id as StringName)
	ids.sort()
	return ids


## Builds a price tag from caller-owned text.
static func price_tag(label_text: String = "") -> Node3D:
	return _flat_text_detail(DETAIL_PRICE_TAG, label_text, Vector3(0.30, 0.035, 0.13))


## Builds a sale sticker from caller-owned text.
static func sale_sticker(label_text: String = "") -> Node3D:
	return _flat_text_detail(DETAIL_SALE_STICKER, label_text, Vector3(0.16, 0.030, 0.11))


## Builds a shelf talker from caller-owned text.
static func shelf_talker(label_text: String = "") -> Node3D:
	var root: Node3D = _flat_text_detail(
		DETAIL_SHELF_TALKER, label_text, Vector3(0.40, 0.030, 0.18)
	)
	_add_box(
		root,
		"FoldFoot",
		Vector3(0.0, -0.04, 0.09),
		Vector3(0.36, 0.030, 0.06),
		_family(root),
		StarterDetailBuilderScript.ROLE_LIP
	)
	return root


## Builds a poster card from caller-owned headline and body text.
static func poster_card(headline_text: String = "", body_text: String = "") -> Node3D:
	var root: Node3D = _flat_text_detail(
		DETAIL_POSTER_CARD, headline_text, Vector3(0.50, 0.030, 0.68)
	)
	_add_label(root, "BodyText", body_text, Vector3(0.0, 0.030, 0.11), 0.016)
	return root


## Builds a visual cable hook with no gameplay interaction or collision.
static func cable_hook() -> Node3D:
	var root: Node3D = _root(DETAIL_CABLE_HOOK)
	_add_cylinder(root, "BackPlate", 0.035, 0.34, Vector3(0.0, 0.18, 0.0), _family(root))
	_add_cylinder(
		root,
		"HookArm",
		0.018,
		0.32,
		Vector3(0.0, 0.25, -0.12),
		_family(root),
		Vector3(90.0, 0.0, 0.0)
	)
	_add_cylinder(
		root,
		"CableLoop",
		0.016,
		0.26,
		Vector3(0.0, 0.16, -0.15),
		StarterDetailBuilderScript.FAMILY_RUBBER,
		Vector3(90.0, 0.0, 0.0)
	)
	return root


## Builds a receipt slip from caller-owned line text.
static func receipt_slip(lines: Array = []) -> Node3D:
	var root: Node3D = _flat_text_detail(
		DETAIL_RECEIPT_SLIP, _joined_lines(lines), Vector3(0.22, 0.018, 0.46)
	)
	_add_box(
		root,
		"PrinterCurl",
		Vector3(0.0, 0.018, -0.25),
		Vector3(0.20, 0.022, 0.035),
		_family(root),
		StarterDetailBuilderScript.ROLE_LIP
	)
	return root


## Builds a label plate from caller-owned text.
static func label_plate(label_text: String = "") -> Node3D:
	var root: Node3D = _flat_text_detail(DETAIL_LABEL_PLATE, label_text, Vector3(0.36, 0.035, 0.14))
	_add_box(
		root,
		"DarkBacker",
		Vector3(0.0, -0.006, 0.0),
		Vector3(0.40, 0.014, 0.18),
		StarterDetailBuilderScript.FAMILY_SHADOW_ACCENT,
		StarterDetailBuilderScript.ROLE_TRIM
	)
	return root


## Builds a queue stanchion pair with a rope.
static func queue_stanchion_rope() -> Node3D:
	var root: Node3D = _root(DETAIL_QUEUE_STANCHION_ROPE)
	for x: float in [-0.34, 0.34]:
		_add_cylinder(
			root,
			"Post%03d" % int(round((x + 0.5) * 100.0)),
			0.028,
			0.58,
			Vector3(x, 0.29, 0.0),
			StarterDetailBuilderScript.FAMILY_STOCKROOM_COOL_METAL
		)
		_add_cylinder(
			root,
			"Base%03d" % int(round((x + 0.5) * 100.0)),
			0.075,
			0.030,
			Vector3(x, 0.015, 0.0),
			StarterDetailBuilderScript.FAMILY_RUBBER
		)
	_add_cylinder(
		root, "Rope", 0.022, 0.70, Vector3(0.0, 0.50, 0.0), _family(root), Vector3(0.0, 0.0, 90.0)
	)
	return root


## Builds a window decal from caller-owned text.
static func window_decal(label_text: String = "") -> Node3D:
	return _flat_text_detail(DETAIL_WINDOW_DECAL, label_text, Vector3(0.42, 0.012, 0.24))


## Builds an hours plaque from caller-owned text.
static func hours_plaque(label_text: String = "") -> Node3D:
	return _flat_text_detail(DETAIL_HOURS_PLAQUE, label_text, Vector3(0.32, 0.030, 0.24))


## Builds a floor mat from caller-owned text.
static func floor_mat(label_text: String = "") -> Node3D:
	var root: Node3D = _flat_text_detail(DETAIL_FLOOR_MAT, label_text, Vector3(0.82, 0.024, 0.46))
	_add_box(
		root,
		"InsetStripeA",
		Vector3(-0.24, 0.020, 0.0),
		Vector3(0.035, 0.012, 0.40),
		StarterDetailBuilderScript.FAMILY_SHADOW_ACCENT,
		StarterDetailBuilderScript.ROLE_SEAM
	)
	_add_box(
		root,
		"InsetStripeB",
		Vector3(0.24, 0.020, 0.0),
		Vector3(0.035, 0.012, 0.40),
		StarterDetailBuilderScript.FAMILY_SHADOW_ACCENT,
		StarterDetailBuilderScript.ROLE_SEAM
	)
	return root


## Builds a small stockroom label from caller-owned text.
static func stockroom_label(label_text: String = "") -> Node3D:
	return _flat_text_detail(DETAIL_STOCKROOM_LABEL, label_text, Vector3(0.30, 0.024, 0.13))


## Builds a condition sticker from caller-owned text.
static func condition_sticker(label_text: String = "") -> Node3D:
	return _flat_text_detail(DETAIL_CONDITION_STICKER, label_text, Vector3(0.14, 0.024, 0.10))


## Builds a protective sleeve visual with no product identity baked in.
static func protective_sleeve() -> Node3D:
	var root: Node3D = _root(DETAIL_PROTECTIVE_SLEEVE)
	_add_box(
		root,
		"SleeveBack",
		Vector3.ZERO,
		Vector3(0.34, 0.018, 0.48),
		_family(root),
		StarterDetailBuilderScript.ROLE_PANEL
	)
	_add_box(
		root,
		"SleeveLip",
		Vector3(0.0, 0.020, -0.24),
		Vector3(0.34, 0.014, 0.030),
		StarterDetailBuilderScript.FAMILY_SHADOW_ACCENT,
		StarterDetailBuilderScript.ROLE_LIP
	)
	return root


## Builds a display placard from caller-owned text.
static func display_placard(label_text: String = "") -> Node3D:
	var root: Node3D = _flat_text_detail(
		DETAIL_DISPLAY_PLACARD, label_text, Vector3(0.34, 0.030, 0.22)
	)
	_add_box(
		root,
		"StandFoot",
		Vector3(0.0, -0.04, 0.09),
		Vector3(0.26, 0.030, 0.08),
		StarterDetailBuilderScript.FAMILY_WOOD_LAMINATE,
		StarterDetailBuilderScript.ROLE_BRACE
	)
	return root


static func _flat_text_detail(detail_id: StringName, text: String, size: Vector3) -> Node3D:
	var root: Node3D = _root(detail_id)
	_add_box(
		root, "Panel", Vector3.ZERO, size, _family(root), StarterDetailBuilderScript.ROLE_LABEL
	)
	_add_label(root, "LabelText", text, Vector3(0.0, size.y + 0.004, 0.0), 0.018)
	return root


static func _root(detail_id: StringName) -> Node3D:
	var spec: Dictionary = _DETAIL_SPECS.get(detail_id, {}) as Dictionary
	var root := Node3D.new()
	root.name = str(spec.get("name", "RetailDetail"))
	root.set_meta("store_visual_id", detail_id)
	root.set_meta("store_visual_source", "retail_detail_builder")
	root.set_meta("store_visual_source_type", &"procedural")
	root.set_meta("store_detail_type", detail_id)
	root.set_meta("store_visual_role", spec.get("role", &""))
	root.set_meta("store_visual_groups", (spec.get("groups", []) as Array).duplicate())
	root.set_meta("store_visual_display_name", str(spec.get("display_name", "")))
	root.set_meta("visual_only", true)
	StarterDetailBuilderScript.apply_visual_metadata(
		root,
		spec.get("family", StarterDetailBuilderScript.FAMILY_PAPER) as StringName,
		StarterDetailBuilderScript.ROLE_LABEL
	)
	return root


static func _family(root: Node) -> StringName:
	return root.get_meta("starter_material_family") as StringName


static func _joined_lines(lines: Array) -> String:
	var text_lines: Array[String] = []
	for line: Variant in lines:
		text_lines.append(str(line))
	return "\n".join(text_lines)


static func _add_label(
	parent: Node3D, name: String, text: String, position: Vector3, pixel_size: float
) -> Label3D:
	var label := Label3D.new()
	label.name = name
	label.text = text
	label.position = position
	label.pixel_size = pixel_size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_meta("caller_owned_text", true)
	StarterDetailBuilderScript.apply_visual_metadata(
		label, StarterDetailBuilderScript.FAMILY_PAPER, StarterDetailBuilderScript.ROLE_LABEL
	)
	parent.add_child(label)
	return label


static func _add_box(
	parent: Node3D,
	name: String,
	position: Vector3,
	size: Vector3,
	family: StringName,
	role: StringName
) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	return _add_mesh(parent, name, mesh, position, Vector3.ZERO, family, role)


static func _add_cylinder(
	parent: Node3D,
	name: String,
	radius: float,
	height: float,
	position: Vector3,
	family: StringName,
	rotation_degrees: Vector3 = Vector3.ZERO
) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 14
	return _add_mesh(
		parent,
		name,
		mesh,
		position,
		rotation_degrees,
		family,
		StarterDetailBuilderScript.ROLE_CABLE
	)


static func _add_mesh(
	parent: Node3D,
	name: String,
	mesh: Mesh,
	position: Vector3,
	rotation_degrees: Vector3,
	family: StringName,
	role: StringName
) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = name
	instance.mesh = mesh
	instance.position = position
	instance.rotation_degrees = rotation_degrees
	instance.material_override = StarterDetailBuilderScript.material_for(family)
	StarterDetailBuilderScript.apply_visual_metadata(instance, family, role)
	parent.add_child(instance)
	return instance
