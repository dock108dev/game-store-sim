## Interactable that teleports the orbit camera pivot to this zone when clicked.
##
## Left-clicking or pressing the mapped keyboard shortcut (nav_zone_N) snaps
## the PlayerController pivot to this zone's world position. The collision
## shape remains active in all builds; the DebugMesh placeholder is hidden
## unless an explicit debug-visual setting opts in.
class_name NavZoneInteractable
extends Interactable

const SHOW_DEBUG_MESHES_SETTING: String = "mallcore/debug/show_nav_zone_meshes"
const SCREENSHOT_MODE_SETTING: String = "mallcore/test/screenshot_mode"

## Keyboard shortcut index (1–5). PlayerController maps nav_zone_N actions to
## nodes in the "nav_zone" group by matching this value.
@export var zone_index: int = 0


func _ready() -> void:
	super._ready()
	_apply_debug_visibility()


## Calls the base interact chain and emits nav_zone_selected so the
## PlayerController pivot teleports here regardless of how interact() was
## triggered (raycast click or keyboard shortcut).
func interact(by: Node = null) -> void:
	super.interact(by)
	EventBus.nav_zone_selected.emit(global_position)


func _apply_debug_visibility() -> void:
	var debug_mesh: MeshInstance3D = get_node_or_null("DebugMesh") as MeshInstance3D
	if debug_mesh == null:
		return
	debug_mesh.visible = _should_show_debug_mesh()


func _should_show_debug_mesh() -> bool:
	return (
		OS.is_debug_build()
		and not bool(ProjectSettings.get_setting(SCREENSHOT_MODE_SETTING, false))
		and bool(ProjectSettings.get_setting(SHOW_DEBUG_MESHES_SETTING, false))
	)
