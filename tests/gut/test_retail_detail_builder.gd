extends GutTest

const RetailDetailBuilderScript: GDScript = preload(
	"res://game/scripts/visuals/retail_detail_builder.gd"
)
const StoreVisualKitScript: GDScript = preload("res://game/scripts/visuals/store_visual_kit.gd")
const StarterDetailBuilderScript: GDScript = preload(
	"res://game/scripts/visuals/starter_detail_builder.gd"
)


func test_detail_registry_exposes_all_retail_detail_builders() -> void:
	for detail_id: StringName in [
		RetailDetailBuilderScript.DETAIL_PRICE_TAG,
		RetailDetailBuilderScript.DETAIL_SALE_STICKER,
		RetailDetailBuilderScript.DETAIL_SHELF_TALKER,
		RetailDetailBuilderScript.DETAIL_POSTER_CARD,
		RetailDetailBuilderScript.DETAIL_CABLE_HOOK,
		RetailDetailBuilderScript.DETAIL_RECEIPT_SLIP,
		RetailDetailBuilderScript.DETAIL_LABEL_PLATE,
		RetailDetailBuilderScript.DETAIL_QUEUE_STANCHION_ROPE,
		RetailDetailBuilderScript.DETAIL_WINDOW_DECAL,
		RetailDetailBuilderScript.DETAIL_HOURS_PLAQUE,
		RetailDetailBuilderScript.DETAIL_FLOOR_MAT,
		RetailDetailBuilderScript.DETAIL_STOCKROOM_LABEL,
		RetailDetailBuilderScript.DETAIL_CONDITION_STICKER,
		RetailDetailBuilderScript.DETAIL_PROTECTIVE_SLEEVE,
		RetailDetailBuilderScript.DETAIL_DISPLAY_PLACARD,
	]:
		assert_true(RetailDetailBuilderScript.detail_ids().has(detail_id), "%s must be public" % detail_id)


func test_price_condition_label_receipt_and_stockroom_details_keep_caller_text() -> void:
	var price_tag: Node3D = RetailDetailBuilderScript.price_tag("$12.99")
	var condition: Node3D = RetailDetailBuilderScript.condition_sticker("TESTED")
	var label_plate: Node3D = RetailDetailBuilderScript.label_plate("ROW A")
	var receipt: Node3D = RetailDetailBuilderScript.receipt_slip(["Subtotal", "Paid"])
	var stockroom: Node3D = RetailDetailBuilderScript.stockroom_label("BIN 03")
	for detail: Node3D in [price_tag, condition, label_plate, receipt, stockroom]:
		add_child_autofree(detail)
		_assert_visual_only_detail(detail)
		_assert_has_material_family(detail)
	_assert_label_text(price_tag, "LabelText", "$12.99")
	_assert_label_text(condition, "LabelText", "TESTED")
	_assert_label_text(label_plate, "LabelText", "ROW A")
	_assert_label_text(receipt, "LabelText", "Subtotal\nPaid")
	_assert_label_text(stockroom, "LabelText", "BIN 03")
	_assert_role(price_tag, StoreVisualKitScript.ROLE_SIGNAGE)
	_assert_role(condition, StoreVisualKitScript.ROLE_SIGNAGE)
	_assert_role(stockroom, StoreVisualKitScript.ROLE_STOCKROOM)
	assert_true(_groups(price_tag).has(StoreVisualKitScript.GROUP_PRICING))
	assert_true(_groups(label_plate).has(RetailDetailBuilderScript.GROUP_BUILD_MODE))


func test_operational_physical_details_cover_hook_queue_floor_and_sleeve_outputs() -> void:
	var hook: Node3D = RetailDetailBuilderScript.cable_hook()
	var queue: Node3D = RetailDetailBuilderScript.queue_stanchion_rope()
	var mat: Node3D = RetailDetailBuilderScript.floor_mat("QUEUE")
	var sleeve: Node3D = RetailDetailBuilderScript.protective_sleeve()
	for detail: Node3D in [hook, queue, mat, sleeve]:
		add_child_autofree(detail)
		_assert_visual_only_detail(detail)
		_assert_has_material_family(detail)
		assert_gte(_count_mesh_descendants(detail), 2, "%s should have readable geometry" % detail.name)
	_assert_role(hook, StoreVisualKitScript.ROLE_TOOL)
	_assert_role(queue, StoreVisualKitScript.ROLE_ROUTE_CUE)
	_assert_role(mat, StoreVisualKitScript.ROLE_DECOR)
	_assert_label_text(mat, "LabelText", "QUEUE")
	assert_true(_groups(queue).has(StoreVisualKitScript.GROUP_WAYFINDING))


func test_storefront_and_display_signage_accept_caller_text_only() -> void:
	var poster: Node3D = RetailDetailBuilderScript.poster_card("TRADE BOX", "ASK STAFF")
	var decal: Node3D = RetailDetailBuilderScript.window_decal("CLEAN CARTS")
	var plaque: Node3D = RetailDetailBuilderScript.hours_plaque("10-9")
	var placard: Node3D = RetailDetailBuilderScript.display_placard("FEATURED")
	var sticker: Node3D = RetailDetailBuilderScript.sale_sticker("DEAL")
	var talker: Node3D = RetailDetailBuilderScript.shelf_talker("PICKS")
	for detail: Node3D in [poster, decal, plaque, placard, sticker, talker]:
		add_child_autofree(detail)
		_assert_visual_only_detail(detail)
		_assert_has_material_family(detail)
		_assert_role(detail, StoreVisualKitScript.ROLE_SIGNAGE)
	_assert_label_text(poster, "LabelText", "TRADE BOX")
	_assert_label_text(poster, "BodyText", "ASK STAFF")
	_assert_label_text(decal, "LabelText", "CLEAN CARTS")
	_assert_label_text(plaque, "LabelText", "10-9")
	_assert_label_text(placard, "LabelText", "FEATURED")
	_assert_label_text(sticker, "LabelText", "DEAL")
	_assert_label_text(talker, "LabelText", "PICKS")
	assert_true(_groups(placard).has(RetailDetailBuilderScript.GROUP_CUSTOMIZATION))


func _assert_visual_only_detail(detail: Node3D) -> void:
	assert_true(bool(detail.get_meta("visual_only", false)), "%s should be visual-only" % detail.name)
	assert_eq(str(detail.get_meta("store_visual_source", "")), "retail_detail_builder")
	assert_eq(detail.get_meta("store_visual_source_type"), &"procedural")
	assert_false(_has_interaction_descendant(detail), "%s must not include gameplay nodes" % detail.name)


func _assert_role(detail: Node3D, expected: StringName) -> void:
	assert_eq(detail.get_meta("store_visual_role"), expected)
	assert_false(str(detail.get_meta("store_visual_display_name", "")).is_empty())


func _assert_label_text(detail: Node3D, path: String, expected: String) -> void:
	var label: Label3D = detail.get_node_or_null(path) as Label3D
	assert_not_null(label, "%s should expose %s" % [detail.name, path])
	if label == null:
		return
	assert_eq(label.text, expected)
	assert_true(bool(label.get_meta("caller_owned_text", false)))


func _assert_has_material_family(detail: Node) -> void:
	assert_false(
		String(StarterDetailBuilderScript.material_family_for_node(detail)).is_empty(),
		"%s root should expose a material family" % detail.name
	)
	var material_nodes: Array[Node] = detail.find_children("*", "MeshInstance3D", true, false)
	assert_gt(material_nodes.size(), 0, "%s should include mesh detail" % detail.name)
	for node: Node in material_nodes:
		assert_false(
			String(StarterDetailBuilderScript.material_family_for_node(node)).is_empty(),
			"%s should expose material family metadata" % node.name
		)


func _groups(detail: Node) -> Array:
	return detail.get_meta("store_visual_groups") as Array


func _count_mesh_descendants(parent: Node) -> int:
	var total: int = 0
	if parent is MeshInstance3D:
		total += 1
	for child: Node in parent.get_children():
		total += _count_mesh_descendants(child)
	return total


func _has_interaction_descendant(root: Node) -> bool:
	if (
		root is Area3D
		or root is CollisionObject3D
		or root is CollisionShape3D
		or root is PhysicsBody3D
		or root is NavigationObstacle3D
		or root is Interactable
	):
		return true
	for child: Node in root.get_children():
		if _has_interaction_descendant(child):
			return true
	return false
