extends "res://scripts/test_week_scene.gd"
var measurements=[]
func find_button(node, text):
 if node is Button and node.text==text:return node
 for child in node.get_children(true):
  var found=find_button(child,text)
  if found!=null:return found
 return null
func snap(title):
 await frames(5)
 RenderingServer.force_draw()
 root.get_texture().get_image().save_png("res://evidence/"+title+".png")
 var dialogs=scene.ui.get_children().filter(func(c):return c is AcceptDialog and c.visible)
 if not dialogs.is_empty():measurements.append({"screen":title,"dialog_size":str(dialogs.back().size),"dialog_position":str(dialogs.back().position)})
func run():
 Engine.time_scale=3
 root.size=Vector2i(2560,1440) if "--retina" in OS.get_cmdline_user_args() else Vector2i(1280,720)
 scene=load("res://main.tscn").instantiate();root.add_child(scene);await frames(5)
 await snap("entry")
 await enter_week();await press(scene.primary);await settle();await snap("prep")
 scene.show_order();await snap("supplier");await key(KEY_ESCAPE);await frames(4)
 scene.show_daily_reports();await snap("history-empty");await dismiss_dialog()
 scene.show_finances();await snap("finances")
 if scene.has_method("show_finance_details"):
  await press(find_button(dialog(),"Calculation details"));await snap("calculation-details");await dismiss_dialog()
 await dismiss_dialog()
 scene.show_copies();await snap("copies")
 if scene.has_method("show_finance_details"):
  var records_button=find_button(dialog(),"Show copy records")
  records_button.grab_focus();await key(KEY_SPACE);check("copy records keyboard disclosure",records_button.button_pressed);await snap("copy-records")
  await press(find_button(dialog(),"Hide copy records"));await frames(3)
 await dismiss_dialog()
 await label_week();await stock_one(0);await stock_one(1);await stock_one(2)
 await snap("stocked")
 await press(scene.primary);await settle();await snap("shop-open")
 await press(scene.close_button);await settle()
 check("shop drains",await drain());await snap("report")
 scene.show_daily_reports();await snap("history");await dismiss_dialog()
 scene.save_path="user://missing-directory/failed.json";scene.save_visible();await frames(5);await snap("save-failed");await press(dialog().get_ok_button());await frames(3)
 # Synthetic empty days exercise the real settlement rules; not an owner playthrough.
 for day in range(1,7):
  scene.state.advance(day);scene.state.receive();scene.state.open();scene.state.close();scene.state.finalize()
 scene.refresh();await snap("week-complete");scene.show_finances();await snap("week-finances");await dismiss_dialog()
 scene.show_daily_reports();await snap("week-history");await dismiss_dialog()
 # Separate fresh synthetic business, using ordinary stock purchases to exhaust cash.
 scene.state=scene.State.new();scene.state.receive()
 scene.state.commit_fixture({"request_id":"failure-rack","operation":"buy","type":"rack","fixture_id":"rack-0001","origin":[400,430],"day":1,"phase":"prep","revision":0})
 for day in range(1,8):
  if day<=3:scene.state.order({"curb":6,"tide":6,"orbit":6,"signal":0,"rally":0},day);scene.state.receive()
  scene.state.open();scene.state.close();scene.state.finalize()
  if day<7:scene.state.advance(day)
 check("synthetic failure reaches bankruptcy",scene.state.data.phase=="bankrupt")
 scene.restore_view();scene.refresh();scene.show_finances();await snap("bankruptcy-finances");await dismiss_dialog()
 scene.state=scene.State.new();scene.restore_view();scene.refresh();scene.show_copies();await snap("copies-empty");await dismiss_dialog()
 await key(KEY_TAB);measurements.append({"terminal_tab_focus":root.gui_get_focus_owner()!=null})
 var out=FileAccess.open("res://evidence/observations.json",FileAccess.WRITE);out.store_string(JSON.stringify({"measurements":measurements,"checks":results},"  "));out.close()
 scene.queue_free();await frames(3);quit()
