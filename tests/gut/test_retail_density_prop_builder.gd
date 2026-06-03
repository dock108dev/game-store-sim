extends GutTest

const RetailDensityPropBuilderScript: GDScript = preload(
	"res://game/scripts/visuals/retail_density_prop_builder.gd"
)


func test_builder_creates_visual_only_game_case_with_specific_parts() -> void:
	var prop: Node3D = RetailDensityPropBuilderScript.build({
		"name": "TestCase",
		"kind": RetailDensityPropBuilderScript.KIND_GAME_CASE,
		"role": "shelf_product_variety",
		"state_key": "shelf_density",
		"state": "stocked",
	})
	add_child_autofree(prop)
	assert_not_null(prop)
	if prop == null:
		return
	assert_eq(prop.name, "TestCase")
	assert_true(bool(prop.get_meta("visual_only", false)))
	assert_true(bool(prop.get_meta("phase4_retail_prop", false)))
	assert_eq(str(prop.get_meta("retail_prop_kind", "")), "game_case")
	assert_eq(str(prop.get_meta("retail_prop_role", "")), "shelf_product_variety")
	assert_eq(str(prop.get_meta("retail_state_key", "")), "shelf_density")
	assert_eq(str(prop.get_meta("retail_state_value", "")), "stocked")
	for child_name: String in ["CaseBody", "FrontLabelBlock", "SpineBand", "ConditionSticker"]:
		assert_not_null(prop.get_node_or_null(child_name), "Game case missing %s" % child_name)


func test_builder_creates_cartridge_console_and_controller_silhouettes() -> void:
	var cartridge: Node3D = RetailDensityPropBuilderScript.build({
		"name": "TestCart",
		"kind": RetailDensityPropBuilderScript.KIND_CARTRIDGE,
	})
	var console_box: Node3D = RetailDensityPropBuilderScript.build({
		"name": "TestConsole",
		"kind": RetailDensityPropBuilderScript.KIND_CONSOLE_BOX,
	})
	var controller: Node3D = RetailDensityPropBuilderScript.build({
		"name": "TestController",
		"kind": RetailDensityPropBuilderScript.KIND_CONTROLLER,
	})
	add_child_autofree(cartridge)
	add_child_autofree(console_box)
	add_child_autofree(controller)
	assert_not_null(cartridge)
	assert_not_null(console_box)
	assert_not_null(controller)
	if cartridge != null:
		assert_not_null(cartridge.get_node_or_null("ContactStrip"))
		assert_not_null(cartridge.get_node_or_null("SideNotch"))
	if console_box != null:
		assert_not_null(console_box.get_node_or_null("HandleSlot"))
		assert_not_null(console_box.get_node_or_null("FragileSticker"))
	if controller != null:
		assert_not_null(controller.get_node_or_null("LeftGrip"))
		assert_not_null(controller.get_node_or_null("ButtonDot00"))


func test_builder_creates_checkout_state_language_without_interaction() -> void:
	var prop: Node3D = RetailDensityPropBuilderScript.build({
		"name": "CheckoutState",
		"kind": RetailDensityPropBuilderScript.KIND_CHECKOUT_STATE,
		"role": "checkout_pending_physical_state",
		"state": "pending",
	})
	add_child_autofree(prop)
	assert_not_null(prop)
	if prop == null:
		return
	for child_name: String in ["StateTray", "StateItem", "StateStrip", "ReceiptSlip"]:
		assert_not_null(prop.get_node_or_null(child_name), "Checkout state missing %s" % child_name)
	assert_false(_has_interaction_descendant(prop))


func test_builder_creates_mall_context_variants() -> void:
	var planter: Node3D = RetailDensityPropBuilderScript.build({
		"name": "Planter",
		"kind": RetailDensityPropBuilderScript.KIND_MALL_CONTEXT,
		"role": "planter",
	})
	var bench: Node3D = RetailDensityPropBuilderScript.build({
		"name": "Bench",
		"kind": RetailDensityPropBuilderScript.KIND_MALL_CONTEXT,
		"role": "bench",
	})
	add_child_autofree(planter)
	add_child_autofree(bench)
	assert_not_null(planter)
	assert_not_null(bench)
	if planter != null:
		assert_not_null(planter.get_node_or_null("PlanterBase"))
		assert_not_null(planter.get_node_or_null("PlantMass"))
	if bench != null:
		assert_not_null(bench.get_node_or_null("BenchSeat"))
		assert_not_null(bench.get_node_or_null("BenchBack"))


func _has_interaction_descendant(node: Node) -> bool:
	if node is CollisionObject3D or node is Area3D or node is Interactable:
		return true
	for child: Node in node.get_children():
		if _has_interaction_descendant(child):
			return true
	return false
