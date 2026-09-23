extends "res://scripts/test_assortment_scene.gd"
var motion=[]
var frame_number=0
var movie_number=0
var last_positions={}
var distances={}
var record_frames=false
var movie_dir=""
func inspect_frame():
 if not is_instance_valid(scene):return
 observe()
 frame_number+=1
 for id in scene.visitors:
  var actor=scene.visitors[id].actor
  if actor.visible:
   if last_positions.has(id):distances[id]=distances.get(id,0.0)+actor.position.distance_to(last_positions[id])
   last_positions[id]=actor.position
 if frame_number%5==0:
  var row={"frame":frame_number,"phase":scene.state.data.phase,"cash":scene.state.data.cash,"revision":scene.state.data.layout_revision,"player":[scene.player.position.x,scene.player.position.y],"customers":scene.state.data.customers.duplicate(true)}
  motion.append(row)
  if record_frames:
   RenderingServer.force_draw()
   root.get_texture().get_image().save_png(movie_dir+"/%05d.png"%movie_number);movie_number+=1
func select_rack(id):
 # Real floor click selects the fixture by shared footprint.
 var pos=scene.Layout.origin(scene.state.data.layout.fixtures[id])+Vector2(130,20)
 await click_at(pos);await frames(3)
 check("pointer rack selection "+id,scene.selected_rack==id)
func run():
 Engine.time_scale=3.0
 var retina="--retina" in OS.get_cmdline_user_args()
 root.size=Vector2i(2560,1440) if retina else Vector2i(1280,720)
 scene=load("res://main.tscn").instantiate();root.add_child(scene);scene.save_path="user://b2-scene.json";await frames(5)
 record_frames=DisplayServer.get_name()!="headless" and not retina
 movie_dir="res://evidence/frames/b2"
 if record_frames:DirAccess.make_dir_recursive_absolute(movie_dir)
 process_frame.connect(inspect_frame)
 await view("b2-fresh")
 var before=scene.state.data.duplicate(true)
 scene.player.position=Vector2(460,450)
 await press(scene.buy_button)
 check("placement cannot cover player foot",not scene.draft_result.ok and "Rowan" in scene.draft_result.code and scene.confirm_button.disabled)
 await key(KEY_ESCAPE);scene.player.position=scene.Layout.SPAWN
 await press(scene.buy_button);await frames(3)
 check("purchase starts pure preview and disables opening",not scene.draft.is_empty() and scene.state.data==before and scene.primary.disabled)
 await view("b2-preview")
 await key(KEY_ESCAPE)
 check("keyboard cancel full state unchanged",scene.draft.is_empty() and scene.state.data==before)
 await press(scene.buy_button);await click_at(Vector2(830,490))
 check("pointer overlap rejected and confirm disabled",not scene.draft_result.ok and scene.confirm_button.disabled and scene.state.data==before)
 await view("b2-rejected")
 await key(KEY_ENTER)
 check("invalid enter is inert",scene.state.data==before)
 await click_at(Vector2(530,450));await key(KEY_RIGHT);await key(KEY_LEFT)
 check("pointer placement and keyboard adjustment snap",scene.draft.origin==[400,430] and scene.draft_result.ok)
 # Saving while previewing serializes only the confirmed state.
 await press(scene.save_button)
 var saved=scene.State.new()
 check("draft absent from checkpoint",saved.load_from(scene.save_path) and saved.data==before)
 await key(KEY_ENTER);await frames(5)
 check("keyboard purchase exactly once",scene.state.data.cash==49000 and scene.state.capacity()==8 and scene.state.data.fixture_events.size()==1 and scene.draft.is_empty())
 await view("b2-purchased")
 scene.confirm_layout()
 check("repeated confirmation no debit",scene.state.data.cash==49000)
 await click_at(Vector2(310,450));await settle()
 await label_products()
 await select_rack("rack-0001");await stock_one(0);await stock_one(1)
 await select_rack("rack-0002");await stock_one(2)
 check("normal stocking targets selected rack",scene.state.data.items["case-01"].fixture_id=="rack-0001" and scene.state.data.items["case-03"].fixture_id=="rack-0002")
 await select_rack("rack-0001")
 before=scene.state.data.items.duplicate(true)
 await press(scene.arrange_button);await key(KEY_LEFT)
 check("stocked movement preview",scene.draft.origin==[430,330] and scene.state.data.items==before)
 await view("b2-stocked-move-preview")
 await key(KEY_ENTER);await frames(5)
 check("move keeps identity price cost slots",scene.state.data.items==before and scene.state.data.layout.fixtures["rack-0001"].origin==[430,330])
 check("art and work port use changed origin",scene.fixture_nodes["rack-0001"].position==Vector2(430,370) and scene.station("stock","rack-0001")==Vector2(490,400))
 await reload_stage("B2 moved stocked")
 check("reload keeps copies expenses revision",scene.state.data.items==before and scene.state.data.cash==49000 and scene.state.data.layout_revision==2)
 await view("b2-stocked-moved")
 # Pending requests cannot be retargeted by selecting a different rack/product/price.
 await stock_one(0,true)
 scene.selected_product="curb";scene.request_action("stock")
 scene.selected_product="orbit";scene.selected_rack="rack-0002";scene.price_input.value=99.99
 scene.begin_layout("move")
 check("layout rejects pending work",scene.draft.is_empty() and "Finish/cancel" in scene.feedback.text)
 await settle();await frames(20)
 check("pending copy and slot stay on original rack",scene.state.data.items["case-01"].fixture_id=="rack-0001" and scene.state.data.items["case-01"].price==2199)
 # Clear path is not evidence of physical arrival.
 scene.player.position=Vector2(400,550);scene.request_action("reprice");var prior=scene.state.data.items.duplicate(true)
 scene.path.clear();scene.path_reachable=false;await frames(10)
 check("empty unreachable path never performs",scene.state.data.items==prior and scene.pending=="reprice")
 await click_at(Vector2(400,550));await settle()
 # Invalidated revision rejects on arrival, even when the static path is still legal.
 scene.selected_product="curb";scene.price_input.value=50;scene.request_action("reprice")
 var cmd={"request_id":"scene-revision","phase":"prep","day":1,"revision":scene.state.data.layout_revision,"operation":"move","type":"rack","fixture_id":"rack-0001","origin":[440,330]}
 check("state edit invalidates pending request",scene.state.commit_fixture(cmd).ok)
 scene.rebuild_layout();await settle()
 check("stale arrival makes no price change",scene.state.data.items["case-01"].price==2199 and "Layout changed" in scene.feedback.text)
 # Put the delivered scene back at the required moved coordinate through ordinary controls.
 await select_rack("rack-0001");await press(scene.arrange_button);await key(KEY_LEFT);await key(KEY_ENTER);await frames(5)
 # A temporary aisle obstruction must wait without receiving/labeling remotely.
 scene.player.position=Vector2(400,550);scene.selected_product="curb";scene.price_input.value=21.99;scene.request_action("reprice")
 var obstacle=scene.visitors["visitor-3"].actor
 obstacle.visible=true;obstacle.position=Vector2(400,540)
 scene.set_process(false)
 # Exercise the actual player movement update while keeping this synthetic obstruction fixed.
 scene.state.data.customers.clear()
 var held_position=scene.player.position
 for i in range(5):
  obstacle.visible=true;scene._process(1.0/30.0)
 check("temporary occupied aisle waits without remote action",scene.player.position==held_position and scene.pending=="reprice")
 obstacle.visible=false;scene.set_process(true);await settle()
 await press(scene.primary);await settle()
 check("ordinary altered layout opens",scene.state.data.phase=="open")
 scene.begin_layout("move")
 check("open editing rejected",scene.draft.is_empty())
 check("buyers browse both racks and reach full queue",await wait_until(func():return scene.state.data.queue.size()==3 and scene.state.data.customers.values().all(func(c):return c.state=="queued" and c.settled)))
 check("browse destination follows owned copy",scene.state.data.customers["visitor-3"].browse_fixture=="rack-0002")
 await view("b2-moving-queue");await reload_stage("B2 reservations queue")
 await press(scene.close_button);await settle()
 check("ordinary close drains",await drain())
 check("layout-adjusted cash and same sales",scene.state.report().sold==3 and scene.state.report().revenue==5697 and scene.state.data.cash==54697 and scene.state.report().investment==6000)
 await view("b2-report");await reload_stage("B2 report")
 await press(scene.order_button);await frames(3)
 var d=dialog()
 for field in controls(d,SpinBox):field.value=2
 await press(d.get_ok_button());await frames(3)
 check("normal replenishment pays once",scene.state.data.cash==49697 and scene.state.pending_shipment().quantity==6)
 await press(scene.primary);await frames(3);await press(dialog().get_ok_button());await frames(3)
 await click_at(Vector2(310,450));await settle()
 check("advance receives same six copies on day2",scene.state.data.day==2 and scene.state.count_at("backroom")==9 and scene.state.capacity()==8 and scene.state.valid())
 check("moving actors observed not screenshots alone",distances.size()==3 and distances.values().all(func(d):return d>600))
 check("altered-layout actors never intersect fixture",not fixture_collision)
 check("altered-layout buyers retain foot separation",not overlap)
 check("state valid throughout altered-layout flow",not invariant_failure)
 record_frames=false
 process_frame.disconnect(inspect_frame)
 var suffix="retina" if retina else "normal"
 var out=FileAccess.open("res://evidence/layout-scene-"+suffix+".json",FileAccess.WRITE);out.store_string(JSON.stringify({"checks":results,"distance":distances,"frames":frame_number,"movie_frames":movie_number},"  "));out.close()
 out=FileAccess.open("res://evidence/layout-motion-"+suffix+".json",FileAccess.WRITE);out.store_string(JSON.stringify(motion));out.close()
 print("B2_LAYOUT_SCENE ",results.size()," checks; actual movement ",distances)
 quit(0 if results.all(func(r):return r.pass) else 1)
