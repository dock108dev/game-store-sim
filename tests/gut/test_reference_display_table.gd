## Tests the reusable reference display table preview products.
extends GutTest

const ShelfSlot: GDScript = preload("res://game/scripts/stores/shelf_slot.gd")
const _MeshBoundsUtil: GDScript = preload(
	"res://game/scripts/visuals/mesh_bounds_util.gd"
)

const DISPLAY_TABLE_SCENE: String = (
	"res://game/scenes/stores/fixtures/fixture_display_table.tscn"
)
const SUPPORT_TOLERANCE: float = 0.02


func test_fixture_display_table_uses_catalog_preview_cases() -> void:
	var root: Node3D = load(DISPLAY_TABLE_SCENE).instantiate() as Node3D
	add_child_autofree(root)

	var preview_layer: Node3D = root.get_node_or_null("PreviewProductCases") as Node3D
	assert_not_null(preview_layer, "FixtureDisplayTable must expose preview product layer")
	if preview_layer == null:
		return
	var preview_cases: Array[Node] = preview_layer.get_children()
	assert_eq(preview_cases.size(), 3, "FixtureDisplayTable must show three reference cases")

	var support: MeshInstance3D = root.get_node_or_null("TableMesh") as MeshInstance3D
	assert_not_null(support, "FixtureDisplayTable must keep TableMesh as support")
	var support_top_y: float = (
		_MeshBoundsUtil.mesh_bounds_in_root(root, support).end.y
		if support != null else 0.0
	)
	for preview_case: Node in preview_cases:
		var case_node := preview_case as Node3D
		assert_not_null(case_node, "Preview product must be a Node3D")
		if case_node == null:
			continue
		assert_eq(str(case_node.get_meta("product_visual_kind", "")), "game_case")
		assert_not_null(case_node.get_node_or_null("SpineTitleLabel"))
		var case_bounds: AABB = _MeshBoundsUtil.visual_bounds(root, case_node)
		assert_gte(
			case_bounds.position.y,
			support_top_y - SUPPORT_TOLERANCE,
			"Preview products must not clip into the table top"
		)
		assert_lte(
			case_bounds.end.y,
			support_top_y + 0.08,
			"Preview products must sit low on the display table"
		)

	for slot: Node in _collect_direct_slots(root):
		var shelf_slot := slot as ShelfSlot
		assert_not_null(shelf_slot, "FixtureDisplayTable slot must use ShelfSlot script")
		if shelf_slot == null:
			continue
		assert_false(
			shelf_slot.is_occupied(),
			"Preview cases must not occupy gameplay ShelfSlot state"
		)


func _collect_direct_slots(root: Node) -> Array[Node]:
	var slots: Array[Node] = []
	for child: Node in root.get_children():
		if child.is_in_group("shelf_slot") or child.get("slot_id") != null:
			slots.append(child)
	return slots

