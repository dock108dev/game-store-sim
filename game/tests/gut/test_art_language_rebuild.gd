extends GutTest

const ART_BENCHMARK_SCENE := "res://scenes/world/art_benchmark/game_shop_art_benchmark.tscn"
const STORE_WORLD_SCENE := "res://scenes/world/store_world.tscn"
const KIT_SCENES := [
	"res://scenes/world/kits/storefront/mall_concourse_slice.tscn",
	"res://scenes/world/kits/storefront/storefront_facade_bay.tscn",
	"res://scenes/world/kits/storefront/storefront_glass_door_open.tscn",
	"res://scenes/world/kits/interior/store_shell_finish_kit.tscn",
	"res://scenes/world/kits/interior/register_counter_kit.tscn",
	"res://scenes/world/kits/fixtures/wall_shelf_bay_kit.tscn",
	"res://scenes/world/kits/products/product_day_one_set.tscn",
	"res://scenes/world/kits/backroom/receiving_intake_kit.tscn",
	"res://scenes/world/kits/backroom/backroom_staff_threshold_kit.tscn",
]
const WORLD_VISUAL_MODULE_PATHS := [
	"WorldModules/MallConcourseModule",
	"WorldModules/StorefrontShellModule",
	"WorldModules/OpeningThresholdModule",
	"WorldModules/StoreInteriorShellModule",
	"WorldModules/FrontCounterZoneModule",
	"WorldModules/StarterProductDisplayModule",
	"WorldModules/SalesFloorFixturesModule",
	"WorldModules/ReceivingAreaModule",
	"WorldModules/BackroomShellModule",
]


func test_art_benchmark_scene_loads_with_required_kit_instances() -> void:
	var scene := _instantiate_scene(ART_BENCHMARK_SCENE)
	add_child_autofree(scene)

	for node_path in [
		"MallConcourseSlice",
		"StorefrontFacadeBay",
		"StorefrontGlassDoorOpen",
		"StoreShellFinishKit",
		"RegisterCounterKit",
		"WallShelfBayKit",
		"DayOneProductSet",
		"ReceivingIntakeKit",
		"BackroomStaffThresholdKit",
		"BenchmarkCameras/StorefrontReviewCamera",
		"BenchmarkCameras/RegisterReviewCamera",
		"BenchmarkCameras/ThresholdReviewCamera",
	]:
		assert_not_null(scene.get_node_or_null(node_path), node_path)


func test_first_art_kit_scenes_expose_stable_anchors() -> void:
	var required_anchors := {
		"res://scenes/world/kits/storefront/storefront_facade_bay.tscn": [
			"StorefrontSignHousing",
			"StorefrontGlassBay",
			"StorefrontDoorFrame",
			"StorefrontSignLeftMountBracket",
			"StorefrontGlassBay/LeftGlassPaneInnerEdge",
			"StorefrontDoorFrame/DoorFrameTopCloserRail",
		],
		"res://scenes/world/kits/storefront/storefront_glass_door_open.tscn": [
			"OpenDoorGlassPanel",
			"OpenDoorCloserBlock",
			"OpenDoorInteriorPullBar",
		],
		"res://scenes/world/kits/interior/store_shell_finish_kit.tscn": [
			"LowPileCarpetField",
			"DrywallBackPanel",
			"WallBaseboardBack",
			"DrywallBackPanel/WallOutletPlateA",
			"AcousticCeilingPanelLeft",
			"FluorescentDiffuserEntry",
		],
		"res://scenes/world/kits/interior/register_counter_kit.tscn": [
			"RegisterCounterBody",
			"RegisterEquipmentCluster",
			"RegisterCashDrawerSeam",
			"RegisterEquipmentCluster/HandheldScannerHead",
			"RegisterEquipmentCluster/ReceiptPrinterSlot",
			"TradeInTrayFrontLip",
		],
		"res://scenes/world/kits/fixtures/wall_shelf_bay_kit.tscn": [
			"WallShelfProductRows",
		],
		"res://scenes/world/kits/products/product_day_one_set.tscn": [
			".",
		],
		"res://scenes/world/kits/backroom/receiving_intake_kit.tscn": [
			"ReceivingIntakeSurface",
			"OpenCartonLeftFlap",
			"ReceivingRackFrame",
			"InvoiceClipboardClip",
		],
		"res://scenes/world/kits/backroom/backroom_staff_threshold_kit.tscn": [
			"BackroomThresholdFrame",
			"BackroomStorageRack",
			"BackroomOfficeDesk",
			"BackroomCalendarBoard",
		],
	}

	for scene_path in required_anchors:
		var kit := _instantiate_scene(scene_path)
		add_child_autofree(kit)
		for anchor_path in required_anchors[scene_path]:
			if anchor_path == ".":
				assert_eq(kit.name, "DayOneProductSet")
			else:
				assert_not_null(kit.get_node_or_null(anchor_path), "%s:%s" % [scene_path, anchor_path])


func test_day_one_product_kit_has_recognizable_product_art_language() -> void:
	var kit := _instantiate_scene("res://scenes/world/kits/products/product_day_one_set.tscn")
	add_child_autofree(kit)

	for node_path in [
		"Footy2002Stack/Footy2002StackCopy01",
		"Footy2002Stack/Footy2002StackCopy02",
		"Footy2002Stack/Footy2002StackBall",
		"Footy2002Stack/Footy2002StackPlayerBody",
		"CritterQuestIIStack/CritterQuestIIStackCopy01",
		"CritterQuestIIStack/CritterQuestIIStackCritterBody",
		"CritterQuestIIStack/CritterQuestIIStackQuestGem",
		"CritterQuestIIStack/CritterQuestIIStackSequelMarker",
		"VortexConsoleBoxStack/VortexConsoleBoxCopy01",
		"VortexConsoleBoxStack/VortexConsoleBoxCopy02",
		"VortexConsoleBoxStack/VortexConsoleBoxHandle",
		"VortexConsoleBoxStack/VortexConsoleRenderBody",
		"VortexControllerPackPair/VortexControllerPack01",
		"VortexControllerPackPair/VortexControllerPack01Bridge",
		"VortexControllerPackPair/VortexControllerPack02PriceSticker",
	]:
		var node := kit.get_node_or_null(node_path)
		assert_not_null(node, node_path)
		if node is Node3D:
			assert_true((node as Node3D).visible, node_path)


func test_first_art_kit_scenes_do_not_use_visible_csg_or_large_labels() -> void:
	for scene_path in KIT_SCENES:
		var kit := _instantiate_scene(scene_path)
		add_child_autofree(kit)
		var visible_csg: Array[Node] = []
		var labels: Array[Label3D] = []
		_collect_visible_csg(kit, visible_csg)
		_collect_labels(kit, labels)

		assert_eq(visible_csg.size(), 0, "%s should not use CSG as visible kit art" % scene_path)
		assert_eq(labels.size(), 0, "%s should not rely on Label3D identity cards" % scene_path)


func test_store_world_instances_first_art_kit_route_without_replacing_mechanics() -> void:
	var store := _instantiate_scene(STORE_WORLD_SCENE)
	add_child_autofree(store)

	var route := store.get_node_or_null("ApprovedArtKitRoute") as Node3D
	assert_not_null(route)
	assert_not_null(store.get_node_or_null("PlayerController"))
	assert_not_null(store.get_node_or_null("RegisterWorkstation"))
	assert_not_null(store.get_node_or_null("ReceivingBox"))
	assert_not_null(store.get_node_or_null("BackroomComputer"))

	for node_path in [
		"ApprovedArtKitRoute/ArtMallConcourseSlice",
		"ApprovedArtKitRoute/ArtStorefrontFacadeBay/StorefrontSignHousing",
		"ApprovedArtKitRoute/ArtStorefrontFacadeBay/StorefrontGlassBay",
		"ApprovedArtKitRoute/ArtStorefrontFacadeBay/StorefrontDoorFrame",
		"ApprovedArtKitRoute/ArtStorefrontFacadeBay/StorefrontSignLeftMountBracket",
		"ApprovedArtKitRoute/ArtStorefrontGlassDoorOpen",
		"ApprovedArtKitRoute/ArtStorefrontGlassDoorOpen/OpenDoorCloserBlock",
		"ApprovedArtKitRoute/ArtStoreShellFinishKit/LowPileCarpetField",
		"ApprovedArtKitRoute/ArtStoreShellFinishKit/DrywallBackPanel",
		"ApprovedArtKitRoute/ArtStoreShellFinishKit/DrywallBackPanel/WallOutletPlateA",
		"ApprovedArtKitRoute/ArtRegisterCounterKit/RegisterCounterBody",
		"ApprovedArtKitRoute/ArtRegisterCounterKit/RegisterEquipmentCluster",
		"ApprovedArtKitRoute/ArtRegisterCounterKit/RegisterEquipmentCluster/HandheldScannerHead",
		"ApprovedArtKitRoute/ArtRegisterCounterKit/RegisterCashDrawerSeam",
		"ApprovedArtKitRoute/ArtWallShelfBayKit/WallShelfProductRows",
		"ApprovedArtKitRoute/ArtDayOneProductSet",
		"ApprovedArtKitRoute/ArtReceivingIntakeKit/ReceivingIntakeSurface",
		"ApprovedArtKitRoute/ArtReceivingIntakeKit/ReceivingRackFrame",
		"ApprovedArtKitRoute/ArtBackroomStaffThresholdKit/BackroomThresholdFrame",
		"ApprovedArtKitRoute/ArtBackroomStaffThresholdKit/BackroomOfficeDesk",
	]:
		assert_not_null(store.get_node_or_null(node_path), node_path)

	var visible_csg: Array[Node] = []
	var labels: Array[Label3D] = []
	_collect_visible_csg(route, visible_csg)
	_collect_labels(route, labels)
	assert_eq(visible_csg.size(), 0)
	assert_eq(labels.size(), 0)


func test_store_world_visual_modules_publish_implementation_contracts() -> void:
	var store := _instantiate_scene(STORE_WORLD_SCENE)
	add_child_autofree(store)

	for module_path in WORLD_VISUAL_MODULE_PATHS:
		var module := store.get_node_or_null(module_path)
		assert_not_null(module, module_path)
		assert_true(module.call("has_visual_contract"), module_path)
		assert_eq(module.call("missing_owned_node_names", store).size(), 0, "%s owned nodes" % module_path)
		assert_eq(module.call("missing_visual_node_names", store).size(), 0, "%s visual nodes" % module_path)
		assert_eq(module.call("missing_collision_node_names", store).size(), 0, "%s collision nodes" % module_path)
		assert_eq(module.call("missing_anchor_node_names", store).size(), 0, "%s anchors" % module_path)
		assert_eq(module.call("missing_material_resource_paths").size(), 0, "%s materials" % module_path)


func _instantiate_scene(scene_path: String) -> Node:
	var packed := load(scene_path) as PackedScene
	assert_not_null(packed, scene_path)
	var instance := packed.instantiate()
	assert_not_null(instance, scene_path)
	return instance


func _collect_visible_csg(node: Node, found: Array[Node]) -> void:
	if node is CSGShape3D and (node as CSGShape3D).is_visible_in_tree():
		found.append(node)
	for child in node.get_children():
		_collect_visible_csg(child, found)


func _collect_labels(node: Node, found: Array[Label3D]) -> void:
	if node is Label3D and (node as Label3D).is_visible_in_tree():
		found.append(node as Label3D)
	for child in node.get_children():
		_collect_labels(child, found)
