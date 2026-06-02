extends GutTest

const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"
const VISUAL_LAYOUT_PATH: String = "res://game/content/visuals/store_visual_layouts.json"
const StoreMerchandisingLabelsScript: GDScript = preload(
	"res://game/scripts/store_session/store_merchandising_labels.gd"
)
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


func test_required_shelf_labels_resolve_from_store_merchandising_data() -> void:
	var required: Array[Dictionary] = [
		{
			"context": {
				"store_id": "retro_games",
				"phase": "starter",
				"surface": "starter_display",
				"role": "feature_header",
				"fixture_id": "starter_display_table",
				"category_id": "cartridges",
			},
			"text": "Fresh Trade Display",
		},
		{
			"context": {
				"store_id": "retro_games",
				"phase": "any",
				"surface": "shelf",
				"role": "category",
				"fixture_id": "cart_wall_rack",
				"category_id": "cartridges",
			},
			"text": "Used Games",
		},
		{
			"context": {
				"store_id": "retro_games",
				"phase": "any",
				"surface": "shelf",
				"role": "category",
				"fixture_id": "console_shelf",
				"category_id": "consoles",
			},
			"text": "Consoles",
		},
		{
			"context": {
				"store_id": "retro_games",
				"phase": "any",
				"surface": "bin",
				"role": "category",
				"fixture_id": "accessories_bin",
				"category_id": "accessories",
			},
			"text": "Accessories",
		},
		{
			"context": {
				"store_id": "retro_games",
				"phase": "any",
				"surface": "shelf",
				"role": "category",
				"fixture_id": "glass_showcase",
				"category_id": "guides",
			},
			"text": "Guides",
		},
		{
			"context": {
				"store_id": "retro_games",
				"phase": "any",
				"surface": "service_counter",
				"role": "service",
				"fixture_id": "checkout_counter",
				"service_id": "trade_ins",
			},
			"text": "Trade-Ins",
		},
		{
			"context": {
				"store_id": "retro_games",
				"phase": "any",
				"surface": "stockroom_pickup",
				"role": "service",
				"fixture_id": "checkout_counter",
				"service_id": "holds",
			},
			"text": "Holds",
		},
		{
			"context": {
				"store_id": "retro_games",
				"phase": "any",
				"surface": "display_table",
				"role": "collection",
				"fixture_id": "glass_showcase",
				"collection_id": "staff_picks",
			},
			"text": "Staff Picks\nCurated Soon",
		},
	]
	for spec: Dictionary in required:
		var resolved: Dictionary = StoreMerchandisingLabelsScript.resolve(spec["context"] as Dictionary)
		assert_false(resolved.is_empty(), "Merchandising label must resolve: %s" % spec)
		assert_eq(
			StoreMerchandisingLabelsScript.display_text(resolved),
			str(spec["text"]),
			"Resolved label text must come from store merchandising data"
		)
		assert_eq(
			str(resolved.get("source", "")),
			"store_config.merchandising_labels",
			"Resolved label must expose its store/content data source"
		)


func test_starter_display_runtime_label_uses_merchandising_data() -> void:
	var shelf: Node = _restock_shelf()
	if shelf == null:
		return
	var label: Label3D = (
		shelf.get_node_or_null("PriceTagRail/StarterDisplayMerchandisingLabelText") as Label3D
	)
	assert_not_null(label, "Starter display must add a readable merchandising label")
	if label == null:
		return
	assert_eq(label.text, "FRESH TRADE DISPLAY")
	assert_eq(
		str(label.get_meta("merchandising_label_source", "")),
		"store_config.merchandising_labels"
	)


func test_empty_carrying_partial_and_stocked_states_are_distinct() -> void:
	var controller: Node = _store_session_controller()
	var shelf: Node = _restock_shelf()
	if controller == null or shelf == null:
		return
	_assert_overlay_visible(shelf, true, "Empty table should show EmptyOverlay")
	assert_eq(_count_shelf_items(shelf), 0, "Empty table starts with no spawned stock")
	_assert_slot_state(controller, 0, StoreSessionController.SLOT_STATE_EMPTY)
	await _walk_to_carrying_stock(controller)
	_assert_overlay_visible(shelf, true, "Carrying before placement is still an empty table")
	_assert_affordance_at_slot(shelf, 0, true)
	_assert_slot_state(controller, 0, StoreSessionController.SLOT_STATE_EMPTY)
	controller.on_store_restock_interacted(false)
	await get_tree().process_frame
	assert_eq(_count_shelf_items(shelf), 1, "First placement creates one product")
	_assert_item_at_slot(shelf, 0, StoreSessionController.starter_first_delivery_item_ids()[0])
	_assert_slot_state(controller, 0, StoreSessionController.SLOT_STATE_STOCKED)
	_assert_overlay_visible(shelf, false, "Partial table should hide EmptyOverlay")
	_assert_affordance_at_slot(shelf, 1, true)
	controller.on_store_restock_interacted(false)
	await get_tree().process_frame
	assert_eq(_count_shelf_items(shelf), 2, "Second placement creates a partial table")
	_assert_item_at_slot(shelf, 1, StoreSessionController.starter_first_delivery_item_ids()[1])
	_assert_affordance_at_slot(shelf, 2, true)
	controller.on_store_restock_interacted(false)
	await get_tree().process_frame
	assert_eq(
		_count_shelf_items(shelf),
		StoreSessionController._BACKROOM_DELIVERY_QUANTITY,
		"Final placement creates the Day 1 stocked state"
	)
	_assert_item_at_slot(shelf, 2, StoreSessionController.starter_first_delivery_item_ids()[2])
	_assert_slot_state(controller, 2, StoreSessionController.SLOT_STATE_STOCKED)
	_assert_affordance_at_slot(shelf, 2, false)
	assert_false(StoreSessionState.carrying_stock, "Final placement clears carried stock")


func test_gap_markers_expose_state_shape_and_physical_cues() -> void:
	var controller: Node = _store_session_controller()
	var shelf: Node = _restock_shelf()
	if controller == null or shelf == null:
		return
	var states: Array[String] = [
		StoreSessionController.SLOT_STATE_SOLD,
		StoreSessionController.SLOT_STATE_HELD,
		StoreSessionController.SLOT_STATE_MISSING,
		StoreSessionController.SLOT_STATE_REFUSED,
		StoreSessionController.SLOT_STATE_BUNDLE_REMOVED,
		StoreSessionController.SLOT_STATE_EXCHANGE_RETURNED,
	]
	for index: int in range(states.size()):
		controller.call(
			"_show_starter_slot_gap",
			index,
			states[index],
			"test_product_%d" % index,
			"test_outcome",
			{}
		)
		var gap: Node3D = shelf.get_node_or_null("StarterDisplaySlotGap%d" % index) as Node3D
		assert_not_null(gap, "Gap marker must exist for %s" % states[index])
		if gap == null:
			continue
		assert_eq(str(gap.get_meta("slot_state", "")), states[index])
		assert_not_null(gap.get_node_or_null("GapTrayShadow"))
		var tag: Node = gap.get_node_or_null("GapStateTag")
		assert_not_null(tag, "Gap marker must include a non-color tag shape")
		if tag != null:
			assert_ne(str(tag.get_meta("tag_shape", "")), "")
		if states[index] == StoreSessionController.SLOT_STATE_HELD:
			assert_not_null(
				gap.get_node_or_null("GapProtectiveSleeve"),
				"Held state must use a physical sleeve cue"
			)


func test_visual_layers_separate_merchandising_price_empty_and_affordance() -> void:
	var controller: Node = _store_session_controller()
	var shelf: Node = _restock_shelf()
	if controller == null or shelf == null:
		return
	for node_path: String in [
		"TableTopSlab",
		"TableLeftApron",
		"TableRightApron",
		"TableUnderFrontRail",
		"TableUnderBackRail",
		"MerchandisingDeck/ProductTray0",
		"MerchandisingDeck/ProductTray1",
		"MerchandisingDeck/ProductTray2",
		"MerchandisingDeck/ConsoleRiser",
		"PriceTagRail/RestockShelfLabel",
		"PriceTagRail/GamePriceTag0",
		"PriceTagRail/GamePriceTag1",
		"EmptyOverlay",
		"Interactable",
	]:
		assert_not_null(
			shelf.get_node_or_null(node_path),
			"Starter display table must keep a separate %s layer" % node_path
		)
	await _walk_to_carrying_stock(controller)
	var affordance: Node = shelf.get_node_or_null("StoreSessionRestockPlacementAffordance")
	assert_not_null(affordance, "Placement affordance must be created while carrying stock")
	if affordance is Node3D:
		assert_gt(
			(affordance as Node3D).position.y,
			(_slot_marker(shelf, 0) as Node3D).position.y,
			"Placement affordance must sit above the product-zone marker layer"
		)


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


func test_stocked_items_use_shared_product_packaging_language() -> void:
	var controller: Node = _store_session_controller()
	var shelf: Node = _restock_shelf()
	if controller == null or shelf == null:
		return
	await _walk_to_carrying_stock(controller)
	for _index: int in range(StoreSessionController._BACKROOM_DELIVERY_QUANTITY):
		controller.on_store_restock_interacted(false)
		await get_tree().process_frame
	for index: int in range(StoreSessionController._BACKROOM_DELIVERY_QUANTITY):
		var item: Node = shelf.get_node_or_null("%s%d" % [ITEM_PREFIX, index])
		assert_not_null(item, "StoreShelfItem%d must exist" % index)
		if item == null:
			continue
		assert_not_null(
			_first_named_descendant(
				item,
				[
					"ProductVisualConsoleBoxRoot",
					"ProductVisualCaseRoot",
					"ProductVisualCartridgeRoot",
					"FallbackFrontPanel",
				]
			),
			"StoreShelfItem%d must expose a product package silhouette" % index
		)
		var price_tag: Node = _first_named_descendant(
			item, ["ProductPriceTag", "FallbackPriceTag"]
		)
		assert_not_null(price_tag, "StoreShelfItem%d must include a product price tag" % index)
		if price_tag != null and price_tag.has_meta("price_cents"):
			assert_gt(
				int(price_tag.get_meta("price_cents", -1)),
				0,
				"StoreShelfItem%d price tag must carry item pricing" % index
			)
		var product_kind: String = str(item.get_meta("product_visual_kind", ""))
		match product_kind:
			"console_box":
				assert_not_null(
					_first_named_descendant(item, ["ConsoleLabelPlate", "ConsoleColorStripe"]),
					"Console stock must keep label and accent panels"
				)
			"game_case":
				assert_not_null(
					_first_named_descendant(item, ["FrontPanel", "PlatformStripe", "TitleBlock"]),
					"Game stock must keep case cover panels"
				)
			"cartridge":
				assert_not_null(
					_first_named_descendant(item, ["CartridgeLabel", "CartridgeAccentStripe"]),
					"Cartridge stock must keep label and accent panels"
				)
			_:
				assert_not_null(
					_first_named_descendant(
						item,
						["FallbackFrontPanel", "FallbackPlatformStripe", "FallbackTitleBlock"]
					),
					"Fallback stock must still read as packaged merchandise"
				)


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


func _assert_item_at_slot(shelf: Node, slot_index: int, expected_item_id: String = "") -> void:
	var item: Node3D = shelf.get_node_or_null("%s%d" % [ITEM_PREFIX, slot_index]) as Node3D
	assert_not_null(item, "StoreShelfItem%d must exist" % slot_index)
	var slot: Node3D = _slot_marker(shelf, slot_index)
	if item == null or slot == null:
		return
	if not expected_item_id.is_empty():
		assert_eq(str(item.get_meta("product_item_id", "")), expected_item_id)
		assert_eq(int(item.get_meta("delivery_index", -1)), slot_index)
		assert_eq(int(item.get_meta("starter_catalog_index", -1)), slot_index)
		assert_eq(str(item.get_meta("stock_state", "")), "first_delivery_stocked")
		assert_eq(str(item.get_meta("stock_source", "")), "first_delivery")
		assert_eq(str(item.get_meta("slot_state", "")), StoreSessionController.SLOT_STATE_STOCKED)
	assert_almost_eq(item.position.x, slot.position.x, 0.01)
	assert_gt(item.position.y, slot.position.y, "Spawned product must sit above its slot marker")
	assert_almost_eq(item.position.z, slot.position.z, 0.02)


func _slot_marker(shelf: Node, slot_index: int) -> Node3D:
	var slot: Node3D = shelf.get_node_or_null("%s%d" % [SLOT_PREFIX, slot_index]) as Node3D
	assert_not_null(slot, "SlotMarker%d must exist" % slot_index)
	return slot


func _assert_slot_state(controller: Node, slot_index: int, expected: String) -> void:
	var states: Dictionary = controller.call("starter_display_slot_states") as Dictionary
	assert_true(states.has(slot_index), "Slot state map must include slot %d" % slot_index)
	if not states.has(slot_index):
		return
	var entry: Dictionary = states[slot_index] as Dictionary
	assert_eq(str(entry.get("slot_state", "")), expected)


func _first_named_descendant(root: Node, names: Array[String]) -> Node:
	if root == null:
		return null
	for name: String in names:
		if String(root.name) == name:
			return root
	for child: Node in root.get_children():
		var found: Node = _first_named_descendant(child, names)
		if found != null:
			return found
	return null


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
