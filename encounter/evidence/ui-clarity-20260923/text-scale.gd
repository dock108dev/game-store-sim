extends "res://scripts/test_week_scene.gd"
func enlarge(node):
 if node is Control:
  node.add_theme_font_size_override("font_size",roundi(node.get_theme_font_size("font_size")*1.2))
 for child in node.get_children(true):enlarge(child)
func run():
 root.size=Vector2i(1280,720)
 scene=load("res://main.tscn").instantiate();root.add_child(scene);await frames(5);await enter_week()
 scene.state.receive();scene.refresh();enlarge(scene.ui);await frames(5);await view("font-120-prep")
 scene.show_finances();enlarge(dialog());await frames(5);await view("font-120-finances")
 scene.queue_free();await frames(3);quit()
