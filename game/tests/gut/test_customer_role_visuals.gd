extends GutTest


func test_buyer_customer_has_shopping_role_prop() -> void:
	var customer: Node = load("res://scenes/customers/simple_buyer_customer.tscn").instantiate()
	add_child_autofree(customer)

	_assert_customer_uses_modular_body_kit(customer)
	assert_not_null(customer.get_node_or_null("ShoppingBasketMesh"))
	assert_true(_body_color(customer).b > _body_color(customer).r)


func test_trade_in_customer_has_trade_role_prop() -> void:
	var customer: Node = load("res://scenes/customers/simple_trade_in_customer.tscn").instantiate()
	add_child_autofree(customer)

	_assert_customer_uses_modular_body_kit(customer)
	assert_not_null(customer.get_node_or_null("TradeInItem"))
	assert_not_null(customer.get_node_or_null("TradeTagMesh"))
	assert_true(_body_color(customer).r > _body_color(customer).b)


func test_preorder_customer_has_larger_preorder_slip() -> void:
	var customer: Node = load("res://scenes/customers/simple_preorder_customer.tscn").instantiate()
	add_child_autofree(customer)

	_assert_customer_uses_modular_body_kit(customer)
	var slip := customer.get_node_or_null("PreorderSlipMesh") as MeshInstance3D
	assert_not_null(slip)
	assert_gte(slip.mesh.size.x, 0.4)


func test_service_customer_has_disc_and_ticket_props() -> void:
	var customer: Node = load("res://scenes/customers/simple_service_customer.tscn").instantiate()
	add_child_autofree(customer)

	_assert_customer_uses_modular_body_kit(customer)
	assert_not_null(customer.get_node_or_null("ServiceDiscMesh"))
	assert_not_null(customer.get_node_or_null("ServiceTicketMesh"))
	assert_true(_body_color(customer).g > _body_color(customer).r)


func test_suspicious_customer_has_note_and_cash_cue() -> void:
	var customer: Node = load("res://scenes/customers/suspicious_customer.tscn").instantiate()
	add_child_autofree(customer)

	_assert_customer_uses_modular_body_kit(customer)
	assert_not_null(customer.get_node_or_null("NoteMesh"))
	assert_not_null(customer.get_node_or_null("CashStackMesh"))
	assert_true(_body_color(customer).r < 0.12)


func test_customer_role_silhouettes_are_visually_distinct() -> void:
	var scene_paths := [
		"res://scenes/customers/simple_buyer_customer.tscn",
		"res://scenes/customers/simple_trade_in_customer.tscn",
		"res://scenes/customers/simple_preorder_customer.tscn",
		"res://scenes/customers/simple_service_customer.tscn",
		"res://scenes/customers/suspicious_customer.tscn",
	]
	var seen_body_widths: Array[float] = []
	for scene_path in scene_paths:
		var customer: Node = load(scene_path).instantiate()
		add_child_autofree(customer)
		_assert_customer_uses_modular_body_kit(customer)
		var body := customer.get_node("BodyMesh") as MeshInstance3D
		seen_body_widths.append(snappedf(body.mesh.size.x, 0.01))

	var min_width := seen_body_widths[0]
	var max_width := seen_body_widths[0]
	for width in seen_body_widths:
		min_width = minf(min_width, width)
		max_width = maxf(max_width, width)

	assert_gt(max_width - min_width, 0.07)


func test_customer_role_props_stay_below_head_and_off_center() -> void:
	for scene_path in [
		"res://scenes/customers/simple_buyer_customer.tscn",
		"res://scenes/customers/simple_trade_in_customer.tscn",
		"res://scenes/customers/simple_preorder_customer.tscn",
		"res://scenes/customers/simple_service_customer.tscn",
		"res://scenes/customers/suspicious_customer.tscn",
	]:
		var customer: Node = load(scene_path).instantiate()
		add_child_autofree(customer)
		var role_prop := customer.get_node("RoleSilhouetteMesh") as MeshInstance3D
		var head := customer.get_node("HeadMesh") as MeshInstance3D
		assert_lt(role_prop.position.y, head.position.y)
		assert_gte(absf(role_prop.position.z), 0.14)
		assert_lte(role_prop.position.y, 1.0)


func _assert_customer_uses_modular_body_kit(customer: Node) -> void:
	var body := customer.get_node_or_null("BodyMesh") as MeshInstance3D
	assert_not_null(body)
	assert_true(body.mesh is BoxMesh)
	assert_not_null(customer.get_node_or_null("HeadMesh"))
	assert_not_null(customer.get_node_or_null("HairMesh"))
	assert_not_null(customer.get_node_or_null("ShoulderMesh"))
	assert_not_null(customer.get_node_or_null("LeftArmMesh"))
	assert_not_null(customer.get_node_or_null("RightArmMesh"))
	assert_not_null(customer.get_node_or_null("LeftLegMesh"))
	assert_not_null(customer.get_node_or_null("RightLegMesh"))
	assert_not_null(customer.get_node_or_null("RoleSilhouetteMesh"))


func _body_color(customer: Node) -> Color:
	var body := customer.get_node("BodyMesh") as MeshInstance3D
	var material := body.mesh.material as StandardMaterial3D
	return material.albedo_color
