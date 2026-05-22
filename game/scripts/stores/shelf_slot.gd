## A single slot on a shelf or display fixture that can hold one item.
class_name ShelfSlot
extends Interactable

signal slot_changed(slot: ShelfSlot)

const _SHELF_PRODUCT_SCENE: PackedScene = preload(
	"res://game/assets/models/props/placeholder_prop_shelf_product.tscn"
)
const _GAME_CARTRIDGE_SCENE: PackedScene = preload(
	"res://game/assets/models/props/placeholder_prop_game_cartridge.tscn"
)
const _GAME_CONSOLE_SCENE: PackedScene = preload(
	"res://game/assets/models/props/prop_game_console.tscn"
)
const _ShelfCategoryNormalizer: GDScript = preload(
	"res://game/scripts/stores/shelf_category_normalizer.gd"
)
const _ProductVisualFactory: GDScript = preload(
	"res://game/scripts/visuals/product_visual_factory.gd"
)
const CATEGORY_SCENES: Dictionary = {
	"sealed_product": _SHELF_PRODUCT_SCENE,
	"cartridge": _GAME_CARTRIDGE_SCENE,
	"console": _GAME_CONSOLE_SCENE,
	"accessory": _SHELF_PRODUCT_SCENE,
	"guide": _SHELF_PRODUCT_SCENE,
	"snacks": _SHELF_PRODUCT_SCENE,
	"merchandise": _SHELF_PRODUCT_SCENE,
}
const DEFAULT_ITEM_SCENE: PackedScene = _SHELF_PRODUCT_SCENE

# Per-category placeholder tint so different stocked items read as visually
# distinct cubes on the shelf even before final art lands. Applied to the
# spawned item mesh's first MeshInstance3D as a surface override material.
const CATEGORY_COLORS: Dictionary = {
	"cartridge": Color(0.40, 0.85, 0.40),
	"console": Color(0.35, 0.55, 0.95),
	"accessory": Color(0.95, 0.85, 0.35),
	"guide": Color(0.95, 0.65, 0.35),
	"sealed_product": Color(0.55, 0.75, 0.85),
	"snacks": Color(0.95, 0.55, 0.75),
	"merchandise": Color(0.45, 0.85, 0.85),
}
const DEFAULT_PLACEHOLDER_COLOR := Color(0.85, 0.85, 0.85)

const HIGHLIGHT_EMPTY := Color(0.2, 0.8, 0.2)
const HIGHLIGHT_OCCUPIED := Color(0.9, 0.2, 0.2)
# accent_interact #5BB8E8 at alpha 0.35 — shown only when stocking cursor matches
const STOCKING_TINT := Color(91.0 / 255.0, 184.0 / 255.0, 232.0 / 255.0, 0.35)
# Always-on dim ghost shown when the slot is empty regardless of placement
# mode, so the player can read floor stock state at a glance from FP eye
# height. Sized smaller than PlaceholderMesh (0.15 m) and held at low alpha
# so it reads as "intentionally empty" without competing with the brighter
# placement marker that overlays it during stocking.
const _EMPTY_GHOST_NAME: StringName = &"EmptyGhost"
const _EMPTY_GHOST_SIZE: Vector3 = Vector3(0.10, 0.10, 0.10)
const _EMPTY_GHOST_COLOR := Color(0.5, 0.5, 0.5, 0.22)
const PROMPT_NO_ITEM_SELECTED: String = "Select an inventory item first"
const PROMPT_SHELF_FULL: String = "Shelf full"
const STOCK_VERB_FORMAT: String = "Stock %s"

@export var slot_id: String = ""
@export var fixture_id: String = ""
@export var slot_size: String = "standard"
## Category filter for stocking highlights. Empty string accepts any category.
@export var accepted_category: String = ""

var _occupied: bool = false
var _held_item_id: String = ""
var _held_category: String = ""
var _held_item_visual_data: Dictionary = {}
var _item_node: Node3D = null
var _placement_active: bool = false
var _info_label: Label3D = null
var _label_accent: Color = Color.WHITE
var _label_focus_active: bool = false
var _authored_display_name: String = ""
var _pending_item_name: String = ""
var _stocked_item_name: String = ""
var _empty_ghost: MeshInstance3D = null

@onready var _empty_mesh: MeshInstance3D = _resolve_empty_mesh()


func _ready() -> void:
	interaction_type = InteractionType.SHELF_SLOT
	if display_name.is_empty():
		display_name = "Shelf Slot"
	# Preserve authored verbs; only replace the inherited default.
	if action_verb == "Interact":
		action_verb = "Stock"
	add_to_group("shelf_slot")
	super._ready()
	# Capture after super._ready() so prompt refresh can restore authored copy.
	_authored_display_name = display_name
	_empty_ghost = _ensure_empty_ghost()
	_update_empty_indicator()
	EventBus.placement_mode_entered.connect(_on_placement_entered)
	EventBus.placement_mode_exited.connect(_on_placement_exited)
	EventBus.placement_hint_requested.connect(_on_placement_hint_requested)
	EventBus.stocking_cursor_active.connect(_on_stocking_cursor_active)
	EventBus.stocking_cursor_inactive.connect(_on_stocking_cursor_inactive)
	# Hover-gated labels avoid cluttering FP eye height.
	focused.connect(_on_label_focused)
	unfocused.connect(_on_label_unfocused)
	slot_changed.connect(_on_self_slot_changed)
	_refresh_prompt_state()


## Returns whether an item is currently placed in this slot.
func is_occupied() -> bool:
	return _occupied


## Returns true if this slot can accept an item.
func is_available() -> bool:
	return not _occupied


## Returns the instance ID of the placed item, or empty string if empty.
func get_item_instance_id() -> String:
	if _occupied:
		return _held_item_id
	return ""


## Returns the instance ID of the held item, or empty StringName if empty.
func get_item_id() -> StringName:
	return StringName(get_item_instance_id())


## Returns the maximum number of items this slot can hold.
func get_capacity() -> int:
	return 1


## Returns the number of items currently occupying this slot (0 or 1).
func get_occupied() -> int:
	return 1 if _occupied else 0


## Returns the normalized runtime category for the held item, or empty if empty.
func get_held_category() -> String:
	if _occupied:
		return _held_category
	return ""


## Places an item into this slot, returning true on success.
## Returning false on a re-stock keeps the current item and visual intact.
func place_item(instance_id: String, category: String = "") -> bool:
	if _occupied:
		return false
	_held_item_visual_data = {}
	return _place_item_internal(instance_id, category)


## Places an item with optional visual-only packaging metadata.
## Missing or malformed visual metadata falls back to the category placeholder.
func place_item_with_data(item_data: Dictionary) -> bool:
	if _occupied:
		return false
	var instance_id: String = str(item_data.get("instance_id", item_data.get("id", "")))
	var category: String = str(item_data.get("category", ""))
	_held_item_visual_data = item_data.duplicate(true)
	return _place_item_internal(instance_id, category)


func _place_item_internal(instance_id: String, category: String = "") -> bool:
	if _occupied:
		return false
	_held_item_id = instance_id
	_held_category = _ShelfCategoryNormalizer.normalize(category)
	_occupied = true
	_update_visual(get_occupied())
	slot_changed.emit(self)
	return true


## Assigns an item to this slot by canonical instance ID, returning true on success.
func assign_item(id: StringName) -> bool:
	return place_item(String(id))


## Removes the item from this slot and returns its instance ID.
## Empty string on an already-empty slot is a no-op result.
func remove_item() -> String:
	if not _occupied:
		return ""
	var item_id: String = _held_item_id
	_held_item_id = ""
	_held_category = ""
	_held_item_visual_data = {}
	_stocked_item_name = ""
	_occupied = false
	_update_visual(get_occupied())
	clear_display_data()
	slot_changed.emit(self)
	return item_id


## Synchronizes the slot's 3D placeholder with current occupancy.
func _update_visual(quantity: int) -> void:
	if quantity <= 0:
		_free_item_mesh()
	elif _item_node == null:
		_spawn_item_mesh(_held_category)
	_update_empty_indicator()


## Removes the held item and restores availability.
func deassign() -> void:
	remove_item()


## Displays item name, condition, and price above this slot as a billboard label.
## Creates the Label3D on first call; subsequent calls update text in place.
func set_display_data(item_name: String, condition: String, price: float) -> void:
	if not _info_label:
		_info_label = Label3D.new()
		# Sized for the fixed orthographic store camera; smaller smudges.
		_info_label.pixel_size = 0.005
		_info_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		_info_label.no_depth_test = true
		_info_label.font_size = 48
		_info_label.outline_size = 6
		_info_label.outline_modulate = Color(0.05, 0.07, 0.12, 0.85)
		_info_label.position = Vector3(0.0, 0.32, 0.0)
		_info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_info_label.modulate = _label_accent
		add_child(_info_label)
	_info_label.text = "%s\n%s  $%.2f" % [item_name, condition.capitalize(), price]
	_info_label.visible = _label_focus_active
	_stocked_item_name = item_name
	_refresh_prompt_state()


## Sets the accent color used for the info label text. Applies immediately if
## the label already exists.
func apply_accent(color: Color) -> void:
	_label_accent = color
	if _info_label:
		_info_label.modulate = color


## Hides the info label without destroying it.
func clear_display_data() -> void:
	_stocked_item_name = ""
	if _info_label:
		_info_label.visible = false
	_refresh_prompt_state()


## Keeps empty capacity visible while preserving placement-only highlights.
func _update_empty_indicator() -> void:
	if not is_node_ready():
		return
	if _empty_mesh != null:
		_empty_mesh.visible = (not _occupied) and _placement_active
	if _empty_ghost != null:
		_empty_ghost.visible = not _occupied


## Creates the always-on dim ghost child if it does not already exist.
func _ensure_empty_ghost() -> MeshInstance3D:
	var existing: MeshInstance3D = get_node_or_null(
		String(_EMPTY_GHOST_NAME)
	) as MeshInstance3D
	if existing != null:
		return existing
	var ghost := MeshInstance3D.new()
	ghost.name = _EMPTY_GHOST_NAME
	var box := BoxMesh.new()
	box.size = _EMPTY_GHOST_SIZE
	ghost.mesh = box
	var mat := StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = _EMPTY_GHOST_COLOR
	ghost.set_surface_override_material(0, mat)
	ghost.visible = not _occupied
	add_child(ghost)
	return ghost


## Spawns a catalog-backed product visual when metadata resolves. Otherwise
## spawns the existing placeholder scene and applies the category tint.
func _spawn_item_mesh(category: String) -> void:
	_free_item_mesh()
	var runtime_category: String = _ShelfCategoryNormalizer.normalize(category)
	var visual_data: Dictionary = _held_item_visual_data.duplicate(true)
	if not visual_data.is_empty():
		visual_data["category"] = runtime_category
		var catalog_visual: Node3D = _ProductVisualFactory.create_visual_for_item(
			visual_data
		)
		if catalog_visual != null:
			_item_node = catalog_visual
			add_child(catalog_visual)
			return
	var scene: PackedScene = CATEGORY_SCENES.get(
		runtime_category, DEFAULT_ITEM_SCENE
	)
	var instance: Node3D = scene.instantiate()
	_item_node = instance
	add_child(instance)
	_apply_category_color(instance, runtime_category)


## Tints the first MeshInstance3D in the placeholder subtree when present.
func _apply_category_color(root: Node3D, category: String) -> void:
	var mesh: MeshInstance3D = _find_first_mesh_instance(root)
	if mesh == null:
		return
	var runtime_category: String = _ShelfCategoryNormalizer.normalize(category)
	var color: Color = CATEGORY_COLORS.get(
		runtime_category, DEFAULT_PLACEHOLDER_COLOR
	)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.7
	var surface_count: int = mesh.get_surface_override_material_count()
	if surface_count <= 0:
		mesh.set_surface_override_material(0, mat)
		return
	for i: int in range(surface_count):
		mesh.set_surface_override_material(i, mat)


static func _find_first_mesh_instance(root: Node) -> MeshInstance3D:
	if root is MeshInstance3D:
		return root as MeshInstance3D
	for child: Node in root.get_children():
		var found: MeshInstance3D = _find_first_mesh_instance(child)
		if found:
			return found
	return null


## Frees the item node if it exists.
func _free_item_mesh() -> void:
	if _item_node and is_instance_valid(_item_node):
		_item_node.queue_free()
		_item_node = null


func _resolve_empty_mesh() -> MeshInstance3D:
	var placeholder: MeshInstance3D = get_node_or_null(
		"PlaceholderMesh"
	) as MeshInstance3D
	if placeholder:
		return placeholder
	return get_node_or_null("Marker") as MeshInstance3D


## State-aware prompt label matching InteractionRay label formatting.
func get_prompt_label() -> String:
	var verb: String = prompt_text.strip_edges()
	var target_name: String = display_name.strip_edges()
	if verb.is_empty() and target_name.is_empty():
		return ""
	if target_name.is_empty():
		return verb
	if verb.is_empty():
		return target_name
	return "%s %s" % [verb, target_name]


## Returns true when the slot would accept the given category. Empty
## accepted_category accepts any item (unfiltered counter / impulse slots).
func accepts_category(item_category: String) -> bool:
	return _ShelfCategoryNormalizer.matches(accepted_category, item_category)


## Recomputes prompt state for placement, empty, and occupied shelf states.
func _refresh_prompt_state() -> void:
	if _placement_active and _occupied:
		display_name = PROMPT_SHELF_FULL
		prompt_text = ""
		return
	if _placement_active and not _pending_item_name.is_empty():
		display_name = _authored_display_name
		prompt_text = STOCK_VERB_FORMAT % _pending_item_name
		return
	if not _occupied:
		display_name = PROMPT_NO_ITEM_SELECTED
		prompt_text = ""
		return
	if not _stocked_item_name.is_empty():
		display_name = "%s ×%d" % [_stocked_item_name, get_occupied()]
	else:
		display_name = _authored_display_name
	prompt_text = ""


func _on_self_slot_changed(_slot: ShelfSlot) -> void:
	_refresh_prompt_state()


func _on_placement_hint_requested(item_name: String) -> void:
	_pending_item_name = item_name
	_refresh_prompt_state()


## Overrides base highlight to use green/red during placement mode.
func highlight() -> void:
	if _placement_active:
		_apply_placement_highlight()
		return
	super.highlight()


## Overrides base unhighlight to clear placement highlights too.
func unhighlight() -> void:
	super.unhighlight()


func _on_label_focused() -> void:
	_label_focus_active = true
	if _info_label:
		_info_label.visible = true


func _on_label_unfocused() -> void:
	_label_focus_active = false
	if _info_label:
		_info_label.visible = false


func _on_placement_entered() -> void:
	_placement_active = true
	_update_empty_indicator()
	_refresh_prompt_state()


func _on_placement_exited() -> void:
	_placement_active = false
	_pending_item_name = ""
	if _highlight_active:
		unhighlight()
	_update_empty_indicator()
	_refresh_prompt_state()


func _on_stocking_cursor_active(item_category: StringName) -> void:
	if _occupied or _empty_mesh == null:
		return
	if not accepts_category(String(item_category)):
		return
	_apply_stocking_highlight()


func _on_stocking_cursor_inactive() -> void:
	_clear_stocking_highlight()


func _apply_stocking_highlight() -> void:
	var mat := StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = STOCKING_TINT
	_empty_mesh.set_surface_override_material(0, mat)


func _clear_stocking_highlight() -> void:
	if _empty_mesh == null:
		return
	_empty_mesh.set_surface_override_material(0, null)


## Applies green (empty) or red (occupied) emission highlight.
func _apply_placement_highlight() -> void:
	if _highlight_active:
		return
	_highlight_active = true

	var mesh_node: MeshInstance3D = _find_mesh_instance()
	if not mesh_node:
		return

	var emission_color: Color
	if _occupied:
		emission_color = HIGHLIGHT_OCCUPIED
	else:
		emission_color = HIGHLIGHT_EMPTY

	_original_materials.clear()
	var surface_count: int = (
		mesh_node.get_surface_override_material_count()
	)
	for i: int in range(surface_count):
		var mat: Material = mesh_node.get_surface_override_material(i)
		if not mat and mesh_node.mesh:
			mat = mesh_node.mesh.surface_get_material(i)
		_original_materials.append(mat)

		var highlight_mat := StandardMaterial3D.new()
		if mat is StandardMaterial3D:
			highlight_mat = (mat as StandardMaterial3D).duplicate()
		highlight_mat.emission_enabled = true
		highlight_mat.emission = emission_color
		highlight_mat.emission_energy_multiplier = 0.8
		mesh_node.set_surface_override_material(i, highlight_mat)
