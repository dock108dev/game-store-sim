## Headless entry point that writes visual gallery review artifacts.
extends SceneTree

const GALLERY_SCENE_PATH: String = "res://tests/visual/visual_gallery.tscn"


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed: PackedScene = load(GALLERY_SCENE_PATH) as PackedScene
	if packed == null:
		push_error("Visual gallery scene missing: %s" % GALLERY_SCENE_PATH)
		quit(1)
		return
	var gallery: Node = packed.instantiate()
	root.add_child(gallery)
	await process_frame
	var result: Dictionary = gallery.call("write_review_artifacts", true) as Dictionary
	if not bool(result.get("ok", false)):
		push_error("Visual gallery artifact generation failed: %s" % str(result.get("error", "")))
		quit(1)
		return
	print("Visual gallery artifacts: %s" % str(result.get("path", "")))
	quit(0)
