## Verifies retro_games.tscn ships Day-1 navigation labels:
##   - the visible ZoneLabels layer only names learning-route destinations
##     that are not already owned by checkout/storefront signage
##   - labels sit above slot height (Y >= 2.0) so they do not occlude
##     interactable slot zones beneath them
##   - the Day-1 navigation labels (shelf + back room) carry a
##     pixel_size large enough to remain legible from the entrance approach
##     and use wording that aligns with the Day-1 objective steps
##   - the group acts as a bulk-hide handle so a future polish pass can
##     toggle all zone markers off in one call
extends GutTest

const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"
const ZONE_GROUP: StringName = &"zone_label"
const VISIBLE_DAY1_NAV_LABELS: Dictionary = {
	"ZoneLabels/ShelvesLabel": {
		"normalized_text": "starter display table",
		"objective_step": "stock_shelf",
	},
	"ZoneLabels/BackroomLabel": {
		"normalized_text": "back room",
		"objective_step": "back_room_inventory",
	},
}
const DEMOTED_DUPLICATE_LABEL_PATHS: Array[String] = [
	"ZoneLabels/CheckoutLabel",
	"ZoneLabels/ExitLabel",
]
const MIN_LABEL_HEIGHT: float = 2.0
# The Day-1 labels must remain legible from across the room (~17m from the
# entrance). pixel_size 0.005 produced 0.18m letters at 36pt — sub-1° at
# entrance distance and unreadable on first approach. The current floor of
# 0.007 keeps letter angular size above 1° from anywhere a player can stand.
const MIN_DAY1_NAV_PIXEL_SIZE: float = 0.007

var _root: Node3D = null


func before_all() -> void:
	var scene: PackedScene = load(SCENE_PATH)
	assert_not_null(scene, "Retro Games scene must load")
	if scene == null:
		return
	_root = scene.instantiate() as Node3D
	add_child(_root)


func after_all() -> void:
	if is_instance_valid(_root):
		_root.free()
	_root = null


func _zone_labels() -> Array[Label3D]:
	var result: Array[Label3D] = []
	if _root == null:
		return result
	for node: Node in get_tree().get_nodes_in_group(ZONE_GROUP):
		if node is Label3D and _root.is_ancestor_of(node):
			result.append(node)
	return result


func test_each_visible_day1_navigation_destination_has_a_label() -> void:
	for path: String in VISIBLE_DAY1_NAV_LABELS.keys():
		var label: Label3D = _root.get_node_or_null(path) as Label3D
		assert_not_null(label, "%s must exist" % path)
		if label == null:
			continue
		assert_true(label.visible, "%s must stay visible for Day-1 navigation" % path)
		assert_true(
			label.is_in_group(ZONE_GROUP),
			"%s must stay in the zone-label group for bulk-hide support" % path,
		)
		var expected: String = String(
			(VISIBLE_DAY1_NAV_LABELS[path] as Dictionary)["normalized_text"]
		)
		assert_eq(
			_normalized_label_text(label),
			expected,
			"%s must use the same player-facing destination name" % path,
		)


func test_checkout_and_exit_are_not_duplicate_visible_zone_labels() -> void:
	for path: String in DEMOTED_DUPLICATE_LABEL_PATHS:
		var label: Node3D = _root.get_node_or_null(path) as Node3D
		assert_not_null(label, "%s must exist as a demoted authoring hook" % path)
		if label != null:
			assert_false(
				_is_visible_in_tree(label),
				"%s must not compete with checkout/storefront identity signage" % path,
			)
	var checkout_sign: Label3D = _root.get_node_or_null(
		"Checkout/Register/CheckoutSign"
	) as Label3D
	var door_prompt: Interactable = _root.get_node_or_null(
		"EntranceDoor/Interactable"
	) as Interactable
	assert_not_null(checkout_sign, "Checkout/Register/CheckoutSign owns checkout identity")
	assert_not_null(door_prompt, "EntranceDoor prompt owns exit-to-mall identity")
	if checkout_sign != null:
		assert_true(checkout_sign.text.to_lower().contains("checkout"))
	if door_prompt != null:
		assert_eq(door_prompt.prompt_text, "Exit to Mall")


func test_zone_labels_clear_slot_height() -> void:
	for label: Label3D in _zone_labels():
		if not _is_visible_in_tree(label):
			continue
		var y: float = label.global_position.y
		assert_gte(
			y, MIN_LABEL_HEIGHT,
			(
				"Zone label '%s' at Y=%.2f must sit at Y >= %.2f so it does "
				+ "not occlude interactable slot zones (slots top at Y≈1.6)"
			) % [label.text, y, MIN_LABEL_HEIGHT],
		)


func test_day1_nav_labels_match_objective_wording() -> void:
	for path: String in VISIBLE_DAY1_NAV_LABELS.keys():
		var label: Label3D = _root.get_node_or_null(path) as Label3D
		assert_not_null(label, "%s must exist" % path)
		if label == null:
			continue
		var spec: Dictionary = VISIBLE_DAY1_NAV_LABELS[path] as Dictionary
		var objective_text: String = _objective_step_text(String(spec["objective_step"]))
		assert_true(
			objective_text.to_lower().contains(_normalized_label_text(label)),
			(
				"%s text '%s' must appear in objectives.json step '%s' text '%s'"
			) % [path, label.text, String(spec["objective_step"]), objective_text],
		)


func test_day1_nav_labels_meet_pixel_size_floor() -> void:
	# AC: readable from 3m approach. pixel_size below the floor pushed the
	# letter angular size below 1° at the typical 15m+ entrance-approach view,
	# making the label illegible until the player was already next to the
	# zone.
	for path: String in VISIBLE_DAY1_NAV_LABELS.keys():
		var label: Label3D = _root.get_node_or_null(path) as Label3D
		assert_not_null(label, "%s must exist" % path)
		if label == null:
			continue
		assert_gte(
			label.pixel_size, MIN_DAY1_NAV_PIXEL_SIZE,
			(
				"%s pixel_size=%.4f must be >= %.4f so letters remain legible "
				+ "on entrance approach (~17m line-of-sight)."
			) % [path, label.pixel_size, MIN_DAY1_NAV_PIXEL_SIZE],
		)


func _objective_step_text(step_id: String) -> String:
	var path: String = "res://game/content/objectives.json"
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	assert_not_null(file, "objectives.json must open")
	if file == null:
		return ""
	var raw: String = file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(raw)
	if not parsed is Dictionary:
		fail_test("objectives.json must parse as a Dictionary")
		return ""
	var dict: Dictionary = parsed
	var entries: Array = dict.get("objectives", []) as Array
	for entry: Variant in entries:
		if not entry is Dictionary:
			continue
		var day_entry: Dictionary = entry
		if int(day_entry.get("day", 0)) != 1:
			continue
		var steps: Array = day_entry.get("steps", []) as Array
		for step: Variant in steps:
			if not step is Dictionary:
				continue
			var step_dict: Dictionary = step
			if String(step_dict.get("id", "")) == step_id:
				return String(step_dict.get("text", ""))
	fail_test("objectives.json has no Day-1 step '%s'" % step_id)
	return ""


func test_zone_labels_bulk_hide_via_group() -> void:
	var labels: Array[Label3D] = _zone_labels()
	assert_gte(
		labels.size(), 2,
		"Expected at least 2 Day-1 navigation labels (shelf, back room)",
	)
	for label: Label3D in labels:
		label.visible = true
	get_tree().call_group(ZONE_GROUP, "set_visible", false)
	for label: Label3D in labels:
		assert_false(
			label.visible,
			"Zone label '%s' must hide via call_group('%s', 'set_visible', false)"
			% [label.text, ZONE_GROUP],
		)


func _normalized_label_text(label: Label3D) -> String:
	return label.text.to_lower().replace("\n", " ").strip_edges()


func _is_visible_in_tree(node: Node3D) -> bool:
	var cursor: Node = node
	while cursor != null and cursor != _root:
		if cursor is Node3D and not (cursor as Node3D).visible:
			return false
		cursor = cursor.get_parent()
	return node.visible
