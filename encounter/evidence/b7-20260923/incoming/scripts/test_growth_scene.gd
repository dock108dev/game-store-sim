extends "res://scripts/test_layout_scene.gd"
func empty_day():
 scene.state.open();scene.state.close();scene.state.finalize();scene.state.advance(scene.state.data.day);scene.state.receive()
func run():
 Engine.time_scale=3.0
 var retina="--retina" in OS.get_cmdline_user_args()
 root.size=Vector2i(2560,1440) if retina else Vector2i(1280,720)
 scene=load("res://main.tscn").instantiate();root.add_child(scene);scene.save_path="user://b3-scene.json";scene.state.checkpoint_path=scene.save_path;await frames(5)
 check("bills and schedule visible from day1",scene.bills_label.visible and "day 7" in scene.bills_label.text and scene.expand_button.disabled)
 await click_at(Vector2(310,450));await settle()
 # Prelude uses ordinary state commands; no arbitrary day/cash/fixture injection.
 for day in range(1,5):empty_day()
 scene.restore_view();scene.refresh();await frames(3)
 record_frames=DisplayServer.get_name()!="headless" and not retina
 movie_dir="res://evidence/frames/b3"
 if record_frames:DirAccess.make_dir_recursive_absolute(movie_dir)
 process_frame.connect(inspect_frame)
 await view("b3-day5")
 var before=scene.state.data.duplicate(true)
 await press(scene.expand_button);await frames(3)
 check("expansion preview valid pure fixed included rack",scene.draft_result.ok and scene.state.data==before and scene.draft.origin==[440,230])
 await view("b3-expansion-preview");await key(KEY_ESCAPE)
 check("expansion cancel no cash mutation",scene.state.data==before)
 # Fail the actual scene autosave, then use its visible Retry save action.
 DirAccess.make_dir_absolute(scene.save_path+".tmp")
 await press(scene.expand_button);await key(KEY_ENTER);await frames(5)
 check("confirmed expansion committed while save failure visible",scene.state.data.cash==45000 and scene.state.capacity()==8 and scene.state.save_pending and scene.save_button.text=="Retry save" and "SAVE FAILED" in scene.feedback.text)
 await view("b3-save-failed")
 DirAccess.remove_absolute(scene.save_path+".tmp")
 await press(scene.save_button);await frames(3)
 check("ordinary save retry does not charge again",not scene.state.save_pending and scene.state.data.cash==45000)
 check("reload names last successful checkpoint", "Day 5" in scene.load_button.tooltip_text and "prep" in scene.load_button.tooltip_text)
 await reload_stage("B3 expansion")
 check("expanded north floor and navigation",scene.bay_floor.visible and scene.nav.region.position.y==22)
 # Later rack2 remains purchasable after expansion.
 await press(scene.buy_button);await key(KEY_ENTER);await frames(3)
 check("rack2 later through controls",scene.state.capacity()==12 and scene.state.data.cash==39000)
 await label_products()
 await select_rack("rack-0003");await stock_one(0);await stock_one(1)
 await select_rack("rack-0002");await stock_one(2)
 check("ordinary stocking reaches north bay",scene.state.data.items["case-01"].fixture_id=="rack-0003" and scene.state.data.items["case-02"].fixture_id=="rack-0003")
 await view("b3-stocked-north")
 await select_rack("rack-0003");await press(scene.arrange_button);await key(KEY_LEFT);await key(KEY_ENTER);await frames(3)
 check("expanded stocked rack moves with slots",scene.state.data.layout.fixtures["rack-0003"].origin==[430,230] and scene.state.data.items["case-01"].fixture_id=="rack-0003")
 await press(scene.primary);await settle()
 check("north bay customers queue",await wait_until(func():return scene.state.data.queue.size()==3 and scene.state.data.customers.values().all(func(c):return c.state=="queued" and c.settled)))
 check("buyers actually browsed expansion",scene.state.data.customers.values().any(func(c):return c.browse_fixture=="rack-0003"))
 await view("b3-queue");await press(scene.close_button);await settle();check("expanded room drains corrected B2 queue",await drain())
 check("day5 paid sales settlement checkpoint",scene.state.data.cash==42000 and scene.state.data.settlements.size()==5 and not scene.state.save_pending)
 await view("b3-day5-report");scene.show_finances();await frames(3);await view("b3-finances");await press(dialog().get_ok_button())
 await press(scene.primary);await frames(3);await press(dialog().get_ok_button());await frames(3)
 check("day6 advance checkpoint",scene.state.data.day==6 and not scene.state.save_pending)
 # Close day6 and day7 through ordinary scene controls, retaining unsold stock.
 for day in [6,7]:
  await press(scene.primary);await settle();await press(scene.close_button);await settle()
  for i in range(2400):
   await process_frame;observe()
   if scene.pending=="" and scene.path.is_empty() and scene.selected_action in ["sale","finalize"]:scene.request_action(scene.selected_action)
   if scene.state.data.phase in ["report","week_complete"]:break
  check("day%d ordinary drain and settlement"%day,scene.state.data.phase==("report" if day==6 else "week_complete") and not scene.state.save_pending)
  if day==6:
   await press(scene.primary);await frames(3);await press(dialog().get_ok_button());await frames(3)
 check("terminal UI no advance or purchases",not scene.primary.visible and not scene.order_button.visible and not scene.arrange_button.visible and scene.expand_button.disabled and "SURVIVED" in scene.details.text)
 await view("b3-survived");await reload_stage("B3 terminal")
 scene.show_daily_reports();await frames(3);await view("b3-daily-history");await press(dialog().get_ok_button());await frames(3)
 var run_id=scene.state.data.run_id
 scene.confirm_reset();await frames(3);await press(dialog().get_ok_button());await frames(3)
 check("terminal preserved through confirmed restart",scene.state.data.day==1 and FileAccess.file_exists("user://terminal-"+run_id+".json"))
 # Separate actual-rule bankruptcy: $450 stock + $60 rack; no employee expenses.
 scene.perform("receive")
 scene.state.commit_fixture({"request_id":"failure-rack","operation":"buy","type":"rack","fixture_id":"rack-0001","origin":[400,430],"day":1,"phase":"prep","revision":0})
 for day in range(1,7):
  scene.state.open();scene.state.close();scene.state.finalize()
  if day<=3:scene.state.order({"curb":6,"tide":6,"orbit":6},day)
  scene.state.advance(day);scene.state.receive()
 scene.restore_view();scene.refresh();await frames(3)
 await press(scene.primary);await settle();await press(scene.close_button);await settle()
 for i in range(2400):
  await process_frame;observe()
  if scene.pending=="" and scene.path.is_empty() and scene.selected_action=="finalize":scene.request_action("finalize")
  if scene.state.data.phase=="bankrupt":break
 check("rent bankruptcy visible and autosaved",scene.state.data.phase=="bankrupt" and scene.state.data.cash==4000 and scene.state.data.terminal.shortfall==11000 and "Unpaid liabilities $150.00" in scene.details.text and not scene.state.save_pending)
 await view("b3-bankrupt");await reload_stage("B3 bankruptcy")
 check("expanded moving actors inspected",distances.size()==3 and distances.values().all(func(d):return d>600))
 check("B3 fixture routes",not fixture_collision)
 check("B3 buyer separation",not overlap)
 check("B3 scene invariants",not invariant_failure)
 record_frames=false;process_frame.disconnect(inspect_frame)
 var suffix="retina" if retina else "normal"
 var out=FileAccess.open("res://evidence/growth-scene-"+suffix+".json",FileAccess.WRITE);out.store_string(JSON.stringify({"checks":results,"distances":distances,"movie_frames":movie_number},"  "));out.close()
 out=FileAccess.open("res://evidence/growth-motion-"+suffix+".json",FileAccess.WRITE);out.store_string(JSON.stringify(motion));out.close()
 print("B3_GROWTH_SCENE ",results.size()," checks")
 quit(0 if results.all(func(r):return r.pass) else 1)

func label_products():
 for n in range(3):
  scene.product_select.select(n);scene.product_select.item_selected.emit(n);scene.price_input.value=10.00
  await press(scene.reprice_button);await settle()
  check("B3 $10 labels through controls "+str(n),scene.state.data.items["case-%02d"%(n+1)].price==1000)
