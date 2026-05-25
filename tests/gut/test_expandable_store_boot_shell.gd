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
		"StockroomLabel",
		"EntryThreshold",
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


func test_boot_shell_is_sparse_leased_room_without_dense_clutter() -> void:
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	assert_not_null(shell, "Boot must generate the compact expandable store shell")
	if shell == null:
		return
	for removed: String in [
		"SpawnForegroundTradeBin",
		"CheckoutImpulseRack",
		"ShelfHeroBacker",
		"ShelfHeroHeaderRail",
		"StockroomReceivingBacker",
		"StockroomWorkShelf",
		"StockroomWallTaskCard",
		"StockroomHandTruckFrame",
		"StarterRegisterCounter",
		"StarterRegisterScreen",
		"BackWallLowerShelf",
		"BackWallUpperShelf",
		"CenterDisplayConsole",
		"CenterDisplayGameA",
		"CenterDisplayGameB",
		"FeaturedBoxArtBacking00",
		"StockroomBoxA",
		"StockroomBoxB",
	]:
		assert_null(shell.get_node_or_null(removed), "Starter shell must not include %s" % removed)


func test_boot_shell_dense_merchandise_count_is_capped_by_owned_inventory() -> void:
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	assert_not_null(shell, "Boot must generate the compact expandable store shell")
	if shell == null:
		return
	var merchandise_count: int = 0
	for prefix: String in [
		"ShelfHeroCase",
		"ShelfHeroSpineStripe",
		"ShelfHeroPriceTag",
		"SpawnForegroundTradeCase",
		"StarterShelfCase",
		"StarterShelfTopCase",
		"CheckoutImpulseFace",
		"StockroomShelfBox",
		"FeaturedBoxArtBacking",
	]:
		merchandise_count += _count_children_with_prefix(shell, prefix)
	assert_lte(merchandise_count, 3, "Boot shell must not exceed starter inventory density")


func test_checkout_counter_is_not_duplicated_inside_boot_shell() -> void:
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	assert_not_null(shell, "Boot must generate the compact expandable store shell")
	if shell == null:
		return
	for removed: String in [
		"CheckoutReceiptPrinterBase",
		"CheckoutReceiptPrinterPaper",
		"CheckoutBarcodeScannerHandle",
		"CheckoutBarcodeScannerHead",
		"CheckoutTradeInForm00",
		"CheckoutManagerNamePlate",
	]:
		assert_null(shell.get_node_or_null(removed), "StoreLayoutRuntime owns %s now" % removed)


func test_stockroom_path_keeps_marker_without_workbench_clutter() -> void:
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	assert_not_null(shell, "Boot must generate the compact expandable store shell")
	if shell == null:
		return
	for required: String in [
		"StockroomPartition",
		"StockroomPost",
		"StockroomHeader",
		"StockroomLabel",
		"StockroomFloorTape",
	]:
		assert_not_null(shell.get_node_or_null(required), "Stockroom marker missing: %s" % required)


func test_manager_customer_proxy_reads_as_person_silhouette() -> void:
	var proxy: Node3D = _root.get_node_or_null("StoreSessionDayOneCustomer/CustomerProxy") as Node3D
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
	_assert_position_near("StoreSessionDayOneCustomer", Vector3(2.52, 0.0, 4.85), 0.05)
	_assert_position_near("StoreSessionRestockShelf", Vector3(-1.35, 0.0, 1.35), 0.05)
	_assert_position_near("StoreSessionBackroomPickup", Vector3(3.15, 0.0, -2.15), 0.05)


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


func test_customer_facing_product_props_are_absent_from_shell() -> void:
	var shell: Node3D = _root.get_node_or_null("ExpandableStoreShell") as Node3D
	assert_not_null(shell, "Boot must generate the compact expandable store shell")
	if shell == null:
		return
	for prop_path: String in [
		"StarterShelfCase00",
		"StarterShelfTopCase00",
		"CenterDisplayConsole",
		"CenterDisplayGameA",
		"FeaturedBoxArtBacking00",
		"SpawnForegroundTradeCase00",
		"CheckoutImpulseFace00",
		"ShelfHeroCase0104",
		"ShelfEndcapFaceout00",
		"StockroomShelfBox00",
	]:
		assert_null(shell.get_node_or_null(prop_path), "Starter shell must not own %s" % prop_path)


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
