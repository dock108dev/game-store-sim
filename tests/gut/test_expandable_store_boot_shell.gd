extends GutTest

const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"

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
	assert_not_null(shell, "Boot must generate the compact expandable store shell")
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
		"ExpansionDoorPanel",
		"StarterSignLabel",
		"StarterRegisterCounter",
		"StarterRegisterScreen",
	]:
		assert_not_null(shell.get_node_or_null(required), "Shell must include %s" % required)

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
				node.visible, "%s must not be visible in the scaffolded boot view" % old_root
			)
	var old_door_mesh: Node3D = _root.get_node_or_null("EntranceDoor/DoorMesh") as Node3D
	assert_not_null(old_door_mesh, "Legacy authored door mesh must still exist")
	if old_door_mesh != null:
		assert_false(old_door_mesh.visible, "Generated shell owns the visible storefront door")


func test_boot_shell_has_screen_first_visual_rescue_groups() -> void:
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	assert_not_null(shell, "Boot must generate the compact expandable store shell")
	if shell == null:
		return
	for required: String in [
		"SpawnSightlineLeftWallSlatA",
		"SpawnSightlineRightServicePanel",
		"SpawnForegroundTradeBin",
		"CheckoutFrontLaminatePanel",
		"CheckoutImpulseRack",
		"ShelfHeroBacker",
		"ShelfHeroHeaderRail",
		"ShelfHeroCase0104",
		"ShelfEndcapFaceout00",
		"ShelfCategoryUsedGamesText",
		"ShelfCategoryStaffPicksText",
		"ShelfCategoryUnderTenText",
		"StockroomReceivingBacker",
		"StockroomWorkShelf",
		"StockroomWallTaskCard",
		"StockroomHandTruckFrame",
	]:
		var node: Node3D = shell.get_node_or_null(required) as Node3D
		assert_not_null(node, "Screen-first shell dressing must include %s" % required)
		if node != null:
			assert_true(node.visible, "%s must be visible in the generated shell" % required)

	var shelf_case_count: int = 0
	for child: Node in shell.get_children():
		if str(child.name).begins_with("ShelfHeroCase"):
			shelf_case_count += 1
	assert_gte(
		shelf_case_count,
		27,
		"Shelf wall rescue must use camera-visible product density, not hidden prop count"
	)


func test_boot_shell_first_ten_seconds_views_have_store_language_props() -> void:
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	assert_not_null(shell, "Boot must generate the compact expandable store shell")
	if shell == null:
		return

	assert_gte(
		_count_children_with_prefix(shell, "ShelfHeroCase"),
		48,
		"Shelf wall must read as stocked game cases in the route screenshot"
	)
	assert_gte(
		_count_children_with_prefix(shell, "ShelfHeroSpineStripe"),
		48,
		"Shelf wall must include case-art striping instead of flat color blocks"
	)
	assert_gte(
		_count_children_with_prefix(shell, "ShelfHeroPriceTag"),
		16,
		"Shelf wall must include visible price-tag rhythm"
	)
	assert_gte(
		_count_children_with_prefix(shell, "SpawnForegroundTradeCase"),
		5,
		"Spawn view must foreground traded game cases"
	)
	for required: String in [
		"SpawnWelcomeMatText",
		"SpawnEntrySensorLeft",
		"SpawnSideWallConsolePosterText",
		"ShelfEndcapFaceoutText",
		"ShelfWallWarmPractical",
	]:
		assert_not_null(shell.get_node_or_null(required), "Store identity prop missing: %s" % required)


func test_checkout_counter_reads_as_service_counter_in_boot_shell() -> void:
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	assert_not_null(shell, "Boot must generate the compact expandable store shell")
	if shell == null:
		return
	for required: String in [
		"CheckoutReceiptPrinterBase",
		"CheckoutReceiptPrinterPaper",
		"CheckoutBarcodeScannerHandle",
		"CheckoutBarcodeScannerHead",
		"CheckoutScannerGlow",
		"CheckoutTradeInForm00",
		"CheckoutTradeInFormClip",
		"CheckoutControllerCableLoopA",
		"CheckoutManagerNamePlate",
		"CheckoutTradeInsText",
		"CheckoutRegisterPractical",
	]:
		assert_not_null(shell.get_node_or_null(required), "Checkout service prop missing: %s" % required)
	assert_gte(
		_count_children_with_prefix(shell, "CheckoutImpulseFace"),
		4,
		"Checkout must include impulse products visible from the manager-counter view"
	)


func test_stockroom_path_reads_as_work_area_in_boot_shell() -> void:
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	assert_not_null(shell, "Boot must generate the compact expandable store shell")
	if shell == null:
		return
	for required: String in [
		"StockroomReceivingTableTop",
		"StockroomReceivingScale",
		"StockroomReceivingScaleScreen",
		"StockroomReceivingChecklist",
		"StockroomTapeRoll",
		"StockroomBoxLabelFacingPlayer",
		"StockroomBoxLabelText",
		"StockroomHandTruckHandle",
		"StockroomHandTruckWheelLeft",
		"StockroomFloorArrowHeadLeft",
		"StockroomUtilityPractical",
	]:
		assert_not_null(shell.get_node_or_null(required), "Stockroom work prop missing: %s" % required)
	assert_gte(
		_count_children_with_prefix(shell, "StockroomShelfLabel"),
		4,
		"Stockroom shelf boxes must carry labels visible from the route view"
	)


func test_manager_customer_proxy_reads_as_person_silhouette() -> void:
	var proxy: Node3D = _root.get_node_or_null("BetaDayOneCustomer/CustomerProxy") as Node3D
	assert_not_null(proxy, "Customer proxy must be generated for the first route target")
	if proxy == null:
		return
	for required: String in [
		"Body",
		"Head",
		"HairCap",
		"FaceBand",
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


func test_critical_day_one_anchors_move_into_the_starter_footprint() -> void:
	_assert_position_near("PlayerEntrySpawn", Vector3(0.0, 0.0, 5.65), 0.05)
	_assert_position_near("EntranceDoor", Vector3(0.0, 0.0, 7.22), 0.05)
	_assert_position_near("checkout_counter", Vector3(2.92, 0.0, 3.75), 0.05)
	_assert_position_near("BetaDayOneCustomer", Vector3(2.52, 0.0, 4.85), 0.05)
	_assert_position_near("BetaRestockShelf", Vector3(-1.7, 0.0, -2.95), 0.05)
	_assert_position_near("BetaBackroomPickup", Vector3(3.15, 0.0, -2.15), 0.05)


func test_shell_signs_do_not_render_mirrored_from_the_back_side() -> void:
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	assert_not_null(shell, "Boot must generate the compact expandable store shell")
	if shell == null:
		return
	for label_path: String in [
		"StarterSignLabel",
		"GamesBayLabel",
		"StockroomLabel",
		"ExpansionLabel",
	]:
		var label: Label3D = shell.get_node_or_null(label_path) as Label3D
		assert_not_null(label, "%s must exist" % label_path)
		if label == null:
			continue
		assert_false(label.double_sided, "%s must not mirror from behind" % label_path)


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
