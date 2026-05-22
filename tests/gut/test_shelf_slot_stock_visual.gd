## Tests for signal-driven ShelfSlot visual updates wired in StoreController.
## Verifies that item_stocked shows a 3D mesh on the slot and
## item_removed_from_shelf clears it — covering customer-purchase and
## move-to-backroom removal paths that bypass InventoryShelfActions.
extends GutTest


func _make_controller_with_slot(slot_id: String) -> Array:
	var controller := StoreController.new()
	var fixture := Node.new()
	fixture.add_to_group("fixture")
	controller.add_child(fixture)
	var slot := ShelfSlot.new()
	slot.slot_id = slot_id
	fixture.add_child(slot)
	add_child_autofree(controller)
	return [controller, slot]


func test_item_stocked_signal_occupies_slot() -> void:
	var pair: Array = _make_controller_with_slot("vis_slot_01")
	var slot := pair[1] as ShelfSlot

	EventBus.item_stocked.emit("inst_vis_01", "vis_slot_01")

	assert_true(
		slot.is_occupied(), "Slot must be occupied after item_stocked fires for its shelf_id"
	)


func test_item_stocked_adds_child_node_to_slot() -> void:
	var pair: Array = _make_controller_with_slot("vis_slot_02")
	var slot := pair[1] as ShelfSlot
	var count_before: int = slot.get_children().size()

	EventBus.item_stocked.emit("inst_vis_02", "vis_slot_02")

	assert_gt(
		slot.get_children().size(),
		count_before,
		"Stocking must add at least one child node (the item mesh) to the slot"
	)


func test_item_removed_from_shelf_clears_slot() -> void:
	var pair: Array = _make_controller_with_slot("vis_slot_03")
	var slot := pair[1] as ShelfSlot

	EventBus.item_stocked.emit("inst_vis_03", "vis_slot_03")
	assert_true(slot.is_occupied(), "Pre-condition: slot must be occupied after stocking")

	EventBus.item_removed_from_shelf.emit("inst_vis_03", "vis_slot_03")

	assert_false(
		slot.is_occupied(),
		"Slot must be empty after item_removed_from_shelf fires for its shelf_id"
	)


func test_item_stocked_unknown_shelf_id_no_effect() -> void:
	var pair: Array = _make_controller_with_slot("vis_slot_04")
	var slot := pair[1] as ShelfSlot

	EventBus.item_stocked.emit("inst_vis_04", "completely_different_shelf")

	assert_false(slot.is_occupied(), "Slot must not be occupied when shelf_id does not match")


func test_item_stocked_occupied_slot_keeps_first_item() -> void:
	var pair: Array = _make_controller_with_slot("vis_slot_05")
	var slot := pair[1] as ShelfSlot

	EventBus.item_stocked.emit("inst_first", "vis_slot_05")
	EventBus.item_stocked.emit("inst_second", "vis_slot_05")

	assert_eq(
		slot.get_item_instance_id(),
		"inst_first",
		"First item must remain; second stock on an occupied slot is rejected"
	)


func test_item_stocked_with_plural_category_uses_runtime_visual_key() -> void:
	var slot: ShelfSlot = _make_bare_slot()

	var ok: bool = slot.place_item("inst_plural_cart", "cartridges")

	assert_true(ok, "place_item must accept plural content categories")
	assert_eq(
		slot.get_held_category(),
		"cartridge",
		"Held category must be normalized before visual spawning"
	)
	assert_not_null(slot._item_node, "Stocking must spawn a visible item node")
	if slot._item_node != null:
		assert_eq(
			String(slot._item_node.name),
			"PlaceholderPropGameCartridge",
			"Plural cartridges must spawn the cartridge display template"
		)


func test_duplicate_place_does_not_replace_visual_or_count() -> void:
	var slot: ShelfSlot = _make_bare_slot()
	assert_true(slot.place_item("inst_first", "cartridges"))
	var first_visual: Node3D = slot._item_node
	var child_count: int = slot.get_children().size()

	var placed_again: bool = slot.place_item("inst_second", "consoles")

	assert_false(placed_again, "Occupied capacity-1 slot must reject restock")
	assert_eq(slot.get_item_instance_id(), "inst_first")
	assert_eq(slot.get_occupied(), 1, "Occupied count must stay at one")
	assert_eq(slot._item_node, first_visual, "Existing visual must not be replaced")
	assert_eq(
		slot.get_children().size(),
		child_count,
		"Rejected restock must not add another visible stock visual"
	)


func test_unknown_category_uses_default_visible_visual() -> void:
	var slot: ShelfSlot = _make_bare_slot()

	assert_true(slot.place_item("inst_unknown", "missing_display_metadata"))

	assert_true(slot.is_occupied(), "Fallback visual path must preserve stock state")
	assert_eq(slot.get_occupied(), 1)
	assert_not_null(slot._item_node, "Fallback path must still spawn a visual")
	if slot._item_node != null:
		assert_eq(
			String(slot._item_node.name),
			"PlaceholderPropShelfProduct",
			"Unknown categories must use the default shelf product visual"
		)
		assert_true(slot._item_node.visible, "Fallback visual must be visible")


func test_item_with_visual_metadata_spawns_designed_case_node() -> void:
	var slot: ShelfSlot = _make_bare_slot()

	var item_data: Dictionary = {
		"instance_id": "inst_catalog_case",
		"category": "cartridge",
		"box_art_key": "motorway_kings_neo_ignite",
	}
	var placed: bool = slot.place_item_with_data(item_data)

	assert_true(placed, "Metadata placement must keep the normal occupancy contract")
	assert_true(slot.is_occupied(), "Catalog-backed placement must occupy the slot")
	assert_not_null(slot._item_node, "Catalog-backed placement must spawn a visual")
	if slot._item_node != null:
		assert_eq(
			String(slot._item_node.name),
			"ProductVisualCaseRoot",
			"Known box_art_key must render the designed case template"
		)
		for child_name: String in [
			"FrontPanel",
			"SpinePanel",
			"SpineTitleLabel",
			"SpinePlatformLabel",
			"PlatformStripe",
			"TitleLabel",
		]:
			assert_not_null(
				slot._item_node.get_node_or_null(child_name),
				"Designed shelf case missing %s" % child_name
			)


func test_malformed_visual_metadata_falls_back_without_breaking_slot_state() -> void:
	var slot: ShelfSlot = _make_bare_slot()
	var changed_count: Array[int] = [0]
	slot.slot_changed.connect(func(_changed_slot: ShelfSlot) -> void: changed_count[0] += 1)

	var item_data: Dictionary = {
		"instance_id": "inst_bad_visual",
		"category": "guide",
		"box_art_key": "does_not_exist",
		"platform_stripe": 12,
	}
	var placed: bool = slot.place_item_with_data(item_data)

	assert_true(placed, "Bad visual metadata must not block shelf placement")
	assert_eq(changed_count[0], 1, "Successful placement must emit slot_changed once")
	assert_true(slot.is_occupied(), "Fallback placement must still occupy the slot")
	assert_eq(slot.get_item_instance_id(), "inst_bad_visual")
	assert_not_null(slot._item_node, "Fallback placement must still spawn a visual")
	if slot._item_node != null:
		assert_eq(
			String(slot._item_node.name),
			"PlaceholderPropShelfProduct",
			"Malformed visual metadata must return to category placeholders"
		)


func test_remove_item_clears_catalog_backed_visual_state() -> void:
	var slot: ShelfSlot = _make_bare_slot()
	slot.place_item_with_data(
		{
			"instance_id": "inst_remove_catalog_case",
			"category": "cartridge",
			"box_art_key": "brain_drill_wave_pocket",
		}
	)

	var removed: String = slot.remove_item()
	await get_tree().process_frame
	await get_tree().process_frame

	assert_eq(removed, "inst_remove_catalog_case")
	assert_false(slot.is_occupied(), "remove_item must clear occupancy")
	assert_eq(slot._held_item_visual_data.size(), 0, "remove_item must clear visual metadata")
	assert_eq(slot._item_node, null, "remove_item must clear designed visual reference")


func test_remove_empty_slot_does_not_emit_slot_changed() -> void:
	var slot: ShelfSlot = _make_bare_slot()
	var changed_count: Array[int] = [0]
	slot.slot_changed.connect(func(_changed_slot: ShelfSlot) -> void: changed_count[0] += 1)

	var removed: String = slot.remove_item()

	assert_eq(removed, "", "Empty remove must keep the existing empty result")
	assert_eq(slot.get_occupied(), 0, "Empty remove must not decrement below zero")
	assert_eq(changed_count[0], 0, "Empty remove must not emit a clear event")


# ── _update_visual SSOT entry point ───────────────────────────────────────────


func _make_bare_slot() -> ShelfSlot:
	var slot := ShelfSlot.new()
	add_child_autofree(slot)
	return slot


func test_place_item_spawns_placeholder_mesh_child() -> void:
	var slot: ShelfSlot = _make_bare_slot()
	var count_before: int = slot.get_children().size()

	slot.place_item("inst_visual_01", "cartridge")

	assert_gt(
		slot.get_children().size(),
		count_before,
		"place_item must spawn a placeholder child so the shelf is visibly stocked"
	)


func test_remove_item_frees_placeholder_mesh_child() -> void:
	var slot: ShelfSlot = _make_bare_slot()
	slot.place_item("inst_visual_02", "cartridge")
	var count_stocked: int = slot.get_children().size()
	assert_gt(count_stocked, 0, "Pre-condition: placeholder must be present")

	slot.remove_item()
	# queue_free defers; flush so the mesh is gone before we count children.
	await get_tree().process_frame
	await get_tree().process_frame

	assert_lt(
		slot.get_children().size(),
		count_stocked,
		"remove_item must free the placeholder so an empty slot has no item mesh"
	)


func test_update_visual_zero_frees_existing_mesh() -> void:
	var slot: ShelfSlot = _make_bare_slot()
	slot.place_item("inst_visual_03", "cartridge")
	assert_gt(slot.get_children().size(), 0, "Pre-condition: placeholder spawned")

	slot._update_visual(0)
	await get_tree().process_frame
	await get_tree().process_frame

	assert_eq(slot._item_node, null, "_update_visual(0) must clear the held item mesh reference")


func test_update_visual_idempotent_for_repeated_positive_quantity() -> void:
	var slot: ShelfSlot = _make_bare_slot()
	slot.place_item("inst_visual_04", "cartridge")
	var first_node: Node3D = slot._item_node
	assert_not_null(first_node, "Pre-condition: place_item must spawn a placeholder")

	slot._update_visual(1)

	assert_eq(
		slot._item_node,
		first_node,
		"_update_visual(1) must not respawn the placeholder when one already exists"
	)


# ── Per-category color tinting ────────────────────────────────────────────────


func _find_mesh_in_subtree(root: Node) -> MeshInstance3D:
	if root is MeshInstance3D:
		return root as MeshInstance3D
	for child: Node in root.get_children():
		var found: MeshInstance3D = _find_mesh_in_subtree(child)
		if found:
			return found
	return null


func test_placeholder_mesh_receives_category_tint() -> void:
	var slot: ShelfSlot = _make_bare_slot()
	slot.place_item("inst_visual_05", "cartridge")

	assert_not_null(slot._item_node, "Placeholder must exist after place_item")
	var mesh: MeshInstance3D = _find_mesh_in_subtree(slot._item_node)
	assert_not_null(mesh, "Placeholder subtree must contain a MeshInstance3D")
	var mat: Material = mesh.get_surface_override_material(0)
	assert_not_null(mat, "Placeholder mesh must carry a category-tinted override")
	var std_mat := mat as StandardMaterial3D
	assert_not_null(std_mat, "Override must be a StandardMaterial3D")
	var expected: Color = ShelfSlot.CATEGORY_COLORS.get("cartridge", Color.WHITE)
	assert_almost_eq(
		std_mat.albedo_color.r,
		expected.r,
		0.001,
		"Cartridge tint red component must match the category color table"
	)
	assert_almost_eq(
		std_mat.albedo_color.g,
		expected.g,
		0.001,
		"Cartridge tint green component must match the category color table"
	)


func test_placeholder_tint_distinguishes_categories() -> void:
	var slot_a: ShelfSlot = _make_bare_slot()
	var slot_b: ShelfSlot = _make_bare_slot()
	slot_a.place_item("inst_a", "cartridge")
	slot_b.place_item("inst_b", "vhs_tapes")

	var mesh_a: MeshInstance3D = _find_mesh_in_subtree(slot_a._item_node)
	var mesh_b: MeshInstance3D = _find_mesh_in_subtree(slot_b._item_node)
	var mat_a := mesh_a.get_surface_override_material(0) as StandardMaterial3D
	var mat_b := mesh_b.get_surface_override_material(0) as StandardMaterial3D

	assert_false(
		mat_a.albedo_color.is_equal_approx(mat_b.albedo_color),
		"Cartridge and VHS placeholders must read as visually different colors"
	)


# ── Stocked-item prompt label ─────────────────────────────────────────────────


func test_prompt_uses_stocked_item_name_after_set_display_data() -> void:
	var slot := ShelfSlot.new()
	slot.display_name = "Cartridge Slot"
	add_child_autofree(slot)
	slot.place_item("inst_visual_06", "cartridge")

	slot.set_display_data("Sonic the Hedgehog", "good", 24.99)

	assert_eq(
		slot.get_prompt_label(),
		"Sonic the Hedgehog ×1",
		"Occupied slot with display data must surface item name and quantity"
	)


func test_prompt_falls_back_to_authored_name_without_display_data() -> void:
	var slot := ShelfSlot.new()
	slot.display_name = "Cartridge Slot"
	add_child_autofree(slot)

	slot.place_item("inst_visual_07", "cartridge")

	assert_eq(
		slot.get_prompt_label(),
		"Cartridge Slot",
		"Occupied slot without set_display_data must fall back to the authored slot name"
	)


func test_prompt_resets_after_remove_item() -> void:
	var slot := ShelfSlot.new()
	slot.display_name = "Cartridge Slot"
	add_child_autofree(slot)
	slot.place_item("inst_visual_08", "cartridge")
	slot.set_display_data("Sonic the Hedgehog", "good", 24.99)

	slot.remove_item()

	assert_eq(
		slot.get_prompt_label(),
		ShelfSlot.PROMPT_NO_ITEM_SELECTED,
		"After remove_item the empty-slot prompt must return"
	)
