extends "res://scripts/test_week_scene.gd"
func run():
 root.size=Vector2i(1280,720)
 scene=load("res://main.tscn").instantiate();root.add_child(scene);await frames(4)
 scene.session_started=true
 scene.entry_menu.hide();scene.entry_menu.queue_free();await frames(2)
 # Synthetic terminal setup; scene controls own the restart confirmation.
 scene.save_path="user://b7-terminal.json";scene.state.checkpoint_path=scene.save_path
 for day in range(1,8):
  scene.state.receive();scene.state.open();scene.state.close();scene.state.finalize()
  if day<7:scene.state.advance(day)
 var terminal=scene.state.data.duplicate(true);scene.refresh()
 scene.show_finances();await frames(3);await view("b7-terminal-finances");await dismiss_dialog()
 scene.confirm_reset();await frames(3);await key(KEY_ESCAPE);await frames(3)
 check("restart cancellation preserves terminal",scene.state.data==terminal)
 scene.save_path="user://missing-b7-folder/run.json"
 scene.confirm_reset();await frames(3);await press(dialog().get_ok_button());await frames(3)
 check("failed restart retains terminal",scene.state.data==terminal and "retained" in scene.feedback.text)
 scene.save_path="user://b7-terminal.json"
 scene.confirm_reset();await frames(3);await press(dialog().get_ok_button());await frames(3)
 var preserved=scene.State.new()
 check("restart archives terminal before new run",scene.state.data.day==1 and scene.state.data.run_id!=terminal.run_id and preserved.load_from("user://terminal-"+terminal.run_id+".json") and preserved.data==terminal)
 # Malformed checkpoint UI must offer a genuinely separate, discoverable week.
 scene.save_path="user://b7-malformed-entry.json"
 var f=FileAccess.open(scene.save_path,FileAccess.WRITE);f.store_string("{broken");f.close()
 var broken=scene.save_path
 scene.show_entry();await frames(3);await view("b7-malformed-entry")
 await press(scene.entry_menu.get_meta("new_button"));await frames(3);await press(dialog().get_ok_button());await frames(3)
 check("malformed original preserved by new week",FileAccess.get_file_as_string(broken)=="{broken" and scene.save_path!=broken and FileAccess.file_exists(scene.save_path))
 check("separate checkpoint discoverable next launch",FileAccess.get_file_as_string(scene.session_file)==scene.save_path.get_file())
 # Locator belongs only to this fault probe; keep later scene suites fresh.
 DirAccess.remove_absolute(scene.session_file)
 f=FileAccess.open("res://evidence/b7-restart.json",FileAccess.WRITE);f.store_string(JSON.stringify(results,"  "));f.close();quit(0)
