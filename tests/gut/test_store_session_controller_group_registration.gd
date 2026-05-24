## Pins the timing invariant that StoreSessionController joins the
## `store_session_controller` scene-tree group as the first action of its
## `_ready()` — before any deferred call, before its child panels open, and
## therefore before `EventBus.day_started` can fire through the controller's
## own flow. The race documented in
## `.aidlc/research/morning-note-body-duplication.md` (Path D — store_session guard
## timing) requires this property: ManagerRelationshipManager's store_session
## short-circuit reads the group on its `day_started` listener, and if the
## controller is not yet a member, the global MorningNotePanel stacks on top
## of `ManagerNotePanel`.
extends GutTest


const SCENE_PATH: String = "res://game/scenes/stores/retro_games.tscn"


func before_each() -> void:
	InputFocus._reset_for_tests()
	ModalQueue._reset_for_tests()


func test_controller_is_in_group_immediately_after_ready() -> void:
	var scene: PackedScene = load(SCENE_PATH)
	assert_not_null(scene, "retro_games.tscn must load")
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	add_child_autofree(root)
	# `add_child` runs `_ready()` synchronously. The controller's `_ready` adds
	# itself to the group as line 1; the deferred `_open_day` has not yet
	# executed. Group lookup must succeed right here, with no
	# `await get_tree().process_frame` in between — that is the invariant
	# ManagerRelationshipManager's store_session guard relies on.
	var controller: Node = get_tree().get_first_node_in_group(
		"store_session_controller"
	)
	assert_not_null(
		controller,
		"StoreSessionController must register in the store_session_controller "
		+ "group during _ready(), before any deferred call runs."
	)


## Direct check on the controller's lifecycle: after `_ready()` returns the
## controller reports `is_in_group` true. Catches a future refactor that moves
## `add_to_group` past a `call_deferred` or below a no-op guard.
func test_controller_reports_is_in_group_after_ready() -> void:
	var scene: PackedScene = load(SCENE_PATH)
	if scene == null:
		return
	var root: Node3D = scene.instantiate() as Node3D
	add_child_autofree(root)
	var controller: Node = get_tree().get_first_node_in_group(
		"store_session_controller"
	)
	if controller == null:
		fail_test("store_session_controller not found in tree after _ready")
		return
	assert_true(
		controller.is_in_group("store_session_controller"),
		"Controller's own is_in_group check must return true after _ready"
	)
