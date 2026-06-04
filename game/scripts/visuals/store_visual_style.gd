## Shared 3D material families, tokens, and metadata for generated store visuals.
class_name StoreVisualStyle
extends RefCounted

const FAMILY_WOOD_LAMINATE: StringName = &"wood_laminate"
const FAMILY_DARK_DEVICE_PLASTIC: StringName = &"dark_device_plastic"
const FAMILY_CARDBOARD: StringName = &"cardboard"
const FAMILY_PAPER: StringName = &"paper"
const FAMILY_PRICE_TAG_WARM: StringName = &"price_tag_warm"
const FAMILY_STOCKROOM_COOL_METAL: StringName = &"stockroom_cool_metal"
const FAMILY_RUBBER: StringName = &"rubber"
const FAMILY_SHADOW_ACCENT: StringName = &"shadow_accent"
const FAMILY_MALL_THRESHOLD_GLASS: StringName = &"mall_threshold_glass"
const FAMILY_MALL_THRESHOLD_METAL: StringName = &"mall_threshold_metal"
const FAMILY_MALL_THRESHOLD_TILE: StringName = &"mall_threshold_tile"
const FAMILY_SALES_FLOOR_WARM: StringName = &"sales_floor_warm"
const FAMILY_AMBER_SIGNAGE: StringName = &"amber_signage"
const FAMILY_PRODUCT_ACCENT_BLUE: StringName = &"product_accent_blue"
const FAMILY_PRODUCT_ACCENT_GREEN: StringName = &"product_accent_green"
const FAMILY_PRODUCT_ACCENT_RED: StringName = &"product_accent_red"
const FAMILY_PRODUCT_ACCENT_PURPLE: StringName = &"product_accent_purple"
const FAMILY_PRODUCT_ACCENT_TEAL: StringName = &"product_accent_teal"

const ROLE_PANEL: StringName = &"panel"
const ROLE_TRIM: StringName = &"trim"
const ROLE_LABEL: StringName = &"label"
const ROLE_SEAM: StringName = &"seam"
const ROLE_LIP: StringName = &"lip"
const ROLE_BRACE: StringName = &"brace"
const ROLE_MAT: StringName = &"mat"
const ROLE_CABLE: StringName = &"cable"

const TOKEN_SHELL_WALL_PANEL: StringName = &"world.shell.wall.panel"
const TOKEN_SHELL_DARK_TRIM: StringName = &"world.shell.dark.trim"
const TOKEN_SALES_FLOOR_FILL: StringName = &"world.sales_floor.fill"
const TOKEN_SALES_FLOOR_PANEL: StringName = &"world.sales_floor.panel"
const TOKEN_SALES_FLOOR_SEAM: StringName = &"world.sales_floor.seam"
const TOKEN_SALES_FLOOR_SCUFF: StringName = &"world.sales_floor.scuff"
const TOKEN_CHECKOUT_WARM_PANEL: StringName = &"world.checkout.warm.panel"
const TOKEN_CHECKOUT_DEVICE_BODY: StringName = &"world.checkout.device.body"
const TOKEN_STOCKROOM_METAL_PANEL: StringName = &"world.stockroom.metal.panel"
const TOKEN_STOCKROOM_METAL_FLOOR: StringName = &"world.stockroom.metal.floor"
const TOKEN_STOCKROOM_RACK_BRACE: StringName = &"world.stockroom.rack.brace"
const TOKEN_SIGNAGE_AMBER_PANEL: StringName = &"world.signage.amber.panel"
const TOKEN_SIGNAGE_AMBER_TRIM: StringName = &"world.signage.amber.trim"
const TOKEN_PAPER_LABEL_FILL: StringName = &"world.paper.label.fill"
const TOKEN_PRICE_TAG_FILL: StringName = &"world.label.price.fill"
const TOKEN_CARDBOARD_BOX_PANEL: StringName = &"world.cardboard.box.panel"
const TOKEN_RUBBER_FLOOR_MAT: StringName = &"world.rubber.floor.mat"
const TOKEN_SHADOW_ACCENT_SEAM: StringName = &"world.shadow_accent.seam"
const TOKEN_THRESHOLD_GLASS_PANEL: StringName = &"world.threshold.glass.panel"
const TOKEN_THRESHOLD_METAL_TRIM: StringName = &"world.threshold.metal.trim"
const TOKEN_THRESHOLD_TILE_PLATE: StringName = &"world.threshold.tile.plate"
const TOKEN_PRODUCT_ACCENT_BLUE: StringName = &"world.product.accent.blue"
const TOKEN_PRODUCT_ACCENT_GREEN: StringName = &"world.product.accent.green"
const TOKEN_PRODUCT_ACCENT_RED: StringName = &"world.product.accent.red"
const TOKEN_PRODUCT_ACCENT_PURPLE: StringName = &"world.product.accent.purple"
const TOKEN_PRODUCT_ACCENT_TEAL: StringName = &"world.product.accent.teal"

const RECIPE_SHELL: StringName = &"shell"
const RECIPE_STOCKROOM: StringName = &"stockroom"
const RECIPE_CHECKOUT: StringName = &"checkout"
const RECIPE_SIGNAGE: StringName = &"signage"
const RECIPE_PRODUCT: StringName = &"product"

const STARTER_FAMILY_IDS: Array[StringName] = [
	FAMILY_WOOD_LAMINATE,
	FAMILY_DARK_DEVICE_PLASTIC,
	FAMILY_CARDBOARD,
	FAMILY_PAPER,
	FAMILY_PRICE_TAG_WARM,
	FAMILY_STOCKROOM_COOL_METAL,
	FAMILY_RUBBER,
	FAMILY_SHADOW_ACCENT,
]

const _MATERIAL_FAMILY_SPECS: Dictionary = {
	FAMILY_WOOD_LAMINATE: {"color": Color(0.54, 0.34, 0.17, 1.0), "roughness": 0.86},
	FAMILY_DARK_DEVICE_PLASTIC: {"color": Color(0.10, 0.11, 0.13, 1.0), "roughness": 0.84},
	FAMILY_CARDBOARD: {"color": Color(0.56, 0.36, 0.18, 1.0), "roughness": 0.90},
	FAMILY_PAPER: {"color": Color(0.96, 0.90, 0.74, 1.0), "roughness": 0.92},
	FAMILY_PRICE_TAG_WARM:
	{
		"color": Color(0.94, 0.79, 0.48, 1.0),
		"emission": Color(0.72, 0.48, 0.18, 1.0),
		"emission_energy": 0.08,
		"roughness": 0.72,
	},
	FAMILY_STOCKROOM_COOL_METAL: {"color": Color(0.33, 0.39, 0.41, 1.0), "roughness": 0.88},
	FAMILY_RUBBER: {"color": Color(0.05, 0.055, 0.055, 1.0), "roughness": 0.94},
	FAMILY_SHADOW_ACCENT: {"color": Color(0.17, 0.18, 0.18, 1.0), "roughness": 0.95},
	FAMILY_MALL_THRESHOLD_GLASS:
	{"color": Color(0.38, 0.47, 0.50, 0.11), "roughness": 0.28, "transparency": true},
	FAMILY_MALL_THRESHOLD_METAL: {"color": Color(0.24, 0.22, 0.20, 1.0), "roughness": 0.62},
	FAMILY_MALL_THRESHOLD_TILE: {"color": Color(0.43, 0.34, 0.22, 1.0), "roughness": 0.82},
	FAMILY_SALES_FLOOR_WARM: {"color": Color(0.44, 0.29, 0.17, 1.0), "roughness": 0.88},
	FAMILY_AMBER_SIGNAGE:
	{
		"color": Color(1.0, 0.78, 0.30, 1.0),
		"emission": Color(1.0, 0.63, 0.18, 1.0),
		"emission_energy": 0.35,
		"roughness": 0.70,
	},
	FAMILY_PRODUCT_ACCENT_BLUE: {"color": Color(0.05, 0.12, 0.32, 1.0), "roughness": 0.78},
	FAMILY_PRODUCT_ACCENT_GREEN: {"color": Color(0.03, 0.23, 0.15, 1.0), "roughness": 0.78},
	FAMILY_PRODUCT_ACCENT_RED: {"color": Color(0.35, 0.08, 0.05, 1.0), "roughness": 0.78},
	FAMILY_PRODUCT_ACCENT_PURPLE: {"color": Color(0.26, 0.12, 0.34, 1.0), "roughness": 0.78},
	FAMILY_PRODUCT_ACCENT_TEAL: {"color": Color(0.04, 0.30, 0.32, 1.0), "roughness": 0.78},
}

const _MATERIAL_TOKENS: Dictionary = {
	TOKEN_SHELL_WALL_PANEL: {
		"family": FAMILY_PAPER,
		"role": ROLE_PANEL,
		"color": Color(0.54, 0.49, 0.41, 1.0),
	},
	TOKEN_SHELL_DARK_TRIM: {
		"family": FAMILY_DARK_DEVICE_PLASTIC,
		"role": ROLE_TRIM,
		"color": Color(0.15, 0.10, 0.07, 1.0),
	},
	TOKEN_SALES_FLOOR_FILL: {"family": FAMILY_SALES_FLOOR_WARM, "role": ROLE_PANEL},
	TOKEN_SALES_FLOOR_PANEL: {
		"family": FAMILY_SALES_FLOOR_WARM,
		"role": ROLE_PANEL,
		"color": Color(0.59, 0.50, 0.37, 1.0),
	},
	TOKEN_SALES_FLOOR_SEAM: {
		"family": FAMILY_SALES_FLOOR_WARM,
		"role": ROLE_SEAM,
		"color": Color(0.38, 0.24, 0.14, 1.0),
	},
	TOKEN_SALES_FLOOR_SCUFF: {
		"family": FAMILY_SALES_FLOOR_WARM,
		"role": ROLE_SEAM,
		"color": Color(0.40, 0.26, 0.16, 1.0),
	},
	TOKEN_CHECKOUT_WARM_PANEL: {
		"family": FAMILY_WOOD_LAMINATE,
		"role": ROLE_PANEL,
		"color": Color(0.62, 0.42, 0.22, 1.0),
	},
	TOKEN_CHECKOUT_DEVICE_BODY: {"family": FAMILY_DARK_DEVICE_PLASTIC, "role": ROLE_PANEL},
	TOKEN_STOCKROOM_METAL_PANEL: {
		"family": FAMILY_STOCKROOM_COOL_METAL,
		"role": ROLE_PANEL,
		"color": Color(0.31, 0.37, 0.39, 1.0),
	},
	TOKEN_STOCKROOM_METAL_FLOOR: {
		"family": FAMILY_STOCKROOM_COOL_METAL,
		"role": ROLE_MAT,
		"color": Color(0.27, 0.35, 0.37, 1.0),
	},
	TOKEN_STOCKROOM_RACK_BRACE: {"family": FAMILY_STOCKROOM_COOL_METAL, "role": ROLE_BRACE},
	TOKEN_SIGNAGE_AMBER_PANEL: {"family": FAMILY_AMBER_SIGNAGE, "role": ROLE_PANEL},
	TOKEN_SIGNAGE_AMBER_TRIM: {"family": FAMILY_AMBER_SIGNAGE, "role": ROLE_TRIM},
	TOKEN_PAPER_LABEL_FILL: {"family": FAMILY_PAPER, "role": ROLE_LABEL},
	TOKEN_PRICE_TAG_FILL: {"family": FAMILY_PRICE_TAG_WARM, "role": ROLE_LABEL},
	TOKEN_CARDBOARD_BOX_PANEL: {"family": FAMILY_CARDBOARD, "role": ROLE_PANEL},
	TOKEN_RUBBER_FLOOR_MAT: {"family": FAMILY_RUBBER, "role": ROLE_MAT},
	TOKEN_SHADOW_ACCENT_SEAM: {"family": FAMILY_SHADOW_ACCENT, "role": ROLE_SEAM},
	TOKEN_THRESHOLD_GLASS_PANEL: {"family": FAMILY_MALL_THRESHOLD_GLASS, "role": ROLE_PANEL},
	TOKEN_THRESHOLD_METAL_TRIM: {"family": FAMILY_MALL_THRESHOLD_METAL, "role": ROLE_TRIM},
	TOKEN_THRESHOLD_TILE_PLATE: {"family": FAMILY_MALL_THRESHOLD_TILE, "role": ROLE_MAT},
	TOKEN_PRODUCT_ACCENT_BLUE: {"family": FAMILY_PRODUCT_ACCENT_BLUE, "role": ROLE_PANEL},
	TOKEN_PRODUCT_ACCENT_GREEN: {"family": FAMILY_PRODUCT_ACCENT_GREEN, "role": ROLE_PANEL},
	TOKEN_PRODUCT_ACCENT_RED: {"family": FAMILY_PRODUCT_ACCENT_RED, "role": ROLE_PANEL},
	TOKEN_PRODUCT_ACCENT_PURPLE: {"family": FAMILY_PRODUCT_ACCENT_PURPLE, "role": ROLE_PANEL},
	TOKEN_PRODUCT_ACCENT_TEAL: {"family": FAMILY_PRODUCT_ACCENT_TEAL, "role": ROLE_PANEL},
}

const _SURFACE_RECIPES: Dictionary = {
	RECIPE_SHELL:
	{
		"wall": TOKEN_SHELL_WALL_PANEL,
		"trim": TOKEN_SHELL_DARK_TRIM,
		"floor": TOKEN_SALES_FLOOR_FILL,
		"floor_panel": TOKEN_SALES_FLOOR_PANEL,
		"floor_seam": TOKEN_SALES_FLOOR_SEAM,
		"floor_scuff": TOKEN_SALES_FLOOR_SCUFF,
		"threshold_glass": TOKEN_THRESHOLD_GLASS_PANEL,
		"threshold_metal": TOKEN_THRESHOLD_METAL_TRIM,
		"threshold_tile": TOKEN_THRESHOLD_TILE_PLATE,
	},
	RECIPE_STOCKROOM:
	{
		"floor": TOKEN_STOCKROOM_METAL_FLOOR,
		"panel": TOKEN_STOCKROOM_METAL_PANEL,
		"rack": TOKEN_STOCKROOM_RACK_BRACE,
		"box": TOKEN_CARDBOARD_BOX_PANEL,
		"label": TOKEN_PAPER_LABEL_FILL,
		"rubber": TOKEN_RUBBER_FLOOR_MAT,
	},
	RECIPE_CHECKOUT:
	{
		"counter": FAMILY_WOOD_LAMINATE,
		"service_panel": TOKEN_CHECKOUT_WARM_PANEL,
		"device": TOKEN_CHECKOUT_DEVICE_BODY,
		"paper": TOKEN_PAPER_LABEL_FILL,
		"mat": TOKEN_RUBBER_FLOOR_MAT,
	},
	RECIPE_SIGNAGE:
	{
		"panel": TOKEN_SIGNAGE_AMBER_PANEL,
		"trim": TOKEN_SIGNAGE_AMBER_TRIM,
		"paper": TOKEN_PAPER_LABEL_FILL,
	},
	RECIPE_PRODUCT:
	{
		"price_tag": TOKEN_PRICE_TAG_FILL,
		"blue": TOKEN_PRODUCT_ACCENT_BLUE,
		"green": TOKEN_PRODUCT_ACCENT_GREEN,
		"red": TOKEN_PRODUCT_ACCENT_RED,
		"purple": TOKEN_PRODUCT_ACCENT_PURPLE,
		"teal": TOKEN_PRODUCT_ACCENT_TEAL,
	},
}


## Returns every known world material family id.
static func material_family_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for raw_id: Variant in _MATERIAL_FAMILY_SPECS.keys():
		ids.append(raw_id as StringName)
	return ids


## Returns the legacy starter family ids exposed by StarterDetailBuilder.
static func starter_material_family_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for family: StringName in STARTER_FAMILY_IDS:
		ids.append(family)
	return ids


## Builds a material for a material family while preserving family metadata.
static func material_for_family(family: StringName) -> StandardMaterial3D:
	var specs: Dictionary = _MATERIAL_FAMILY_SPECS.get(family, {}) as Dictionary
	if specs.is_empty():
		return null
	return _material_from_spec(family, family, &"", specs)


## Builds a material for a specific semantic token.
static func material_for_token(token: StringName) -> StandardMaterial3D:
	var specs: Dictionary = _MATERIAL_TOKENS.get(token, {}) as Dictionary
	if specs.is_empty():
		return null
	return _material_from_spec(token, family_for_token(token), role_for_token(token), specs)


## Returns a token's material family without coupling it to the detail role.
static func family_for_token(token: StringName) -> StringName:
	var specs: Dictionary = _MATERIAL_TOKENS.get(token, {}) as Dictionary
	return specs.get("family", &"") as StringName


## Returns a token's default detail role without coupling it to the family.
static func role_for_token(token: StringName) -> StringName:
	var specs: Dictionary = _MATERIAL_TOKENS.get(token, {}) as Dictionary
	return specs.get("role", &"") as StringName


## Returns a named recipe mapping semantic surface slots to families or tokens.
static func surface_recipe(recipe_id: StringName) -> Dictionary:
	var recipe: Dictionary = _SURFACE_RECIPES.get(recipe_id, {}) as Dictionary
	return recipe.duplicate()


## Adds visual metadata while keeping starter compatibility keys available.
static func apply_metadata(
	node: Node, family: StringName, role: StringName, token: StringName = &""
) -> void:
	if node == null:
		return
	node.set_meta("starter_visual_only", true)
	if not String(token).is_empty():
		node.set_meta("store_material_token", token)
	node.set_meta("store_material_family", family)
	node.set_meta("starter_material_family", family)
	node.set_meta("starter_detail_role", role)


## Adds family/role metadata from a material created by this style registry.
static func apply_material_metadata(
	node: Node, material: Material, fallback_role: StringName = ROLE_PANEL
) -> void:
	if node == null or material == null:
		return
	var family: StringName = material_family_for_material(material)
	if String(family).is_empty():
		return
	var token: StringName = material_token_for_material(material)
	var role: StringName = material_role_for_material(material)
	if String(role).is_empty():
		role = fallback_role
	apply_metadata(node, family, role, token)


## Returns a node's material family from compatible metadata or material tags.
static func material_family_for_node(node: Node) -> StringName:
	if node == null:
		return &""
	if node.has_meta("store_material_family"):
		return node.get_meta("store_material_family") as StringName
	if node.has_meta("starter_material_family"):
		return node.get_meta("starter_material_family") as StringName
	var mesh_instance: MeshInstance3D = node as MeshInstance3D
	if mesh_instance == null:
		return &""
	return material_family_for_material(mesh_instance.material_override)


## Builds the active or inactive store accent as a world material.
static func store_accent_material(store_id: StringName, active: bool = true) -> StandardMaterial3D:
	var color: Color = UIThemeConstants.get_store_accent(store_id, active)
	var material := StandardMaterial3D.new()
	material.resource_name = "store_%s_accent_%s" % [store_id, "active" if active else "inactive"]
	material.albedo_color = color
	material.roughness = 0.78
	material.metallic = 0.0
	material.set_meta("store_material_family", FAMILY_AMBER_SIGNAGE)
	return material


static func material_family_for_material(material: Material) -> StringName:
	if material == null:
		return &""
	if material.has_meta("store_material_family"):
		return material.get_meta("store_material_family") as StringName
	if material.has_meta("starter_material_family"):
		return material.get_meta("starter_material_family") as StringName
	var resource_id := StringName(material.resource_name)
	if _MATERIAL_FAMILY_SPECS.has(resource_id):
		return resource_id
	return &""


static func material_token_for_material(material: Material) -> StringName:
	if material != null and material.has_meta("store_material_token"):
		return material.get_meta("store_material_token") as StringName
	return &""


static func material_role_for_material(material: Material) -> StringName:
	if material != null and material.has_meta("starter_detail_role"):
		return material.get_meta("starter_detail_role") as StringName
	return &""


static func _material_from_spec(
	resource_id: StringName, family: StringName, role: StringName, specs: Dictionary
) -> StandardMaterial3D:
	var family_specs: Dictionary = _MATERIAL_FAMILY_SPECS.get(family, {}) as Dictionary
	var material := StandardMaterial3D.new()
	material.resource_name = String(resource_id)
	material.albedo_color = specs.get("color", family_specs.get("color", Color.WHITE)) as Color
	material.roughness = float(specs.get("roughness", family_specs.get("roughness", 0.86)))
	material.metallic = float(specs.get("metallic", family_specs.get("metallic", 0.0)))
	var emission_energy: float = float(
		specs.get("emission_energy", family_specs.get("emission_energy", 0.0))
	)
	if emission_energy > 0.0:
		material.emission_enabled = true
		material.emission = specs.get(
			"emission", family_specs.get("emission", Color.TRANSPARENT)
		) as Color
		material.emission_energy_multiplier = emission_energy
	if bool(specs.get("transparency", family_specs.get("transparency", false))):
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.blend_mode = BaseMaterial3D.BLEND_MODE_MIX
	material.set_meta("store_material_family", family)
	material.set_meta("starter_material_family", family)
	if not String(role).is_empty():
		material.set_meta("starter_detail_role", role)
	if resource_id != family:
		material.set_meta("store_material_token", resource_id)
	return material
