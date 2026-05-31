## Source-visible routing contract for the starter retail kit concepts.
##
## Starter-prefixed names here are conceptual kit IDs. Reusable visual assets,
## layout fixture instance IDs, and build fixture definition IDs stay in their
## own fields so they do not become interchangeable by accident.
class_name StarterRetailKitManifest
extends RefCounted

const StoreVisualKitScript: GDScript = preload("res://game/scripts/visuals/store_visual_kit.gd")

const OWNER_SCOPE: StringName = &"starter_retail_kit_routing"

const SOURCE_LAYOUT_FIXTURE: StringName = &"layout_fixture"
const SOURCE_STORE_VISUAL_KIT: StringName = &"store_visual_kit"
const SOURCE_REUSABLE_SCENE: StringName = &"reusable_scene"
const SOURCE_PRODUCT_FACTORY: StringName = &"product_visual_factory"

const CONCEPTS: Dictionary = {
	&"starter_checkout_counter": {
		"concept_name": "checkout counter",
		"owner_scope": OWNER_SCOPE,
		"store_visual_id": StoreVisualKitScript.CHECKOUT_COUNTER,
		"variant_visual_ids": [],
		"layout_fixture_id": &"starter_checkout_counter",
		"build_fixture_id": &"counter",
		"canonical_path": "res://game/scenes/stores/fixtures/fixture_checkout_counter.tscn",
		"source_kind": SOURCE_LAYOUT_FIXTURE,
		"generated_reason": "",
	},
	&"starter_register_terminal": {
		"concept_name": "register terminal",
		"owner_scope": OWNER_SCOPE,
		"store_visual_id": StoreVisualKitScript.REGISTER,
		"variant_visual_ids": [StoreVisualKitScript.GLTF_REGISTER_MONITOR],
		"layout_fixture_id": &"starter_register_terminal",
		"build_fixture_id": &"register",
		"canonical_path": "res://game/scenes/stores/fixtures/prop_register.tscn",
		"source_kind": SOURCE_STORE_VISUAL_KIT,
		"generated_reason": "",
	},
	&"starter_card_reader": {
		"concept_name": "card reader",
		"owner_scope": OWNER_SCOPE,
		"store_visual_id": StoreVisualKitScript.CARD_READER,
		"variant_visual_ids": [],
		"layout_fixture_id": &"starter_card_reader",
		"build_fixture_id": &"",
		"canonical_path": "res://game/scenes/stores/fixtures/prop_card_reader.tscn",
		"source_kind": SOURCE_STORE_VISUAL_KIT,
		"generated_reason": "",
	},
	&"starter_receipt_printer": {
		"concept_name": "receipt printer",
		"owner_scope": OWNER_SCOPE,
		"store_visual_id": StoreVisualKitScript.RECEIPT_PRINTER,
		"variant_visual_ids": [StoreVisualKitScript.GLTF_RECEIPT_PRINTER],
		"layout_fixture_id": &"starter_receipt_printer",
		"build_fixture_id": &"",
		"canonical_path": "res://game/scenes/stores/fixtures/prop_receipt_printer.tscn",
		"source_kind": SOURCE_STORE_VISUAL_KIT,
		"generated_reason": "",
	},
	&"starter_wall_shelf": {
		"concept_name": "wall shelf",
		"owner_scope": OWNER_SCOPE,
		"store_visual_id": StoreVisualKitScript.WALL_SHELF,
		"variant_visual_ids": [],
		"layout_fixture_id": &"",
		"build_fixture_id": &"wall_shelf",
		"canonical_path": "res://game/scenes/stores/fixtures/retail_wall_shelf.tscn",
		"source_kind": SOURCE_STORE_VISUAL_KIT,
		"generated_reason": "",
	},
	&"starter_gondola_shelf": {
		"concept_name": "gondola shelf",
		"owner_scope": OWNER_SCOPE,
		"store_visual_id": StoreVisualKitScript.FLOOR_RACK,
		"variant_visual_ids": [],
		"layout_fixture_id": &"",
		"build_fixture_id": &"floor_rack",
		"canonical_path": "res://game/scenes/stores/fixtures/retail_gondola_shelf.tscn",
		"source_kind": SOURCE_REUSABLE_SCENE,
		"generated_reason": "",
	},
	&"starter_display_table": {
		"concept_name": "display table",
		"owner_scope": OWNER_SCOPE,
		"store_visual_id": StoreVisualKitScript.DISPLAY_TABLE,
		"variant_visual_ids": [],
		"layout_fixture_id": &"starter_display_table",
		"build_fixture_id": &"display_table",
		"canonical_path": "res://game/scenes/stores/fixtures/fixture_display_table.tscn",
		"source_kind": SOURCE_LAYOUT_FIXTURE,
		"generated_reason": "",
	},
	&"starter_stockroom_shelf": {
		"concept_name": "stockroom shelf",
		"owner_scope": OWNER_SCOPE,
		"store_visual_id": StoreVisualKitScript.STOCKROOM_SHELF,
		"variant_visual_ids": [],
		"layout_fixture_id": &"",
		"build_fixture_id": &"storage_unit",
		"canonical_path": "res://game/scripts/visuals/store_visual_kit.gd",
		"source_kind": SOURCE_STORE_VISUAL_KIT,
		"generated_reason": "",
	},
	&"starter_receiving_table": {
		"concept_name": "receiving table",
		"owner_scope": OWNER_SCOPE,
		"store_visual_id": &"",
		"variant_visual_ids": [],
		"layout_fixture_id": &"",
		"build_fixture_id": &"testing_station",
		"canonical_path": "res://game/scenes/stores/fixtures/receiving_table.tscn",
		"source_kind": SOURCE_REUSABLE_SCENE,
		"generated_reason": "",
	},
	&"starter_game_case": {
		"concept_name": "game case",
		"owner_scope": OWNER_SCOPE,
		"store_visual_id": StoreVisualKitScript.GAME_CASE,
		"variant_visual_ids": [StoreVisualKitScript.GLTF_GAME_CASE],
		"layout_fixture_id": &"",
		"build_fixture_id": &"",
		"canonical_path": "res://game/scripts/visuals/product_visual_factory.gd",
		"source_kind": SOURCE_PRODUCT_FACTORY,
		"generated_reason": "",
	},
	&"starter_cartridge": {
		"concept_name": "cartridge",
		"owner_scope": OWNER_SCOPE,
		"store_visual_id": StoreVisualKitScript.GLTF_CARTRIDGE_GB,
		"variant_visual_ids": [
			StoreVisualKitScript.GLTF_CARTRIDGE_N64,
			StoreVisualKitScript.GLTF_CARTRIDGE_SNES,
		],
		"layout_fixture_id": &"",
		"build_fixture_id": &"",
		"canonical_path": "res://game/scripts/visuals/product_visual_factory.gd",
		"source_kind": SOURCE_PRODUCT_FACTORY,
		"generated_reason": "",
	},
	&"starter_console_box": {
		"concept_name": "console box",
		"owner_scope": OWNER_SCOPE,
		"store_visual_id": StoreVisualKitScript.CONSOLE_BOX,
		"variant_visual_ids": [StoreVisualKitScript.GLTF_CONSOLE_BOX],
		"layout_fixture_id": &"",
		"build_fixture_id": &"",
		"canonical_path": "res://game/scripts/visuals/product_visual_factory.gd",
		"source_kind": SOURCE_PRODUCT_FACTORY,
		"generated_reason": "",
	},
	&"starter_price_tag": {
		"concept_name": "price tag",
		"owner_scope": OWNER_SCOPE,
		"store_visual_id": StoreVisualKitScript.PRICE_TAG,
		"variant_visual_ids": [StoreVisualKitScript.PRODUCT_PRICE_TAG],
		"layout_fixture_id": &"",
		"build_fixture_id": &"",
		"canonical_path": "res://game/scenes/stores/fixtures/price_tag.tscn",
		"source_kind": SOURCE_STORE_VISUAL_KIT,
		"generated_reason": "",
	},
	&"starter_shelf_label": {
		"concept_name": "shelf label",
		"owner_scope": OWNER_SCOPE,
		"store_visual_id": StoreVisualKitScript.SHELF_LABEL,
		"variant_visual_ids": [],
		"layout_fixture_id": &"",
		"build_fixture_id": &"",
		"canonical_path": "res://game/scenes/stores/fixtures/shelf_label.tscn",
		"source_kind": SOURCE_REUSABLE_SCENE,
		"generated_reason": "",
	},
	&"starter_acrylic_stand": {
		"concept_name": "acrylic stand",
		"owner_scope": OWNER_SCOPE,
		"store_visual_id": StoreVisualKitScript.ACRYLIC_STAND,
		"variant_visual_ids": [],
		"layout_fixture_id": &"starter_acrylic_stand",
		"build_fixture_id": &"",
		"canonical_path": "res://game/scripts/visuals/small_display_prop_builder.gd",
		"source_kind": SOURCE_STORE_VISUAL_KIT,
		"generated_reason": "",
	},
	&"starter_controller_bin": {
		"concept_name": "controller bin",
		"owner_scope": OWNER_SCOPE,
		"store_visual_id": StoreVisualKitScript.CONTROLLER_BIN_PROP,
		"variant_visual_ids": [],
		"layout_fixture_id": &"starter_controller_bin",
		"build_fixture_id": &"",
		"canonical_path": "res://game/scripts/visuals/small_display_prop_builder.gd",
		"source_kind": SOURCE_STORE_VISUAL_KIT,
		"generated_reason": "",
	},
	&"starter_repair_testing_mat": {
		"concept_name": "repair/testing mat",
		"owner_scope": OWNER_SCOPE,
		"store_visual_id": StoreVisualKitScript.REPAIR_TESTING_MAT,
		"variant_visual_ids": [],
		"layout_fixture_id": &"starter_repair_testing_mat",
		"build_fixture_id": &"",
		"canonical_path": "res://game/scripts/visuals/small_display_prop_builder.gd",
		"source_kind": SOURCE_STORE_VISUAL_KIT,
		"generated_reason": "",
	},
	&"starter_clipboard_intake_slip": {
		"concept_name": "clipboard/intake slip",
		"owner_scope": OWNER_SCOPE,
		"store_visual_id": StoreVisualKitScript.CLIPBOARD,
		"variant_visual_ids": [],
		"layout_fixture_id": &"starter_clipboard_intake_slip",
		"build_fixture_id": &"",
		"canonical_path": "res://game/scripts/visuals/store_visual_kit.gd",
		"source_kind": SOURCE_STORE_VISUAL_KIT,
		"generated_reason": "",
	},
	&"starter_taped_box_label": {
		"concept_name": "taped box label",
		"owner_scope": OWNER_SCOPE,
		"store_visual_id": StoreVisualKitScript.TAPED_BOX_LABEL,
		"variant_visual_ids": [],
		"layout_fixture_id": &"starter_taped_box_label",
		"build_fixture_id": &"",
		"canonical_path": "res://game/scripts/visuals/small_display_prop_builder.gd",
		"source_kind": SOURCE_STORE_VISUAL_KIT,
		"generated_reason": "",
	},
	&"starter_security_tag_block": {
		"concept_name": "security tag block",
		"owner_scope": OWNER_SCOPE,
		"store_visual_id": StoreVisualKitScript.SECURITY_TAG_BLOCK,
		"variant_visual_ids": [],
		"layout_fixture_id": &"starter_security_tag_block",
		"build_fixture_id": &"",
		"canonical_path": "res://game/scripts/visuals/small_display_prop_builder.gd",
		"source_kind": SOURCE_STORE_VISUAL_KIT,
		"generated_reason": "",
	},
}

static func concept_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for raw_id: Variant in CONCEPTS.keys():
		ids.append(raw_id as StringName)
	ids.sort()
	return ids


static func entry(concept_id: StringName) -> Dictionary:
	return (CONCEPTS.get(concept_id, {}) as Dictionary).duplicate(true)


static func starter_visual_aliases() -> Dictionary:
	return _aliases_from_concepts("store_visual_id")


static func starter_build_fixture_aliases() -> Dictionary:
	return _aliases_from_concepts("build_fixture_id")


static func _aliases_from_concepts(field_name: String) -> Dictionary:
	var aliases: Dictionary = {}
	for concept_id: StringName in concept_ids():
		var concept: Dictionary = CONCEPTS.get(concept_id, {}) as Dictionary
		var alias: StringName = concept.get(field_name, &"") as StringName
		if not String(alias).is_empty():
			aliases[concept_id] = alias
	return aliases
