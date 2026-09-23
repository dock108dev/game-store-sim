extends "res://scripts/test_employees_scene.gd"
var week_motion=[]
var snapshots=[]
var sample=0
var max_buyers=0
var week_failed=false
var header_overlap=false
func check(name,ok):
 results.append({"check":name,"pass":ok})
 if not ok:
  week_failed=true
  var f=FileAccess.open("res://evidence/week-scene-failure.json",FileAccess.WRITE);f.store_string(JSON.stringify({"checks":results,"state":scene.state.data if is_instance_valid(scene) else {},"trace":week_motion.slice(-40)},"  "));f.close()
  push_error(name);quit(1)
func watch():
 if not is_instance_valid(scene):return
 sample+=1
 if scene.order_button.visible and [scene.bills_label,scene.shelf_label,scene.summary].any(func(label):return scene.order_button.get_global_rect().intersects(label.get_global_rect())):header_overlap=true
 var bodies=scene.bodies()
 for a in bodies:
  for b in bodies:
   if a!=b and a.position.distance_to(b.position)<27:overlap=true
  for obstacle in scene.Layout.obstacles(scene.state.data.layout):
   if obstacle.grow(11).has_point(a.position):fixture_collision=true
 max_buyers=maxi(max_buyers,scene.visitors.values().filter(func(v):return v.actor.visible).size())
 if sample%15==0:
  if not scene.state.valid():invariant_failure=true
  var actors={}
  for id in scene.visitors:
   if scene.visitors[id].actor.visible:actors[id]=[scene.visitors[id].actor.position.x,scene.visitors[id].actor.position.y]
  for id in scene.workers:
   if scene.workers[id].actor.visible:actors[id]=[scene.workers[id].actor.position.x,scene.workers[id].actor.position.y]
  if scene.seller_view.actor.visible:actors.seller=[scene.seller_view.actor.position.x,scene.seller_view.actor.position.y]
  week_motion.append({"frame":sample,"day":scene.state.data.day,"phase":scene.state.data.phase,"clock":scene.state.data.clock,"actors":actors,"player":[scene.player.position.x,scene.player.position.y],"cash":scene.state.data.cash,"sold":scene.state.data.sales.size(),"jobs":scene.state.data.jobs.size()})
  if record_frames:
   RenderingServer.force_draw();root.get_texture().get_image().save_png(movie_dir+"/%05d.png"%movie_number);movie_number+=1
func named(text):return controls(dialog(),Button).filter(func(b):return b.visible and b.text.begins_with(text))[0]
func dismiss_dialog():
 await press(dialog().get_ok_button());await frames(4)
func advance_control():
 await press(scene.primary);await frames(3);await dismiss_dialog();await frames(4)
func label_week():
 for n in range(5):
  var p=scene.State.PRODUCTS[n]
  if not scene.State.Week.released(p,scene.state.data.day):continue
  scene.product_select.select(n);scene.product_select.item_selected.emit(n)
  scene.price_input.value=float(scene.State.CATALOG[p].reference)/100
  await press(scene.reprice_button);await settle()
 # Used rows come first, each current unsold copy gets its own reference label.
 var used=scene.state.data.items.values().filter(func(i):return i.kind=="used" and i.location=="backroom" and i.available_day<=scene.state.data.day and i.price==0)
 for i in used:
  await press(scene.copies_button);await frames(4);await view("b6-used-label-day"+str(scene.state.data.day));await press(named("Label"));await settle()
func order_control(q):
 await press(scene.order_button);await frames(4)
 var fields=controls(dialog(),SpinBox)
 for n in range(5):fields[n].value=q[n]
 await view("b6-order-day"+str(scene.state.data.day))
 var cash=scene.state.data.cash
 await press(dialog().get_ok_button());await frames(4)
 check("paid same-prep supplier control",scene.state.data.cash<cash and not scene.state.pending_shipment().is_empty() and scene.state.data.phase=="prep")
 await reload_stage("paid order day "+str(scene.state.data.day))
 await press(scene.primary);await settle();check("same-day receiving control",scene.state.pending_shipment().is_empty())
func player_stock_all():
 for p in range(3):
  for n in range(2):
   var slot=scene.state.free_slot()
   var index=scene.Layout.racks(scene.state.data.layout).find(slot.fixture_id)
   scene.rack_select.select(index);scene.rack_select.item_selected.emit(index)
   await stock_one(p)
func seller_control():
 await press(scene.seller_button);await settle();await frames(4)
 await view("b6-seller-day"+str(scene.state.data.day))
 if scene.state.data.day==7:
  await press(named("Refuse seller"));await frames(4)
 else:
  controls(dialog(),SpinBox)[0].value=1
  await press(named("Send initial"));await frames(4)
  check("seller ordinary disclosed floor",scene.state.seller().status=="counter")
  await press(named("Accept counter"));await frames(4)
  await press(named("Confirm purchase"));await frames(4)
  check("seller ordinary exact payment",scene.state.seller().status=="completed")
 await click_at(Vector2(410,550));await settle()
func run_day():
 await press(scene.primary);await settle();await frames(4)
 if scene.state.data.phase=="prep":await dismiss_dialog();await settle()
 await click_at(Vector2(410,550));await settle()
 var seller_done=scene.state.data.day==1
 var resumed=false
 for i in range(5500):
  await process_frame
  if not seller_done and scene.state.seller().status=="ready" and scene.pending=="":
   await seller_control();seller_done=true
  if scene.state.data.day<3 and scene.selected_action=="sale" and scene.pending=="" and scene.path.is_empty():
   await press(scene.primary);await settle();await click_at(Vector2(410,550));await settle()
  if not resumed and scene.state.data.day==4 and scene.state.data.sales.any(func(s):return s.day==4):
   await reload_stage("live release-day progress");await click_at(Vector2(410,550));await settle();resumed=true
  if scene.state.data.customers.values().all(func(c):return c.state=="gone") and seller_done and (scene.state.seller().is_empty() or scene.state.seller().motion=="gone"):break
 check("all authored arrivals physically drain day "+str(scene.state.data.day),scene.state.data.customers.values().all(func(c):return c.state=="gone"))
 await view("b6-drained-day"+str(scene.state.data.day))
 await press(scene.close_button);await settle()
 check("floor job seller drain",await wait_until(func():return scene.state.can_finalize(),1800))
 await press(scene.primary);await settle();await frames(4)
 check("daily close valid",scene.state.valid() and scene.state.data.phase in ["report","week_complete"])
 snapshots.append(scene.state.data.duplicate(true));await view("b6-report-day"+str(scene.state.data.day));await reload_stage("closed day "+str(scene.state.data.day))
func run():
 Engine.time_scale=3.0
 var retina="--retina" in OS.get_cmdline_user_args()
 root.size=Vector2i(2560,1440) if retina else Vector2i(1280,720)
 scene=load("res://main.tscn").instantiate();root.add_child(scene);scene.save_path="user://b7-week-"+str(Time.get_ticks_usec())+".json";scene.state.checkpoint_path=scene.save_path;await frames(5)
 await enter_week()
 record_frames=DisplayServer.get_name()!="headless" and not retina;movie_dir="res://evidence/frames/b6"
 if record_frames:DirAccess.make_dir_recursive_absolute(movie_dir)
 process_frame.connect(watch)
 check("additional appearances constructed before ready",[3,4,5].all(func(n):return scene.visitors.values()[n].actor.rigs.front.get_node("head").get_child_count()==2))
 await view("b6-fresh")
 # Calendar, supplier, fields, player movement and buttons use ordinary UI input.
 var calendar=scene.ui.get_children().filter(func(c):return c is Button and c.text=="Release calendar")[0]
 await press(calendar);await frames(4);await view("b6-calendar");await dismiss_dialog()
 check("release dropdown disabled day1",scene.product_select.is_item_disabled(3) and scene.product_select.is_item_disabled(4))
 await press(scene.primary);await settle()
 await press(scene.buy_button);await key(KEY_ENTER);await frames(5)
 check("ordinary second rack",scene.state.capacity()==8)
 for day in range(1,8):
  if day==3:await hire_control("morgan")
  if day==6:await hire_control("jules")
  if day==5:await press(scene.expand_button);await key(KEY_ENTER);await frames(4)
  if day in [3,5,7]:await order_control([1,1,1,0,0])
  if day==4:await order_control([1,1,1,2,0])
  if day==6:await order_control([1,1,1,2,2])
  await label_week()
  if day==1:await player_stock_all()
  if day>=3:
   await click_at(Vector2(410,550));await settle();await staff_role("morgan",1)
   if day>=6:await staff_role("jules",1)
   check("workers stock released and mixed copies",await wait_until(func():return scene.state.data.items.values().all(func(i):return i.location!="backroom" or i.available_day>day),3600))
   await staff_role("morgan",2)
   if day>=6:await staff_role("jules",2)
  await view("b6-stocked-day"+str(day))
  check("release boundary control day "+str(day),scene.product_select.is_item_disabled(3)==(day<4) and scene.product_select.is_item_disabled(4)==(day<6))
  await run_day()
  if day<7:await advance_control()
 check("supplier leaves bills capacity and cash readable",not header_overlap)
 check("technical week terminal",scene.state.data.phase=="week_complete")
 check("cash ledger inventory reconcile",scene.state.business_report().cash==scene.state.data.cash and scene.state.business_report().inventory_cost==scene.state.data.items.values().filter(func(i):return i.location!="sold").reduce(func(total,i):return total+i.cost,0))
 check("three buyer active cap",max_buyers<=3)
 check("all actor separation",not overlap)
 check("fixture clearance",not fixture_collision)
 check("continuous state validity",not invariant_failure)
 check("five-title sales",scene.State.PRODUCTS.all(func(p):return scene.state.data.sales.any(func(s):return s.product==p)))
 check("used staff sales",scene.state.data.jobs.any(func(j):return j.actor=="morgan" and j.kind=="sale" and j.status=="committed" and scene.state.data.items[j.copy].kind=="used"))
 process_frame.disconnect(watch);record_frames=false
 var suffix="retina" if retina else "headless" if DisplayServer.get_name()=="headless" else "normal"
 var f=FileAccess.open("res://evidence/week-scene-"+suffix+".json",FileAccess.WRITE);f.store_string(JSON.stringify({"checks":results,"days":snapshots,"max_buyers":max_buyers,"frames":movie_number},"  "));f.close()
 f=FileAccess.open("res://evidence/week-motion-"+suffix+".json",FileAccess.WRITE);f.store_string(JSON.stringify(week_motion));f.close()
 print("B6_SCENE ",results.size()," cash ",scene.state.data.cash);quit(0)

func settle():
 for i in range(1600):
  await process_frame
  if scene.pending=="" and scene.path.is_empty() and not scene.floor_walk:return
 check("action route finishes",false)

func press(control):
 # Native-window replays can lose a synthetic click during focus changes.
 # Observe actual button activation, retry bounded UI input, never emit the action.
 var activations=[0]
 var witness=func():activations[0]+=1
 control.pressed.connect(witness)
 for attempt in range(3):
  var vp=control.get_viewport()
  var pos=control.get_global_rect().get_center()
  if vp!=root:pos+=Vector2(vp.position)
  var motion=InputEventMouseMotion.new();motion.position=pos;motion.global_position=pos;root.push_input(motion,true)
  for down in [true,false]:
   var event=InputEventMouseButton.new();event.position=pos;event.global_position=pos;event.button_index=MOUSE_BUTTON_LEFT;event.pressed=down;root.push_input(event,true)
  await frames(3)
  if activations[0]>0:break
  if not is_instance_valid(control):break
 if is_instance_valid(control):control.pressed.disconnect(witness)
 check("ordinary button activated "+str(control.text) if is_instance_valid(control) else "ordinary button activated (closed dialog)",activations[0]>0)

func enter_week():
 var buttons=controls(scene.entry_menu,Button)
 await press(scene.entry_menu.get_meta("new_button"));await frames(4)
