extends "res://scripts/test_encounter.gd"
func check(name,ok):
 results.append({"check":name,"pass":ok})
 if not ok:
  var out=FileAccess.open("res://evidence/wave-scene-failure.json",FileAccess.WRITE);out.store_string(JSON.stringify(results,"  "));out.close()
  push_error(name);quit(1)
var overlap=false
var fixture_collision=false
var invariant_failure=false
func observe():
 var active=scene.visitors.values().filter(func(v):return v.actor.visible)
 for v in active:
  for b in scene.BLOCKS:
   if b.has_point(v.actor.position):fixture_collision=true
  for other in active:
   if v!=other and v.actor.position.distance_to(other.actor.position)<59:overlap=true
 if not scene.state.valid():invariant_failure=true
func wait_until(predicate,limit=1800):
 for i in range(limit):
  await process_frame;observe()
  if predicate.call():return true
 print("R4_TIMEOUT ",JSON.stringify(scene.state.data))
 return false
func reload_stage(name):
 scene.set_process(false)
 var before=scene.state.data.duplicate(true)
 await key(KEY_K);await key(KEY_L)
 check("scene reload "+name,scene.state.valid() and scene.state.data.decisions==before.decisions and scene.state.data.queue==before.queue and is_equal_approx(scene.state.data.clock,before.clock) and scene.state.data.customers.keys()==before.customers.keys())
 for id in before.customers:
  check("saved progress "+name+" "+id,scene.state.data.customers[id].state==before.customers[id].state and scene.state.data.customers[id].budget==before.customers[id].budget and is_equal_approx(scene.state.data.customers[id].elapsed,before.customers[id].elapsed))
 scene.set_process(true)
func drain():
 for i in range(2400):
  await process_frame;observe()
  if scene.pending=="" and scene.path.is_empty():
   if scene.selected_action in ["sale","finalize"]:scene.request_action(scene.selected_action)
  if scene.state.data.phase=="report":return true
 print("R4_DRAIN_TIMEOUT ",JSON.stringify(scene.state.data));return false
func run():
 Engine.time_scale=3.0
 root.size=Vector2i(2560,1440) if "--retina" in OS.get_cmdline_user_args() else Vector2i(1280,720)
 scene=load("res://main.tscn").instantiate();root.add_child(scene);scene.save_path="user://wave-scene.json";await frames(5)
 check("R1 fresh UI",scene.state.valid() and scene.details.get_rect().end.y<scene.primary.position.y)
 await view("r4-prep")
 await click_at(Vector2(310,430));await settle()
 scene.price_input.value=0;check("R3 lower price bound",scene.price_input.value==1)
 scene.price_input.value=100;check("R3 upper price bound",is_equal_approx(scene.price_input.value,99.99))
 scene.price_input.value=16.99
 await click_at(Vector2(1080,423));await settle()
 await key(KEY_E);await settle()
 check("three stocked through controls",scene.state.count_at("shelf")==3 and scene.cases[2].visible)
 await view("r4-stocked")
 await click_at(Vector2(780,480));await settle()
 check("first arrival others pending",scene.state.data.customers["visitor-1"].state=="arriving" and scene.state.data.customers["visitor-2"].state=="waiting")
 await reload_stage("arrivals")
 check("visible browsing",await wait_until(func():return scene.state.data.customers["visitor-1"].state=="browsing"))
 await reload_stage("browsing")
 await view("r4-browsing")
 check("three waiting without overlap",await wait_until(func():return scene.state.data.queue.size()==3 and scene.state.data.customers.values().all(func(c):return c.state=="queued" and c.settled)))
 await view("r4-full-queue")
 await reload_stage("queue")
 check("queue UI clear",scene.details.get_rect().end.y<scene.primary.position.y and scene.primary.text.begins_with("Serve "))
 await click_at(Vector2(1080,475));await settle()
 check("closing keeps three reservations",scene.state.data.phase=="closing" and scene.state.data.queue.size()==3 and not scene.state.finalize())
 await reload_stage("closing")
 await view("r4-closing")
 check("closing drains through checkout actions",await drain())
 check("R1 R3 report totals",scene.state.report().sold==3 and scene.state.report().revenue==5097 and scene.state.report().remaining==0 and scene.state.valid())
 await view("r4-all-sold-report")
 check("report geometry",scene.details.get_rect().end.y<scene.primary.position.y)
 await reload_stage("report")
 # No-stock next day via actual advance dialog.
 await click_at(Vector2(1080,423));await frames(3)
 var dialog=scene.ui.get_children().filter(func(c):return c is ConfirmationDialog).back()
 dialog.confirmed.emit();await frames(3)
 await click_at(Vector2(1080,423));await settle()
 check("no stock still admits wave",scene.state.data.phase=="open")
 check("three distinct stock misses",await wait_until(func():return scene.state.report().unavailable==3))
 await view("r4-no-stock")
 scene.request_action("close");await settle();check("empty wave drains",await drain())
 check("no stock report accurate",scene.state.report().unavailable==3 and scene.state.report().missed==0 and scene.state.report().sold==0)
 # Paid next-day replenishment dialog and mixed prices.
 await click_at(Vector2(1080,475));await frames(3)
 dialog=scene.ui.get_children().filter(func(c):return c is ConfirmationDialog).back()
 await view("r4-order")
 dialog.confirmed.emit();await frames(3)
 check("R2 paid two-copy replenishment",scene.state.pending_shipment().quantity==2)
 await reload_stage("paid order")
 await click_at(Vector2(1080,423));await frames(3)
 dialog=scene.ui.get_children().filter(func(c):return c is ConfirmationDialog).back();dialog.confirmed.emit();await frames(3)
 await click_at(Vector2(310,430));await settle()
 scene.price_input.value=21.99
 await click_at(Vector2(1080,423));await settle();await key(KEY_E);await settle()
 check("R2 next day replenishment stocked",scene.state.count_at("shelf")==2 and scene.state.data.day==3)
 await click_at(Vector2(1080,423));await settle()
 # Day 3 budgets: 17.59, 30.78, 27.48. One declines then two buy.
 check("mixed wave one refusal two queues",await wait_until(func():return scene.state.report().missed==1 and scene.state.data.queue.size()==2 and scene.state.data.customers["visitor-2"].settled and scene.state.data.customers["visitor-3"].settled))
 await view("r4-mixed-wave")
 await reload_stage("mixed decisions")
 scene.request_action("close");await settle();check("mixed wave drains",await drain())
 check("mixed report totals",scene.state.report().sold==2 and scene.state.report().missed==1 and scene.state.report().unavailable==0 and scene.state.report().revenue==4398 and scene.state.report().remaining==0)
 await view("r4-mixed-report")
 # Close while first visitor browses: no more arrivals, existing customer may buy.
 scene.perform("reset");scene.perform("receive");scene.price_input.value=16.99;scene.perform("price");scene.perform("stock");scene.perform("open")
 check("closing arrival exists",scene.state.close())
 # At this boundary no process tick occurred, so all three are cancelled.
 check("immediate close cancels all admission",scene.state.can_finalize() and scene.state.finalize())
 scene.perform("reset");scene.perform("receive");scene.perform("price");scene.perform("stock");scene.perform("open")
 await wait_until(func():return scene.state.data.customers["visitor-1"].state=="arriving");scene.state.close()
 await reload_stage("early closing arrival")
 check("early admitted visitor finishes",await drain())
 check("early close one sale",scene.state.report().sold==1 and scene.state.data.customers["visitor-2"].state=="cancelled")
 check("routes avoid fixtures",not fixture_collision)
 check("customers never overlap",not overlap)
 check("state invariants throughout gameplay",not invariant_failure)
 DirAccess.remove_absolute(scene.save_path)
 var suffix="retina" if "--retina" in OS.get_cmdline_user_args() else "normal"
 var out=FileAccess.open("res://evidence/wave-scene-"+suffix+".json",FileAccess.WRITE);out.store_string(JSON.stringify(results,"  "));out.close()
 print("R4_SCENE ",results.size()," checks ",suffix)
 quit(0 if results.all(func(r):return r.pass) else 1)
