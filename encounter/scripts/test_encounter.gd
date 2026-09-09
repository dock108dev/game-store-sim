extends SceneTree
var scene
var results=[]
func check(name,ok):
 results.append({"check":name,"pass":ok})
 if not ok:push_error(name)
func frames(n):
 for i in range(n):await process_frame
func click_at(p):
 var e=InputEventMouseButton.new();e.position=p;e.global_position=p;e.button_index=MOUSE_BUTTON_LEFT;e.pressed=true;root.push_input(e,true)
 await process_frame
 e=InputEventMouseButton.new();e.position=p;e.global_position=p;e.button_index=MOUSE_BUTTON_LEFT;e.pressed=false;root.push_input(e,true)
 await frames(3)
func key(k):
 var e=InputEventKey.new();e.keycode=k;e.physical_keycode=k;e.pressed=true;Input.parse_input_event(e);await frames(3)
 e=InputEventKey.new();e.keycode=k;e.physical_keycode=k;e.pressed=false;Input.parse_input_event(e);await frames(3)
func settle():
 for i in range(800):
  await process_frame
  if scene.pending=="" and scene.path.is_empty():return
 check("action route finishes",false)
func _initialize():call_deferred("run")
func view(name):
 if DisplayServer.get_name()=="headless":return
 await RenderingServer.frame_post_draw
 var suffix="retina" if "--retina" in OS.get_cmdline_user_args() else "normal"
 root.get_texture().get_image().save_png("res://evidence/"+name+"-"+suffix+".png")
func run():
 root.size=Vector2i(2560,1440) if "--retina" in OS.get_cmdline_user_args() else Vector2i(1280,720)
 scene=load("res://main.tscn").instantiate();root.add_child(scene);scene.save_path="user://input-test-"+str(Time.get_ticks_usec())+".json";await frames(5)
 await view("fresh")
 check("fresh readable overview",scene.state.valid() and scene.guide.text.begins_with("1 / 7") and scene.details.get_rect().end.y<scene.primary.position.y)
 await click_at(Vector2(310,430));await settle()
 await view("pricing")
 check("world receiving click",scene.state.data.received)
 scene.price_input.value=2199.0/100
 await click_at(Vector2(1080,423));await settle()
 check("price entry stays clear",scene.details.get_rect().end.y<scene.price_input.position.y)
 check("price button input",scene.state.data.items["case-01"].price==2199)
 await key(KEY_E);await settle();await frames(55)
 await view("stocked")
 check("E stocks shelf with two visible cases",scene.state.count_at("shelf")==2 and scene.cases[0].visible and scene.cases[1].visible and not scene.cases[2].visible)
 await click_at(Vector2(780,480));await settle()
 check("counter click opens",scene.state.data.phase=="open")
 var collision=false
 var selected=false
 for i in range(1600):
  await process_frame
  for block in scene.BLOCKS:
   if block.has_point(scene.customer.position):collision=true
  if scene.customer_stage=="to_queue":selected=true
  if scene.customer_stage=="queued":break
 check("customer browses selects routes and queues",selected and scene.customer_stage=="queued" and not collision)
 await view("queued")
 check("reserved shelf depletion",scene.state.count_at("shelf")==1 and not scene.cases[1].visible)
 await key(KEY_K)
 var before=scene.state.data.duplicate(true)
 scene.perform("reset");await key(KEY_L)
 check("queued save reset reload",scene.state.data==before and scene.customer_stage=="queued" and scene.customer.visible)
 await click_at(Vector2(1080,423));await settle()
 check("button checkout updates money inventory",scene.state.report().cash==57199 and scene.state.report().remaining==1 and scene.state.valid())
 await click_at(Vector2(1080,475));await settle()
 await view("report")
 check("close report readable",scene.state.data.phase=="report" and scene.details.get_rect().end.y<scene.primary.position.y and not scene.close_button.visible)
 await key(KEY_K);scene.perform("reset");await key(KEY_L)
 check("report save reset reload",scene.state.data.phase=="report" and scene.state.data.cash==57199 and scene.state.valid())
 # R2 uses the visible order and next-day dialogs, with input events.
 await click_at(Vector2(1080,475));await frames(3)
 var dialog=scene.ui.get_children().filter(func(c):return c is ConfirmationDialog).back()
 await view("order")
 print("ORDER_DIALOG ",dialog.visible," ",dialog.size)
 check("order preview readable",dialog.visible and dialog.size.x>=560)
 dialog.get_ok_button().pressed.emit();dialog.confirmed.emit();await frames(3)
 check("order dialog pays once",scene.state.data.cash==55599 and scene.state.pending_shipment().quantity==2)
 await key(KEY_K);scene.perform("reset");await key(KEY_L)
 check("paid order reload",scene.state.pending_shipment().quantity==2 and scene.state.data.cash==55599)
 await click_at(Vector2(1080,423));await frames(3)
 dialog=scene.ui.get_children().filter(func(c):return c is ConfirmationDialog).back()
 await view("advance")
 dialog.confirmed.emit();dialog.confirmed.emit();await frames(3)
 check("day dialog repeated confirmation",scene.state.data.day==2 and scene.state.report().sold==0)
 await key(KEY_K);scene.perform("reset");await key(KEY_L)
 await click_at(Vector2(310,430));await settle()
 check("day two receiving control",scene.state.count_at("backroom")==2 and scene.state.data.cash==55599)
 await key(KEY_K);scene.perform("reset");await key(KEY_L)
 scene.price_input.value=24.99
 await click_at(Vector2(1080,423));await settle()
 await key(KEY_E);await settle();await frames(55)
 await view("day-two-stocked")
 check("day two prices and stock",scene.state.count_at("shelf")==3 and scene.state.data.items["case-02"].price==2199 and scene.state.data.items["order-1-copy-1"].price==2499)
 await click_at(Vector2(780,480));await settle()
 collision=false
 for i in range(1600):
  await process_frame
  for block in scene.BLOCKS:
   if block.has_point(scene.customer.position):collision=true
  if scene.customer_stage=="queued":break
 check("second customer route",scene.customer_stage=="queued" and not collision)
 await key(KEY_K);scene.perform("reset");await key(KEY_L)
 await click_at(Vector2(1080,423));await settle()
 await click_at(Vector2(1080,475));await settle()
 await view("day-two-report")
 check("second playable report",scene.state.data.phase=="report" and scene.state.data.cash==57798 and scene.state.report().sold==1 and scene.state.valid())
 await key(KEY_K);scene.perform("reset");await key(KEY_L)
 check("second report reload",scene.state.data.day==2 and scene.state.data.sales.size()==2 and scene.state.valid())
 # Validate fixture detours and both sides of the depth sorting line.
 for dest in [Vector2(630,320),Vector2(630,440),Vector2(790,430),Vector2(790,590)]:
  scene.path=scene.route(scene.player.position,dest);scene.pending="";await settle()
  await view("overlap-"+str(int(dest.x))+"-"+str(int(dest.y)))
  check("walkable overlap viewpoint "+str(dest),scene.player.position.distance_to(dest)<1)
 scene.perform("reset");var start=scene.player.position
 var e=InputEventKey.new();e.physical_keycode=KEY_D;e.keycode=KEY_D;e.pressed=true;Input.parse_input_event(e);await frames(20)
 e=InputEventKey.new();e.physical_keycode=KEY_D;e.keycode=KEY_D;e.pressed=false;Input.parse_input_event(e);await frames(2)
 check("physical D movement",scene.player.position.x>start.x+10)
 var stopped=scene.player.position;await frames(15);check("release stops",scene.player.position==stopped)
 DirAccess.remove_absolute(scene.save_path)
 var out=FileAccess.open("res://evidence/encounter-checks.json",FileAccess.WRITE);out.store_string(JSON.stringify(results,"  "))
 print(JSON.stringify(results))
 quit(0 if results.all(func(r):return r.pass) else 1)
