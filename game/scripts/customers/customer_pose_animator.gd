extends Node3D
class_name CustomerPoseAnimator

const POSE_IDLE := "idle"
const POSE_WALK := "walk"
const POSE_BROWSE := "browse"
const POSE_PICK_UP := "pick_up"
const POSE_QUEUE := "queue"
const POSE_TALK := "talk"
const POSE_PAY := "pay"
const POSE_HAND_OVER_ITEM := "hand_over_item"
const POSE_LEAVE_HAPPY := "leave_happy"
const POSE_LEAVE_ANNOYED := "leave_annoyed"
const POSE_WAIT_IMPATIENT := "wait_impatient"

@export var state_source_path: NodePath = NodePath("..")
@export var impatient_after_seconds: float = 4.0
@export var walk_cycle_speed: float = 6.0
@export var left_arm_path: NodePath = NodePath("../LeftArmMesh")
@export var right_arm_path: NodePath = NodePath("../RightArmMesh")
@export var left_leg_path: NodePath = NodePath("../LeftLegMesh")
@export var right_leg_path: NodePath = NodePath("../RightLegMesh")
@export var head_path: NodePath = NodePath("../HeadMesh")
@export var role_prop_path: NodePath = NodePath("../RoleSilhouetteMesh")

var pose_state: String = POSE_IDLE
var state_elapsed_seconds: float = 0.0
var _last_source_state: String = ""


static func supported_pose_states() -> Array[String]:
	return [
		POSE_IDLE,
		POSE_WALK,
		POSE_BROWSE,
		POSE_PICK_UP,
		POSE_QUEUE,
		POSE_TALK,
		POSE_PAY,
		POSE_HAND_OVER_ITEM,
		POSE_LEAVE_HAPPY,
		POSE_LEAVE_ANNOYED,
		POSE_WAIT_IMPATIENT,
	]


func _ready() -> void:
	tick_pose(0.0)


func _process(delta: float) -> void:
	tick_pose(delta)


func tick_pose(delta: float) -> String:
	var source_state := _read_source_state()
	if source_state != _last_source_state:
		_last_source_state = source_state
		state_elapsed_seconds = 0.0
	else:
		state_elapsed_seconds += delta

	pose_state = get_pose_for_customer_state(source_state, state_elapsed_seconds)
	_apply_pose(pose_state, state_elapsed_seconds)
	return pose_state


func get_supported_pose_states() -> Array[String]:
	return CustomerPoseAnimator.supported_pose_states()


func get_pose_for_customer_state(customer_state: String, elapsed_seconds: float = 0.0) -> String:
	match customer_state:
		"moving_to_item", "moving_to_register":
			return POSE_WALK
		"browsing":
			return POSE_BROWSE
		"waiting_for_register":
			if elapsed_seconds >= impatient_after_seconds:
				return POSE_WAIT_IMPATIENT
			return POSE_QUEUE
		"sale_complete", "trade_complete", "preorder_complete", "service_complete":
			return POSE_LEAVE_HAPPY
		"trade_declined":
			return POSE_LEAVE_ANNOYED
		"waiting_for_trade":
			return POSE_HAND_OVER_ITEM
		"waiting_for_preorder", "waiting_for_service":
			return POSE_TALK

	if customer_state.is_empty() and get_parent() is SuspiciousCustomer:
		return POSE_TALK

	return POSE_IDLE


func get_pose_summary() -> Dictionary:
	return {
		"pose_state": pose_state,
		"supported_poses": get_supported_pose_states(),
		"state_elapsed_seconds": state_elapsed_seconds,
	}


func _apply_pose(next_pose: String, elapsed_seconds: float) -> void:
	var arm_swing := sin(elapsed_seconds * walk_cycle_speed) * 0.28
	var leg_swing := sin(elapsed_seconds * walk_cycle_speed) * 0.22
	var left_arm_rotation := Vector3.ZERO
	var right_arm_rotation := Vector3.ZERO
	var left_leg_rotation := Vector3.ZERO
	var right_leg_rotation := Vector3.ZERO
	var head_rotation := Vector3.ZERO
	var prop_rotation := Vector3.ZERO

	match next_pose:
		POSE_WALK:
			left_arm_rotation = Vector3(arm_swing, 0.0, -0.12)
			right_arm_rotation = Vector3(-arm_swing, 0.0, 0.12)
			left_leg_rotation = Vector3(-leg_swing, 0.0, 0.0)
			right_leg_rotation = Vector3(leg_swing, 0.0, 0.0)
		POSE_BROWSE:
			head_rotation = Vector3(0.0, sin(elapsed_seconds * 1.8) * 0.18, 0.0)
			right_arm_rotation = Vector3(-0.16, 0.0, 0.08)
		POSE_PICK_UP:
			right_arm_rotation = Vector3(-0.55, 0.0, 0.2)
			head_rotation = Vector3(-0.12, 0.0, 0.0)
		POSE_QUEUE:
			left_arm_rotation = Vector3(-0.08, 0.0, -0.08)
			right_arm_rotation = Vector3(-0.08, 0.0, 0.08)
		POSE_TALK:
			head_rotation = Vector3(0.0, 0.12, 0.0)
			right_arm_rotation = Vector3(-0.38, 0.0, 0.26)
		POSE_PAY:
			right_arm_rotation = Vector3(-0.5, 0.0, 0.18)
			prop_rotation = Vector3(-0.18, 0.0, 0.0)
		POSE_HAND_OVER_ITEM:
			left_arm_rotation = Vector3(-0.42, 0.0, -0.22)
			right_arm_rotation = Vector3(-0.5, 0.0, 0.22)
			prop_rotation = Vector3(-0.24, 0.0, 0.0)
		POSE_LEAVE_HAPPY:
			head_rotation = Vector3(0.0, 0.0, 0.08)
			right_arm_rotation = Vector3(-0.2, 0.0, 0.36)
		POSE_LEAVE_ANNOYED:
			head_rotation = Vector3(0.12, 0.0, -0.08)
			left_arm_rotation = Vector3(0.1, 0.0, -0.28)
			right_arm_rotation = Vector3(0.1, 0.0, 0.28)
		POSE_WAIT_IMPATIENT:
			head_rotation = Vector3(0.0, sin(elapsed_seconds * 4.0) * 0.12, 0.0)
			left_arm_rotation = Vector3(-0.18, 0.0, -0.22)
			right_arm_rotation = Vector3(-0.18, 0.0, 0.22)

	_set_rotation(left_arm_path, left_arm_rotation)
	_set_rotation(right_arm_path, right_arm_rotation)
	_set_rotation(left_leg_path, left_leg_rotation)
	_set_rotation(right_leg_path, right_leg_rotation)
	_set_rotation(head_path, head_rotation)
	_set_rotation(role_prop_path, prop_rotation)


func _read_source_state() -> String:
	var source := get_node_or_null(state_source_path)
	if source == null:
		source = get_parent()
	if source == null:
		return ""

	var source_state = source.get("state")
	if source_state is String:
		return source_state

	return ""


func _set_rotation(path: NodePath, rotation: Vector3) -> void:
	var target := get_node_or_null(path) as Node3D
	if target != null:
		target.rotation = rotation
