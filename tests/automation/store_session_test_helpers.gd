extends RefCounted


static func acknowledge_first_minute_detail(controller: Node) -> bool:
	if controller == null:
		return false
	var panel: ModalPanel = controller.get("_first_minute_detail_panel") as ModalPanel
	if panel == null or not panel.visible:
		return false
	var button: Button = panel.get("_confirm_button") as Button
	if button == null:
		return false
	button.pressed.emit()
	return true


static func assert_acknowledge_first_minute_detail(test: Object, controller: Node) -> void:
	var panel: ModalPanel = controller.get("_first_minute_detail_panel") as ModalPanel
	test.assert_not_null(panel, "First-minute detail panel must exist")
	if panel == null or not panel.visible:
		return
	test.assert_true(
		acknowledge_first_minute_detail(controller),
		"First-minute detail panel must expose a confirm button"
	)
