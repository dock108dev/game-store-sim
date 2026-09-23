extends "res://scripts/test_encounter.gd"
func check(name,ok):
 results.append({"check":name,"pass":ok})
 if not ok:
  var out=FileAccess.open("res://evidence/assortment-scene-failure.json",FileAccess.WRITE);out.store_string(JSON.stringify(results,"  "));out.close()
  push_error(name);quit(1)
var overlap=false
var fixture_collision=false
var invariant_failure=false
func observe():
 var active=scene.visitors.values().filter(func(v):return v.actor.visible)
 for v in active:
  for b in scene.Layout.obstacles(scene.state.data.layout):
   if b.has_point(v.actor.position):fixture_collision=true
  for other in active:
   if v!=other and v.actor.position.distance_to(other.actor.position)<27:overlap=true
 if not scene.state.valid():invariant_failure=true
func wait_until(predicate,limit=1800):
 for i in range(limit):
  await process_frame;observe()
  if predicate.call():return true
 print("R5_TIMEOUT ",JSON.stringify(scene.state.data))
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
 print("R5_DRAIN_TIMEOUT ",JSON.stringify(scene.state.data));return false
func controls(node, type):
 var found=[]
 for c in node.get_children():
  if is_instance_of(c,type):found.append(c)
  found.append_array(controls(c,type))
 return found
func press(control):
 var vp=control.get_viewport()
 var pos=control.get_global_rect().get_center()
 if vp!=root:pos+=Vector2(vp.position)
 vp=root
 var motion=InputEventMouseMotion.new();motion.position=pos;motion.global_position=pos;vp.push_input(motion,true);await frames(2)
 for down in [true,false]:
  var e=InputEventMouseButton.new();e.position=pos;e.global_position=pos;e.button_index=MOUSE_BUTTON_LEFT;e.pressed=down;vp.push_input(e,true);await frames(2)
func dialog():return scene.ui.get_children().filter(func(c):return c is AcceptDialog).back()
func label_products():
 for n in range(3):
  scene.product_select.select(n);scene.product_select.item_selected.emit(n)
  scene.price_input.value=[21.99,19.99,14.99][n]
  await press(scene.reprice_button);await settle()
  check("selected product priced through controls "+str(n),scene.state.data.items["case-%02d"%(n+1)].price==roundi(scene.price_input.value*100))
func stock_one(n,returning=false):
 await press(scene.assortment_button);await frames(3)
 var d=dialog();var buttons=controls(d,Button).filter(func(b):return b.text==("Return 1" if returning else "Shelf +1"))
 await press(buttons[n]);await settle();await frames(20)
func stock_dialog(omit=""):
 for n in range(3):
  if scene.State.PRODUCTS[n]!=omit:await stock_one(n)
 await press(scene.assortment_button);await frames(3);await view("r5-assortment")
 await press(dialog().get_ok_button());await frames(3)
func run():
 Engine.time_scale=3.0
 root.size=Vector2i(2560,1440) if "--retina" in OS.get_cmdline_user_args() else Vector2i(1280,720)
 scene=load("res://main.tscn").instantiate();root.add_child(scene);scene.save_path="user://assortment-scene.json";await frames(5)
 await view("r5-prep")
 await click_at(Vector2(310,430));await settle()
 check("actual receiving",scene.state.data.received)
 await label_products();await stock_dialog()
 check("mixed labels and shelf through controls",scene.state.count_at("shelf")==3 and scene.state.data.items["case-02"].price==1999)
 await reload_stage("stocking")
 await view("r5-stocked")
 await press(scene.primary);await settle()
 check("staggered first arrival",scene.state.data.customers["visitor-1"].state=="arriving")
 await reload_stage("arrival")
 check("visible selection",await wait_until(func():return scene.state.data.customers["visitor-1"].state=="selected"))
 await reload_stage("selection")
 await view("r5-selection")
 check("three products queued",await wait_until(func():return scene.state.data.queue.size()==3 and scene.state.data.customers.values().all(func(c):return c.state=="queued" and c.settled)))
 await view("r5-queue")
 check("queue readable",scene.details.get_rect().end.y<scene.primary.position.y)
 await press(scene.close_button);await settle();await reload_stage("closing")
 check("closing retains queue",scene.state.data.queue.size()==3 and not scene.state.finalize())
 check("checkout drains",await drain())
 check("mixed product totals",scene.state.report().sold==3 and scene.state.report().revenue==5697 and scene.state.report().cost==2500)
 await view("r5-report");await reload_stage("report")
 await press(scene.assortment_button);await frames(3);await view("r5-product-report");await press(dialog().get_ok_button());await frames(3)
 await press(scene.order_button);await frames(3)
 var d=dialog();var fields=controls(d,SpinBox)
 # Numeric fields and confirmation are the real dialog; enter six total copies.
 for field in fields:field.value=2
 await view("r5-order")
 await press(d.get_ok_button());await frames(3)
 check("mixed order through dialog",scene.state.pending_shipment().quantity==6 and scene.state.data.cash==55697)
 await reload_stage("ordering")
 await press(scene.primary);await frames(3);await press(dialog().get_ok_button());await frames(3)
 await click_at(Vector2(310,430));await settle();await label_products()
 await stock_one(0);await stock_one(0);await stock_one(1);await stock_one(1)
 await press(scene.assortment_button);await frames(3);d=dialog()
 var adds=controls(d,Button).filter(func(b):return b.text=="Shelf +1")
 check("four spaces enforce overflow",scene.state.shelf_used()==4 and scene.state.count_at("backroom")==2 and adds[2].disabled)
 await press(d.get_ok_button());await frames(3)
 await stock_one(0,true);await stock_one(2)
 check("return changes assortment",scene.state.count_at("shelf","curb")==1 and scene.state.count_at("shelf","orbit")==1 and scene.state.shelf_used()==4)
 await view("r5-overflow");await reload_stage("day2 assortment")
 await press(scene.primary);await settle()
 check("day2 decisions",await wait_until(func():return scene.state.data.decisions.size()==6))
 scene.request_action("close");await settle();check("day2 drains",await drain())
 check("two day ledger",scene.state.report().sold==2 and scene.state.report().missed==1 and scene.state.report().revenue==4198 and scene.state.data.cash==59895 and scene.state.valid())
 await view("r5-day2-report")
 scene.perform("reset");scene.perform("receive");await label_products();await stock_dialog("orbit")
 await press(scene.primary);await settle()
 check("sought item missing",await wait_until(func():return scene.state.report("orbit").unavailable==1))
 await view("r5-unavailable");scene.request_action("close");await settle();check("missing shift drains",await drain())
 check("comparison leaves one unavailable",scene.state.report().sold==2 and scene.state.report().revenue==4198 and scene.state.report().unavailable==1 and scene.state.report().missed==0)
 await view("r5-missing-report")
 scene.perform("reset");scene.perform("receive")
 for n in range(3):
  scene.selected_product=scene.State.PRODUCTS[n];scene.price_input.value=float(scene.State.CATALOG[scene.selected_product].reference)/100;scene.perform("reprice");scene.request_action("stock");await settle();await frames(20)
 scene.perform("open")
 check("product price refusal",await wait_until(func():return scene.state.report("tide").missed==1))
 await view("r5-price-refusal");scene.request_action("close");await settle();check("refusal drains",await drain())
 check("routes avoid fixtures",not fixture_collision)
 check("customers never overlap",not overlap)
 check("invariants throughout gameplay",not invariant_failure)
 var suffix="retina" if "--retina" in OS.get_cmdline_user_args() else "normal"
 var out=FileAccess.open("res://evidence/assortment-scene-"+suffix+".json",FileAccess.WRITE);out.store_string(JSON.stringify(results,"  "));out.close()
 print("R5_SCENE ",results.size()," checks ",suffix);quit(0 if results.all(func(r):return r.pass) else 1)

func view(name):
 if DisplayServer.get_name()=="headless":return
 RenderingServer.force_draw()
 var suffix="retina" if "--retina" in OS.get_cmdline_user_args() else "normal"
 root.get_texture().get_image().save_png("res://evidence/"+name+"-"+suffix+".png")
