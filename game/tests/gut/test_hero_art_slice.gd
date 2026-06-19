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
	assert_true(root.get_meta("visual_rules").has("isolated hero art slice only; no mechanics integration"))

	var camera := scene.get_node_or_null(HERO_CAMERA_PATH)
	assert_not_null(camera, "Hero scene should expose a fixed review camera.")


func test_hero_art_slice_does_not_embed_gameplay_systems() -> void:
	var scene := HERO_SCENE.instantiate()
	add_child_autofree(scene)
	await get_tree().process_frame

	assert_null(scene.find_child("StoreSession", true, false))
	assert_null(scene.find_child("CustomerManager", true, false))
	assert_null(scene.find_child("FixturePlacementManager", true, false))
	assert_null(scene.find_child("RegisterCheckoutPanel", true, false))
