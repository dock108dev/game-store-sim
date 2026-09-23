extends "res://scripts/test_week_scene.gd"
func run():
 root.size=Vector2i(2560,1440) if "--retina" in OS.get_cmdline_user_args() else Vector2i(1280,720)
 scene=load("res://main.tscn").instantiate();root.add_child(scene);await frames(4)
 scene.entry_menu.hide();scene.entry_menu.queue_free();scene.flow_paused=false
 check("retained B1 failure fixture valid",scene.state.load_from("res://evidence/b7-bankruptcy-fixture.json"))
 scene.restore_view();scene.refresh();scene.flow_paused=true
 scene.show_finances();await frames(4);await view("b7-bankruptcy-finances")
 await dismiss_dialog();scene.show_daily_reports();await frames(4);await view("b7-daily-closes");await dismiss_dialog()
 scene.queue_free();await frames(3);quit()
