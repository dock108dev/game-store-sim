extends GutTest

const GONDOLA_SHELF_PATH: String = (
	"res://game/scenes/stores/fixtures/retail_gondola_shelf.tscn"
)


func test_gondola_shelf_scene_has_double_sided_retail_shape() -> void:
	var root: Node3D = _instantiate_gondola()
	assert_not_null(root.get_node_or_null("GondolaMesh"))
	assert_not_null(root.get_node_or_null("StaticBody3D/CollisionShape3D"))
	assert_not_null(root.get_node_or_null("StaticBody3D/NavigationObstacle3D"))
	for required_path: String in [
		"CenterSpine",
		"TopShelfFront",
		"TopShelfBack",
		"LeftEndCap",
		"RightEndCap",
		"MerchandisingRows/FrontLabelRail",
		"MerchandisingRows/BackLabelRail",
		"MerchandisingRows/FrontShelfLip",
		"MerchandisingRows/BackShelfLip",
	]:
		assert_not_null(root.get_node_or_null(required_path), "Missing %s" % required_path)
	root.free()


func test_gondola_shelf_keeps_six_gameplay_slots() -> void:
	var root: Node3D = _instantiate_gondola()
	var slot_ids: PackedStringArray = []
	var front_count := 0
	var back_count := 0
	for index: int in range(1, 7):
		var slot: Area3D = root.get_node_or_null("Slot%d" % index) as Area3D
		assert_not_null(slot, "Slot%d must exist" % index)
		if slot == null:
			continue
		assert_true(slot.is_in_group(&"shelf_slot"))
		slot_ids.append(str(slot.get("slot_id")))
		if slot.position.z < 0.0:
			front_count += 1
		if slot.position.z > 0.0:
			back_count += 1
	assert_eq(slot_ids, PackedStringArray([
		"gondola_1",
		"gondola_2",
		"gondola_3",
		"gondola_4",
		"gondola_5",
		"gondola_6",
	]))
	assert_eq(front_count, 3)
	assert_eq(back_count, 3)
	assert_eq(_count_shelf_slots(root), 6)
	root.free()


func test_gondola_merchandising_is_visual_only() -> void:
	var root: Node3D = _instantiate_gondola()
	var merchandising: Node = root.get_node_or_null("MerchandisingRows")
	assert_not_null(merchandising)
	for required_path: String in [
		"FrontStockedCaseA",
		"FrontStockedCaseB",
		"FrontEmptyBay",
		"FrontLabelTagA",
		"BackStockedSpineA",
		"BackStockStack",
		"BackEmptyBay",
		"BackLabelTagB",
	]:
		var node: Node = merchandising.get_node_or_null(required_path)
		assert_not_null(node, "Missing merchandising detail %s" % required_path)
		if node != null:
			assert_false(node is Area3D, "%s must not be an extra gameplay slot" % required_path)
	assert_eq(_count_shelf_slots(root), 6)
	root.free()


func _instantiate_gondola() -> Node3D:
	var packed: PackedScene = load(GONDOLA_SHELF_PATH) as PackedScene
	assert_not_null(packed, "Gondola shelf scene should load")
	var root: Node3D = packed.instantiate() as Node3D
	assert_not_null(root, "Gondola shelf scene should instantiate as Node3D")
	return root


func _count_shelf_slots(root: Node) -> int:
	var count := 0
	if root is Area3D and root.is_in_group(&"shelf_slot"):
		count += 1
	for child: Node in root.get_children():
		count += _count_shelf_slots(child)
	return count
