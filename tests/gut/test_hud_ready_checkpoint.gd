extends GutTest

const _HudScene: PackedScene = preload("res://game/scenes/ui/hud.tscn")


func before_each() -> void:
	AuditLog.clear()


func test_hud_ready_checkpoint_emits_after_required_nodes_exist() -> void:
	var hud: CanvasLayer = _HudScene.instantiate() as CanvasLayer
	add_child_autofree(hud)
	await get_tree().process_frame
	await get_tree().process_frame

	var saw: bool = false
	for entry: Dictionary in AuditLog.recent(16):
		if entry.get("checkpoint", &"") == &"hud_ready":
			saw = true
			break

	assert_true(saw, "HUD should emit hud_ready after required nodes initialize")
