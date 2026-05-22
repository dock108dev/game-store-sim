## Verifies the consolidated retro_games testing zone:
##   - crt_demo_area and testing_station co-locate at the left-mid floor slot
##     described by the BRAINDUMP floor plan.
##   - the visible CRT prop is identifiable as a testing area before the player
##     interacts (CRT monitor child + "Coming Soon" Label3D facing the camera).
##   - the testing_station Interactable ships disabled so the InteractionRay
##     suppresses the "[E] Test Console" prompt while the testing flow is
##     unimplemented.
##   - the consolidated zone leaves the central walking aisle (X∈[-1,1]) clear.
extends GutTest

const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"
const CENTER_AISLE_HALF_WIDTH: float = 1.0
# Co-location budget: both nodes must land within ~30 cm of each other so they
# read as one zone from the overhead camera (the bench is 1.4m wide).
const COLOCATION_BUDGET: float = 0.3

var _root: Node3D = null


func before_all() -> void:
	var scene: PackedScene = load(SCENE_PATH)
	assert_not_null(scene, "Retro Games scene must load")
	if scene:
		_root = scene.instantiate() as Node3D
		add_child(_root)


func after_all() -> void:
	if is_instance_valid(_root):
		_root.free()
	_root = null


func test_testing_station_and_crt_demo_area_are_colocated() -> void:
	var testing: Node3D = _root.get_node_or_null("testing_station") as Node3D
	var crt: Node3D = _root.get_node_or_null("crt_demo_area") as Node3D
	assert_not_null(testing, "testing_station must exist")
	assert_not_null(crt, "crt_demo_area must exist")
	if testing == null or crt == null:
		return
	var distance: float = testing.global_position.distance_to(
		crt.global_position
	)
	assert_lte(
		distance, COLOCATION_BUDGET,
		(
			"testing_station (%s) and crt_demo_area (%s) must co-locate within "
			+ "%.2f m so they read as one consolidated testing zone; found "
			+ "%.2f m apart."
		) % [
			str(testing.global_position),
			str(crt.global_position),
			COLOCATION_BUDGET,
			distance,
		],
	)


func test_testing_zone_sits_in_left_mid_quadrant() -> void:
	var crt: Node3D = _root.get_node_or_null("crt_demo_area") as Node3D
	assert_not_null(crt, "crt_demo_area must exist")
	if crt == null:
		return
	var pos: Vector3 = crt.global_position
	# Left-mid per the recomposed floor plan: parked beside the main path,
	# clear of the rear shelf/backroom lanes.
	assert_between(
		pos.x, -6.9, -5.5,
		"Testing zone x=%.2f must sit in the left-mid quadrant" % pos.x,
	)
	assert_between(
		pos.z, -1.9, -0.5,
		"Testing zone z=%.2f must sit in the left-mid quadrant" % pos.z,
	)


func test_center_walking_aisle_is_unobstructed_by_testing_zone() -> void:
	for fixture_name: String in ["testing_station", "crt_demo_area"]:
		var fixture: Node3D = _root.get_node_or_null(fixture_name) as Node3D
		assert_not_null(fixture, "%s must exist" % fixture_name)
		if fixture == null:
			continue
		assert_gte(
			absf(fixture.global_position.x),
			CENTER_AISLE_HALF_WIDTH,
			(
				"%s at x=%.2f intrudes into the center walking aisle "
				+ "(|x| < %.2f)."
			) % [
				fixture_name,
				fixture.global_position.x,
				CENTER_AISLE_HALF_WIDTH,
			],
		)


func test_crt_monitor_is_visible_in_testing_zone() -> void:
	var crt: Node3D = _root.get_node_or_null(
		"crt_demo_area/CRTMonitor"
	) as Node3D
	assert_not_null(
		crt,
		"crt_demo_area/CRTMonitor must exist so the testing zone reads "
			+ "as a CRT testing area before interacting"
	)
	if crt == null:
		return
	assert_true(
		crt.visible,
		"CRT monitor must be visible so the testing zone is identifiable"
	)


func test_coming_soon_label_exists_and_faces_camera() -> void:
	var label: Label3D = _root.get_node_or_null(
		"crt_demo_area/ComingSoonLabel"
	) as Label3D
	assert_not_null(
		label,
		"ComingSoonLabel must exist on the testing zone to signal the "
			+ "non-functional state in-world"
	)
	if label == null:
		return
	assert_true(
		label.visible,
		"ComingSoonLabel must be visible"
	)
	var label_text: String = label.text.to_lower()
	assert_true(
		label_text.contains("soon")
			and (label_text.contains("try") or label_text.contains("testing")),
		"ComingSoonLabel text should communicate the parked try-it state"
	)
	# Storefront SignName uses Transform3D(-1,…,-1,…) — a 180° Y rotation that
	# orients the Label3D toward the front of the store (toward the camera).
	# Apply the same convention here so the sign reads from the player's POV.
	var basis: Basis = label.global_transform.basis
	assert_lt(
		basis.x.x, 0.0,
		(
			"ComingSoonLabel must face the camera (front of store, +Z); "
			+ "expected a 180° Y-axis rotation but found basis.x.x=%.3f"
		) % basis.x.x,
	)
	assert_lt(
		basis.z.z, 0.0,
		(
			"ComingSoonLabel must face the camera (front of store, +Z); "
			+ "expected a 180° Y-axis rotation but found basis.z.z=%.3f"
		) % basis.z.z,
	)


func test_lockout_props_do_not_block_crt_or_sign_readability() -> void:
	var monitor: Node3D = _root.get_node_or_null(
		"crt_demo_area/CRTMonitor"
	) as Node3D
	var label: Label3D = _root.get_node_or_null(
		"crt_demo_area/ComingSoonLabel"
	) as Label3D
	var rail: Node3D = _root.get_node_or_null(
		"crt_demo_area/SetupBarrierRail"
	) as Node3D
	var cover: Node3D = _root.get_node_or_null(
		"crt_demo_area/DustCover"
	) as Node3D
	var lock_tag: Label3D = _root.get_node_or_null(
		"crt_demo_area/SetupLockTag"
	) as Label3D
	for node: Node in [monitor, label, rail, cover, lock_tag]:
		assert_not_null(node, "Testing-zone lockout/readability node must exist")
	if (
		monitor == null
		or label == null
		or rail == null
		or cover == null
		or lock_tag == null
	):
		return
	assert_lt(
		rail.global_position.y,
		label.global_position.y - 0.4,
		"Setup barrier rail must stay below ComingSoonLabel sightline"
	)
	assert_lt(
		cover.global_position.y,
		monitor.global_position.y,
		"Dust cover must sit below the CRT monitor center so the CRT remains readable"
	)
	assert_between(
		lock_tag.global_position.y,
		monitor.global_position.y - 0.25,
		label.global_position.y - 0.35,
		"Locked setup tag must live between the CRT and main sign without blocking either"
	)


func test_testing_station_interactable_ships_disabled() -> void:
	var testing: Node3D = _root.get_node_or_null("testing_station") as Node3D
	assert_not_null(testing, "testing_station must exist")
	if testing == null:
		return
	var interactable: Interactable = testing.get_node_or_null(
		"Interactable"
	) as Interactable
	assert_not_null(
		interactable,
		"testing_station/Interactable must exist for future re-enable"
	)
	if interactable == null:
		return
	assert_false(
		interactable.enabled,
		(
			"testing_station/Interactable must ship disabled so InteractionRay "
			+ "suppresses the [E] prompt while the testing flow is unwired"
		),
	)
