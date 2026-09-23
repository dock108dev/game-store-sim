extends "res://scripts/test_week_scene.gd"
func run():
 Engine.time_scale=1
 root.size=Vector2i(1280,720)
 scene=load("res://main.tscn").instantiate();root.add_child(scene);scene.save_path="user://b7-exit.json";await frames(5)
 # Refresh entry after selecting this isolated script's checkpoint.
 scene.entry_menu.queue_free();await frames(2);scene.show_entry();await frames(3)
 if "--resume" in OS.get_cmdline_user_args():
  check("relaunch checkpoint describes open day", "Day 1" in scene.checkpoint_info().text and "open" in scene.checkpoint_info().text)
  await press(scene.entry_menu.get_meta("continue_button"));scene.flow_paused=true;await frames(2)
  var expected=scene.State.Economy.normalized(JSON.parse_string(FileAccess.get_file_as_string("res://evidence/b7-exit-before.json")))
  check("relaunch restores exact transactions",scene.state.data.cash==expected.cash and scene.state.data.events==expected.events and scene.state.data.sales==expected.sales and scene.state.data.items==expected.items)
  var f=FileAccess.open("res://evidence/b7-exit-resume.json",FileAccess.WRITE);f.store_string(JSON.stringify(results));f.close()
  scene.flow_paused=false
  scene.notification(Node.NOTIFICATION_WM_CLOSE_REQUEST);await frames(3)
 else:
  await enter_week();await press(scene.primary);await settle()
  for n in range(3):
   scene.product_select.select(n);scene.product_select.item_selected.emit(n)
   await press(scene.reprice_button);await settle();await stock_one(n)
  await press(scene.primary);await settle();await frames(5)
  if scene.state.data.phase=="prep":await dismiss_dialog();await settle()
  check("ordinary mid-day reached",scene.state.data.phase=="open")
  await key(KEY_ESCAPE);await frames(3)
  var f=FileAccess.open("res://evidence/b7-exit-before.json",FileAccess.WRITE);f.store_string(JSON.stringify(scene.state.data));f.close()
 await view("b7-exit-confirmation")
 await press(dialog().get_meta("quit_button"))
