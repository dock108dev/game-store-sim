extends Node3D
class_name HeroArtSliceScene

const HERO_CAMERA_PATH := "HeroArtRoot/Cameras/StorefrontHeroCamera"

var _materials := {}
var _cover_materials: Array[StandardMaterial3D] = []


func _ready() -> void:
	if has_node("HeroArtRoot"):
		return

	_build_materials()
	_build_scene()


func visual_rules() -> PackedStringArray:
	return PackedStringArray([
		"isolated hero art slice only; no mechanics integration",
		"mall storefront first read with visible first 15-20 feet of store",
		"small-chain Games4U identity, legal-safe fictional products",
		"empty-ish pre-day-one store with starter products and visible empty fixture capacity",
		"no debug labels or text-dependent product identity",
	])


func _build_scene() -> void:
	var root := Node3D.new()
	root.name = "HeroArtRoot"
	root.set_meta("packet", "05-hero-art-slice-proof")
	root.set_meta("visual_rules", visual_rules())
	add_child(root)

	_build_lighting(root)
	_build_mall_concourse(root)
	_build_store_shell(root)
	_build_storefront(root)
	_build_counter(root)
	_build_fixture_and_products(root)
	_build_cameras(root)


func _build_lighting(root: Node3D) -> void:
	var world := WorldEnvironment.new()
	world.name = "HeroWorldEnvironment"
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.52, 0.54, 0.52)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.76, 0.74, 0.66)
	environment.ambient_light_energy = 0.78
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.adjustment_enabled = true
	environment.adjustment_brightness = 1.04
	environment.adjustment_contrast = 1.12
	environment.adjustment_saturation = 0.88
	world.environment = environment
	root.add_child(world)

	var sun := DirectionalLight3D.new()
	sun.name = "SoftMallMorningLight"
	sun.light_energy = 0.72
	sun.rotation_degrees = Vector3(-42.0, -25.0, 0.0)
	root.add_child(sun)

	for index in range(4):
		var light := OmniLight3D.new()
		light.name = "WarmStoreFill%02d" % [index + 1]
		light.light_color = Color(1.0, 0.90, 0.72)
		light.light_energy = 0.56
		light.omni_range = 4.2
		light.position = Vector3(-2.8 + float(index) * 1.85, 2.35, 1.2 + float(index % 2) * 2.0)
		root.add_child(light)


func _build_mall_concourse(root: Node3D) -> void:
	var mall := Node3D.new()
	mall.name = "QuietSecondFloorMallConcourse"
	root.add_child(mall)

	_box(mall, "MallFloorLargeFormatTile", Vector3(0.0, -0.055, -5.1), Vector3(12.0, 0.08, 7.5), _materials["mall_tile"])
	for x in range(-5, 6):
		_box(mall, "MallTileVerticalGrout%02d" % [x + 5], Vector3(float(x), 0.002, -5.1), Vector3(0.026, 0.018, 7.3), _materials["grout"])
	for z_index in range(7):
		var z := -8.35 + float(z_index) * 1.12
		_box(mall, "MallTileHorizontalGrout%02d" % [z_index + 1], Vector3(0.0, 0.004, z), Vector3(11.8, 0.018, 0.026), _materials["grout"])

	_box(mall, "OppositeMallWall", Vector3(0.0, 1.35, -8.85), Vector3(12.0, 2.7, 0.16), _materials["mall_wall"])
	_build_neighbor_store(mall, "NeighborBookShop", Vector3(-4.4, 0.0, -8.67), Color(0.33, 0.39, 0.36), Color(0.85, 0.72, 0.48))
	_build_neighbor_store(mall, "NeighborMusicShop", Vector3(4.35, 0.0, -8.67), Color(0.25, 0.32, 0.38), Color(0.65, 0.82, 0.86))

	_box(mall, "SecondFloorGuardrailTop", Vector3(-5.25, 1.0, -4.25), Vector3(0.10, 0.08, 4.8), _materials["dark_metal"])
	_box(mall, "SecondFloorGuardrailMid", Vector3(-5.25, 0.66, -4.25), Vector3(0.07, 0.055, 4.8), _materials["dark_metal"])
	for post in range(5):
		_box(mall, "SecondFloorGuardrailPost%02d" % [post + 1], Vector3(-5.25, 0.53, -6.2 + float(post) * 0.98), Vector3(0.12, 1.02, 0.12), _materials["dark_metal"])

	_box(mall, "MallBenchWoodSeat", Vector3(3.2, 0.42, -5.6), Vector3(1.3, 0.14, 0.36), _materials["warm_wood"])
	_box(mall, "MallBenchBack", Vector3(3.2, 0.74, -5.78), Vector3(1.3, 0.42, 0.09), _materials["warm_wood"])
	_box(mall, "MallBenchLeftLeg", Vector3(2.68, 0.22, -5.55), Vector3(0.10, 0.42, 0.12), _materials["dark_metal"])
	_box(mall, "MallBenchRightLeg", Vector3(3.72, 0.22, -5.55), Vector3(0.10, 0.42, 0.12), _materials["dark_metal"])

	_planter(mall, Vector3(-3.55, 0.0, -5.25), "LeftConcoursePlanter")
	_planter(mall, Vector3(5.15, 0.0, -6.2), "RightConcoursePlanter")


func _build_neighbor_store(parent: Node3D, node_name: String, base_position: Vector3, panel_color: Color, trim_color: Color) -> void:
	var store := Node3D.new()
	store.name = node_name
	store.position = base_position
	parent.add_child(store)
	var panel_mat := _mat("%sPanel" % node_name, panel_color, 0.82)
	var trim_mat := _emissive_mat("%sLightbox" % node_name, trim_color, 0.22)
	_box(store, "RecessedDarkGlass", Vector3(0.0, 1.0, 0.0), Vector3(2.0, 1.85, 0.06), _materials["black_glass"])
	_box(store, "FasciaColorPanel", Vector3(0.0, 2.25, -0.035), Vector3(2.25, 0.34, 0.08), panel_mat)
	_box(store, "QuietLitTrim", Vector3(0.0, 2.47, -0.075), Vector3(2.25, 0.045, 0.05), trim_mat)


func _build_store_shell(root: Node3D) -> void:
	var shell := Node3D.new()
	shell.name = "VisibleFirstTwentyFeetInterior"
	root.add_child(shell)

	_box(shell, "LowPileStartupCarpet", Vector3(0.0, -0.045, 2.35), Vector3(8.65, 0.075, 7.35), _materials["store_carpet"])
	_box(shell, "EntryTileTransition", Vector3(0.0, -0.035, -0.42), Vector3(8.35, 0.08, 1.25), _materials["store_entry_tile"])
	_box(shell, "StoreLeftDrywall", Vector3(-4.35, 1.35, 2.35), Vector3(0.12, 2.70, 7.35), _materials["warm_drywall"])
	_box(shell, "StoreRightDrywall", Vector3(4.35, 1.35, 2.35), Vector3(0.12, 2.70, 7.35), _materials["warm_drywall"])
	_box(shell, "RearSoftSlatwall", Vector3(0.0, 1.35, 5.98), Vector3(8.65, 2.70, 0.12), _materials["slatwall"])
	_box(shell, "DarkBaseboardLeft", Vector3(-4.27, 0.17, 2.35), Vector3(0.12, 0.24, 7.25), _materials["dark_blue_metal"])
	_box(shell, "DarkBaseboardRight", Vector3(4.27, 0.17, 2.35), Vector3(0.12, 0.24, 7.25), _materials["dark_blue_metal"])
	_box(shell, "DarkBaseboardRear", Vector3(0.0, 0.17, 5.88), Vector3(8.55, 0.24, 0.12), _materials["dark_blue_metal"])

	for y_index in range(9):
		var y := 0.58 + float(y_index) * 0.18
		_box(shell, "RearSlatwallGroove%02d" % [y_index + 1], Vector3(0.0, y, 5.905), Vector3(8.35, 0.022, 0.035), _materials["slat_shadow"])

	_box(shell, "QuietDropCeilingPlane", Vector3(0.0, 2.82, 2.2), Vector3(8.65, 0.08, 7.2), _materials["ceiling_panel"])
	for x_index in range(6):
		_box(shell, "CeilingGridRunnerX%02d" % [x_index + 1], Vector3(-3.6 + float(x_index) * 1.45, 2.765, 2.2), Vector3(0.035, 0.06, 7.05), _materials["ceiling_grid"])
	for z_index in range(6):
		_box(shell, "CeilingGridRunnerZ%02d" % [z_index + 1], Vector3(0.0, 2.76, -0.75 + float(z_index) * 1.25), Vector3(8.45, 0.06, 0.035), _materials["ceiling_grid"])
	for fixture in range(4):
		_box(shell, "WarmFluorescentDiffuser%02d" % [fixture + 1], Vector3(-2.55 + float(fixture % 2) * 5.1, 2.705, 0.65 + float(fixture / 2) * 2.65), Vector3(1.25, 0.045, 0.32), _materials["fluorescent"])

	_box(shell, "BackroomDoorHint", Vector3(-3.65, 1.05, 5.84), Vector3(0.72, 1.85, 0.06), _materials["backroom_door"])
	_box(shell, "BackroomDoorWindow", Vector3(-3.65, 1.55, 5.80), Vector3(0.42, 0.35, 0.035), _materials["frosted_glass"])


func _build_storefront(root: Node3D) -> void:
	var front := Node3D.new()
	front.name = "Games4UDesignedStorefront"
	root.add_child(front)

	_box(front, "DeepStorefrontHeaderBulkhead", Vector3(0.0, 2.62, -0.90), Vector3(8.95, 0.52, 0.36), _materials["dark_blue_metal"])
	_box(front, "LayeredHeaderLowerLip", Vector3(0.0, 2.32, -0.86), Vector3(8.95, 0.08, 0.42), _materials["dark_metal"])
	_box(front, "SubtleBlueTrimUpper", Vector3(0.0, 2.90, -1.08), Vector3(8.75, 0.055, 0.06), _materials["cool_trim"])
	_box(front, "SubtleBlueTrimLower", Vector3(0.0, 2.30, -1.08), Vector3(8.75, 0.04, 0.05), _materials["cool_trim"])

	_box(front, "RaisedGames4USignCabinet", Vector3(0.0, 2.64, -1.18), Vector3(2.95, 0.55, 0.10), _materials["sign_cabinet"])
	_bitmap_panel(front, "Games4ULogoBitmap", "GAMES4U", Vector3(0.0, 2.64, -1.245), Vector3.ZERO, Vector2(2.55, 0.36), _materials["sign_cabinet"].albedo_color, _materials["dark_blue_metal"].albedo_color)

	_box(front, "LeftStorefrontPier", Vector3(-4.38, 1.35, -0.83), Vector3(0.26, 2.65, 0.32), _materials["painted_column"])
	_box(front, "RightStorefrontPier", Vector3(4.38, 1.35, -0.83), Vector3(0.26, 2.65, 0.32), _materials["painted_column"])
	_box(front, "StorefrontKickPlate", Vector3(0.0, 0.18, -0.89), Vector3(8.65, 0.36, 0.18), _materials["dark_blue_metal"])

	for x in [-3.55, -2.25, -0.92, 0.92, 2.25, 3.55]:
		_box(front, "WeightedAluminumMullion%02d" % int((x + 4.0) * 10.0), Vector3(x, 1.35, -0.93), Vector3(0.085, 2.42, 0.12), _materials["dark_metal"])
	for y in [0.78, 1.58, 2.16]:
		_box(front, "StorefrontHorizontalRail%02d" % int(y * 100.0), Vector3(0.0, y, -0.935), Vector3(8.62, 0.07, 0.12), _materials["dark_metal"])

	for pane in range(5):
		var x := -3.0 + float(pane) * 1.5
		_box(front, "SlightlyTintedGlassPane%02d" % [pane + 1], Vector3(x, 1.42, -0.975), Vector3(1.18, 1.46, 0.022), _materials["storefront_glass"])

	var door := Node3D.new()
	door.name = "ProppedOpenGlassDoor"
	door.position = Vector3(0.0, 0.0, -0.94)
	door.rotation_degrees = Vector3(0.0, -17.0, 0.0)
	front.add_child(door)
	_box(door, "OpenDoorGlass", Vector3(0.0, 1.28, -0.02), Vector3(0.98, 1.72, 0.025), _materials["storefront_glass"])
	_box(door, "OpenDoorTopRail", Vector3(0.0, 2.18, -0.01), Vector3(1.08, 0.08, 0.09), _materials["dark_metal"])
	_box(door, "OpenDoorBottomRail", Vector3(0.0, 0.37, -0.01), Vector3(1.08, 0.08, 0.09), _materials["dark_metal"])
	_box(door, "OpenDoorLeftRail", Vector3(-0.54, 1.28, -0.01), Vector3(0.08, 1.82, 0.09), _materials["dark_metal"])
	_box(door, "OpenDoorRightRail", Vector3(0.54, 1.28, -0.01), Vector3(0.08, 1.82, 0.09), _materials["dark_metal"])
	_box(door, "BrassPullHandle", Vector3(0.39, 1.22, -0.08), Vector3(0.055, 0.62, 0.065), _materials["brass"])

	_bitmap_panel(front, "SmallOpenSignBitmap", "OPEN", Vector3(1.18, 1.58, -1.03), Vector3.ZERO, Vector2(0.48, 0.18), Color(0.12, 0.23, 0.25), Color(0.91, 0.80, 0.50))
	_box(front, "DoorThresholdMetalStrip", Vector3(0.0, 0.025, -0.58), Vector3(1.68, 0.05, 0.20), _materials["brass"])


func _build_counter(root: Node3D) -> void:
	var counter := Node3D.new()
	counter.name = "RightSideCashWrapHeroCounter"
	counter.position = Vector3(2.15, 0.0, 1.05)
	counter.rotation_degrees = Vector3(0.0, -7.5, 0.0)
	root.add_child(counter)

	_box(counter, "LaminateCashWrapBody", Vector3(0.0, 0.46, 0.0), Vector3(2.65, 0.92, 0.72), _materials["dark_laminate"])
	_box(counter, "CreamCountertopSlab", Vector3(0.0, 0.96, -0.02), Vector3(2.8, 0.12, 0.84), _materials["cream_counter"])
	_box(counter, "GlassDisplayFrontPane", Vector3(0.0, 0.66, -0.39), Vector3(2.48, 0.56, 0.032), _materials["clear_glass"])
	_box(counter, "DisplayCaseWarmInterior", Vector3(0.0, 0.62, -0.32), Vector3(2.35, 0.12, 0.08), _materials["warm_light"])
	for bay in range(4):
		_game_case(counter, "CounterCaseHeroGame%02d" % [bay + 1], Vector3(-0.88 + float(bay) * 0.42, 0.71, -0.45), Vector3(0.0, 0.0, 0.0), bay + 10, 0.42)

	_box(counter, "POSRegisterBase", Vector3(-0.72, 1.18, 0.16), Vector3(0.54, 0.24, 0.36), _materials["register_plastic"])
	_box(counter, "POSRegisterScreen", Vector3(-0.72, 1.38, -0.02), Vector3(0.42, 0.28, 0.055), _materials["black_glass"])
	_box(counter, "ReceiptPrinter", Vector3(-0.05, 1.12, 0.18), Vector3(0.36, 0.16, 0.28), _materials["register_plastic"])
	_box(counter, "ScannerCradle", Vector3(0.36, 1.105, -0.10), Vector3(0.36, 0.08, 0.24), _materials["dark_metal"])
	_box(counter, "PaperBagStack", Vector3(0.88, 1.08, 0.12), Vector3(0.34, 0.08, 0.28), _materials["paper_bag"])
	_box(counter, "TradeInSlipStack", Vector3(0.86, 1.075, -0.18), Vector3(0.36, 0.025, 0.24), _materials["pale_paper"])
	_controller(counter, Vector3(0.22, 1.12, -0.38), "LooseDemoController")


func _build_fixture_and_products(root: Node3D) -> void:
	var fixture := Node3D.new()
	fixture.name = "StarterWallRackWithEmptyCapacity"
	fixture.position = Vector3(-2.55, 0.0, 2.15)
	fixture.rotation_degrees = Vector3(0.0, 7.0, 0.0)
	root.add_child(fixture)

	_box(fixture, "LaminateBaseToeKick", Vector3(0.0, 0.18, 0.0), Vector3(2.55, 0.36, 0.64), _materials["dark_laminate"])
	_box(fixture, "BackPanelWithSlatGrooves", Vector3(0.0, 1.15, 0.29), Vector3(2.65, 1.90, 0.12), _materials["slatwall"])
	for rail in range(8):
		_box(fixture, "FixtureBackSlatGroove%02d" % [rail + 1], Vector3(0.0, 0.50 + float(rail) * 0.19, 0.215), Vector3(2.45, 0.02, 0.035), _materials["slat_shadow"])
	for shelf in range(4):
		var y := 0.52 + float(shelf) * 0.36
		_box(fixture, "AngledAcrylicCaseShelf%02d" % [shelf + 1], Vector3(0.0, y, -0.10), Vector3(2.35, 0.045, 0.56), _materials["acrylic_shelf"])
		_box(fixture, "RoundedShelfFrontRail%02d" % [shelf + 1], Vector3(0.0, y + 0.075, -0.39), Vector3(2.42, 0.06, 0.055), _materials["dark_metal"])
		_box(fixture, "EmptySlotShadowRail%02d" % [shelf + 1], Vector3(0.0, y + 0.13, -0.29), Vector3(2.25, 0.035, 0.035), _materials["empty_slot"])
	for slot in range(7):
		_game_case(fixture, "StarterRackFootyCase%02d" % [slot + 1], Vector3(-0.92 + float(slot) * 0.18, 0.68, -0.42), Vector3(-12.0, 0.0, 0.0), slot, 0.48)
	for slot in range(4):
		_game_case(fixture, "StarterRackAdventureCase%02d" % [slot + 1], Vector3(0.42 + float(slot) * 0.19, 0.68, -0.42), Vector3(-12.0, 0.0, 0.0), slot + 4, 0.48)

	_console_box(fixture, "StarterConsoleBoxOnLowerShelf", Vector3(-0.52, 0.39, -0.38), 1.0)
	_box(fixture, "SmallAccessoryPackage", Vector3(0.78, 0.42, -0.38), Vector3(0.26, 0.32, 0.10), _materials["accessory_package"])
	_bitmap_panel(fixture, "AccessoryPackageFace", "", Vector3(0.78, 0.42, -0.437), Vector3.ZERO, Vector2(0.22, 0.28), Color(0.70, 0.62, 0.42), Color(0.12, 0.22, 0.24))

	var window_display := Node3D.new()
	window_display.name = "SparseWindowStarterDisplay"
	window_display.position = Vector3(-1.75, 0.0, -0.25)
	window_display.rotation_degrees = Vector3(0.0, -11.0, 0.0)
	root.add_child(window_display)
	_box(window_display, "SmallRoundDisplayPedestal", Vector3(0.0, 0.42, 0.0), Vector3(0.72, 0.84, 0.48), _materials["cream_counter"])
	_console_box(window_display, "WindowHeroConsoleBox", Vector3(0.0, 0.94, -0.08), 1.18)
	_game_case(window_display, "WindowHeroGameCaseA", Vector3(-0.34, 0.94, -0.34), Vector3(-7.0, 0.0, 0.0), 2, 0.58)
	_game_case(window_display, "WindowHeroGameCaseB", Vector3(0.35, 0.94, -0.34), Vector3(-7.0, 0.0, 0.0), 5, 0.58)


func _build_cameras(root: Node3D) -> void:
	var cameras := Node3D.new()
	cameras.name = "Cameras"
	root.add_child(cameras)

	var hero := Camera3D.new()
	hero.name = "StorefrontHeroCamera"
	hero.current = true
	hero.fov = 58.0
	cameras.add_child(hero)
	hero.global_position = Vector3(0.55, 1.45, -6.35)
	hero.look_at(Vector3(0.08, 1.32, 1.15), Vector3.UP)

	var interior := Camera3D.new()
	interior.name = "InteriorProofCamera"
	interior.fov = 58.0
	cameras.add_child(interior)
	interior.global_position = Vector3(0.25, 1.42, -0.10)
	interior.look_at(Vector3(1.55, 1.05, 2.60), Vector3.UP)


func _controller(parent: Node3D, position_value: Vector3, node_name: String) -> void:
	var controller := Node3D.new()
	controller.name = node_name
	controller.position = position_value
	parent.add_child(controller)
	_box(controller, "ControllerBody", Vector3(0.0, 0.0, 0.0), Vector3(0.34, 0.075, 0.16), _materials["controller_blue"])
	_box(controller, "LeftGrip", Vector3(-0.14, -0.055, 0.0), Vector3(0.10, 0.11, 0.13), _materials["controller_blue"])
	_box(controller, "RightGrip", Vector3(0.14, -0.055, 0.0), Vector3(0.10, 0.11, 0.13), _materials["controller_blue"])
	_box(controller, "FaceButtonCluster", Vector3(0.085, 0.047, -0.035), Vector3(0.08, 0.018, 0.055), _materials["button_gray"])
	_box(controller, "DPad", Vector3(-0.09, 0.047, -0.035), Vector3(0.07, 0.018, 0.055), _materials["button_gray"])


func _planter(parent: Node3D, position_value: Vector3, node_name: String) -> void:
	var planter := Node3D.new()
	planter.name = node_name
	planter.position = position_value
	parent.add_child(planter)
	_box(planter, "PlanterBox", Vector3(0.0, 0.26, 0.0), Vector3(0.64, 0.52, 0.44), _materials["planter_clay"])
	for leaf in range(6):
		var angle := float(leaf) * TAU / 6.0
		var leaf_node := _box(planter, "PlantLeaf%02d" % [leaf + 1], Vector3(cos(angle) * 0.12, 0.62, sin(angle) * 0.09), Vector3(0.10, 0.24, 0.055), _materials["plant_green"])
		leaf_node.rotation_degrees = Vector3(0.0, rad_to_deg(angle), -18.0 + float(leaf % 3) * 12.0)


func _game_case(parent: Node3D, node_name: String, position_value: Vector3, rotation_value: Vector3, variant: int, scale_value: float) -> void:
	var holder := Node3D.new()
	holder.name = node_name
	holder.position = position_value
	holder.rotation_degrees = rotation_value
	holder.scale = Vector3.ONE * scale_value
	parent.add_child(holder)
	_box(holder, "DVDCaseBlackShell", Vector3(0.0, 0.0, 0.0), Vector3(0.22, 0.32, 0.034), _materials["case_black"])
	_bitmap_panel(holder, "GeneratedCoverArtFace", "", Vector3(0.0, 0.0, -0.023), Vector3.ZERO, Vector2(0.18, 0.27), _cover_materials[variant % _cover_materials.size()].albedo_color, Color(0.95, 0.84, 0.42), _cover_texture(variant))
	_box(holder, "ColoredPlatformSpine", Vector3(-0.095, 0.0, -0.041), Vector3(0.026, 0.30, 0.012), _platform_material(variant))
	_box(holder, "TinyPriceSticker", Vector3(0.065, -0.115, -0.044), Vector3(0.055, 0.035, 0.012), _materials["price_sticker"])


func _console_box(parent: Node3D, node_name: String, position_value: Vector3, scale_value: float) -> void:
	var box_node := Node3D.new()
	box_node.name = node_name
	box_node.position = position_value
	box_node.scale = Vector3.ONE * scale_value
	parent.add_child(box_node)
	_box(box_node, "ConsolePackageBody", Vector3(0.0, 0.0, 0.0), Vector3(0.55, 0.34, 0.18), _materials["console_package"])
	_bitmap_panel(box_node, "ConsolePackageBitmapFace", "", Vector3(0.0, 0.0, -0.098), Vector3.ZERO, Vector2(0.46, 0.27), Color(0.30, 0.35, 0.35), Color(0.86, 0.74, 0.46), _console_texture())
	_box(box_node, "ConsoleBoxSideStripe", Vector3(-0.22, 0.0, -0.106), Vector3(0.055, 0.28, 0.014), _materials["platform_teal"])


func _box(parent: Node3D, node_name: String, position_value: Vector3, size: Vector3, material: StandardMaterial3D) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = material
	var node := MeshInstance3D.new()
	node.name = node_name
	node.mesh = mesh
	node.position = position_value
	parent.add_child(node)
	return node


func _bitmap_panel(
	parent: Node3D,
	node_name: String,
	text: String,
	position_value: Vector3,
	rotation_value: Vector3,
	size: Vector2,
	background: Color,
	foreground: Color,
	texture_override: Texture2D = null
) -> MeshInstance3D:
	var mesh := QuadMesh.new()
	mesh.size = size
	var node := MeshInstance3D.new()
	node.name = node_name
	node.mesh = mesh
	node.position = position_value
	node.rotation_degrees = rotation_value
	var mat := StandardMaterial3D.new()
	mat.albedo_color = background
	mat.roughness = 0.66
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.albedo_texture = texture_override if texture_override != null else _sign_texture(background, foreground, text)
	node.material_override = mat
	parent.add_child(node)
	return node


func _build_materials() -> void:
	_materials = {
		"mall_tile": _mat("mall_tile", Color(0.54, 0.53, 0.48), 0.82, 0.0, _checker_texture(Color(0.48, 0.48, 0.43), Color(0.61, 0.60, 0.54), 32)),
		"store_entry_tile": _mat("store_entry_tile", Color(0.61, 0.59, 0.52), 0.78, 0.0, _checker_texture(Color(0.55, 0.54, 0.49), Color(0.68, 0.65, 0.56), 48)),
		"grout": _mat("grout", Color(0.76, 0.70, 0.53), 0.95),
		"mall_wall": _mat("mall_wall", Color(0.58, 0.59, 0.55), 0.9),
		"store_carpet": _mat("store_carpet", Color(0.36, 0.35, 0.30), 0.95, 0.0, _noise_texture(Color(0.27, 0.28, 0.25), Color(0.45, 0.43, 0.36), 28)),
		"warm_drywall": _mat("warm_drywall", Color(0.76, 0.76, 0.68), 0.88, 0.0, _noise_texture(Color(0.68, 0.70, 0.64), Color(0.84, 0.82, 0.72), 34)),
		"slatwall": _mat("slatwall", Color(0.70, 0.70, 0.61), 0.86),
		"slat_shadow": _mat("slat_shadow", Color(0.34, 0.36, 0.32), 0.9),
		"dark_blue_metal": _mat("dark_blue_metal", Color(0.035, 0.12, 0.15), 0.52, 0.1),
		"dark_metal": _mat("dark_metal", Color(0.025, 0.030, 0.032), 0.48, 0.16),
		"painted_column": _mat("painted_column", Color(0.61, 0.66, 0.64), 0.82),
		"sign_cabinet": _emissive_mat("sign_cabinet", Color(0.88, 0.77, 0.55), 0.12),
		"cool_trim": _emissive_mat("cool_trim", Color(0.35, 0.77, 0.84), 0.45),
		"storefront_glass": _glass_mat("storefront_glass", Color(0.58, 0.78, 0.84, 0.25)),
		"clear_glass": _glass_mat("clear_glass", Color(0.72, 0.88, 0.92, 0.27)),
		"frosted_glass": _glass_mat("frosted_glass", Color(0.66, 0.82, 0.86, 0.45)),
		"black_glass": _glass_mat("black_glass", Color(0.01, 0.018, 0.02, 0.88)),
		"brass": _mat("brass", Color(0.78, 0.62, 0.34), 0.38, 0.18),
		"ceiling_panel": _mat("ceiling_panel", Color(0.67, 0.66, 0.61), 0.92, 0.0, _checker_texture(Color(0.61, 0.61, 0.57), Color(0.72, 0.71, 0.66), 18)),
		"ceiling_grid": _mat("ceiling_grid", Color(0.30, 0.31, 0.30), 0.62),
		"fluorescent": _emissive_mat("fluorescent", Color(1.0, 0.90, 0.68), 0.48),
		"backroom_door": _mat("backroom_door", Color(0.42, 0.46, 0.42), 0.76),
		"dark_laminate": _mat("dark_laminate", Color(0.10, 0.075, 0.055), 0.54),
		"cream_counter": _mat("cream_counter", Color(0.78, 0.72, 0.59), 0.62),
		"register_plastic": _mat("register_plastic", Color(0.29, 0.32, 0.32), 0.55),
		"paper_bag": _mat("paper_bag", Color(0.70, 0.58, 0.38), 0.86),
		"pale_paper": _mat("pale_paper", Color(0.84, 0.80, 0.67), 0.92),
		"case_black": _mat("case_black", Color(0.018, 0.020, 0.020), 0.50),
		"price_sticker": _mat("price_sticker", Color(0.88, 0.72, 0.34), 0.66),
		"platform_teal": _mat("platform_teal", Color(0.08, 0.28, 0.30), 0.62),
		"platform_red": _mat("platform_red", Color(0.42, 0.16, 0.13), 0.62),
		"platform_gold": _mat("platform_gold", Color(0.54, 0.42, 0.19), 0.62),
		"console_package": _mat("console_package", Color(0.32, 0.36, 0.35), 0.76),
		"accessory_package": _mat("accessory_package", Color(0.65, 0.58, 0.42), 0.78),
		"acrylic_shelf": _glass_mat("acrylic_shelf", Color(0.78, 0.90, 0.92, 0.23)),
		"empty_slot": _mat("empty_slot", Color(0.45, 0.47, 0.42), 0.86),
		"warm_light": _emissive_mat("warm_light", Color(0.96, 0.78, 0.47), 0.30),
		"controller_blue": _mat("controller_blue", Color(0.055, 0.18, 0.23), 0.58),
		"button_gray": _mat("button_gray", Color(0.64, 0.66, 0.62), 0.55),
		"warm_wood": _mat("warm_wood", Color(0.42, 0.27, 0.14), 0.66, 0.0, _noise_texture(Color(0.33, 0.20, 0.10), Color(0.55, 0.37, 0.18), 18)),
		"planter_clay": _mat("planter_clay", Color(0.50, 0.30, 0.19), 0.82),
		"plant_green": _mat("plant_green", Color(0.15, 0.34, 0.18), 0.78),
	}

	_cover_materials.clear()
	for index in range(12):
		var base: Color = [
			Color(0.13, 0.27, 0.42),
			Color(0.42, 0.22, 0.14),
			Color(0.22, 0.39, 0.24),
			Color(0.50, 0.43, 0.18),
			Color(0.24, 0.19, 0.36),
			Color(0.15, 0.38, 0.40),
		][index % 6]
		_cover_materials.append(_mat("hero_cover_%02d" % [index], base, 0.62))


func _mat(name: String, color: Color, roughness: float, metallic: float = 0.0, texture: Texture2D = null) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.resource_name = name
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	if texture != null:
		material.albedo_texture = texture
	if color.a < 1.0:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return material


func _glass_mat(name: String, color: Color) -> StandardMaterial3D:
	var material := _mat(name, color, 0.08)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
	return material


func _emissive_mat(name: String, color: Color, energy: float) -> StandardMaterial3D:
	var material := _mat(name, color, 0.34)
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = energy
	return material


func _platform_material(index: int) -> StandardMaterial3D:
	match index % 3:
		0:
			return _materials["platform_teal"]
		1:
			return _materials["platform_red"]
		_:
			return _materials["platform_gold"]


func _checker_texture(a: Color, b: Color, cell_size: int) -> ImageTexture:
	var image := Image.create(128, 128, false, Image.FORMAT_RGBA8)
	for y in range(128):
		for x in range(128):
			var use_a := int(floor(float(x) / float(cell_size)) + floor(float(y) / float(cell_size))) % 2 == 0
			image.set_pixel(x, y, a if use_a else b)
	return ImageTexture.create_from_image(image)


func _noise_texture(a: Color, b: Color, cell_size: int) -> ImageTexture:
	var image := Image.create(128, 128, false, Image.FORMAT_RGBA8)
	for y in range(128):
		for x in range(128):
			var band := float(((x * 13 + y * 29) % cell_size)) / float(maxi(1, cell_size))
			image.set_pixel(x, y, a.lerp(b, band))
	return ImageTexture.create_from_image(image)


func _sign_texture(background: Color, foreground: Color, text: String) -> ImageTexture:
	var image := Image.create(256, 64, false, Image.FORMAT_RGBA8)
	for y in range(64):
		for x in range(256):
			var shade: float = 0.92 + 0.08 * (1.0 - abs(float(x) - 128.0) / 128.0)
			image.set_pixel(x, y, background * shade)
	if text.is_empty():
		return ImageTexture.create_from_image(image)

	var cursor_x := 14
	var pixel := 5
	var origin_y := 14
	for letter in text:
		var rows := _glyph_rows(letter)
		for row in range(rows.size()):
			var row_text := rows[row]
			for column in range(row_text.length()):
				if row_text.substr(column, 1) == "#":
					_fill_rect(image, cursor_x + column * pixel, origin_y + row * pixel, pixel - 1, pixel - 1, foreground)
		cursor_x += 31
	return ImageTexture.create_from_image(image)


func _cover_texture(index: int) -> ImageTexture:
	var image := Image.create(128, 192, false, Image.FORMAT_RGBA8)
	var base: Color = _cover_materials[index % _cover_materials.size()].albedo_color
	var accent: Color = [Color(0.90, 0.74, 0.34), Color(0.68, 0.85, 0.78), Color(0.78, 0.55, 0.42)][index % 3]
	for y in range(192):
		for x in range(128):
			var uv_x := float(x) / 127.0
			var shade: float = 0.74 + 0.22 * (1.0 - abs(uv_x - 0.5) * 1.5)
			var c: Color = base * shade
			if y < 20:
				c = accent
			elif y > 170:
				c = Color(0.035, 0.038, 0.04)
			image.set_pixel(x, y, c)
	_draw_cover_shape(image, index, accent)
	_fill_rect(image, 18, 32, 88, 5, Color(0.92, 0.88, 0.70))
	_fill_rect(image, 18, 43, 56, 4, Color(0.75, 0.72, 0.60))
	_fill_rect(image, 94, 166, 24, 14, Color(0.90, 0.72, 0.30))
	return ImageTexture.create_from_image(image)


func _console_texture() -> ImageTexture:
	var image := Image.create(192, 112, false, Image.FORMAT_RGBA8)
	for y in range(112):
		for x in range(192):
			image.set_pixel(x, y, Color(0.28, 0.33, 0.34).lerp(Color(0.43, 0.46, 0.42), float(x) / 191.0))
	_fill_rect(image, 20, 18, 52, 72, Color(0.08, 0.16, 0.18))
	_fill_rect(image, 82, 30, 86, 8, Color(0.86, 0.76, 0.45))
	_fill_rect(image, 82, 48, 54, 7, Color(0.64, 0.74, 0.70))
	_fill_rect(image, 143, 73, 26, 18, Color(0.08, 0.20, 0.22))
	return ImageTexture.create_from_image(image)


func _draw_cover_shape(image: Image, index: int, accent: Color) -> void:
	match index % 4:
		0:
			_fill_ellipse(image, Vector2i(64, 104), Vector2i(34, 44), accent.darkened(0.15))
			_fill_ellipse(image, Vector2i(54, 94), Vector2i(12, 15), Color(0.18, 0.32, 0.40))
		1:
			_fill_rect(image, 42, 70, 44, 72, accent.darkened(0.10))
			_fill_rect(image, 55, 88, 20, 30, Color(0.15, 0.28, 0.36))
		2:
			_fill_ellipse(image, Vector2i(64, 100), Vector2i(42, 28), accent)
			_fill_rect(image, 46, 84, 34, 48, Color(0.22, 0.34, 0.26))
		_:
			_fill_rect(image, 34, 66, 62, 82, accent.darkened(0.12))
			_fill_ellipse(image, Vector2i(66, 108), Vector2i(22, 22), Color(0.12, 0.24, 0.30))


func _fill_rect(image: Image, x0: int, y0: int, width: int, height: int, color: Color) -> void:
	for y in range(maxi(0, y0), mini(image.get_height(), y0 + height)):
		for x in range(maxi(0, x0), mini(image.get_width(), x0 + width)):
			image.set_pixel(x, y, color)


func _fill_ellipse(image: Image, center: Vector2i, radius: Vector2i, color: Color) -> void:
	for y in range(maxi(0, center.y - radius.y), mini(image.get_height(), center.y + radius.y)):
		for x in range(maxi(0, center.x - radius.x), mini(image.get_width(), center.x + radius.x)):
			var dx := float(x - center.x) / float(maxi(1, radius.x))
			var dy := float(y - center.y) / float(maxi(1, radius.y))
			if dx * dx + dy * dy <= 1.0:
				image.set_pixel(x, y, color)


func _glyph_rows(letter: String) -> PackedStringArray:
	match letter.to_upper():
		"G":
			return PackedStringArray([".####", "#....", "#....", "#.###", "#...#", "#...#", ".####"])
		"A":
			return PackedStringArray([".###.", "#...#", "#...#", "#####", "#...#", "#...#", "#...#"])
		"M":
			return PackedStringArray(["#...#", "##.##", "#.#.#", "#...#", "#...#", "#...#", "#...#"])
		"E":
			return PackedStringArray(["#####", "#....", "#....", "####.", "#....", "#....", "#####"])
		"S":
			return PackedStringArray([".####", "#....", "#....", ".###.", "....#", "....#", "####."])
		"4":
			return PackedStringArray(["#...#", "#...#", "#...#", "#####", "....#", "....#", "....#"])
		"U":
			return PackedStringArray(["#...#", "#...#", "#...#", "#...#", "#...#", "#...#", ".###."])
		"O":
			return PackedStringArray([".###.", "#...#", "#...#", "#...#", "#...#", "#...#", ".###."])
		"P":
			return PackedStringArray(["####.", "#...#", "#...#", "####.", "#....", "#....", "#...."])
		"N":
			return PackedStringArray(["#...#", "##..#", "#.#.#", "#..##", "#...#", "#...#", "#...#"])
		_:
			return PackedStringArray([".....", ".....", ".....", ".....", ".....", ".....", "....."])
