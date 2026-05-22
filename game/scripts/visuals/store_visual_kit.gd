## Registry for reusable store fixture/prop scenes used by store layouts and
## runtime feedback. This is visual-only: inventory, unlocks, and economy stay
## in the game systems that decide when these assets appear.
class_name StoreVisualKit
extends RefCounted

const WALL_SHELF: StringName = &"wall_shelf"
const CHECKOUT_COUNTER: StringName = &"checkout_counter"
const STOCKROOM_TABLE: StringName = &"stockroom_table"
const STOCK_BOX: StringName = &"stock_box"
const GAME_CASE: StringName = &"game_case"
const CONSOLE_BOX: StringName = &"console_box"
const REGISTER: StringName = &"register"
const RECEIPT_PRINTER: StringName = &"receipt_printer"
const CARD_READER: StringName = &"card_reader"
const QUEUE_LANE: StringName = &"queue_lane"

const _SCENE_PATHS: Dictionary = {
	WALL_SHELF: "res://game/scenes/stores/fixtures/fixture_wall_shelf.tscn",
	CHECKOUT_COUNTER: "res://game/scenes/stores/fixtures/fixture_checkout_counter.tscn",
	STOCKROOM_TABLE: "res://game/scenes/stores/fixtures/fixture_stockroom_table.tscn",
	STOCK_BOX: "res://game/scenes/stores/fixtures/box_stack.tscn",
	GAME_CASE: "res://game/scenes/stores/fixtures/prop_game_case.tscn",
	CONSOLE_BOX: "res://game/scenes/stores/fixtures/prop_console_box.tscn",
	REGISTER: "res://game/scenes/stores/fixtures/prop_register.tscn",
	RECEIPT_PRINTER: "res://game/scenes/stores/fixtures/prop_receipt_printer.tscn",
	CARD_READER: "res://game/scenes/stores/fixtures/prop_card_reader.tscn",
	QUEUE_LANE: "res://game/scenes/stores/fixtures/fixture_queue_lane.tscn",
}

const _STARTER_STORE_IDS: Array[StringName] = [
	WALL_SHELF,
	CHECKOUT_COUNTER,
	STOCKROOM_TABLE,
	STOCK_BOX,
	GAME_CASE,
	CONSOLE_BOX,
	REGISTER,
]


static func scene_path(id: StringName) -> String:
	return str(_SCENE_PATHS.get(id, ""))


static func has_visual(id: StringName) -> bool:
	var path: String = scene_path(id)
	return not path.is_empty() and ResourceLoader.exists(path)


static func instantiate(id: StringName) -> Node:
	var path: String = scene_path(id)
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	var scene: PackedScene = load(path) as PackedScene
	if scene == null:
		return null
	return scene.instantiate()


static func required_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for raw_id: Variant in _SCENE_PATHS.keys():
		ids.append(raw_id as StringName)
	ids.sort()
	return ids


static func starter_store_ids() -> Array[StringName]:
	return _STARTER_STORE_IDS.duplicate()


static func validate() -> Dictionary:
	var missing: Array[StringName] = []
	for id: StringName in required_ids():
		if not has_visual(id):
			missing.append(id)
	return {
		"ok": missing.is_empty(),
		"missing": missing,
	}
