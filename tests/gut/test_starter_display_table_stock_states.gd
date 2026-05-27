extends GutTest

const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"
const VISUAL_LAYOUT_PATH: String = "res://game/content/visuals/store_visual_layouts.json"
const SLOT_PREFIX: String = "SlotMarker"
const ITEM_PREFIX: String = "StoreShelfItem"

var _root: Node3D = null


func before_each() -> void:
	StoreSessionState.reset_new_run()
	StoreSessionState.preopening_complete = true
	var scene: PackedScene = load(SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	_root = scene.instantiate() as Node3D
	add_child(_root)
	await get_tree().process_frame
	await get_tree().process_frame
	var controller: Node = _store_session_controller()
	if controller != null:
		var panel: ManagerNotePanel = controller.get("_vic_note_panel") as ManagerNotePanel
		if panel != null and panel.visible:
			panel.close()
			panel.note_dismissed.emit()
			await get_tree().process_frame


func after_each() -> void:
	if is_instance_valid(_root):
		_root.free()
	_root = null
	StoreSessionState.reset_new_run()


func test_scene_restock_target_declares_starter_display_table_identity() -> void:
	var shelf: Node = _restock_shelf()
	if shelf == null:
		return
	assert_eq(
		str(shelf.get_meta("visual_layout_name", "")),
		"StarterDisplayTable",
		"Scene-authored restock shelf must declare the matching visual-layout name"
	)
	assert_eq(
		str(shelf.get_meta("visual_fixture_id", "")),
		"starter_display_table",
		"Scene-authored restock shelf must declare the matching visual fixture id"
	)
	assert_eq(
		str(shelf.get_meta("restock_interactable_id", "")),
		"shelf.starter_display",
		"Scene-authored restock shelf must declare the gameplay interactable id"
	)
	var interactable: Node = shelf.get_node_or_null("Interactable")
	assert_not_null(interactable, "StoreSessionRestockShelf/Interactable must exist")
	if interactable != null:
		assert_eq(
			StringName(interactable.get("interactable_id")),
			&"shelf.starter_display",
			"Restock interactable id must stay tied to the starter display table"
		)
	assert_true(
		_visual_layout_contains_starter_display_table(),
		"Visual layout content must keep the StarterDisplayTable fixture entry"
	)


func test_empty_carrying_partial_and_stocked_states_are_distinct() -> void:
	var controller: Node = _store_session_controller()
	var shelf: Node = _restock_shelf()
	if controller == null or shelf == null:
		return
	_assert_overlay_visible(shelf, true, "Empty table should show EmptyOverlay")
	assert_eq(_count_shelf_items(shelf), 0, "Empty table starts with no spawned stock")
	await _walk_to_carrying_stock(controller)
	_assert_overlay_visible(shelf, true, "Carrying before placement is still an empty table")
	_assert_affordance_at_slot(shelf, 0, true)
	controller.on_store_restock_interacted(false)
	await get_tree().process_frame
	assert_eq(_count_shelf_items(shelf), 1, "First placement creates one product")
	_assert_item_at_slot(shelf, 0)
	_assert_overlay_visible(shelf, false, "Partial table should hide EmptyOverlay")
	_assert_affordance_at_slot(shelf, 1, true)
	controller.on_store_restock_interacted(false)
	await get_tree().process_frame
	assert_eq(_count_shelf_items(shelf), 2, "Second placement creates a partial table")
	_assert_item_at_slot(shelf, 1)
	_assert_affordance_at_slot(shelf, 2, true)
	controller.on_store_restock_interacted(false)
	await get_tree().process_frame
	assert_eq(
		_count_shelf_items(shelf),
		StoreSessionController._BACKROOM_DELIVERY_QUANTITY,
		"Final placement creates the Day 1 stocked state"
	)
	_assert_item_at_slot(shelf, 2)
	_assert_affordance_at_slot(shelf, 2, false)
	assert_false(StoreSessionState.carrying_stock, "Final placement clears carried stock")


func test_spawned_day_one_items_share_consistent_case_scale() -> void:
	var controller: Node = _store_session_controller()
	var shelf: Node = _restock_shelf()
	if controller == null or shelf == null:
		return
	await _walk_to_carrying_stock(controller)
	for _index: int in range(StoreSessionController._BACKROOM_DELIVERY_QUANTITY):
		controller.on_store_restock_interacted(false)
		await get_tree().process_frame
	for index: int in range(StoreSessionController._BACKROOM_DELIVERY_QUANTITY):
		var item: MeshInstance3D = shelf.get_node_or_null("%s%d" % [ITEM_PREFIX, index]) as MeshInstance3D
		assert_not_null(item, "StoreShelfItem%d must exist" % index)
		if item == null:
			continue
		var mesh: BoxMesh = item.mesh as BoxMesh
		assert_not_null(mesh, "StoreShelfItem%d must keep a case-like BoxMesh shell" % index)
		if mesh == null:
			continue
		assert_almost_eq(mesh.size.x, 0.18, 0.01, "Case width must stay consistent")
		assert_almost_eq(mesh.size.y, 0.22, 0.01, "Case height must stay consistent")
		assert_almost_eq(mesh.size.z, 0.06, 0.01, "Case depth must stay consistent")


func _store_session_controller() -> Node:
	return get_tree().get_first_node_in_group("store_session_controller")


func _restock_shelf() -> Node:
	var shelf: Node = _root.get_node_or_null("StoreSessionRestockShelf")
	assert_not_null(shelf, "StoreSessionRestockShelf must exist")
	return shelf


func _walk_to_carrying_stock(controller: Node) -> void:
	controller._on_choice_selected(&"clean_exchange", {})
	await get_tree().process_frame
	controller.on_store_stockroom_pickup_interacted()
	await get_tree().process_frame


func _count_shelf_items(shelf: Node) -> int:
	var count: int = 0
	for child: Node in shelf.get_children():
		if String(child.name).begins_with(ITEM_PREFIX):
			count += 1
	return count


func _assert_overlay_visible(shelf: Node, expected: bool, message: String) -> void:
	var overlay: Node3D = shelf.get_node_or_null("EmptyOverlay") as Node3D
	assert_not_null(overlay, "EmptyOverlay must exist")
	if overlay != null:
		assert_eq(overlay.visible, expected, message)


func _assert_affordance_at_slot(shelf: Node, slot_index: int, expected_visible: bool) -> void:
	var affordance: Node3D = (
		shelf.get_node_or_null("StoreSessionRestockPlacementAffordance") as Node3D
	)
	assert_not_null(affordance, "Placement affordance must exist after carrying stock")
	if affordance == null:
		return
	assert_eq(affordance.visible, expected_visible, "Placement affordance visibility mismatch")
	if expected_visible:
		var slot: Node3D = _slot_marker(shelf, slot_index)
		if slot != null:
			assert_almost_eq(affordance.position.x, slot.position.x, 0.01)


func _assert_item_at_slot(shelf: Node, slot_index: int) -> void:
	var item: Node3D = shelf.get_node_or_null("%s%d" % [ITEM_PREFIX, slot_index]) as Node3D
	assert_not_null(item, "StoreShelfItem%d must exist" % slot_index)
	var slot: Node3D = _slot_marker(shelf, slot_index)
	if item == null or slot == null:
		return
	assert_almost_eq(item.position.x, slot.position.x, 0.01)
	assert_gt(item.position.y, slot.position.y, "Spawned product must sit above its slot marker")
	assert_almost_eq(item.position.z, slot.position.z, 0.02)


func _slot_marker(shelf: Node, slot_index: int) -> Node3D:
	var slot: Node3D = shelf.get_node_or_null("%s%d" % [SLOT_PREFIX, slot_index]) as Node3D
	assert_not_null(slot, "SlotMarker%d must exist" % slot_index)
	return slot


func _visual_layout_contains_starter_display_table() -> bool:
	var raw: String = FileAccess.get_file_as_string(VISUAL_LAYOUT_PATH)
	var parsed: Variant = JSON.parse_string(raw)
	if not (parsed is Dictionary):
		return false
	for entry: Dictionary in (parsed as Dictionary).get("entries", []):
		if str(entry.get("layout_id", "")) != "retro_games_starter_small":
			continue
		for placement: Dictionary in entry.get("placements", []):
			if (
				str(placement.get("name", "")) == "StarterDisplayTable"
				and str(placement.get("fixture_id", "")) == "starter_display_table"
				and str(placement.get("fixture_type", "")) == "display_table"
			):
				return true
	return false
