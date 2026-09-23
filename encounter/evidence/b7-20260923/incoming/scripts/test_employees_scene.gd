extends "res://scripts/test_layout_scene.gd"
var worker_distances={}
var worker_last={}
var b4_motion=[]
var b4_frame=0
func inspect_workers():
 if not is_instance_valid(scene):return
 b4_frame+=1
 var positions={}
 for id in scene.workers:
  var w=scene.workers[id]
  if not w.actor.visible:worker_last.erase(id);continue
  positions[id]=[w.actor.position.x,w.actor.position.y]
  if worker_last.has(id):worker_distances[id]=worker_distances.get(id,0.0)+w.actor.position.distance_to(worker_last[id])
  worker_last[id]=w.actor.position
  for b in scene.Layout.obstacles(scene.state.data.layout):
   if b.grow(11).has_point(w.actor.position):fixture_collision=true
 var bodies=scene.bodies()
 for a in bodies:
  for b in bodies:
   if a!=b and a.position.distance_to(b.position)<27:overlap=true
 if b4_frame%5==0:
  b4_motion.append({"frame":b4_frame,"workers":positions,"player":[scene.player.position.x,scene.player.position.y],"customers":scene.state.data.customers.duplicate(true),"jobs":scene.state.data.jobs.duplicate(true),"cash":scene.state.data.cash})
  if record_frames:
   RenderingServer.force_draw();root.get_texture().get_image().save_png(movie_dir+"/%05d.png"%movie_number);movie_number+=1
func staff_role(id,index):
 await press(scene.staff_button);await frames(3)
 var opts=controls(dialog(),OptionButton)
 var option=opts[scene.State.Staff.IDS.find(id)]
 option.select(index);option.item_selected.emit(index);await frames(3)
 await press(dialog().get_ok_button());await frames(3)
 check("role control "+id+" "+str(index),scene.state.data.staff[id].role==scene.State.Staff.ROLES[index])
func hire_control(id):
 await press(scene.staff_button);await frames(3)
 var rows=controls(dialog(),HBoxContainer)
 var row=rows[scene.State.Staff.IDS.find(id)]
 await press(controls(row,Button).filter(func(b):return b.text=="Hire · $12 today")[0]);await frames(3)
 await press(dialog().get_ok_button());await frames(3)
 await press(dialog().get_ok_button());await frames(3)
 check("confirmed hire "+id,scene.state.data.staff[id].employed)
func run():
 Engine.time_scale=3.0
 var retina="--retina" in OS.get_cmdline_user_args()
 root.size=Vector2i(2560,1440) if retina else Vector2i(1280,720)
 scene=load("res://main.tscn").instantiate();root.add_child(scene);scene.save_path="user://b4-scene.json";await frames(5)
 record_frames=DisplayServer.get_name()!="headless" and not retina
 movie_dir="res://evidence/frames/b4"
 if record_frames:DirAccess.make_dir_recursive_absolute(movie_dir)
 process_frame.connect(inspect_workers)
 for expanded in [false,true]:
  worker_last.clear()
  scene.set_process(false);scene.state.data.phase="prep";scene.state.reset();scene.state.receive()
  # Synthetic setup only: empty state-command days unlock the relevant slice.
  while scene.state.data.day<(5 if expanded else 3):
   scene.state.open();scene.state.close();scene.state.finalize();scene.state.advance(scene.state.data.day)
  scene.restore_view();scene.player.position=scene.Layout.SPAWN;scene.refresh();scene.set_process(true);await frames(3)
  if expanded:
   await press(scene.expand_button);await key(KEY_ENTER);await frames(3)
   check("ordinary north bay purchase",scene.state.data.layout.space_level==1)
  await label_products()
  await click_at(Vector2(410,550));await settle()
  await hire_control("morgan");await hire_control("jules")
  await staff_role("morgan",1);await staff_role("jules",1)
  if not expanded:
   check("unfinished worker claim available",await wait_until(func():return not scene.State.Staff.active(scene.state.data).is_empty()))
   # Paused snapshot boundary is an isolated restoration probe, not owner play.
   scene.set_process(false)
   var copies=scene.state.data.items.duplicate(true);var wages=scene.state.data.wage_commitments.duplicate(true)
   await press(scene.save_button);await press(scene.load_button)
   check("unfinished reload preserves copies wages and releases jobs",scene.state.data.items==copies and scene.state.data.wage_commitments==wages and scene.State.Staff.active(scene.state.data).is_empty())
   scene.set_process(true)
   check("restored workers reassign",await wait_until(func():return not scene.State.Staff.job(scene.state.data,"morgan").is_empty()))
   scene.set_process(false)
   var positions=[scene.workers.morgan.actor.position,scene.workers.jules.actor.position]
   await press(scene.arrange_button);await frames(20)
   check("layout pauses workers and releases unfinished claims",not scene.draft.is_empty() and scene.State.Staff.active(scene.state.data).is_empty() and positions==[scene.workers.morgan.actor.position,scene.workers.jules.actor.position])
   await key(KEY_ESCAPE);scene.set_process(true)
   check("workers resume after layout cancel",await wait_until(func():return not scene.State.Staff.job(scene.state.data,"morgan").is_empty()))
   scene.set_process(false)
   await press(scene.staff_button);await frames(3)
   var takes=controls(dialog(),Button).filter(func(b):return b.text=="Take over")
   await press(takes[0]);await frames(3)
   check("explicit takeover control transfers unfinished job",not scene.State.Staff.job(scene.state.data,"player").is_empty())
   await view("b4-takeover")
   scene.set_process(true);await settle();await frames(20)
   check("player takeover completed through receiving and shelf travel",scene.state.data.jobs.any(func(j):return j.actor=="player" and j.kind=="stock" and j.status=="committed" and j.received))
   await click_at(Vector2(410,550));await settle()
  check("both workers physically stock",await wait_until(func():return scene.state.data.jobs.any(func(j):return j.actor=="morgan" and j.kind=="stock" and j.status=="committed") and scene.state.data.jobs.any(func(j):return j.actor=="jules" and j.kind=="stock" and j.status=="committed"),2400))
  check("fill available shelf through workers",await wait_until(func():return scene.state.count_at("shelf")== (6 if expanded else 4),2400))
  await view("b4-stocked-"+str(expanded))
  await staff_role("morgan",2);await staff_role("jules",0)
  await press(scene.primary);await frames(3)
  check("paid idle opening warning",dialog().title=="Paid idle employees")
  await press(dialog().get_ok_button());await settle()
  await click_at(Vector2(410,550));await settle()
  check("Morgan useful checkout",await wait_until(func():return scene.state.data.jobs.any(func(j):return j.actor=="morgan" and j.kind=="sale" and j.status=="committed"),2400))
  await staff_role("morgan",0);await staff_role("jules",2)
  check("Jules useful checkout",await wait_until(func():return scene.state.data.jobs.any(func(j):return j.actor=="jules" and j.kind=="sale" and j.status=="committed"),2400))
  await view("b4-checkout-"+str(expanded))
  await press(scene.close_button);await settle();await click_at(Vector2(410,550));await settle()
  check("checkout drains on close",await wait_until(func():return scene.state.can_finalize(),2400))
  await press(scene.primary);await settle()
  check("employment wage settlement",scene.state.business_report(scene.state.data.day).paid_overhead==2400 and scene.state.valid())
  await view("b4-report-"+str(expanded))
  await reload_stage("employee report")
 # Synthetic route fault: navigation marks a required port blocked, without editing business state.
 record_frames=false;worker_last.clear();scene.set_process(false)
 scene.state.data.phase="prep";scene.state.reset();scene.state.receive()
 for day in [1,2]:scene.state.open();scene.state.close();scene.state.finalize();scene.state.advance(day)
 scene.state.hire("morgan");scene.state.assign("morgan","stocking");scene.state.price(1000)
 scene.restore_view();scene.player.position=Vector2(410,550);scene.refresh();scene.update_workers(0)
 scene.nav.set_point_solid(Vector2i(37,45),true);scene.set_process(true);await frames(100)
 check("blocked receiving never commits remotely",scene.state.count_at("shelf")==0 and not scene.State.Staff.job(scene.state.data,"morgan").received and "Waiting" in scene.workers.morgan.status)
 scene.nav=scene.Layout.navigation(scene.state.data.layout)
 check("route recovery completes useful work",await wait_until(func():return scene.state.count_at("shelf")>0))
 # Synthetic restored buyer at receiving: workers must choose a separated spawn.
 scene.set_process(false);scene.state.open();scene.state.tick(10);scene.state.arrive("visitor-1")
 scene.state.data.customers["visitor-1"].position=[380,450]
 check("restoration probe save",scene.state.save_to(scene.save_path) and scene.state.load_from(scene.save_path))
 scene.restore_view();scene.update_workers(0)
 var restored_bodies=scene.bodies()
 check("restored customer visible before employee spawn",scene.visitors["visitor-1"].actor.visible and restored_bodies.all(func(a):return restored_bodies.all(func(b):return a==b or a.position.distance_to(b.position)>=28)))
 scene.player.position=scene.Layout.ENTRY;scene.update_wave(0)
 check("occupied entrance delays customer spawn",scene.state.data.customers["visitor-2"].state=="waiting")
 check("workers moved",worker_distances.size()==2 and worker_distances.values().all(func(d):return d>400))
 check("no actor overlap",not overlap)
 check("worker fixture clearance",not fixture_collision)
 check("state invariants",not invariant_failure)
 record_frames=false;process_frame.disconnect(inspect_workers)
 var suffix="retina" if retina else "normal"
 var f=FileAccess.open("res://evidence/employees-scene-"+suffix+".json",FileAccess.WRITE);f.store_string(JSON.stringify({"checks":results,"distances":worker_distances,"frames":movie_number},"  "));f.close()
 f=FileAccess.open("res://evidence/employees-motion-"+suffix+".json",FileAccess.WRITE);f.store_string(JSON.stringify(b4_motion));f.close()
 print("B4_SCENE ",results.size()," checks");quit(0)

func label_products():
 for n in range(3):
  scene.product_select.select(n);scene.product_select.item_selected.emit(n);scene.price_input.value=10.0
  await press(scene.reprice_button);await settle()
  check("ordinary $10 label "+str(n),scene.state.data.items["case-%02d"%(n+1)].price==1000)
