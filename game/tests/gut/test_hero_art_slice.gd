extends GutTest

const HERO_SCENE := preload("res://scenes/world/art_benchmark/hero_art_slice.tscn")
const HERO_CAMERA_PATH := "HeroArtRoot/Cameras/StorefrontHeroCamera"


func test_hero_art_slice_loads_with_locked_visual_scope() -> void:
	var scene := HERO_SCENE.instantiate()
	add_child_autofree(scene)
	await get_tree().process_frame

	var root := scene.get_node_or_null("HeroArtRoot")
	assert_not_null(root, "Hero art root should be generated.")
	assert_eq(root.get_meta("packet"), "05-hero-art-slice-proof")
	assert_eq(root.get_meta("proof_method"), "authored_bitmap_assets_and_scene_authored_modules")
	assert_eq(root.get_meta("integration_state"), "future_integration_only")
	assert_true(root.get_meta("visual_rules").has("isolated hero art slice only; no mechanics integration"))
	assert_true(root.get_meta("visual_rules").has("authored/imported-style art proof; no visible procedural text panels"))

	var camera := scene.get_node_or_null(HERO_CAMERA_PATH)
	assert_not_null(camera, "Hero scene should expose a fixed review camera.")

	assert_not_null(scene.find_child("BakedGames4USignBitmap", true, false))
	assert_not_null(scene.find_child("StarterWallRackWithVisibleEmptyCapacity", true, false))
	assert_not_null(scene.find_child("RightSideCashWrapCounterArtProof", true, false))
	assert_not_null(scene.find_child("DayOneStarterReceivingHint", true, false))


func test_hero_art_slice_does_not_embed_gameplay_systems() -> void:
	var scene := HERO_SCENE.instantiate()
	add_child_autofree(scene)
	await get_tree().process_frame

	assert_null(scene.find_child("StoreSession", true, false))
	assert_null(scene.find_child("CustomerManager", true, false))
	assert_null(scene.find_child("FixturePlacementManager", true, false))
	assert_null(scene.find_child("RegisterCheckoutPanel", true, false))


func test_hero_art_slice_uses_baked_assets_not_live_text_nodes() -> void:
	var scene := HERO_SCENE.instantiate()
	add_child_autofree(scene)
	await get_tree().process_frame

	assert_null(scene.find_child("*Label*", true, false))
	assert_null(scene.find_child("*Text*", true, false))
	assert_true(FileAccess.file_exists("res://assets/art_proof/generated/games4u_sign.png"))
	assert_true(FileAccess.file_exists("res://assets/art_proof/generated/footy_2002_cover.png"))
	assert_true(FileAccess.file_exists("res://assets/art_proof/generated/critter_quest_cover.png"))
	assert_true(FileAccess.file_exists("res://assets/art_proof/generated/vortex_console_box.png"))
	assert_true(FileAccess.file_exists("res://assets/art_proof/generated/controller_pack.png"))
