extends GutTest


func test_buyer_customer_has_shopping_role_prop() -> void:
	var customer: Node = load("res://scenes/customers/simple_buyer_customer.tscn").instantiate()
	add_child_autofree(customer)

	assert_not_null(customer.get_node_or_null("ShoppingBasketMesh"))
	assert_true(_body_color(customer).b > _body_color(customer).r)


func test_trade_in_customer_has_trade_role_prop() -> void:
	var customer: Node = load("res://scenes/customers/simple_trade_in_customer.tscn").instantiate()
	add_child_autofree(customer)

	assert_not_null(customer.get_node_or_null("TradeInItem"))
	assert_not_null(customer.get_node_or_null("TradeTagMesh"))
	assert_true(_body_color(customer).r > _body_color(customer).b)


func test_preorder_customer_has_larger_preorder_slip() -> void:
	var customer: Node = load("res://scenes/customers/simple_preorder_customer.tscn").instantiate()
	add_child_autofree(customer)

	var slip := customer.get_node_or_null("PreorderSlipMesh") as MeshInstance3D
	assert_not_null(slip)
	assert_gte(slip.mesh.size.x, 0.4)


func test_service_customer_has_disc_and_ticket_props() -> void:
	var customer: Node = load("res://scenes/customers/simple_service_customer.tscn").instantiate()
	add_child_autofree(customer)

	assert_not_null(customer.get_node_or_null("ServiceDiscMesh"))
	assert_not_null(customer.get_node_or_null("ServiceTicketMesh"))
	assert_true(_body_color(customer).g > _body_color(customer).r)


func test_suspicious_customer_has_note_and_cash_cue() -> void:
	var customer: Node = load("res://scenes/customers/suspicious_customer.tscn").instantiate()
	add_child_autofree(customer)

	assert_not_null(customer.get_node_or_null("NoteMesh"))
	assert_not_null(customer.get_node_or_null("CashStackMesh"))
	assert_true(_body_color(customer).r < 0.12)


func _body_color(customer: Node) -> Color:
	var body := customer.get_node("BodyMesh") as MeshInstance3D
	var material := body.mesh.material as StandardMaterial3D
	return material.albedo_color
