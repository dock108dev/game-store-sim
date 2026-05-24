## Builds visual-only catalog product cases for the reusable display table fixture.
extends Node3D

const ProductVisualCatalogScript: GDScript = preload(
	"res://game/scripts/visuals/product_visual_catalog.gd"
)
const ProductVisualFactoryScript: GDScript = preload(
	"res://game/scripts/visuals/product_visual_factory.gd"
)
const MeshBoundsUtilScript: GDScript = preload(
	"res://game/scripts/visuals/mesh_bounds_util.gd"
)

const _PREVIEW_LAYER_NAME: String = "PreviewProductCases"
const _SURFACE_CLEARANCE: float = 0.012
const _LAY_FLAT_DEGREES: float = -90.0
const _PREVIEW_ITEMS: Array[Dictionary] = [
	{
		"slot_id": "display_table_1",
		"box_art_key": "star_pantry_rangers_vecforce_hd",
		"category": "cartridge",
		"yaw_degrees": -8.0,
	},
	{
		"slot_id": "display_table_2",
		"box_art_key": "goblin_kart_canopy_wave",
		"category": "cartridge",
		"yaw_degrees": 4.0,
	},
	{
		"slot_id": "display_table_3",
		"box_art_key": "brain_drill_wave_pocket",
		"category": "cartridge",
		"yaw_degrees": 10.0,
	},
]


func _ready() -> void:
	rebuild_preview_products()


## Rebuilds the table's decorative product cases without occupying ShelfSlot state.
func rebuild_preview_products() -> void:
	var preview_layer: Node3D = _ensure_preview_layer()
	_clear_children(preview_layer)

	var catalog: RefCounted = ProductVisualCatalogScript.load_default()
	if catalog == null or not str(catalog.get("load_error")).is_empty():
		push_warning("Display table product catalog did not load")
		return

	for index: int in range(_PREVIEW_ITEMS.size()):
		_add_preview_case(preview_layer, _PREVIEW_ITEMS[index], index, catalog)


func _ensure_preview_layer() -> Node3D:
	var existing: Node3D = get_node_or_null(_PREVIEW_LAYER_NAME) as Node3D
	if existing != null:
		return existing
	var layer := Node3D.new()
	layer.name = _PREVIEW_LAYER_NAME
	add_child(layer)
	return layer


func _clear_children(parent: Node) -> void:
	for child: Node in parent.get_children():
		parent.remove_child(child)
		child.free()


func _add_preview_case(
	preview_layer: Node3D, item: Dictionary, index: int, catalog: RefCounted
) -> void:
	var slot_id: String = str(item.get("slot_id", ""))
	var slot: Node3D = _find_slot(slot_id)
	if slot == null:
		push_warning("Display table preview slot missing: %s" % slot_id)
		return

	var visual_data: Dictionary = item.duplicate(true)
	visual_data["instance_id"] = "display_table_preview_%d" % index
	var visual: Node3D = ProductVisualFactoryScript.create_visual_for_item_with_catalog(
		visual_data, catalog
	)
	if visual == null:
		push_warning("Display table preview case missing visual: %s" % slot_id)
		return

	visual.name = "PreviewProductCase%d" % (index + 1)
	var yaw: float = deg_to_rad(float(item.get("yaw_degrees", 0.0)))
	visual.transform.basis = (
		Basis(Vector3.UP, yaw) * Basis(Vector3.RIGHT, deg_to_rad(_LAY_FLAT_DEGREES))
	)
	preview_layer.add_child(visual)
	_position_visual_on_slot(preview_layer, visual, slot.position)


func _find_slot(slot_id: String) -> Node3D:
	if slot_id.is_empty():
		return null
	for child: Node in get_children():
		if str(child.get("slot_id")) == slot_id and child is Node3D:
			return child as Node3D
	return null


func _position_visual_on_slot(
	preview_layer: Node3D, visual: Node3D, slot_position: Vector3
) -> void:
	var bounds: AABB = MeshBoundsUtilScript.visual_bounds(preview_layer, visual)
	if bounds.size == Vector3.ZERO:
		visual.position = slot_position + Vector3(0.0, _SURFACE_CLEARANCE, 0.0)
		return
	var center := Vector3(
		bounds.position.x + bounds.size.x * 0.5,
		0.0,
		bounds.position.z + bounds.size.z * 0.5
	)
	visual.position += Vector3(
		slot_position.x - center.x,
		slot_position.y + _SURFACE_CLEARANCE - bounds.position.y,
		slot_position.z - center.z
	)
