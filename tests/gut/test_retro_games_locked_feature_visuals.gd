extends GutTest

const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"
const TABLE_PROP_MIN_Y: float = 0.72
const TABLE_PROP_MAX_Y: float = 1.05

var _root: Node3D = null
var _saved_state: GameManager.State
var _saved_day: int


func before_all() -> void:
	_saved_state = GameManager.current_state
	_saved_day = GameManager.get_current_day()
	GameManager.current_state = GameManager.State.STORE_VIEW
	GameManager.set_current_day(1)
	var scene: PackedScene = load(SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene:
		_root = scene.instantiate() as Node3D
		add_child(_root)


func after_all() -> void:
	if is_instance_valid(_root):
		_root.free()
	_root = null
	GameManager.current_state = _saved_state
	GameManager.set_current_day(_saved_day)


func test_try_it_testing_reads_as_intentionally_unavailable() -> void:
	var sign: Label3D = _label("crt_demo_area/ComingSoonLabel")
	if sign == null:
		return
	var text: String = sign.text.to_lower()
	assert_true(
		text.contains("try") or text.contains("testing"),
		"Try-It sign must name the parked testing feature"
	)
	assert_true(
		text.contains("coming soon") or text.contains("setup"),
		"Try-It sign must communicate unavailability"
	)
	for prop_path: String in [
		"crt_demo_area/SetupBarrierRail",
		"crt_demo_area/SetupBarrierPostLeft",
		"crt_demo_area/SetupBarrierPostRight",
		"crt_demo_area/SetupLockTagBacking",
		"crt_demo_area/SetupLockTag",
		"crt_demo_area/DustCover",
		"crt_demo_area/UnpluggedCableCoil",
	]:
		_assert_hidden_node(prop_path)
	var lock_tag: Label3D = _label("crt_demo_area/SetupLockTag")
	if lock_tag == null:
		return
	assert_true(
		lock_tag.text.to_lower().contains("locked"),
		"Try-It lock tag must make the station read unavailable from the aisle"
	)


func test_staff_picks_display_reads_as_curated_but_locked() -> void:
	_assert_hidden_node("staff_picks_table")
	var sign: Label3D = _label("ZoneLabels/StaffPicksLabel")
	if sign == null:
		return
	var text: String = sign.text.to_lower()
	assert_true(
		text.contains("staff") and text.contains("pick"),
		"Staff Picks sign must name the feature"
	)
	assert_true(
		text.contains("curated") or text.contains("soon"),
		"Staff Picks sign must communicate the parked state"
	)
	for prop_path: String in [
		"staff_picks_table/DisplayRiser",
		"staff_picks_table/StaffPickDungeonDad",
		"staff_picks_table/StaffPickSpaceMall",
		"staff_picks_table/StaffPickKartClerk",
		"staff_picks_table/StaffPickPixelPets",
		"staff_picks_table/VicListCard",
		"staff_picks_table/VicListLabel",
		"staff_picks_table/CoopNightCard",
		"staff_picks_table/CoopNightLabel",
		"staff_picks_table/DisplayGuardRail",
	]:
		_assert_hidden_node(prop_path)


func test_staff_pick_cards_are_supported_by_the_table() -> void:
	for prop_path: String in [
		"staff_picks_table/StaffPickDungeonDad",
		"staff_picks_table/StaffPickSpaceMall",
		"staff_picks_table/StaffPickKartClerk",
		"staff_picks_table/StaffPickPixelPets",
		"staff_picks_table/VicListCard",
		"staff_picks_table/CoopNightCard",
	]:
		var prop: Node3D = _root.get_node_or_null(prop_path) as Node3D
		assert_not_null(prop, "%s must exist" % prop_path)
		if prop == null:
			continue
		assert_between(
			prop.global_position.y,
			TABLE_PROP_MIN_Y,
			TABLE_PROP_MAX_Y,
			"%s must sit on the Staff Picks table, not float or clip the floor"
			% prop_path
		)


func test_locked_feature_displays_do_not_enable_gameplay_targets() -> void:
	for path: String in ["crt_demo_area", "testing_station", "staff_picks_table"]:
		var node: Node = _root.get_node_or_null(path)
		assert_not_null(node, "%s must exist" % path)
		if node == null:
			continue
		var interactables: Array[Interactable] = []
		_collect_interactables(node, interactables)
		for interactable: Interactable in interactables:
			assert_false(
				interactable.enabled,
				"%s must not expose an enabled Interactable"
				% _root.get_path_to(interactable)
			)


func _label(path: String) -> Label3D:
	var label: Label3D = _root.get_node_or_null(path) as Label3D
	assert_not_null(label, "%s must exist" % path)
	return label


func _assert_hidden_node(path: String) -> void:
	var node: Node = _root.get_node_or_null(path)
	assert_not_null(node, "%s must exist" % path)
	if node != null:
		assert_false(
			_is_visible_through_ancestors(node),
			"%s must be hidden by beta runtime scope" % path
		)


func _collect_interactables(node: Node, out: Array[Interactable]) -> void:
	if node is Interactable:
		out.append(node as Interactable)
	for child: Node in node.get_children():
		_collect_interactables(child, out)


func _is_visible_through_ancestors(node: Node) -> bool:
	var current: Node = node
	while current != null and current != _root:
		if current is Node3D and not (current as Node3D).visible:
			return false
		current = current.get_parent()
	return true
