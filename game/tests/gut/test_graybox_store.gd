extends GutTest

const MAIN_SCENE := "res://scenes/world/store_world.tscn"
const LEGACY_SCENE := "res://scenes/world/graybox_store.tscn"

var _store: Node3D


func before_each() -> void:
	_store = load(MAIN_SCENE).instantiate()
	add_child_autofree(_store)


func test_main_scene_loads_store_world() -> void:
	assert_not_null(_store)
	assert_true(_store is Node3D)


func test_main_scene_has_expected_root_name() -> void:
	assert_eq(_store.name, "StoreWorld")


func test_legacy_graybox_store_wraps_store_world_for_compatibility() -> void:
	var legacy: Node3D = load(LEGACY_SCENE).instantiate()
	add_child_autofree(legacy)

	assert_eq(legacy.name, "GrayboxStore")
	assert_not_null(legacy.get_node_or_null("PlayerController"))
	assert_not_null(legacy.get_node_or_null("StoreSession"))
	assert_not_null(legacy.get_node_or_null("WorldModules"))
	assert_not_null(legacy.get_node_or_null("Systems"))


func test_store_world_has_modular_production_anchors() -> void:
	var world_modules := _store.get_node_or_null("WorldModules")
	var systems := _store.get_node_or_null("Systems")
	var lighting := _store.get_node_or_null("Lighting")
	var screenshot_anchors := _store.get_node_or_null("ScreenshotAnchors")

	assert_not_null(world_modules)
	assert_not_null(systems)
	assert_not_null(lighting)
	assert_not_null(screenshot_anchors)

	var expected_modules := [
		"WorldModules/MallConcourseModule",
		"WorldModules/StorefrontShellModule",
		"WorldModules/OpeningThresholdModule",
		"WorldModules/StoreInteriorShellModule",
		"WorldModules/FrontCounterZoneModule",
		"WorldModules/StarterProductDisplayModule",
		"WorldModules/SalesFloorFixturesModule",
		"WorldModules/ReceivingAreaModule",
		"WorldModules/BackroomShellModule",
		"Systems/StoreSystemsModule",
	]
	for module_path in expected_modules:
		var module := _store.get_node_or_null(module_path)
		assert_not_null(module, module_path)
		assert_true(module.has_method("missing_owned_node_names"), module_path)
		assert_false(str(module.get("module_id")).is_empty(), module_path)
		assert_false(str(module.get("responsibility")).is_empty(), module_path)
		assert_gt((module.get("owned_node_names") as PackedStringArray).size(), 0, module_path)


func test_store_world_module_manifests_resolve_owned_nodes() -> void:
	var manifests: Array[Node] = []
	manifests.append_array(_store.get_node("WorldModules").get_children())
	manifests.append(_store.get_node("Systems/StoreSystemsModule"))

	for manifest_node in manifests:
		var manifest := manifest_node
		assert_not_null(manifest, str(manifest_node.name))
		assert_true(manifest.has_method("missing_owned_node_names"), str(manifest_node.name))
		assert_eq(
			(manifest.call("missing_owned_node_names", _store) as PackedStringArray).size(),
			0,
			"%s missing owned production nodes" % str(manifest.get("module_id"))
		)


func test_player_controller_exists() -> void:
	assert_not_null(_store.get_node_or_null("PlayerController"))


func test_player_starts_above_floor() -> void:
	var player := _store.get_node("PlayerController") as CharacterBody3D
	assert_gt(player.global_position.y, -0.01)


func test_player_spawn_has_recovery_view_budget() -> void:
	var player := _store.get_node("PlayerController") as CharacterBody3D
	var head := player.get_node_or_null("Head") as Node3D
	var camera := player.get_node_or_null("Head/Camera3D") as Camera3D
	var hold_anchor := player.get_node_or_null("Head/Camera3D/HoldAnchor") as Node3D
	var register := _store.get_node("RegisterWorkstation") as Node3D

	assert_not_null(head)
	assert_not_null(camera)
	assert_not_null(hold_anchor)
	assert_lt(player.global_position.z, -10.0)
	assert_gt(player.global_position.x, -3.0)
	assert_lt(player.global_position.x, -2.2)
	assert_gt(head.position.y, 1.65)
	assert_gte(camera.fov, 78.0)
	assert_lte(camera.near, 0.04)
	assert_gt(-player.global_transform.basis.z.x, 0.35)
	assert_gt(-player.global_transform.basis.z.z, 0.9)
	assert_gt(_flat_distance_xz(player.global_position, register.global_position), 7.0)
	assert_gt(hold_anchor.position.x, 0.55)
	assert_lt(hold_anchor.position.y, -0.55)
	assert_lt(hold_anchor.position.z, -1.45)


func test_floor_collision_is_enabled() -> void:
	var floor := _store.get_node("Floor") as CSGBox3D
	assert_true(floor.use_collision)


func test_front_door_opening_is_walkable_from_mall_concourse() -> void:
	var blocker := _store.get_node_or_null("FrontDoorBlocker") as StaticBody3D
	assert_not_null(blocker)
	assert_false(blocker.visible)
	assert_almost_eq(blocker.global_position.z, -6.0, 0.01)

	var collision_shape := blocker.get_node_or_null("CollisionShape3D") as CollisionShape3D
	assert_not_null(collision_shape)
	assert_true(collision_shape.disabled)

	var shape := collision_shape.shape as BoxShape3D
	assert_not_null(shape)
	assert_gte(shape.size.x, 3.5)
	assert_gte(shape.size.y, 2.5)
	assert_gte(shape.size.z, 0.2)


func test_storefront_entry_has_production_cues() -> void:
	var left_glass := _store.get_node_or_null("StorefrontGlassLeft") as CSGBox3D
	var right_glass := _store.get_node_or_null("StorefrontGlassRight") as CSGBox3D
	var entry_cue := _store.get_node_or_null("EntrySidewalkCue") as CSGBox3D
	var threshold_strip := _store.get_node_or_null("EntryThresholdInteriorStrip") as CSGBox3D
	var concourse_floor := _store.get_node_or_null("SecondFloorMallConcourse/MallConcourseFloor") as CSGBox3D
	var railing := _store.get_node_or_null("SecondFloorMallConcourse/MallAtriumRailingTop") as CSGBox3D
	var open_door := _store.get_node_or_null("StorefrontOpenGlassDoor") as CSGBox3D
	var neon_top := _store.get_node_or_null("StorefrontNeonTopRail") as CSGBox3D
	var open_label := _store.get_node_or_null("OpenSignPanel/OpenSignLabel") as Label3D
	var hours_label := _store.get_node_or_null("HoursDecalPanel/HoursDecalLabel") as Label3D

	assert_not_null(left_glass)
	assert_not_null(right_glass)
	assert_not_null(entry_cue)
	assert_not_null(threshold_strip)
	assert_not_null(concourse_floor)
	assert_not_null(railing)
	assert_not_null(open_door)
	assert_not_null(neon_top)
	assert_not_null(open_label)
	assert_not_null(hours_label)
	assert_false(left_glass.use_collision)
	assert_false(right_glass.use_collision)
	assert_false(entry_cue.use_collision)
	assert_false(threshold_strip.use_collision)
	assert_true(concourse_floor.use_collision)
	assert_true(railing.use_collision)
	assert_eq(open_label.text, "CLOSED")
	assert_eq(hours_label.text, "11-8")
	assert_lt(left_glass.global_position.z, -5.8)
	assert_lt(right_glass.global_position.z, -5.8)
	assert_lt(concourse_floor.global_position.z, -8.5)
	assert_lt(railing.global_position.z, -13.0)
	assert_lt(open_door.global_position.z, -6.1)
	assert_gt(neon_top.global_position.y, 2.5)
	assert_lt(entry_cue.global_position.z, -5.8)
	assert_lt(threshold_strip.global_position.z, -5.2)
	assert_gt(left_glass.size.y, 1.6)
	assert_gt(right_glass.size.y, 1.6)

	var glass_material := left_glass.material as StandardMaterial3D
	assert_not_null(glass_material)
	assert_lt(glass_material.albedo_color.a, 0.5)
	assert_eq(glass_material.transparency, BaseMaterial3D.TRANSPARENCY_ALPHA)


func test_opening_visual_asset_pass_has_authored_route_modules() -> void:
	var mall_shell_boxes := [
		"SecondFloorMallConcourse/MallTilePanelNearLeft",
		"SecondFloorMallConcourse/MallTilePanelNearRight",
		"SecondFloorMallConcourse/MallTilePanelFarLeft",
		"SecondFloorMallConcourse/MallTilePanelFarRight",
		"SecondFloorMallConcourse/MallRailTopHighlight",
		"SecondFloorMallConcourse/NeighborStoreLeftShutterSlatA",
		"SecondFloorMallConcourse/NeighborStoreRightShutterSlatA",
		"SecondFloorMallConcourse/MallDirectoryMapLineA",
		"SecondFloorMallConcourse/MallDirectoryMapDot",
	]
	for prop_path in mall_shell_boxes:
		var prop := _store.get_node_or_null(prop_path) as CSGBox3D
		assert_not_null(prop, prop_path)
		assert_false(prop.use_collision, prop_path)

	for prop_path in [
		"SecondFloorMallConcourse/MallRailPostRoundA",
		"SecondFloorMallConcourse/MallRailPostRoundB",
		"SecondFloorMallConcourse/MallPlanterLeftLeafA",
		"SecondFloorMallConcourse/MallPlanterRightLeafA",
		"StoreIdentitySignDiscIcon",
	]:
		var prop := _store.get_node_or_null(prop_path) as CSGCylinder3D
		assert_not_null(prop, prop_path)
		assert_gte(prop.sides, 7, prop_path)

	var storefront_modules := [
		"StorefrontGlassLeftMullionVerticalA",
		"StorefrontGlassLeftMullionMidRail",
		"StorefrontGlassRightMullionVerticalA",
		"StorefrontGlassRightMullionMidRail",
		"StoreIdentitySignGlowBacker",
		"StoreIdentitySignCartridgeIcon",
		"StoreIdentitySignCartridgeNotch",
		"StorefrontOpenDoorTopRail",
		"StorefrontOpenDoorBottomRail",
		"StorefrontThresholdMetalLip",
		"StorefrontThresholdRubberInset",
	]
	for prop_path in storefront_modules:
		var prop := _store.get_node_or_null(prop_path) as CSGBox3D
		assert_not_null(prop, prop_path)
		assert_false(prop.use_collision, prop_path)
		assert_lt(prop.global_position.z, -5.0, prop_path)

	var sign_label := _store.get_node("StoreIdentitySignPanel/StoreIdentitySignLabel") as Label3D
	var setup_label := _store.get_node("OpenSignPanel/OpenSignLabel") as Label3D
	var hours_label := _store.get_node("HoursDecalPanel/HoursDecalLabel") as Label3D
	assert_lte(sign_label.pixel_size, 0.0041)
	assert_lte(setup_label.pixel_size, 0.0028)
	assert_eq(setup_label.text, "CLOSED")
	assert_lte(hours_label.pixel_size, 0.0027)


func test_opening_visual_asset_pass_has_starter_products_and_first_corner() -> void:
	var starter_product_boxes := [
		"StarterNewGameCaseA",
		"StarterNewGameCaseA/StarterNewGameCaseACoverStripe",
		"StarterNewGameCaseA/StarterNewGameCaseAPriceTag",
		"StarterNewGameCaseA/StarterNewGameCaseAGenreBadge",
		"StarterNewGameCaseB",
		"StarterNewGameCaseB/StarterNewGameCaseBCoverStripe",
		"StarterNewGameCaseB/StarterNewGameCaseBPlatformBand",
		"StarterNewGameCaseB/StarterNewGameCaseBQuestSigil",
		"StarterNewGameCaseB/StarterNewGameCaseBPriceTag",
		"StarterConsoleBox",
		"StarterConsoleBox/StarterConsoleBoxHandle",
		"StarterConsoleBox/StarterConsoleBoxScreenGraphic",
		"StarterAccessoryBox",
		"StarterAccessoryBox/StarterAccessoryControllerSilhouette",
		"StarterAccessoryBox/StarterAccessoryButtonDotA",
		"StarterAccessoryBox/StarterAccessoryButtonDotB",
		"WindowDisplayCaseA/WindowDisplayCaseACoverBand",
		"WindowDisplayCaseA/WindowDisplayCaseASpineStrip",
		"WindowDisplayCaseB/WindowDisplayCaseBPlatformBand",
		"WindowDisplayCaseB/WindowDisplayCaseBSealSticker",
	]
	for prop_path in starter_product_boxes:
		var prop := _store.get_node_or_null(prop_path) as CSGBox3D
		assert_not_null(prop, prop_path)
		assert_false(prop.use_collision, prop_path)

	assert_eq((_store.get_node("StarterNewGameCaseA/StarterNewGameCaseATitleLabel") as Label3D).text, "FOOTY 2002")
	assert_eq((_store.get_node("StarterNewGameCaseA/StarterNewGameCaseAPriceLabel") as Label3D).text, "New $49.99")
	assert_eq((_store.get_node("StarterNewGameCaseB/StarterNewGameCaseBTitleLabel") as Label3D).text, "AETHER QUEST")
	assert_eq((_store.get_node("StarterNewGameCaseB/StarterNewGameCaseBPriceLabel") as Label3D).text, "New $39.99")

	var first_corner_boxes := [
		"FirstInteriorBenchmarkSlatwall",
		"FirstInteriorSlatRailA",
		"FirstInteriorSlatRailB",
		"FirstInteriorSlatRailC",
		"FirstInteriorNewReleaseShelf",
		"FirstInteriorConsoleDisplayPlinth",
		"FirstInteriorConsoleDisplayBox",
		"FirstInteriorConsoleDisplayBox/FirstInteriorConsoleDisplayGraphic",
		"FirstInteriorAccessoryPegA",
		"FirstInteriorAccessoryPackA",
		"FirstInteriorAccessoryPackA/FirstInteriorAccessoryPackAIcon",
	]
	for prop_path in first_corner_boxes:
		var prop := _store.get_node_or_null(prop_path) as CSGBox3D
		assert_not_null(prop, prop_path)
		assert_false(prop.use_collision, prop_path)
		assert_true(_is_inside_store_floorprint(prop.global_position), prop_path)
		assert_lt(prop.global_position.z, -4.0, prop_path)

	assert_lt((_store.get_node("FirstInteriorNewReleaseShelf") as CSGBox3D).global_position.z, -4.5)
	assert_gt((_store.get_node("FirstInteriorBenchmarkSlatwall") as CSGBox3D).size.x, 2.0)
	assert_gt((_store.get_node("FirstInteriorConsoleDisplayBox") as CSGBox3D).size.y, 0.2)
	assert_lt((_store.get_node("StarterNewGameCaseA") as CSGBox3D).size.x, 0.24)
	assert_lt((_store.get_node("StarterNewGameCaseB") as CSGBox3D).size.x, 0.24)


func test_opening_spawn_composition_has_first_view_landmarks() -> void:
	var player := _store.get_node("PlayerController") as CharacterBody3D
	var store_sign := _store.get_node_or_null("StoreIdentitySignPanel") as CSGBox3D
	var register := _store.get_node_or_null("RegisterWorkstation") as Node3D
	var display_rack := _store.get_node_or_null("GameDisplayRack") as Node3D
	var backroom_hint := _store.get_node_or_null("BackroomHintFromEntryPanel") as CSGBox3D
	var concourse_sightline := _store.get_node_or_null("SecondFloorMallConcourse/OpeningSpawnSightline") as CSGBox3D
	var mall_directory := _store.get_node_or_null("SecondFloorMallConcourse/MallDirectoryPanel") as CSGBox3D
	var register_route := _store.get_node_or_null("EntryRouteStripeRegister") as CSGBox3D
	var shelf_route := _store.get_node_or_null("EntryRouteStripeShelf") as CSGBox3D

	assert_not_null(store_sign)
	assert_not_null(register)
	assert_not_null(display_rack)
	assert_not_null(backroom_hint)
	assert_not_null(concourse_sightline)
	assert_not_null(mall_directory)
	assert_not_null(register_route)
	assert_not_null(shelf_route)
	assert_false(backroom_hint.use_collision)
	assert_false(concourse_sightline.use_collision)
	assert_false(register_route.use_collision)
	assert_false(shelf_route.use_collision)
	assert_lt(_flat_distance_xz(player.global_position, store_sign.global_position), 6.4)
	assert_gt(_flat_distance_xz(player.global_position, register.global_position), 7.0)
	assert_gt(display_rack.global_position.z, 5.4)
	assert_gt(backroom_hint.global_position.z, 3.0)
	assert_eq((_store.get_node("BackroomHintFromEntryPanel/BackroomHintFromEntryLabel") as Label3D).text, "OFFICE + STOCK")
	assert_lt(concourse_sightline.global_position.z, -8.0)
	assert_lt(mall_directory.global_position.z, -11.0)
	assert_lt(register_route.global_position.z, -4.6)
	assert_lt(shelf_route.global_position.z, -4.5)
	assert_gt(register_route.global_position.x, 0.5)
	assert_lt(shelf_route.global_position.x, -0.5)


func test_receiving_box_exists() -> void:
	assert_not_null(_store.get_node_or_null("ReceivingBox"))


func test_used_game_exists() -> void:
	assert_not_null(_store.get_node_or_null("ReceivingBox/PlaceholderUsedGame"))


func test_used_game_starts_in_receiving_box() -> void:
	var receiving_box := _store.get_node("ReceivingBox") as Node3D
	var item := receiving_box.get_node("PlaceholderUsedGame") as Node3D

	assert_eq(item.get_parent(), receiving_box)
	assert_eq(item.get("location_id"), "receiving_box_001")
	assert_gt(item.global_position.y, 0.15)


func test_receiving_box_has_multiple_items() -> void:
	var receiving_box := _store.get_node("ReceivingBox") as Node3D
	assert_not_null(receiving_box.get_node_or_null("PlaceholderUsedGame"))
	assert_not_null(receiving_box.get_node_or_null("PlaceholderUsedGame002"))
	assert_not_null(receiving_box.get_node_or_null("PlaceholderUsedGame003"))


func test_receiving_box_has_nonblocking_intake_lanes_and_label() -> void:
	var receiving_box := _store.get_node("ReceivingBox") as Node3D
	var intake_label := receiving_box.get_node_or_null("IntakeTagPanel/IntakeTagLabel") as Label3D
	assert_not_null(intake_label)
	assert_eq(intake_label.text, "INTAKE")
	assert_eq(intake_label.billboard, 0)
	assert_lte(intake_label.pixel_size, 0.0028)

	for lane_name in ["ReceivingLane001", "ReceivingLane002", "ReceivingLane003"]:
		var lane := receiving_box.get_node_or_null(lane_name) as CSGBox3D
		assert_not_null(lane)
		assert_false(lane.use_collision)
		assert_lte(lane.size.y, 0.0121)
		assert_lte(absf(lane.position.x), 0.35)
		assert_lte(absf(lane.position.z), 0.08)


func test_receiving_box_has_open_invoice_sort_state_cues() -> void:
	var receiving_box := _store.get_node("ReceivingBox") as Node3D
	var expected_labels := {
		"OpenBoxStatePanel/OpenBoxStateLabel": "OPEN",
		"InvoiceStatePanel/InvoiceStateLabel": "CHECK",
		"SortStatePanel/SortStateLabel": "SORT",
	}

	for label_path in expected_labels:
		var label := receiving_box.get_node_or_null(label_path) as Label3D
		assert_not_null(label)
		assert_eq(label.text, expected_labels[label_path])
		assert_true(label.no_depth_test)
		assert_eq(label.billboard, BaseMaterial3D.BILLBOARD_ENABLED)
		assert_lte(label.pixel_size, 0.0032)

	for flap_name in ["OpenBoxFlapFront", "OpenBoxFlapLeft", "OpenBoxFlapRight"]:
		var flap := receiving_box.get_node_or_null(flap_name) as CSGBox3D
		assert_not_null(flap)
		assert_false(flap.use_collision)
		assert_gt(flap.global_position.y, 0.25)


func test_receiving_box_contains_mismatched_serial_item() -> void:
	var item := _store.get_node("ReceivingBox/PlaceholderUsedGame003")

	assert_eq(item.get("instance_id"), "item_used_star_trader_003")
	assert_eq(item.get("location_id"), "receiving_box_001")
	assert_eq(item.get("serial_id"), "GST-1047")
	assert_eq(item.get("expected_serial_id"), "GST-003")
	assert_true(item.call("has_serial_mismatch"))
	assert_eq(item.call("get_suspicious_event_id"), "serial_mismatch_item_used_star_trader_003")


func test_receiving_box_contains_supplier_message_artifact() -> void:
	var message := _store.get_node_or_null("ReceivingBox/SupplierMessage001")

	assert_not_null(message)
	assert_eq(message.get("message_id"), "msg_supplier_lot_a17")
	assert_eq(message.get("supplier_id"), "North Dock Wholesale")
	assert_string_contains(message.call("interact"), "Receiving discrepancy")


func test_display_rack_slot_starts_empty() -> void:
	var slot := _store.get_node("GameDisplayRack/ShelfSlot001") as ShelfSlot
	assert_true(slot.is_available())
	assert_null(slot.get_occupied_item())


func test_display_rack_has_twelve_stockable_slots() -> void:
	for slot_index in range(1, 13):
		assert_not_null(_store.get_node_or_null("GameDisplayRack/ShelfSlot%03d" % slot_index))


func test_display_rack_slots_are_assigned_used_game_category() -> void:
	for slot_name in _display_rack_slot_names():
		var slot := _store.get_node("GameDisplayRack/%s" % slot_name) as ShelfSlot
		assert_eq(slot.get_accepted_category(), "used_game")


func test_display_rack_is_wall_aligned() -> void:
	var rack := _store.get_node("GameDisplayRack") as Node3D
	assert_almost_eq(rack.global_position.z, 5.62, 0.01)
	assert_gt(rack.global_position.x, -3.3)


func test_receiving_box_is_clear_of_corner() -> void:
	var receiving_box := _store.get_node("ReceivingBox") as Node3D
	assert_gt(receiving_box.global_position.x, -5.0)
	assert_lt(receiving_box.global_position.z, 4.1)


func test_backroom_floor_marker_stays_subtle() -> void:
	var backroom_zone := _store.get_node("BackroomZone") as CSGBox3D
	assert_lte(backroom_zone.size.y, 0.013)
	assert_lte(backroom_zone.size.x, 12.4)


func test_store_materials_use_readable_floor_wall_counter_contrast() -> void:
	var floor_material := (_store.get_node("Floor") as CSGBox3D).material as StandardMaterial3D
	var wall_material := (_store.get_node("BackWall") as CSGBox3D).material as StandardMaterial3D
	var counter_material := (_store.get_node("CounterBase") as CSGBox3D).material as StandardMaterial3D

	assert_not_null(floor_material)
	assert_not_null(wall_material)
	assert_not_null(counter_material)
	assert_gt(_color_luma(wall_material.albedo_color), _color_luma(floor_material.albedo_color) + 0.28)
	assert_gt(_color_luma(floor_material.albedo_color), _color_luma(counter_material.albedo_color) + 0.14)
	assert_gt(wall_material.albedo_color.b, floor_material.albedo_color.b)
	assert_gte(floor_material.roughness, 0.9)
	assert_gte(wall_material.roughness, 0.65)


func test_finished_shell_trim_and_material_cues_are_nonblocking() -> void:
	var finish_props := [
		"SalesChairRailBack",
		"SalesChairRailLeft",
		"SalesChairRailRight",
		"SalesCornerTrimBackLeft",
		"SalesCornerTrimBackRight",
		"SalesCeilingGridLong",
		"SalesCeilingGridCross",
		"EntryRubberMat",
		"RegisterRubberMat",
	]
	for prop_path in finish_props:
		var prop := _store.get_node_or_null(prop_path) as CSGBox3D
		assert_not_null(prop)
		assert_false(prop.use_collision, prop_path)
		assert_true(_is_inside_store_floorprint(prop.global_position), prop_path)

	var chair_rail := _store.get_node("SalesChairRailBack") as CSGBox3D
	var corner_trim := _store.get_node("SalesCornerTrimBackLeft") as CSGBox3D
	var ceiling_grid := _store.get_node("SalesCeilingGridLong") as CSGBox3D
	var entry_mat := _store.get_node("EntryRubberMat") as CSGBox3D
	var register_mat := _store.get_node("RegisterRubberMat") as CSGBox3D
	var wall_material := (_store.get_node("BackWall") as CSGBox3D).material as StandardMaterial3D
	var rail_material := chair_rail.material as StandardMaterial3D
	var mat_material := entry_mat.material as StandardMaterial3D

	assert_not_null(rail_material)
	assert_not_null(mat_material)
	assert_gt(_color_luma(rail_material.albedo_color), _color_luma(wall_material.albedo_color) - 0.2)
	assert_lt(_color_luma(mat_material.albedo_color), 0.25)
	assert_gt(corner_trim.size.y, 2.2)
	assert_gt(ceiling_grid.global_position.y, 2.8)
	assert_lte(entry_mat.size.y, 0.015)
	assert_lte(register_mat.size.y, 0.015)


func test_store_lighting_has_bright_store_warm_mall_and_cool_backroom_layers() -> void:
	var sun_light := _store.get_node_or_null("SunLight") as DirectionalLight3D
	var mall_light := _store.get_node_or_null("MallConcourseLight") as OmniLight3D
	var sales_light := _store.get_node_or_null("StoreLight") as OmniLight3D
	var register_light := _store.get_node_or_null("RegisterTaskLight") as OmniLight3D
	var backroom_light := _store.get_node_or_null("BackroomUtilityLight") as OmniLight3D

	assert_not_null(sun_light)
	assert_not_null(mall_light)
	assert_not_null(sales_light)
	assert_not_null(register_light)
	assert_not_null(backroom_light)
	assert_lte(sun_light.light_energy, 1.0)
	assert_gt(sales_light.light_energy, backroom_light.light_energy)
	assert_gt(sales_light.light_energy, mall_light.light_energy)
	assert_gt(register_light.light_energy, 1.5)
	assert_gt(mall_light.light_color.r, mall_light.light_color.b)
	assert_gt(sales_light.light_color.b, sales_light.light_color.r)
	assert_gt(register_light.light_color.r, register_light.light_color.b)
	assert_gt(backroom_light.light_color.b, backroom_light.light_color.r)
	assert_gt(mall_light.omni_range, 8.0)
	assert_lt(sales_light.global_position.z, 1.0)
	assert_gt(backroom_light.global_position.z, 4.0)


func test_production_lighting_accents_stay_readable_and_bounded() -> void:
	var accent_lights := {
		"StorefrontAccentLight": {
			"warm": true,
			"z_less_than": -4.0,
			"max_energy": 1.25,
			"max_range": 3.3,
		},
		"ShelfAccentLight": {
			"warm": true,
			"z_greater_than": 4.0,
			"max_energy": 1.35,
			"max_range": 3.2,
		},
		"ReceivingWorkLight": {
			"warm": false,
			"z_greater_than": 4.0,
			"max_energy": 1.0,
			"max_range": 2.7,
		},
		"BackroomDeskLight": {
			"warm": false,
			"z_greater_than": 4.0,
			"max_energy": 1.1,
			"max_range": 2.6,
		},
	}

	var total_accent_energy := 0.0
	for light_name in accent_lights:
		var light := _store.get_node_or_null(light_name) as OmniLight3D
		assert_not_null(light)
		assert_gt(light.global_position.y, 1.6)
		assert_lte(light.light_energy, accent_lights[light_name]["max_energy"])
		assert_lte(light.omni_range, accent_lights[light_name]["max_range"])
		if accent_lights[light_name].has("z_less_than"):
			assert_lt(light.global_position.z, accent_lights[light_name]["z_less_than"])
		if accent_lights[light_name].has("z_greater_than"):
			assert_gt(light.global_position.z, accent_lights[light_name]["z_greater_than"])
		if accent_lights[light_name]["warm"]:
			assert_gt(light.light_color.r, light.light_color.b)
		else:
			assert_gt(light.light_color.b, light.light_color.r)
		total_accent_energy += light.light_energy

	var sun_light := _store.get_node("SunLight") as DirectionalLight3D
	var sales_light := _store.get_node("StoreLight") as OmniLight3D
	var register_light := _store.get_node("RegisterTaskLight") as OmniLight3D
	var backroom_light := _store.get_node("BackroomUtilityLight") as OmniLight3D
	assert_lte(sun_light.light_energy + sales_light.light_energy + register_light.light_energy + backroom_light.light_energy + total_accent_energy, 12.25)


func test_packet_seven_material_polish_has_attached_carpet_and_wall_cues() -> void:
	for fleck_path in [
		"CommercialCarpetFleckA",
		"CommercialCarpetFleckB",
		"CommercialCarpetFleckC",
		"CommercialCarpetFleckD",
		"CommercialCarpetFleckE",
		"CommercialCarpetFleckF",
	]:
		var fleck := _store.get_node_or_null(fleck_path) as CSGBox3D
		assert_not_null(fleck, fleck_path)
		assert_false(fleck.use_collision, fleck_path)
		assert_lte(fleck.size.y, 0.0061, fleck_path)
		assert_true(_is_inside_store_floorprint(fleck.global_position), fleck_path)

	for panel_path in [
		"SalesWallColorPanelBackLeft",
		"SalesWallColorPanelBackRight",
		"SalesWallColorPanelLeftFront",
		"SalesWallColorPanelRightFront",
	]:
		var panel := _store.get_node_or_null(panel_path) as CSGBox3D
		assert_not_null(panel, panel_path)
		assert_false(panel.use_collision, panel_path)
		assert_true(_is_inside_store_floorprint(panel.global_position), panel_path)
		assert_gt(panel.global_position.y, 1.0, panel_path)

	var mall_material := (_store.get_node("SecondFloorMallConcourse/MallConcourseFloor") as CSGBox3D).material as StandardMaterial3D
	var wall_panel_material := (_store.get_node("SalesWallColorPanelBackLeft") as CSGBox3D).material as StandardMaterial3D
	var wall_material := (_store.get_node("BackWall") as CSGBox3D).material as StandardMaterial3D
	assert_not_null(mall_material)
	assert_not_null(wall_panel_material)
	assert_gt(mall_material.albedo_color.r, mall_material.albedo_color.b)
	assert_gt(absf(_color_luma(wall_material.albedo_color) - _color_luma(wall_panel_material.albedo_color)), 0.08)


func test_stockroom_lighting_materials_and_density_cues_stay_nonblocking() -> void:
	var cool_light_props := [
		"StockroomCoolLightStripReceiving",
		"StockroomCoolLightStripOffice",
	]
	for prop_path in cool_light_props:
		var prop := _store.get_node_or_null(prop_path) as CSGBox3D
		assert_not_null(prop)
		assert_false(prop.use_collision)
		assert_gt(prop.global_position.y, 2.5)
		var material := prop.material as StandardMaterial3D
		assert_not_null(material)
		assert_gt(material.albedo_color.b, material.albedo_color.r)

	var carry_route := _store.get_node("StockroomCarryRoute") as CSGBox3D
	for tape_path in ["StockroomRouteTapeA", "StockroomRouteTapeB", "StockroomRouteTapeC"]:
		var tape := _store.get_node_or_null(tape_path) as CSGBox3D
		assert_not_null(tape)
		assert_false(tape.use_collision)
		assert_lte(tape.size.y, 0.0061)
		assert_lte(_flat_distance_xz(tape.global_position, carry_route.global_position), 4.0)
		var tape_material := tape.material as StandardMaterial3D
		assert_not_null(tape_material)
		assert_eq(tape_material.transparency, BaseMaterial3D.TRANSPARENCY_ALPHA)

	for shadow_path in ["ReceivingPalletShadow", "BackstockShelfShadow"]:
		var shadow := _store.get_node_or_null(shadow_path) as CSGBox3D
		assert_not_null(shadow)
		assert_false(shadow.use_collision)
		assert_lte(shadow.size.y, 0.0041)
		assert_lte(shadow.global_position.y, 0.006)
		var shadow_material := shadow.material as StandardMaterial3D
		assert_not_null(shadow_material)
		assert_eq(shadow_material.transparency, BaseMaterial3D.TRANSPARENCY_ALPHA)

	var cardboard := (_store.get_node("ReceivingBoxStackA") as CSGBox3D).material as StandardMaterial3D
	var cardboard_alt := (_store.get_node("ReceivingBoxStackB") as CSGBox3D).material as StandardMaterial3D
	var paper := (_store.get_node("ReceivingInvoicePaper") as CSGBox3D).material as StandardMaterial3D
	var blue_slip := (_store.get_node("ReceivingBlueSortSlip") as CSGBox3D).material as StandardMaterial3D
	assert_not_null(cardboard)
	assert_not_null(cardboard_alt)
	assert_not_null(paper)
	assert_not_null(blue_slip)
	assert_gt(absf(cardboard_alt.albedo_color.r - cardboard.albedo_color.r), 0.05)
	assert_gt(blue_slip.albedo_color.b, paper.albedo_color.b)

	for wall_detail_path in ["ReceivingWallChecklist", "ReceivingWallBlueSlip", "OfficeWallPlannerCardA", "OfficeWallPlannerCardB"]:
		var wall_detail := _store.get_node_or_null(wall_detail_path) as CSGBox3D
		assert_not_null(wall_detail)
		assert_false(wall_detail.use_collision)
		assert_gt(wall_detail.global_position.y, 1.0)
		assert_gt(wall_detail.global_position.z, 5.6)


func test_sales_floor_has_merchandising_and_route_cues() -> void:
	var route_mat := _store.get_node_or_null("SalesFloorRouteMat") as CSGBox3D
	var new_release_endcap := _store.get_node_or_null("NewReleaseEndcap") as Node3D
	var staff_picks_stand := _store.get_node_or_null("StaffPicksStand") as Node3D
	var new_release_label := _store.get_node_or_null("NewReleaseEndcap/EndcapHeaderPanel/EndcapHeaderLabel") as Label3D
	var staff_picks_label := _store.get_node_or_null("StaffPicksStand/StaffPicksHeaderPanel/StaffPicksHeaderLabel") as Label3D
	var used_talker_label := _store.get_node_or_null("UsedShelfTalkerPanel/UsedShelfTalkerLabel") as Label3D
	var preorder_label := _store.get_node_or_null("PreorderWallHeaderPanel/PreorderWallHeaderLabel") as Label3D

	assert_not_null(route_mat)
	assert_not_null(new_release_endcap)
	assert_not_null(staff_picks_stand)
	assert_not_null(new_release_label)
	assert_not_null(staff_picks_label)
	assert_not_null(used_talker_label)
	assert_not_null(preorder_label)
	assert_false(route_mat.use_collision)
	assert_eq(new_release_label.text, "NEW RELEASES")
	assert_eq(staff_picks_label.text, "STAFF PICKS")
	assert_eq(used_talker_label.text, "TESTED")
	assert_eq(preorder_label.text, "PREORDERS")
	assert_lte(route_mat.size.y, 0.0121)
	assert_true(_is_inside_store_floorprint(route_mat.global_position))
	assert_true(_is_inside_store_floorprint(new_release_endcap.global_position))
	assert_true(_is_inside_store_floorprint(staff_picks_stand.global_position))
	assert_lt(new_release_endcap.global_position.z, 0.0)
	assert_lt(staff_picks_stand.global_position.z, 1.0)

	for cue_path in [
		"NewReleaseEndcap/EndcapBase",
		"NewReleaseEndcap/EndcapHeaderPanel",
		"NewReleaseEndcap/EndcapCaseStackA",
		"NewReleaseEndcap/EndcapCaseStackB",
		"StaffPicksStand/StaffPicksBase",
		"StaffPicksStand/StaffPicksHeaderPanel",
		"StaffPicksStand/StaffPickCaseA",
		"StaffPicksStand/StaffPickCaseB",
		"UsedSpineRowTop",
		"UsedSpineRowMiddle",
		"UsedSpineRowBottom",
		"UsedShelfTalkerPanel",
		"PreorderWallPanel",
		"PreorderWallHeaderPanel",
		"PreorderCaseStackA",
		"PreorderCaseStackB",
		"PreorderCaseStackC",
	]:
		var cue := _store.get_node_or_null(cue_path) as CSGBox3D
		assert_not_null(cue)
		assert_false(cue.use_collision)

	var register := _store.get_node("RegisterWorkstation") as Node3D
	var rack := _store.get_node("GameDisplayRack") as Node3D
	assert_gt(_flat_distance_xz(new_release_endcap.global_position, register.global_position), 3.0)
	assert_gt(_flat_distance_xz(staff_picks_stand.global_position, rack.global_position), 4.0)
	assert_lt(_flat_distance_xz((_store.get_node("UsedSpineRowTop") as CSGBox3D).global_position, rack.global_position), 1.0)
	assert_gt((_store.get_node("PreorderWallPanel") as CSGBox3D).global_position.x, 6.6)


func test_fixture_kit_has_accessory_and_locked_case_cues() -> void:
	var peg_wall := _store.get_node_or_null("AccessoryPegWall") as Node3D
	var locked_case := _store.get_node_or_null("LockedCasePlaceholder") as Node3D
	var peg_label := _store.get_node_or_null("AccessoryPegWall/PegWallHeaderPanel/PegWallHeaderLabel") as Label3D
	var locked_label := _store.get_node_or_null("LockedCasePlaceholder/LockedCaseHeaderPanel/LockedCaseHeaderLabel") as Label3D
	var peg_unlock_label := _store.get_node_or_null("FuturePegWallUnlockPanel/FuturePegWallUnlockLabel") as Label3D
	var storage_unlock_label := _store.get_node_or_null("FutureBackroomRackUnlockPanel/FutureBackroomRackUnlockLabel") as Label3D

	assert_not_null(peg_wall)
	assert_not_null(locked_case)
	assert_not_null(peg_label)
	assert_not_null(locked_label)
	assert_not_null(peg_unlock_label)
	assert_not_null(storage_unlock_label)
	assert_eq(peg_label.text, "ACCESSORIES")
	assert_eq(locked_label.text, "LOCKED CASE")
	assert_eq(peg_unlock_label.text, "PEG UPGRADE")
	assert_eq(storage_unlock_label.text, "STORAGE UPGRADE")
	assert_true(_is_inside_store_floorprint(peg_wall.global_position))
	assert_true(_is_inside_store_floorprint(locked_case.global_position))
	assert_gt(peg_wall.global_position.x, 6.0)
	assert_gt(locked_case.global_position.x, 4.8)
	assert_lt(locked_case.global_position.z, 0.0)

	for cue_path in [
		"AccessoryPegWall/PegWallBackPanel",
		"AccessoryPegWall/PegWallHeaderPanel",
		"AccessoryPegWall/PegHookA",
		"AccessoryPegWall/PegHookB",
		"AccessoryPegWall/PegHookC",
		"AccessoryPegWall/PegAccessoryCardA",
		"AccessoryPegWall/PegAccessoryCardB",
		"AccessoryPegWall/PegAccessoryCardC",
		"FuturePegWallUnlockPanel",
		"FutureBackroomRackUnlockPanel",
		"LockedCasePlaceholder/LockedCaseBase",
		"LockedCasePlaceholder/LockedCaseGlass",
		"LockedCasePlaceholder/LockedCaseHeaderPanel",
		"LockedCasePlaceholder/LockedCaseItemA",
		"LockedCasePlaceholder/LockedCaseItemB",
	]:
		var cue := _store.get_node_or_null(cue_path) as CSGBox3D
		assert_not_null(cue)
		assert_false(cue.use_collision)

	var glass_material := (_store.get_node("LockedCasePlaceholder/LockedCaseGlass") as CSGBox3D).material as StandardMaterial3D
	assert_not_null(glass_material)
	assert_lt(glass_material.albedo_color.a, 0.5)
	assert_true(peg_unlock_label.no_depth_test)
	assert_true(storage_unlock_label.no_depth_test)
	assert_gt((_store.get_node("FuturePegWallUnlockPanel") as CSGBox3D).global_position.x, 6.0)
	assert_gt((_store.get_node("FutureBackroomRackUnlockPanel") as CSGBox3D).global_position.z, 3.8)


func test_day_one_owned_starter_stock_is_physical_and_limited() -> void:
	var starter_crate := _store.get_node_or_null("DayOneStarterStockCrate") as Node3D
	var starter_label := _store.get_node_or_null("DayOneStarterStockCrate/StarterStockTicketPanel/StarterStockTicketLabel") as Label3D
	var checklist := _store.get_node_or_null("FirstOpenChecklistPanel/FirstOpenChecklistLabel") as Label3D
	var empty_capacity_label := _store.get_node_or_null("DayOneEmptyShelfTagPanel/DayOneEmptyShelfTagLabel") as Label3D

	assert_not_null(starter_crate)
	assert_not_null(starter_label)
	assert_not_null(checklist)
	assert_not_null(empty_capacity_label)
	assert_eq(starter_label.text, "OWNED STARTER")
	assert_eq(checklist.text, "PLACE THEN OPEN")
	assert_eq(empty_capacity_label.text, "ROOM TO GROW")
	assert_gt(starter_crate.global_position.z, 3.8)
	assert_lt(starter_crate.global_position.x, -3.8)
	assert_true(_is_inside_store_floorprint(starter_crate.global_position))
	assert_lt((_store.get_node("DayOneEmptyShelfTagPanel") as CSGBox3D).global_position.z, 5.3)

	var starter_items := [
		"DayOneStarterStockCrate/StarterNewGameCaseA",
		"DayOneStarterStockCrate/StarterNewGameCaseB",
		"DayOneStarterStockCrate/StarterConsoleBox",
		"DayOneStarterStockCrate/StarterAccessoryController",
	]
	for item_path in starter_items:
		var item := _store.get_node_or_null(item_path) as CSGBox3D
		assert_not_null(item, item_path)
		assert_false(item.use_collision, item_path)
		assert_lt(_flat_distance_xz(item.global_position, starter_crate.global_position), 0.55)

	for empty_capacity_path in ["DayOneEmptyCapacityRailA", "DayOneEmptyCapacityRailB", "DayOneEmptyShelfTagPanel"]:
		var cue := _store.get_node_or_null(empty_capacity_path) as CSGBox3D
		assert_not_null(cue, empty_capacity_path)
		assert_false(cue.use_collision, empty_capacity_path)


func test_future_inventory_is_catalog_planning_until_paid_or_received() -> void:
	var future_catalog_label := _store.get_node_or_null("FutureProductCatalogPanel/FutureProductCatalogLabel") as Label3D
	var design_catalog_label := _store.get_node_or_null("StoreDesignCatalogPanel/StoreDesignCatalogLabel") as Label3D
	var cost_rule_label := _store.get_node_or_null("CatalogCostRulePanel/CatalogCostRuleLabel") as Label3D
	var paid_arrival_label := _store.get_node_or_null("PaidOrderReceivingLabelPanel/PaidOrderReceivingLabel") as Label3D
	var paid_arrival_lane := _store.get_node_or_null("PaidOrderReceivingLane") as CSGBox3D

	assert_not_null(future_catalog_label)
	assert_not_null(design_catalog_label)
	assert_not_null(cost_rule_label)
	assert_not_null(paid_arrival_label)
	assert_not_null(paid_arrival_lane)
	assert_eq(future_catalog_label.text, "ORDER CATALOG")
	assert_eq(design_catalog_label.text, "STORE DESIGN")
	assert_eq(cost_rule_label.text, "BUY -> RECEIVING")
	assert_eq(paid_arrival_label.text, "PAID ARRIVALS")
	assert_false(paid_arrival_lane.use_collision)
	assert_gt(paid_arrival_lane.global_position.z, 3.0)
	assert_lt(_flat_distance_xz(paid_arrival_lane.global_position, (_store.get_node("ReceivingBox") as Node3D).global_position), 1.0)

	var catalog_surfaces := [
		"FutureProductCatalogPanel",
		"StoreDesignCatalogPanel",
		"CatalogCostRulePanel",
		"BackroomCatalogCardA",
		"BackroomCatalogCardB",
		"BackroomCartSummaryPanel",
		"FuturePegWallUnlockPanel",
		"FutureBackroomRackUnlockPanel",
		"UpgradePreviewRackCard",
	]
	for surface_path in catalog_surfaces:
		var surface := _store.get_node_or_null(surface_path) as CSGBox3D
		assert_not_null(surface, surface_path)
		assert_false(surface.use_collision, surface_path)

	for forbidden_path in [
		"BackroomStorageShelf/FutureProductStock",
		"BackroomStorageShelf/LockedFutureInventory",
		"BackroomStorageShelf/UnownedCatalogStock",
		"DayOneStarterStockCrate/FutureProductStock",
		"DayOneStarterStockCrate/LockedFutureInventory",
	]:
		assert_null(_store.get_node_or_null(forbidden_path), forbidden_path)


func test_store_signage_uses_fictional_world_labels() -> void:
	var expected_labels := {
		"StoreIdentitySignPanel/StoreIdentitySignLabel": "Games4U",
		"DisplaySignPanel/DisplaySignLabel": "RACKS",
		"RegisterSignPanel/RegisterSignLabel": "REGISTER",
		"BackroomSignPanel/BackroomSignLabel": "STAFF",
		"ReceivingSignPanel/ReceivingSignLabel": "RECV",
		"StorageSignPanel/StorageSignLabel": "STOCK",
	}
	var banned_terms := ["GAMESTOP", "NINTENDO", "PLAYSTATION", "XBOX", "SEGA", "ATARI"]

	for label_path in expected_labels:
		var label := _store.get_node_or_null(label_path) as Label3D
		assert_not_null(label)
		assert_eq(label.text, expected_labels[label_path])
		if label_path == "StoreIdentitySignPanel/StoreIdentitySignLabel":
			assert_true(label.is_visible_in_tree(), label_path)
			assert_gte(label.font_size, 20)
			assert_lte(label.pixel_size, 0.0041)
		else:
			assert_false(label.is_visible_in_tree(), "%s should no longer explain the benchmark route" % label_path)
			assert_lte(label.pixel_size, 0.003)
		assert_eq(label.billboard, 0)
		for banned_term in banned_terms:
			assert_false(label.text.contains(banned_term))


func test_store_sign_panels_are_nonblocking_and_zone_aligned() -> void:
	var expected_panels := {
		"StoreIdentitySignPanel": Vector3(0, 2.18, -5.86),
		"DisplaySignPanel": Vector3(-3.18, 1.98, 5.82),
		"RegisterSignPanel": Vector3(2.55, 1.38, -2.92),
		"BackroomSignPanel": Vector3(0.2, 1.78, 3.36),
		"ReceivingSignPanel": Vector3(-5.28, 1.72, 5.84),
		"StorageSignPanel": Vector3(-5.85, 1.52, 4.78),
	}

	for panel_name in expected_panels:
		var panel := _store.get_node_or_null(panel_name) as CSGBox3D
		assert_not_null(panel)
		assert_false(panel.use_collision)
		assert_almost_eq(panel.global_position.x, expected_panels[panel_name].x, 0.01)
		assert_almost_eq(panel.global_position.y, expected_panels[panel_name].y, 0.01)
		assert_almost_eq(panel.global_position.z, expected_panels[panel_name].z, 0.01)

	assert_gt(_flat_distance_xz((_store.get_node("RegisterSignPanel") as CSGBox3D).global_position, (_store.get_node("GameDisplayRack") as Node3D).global_position), 6.0)
	assert_gt(_flat_distance_xz((_store.get_node("ReceivingSignPanel") as CSGBox3D).global_position, (_store.get_node("ReceivingBox") as Node3D).global_position), 1.8)
	assert_lt(_flat_distance_xz((_store.get_node("ReceivingSignPanel") as CSGBox3D).global_position, (_store.get_node("ReceivingBox") as Node3D).global_position), 2.2)


func test_panel_backed_labels_are_depth_safe_from_oblique_angles() -> void:
	var label_paths := [
		"RightWallUsedPosterPanel/RightWallUsedPosterLabel",
		"RightWallControllerPosterPanel/RightWallControllerPosterLabel",
		"StoreIdentitySignPanel/StoreIdentitySignLabel",
		"OpenSignPanel/OpenSignLabel",
		"HoursDecalPanel/HoursDecalLabel",
		"DisplaySignPanel/DisplaySignLabel",
		"RegisterSignPanel/RegisterSignLabel",
		"BackroomSignPanel/BackroomSignLabel",
		"EmployeesOnlySignPanel/EmployeesOnlySignLabel",
		"BackWallFeatureStripe/BackWallFeatureLabel",
		"ReceivingSignPanel/ReceivingSignLabel",
		"StorageSignPanel/StorageSignLabel",
		"OfficeSignPanel/OfficeSignLabel",
		"ServiceSignPanel/ServiceSignLabel",
		"NewReleaseEndcap/EndcapHeaderPanel/EndcapHeaderLabel",
		"StaffPicksStand/StaffPicksHeaderPanel/StaffPicksHeaderLabel",
		"WeeklyPicksPosterPanel/WeeklyPicksPosterLabel",
		"NewThisWeekPosterPanel/NewThisWeekPosterLabel",
		"NewThisWeekPosterPanel/NewThisWeekPosterSubLabel",
		"ComingSoonPosterPanel/ComingSoonPosterLabel",
		"ComingSoonPosterPanel/ComingSoonPosterDateLabel",
		"TradeBonusPosterPanel/TradeBonusPosterLabel",
		"TradeBonusPosterPanel/TradeBonusPosterSubLabel",
		"WeeklyPicksPosterPanel/WeeklyPicksPosterSubLabel",
		"CounterDealTagPanel/CounterDealTagLabel",
		"BargainBin/BinFrontTag/BinFrontLabel",
		"AccessoryPegWall/PegWallHeaderPanel/PegWallHeaderLabel",
		"LockedCasePlaceholder/LockedCaseHeaderPanel/LockedCaseHeaderLabel",
		"BackroomDeliveryDoor/DeliveryDoorLabel",
		"ReceivingInvoiceClipboard/ReceivingInvoiceLabel",
		"BackstockOverflowLabelPanel/BackstockOverflowLabel",
		"BackroomStorageShelf/BackstockUsedGamesLabelPanel/BackstockUsedGamesLabel",
		"BackroomStorageShelf/BackstockAccessoryLabelPanel/BackstockAccessoryLabel",
		"BackroomStorageShelf/BackstockHardwareLabelPanel/BackstockHardwareLabel",
		"BackstockPullStageLabelPanel/BackstockPullStageLabel",
		"ManagementBoardLabelPanel/ManagementBoardLabel",
		"BackroomServiceBench/ServiceTicketPanel/ServiceTicketLabel",
		"BackroomSafePlaceholder/SafeLabelPanel/SafeLabel",
		"SecurityMonitorPanel/SecurityMonitorLabel",
		"SuspiciousGoodsTagPanel/SuspiciousGoodsTagLabel",
		"RecordsFileLabelPanel/RecordsFileLabel",
		"ReceivingBox/IntakeTagPanel/IntakeTagLabel",
		"GameDisplayRack/CategoryHeaderPanel/CategoryHeaderLabel",
	]

	for label_path in label_paths:
		var label := _store.get_node_or_null(label_path) as Label3D
		assert_not_null(label, label_path)
		assert_true(label.no_depth_test, label_path)


func test_screenshot_facing_world_labels_use_staff_side_orientation() -> void:
	var label_paths := [
		"StoreIdentitySignPanel/StoreIdentitySignLabel",
		"RegisterSignPanel/RegisterSignLabel",
		"BackWallFeatureStripe/BackWallFeatureLabel",
		"NewThisWeekPosterPanel/NewThisWeekPosterLabel",
		"NewThisWeekPosterPanel/NewThisWeekPosterSubLabel",
		"ComingSoonPosterPanel/ComingSoonPosterLabel",
		"ComingSoonPosterPanel/ComingSoonPosterDateLabel",
		"TradeBonusPosterPanel/TradeBonusPosterLabel",
		"TradeBonusPosterPanel/TradeBonusPosterSubLabel",
		"CounterDealTagPanel/CounterDealTagLabel",
		"LockedCasePlaceholder/LockedCaseHeaderPanel/LockedCaseHeaderLabel",
		"WindowDisplayPosterPanel/WindowDisplayPosterLabel",
		"TradeServiceDecalPanel/TradeServiceDecalLabel",
		"ShelfFacingDensityBand/ShelfFacingDensityLabel",
	]

	for label_path in label_paths:
		var label := _store.get_node_or_null(label_path) as Label3D
		assert_not_null(label, label_path)
		assert_eq(label.billboard, 0, label_path)
		assert_false(label.double_sided, label_path)
		assert_lte(label.transform.basis.x.x, -0.9, label_path)
		assert_lte(label.transform.basis.z.z, -0.9, label_path)


func test_stockroom_staff_boundary_reads_as_employees_only() -> void:
	var label := _store.get_node_or_null("EmployeesOnlySignPanel/EmployeesOnlySignLabel") as Label3D
	assert_not_null(label)
	assert_eq(label.text, "EMPLOYEES ONLY")
	assert_lte(label.pixel_size, 0.0025)
	assert_true(label.no_depth_test)
	assert_eq(label.billboard, 0)
	assert_false(label.double_sided)
	assert_lte(label.transform.basis.x.x, -0.9)
	assert_lte(label.transform.basis.z.z, -0.9)

	for path in [
		"StaffThresholdMat",
		"StaffDoorFrameLeft",
		"StaffDoorFrameRight",
		"EmployeesOnlySignPanel",
		"StaffThresholdHeaderBeam",
		"StaffThresholdHeaderInset",
		"StaffThresholdLeftReturnWall",
		"StaffThresholdRightReturnWall",
		"StaffThresholdBackroomFloorPanel",
		"StaffThresholdDoorStopLeft",
		"StaffThresholdDoorStopRight",
		"StaffShortHallLeftWall",
		"StaffShortHallRightWall",
		"StaffShortHallCeilingSoffit",
		"StaffDoorJambDepthLeft",
		"StaffDoorJambDepthRight",
		"StaffUtilityFloorInset",
		"StaffThresholdCoolLightBar",
	]:
		var marker := _store.get_node_or_null(path) as CSGBox3D
		assert_not_null(marker, path)
		assert_false(marker.use_collision, path)
		assert_true(_is_inside_store_floorprint(marker.global_position), path)

	var threshold := _store.get_node("StaffThresholdMat") as CSGBox3D
	assert_almost_eq(threshold.global_position.z, 3.34, 0.01)
	assert_gte(threshold.size.x, 2.2)
	assert_lte(threshold.size.z, 0.75)

	var header := _store.get_node("StaffThresholdHeaderBeam") as CSGBox3D
	var floor_panel := _store.get_node("StaffThresholdBackroomFloorPanel") as CSGBox3D
	var left_return := _store.get_node("StaffThresholdLeftReturnWall") as CSGBox3D
	var right_return := _store.get_node("StaffThresholdRightReturnWall") as CSGBox3D
	var hall_left := _store.get_node("StaffShortHallLeftWall") as CSGBox3D
	var hall_right := _store.get_node("StaffShortHallRightWall") as CSGBox3D
	var soffit := _store.get_node("StaffShortHallCeilingSoffit") as CSGBox3D
	assert_gt(header.global_position.y, 1.8)
	assert_gt(floor_panel.global_position.z, threshold.global_position.z)
	assert_gte(floor_panel.size.x, 3.0)
	assert_lt(left_return.global_position.x, (_store.get_node("StaffDoorFrameLeft") as CSGBox3D).global_position.x)
	assert_gt(right_return.global_position.x, (_store.get_node("StaffDoorFrameRight") as CSGBox3D).global_position.x)
	assert_gt(hall_left.size.z, 1.0)
	assert_gt(hall_right.size.z, 1.0)
	assert_gt(soffit.global_position.y, header.global_position.y)
	assert_gt(soffit.global_position.z, threshold.global_position.z)


func test_stockroom_shell_has_office_service_and_carry_route_cues() -> void:
	var expected_labels := {
		"OfficeSignPanel/OfficeSignLabel": "OFFICE",
		"ServiceSignPanel/ServiceSignLabel": "SERVICE",
	}

	for label_path in expected_labels:
		var label := _store.get_node_or_null(label_path) as Label3D
		assert_not_null(label)
		assert_eq(label.text, expected_labels[label_path])
		assert_lte(label.pixel_size, 0.0031)
		assert_true(label.no_depth_test)

	for panel_path in ["OfficeSignPanel", "ServiceSignPanel", "StockroomCarryRoute"]:
		var panel := _store.get_node_or_null(panel_path) as CSGBox3D
		assert_not_null(panel, panel_path)
		assert_false(panel.use_collision, panel_path)
		assert_true(_is_inside_store_floorprint(panel.global_position), panel_path)

	var carry_route := _store.get_node("StockroomCarryRoute") as CSGBox3D
	assert_gte(carry_route.size.x, 8.0)
	assert_lt(_flat_distance_xz(carry_route.global_position, (_store.get_node("ReceivingBox") as Node3D).global_position), 3.8)
	assert_lt(_flat_distance_xz(carry_route.global_position, (_store.get_node("BackroomStorageShelf") as Node3D).global_position), 4.8)


func test_alpha_wall_detail_breaks_up_blank_graybox_planes() -> void:
	var expected_labels := {
		"RightWallUsedPosterPanel/RightWallUsedPosterLabel": "USED",
		"RightWallControllerPosterPanel/RightWallControllerPosterLabel": "PADS",
		"BackWallFeatureStripe/BackWallFeatureLabel": "BUY  SELL  REPAIR",
	}

	for label_path in expected_labels:
		var label := _store.get_node_or_null(label_path) as Label3D
		assert_not_null(label)
		assert_eq(label.text, expected_labels[label_path])
		assert_lte(label.pixel_size, 0.0027)

	for panel_path in [
		"RightWallMerchBand",
		"RightWallUsedPosterPanel",
		"RightWallControllerPosterPanel",
		"BackWallFeatureStripe",
		"RightWallUsedPosterCaseA",
		"RightWallUsedPosterCaseB",
		"RightWallControllerPosterPadA",
		"RightWallControllerPosterPadB",
	]:
		var panel := _store.get_node_or_null(panel_path) as CSGBox3D
		assert_not_null(panel)
		assert_false(panel.use_collision)
		assert_true(_is_inside_store_floorprint(panel.global_position))

	assert_gt((_store.get_node("RightWallMerchBand") as CSGBox3D).global_position.x, 6.7)
	assert_gt((_store.get_node("BackWallFeatureStripe") as CSGBox3D).global_position.z, 5.7)


func test_retail_clutter_uses_short_fictional_callouts() -> void:
	var expected_labels := {
		"WeeklyPicksPosterPanel/WeeklyPicksPosterLabel": "SALE",
		"WeeklyPicksPosterPanel/WeeklyPicksPosterSubLabel": "NOW ON SALE",
		"NewThisWeekPosterPanel/NewThisWeekPosterLabel": "NEW",
		"NewThisWeekPosterPanel/NewThisWeekPosterSubLabel": "THIS WEEK",
		"ComingSoonPosterPanel/ComingSoonPosterLabel": "COMING SOON",
		"TradeBonusPosterPanel/TradeBonusPosterLabel": "TRADE",
		"TradeBonusPosterPanel/TradeBonusPosterSubLabel": "BONUS",
		"CounterDealTagPanel/CounterDealTagLabel": "$9+ USED",
		"BargainBin/BinFrontTag/BinFrontLabel": "BARGAIN BIN",
	}

	for label_path in expected_labels:
		var label := _store.get_node_or_null(label_path) as Label3D
		assert_not_null(label)
		assert_eq(label.text, expected_labels[label_path])
		assert_lte(label.text.length(), 13)
		assert_lte(label.pixel_size, 0.0039)


func test_store_identity_data_keeps_games4u_editable() -> void:
	var text := FileAccess.get_file_as_string("res://data/store_identity/default_store_identity.json")
	assert_false(text.is_empty())
	var parsed = JSON.parse_string(text)
	assert_true(parsed is Dictionary)
	var identity := parsed as Dictionary
	assert_eq(identity.get("store_display_name"), "Games4U")
	assert_true(bool(identity.get("editable")))
	assert_true((identity.get("default_shelf_labels") as Array).has("Potpourri"))
	assert_true((identity.get("poster_templates") as Array).has("upcoming_releases"))


func test_packet_six_signage_uses_attached_retail_detail_not_debug_cards() -> void:
	var retail_props := [
		"OpenSignHangerTop",
		"OpenSignHangerLeft",
		"OpenSignHangerRight",
		"NewThisWeekPosterPanel/NewThisWeekPosterCaseIconA",
		"NewThisWeekPosterPanel/NewThisWeekPosterCaseIconB",
		"ComingSoonPosterPanel",
		"ComingSoonPosterPanel/ComingSoonPosterSilhouette",
		"TradeBonusPosterPanel/TradeBonusPosterTicketA",
		"TradeBonusPosterPanel/TradeBonusPosterTicketB",
		"WeeklyPicksPosterPanel/WeeklyPicksPosterAccent",
	]
	for prop_path in retail_props:
		var prop := _store.get_node_or_null(prop_path) as CSGBox3D
		assert_not_null(prop, prop_path)
		assert_false(prop.use_collision, prop_path)

	assert_eq((_store.get_node("GameDisplayRack/CategoryHeaderPanel/CategoryHeaderLabel") as Label3D).text, "Potpourri")
	assert_eq((_store.get_node("ShelfFacingDensityBand/ShelfFacingDensityLabel") as Label3D).text, "Potpourri")


func test_retail_clutter_is_nonblocking_and_away_from_interaction_hotspots() -> void:
	var clutter_boxes := [
		"WeeklyPicksPosterPanel",
		"NewThisWeekPosterPanel",
		"ComingSoonPosterPanel",
		"TradeBonusPosterPanel",
		"CounterDealTagPanel",
		"RegisterQueueMat",
		"BargainBin/BinBase",
		"BargainBin/BinFrontTag",
		"BargainBin/BinGameStackA",
		"BargainBin/BinGameStackB",
		"ControllerDisplayStand/StandBase",
		"ControllerDisplayStand/ControllerPadA",
		"ControllerDisplayStand/ControllerPadB",
	]
	var register := _store.get_node("RegisterWorkstation") as Node3D
	var rack := _store.get_node("GameDisplayRack") as Node3D

	for box_path in clutter_boxes:
		var box := _store.get_node_or_null(box_path) as CSGBox3D
		assert_not_null(box)
		assert_false(box.use_collision)
		assert_true(_is_inside_store_floorprint(box.global_position))

	assert_gt(_flat_distance_xz((_store.get_node("BargainBin") as Node3D).global_position, register.global_position), 4.0)
	assert_gt(_flat_distance_xz((_store.get_node("ControllerDisplayStand") as Node3D).global_position, rack.global_position), 3.0)
	assert_lte((_store.get_node("RegisterQueueMat") as CSGBox3D).size.y, 0.0121)


func test_register_counter_has_command_center_props() -> void:
	var register := _store.get_node("RegisterWorkstation") as Node3D
	var command_props := [
		"RegisterScanner",
		"ScannerBeamCue",
		"CardReader",
		"CardReaderScreen",
		"ReceiptPrinter",
		"ReceiptSlip",
		"SaleScanPad",
		"SleeveStack",
		"RegisterCounterWorkRail",
		"CustomerCounterMat",
		"CustomerApproachMarker",
		"RegisterModeCueRail",
		"RegisterModeSaleCue",
		"RegisterModeReturnCue",
		"RegisterModeTradeCue",
		"RegisterModePreorderCue",
		"RegisterModeServiceCue",
		"CounterImpulseRack/ImpulseRackBase",
		"CounterImpulseRack/ImpulseCaseA",
		"CounterImpulseRack/ImpulseCaseB",
		"CounterImpulseRack/ImpulseCaseC",
	]

	for prop_path in command_props:
		var prop := _store.get_node_or_null(prop_path) as CSGBox3D
		assert_not_null(prop)
		assert_false(prop.use_collision, prop_path)
		assert_lt(_flat_distance_xz(prop.global_position, register.global_position), 1.65)

	var impulse_rack := _store.get_node_or_null("CounterImpulseRack") as Node3D
	assert_not_null(impulse_rack)
	assert_lt(_flat_distance_xz(impulse_rack.global_position, register.global_position), 1.45)
	assert_lte((_store.get_node("CustomerCounterMat") as CSGBox3D).size.y, 0.0121)
	assert_lte((_store.get_node("CustomerApproachMarker") as CSGBox3D).size.y, 0.015)
	assert_gt((_store.get_node("ReceiptSlip") as CSGBox3D).global_position.y, 1.2)
	assert_gt((_store.get_node("SleeveStack") as CSGBox3D).global_position.x, register.global_position.x)
	assert_eq((_store.get_node("CardReader/CardReaderLabel") as Label3D).text, "PAY")
	assert_eq((_store.get_node("ReceiptSlip/ReceiptSlipLabel") as Label3D).text, "RECEIPT")
	assert_eq((_store.get_node("SaleScanPad/SaleScanPadLabel") as Label3D).text, "SALE")
	assert_eq((_store.get_node("SleeveStack/SleeveStackLabel") as Label3D).text, "BAGS")


func test_checkout_counter_reads_as_clean_trade_in_workstation() -> void:
	var register := _store.get_node("RegisterWorkstation") as Node3D
	var counter_top := _store.get_node("CounterTop") as CSGBox3D

	for edge_path in [
		"CounterTopFrontLaminateEdge",
		"CounterTopBackLaminateEdge",
		"CounterLeftLaminateEdge",
		"CounterRightLaminateEdge",
		"CounterCustomerKickPanel",
	]:
		var edge := _store.get_node_or_null(edge_path) as CSGBox3D
		assert_not_null(edge, edge_path)
		assert_false(edge.use_collision, edge_path)
		assert_true(_is_inside_store_floorprint(edge.global_position), edge_path)

	assert_gt((_store.get_node("CounterTopFrontLaminateEdge") as CSGBox3D).global_position.y, counter_top.global_position.y)
	assert_gt((_store.get_node("CounterTopBackLaminateEdge") as CSGBox3D).global_position.y, counter_top.global_position.y)
	assert_lt((_store.get_node("CounterTopFrontLaminateEdge") as CSGBox3D).global_position.z, register.global_position.z)
	assert_gt((_store.get_node("CounterTopBackLaminateEdge") as CSGBox3D).global_position.z, register.global_position.z)

	for intake_path in [
		"TradeInInspectionTrayFrontLip",
		"TradeInInspectionItemCue",
		"BehindCounterIntakeShelf",
		"BehindCounterTradeInCaseCue",
		"BehindCounterHoldConsoleBox",
		"BehindCounterHoldTag",
	]:
		var prop := _store.get_node_or_null(intake_path) as CSGBox3D
		assert_not_null(prop, intake_path)
		assert_false(prop.use_collision, intake_path)
		assert_lt(_flat_distance_xz(prop.global_position, register.global_position), 1.35, intake_path)

	assert_gt((_store.get_node("BehindCounterIntakeShelf") as CSGBox3D).global_position.z, register.global_position.z)
	assert_gt((_store.get_node("BehindCounterHoldConsoleBox") as CSGBox3D).global_position.z, register.global_position.z)
	assert_gt((_store.get_node("TradeInInspectionItemCue") as CSGBox3D).global_position.y, 1.3)


func test_backroom_visual_zones_exist_without_collision() -> void:
	var expected_zones := {
		"BackroomReceivingZone": Vector3(-4.65, 0.028, 3.82),
		"BackroomStorageZone": Vector3(-2.75, 0.03, 5.55),
		"BackroomManagementZone": Vector3(4.6, 0.032, 4.28),
		"BackroomServiceZone": Vector3(2.05, 0.034, 5.45),
		"BackroomPathZone": Vector3(-0.45, 0.04, 4.45),
	}

	for zone_name in expected_zones:
		var zone := _store.get_node_or_null(zone_name) as CSGBox3D
		assert_not_null(zone)
		assert_false(zone.use_collision)
		assert_lte(zone.size.y, 0.015)
		assert_almost_eq(zone.global_position.x, expected_zones[zone_name].x, 0.01)
		assert_almost_eq(zone.global_position.z, expected_zones[zone_name].z, 0.01)


func test_backroom_receiving_and_storage_props_exist() -> void:
	var receiving_props := [
		"ReceivingPallet",
		"ReceivingIntakeTableTop",
		"ReceivingIntakeTableLegA",
		"ReceivingIntakeTableLegB",
		"ReceivingBoxStackA",
		"ReceivingBoxStackALabel",
		"ReceivingBoxStackATapeA",
		"ReceivingBoxStackATapeB",
		"ReceivingBoxStackB",
		"ReceivingStagedCartBase",
		"ReceivingStagedCartHandle",
		"BackroomDeliveryDoor",
		"DeliveryDoorSlatA",
		"DeliveryDoorSlatB",
		"ReceivingInvoiceClipboard",
		"ReceivingInvoicePaper",
		"ReceivingSortedTray",
		"ReceivingSortedTrayLaneA",
		"ReceivingSortedTrayLaneB",
		"ReceivingSortedTrayLaneC",
		"ReceivingWorkflowCardDelivery",
		"ReceivingWorkflowCardCheck",
		"ReceivingWorkflowCardSort",
	]
	for prop_path in receiving_props:
		var prop := _store.get_node_or_null(prop_path) as CSGBox3D
		assert_not_null(prop)
		assert_false(prop.use_collision)
		assert_lt(_flat_distance_xz(prop.global_position, _store.get_node("ReceivingBox").global_position), 2.25)

	for wheel_path in ["ReceivingStagedCartWheelA", "ReceivingStagedCartWheelB"]:
		var wheel := _store.get_node_or_null(wheel_path) as CSGCylinder3D
		assert_not_null(wheel, wheel_path)
		assert_false(wheel.use_collision, wheel_path)
		assert_lt(_flat_distance_xz(wheel.global_position, _store.get_node("ReceivingBox").global_position), 1.7)

	var storage_shelf := _store.get_node_or_null("BackroomStorageShelf") as Node3D
	assert_not_null(storage_shelf)
	assert_not_null(storage_shelf.get_node_or_null("LowerShelf"))
	assert_not_null(storage_shelf.get_node_or_null("UpperShelf"))
	assert_not_null(storage_shelf.get_node_or_null("TopShelf"))
	assert_not_null(storage_shelf.get_node_or_null("StorageBoxA"))
	assert_not_null(storage_shelf.get_node_or_null("StorageBoxB"))
	assert_not_null(storage_shelf.get_node_or_null("StorageBinUsedGames"))
	assert_not_null(storage_shelf.get_node_or_null("StorageBinAccessories"))
	assert_not_null(storage_shelf.get_node_or_null("StorageBinHardware"))
	assert_not_null(_store.get_node_or_null("BackstockOverflowCrateA"))
	assert_not_null(_store.get_node_or_null("BackstockOverflowCrateB"))
	assert_not_null(_store.get_node_or_null("BackstockOverflowShelf"))
	assert_not_null(_store.get_node_or_null("BackstockOverflowLabelPanel/BackstockOverflowLabel"))
	assert_lt(storage_shelf.global_position.x, _store.get_node("ReceivingBox").global_position.x)
	assert_gt(storage_shelf.global_position.z, 5.0)


func test_backstock_shelving_has_category_lanes_and_bins() -> void:
	var storage_shelf := _store.get_node("BackroomStorageShelf") as Node3D
	var expected_labels := {
		"BackstockUsedGamesLabelPanel/BackstockUsedGamesLabel": "USED",
		"BackstockAccessoryLabelPanel/BackstockAccessoryLabel": "ACCESS",
		"BackstockHardwareLabelPanel/BackstockHardwareLabel": "HW",
	}

	for label_path in expected_labels:
		var label := storage_shelf.get_node_or_null(label_path) as Label3D
		assert_not_null(label)
		assert_eq(label.text, expected_labels[label_path])
		assert_true(label.no_depth_test)
		assert_eq(label.billboard, BaseMaterial3D.BILLBOARD_ENABLED)
		assert_lte(label.pixel_size, 0.0027)

	for divider_path in ["StorageLaneDividerA", "StorageLaneDividerB"]:
		var divider := storage_shelf.get_node_or_null(divider_path) as CSGBox3D
		assert_not_null(divider)
		assert_false(divider.use_collision)
		assert_gt(divider.size.y, 0.7)

	for bin_path in ["StorageBinUsedGames", "StorageBinAccessories", "StorageBinHardware"]:
		var bin := storage_shelf.get_node_or_null(bin_path) as CSGBox3D
		assert_not_null(bin)
		assert_false(bin.use_collision)
		assert_gt(bin.global_position.y, 0.5)
		assert_lt(absf(bin.position.x), 0.7)


func test_backstock_pull_stage_connects_storage_to_carry_route() -> void:
	var receiving_box := _store.get_node("ReceivingBox") as Node3D
	var storage_shelf := _store.get_node("BackroomStorageShelf") as Node3D
	var carry_route := _store.get_node("StockroomCarryRoute") as CSGBox3D
	var pull_stage := _store.get_node_or_null("BackstockPullStageSurface") as CSGBox3D
	var pull_slip := _store.get_node_or_null("BackstockPullStageSlip") as CSGBox3D
	var pull_label := _store.get_node_or_null("BackstockPullStageLabelPanel/BackstockPullStageLabel") as Label3D
	var overflow_shelf := _store.get_node_or_null("BackstockOverflowShelf") as CSGBox3D
	var receiving_arrow := _store.get_node_or_null("ReceivingWorkflowArrowToPull") as CSGBox3D
	var shelf_arrow := _store.get_node_or_null("BackstockWorkflowArrowToShelf") as CSGBox3D

	assert_not_null(pull_stage)
	assert_not_null(pull_slip)
	assert_not_null(pull_label)
	assert_not_null(overflow_shelf)
	assert_not_null(receiving_arrow)
	assert_not_null(shelf_arrow)
	assert_false(pull_stage.use_collision)
	assert_false(pull_slip.use_collision)
	assert_false(overflow_shelf.use_collision)
	assert_false(receiving_arrow.use_collision)
	assert_false(shelf_arrow.use_collision)
	assert_eq(pull_label.text, "PULL")
	assert_true(pull_label.no_depth_test)
	assert_eq(pull_label.billboard, BaseMaterial3D.BILLBOARD_ENABLED)
	assert_lt(_flat_distance_xz(pull_stage.global_position, storage_shelf.global_position), 2.1)
	assert_lt(_flat_distance_xz(pull_stage.global_position, receiving_box.global_position), 1.5)
	assert_lt(_flat_distance_xz(pull_stage.global_position, carry_route.global_position), 3.0)
	assert_lt(_flat_distance_xz(receiving_arrow.global_position, receiving_box.global_position), 1.8)
	assert_lt(_flat_distance_xz(shelf_arrow.global_position, storage_shelf.global_position), 2.0)
	assert_gt(pull_stage.global_position.y, 0.35)


func test_receiving_intake_station_reads_as_workflow_surface() -> void:
	var receiving_box := _store.get_node("ReceivingBox") as Node3D
	var intake_table := _store.get_node_or_null("ReceivingIntakeTableTop") as CSGBox3D
	var sorted_tray := _store.get_node_or_null("ReceivingSortedTray") as CSGBox3D
	var sorted_label := _store.get_node_or_null("ReceivingSortedTrayLabelPanel/ReceivingSortedTrayLabel") as Label3D
	var staged_cart := _store.get_node_or_null("ReceivingStagedCartBase") as CSGBox3D
	var carton_tape_a := _store.get_node_or_null("ReceivingBoxStackATapeA") as CSGBox3D
	var carton_tape_b := _store.get_node_or_null("ReceivingBoxStackATapeB") as CSGBox3D
	var workflow_cards := [
		"ReceivingWorkflowCardDelivery",
		"ReceivingWorkflowCardCheck",
		"ReceivingWorkflowCardSort",
	]

	assert_not_null(intake_table)
	assert_not_null(sorted_tray)
	assert_not_null(sorted_label)
	assert_not_null(staged_cart)
	assert_not_null(carton_tape_a)
	assert_not_null(carton_tape_b)
	assert_false(intake_table.use_collision)
	assert_false(sorted_tray.use_collision)
	assert_false(staged_cart.use_collision)
	assert_false(carton_tape_a.use_collision)
	assert_false(carton_tape_b.use_collision)
	assert_eq(sorted_label.text, "SORTED")
	assert_true(sorted_label.no_depth_test)
	assert_eq(sorted_label.billboard, BaseMaterial3D.BILLBOARD_ENABLED)
	assert_lt(_flat_distance_xz(intake_table.global_position, receiving_box.global_position), 0.9)
	assert_lt(_flat_distance_xz(sorted_tray.global_position, receiving_box.global_position), 1.1)
	assert_lt(_flat_distance_xz(staged_cart.global_position, receiving_box.global_position), 0.85)
	assert_gt(sorted_tray.global_position.y, receiving_box.global_position.y + 0.35)
	assert_gt(carton_tape_a.global_position.y, (_store.get_node("ReceivingBoxStackA") as CSGBox3D).global_position.y)
	assert_gt(carton_tape_b.global_position.y, (_store.get_node("ReceivingBoxStackA") as CSGBox3D).global_position.y)
	for card_path in workflow_cards:
		var card := _store.get_node_or_null(card_path) as CSGBox3D
		assert_not_null(card)
		assert_false(card.use_collision)
		assert_lt(_flat_distance_xz(card.global_position, receiving_box.global_position), 1.8)
		assert_gt(card.global_position.y, 0.65)

	for item_name in ["PlaceholderUsedGame", "PlaceholderUsedGame002", "PlaceholderUsedGame003"]:
		var item := receiving_box.get_node(item_name) as Node3D
		assert_eq(item.get("location_id"), "receiving_box_001")
		assert_gt(item.global_position.y, receiving_box.global_position.y + 0.18)


func test_backroom_management_and_service_props_exist() -> void:
	var management_props := [
		"BackroomManagementBoard",
		"ManagementBoardLabelPanel",
		"ManagementReportCardA",
		"ManagementReportCardB",
		"ManagementDeskPad",
		"ManagementKeyboard",
		"ManagementTaskCard",
		"ManagerOfficeRug",
		"ManagerChairSeat",
		"ManagerChairBack",
		"ManagerChairLegA",
		"ManagerChairLegB",
		"OfficeFileBoxA",
		"OfficeFileBoxB",
		"OfficeSupplierNote",
		"OfficeBillStack",
		"OfficeCalendarCard",
		"OfficeRecordsShelf",
		"OfficeTaskLampBase",
		"OfficeTaskLampArm",
		"OfficeTaskLampShade",
		"ManagementComputerTaskRail",
		"ManagementTabDashboard",
		"ManagementTabOrders",
		"ManagementTabReleases",
	]
	for prop_path in management_props:
		var prop := _store.get_node_or_null(prop_path) as CSGBox3D
		assert_not_null(prop)
		assert_false(prop.use_collision)
		assert_gt(prop.global_position.x, 4.0)
		assert_gt(prop.global_position.z, 3.8)

	var service_bench := _store.get_node_or_null("BackroomServiceBench") as Node3D
	assert_not_null(service_bench)
	assert_not_null(service_bench.get_node_or_null("ServiceMat"))
	assert_not_null(service_bench.get_node_or_null("ServiceDisc"))
	assert_not_null(service_bench.get_node_or_null("PaperworkStack"))
	assert_not_null(service_bench.get_node_or_null("ToolTray"))
	assert_not_null(service_bench.get_node_or_null("ServicePartsBin"))
	assert_not_null(service_bench.get_node_or_null("ServiceReadyShelf"))
	assert_not_null(service_bench.get_node_or_null("ServiceReadyTicket"))
	assert_not_null(service_bench.get_node_or_null("ServiceTicketPanel"))
	assert_eq((service_bench.get_node("ServiceTicketPanel/ServiceTicketLabel") as Label3D).text, "SERVICE")
	assert_gt(service_bench.global_position.z, 5.0)
	assert_gt(_flat_distance_xz(service_bench.global_position, _store.get_node("RegisterWorkstation").global_position), 7.0)


func test_service_bench_has_ready_parts_and_ticket_workflow_cues() -> void:
	var service_bench := _store.get_node("BackroomServiceBench") as Node3D
	var parts_bin := service_bench.get_node_or_null("ServicePartsBin") as CSGBox3D
	var ready_shelf := service_bench.get_node_or_null("ServiceReadyShelf") as CSGBox3D
	var ready_ticket := service_bench.get_node_or_null("ServiceReadyTicket") as CSGBox3D
	var service_ticket := service_bench.get_node_or_null("ServiceTicketPanel") as CSGBox3D
	var service_label := service_bench.get_node_or_null("ServiceTicketPanel/ServiceTicketLabel") as Label3D

	for cue in [parts_bin, ready_shelf, ready_ticket, service_ticket]:
		assert_not_null(cue)
		assert_false(cue.use_collision)
		assert_gt(cue.global_position.y, service_bench.global_position.y + 0.6)

	assert_not_null(service_label)
	assert_eq(service_label.text, "SERVICE")
	assert_true(service_label.no_depth_test)
	assert_lt(_flat_distance_xz(ready_shelf.global_position, service_ticket.global_position), 0.45)
	assert_lt(_flat_distance_xz(parts_bin.global_position, _store.get_node("BackroomComputer").global_position), 4.1)


func test_manager_office_frames_backroom_computer_without_register_actions() -> void:
	var computer := _store.get_node("BackroomComputer") as Node3D
	var office_rug := _store.get_node_or_null("ManagerOfficeRug") as CSGBox3D
	var chair := _store.get_node_or_null("ManagerChairSeat") as CSGBox3D
	var file_box := _store.get_node_or_null("OfficeFileBoxA") as CSGBox3D
	var supplier_note := _store.get_node_or_null("OfficeSupplierNote") as CSGBox3D
	var bill_stack := _store.get_node_or_null("OfficeBillStack") as CSGBox3D
	var calendar := _store.get_node_or_null("OfficeCalendarCard") as CSGBox3D
	var records_shelf := _store.get_node_or_null("OfficeRecordsShelf") as CSGBox3D
	var task_lamp := _store.get_node_or_null("OfficeTaskLampShade") as CSGBox3D
	var task_rail := _store.get_node_or_null("ManagementComputerTaskRail") as CSGBox3D
	var board_label := _store.get_node_or_null("ManagementBoardLabelPanel/ManagementBoardLabel") as Label3D
	var task_labels := {
		"ManagementTabDashboard/ManagementTabDashboardLabel": "DASH",
		"ManagementTabOrders/ManagementTabOrdersLabel": "ORD",
		"ManagementTabReleases/ManagementTabReleasesLabel": "REL",
	}

	assert_not_null(office_rug)
	assert_not_null(chair)
	assert_not_null(file_box)
	assert_not_null(supplier_note)
	assert_not_null(bill_stack)
	assert_not_null(calendar)
	assert_not_null(records_shelf)
	assert_not_null(task_lamp)
	assert_not_null(task_rail)
	assert_not_null(board_label)
	assert_eq(board_label.text, "PLAN")
	assert_true(board_label.no_depth_test)
	assert_eq(board_label.billboard, BaseMaterial3D.BILLBOARD_ENABLED)

	for cue in [office_rug, chair, file_box, supplier_note, bill_stack, calendar, records_shelf, task_lamp, task_rail]:
		assert_false(cue.use_collision)
		assert_lt(_flat_distance_xz(cue.global_position, computer.global_position), 1.55)
		assert_true(_is_inside_store_floorprint(cue.global_position))

	for label_path in task_labels:
		var task_label := _store.get_node_or_null(label_path) as Label3D
		assert_not_null(task_label)
		assert_eq(task_label.text, task_labels[label_path])
		assert_true(task_label.no_depth_test)
		assert_eq(task_label.billboard, BaseMaterial3D.BILLBOARD_ENABLED)

	assert_gt(_flat_distance_xz(computer.global_position, _store.get_node("RegisterWorkstation").global_position), 7.0)
	assert_gt(computer.global_position.x, 4.0)
	assert_gt(computer.global_position.z, 4.0)


func test_backroom_production_blockout_has_security_and_paperwork_cues() -> void:
	var expected_labels := {
		"BackroomDeliveryDoor/DeliveryDoorLabel": "DROP",
		"ReceivingInvoiceClipboard/ReceivingInvoiceLabel": "INVOICE",
		"BackstockOverflowLabelPanel/BackstockOverflowLabel": "BACKSTOCK",
		"BackroomSafePlaceholder/SafeLabelPanel/SafeLabel": "SAFE",
		"SecurityMonitorPanel/SecurityMonitorLabel": "SECURITY",
		"SuspiciousGoodsTagPanel/SuspiciousGoodsTagLabel": "HOLD",
		"RecordsFileLabelPanel/RecordsFileLabel": "FILES",
	}
	for label_path in expected_labels:
		var label := _store.get_node_or_null(label_path) as Label3D
		assert_not_null(label)
		assert_eq(label.text, expected_labels[label_path])

	var safe := _store.get_node_or_null("BackroomSafePlaceholder") as Node3D
	var security_monitor := _store.get_node_or_null("SecurityMonitorPanel") as CSGBox3D
	var evidence_locker := _store.get_node_or_null("EvidenceLockerPlaceholder") as CSGBox3D
	var high_value_shelf := _store.get_node_or_null("HighValueShelf") as CSGBox3D
	var suspicious_tray := _store.get_node_or_null("SuspiciousGoodsIsolationTray") as CSGBox3D
	var records_box := _store.get_node_or_null("RecordsFileBox") as CSGBox3D
	assert_not_null(safe)
	assert_not_null(security_monitor)
	assert_not_null(evidence_locker)
	assert_not_null(high_value_shelf)
	assert_not_null(suspicious_tray)
	assert_not_null(records_box)
	assert_true(_is_inside_store_floorprint(safe.global_position))
	assert_true(_is_inside_store_floorprint(security_monitor.global_position))
	assert_true(_is_inside_store_floorprint(evidence_locker.global_position))
	assert_true(_is_inside_store_floorprint(high_value_shelf.global_position))
	assert_true(_is_inside_store_floorprint(suspicious_tray.global_position))
	assert_true(_is_inside_store_floorprint(records_box.global_position))
	assert_gt(safe.global_position.x, 5.5)
	assert_gt(security_monitor.global_position.x, 5.0)
	assert_gt(evidence_locker.global_position.z, 4.0)
	assert_lt(_flat_distance_xz(high_value_shelf.global_position, safe.global_position), 0.7)
	assert_lt(_flat_distance_xz(suspicious_tray.global_position, evidence_locker.global_position), 0.8)

	for cue_path in [
		"BackroomSafePlaceholder/SafeBody",
		"BackroomSafePlaceholder/SafeDoorPanel",
		"BackroomSafePlaceholder/SafeHandle",
		"BackroomSafePlaceholder/SafeLabelPanel",
		"SecurityMonitorPanel",
		"SecurityMonitorScreen",
		"EvidenceLockerPlaceholder",
		"HighValueShelf",
		"HighValueCaseA",
		"HighValueCaseB",
		"SuspiciousGoodsIsolationTray",
		"SuspiciousGoodsTagPanel",
		"RecordsFileBox",
		"RecordsFileLabelPanel",
	]:
		var cue := _store.get_node_or_null(cue_path) as CSGBox3D
		assert_not_null(cue)
		assert_false(cue.use_collision)


func test_production_environment_props_preserve_core_navigation_clearance() -> void:
	var decorative_csg_paths := [
		"StorefrontGlassLeft",
		"StorefrontGlassRight",
		"EntrySidewalkCue",
		"CommercialCarpetFleckA",
		"CommercialCarpetFleckB",
		"CommercialCarpetFleckC",
		"CommercialCarpetFleckD",
		"CommercialCarpetFleckE",
		"CommercialCarpetFleckF",
		"SalesWallColorPanelBackLeft",
		"SalesWallColorPanelBackRight",
		"SalesWallColorPanelLeftFront",
		"SalesWallColorPanelRightFront",
		"SalesFloorRouteMat",
		"NewReleaseEndcap/EndcapBase",
		"NewReleaseEndcap/EndcapHeaderPanel",
		"StaffPicksStand/StaffPicksBase",
		"AccessoryPegWall/PegWallBackPanel",
		"LockedCasePlaceholder/LockedCaseBase",
		"LockedCasePlaceholder/LockedCaseGlass",
		"RegisterScanner",
		"ScannerBeamCue",
		"CardReader",
		"ReceiptPrinter",
			"SleeveStack",
			"CounterImpulseRack/ImpulseRackBase",
			"CustomerCounterMat",
			"RegisterQueueMat",
			"StockroomRouteTapeA",
			"StockroomRouteTapeB",
			"StockroomRouteTapeC",
			"StockroomCoolLightStripReceiving",
			"StockroomCoolLightStripOffice",
			"BackroomReceivingZone",
			"BackroomStorageZone",
			"BackroomManagementZone",
			"BackroomServiceZone",
			"BackroomPathZone",
			"ReceivingPalletShadow",
			"BackroomDeliveryDoor",
			"ReceivingWallChecklist",
			"ReceivingWallBlueSlip",
			"ReceivingInvoiceClipboard",
			"ReceivingBlueSortSlip",
			"BackstockOverflowCrateA",
			"BackstockOverflowCrateB",
			"BackstockShelfShadow",
			"OfficeWallPlannerCardA",
			"OfficeWallPlannerCardB",
			"ManagementDeskPad",
		"ManagementKeyboard",
		"BackroomServiceBench/ServiceTicketPanel",
		"BackroomSafePlaceholder/SafeBody",
		"SecurityMonitorPanel",
		"EvidenceLockerPlaceholder",
	]
	for prop_path in decorative_csg_paths:
		var prop := _store.get_node_or_null(prop_path) as CSGBox3D
		assert_not_null(prop)
		assert_false(prop.use_collision)

	var player := _store.get_node("PlayerController") as CharacterBody3D
	var rack := _store.get_node("GameDisplayRack") as Node3D
	var register := _store.get_node("RegisterWorkstation") as Node3D
	var receiving_box := _store.get_node("ReceivingBox") as Node3D
	var storage_shelf := _store.get_node("BackroomStorageShelf") as Node3D
	var fixture_manager := _store.get_node("FixturePlacementManager")
	var ghost := fixture_manager.get_node("GhostRackPreview") as Node3D

	assert_lt(player.global_position.z, -10.0)
	assert_gt(_flat_distance_xz(player.global_position, register.global_position), 7.0)
	assert_true((_store.get_node("SecondFloorMallConcourse/MallConcourseFloor") as CSGBox3D).use_collision)
	assert_lt(_flat_distance_xz(register.global_position, rack.global_position), 10.0)
	assert_lt(_flat_distance_xz(rack.global_position, receiving_box.global_position), 2.4)
	assert_lt(_flat_distance_xz(receiving_box.global_position, storage_shelf.global_position), 2.4)
	assert_lte((_store.get_node("BackroomPathZone") as CSGBox3D).size.y, 0.015)
	assert_lte((_store.get_node("RegisterQueueMat") as CSGBox3D).size.y, 0.0121)
	assert_true(_is_inside_store_floorprint(ghost.global_position))
	assert_true(_is_inside_store_floorprint(fixture_manager.get("default_ghost_position")))


func test_production_visual_overhaul_storefront_and_architecture_cues_exist() -> void:
	var storefront_props := [
		"EntryThresholdInteriorStrip",
		"EntryRouteStripeRegister",
		"EntryRouteStripeShelf",
		"StorefrontFacadePierLeft",
		"StorefrontFacadePierRight",
		"StorefrontCenterDoorFrameLeft",
		"StorefrontCenterDoorFrameRight",
		"StorefrontSignTrimTop",
		"StorefrontSignTrimBottom",
		"WindowDisplayConsoleBox",
		"WindowDisplayPlatformStack",
		"WindowDisplayShelfDeck",
		"WindowDisplaySpotlightBar",
		"WindowDisplayControllerA",
		"WindowDisplayControllerB",
		"WindowDisplayCaseA",
		"WindowDisplayCaseB",
		"WindowDisplayPosterPanel",
		"TradeServiceDecalPanel",
	]
	for prop_path in storefront_props:
		var prop := _store.get_node_or_null(prop_path) as CSGBox3D
		assert_not_null(prop)
		assert_false(prop.use_collision, prop_path)
		assert_true(_is_inside_store_floorprint(prop.global_position), prop_path)
		assert_lt(prop.global_position.z, -4.5, prop_path)

	assert_eq((_store.get_node("WindowDisplayPosterPanel/WindowDisplayPosterLabel") as Label3D).text, "USED + NEW")
	assert_eq((_store.get_node("WindowDisplayCaseA/WindowDisplayCaseALabel") as Label3D).text, "USED")
	assert_eq((_store.get_node("WindowDisplayCaseB/WindowDisplayCaseBLabel") as Label3D).text, "SEALED")
	assert_eq((_store.get_node("TradeServiceDecalPanel/TradeServiceDecalLabel") as Label3D).text, "TRADE / SERVICE")
	assert_gt((_store.get_node("StorefrontSignTrimTop") as CSGBox3D).global_position.y, 2.4)
	assert_lt((_store.get_node("WindowDisplayConsoleBox") as CSGBox3D).global_position.y, 0.7)
	assert_lt((_store.get_node("WindowDisplayShelfDeck") as CSGBox3D).global_position.y, 0.5)
	assert_gt((_store.get_node("WindowDisplaySpotlightBar") as CSGBox3D).global_position.y, 1.7)
	assert_gt((_store.get_node("StorefrontFacadePierLeft") as CSGBox3D).size.y, 2.0)
	assert_gt((_store.get_node("StorefrontCenterDoorFrameRight") as CSGBox3D).size.y, 2.0)

	var architecture_props := [
		"SalesBaseboardFront",
		"SalesBaseboardBack",
		"SalesBaseboardLeft",
		"SalesBaseboardRight",
		"SalesChairRailBack",
		"SalesChairRailLeft",
		"SalesChairRailRight",
		"SalesCornerTrimBackLeft",
		"SalesCornerTrimBackRight",
		"SalesCeilingPanelA",
		"SalesCeilingPanelB",
		"SalesCeilingGridLong",
		"SalesCeilingGridCross",
		"FloorTransitionStripSalesBack",
		"EntryRubberMat",
		"RegisterRubberMat",
		"CounterFrontTrim",
	]
	for prop_path in architecture_props:
		var prop := _store.get_node_or_null(prop_path) as CSGBox3D
		assert_not_null(prop)
		assert_false(prop.use_collision, prop_path)
		assert_true(_is_inside_store_floorprint(prop.global_position), prop_path)

	assert_lte((_store.get_node("FloorTransitionStripSalesBack") as CSGBox3D).size.y, 0.0061)
	assert_gt((_store.get_node("SalesCeilingPanelA") as CSGBox3D).global_position.y, 2.6)
	assert_gt((_store.get_node("SalesCeilingPanelB") as CSGBox3D).global_position.y, 2.6)


func test_production_visual_overhaul_product_density_and_transaction_surfaces_exist() -> void:
	var rack := _store.get_node("GameDisplayRack") as Node3D
	var register := _store.get_node("RegisterWorkstation") as Node3D
	var density_props := [
		"ShelfFacingDensityBand",
		"ShelfPriceTagA",
		"ShelfPriceTagB",
		"ShelfPriceTagC",
		"UsedSpineRowTop",
		"UsedSpineRowMiddle",
		"UsedSpineRowBottom",
		"UsedShelfTalkerPanel",
	]
	for prop_path in density_props:
		var prop := _store.get_node_or_null(prop_path) as CSGBox3D
		assert_not_null(prop)
		assert_false(prop.use_collision, prop_path)
		assert_lt(_flat_distance_xz(prop.global_position, rack.global_position), 0.95, prop_path)

	assert_eq((_store.get_node("ShelfFacingDensityBand/ShelfFacingDensityLabel") as Label3D).text, "Potpourri")
	assert_eq((_store.get_node("UsedShelfTalkerPanel/UsedShelfTalkerLabel") as Label3D).text, "TESTED")

	for preorder_path in ["PreorderWallPanel", "PreorderWallHeaderPanel", "PreorderCaseStackA", "PreorderCaseStackB", "PreorderCaseStackC"]:
		var preorder_prop := _store.get_node_or_null(preorder_path) as CSGBox3D
		assert_not_null(preorder_prop)
		assert_false(preorder_prop.use_collision, preorder_path)
		assert_true(_is_inside_store_floorprint(preorder_prop.global_position), preorder_path)
		assert_gt(preorder_prop.global_position.x, 6.5, preorder_path)
	assert_eq((_store.get_node("PreorderWallHeaderPanel/PreorderWallHeaderLabel") as Label3D).text, "PREORDERS")

	var transaction_props := [
		"ReturnReviewTray",
		"TradeInInspectionTray",
		"PreorderSlipStack",
		"ServicePickupMarker",
		"SaleScanPad",
		"RegisterModeCueRail",
		"RegisterModeSaleCue",
		"RegisterModeReturnCue",
		"RegisterModeTradeCue",
		"RegisterModePreorderCue",
		"RegisterModeServiceCue",
		"CashDrawerSlot",
		"CashDrawerPull",
		"PaymentStatusGlowPanel",
		"RegisterWorkflowCard",
	]
	for prop_path in transaction_props:
		var prop := _store.get_node_or_null(prop_path) as CSGBox3D
		assert_not_null(prop)
		assert_false(prop.use_collision, prop_path)
		assert_lt(_flat_distance_xz(prop.global_position, register.global_position), 1.15, prop_path)
		assert_gt(prop.global_position.y, 1.15, prop_path)

	var return_material := (_store.get_node("ReturnReviewTray") as CSGBox3D).material as StandardMaterial3D
	var trade_material := (_store.get_node("TradeInInspectionTray") as CSGBox3D).material as StandardMaterial3D
	assert_not_null(return_material)
	assert_not_null(trade_material)
	assert_gt(return_material.albedo_color.b, trade_material.albedo_color.b)
	assert_eq((_store.get_node("ReturnReviewTray/ReturnReviewTrayLabel") as Label3D).text, "RETURNS")
	assert_eq((_store.get_node("TradeInInspectionTray/TradeInInspectionTrayLabel") as Label3D).text, "TRADE")
	assert_eq((_store.get_node("PreorderSlipStack/PreorderSlipStackLabel") as Label3D).text, "PRE")
	assert_eq((_store.get_node("ServicePickupMarker/ServicePickupMarkerLabel") as Label3D).text, "SVC")
	assert_eq((_store.get_node("SaleScanPad/SaleScanPadLabel") as Label3D).text, "SALE")
	assert_eq((_store.get_node("RegisterWorkflowCard/RegisterWorkflowCardLabel") as Label3D).text, "SCAN PAY BAG")
	assert_true((_store.get_node("RegisterWorkflowCard/RegisterWorkflowCardLabel") as Label3D).no_depth_test)
	assert_lt((_store.get_node("RegisterModeSaleCue") as CSGBox3D).global_position.x, (_store.get_node("RegisterModeServiceCue") as CSGBox3D).global_position.x)


func test_production_visual_overhaul_catalog_build_and_upgrade_cues_exist() -> void:
	var computer := _store.get_node("BackroomComputer") as Node3D
	for prop_path in [
		"BackroomCatalogCardA",
		"BackroomCatalogCardB",
		"BackroomCartSummaryPanel",
		"DesignSwatchStrip",
		"DesignSwatchTeal",
		"DesignSwatchYellow",
		"DesignSwatchDark",
	]:
		var prop := _store.get_node_or_null(prop_path) as CSGBox3D
		assert_not_null(prop)
		assert_false(prop.use_collision, prop_path)
		assert_lt(_flat_distance_xz(prop.global_position, computer.global_position), 1.25, prop_path)
		assert_true(_is_inside_store_floorprint(prop.global_position), prop_path)

	var ghost := _store.get_node("FixturePlacementManager/GhostRackPreview") as Node3D
	assert_false(ghost.visible)
	for prop_path in [
		"FixturePlacementManager/GhostRackPreview/FixtureGhostFootprintA",
		"FixturePlacementManager/GhostRackPreview/FixtureGhostFootprintB",
		"FixturePlacementManager/GhostRackPreview/FixtureGhostFootprintC",
		"FixturePlacementManager/GhostRackPreview/FixtureGhostFootprintD",
	]:
		var prop := _store.get_node_or_null(prop_path) as CSGBox3D
		assert_not_null(prop)
		assert_false(prop.use_collision, prop_path)
		assert_lte(prop.size.y, 0.026, prop_path)

	for ghost_detail_path in [
		"FixturePlacementManager/GhostRackPreview/MiddleLedge",
		"FixturePlacementManager/GhostRackPreview/TopLedge",
		"FixturePlacementManager/GhostRackPreview/GhostSlotTickA",
		"FixturePlacementManager/GhostRackPreview/GhostSlotTickB",
		"FixturePlacementManager/GhostRackPreview/GhostSlotTickC",
	]:
		var detail := _store.get_node_or_null(ghost_detail_path) as CSGBox3D
		assert_not_null(detail)
		assert_false(detail.use_collision, ghost_detail_path)

	var upgrade_props := [
		"FixturePlacementInstructionPanel",
		"WallPaintSwatchStrip",
		"FloorMaterialSamplePanel",
		"UpgradePreviewRackCard",
		"ExpansionFootprintTapeA",
		"ExpansionFootprintTapeB",
	]
	for prop_path in upgrade_props:
		var prop := _store.get_node_or_null(prop_path) as CSGBox3D
		assert_not_null(prop)
		assert_false(prop.use_collision, prop_path)
		assert_true(_is_inside_store_floorprint(prop.global_position), prop_path)

	assert_eq((_store.get_node("FixturePlacementInstructionPanel/FixturePlacementInstructionLabel") as Label3D).text, "VALID FOOTPRINT")
	assert_eq((_store.get_node("BackroomCatalogCardA/BackroomCatalogCardALabel") as Label3D).text, "CATALOG")
	assert_eq((_store.get_node("BackroomCatalogCardB/BackroomCatalogCardBLabel") as Label3D).text, "BUILD")
	assert_eq((_store.get_node("BackroomCartSummaryPanel/BackroomCartSummaryLabel") as Label3D).text, "CART")
	assert_eq((_store.get_node("DesignSwatchStrip/DesignSwatchStripLabel") as Label3D).text, "PALETTE")
	assert_eq((_store.get_node("UpgradePreviewRackCard/UpgradePreviewRackLabel") as Label3D).text, "UPGRADE")
	assert_lte((_store.get_node("ExpansionFootprintTapeA") as CSGBox3D).size.y, 0.0061)
	assert_lte((_store.get_node("ExpansionFootprintTapeB") as CSGBox3D).size.y, 0.0061)

	var session := _store.get_node("StoreSession") as StoreSession
	for decoration_state in session.get_decoration_surface_states():
		var visible_path := str(decoration_state.get("visible_node_path", ""))
		var visible_node := _store.get_node_or_null(visible_path) as Node3D
		assert_not_null(visible_node, visible_path)
		if visible_node is CSGBox3D:
			assert_false((visible_node as CSGBox3D).use_collision, visible_path)

	for upgrade_state in session.get_upgrade_surface_states():
		var visible_path := str(upgrade_state.get("visible_surface", ""))
		var visible_node := _store.get_node_or_null(visible_path) as Node3D
		assert_not_null(visible_node, visible_path)


func test_hard_visual_benchmark_route_has_physical_game_shop_anchors() -> void:
	var register := _store.get_node("RegisterWorkstation") as Node3D
	var shelf_kit := _store.get_node_or_null("BenchmarkWallShelfKit") as Node3D
	assert_not_null(shelf_kit)
	assert_true(_is_inside_store_floorprint(shelf_kit.global_position))
	assert_lt(shelf_kit.global_position.z, -4.0)
	assert_lt(_flat_distance_xz(shelf_kit.global_position, register.global_position), 5.6)

	for prop_path in [
		"BenchmarkWallShelfKit/BenchmarkShelfBackPanel",
		"BenchmarkWallShelfKit/BenchmarkShelfLeftUpright",
		"BenchmarkWallShelfKit/BenchmarkShelfRightUpright",
		"BenchmarkWallShelfKit/BenchmarkShelfDeckTop",
		"BenchmarkWallShelfKit/BenchmarkShelfDeckMiddle",
		"BenchmarkWallShelfKit/BenchmarkShelfDeckBottom",
		"BenchmarkWallShelfKit/BenchmarkShelfLipTop",
		"BenchmarkWallShelfKit/BenchmarkShelfLipMiddle",
		"BenchmarkWallShelfKit/BenchmarkShelfLipBottom",
		"BenchmarkWallShelfKit/BenchmarkNewGameFacingA",
		"BenchmarkWallShelfKit/BenchmarkNewGameFacingB",
		"BenchmarkWallShelfKit/BenchmarkConsoleBoxFacing",
		"BenchmarkWallShelfKit/BenchmarkUsedGameSpineRowA",
		"BenchmarkWallShelfKit/BenchmarkUsedGameSpineRowB",
		"BenchmarkWallShelfKit/BenchmarkAccessoryPegboard",
		"BenchmarkWallShelfKit/BenchmarkAccessoryHookA",
		"BenchmarkWallShelfKit/BenchmarkAccessoryHookB",
		"BenchmarkWallShelfKit/BenchmarkControllerPack",
		"RegisterCounterMonitorBody",
		"RegisterCounterMonitorScreen",
		"RegisterCounterMonitorStand",
		"RegisterBagHookRail",
		"RegisterBagSleeveA",
		"RegisterBagSleeveB",
		"BenchmarkCeilingPanelFrontLeft",
		"BenchmarkCeilingPanelFrontRight",
		"BenchmarkCeilingGridFront",
		"BenchmarkFluorescentBarEntry",
		"BenchmarkFluorescentBarRegister",
	]:
		var prop := _store.get_node_or_null(prop_path) as CSGBox3D
		assert_not_null(prop, prop_path)
		assert_false(prop.use_collision, prop_path)
		assert_true(_is_inside_store_floorprint(prop.global_position), prop_path)

	assert_gt((_store.get_node("BenchmarkWallShelfKit/BenchmarkShelfBackPanel") as CSGBox3D).size.y, 1.0)
	assert_gt((_store.get_node("BenchmarkWallShelfKit/BenchmarkShelfDeckTop") as CSGBox3D).size.x, 1.7)
	assert_gt((_store.get_node("BenchmarkWallShelfKit/BenchmarkConsoleBoxFacing") as CSGBox3D).size.x, 0.45)
	assert_gt((_store.get_node("RegisterCounterMonitorBody") as CSGBox3D).global_position.y, 1.35)
	assert_lt(_flat_distance_xz((_store.get_node("RegisterCounterMonitorBody") as CSGBox3D).global_position, register.global_position), 0.55)
	assert_gt((_store.get_node("BenchmarkFluorescentBarRegister") as CSGBox3D).global_position.y, 2.6)


func test_hard_visual_benchmark_suppresses_explanatory_label_cards() -> void:
	for hidden_panel_path in [
		"DisplaySignPanel",
		"RegisterSignPanel",
		"BackroomSignPanel",
		"ReceivingSignPanel",
		"StorageSignPanel",
		"OfficeSignPanel",
		"ServiceSignPanel",
		"NewReleaseEndcap/EndcapHeaderPanel",
		"StaffPicksStand/StaffPicksHeaderPanel",
		"AccessoryPegWall/PegWallHeaderPanel",
		"FuturePegWallUnlockPanel",
		"LockedCasePlaceholder/LockedCaseHeaderPanel",
		"FutureBackroomRackUnlockPanel",
		"BackroomHintFromEntryPanel",
		"ShelfFacingDensityBand",
		"PreorderWallHeaderPanel",
		"RegisterWorkflowCard",
		"CatalogCostRulePanel",
	]:
		var panel := _store.get_node_or_null(hidden_panel_path) as Node3D
		assert_not_null(panel, hidden_panel_path)
		assert_false(panel.is_visible_in_tree(), hidden_panel_path)

	var visible_labels: Array[Label3D] = []
	_collect_visible_labels(_store, visible_labels)
	var banned_visible_terms := [
		"RACKS",
		"REGISTER",
		"BACKROOM",
		"RECEIVING",
		"STORAGE",
		"USED WALL",
		"CONTROLLERS",
		"ACCESSORIES",
		"LOCKED CASE",
		"PREORDERS",
		"SCAN PAY BAG",
	]
	for label in visible_labels:
		for banned_term in banned_visible_terms:
			assert_false(label.text.contains(banned_term), "%s should not be visible in %s" % [banned_term, label.get_path()])


func test_hard_visual_benchmark_backroom_threshold_has_depth() -> void:
	var threshold := _store.get_node("StaffThresholdMat") as CSGBox3D
	var left_hall := _store.get_node("StaffShortHallLeftWall") as CSGBox3D
	var right_hall := _store.get_node("StaffShortHallRightWall") as CSGBox3D
	var soffit := _store.get_node("StaffShortHallCeilingSoffit") as CSGBox3D
	var inset := _store.get_node("StaffUtilityFloorInset") as CSGBox3D
	var light_bar := _store.get_node("StaffThresholdCoolLightBar") as CSGBox3D
	var receiving := _store.get_node("ReceivingBox") as Node3D
	var computer := _store.get_node("BackroomComputer") as Node3D
	var separation_left := _store.get_node("StockroomSalesSeparationLeft") as CSGBox3D
	var separation_right := _store.get_node("StockroomSalesSeparationRight") as CSGBox3D
	var receiving_privacy := _store.get_node("StockroomReceivingPrivacyWall") as CSGBox3D
	var office_privacy := _store.get_node("StockroomOfficePrivacyReturn") as CSGBox3D
	var pocket_shadow := _store.get_node("StockroomDoorPocketShadow") as CSGBox3D

	assert_gt(left_hall.global_position.z, threshold.global_position.z)
	assert_gt(right_hall.global_position.z, threshold.global_position.z)
	assert_gt(inset.global_position.z, threshold.global_position.z)
	assert_gt(left_hall.size.z, threshold.size.z)
	assert_gt(right_hall.size.z, threshold.size.z)
	assert_gt(soffit.size.z, 1.0)
	assert_gt(light_bar.global_position.y, 2.0)
	assert_lt(left_hall.global_position.x, threshold.global_position.x)
	assert_gt(right_hall.global_position.x, threshold.global_position.x)
	assert_gt(_flat_distance_xz(threshold.global_position, receiving.global_position), 3.0)
	assert_gt(_flat_distance_xz(threshold.global_position, computer.global_position), 3.0)
	assert_true(_is_inside_store_floorprint(left_hall.global_position))
	assert_true(_is_inside_store_floorprint(right_hall.global_position))
	assert_true(separation_left.use_collision)
	assert_true(separation_right.use_collision)
	assert_true(receiving_privacy.use_collision)
	assert_true(office_privacy.use_collision)
	assert_false(pocket_shadow.use_collision)
	assert_lt(separation_left.global_position.x, threshold.global_position.x)
	assert_gt(separation_right.global_position.x, threshold.global_position.x)
	assert_almost_eq(separation_left.global_position.z, threshold.global_position.z, 0.05)
	assert_almost_eq(separation_right.global_position.z, threshold.global_position.z, 0.05)
	assert_gt(separation_left.size.y, 2.0)
	assert_gt(separation_right.size.y, 2.0)
	assert_gt(receiving_privacy.global_position.z, threshold.global_position.z)
	assert_gt(receiving_privacy.global_position.x, receiving.global_position.x)
	assert_lt(receiving_privacy.global_position.x, threshold.global_position.x)
	assert_lt(_flat_distance_xz(receiving_privacy.global_position, receiving.global_position), 2.6)
	assert_gt(office_privacy.global_position.z, threshold.global_position.z)


func test_register_workstation_exists() -> void:
	assert_not_null(_store.get_node_or_null("RegisterWorkstation"))


func test_customer_manager_exists() -> void:
	var manager := _store.get_node_or_null("CustomerManager") as Node3D
	assert_not_null(manager)
	assert_false(manager.visible)
	assert_false(manager.is_visible_in_tree())


func test_customer_manager_has_two_buyers() -> void:
	var manager := _store.get_node("CustomerManager")
	assert_eq(manager.get_customers().size(), 2)
	for customer in manager.get_customers():
		assert_false((customer as Node3D).is_visible_in_tree())


func test_suspicious_customer_exists_as_optional_encounter() -> void:
	var customer := _store.get_node_or_null("SuspiciousCustomer")
	var event_log := _store.get_node("SuspiciousEventLog")
	var storage := _store.get_node("EvidenceStorage")

	assert_not_null(customer)
	assert_false(customer.visible)
	assert_string_contains(customer.get_interaction_prompt(), "Talk To")
	assert_eq(event_log.get_event_count(), 0)
	assert_eq(storage.get_evidence_count(), 0)

	customer.interact()

	assert_true(event_log.has_event("cash_buyer_bulk_request_001"))
	assert_true(storage.has_evidence("cash_buyer_bulk_request_001"))
	assert_eq(event_log.get_event_count(), 1)
	assert_eq(storage.get_evidence_count(), 1)


func test_suspicious_customer_does_not_join_sales_customer_queue() -> void:
	var manager := _store.get_node("CustomerManager")
	var customer := _store.get_node("SuspiciousCustomer")

	assert_eq(manager.get_customers().size(), 2)
	assert_ne(customer.get_parent(), manager)


func test_trade_in_customer_exists_with_item() -> void:
	var customer := _store.get_node_or_null("TradeInCustomer") as SimpleTradeInCustomer
	assert_not_null(customer)
	assert_false(customer.visible)
	assert_not_null(customer.get_trade_item())


func test_service_customer_exists_with_disc_resurfacing_request() -> void:
	var customer := _store.get_node_or_null("ServiceCustomer")

	assert_not_null(customer)
	assert_false((customer as Node3D).visible)
	assert_true(customer.call("is_waiting_for_service"))
	assert_eq(customer.get("service_name"), "Disc Resurfacing")
	assert_eq(customer.get("item_name"), "Scratched Orbit Disc")
	assert_eq(customer.call("get_price_cents"), 599)
	assert_eq(customer.call("get_cost_cents"), 125)


func test_transaction_ledger_exists() -> void:
	assert_not_null(_store.get_node_or_null("TransactionLedger"))


func test_store_session_exists() -> void:
	assert_not_null(_store.get_node_or_null("StoreSession"))


func test_suspicious_event_log_exists() -> void:
	var event_log := _store.get_node_or_null("SuspiciousEventLog")
	assert_not_null(event_log)
	assert_eq(event_log.get_event_count(), 0)


func test_evidence_storage_exists() -> void:
	var storage := _store.get_node_or_null("EvidenceStorage")
	assert_not_null(storage)
	assert_eq(storage.get_evidence_count(), 0)


func test_backroom_computer_exists() -> void:
	assert_not_null(_store.get_node_or_null("BackroomComputer"))


func test_fixture_placement_manager_exists_with_hidden_ghost() -> void:
	var manager := _store.get_node_or_null("FixturePlacementManager")
	assert_not_null(manager)
	assert_false(manager.is_ghost_visible())
	assert_not_null(_store.get_node_or_null("FixturePlacementManager/GhostRackPreview"))
	assert_gt((manager.get("path_clearance_points") as PackedVector3Array).size(), 0)


func test_register_is_wired_to_customer_manager_ledger_and_session() -> void:
	var register := _store.get_node("RegisterWorkstation") as RegisterWorkstation
	var manager := register.get_node_or_null(register.customer_manager_path)
	var trade_customer := register.get_node_or_null(register.trade_in_customer_path)
	var preorder_customer := register.get_node_or_null(register.preorder_customer_path)
	var service_customer := register.get_node_or_null(register.service_customer_path)
	var receiving_box := register.get_node_or_null(register.receiving_box_path)
	var ledger := register.get_node_or_null(register.ledger_path) as TransactionLedger
	var session := register.get_node_or_null(register.store_session_path)

	assert_not_null(manager)
	assert_not_null(trade_customer)
	assert_not_null(preorder_customer)
	assert_not_null(service_customer)
	assert_not_null(receiving_box)
	assert_not_null(ledger)
	assert_not_null(session)


func test_preorder_customer_exists_and_targets_upcoming_release() -> void:
	var customer := _store.get_node_or_null("PreorderCustomer") as SimplePreorderCustomer

	assert_not_null(customer)
	assert_false(customer.visible)
	assert_true(customer.is_waiting_for_preorder())
	assert_eq(customer.get_release_name(), "Neon Skyline")
	assert_eq(customer.get_deposit_cents(), 500)


func test_store_session_is_wired_to_transaction_ledger() -> void:
	var session := _store.get_node("StoreSession")
	var ledger := session.get_node_or_null(session.get("ledger_path")) as TransactionLedger

	assert_not_null(ledger)


func test_store_session_is_wired_to_inventory_root() -> void:
	var session := _store.get_node("StoreSession")
	assert_eq(session.get_node_or_null(session.get("inventory_root_path")), _store)
	assert_gt(session.get_active_inventory_items().size(), 0)


func test_store_session_is_wired_to_receiving_box() -> void:
	var session := _store.get_node("StoreSession")
	var receiving_box := session.get_node_or_null(session.get("receiving_box_path"))

	assert_eq(receiving_box, _store.get_node("ReceivingBox"))


func test_store_session_is_wired_to_fixture_placement_manager() -> void:
	var session := _store.get_node("StoreSession")
	var manager := session.get_node_or_null(session.get("fixture_placement_manager_path"))

	assert_not_null(manager)


func test_store_session_is_wired_to_evidence_storage() -> void:
	var session := _store.get_node("StoreSession")
	var storage := session.get_node_or_null(session.get("evidence_storage_path"))

	assert_eq(storage, _store.get_node("EvidenceStorage"))
	assert_string_contains(session.get_security_placeholder_summary_text(), "Security placeholders:")


func test_store_session_is_wired_to_customer_manager_for_layout_effects() -> void:
	var session := _store.get_node("StoreSession")
	var manager := session.get_node_or_null(session.get("customer_manager_path"))

	assert_eq(manager, _store.get_node("CustomerManager"))
	assert_string_contains(session.get_layout_effect_summary_text(), "queue")


func test_fixture_order_shows_placement_ghost() -> void:
	var session := _store.get_node("StoreSession")
	var manager := _store.get_node("FixturePlacementManager")

	var order: Dictionary = session.order_fixture("fixture_game_display_rack")

	assert_false(order.is_empty())
	assert_true(manager.is_ghost_visible())
	assert_eq(manager.get_current_order_id(), order.get("order_id"))
	assert_eq(manager.get_current_fixture_id(), "fixture_game_display_rack")
	assert_eq(manager.get_placement_state(), "valid")


func test_fixture_placement_ghost_marks_invalid_out_of_bounds_position() -> void:
	var session := _store.get_node("StoreSession")
	var manager := _store.get_node("FixturePlacementManager")
	session.order_fixture("fixture_game_display_rack")

	assert_false(manager.set_ghost_position(Vector3(99.0, 0.04, 2.15)))

	assert_eq(manager.get_placement_state(), "invalid")
	assert_false(manager.is_current_position_valid())


func test_fixture_placement_ghost_supports_rotation_and_grid_movement() -> void:
	var session := _store.get_node("StoreSession")
	var manager := _store.get_node("FixturePlacementManager")
	session.order_fixture("fixture_game_display_rack")

	assert_true(manager.rotate_ghost())
	assert_true(manager.move_ghost_by_grid(1, 1))

	assert_almost_eq(manager.get_ghost_rotation_y(), deg_to_rad(90.0), 0.001)
	assert_eq(manager.get_placement_state(), "valid")


func test_fixture_order_can_be_placed_in_main_scene() -> void:
	var session := _store.get_node("StoreSession")
	var manager := _store.get_node("FixturePlacementManager")
	var order: Dictionary = session.order_fixture("fixture_game_display_rack")

	var placed_order: Dictionary = session.place_pending_fixture()

	assert_false(order.is_empty())
	assert_false(placed_order.is_empty())
	assert_eq(placed_order.get("order_id"), order.get("order_id"))
	assert_eq(placed_order.get("status"), "placed")
	assert_false(manager.is_ghost_visible())
	assert_eq(session.get_pending_fixture_orders().size(), 0)
	assert_eq(session.get_placed_fixture_orders().size(), 1)
	var placed_rack := _store.get_node_or_null("PlacedGameDisplayRack001") as Node3D
	assert_not_null(placed_rack)
	assert_not_null(placed_rack.get_node_or_null("ShelfSlot001"))
	assert_not_null(placed_rack.get_node_or_null("ShelfSlot002"))
	assert_not_null(placed_rack.get_node_or_null("ShelfSlot003"))
	assert_not_null(placed_rack.get_node_or_null("ShelfSlot012"))


func test_supplier_order_delivers_items_to_main_scene_receiving_box() -> void:
	var session := _store.get_node("StoreSession")
	var receiving_box := _store.get_node("ReceivingBox")

	var order: Dictionary = session.order_supplier_lot("supplier_lot_used_games_001")
	session.end_day()
	var started: Dictionary = session.start_next_day()

	assert_false(order.is_empty())
	assert_false(started.is_empty())
	assert_eq(started.get("delivered_count"), 1)
	assert_eq(session.get_pending_supplier_orders().size(), 0)
	assert_eq(session.get_delivered_supplier_orders().size(), 1)
	assert_not_null(receiving_box.get_node_or_null("DeliveredUsedGame004"))
	assert_not_null(receiving_box.get_node_or_null("DeliveredUsedGame005"))
	assert_not_null(receiving_box.get_node_or_null("DeliveredUsedGame006"))
	assert_string_contains(session.get_inventory_summary_text(), "Star Trader x4")
	assert_string_contains(session.get_inventory_summary_text(), "Moon Escape x1")
	assert_string_contains(session.get_inventory_summary_text(), "Neon Harbor x1")


func test_backroom_computer_is_wired_to_store_session() -> void:
	var computer := _store.get_node("BackroomComputer")
	var session := computer.get_node_or_null(computer.get("store_session_path"))

	assert_not_null(session)


func test_customer_manager_targets_display_slots() -> void:
	var manager := _store.get_node("CustomerManager")
	for slot_path in manager.get("display_slot_paths"):
		var slot := manager.get_node_or_null(slot_path) as ShelfSlot
		assert_not_null(slot)


func test_customer_manager_paths_validate_inside_store() -> void:
	var manager := _store.get_node("CustomerManager")
	assert_eq(manager.validate_customer_paths(), [])


func test_register_area_customer_positions_are_spaced_for_readability() -> void:
	var manager := _store.get_node("CustomerManager")
	var register_customers: Array[Node3D] = [
		_store.get_node("TradeInCustomer") as Node3D,
		_store.get_node("PreorderCustomer") as Node3D,
		_store.get_node("ServiceCustomer") as Node3D,
		_store.get_node("ReturnCustomer") as Node3D,
		_store.get_node("SuspiciousCustomer") as Node3D,
	]

	for index in range(register_customers.size()):
		for next_index in range(index + 1, register_customers.size()):
			assert_gte(
				_flat_distance_xz(register_customers[index].global_position, register_customers[next_index].global_position),
				0.95
			)

	for customer in register_customers:
		assert_gte(_flat_distance_xz(customer.global_position, manager.register_queue_start), 1.25)
		assert_true(manager.is_position_inside_store(customer.global_position))

	assert_lt((_store.get_node("TradeInCustomer") as Node3D).global_position.x, 0.0)
	assert_lt((_store.get_node("PreorderCustomer") as Node3D).global_position.x, -1.0)
	assert_lt((_store.get_node("ServiceCustomer") as Node3D).global_position.x, -2.0)
	assert_lt((_store.get_node("ReturnCustomer") as Node3D).global_position.x, -3.0)
	assert_lt((_store.get_node("SuspiciousCustomer") as Node3D).global_position.x, -3.5)


func test_buyer_queue_lane_stays_clear_of_special_customers() -> void:
	var manager := _store.get_node("CustomerManager")
	var special_customers: Array[Node3D] = [
		_store.get_node("TradeInCustomer") as Node3D,
		_store.get_node("PreorderCustomer") as Node3D,
		_store.get_node("ServiceCustomer") as Node3D,
		_store.get_node("ReturnCustomer") as Node3D,
		_store.get_node("SuspiciousCustomer") as Node3D,
	]

	for queue_index in range(3):
		var queue_position: Vector3 = manager._queue_position_for_index(queue_index)
		assert_true(manager.is_position_inside_store(queue_position))
		for customer in special_customers:
			assert_gte(_flat_distance_xz(queue_position, customer.global_position), 1.2)


func test_alpha_special_customer_arc_has_readable_depth_separation() -> void:
	var trade_in := _store.get_node("TradeInCustomer") as Node3D
	var preorder := _store.get_node("PreorderCustomer") as Node3D
	var service := _store.get_node("ServiceCustomer") as Node3D
	var return_customer := _store.get_node("ReturnCustomer") as Node3D
	var suspicious := _store.get_node("SuspiciousCustomer") as Node3D

	assert_lt(preorder.global_position.z, trade_in.global_position.z - 0.5)
	assert_lt(service.global_position.x, preorder.global_position.x - 1.0)
	assert_lt(return_customer.global_position.x, service.global_position.x - 0.5)
	assert_lt(suspicious.global_position.x, return_customer.global_position.x - 0.5)
	assert_gte(_flat_distance_xz(preorder.global_position, service.global_position), 1.25)
	assert_gte(_flat_distance_xz(service.global_position, return_customer.global_position), 1.0)
	assert_gte(_flat_distance_xz(return_customer.global_position, suspicious.global_position), 1.0)


func test_alpha_customer_queue_lane_keeps_internal_spacing_contract() -> void:
	var manager := _store.get_node("CustomerManager")
	var queue_positions: Array[Vector3] = manager.get_queue_lane_positions(3)
	assert_eq(queue_positions.size(), 3)
	assert_gte(manager.register_queue_spacing.length(), manager.minimum_queue_spacing_distance)

	for index in range(queue_positions.size()):
		var queue_position := queue_positions[index]
		assert_true(manager.is_position_inside_store(queue_position))
		if index > 0:
			assert_gte(
				_flat_distance_xz(queue_positions[index - 1], queue_position),
				manager.minimum_queue_spacing_distance
			)

	var special_customers: Array[Node3D] = [
		_store.get_node("TradeInCustomer") as Node3D,
		_store.get_node("PreorderCustomer") as Node3D,
		_store.get_node("ServiceCustomer") as Node3D,
		_store.get_node("ReturnCustomer") as Node3D,
		_store.get_node("SuspiciousCustomer") as Node3D,
	]
	for queue_position in queue_positions:
		for customer in special_customers:
			assert_gte(
				_flat_distance_xz(queue_position, customer.global_position),
				manager.minimum_queue_spacing_distance + 0.5
			)


func test_no_standalone_pricing_workstation_exists() -> void:
	assert_null(_store.get_node_or_null("PricingWorkstation"))


func test_no_standalone_price_register_exists() -> void:
	assert_null(_store.get_node_or_null("PricingRegister"))


func test_game_display_rack_exists() -> void:
	assert_not_null(_store.get_node_or_null("GameDisplayRack"))


func _flat_distance_xz(first: Vector3, second: Vector3) -> float:
	return Vector2(first.x, first.z).distance_to(Vector2(second.x, second.z))


func _color_luma(color: Color) -> float:
	return color.r * 0.2126 + color.g * 0.7152 + color.b * 0.0722


func _display_rack_slot_names() -> Array[String]:
	var names: Array[String] = []
	for slot_index in range(1, 13):
		names.append("ShelfSlot%03d" % slot_index)
	return names


func _collect_visible_labels(node: Node, labels: Array[Label3D]) -> void:
	if node is Label3D and (node as Label3D).is_visible_in_tree():
		labels.append(node as Label3D)
	for child in node.get_children():
		_collect_visible_labels(child, labels)


func _is_inside_store_floorprint(position: Vector3) -> bool:
	return position.x >= -6.9 and position.x <= 6.9 and position.z >= -5.9 and position.z <= 5.9
