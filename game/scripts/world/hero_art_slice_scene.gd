extends Node3D
class_name HeroArtSliceScene

const HERO_CAMERA_PATH := "HeroArtRoot/Cameras/StorefrontHeroCamera"
const ART_PROOF_ROOT := "res://assets/art_proof/generated/"

var _materials: Dictionary = {}
var _cover_textures: Array[String] = [
	ART_PROOF_ROOT + "footy_2002_cover.png",
	ART_PROOF_ROOT + "critter_quest_cover.png",
	ART_PROOF_ROOT + "orbit_runner_cover.png",
	ART_PROOF_ROOT + "cobalt_courier_cover.png",
]


func _ready() -> void:
	if has_node("HeroArtRoot"):
		return

	_build_materials()
	_build_scene()


func visual_rules() -> PackedStringArray:
	return PackedStringArray([
		"isolated hero art slice only; no mechanics integration",
		"authored/imported-style art proof; no visible procedural text panels",
		"mall storefront first read with visible first 15-20 feet of store",
		"small-chain Games4U identity, legal-safe fictional products",
		"empty-ish pre-day-one store with starter products and visible empty fixture capacity",
		"product art and fixture silhouette must read before labels",
	])


func _build_scene() -> void:
	var root := Node3D.new()
	root.name = "HeroArtRoot"
	root.set_meta("packet", "05-hero-art-slice-proof")
	root.set_meta("proof_method", "authored_bitmap_assets_and_scene_authored_modules")
	root.set_meta("integration_state", "future_integration_only")
	root.set_meta("visual_rules", visual_rules())
	add_child(root)

	_build_world(root)
	_build_mall_concourse(root)
	_build_store_shell(root)
	_build_storefront(root)
	_build_counter(root)
	_build_fixture_and_products(root)
	_build_startup_delivery(root)
	_build_cameras(root)


func _build_world(root: Node3D) -> void:
	var world := WorldEnvironment.new()
	world.name = "HeroArtWorldEnvironment"
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.50, 0.52, 0.50)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.76, 0.74, 0.66)
	environment.ambient_light_energy = 0.82
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.adjustment_enabled = true
	environment.adjustment_brightness = 1.03
	environment.adjustment_contrast = 1.08
	environment.adjustment_saturation = 0.92
	world.environment = environment
	root.add_child(world)

	var sun := DirectionalLight3D.new()
	sun.name = "SoftMallSkylight"
	sun.light_energy = 0.66
	sun.rotation_degrees = Vector3(-43.0, 24.0, 0.0)
	root.add_child(sun)

	for index in range(5):
		var light := OmniLight3D.new()
		light.name = "WarmStoreFill%02d" % [index + 1]
		light.light_color = Color(1.0, 0.91, 0.74)
		light.light_energy = 0.44
		light.omni_range = 4.2
		light.position = Vector3(-3.0 + float(index) * 1.45, 2.35, -0.9 - float(index % 2) * 1.9)
		root.add_child(light)


func _build_mall_concourse(root: Node3D) -> void:
	var mall := Node3D.new()
	mall.name = "SecondFloorMallConcourseArtProof"
	root.add_child(mall)

	_plane_xz(mall, "MallTileFloorBitmap", Vector3(0.0, -0.02, 4.0), Vector2(12.0, 8.0), _materials["mall_tile"])
	_box(mall, "OppositeMallWallQuietMass", Vector3(0.0, 1.35, 7.72), Vector3(12.0, 2.7, 0.18), _materials["mall_wall"])
	_neighbor_store(mall, "NeighborCardsAndComics", Vector3(-4.45, 0.0, 7.58), _materials["neighbor_green"], _materials["brass"])
	_neighbor_store(mall, "NeighborMusicAndMovies", Vector3(4.35, 0.0, 7.58), _materials["neighbor_blue"], _materials["cool_trim"])

	_box(mall, "SecondFloorGuardrailTopRail", Vector3(-5.35, 1.02, 3.65), Vector3(0.10, 0.08, 4.9), _materials["nearly_black"])
	_box(mall, "SecondFloorGuardrailMidRail", Vector3(-5.35, 0.66, 3.65), Vector3(0.07, 0.06, 4.9), _materials["nearly_black"])
	for index in range(6):
		_box(mall, "SecondFloorGuardrailPost%02d" % [index + 1], Vector3(-5.35, 0.52, 1.32 + float(index) * 0.92), Vector3(0.12, 1.05, 0.12), _materials["nearly_black"])

	_mall_bench(mall, Vector3(3.55, 0.0, 3.85))
	_planter(mall, Vector3(-3.4, 0.0, 4.65), "LeftConcoursePlanter")
	_planter(mall, Vector3(5.15, 0.0, 5.18), "RightConcoursePlanter")


func _neighbor_store(parent: Node3D, node_name: String, position: Vector3, panel_mat: Material, accent_mat: Material) -> void:
	var store := Node3D.new()
	store.name = node_name
	store.position = position
	parent.add_child(store)
	_box(store, "DarkRecessedNeighborGlass", Vector3(0.0, 1.04, 0.0), Vector3(2.05, 1.82, 0.06), _materials["dark_glass"])
	_box(store, "SimpleNeighborFascia", Vector3(0.0, 2.20, -0.04), Vector3(2.35, 0.34, 0.08), panel_mat)
	_box(store, "QuietNeighborLightStrip", Vector3(0.0, 2.45, -0.08), Vector3(2.20, 0.05, 0.05), accent_mat)


func _build_store_shell(root: Node3D) -> void:
	var shell := Node3D.new()
	shell.name = "FirstStoreInteriorAuthoredShell"
	root.add_child(shell)

	_plane_xz(shell, "LowPileStoreCarpetBitmap", Vector3(0.0, -0.015, -2.65), Vector2(8.5, 7.2), _materials["carpet"])
	_box(shell, "EntryTileTransitionSlab", Vector3(0.0, 0.005, 0.28), Vector3(8.45, 0.05, 1.05), _materials["entry_tile"])
	_box(shell, "LeftCleanDrywallPlane", Vector3(-4.32, 1.36, -2.52), Vector3(0.12, 2.72, 7.05), _materials["warm_drywall"])
	_box(shell, "RightCleanDrywallPlane", Vector3(4.32, 1.36, -2.52), Vector3(0.12, 2.72, 7.05), _materials["warm_drywall"])
	_box(shell, "RearSlatwallWithDepth", Vector3(0.0, 1.36, -6.03), Vector3(8.65, 2.72, 0.13), _materials["slatwall"])
	_box(shell, "LeftBaseboard", Vector3(-4.23, 0.16, -2.52), Vector3(0.13, 0.23, 6.95), _materials["store_blue"])
	_box(shell, "RightBaseboard", Vector3(4.23, 0.16, -2.52), Vector3(0.13, 0.23, 6.95), _materials["store_blue"])
	_box(shell, "RearBaseboard", Vector3(0.0, 0.16, -5.93), Vector3(8.42, 0.23, 0.12), _materials["store_blue"])

	for groove in range(9):
		_box(shell, "RearSlatwallShadowGroove%02d" % [groove + 1], Vector3(0.0, 0.56 + float(groove) * 0.19, -5.945), Vector3(8.28, 0.018, 0.03), _materials["slat_shadow"])

	_box(shell, "QuietDropCeilingPlane", Vector3(0.0, 2.80, -2.53), Vector3(8.65, 0.08, 7.08), _materials["ceiling"])
	for x_index in range(6):
		_box(shell, "CeilingGridCrossRunner%02d" % [x_index + 1], Vector3(-3.6 + float(x_index) * 1.45, 2.745, -2.53), Vector3(0.035, 0.055, 6.9), _materials["ceiling_grid"])
	for z_index in range(6):
		_box(shell, "CeilingGridLongRunner%02d" % [z_index + 1], Vector3(0.0, 2.74, 0.4 - float(z_index) * 1.25), Vector3(8.45, 0.055, 0.035), _materials["ceiling_grid"])
	for fixture in range(4):
		_box(shell, "WarmFluorescentDiffuser%02d" % [fixture + 1], Vector3(-2.55 + float(fixture % 2) * 5.1, 2.69, -1.05 - float(fixture / 2) * 2.55), Vector3(1.25, 0.04, 0.32), _materials["warm_light"])

	_box(shell, "BackroomDoorSolidMass", Vector3(-3.48, 1.05, -5.84), Vector3(0.76, 1.85, 0.06), _materials["backroom_door"])
	_box(shell, "BackroomDoorInsetWindow", Vector3(-3.48, 1.56, -5.785), Vector3(0.42, 0.34, 0.035), _materials["frosted_glass"])
	_box(shell, "EmployeeOnlySmallPlaque", Vector3(-3.48, 1.02, -5.775), Vector3(0.38, 0.08, 0.025), _materials["brass"])


func _build_storefront(root: Node3D) -> void:
	var front := Node3D.new()
	front.name = "Games4UAuthoredStorefront"
	root.add_child(front)

	_box(front, "DeepBlueHeaderBulkhead", Vector3(0.0, 2.60, 0.78), Vector3(8.95, 0.52, 0.34), _materials["store_blue"])
	_box(front, "HeaderLowerShadowLip", Vector3(0.0, 2.29, 0.72), Vector3(8.95, 0.08, 0.40), _materials["nearly_black"])
	_box(front, "HeaderTopCoolTrim", Vector3(0.0, 2.89, 0.96), Vector3(8.70, 0.055, 0.055), _materials["cool_trim"])
	_box(front, "HeaderLowerCoolTrim", Vector3(0.0, 2.29, 0.96), Vector3(8.70, 0.04, 0.055), _materials["cool_trim"])
	_quad_xy(front, "BakedGames4USignBitmap", Vector3(0.0, 2.62, 1.02), Vector2(2.95, 0.68), _materials["games4u_sign"])

	_box(front, "LeftStorefrontPierPainted", Vector3(-4.38, 1.34, 0.73), Vector3(0.28, 2.66, 0.32), _materials["painted_column"])
	_box(front, "RightStorefrontPierPainted", Vector3(4.38, 1.34, 0.73), Vector3(0.28, 2.66, 0.32), _materials["painted_column"])
	_box(front, "StorefrontKickPlate", Vector3(0.0, 0.18, 0.78), Vector3(8.65, 0.36, 0.16), _materials["store_blue"])

	for x in [-3.55, -2.25, -0.88, 0.88, 2.25, 3.55]:
		_box(front, "WeightedAluminumMullion%02d" % [int((x + 4.0) * 10.0)], Vector3(x, 1.35, 0.84), Vector3(0.085, 2.42, 0.105), _materials["dark_metal"])
	for y in [0.78, 1.58, 2.16]:
		_box(front, "StorefrontHorizontalRail%02d" % [int(y * 100.0)], Vector3(0.0, y, 0.845), Vector3(8.62, 0.07, 0.105), _materials["dark_metal"])
	for pane in range(5):
		_box(front, "TintedGlassPane%02d" % [pane + 1], Vector3(-3.0 + float(pane) * 1.5, 1.42, 0.91), Vector3(1.18, 1.46, 0.025), _materials["store_glass"])

	var door := Node3D.new()
	door.name = "OpenGlassDoorFixedAngle"
	door.position = Vector3(0.0, 0.0, 0.84)
	door.rotation_degrees = Vector3(0.0, 16.0, 0.0)
	front.add_child(door)
	_box(door, "OpenDoorGlassPanel", Vector3(0.0, 1.28, 0.03), Vector3(1.00, 1.74, 0.025), _materials["store_glass"])
	_box(door, "OpenDoorTopRail", Vector3(0.0, 2.18, 0.03), Vector3(1.08, 0.08, 0.085), _materials["dark_metal"])
	_box(door, "OpenDoorBottomRail", Vector3(0.0, 0.37, 0.03), Vector3(1.08, 0.08, 0.085), _materials["dark_metal"])
	_box(door, "OpenDoorLeftRail", Vector3(-0.54, 1.28, 0.03), Vector3(0.08, 1.82, 0.085), _materials["dark_metal"])
	_box(door, "OpenDoorRightRail", Vector3(0.54, 1.28, 0.03), Vector3(0.08, 1.82, 0.085), _materials["dark_metal"])
	_box(door, "BrassPullHandle", Vector3(0.39, 1.22, 0.10), Vector3(0.055, 0.62, 0.06), _materials["brass"])

	_quad_xy(front, "BakedOpenSetupSign", Vector3(1.22, 1.55, 0.965), Vector2(0.50, 0.22), _materials["open_sign"])
	_box(front, "DoorThresholdMetalStrip", Vector3(0.0, 0.025, 0.42), Vector3(1.68, 0.05, 0.18), _materials["brass"])


func _build_counter(root: Node3D) -> void:
	var counter := Node3D.new()
	counter.name = "RightSideCashWrapCounterArtProof"
	counter.position = Vector3(2.18, 0.0, -1.25)
	counter.rotation_degrees = Vector3(0.0, 8.0, 0.0)
	root.add_child(counter)

	_box(counter, "DarkLaminateCashWrapBody", Vector3(0.0, 0.46, 0.0), Vector3(2.72, 0.92, 0.74), _materials["dark_laminate"])
	_box(counter, "CreamLaminateCountertop", Vector3(0.0, 0.96, 0.0), Vector3(2.88, 0.12, 0.88), _materials["cream"])
	_box(counter, "GlassDisplayFront", Vector3(0.0, 0.66, 0.43), Vector3(2.46, 0.54, 0.03), _materials["clear_glass"])
	_box(counter, "DisplayInteriorWarmShelf", Vector3(0.0, 0.58, 0.34), Vector3(2.32, 0.08, 0.18), _materials["warm_light"])
	for index in range(5):
		_game_case(counter, "CounterDisplayCase%02d" % [index + 1], Vector3(-0.86 + float(index) * 0.43, 0.73, 0.45), Vector3(-8.0, 0.0, 0.0), index % _cover_textures.size(), 0.45)

	_box(counter, "RegisterBaseWithKeys", Vector3(-0.74, 1.16, -0.18), Vector3(0.56, 0.22, 0.34), _materials["register_plastic"])
	_box(counter, "RegisterScreenDarkGlass", Vector3(-0.74, 1.37, 0.02), Vector3(0.44, 0.28, 0.055), _materials["dark_glass"])
	_box(counter, "ReceiptPrinterSmall", Vector3(-0.08, 1.11, -0.18), Vector3(0.36, 0.15, 0.28), _materials["register_plastic"])
	_box(counter, "HandScannerCradle", Vector3(0.38, 1.10, 0.12), Vector3(0.36, 0.075, 0.24), _materials["dark_metal"])
	_controller(counter, Vector3(0.40, 1.17, 0.28), "LooseDemoControllerOnCounter")
	_box(counter, "FlatPaperBagStack", Vector3(0.94, 1.08, -0.18), Vector3(0.34, 0.08, 0.28), _materials["paper_bag"])
	_box(counter, "TradeSlipStack", Vector3(0.92, 1.075, 0.15), Vector3(0.36, 0.025, 0.24), _materials["pale_paper"])


func _build_fixture_and_products(root: Node3D) -> void:
	var fixture := Node3D.new()
	fixture.name = "StarterWallRackWithVisibleEmptyCapacity"
	fixture.position = Vector3(-2.46, 0.0, -2.75)
	fixture.rotation_degrees = Vector3(0.0, -8.0, 0.0)
	root.add_child(fixture)

	_box(fixture, "LaminateRackBase", Vector3(0.0, 0.18, 0.0), Vector3(2.62, 0.36, 0.62), _materials["dark_laminate"])
	_box(fixture, "InsetSlatwallBackPanel", Vector3(0.0, 1.14, -0.28), Vector3(2.72, 1.88, 0.10), _materials["slatwall"])
	_cylinder(fixture, "RoundedLeftRackSide", Vector3(-1.36, 1.03, -0.08), 0.055, 1.76, _materials["dark_metal"], Vector3.ZERO)
	_cylinder(fixture, "RoundedRightRackSide", Vector3(1.36, 1.03, -0.08), 0.055, 1.76, _materials["dark_metal"], Vector3.ZERO)
	_quad_xy(fixture, "BakedNewThisWeekShelfHeader", Vector3(0.0, 1.94, 0.03), Vector2(1.75, 0.32), _materials["new_this_week"])
	for rail in range(7):
		_box(fixture, "BackPanelSlatGroove%02d" % [rail + 1], Vector3(0.0, 0.58 + float(rail) * 0.20, -0.225), Vector3(2.46, 0.018, 0.035), _materials["slat_shadow"])
	for shelf in range(4):
		var y := 0.52 + float(shelf) * 0.35
		_box(fixture, "AcrylicShelfPlane%02d" % [shelf + 1], Vector3(0.0, y, 0.05), Vector3(2.42, 0.045, 0.58), _materials["acrylic"])
		_cylinder(fixture, "RoundedShelfFrontLip%02d" % [shelf + 1], Vector3(0.0, y + 0.06, 0.36), 0.03, 2.50, _materials["dark_metal"], Vector3(0.0, 0.0, 90.0))
		_box(fixture, "VisibleEmptyCapacityShadow%02d" % [shelf + 1], Vector3(0.34, y + 0.09, 0.23), Vector3(1.30, 0.03, 0.025), _materials["empty_slot_shadow"])

	for slot in range(6):
		_game_case(fixture, "StarterFootyCase%02d" % [slot + 1], Vector3(-0.92 + float(slot) * 0.20, 0.70, 0.40), Vector3(-10.0, 0.0, 0.0), 0, 0.48)
	for slot in range(4):
		_game_case(fixture, "StarterCritterQuestCase%02d" % [slot + 1], Vector3(0.42 + float(slot) * 0.20, 0.70, 0.40), Vector3(-10.0, 0.0, 0.0), 1, 0.48)
	_console_box(fixture, "StarterVortexConsoleBoxOnLowerShelf", Vector3(-0.50, 0.38, 0.37), 1.0)
	_accessory_pack(fixture, "StarterControllerRetailPack", Vector3(0.72, 0.42, 0.39), 0.72)

	var display := Node3D.new()
	display.name = "SparseWindowStarterDisplay"
	display.position = Vector3(-1.75, 0.0, -0.36)
	display.rotation_degrees = Vector3(0.0, 11.0, 0.0)
	root.add_child(display)
	_cylinder(display, "RoundedWindowDisplayPedestal", Vector3(0.0, 0.44, 0.0), 0.36, 0.88, _materials["cream"], Vector3.ZERO)
	_console_box(display, "WindowHeroVortexConsoleBox", Vector3(0.0, 0.98, 0.0), 1.16)
	_game_case(display, "WindowHeroFootyCase", Vector3(-0.38, 1.00, 0.34), Vector3(-7.0, 0.0, 0.0), 0, 0.58)
	_game_case(display, "WindowHeroCritterCase", Vector3(0.38, 1.00, 0.34), Vector3(-7.0, 0.0, 0.0), 1, 0.58)


func _build_startup_delivery(root: Node3D) -> void:
	var receiving := Node3D.new()
	receiving.name = "DayOneStarterReceivingHint"
	receiving.position = Vector3(3.0, 0.0, -4.2)
	receiving.rotation_degrees = Vector3(0.0, -12.0, 0.0)
	root.add_child(receiving)
	_box(receiving, "CleanReceivingCartBase", Vector3(0.0, 0.42, 0.0), Vector3(1.15, 0.12, 0.68), _materials["dark_metal"])
	for wheel in [Vector3(-0.44, 0.16, -0.23), Vector3(0.44, 0.16, -0.23), Vector3(-0.44, 0.16, 0.23), Vector3(0.44, 0.16, 0.23)]:
		_cylinder(receiving, "CartCaster%02d" % [receiving.get_child_count()], wheel, 0.07, 0.04, _materials["nearly_black"], Vector3(90.0, 0.0, 0.0))
	_box(receiving, "StarterDeliveryBoxA", Vector3(-0.28, 0.70, 0.02), Vector3(0.42, 0.42, 0.36), _materials["cardboard"])
	_box(receiving, "StarterDeliveryBoxB", Vector3(0.26, 0.66, -0.08), Vector3(0.36, 0.34, 0.32), _materials["cardboard"])
	_box(receiving, "FoldedSetupPosterTube", Vector3(0.38, 0.93, 0.18), Vector3(0.12, 0.10, 0.50), _materials["paper_bag"])


func _build_cameras(root: Node3D) -> void:
	var cameras := Node3D.new()
	cameras.name = "Cameras"
	root.add_child(cameras)

	var hero := Camera3D.new()
	hero.name = "StorefrontHeroCamera"
	hero.current = true
	hero.fov = 55.0
	cameras.add_child(hero)
	hero.global_position = Vector3(0.72, 1.48, 6.75)
	hero.look_at(Vector3(0.0, 1.25, -1.35), Vector3.UP)

	var interior := Camera3D.new()
	interior.name = "InteriorFixtureCamera"
	interior.fov = 58.0
	cameras.add_child(interior)
	interior.global_position = Vector3(1.60, 1.35, 0.08)
	interior.look_at(Vector3(-1.25, 1.02, -3.0), Vector3.UP)


func _build_materials() -> void:
	_materials["warm_drywall"] = _mat(Color(0.70, 0.72, 0.66), 0.92)
	_materials["mall_wall"] = _mat(Color(0.49, 0.50, 0.47), 0.94)
	_materials["store_blue"] = _mat(Color(0.045, 0.135, 0.18), 0.72)
	_materials["dark_metal"] = _mat(Color(0.055, 0.065, 0.070), 0.58, 0.15)
	_materials["nearly_black"] = _mat(Color(0.025, 0.028, 0.030), 0.68)
	_materials["dark_laminate"] = _mat(Color(0.08, 0.07, 0.055), 0.86)
	_materials["cream"] = _mat(Color(0.78, 0.75, 0.64), 0.74)
	_materials["entry_tile"] = _mat(Color(0.56, 0.55, 0.49), 0.82)
	_materials["ceiling"] = _mat(Color(0.54, 0.54, 0.51), 0.95)
	_materials["ceiling_grid"] = _mat(Color(0.37, 0.38, 0.36), 0.85)
	_materials["warm_light"] = _emissive_mat(Color(1.0, 0.84, 0.55), 0.36)
	_materials["cool_trim"] = _emissive_mat(Color(0.36, 0.77, 0.86), 0.22)
	_materials["brass"] = _mat(Color(0.82, 0.66, 0.34), 0.45, 0.25)
	_materials["painted_column"] = _mat(Color(0.60, 0.66, 0.66), 0.88)
	_materials["slatwall"] = _mat(Color(0.54, 0.62, 0.60), 0.88)
	_materials["slat_shadow"] = _mat(Color(0.30, 0.36, 0.36), 0.96)
	_materials["backroom_door"] = _mat(Color(0.25, 0.34, 0.36), 0.84)
	_materials["register_plastic"] = _mat(Color(0.58, 0.60, 0.57), 0.72)
	_materials["paper_bag"] = _mat(Color(0.76, 0.63, 0.40), 0.90)
	_materials["pale_paper"] = _mat(Color(0.85, 0.82, 0.69), 0.92)
	_materials["cardboard"] = _mat(Color(0.52, 0.36, 0.19), 0.92)
	_materials["empty_slot_shadow"] = _mat(Color(0.18, 0.25, 0.25), 0.96)
	_materials["acrylic"] = _glass_mat(Color(0.72, 0.88, 0.95, 0.34))
	_materials["store_glass"] = _glass_mat(Color(0.58, 0.79, 0.86, 0.30))
	_materials["clear_glass"] = _glass_mat(Color(0.75, 0.90, 0.95, 0.28))
	_materials["frosted_glass"] = _glass_mat(Color(0.70, 0.86, 0.90, 0.42))
	_materials["dark_glass"] = _glass_mat(Color(0.02, 0.025, 0.03, 0.82))
	_materials["neighbor_green"] = _mat(Color(0.19, 0.28, 0.23), 0.80)
	_materials["neighbor_blue"] = _mat(Color(0.18, 0.25, 0.30), 0.80)

	_materials["games4u_sign"] = _texture_mat(ART_PROOF_ROOT + "games4u_sign.png")
	_materials["open_sign"] = _texture_mat(ART_PROOF_ROOT + "open_setup_sign.png")
	_materials["grand_opening"] = _texture_mat(ART_PROOF_ROOT + "grand_opening_poster.png")
	_materials["new_this_week"] = _texture_mat(ART_PROOF_ROOT + "new_this_week_label.png")
	_materials["console_box_art"] = _texture_mat(ART_PROOF_ROOT + "vortex_console_box.png")
	_materials["controller_pack_art"] = _texture_mat(ART_PROOF_ROOT + "controller_pack.png")
	_materials["carpet"] = _texture_mat(ART_PROOF_ROOT + "low_pile_carpet.png")
	_materials["mall_tile"] = _texture_mat(ART_PROOF_ROOT + "mall_tile_grid.png")


func _mat(color: Color, roughness: float, metallic: float = 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	return material


func _emissive_mat(color: Color, energy: float) -> StandardMaterial3D:
	var material := _mat(color, 0.55)
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = energy
	return material


func _glass_mat(color: Color) -> StandardMaterial3D:
	var material := _mat(color, 0.18)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = color
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material


func _texture_mat(path: String) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	var image := Image.new()
	var error := image.load(path)
	if error != OK:
		push_error("Could not load hero art proof texture: %s" % path)
		return material
	var texture := ImageTexture.create_from_image(image)
	material.albedo_texture = texture
	material.roughness = 0.82
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material


func _box(parent: Node3D, node_name: String, position: Vector3, size: Vector3, material: Material, rotation_degrees: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.material_override = material
	instance.position = position
	instance.rotation_degrees = rotation_degrees
	parent.add_child(instance)
	return instance


func _cylinder(parent: Node3D, node_name: String, position: Vector3, radius: float, height: float, material: Material, rotation_degrees: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 24
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.material_override = material
	instance.position = position
	instance.rotation_degrees = rotation_degrees
	parent.add_child(instance)
	return instance


func _sphere(parent: Node3D, node_name: String, position: Vector3, scale: Vector3, material: Material) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mesh.radial_segments = 24
	mesh.rings = 12
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.material_override = material
	instance.position = position
	instance.scale = scale
	parent.add_child(instance)
	return instance


func _quad_xy(parent: Node3D, node_name: String, position: Vector3, size: Vector2, material: Material, rotation_degrees: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mesh := QuadMesh.new()
	mesh.size = size
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.material_override = material
	instance.position = position
	instance.rotation_degrees = rotation_degrees
	parent.add_child(instance)
	return instance


func _plane_xz(parent: Node3D, node_name: String, position: Vector3, size: Vector2, material: Material) -> MeshInstance3D:
	var mesh := PlaneMesh.new()
	mesh.size = size
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.material_override = material
	instance.position = position
	parent.add_child(instance)
	return instance


func _game_case(parent: Node3D, node_name: String, position: Vector3, rotation_degrees: Vector3, cover_index: int, height: float) -> Node3D:
	var case_root := Node3D.new()
	case_root.name = node_name
	case_root.position = position
	case_root.rotation_degrees = rotation_degrees
	parent.add_child(case_root)

	var width := height * 0.62
	_box(case_root, "DVDCaseDarkPlasticBody", Vector3.ZERO, Vector3(width, height, 0.035), _materials["nearly_black"])
	var cover_path := _cover_textures[cover_index % _cover_textures.size()]
	_quad_xy(case_root, "BakedCoverArtFront", Vector3(0.0, 0.0, 0.022), Vector2(width * 0.92, height * 0.92), _texture_mat(cover_path))
	_box(case_root, "ColoredSpineBand", Vector3(-width * 0.51, 0.0, 0.030), Vector3(width * 0.06, height * 0.96, 0.018), _materials["brass"])
	_box(case_root, "ClearCaseSheen", Vector3(0.0, 0.0, 0.041), Vector3(width * 0.96, height * 0.96, 0.006), _materials["clear_glass"])
	return case_root


func _console_box(parent: Node3D, node_name: String, position: Vector3, scale_factor: float) -> Node3D:
	var box_root := Node3D.new()
	box_root.name = node_name
	box_root.position = position
	parent.add_child(box_root)
	var size := Vector3(0.62, 0.42, 0.16) * scale_factor
	_box(box_root, "ConsoleBoxCardboardMass", Vector3.ZERO, size, _materials["store_blue"])
	_quad_xy(box_root, "BakedConsoleBoxFrontArt", Vector3(0.0, 0.0, size.z * 0.54), Vector2(size.x * 0.92, size.y * 0.88), _materials["console_box_art"])
	_box(box_root, "ConsoleBoxSideAccent", Vector3(size.x * 0.52, 0.0, 0.0), Vector3(0.025, size.y * 0.96, size.z * 0.95), _materials["brass"])
	return box_root


func _accessory_pack(parent: Node3D, node_name: String, position: Vector3, scale_factor: float) -> Node3D:
	var pack_root := Node3D.new()
	pack_root.name = node_name
	pack_root.position = position
	parent.add_child(pack_root)
	var size := Vector3(0.30, 0.42, 0.10) * scale_factor
	_box(pack_root, "AccessoryBlisterCardMass", Vector3.ZERO, size, _materials["paper_bag"])
	_quad_xy(pack_root, "BakedControllerPackFront", Vector3(0.0, 0.0, size.z * 0.56), Vector2(size.x * 0.92, size.y * 0.92), _materials["controller_pack_art"])
	return pack_root


func _controller(parent: Node3D, position: Vector3, node_name: String) -> Node3D:
	var controller := Node3D.new()
	controller.name = node_name
	controller.position = position
	parent.add_child(controller)
	_sphere(controller, "RoundedControllerCenter", Vector3.ZERO, Vector3(0.34, 0.11, 0.18), _materials["nearly_black"])
	_sphere(controller, "LeftGrip", Vector3(-0.19, -0.01, 0.02), Vector3(0.16, 0.10, 0.24), _materials["nearly_black"])
	_sphere(controller, "RightGrip", Vector3(0.19, -0.01, 0.02), Vector3(0.16, 0.10, 0.24), _materials["nearly_black"])
	_sphere(controller, "LeftThumbstick", Vector3(-0.10, 0.075, 0.06), Vector3(0.045, 0.028, 0.045), _materials["dark_metal"])
	_sphere(controller, "FaceButtonA", Vector3(0.09, 0.075, 0.05), Vector3(0.038, 0.022, 0.038), _materials["cool_trim"])
	_sphere(controller, "FaceButtonB", Vector3(0.16, 0.075, 0.02), Vector3(0.035, 0.020, 0.035), _materials["brass"])
	return controller


func _mall_bench(parent: Node3D, position: Vector3) -> void:
	var bench := Node3D.new()
	bench.name = "QuietMallBench"
	bench.position = position
	parent.add_child(bench)
	_box(bench, "BenchWoodSeat", Vector3(0.0, 0.42, 0.0), Vector3(1.30, 0.14, 0.36), _materials["paper_bag"])
	_box(bench, "BenchWoodBack", Vector3(0.0, 0.72, -0.18), Vector3(1.30, 0.38, 0.08), _materials["paper_bag"])
	_box(bench, "BenchLeftLeg", Vector3(-0.52, 0.22, 0.02), Vector3(0.10, 0.42, 0.12), _materials["dark_metal"])
	_box(bench, "BenchRightLeg", Vector3(0.52, 0.22, 0.02), Vector3(0.10, 0.42, 0.12), _materials["dark_metal"])


func _planter(parent: Node3D, position: Vector3, node_name: String) -> void:
	var planter := Node3D.new()
	planter.name = node_name
	planter.position = position
	parent.add_child(planter)
	_cylinder(planter, "RoundedPlanterPot", Vector3(0.0, 0.23, 0.0), 0.25, 0.46, _materials["cardboard"], Vector3.ZERO)
	for leaf in range(7):
		var angle := TAU * float(leaf) / 7.0
		var x := cos(angle) * 0.18
		var z := sin(angle) * 0.18
		_sphere(planter, "SoftPlanterLeaf%02d" % [leaf + 1], Vector3(x, 0.58 + float(leaf % 2) * 0.08, z), Vector3(0.10, 0.20, 0.04), _materials["neighbor_green"])
