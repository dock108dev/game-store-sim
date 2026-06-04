# gdlint:disable=max-file-lines
## Registry for reusable store fixture/prop scenes used by store layouts and
## runtime feedback. This is visual-only: inventory, unlocks, and economy stay
## in the game systems that decide when these assets appear.
## See cleanup-report.md "Files still >500 LOC": factories need separate helpers.
class_name StoreVisualKit
extends RefCounted

const StarterDetailBuilderScript: GDScript = preload(
	"res://game/scripts/visuals/starter_detail_builder.gd"
)
const SmallDisplayPropBuilderScript: GDScript = preload(
	"res://game/scripts/visuals/small_display_prop_builder.gd"
)

const WALL_SHELF: StringName = &"wall_shelf"
const FLOOR_RACK: StringName = &"floor_rack"
const DISPLAY_TABLE: StringName = &"display_table"
const CHECKOUT_COUNTER: StringName = &"checkout_counter"
const STOCKROOM_TABLE: StringName = &"stockroom_table"
const STOCKROOM_SHELF: StringName = &"stockroom_shelf"
const STOCK_BOX: StringName = &"stock_box"
const GAME_CASE: StringName = &"game_case"
const CONSOLE_BOX: StringName = &"console_box"
const REGISTER: StringName = &"register"
const RECEIPT_PRINTER: StringName = &"receipt_printer"
const CARD_READER: StringName = &"card_reader"
const QUEUE_LANE: StringName = &"queue_lane"
const PRICE_TAG: StringName = &"price_tag"
const PRODUCT_PRICE_TAG: StringName = &"product_price_tag"
const SHELF_LABEL: StringName = &"shelf_label"
const SIGN_SHELF_LABEL: StringName = &"sign_shelf_label"
const ACRYLIC_STAND: StringName = &"acrylic_stand"
const CONTROLLER_BIN_PROP: StringName = &"controller_bin_prop"
const REPAIR_TESTING_MAT: StringName = &"repair_testing_mat"
const TAPED_BOX_LABEL: StringName = &"taped_box_label"
const SECURITY_TAG_BLOCK: StringName = &"security_tag_block"
const GLTF_COUNTER_REGISTER: StringName = &"gltf_counter_register"
const GLTF_GAME_CASE: StringName = &"gltf_game_case"
const GLTF_CONSOLE_BOX: StringName = &"gltf_console_box"
const GLTF_CARTRIDGE_GB: StringName = &"gltf_cartridge_gb"
const GLTF_CARTRIDGE_N64: StringName = &"gltf_cartridge_n64"
const GLTF_CARTRIDGE_SNES: StringName = &"gltf_cartridge_snes"
const GLTF_CONSOLE_N64: StringName = &"gltf_console_n64"
const GLTF_CONSOLE_PS1: StringName = &"gltf_console_ps1"
const GLTF_CONSOLE_SNES: StringName = &"gltf_console_snes"
const GLTF_CRT_MONITOR: StringName = &"gltf_crt_monitor"
const GLTF_HOLD_TAG: StringName = &"gltf_hold_tag"
const GLTF_RECEIPT_PRINTER: StringName = &"gltf_receipt_printer"
const GLTF_REGISTER_MONITOR: StringName = &"gltf_register_monitor"
const BARCODE_SCANNER: StringName = &"barcode_scanner"
const CLIPBOARD: StringName = &"clipboard"
const HAND_TRUCK: StringName = &"hand_truck"
const PAPER_STACK: StringName = &"paper_stack"
const SHIPPING_SCALE: StringName = &"shipping_scale"
const TAPE_ROLL: StringName = &"tape_roll"

const ROLE_FIXTURE: StringName = &"fixture"
const ROLE_TOOL: StringName = &"tool"
const ROLE_PRODUCT: StringName = &"product"
const ROLE_SIGNAGE: StringName = &"signage"
const ROLE_DECOR: StringName = &"decor"
const ROLE_ROUTE_CUE: StringName = &"route_cue"
const ROLE_STOCKROOM: StringName = &"stockroom"
const ROLE_SERVICE: StringName = &"service"

const GROUP_RETAIL_FLOOR: StringName = &"retail_floor"
const GROUP_CHECKOUT: StringName = &"checkout"
const GROUP_STOCKROOM: StringName = &"stockroom"
const GROUP_PRODUCT_DISPLAY: StringName = &"product_display"
const GROUP_PRICING: StringName = &"pricing"
const GROUP_WAYFINDING: StringName = &"wayfinding"
const GROUP_BACK_OF_HOUSE: StringName = &"back_of_house"
const GROUP_STARTER_KIT: StringName = &"starter_kit"
const GROUP_SHELL_PROP: StringName = &"shell_prop"

const STARTER_CHECKOUT_COUNTER: StringName = &"starter_checkout_counter"
const STARTER_REGISTER_TERMINAL: StringName = &"starter_register_terminal"
const STARTER_CARD_READER: StringName = &"starter_card_reader"
const STARTER_RECEIPT_PRINTER: StringName = &"starter_receipt_printer"
const STARTER_STOCKROOM_SHELF: StringName = &"starter_stockroom_shelf"
const STARTER_ACRYLIC_STAND: StringName = &"starter_acrylic_stand"
const STARTER_CONTROLLER_BIN: StringName = &"starter_controller_bin"
const STARTER_REPAIR_TESTING_MAT: StringName = &"starter_repair_testing_mat"
const STARTER_CLIPBOARD_INTAKE_SLIP: StringName = &"starter_clipboard_intake_slip"
const STARTER_TAPED_BOX_LABEL: StringName = &"starter_taped_box_label"
const STARTER_SECURITY_TAG_BLOCK: StringName = &"starter_security_tag_block"

const _SCENE_PATHS: Dictionary = {
	WALL_SHELF: "res://game/scenes/stores/fixtures/retail_wall_shelf.tscn",
	FLOOR_RACK: "res://game/scenes/stores/fixtures/retail_gondola_shelf.tscn",
	DISPLAY_TABLE: "res://game/scenes/stores/fixtures/fixture_display_table.tscn",
	CHECKOUT_COUNTER: "res://game/scenes/stores/fixtures/fixture_checkout_counter.tscn",
	STOCKROOM_TABLE: "res://game/scenes/stores/fixtures/fixture_stockroom_table.tscn",
	STOCK_BOX: "res://game/scenes/stores/fixtures/box_stack.tscn",
	GAME_CASE: "res://game/scenes/stores/fixtures/prop_game_case.tscn",
	CONSOLE_BOX: "res://game/scenes/stores/fixtures/prop_console_box.tscn",
	REGISTER: "res://game/scenes/stores/fixtures/prop_register.tscn",
	RECEIPT_PRINTER: "res://game/scenes/stores/fixtures/prop_receipt_printer.tscn",
	CARD_READER: "res://game/scenes/stores/fixtures/prop_card_reader.tscn",
	QUEUE_LANE: "res://game/scenes/stores/fixtures/fixture_queue_lane.tscn",
	PRICE_TAG: "res://game/scenes/stores/fixtures/price_tag.tscn",
	SHELF_LABEL: "res://game/scenes/stores/fixtures/shelf_label.tscn",
	SIGN_SHELF_LABEL: "res://game/scenes/stores/fixtures/sign_shelf_label.tscn",
	GLTF_COUNTER_REGISTER: "res://game/assets/models/fixtures/prop_counter_register.gltf",
	GLTF_GAME_CASE: "res://game/assets/models/props/prop_game_case.gltf",
	GLTF_CONSOLE_BOX: "res://game/assets/models/props/prop_console_box.gltf",
	GLTF_CARTRIDGE_GB: "res://game/assets/models/props/prop_cartridge_gb.gltf",
	GLTF_CARTRIDGE_N64: "res://game/assets/models/props/prop_cartridge_n64.gltf",
	GLTF_CARTRIDGE_SNES: "res://game/assets/models/props/prop_cartridge_snes.gltf",
	GLTF_CONSOLE_N64: "res://game/assets/models/props/prop_console_n64.gltf",
	GLTF_CONSOLE_PS1: "res://game/assets/models/props/prop_console_ps1.gltf",
	GLTF_CONSOLE_SNES: "res://game/assets/models/props/prop_console_snes.gltf",
	GLTF_CRT_MONITOR: "res://game/assets/models/props/prop_crt_monitor.gltf",
	GLTF_HOLD_TAG: "res://game/assets/models/props/prop_hold_tag.gltf",
	GLTF_RECEIPT_PRINTER: "res://game/assets/models/props/prop_receipt_printer.gltf",
	GLTF_REGISTER_MONITOR: "res://game/assets/models/props/prop_register_monitor.gltf",
}

const _STARTER_STORE_IDS: Array[StringName] = [
	WALL_SHELF,
	FLOOR_RACK,
	DISPLAY_TABLE,
	CHECKOUT_COUNTER,
	STOCKROOM_TABLE,
	STOCKROOM_SHELF,
	STOCK_BOX,
	GAME_CASE,
	CONSOLE_BOX,
	REGISTER,
	CARD_READER,
	RECEIPT_PRINTER,
	PRICE_TAG,
	SHELF_LABEL,
	SIGN_SHELF_LABEL,
	ACRYLIC_STAND,
	CONTROLLER_BIN_PROP,
	REPAIR_TESTING_MAT,
	CLIPBOARD,
	TAPED_BOX_LABEL,
	SECURITY_TAG_BLOCK,
]

const _STARTER_SHELL_PROP_IDS: Array[StringName] = [
	GLTF_COUNTER_REGISTER,
	GLTF_GAME_CASE,
	GLTF_CONSOLE_BOX,
	GLTF_CARTRIDGE_GB,
	GLTF_CARTRIDGE_N64,
	GLTF_CARTRIDGE_SNES,
	GLTF_CONSOLE_N64,
	GLTF_CONSOLE_PS1,
	GLTF_CONSOLE_SNES,
	GLTF_CRT_MONITOR,
	GLTF_HOLD_TAG,
	RECEIPT_PRINTER,
	REGISTER,
	STOCK_BOX,
	STOCKROOM_SHELF,
	CARD_READER,
	BARCODE_SCANNER,
	CLIPBOARD,
	HAND_TRUCK,
	PAPER_STACK,
	SHIPPING_SCALE,
	TAPE_ROLL,
	PRICE_TAG,
	SHELF_LABEL,
	SIGN_SHELF_LABEL,
	ACRYLIC_STAND,
	CONTROLLER_BIN_PROP,
	REPAIR_TESTING_MAT,
	TAPED_BOX_LABEL,
	SECURITY_TAG_BLOCK,
]

const _STARTER_CHECKOUT_STATION_COMPONENTS: Array[Dictionary] = [
	{
		"concept_id": STARTER_CHECKOUT_COUNTER,
		"visual_id": CHECKOUT_COUNTER,
		"slot_name": &"CheckoutCounterTop",
		"day_one_default": true,
	},
	{
		"concept_id": STARTER_REGISTER_TERMINAL,
		"visual_id": REGISTER,
		"slot_name": &"CheckoutRegisterScreen",
		"day_one_default": true,
	},
	{
		"concept_id": STARTER_CARD_READER,
		"visual_id": CARD_READER,
		"slot_name": &"CheckoutCardReader",
		"day_one_default": true,
	},
	{
		"concept_id": STARTER_RECEIPT_PRINTER,
		"visual_id": RECEIPT_PRINTER,
		"slot_name": &"CheckoutReceiptPrinterBody",
		"day_one_default": true,
	},
]

const _STARTER_STOCKROOM_SHELF_COMPONENTS: Array[Dictionary] = [
	{"name": &"StockroomBackRackShelf00", "role": &"shelf"},
	{"name": &"StockroomBackRackShelf01", "role": &"shelf"},
	{"name": &"StockroomBackRackShelf02", "role": &"shelf"},
	{"name": &"StockroomBackRackUpright350", "role": &"upright"},
	{"name": &"StockroomBackRackUpright402", "role": &"upright"},
	{"name": &"StockroomBackRackUpright474", "role": &"upright"},
	{"name": &"StockroomBackRackUpright528", "role": &"upright"},
	{"name": &"StockroomBackRackBraceLeft", "role": &"brace"},
	{"name": &"StockroomBackRackBraceRight", "role": &"brace"},
	{"name": &"StockroomShelfBoxAnchor00", "role": &"inventory_box_attachment"},
	{"name": &"StockroomShelfBoxAnchor01", "role": &"inventory_box_attachment"},
]

const _STARTER_SMALL_DISPLAY_PROP_COMPONENTS: Array[Dictionary] = [
	{
		"concept_id": STARTER_ACRYLIC_STAND,
		"category": SmallDisplayPropBuilderScript.CATEGORY_ACRYLIC_STAND,
		"visual_id": ACRYLIC_STAND,
		"day_one_default": true,
	},
	{
		"concept_id": STARTER_CONTROLLER_BIN,
		"category": SmallDisplayPropBuilderScript.CATEGORY_CONTROLLER_BIN,
		"visual_id": CONTROLLER_BIN_PROP,
		"day_one_default": true,
	},
	{
		"concept_id": STARTER_REPAIR_TESTING_MAT,
		"category": SmallDisplayPropBuilderScript.CATEGORY_REPAIR_TESTING_MAT,
		"visual_id": REPAIR_TESTING_MAT,
		"day_one_default": true,
	},
	{
		"concept_id": STARTER_CLIPBOARD_INTAKE_SLIP,
		"category": SmallDisplayPropBuilderScript.CATEGORY_CLIPBOARD_INTAKE_SLIP,
		"visual_id": CLIPBOARD,
		"day_one_default": true,
	},
	{
		"concept_id": STARTER_TAPED_BOX_LABEL,
		"category": SmallDisplayPropBuilderScript.CATEGORY_TAPED_BOX_LABEL,
		"visual_id": TAPED_BOX_LABEL,
		"day_one_default": true,
	},
	{
		"concept_id": STARTER_SECURITY_TAG_BLOCK,
		"category": SmallDisplayPropBuilderScript.CATEGORY_SECURITY_TAG_BLOCK,
		"visual_id": SECURITY_TAG_BLOCK,
		"day_one_default": true,
	},
]

const _PROCEDURAL_IDS: Array[StringName] = [
	STOCKROOM_SHELF,
	PRODUCT_PRICE_TAG,
	ACRYLIC_STAND,
	CONTROLLER_BIN_PROP,
	REPAIR_TESTING_MAT,
	BARCODE_SCANNER,
	CLIPBOARD,
	HAND_TRUCK,
	PAPER_STACK,
	SHIPPING_SCALE,
	TAPE_ROLL,
	TAPED_BOX_LABEL,
	SECURITY_TAG_BLOCK,
]

const _VISUAL_METADATA: Dictionary = {
	WALL_SHELF: {
		"display_name": "wall shelf",
		"role": ROLE_FIXTURE,
		"groups": [GROUP_RETAIL_FLOOR, GROUP_PRODUCT_DISPLAY],
	},
	FLOOR_RACK: {
		"display_name": "floor rack",
		"role": ROLE_FIXTURE,
		"groups": [GROUP_RETAIL_FLOOR, GROUP_PRODUCT_DISPLAY],
	},
	DISPLAY_TABLE: {
		"display_name": "display table",
		"role": ROLE_FIXTURE,
		"groups": [GROUP_RETAIL_FLOOR, GROUP_PRODUCT_DISPLAY],
	},
	CHECKOUT_COUNTER: {
		"display_name": "checkout counter",
		"role": ROLE_FIXTURE,
		"groups": [GROUP_CHECKOUT, GROUP_RETAIL_FLOOR],
	},
	STOCKROOM_TABLE: {
		"display_name": "stockroom table",
		"role": ROLE_FIXTURE,
		"groups": [GROUP_STOCKROOM, GROUP_BACK_OF_HOUSE],
	},
	STOCKROOM_SHELF: {
		"display_name": "stockroom shelf",
		"role": ROLE_STOCKROOM,
		"groups": [GROUP_STOCKROOM, GROUP_BACK_OF_HOUSE],
		"fixture_like": true,
		"visual_only": true,
	},
	STOCK_BOX: {
		"display_name": "stock box",
		"role": ROLE_STOCKROOM,
		"groups": [GROUP_STOCKROOM, GROUP_BACK_OF_HOUSE],
	},
	GAME_CASE: {
		"display_name": "game case",
		"role": ROLE_PRODUCT,
		"groups": [GROUP_RETAIL_FLOOR, GROUP_PRODUCT_DISPLAY],
		"visual_only": true,
	},
	CONSOLE_BOX: {
		"display_name": "console box",
		"role": ROLE_PRODUCT,
		"groups": [GROUP_RETAIL_FLOOR, GROUP_PRODUCT_DISPLAY],
		"visual_only": true,
	},
	REGISTER: {
		"display_name": "register",
		"role": ROLE_SERVICE,
		"groups": [GROUP_CHECKOUT, GROUP_RETAIL_FLOOR],
	},
	RECEIPT_PRINTER: {
		"display_name": "receipt printer",
		"role": ROLE_SERVICE,
		"groups": [GROUP_CHECKOUT, GROUP_RETAIL_FLOOR],
	},
	CARD_READER: {
		"display_name": "card reader",
		"role": ROLE_SERVICE,
		"groups": [GROUP_CHECKOUT, GROUP_RETAIL_FLOOR],
	},
	QUEUE_LANE: {
		"display_name": "queue lane",
		"role": ROLE_ROUTE_CUE,
		"groups": [GROUP_CHECKOUT, GROUP_RETAIL_FLOOR, GROUP_WAYFINDING],
	},
	PRICE_TAG: {
		"display_name": "price tag",
		"role": ROLE_SIGNAGE,
		"groups": [GROUP_PRICING, GROUP_RETAIL_FLOOR, GROUP_PRODUCT_DISPLAY],
		"visual_only": true,
	},
	PRODUCT_PRICE_TAG: {
		"display_name": "product price tag",
		"role": ROLE_SIGNAGE,
		"groups": [GROUP_PRICING, GROUP_RETAIL_FLOOR, GROUP_PRODUCT_DISPLAY],
		"visual_only": true,
	},
	SHELF_LABEL: {
		"display_name": "shelf label",
		"role": ROLE_SIGNAGE,
		"groups": [GROUP_PRICING, GROUP_RETAIL_FLOOR, GROUP_PRODUCT_DISPLAY],
		"visual_only": true,
	},
	SIGN_SHELF_LABEL: {
		"display_name": "sign shelf label",
		"role": ROLE_SIGNAGE,
		"groups": [GROUP_WAYFINDING, GROUP_RETAIL_FLOOR],
		"visual_only": true,
	},
	ACRYLIC_STAND: {
		"display_name": "acrylic stand",
		"role": ROLE_DECOR,
		"groups": [GROUP_RETAIL_FLOOR, GROUP_PRODUCT_DISPLAY, GROUP_STARTER_KIT],
		"visual_only": true,
	},
	CONTROLLER_BIN_PROP: {
		"display_name": "controller bin",
		"role": ROLE_DECOR,
		"groups": [GROUP_RETAIL_FLOOR, GROUP_PRODUCT_DISPLAY, GROUP_STARTER_KIT],
		"visual_only": true,
	},
	REPAIR_TESTING_MAT: {
		"display_name": "repair testing mat",
		"role": ROLE_DECOR,
		"groups": [GROUP_RETAIL_FLOOR, GROUP_PRODUCT_DISPLAY, GROUP_STARTER_KIT],
		"visual_only": true,
	},
	TAPED_BOX_LABEL: {
		"display_name": "taped box label",
		"role": ROLE_STOCKROOM,
		"groups": [GROUP_STOCKROOM, GROUP_BACK_OF_HOUSE, ROLE_SIGNAGE],
		"visual_only": true,
	},
	SECURITY_TAG_BLOCK: {
		"display_name": "security tag block",
		"role": ROLE_DECOR,
		"groups": [GROUP_RETAIL_FLOOR, GROUP_PRODUCT_DISPLAY, GROUP_STARTER_KIT],
		"visual_only": true,
	},
	GLTF_COUNTER_REGISTER: {
		"display_name": "counter register model",
		"role": ROLE_SERVICE,
		"groups": [GROUP_CHECKOUT, GROUP_RETAIL_FLOOR, GROUP_SHELL_PROP],
	},
	GLTF_GAME_CASE: {
		"display_name": "game case model",
		"role": ROLE_PRODUCT,
		"groups": [GROUP_RETAIL_FLOOR, GROUP_PRODUCT_DISPLAY, GROUP_SHELL_PROP],
		"visual_only": true,
	},
	GLTF_CONSOLE_BOX: {
		"display_name": "console box model",
		"role": ROLE_PRODUCT,
		"groups": [GROUP_RETAIL_FLOOR, GROUP_PRODUCT_DISPLAY, GROUP_SHELL_PROP],
		"visual_only": true,
	},
	GLTF_CARTRIDGE_GB: {
		"display_name": "compact cartridge model",
		"role": ROLE_PRODUCT,
		"groups": [GROUP_RETAIL_FLOOR, GROUP_PRODUCT_DISPLAY, GROUP_SHELL_PROP],
		"visual_only": true,
	},
	GLTF_CARTRIDGE_N64: {
		"display_name": "wide cartridge model",
		"role": ROLE_PRODUCT,
		"groups": [GROUP_RETAIL_FLOOR, GROUP_PRODUCT_DISPLAY, GROUP_SHELL_PROP],
		"visual_only": true,
	},
	GLTF_CARTRIDGE_SNES: {
		"display_name": "flat cartridge model",
		"role": ROLE_PRODUCT,
		"groups": [GROUP_RETAIL_FLOOR, GROUP_PRODUCT_DISPLAY, GROUP_SHELL_PROP],
		"visual_only": true,
	},
	GLTF_CONSOLE_N64: {
		"display_name": "rounded console model",
		"role": ROLE_PRODUCT,
		"groups": [GROUP_RETAIL_FLOOR, GROUP_PRODUCT_DISPLAY, GROUP_SHELL_PROP],
		"visual_only": true,
	},
	GLTF_CONSOLE_PS1: {
		"display_name": "disc console model",
		"role": ROLE_PRODUCT,
		"groups": [GROUP_RETAIL_FLOOR, GROUP_PRODUCT_DISPLAY, GROUP_SHELL_PROP],
		"visual_only": true,
	},
	GLTF_CONSOLE_SNES: {
		"display_name": "classic console model",
		"role": ROLE_PRODUCT,
		"groups": [GROUP_RETAIL_FLOOR, GROUP_PRODUCT_DISPLAY, GROUP_SHELL_PROP],
		"visual_only": true,
	},
	GLTF_CRT_MONITOR: {
		"display_name": "crt monitor model",
		"role": ROLE_DECOR,
		"groups": [GROUP_RETAIL_FLOOR, GROUP_PRODUCT_DISPLAY, GROUP_SHELL_PROP],
		"visual_only": true,
	},
	GLTF_HOLD_TAG: {
		"display_name": "hold tag model",
		"role": ROLE_SIGNAGE,
		"groups": [GROUP_PRICING, GROUP_RETAIL_FLOOR, GROUP_PRODUCT_DISPLAY, GROUP_SHELL_PROP],
		"visual_only": true,
	},
	GLTF_RECEIPT_PRINTER: {
		"display_name": "receipt printer model",
		"role": ROLE_SERVICE,
		"groups": [GROUP_CHECKOUT, GROUP_RETAIL_FLOOR, GROUP_SHELL_PROP],
	},
	GLTF_REGISTER_MONITOR: {
		"display_name": "register monitor model",
		"role": ROLE_SERVICE,
		"groups": [GROUP_CHECKOUT, GROUP_RETAIL_FLOOR, GROUP_SHELL_PROP],
	},
	BARCODE_SCANNER: {
		"display_name": "barcode scanner",
		"role": ROLE_TOOL,
		"groups": [GROUP_CHECKOUT, GROUP_RETAIL_FLOOR],
		"visual_only": true,
	},
	CLIPBOARD: {
		"display_name": "clipboard",
		"role": ROLE_TOOL,
		"groups": [GROUP_STOCKROOM, GROUP_BACK_OF_HOUSE],
		"visual_only": true,
	},
	HAND_TRUCK: {
		"display_name": "hand truck",
		"role": ROLE_STOCKROOM,
		"groups": [GROUP_STOCKROOM, GROUP_BACK_OF_HOUSE, ROLE_TOOL],
		"visual_only": true,
	},
	PAPER_STACK: {
		"display_name": "paper stack",
		"role": ROLE_STOCKROOM,
		"groups": [GROUP_STOCKROOM, GROUP_BACK_OF_HOUSE],
		"visual_only": true,
	},
	SHIPPING_SCALE: {
		"display_name": "shipping scale",
		"role": ROLE_STOCKROOM,
		"groups": [GROUP_STOCKROOM, GROUP_BACK_OF_HOUSE, ROLE_TOOL],
		"visual_only": true,
	},
	TAPE_ROLL: {
		"display_name": "tape roll",
		"role": ROLE_STOCKROOM,
		"groups": [GROUP_STOCKROOM, GROUP_BACK_OF_HOUSE, ROLE_TOOL],
		"visual_only": true,
	},
}


static func scene_path(id: StringName) -> String:
	return str(_SCENE_PATHS.get(id, ""))


static func has_visual(id: StringName) -> bool:
	var path: String = scene_path(id)
	return _PROCEDURAL_IDS.has(id) or (not path.is_empty() and ResourceLoader.exists(path))


static func instantiate(id: StringName) -> Node:
	if _PROCEDURAL_IDS.has(id):
		return _apply_visual_metadata(_instantiate_procedural(id), id)
	var path: String = scene_path(id)
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	var scene: PackedScene = load(path) as PackedScene
	if scene == null:
		return null
	return _apply_visual_metadata(scene.instantiate(), id)


## Creates a product-scale price tag and stores price ownership on the tag node.
static func instantiate_product_price_tag(price_cents: int) -> MeshInstance3D:
	return _product_price_tag(price_cents)


## Creates a reusable shelf label scene and optionally applies caller-owned text.
static func instantiate_shelf_label(label_text: String = "") -> Node3D:
	var label: Node3D = instantiate(SHELF_LABEL) as Node3D
	if label == null:
		return null
	if not label_text.is_empty():
		apply_shelf_label_text(label, label_text)
	return label


static func apply_shelf_label_text(label_root: Node, label_text: String) -> bool:
	if label_root == null:
		return false
	var label: Label3D = label_root.get_node_or_null("LabelText") as Label3D
	if label == null:
		return false
	label.text = label_text
	return true


## Returns semantic metadata for a reusable visual ID, including source details.
static func visual_metadata(id: StringName) -> Dictionary:
	if not _VISUAL_METADATA.has(id):
		return {}
	var metadata: Dictionary = (_VISUAL_METADATA.get(id, {}) as Dictionary).duplicate(true)
	metadata["source_type"] = source_type(id)
	var path: String = scene_path(id)
	if not path.is_empty():
		metadata["scene_path"] = path
	return metadata


## Returns the primary semantic role for a visual ID.
static func visual_role(id: StringName) -> StringName:
	var metadata: Dictionary = _VISUAL_METADATA.get(id, {}) as Dictionary
	return metadata.get("role", &"") as StringName


## Returns orthogonal context groups for a visual ID.
static func visual_groups(id: StringName) -> Array[StringName]:
	var metadata: Dictionary = _VISUAL_METADATA.get(id, {}) as Dictionary
	var groups: Array[StringName] = []
	for raw_group: Variant in metadata.get("groups", []):
		groups.append(raw_group as StringName)
	return groups


## Returns all reusable visual IDs with the requested primary role.
static func visuals_for_role(role: StringName) -> Array[StringName]:
	var ids: Array[StringName] = []
	for raw_id: Variant in _VISUAL_METADATA.keys():
		var id: StringName = raw_id as StringName
		if visual_role(id) == role:
			ids.append(id)
	ids.sort()
	return ids


## Returns all reusable visual IDs tagged for the requested context group.
static func visuals_in_group(group: StringName) -> Array[StringName]:
	var ids: Array[StringName] = []
	for raw_id: Variant in _VISUAL_METADATA.keys():
		var id: StringName = raw_id as StringName
		if visual_groups(id).has(group):
			ids.append(id)
	ids.sort()
	return ids


## Returns whether a visual ID has the requested primary semantic role.
static func has_visual_role(id: StringName, role: StringName) -> bool:
	return visual_role(id) == role


## Returns whether a visual ID is tagged for the requested context group.
static func has_visual_group(id: StringName, group: StringName) -> bool:
	return visual_groups(id).has(group)


static func required_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for raw_id: Variant in _SCENE_PATHS.keys():
		ids.append(raw_id as StringName)
	for id: StringName in _PROCEDURAL_IDS:
		ids.append(id)
	ids.sort()
	return ids


static func starter_store_ids() -> Array[StringName]:
	return _STARTER_STORE_IDS.duplicate()


static func starter_shell_prop_ids() -> Array[StringName]:
	return _STARTER_SHELL_PROP_IDS.duplicate()


static func starter_checkout_station_components() -> Array[Dictionary]:
	return _STARTER_CHECKOUT_STATION_COMPONENTS.duplicate(true)


static func starter_stockroom_shelf_components() -> Array[Dictionary]:
	return _STARTER_STOCKROOM_SHELF_COMPONENTS.duplicate(true)


static func starter_small_display_prop_components() -> Array[Dictionary]:
	return _STARTER_SMALL_DISPLAY_PROP_COMPONENTS.duplicate(true)


static func validate() -> Dictionary:
	var missing: Array[StringName] = []
	var missing_metadata: Array[StringName] = []
	for id: StringName in required_ids():
		if not has_visual(id):
			missing.append(id)
		if not _VISUAL_METADATA.has(id):
			missing_metadata.append(id)
	return {
		"ok": missing.is_empty() and missing_metadata.is_empty(),
		"missing": missing,
		"missing_metadata": missing_metadata,
	}


static func source_type(id: StringName) -> StringName:
	if _PROCEDURAL_IDS.has(id):
		return &"procedural"
	if _SCENE_PATHS.has(id):
		return &"scene"
	return &"missing"


static func _instantiate_procedural(id: StringName) -> Node3D:
	match id:
		STOCKROOM_SHELF:
			return _stockroom_shelf()
		PRODUCT_PRICE_TAG:
			return _product_price_tag(-1)
		ACRYLIC_STAND:
			return SmallDisplayPropBuilderScript.build(
				SmallDisplayPropBuilderScript.CATEGORY_ACRYLIC_STAND,
				id
			)
		CONTROLLER_BIN_PROP:
			return SmallDisplayPropBuilderScript.build(
				SmallDisplayPropBuilderScript.CATEGORY_CONTROLLER_BIN,
				id
			)
		REPAIR_TESTING_MAT:
			return SmallDisplayPropBuilderScript.build(
				SmallDisplayPropBuilderScript.CATEGORY_REPAIR_TESTING_MAT,
				id
			)
		BARCODE_SCANNER:
			return _barcode_scanner()
		CLIPBOARD:
			return _clipboard()
		HAND_TRUCK:
			return _hand_truck()
		PAPER_STACK:
			return _paper_stack()
		SHIPPING_SCALE:
			return _shipping_scale()
		TAPE_ROLL:
			return _tape_roll()
		TAPED_BOX_LABEL:
			return SmallDisplayPropBuilderScript.build(
				SmallDisplayPropBuilderScript.CATEGORY_TAPED_BOX_LABEL,
				id
			)
		SECURITY_TAG_BLOCK:
			return SmallDisplayPropBuilderScript.build(
				SmallDisplayPropBuilderScript.CATEGORY_SECURITY_TAG_BLOCK,
				id
			)
	return null


static func _apply_visual_metadata(root: Node, id: StringName) -> Node:
	if root == null:
		return null
	var metadata: Dictionary = visual_metadata(id)
	if bool(metadata.get("assembly", false)) and bool(metadata.get("visual_only", false)):
		_strip_runtime_blockers(root)
	root.set_meta("store_visual_id", id)
	root.set_meta("store_visual_source", "store_visual_kit")
	root.set_meta("store_visual_role", metadata.get("role", &""))
	root.set_meta("store_visual_groups", visual_groups(id))
	root.set_meta("store_visual_display_name", str(metadata.get("display_name", "")))
	if metadata.has("visual_only"):
		root.set_meta("visual_only", bool(metadata.get("visual_only", false)))
	root.set_meta("store_visual_source_type", metadata.get("source_type", &"missing"))
	return root


static func _strip_runtime_blockers(node: Node) -> void:
	for child: Node in node.get_children():
		if (
			child is CollisionObject3D
			or child is CollisionShape3D
			or child is NavigationObstacle3D
		):
			child.free()
			continue
		_strip_runtime_blockers(child)


static func _product_price_tag(price_cents: int) -> MeshInstance3D:
	var tag: MeshInstance3D = StarterDetailBuilderScript.product_price_tag(price_cents)
	if tag == null:
		return null
	return _apply_visual_metadata(tag, PRODUCT_PRICE_TAG) as MeshInstance3D


static func _root(name: String, id: StringName) -> Node3D:
	var root := Node3D.new()
	root.name = name
	root.set_meta("store_visual_id", id)
	root.set_meta("store_visual_source", "store_visual_kit")
	return root


static func _stockroom_shelf() -> Node3D:
	var root: Node3D = _root("StarterStockroomShelf", STOCKROOM_SHELF)
	root.set_meta("visual_only", true)
	root.set_meta("starter_kit_concept_id", STARTER_STOCKROOM_SHELF)
	_add_starter_box(
		root,
		"StockroomSupplyShelf",
		Vector3(-0.14, 0.88, -0.27),
		Vector3(1.75, 0.10, 0.34),
		StarterDetailBuilderScript.FAMILY_WOOD_LAMINATE,
		StarterDetailBuilderScript.ROLE_PANEL
	)
	for index: int in range(5):
		var x_offset: float = -0.74 + float(index) * 0.30
		_add_starter_box(
			root,
			"StockroomSupplyBox%02d" % index,
			Vector3(x_offset, 1.04, -0.27),
			Vector3(0.20, 0.18, 0.22),
			StarterDetailBuilderScript.FAMILY_CARDBOARD,
			StarterDetailBuilderScript.ROLE_PANEL
		)
		_add_starter_box(
			root,
			"StockroomSupplyLabel%02d" % index,
			Vector3(x_offset, 1.04, -0.14),
			Vector3(0.12, 0.045, 0.018),
			StarterDetailBuilderScript.FAMILY_PAPER,
			StarterDetailBuilderScript.ROLE_LABEL
		)
		_add_starter_box(
			root,
			"StockroomSupplyBand%02d" % index,
			Vector3(x_offset, 1.15, -0.14),
			Vector3(0.16, 0.035, 0.016),
			StarterDetailBuilderScript.FAMILY_SHADOW_ACCENT,
			StarterDetailBuilderScript.ROLE_TRIM
		)
	for level: int in range(3):
		_add_starter_box(
			root,
			"StockroomBackRackShelf%02d" % level,
			Vector3(0.0, 1.24 + float(level) * 0.42, 0.0),
			Vector3(1.92, 0.055, 0.20),
			StarterDetailBuilderScript.FAMILY_STOCKROOM_COOL_METAL,
			StarterDetailBuilderScript.ROLE_PANEL
		)
	for rack_x: float in [-1.02, -0.50, 0.22, 0.76]:
		_add_starter_box(
			root,
			"StockroomBackRackUpright%02d" % int(round((4.52 + rack_x) * 100.0)),
			Vector3(rack_x, 1.62, 0.02),
			Vector3(0.045, 1.28, 0.08),
			StarterDetailBuilderScript.FAMILY_STOCKROOM_COOL_METAL,
			StarterDetailBuilderScript.ROLE_TRIM
		)
	_add_starter_box(
		root,
		"StockroomBackRackBraceLeft",
		Vector3(-0.76, 1.58, 0.07),
		Vector3(0.035, 1.18, 0.055),
		StarterDetailBuilderScript.FAMILY_SHADOW_ACCENT,
		StarterDetailBuilderScript.ROLE_BRACE,
		Vector3(0.0, 0.0, -22.0)
	)
	_add_starter_box(
		root,
		"StockroomBackRackBraceRight",
		Vector3(0.50, 1.58, 0.07),
		Vector3(0.035, 1.18, 0.055),
		StarterDetailBuilderScript.FAMILY_SHADOW_ACCENT,
		StarterDetailBuilderScript.ROLE_BRACE,
		Vector3(0.0, 0.0, 22.0)
	)
	for index: int in range(2):
		var anchor := Node3D.new()
		anchor.name = "StockroomShelfBoxAnchor%02d" % index
		anchor.position = Vector3(-0.42 + float(index) * 0.72, 1.47, -0.01)
		anchor.set_meta("attachment_role", "inventory_box")
		root.add_child(anchor)
	return root


static func _barcode_scanner() -> Node3D:
	var root: Node3D = _root("PropBarcodeScanner", BARCODE_SCANNER)
	_add_cylinder(
		root,
		"Handle",
		0.035,
		0.28,
		Vector3(0.0, 0.10, 0.0),
		Color(0.06, 0.06, 0.07, 1.0),
		Vector3(14.0, 0.0, 0.0)
	)
	_add_capsule(
		root,
		"ScannerHead",
		0.07,
		0.18,
		Vector3(0.0, 0.24, -0.08),
		Color(0.08, 0.09, 0.10, 1.0),
		Vector3(90.0, 0.0, 0.0)
	)
	_add_plane(
		root,
		"ScanWindow",
		Vector2(0.13, 0.035),
		Vector3(0.0, 0.24, -0.175),
		Color(0.16, 0.95, 0.55, 1.0),
		Vector3(90.0, 0.0, 0.0),
		Color(0.12, 1.0, 0.55, 1.0)
	)
	return root


static func _clipboard() -> Node3D:
	var root: Node3D = _root("PropClipboard", CLIPBOARD)
	root.set_meta("visual_only", true)
	root.set_meta(
		"small_display_prop_category",
		SmallDisplayPropBuilderScript.CATEGORY_CLIPBOARD_INTAKE_SLIP
	)
	_add_plane(
		root,
		"Board",
		Vector2(0.34, 0.46),
		Vector3.ZERO,
		Color(0.46, 0.31, 0.18, 1.0),
		Vector3.ZERO
	)
	_add_plane(
		root,
		"Paper",
		Vector2(0.28, 0.34),
		Vector3(0.0, 0.006, 0.01),
		Color(0.94, 0.88, 0.70, 1.0),
		Vector3.ZERO
	)
	_add_cylinder(
		root,
		"Clip",
		0.025,
		0.18,
		Vector3(0.0, 0.018, -0.18),
		Color(0.74, 0.58, 0.30, 1.0),
		Vector3(0.0, 0.0, 90.0)
	)
	return root


static func _hand_truck() -> Node3D:
	var root: Node3D = _root("FixtureHandTruck", HAND_TRUCK)
	for x: float in [-0.12, 0.12]:
		_add_cylinder(
			root,
			"FrameRail%s" % ("Left" if x < 0.0 else "Right"),
			0.018,
			1.05,
			Vector3(x, 0.58, 0.0),
			Color(0.05, 0.055, 0.06, 1.0),
			Vector3(8.0, 0.0, 0.0)
		)
		_add_cylinder(
			root,
			"Wheel%s" % ("Left" if x < 0.0 else "Right"),
			0.095,
			0.055,
			Vector3(x, 0.10, 0.13),
			Color(0.03, 0.03, 0.035, 1.0),
			Vector3(0.0, 0.0, 90.0)
		)
	_add_cylinder(
		root,
		"Handle",
		0.022,
		0.38,
		Vector3(0.0, 1.12, -0.02),
		Color(0.05, 0.055, 0.06, 1.0),
		Vector3(0.0, 0.0, 90.0)
	)
	_add_plane(
		root,
		"ToePlate",
		Vector2(0.46, 0.28),
		Vector3(0.0, 0.045, -0.12),
		Color(0.06, 0.06, 0.065, 1.0),
		Vector3.ZERO
	)
	return root


static func _paper_stack() -> Node3D:
	var root: Node3D = _root("PropPaperStack", PAPER_STACK)
	for index: int in range(3):
		_add_plane(
			root,
			"Page%02d" % index,
			Vector2(0.30, 0.22),
			Vector3(float(index) * 0.018, float(index) * 0.004, 0.0),
			Color(0.96, 0.90, 0.74, 1.0),
			Vector3(0.0, float(index) * 2.0, 0.0)
		)
	return root


static func _shipping_scale() -> Node3D:
	var root: Node3D = _root("PropShippingScale", SHIPPING_SCALE)
	_add_cylinder(
		root,
		"WeighingPlate",
		0.15,
		0.035,
		Vector3(0.0, 0.035, 0.0),
		Color(0.12, 0.13, 0.14, 1.0)
	)
	_add_plane(
		root,
		"Readout",
		Vector2(0.15, 0.055),
		Vector3(0.0, 0.09, -0.13),
		Color(0.12, 0.36, 0.28, 1.0),
		Vector3(-55.0, 0.0, 0.0),
		Color(0.10, 0.62, 0.40, 1.0)
	)
	return root


static func _tape_roll() -> Node3D:
	var root: Node3D = _root("PropTapeRoll", TAPE_ROLL)
	_add_cylinder(
		root,
		"Roll",
		0.105,
		0.055,
		Vector3.ZERO,
		Color(0.86, 0.62, 0.20, 1.0),
		Vector3(90.0, 0.0, 0.0)
	)
	_add_cylinder(
		root,
		"Core",
		0.052,
		0.058,
		Vector3.ZERO,
		Color(0.95, 0.88, 0.68, 1.0),
		Vector3(90.0, 0.0, 0.0)
	)
	return root


static func _add_cylinder(
	parent: Node3D,
	name: String,
	radius: float,
	height: float,
	position: Vector3,
	color: Color,
	rotation_degrees: Vector3 = Vector3.ZERO
) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 18
	return _add_mesh(parent, name, mesh, position, rotation_degrees, _mat(color))


static func _add_capsule(
	parent: Node3D,
	name: String,
	radius: float,
	height: float,
	position: Vector3,
	color: Color,
	rotation_degrees: Vector3 = Vector3.ZERO
) -> MeshInstance3D:
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	mesh.radial_segments = 16
	mesh.rings = 6
	return _add_mesh(parent, name, mesh, position, rotation_degrees, _mat(color))


static func _add_plane(
	parent: Node3D,
	name: String,
	size: Vector2,
	position: Vector3,
	color: Color,
	rotation_degrees: Vector3,
	emission: Color = Color.TRANSPARENT
) -> MeshInstance3D:
	var mesh := PlaneMesh.new()
	mesh.size = size
	var material: StandardMaterial3D = _mat(color, emission)
	return _add_mesh(parent, name, mesh, position, rotation_degrees, material)


static func _add_starter_box(
	parent: Node3D,
	name: String,
	position: Vector3,
	size: Vector3,
	family: StringName,
	role: StringName,
	rotation_degrees: Vector3 = Vector3.ZERO
) -> MeshInstance3D:
	var material: StandardMaterial3D = StarterDetailBuilderScript.material_for(family)
	if material == null:
		return null
	var mesh := BoxMesh.new()
	mesh.size = size
	var instance: MeshInstance3D = _add_mesh(
		parent, name, mesh, position, rotation_degrees, material
	)
	StarterDetailBuilderScript.apply_visual_metadata(instance, family, role)
	return instance


static func _add_mesh(
	parent: Node3D,
	name: String,
	mesh: Mesh,
	position: Vector3,
	rotation_degrees: Vector3,
	material: StandardMaterial3D
) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = name
	instance.mesh = mesh
	instance.position = position
	instance.rotation_degrees = rotation_degrees
	instance.material_override = material
	parent.add_child(instance)
	return instance


static func _mat(color: Color, emission: Color = Color.TRANSPARENT) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.84
	if emission.a > 0.0:
		material.emission_enabled = true
		material.emission = emission
		material.emission_energy_multiplier = 0.28
	return material
