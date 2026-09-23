extends "res://scripts/test_week_scene.gd"
func run():
 Engine.time_scale=1
 root.size=Vector2i(2560,1440) if "--retina" in OS.get_cmdline_user_args() else Vector2i(1280,720)
 scene=load("res://main.tscn").instantiate();root.add_child(scene);scene.save_path="user://b7-flow-"+str(Time.get_ticks_usec())+".json";await frames(5)
 await view("b7-entry")
 check("entry pauses time and movement",scene.flow_paused and scene.state.data.clock==0)
 check("missing checkpoint explanation",not scene.checkpoint_info().ok and "No checkpoint" in scene.checkpoint_info().text)
 await enter_week();await key(KEY_F1);await frames(3);await view("b7-help");await key(KEY_ESCAPE);await frames(3)
 check("help dismisses",not scene.flow_paused)
 await press(scene.primary);await settle();check("guided receive",scene.state.data.received)
 await press(scene.order_button);await frames(3)
 var standing=scene.player.position
 await key(KEY_RIGHT);await frames(3)
 check("modal arrows do not move Rowan",scene.player.position==standing)
 await key(KEY_ESCAPE);await frames(3)
 await key(KEY_K);await frames(5)
 var saved=scene.state.data.duplicate(true)
 check("visible save succeeded",not scene.state.save_pending and "Saved:" in scene.feedback.text)
 await key(KEY_L);await frames(3);await view("b7-reload-warning");await key(KEY_ESCAPE);await frames(3)
 check("reload cancellation retains state",scene.state.data==saved and not scene.flow_paused)
 scene.show_entry();await frames(3);await press(scene.entry_menu.get_meta("continue_button"));await frames(3)
 check("continue restores checkpoint",scene.state.data==saved and not scene.flow_paused)
 # Continue may become unreadable after its menu probe; never silently ignore it.
 scene.show_entry();await frames(3)
 var continue_path=scene.save_path;scene.save_path="user://missing-continue.json"
 await press(scene.entry_menu.get_meta("continue_button"));await frames(3)
 check("continue failure is visible and retains live state", "Continue failed" in scene.entry_menu.dialog_text and scene.state.data==saved and scene.flow_paused)
 scene.save_path=continue_path
 await press(scene.entry_menu.get_meta("continue_button"));await frames(3)
 # Save succeeded but the separate-week locator failed: Save and quit must stay open.
 var base_path=scene.save_path;var locator_path=scene.session_file
 scene.save_path="user://week-locator-test.json";scene.session_file="user://missing-locator/active-week.txt"
 scene.save_visible(true);await frames(5)
 check("locator open failure prevents quit after saved checkpoint",FileAccess.file_exists(scene.save_path) and not scene.state.save_pending and dialog().title.begins_with("Continue locator failed") and scene.state.data==saved)
 await press(dialog().get_ok_button());await frames(3)
 # Force rename failure independently of opening the temporary file.
 scene.session_file="user://locator-directory"
 DirAccess.make_dir_absolute(scene.session_file)
 scene.save_visible(true);await frames(5)
 check("locator rename failure prevents quit",dialog().title.begins_with("Continue locator failed") and scene.state.data==saved)
 await press(dialog().get_ok_button());await frames(3)
 scene.session_file=locator_path
 scene.save_visible();await frames(5)
 check("locator recovery publishes checkpoint without replay",FileAccess.get_file_as_string(locator_path)==scene.save_path.get_file() and scene.state.data==saved)
 DirAccess.remove_absolute(locator_path)
 scene.save_path=base_path
 # Inject only an isolated unwritable destination; no state or ledger editing.
 var original=scene.save_path;scene.save_path="user://missing-folder/checkpoint.json"
 await key(KEY_K);await frames(5);await view("b7-save-failure")
 check("failure retains transactions",scene.state.save_pending and scene.state.data==saved and dialog().title.begins_with("Save failed"))
 scene.save_path=original
 await press(dialog().get_meta("retry_button"));await frames(5)
 check("retry no duplicate transactions",not scene.state.save_pending and scene.state.data==saved)
 for contents in ["{broken",'{"version":9}', '{"version":10,"ruleset_id":"b6-retail-1"}']:
  scene.save_path="user://b7-invalid.json"
  var f=FileAccess.open(scene.save_path,FileAccess.WRITE);f.store_string(contents);f.close()
  var info=scene.checkpoint_info()
  check("invalid explained without replacement",not info.ok and not scene.state.save_to(scene.save_path) and FileAccess.get_file_as_string(scene.save_path)==contents and scene.state.data==saved)
 scene.save_path=original
 scene.notification(Node.NOTIFICATION_WM_CLOSE_REQUEST);await frames(4);await view("b7-close-warning")
 check("window close warns and pauses",scene.flow_paused and dialog().title=="Week menu")
 await key(KEY_ESCAPE);await frames(4)
 check("window close cancellation keeps session",not scene.flow_paused and scene.state.data==saved)
 # Keyboard focus and decorative hit testing.
 await key(KEY_TAB);check("keyboard focus present",root.gui_get_focus_owner()!=null)
 check("decorative labels ignore pointer",scene.guide.mouse_filter==Control.MOUSE_FILTER_IGNORE and scene.shelf_label.mouse_filter==Control.MOUSE_FILTER_IGNORE)
 for phase in ["prep","open"]:
  if phase=="open":scene.state.open()
  scene.refresh();await frames(3)
  check("toolbar stays above playable expanded floor",scene.expand_button.position.y==170)
 var out=FileAccess.open("res://evidence/b7-presentation-"+("retina" if "--retina" in OS.get_cmdline_user_args() else "headless" if DisplayServer.get_name()=="headless" else "normal")+".json",FileAccess.WRITE);out.store_string(JSON.stringify(results,"  "));out.close()
 quit(0)
