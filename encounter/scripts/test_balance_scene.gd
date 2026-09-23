extends "res://scripts/test_week_scene.gd"
const Policy=preload("res://scripts/b8_policy.gd")
var strategy="growth"
var actions=[]
var telemetry=[]
var day_start=0
var last_clock=0.0
var queue_seconds={}
var active_queue={}
var queue_max=0
var day_metrics=[]
var pace=false
var pace_frames=0
var capture_times=[]
func check(name,ok):
 if not ok and is_instance_valid(scene):
  var f=FileAccess.open("res://evidence/b8-partial.json",FileAccess.WRITE)
  f.store_string(JSON.stringify({"strategy":strategy,"failed_check":name,"days":day_metrics,"snapshots":snapshots,"actions":actions,"telemetry":telemetry,"capture_times":capture_times,"state":scene.state.data},"  "));f.close()
 super.check(name,ok)
func settle():
 var last=scene.player.position;var stalled=0.0;var detours=0
 for i in range(1600):
  await process_frame
  if scene.pending=="" and scene.path.is_empty() and not scene.floor_walk:return
  if scene.player.position.distance_to(last)<0.1:stalled+=scene.get_process_delta_time()
  else:stalled=0.0
  last=scene.player.position
  # Ordinary visible correction: step down out of a rack/queue passing lane.
  # Physical WASD keeps collision checks; no position/state assignment or reload.
  if scene.floor_walk and stalled>2.0 and detours<4:
   var target=scene.floor_target;var before=scene.player.position
   await key(KEY_S);await key(KEY_S)
   actions.append({"day":scene.state.data.day,"type":"aisle_detour","from":[before.x,before.y],"to":[scene.player.position.x,scene.player.position.y],"clock":scene.state.data.clock})
   await click_at(target);detours+=1;stalled=0.0;last=scene.player.position
 check("action route finishes",false)
func press(control):
 actions.append({"day":scene.state.data.day,"phase":scene.state.data.phase,"clock":scene.state.data.clock,"type":"button","label":control.text})
 await super.press(control)
func key(k):
 if is_instance_valid(scene):actions.append({"day":scene.state.data.day,"phase":scene.state.data.phase,"type":"key","key":k})
 await super.key(k)
func click_at(p):
 if is_instance_valid(scene):actions.append({"day":scene.state.data.day,"phase":scene.state.data.phase,"type":"floor","position":[p.x,p.y]})
 await super.click_at(p)
func track():
 if not is_instance_valid(scene):return
 var dt=maxf(0.0,scene.state.data.clock-last_clock);last_clock=scene.state.data.clock
 queue_max=maxi(queue_max,scene.state.data.queue.size())
 for id in scene.state.data.queue:queue_seconds[id]=queue_seconds.get(id,0.0)+dt
 if sample%30==0:telemetry.append({"day":scene.state.data.day,"phase":scene.state.data.phase,"clock":scene.state.data.clock,"queue":scene.state.data.queue.size(),"pending":scene.pending,"wall_msec":Time.get_ticks_msec()})
 if pace and scene.state.data.day in [1,6] and DisplayServer.get_name()!="headless":
  pace_frames+=1
  if pace_frames%3==0:
   var file="res://evidence/pace/%05d.png"%(pace_frames/3)
   capture_times.append({"file":file.get_file(),"wall_msec":Time.get_ticks_msec(),"day":scene.state.data.day})
   RenderingServer.force_draw();root.get_texture().get_image().save_png(file)
func label_week():
 for n in range(5):
  var p=scene.State.PRODUCTS[n]
  if not scene.State.Week.released(p,scene.state.data.day):continue
  var price=int(scene.State.CATALOG[p].reference*Policy.percent(strategy,scene.state.data.day)/100)
  if not scene.state.data.items.values().any(func(i):return i.product==p and i.kind=="new" and i.location!="sold" and i.price!=price):continue
  scene.product_select.select(n);scene.product_select.item_selected.emit(n);scene.price_input.value=float(price)/100
  actions.append({"day":scene.state.data.day,"type":"fields","count":2,"purpose":"title and price"})
  await press(scene.reprice_button);await settle()
 var used=scene.state.data.items.values().filter(func(i):return i.kind=="used" and i.location=="backroom" and i.available_day<=scene.state.data.day and i.price==0)
 for item in used:
  await press(scene.copies_button);await frames(4);await press(named("Label"));await settle()
func manual_stock():
 for n in range(5):
  var p=scene.State.PRODUCTS[n]
  while scene.state.data.items.values().any(func(i):return i.product==p and i.location=="backroom" and i.available_day<=scene.state.data.day and i.price>0) and not scene.state.free_slot().is_empty():
   var slot=scene.state.free_slot();var idx=scene.Layout.racks(scene.state.data.layout).find(slot.fixture_id)
   scene.rack_select.select(idx);scene.rack_select.item_selected.emit(idx)
   actions.append({"day":scene.state.data.day,"type":"fields","count":1,"purpose":"rack"})
   await stock_one(n)
func staff_role(id,index):
 actions.append({"day":scene.state.data.day,"type":"fields","count":1,"purpose":"employee role"})
 await super.staff_role(id,index)
func seller_control():
 if Policy.trading(strategy):
  if scene.state.data.day<7:actions.append({"day":scene.state.data.day,"type":"fields","count":1,"purpose":"initial seller offer"})
  await super.seller_control();return
 await press(scene.seller_button);await settle();await frames(4)
 await press(named("Refuse seller"));await frames(4)
 await click_at(Vector2(410,550));await settle()
func run_day():
 await press(scene.primary);await settle();await frames(4)
 if scene.state.data.phase=="prep":await dismiss_dialog();await settle()
 await click_at(Vector2(410,550));await settle()
 var seller_done=scene.state.data.day==1
 for i in range(14000):
  await process_frame
  if not seller_done and scene.state.seller().status=="ready" and scene.pending=="":await seller_control();seller_done=true
  if (not Policy.growth(strategy) or scene.state.data.day<3) and scene.selected_action=="sale" and scene.pending=="" and scene.path.is_empty():
   await press(scene.primary);await settle();await click_at(Vector2(410,550));await settle()
  if scene.state.data.customers.values().all(func(c):return c.state=="gone") and seller_done and (scene.state.seller().is_empty() or scene.state.seller().motion=="gone"):break
 check("all buyers drained "+strategy+str(scene.state.data.day),scene.state.data.customers.values().all(func(c):return c.state=="gone"))
 await press(scene.close_button);await settle()
 check("can settle",await wait_until(func():return scene.state.can_finalize(),1800))
 await press(scene.primary);await settle();await frames(4)
 check("valid daily terminal/report",scene.state.valid() and scene.state.data.phase in ["report","week_complete","bankrupt"])
 snapshots.append(scene.state.data.duplicate(true))
 day_metrics.append({"day":scene.state.data.day,"report":scene.state.business_report(scene.state.data.day),"retail":scene.state.report(),"queue_max":queue_max,"queue_seconds":queue_seconds.duplicate(),"wall_seconds":float(Time.get_ticks_msec()-day_start)/1000,"actions":actions.filter(func(a):return a.day==scene.state.data.day)})
 await view("b8-"+strategy+"-day"+str(scene.state.data.day));queue_max=0;queue_seconds.clear()
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--strategy="):strategy=arg.split("=")[1]
 pace="--pace" in OS.get_cmdline_user_args()
 Engine.time_scale=1.0 if pace else 3.0
 var retina="--retina" in OS.get_cmdline_user_args()
 root.size=Vector2i(2560,1440) if retina else Vector2i(1280,720)
 scene=load("res://main.tscn").instantiate();root.add_child(scene);scene.save_path="user://b8-"+strategy+"-"+str(Time.get_ticks_usec())+".json";scene.state.checkpoint_path=scene.save_path;await frames(5)
 await enter_week()
 if pace:DirAccess.make_dir_recursive_absolute("res://evidence/pace")
 process_frame.connect(watch);process_frame.connect(track)
 # Setup is New week only; no prelude, state edits, teleports, grants or debug actions.
 var calendar=scene.ui.get_children().filter(func(c):return c is Button and c.text=="Release calendar")[0]
 await press(calendar);await frames(4);await dismiss_dialog()
 await press(scene.primary);await settle()
 if strategy!="closed":await press(scene.buy_button);await key(KEY_ENTER);await frames(5)
 for day in range(1,8):
  day_start=Time.get_ticks_msec();last_clock=scene.state.data.clock
  if pace:Engine.time_scale=1.0 if day in [1,6] else 3.0
  for id in scene.State.Staff.IDS:
   if Policy.hire_day(strategy,id)==day or (strategy=="bankruptcy" and day==3):await hire_control(id)
  if Policy.growth(strategy) and day==5:await press(scene.expand_button);await key(KEY_ENTER);await frames(4)
  if day==2 and Policy.growth(strategy):
   await select_rack("rack-0001");await press(scene.arrange_button);await key(KEY_LEFT);await key(KEY_ENTER);await frames(4)
  var q=Policy.quantities(scene.state,strategy)
  if q.any(func(v):return v>0):
   actions.append({"day":day,"type":"fields","count":5,"purpose":"supplier quantities"});await order_control(q)
  if strategy not in ["closed","bankruptcy"]:
   await label_week()
   if Policy.growth(strategy) and day>=3:
    await click_at(Vector2(410,550));await settle();await staff_role("morgan",1)
    if Policy.hire_day(strategy,"jules")>0 and day>=6:await staff_role("jules",1)
    check("staff stocked available copies",await wait_until(func():return scene.state.data.items.values().all(func(i):return i.location!="backroom" or i.available_day>day),3600))
    await staff_role("morgan",2)
    if Policy.hire_day(strategy,"jules")>0 and day>=6:await staff_role("jules",2)
   else:await manual_stock()
  await run_day()
  if day==3:await reload_stage("B8 closed checkpoint no rollback")
  if day<7:await advance_control()
 check("expected terminal",scene.state.data.phase==("bankrupt" if strategy=="bankruptcy" else "week_complete"))
 check("continuous state valid",not invariant_failure)
 check("actor separation",not overlap)
 check("fixture clearance",not fixture_collision)
 check("buyer cap",max_buyers<=3)
 var finances=scene.ui.get_children().filter(func(c):return c is Button and c.text=="Finances")[0]
 await press(finances);await frames(4);await view("b8-"+strategy+"-terminal-finances");await dismiss_dialog()
 process_frame.disconnect(watch);process_frame.disconnect(track)
 var mode="retina" if retina else "headless" if DisplayServer.get_name()=="headless" else "normal"
 var f=FileAccess.open("res://evidence/b8-"+strategy+"-"+mode+".json",FileAccess.WRITE)
 f.store_string(JSON.stringify({"strategy":strategy,"mode":mode,"pace_days_1_6":pace,"time_scale_other":3,"setup":"New week via controls only","checks":results,"days":day_metrics,"snapshots":snapshots,"actions":actions,"telemetry":telemetry,"capture_times":capture_times,"motion":week_motion,"final":scene.state.business_report(),"terminal":scene.state.data.terminal},"  "));f.close()
 print("B8_SCENE ",strategy," ",scene.state.data.cash);quit(0)
