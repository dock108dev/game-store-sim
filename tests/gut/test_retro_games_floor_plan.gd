## Verifies retro_games.tscn matches the BRAINDUMP retail floor plan:
## testing zone on the left, register on the right, central walking aisle
## clear except for the central display table, and customer waypoints
## scattered to track the new fixture quadrants.
extends GutTest

const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"
# Aisle width: any fixture with |center.x| < CENTER_AISLE_HALF_WIDTH that is
# not the central display table (GlassCase) violates the open-floor contract.
const CENTER_AISLE_HALF_WIDTH: float = 1.0
const CENTRAL_DISPLAY_NODE: String = "GlassCase"
const TESTING_ZONE_X_MIN: float = -6.9
const TESTING_ZONE_X_MAX: float = -5.5
const TESTING_ZONE_Z_MIN: float = -1.9
const TESTING_ZONE_Z_MAX: float = -0.5
const FIRST_RUN_ROUTE_MAX_SEGMENT_M: float = 13.5
# Fixtures that must occupy the named quadrant per the floor plan.
const LEFT_FIXTURES: Array[String] = [
	"testing_station", "crt_demo_area", "AccessoriesBin", "refurb_bench",
]
const RIGHT_FIXTURES: Array[String] = [
	"Checkout", "checkout_counter", "ConsoleShelf",
]
const BACK_FIXTURES: Array[String] = ["CartRackLeft", "CartRackRight"]
const ENTRY_LANE_X_MIN: float = -1.2
const ENTRY_LANE_X_MAX: float = 1.2
const ENTRY_LANE_Z_MIN: float = 6.8
const ENTRY_LANE_Z_MAX: float = 9.45
const RIGHT_CIRCULATION_X_MIN: float = 1.25
const RIGHT_CIRCULATION_X_MAX: float = 4.45
const RIGHT_CIRCULATION_Z_MIN: float = -7.85
const RIGHT_CIRCULATION_Z_MAX: float = 5.95
const BACKROOM_APPROACH_X_MIN: float = 4.75
const BACKROOM_APPROACH_X_MAX: float = 6.35
const BACKROOM_APPROACH_Z_MIN: float = -8.9
const BACKROOM_APPROACH_Z_MAX: float = -5.95
const DISPLAY_FOOTPRINTS: Dictionary = {
	"GlassCase": "CaseMesh",
	"featured_display": "DisplayMesh",
	"bargain_bin": "BinMesh",
	"staff_picks_table": "TableMesh",
}

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


# ── Quadrant placement matches BRAINDUMP floor plan ──────────────────────────

func test_testing_zone_is_on_left_side() -> void:
	for fixture_name: String in ["testing_station", "crt_demo_area"]:
		var fixture: Node3D = _root.get_node_or_null(fixture_name) as Node3D
		assert_not_null(fixture, "%s must exist" % fixture_name)
		if fixture == null:
			continue
		var pos: Vector3 = fixture.global_position
		assert_between(
			pos.x, TESTING_ZONE_X_MIN, TESTING_ZONE_X_MAX,
			(
				"%s must sit in the left-mid try-it bay; found x=%.2f"
			) % [fixture_name, pos.x],
		)
		assert_between(
			pos.z, TESTING_ZONE_Z_MIN, TESTING_ZONE_Z_MAX,
			(
				"%s must sit in the left-mid try-it bay; found z=%.2f"
			) % [fixture_name, pos.z],
		)


func test_register_is_on_right_side() -> void:
	for fixture_name: String in ["Checkout", "checkout_counter"]:
		var fixture: Node3D = _root.get_node_or_null(fixture_name) as Node3D
		assert_not_null(fixture, "%s must exist" % fixture_name)
		if fixture == null:
			continue
		assert_gt(
			fixture.global_position.x, 0.0,
			(
				"%s must sit on the RIGHT side of the store (x > 0) per the "
				+ "BRAINDUMP floor plan; found x=%.2f"
			) % [fixture_name, fixture.global_position.x],
		)


func test_back_wall_shelves_remain_along_back_wall() -> void:
	# Back wall sits at z=-10.05 in the resized 16×20 interior; cart racks
	# must hug it within ~2 m so they read as wall-mounted shelving.
	for fixture_name: String in BACK_FIXTURES:
		var fixture: Node3D = _root.get_node_or_null(fixture_name) as Node3D
		assert_not_null(fixture, "%s must exist" % fixture_name)
		if fixture == null:
			continue
		assert_lt(
			fixture.global_position.z, -8.0,
			(
				"%s must remain against the back wall (z < -8.0); found z=%.2f"
			) % [fixture_name, fixture.global_position.z],
		)


# ── Open floor: center aisle clear except for the central display table ─────

func test_center_aisle_is_clear_except_central_display() -> void:
	for fixture_name: String in (
		LEFT_FIXTURES + RIGHT_FIXTURES + BACK_FIXTURES
	):
		var fixture: Node3D = _root.get_node_or_null(fixture_name) as Node3D
		if fixture == null:
			continue
		assert_gte(
			absf(fixture.global_position.x),
			CENTER_AISLE_HALF_WIDTH,
			(
				"%s at x=%.2f intrudes into the center walking aisle "
				+ "(|x| < %.2f). Only %s may sit in the aisle."
			) % [
				fixture_name,
				fixture.global_position.x,
				CENTER_AISLE_HALF_WIDTH,
				CENTRAL_DISPLAY_NODE,
			],
		)


func test_central_display_remains_in_aisle_center() -> void:
	var glass: Node3D = _root.get_node_or_null(CENTRAL_DISPLAY_NODE) as Node3D
	assert_not_null(glass, "%s must exist" % CENTRAL_DISPLAY_NODE)
	if glass == null:
		return
	assert_lt(
		absf(glass.global_position.x),
		CENTER_AISLE_HALF_WIDTH,
		"Central display table must remain near x=0 (currently x=%.2f)"
		% glass.global_position.x,
	)


func test_entrance_has_threshold_promo_and_clear_entry_lane() -> void:
	var door: Node3D = _root.get_node_or_null("EntranceDoor") as Node3D
	var threshold: MeshInstance3D = (
		_root.get_node_or_null("EntranceInterior/FloorStrip") as MeshInstance3D
	)
	var welcome_mat: MeshInstance3D = (
		_root.get_node_or_null("ReadabilityProps/ZoneIdentity/EntranceRubberMat")
		as MeshInstance3D
	)
	var promo_bin: Node3D = _root.get_node_or_null("bargain_bin") as Node3D
	for node: Node in [door, threshold, welcome_mat, promo_bin]:
		assert_not_null(node, "Entrance reset anchor must exist")
	if door == null or threshold == null or welcome_mat == null or promo_bin == null:
		return
	assert_gt(door.global_position.z, 9.8, "Door must anchor the exit threshold")
	assert_between(
		welcome_mat.global_position.z, 8.3, 9.2,
		"Welcome mat must stay just inside the entry threshold",
	)
	assert_between(
		promo_bin.global_position.x, -3.6, -2.0,
		"Entrance promo bin must sit left of the clear doorway lane",
	)
	assert_between(
		promo_bin.global_position.z, 6.85, 8.1,
		"Entrance promo bin must read as front-entry merchandising",
	)
	_assert_display_footprints_clear_rect(
		"entry lane",
		ENTRY_LANE_X_MIN,
		ENTRY_LANE_X_MAX,
		ENTRY_LANE_Z_MIN,
		ENTRY_LANE_Z_MAX,
	)


func test_main_floor_display_footprints_are_low_and_intentional() -> void:
	var glass: Node3D = _root.get_node_or_null("GlassCase") as Node3D
	var featured: Node3D = _root.get_node_or_null("featured_display") as Node3D
	var staff_picks: Node3D = _root.get_node_or_null("staff_picks_table") as Node3D
	var bargain_bin: Node3D = _root.get_node_or_null("bargain_bin") as Node3D
	for node: Node3D in [glass, featured, staff_picks, bargain_bin]:
		assert_not_null(node, "Display classification anchor must exist")
	if glass == null or featured == null or staff_picks == null or bargain_bin == null:
		return
	assert_lt(absf(glass.global_position.x), 1.0, "GlassCase is the kept center island")
	assert_between(
		featured.global_position.x, -3.35, -1.85,
		"featured_display must move out of the doorway spine",
	)
	assert_between(
		featured.global_position.z, 1.5, 3.25,
		"featured_display must sit on the planned main-floor display band",
	)
	assert_lt(staff_picks.global_position.x, -3.5, "staff_picks_table stays front-left")
	assert_gt(staff_picks.global_position.z, 5.0, "staff_picks_table stays front-left")
	assert_gt(bargain_bin.global_position.z, 6.85, "bargain_bin is the entry promo bin")
	for root_name: String in DISPLAY_FOOTPRINTS.keys():
		var mesh: MeshInstance3D = _display_mesh(root_name)
		assert_not_null(mesh, "%s must expose a display footprint mesh" % root_name)
		if mesh == null or not (mesh.mesh is BoxMesh):
			continue
		var top_y: float = _box_top_y(mesh)
		assert_lte(top_y, 1.15, "%s must remain a low display footprint" % root_name)


func test_main_circulation_lanes_clear_display_footprints() -> void:
	_assert_display_footprints_clear_rect(
		"entry to checkout",
		ENTRY_LANE_X_MIN,
		ENTRY_LANE_X_MAX,
		ENTRY_LANE_Z_MIN,
		ENTRY_LANE_Z_MAX,
	)
	_assert_display_footprints_clear_rect(
		"checkout to retro games wall",
		RIGHT_CIRCULATION_X_MIN,
		RIGHT_CIRCULATION_X_MAX,
		RIGHT_CIRCULATION_Z_MIN,
		RIGHT_CIRCULATION_Z_MAX,
	)
	_assert_display_footprints_clear_rect(
		"shelves to backroom",
		BACKROOM_APPROACH_X_MIN,
		BACKROOM_APPROACH_X_MAX,
		BACKROOM_APPROACH_Z_MIN,
		BACKROOM_APPROACH_Z_MAX,
	)


# ── Testing zone clear: refurb_bench must not block the left-mid area ───────

func test_refurb_bench_clear_of_testing_zone() -> void:
	# refurb_bench belongs to the left service side but must not sit inside
	# the authored try-it footprint, otherwise that bay reads as blocked.
	var refurb: Node3D = _root.get_node_or_null("refurb_bench") as Node3D
	assert_not_null(refurb, "refurb_bench must exist")
	if refurb == null:
		return
	var pos: Vector3 = refurb.global_position
	var inside_zone: bool = (
		pos.x >= TESTING_ZONE_X_MIN and pos.x <= TESTING_ZONE_X_MAX
		and pos.z >= TESTING_ZONE_Z_MIN and pos.z <= TESTING_ZONE_Z_MAX
	)
	assert_false(
		inside_zone,
		(
			"refurb_bench at (%.2f, %.2f) must not sit inside the try-it bay"
		) % [pos.x, pos.z],
	)


func test_required_zones_are_spatially_distinct() -> void:
	var entry: Node3D = _root.get_node_or_null("EntryArea") as Node3D
	var checkout: Node3D = _root.get_node_or_null("Checkout") as Node3D
	var main_display: Node3D = _root.get_node_or_null("GlassCase") as Node3D
	var retro_wall: Node3D = _root.get_node_or_null("CartRackLeft") as Node3D
	var consoles: Node3D = _root.get_node_or_null("ConsoleShelf") as Node3D
	var backroom: Node3D = _root.get_node_or_null("back_room") as Node3D
	var try_it: Node3D = _root.get_node_or_null("crt_demo_area") as Node3D
	var staff_picks: Node3D = _root.get_node_or_null("staff_picks_table") as Node3D
	for node: Node3D in [
		entry,
		checkout,
		main_display,
		retro_wall,
		consoles,
		backroom,
		try_it,
		staff_picks,
	]:
		assert_not_null(node, "Required floor-plan zone anchor must exist")
	if (
		entry == null
		or checkout == null
		or main_display == null
		or retro_wall == null
		or consoles == null
		or backroom == null
		or try_it == null
		or staff_picks == null
	):
		return
	assert_gt(entry.global_position.z, 8.5, "Entrance must read at the front")
	assert_gt(checkout.global_position.x, 4.0, "Checkout must occupy right-front")
	assert_gt(checkout.global_position.z, 6.0, "Checkout must occupy right-front")
	assert_lt(absf(main_display.global_position.x), 1.0, "Main display must anchor center floor")
	assert_lt(retro_wall.global_position.z, -8.0, "Retro games wall must sit at the rear")
	assert_lt(retro_wall.global_position.x, -3.0, "Retro games wall must read left/rear")
	assert_gt(consoles.global_position.x, 5.0, "Used consoles must read on the right wall")
	assert_lt(consoles.global_position.z, -2.0, "Used consoles must sit past the main aisle")
	assert_gt(backroom.global_position.x, 5.0, "Backroom must remain right-rear receiving")
	assert_lt(backroom.global_position.z, -7.0, "Backroom must remain right-rear receiving")
	assert_lt(try_it.global_position.x, -5.5, "Try-it zone must read left side")
	assert_between(
		try_it.global_position.z, TESTING_ZONE_Z_MIN, TESTING_ZONE_Z_MAX,
		"Try-it zone must sit mid-room, not in the back shelf lane",
	)
	assert_lt(staff_picks.global_position.x, -3.5, "Staff picks must stay front-left")
	assert_gt(staff_picks.global_position.z, 5.0, "Staff picks must stay front-left")


func test_first_run_route_has_obvious_front_back_return_order() -> void:
	var entry: Marker3D = _root.get_node_or_null(
		"CustomerNavConfig/EntryPoint"
	) as Marker3D
	var checkout: Marker3D = _root.get_node_or_null(
		"CustomerNavConfig/CheckoutApproach"
	) as Marker3D
	var main_display: Marker3D = _root.get_node_or_null(
		"CustomerNavConfig/BrowseWaypoint03"
	) as Marker3D
	var shelf: Marker3D = _root.get_node_or_null(
		"CustomerNavConfig/BrowseWaypoint01"
	) as Marker3D
	var backroom: Node3D = _root.get_node_or_null("StoreSessionBackroomPickup") as Node3D
	var restock_shelf: Node3D = _root.get_node_or_null("StoreSessionRestockShelf") as Node3D
	var day_end: Node3D = _root.get_node_or_null("StoreSessionDayEndTrigger") as Node3D
	for node: Node3D in [
		entry,
		checkout,
		main_display,
		shelf,
		backroom,
		restock_shelf,
		day_end,
	]:
		assert_not_null(node, "Route anchor must exist")
	if (
		entry == null
		or checkout == null
		or main_display == null
		or shelf == null
		or backroom == null
		or restock_shelf == null
		or day_end == null
	):
		return
	assert_gt(entry.global_position.z, checkout.global_position.z)
	assert_gt(checkout.global_position.z, main_display.global_position.z)
	assert_gt(main_display.global_position.z, shelf.global_position.z)
	assert_gt(backroom.global_position.x, 5.4)
	assert_lt(backroom.global_position.z, -7.2)
	assert_lt(restock_shelf.global_position.x, 0.0)
	assert_lt(restock_shelf.global_position.z, -7.0)
	assert_gt(day_end.global_position.z, 7.0)
	var route_points: Array[Vector3] = [
		entry.global_position,
		checkout.global_position,
		main_display.global_position,
		shelf.global_position,
		backroom.global_position,
		restock_shelf.global_position,
		main_display.global_position,
		checkout.global_position,
		day_end.global_position,
	]
	for i: int in range(route_points.size() - 1):
		var distance: float = route_points[i].distance_to(route_points[i + 1])
		assert_gt(distance, 1.0, "Route segment %d must be visually distinct" % i)
		assert_lt(
			distance,
			FIRST_RUN_ROUTE_MAX_SEGMENT_M,
			"Route segment %d must not jump across an unreadable dead end" % i
		)


# ── Customer waypoints track repositioned fixtures ──────────────────────────

func test_checkout_approach_tracks_register_quadrant() -> void:
	var marker: Marker3D = (
		_root.get_node_or_null("CustomerNavConfig/CheckoutApproach")
		as Marker3D
	)
	assert_not_null(marker, "CustomerNavConfig/CheckoutApproach must exist")
	if marker == null:
		return
	assert_gt(
		marker.global_position.x, 0.0,
		(
			"CheckoutApproach must follow the register to the right side "
			+ "(x > 0); found x=%.2f"
		) % marker.global_position.x,
	)


func test_browse_waypoints_scatter_across_fixture_quadrants() -> void:
	# After repositioning, the four browse waypoints should not all bunch on
	# one half of the store. Verify that waypoints exist in both x<0 and
	# x>0 halves so customers visit testing zone (left) and right shelves.
	var any_left: bool = false
	var any_right: bool = false
	for i: int in range(1, 5):
		var marker: Marker3D = (
			_root.get_node_or_null("CustomerNavConfig/BrowseWaypoint%02d" % i)
			as Marker3D
		)
		assert_not_null(
			marker,
			"CustomerNavConfig/BrowseWaypoint%02d must exist" % i,
		)
		if marker == null:
			continue
		if marker.global_position.x < 0.0:
			any_left = true
		if marker.global_position.x > 0.0:
			any_right = true
	assert_true(
		any_left,
		"At least one BrowseWaypoint must visit the left (testing-zone) half"
	)
	assert_true(
		any_right,
		"At least one BrowseWaypoint must visit the right (shelf/console) half"
	)


# ── NavZone snap targets: ZoneRegister must follow the new register ─────────

func test_nav_zone_register_follows_new_register_position() -> void:
	var zone: Area3D = (
		_root.get_node_or_null("NavZones/ZoneRegister") as Area3D
	)
	assert_not_null(zone, "NavZones/ZoneRegister must exist")
	if zone == null:
		return
	var checkout: Node3D = _root.get_node_or_null("Checkout") as Node3D
	assert_not_null(checkout, "Checkout must exist")
	if checkout == null:
		return
	# Snap target should land within ~1.5 m of the register fixture so Shift+4
	# frames the counter rather than the old left-side coordinate.
	var lateral_offset: float = absf(
		zone.global_position.x - checkout.global_position.x
	)
	assert_lte(
		lateral_offset, 1.5,
		(
			"ZoneRegister x=%.2f must sit within 1.5 m of Checkout x=%.2f so "
			+ "Shift+4 snaps the camera onto the register"
		) % [zone.global_position.x, checkout.global_position.x],
	)


func _assert_display_footprints_clear_rect(
	lane_name: String,
	x_min: float,
	x_max: float,
	z_min: float,
	z_max: float
) -> void:
	for root_name: String in DISPLAY_FOOTPRINTS.keys():
		var mesh: MeshInstance3D = _display_mesh(root_name)
		if mesh == null or not (mesh.mesh is BoxMesh):
			continue
		assert_false(
			_box_intersects_rect(mesh, x_min, x_max, z_min, z_max),
			"%s display footprint must not intersect the %s circulation lane"
			% [root_name, lane_name],
		)


func _display_mesh(root_name: String) -> MeshInstance3D:
	var mesh_path: String = DISPLAY_FOOTPRINTS[root_name]
	return _root.get_node_or_null("%s/%s" % [root_name, mesh_path]) as MeshInstance3D


func _box_intersects_rect(
	mesh: MeshInstance3D,
	x_min: float,
	x_max: float,
	z_min: float,
	z_max: float
) -> bool:
	var bounds: Dictionary = _box_xz_bounds(mesh)
	return (
		float(bounds["x_min"]) <= x_max
		and float(bounds["x_max"]) >= x_min
		and float(bounds["z_min"]) <= z_max
		and float(bounds["z_max"]) >= z_min
	)


func _box_xz_bounds(mesh: MeshInstance3D) -> Dictionary:
	var box: BoxMesh = mesh.mesh as BoxMesh
	if box == null:
		return {
			"x_min": mesh.global_position.x,
			"x_max": mesh.global_position.x,
			"z_min": mesh.global_position.z,
			"z_max": mesh.global_position.z,
		}
	var raw_scale: Vector3 = mesh.global_transform.basis.get_scale()
	var scale: Vector3 = Vector3(absf(raw_scale.x), absf(raw_scale.y), absf(raw_scale.z))
	var half_size: Vector3 = Vector3(
		box.size.x * scale.x * 0.5,
		box.size.y * scale.y * 0.5,
		box.size.z * scale.z * 0.5
	)
	return {
		"x_min": mesh.global_position.x - half_size.x,
		"x_max": mesh.global_position.x + half_size.x,
		"z_min": mesh.global_position.z - half_size.z,
		"z_max": mesh.global_position.z + half_size.z,
	}


func _box_top_y(mesh: MeshInstance3D) -> float:
	var box: BoxMesh = mesh.mesh as BoxMesh
	if box == null:
		return mesh.global_position.y
	var raw_scale: Vector3 = mesh.global_transform.basis.get_scale()
	var scale: Vector3 = Vector3(absf(raw_scale.x), absf(raw_scale.y), absf(raw_scale.z))
	return mesh.global_position.y + box.size.y * scale.y * 0.5
