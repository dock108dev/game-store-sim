## gdlint:disable=max-public-methods,max-file-lines
extends GutTest

# See docs/audits/cleanup-report.md: this shell acceptance suite stays together
# until bootstrap, floor-plan, and visual-role assertions can split cleanly.
const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"
const SHELL_PRACTICAL_MAX_ENERGY: float = 0.65
const SHELL_PRACTICAL_MAX_RANGE: float = 3.8
const PRACTICAL_SOURCE_MAX_EMISSION: float = 0.55
const GENERATED_REGISTER_SCREEN_MIN_EMISSION: float = 0.42
const GENERATED_REGISTER_SCREEN_MAX_EMISSION: float = 0.60
const ZONE_COLOR_DELTA_MIN: float = 0.05
const STOCKROOM_CONNECTION_TOLERANCE: float = 0.12
const ExpandableStoreShellRuntimeScript: GDScript = preload(
	"res://game/scripts/visuals/expandable_store_shell_runtime.gd"
)
const StoreVisualLayoutScript: GDScript = preload(
	"res://game/scripts/visuals/store_visual_layout.gd"
)
const VisualValueUtilScript: GDScript = preload("res://game/scripts/visuals/visual_value_util.gd")

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
			assert_almost_eq(floor_mesh.size.x, 16.0, 0.01, "StarterFloor width")
			assert_almost_eq(floor_mesh.size.z, 20.0, 0.01, "StarterFloor depth")
		assert_almost_eq(floor.position.z, 0.0, 0.01, "StarterFloor center Z")

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
		"StarterMotorwayKings",
		"StarterDisplayTableBacker",
		"StarterDisplayTableTray",
		"StarterConsoleNeoIgnite",
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
		"StarterConsole",
		"StarterMotorway",
		"StarterKingdom",
		"StarterUsedEmptySlot",
		"StarterDisplayEmptySlot",
	]:
		sales_floor_count += _count_children_with_prefix(shell, prefix)
	assert_gte(sales_floor_count, 8, "Boot shell needs curated sales-floor facings")
	assert_lte(sales_floor_count, 10, "Boot shell must separate density from SKU variety")
	assert_eq(
		_collect_distinct_product_item_ids(shell),
		_expected_first_delivery_ids(),
		"Boot shell must expose only the first-delivery starter product types"
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
		"StarterUsedShelfTopLip",
		"StarterUsedShelfMiddleLip",
		"StarterUsedShelfBottomLip",
		"StarterUsedShelfLeftDivider",
		"StarterUsedShelfCenterDivider",
		"StarterUsedShelfRightDivider",
		"StarterUsedShelfPriceTag00",
		"StarterUsedShelfRightEmptyBay",
		"StarterUsedShelfRightPriceTag",
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
		assert_not_null(
			shell.get_node_or_null(required), "Sparse fixture cue missing: %s" % required
		)
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
	var stockroom_pickup: OmniLight3D = (
		shell.get_node_or_null("StockroomPickupWarmPractical") as OmniLight3D
	)
	var entry: OmniLight3D = shell.get_node_or_null("EntryThresholdPractical") as OmniLight3D
	for light: OmniLight3D in [
		checkout,
		shelf_edge,
		shelf_wall,
		stockroom,
		stockroom_pickup,
		entry,
	]:
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
		assert_gt(
			stockroom.light_color.b, stockroom.light_color.r, "Stockroom practical must read cool"
		)
	if entry != null:
		assert_gt(
			entry.light_color.r, entry.light_color.b, "Entry threshold practical must stay warm"
		)


func test_boot_shell_practicals_have_physical_sources_and_plane_metadata() -> void:
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	assert_not_null(shell, "Boot must generate the expanded expandable store shell")
	if shell == null:
		return
	var practical_sources: Dictionary = {
		"CheckoutRegisterPracticalSource": "register",
		"CrtSignGlowPracticalSource": "crt_sign",
		"StockroomStripLightSource": "stockroom_strip",
		"DisplayTableUndershelfPracticalSource": "display_table_undershelf",
		"StorefrontCanopyGlowSource": "storefront",
	}
	for node_path: String in practical_sources:
		var source: MeshInstance3D = shell.get_node_or_null(node_path) as MeshInstance3D
		assert_not_null(source, "Practical source mesh missing: %s" % node_path)
		if source == null:
			continue
		_assert_panel_or_strip(shell, node_path)
		assert_true(
			bool(source.get_meta("practical_light_source", false)),
			"%s must declare itself as a practical source" % node_path
		)
		assert_eq(
			str(source.get_meta("practical_light_role", "")),
			String(practical_sources[node_path]),
			"%s must expose its lighting role" % node_path
		)
		assert_false(
			str(source.get_meta("visual_plane", "")).is_empty(),
			"%s must belong to a reviewable visual plane" % node_path
		)
		assert_eq(
			str(source.get_meta("route_critical_shadow_policy", "")),
			"preserve",
			"%s must document route-anchor shadow preservation" % node_path
		)
		var mat: StandardMaterial3D = source.material_override as StandardMaterial3D
		assert_not_null(mat, "%s must carry an emissive source material" % node_path)
		if mat == null:
			continue
		assert_true(mat.emission_enabled, "%s must be visible as glow geometry" % node_path)
		assert_lte(
			mat.emission_energy_multiplier,
			PRACTICAL_SOURCE_MAX_EMISSION,
			"%s must stay a practical cue instead of a bloom workaround" % node_path
		)


func test_boot_shell_practical_sources_separate_route_depth_without_floor_planes() -> void:
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	assert_not_null(shell, "Boot must generate the expanded expandable store shell")
	if shell == null:
		return
	for removed: String in [
		"SpawnForegroundWarmPlane",
		"MainMidgroundWorkSurfacePlane",
		"BackWallBackgroundCoolPlane",
		"StockroomCoolBackgroundPlane",
	]:
		assert_null(shell.get_node_or_null(removed), "%s must not render as a helper plane" % removed)
	var register_source: MeshInstance3D = (
		shell.get_node_or_null("CheckoutRegisterPracticalSource") as MeshInstance3D
	)
	var display_source: MeshInstance3D = (
		shell.get_node_or_null("DisplayTableUndershelfPracticalSource") as MeshInstance3D
	)
	var sign_source: MeshInstance3D = (
		shell.get_node_or_null("CrtSignGlowPracticalSource") as MeshInstance3D
	)
	var stockroom_source: MeshInstance3D = (
		shell.get_node_or_null("StockroomStripLightSource") as MeshInstance3D
	)
	for source: MeshInstance3D in [register_source, display_source, sign_source, stockroom_source]:
		assert_not_null(source, "Practical source must exist")
		if source == null:
			continue
		assert_false(
			str(source.get_meta("visual_plane", "")).is_empty(),
			"%s must declare its depth plane through metadata" % source.name
		)
		assert_eq(
			str(source.get_meta("route_critical_shadow_policy", "")),
			"preserve",
			"%s must preserve route-critical object readability" % source.name
		)
	if (
		register_source == null
		or display_source == null
		or sign_source == null
		or stockroom_source == null
	):
		return
	assert_gt(register_source.position.z, display_source.position.z)
	assert_gt(display_source.position.z, sign_source.position.z)
	var display_mat: StandardMaterial3D = display_source.material_override as StandardMaterial3D
	var stockroom_mat: StandardMaterial3D = stockroom_source.material_override as StandardMaterial3D
	assert_not_null(display_mat, "Display practical source must carry material")
	assert_not_null(stockroom_mat, "Stockroom practical source must carry material")
	if display_mat == null or stockroom_mat == null:
		return
	assert_gte(
		_color_distance(display_mat.albedo_color, stockroom_mat.albedo_color),
		ZONE_COLOR_DELTA_MIN * 2.0,
		"Sales-floor and stockroom practicals must stay visually distinct"
	)


func test_boot_shell_generated_zone_surfaces_keep_store_readable() -> void:
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	assert_not_null(shell, "Boot must generate the expanded expandable store shell")
	if shell == null:
		return
	for required: String in [
		"SalesFloorWarmBackWallPanel",
		"ShelfWallCoolReadPanel",
		"ShelfWallAccentTopRail",
		"ShelfWallSlatRail00",
		"ShelfWallSlatRail01",
		"ShelfWallSlatRail02",
		"ShelfWallSlatRail03",
		"ShelfWallCategoryPlaque",
		"ShelfWallFeatureFacing",
		"CheckoutServiceWarmWallPanel",
		"CheckoutCounterEdgeLine",
		"CheckoutServiceMenuBoard",
		"CheckoutServiceMenuHeader",
		"CheckoutServiceMenuBottomRule",
		"QueueLaneStanchionPost00",
		"QueueLaneStanchionPost01",
		"QueueLaneStanchionPost02",
		"QueueLaneCounterRope",
		"StockroomCoolDoorRevealLeft",
		"StockroomCoolDoorRevealRight",
		"StockroomCoolDoorRevealHeader",
		"StockroomPickupWallTaskCard",
		"FrontDoorLowerKickPlate",
		"FrontDoorHorizontalPushBar",
		"ShelfLifeTradePoster/Panel",
		"ShelfLifeRepairPoster/Panel",
		"ShelfLifeQueueCardPanel",
	]:
		assert_not_null(
			shell.get_node_or_null(required), "Generated zone surface missing: %s" % required
		)
	var shelf_panel: StandardMaterial3D = _material_for(shell, "ShelfWallCoolReadPanel")
	var checkout_panel: StandardMaterial3D = _material_for(shell, "CheckoutServiceWarmWallPanel")
	var stockroom_reveal: StandardMaterial3D = _material_for(shell, "StockroomCoolDoorRevealLeft")
	var entry_plate: StandardMaterial3D = _material_for(shell, "FrontDoorLowerKickPlate")
	var menu_board: StandardMaterial3D = _material_for(shell, "CheckoutServiceMenuBoard")
	var queue_rope: StandardMaterial3D = _material_for(shell, "QueueLaneCounterRope")
	assert_not_null(shelf_panel, "Shelf zone panel must carry material")
	assert_not_null(checkout_panel, "Checkout zone panel must carry material")
	assert_not_null(stockroom_reveal, "Stockroom reveal must carry material")
	assert_not_null(entry_plate, "Entry door plate must carry material")
	assert_not_null(menu_board, "Checkout service menu board must carry material")
	assert_not_null(queue_rope, "Queue lane rope must carry material")
	if shelf_panel != null:
		assert_gte(
			shelf_panel.albedo_color.b - shelf_panel.albedo_color.r,
			ZONE_COLOR_DELTA_MIN,
			"Shelf wall panel must cool the shelf read against warm wood"
		)
	if checkout_panel != null:
		assert_gte(
			checkout_panel.albedo_color.r - checkout_panel.albedo_color.b,
			ZONE_COLOR_DELTA_MIN,
			"Checkout service panel must stay warm"
		)
	if stockroom_reveal != null:
		assert_gte(
			stockroom_reveal.albedo_color.b - stockroom_reveal.albedo_color.r,
			ZONE_COLOR_DELTA_MIN,
			"Stockroom doorway reveal must read cooler than the sales floor"
		)
	if entry_plate != null and checkout_panel != null:
		assert_lt(
			_brightest_channel(entry_plate.albedo_color),
			_brightest_channel(checkout_panel.albedo_color),
			"Entry door plate must orient the exit without overpowering checkout"
		)
	if menu_board != null and checkout_panel != null:
		assert_eq(
			menu_board.albedo_color,
			checkout_panel.albedo_color,
			"Checkout service menu board must share checkout service material language"
		)
	if queue_rope != null and checkout_panel != null:
		assert_gte(
			queue_rope.albedo_color.r,
			checkout_panel.albedo_color.r,
			"Queue rope should read as part of the warm checkout/manager lane"
		)
	for index: int in range(3):
		var marker: Node3D = _root.get_node_or_null("QueueMarker%d" % (index + 1)) as Node3D
		var post: Node3D = shell.get_node_or_null("QueueLaneStanchionPost%02d" % index) as Node3D
		assert_not_null(marker, "Queue marker %d must exist" % (index + 1))
		assert_not_null(post, "Queue lane post %d must exist" % index)
		if marker == null or post == null:
			continue
		assert_lte(
			_flat_xz_distance(marker.global_position, post.global_position),
			0.80,
			"Generated queue post %d must stay near the queue footprint" % index
		)


func test_floor_treatment_does_not_expose_route_cue_geometry() -> void:
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	assert_not_null(shell, "Boot must generate the expanded expandable store shell")
	if shell == null:
		return
	for removed: String in [
		"FloorTrafficScuff00",
		"CheckoutQueueFloorRail",
		"StarterDisplayFloorRail",
		"StockroomThresholdFloorRail",
		"SpawnAisleRunner",
		"StarterAisleMat",
		"CheckoutServiceFloorPool",
		"QueueLaneWarmInlay",
		"QueueLaneMarkerPuck00",
		"StockroomUtilityFloorApron",
		"StockroomWarmPickupSightPatch",
		"EntryMutedFloorMat",
		"EntryWarmSightlineStrip",
		"OnboardingRouteCues/CheckoutBackroomFloorWear00",
	]:
		assert_null(shell.get_node_or_null(removed), "%s must not render as floor guidance" % removed)
	for required: String in [
		"FloorBoardSeam00",
		"StockroomFloorTape",
		"CheckoutQueueRopeFront",
		"QueueLaneCounterRope",
		"StarterUsedShelfPriceTag00",
		"ProductPriceTag",
	]:
		assert_not_null(
			shell.find_child(required, true, false),
			"Floor/readability hierarchy node missing: %s" % required
		)
	var floor_mat: StandardMaterial3D = _material_for(shell, "StarterFloor")
	var seam_mat: StandardMaterial3D = _material_for(shell, "FloorBoardSeam00")
	var checkout_rope_mat: StandardMaterial3D = _material_for(shell, "CheckoutQueueRopeFront")
	var stockroom_sill_mat: StandardMaterial3D = _material_for(shell, "StockroomFloorTape")
	assert_not_null(floor_mat, "Starter floor must carry material")
	assert_not_null(seam_mat, "Floor seam must carry material")
	assert_not_null(checkout_rope_mat, "Checkout queue rope must carry material")
	assert_not_null(stockroom_sill_mat, "Stockroom threshold sill must carry material")
	if (
		floor_mat == null
		or seam_mat == null
		or checkout_rope_mat == null
		or stockroom_sill_mat == null
	):
		return
	var seam_delta: float = _color_distance(floor_mat.albedo_color, seam_mat.albedo_color)
	var checkout_delta: float = _color_distance(
		floor_mat.albedo_color, checkout_rope_mat.albedo_color
	)
	var stockroom_delta: float = _color_distance(
		floor_mat.albedo_color, stockroom_sill_mat.albedo_color
	)
	assert_lt(seam_delta, checkout_delta, "Floor seams must be quieter than checkout cues")
	assert_lt(seam_delta, stockroom_delta, "Floor seams must be quieter than stockroom cues")


func test_wall_posters_use_store_identity_panels_not_random_decals() -> void:
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	assert_not_null(shell, "Boot must generate the expanded expandable store shell")
	if shell == null:
		return
	for poster_path: String in ["ShelfLifeTradePoster", "ShelfLifeRepairPoster"]:
		var poster: Node3D = shell.get_node_or_null(poster_path) as Node3D
		assert_not_null(poster, "Store identity poster missing: %s" % poster_path)
		if poster == null:
			continue
		assert_eq(
			str(poster.get_meta("visual_source", "")),
			"store_identity_poster",
			"%s must be declared as store identity dressing" % poster_path
		)
		for child_name: String in ["Panel", "TopRail", "BottomRail", "CaseStripe00"]:
			var child_path: String = "%s/%s" % [poster_path, child_name]
			assert_not_null(
				shell.get_node_or_null(child_path), "Poster detail missing: %s" % child_path
			)
			_assert_panel_or_strip(shell, child_path)
	for label: Label3D in _collect_visible_labels(shell):
		var text: String = label.text.strip_edges().to_lower()
		assert_false(text.contains("debug"), "%s must not expose debug text" % label.name)
		assert_false(
			text.contains("placeholder"), "%s must not expose placeholder text" % label.name
		)
		assert_false(text.contains("zone"), "%s must not expose zone-label text" % label.name)


func test_spawn_view_supports_store_identity_and_route_cues() -> void:
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	assert_not_null(shell, "Boot must generate the expanded expandable store shell")
	if shell == null:
		return
	for required: String in [
		"StoreIdentityWallPanel",
		"StoreIdentitySignCanopy",
		"StoreIdentitySignUnderRail",
		"StoreIdentitySignBracketLeft",
		"StoreIdentitySignBracketRight",
		"StoreIdentityProductFacing00",
		"StoreIdentityProductFacing01",
		"StoreIdentityProductFacing02",
		"StoreIdentityMerchShelfRail",
		"StoreIdentitySignWashPractical",
		"StorefrontCanopyLabel",
		"FrontGlassLeftLite",
		"FrontGlassRightLite",
		"MallSideTransomGlow",
		"StoreHoursPlaque",
		"FrontWindowDecalLeft",
		"ThresholdFloorInlay",
		"WelcomeMatInset",
		"FrontDoorLowerKickPlate",
		"FrontDoorHorizontalPushBar",
		"WindowDisplayCartridgeStack",
		"CheckoutQueueStanchionPost00",
		"CheckoutQueueStanchionPost01",
		"CheckoutQueueStanchionPost02",
		"CheckoutQueueRopeFront",
		"StarterDisplayShelfEdgeCard",
		"StockroomDoorDirectionPlaque",
		"CheckoutServiceWarmWallPanel",
		"ShelfWallCoolReadPanel",
		"StockroomCoolDoorRevealHeader",
	]:
		assert_not_null(
			shell.get_node_or_null(required), "Spawn readability cue missing: %s" % required
		)
	var sign_label: Label3D = shell.get_node_or_null("StarterSignLabel") as Label3D
	var identity_panel: Node3D = shell.get_node_or_null("StoreIdentityWallPanel") as Node3D
	var checkout_rope: Node3D = shell.get_node_or_null("CheckoutQueueRopeFront") as Node3D
	var starter_card: Node3D = shell.get_node_or_null("StarterDisplayShelfEdgeCard") as Node3D
	var stockroom_plaque: Node3D = shell.get_node_or_null("StockroomDoorDirectionPlaque") as Node3D
	assert_not_null(sign_label, "Store sign must stay visible at spawn")
	assert_not_null(identity_panel, "Store sign must sit in a supported wall treatment")
	assert_not_null(checkout_rope, "Manager/register fixture cue must be visible from spawn")
	assert_not_null(starter_card, "Starter display fixture cue must be visible from spawn")
	assert_not_null(stockroom_plaque, "Stockroom entrance fixture cue must be visible from spawn")
	if sign_label != null and identity_panel != null:
		assert_eq(sign_label.text, "RETRO REWIND", "Spawn sign must carry the store identity")
		assert_almost_eq(
			identity_panel.position.x,
			sign_label.position.x,
			0.05,
			"Identity panel should frame the store identity sign"
		)
	if checkout_rope != null:
		assert_gt(
			checkout_rope.position.x, 2.0, "Checkout cue should lead toward the manager/register"
		)
	if starter_card != null:
		assert_lt(starter_card.position.x, -2.0, "Starter display cue should pull left from spawn")
	if stockroom_plaque != null:
		assert_lt(
			stockroom_plaque.position.z,
			-4.0,
			"Stockroom cue should sit deeper than sales floor cues"
		)


func test_spawn_view_cues_are_panels_and_strips_not_debug_blocks() -> void:
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	assert_not_null(shell, "Boot must generate the expanded expandable store shell")
	if shell == null:
		return
	for node_path: String in [
		"StoreIdentityWallPanel",
		"StoreIdentitySignCanopy",
		"StoreIdentitySignUnderRail",
		"StoreIdentitySignBracketLeft",
		"StoreIdentitySignBracketRight",
		"StoreIdentityProductFacing00",
		"StoreIdentityProductFacing01",
		"StoreIdentityProductFacing02",
		"StoreIdentityMerchShelfRail",
		"FrontGlassLeftLite",
		"FrontGlassRightLite",
		"MallSideTransomGlow",
		"StoreHoursPlaque",
		"FrontWindowDecalLeft",
		"ThresholdFloorInlay",
		"WelcomeMatInset",
		"FrontDoorLowerKickPlate",
		"FrontDoorHorizontalPushBar",
		"WindowDisplayCartridgeStack",
		"CheckoutQueueRopeFront",
		"StarterDisplayShelfEdgeCard",
		"StockroomDoorDirectionPlaque",
	]:
		_assert_panel_or_strip(shell, node_path)


func test_storefront_threshold_identity_is_visual_only_generated_shell() -> void:
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	assert_not_null(shell, "Boot must generate the expanded expandable store shell")
	if shell == null:
		return
	for node_path: String in [
		"StorefrontCanopyLabel",
		"FrontGlassLeftLite",
		"FrontGlassRightLite",
		"MallSideTransomGlow",
		"StoreHoursPlaque",
		"StoreHoursPlaqueText",
		"FrontWindowDecalLeft",
		"FrontWindowDecalRight",
		"ThresholdFloorInlay",
		"WelcomeMatInset",
		"MallTileToStoreFloorBreak",
		"EntryReturnLeftTrim",
		"EntryReturnRightTrim",
		"WindowDisplayCartridgeStack",
	]:
		var node: Node = shell.get_node_or_null(node_path)
		assert_not_null(node, "Storefront threshold identity missing: %s" % node_path)
		if node == null:
			continue
		assert_true(
			bool(node.get_meta("storefront_threshold_identity", false)),
			"%s must be declared as storefront identity" % node_path
		)
		assert_true(bool(node.get_meta("visual_only", false)), "%s must be visual-only" % node_path)
		assert_false(node is CollisionObject3D, "%s must not add route collision" % node_path)
		assert_false(node is Interactable, "%s must not add an interaction target" % node_path)
		assert_false(node is Area3D, "%s must not add a route or trigger area" % node_path)
	var canopy_label: Label3D = shell.get_node_or_null("StorefrontCanopyLabel") as Label3D
	assert_not_null(canopy_label, "Front canopy must carry a physical store-name label")
	if canopy_label != null:
		assert_eq(canopy_label.text, "RETRO REWIND")


func test_failed_density_layers_are_not_part_of_boot_shell() -> void:
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	assert_not_null(shell, "Boot must generate the expanded expandable store shell")
	if shell == null:
		return
	for removed: String in [
		"StoreArtCheckoutRetailWall",
		"StoreArtDenseShelfWall",
		"StoreArtDisplayTableMerch",
		"StoreArtStockroomWorkZone",
		"StoreArtStorefrontWindowDisplay",
		"Phase4ShelfCartridgeRun00",
		"Phase4ShelfConsoleBox00",
		"Phase4ShelfControllerLoose00",
		"Phase4CheckoutPendingTray",
		"Phase4MallPlanter00",
		"StockroomExpandedFrontPartitionHighA",
		"StockroomExpandedFrontPartitionHighB",
	]:
		assert_null(
			shell.get_node_or_null(removed), "Failed visual layer must stay removed: %s" % removed
		)


func test_reference_inspired_surfaces_replace_random_blockout_clutter() -> void:
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	assert_not_null(shell, "Boot must generate the expanded expandable store shell")
	if shell == null:
		return
	for required: String in [
		"ReferenceSalesWallPaintField",
		"ReferenceManagerOfficeWallField",
		"ReferenceStockroomBluePaintField",
		"ReferenceCeilingGridRunX00",
		"ReferenceOfficeUnlockBoard",
		"ReferenceOfficeWoodPanelStrip00",
		"ReferenceCheckoutWoodDeskReturn",
		"ReferenceCheckoutRedServicePanel",
		"ReferenceDisplayCuttingMat",
		"ReferenceDisplayLowGlassCase",
		"ReferenceDisplayGlassCaseGame00",
		"ReferenceDisplayOpenCartonBase",
		"ReferenceDisplayStoolSeat",
		"ReferenceUsedGamesHeaderPanel",
		"ReferenceShelfGameFacing00",
		"ReferenceShelfGameFacing11",
		"ReferenceStockroomPegboard",
		"ReferenceStockroomWorkOrderBoard",
		"ReferenceStockroomDoorLabelPlate",
		"ReferenceWindowStaffPicksPlinth",
		"ReferenceEntryPlantPot",
		"ReferenceEntryPlantMass",
	]:
		assert_not_null(
			shell.get_node_or_null(required), "Inspired fixture cue missing: %s" % required
		)
	assert_gte(
		_count_children_with_prefix(shell, "ReferenceShelfGameFacing"),
		12,
		"Shelf wall should use many flat facings instead of a few black placeholder boxes"
	)
	assert_gte(
		_count_children_with_prefix(shell, "ReferenceOfficeUnlockCard"),
		10,
		"Office wall should read like a real progression board"
	)
	assert_gte(
		_count_children_with_prefix(shell, "ReferenceDisplayCartonGame"),
		5,
		"Starter display should use open-carton product silhouettes instead of solid blocks"
	)


func test_close_read_surfaces_are_authored_fixtures_not_blank_slabs() -> void:
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	assert_not_null(shell, "Boot must generate the expanded expandable store shell")
	if shell == null:
		return
	for required: String in [
		"ExpansionShutterSlat00",
		"ExpansionPreviewPosterPanel",
		"FrontDoorCenterMullion",
		"FrontDoorLogoDecal",
		"FrontDoorHorizontalPushBar",
		"FrontDoorOpenHoursDecal",
		"WelcomeMatRib00",
		"StockroomDoorCrossbar",
		"StockroomDoorStaffCard",
		"ReferenceStockroomDoorLabelText",
	]:
		assert_not_null(
			shell.get_node_or_null(required), "Close-read fixture cue missing: %s" % required
		)
	var expansion_panel: Node3D = shell.get_node_or_null("ExpansionDoorPanel") as Node3D
	assert_not_null(expansion_panel, "Expansion door shell panel must still exist")
	if expansion_panel != null:
		var expansion_size: Vector3 = _box_size(expansion_panel)
		assert_lte(
			expansion_size.z,
			2.65,
			"ExpansionDoorPanel must not dominate the wall as a blank oversized slab"
		)
		assert_lte(
			expansion_size.y,
			2.15,
			"ExpansionDoorPanel should read as a shutter panel below header height"
		)
	var glass_case: Node3D = shell.get_node_or_null("ReferenceDisplayLowGlassCase") as Node3D
	assert_not_null(glass_case, "Display table must keep a glass case cue")
	if glass_case != null:
		var glass_case_size: Vector3 = _box_size(glass_case)
		assert_lte(
			glass_case_size.y,
			0.08,
			"Display glass must be a low cover, not a chunky block in the camera"
		)
	assert_gte(
		_count_children_with_prefix(shell, "ExpansionShutterSlat"),
		6,
		"Expansion wall should read as shuttered retail frontage"
	)
	var welcome_mat: Node3D = shell.get_node_or_null("WelcomeMatInset") as Node3D
	assert_not_null(welcome_mat, "Entry must keep a welcome mat cue")
	if welcome_mat != null:
		var welcome_mat_size: Vector3 = _box_size(welcome_mat)
		assert_lte(
			welcome_mat_size.x,
			1.60,
			"Welcome mat must not fill the exit threshold as a giant black plane"
		)
		assert_lte(welcome_mat_size.z, 0.40, "Welcome mat must stay below close-camera slab scale")
	var threshold_inlay: Node3D = shell.get_node_or_null("ThresholdFloorInlay") as Node3D
	assert_not_null(threshold_inlay, "Entry must keep a threshold inlay cue")
	if threshold_inlay != null:
		assert_lte(
			_box_size(threshold_inlay).x,
			0.70,
			"Threshold inlay should be a small branded detail, not a full-width floor bar"
		)
	var entry_plate: Node3D = shell.get_node_or_null("FrontDoorLowerKickPlate") as Node3D
	assert_not_null(entry_plate, "Entry orientation plate must still exist")
	if entry_plate != null:
		assert_lte(
			_box_size(entry_plate).x,
			1.25,
			"Entry orientation plate must not compete with the authored storefront"
		)


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
	assert_true(
		material.emission_enabled, "Generated checkout screen must emit restrained POS glow"
	)
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
		"StockroomFrontRightWallPanel",
		"StockroomDoorLintel",
		"StockroomFloorTape",
		"StockroomEmployeeDoorStripeLeft",
		"StockroomEmployeeDoorStripeRight",
		"StockroomDoorStop",
	]:
		assert_not_null(shell.get_node_or_null(required), "Stockroom marker missing: %s" % required)


func test_stockroom_boundary_matches_expanded_runtime_staff_corner() -> void:
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	assert_not_null(shell, "Boot must generate the expanded expandable store shell")
	if shell == null:
		return
	var room_bounds: Dictionary = _stockroom_room_bounds()
	var doorway: Dictionary = _stockroom_doorway()
	assert_false(room_bounds.is_empty(), "Stockroom room bounds must be declared")
	assert_false(doorway.is_empty(), "Stockroom doorway contract must be declared")
	if room_bounds.is_empty() or doorway.is_empty():
		return
	var room_min: Vector3 = _vector3_from_array(room_bounds.get("min"))
	var room_max: Vector3 = _vector3_from_array(room_bounds.get("max"))
	var doorway_position: Vector3 = _vector3_from_array(doorway.get("position"))
	var opening: Dictionary = doorway.get("opening_bounds", {}) as Dictionary
	var opening_min: Vector3 = _vector3_from_array(opening.get("min"))
	var opening_max: Vector3 = _vector3_from_array(opening.get("max"))
	var threshold: Node3D = shell.get_node_or_null("StockroomFloorTape") as Node3D
	assert_not_null(threshold, "StockroomFloorTape must mark the doorway gap")
	if threshold == null:
		return

	var left_wall: Node3D = shell.get_node_or_null("StockroomLeftSideReturn") as Node3D
	var right_wall: Node3D = shell.get_node_or_null("StockroomSideReturn") as Node3D
	var back_wall: Node3D = shell.get_node_or_null("StockroomBackPanel") as Node3D
	var front_left: Node3D = shell.get_node_or_null("StockroomPartition") as Node3D
	var front_right: Node3D = shell.get_node_or_null("StockroomFrontRightWallPanel") as Node3D
	var left_jamb: Node3D = shell.get_node_or_null("StockroomPost") as Node3D
	var right_jamb: Node3D = shell.get_node_or_null("StockroomDoorJambRight") as Node3D
	for node: Node3D in [
		left_wall,
		right_wall,
		back_wall,
		front_left,
		front_right,
		left_jamb,
		right_jamb,
	]:
		assert_not_null(node, "Stockroom boundary node must exist")
	if (
		left_wall == null
		or right_wall == null
		or back_wall == null
		or front_left == null
		or front_right == null
		or left_jamb == null
		or right_jamb == null
	):
		return

	var left_min: Vector3 = _node_min(left_wall)
	var left_max: Vector3 = _node_max(left_wall)
	var right_min: Vector3 = _node_min(right_wall)
	var right_max: Vector3 = _node_max(right_wall)
	var back_min: Vector3 = _node_min(back_wall)
	var back_max: Vector3 = _node_max(back_wall)
	assert_almost_eq(
		left_min.x,
		room_min.x,
		STOCKROOM_CONNECTION_TOLERANCE,
		"Left stockroom wall must sit on the contracted room edge"
	)
	assert_almost_eq(
		right_max.x,
		room_max.x,
		STOCKROOM_CONNECTION_TOLERANCE,
		"Right stockroom wall must sit on the contracted room edge"
	)
	assert_almost_eq(
		back_min.z,
		room_min.z,
		STOCKROOM_CONNECTION_TOLERANCE,
		"Back stockroom wall must sit on the contracted room edge"
	)
	assert_lte(
		left_min.z,
		back_max.z + STOCKROOM_CONNECTION_TOLERANCE,
		"Left stockroom wall must visually meet the back wall"
	)
	assert_lte(
		right_min.z,
		back_max.z + STOCKROOM_CONNECTION_TOLERANCE,
		"Right stockroom wall must visually meet the back wall"
	)
	assert_gte(
		left_max.z,
		threshold.position.z - STOCKROOM_CONNECTION_TOLERANCE,
		"Left stockroom wall must run continuously from the doorway area"
	)
	assert_almost_eq(
		left_max.z,
		room_max.z,
		STOCKROOM_CONNECTION_TOLERANCE,
		"Left stockroom wall must run to the contracted front face"
	)
	assert_almost_eq(
		right_max.z,
		room_max.z,
		STOCKROOM_CONNECTION_TOLERANCE,
		"Right stockroom wall must run to the contracted front face"
	)

	var front_left_min: Vector3 = _node_min(front_left)
	var front_left_max: Vector3 = _node_max(front_left)
	var front_right_min: Vector3 = _node_min(front_right)
	var front_right_max: Vector3 = _node_max(front_right)
	var left_jamb_max: Vector3 = _node_max(left_jamb)
	var right_jamb_min: Vector3 = _node_min(right_jamb)
	assert_almost_eq(front_left_min.x, room_min.x, STOCKROOM_CONNECTION_TOLERANCE)
	assert_almost_eq(front_left_max.x, opening_min.x, STOCKROOM_CONNECTION_TOLERANCE)
	assert_almost_eq(front_right_min.x, opening_max.x, STOCKROOM_CONNECTION_TOLERANCE)
	assert_almost_eq(front_right_max.x, room_max.x, STOCKROOM_CONNECTION_TOLERANCE)
	assert_almost_eq(front_left_max.z, room_max.z, STOCKROOM_CONNECTION_TOLERANCE)
	assert_almost_eq(front_right_max.z, room_max.z, STOCKROOM_CONNECTION_TOLERANCE)
	assert_almost_eq(threshold.position.z, doorway_position.z, STOCKROOM_CONNECTION_TOLERANCE)
	assert_almost_eq(left_jamb_max.x, opening_min.x, STOCKROOM_CONNECTION_TOLERANCE)
	assert_almost_eq(right_jamb_min.x, opening_max.x, STOCKROOM_CONNECTION_TOLERANCE)
	assert_almost_eq(
		right_jamb_min.x - left_jamb_max.x,
		float(doorway.get("clear_width_m", 0.0)),
		0.04,
		"Stockroom front must leave exactly one player-readable doorway gap"
	)

	assert_gte(
		_count_children_with_prefix(shell, "StockroomSupplyBox"),
		5,
		"Expanded stockroom should carry enough storage boxes to read as working space"
	)
	var back_room_label: Label3D = (
		shell.get_node_or_null("ReferenceStockroomDoorLabelText") as Label3D
	)
	assert_not_null(back_room_label, "Stockroom doorway should use a sparse physical door plaque")
	if back_room_label != null:
		assert_eq(back_room_label.text, "BACK ROOM")


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


func test_manager_proxy_reads_as_person_silhouette() -> void:
	var proxy: Node3D = _root.get_node_or_null("StoreSessionManager/ManagerProxy") as Node3D
	assert_not_null(proxy, "Manager proxy must be generated for the first route target")
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
	_assert_position_near("PlayerEntrySpawn", Vector3(-0.55, 0.0, 9.0), 0.05)
	_assert_position_near("EntranceDoor", Vector3(0.0, 0.0, 9.72), 0.05)
	_assert_position_near("checkout_counter", Vector3(5.65, 0.0, 6.15), 0.05)
	_assert_position_near("StoreSessionManager", Vector3(5.85, 0.0, 5.40), 0.05)
	_assert_position_near("StoreSessionDayOneCustomer", Vector3(4.85, 0.0, 7.25), 0.05)
	_assert_position_near("StoreSessionRestockShelf", Vector3(-4.10, 0.0, -1.20), 0.05)
	_assert_position_near("StoreSessionBackroomPickup", Vector3(4.90, 0.0, -8.70), 0.05)


func test_day_one_anchor_positions_match_physical_layout_contract() -> void:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	var contract: Dictionary = catalog.call(
		"get_physical_contract", StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT
	)
	var store_bounds: Dictionary = contract.get("store_bounds", {}) as Dictionary
	var checkout_placement: Dictionary = (
		catalog
		. call(
			"get_fixture_placement",
			StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT,
			"starter_checkout_counter",
		)
	)
	var checkout_contract: Dictionary = _contract_for_object(contract, "starter_checkout_counter")
	var display_placement: Dictionary = (
		catalog
		. call(
			"get_fixture_placement",
			StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT,
			"starter_display_table",
		)
	)

	_assert_position_near(
		"PlayerEntrySpawn",
		_vector3_from_array(_contract_for_object(contract, "player_entry_spawn").get("position")),
		0.01
	)
	_assert_position_near(
		"EntranceDoor",
		_vector3_from_array(_contract_for_object(contract, "entrance_door").get("position")),
		0.01
	)
	_assert_position_near(
		"StoreSessionBackroomPickup",
		_vector3_from_array(_contract_for_object(contract, "stockroom_pickup").get("position")),
		0.01
	)
	_assert_position_near(
		"checkout_counter", _vector3_from_array(checkout_placement.get("position")), 0.01
	)
	_assert_position_near(
		"StoreSessionRestockShelf", _vector3_from_array(display_placement.get("position")), 0.01
	)

	var checkout_position: Vector3 = _vector3_from_array(checkout_placement.get("position"))
	var customer_spot: Dictionary = _service_point(checkout_contract, "checkout_customer_spot")
	var service_position: Vector3 = (
		checkout_position + _vector3_from_array(customer_spot.get("position_offset"))
	)
	var staff_spot: Dictionary = _service_point(checkout_contract, "checkout_staff_spot")
	var staff_position: Vector3 = (
		checkout_position + _vector3_from_array(staff_spot.get("position_offset"))
	)
	_assert_position_near("StoreSessionManager", staff_position, 0.01)
	_assert_position_near("StoreSessionDayOneCustomer", service_position, 0.01)
	for index: int in range(3):
		var path := "QueueMarker%d" % (index + 1)
		var expected: Vector3 = _vector3_from_array(
			(_contract_for_object(contract, "queue_marker_positions").get("positions") as Array)[index]
		)
		_assert_position_near(path, expected, 0.01)

	var spawn: Marker3D = _root.get_node_or_null("PlayerEntrySpawn") as Marker3D
	assert_eq(
		spawn.get_meta("bounds_min"), _vector3_from_array(store_bounds.get("player_bounds_min"))
	)
	assert_eq(
		spawn.get_meta("bounds_max"), _vector3_from_array(store_bounds.get("player_bounds_max"))
	)


func test_malformed_optional_contract_fields_fall_back_without_dropping_authored_nodes() -> void:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	var layout: Dictionary = catalog.call(
		"get_layout", StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT
	)
	var contract: Dictionary = layout.get("physical_contract", {}) as Dictionary
	var spawn_contract: Dictionary = _contract_for_object(contract, "player_entry_spawn")
	var queue_contract: Dictionary = _contract_for_object(contract, "queue_marker_positions")
	var checkout_contract: Dictionary = _contract_for_object(contract, "starter_checkout_counter")
	var customer_spot: Dictionary = _service_point(checkout_contract, "checkout_customer_spot")
	spawn_contract["position"] = ["bad", 0.0, 9.0]
	queue_contract["positions"] = [["bad"]]
	customer_spot["position_offset"] = ["bad"]
	var broken_catalog: RefCounted = StoreVisualLayoutScript.new()
	broken_catalog.call("load_from_dictionary", {"entries": [layout]})

	ExpandableStoreShellRuntimeScript.call("_apply_with_catalog", _root, broken_catalog)

	_assert_position_near("PlayerEntrySpawn", Vector3(-0.55, 0.0, 9.0), 0.01)
	_assert_position_near("QueueMarker1", Vector3(4.85, 0.0, 7.25), 0.01)
	_assert_position_near("QueueMarker2", Vector3(3.90, 0.0, 7.50), 0.01)
	_assert_position_near("QueueMarker3", Vector3(2.95, 0.0, 7.75), 0.01)
	assert_not_null(_root.get_node_or_null("StoreSessionRestockShelf/Interactable"))
	assert_not_null(_root.get_node_or_null("StoreSessionBackroomPickup/Interactable"))
	assert_not_null(_root.get_node_or_null("checkout_counter/Interactable"))
	assert_true(_root.get_node("QueueMarker1").is_in_group("queue_markers"))


func test_checkout_lane_runtime_uses_queue_slots_as_single_source() -> void:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	var layout: Dictionary = (
		(
			catalog.call("get_layout", StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT)
			as Dictionary
		)
		. duplicate(true)
	)
	var contract: Dictionary = layout.get("physical_contract", {}) as Dictionary
	var queue_contract: Dictionary = _contract_for_object(contract, "queue_marker_positions")
	var front_lane_contract: Dictionary = _contract_for_object(contract, "front_lane_queue")
	var route_zone: Dictionary = _zone_for_id(contract, "customer_route_core")
	queue_contract["positions"] = [
		[4.65, 0.0, 7.10],
		[3.70, 0.0, 7.35],
		[2.75, 0.0, 7.60],
	]
	front_lane_contract["position"] = [-6.0, 0.0, -6.0]
	route_zone["points"] = [
		[0.0, 0.0, 8.2],
		[-4.10, 0.0, -1.20],
		[-5.0, 0.0, -5.0],
		[0.0, 0.0, 8.2],
	]
	var broken_catalog: RefCounted = StoreVisualLayoutScript.new()
	broken_catalog.call("load_from_dictionary", {"entries": [layout]})

	ExpandableStoreShellRuntimeScript.call("_apply_with_catalog", _root, broken_catalog)

	_assert_position_near("QueueMarker1", Vector3(4.65, 0.0, 7.10), 0.01)
	_assert_position_near("QueueMarker2", Vector3(3.70, 0.0, 7.35), 0.01)
	_assert_position_near("QueueMarker3", Vector3(2.75, 0.0, 7.60), 0.01)
	_assert_position_near("FrontLaneQueue", Vector3(3.70, 0.0, 7.35), 0.01)
	_assert_position_near("CustomerNavConfig/CheckoutApproach", Vector3(4.65, 0.05, 7.10), 0.01)
	_assert_position_near("RegisterArea", Vector3(4.65, 1.0, 7.10), 0.01)


func test_invalid_contract_fallback_diagnostic_is_source_visible() -> void:
	var source: String = FileAccess.get_file_as_string(
		"res://game/scripts/visuals/expandable_store_shell_runtime.gd"
	)
	assert_string_contains(source, "invalid physical layout contract value")
	assert_string_contains(source, "using fallback")


func test_player_spawn_bounds_match_expanded_runtime_shell() -> void:
	var spawn: Marker3D = _root.get_node_or_null("PlayerEntrySpawn") as Marker3D
	assert_not_null(spawn, "PlayerEntrySpawn must exist")
	if spawn == null:
		return
	assert_eq(spawn.get_meta("bounds_min"), Vector3(-7.45, 0.0, -9.35))
	assert_eq(spawn.get_meta("bounds_max"), Vector3(7.45, 0.0, 9.05))
	assert_between(spawn.position.x, -7.45, 7.45, "Spawn X must be inside player bounds")
	assert_between(spawn.position.z, -9.35, 9.05, "Spawn Z must be inside player bounds")


func test_player_spawn_faces_inward_toward_first_route_landmarks() -> void:
	var spawn: Marker3D = _root.get_node_or_null("PlayerEntrySpawn") as Marker3D
	var manager: Node3D = _root.get_node_or_null("StoreSessionManager") as Node3D
	var checkout: Node3D = _root.get_node_or_null("checkout_counter") as Node3D
	var exit: Node3D = _root.get_node_or_null("EntranceDoor") as Node3D
	assert_not_null(spawn, "PlayerEntrySpawn must exist")
	assert_not_null(manager, "StoreSessionManager must exist")
	assert_not_null(checkout, "checkout_counter must exist")
	assert_not_null(exit, "EntranceDoor must exist")
	if spawn == null or manager == null or checkout == null or exit == null:
		return
	var forward: Vector3 = _flat_forward(spawn)
	assert_lt(forward.z, -0.90, "Spawn must face inward across the sales floor")
	assert_gt(
		forward.dot(_flat_direction(spawn.global_position, manager.global_position)),
		0.50,
		"First manager beat must sit inside the spawn view cone"
	)
	assert_gt(
		forward.dot(_flat_direction(spawn.global_position, checkout.global_position)),
		0.50,
		"Checkout must sit inside the spawn view cone"
	)
	assert_lt(
		forward.dot(_flat_direction(spawn.global_position, exit.global_position)),
		0.0,
		"Spawn must not start by facing the mall exit dead-end"
	)


func test_customer_browse_waypoints_stay_out_of_stockroom() -> void:
	var nav_config: Node = _root.get_node_or_null("CustomerNavConfig")
	assert_not_null(nav_config, "CustomerNavConfig must exist")
	if nav_config == null:
		return
	var room_bounds: Dictionary = _stockroom_room_bounds()
	assert_false(room_bounds.is_empty(), "Stockroom room bounds must be declared")
	if room_bounds.is_empty():
		return
	var room_min: Vector3 = _vector3_from_array(room_bounds.get("min"))
	var room_max: Vector3 = _vector3_from_array(room_bounds.get("max"))
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
			marker.position.x >= room_min.x
			and marker.position.x <= room_max.x
			and marker.position.z >= room_min.z
			and marker.position.z <= room_max.z
		)
		assert_false(
			in_stockroom, "%s must not route customers into the staff-only stockroom" % marker_name
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
		"StarterConsoleNeoIgnite",
		"StarterMotorwayKings",
		"StarterKingdomEmbers",
		"StockroomSupplyBox00",
		"StockroomSupplyBox02",
	]:
		assert_not_null(
			shell.get_node_or_null(required), "Starter shell product prop missing: %s" % required
		)
	for reserve_product: String in ["StarterTorqueForce", "StarterGridiron"]:
		assert_null(
			shell.get_node_or_null(reserve_product),
			(
				"Reserve starter product must not appear in the first-delivery boot shell: %s"
				% reserve_product
			)
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
		assert_eq(str(product.get_meta("stock_state", "")), "first_delivery_stocked")


func test_boot_shell_avoids_product_name_spam() -> void:
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	assert_not_null(shell, "Boot must generate the expanded expandable store shell")
	if shell == null:
		return
	var visible_text_count: int = 0
	var stockroom_inventory_label_count: int = 0
	for label: Label3D in _collect_visible_labels(shell):
		if _is_stockroom_inventory_label(label):
			if label.text.strip_edges() != "":
				stockroom_inventory_label_count += 1
			continue
		if _is_functional_wayfinding_label(label):
			continue
		if label.text.strip_edges() != "":
			visible_text_count += 1
	assert_lte(
		visible_text_count, 3, "Generated store shell should not spam product/category labels"
	)
	assert_lte(
		stockroom_inventory_label_count,
		1,
		"Stockroom inventory projection should use one concise operational label"
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


func _expected_first_delivery_ids() -> PackedStringArray:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	return (
		catalog
		. call(
			"get_product_item_ids",
			StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT,
			StoreVisualLayoutScript.STOCK_STATE_FIRST_DELIVERY,
		)
	)


func _collect_product_displays(parent: Node) -> Array[Node]:
	var products: Array[Node] = []
	for child: Node in parent.get_children():
		if child.is_in_group("product_display"):
			products.append(child)
		products.append_array(_collect_product_displays(child))
	return products


func _has_interaction_descendant(node: Node) -> bool:
	if (
		node is CollisionObject3D
		or node is CollisionShape3D
		or node is Area3D
		or node is Interactable
	):
		return true
	for child: Node in node.get_children():
		if _has_interaction_descendant(child):
			return true
	return false


func _count_mesh_descendants(node: Node) -> int:
	var total := 0
	if node is MeshInstance3D:
		total += 1
	for child: Node in node.get_children():
		total += _count_mesh_descendants(child)
	return total


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


func _assert_panel_or_strip(parent: Node, node_path: String) -> void:
	var node: Node3D = parent.get_node_or_null(node_path) as Node3D
	assert_not_null(node, "%s must exist" % node_path)
	if node == null:
		return
	var size: Vector3 = _box_size(node)
	assert_gt(size.length_squared(), 0.0, "%s must expose a box mesh size" % node_path)
	if size.length_squared() <= 0.0:
		return
	var shortest: float = minf(size.x, minf(size.y, size.z))
	var longest: float = maxf(size.x, maxf(size.y, size.z))
	assert_lte(shortest, 0.14, "%s must be visibly thin instead of cube-like" % node_path)
	assert_gte(
		longest / maxf(shortest, 0.001),
		3.0,
		"%s must read as an authored panel, rail, or strip" % node_path
	)


func _material_for(parent: Node, node_path: String) -> StandardMaterial3D:
	var node: Node3D = parent.get_node_or_null(node_path) as Node3D
	if node == null:
		return null
	var mesh_instance: MeshInstance3D = node as MeshInstance3D
	if mesh_instance == null:
		mesh_instance = node.get_node_or_null("Visual") as MeshInstance3D
	if mesh_instance == null:
		return null
	return mesh_instance.material_override as StandardMaterial3D


func _brightest_channel(color: Color) -> float:
	return maxf(maxf(color.r, color.g), color.b)


func _color_distance(a: Color, b: Color) -> float:
	return Vector3(a.r - b.r, a.g - b.g, a.b - b.b).length()


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


func _flat_xz_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x, a.z).distance_to(Vector2(b.x, b.z))


func _flat_forward(node: Node3D) -> Vector3:
	var forward: Vector3 = -node.global_transform.basis.z
	forward.y = 0.0
	return forward.normalized()


func _flat_direction(from: Vector3, to: Vector3) -> Vector3:
	var direction := to - from
	direction.y = 0.0
	return direction.normalized()


func _contract_for_object(contract: Dictionary, object_id: String) -> Dictionary:
	for raw_contract: Variant in contract.get("placement_contracts", []):
		if raw_contract is Dictionary:
			var entry: Dictionary = raw_contract as Dictionary
			if str(entry.get("object_id", "")) == object_id:
				return entry
	return {}


func _zone_for_id(contract: Dictionary, zone_id: String) -> Dictionary:
	for raw_zone: Variant in contract.get("zones", []):
		if raw_zone is Dictionary:
			var zone: Dictionary = raw_zone as Dictionary
			if str(zone.get("zone_id", "")) == zone_id:
				return zone
	return {}


func _service_point(contract: Dictionary, point_id: String) -> Dictionary:
	for raw_point: Variant in contract.get("service_points", []):
		if raw_point is Dictionary:
			var point: Dictionary = raw_point as Dictionary
			if str(point.get("point_id", "")) == point_id:
				return point
	return {}


func _vector3_from_array(raw_value: Variant) -> Vector3:
	assert_true(VisualValueUtilScript.is_vector3_array(raw_value), "Expected Vector3 array")
	if not VisualValueUtilScript.is_vector3_array(raw_value):
		return Vector3.ZERO
	return VisualValueUtilScript.vector3_from_exact_array(raw_value, Vector3.ZERO)


func _stockroom_room_bounds() -> Dictionary:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	var room: Dictionary = catalog.call(
		"get_room_contract", StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT, "stockroom"
	)
	return (room.get("bounds", {}) as Dictionary).duplicate(true)


func _stockroom_doorway() -> Dictionary:
	var catalog: RefCounted = StoreVisualLayoutScript.load_default()
	var room: Dictionary = catalog.call(
		"get_room_contract", StoreVisualLayoutScript.RETRO_GAMES_STARTER_LAYOUT, "stockroom"
	)
	var doorways: Array = room.get("doorways", []) as Array
	if doorways.size() != 1 or doorways[0] is not Dictionary:
		return {}
	return (doorways[0] as Dictionary).duplicate(true)


func _node_min(node: Node3D) -> Vector3:
	var size: Vector3 = _box_size(node)
	return node.position - size * 0.5


func _node_max(node: Node3D) -> Vector3:
	var size: Vector3 = _box_size(node)
	return node.position + size * 0.5


func _collect_visible_labels(parent: Node) -> Array[Label3D]:
	var labels: Array[Label3D] = []
	for child: Node in parent.get_children():
		if child is Label3D and (child as Label3D).visible:
			labels.append(child as Label3D)
		labels.append_array(_collect_visible_labels(child))
	return labels


func _is_stockroom_inventory_label(label: Label3D) -> bool:
	var current: Node = label
	while current != null:
		if bool(current.get_meta("stockroom_inventory_projection", false)):
			return true
		current = current.get_parent()
	return false


func _is_functional_wayfinding_label(label: Label3D) -> bool:
	var text: String = label.text.strip_edges()
	if text.is_empty():
		return true
	return (
		[
			"OPEN",
			"STAFF",
			"BACK ROOM",
			"NEXT AISLE",
		]
		. has(text)
	)
