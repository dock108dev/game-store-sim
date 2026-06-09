extends GutTest

const MAIN_SCENE := "res://scenes/world/graybox_store.tscn"

var _store: Node3D


func before_each() -> void:
	_store = load(MAIN_SCENE).instantiate()
	add_child_autofree(_store)


func test_main_scene_loads_graybox_store() -> void:
	assert_not_null(_store)
	assert_true(_store is Node3D)


func test_main_scene_has_expected_root_name() -> void:
	assert_eq(_store.name, "GrayboxStore")


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
	var trade_in_customer := _store.get_node("TradeInCustomer") as Node3D

	assert_not_null(head)
	assert_not_null(camera)
	assert_not_null(hold_anchor)
	assert_lt(player.global_position.z, -5.0)
	assert_gt(player.global_position.x, 4.4)
	assert_lt(player.global_position.x, 5.3)
	assert_gt(head.position.y, 1.65)
	assert_gte(camera.fov, 78.0)
	assert_lte(camera.near, 0.04)
	assert_gt(-player.global_transform.basis.z.x, 0.45)
	assert_gt(-player.global_transform.basis.z.z, 0.55)
	assert_gt(_flat_distance_xz(player.global_position, register.global_position), 3.4)
	assert_gt(_flat_distance_xz(player.global_position, trade_in_customer.global_position), 1.7)
	assert_gt(hold_anchor.position.x, 0.55)
	assert_lt(hold_anchor.position.y, -0.55)
	assert_lt(hold_anchor.position.z, -1.45)


func test_floor_collision_is_enabled() -> void:
	var floor := _store.get_node("Floor") as CSGBox3D
	assert_true(floor.use_collision)


func test_front_door_opening_is_blocked_for_now() -> void:
	var blocker := _store.get_node_or_null("FrontDoorBlocker") as StaticBody3D
	assert_not_null(blocker)
	assert_false(blocker.visible)
	assert_almost_eq(blocker.global_position.z, -6.0, 0.01)

	var collision_shape := blocker.get_node_or_null("CollisionShape3D") as CollisionShape3D
	assert_not_null(collision_shape)
	assert_false(collision_shape.disabled)

	var shape := collision_shape.shape as BoxShape3D
	assert_not_null(shape)
	assert_gte(shape.size.x, 3.5)
	assert_gte(shape.size.y, 2.5)
	assert_gte(shape.size.z, 0.2)


func test_storefront_entry_has_production_cues() -> void:
	var left_glass := _store.get_node_or_null("StorefrontGlassLeft") as CSGBox3D
	var right_glass := _store.get_node_or_null("StorefrontGlassRight") as CSGBox3D
	var entry_cue := _store.get_node_or_null("EntrySidewalkCue") as CSGBox3D
	var open_label := _store.get_node_or_null("OpenSignPanel/OpenSignLabel") as Label3D
	var hours_label := _store.get_node_or_null("HoursDecalPanel/HoursDecalLabel") as Label3D

	assert_not_null(left_glass)
	assert_not_null(right_glass)
	assert_not_null(entry_cue)
	assert_not_null(open_label)
	assert_not_null(hours_label)
	assert_false(left_glass.use_collision)
	assert_false(right_glass.use_collision)
	assert_false(entry_cue.use_collision)
	assert_eq(open_label.text, "OPEN")
	assert_eq(hours_label.text, "11-8")
	assert_lt(left_glass.global_position.z, -5.8)
	assert_lt(right_glass.global_position.z, -5.8)
	assert_lt(entry_cue.global_position.z, -5.8)
	assert_gt(left_glass.size.y, 1.6)
	assert_gt(right_glass.size.y, 1.6)

	var glass_material := left_glass.material as StandardMaterial3D
	assert_not_null(glass_material)
	assert_lt(glass_material.albedo_color.a, 0.5)
	assert_eq(glass_material.transparency, BaseMaterial3D.TRANSPARENCY_ALPHA)


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

	for lane_name in ["ReceivingLane001", "ReceivingLane002", "ReceivingLane003"]:
		var lane := receiving_box.get_node_or_null(lane_name) as CSGBox3D
		assert_not_null(lane)
		assert_false(lane.use_collision)
		assert_lte(lane.size.y, 0.0121)
		assert_lte(absf(lane.position.x), 0.35)
		assert_lte(absf(lane.position.z), 0.08)


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


func test_display_rack_has_three_slots() -> void:
	assert_not_null(_store.get_node_or_null("GameDisplayRack/ShelfSlot001"))
	assert_not_null(_store.get_node_or_null("GameDisplayRack/ShelfSlot002"))
	assert_not_null(_store.get_node_or_null("GameDisplayRack/ShelfSlot003"))


func test_display_rack_slots_are_assigned_used_game_category() -> void:
	for slot_name in ["ShelfSlot001", "ShelfSlot002", "ShelfSlot003"]:
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


func test_store_lighting_has_warm_sales_and_cool_backroom_layers() -> void:
	var sun_light := _store.get_node_or_null("SunLight") as DirectionalLight3D
	var sales_light := _store.get_node_or_null("StoreLight") as OmniLight3D
	var register_light := _store.get_node_or_null("RegisterTaskLight") as OmniLight3D
	var backroom_light := _store.get_node_or_null("BackroomUtilityLight") as OmniLight3D

	assert_not_null(sun_light)
	assert_not_null(sales_light)
	assert_not_null(register_light)
	assert_not_null(backroom_light)
	assert_lte(sun_light.light_energy, 1.0)
	assert_gt(sales_light.light_energy, backroom_light.light_energy)
	assert_gt(register_light.light_energy, 1.5)
	assert_gt(sales_light.light_color.r, sales_light.light_color.b)
	assert_gt(register_light.light_color.r, register_light.light_color.b)
	assert_gt(backroom_light.light_color.b, backroom_light.light_color.r)
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
	assert_lte(sun_light.light_energy + sales_light.light_energy + register_light.light_energy + backroom_light.light_energy + total_accent_energy, 11.0)


func test_sales_floor_has_merchandising_and_route_cues() -> void:
	var route_mat := _store.get_node_or_null("SalesFloorRouteMat") as CSGBox3D
	var new_release_endcap := _store.get_node_or_null("NewReleaseEndcap") as Node3D
	var staff_picks_stand := _store.get_node_or_null("StaffPicksStand") as Node3D
	var new_release_label := _store.get_node_or_null("NewReleaseEndcap/EndcapHeaderPanel/EndcapHeaderLabel") as Label3D
	var staff_picks_label := _store.get_node_or_null("StaffPicksStand/StaffPicksHeaderPanel/StaffPicksHeaderLabel") as Label3D

	assert_not_null(route_mat)
	assert_not_null(new_release_endcap)
	assert_not_null(staff_picks_stand)
	assert_not_null(new_release_label)
	assert_not_null(staff_picks_label)
	assert_false(route_mat.use_collision)
	assert_eq(new_release_label.text, "NEW RELEASES")
	assert_eq(staff_picks_label.text, "STAFF PICKS")
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
	]:
		var cue := _store.get_node_or_null(cue_path) as CSGBox3D
		assert_not_null(cue)
		assert_false(cue.use_collision)

	var register := _store.get_node("RegisterWorkstation") as Node3D
	var rack := _store.get_node("GameDisplayRack") as Node3D
	assert_gt(_flat_distance_xz(new_release_endcap.global_position, register.global_position), 3.0)
	assert_gt(_flat_distance_xz(staff_picks_stand.global_position, rack.global_position), 4.0)


func test_fixture_kit_has_accessory_and_locked_case_cues() -> void:
	var peg_wall := _store.get_node_or_null("AccessoryPegWall") as Node3D
	var locked_case := _store.get_node_or_null("LockedCasePlaceholder") as Node3D
	var peg_label := _store.get_node_or_null("AccessoryPegWall/PegWallHeaderPanel/PegWallHeaderLabel") as Label3D
	var locked_label := _store.get_node_or_null("LockedCasePlaceholder/LockedCaseHeaderPanel/LockedCaseHeaderLabel") as Label3D

	assert_not_null(peg_wall)
	assert_not_null(locked_case)
	assert_not_null(peg_label)
	assert_not_null(locked_label)
	assert_eq(peg_label.text, "ACCESSORIES")
	assert_eq(locked_label.text, "LOCKED CASE")
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


func test_store_signage_uses_fictional_world_labels() -> void:
	var expected_labels := {
		"StoreIdentitySignPanel/StoreIdentitySignLabel": "SAVE POINT GAMES",
		"DisplaySignPanel/DisplaySignLabel": "DISPLAY RACKS",
		"RegisterSignPanel/RegisterSignLabel": "REGISTER",
		"BackroomSignPanel/BackroomSignLabel": "BACKROOM",
		"ReceivingSignPanel/ReceivingSignLabel": "RECEIVING",
		"StorageSignPanel/StorageSignLabel": "STORAGE",
	}
	var banned_terms := ["GAMESTOP", "NINTENDO", "PLAYSTATION", "XBOX", "SEGA", "ATARI"]

	for label_path in expected_labels:
		var label := _store.get_node_or_null(label_path) as Label3D
		assert_not_null(label)
		assert_eq(label.text, expected_labels[label_path])
		assert_gte(label.font_size, 30)
		assert_lte(label.pixel_size, 0.0066)
		for banned_term in banned_terms:
			assert_false(label.text.contains(banned_term))


func test_store_sign_panels_are_nonblocking_and_zone_aligned() -> void:
	var expected_panels := {
		"StoreIdentitySignPanel": Vector3(0, 2.18, -5.86),
		"DisplaySignPanel": Vector3(-3.18, 1.78, 5.82),
		"RegisterSignPanel": Vector3(3.05, 1.46, -2.9),
		"BackroomSignPanel": Vector3(0.3, 1.96, 3.26),
		"ReceivingSignPanel": Vector3(-4.65, 1.18, 3.08),
		"StorageSignPanel": Vector3(-5.85, 1.38, 4.66),
	}

	for panel_name in expected_panels:
		var panel := _store.get_node_or_null(panel_name) as CSGBox3D
		assert_not_null(panel)
		assert_false(panel.use_collision)
		assert_almost_eq(panel.global_position.x, expected_panels[panel_name].x, 0.01)
		assert_almost_eq(panel.global_position.y, expected_panels[panel_name].y, 0.01)
		assert_almost_eq(panel.global_position.z, expected_panels[panel_name].z, 0.01)

	assert_gt(_flat_distance_xz((_store.get_node("RegisterSignPanel") as CSGBox3D).global_position, (_store.get_node("GameDisplayRack") as Node3D).global_position), 6.0)
	assert_lt(_flat_distance_xz((_store.get_node("ReceivingSignPanel") as CSGBox3D).global_position, (_store.get_node("ReceivingBox") as Node3D).global_position), 0.9)


func test_alpha_wall_detail_breaks_up_blank_graybox_planes() -> void:
	var expected_labels := {
		"RightWallUsedPosterPanel/RightWallUsedPosterLabel": "USED WALL",
		"RightWallControllerPosterPanel/RightWallControllerPosterLabel": "CONTROLLERS",
		"BackWallFeatureStripe/BackWallFeatureLabel": "BUY  SELL  REPAIR",
	}

	for label_path in expected_labels:
		var label := _store.get_node_or_null(label_path) as Label3D
		assert_not_null(label)
		assert_eq(label.text, expected_labels[label_path])
		assert_lte(label.pixel_size, 0.0042)

	for panel_path in [
		"RightWallMerchBand",
		"RightWallUsedPosterPanel",
		"RightWallControllerPosterPanel",
		"BackWallFeatureStripe",
	]:
		var panel := _store.get_node_or_null(panel_path) as CSGBox3D
		assert_not_null(panel)
		assert_false(panel.use_collision)
		assert_true(_is_inside_store_floorprint(panel.global_position))

	assert_gt((_store.get_node("RightWallMerchBand") as CSGBox3D).global_position.x, 6.7)
	assert_gt((_store.get_node("BackWallFeatureStripe") as CSGBox3D).global_position.z, 5.7)


func test_retail_clutter_uses_short_fictional_callouts() -> void:
	var expected_labels := {
		"WeeklyPicksPosterPanel/WeeklyPicksPosterLabel": "WEEKLY PICKS",
		"NewThisWeekPosterPanel/NewThisWeekPosterLabel": "NEW THIS WEEK",
		"TradeBonusPosterPanel/TradeBonusPosterLabel": "TRADE BONUS",
		"CounterDealTagPanel/CounterDealTagLabel": "$9+ USED",
		"BargainBin/BinFrontTag/BinFrontLabel": "BARGAIN BIN",
	}

	for label_path in expected_labels:
		var label := _store.get_node_or_null(label_path) as Label3D
		assert_not_null(label)
		assert_eq(label.text, expected_labels[label_path])
		assert_lte(label.text.length(), 13)
		assert_lte(label.pixel_size, 0.0049)


func test_retail_clutter_is_nonblocking_and_away_from_interaction_hotspots() -> void:
	var clutter_boxes := [
		"WeeklyPicksPosterPanel",
		"NewThisWeekPosterPanel",
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
		"SleeveStack",
		"CustomerCounterMat",
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
	assert_gt((_store.get_node("ReceiptSlip") as CSGBox3D).global_position.y, 1.2)
	assert_gt((_store.get_node("SleeveStack") as CSGBox3D).global_position.x, register.global_position.x)


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
		"ReceivingBoxStackA",
		"ReceivingBoxStackALabel",
		"ReceivingBoxStackB",
		"BackroomDeliveryDoor",
		"DeliveryDoorSlatA",
		"DeliveryDoorSlatB",
		"ReceivingInvoiceClipboard",
		"ReceivingInvoicePaper",
	]
	for prop_path in receiving_props:
		var prop := _store.get_node_or_null(prop_path) as CSGBox3D
		assert_not_null(prop)
		assert_false(prop.use_collision)
		assert_lt(_flat_distance_xz(prop.global_position, _store.get_node("ReceivingBox").global_position), 2.25)

	var storage_shelf := _store.get_node_or_null("BackroomStorageShelf") as Node3D
	assert_not_null(storage_shelf)
	assert_not_null(storage_shelf.get_node_or_null("LowerShelf"))
	assert_not_null(storage_shelf.get_node_or_null("UpperShelf"))
	assert_not_null(storage_shelf.get_node_or_null("StorageBoxA"))
	assert_not_null(storage_shelf.get_node_or_null("StorageBoxB"))
	assert_not_null(_store.get_node_or_null("BackstockOverflowCrateA"))
	assert_not_null(_store.get_node_or_null("BackstockOverflowCrateB"))
	assert_not_null(_store.get_node_or_null("BackstockOverflowLabelPanel/BackstockOverflowLabel"))
	assert_lt(storage_shelf.global_position.x, _store.get_node("ReceivingBox").global_position.x)
	assert_gt(storage_shelf.global_position.z, 5.0)


func test_backroom_management_and_service_props_exist() -> void:
	var management_props := [
		"BackroomManagementBoard",
		"ManagementReportCardA",
		"ManagementReportCardB",
		"ManagementDeskPad",
		"ManagementKeyboard",
		"ManagementTaskCard",
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
	assert_not_null(service_bench.get_node_or_null("ServiceTicketPanel"))
	assert_eq((service_bench.get_node("ServiceTicketPanel/ServiceTicketLabel") as Label3D).text, "SERVICE")
	assert_gt(service_bench.global_position.z, 5.0)
	assert_gt(_flat_distance_xz(service_bench.global_position, _store.get_node("RegisterWorkstation").global_position), 7.0)


func test_backroom_production_blockout_has_security_and_paperwork_cues() -> void:
	var expected_labels := {
		"BackroomDeliveryDoor/DeliveryDoorLabel": "DELIVERIES",
		"ReceivingInvoiceClipboard/ReceivingInvoiceLabel": "INVOICE",
		"BackstockOverflowLabelPanel/BackstockOverflowLabel": "BACKSTOCK",
		"BackroomSafePlaceholder/SafeLabelPanel/SafeLabel": "SAFE",
		"SecurityMonitorPanel/SecurityMonitorLabel": "SECURITY",
	}
	for label_path in expected_labels:
		var label := _store.get_node_or_null(label_path) as Label3D
		assert_not_null(label)
		assert_eq(label.text, expected_labels[label_path])

	var safe := _store.get_node_or_null("BackroomSafePlaceholder") as Node3D
	var security_monitor := _store.get_node_or_null("SecurityMonitorPanel") as CSGBox3D
	var evidence_locker := _store.get_node_or_null("EvidenceLockerPlaceholder") as CSGBox3D
	assert_not_null(safe)
	assert_not_null(security_monitor)
	assert_not_null(evidence_locker)
	assert_true(_is_inside_store_floorprint(safe.global_position))
	assert_true(_is_inside_store_floorprint(security_monitor.global_position))
	assert_true(_is_inside_store_floorprint(evidence_locker.global_position))
	assert_gt(safe.global_position.x, 5.5)
	assert_gt(security_monitor.global_position.x, 5.0)
	assert_gt(evidence_locker.global_position.z, 4.0)

	for cue_path in [
		"BackroomSafePlaceholder/SafeBody",
		"BackroomSafePlaceholder/SafeDoorPanel",
		"BackroomSafePlaceholder/SafeHandle",
		"BackroomSafePlaceholder/SafeLabelPanel",
		"SecurityMonitorPanel",
		"SecurityMonitorScreen",
		"EvidenceLockerPlaceholder",
	]:
		var cue := _store.get_node_or_null(cue_path) as CSGBox3D
		assert_not_null(cue)
		assert_false(cue.use_collision)


func test_production_environment_props_preserve_core_navigation_clearance() -> void:
	var decorative_csg_paths := [
		"StorefrontGlassLeft",
		"StorefrontGlassRight",
		"EntrySidewalkCue",
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
		"BackroomReceivingZone",
		"BackroomStorageZone",
		"BackroomManagementZone",
		"BackroomServiceZone",
		"BackroomPathZone",
		"BackroomDeliveryDoor",
		"ReceivingInvoiceClipboard",
		"BackstockOverflowCrateA",
		"BackstockOverflowCrateB",
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

	assert_lt(_flat_distance_xz(player.global_position, register.global_position), 5.2)
	assert_lt(_flat_distance_xz(register.global_position, rack.global_position), 10.0)
	assert_lt(_flat_distance_xz(rack.global_position, receiving_box.global_position), 2.4)
	assert_lt(_flat_distance_xz(receiving_box.global_position, storage_shelf.global_position), 2.4)
	assert_lte((_store.get_node("BackroomPathZone") as CSGBox3D).size.y, 0.015)
	assert_lte((_store.get_node("RegisterQueueMat") as CSGBox3D).size.y, 0.0121)
	assert_true(_is_inside_store_floorprint(ghost.global_position))
	assert_true(_is_inside_store_floorprint(fixture_manager.get("default_ghost_position")))


func test_register_workstation_exists() -> void:
	assert_not_null(_store.get_node_or_null("RegisterWorkstation"))


func test_customer_manager_exists() -> void:
	assert_not_null(_store.get_node_or_null("CustomerManager"))


func test_customer_manager_has_two_buyers() -> void:
	var manager := _store.get_node("CustomerManager")
	assert_eq(manager.get_customers().size(), 2)


func test_suspicious_customer_exists_as_optional_encounter() -> void:
	var customer := _store.get_node_or_null("SuspiciousCustomer")
	var event_log := _store.get_node("SuspiciousEventLog")
	var storage := _store.get_node("EvidenceStorage")

	assert_not_null(customer)
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
	assert_not_null(customer.get_trade_item())


func test_service_customer_exists_with_disc_resurfacing_request() -> void:
	var customer := _store.get_node_or_null("ServiceCustomer")

	assert_not_null(customer)
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
	assert_lt((_store.get_node("SuspiciousCustomer") as Node3D).global_position.x, -3.5)


func test_buyer_queue_lane_stays_clear_of_special_customers() -> void:
	var manager := _store.get_node("CustomerManager")
	var special_customers: Array[Node3D] = [
		_store.get_node("TradeInCustomer") as Node3D,
		_store.get_node("PreorderCustomer") as Node3D,
		_store.get_node("ServiceCustomer") as Node3D,
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
	var suspicious := _store.get_node("SuspiciousCustomer") as Node3D

	assert_lt(preorder.global_position.z, trade_in.global_position.z - 0.5)
	assert_lt(service.global_position.x, preorder.global_position.x - 1.0)
	assert_lt(suspicious.global_position.x, service.global_position.x - 1.0)
	assert_gte(_flat_distance_xz(preorder.global_position, service.global_position), 1.25)
	assert_gte(_flat_distance_xz(service.global_position, suspicious.global_position), 1.35)


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


func _is_inside_store_floorprint(position: Vector3) -> bool:
	return position.x >= -6.9 and position.x <= 6.9 and position.z >= -5.9 and position.z <= 5.9
