extends GutTest

const ENV_PATH: String = "res://game/resources/environments/env_retro_games.tres"
const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"

const RETRO_ENV_MAX_GLOW_BLOOM: float = 0.12
const RETRO_ENV_MAX_GLOW_STRENGTH: float = 0.32
const RETRO_ENV_MAX_AMBIENT_ENERGY: float = 0.25
const GLOBAL_KEY_MAX_ENERGY: float = 0.75
const GLOBAL_KEY_MAX_RANGE: float = 11.0
const ZONE_LIGHT_MAX_ENERGY: float = 0.9
const ZONE_OMNI_MAX_RANGE: float = 6.0
const ZONE_SPOT_MAX_RANGE: float = 4.2
const CHECKOUT_SERVICE_MAX_ENERGY: float = 0.9
const BACKROOM_UTILITY_MIN_ENERGY: float = 0.22

const REQUIRED_ZONE_LIGHTS: Array[String] = [
	"ReadabilityProps/ZoneLighting/MainAisleWarmFill",
	"ReadabilityProps/ZoneLighting/CheckoutAmberFill",
	"ReadabilityProps/ZoneLighting/OldGenZoneFill",
]

const VIEW_ANCHORS: Dictionary = {
	"spawn": [
		"PlayerEntrySpawn",
		"ReadabilityProps/ZoneIdentity/EntryCeilingPractical",
	],
	"checkout": [
		"Checkout/Register/RegisterScreen",
		"ReadabilityProps/ZoneLighting/CheckoutAmberFill",
	],
	"shelves": [
		"ReadabilityProps/ProductDisplayRows/ShelfProductBacker",
		"ReadabilityProps/ZoneLighting/OldGenZoneFill",
	],
	"backroom": [
		"back_room/BackroomWorkLight",
		"BackroomUtilityLight",
	],
	"used_consoles": [
		"ReadabilityProps/UsedConsoleDressing/UsedConsoleDisplayDeck",
		"ReadabilityProps/ZoneLighting/OldGenZoneFill",
	],
	"try_it": [
		"crt_demo_area/ComingSoonLabel",
		"CRTDemoSpotlight",
	],
}


func test_retro_environment_avoids_bloom_haze() -> void:
	var env: Environment = load(ENV_PATH) as Environment
	assert_not_null(env, "Retro Games environment must load")
	if env == null:
		return
	assert_lte(
		env.glow_bloom,
		RETRO_ENV_MAX_GLOW_BLOOM,
		"glow_bloom must stay low enough to avoid camera haze"
	)
	assert_lte(
		env.glow_strength,
		RETRO_ENV_MAX_GLOW_STRENGTH,
		"glow_strength must not wash neon over physical props"
	)
	assert_lte(
		env.ambient_light_energy,
		RETRO_ENV_MAX_AMBIENT_ENERGY,
		"ambient energy must not become a gray-wash readability workaround"
	)
	assert_true(env.ssao_enabled, "SSAO should remain enabled for prop grounding")


func test_global_key_light_does_not_flatten_room() -> void:
	var root: Node3D = _instantiate_store()
	if root == null:
		return
	var key_light: OmniLight3D = root.get_node_or_null("FluorescentKeyLight") as OmniLight3D
	assert_not_null(key_light, "FluorescentKeyLight must exist")
	if key_light != null:
		assert_lte(
			key_light.light_energy,
			GLOBAL_KEY_MAX_ENERGY,
			"global key energy must leave room for zone hierarchy"
		)
		assert_lte(
			key_light.omni_range,
			GLOBAL_KEY_MAX_RANGE,
			"global key range must not light the whole store uniformly"
		)
	root.free()


func test_zone_lights_stay_local_and_distinct() -> void:
	var root: Node3D = _instantiate_store()
	if root == null:
		return
	for node_path: String in REQUIRED_ZONE_LIGHTS:
		assert_not_null(root.get_node_or_null(node_path), "Missing zone light: %s" % node_path)
	var lighting_root: Node = root.get_node_or_null("ReadabilityProps/ZoneLighting")
	assert_not_null(lighting_root, "ZoneLighting root must exist")
	if lighting_root != null:
		for child: Node in lighting_root.get_children():
			if child is Light3D:
				_assert_light_stays_local(child as Light3D)
	var checkout: Light3D = root.get_node_or_null(
		"ReadabilityProps/ZoneLighting/CheckoutAmberFill"
	) as Light3D
	var backroom: Light3D = root.get_node_or_null(
		"BackroomUtilityLight"
	) as Light3D
	var shelf_cool: Light3D = root.get_node_or_null(
		"ReadabilityProps/ZoneLighting/OldGenZoneFill"
	) as Light3D
	if checkout != null:
		assert_gt(checkout.light_color.r, checkout.light_color.b, "checkout light must read warm")
	if backroom != null:
		assert_gt(backroom.light_color.b, backroom.light_color.r, "backroom light must read cool")
	if shelf_cool != null:
		assert_gt(shelf_cool.light_color.b, shelf_cool.light_color.r, "shelf edge light must stay cool")
	root.free()


func test_authored_service_practicals_keep_zone_temperatures() -> void:
	var root: Node3D = _instantiate_store()
	if root == null:
		return
	var checkout_spot: SpotLight3D = root.get_node_or_null("CheckoutLaneSpotlight") as SpotLight3D
	var checkout_practical: OmniLight3D = (
		root.get_node_or_null("CheckoutCounterPractical") as OmniLight3D
	)
	var backroom_practical: OmniLight3D = root.get_node_or_null("BackroomUtilityLight") as OmniLight3D
	assert_not_null(checkout_spot, "CheckoutLaneSpotlight must exist")
	assert_not_null(checkout_practical, "CheckoutCounterPractical must exist")
	assert_not_null(backroom_practical, "BackroomUtilityLight must exist")
	if checkout_spot != null:
		assert_lte(
			checkout_spot.light_energy,
			CHECKOUT_SERVICE_MAX_ENERGY,
			"Checkout spot must not overpower the shelf and entry practicals"
		)
	if checkout_practical != null:
		assert_gt(
			checkout_practical.light_color.r,
			checkout_practical.light_color.b,
			"Checkout practical must read as a warm service-zone fill"
		)
		assert_lte(
			checkout_practical.omni_range,
			3.0,
			"Checkout practical must stay near the register screen"
		)
	if backroom_practical != null:
		assert_gt(
			backroom_practical.light_color.b,
			backroom_practical.light_color.r,
			"Backroom practical must stay cooler than the sales floor"
		)
		assert_gte(
			backroom_practical.light_energy,
			BACKROOM_UTILITY_MIN_ENERGY,
			"Backroom practical must keep the stock pickup target out of silhouette"
		)
	root.free()


func test_lighting_views_have_readable_anchors() -> void:
	var root: Node3D = _instantiate_store()
	if root == null:
		return
	for view_name: String in VIEW_ANCHORS.keys():
		for node_path: String in VIEW_ANCHORS[view_name]:
			assert_not_null(
				root.get_node_or_null(node_path),
				"%s view must keep readable anchor %s" % [view_name, node_path]
			)
	root.free()


func _instantiate_store() -> Node3D:
	var scene: PackedScene = load(SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return null
	var root: Node3D = scene.instantiate() as Node3D
	assert_not_null(root, "retro_games.tscn must instantiate as Node3D")
	return root


func _assert_light_stays_local(light: Light3D) -> void:
	assert_lte(
		light.light_energy,
		ZONE_LIGHT_MAX_ENERGY,
		"%s light_energy must stay local" % light.name
	)
	if light is OmniLight3D:
		assert_lte(
			(light as OmniLight3D).omni_range,
			ZONE_OMNI_MAX_RANGE,
			"%s omni_range must stay local" % light.name
		)
	if light is SpotLight3D:
		assert_lte(
			(light as SpotLight3D).spot_range,
			ZONE_SPOT_MAX_RANGE,
			"%s spot_range must stay local" % light.name
		)
