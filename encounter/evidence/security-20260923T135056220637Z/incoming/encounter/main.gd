extends Node2D
const GlassUI=preload("res://glass_ui.gd")
const State = preload("res://state.gd")
const Actor = preload("res://actor.gd")
var session_file="user://active-week.txt"
var entry_menu
var flow_paused=false
var saving=false
var session_started=false
var help_visible=true
var checkpoint_notice=""
var save_path = "user://encounter.json"
const Layout=preload("res://layout.gd")
var fixture_nodes={}
var layout_overlay: Node2D
var selected_rack="rack-0001"
var rack_select: OptionButton
var arrange_button: Button
var buy_button: Button
var confirm_button: Button
var cancel_button: Button
var draft={}
var draft_result={}
var pending_fixture="rack-0001"
var pending_copy=""
var pending_copy_snapshot={}
var pending_customer=""
var pending_slot=-1
var pending_revision=0
var pending_target=Vector2.ZERO
var path_reachable=false
var request_serial=0
var state = State.new()
var player
var customer
var visitors = {}
var workers={}
var seller_view={}
var seller_button: Button
var copies_button: Button
var pending_seller=""
var seller_dialog
var staff_button: Button
var stock_button: Button
var opening_confirmed=false

var world: Node2D
var nav = AStarGrid2D.new()
var path = PackedVector2Array()
var floor_walk=false
var floor_target=Vector2.ZERO
var pending = ""
var pending_product="curb"
var pending_cents=2199
var ui: CanvasLayer
var summary: Label
var guide: Label
var details: Label
var feedback: Label
var customer_label: Label
var shelf_label: Label
var primary: Button
var day_label: Label
var order_button: Button
var reprice_button: Button
var price_input: SpinBox
var expand_button: Button
var bills_label: Label
var bay_floor: Polygon2D
var shelf_panel
var save_button: Button
var load_button: Button
var close_button: Button
var cases = []
var box: Sprite2D
var selected_action = "receive"
var selected_product="curb"
var assortment_demo=""
var assortment_button: Button
var product_select: OptionButton
var demo_price=0
var capture = false
var capture_frame = 0
var capture_dir = ""
var report_shown_day=0
var report_hold=0.0
var capture_report_dialog
var auto_step = 0
var auto_wait = 0.0
var trace = []
func money(cents) -> String: return "$%.2f" % (float(cents)/100.0)
func sprite(parent: Node, texture: String, pos: Vector2, scale_value: float) -> Sprite2D:
 var s=Sprite2D.new();s.texture=load("res://art/"+texture+".png");s.centered=false;s.position=pos;s.scale=Vector2.ONE*scale_value;parent.add_child(s);return s
func label(parent: Node, text: String, pos: Vector2, size: int, color=Color("293442")) -> Label:
 var l=Label.new();l.mouse_filter=Control.MOUSE_FILTER_IGNORE;l.text=text;l.position=pos;l.add_theme_font_size_override("font_size",size);l.add_theme_color_override("font_color",color);parent.add_child(l);return l
func button(text: String,pos: Vector2,width: float,action: Callable) -> Button:
 var b=Button.new();b.text=text;b.position=pos;b.size=Vector2(width,44);b.add_theme_font_size_override("font_size",18);b.pressed.connect(action)
 b.theme=GlassUI.make_theme();ui.add_child(b);return b
func panel(pos: Vector2,size: Vector2,_color: Color):
 var p=Panel.new();p.position=pos;p.size=size;p.add_theme_stylebox_override("panel",GlassUI.panel_style());p.mouse_filter=Control.MOUSE_FILTER_IGNORE;ui.add_child(p);return p

func _ready():
 get_tree().auto_accept_quit=false
 get_viewport().gui_embed_subwindows=true
 RenderingServer.set_default_clear_color(Color("e8e2d5"))
 texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
 sprite(self,"retail-context",Vector2.ZERO,.25)
 bay_floor=Polygon2D.new();bay_floor.polygon=PackedVector2Array([Vector2(180,220),Vector2(900,220),Vector2(900,320),Vector2(180,320)]);bay_floor.color=Color("b9b2a0");add_child(bay_floor)
 world=Node2D.new();world.y_sort_enabled=true;add_child(world)
 rebuild_layout()
 player=Actor.new();player.position=Layout.SPAWN;world.add_child(player)
 for n in range(8):
  var actor=Actor.new();actor.appearance=n%6;actor.position=Layout.ENTRY;actor.visible=false;world.add_child(actor)
  actor.modulate=[Color(.98,.83,.77),Color(.77,.90,.98),Color(.90,.91,.73),Color("dbaac9"),Color("99cbb8"),Color("dcbf88")][n%6]
  var held=sprite(actor,"case",Vector2(7,-45),.085);held.visible=false
  visitors["buyer:"+state.data.run_id+":"+str(int(state.data.day))+":"+str(n+1)]={"actor":actor,"held":held,"label":null}
 for id in State.Staff.IDS:
  var actor=Actor.new();actor.visible=false;world.add_child(actor)
  actor.modulate=Color("a6d1b1") if id=="morgan" else Color("d6b9df")
  workers[id]={"actor":actor,"label":null,"status":"Unassigned","spawned":false,"rest":Vector2.ZERO}
 var seller_actor=Actor.new();seller_actor.visible=false;seller_actor.modulate=Color("e9c88c");world.add_child(seller_actor)
 seller_view={"actor":seller_actor,"label":null}
 customer=visitors.values()[0].actor
 ui=CanvasLayer.new();add_child(ui)
 panel(Vector2(0,0),Vector2(1280,145),Color("f2eddf"))
 label(ui,"REPLAY JUNCTION",Vector2(40,24),32)
 day_label=label(ui,"SATURDAY, 2002  /  YOUR FIRST SHIFT",Vector2(42,68),16,Color("416489"))
 summary=label(ui,"",Vector2(650,18),18)
 guide=label(ui,"",Vector2(42,118),18)
 guide.clip_text=true;guide.size=Vector2(870,24)
 panel(Vector2(922,158),Vector2(334,476),Color("f9f5e9"))
 product_select=OptionButton.new();product_select.theme=GlassUI.make_theme();product_select.position=Vector2(944,202);product_select.size=Vector2(288,36);product_select.add_theme_font_size_override("font_size",18)
 for product in State.PRODUCTS:product_select.add_item(State.CATALOG[product].name)
 product_select.item_selected.connect(func(index):selected_product=State.PRODUCTS[index];price_input.value=float(State.CATALOG[selected_product].reference)/100;refresh())
 ui.add_child(product_select)
 details=label(ui,"",Vector2(944,246),18)
 price_input=SpinBox.new();price_input.theme=GlassUI.make_theme();price_input.position=Vector2(944,390);price_input.size=Vector2(288,42);price_input.min_value=1;price_input.max_value=99.99;price_input.step=.01;price_input.value=20.0;price_input.prefix="$ ";price_input.add_theme_font_size_override("font_size",20);ui.add_child(price_input)
 price_input.tooltip_text="These labels apply to NEW copies of the selected product only. Used copies have individual labels in Copies / labels. Editing alone changes no copy."
 reprice_button=button("Apply price to unsold stock",Vector2(944,340),288,func():request_action("reprice"))
 primary=button("",Vector2(944,440),288,func():request_action(selected_action))
 assortment_button=button("Assortment · 4 shelf spaces",Vector2(944,490),288,show_assortment)
 close_button=button("Close admission",Vector2(944,490),288,func():request_action("close"))
 order_button=button("Supplier",Vector2(900,24),190,show_order)
 button("Release calendar",Vector2(440,24),180,show_calendar)
 save_button=button("Save",Vector2(944,540),138,func():save_visible())
 load_button=button("Reload",Vector2(1094,540),138,confirm_reload)
 button("Menu / Quit",Vector2(944,590),288,show_pause_menu)
 button("Help · F1",Vector2(1100,126),132,show_help)
 panel(Vector2(24,634),Vector2(1232,68),Color("293442"))
 feedback=label(ui,"Welcome, Rowan. Receive six prepaid games. Rent is due at day-7 close.",Vector2(42,644),18,Color("182338"))
 label(ui,"Click a station or the shift button • WASD / arrows walk • E interact • K save • L reload • F1 help • Esc menu",Vector2(42,675),16,Color("54647b"))
 shelf_panel=panel(Vector2(40,220),Vector2(760,32),Color.WHITE)
 shelf_label=label(ui,"",Vector2(52,224),17)
 for id in visitors:
  visitors[id].label=label(ui,"",Vector2.ZERO,16)
  visitors[id].label.add_theme_color_override("font_shadow_color",Color("fff6dc"))
  visitors[id].label.add_theme_constant_override("shadow_outline_size",3)
 customer_label=visitors.values()[0].label
 for id in workers:
  workers[id].label=label(ui,"",Vector2.ZERO,14)
  workers[id].label.add_theme_color_override("font_shadow_color",Color("fff6dc"))
  workers[id].label.add_theme_constant_override("shadow_outline_size",3)
 seller_view.label=label(ui,"",Vector2.ZERO,15)
 seller_button=button("Seller intake",Vector2(940,80),150,func():request_action("inspect"))
 copies_button=button("Copies / labels",Vector2(940,126),150,show_copies)
 staff_button=button("Employees",Vector2(1100,24),132,show_staff)
 stock_button=button("Stock",Vector2(1100,80),132,show_assortment)
 bills_label=label(ui,"",Vector2(42,144),16)
 expand_button=button("North bay · $100",Vector2(620,170),180,func():begin_layout("expand"))
 button("Finances",Vector2(810,170),100,show_finances)
 arrange_button=button("Arrange shop",Vector2(40,170),170,func():begin_layout("move"))
 buy_button=button("Buy rack · $60",Vector2(220,170),180,func():begin_layout("buy"))
 rack_select=OptionButton.new();rack_select.theme=GlassUI.make_theme();rack_select.position=Vector2(410,170);rack_select.size=Vector2(200,44);ui.add_child(rack_select)
 rack_select.item_selected.connect(func(n):selected_rack=Layout.racks(state.data.layout)[n];refresh())
 confirm_button=button("Confirm · Enter",Vector2(620,170),180,confirm_layout)
 cancel_button=button("Cancel",Vector2(810,170),100,cancel_layout)
 layout_overlay=Node2D.new();layout_overlay.z_index=100;add_child(layout_overlay);layout_overlay.draw.connect(draw_layout)
 update_rack_select()
 label(ui,"RECEIVING",Vector2(260,480),16)
 label(ui,"CHECKOUT",Vector2(725,548),16)
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--assortment-demo="):
   assortment_demo=arg.get_slice("=",1);save_path="user://assortment-"+assortment_demo+".json"
  if arg.begins_with("--pricing-demo="):
   var name=arg.get_slice("=",1)
   demo_price={"low":1699,"reference":2199,"high":2699}.get(name,2199)
   save_path="user://pricing-demo-"+name+".json"
   price_input.value=float(demo_price)/100
 capture="--capture" in OS.get_cmdline_user_args()
 if capture:
  save_path="user://capture-"+str(Time.get_ticks_usec())+".json"
  capture_dir="res://evidence/frames/"+str(Time.get_unix_time_from_system()).replace(".","-")
  DirAccess.make_dir_recursive_absolute(capture_dir)
 if FileAccess.file_exists(session_file):
  var active=FileAccess.get_file_as_string(session_file).strip_edges()
  if active.begins_with("week-") and active.ends_with(".json") and active.is_valid_filename():save_path="user://"+active
 state.checkpoint_path=save_path
 var saved_probe=State.new()
 if FileAccess.file_exists(save_path) and saved_probe.load_from(save_path):state.last_checkpoint_label=saved_probe.last_checkpoint_label
 if assortment_demo!="":setup_comparison()
 print("R1_DISPLAY ",JSON.stringify({"window":DisplayServer.window_get_size(),"viewport":get_viewport_rect().size,"screen_scale":DisplayServer.screen_get_scale(),"canvas_scale":get_viewport().get_final_transform().get_scale()}))
 refresh()
 if not capture and assortment_demo=="":show_entry()
func setup_comparison():
 # Separate comparison-only fixture, built through the ordinary paid two-day loop.
 state.receive()
 for product in State.PRODUCTS:
  state.price(1999 if product=="tide" else State.CATALOG[product].reference,product);state.stock(product)
 state.open()
 for id in state.buyer_ids():
  state.tick(200);state.arrive(id);state.browse(id);state.reserve(id);state.queue(id);state.data.customers[id].settled=true;state.sale(id);state.gone(id)
 state.close();state.finalize();state.advance(1);state.order({"curb":2,"tide":2,"orbit":2,"signal":0,"rally":0},2);state.receive()
 for product in State.PRODUCTS:state.price(State.CATALOG[product].reference,product)
 state.stock("curb",2);state.stock("tide",1 if assortment_demo=="stocked" else 2)
 if assortment_demo=="stocked":state.stock("orbit")
 trace.append({"action":"comparison-prep","mode":assortment_demo,"data":state.data.duplicate(true)})
 state.open();restore_view()
func confirm_reset(return_path: String=""):
 flow_paused=true
 var dialog=ConfirmationDialog.new();dialog.theme=GlassUI.make_theme();dialog.dialog_text="Start a new seven-day business?\nA completed or bankrupt run must be preserved before restart.\nOther unsaved progress will be discarded.";dialog.title="Restart week";dialog.confirmed.connect(func():flow_paused=false;session_started=true;perform("reset"));dialog.canceled.connect(func():
  flow_paused=false
  if return_path!="":save_path=return_path
  if not session_started:call_deferred("show_entry")
 );dialog.confirmed.connect(dialog.queue_free);dialog.canceled.connect(dialog.queue_free);ui.add_child(dialog);dialog.popup_centered(Vector2i(650,180))
func save_feedback() -> String:
 return "Saved: "+state.last_checkpoint_label+"." if not state.save_pending else "SAVE FAILED — progress remains live. Save retries without repeating charges."
func show_finances():
 var d=AcceptDialog.new();d.theme=GlassUI.make_theme();d.title="Business finances • day "+str(state.data.day)
 var r=state.business_report();var today=state.business_report(state.data.day)
 d.dialog_text="Rent: $150 due day 7 close. Wage commitments are shown before opening.\nNorth bay: $100 from day 5 preparation, includes four-slot rack.\n\nWEEK TO DATE\nSales receipts %s • Inventory purchases %s • Cost of sales %s\nMerchandise margin %s • Incurred overhead %s • Operating result %s\nPaid overhead %s • Unpaid liabilities %s • Investment %s\nInventory at cost %s • Cash %s\n\nTODAY’S CASH\nOpening %s + receipts %s − stock %s − investment %s − paid bills %s = %s\nSupplier purchases are paid during preparation; close snapshots include that spending.\nDaily close snapshots retained: %d"%[money(r.receipts),money(r.inventory_purchases),money(r.cost_of_sales),money(r.margin),money(r.incurred_overhead),money(r.operating_result),money(r.paid_overhead),money(r.unpaid_liabilities),money(r.investment),money(r.inventory_cost),money(r.cash),money(today.opening_cash),money(today.receipts),money(today.inventory_purchases),money(today.investment),money(today.paid_overhead),money(today.cash),state.data.settlements.size()]
 var wages=state.data.wage_commitments.reduce(func(total,c):return total+int(c.amount),0)
 var rent=state.data.events.filter(func(e):return e.kind=="rent").reduce(func(total,e):return total+int(e.amount),0)
 d.dialog_text+="\nWages incurred %s • Rent incurred %s (unpaid amounts included above)."%[money(wages),money(rent)]
 d.dialog_text+="\nStock purchases use cash now; only sold copies become cost of sales.\nMargin = receipts − cost of sales. Operating result = margin − wages − rent.\nInvestment buys fixtures/space; it is separate from operating result."
 if state.data.phase=="week_complete":d.dialog_text+="\nSURVIVED: all due bills paid. This does not imply an operating profit."
 if state.data.phase=="bankrupt":
  var due=state.data.events.filter(func(e):return e.id==state.data.terminal.due_event)
  d.dialog_text+="\nBANKRUPT: could not pay "+due[0].kind+" ("+money(due[0].amount)+"). Cash shortfall "+money(state.data.terminal.shortfall)+".\nInventory cannot pay cash bills; no automatic liquidation. Menu offers a preserved restart."
 d.add_button("Daily closes",true,"history")
 d.custom_action.connect(func(_action):show_daily_reports())
 d.confirmed.connect(d.queue_free);ui.add_child(d);d.popup_centered(Vector2i(940,420))
func show_daily_reports():
 var d=AcceptDialog.new();d.theme=GlassUI.make_theme();d.title="Daily closing snapshots"
 var rows=["Frozen after all trading and due bills.","Cash and merchandise margin are different measures.",""]
 for row in state.data.settlements:
  var r=row.report
  rows.append("Day %d: Cash %s | Receipts %s | Stock bought %s | Cost sold %s\nMargin %s | Wages/rent %s | Unpaid %s | Investment %s"%[row.day,money(r.cash),money(r.receipts),money(r.inventory_purchases),money(r.cost_of_sales),money(r.margin),money(r.incurred_overhead),money(r.unpaid_liabilities),money(r.investment)])
 if state.data.settlements.is_empty():rows.append("No days settled yet.")
 d.dialog_text="\n".join(rows);d.confirmed.connect(d.queue_free);ui.add_child(d);d.popup_centered(Vector2i(850,360))
func show_assortment():
 if not draft.is_empty():return
 var dialog=AcceptDialog.new();dialog.title="Per-product results" if state.data.phase=="report" else "Assortment • "+selected_rack+" • "+str(state.capacity())+" total slots";dialog.min_size=Vector2i(850,330)
 dialog.theme=GlassUI.make_theme();dialog.theme.default_font_size=18
 var content=VBoxContainer.new();content.add_theme_constant_override("separation",12);dialog.add_child(content)
 var info=Label.new();content.add_child(info)
 var refresh_rows=[]
 for product in State.PRODUCTS:
  var row=HBoxContainer.new();row.add_theme_constant_override("separation",12);content.add_child(row)
  var art=TextureRect.new();art.texture=load("res://art/"+State.CATALOG[product].art+".png");art.custom_minimum_size=Vector2(38,52);art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;art.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;row.add_child(art)
  var detail=Label.new();detail.custom_minimum_size.x=460;row.add_child(detail)
  var add=Button.new();add.text="Shelf +1";add.custom_minimum_size=Vector2(110,44);row.add_child(add)
  var remove=Button.new();remove.text="Return 1";remove.custom_minimum_size=Vector2(110,44);row.add_child(remove)
  var update=func():
   var r=state.report(product)
   detail.text="%s • New buy %s / Ref %s\nShelf %d • Backroom %d • Sold %d • Price misses %d • Stock misses %d\nRevenue %s • Cost %s • Gross profit %s" % [State.CATALOG[product].name,money(State.CATALOG[product].cost),money(State.CATALOG[product].reference),state.count_at("shelf",product),state.count_at("backroom",product),r.sold,r.missed,r.unavailable,money(r.revenue),money(r.cost),money(r.margin)]
   detail.add_theme_font_size_override("font_size",16)
   add.disabled=state.data.phase not in ["prep","open"] or state.free_slot(selected_rack).is_empty() or not state.data.items.values().any(func(i):return i.product==product and i.location=="backroom" and i.price>0)
   remove.disabled=state.data.phase!="prep" or not state.data.items.values().any(func(i):return i.product==product and i.location=="shelf" and i.fixture_id==selected_rack)
  if state.data.phase=="report":add.hide();remove.hide()
  refresh_rows.append(update)
  add.pressed.connect(func():
   selected_product=product;request_action("stock");dialog.queue_free())
  remove.pressed.connect(func():
   selected_product=product;request_action("return");dialog.queue_free())
 info.text="Selected: "+selected_rack+" • Four slots per rack. Choose a copy, then Rowan walks to the rack.\nReturn keeps the copy’s price and cost. Select racks on the shop toolbar."
 if state.data.phase=="report":info.text="Day %d • Revenue %s • Gross profit %s • Cash %s\nReview sales and misses; supplier purchases resume next preparation."%[state.data.day,money(state.report().revenue),money(state.report().margin),money(state.data.cash)]
 for_update(refresh_rows)
 dialog.confirmed.connect(dialog.queue_free);dialog.canceled.connect(dialog.queue_free);ui.add_child(dialog);dialog.popup_centered()
func for_update(callbacks):
 for callback in callbacks:callback.call()
func show_order():
 if state.data.phase != "prep": return
 var order_day=state.data.day
 var dialog=ConfirmationDialog.new();dialog.title="Supplier • five-title release calendar";dialog.ok_button_text="Pay & place order"
 dialog.theme=GlassUI.make_theme();dialog.theme.default_font_size=20
 var content=VBoxContainer.new();content.add_theme_constant_override("separation",12);dialog.add_child(content)
 var fields={}
 for product in State.PRODUCTS:
  var row=HBoxContainer.new();content.add_child(row)
  var info=Label.new();info.text="%s  • Buy %s / Ref %s"%[State.CATALOG[product].name,money(State.CATALOG[product].cost),money(State.CATALOG[product].reference)];info.custom_minimum_size.x=540;row.add_child(info)
  var quantity=SpinBox.new();quantity.min_value=0;quantity.max_value=6;quantity.step=1;quantity.custom_minimum_size=Vector2(110,44);quantity.editable=State.Week.released(product,order_day);row.add_child(quantity);fields[product]=quantity
  if not quantity.editable:info.text+=" · DAY %d"%State.CATALOG[product].release;quantity.max_value=0
 var total_label=Label.new();content.add_child(total_label)
 var update=func(_v=0):
  var total=0;var quantity=0
  for product in State.PRODUCTS:total+=int(fields[product].value)*State.CATALOG[product].cost;quantity+=int(fields[product].value)
  total_label.text="Cash %s • Total %s • After payment %s\nReceive today (day %d) • One mixed order per preparation"%[money(state.data.cash),money(total),money(state.data.cash-total),order_day]
  dialog.get_ok_button().disabled=total==0 or total>state.data.cash or state.backroom_committed()+quantity>64 or state.data.orders.any(func(o):return o.day==order_day) or not state.data.received
 for field in fields.values():field.value_changed.connect(update)
 update.call()
 dialog.confirmed.connect(func():
  var quantities={}
  for product in State.PRODUCTS:quantities[product]=int(fields[product].value)
  var ok=state.order(quantities,order_day)
  feedback.text="Mixed order paid once. Receive it before opening." if ok else "Order rejected. Check release date, daily limit, cash and backroom capacity."
  trace.append({"action":"order","ok":ok,"quantities":quantities,"cash":state.data.cash});refresh();dialog.queue_free())
 dialog.canceled.connect(dialog.queue_free);ui.add_child(dialog);dialog.popup_centered(Vector2i(750,300))
func show_advance():
 if state.data.phase != "report": return
 var closing_day = state.data.day
 var dialog = ConfirmationDialog.new();dialog.theme=GlassUI.make_theme();dialog.theme.default_font_size=20;dialog.title="Start the next day"
 dialog.dialog_text="Advance to day %d?\nUnsold stock, prices and cash carry forward.\nDaily sales reset; buy and receive new stock during preparation." % (closing_day+1)
 dialog.confirmed.connect(func():
  state.checkpoint_path=save_path
  var ok=state.advance(closing_day)
  if ok:restore_view()
  feedback.text=("New day. Receive any paid shipment, price and stock. "+save_feedback()) if ok else "Day already advanced."
  trace.append({"action":"advance","ok":ok,"day":state.data.day});refresh();dialog.queue_free())
 dialog.canceled.connect(dialog.queue_free);ui.add_child(dialog);dialog.popup_centered(Vector2i(550,170))
func route(from: Vector2,to: Vector2) -> Dictionary:
 var a=Vector2i((from/10).round());var b=Vector2i((to/10).round())
 if not nav.is_in_boundsv(a) or not nav.is_in_boundsv(b) or nav.is_point_solid(b):return {"reachable":false,"points":PackedVector2Array()}
 var points=nav.get_point_path(a,b)
 return {"reachable":not points.is_empty(),"points":points}
func station(action: String,fixture_id: String = "") -> Vector2:
 if fixture_id=="":fixture_id=selected_rack
 if action=="inspect":return Layout.ports(state.data.layout,"checkout-01").inspect
 if action in ["receive","price","reprice","copy_price"]:return Layout.ports(state.data.layout,"receiving-01").receive
 if action in ["stock","return"]:return Layout.ports(state.data.layout,fixture_id).get("work",Vector2(-100,-100))
 if action in ["sale","open","close"]:return Layout.ports(state.data.layout,"checkout-01").cashier
 return player.position
func request_action(action: String,requested_copy: String="",copy_cents: int=0):
 floor_walk=false
 if action=="open" and not opening_confirmed and State.Staff.IDS.any(func(id):return state.data.staff[id].employed and state.data.staff[id].role=="unassigned"):
  var dialog=ConfirmationDialog.new();dialog.title="Paid idle employees";dialog.dialog_text="Unassigned employees will be paid $12 each today, even without work. Open anyway?";dialog.theme=GlassUI.make_theme();ui.add_child(dialog)
  dialog.confirmed.connect(func():opening_confirmed=true;request_action("open");dialog.queue_free());dialog.canceled.connect(dialog.queue_free);dialog.popup_centered(Vector2i(620,200));return
 if not draft.is_empty():feedback.text="Confirm or cancel the layout preview first.";return
 if pending!="":feedback.text="Finish/cancel current action first (click clear floor to cancel).";return
 if action=="advance":show_advance();return
 if action=="order":show_order();return
 if action=="wait":feedback.text="Customers browse independently. Serve the front of the checkout queue.";return
 if action=="inspect":
  var row=state.seller()
  if row.is_empty() or row.status not in ["ready","counter","accepted"]:feedback.text="Seller has not reached intake, or is resolved.";return
  pending_seller=row.id
 pending_product=selected_product;pending_cents=roundi(price_input.value*100)
 pending_fixture=selected_rack;pending_revision=state.data.layout_revision;pending_copy="";pending_slot=-1
 if action=="copy_price":pending_copy=requested_copy;pending_cents=copy_cents
 if action in ["stock","return"]:
  for id in state.ordered_copy_ids():
   var item=state.data.items[id]
   if (requested_copy=="" or id==requested_copy) and item.product==pending_product and ((action=="stock" and item.location=="backroom" and item.price>0) or (action=="return" and item.location=="shelf" and item.fixture_id==pending_fixture)):

    if action=="stock" and State.Staff.active(state.data).any(func(j):return j.kind=="stock" and j.copy==id):continue
    pending_copy=id;break
  if action=="stock":
   var slot=state.free_slot(pending_fixture)
   if not slot.is_empty():pending_slot=slot.slot_index
  if pending_copy=="" or (action=="stock" and pending_slot<0):feedback.text="No eligible copy or free slot on "+pending_fixture;return
 pending_copy_snapshot=state.data.items[pending_copy].duplicate(true) if pending_copy!="" else {}
 pending_customer=state.data.queue[0] if action=="sale" and not state.data.queue.is_empty() else ""
 if action in ["stock","sale"]:
  var j=state.claim("player",action,pending_copy,pending_fixture,pending_slot,pending_customer)
  if j.is_empty():feedback.text="Work unavailable or claimed. Employees → Take over to claim unfinished work.";return
 pending_target=station("receive" if action=="stock" else action,pending_fixture)
 var result=route(player.position,pending_target)
 path_reachable=result.reachable
 if not path_reachable:State.Staff.cancel(state.data,"player","Unreachable station");feedback.text="Unreachable station. Rearrange during preparation.";return
 pending=action;path=result.points;feedback.text="Rowan → "+{"receive":"receiving","price":"price labels","stock":pending_fixture,"return":pending_fixture,"sale":"checkout","open":"register","close":"register"}.get(action,action)
func perform(action: String, product: String = "", cents: int = 0):
 if not draft.is_empty() and action not in ["save","load","reset"]:return
 if product=="":product=selected_product
 if cents==0:cents=roundi(price_input.value*100)
 state.checkpoint_path=save_path
 var ok=false
 if action in ["stock","return","sale"]:
  if pending_revision!=state.data.layout_revision or player.position.distance_to(station(action,pending_fixture))>=1:feedback.text="Return to the requested station before acting.";return
  if action!="sale" and (not state.data.items.has(pending_copy) or state.data.items[pending_copy]!=pending_copy_snapshot):State.Staff.cancel(state.data,"player","Copy changed");feedback.text="Copy changed; request the action again.";return
 if action in ["load","reset"]:draft.clear();draft_result.clear()
 match action:
  "inspect":
   ok=state.inspect_seller(pending_seller,player.position)
   if ok:player.reach();show_seller()
  "copy_price":ok=state.price_copy(pending_copy,cents,pending_copy_snapshot)
  "receive":ok=state.receive()
  "price":ok=state.price(cents,product)
  "reprice":ok=state.reprice(cents,product)
  "stock":
   ok=state.complete_job("player",player.position)
   if ok:player.reach()
  "return":ok=state.return_copy(pending_copy)
  "open":ok=state.open();opening_confirmed=false
  "sale":
   if not state.data.queue.is_empty() and state.data.queue[0]==pending_customer:ok=state.complete_job("player",player.position)
  "close":ok=state.close()
  "finalize":ok=state.finalize()
  "save":ok=state.retry_save()
  "load":
   ok=state.load_from(save_path)
   if ok:restore_view()
  "reset":
   ok=state.restart(save_path)
   if ok:restore_view()
 feedback.text={"inspect":"Seller inspected. Offers are separate from payment confirmation.","copy_price":"Individual copy labeled. Its acquisition cost is unchanged.","return":"Copy returned to backroom; cost and label retained.","receive":"Shipment received once. Price the new copies at the shift desk.","reprice":"New copies repriced. Used labels stay separate; buyers may decline.","price":"Price labels ready. Stock the priced copies on the display.","stock":"Priced copies on display. Open the shop when you’re ready.","open":"OPEN. Today’s authored roster arrives at 18-second intervals.","sale":"Sale complete. Remaining stock and cash updated.","close":"Admission closed. Existing customers may finish browsing and buying.","finalize":"Day finalized. Sales are now locked; review the report.","save":"Shift saved. Reload restores this exact business state.","load":"Saved shift restored. Inventory, reservations and cash agree.","reset":"New week started. Terminal results retained."}.get(action,action) if ok else ("Cannot load: malformed or unsupported checkpoint. This build supports schema 10 only; New practice shift is separate." if action=="load" else "Restart/save failed; current progress retained. Check access and retry." if action=="reset" else "Cannot do that now. Follow the current shift step.")
 if action=="finalize" and ok and state.data.phase in ["week_complete","bankrupt"]:feedback.text="Week complete. Review finances or restart." if state.data.phase=="week_complete" else "Business ended: a due bill could not be paid. Review finances or restart."
 if action in ["finalize","reset"] and ok:feedback.text+=" "+save_feedback()
 if action=="save" and ok:feedback.text=save_feedback()
 if action=="save" and not ok:feedback.text=save_feedback()
 if action=="reset" and not ok:feedback.text="Restart blocked: terminal result could not be preserved. Live run retained."
 if action in ["reset","save"] and ok:remember_active_path()
 trace.append({"action":action,"ok":ok,"report":state.report(),"phase":state.data.phase})
 print("R1_ACTION ",JSON.stringify(trace.back()))
 refresh()
func restore_view():
 sync_visitors()
 if is_instance_valid(seller_dialog):seller_dialog.queue_free()
 var restored_seller=state.seller()
 seller_view.actor.visible=not restored_seller.is_empty() and restored_seller.motion not in ["waiting","gone"]
 if not restored_seller.is_empty():seller_view.actor.position=Vector2(restored_seller.position[0],restored_seller.position[1])
 for w in workers.values():w.spawned=false;w.actor.visible=false;w.actor.reaching=false
 opening_confirmed=false
 floor_walk=false
 path.clear();pending="";draft.clear();player.position=Layout.ports(state.data.layout,"checkout-01").cashier;rebuild_layout();update_rack_select();redraw_layout()
 for id in visitors:
  visitors[id].actor.visible=false
  if state.data.customers.has(id):
   var c=state.data.customers[id]
   visitors[id].actor.position=Vector2(c.position[0],c.position[1])
   visitors[id].actor.visible=c.state not in ["waiting","gone","cancelled"]
 for spawn in [Layout.ports(state.data.layout,"checkout-01").cashier,Layout.SPAWN,Vector2(400,510),Vector2(380,490),Vector2(200,330)]:
  if Layout.walkable(state.data.layout,spawn) and (not seller_view.actor.visible or spawn.distance_to(seller_view.actor.position)>=28) and state.data.customers.values().all(func(c):return c.state in ["waiting","gone","cancelled"] or spawn.distance_to(Vector2(c.position[0],c.position[1]))>=28):player.position=spawn;break
 var copies=state.data.items.values().filter(func(i):return i.kind=="new" and i.product==selected_product and i.location!="sold" and i.price>0)
 price_input.value=float(copies[0].price if not copies.is_empty() else State.CATALOG[selected_product].reference)/100

func refresh():
 sync_visitors()
 for n in range(State.PRODUCTS.size()):product_select.set_item_disabled(n,not State.Week.released(State.PRODUCTS[n],state.data.day))
 var seller=state.seller()
 seller_button.disabled=not draft.is_empty() or seller.is_empty() or seller.status not in ["ready","counter","accepted"]
 seller_button.text="Seller intake"
 seller_button.tooltip_text=seller.status.capitalize() if not seller.is_empty() else "Sellers arrive from day 2"
 copies_button.disabled=not draft.is_empty()
 details.add_theme_font_size_override("font_size",16 if state.data.phase=="report" else 18)
 details.size=Vector2.ZERO
 stock_button.visible=state.data.phase in ["prep","open"]
 staff_button.disabled=not draft.is_empty()
 var r=state.report()
 bay_floor.visible=state.data.layout.space_level==1
 var wages=0
 for c in state.data.wage_commitments:
  if c.day==state.data.day:wages+=int(c.amount)
 bills_label.position.y=64
 var rent_status="day 7 close"
 for event in state.data.events:
  if event.kind=="rent":rent_status="PAID" if event.status=="paid" else "UNPAID"
 bills_label.text="Day %d / 7 · "%state.data.day+"Rent $150 · "+rent_status+"  |  Today’s wage commitments "+money(wages)+"  |  North bay $100 · day 5"
 expand_button.visible=draft.is_empty() and state.data.phase=="prep"
 expand_button.disabled=state.data.phase!="prep" or state.data.day<5 or state.data.layout.space_level==1
 save_button.text="Retry save" if state.save_pending else "Save"
 shelf_label.position=Vector2(42,86)
 if shelf_panel!=null:shelf_panel.visible=false
 for control in [arrange_button,buy_button,rack_select,expand_button,confirm_button,cancel_button]:control.position.y=170
 day_label.visible=false
 day_label.text=("ASSORTMENT COMPARISON · "+assortment_demo.to_upper()+" • " if assortment_demo!="" else "")+"DAY %d  /  MALL SHOP • 2002" % state.data.day
 summary.text="%s\nCash %s" % [state.data.phase.replace("_"," ").to_upper(),money(r.cash)]
 shelf_label.text="%s: %d / 4 occupied • Shop total: %d / %d slots"%[selected_rack,state.data.items.values().filter(func(i):return i.fixture_id==selected_rack).size(),state.shelf_used(),state.capacity()]
 arrange_button.visible=state.data.phase=="prep";buy_button.visible=arrange_button.visible;rack_select.visible=arrange_button.visible
 confirm_button.visible=not draft.is_empty();cancel_button.visible=confirm_button.visible
 arrange_button.disabled=not draft.is_empty();buy_button.disabled=not draft.is_empty();rack_select.disabled=not draft.is_empty()
 confirm_button.disabled=not draft_result.get("ok",false)
 redraw_layout()
 for slot_view in cases:
  var matches=state.data.items.values().filter(func(i):return i.fixture_id==slot_view.fixture_id and i.slot_index==slot_view.slot_index and i.location=="shelf")
  slot_view.sprite.visible=not matches.is_empty()
  if slot_view.sprite.visible:slot_view.sprite.texture=load("res://art/"+State.CATALOG[matches[0].product].art+".png")
 box.modulate.a=1.0 if not state.data.received or not state.pending_shipment().is_empty() else .40
 price_input.visible=state.data.phase=="prep" and state.data.received and state.pending_shipment().is_empty()
 reprice_button.visible=price_input.visible
 product_select.visible=state.data.phase=="prep"
 assortment_button.visible=state.data.phase in ["prep","report"]
 assortment_button.position.y=390 if state.data.phase=="report" else 490
 assortment_button.text="Per-product report" if state.data.phase=="report" else "Assortment · "+str(state.capacity())+" slots"
 details.position.y=210 if state.data.phase!="prep" else 246
 product_select.disabled=not draft.is_empty()
 price_input.editable=draft.is_empty()
 primary.disabled=not draft.is_empty()
 reprice_button.disabled=not draft.is_empty()
 assortment_button.disabled=not draft.is_empty()
 close_button.disabled=state.data.phase!="open"
 close_button.visible=state.data.phase=="open"
 load_button.disabled=not FileAccess.file_exists(save_path)
 load_button.tooltip_text=state.last_checkpoint_label+". Reload discards progress after this successful checkpoint."
 order_button.visible=state.data.phase=="prep"
 order_button.disabled=not draft.is_empty() or not state.data.received or state.data.orders.any(func(o):return o.day==state.data.day)
 if state.data.phase in ["week_complete","bankrupt"]:
  var week=state.business_report()
  guide.text="Survived: all due bills paid. Survival is not profit. Review finances or Menu." if state.data.phase=="week_complete" else "Bankrupt • A due bill could not be paid. Review liabilities or restart."
  details.text="%s\nCash %s\nMerchandise margin %s\nIncurred overhead %s\nOperating result %s\nUnpaid liabilities %s\nInvestment %s\nShortfall %s"%["SURVIVED" if state.data.phase=="week_complete" else "BUSINESS ENDED",money(week.cash),money(week.margin),money(week.incurred_overhead),money(week.operating_result),money(week.unpaid_liabilities),money(week.investment),money(state.data.terminal.shortfall)]
  details.add_theme_font_size_override("font_size",16)
  primary.visible=false;selected_action="wait"
  return
 if state.data.phase=="report":
  shelf_label.text="Shop capacity: %d slots • Fixtures / expansion paid: %s"%[state.capacity(),money(r.investment)]
  guide.text="Shift complete • Review finances, then advance to day %d." % (state.data.day+1)
  details.tooltip_text="Fixtures / expansion paid: "+money(r.investment)+". Revenue: today’s completed sales. Sold-copy cost: historical purchase cost of each sold copy. Gross profit: revenue minus that cost, before overhead. Orders reduce cash, not profit, until sold."
  details.text="DAY %d • %d sold • %d price misses\n%d stock misses\nRevenue              %s\nSold-copy cost     %s\nMerch. margin      %s\nUnsold copies       %d\nCash available      %s"%[state.data.day,r.sold,r.missed,r.unavailable,money(r.revenue),money(r.cost),money(r.margin),r.remaining,money(r.cash)]
  primary.visible=true;primary.text="Advance to day %d" % (state.data.day+1);selected_action="advance"
  return
 primary.visible=true
 var prices=[]
 for item in state.data.items.values():
  if item.kind=="new" and item.product==selected_product and item.location != "sold" and item.price > 0 and not prices.has(item.price):prices.append(item.price)
 prices.sort()
 var price_text="Unpriced" if prices.is_empty() else money(prices[0])+" each"
 if prices.size()>1:price_text=money(prices[0])+" – "+money(prices.back())+" labels"
 details.text="New %s • Cost %s\nRef %s · new copies\nShelf %d  •  Backroom %d"%[price_text,money(State.CATALOG[selected_product].cost),money(State.CATALOG[selected_product].reference),state.count_at("shelf",selected_product),state.count_at("backroom",selected_product)]
 if state.data.phase in ["open","closing"]:
  var lines=[]
  for id in state.data.customers:
   var c=state.data.customers[id]
   var status={"waiting":"Due shortly","arriving":"Arriving","browsing":"Browsing","selected":"Considering price","queued":"Queue #%d" % (state.data.queue.find(id)+1),"leaving":"Leaving","gone":"Left","cancelled":"Admission closed"}.get(c.state,c.state)
   if c.decision=="decline":status="Label exceeds budget "+money(c.budget)
   if c.decision=="unavailable":status="No eligible shelf copy"
   if c.decision=="buy" and c.item=="":status="Purchased" if state.data.sales.any(func(row):return row.day==state.data.day and row.customer==id) else "Departed"
   if c.state in ["waiting","gone","cancelled"]:continue
   lines.append(c.name+" → "+State.CATALOG[c.product].name+"\n"+status+(" · "+money(c.offer) if c.offer>0 else ""))
  details.add_theme_font_size_override("font_size",16)
  details.text="Shelf %d • Sold %d\n%s" % [state.count_at("shelf"),r.sold,"\n".join(lines)]
  if not state.data.queue.is_empty():
   var c=state.data.customers[state.data.queue[0]]
   selected_action="sale" if c.settled else "wait"
   primary.text="Serve %s · %s" % [c.name,money(c.offer)] if c.settled else c.name+" → checkout…"
  elif state.can_finalize():selected_action="finalize";primary.text="Finalize day report"
  elif state.data.phase=="open" and state.data.customers.values().all(func(c):return c.state=="gone"):
   selected_action="close";primary.text="Close admission"
  else:selected_action="wait";primary.text="Customers browsing…"
  guide.text="Admission closed • Finish existing customers, then finalize the day." if state.data.phase=="closing" else "%d shoppers today • At most three inside • Close admission whenever you choose."%state.data.customers.size()
 elif not state.data.received or not state.pending_shipment().is_empty():selected_action="receive";primary.text="Receive %d copies" % (6 if not state.data.received else state.pending_shipment().quantity);guide.text="1 / 7  •  Receive the shipment at the box."
 else:
  selected_action="open";primary.text="Open the shop"
  reprice_button.text="Label NEW copies"
  guide.text="Prep • Supplier → receive → label → stock. Calendar shows today’s interests."
  if state.data.items.values().any(func(i):return i.location=="backroom" and i.price==0 and i.available_day<=state.data.day):guide.text="Next: choose a title and Label NEW copies; use Copies / labels for used stock."
  elif state.shelf_used()==0:guide.text="Next: Stock → Shelf +1. Choose the selected rack; Rowan receives and carries the copy."
 guide.visible=help_visible
func move_actor(who,points: PackedVector2Array,delta: float,speed: float) -> Vector2:
 if points.is_empty():return Vector2.ZERO
 var target=points[0];var dir=(target-who.position).normalized();who.position=who.position.move_toward(target,speed*delta)
 if who.position.distance_to(target)<.1:points.remove_at(0)
 return dir
func _unhandled_input(event):
 if flow_paused:return
 if not draft.is_empty():
  if event is InputEventKey and event.pressed and not event.echo:
   match event.keycode:
    KEY_ESCAPE:cancel_layout()
    KEY_ENTER,KEY_KP_ENTER:confirm_layout()
    KEY_LEFT,KEY_RIGHT,KEY_UP,KEY_DOWN:
     var offset={KEY_LEFT:Vector2(-10,0),KEY_RIGHT:Vector2(10,0),KEY_UP:Vector2(0,-10),KEY_DOWN:Vector2(0,10)}[event.keycode]
     set_draft_origin(Vector2(draft.origin[0],draft.origin[1])+offset)
  if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT and event.position.x<910 and event.position.y>=Layout.floor_bounds(state.data.layout.space_level).position.y:set_draft_origin(event.position-Vector2(130,20))
  return
 if event is InputEventKey and event.pressed and not event.echo:
  match event.keycode:
   KEY_E:request_action(selected_action)
   KEY_K:save_visible()
   KEY_L:confirm_reload()
   KEY_F1:show_help()
   KEY_ESCAPE:show_pause_menu()
 if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
  var p=event.position
  var hit=""
  for id in state.data.layout.fixtures:
   var f=state.data.layout.fixtures[id]
   if Layout.footprint(f).grow(10).has_point(p):hit=id
  if hit=="receiving-01":request_action("receive" if not state.data.received or not state.pending_shipment().is_empty() else "price")
  elif hit.begins_with("rack"):
   selected_rack=hit;update_rack_select();refresh()
  elif hit=="checkout-01":request_action(selected_action if state.data.phase in ["open","closing"] else ("open" if state.data.phase=="prep" else "wait"))
  elif Layout.floor_bounds(state.data.layout.space_level).has_point(p):
   State.Staff.cancel(state.data,"player","Player cancelled travel")
   floor_walk=true;floor_target=p.snapped(Vector2(10,10))
   var result=route(player.position,floor_target);path=result.points;path_reachable=result.reachable;pending=""
func _process(delta):
 if player==null or flow_paused:return
 if not draft.is_empty():return
 var dir=Vector2(float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT))-float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)),float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN))-float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP))).normalized()
 if price_input.get_line_edit().has_focus() or ui.get_children().any(func(c):return c is Window and c.visible):dir=Vector2.ZERO
 if dir!=Vector2.ZERO:
  State.Staff.cancel(state.data,"player","Player cancelled travel")
  path.clear();pending="";floor_walk=false
  var next=player.position+dir*110*delta
  var blocked=false
  for block in Layout.obstacles(state.data.layout):
   if block.grow(Layout.RADIUS).has_point(next):blocked=true
  for v in visitors.values()+workers.values()+[seller_view]:
   if v.actor.visible and next.distance_to(v.actor.position)<28:blocked=true
  if not blocked:player.position=next.clamp(Layout.floor_bounds(state.data.layout.space_level).position,Layout.floor_bounds(state.data.layout.space_level).end-Vector2(10,10))
  else:dir=Vector2.ZERO
 elif not player.reaching and not yield_to_queue(player):
  if (pending!="" or floor_walk) and player.position.distance_to(pending_target if pending!="" else floor_target)>=1:
   var routed=dynamic_route(player,pending_target if pending!="" else floor_target);path=routed.points;path_reachable=routed.reachable
   if path.size()>1 and player.position.distance_to(path[0])<8 and clear_segment(player,path[1]):path.remove_at(0)
  var clear=true
  if not path.is_empty():
   var next=player.position.move_toward(path[0],110*delta)
   for v in visitors.values()+workers.values()+[seller_view]:
    if v.actor.visible and next.distance_to(v.actor.position)<28:clear=false
  if clear:dir=move_actor(player,path,delta,110)
  elif pending!="":feedback.text="Rowan: Waiting for aisle"
 if floor_walk and player.position.distance_to(floor_target)<1:floor_walk=false
 player.pose(dir,delta)
 if path.is_empty() and pending!="" and path_reachable and player.position.distance_to(pending_target)<1:
  if pending=="stock" and not State.Staff.job(state.data,"player").is_empty() and not State.Staff.job(state.data,"player").received:
   state.visit_receiving("player",player.position);player.reach();pending_target=station("stock",pending_fixture);var onward=route(player.position,pending_target);path=onward.points;path_reachable=onward.reachable;return
  var action=pending;pending=""
  if pending_revision==state.data.layout_revision:perform(action,pending_product,pending_cents)
  else:State.Staff.cancel(state.data,"player","Layout changed");feedback.text="Layout changed; request the action again."
 update_workers(delta)
 update_wave(delta)
 update_seller(delta)
 arrange_actor_labels()
 if capture:await capture_tick(delta)
func update_wave(delta):
 state.tick(delta)
 var ordered=visitors.keys()
 var priority={"leaving":0,"queued":1,"arriving":2,"browsing":3,"selected":3,"waiting":4}
 ordered.sort_custom(func(a,b):return priority.get(state.data.customers.get(a,{}).get("state"),5)<priority.get(state.data.customers.get(b,{}).get("state"),5))
 for id in ordered:
  var v=visitors[id]
  if not state.data.customers.has(id):
   v.actor.visible=false;v.label.visible=false;v.held.visible=false
   continue
  var c=state.data.customers[id]
  if c.state=="waiting":
   var door_clear=not state.data.customers.values().any(func(other):return other.state=="leaving" or (other.state=="queued" and not other.settled))
   for other in visitors.values():
    if other.actor.visible and other.actor.position.distance_to(Layout.ENTRY)<80:door_clear=false
   for other in workers.values()+[seller_view,{"actor":player}]:
    if other.actor.visible and other.actor.position.distance_to(Layout.ENTRY)<28:door_clear=false
   if door_clear and state.data.clock>=c.arrival and state.data.customers.values().filter(func(other):return other.state not in ["waiting","gone","cancelled"]).size()<3:
    var destination=browse_destination(c)
    if not destination.is_empty():
     c.browse_fixture=destination.fixture_id;c.browse_port=destination.port
     state.arrive(id)
  v.actor.visible=c.state not in ["waiting","gone","cancelled"]
  var target=v.actor.position
  if c.state=="arriving":target=Layout.ports(state.data.layout,c.browse_fixture)[c.browse_port]
  elif c.state=="queued":
   target=Layout.queue_ports(state.data.layout)[state.data.queue.find(id)]
   if state.data.customers.values().any(func(other):return other.state=="leaving"):target=v.actor.position
  elif c.state=="leaving":target=Layout.ENTRY
  var movement=Vector2.ZERO
  if v.actor.visible and v.actor.position.distance_to(target)>1:
   # Other visitors occupy navigation cells, keeping routes and waiting bodies separate.
   var blocked_cells=[]
   for other in visitors.values()+workers.values()+[seller_view,{"actor":player}]:
    if other==v or not other.actor.visible:continue
    for x in range(nav.region.position.x,nav.region.end.x):
     for y in range(nav.region.position.y,nav.region.end.y):
      var cell=Vector2i(x,y)
      if Vector2(cell*10).distance_to(other.actor.position)<28 and not nav.is_point_solid(cell):
       nav.set_point_solid(cell);blocked_cells.append(cell)
   var routed=route(v.actor.position,target)
   var points=routed.points
   for cell in blocked_cells:nav.set_point_solid(cell,false)
   if points.size()>1 and v.actor.position.distance_to(points[0])<8 and clear_segment(v.actor,points[1]):points.remove_at(0)
   if not routed.reachable:feedback.text=c.name+": Waiting for aisle"
   if routed.reachable:
    var next=v.actor.position.move_toward(points[0],80*delta)
    var clear=true
    for other in visitors.values()+workers.values()+[seller_view,{"actor":player}]:
     if other!=v and other.actor.visible and next.distance_to(other.actor.position)<28:clear=false
    if clear:
     movement=(next-v.actor.position).normalized();v.actor.position=next
  v.actor.pose(movement,delta)
  c.position=[v.actor.position.x,v.actor.position.y]
  if c.state=="arriving" and v.actor.position.distance_to(target)<1:
   state.browse(id);v.actor.reach()
  elif c.state in ["browsing","selected"]:
   c.elapsed+=delta
   if c.state=="browsing" and c.elapsed>=1.5:state.reserve(id)
   if c.state=="selected" and c.elapsed>=4.0:state.queue(id)
   if c.state=="leaving":feedback.text=c.name+(": Over my budget. Copy returned to the shelf." if c.decision=="decline" else ": No copy available. No price decision made.")
  elif c.state=="queued":c.settled=v.actor.position.distance_to(Layout.queue_ports(state.data.layout)[state.data.queue.find(id)])<1
  elif c.state=="leaving" and v.actor.position.distance_to(target)<1:state.gone(id)
  v.held.visible=c.item!="" and c.decision=="buy"
  if c.item!="":v.held.texture=load("res://art/"+State.CATALOG[c.product].art+".png")
  v.label.visible=v.actor.visible
  v.label.position=v.actor.position+Vector2(-35,8)
  v.label.text=c.name+(" · #%d" % (state.data.queue.find(id)+1) if c.state=="queued" else " · Browse" if c.state in ["browsing","selected"] else "")
 refresh()
func capture_tick(delta):
 auto_wait+=delta
 if state.data.phase=="report":
  if report_shown_day!=state.data.day:
   show_assortment();capture_report_dialog=ui.get_children().filter(func(c):return c is AcceptDialog).back();report_shown_day=state.data.day;report_hold=0
  report_hold+=delta
  if report_hold<5.0:auto_wait=0
  elif is_instance_valid(capture_report_dialog):capture_report_dialog.queue_free()
 if pending=="" and path.is_empty() and auto_wait>1.5:
  var action=""
  if state.data.phase=="prep":
   if not state.data.received or not state.pending_shipment().is_empty():action="receive"
   else:
    for product in State.PRODUCTS:
     state.reprice(1999 if product=="tide" else State.CATALOG[product].reference,product)
     state.stock(product)
    trace.append({"action":"assortment","data":state.data.duplicate(true)})
    action="open"
  elif state.data.phase=="open":
   if state.data.clock>30:action="close"
  elif state.data.phase=="closing":
   if selected_action in ["sale","finalize"]:action=selected_action
  elif state.data.phase=="report":
   if auto_step==0 and assortment_demo=="":
    state.save_to(save_path);state.load_from(save_path)
    trace.append({"action":"report-reload","data":state.data.duplicate(true)})
    state.advance(state.data.day);state.order({"curb":2,"tide":2,"orbit":2,"signal":0,"rally":0},state.data.day);restore_view();auto_step=1
   else:
    assert(state.valid())
    trace.append({"action":"capture-final","data":state.data.duplicate(true),"report":state.report()})
    var f=FileAccess.open(capture_dir+"/trace.json",FileAccess.WRITE);f.store_string(JSON.stringify(trace,"  "));f.close();print("R5_CAPTURE ",capture_dir);get_tree().quit();return
  if action!="":request_action(action)
  auto_wait=0
 # Force a draw before reading pixels, including when macOS occludes this test window.
 RenderingServer.force_draw()
 get_viewport().get_texture().get_image().save_png(capture_dir+"/%05d.png"%capture_frame)
 capture_frame+=1

func rebuild_layout():
 for node in fixture_nodes.values():node.queue_free()
 fixture_nodes.clear();cases.clear()
 for id in state.data.layout.fixtures:
  var f=state.data.layout.fixtures[id];var definition=Layout.fixture_definition(f.type)
  var node=Node2D.new();node.position=Layout.origin(f)+Vector2(0,definition.size.y);world.add_child(node);fixture_nodes[id]=node
  var art=sprite(node,definition.art,definition.art_offset-Vector2(0,definition.size.y),.25)
  if f.type=="receiving":box=art
  if f.type=="rack":
   for n in range(4):cases.append({"fixture_id":id,"slot_index":n,"sprite":sprite(node,"case",Layout.SLOT_ANCHORS[n]-Vector2(0,definition.size.y),.17)})
 nav=Layout.navigation(state.data.layout)
func update_rack_select():
 if rack_select==null:return
 var ids=Layout.racks(state.data.layout)
 if selected_rack not in ids:selected_rack=ids[0]
 rack_select.clear()
 for id in ids:rack_select.add_item(id)
 rack_select.select(ids.find(selected_rack))
func begin_layout(operation: String):
 if state.data.phase!="prep":feedback.text="Arrange only during preparation.";return
 if pending!="" or not path.is_empty() or player.reaching:feedback.text="Finish/cancel current action before arranging (click clear floor to cancel).";return
 request_serial+=1
 for id in State.Staff.IDS:State.Staff.cancel(state.data,id,"Layout editing pauses workers")
 draft={"request_id":state.data.run_id+":"+str(Time.get_ticks_usec())+":"+str(request_serial),"phase":"prep","day":state.data.day,"revision":state.data.layout_revision,"operation":operation,"type":"rack","fixture_id":selected_rack,"origin":[440,230] if operation=="expand" else [400,430] if operation=="buy" else state.data.layout.fixtures[selected_rack].origin.duplicate()}
 set_draft_origin(Vector2(draft.origin[0],draft.origin[1]));refresh()
func set_draft_origin(pos: Vector2):
 if draft.operation=="expand":pos=Vector2(440,230)
 draft.origin=[roundi(pos.x/10)*10,roundi(pos.y/10)*10]
 draft_result=state.preview_fixture(draft)
 if draft_result.ok and not Layout.walkable(draft_result.layout,player.position):draft_result={"ok":false,"code":"Placement covers Rowan; cancel and move Rowan first"}
 feedback.text=("EXPAND $100 • " if draft.operation=="expand" else "BUY $60 • " if draft.operation=="buy" else "MOVE FREE • ")+draft_result.code+" • Click floor / arrows • Enter applies • Esc cancels"
 refresh();redraw_layout()
func confirm_layout():
 for w in workers.values():
  if w.actor.visible and draft_result.get("ok",false) and not Layout.walkable(draft_result.layout,w.actor.position):feedback.text="Worker occupies placement; move staff away first.";return
 if draft.is_empty():return
 set_draft_origin(Vector2(draft.origin[0],draft.origin[1]))
 if not draft_result.ok:return
 state.checkpoint_path=save_path
 var expanding=draft.operation=="expand"
 var result=state.commit_fixture(draft)
 if result.ok:
  selected_rack=result.fixture_id;draft.clear();path.clear();pending="";rebuild_layout();update_rack_select()
 feedback.text=result.code+" • Cash "+money(state.data.cash)+" • "+str(state.capacity())+" slots"
 if result.ok and expanding:feedback.text+=" • "+save_feedback()
 refresh();redraw_layout()
func cancel_layout():
 draft.clear();draft_result.clear();feedback.text="Layout preview canceled. Cash, copies and fixtures unchanged.";refresh();redraw_layout()
func browse_destination(buyer) -> Dictionary:
 var definition=buyer if buyer is Dictionary else {"product":buyer,"accept_used":true}
 var ids=[]
 for copy_id in state.ordered_copy_ids():
  var item=state.data.items[copy_id]
  if item.location=="shelf" and state.eligible(item,definition) and item.fixture_id not in ids:ids.append(item.fixture_id)
 # Missing-product shoppers still physically inspect a rack before recording a stock miss.
 if ids.is_empty():ids=Layout.racks(state.data.layout)
 else:ids=ids.slice(0,1)
 for id in ids:
  for port in ["browse-0","browse-1"]:
   if not state.data.customers.values().any(func(c):return c.state in ["arriving","browsing","selected"] and c.get("browse_fixture")==id and c.get("browse_port")==port):return {"fixture_id":id,"port":port}
 return {}
func draw_layout():
 if state==null:return
 if state.data.phase=="prep":
  for id in Layout.racks(state.data.layout):
   var f=state.data.layout.fixtures[id]
   layout_overlay.draw_rect(Layout.footprint(f),Color(0.2,0.5,0.7,0.8) if id==selected_rack else Color(0.2,0.5,0.7,0.3),false,2)
   if id==selected_rack:
    for anchor in Layout.SLOT_ANCHORS:layout_overlay.draw_rect(Rect2(Layout.origin(f)+anchor,Vector2(28,38)),Color(0.2,0.55,0.8,0.8),false,2)
 if not draft.is_empty():
  var pos=Vector2(draft.origin[0],draft.origin[1]);var color=Color(0.1,0.75,0.35,0.5) if draft_result.get("ok",false) else Color(0.9,0.18,0.1,0.5)
  layout_overlay.draw_texture_rect(load("res://art/retail-shelf-empty.png"),Rect2(pos+Layout.fixture_definition("rack").art_offset,load("res://art/retail-shelf-empty.png").get_size()*.25),false,color)
  layout_overlay.draw_rect(Rect2(pos,Vector2(260,40)),color,false,4)

func redraw_layout():
 if layout_overlay!=null:layout_overlay.queue_redraw()

func show_staff():
 if not draft.is_empty():return
 var dialog=AcceptDialog.new();dialog.title="Employees · available from day 3 preparation";dialog.theme=GlassUI.make_theme();dialog.min_size=Vector2i(810,300)
 var box_ui=VBoxContainer.new();box_ui.add_theme_constant_override("separation",16);dialog.add_child(box_ui)
 var info=Label.new();info.text="Hire commits $12 today, even if dismissed or idle. Returning staff commit on Open.\nDismiss before opening to avoid a new day's wage. Roles never refund commitments.";info.add_theme_font_size_override("font_size",16);box_ui.add_child(info)
 for id in State.Staff.IDS:
  var row=HBoxContainer.new();row.add_theme_constant_override("separation",10);box_ui.add_child(row)
  var title=Label.new();title.custom_minimum_size.x=250;title.text=id.capitalize()+" · "+state.data.staff[id].role+"\n"+workers[id].status;title.add_theme_font_size_override("font_size",14);title.tooltip_text=workers[id].status;row.add_child(title)
  var hire_button=Button.new();hire_button.text="Dismiss" if state.data.staff[id].employed else "Hire · $12 today";hire_button.disabled=state.data.phase!="prep" or state.data.day<3;row.add_child(hire_button)
  hire_button.pressed.connect(func():
   if state.data.staff[id].employed:state.dismiss(id);dialog.hide();dialog.queue_free();show_staff()
   else:
    dialog.hide()
    var confirm=ConfirmationDialog.new();confirm.title="Hire "+id.capitalize();confirm.dialog_text="Commit $12 for today, payable at close, even if idle or dismissed?";confirm.theme=GlassUI.make_theme();ui.add_child(confirm)
    confirm.confirmed.connect(func():state.hire(id);confirm.hide();confirm.queue_free();dialog.hide();dialog.queue_free();show_staff());confirm.canceled.connect(func():confirm.queue_free();dialog.show());confirm.popup_centered(Vector2i(650,180)))
  var role=OptionButton.new()
  for value in State.Staff.ROLES:role.add_item(value.capitalize())
  role.select(State.Staff.ROLES.find(state.data.staff[id].role));role.disabled=not state.data.staff[id].employed or state.data.phase not in ["prep","open"];row.add_child(role)
  role.item_selected.connect(func(n):state.assign(id,State.Staff.ROLES[n]);feedback.text=id.capitalize()+" → "+State.Staff.ROLES[n]+". Today's commitment retained.";dialog.hide();dialog.queue_free();show_staff())
  var take=Button.new();take.text="Take over";take.disabled=State.Staff.job(state.data,id).is_empty() or pending!="";row.add_child(take)
  take.pressed.connect(func():
   var j=state.take_over(id)
   if not j.is_empty():
    pending=j.kind;pending_copy=j.copy;pending_fixture=j.fixture;pending_slot=j.slot;pending_customer=j.customer;pending_revision=j.revision;pending_product=state.data.items[j.copy].product;pending_copy_snapshot=state.data.items[j.copy].duplicate(true)
    pending_target=station("receive" if j.kind=="stock" else "sale",j.fixture);var routed=route(player.position,pending_target);path=routed.points;path_reachable=routed.reachable
    feedback.text="Rowan took over unfinished work. Travel to the station to complete it."
   dialog.queue_free())
 ui.add_child(dialog);dialog.confirmed.connect(dialog.queue_free);dialog.popup_centered()

func bodies() -> Array:
 var result=[player]
 for v in visitors.values()+workers.values()+[seller_view]:
  if v.actor.visible:result.append(v.actor)
 return result
func dynamic_route(actor,target: Vector2,allow_staging: bool=true) -> Dictionary:
 var cells=[]
 for other in bodies():
  if other==actor:continue
  var center=Vector2i((other.position/10).round())
  for x in range(center.x-3,center.x+4):
   for y in range(center.y-3,center.y+4):
    var cell=Vector2i(x,y)
    if nav.is_in_boundsv(cell) and Vector2(cell*10).distance_to(other.position)<28 and not nav.is_point_solid(cell):nav.set_point_solid(cell);cells.append(cell)
 var result=route(actor.position,target)
 if not result.reachable and allow_staging:
  # A occupied work port is a wait, not a remote arrival. Approach a free staging cell.
  for offset in [Vector2(0,40),Vector2(-40,0),Vector2(40,0),Vector2(0,-40),Vector2(-40,40),Vector2(40,40)]:
   var staging=target+offset
   if actor.position.distance_to(staging)<20:continue
   var alternative=route(actor.position,staging)
   if alternative.reachable:result=alternative;break
 for cell in cells:nav.set_point_solid(cell,false)
 return result
func worker_move(actor,target: Vector2,delta: float) -> Vector2:
 if actor.reaching or actor.position.distance_to(target)<1 or yield_to_queue(actor):return Vector2.ZERO
 var routed=dynamic_route(actor,target)
 if not routed.reachable:return Vector2.ZERO
 var points=routed.points
 if points.size()>1 and actor.position.distance_to(points[0])<8 and clear_segment(actor,points[1]):points.remove_at(0)
 if points.is_empty():return Vector2.ZERO
 var next=actor.position.move_toward(points[0],80*delta)
 for other in bodies():
  if other!=actor and next.distance_to(other.position)<28:return Vector2.ZERO
 var movement=(next-actor.position).normalized();actor.position=next
 return movement
func update_workers(delta):
 for id in State.Staff.IDS:
  var w=workers[id];var employed=state.data.staff[id].employed
  if not employed:
   w.actor.visible=false;w.label.visible=false;w.spawned=false;w.status="Not hired";continue
  if not w.spawned:
   # Wait for a legal receiving-access spawn; never overlap a restored customer/player.
   for p in [Vector2(380,450),Vector2(380,490),Vector2(380,410)]:
    if Layout.walkable(state.data.layout,p) and bodies().all(func(a):return a.position.distance_to(p)>=32):
     w.actor.position=p;w.spawned=true;w.actor.visible=true;break
   if not w.spawned:w.status="Waiting for receiving access";continue
  var j=State.Staff.job(state.data,id)
  var role=state.data.staff[id].role
  var rest=Vector2(240,340 if id=="morgan" else 390)
  # Layouts may cover a rest point. Choose another legal cell without moving instantly.
  if not Layout.walkable(state.data.layout,rest):rest=Vector2(200,340 if id=="morgan" else 390)
  var target=rest
  w.status=("Unassigned · $12 committed" if state.data.wage_commitments.any(func(c):return c.staff_id==id and c.day==state.data.day) else "Unassigned · $12 on Open") if role=="unassigned" else "No work available"
  if j.is_empty() and not w.actor.reaching:
   if role=="stocking" and state.data.phase in ["prep","open"]:
    var slot=state.free_slot()
    w.status="Shelf full / slots claimed" if slot.is_empty() else "No priced backroom stock"
    if not slot.is_empty():
     for copy_id in state.ordered_copy_ids():
      j=state.claim(id,"stock",copy_id,slot.fixture_id,slot.slot_index)
      if not j.is_empty():break
   elif role=="checkout" and state.data.phase in ["open","closing"]:
    w.status="Waiting for settled queue / cashier"
    if not state.data.queue.is_empty():j=state.claim(id,"sale","","",-1,state.data.queue[0])
  if not j.is_empty():
   target=Layout.ports(state.data.layout,"receiving-01").receive if j.kind=="stock" and not j.received else Layout.ports(state.data.layout,j.fixture)["work" if j.kind=="stock" else "cashier"]
   w.status="Receiving → "+j.fixture if j.kind=="stock" and not j.received else "Stocking "+j.fixture if j.kind=="stock" else "Checkout · "+state.data.customers[j.customer].name
  if nav.is_point_solid(Vector2i((target/10).round())):w.status+=" · Waiting for aisle"
  var movement=worker_move(w.actor,target,delta)
  w.actor.pose(movement,delta)
  if w.actor.position.distance_to(target)>=1 and movement==Vector2.ZERO and not w.actor.reaching:w.status+=" · Waiting for aisle"
  if not j.is_empty() and w.actor.position.distance_to(target)<1 and not w.actor.reaching:
   if j.kind=="stock" and not j.received:state.visit_receiving(id,w.actor.position);w.actor.reach()
   elif not j.get("reached",false):j.reached=true;w.actor.reach()
   elif state.complete_job(id,w.actor.position):feedback.text=id.capitalize()+" completed "+("stocking one copy." if j.kind=="stock" else "one sale.")
  w.label.visible=true;w.label.position=w.actor.position+Vector2(-45,10);w.label.text=id.capitalize()+" · "+{"stocking":"Stock","checkout":"Checkout","unassigned":"Idle"}[role]

func update_seller(delta):
 var row=state.seller();var a=seller_view.actor
 if row.is_empty():a.visible=false;seller_view.label.visible=false;return
 if row.motion=="waiting" and state.data.phase=="open" and state.data.clock>=row.arrival:
  if bodies().all(func(b):return b.position.distance_to(Layout.ENTRY)>=80) and not state.data.customers.values().any(func(c):return c.state=="leaving"):
   row.motion="arriving";row.status="arriving";a.position=Layout.ENTRY
 a.visible=row.motion not in ["waiting","gone"]
 if a.visible:
  var target=Layout.ENTRY if row.motion=="leaving" else Layout.ports(state.data.layout,"checkout-01").intake
  var movement=worker_move(a,target,delta);a.pose(movement,delta)
  row.position=[a.position.x,a.position.y]
  if a.position.distance_to(target)<1:
   if row.motion=="arriving":row.motion="intake";row.status="ready";a.reach()
   elif row.motion=="leaving":row.motion="gone";a.visible=false
 seller_view.label.visible=a.visible;seller_view.label.position=a.position+Vector2(-60,12);seller_view.label.text="Seller · "+row.status.capitalize()
 if is_instance_valid(seller_dialog) and row.status in State.Used.DONE:seller_dialog.hide();seller_dialog.queue_free()

func show_seller():
 var row=state.seller()
 if row.is_empty() or not row.inspected or row.status not in ["ready","counter","accepted"]:return
 if is_instance_valid(seller_dialog):seller_dialog.hide();seller_dialog.queue_free()
 var d=AcceptDialog.new();seller_dialog=d;d.title="Seller intake · acquisition only";d.theme=GlassUI.make_theme();d.min_size=Vector2i(730,350)
 var box_ui=VBoxContainer.new();box_ui.add_theme_constant_override("separation",14);d.add_child(box_ui)
 var info=Label.new();box_ui.add_child(info)
 info.text="%s · USED / %s\nSuggested resale %s · Asking %s\nOne initial offer, one seller counter, at most one final offer.\nPurchased copies wait until next preparation, then need a label."%[State.CATALOG[row.product].name,row.condition.capitalize(),money(row.resale),money(row.asking)]
 if state.data.day==7:info.text+="\nDay 7: this copy cannot be resold within this week."
 var id=row.id;var revision=int(row.revision)
 var offer=SpinBox.new();offer.min_value=1;offer.max_value=float(row.asking)/100;offer.step=.01;offer.value=float(row.floor if row.status=="counter" else row.asking)/100;offer.prefix="$ ";box_ui.add_child(offer)
 var send=Button.new();send.text="Send final shop offer" if row.status=="counter" else "Send initial offer";box_ui.add_child(send)
 send.pressed.connect(func():var r=state.seller_offer(id,revision,roundi(offer.value*100));feedback.text=r.code;show_seller())
 if row.status=="counter":
  info.text+="\nSeller counter: "+money(row.floor)
  var accept=Button.new();accept.text="Accept counter · "+money(row.floor);box_ui.add_child(accept)
  accept.pressed.connect(func():var r=state.seller_offer(id,revision,int(row.floor));feedback.text=r.code;show_seller())
 if row.status=="accepted":
  offer.hide();send.hide();info.text+="\nAccepted exactly "+money(row.accepted)+". Nothing paid yet."
  var pay=Button.new();pay.text="Confirm purchase · "+money(row.accepted);box_ui.add_child(pay)
  var command=State.Used.command(state).duplicate(true)
  pay.pressed.connect(func():var r=state.purchase_used(command);feedback.text=r.code;d.hide();d.queue_free();if not r.ok:show_seller())
 var refuse=Button.new();refuse.text="Refuse seller";box_ui.add_child(refuse)
 refuse.pressed.connect(func():feedback.text=state.seller_cancel(id,revision,true).code;d.hide();d.queue_free())
 var cancel=Button.new();cancel.text="Cancel trade";box_ui.add_child(cancel)
 cancel.pressed.connect(func():feedback.text=state.seller_cancel(id,revision).code;d.hide();d.queue_free())
 d.ok_button_text="Leave pending";d.confirmed.connect(d.queue_free);d.canceled.connect(d.queue_free);ui.add_child(d);d.popup_centered()

func show_copies():
 if not draft.is_empty():return
 var d=AcceptDialog.new();d.title="Individual copies · labels and provenance";d.theme=GlassUI.make_theme();d.min_size=Vector2i(1040,440)
 var scroll=ScrollContainer.new();scroll.custom_minimum_size=Vector2(1010,400);d.add_child(scroll)
 var box_ui=VBoxContainer.new();box_ui.size_flags_horizontal=Control.SIZE_EXPAND_FILL;box_ui.add_theme_constant_override("separation",12);scroll.add_child(box_ui)
 var info=Label.new();info.text="Each row is one copy. New product labels never change used labels. Used stock unlocks next prep.\nShelf +1 uses the selected rack and the same work claims as employees.";box_ui.add_child(info)
 var ids=state.ordered_copy_ids().filter(func(id):return state.data.items[id].location!="sold")
 ids.sort_custom(func(a,b):return state.data.items[a].kind=="used" and state.data.items[b].kind!="used")
 for id in ids:
  var item=state.data.items[id];var row=HBoxContainer.new();box_ui.add_child(row)
  var detail=Label.new();detail.custom_minimum_size.x=600;detail.add_theme_font_size_override("font_size",15);row.add_child(detail)
  detail.text="%s · %s / %s · %s\n%s · Cost %s · Label %s%s"%[State.CATALOG[item.product].name,item.kind.to_upper(),item.condition,item.location,id,money(item.cost),money(item.price)," · available day "+str(int(item.available_day)) if item.available_day>state.data.day else ""]
  detail.tooltip_text="Immutable acquisition: "+item.acquisition_id+" · copy "+id
  var field=SpinBox.new();field.min_value=1;field.max_value=99.99;field.step=.01;field.prefix="$ ";field.value=float(item.price if item.price>0 else int(State.CATALOG[item.product].reference*State.Used.GRADES.get(item.condition,100)/100))/100;row.add_child(field)
  var apply=Button.new();apply.text="Label";apply.disabled=state.data.phase!="prep" or item.location not in ["backroom","shelf"] or item.available_day>state.data.day;row.add_child(apply)
  apply.pressed.connect(func():request_action("copy_price",id,roundi(field.value*100));d.queue_free())
  var stock=Button.new();stock.text="Shelf +1";stock.disabled=state.data.phase not in ["prep","open"] or item.location!="backroom" or item.price<100 or item.available_day>state.data.day or state.free_slot(selected_rack).is_empty();row.add_child(stock)
  stock.pressed.connect(func():selected_product=item.product;request_action("stock",id);d.queue_free())
  var back=Button.new();back.text="Return";back.disabled=state.data.phase!="prep" or item.location!="shelf";row.add_child(back)
  back.pressed.connect(func():selected_product=item.product;selected_rack=item.fixture_id;request_action("return",id);d.queue_free())
 d.confirmed.connect(d.queue_free);ui.add_child(d);d.popup_centered()

func sync_visitors():
 if visitors.is_empty():return
 var first="buyer:"+state.data.run_id+":"+str(int(state.data.day))+":1"
 if visitors.keys()[0]==first:return
 var pool=visitors.values();visitors.clear()
 for n in range(pool.size()):
  var v=pool[n];v.actor.visible=false;v.actor.position=Layout.ENTRY
  if v.label!=null:v.label.visible=false
  visitors["buyer:"+state.data.run_id+":"+str(int(state.data.day))+":"+str(n+1)]=v
func show_calendar():
 var dialog=AcceptDialog.new();dialog.title="First-week release calendar & interests";dialog.theme=GlassUI.make_theme()
 var lines=["Signal Harbor · releases day 4 · $16 supply / $30 reference", "Pocket Rally Club · releases day 6 · $10 supply / $24 reference", "", "One paid mixed order in preparation; receive before opening.", "First interest in each title seeks NEW. Repeats accept used grades.", "Budgets are based on new references; a label never guarantees a sale.", ""]
 for day in range(1,8):
  var names=[]
  for product in State.Week.DAYS[day-1]:names.append({"curb":"C","tide":"T","orbit":"O","signal":"S","rally":"R"}[product])
  lines.append("Day %d · %d shoppers · %s"%[day,names.size(),", ".join(names)])
 lines.append("C Curb · T Tidebound · O Orbit · S Signal · R Rally")
 dialog.dialog_text="\n".join(lines);ui.add_child(dialog);dialog.confirmed.connect(dialog.queue_free);dialog.popup_centered(Vector2i(800,430))

func yield_to_queue(actor) -> bool:
 # Yield only to a buyer that can actually advance. Otherwise a waiting Rowan
 # can occupy the buyer's only escape from a rack, creating a permanent stalemate.
 for id in state.data.customers:
  var c=state.data.customers[id]
  if (c.state=="leaving" or (c.state=="queued" and not c.settled)) and visitors.has(id):
   var buyer=visitors[id].actor
   if not buyer.visible or actor.position.distance_to(buyer.position)>=90:continue
   var target=Layout.ENTRY if c.state=="leaving" else Layout.queue_ports(state.data.layout)[state.data.queue.find(id)]
   var routed=dynamic_route(buyer,target,false)
   if not routed.reachable:continue
   var points=routed.points
   if points.size()>1 and buyer.position.distance_to(points[0])<8 and clear_segment(buyer,points[1]):points.remove_at(0)
   if points.is_empty() or buyer.position.distance_to(points[0])<0.1:continue
   var next=buyer.position.move_toward(points[0],2.0)
   if clear_segment(buyer,next):return true
 return false

func clear_segment(actor,to: Vector2) -> bool:
 for other in bodies():
  if other!=actor and Geometry2D.get_closest_point_to_segment(other.position,actor.position,to).distance_to(other.position)<28:return false
 var steps=maxi(1,ceili(actor.position.distance_to(to)/2.0))
 for n in range(1,steps+1):
  if not Layout.walkable(state.data.layout,actor.position.lerp(to,float(n)/steps)):return false
 return true

# B7: presentation/session state is deliberately not part of schema 10.
func checkpoint_info() -> Dictionary:
 if not FileAccess.file_exists(save_path):return {"ok":false,"text":"No checkpoint yet. New week starts with six prepaid copies and $550."}
 var parser=JSON.new()
 if parser.parse(FileAccess.get_file_as_string(save_path))!=OK or not parser.data is Dictionary:return {"ok":false,"text":"Malformed checkpoint. The original file is preserved; New week will use a separate file."}
 if parser.data.get("version")!=10 or parser.data.get("ruleset_id")!="b6-retail-1":return {"ok":false,"text":"Incompatible checkpoint. Requires schema 10 / B6 retail rules. Original preserved; New week uses a separate file."}
 var probe=State.new()
 if not probe.load_from(save_path):return {"ok":false,"text":"Checkpoint failed integrity checks. Original preserved; New week uses a separate file."}
 return {"ok":true,"text":"Last successful checkpoint: "+probe.last_checkpoint_label+" • Cash "+money(probe.data.cash)}
func flow_dialog(title: String, text: String) -> AcceptDialog:
 flow_paused=true
 var d=AcceptDialog.new();d.theme=GlassUI.make_theme();d.title=title;d.dialog_text=text;d.exclusive=true
 ui.add_child(d)
 d.confirmed.connect(func():flow_paused=false;d.queue_free())
 d.canceled.connect(func():flow_paused=false;d.queue_free())
 d.popup_centered(Vector2i(860,300));return d
func show_entry():
 var info=checkpoint_info()
 entry_menu=flow_dialog("Replay Junction • Your first week",info.text+"\n\nRun seven days of an illustrated game shop. Rent: $150 at day-7 close.\nContinue restores only the last successful checkpoint.")
 entry_menu.get_ok_button().hide()
 entry_menu.close_requested.connect(func():call_deferred("show_entry"))
 var resume=entry_menu.add_button("Continue",false,"continue");resume.disabled=not info.ok;entry_menu.set_meta("continue_button",resume)
 entry_menu.set_meta("new_button",entry_menu.add_button("New week",false,"new"))
 entry_menu.add_button("Controls / help",false,"help")
 entry_menu.add_button("Quit",false,"quit")
 entry_menu.custom_action.connect(func(action):
  match action:
   "continue":
    if state.load_from(save_path):session_started=true;entry_menu.hide();entry_menu.queue_free();flow_paused=false;restore_view();refresh();feedback.text=info.text
    else:entry_menu.dialog_text="Continue failed. The checkpoint could not be read or validated. Your current session is unchanged. Check folder access and retry."
   "new":
    if FileAccess.file_exists(save_path):
     var original_path=save_path
     var preserved=State.new()
     if info.ok and preserved.load_from(save_path):state=preserved
     else:
      save_path="user://week-"+str(Time.get_ticks_usec())+".json"

     entry_menu.hide();entry_menu.queue_free();flow_paused=false;confirm_reset(original_path)
    else:session_started=true;entry_menu.hide();entry_menu.queue_free();flow_paused=false;feedback.text="Start here: Receive six prepaid copies. Help explains each step."
   "help":entry_menu.hide();show_help()
   "quit":get_tree().quit()
 )
 if info.ok:resume.grab_focus()
func show_help():
 var context=guide.text
 var d=flow_dialog("Controls / help • Day %d"%state.data.day,context+"\n\nPREPARE: Receive at the box → select title → label new copies → Stock / Shelf +1.\nSupplier: one paid mixed order per prep; receive it before opening.\nOPEN: Serve the settled queue with the shift button. Close stops new admissions;\nfinish admitted buyers and sellers, then finalize and review Finances.\n\nClick floor to walk; WASD / arrows move; E uses the shift action.\nTab / Shift-Tab focus controls; Enter activates; Escape cancels dialogs/layout.\nK saves; L asks before reload; F1 reopens help; Escape opens the menu.\n\nBuyers seek their title and eligible new/used copies; they refuse over-budget labels.\nUsed purchases wait until next prep. Day-7 purchases cannot resell this week.\nStaff from day 3: $12 each per employed day, even idle. Assign a role in Employees.\nStocking needs a priced, available copy and free slot; checkout needs a settled queue.\nAisles and stations must be clear. Releases: days 4 and 6 (Calendar).\nExpansion: $100 from day 5, includes a rack; rearrange during preparation.")
 d.size=Vector2i(980,570)
 d.add_button("Hide / show guidance",false,"guide")
 d.custom_action.connect(func(_a):help_visible=not help_visible;guide.visible=help_visible)
 d.confirmed.connect(func():if is_instance_valid(entry_menu):entry_menu.show();flow_paused=true)
 d.canceled.connect(func():if is_instance_valid(entry_menu):entry_menu.show();flow_paused=true)
func show_pause_menu():
 var d=flow_dialog("Week menu", "Progress since the last successful save is unsaved.\n"+state.last_checkpoint_label+"\nSave and quit preserves inventory, cash and completed transactions.\nUnfinished travel is safely restored as unclaimed work.")
 d.ok_button_text="Return to shop"
 d.set_meta("quit_button",d.add_button("Save and quit",false,"quit"))
 d.set_meta("restart_button",d.add_button("Restart week",false,"restart"))
 d.custom_action.connect(func(action):
  d.hide();d.queue_free();flow_paused=false
  if action=="quit":save_visible(true)
  else:confirm_reset())
func _notification(what):
 if what==NOTIFICATION_WM_CLOSE_REQUEST and is_instance_valid(ui):show_pause_menu()
func save_visible(exit_after: bool=false):
 if saving:return
 saving=true;flow_paused=true;feedback.text="Saving… keep this window open.";save_button.text="Saving…"
 await get_tree().process_frame
 state.checkpoint_path=save_path
 var ok=state.retry_save()
 saving=false;flow_paused=false;refresh();feedback.text=save_feedback()
 var locator_ok=remember_active_path() if ok else false
 if ok and not locator_ok:
  var d=flow_dialog("Continue locator failed • week saved","The week checkpoint was saved, but Continue could not be updated.\nKeep this window open and retry after checking folder access or disk space.\nCheckpoint: "+save_path.get_file())
  d.ok_button_text="Keep playing";d.set_meta("retry_button",d.add_button("Retry save"+(" and quit" if exit_after else ""),false,"retry"))
  d.custom_action.connect(func(_a):d.hide();d.queue_free();flow_paused=false;save_visible(exit_after))
 if ok and locator_ok and exit_after:get_tree().quit()
 elif not ok:
  var d=flow_dialog("Save failed • progress remains here","Could not write the checkpoint. Check folder access or available disk space.\nNo transactions are repeated by Retry. Keep playing retains progress in memory.\nThe existing checkpoint has not been replaced.")
  d.ok_button_text="Keep playing";d.set_meta("retry_button",d.add_button("Retry save"+ (" and quit" if exit_after else ""),false,"retry"))
  d.custom_action.connect(func(_a):d.hide();d.queue_free();flow_paused=false;save_visible(exit_after))
func confirm_reload():
 var info=checkpoint_info()
 var d=ConfirmationDialog.new();d.theme=GlassUI.make_theme();d.title="Reload checkpoint?";d.dialog_text=info.text+"\nUnsaved progress will be discarded. Cancel keeps this session.";d.get_ok_button().disabled=not info.ok
 ui.add_child(d);flow_paused=true
 d.confirmed.connect(func():flow_paused=false;perform("load");d.queue_free())
 d.canceled.connect(func():flow_paused=false;d.queue_free());d.popup_centered(Vector2i(840,200))
func arrange_actor_labels():
 var occupied=[]
 for v in visitors.values()+workers.values()+[seller_view]:
  if not v.label.visible:continue
  var l=v.label
  l.add_theme_font_size_override("font_size",15)
  l.position=Vector2(clampf(v.actor.position.x-l.size.x/2,185,900-l.size.x),clampf(v.actor.position.y-132,220,570))
  for rect in occupied:
   if Rect2(l.position,l.size).grow(3).intersects(rect):l.position.y=rect.end.y+4
  occupied.append(Rect2(l.position,l.size))

func locator_failed(stage: String, code: int) -> bool:
 print("STORAGE_FAILURE ",JSON.stringify({"operation":"locator","stage":stage,"code":code}))
 feedback.text="Week saved, but Continue was not updated. Keep this window open and retry Save. Checkpoint: "+save_path.get_file()
 return false
func remember_active_path() -> bool:
 if not save_path.get_file().begins_with("week-"):return true
 var pointer=FileAccess.open(session_file+".tmp",FileAccess.WRITE)
 if pointer==null:return locator_failed("open_temporary",FileAccess.get_open_error())
 pointer.store_string(save_path.get_file());pointer.flush();var error=pointer.get_error();pointer.close()
 if error!=OK:return locator_failed("write_flush",error)
 error=DirAccess.rename_absolute(session_file+".tmp",session_file)
 if error!=OK:return locator_failed("replace",error)
 return true
