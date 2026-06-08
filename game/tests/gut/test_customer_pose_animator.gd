extends GutTest


func test_customer_pose_animator_lists_required_placeholder_poses() -> void:
	var animator := CustomerPoseAnimator.new()
	add_child_autofree(animator)

	var poses := animator.get_supported_pose_states()
	for pose in [
		CustomerPoseAnimator.POSE_IDLE,
		CustomerPoseAnimator.POSE_WALK,
		CustomerPoseAnimator.POSE_BROWSE,
		CustomerPoseAnimator.POSE_PICK_UP,
		CustomerPoseAnimator.POSE_QUEUE,
		CustomerPoseAnimator.POSE_TALK,
		CustomerPoseAnimator.POSE_PAY,
		CustomerPoseAnimator.POSE_HAND_OVER_ITEM,
		CustomerPoseAnimator.POSE_LEAVE_HAPPY,
		CustomerPoseAnimator.POSE_LEAVE_ANNOYED,
		CustomerPoseAnimator.POSE_WAIT_IMPATIENT,
	]:
		assert_true(poses.has(pose))


func test_buyer_pose_tracks_movement_queue_and_impatience() -> void:
	var customer: SimpleBuyerCustomer = load("res://scenes/customers/simple_buyer_customer.tscn").instantiate()
	add_child_autofree(customer)
	var animator := customer.get_node("CustomerPoseAnimator") as CustomerPoseAnimator

	customer.state = SimpleBuyerCustomer.STATE_BROWSING
	assert_eq(animator.tick_pose(0.0), CustomerPoseAnimator.POSE_BROWSE)

	customer.state = SimpleBuyerCustomer.STATE_MOVING_TO_ITEM
	assert_eq(animator.tick_pose(0.0), CustomerPoseAnimator.POSE_WALK)

	customer.state = SimpleBuyerCustomer.STATE_WAITING_FOR_REGISTER
	assert_eq(animator.tick_pose(0.0), CustomerPoseAnimator.POSE_QUEUE)
	assert_eq(animator.tick_pose(animator.impatient_after_seconds + 0.1), CustomerPoseAnimator.POSE_WAIT_IMPATIENT)


func test_special_customer_poses_match_transaction_outcomes() -> void:
	var trade_customer: SimpleTradeInCustomer = load("res://scenes/customers/simple_trade_in_customer.tscn").instantiate()
	add_child_autofree(trade_customer)
	var trade_animator := trade_customer.get_node("CustomerPoseAnimator") as CustomerPoseAnimator
	assert_eq(trade_animator.tick_pose(0.0), CustomerPoseAnimator.POSE_HAND_OVER_ITEM)

	trade_customer.decline_trade_in()
	assert_eq(trade_animator.tick_pose(0.0), CustomerPoseAnimator.POSE_LEAVE_ANNOYED)

	var preorder_customer: SimplePreorderCustomer = load("res://scenes/customers/simple_preorder_customer.tscn").instantiate()
	add_child_autofree(preorder_customer)
	var preorder_animator := preorder_customer.get_node("CustomerPoseAnimator") as CustomerPoseAnimator
	assert_eq(preorder_animator.tick_pose(0.0), CustomerPoseAnimator.POSE_TALK)
	preorder_customer.complete_preorder()
	assert_eq(preorder_animator.tick_pose(0.0), CustomerPoseAnimator.POSE_LEAVE_HAPPY)

	var service_customer: SimpleServiceCustomer = load("res://scenes/customers/simple_service_customer.tscn").instantiate()
	add_child_autofree(service_customer)
	var service_animator := service_customer.get_node("CustomerPoseAnimator") as CustomerPoseAnimator
	assert_eq(service_animator.tick_pose(0.0), CustomerPoseAnimator.POSE_TALK)
	service_customer.complete_service()
	assert_eq(service_animator.tick_pose(0.0), CustomerPoseAnimator.POSE_LEAVE_HAPPY)


func test_pose_application_moves_limbs_without_moving_customer_root() -> void:
	var customer: SimpleBuyerCustomer = load("res://scenes/customers/simple_buyer_customer.tscn").instantiate()
	add_child_autofree(customer)
	var animator := customer.get_node("CustomerPoseAnimator") as CustomerPoseAnimator
	var root_position := customer.position

	customer.state = SimpleBuyerCustomer.STATE_MOVING_TO_REGISTER
	animator.tick_pose(0.0)
	animator.tick_pose(0.3)

	var left_arm := customer.get_node("LeftArmMesh") as Node3D
	var right_leg := customer.get_node("RightLegMesh") as Node3D
	assert_ne(left_arm.rotation, Vector3.ZERO)
	assert_ne(right_leg.rotation, Vector3.ZERO)
	assert_eq(customer.position, root_position)
