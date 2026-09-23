extends "res://scripts/test_employees_scene.gd"
var b5_trace=[]
var b5_frame=0
var seller_distance=0.0
var seller_last=Vector2.ZERO
var have_seller=false
var outcomes=[]
var interface_overlap=false
func inspect_used():
 if not is_instance_valid(scene):return
 b5_frame+=1
 if scene.seller_button.get_rect().end.x>scene.stock_button.position.x:interface_overlap=true
 var bodies=scene.bodies()
 for a in bodies:
  for b in bodies:
   if a!=b and a.position.distance_to(b.position)<27:overlap=true
  for obstacle in scene.Layout.obstacles(scene.state.data.layout):
   if obstacle.grow(11).has_point(a.position):fixture_collision=true
 var a=scene.seller_view.actor
 if a.visible:
  if have_seller:seller_distance+=seller_last.distance_to(a.position)
  have_seller=true;seller_last=a.position
 else:have_seller=false
 if not scene.state.valid():invariant_failure=true
 if b5_frame%5==0:
  var positions={}
  for id in scene.workers:
   var w=scene.workers[id]
   if w.actor.visible:positions[id]=[w.actor.position.x,w.actor.position.y]
  b5_trace.append({"frame":b5_frame,"day":scene.state.data.day,"phase":scene.state.data.phase,"seller":scene.state.seller().duplicate(true),"workers":positions,"player":[scene.player.position.x,scene.player.position.y],"customers":scene.state.data.customers.duplicate(true),"jobs":scene.state.data.jobs.duplicate(true),"sales":scene.state.data.sales.duplicate(true),"cash":scene.state.data.cash})
  if record_frames:
   RenderingServer.force_draw();root.get_texture().get_image().save_png(movie_dir+"/%05d.png"%movie_number);movie_number+=1
func named(text):return controls(dialog(),Button).filter(func(b):return b.text.begins_with(text))[0]
func used_label(expanded=false):
 await press(scene.copies_button);await frames(3)
 check("used individual labels visible",dialog().title=="Individual copies · labels and provenance")
 if expanded:controls(dialog(),SpinBox)[0].value=10.0
 await frames(3)
 await view("b5-copy-labels")
 await press(named("Label"));await settle();await frames(3)
func used_stock():
 await press(scene.copies_button);await frames(3);await press(named("Shelf +1"));await settle();await frames(10)
func close_day():
 await press(scene.close_button);await settle();await click_at(Vector2(410,550));await settle()
 check("seller buyer worker close drains",await wait_until(func():return scene.state.can_finalize(),3000))
 await press(scene.primary);await settle();await frames(5)
 check("report valid",scene.state.data.phase=="report" and scene.state.valid())
func run():
 Engine.time_scale=3.0
 var retina="--retina" in OS.get_cmdline_user_args()
 root.size=Vector2i(2560,1440) if retina else Vector2i(1280,720)
 scene=load("res://main.tscn").instantiate();root.add_child(scene);scene.save_path="user://b5-scene.json";await frames(5)
 record_frames=DisplayServer.get_name()!="headless" and not retina;movie_dir="res://evidence/frames/b5"
 if record_frames:DirAccess.make_dir_recursive_absolute(movie_dir)
 process_frame.connect(inspect_used)
 for expanded in [false,true]:
  scene.set_process(false);scene.state.data.phase="prep";scene.state.reset();scene.state.receive()
  # Synthetic empty-day prelude unlocks day 2/day 5; the trading loop below uses controls.
  while scene.state.data.day<(5 if expanded else 2):scene.state.open();scene.state.close();scene.state.finalize();scene.state.advance(scene.state.data.day)
  scene.restore_view();scene.player.position=scene.Layout.SPAWN;scene.refresh();scene.set_process(true);await frames(3)
  if expanded:await press(scene.expand_button);await key(KEY_ENTER);await frames(3)
  await press(scene.primary);await settle();await click_at(Vector2(410,550));await settle()
  check("seller physically arrives at separate intake",await wait_until(func():return scene.state.seller().status=="ready",3000))
  check("seller never joins buyer queue",not scene.state.data.queue.has(scene.state.seller().id) and scene.seller_view.actor.position==Vector2(850,420))
  await view("b5-intake-"+str(expanded))
  await press(scene.seller_button);await settle();await frames(5)
  check("Rowan physically inspects",scene.player.position==Vector2(810,420) and scene.state.seller().inspected)
  await view("b5-inspect-"+str(expanded))
  var row=scene.state.seller();var amount=int(row.asking)
  if expanded:
   controls(dialog(),SpinBox)[0].value=1
   await press(named("Send initial"));await frames(5)
   check("ordinary counter disclosure",row.status=="counter" and row.offers==[100])
   await view("b5-counter")
   await press(dialog().get_ok_button());await frames(3)
   # Explicit save/reload at disclosed counter, with simulation paused for a stable comparison.
   scene.set_process(false);var terms=row.duplicate(true)
   await press(scene.save_button);await press(scene.load_button)
   check("counter reload exact terms and progress",scene.state.seller()==terms)
   scene.set_process(true);await press(scene.seller_button);await settle();await frames(5)
   await press(named("Accept counter"));await frames(5);amount=int(scene.state.seller().floor)
  else:
   await press(named("Send initial"));await frames(5)
  check("accepted requires separate payment",scene.state.seller().status=="accepted" and scene.state.data.items.size()==6)
  await view("b5-accepted-"+str(expanded))
  var before=scene.state.data.cash
  await press(named("Confirm purchase"));await frames(10)
  var id="used:"+scene.state.data.run_id+":"+str(int(scene.state.data.day))+":1"
  check("ordinary purchase exact debit and one copy",scene.state.data.cash==before-amount and scene.state.data.items[id].cost==amount and scene.state.data.items[id].price==0)
  await click_at(Vector2(410,550));await settle()
  check("completed seller walks out",await wait_until(func():return scene.state.seller().motion=="gone",3000))
  await close_day();await view("b5-purchase-report-"+str(expanded))
  check("purchase report distinguishes spending from margin",scene.state.business_report(scene.state.data.day).inventory_purchases==amount and scene.state.report().cost==0 and scene.state.report().margin==0)
  await press(scene.primary);await frames(3);await press(dialog().get_ok_button());await frames(5)
  await hire_control("morgan");await hire_control("jules")
  await used_label(expanded)
  check("new price summary excludes used label",scene.details.text.begins_with("New Unpriced") and scene.state.data.items["case-01"].price==0)
  var resale=int(scene.state.data.items[id].price)
  check("explicit condition label chosen through controls",resale==(1000 if expanded else 1759))
  if not expanded:
   await used_stock()
   check("Rowan stocks exact used copy",scene.state.data.items[id].location=="shelf" and scene.state.data.jobs.any(func(j):return j.actor=="player" and j.copy==id and j.kind=="stock" and j.status=="committed"))
  else:
   await click_at(Vector2(410,550));await settle();await staff_role("morgan",1);await staff_role("jules",1)
   check("workers stock one used copy with exclusive claim",await wait_until(func():return scene.state.data.items[id].location=="shelf",2400))
   check("single used stock commit",scene.state.data.jobs.filter(func(j):return j.copy==id and j.kind=="stock" and j.status=="committed").size()==1)
  await view("b5-used-stocked-"+str(expanded))
  await staff_role("morgan",2 if not expanded else 0);await staff_role("jules",2 if not expanded else 0)
  await press(scene.primary);await frames(3)
  if expanded:await press(dialog().get_ok_button())
  await settle();await click_at(Vector2(410,550));await settle()
  if expanded:
   check("used fixed-price buyer queues",await wait_until(func():return not scene.state.data.queue.is_empty() and scene.state.data.customers[scene.state.data.queue[0]].settled,2400))
   await view("b5-fixed-checkout")
   await press(scene.primary);await settle();await click_at(Vector2(410,550));await settle()
  check("fixed-price used sale",await wait_until(func():return scene.state.data.items[id].location=="sold",2400))
  check("actual cost survives resale",scene.state.data.sales.back().item==id and scene.state.data.sales.back().cost==amount and scene.state.data.sales.back().price==resale)
  check("sale actor matches ordinary loop",scene.state.data.jobs.any(func(j):return j.copy==id and j.kind=="sale" and j.status=="committed" and (j.actor=="player" if expanded else j.actor in ["morgan","jules"])))
  await close_day();await view("b5-resale-report-"+str(expanded));await reload_stage("used resale report")
  check("report merchandise margin uses acquisition cost",scene.state.report().margin==resale-amount and scene.state.business_report(scene.state.data.day).paid_overhead==2400)
  outcomes.append(scene.state.data.duplicate(true))
 check("seller traveled visibly",seller_distance>1800)
 check("seller status cannot overlap Stock control",not interface_overlap)
 check("all actor separation",not overlap)
 check("all actor fixture clearance",not fixture_collision)
 check("state invariants during ordinary loop",not invariant_failure)
 process_frame.disconnect(inspect_used);record_frames=false
 var suffix="retina" if retina else "normal"
 var f=FileAccess.open("res://evidence/used-scene-"+suffix+".json",FileAccess.WRITE);f.store_string(JSON.stringify({"checks":results,"outcomes":outcomes,"seller_distance":seller_distance,"frames":movie_number},"  "));f.close()
 f=FileAccess.open("res://evidence/used-motion-"+suffix+".json",FileAccess.WRITE);f.store_string(JSON.stringify(b5_trace));f.close()
 print("B5_SCENE ",results.size()," checks");quit(0)
