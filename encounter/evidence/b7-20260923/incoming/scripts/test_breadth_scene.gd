extends "res://scripts/test_week_scene.gd"
func run():
 Engine.time_scale=3.0
 var retina="--retina" in OS.get_cmdline_user_args()
 root.size=Vector2i(2560,1440) if retina else Vector2i(1280,720)
 scene=load("res://main.tscn").instantiate();root.add_child(scene);scene.save_path="user://b6-breadth.json";await frames(5)
 record_frames=DisplayServer.get_name()!="headless" and not retina;movie_dir="res://evidence/frames/b6-breadth"
 if record_frames:DirAccess.make_dir_recursive_absolute(movie_dir)
 # Explicit synthetic empty-day prelude. No owner save or injected money/inventory.
 scene.set_process(false);scene.state.receive()
 while scene.state.data.day<5:
  scene.state.open();scene.state.close();scene.state.finalize();scene.state.advance(scene.state.data.day)
 scene.restore_view();scene.refresh();scene.set_process(true)
 process_frame.connect(watch)
 await press(scene.buy_button);await key(KEY_ENTER);await frames(3)
 await press(scene.primary);await settle();await click_at(Vector2(410,550));await settle()
 check("day5 seller physically reaches intake",await wait_until(func():return scene.state.seller().status=="ready",2400))
 await seller_control()
 check("empty day5 full roster drains",await wait_until(func():return scene.state.data.customers.values().all(func(c):return c.state=="gone"),3600))
 await press(scene.close_button);await settle();check("seller drain",await wait_until(func():return scene.state.can_finalize(),2400));await press(scene.primary);await settle();await advance_control()
 await hire_control("morgan");await hire_control("jules")
 # Both releases through supplier; original prepaid copies remain. Eight slots are full.
 await order_control([0,0,0,1,1]);await label_week()
 # Player explicitly stocks fair Curb, labels independent of the new copies.
 await press(scene.copies_button);await frames(4);await press(named("Shelf +1"));await settle()
 var used="used:"+scene.state.data.run_id+":5:1"
 check("player stocks selected used copy",scene.state.data.items[used].location=="shelf")
 await click_at(Vector2(410,550));await settle();await staff_role("morgan",1);await staff_role("jules",1)
 check("base full mixed display",await wait_until(func():return scene.state.shelf_used()==8,3600))
 # Force no shopping substitution: all five titles need deliberate allocation.
 # Return one duplicate original via ordinary assortment so a release gets a slot.
 await staff_role("morgan",0);await staff_role("jules",0)
 for p in ["signal","rally"]:
  if scene.state.count_at("shelf",p)==0:
   await press(scene.copies_button);await frames(4)
   var rows=controls(dialog(),HBoxContainer).filter(func(row):return controls(row,Label).any(func(label):return label.text.begins_with("Curb Circuit 02 · NEW / new · shelf")))
   await press(controls(rows[0],Button).filter(func(button):return button.text=="Return")[0]);await settle()
   var slot=scene.state.free_slot();var index=scene.Layout.racks(scene.state.data.layout).find(slot.fixture_id)
   scene.rack_select.select(index);scene.rack_select.item_selected.emit(index)
   await stock_one(scene.State.PRODUCTS.find(p))
 await staff_role("morgan",2);await staff_role("jules",2)
 await view("b6-base-five-title-mix")
 await press(scene.primary);await settle();await click_at(Vector2(410,550));await settle()
 var seller_done=false;var switch_done=false
 for n in range(6000):
  await process_frame
  if not seller_done and scene.state.seller().status=="ready":await seller_control();seller_done=true
  if not switch_done and scene.state.data.sales.filter(func(s):return s.day==6).size()>=3:
   await staff_role("morgan",0);await staff_role("jules",0);switch_done=true
  if switch_done and scene.selected_action=="sale" and scene.pending=="" and scene.path.is_empty():
   await press(scene.primary);await settle();await click_at(Vector2(410,550));await settle()
  if scene.state.data.customers.values().all(func(c):return c.state=="gone") and seller_done and scene.state.seller().motion=="gone":break
 check("eight buyers workers seller drain in base",scene.state.data.customers.values().all(func(c):return c.state=="gone"))
 check("player sells used fixed offer",scene.state.data.jobs.any(func(j):return j.actor=="player" and j.copy==used and j.kind=="sale" and j.status=="committed"))
 check("new release ordinary player sale",scene.state.data.jobs.any(func(j):return j.actor=="player" and j.kind=="sale" and j.status=="committed" and scene.state.data.items[j.copy].product in ["signal","rally"]))
 await press(scene.close_button);await settle();check("base closes",await wait_until(func():return scene.state.can_finalize(),2400));await press(scene.primary);await settle()
 check("base no expansion and financial validity",scene.state.data.layout.space_level==0 and scene.state.valid())
 check("base eight-arrival actor clearance",not overlap and not fixture_collision and max_buyers<=3)
 check("base live invariants",not invariant_failure)
 await view("b6-base-report");await reload_stage("base mixed report")
 process_frame.disconnect(watch);record_frames=false
 var suffix="retina" if retina else "headless" if DisplayServer.get_name()=="headless" else "normal"
 var f=FileAccess.open("res://evidence/breadth-scene-"+suffix+".json",FileAccess.WRITE);f.store_string(JSON.stringify({"checks":results,"final":scene.state.data,"max_buyers":max_buyers,"frames":movie_number},"  "));f.close()
 f=FileAccess.open("res://evidence/breadth-motion-"+suffix+".json",FileAccess.WRITE);f.store_string(JSON.stringify(week_motion));f.close()
 print("B6_BREADTH ",results.size());quit(0)
