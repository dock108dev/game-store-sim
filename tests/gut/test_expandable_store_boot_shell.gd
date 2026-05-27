extends GutTest

const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"
const SHELL_PRACTICAL_MAX_ENERGY: float = 0.65
const SHELL_PRACTICAL_MAX_RANGE: float = 3.8
const GENERATED_REGISTER_SCREEN_MIN_EMISSION: float = 0.42
const GENERATED_REGISTER_SCREEN_MAX_EMISSION: float = 0.60

var _root: Node3D = null
var _saved_state: GameManager.State


func before_each() -> void:
	_saved_state = GameManager.current_state
	GameManager.current_state = GameManager.State.STORE_VIEW
	StoreSessionState.reset_new_run()
	var scene: PackedScene = load(SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	_root = scene.instantiate() as Node3D
	add_child(_root)
	await get_tree().process_frame
	await get_tree().process_frame


func after_each() -> void:
	if is_instance_valid(_root):
		_root.free()
	_root = null
	StoreSessionState.reset_new_run()
	GameManager.current_state = _saved_state


func test_boot_uses_expandable_store_shell_instead_of_authored_full_room() -> void:
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	assert_not_null(shell, "Boot must generate the expanded expandable store shell")
	if shell == null:
		return
	assert_true(shell.visible)
	for required: String in [
		"StarterFloor",
		"StarterBackWall",
		"StarterLeftWall",
		"StarterRightWall",
		"StarterGlassDoorBlocker",
		"StockroomPartition",
		"StockroomLeftSideReturn",
		"StockroomSideReturn",
		"StockroomBackPanel",
		"StockroomDoorJambRight",
		"ExpansionDoorPanel",
		"StarterSignLabel",
		"CheckoutRegisterScreen",
		"EntryThreshold",
	]:
		assert_not_null(shell.get_node_or_null(required), "Shell must include %s" % required)
	var floor: MeshInstance3D = shell.get_node_or_null("StarterFloor") as MeshInstance3D
	assert_not_null(floor, "StarterFloor must be generated as the visible runtime floor")
	if floor != null:
		var floor_mesh: BoxMesh = floor.mesh as BoxMesh
		assert_not_null(floor_mesh, "StarterFloor must use a BoxMesh footprint")
		if floor_mesh != null:
			assert_almost_eq(floor_mesh.size.x, 12.0, 0.01, "StarterFloor width")
			assert_almost_eq(floor_mesh.size.z, 17.5, 0.01, "StarterFloor depth")
		assert_almost_eq(floor.position.z, 1.10, 0.01, "StarterFloor center Z")

	for old_root: String in [
		"Floor",
		"BackWallBody",
		"InteriorSignage",
		"ReadabilityProps",
		"Checkout",
		"back_room",
	]:
		var node: Node3D = _root.get_node_or_null(old_root) as Node3D
		assert_not_null(
			node, "Legacy authored root remains available as non-visual anchor: %s" % old_root
		)
		if node != null:
			assert_false(
				node.visible, "%s must not be visible in the generated boot view" % old_root
			)
	var old_door_mesh: Node3D = _root.get_node_or_null("EntranceDoor/DoorMesh") as Node3D
	assert_not_null(old_door_mesh, "Legacy authored door mesh must still exist")
	if old_door_mesh != null:
		assert_false(old_door_mesh.visible, "Generated shell owns the visible storefront door")


func test_boot_shell_has_curated_retail_fixtures_without_old_placeholder_roots() -> void:
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	assert_not_null(shell, "Boot must generate the expanded expandable store shell")
	if shell == null:
		return
	for required: String in [
		"CheckoutRegisterDrawer",
		"CheckoutRegisterScreen",
		"StarterUsedShelfBacker",
		"StarterProductMotorwayKings",
		"StarterDisplayTableBacker",
		"StarterDisplayTableTray",
		"StarterProductConsoleNeoIgnite",
		"StockroomSupplyShelf",
		"StockroomReceivingTableTop",
	]:
		assert_not_null(
			shell.get_node_or_null(required), "Starter shell must include %s" % required
		)
	for removed: String in [
		"SpawnForegroundTradeBin",
		"StarterRegisterCounter",
		"StarterRegisterScreen",
		"BackWallLowerShelf",
		"BackWallUpperShelf",
		"CenterDisplayConsole",
		"CenterDisplayGameA",
		"CenterDisplayGameB",
		"FeaturedBoxArtBacking00",
		"ShelfHeroBacker",
		"ShelfHeroCase0000",
		"StockroomReceivingBacker",
		"StockroomWorkShelf",
		"CheckoutReceiptPrinterBase",
		"StockroomBoxA",
		"StockroomBoxB",
	]:
		assert_null(shell.get_node_or_null(removed), "Starter shell must not include %s" % removed)


func test_boot_shell_merchandise_density_reads_as_used_game_store() -> void:
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	assert_not_null(shell, "Boot must generate the expanded expandable store shell")
	if shell == null:
		return
	var sales_floor_count: int = 0
	for prefix: String in [
		"StarterProduct",
		"StarterUsedEmptySlot",
		"StarterDisplayEmptySlot",
	]:
		sales_floor_count += _count_children_with_prefix(shell, prefix)
	assert_gte(sales_floor_count, 10, "Boot shell needs curated sales-floor facings")
	assert_lte(sales_floor_count, 12, "Boot shell must separate density from SKU variety")
	assert_eq(
		_collect_distinct_product_item_ids(shell).size(),
		5,
		"Boot shell must expose five distinct starter sellable product types"
	)
	var stockroom_support_count: int = 0
	for prefix: String in [
		"StockroomSupplyBox",
		"StockroomSupplyLabel",
	]:
		stockroom_support_count += _count_children_with_prefix(shell, prefix)
	assert_lte(
		sales_floor_count + stockroom_support_count,
		28,
		"Boot shell must stay restrained and intentional across visible route props"
	)


func test_boot_shell_pairs_wall_shelf_with_starter_display_table() -> void:
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	var display_table: Node3D = _root.get_node_or_null("StoreSessionRestockShelf") as Node3D
	assert_not_null(shell, "Boot must generate the expanded expandable store shell")
	assert_not_null(display_table, "Starter display table must stay visible as the stocking target")
	if shell == null or display_table == null:
		return
	for required: String in [
		"StarterUsedShelfBacker",
		"StarterUsedShelfBottomLip",
		"StarterUsedShelfLeftDivider",
		"StarterUsedShelfCenterDivider",
		"StarterUsedShelfRightDivider",
		"StarterUsedShelfFloorFootprint",
		"StarterDisplayTableFootprint",
		"StarterDisplayTableBacker",
		"StarterDisplayTableBackRail",
		"StarterDisplayTableFrontLip",
		"StarterDisplayTableLeftDivider",
		"StarterDisplayTableRightDivider",
		"StarterDisplayTableRiser",
		"StarterDisplayTableTray",
		"StarterDisplayEmptySlot00",
		"StarterUsedEmptySlot00",
	]:
		assert_not_null(shell.get_node_or_null(required), "Sparse fixture cue missing: %s" % required)
	for required: String in [
		"ShelfBoard",
		"TableFrontApron",
		"EmptyOverlay",
		"MerchandisingFrame/BackPanel",
		"MerchandisingFrame/MiddleShelfLip",
		"MerchandisingFrame/BottomShelfLip",
		"MerchandisingFrame/LeftDivider",
		"MerchandisingFrame/RightDivider",
	]:
		assert_not_null(
			display_table.get_node_or_null(required),
			"Starter display table must read as a fixture before stock appears: %s" % required
		)


func test_checkout_counter_has_visible_register_cluster_inside_boot_shell() -> void:
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	assert_not_null(shell, "Boot must generate the expanded expandable store shell")
	if shell == null:
		return
	for required: String in [
		"CheckoutRegisterDrawer",
		"CheckoutRegisterCashSlot",
		"CheckoutRegisterNeck",
		"CheckoutRegisterScreen",
		"CheckoutRegisterScreenBezel",
		"CheckoutRegisterKeypad",
		"CheckoutReceiptSlip",
		"CheckoutCounterPaperStack",
		"CheckoutManagerNamePlate",
	]:
		assert_not_null(
			shell.get_node_or_null(required), "Checkout register prop missing: %s" % required
		)


func test_boot_shell_zone_practicals_preserve_readability_hierarchy() -> void:
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	assert_not_null(shell, "Boot must generate the expanded expandable store shell")
	if shell == null:
		return
	var checkout: OmniLight3D = shell.get_node_or_null("CheckoutRegisterPractical") as OmniLight3D
	var shelf_edge: OmniLight3D = shell.get_node_or_null("ShelfEdgeCoolPractical") as OmniLight3D
	var shelf_wall: OmniLight3D = shell.get_node_or_null("ShelfWallWarmPractical") as OmniLight3D
	var stockroom: OmniLight3D = shell.get_node_or_null("StockroomUtilityPractical") as OmniLight3D
	var entry: OmniLight3D = shell.get_node_or_null("EntryThresholdPractical") as OmniLight3D
	for light: OmniLight3D in [checkout, shelf_edge, shelf_wall, stockroom, entry]:
		assert_not_null(light, "Generated zone practical must exist")
		if light == null:
			continue
		assert_lte(
			light.light_energy,
			SHELL_PRACTICAL_MAX_ENERGY,
			"%s must stay local instead of flattening the store" % light.name
		)
		assert_lte(
			light.omni_range,
			SHELL_PRACTICAL_MAX_RANGE,
			"%s must stay scoped to its route zone" % light.name
		)
	if checkout != null:
		assert_gt(checkout.light_color.r, checkout.light_color.b, "Checkout practical must be warm")
	if shelf_edge != null:
		assert_gt(shelf_edge.light_color.b, shelf_edge.light_color.r, "Shelf edge must read cool")
	if stockroom != null:
		assert_gt(stockroom.light_color.b, stockroom.light_color.r, "Stockroom practical must read cool")
	if entry != null:
		assert_gt(entry.light_color.r, entry.light_color.b, "Entry threshold practical must stay warm")


func test_boot_shell_register_screen_glow_stays_readable_and_restrained() -> void:
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	assert_not_null(shell, "Boot must generate the expanded expandable store shell")
	if shell == null:
		return
	var screen: MeshInstance3D = shell.get_node_or_null("CheckoutRegisterScreen") as MeshInstance3D
	assert_not_null(screen, "Generated checkout screen must exist")
	if screen == null:
		return
	var material: StandardMaterial3D = screen.material_override as StandardMaterial3D
	assert_not_null(material, "Generated checkout screen must carry a StandardMaterial3D")
	if material == null:
		return
	assert_true(material.emission_enabled, "Generated checkout screen must emit restrained POS glow")
	assert_between(
		material.emission_energy_multiplier,
		GENERATED_REGISTER_SCREEN_MIN_EMISSION,
		GENERATED_REGISTER_SCREEN_MAX_EMISSION,
		"Generated register glow must be visible without becoming a bloom workaround"
	)


func test_stockroom_path_keeps_marker_without_workbench_clutter() -> void:
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	assert_not_null(shell, "Boot must generate the expanded expandable store shell")
	if shell == null:
		return
	for required: String in [
		"StockroomPartition",
		"StockroomSideReturn",
		"StockroomBackPanel",
		"StockroomPost",
		"StockroomHeader",
		"StockroomDoorJambRight",
		"StockroomDoorLintel",
		"StockroomFloorTape",
		"StockroomEmployeeStripeLeft",
		"StockroomEmployeeStripeRight",
		"StockroomDoorStop",
	]:
		assert_not_null(shell.get_node_or_null(required), "Stockroom marker missing: %s" % required)


func test_stockroom_boundary_matches_expanded_runtime_staff_corner() -> void:
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	assert_not_null(shell, "Boot must generate the expanded expandable store shell")
	if shell == null:
		return
	for node_path: String in [
		"StockroomPartition",
		"StockroomLeftSideReturn",
		"StockroomSideReturn",
		"StockroomBackPanel",
		"StockroomFloorTape",
		"StockroomSupplyShelf",
		"StockroomReceivingTableTop",
	]:
		var node: Node3D = shell.get_node_or_null(node_path) as Node3D
		assert_not_null(node, "Expanded stockroom node missing: %s" % node_path)
		if node == null:
			continue
		assert_between(
			node.position.x,
			3.10,
			5.95,
			"%s must stay inside the expanded staff stockroom corner" % node_path
		)
		assert_between(
			node.position.z,
			-7.55,
			-4.05,
			"%s must stay inside the expanded staff stockroom corner" % node_path
		)

	assert_eq(
		_count_children_with_prefix(shell, "StockroomSupplyBox"),
		5,
		"Expanded stockroom should carry enough storage boxes to read as working space"
	)
	for label: Label3D in _collect_visible_labels(shell):
		var text: String = label.text.strip_edges().to_lower()
		assert_false(
			text.contains("stockroom"), "%s must not rely on a stockroom wall label" % label.name
		)
		assert_false(
			text.contains("stock room"), "%s must not rely on a stock room wall label" % label.name
		)
		assert_false(
			text.contains("back room"), "%s must not rely on a back room wall label" % label.name
		)


func test_stockroom_has_working_room_depth_and_pickup_clearance() -> void:
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	var pickup: Node3D = _root.get_node_or_null("StoreSessionBackroomPickup") as Node3D
	assert_not_null(shell, "Boot must generate the expanded expandable store shell")
	assert_not_null(pickup, "StoreSessionBackroomPickup must exist")
	if shell == null or pickup == null:
		return
	var left_return: Node3D = shell.get_node_or_null("StockroomLeftSideReturn") as Node3D
	var right_return: Node3D = shell.get_node_or_null("StockroomSideReturn") as Node3D
	var back_panel: Node3D = shell.get_node_or_null("StockroomBackPanel") as Node3D
	var threshold: Node3D = shell.get_node_or_null("StockroomFloorTape") as Node3D
	assert_not_null(left_return, "Expanded stockroom must have a left side return")
	assert_not_null(right_return, "Expanded stockroom must have a right side return")
	assert_not_null(back_panel, "Expanded stockroom must have a back panel")
	assert_not_null(threshold, "Expanded stockroom must have a threshold marker")
	if left_return == null or right_return == null or back_panel == null or threshold == null:
		return
	var left_size: Vector3 = _box_size(left_return)
	var right_size: Vector3 = _box_size(right_return)
	var back_size: Vector3 = _box_size(back_panel)
	var room_width: float = (
		(right_return.position.x + right_size.x * 0.5)
		- (left_return.position.x - left_size.x * 0.5)
	)
	var room_depth: float = threshold.position.z - (back_panel.position.z - back_size.z * 0.5)
	var room_area: float = room_width * room_depth
	assert_gte(room_width, 2.65, "Stockroom must be wide enough to read as a room")
	assert_gte(room_depth, 3.00, "Stockroom must have working depth behind the doorway")
	assert_gte(room_area, 8.00, "Stockroom footprint must exceed closet-scale area")
	assert_between(
		pickup.position.x,
		left_return.position.x + 0.70,
		right_return.position.x - 0.70,
		"Pickup must leave side clearance for receiving and sorting movement"
	)


func test_stockroom_threshold_to_pickup_route_stays_clear() -> void:
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	var pickup: Node3D = _root.get_node_or_null("StoreSessionBackroomPickup") as Node3D
	assert_not_null(shell, "Boot must generate the expanded expandable store shell")
	assert_not_null(pickup, "StoreSessionBackroomPickup must exist")
	if shell == null or pickup == null:
		return
	var threshold: Node3D = shell.get_node_or_null("StockroomFloorTape") as Node3D
	assert_not_null(threshold, "StockroomFloorTape must mark the closet threshold")
	if threshold == null:
		return
	for prop_path: String in [
		"StockroomReceivingTableTop",
		"StockroomSupplyShelf",
		"StockroomSupplyBox00",
		"StockroomSupplyBox01",
		"StockroomSupplyBox02",
		"StockroomSupplyBox03",
		"StockroomSupplyBox04",
		"StockroomHandTruckHint",
	]:
		var prop: Node3D = shell.get_node_or_null(prop_path) as Node3D
		assert_not_null(prop, "Stockroom support prop missing: %s" % prop_path)
		if prop == null:
			continue
		assert_gt(
			_flat_distance_to_segment(prop.position, threshold.position, pickup.position),
			0.34,
			"%s must not sit in the threshold-to-pickup route" % prop_path
		)


func test_manager_customer_proxy_reads_as_person_silhouette() -> void:
	var proxy: Node3D = _root.get_node_or_null("StoreSessionDayOneCustomer/CustomerProxy") as Node3D
	assert_not_null(proxy, "Customer proxy must be generated for the first route target")
	if proxy == null:
		return
	for required: String in [
		"Body",
		"ApronPanel",
		"Head",
		"HairCap",
		"EyeLine",
		"ArmLeft",
		"ArmRight",
		"LegLeft",
		"LegRight",
		"ShoeLeft",
		"ShoeRight",
		"Badge",
		"NameTag",
		"Lanyard",
		"Clipboard",
	]:
		var part: Node3D = proxy.get_node_or_null(required) as Node3D
		assert_not_null(part, "Person silhouette part missing: %s" % required)
		if part != null:
			assert_true(part.visible, "%s must be visible for the first manager beat" % required)


func test_critical_day_one_anchors_move_into_the_expanded_runtime_footprint() -> void:
	_assert_position_near("PlayerEntrySpawn", Vector3(0.0, 0.0, 7.85), 0.05)
	_assert_position_near("EntranceDoor", Vector3(0.0, 0.0, 9.62), 0.05)
	_assert_position_near("checkout_counter", Vector3(4.25, 0.0, 5.55), 0.05)
	_assert_position_near("StoreSessionDayOneCustomer", Vector3(3.55, 0.0, 6.65), 0.05)
	_assert_position_near("StoreSessionRestockShelf", Vector3(-2.65, 0.0, 1.05), 0.05)
	_assert_position_near("StoreSessionBackroomPickup", Vector3(4.80, 0.0, -6.85), 0.05)


func test_player_spawn_bounds_match_expanded_runtime_shell() -> void:
	var spawn: Marker3D = _root.get_node_or_null("PlayerEntrySpawn") as Marker3D
	assert_not_null(spawn, "PlayerEntrySpawn must exist")
	if spawn == null:
		return
	assert_eq(spawn.get_meta("bounds_min"), Vector3(-5.45, 0.0, -7.30))
	assert_eq(spawn.get_meta("bounds_max"), Vector3(5.45, 0.0, 8.65))
	assert_between(spawn.position.x, -5.45, 5.45, "Spawn X must be inside player bounds")
	assert_between(spawn.position.z, -7.30, 8.65, "Spawn Z must be inside player bounds")


func test_customer_browse_waypoints_stay_out_of_stockroom() -> void:
	var nav_config: Node = _root.get_node_or_null("CustomerNavConfig")
	assert_not_null(nav_config, "CustomerNavConfig must exist")
	if nav_config == null:
		return
	for marker_name: String in [
		"BrowseWaypoint01",
		"BrowseWaypoint02",
		"BrowseWaypoint03",
		"BrowseWaypoint04",
		"CheckoutApproach",
	]:
		var marker: Marker3D = nav_config.get_node_or_null(marker_name) as Marker3D
		assert_not_null(marker, "%s must exist" % marker_name)
		if marker == null:
			continue
		var in_stockroom: bool = (
			marker.position.x >= 3.10
			and marker.position.x <= 5.95
			and marker.position.z >= -7.55
			and marker.position.z <= -4.05
		)
		assert_false(
			in_stockroom, "%s must not route customers into the stock closet" % marker_name
		)


func test_shell_signs_do_not_render_mirrored_from_the_back_side() -> void:
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	assert_not_null(shell, "Boot must generate the expanded expandable store shell")
	if shell == null:
		return
	for label_path: String in [
		"StarterSignLabel",
		"GamesBayLabel",
		"ExpansionLabel",
		"CheckoutTradeInsText",
		"StockroomWallTaskText",
	]:
		var label: Label3D = shell.get_node_or_null(label_path) as Label3D
		assert_not_null(label, "%s must exist" % label_path)
		if label == null:
			continue
		assert_false(label.double_sided, "%s must not mirror from behind" % label_path)


func test_customer_facing_product_props_are_present_but_curated() -> void:
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	assert_not_null(shell, "Boot must generate the expanded expandable store shell")
	if shell == null:
		return
	for required: String in [
		"StarterProductConsoleNeoIgnite",
		"StarterProductMotorwayKings",
		"StarterProductKingdomEmbers",
		"StarterProductTorqueForce",
		"StarterProductGridiron",
		"StockroomSupplyBox00",
		"StockroomSupplyBox02",
	]:
		assert_not_null(
			shell.get_node_or_null(required), "Starter shell product prop missing: %s" % required
		)
	for removed: String in [
		"StarterShelfCase00",
		"StarterShelfTopCase00",
		"StarterUsedCase00",
		"CenterDisplayConsole",
		"CenterDisplayGameA",
		"FeaturedBoxArtBacking00",
		"SpawnForegroundTradeCase00",
		"ShelfEndcapFaceout00",
		"CheckoutImpulseFace00",
	]:
		assert_null(
			shell.get_node_or_null(removed), "Starter shell must not own old prop %s" % removed
		)
	for product: Node in _collect_product_displays(shell):
		assert_eq(str(product.get_meta("visual_source", "")), "product_visual_factory")
		assert_not_null(product.get_node_or_null("ProductPriceTag"))


func test_boot_shell_avoids_product_name_spam() -> void:
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	assert_not_null(shell, "Boot must generate the expanded expandable store shell")
	if shell == null:
		return
	var visible_text_count: int = 0
	for label: Label3D in _collect_visible_labels(shell):
		if label.text.strip_edges() != "":
			visible_text_count += 1
	assert_lte(
		visible_text_count, 2, "Generated store shell should not spam product/category labels"
	)


func _assert_position_near(path: String, expected: Vector3, tolerance: float) -> void:
	var node: Node3D = _root.get_node_or_null(path) as Node3D
	assert_not_null(node, "%s must exist" % path)
	if node == null:
		return
	assert_almost_eq(node.position.x, expected.x, tolerance, "%s.x" % path)
	assert_almost_eq(node.position.y, expected.y, tolerance, "%s.y" % path)
	assert_almost_eq(node.position.z, expected.z, tolerance, "%s.z" % path)


func _count_children_with_prefix(parent: Node, prefix: String) -> int:
	var total := 0
	for child: Node in parent.get_children():
		if str(child.name).begins_with(prefix):
			total += 1
	return total


func _collect_distinct_product_item_ids(parent: Node) -> PackedStringArray:
	var ids: PackedStringArray = []
	for product: Node in _collect_product_displays(parent):
		var item_id: String = str(product.get_meta("product_item_id", ""))
		if not item_id.is_empty() and not ids.has(item_id):
			ids.append(item_id)
	return ids


func _collect_product_displays(parent: Node) -> Array[Node]:
	var products: Array[Node] = []
	for child: Node in parent.get_children():
		if child.is_in_group("product_display"):
			products.append(child)
		products.append_array(_collect_product_displays(child))
	return products


func _box_size(node: Node3D) -> Vector3:
	var mesh_instance: MeshInstance3D = node as MeshInstance3D
	if mesh_instance == null:
		mesh_instance = node.get_node_or_null("Visual") as MeshInstance3D
	if mesh_instance == null:
		return Vector3.ZERO
	var box_mesh: BoxMesh = mesh_instance.mesh as BoxMesh
	if box_mesh == null:
		return Vector3.ZERO
	return box_mesh.size


func _flat_distance_to_segment(point: Vector3, start: Vector3, end: Vector3) -> float:
	var point_2d := Vector2(point.x, point.z)
	var start_2d := Vector2(start.x, start.z)
	var end_2d := Vector2(end.x, end.z)
	var segment := end_2d - start_2d
	var length_squared: float = segment.length_squared()
	if length_squared <= 0.0001:
		return point_2d.distance_to(start_2d)
	var t: float = clampf((point_2d - start_2d).dot(segment) / length_squared, 0.0, 1.0)
	return point_2d.distance_to(start_2d + segment * t)


func _collect_visible_labels(parent: Node) -> Array[Label3D]:
	var labels: Array[Label3D] = []
	for child: Node in parent.get_children():
		if child is Label3D and (child as Label3D).visible:
			labels.append(child as Label3D)
		labels.append_array(_collect_visible_labels(child))
	return labels
