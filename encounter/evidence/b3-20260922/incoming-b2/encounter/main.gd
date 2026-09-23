extends Node2D
const GlassUI=preload("res://glass_ui.gd")
const State = preload("res://state.gd")
const Actor = preload("res://actor.gd")
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

var world: Node2D
var nav = AStarGrid2D.new()
var path = PackedVector2Array()
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
 var l=Label.new();l.text=text;l.position=pos;l.add_theme_font_size_override("font_size",size);l.add_theme_color_override("font_color",color);parent.add_child(l);return l
func button(text: String,pos: Vector2,width: float,action: Callable) -> Button:
 var b=Button.new();b.text=text;b.position=pos;b.size=Vector2(width,44);b.add_theme_font_size_override("font_size",18);b.pressed.connect(action)
 b.theme=GlassUI.make_theme();ui.add_child(b);return b
func panel(pos: Vector2,size: Vector2,_color: Color):
 var p=Panel.new();p.position=pos;p.size=size;p.add_theme_stylebox_override("panel",GlassUI.panel_style());p.mouse_filter=Control.MOUSE_FILTER_IGNORE;ui.add_child(p)

func _ready():
 get_viewport().gui_embed_subwindows=true
 RenderingServer.set_default_clear_color(Color("e8e2d5"))
 texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
 sprite(self,"retail-context",Vector2.ZERO,.25)
 world=Node2D.new();world.y_sort_enabled=true;add_child(world)
 rebuild_layout()
 player=Actor.new();player.position=Layout.SPAWN;world.add_child(player)
 for n in range(3):
  var actor=Actor.new();actor.position=Layout.ENTRY;actor.visible=false;world.add_child(actor)
  actor.modulate=[Color(.98,.83,.77),Color(.77,.90,.98),Color(.90,.91,.73)][n]
  var held=sprite(actor,"case",Vector2(7,-45),.085);held.visible=false
  visitors[State.VISITORS[n]]={"actor":actor,"held":held,"label":null}
 customer=visitors["visitor-1"].actor
 ui=CanvasLayer.new();add_child(ui)
 panel(Vector2(0,0),Vector2(1280,145),Color("f2eddf"))
 label(ui,"REPLAY JUNCTION",Vector2(40,24),32)
 day_label=label(ui,"SATURDAY, 2002  /  YOUR FIRST SHIFT",Vector2(42,68),16,Color("416489"))
 summary=label(ui,"",Vector2(650,30),22)
 guide=label(ui,"",Vector2(42,108),20)
 panel(Vector2(922,158),Vector2(334,476),Color("f9f5e9"))
 label(ui,"SHIFT DESK",Vector2(944,168),21)
 product_select=OptionButton.new();product_select.theme=GlassUI.make_theme();product_select.position=Vector2(944,202);product_select.size=Vector2(288,36);product_select.add_theme_font_size_override("font_size",18)
 for product in State.PRODUCTS:product_select.add_item(State.CATALOG[product].name)
 product_select.item_selected.connect(func(index):selected_product=State.PRODUCTS[index];price_input.value=float(State.CATALOG[selected_product].reference)/100;refresh())
 ui.add_child(product_select)
 details=label(ui,"",Vector2(944,246),18)
 price_input=SpinBox.new();price_input.theme=GlassUI.make_theme();price_input.position=Vector2(944,390);price_input.size=Vector2(288,42);price_input.min_value=1;price_input.max_value=99.99;price_input.step=.01;price_input.value=21.99;price_input.prefix="$ ";price_input.add_theme_font_size_override("font_size",20);ui.add_child(price_input)
 price_input.tooltip_text="Prices apply to the selected product only. Editing alone changes no copy."
 reprice_button=button("Apply price to unsold stock",Vector2(944,340),288,func():request_action("reprice"))
 primary=button("",Vector2(944,440),288,func():request_action(selected_action))
 assortment_button=button("Assortment · 4 shelf spaces",Vector2(944,490),288,show_assortment)
 close_button=button("Close admission",Vector2(944,490),288,func():request_action("close"))
 order_button=button("Order replenishment",Vector2(944,490),288,show_order)
 save_button=button("Save",Vector2(944,540),138,func():perform("save"))
 load_button=button("Reload",Vector2(1094,540),138,func():perform("load"))
 button("New practice shift",Vector2(944,590),288,confirm_reset)
 panel(Vector2(24,634),Vector2(1232,68),Color("293442"))
 feedback=label(ui,"Welcome, Rowan. Receive the three prepaid used games to begin.",Vector2(42,644),18,Color("182338"))
 label(ui,"Click a station or the shift button • WASD / arrows walk • E interact • K save • L reload",Vector2(42,675),16,Color("54647b"))
 panel(Vector2(40,220),Vector2(760,32),Color.WHITE)
 shelf_label=label(ui,"",Vector2(52,224),17)
 for id in visitors:
  visitors[id].label=label(ui,"",Vector2.ZERO,16)
  visitors[id].label.add_theme_color_override("font_shadow_color",Color("fff6dc"))
  visitors[id].label.add_theme_constant_override("shadow_outline_size",3)
 customer_label=visitors["visitor-1"].label
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
 if assortment_demo!="":setup_comparison()
 print("R1_DISPLAY ",JSON.stringify({"window":DisplayServer.window_get_size(),"viewport":get_viewport_rect().size,"screen_scale":DisplayServer.screen_get_scale(),"canvas_scale":get_viewport().get_final_transform().get_scale()}))
 refresh()
func setup_comparison():
 # Separate comparison-only fixture, built through the ordinary paid two-day loop.
 state.receive()
 for product in State.PRODUCTS:
  state.price(1999 if product=="tide" else State.CATALOG[product].reference,product);state.stock(product)
 state.open()
 for id in State.VISITORS:
  state.tick(10);state.arrive(id);state.browse(id);state.reserve(id);state.queue(id);state.data.customers[id].settled=true;state.sale(id);state.gone(id)
 state.close();state.finalize();state.order({"curb":2,"tide":2,"orbit":2},1);state.advance(1);state.receive()
 for product in State.PRODUCTS:state.price({"curb":2199,"tide":1999,"orbit":1299}[product],product)
 state.stock("curb",2);state.stock("tide",1 if assortment_demo=="stocked" else 2)
 if assortment_demo=="stocked":state.stock("orbit")
 trace.append({"action":"comparison-prep","mode":assortment_demo,"data":state.data.duplicate(true)})
 state.open();restore_view()
func confirm_reset():
 var dialog=ConfirmationDialog.new();dialog.theme=GlassUI.make_theme();dialog.dialog_text="Start a fresh practice shift?\nUnsaved progress will be discarded. Your saved shift stays available with Reload.";dialog.title="New practice shift";dialog.confirmed.connect(func():perform("reset"));dialog.confirmed.connect(dialog.queue_free);dialog.canceled.connect(dialog.queue_free);ui.add_child(dialog);dialog.popup_centered(Vector2i(520,150))
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
   detail.text="%s • Buy %s / Ref %s\nShelf %d • Backroom %d • Sold %d • Price misses %d • Stock misses %d\nRevenue %s • Cost %s • Gross profit %s" % [State.CATALOG[product].name,money(State.CATALOG[product].cost),money(State.CATALOG[product].reference),state.count_at("shelf",product),state.count_at("backroom",product),r.sold,r.missed,r.unavailable,money(r.revenue),money(r.cost),money(r.margin)]
   detail.add_theme_font_size_override("font_size",16)
   add.disabled=state.data.phase!="prep" or state.free_slot(selected_rack).is_empty() or not state.data.items.values().any(func(i):return i.product==product and i.location=="backroom" and i.price>0)
   remove.disabled=state.data.phase!="prep" or not state.data.items.values().any(func(i):return i.product==product and i.location=="shelf" and i.fixture_id==selected_rack)
  if state.data.phase=="report":add.hide();remove.hide()
  refresh_rows.append(update)
  add.pressed.connect(func():
   selected_product=product;request_action("stock");dialog.queue_free())
  remove.pressed.connect(func():
   selected_product=product;request_action("return");dialog.queue_free())
 info.text="Selected: "+selected_rack+" • Four slots per rack. Choose a copy, then Rowan walks to the rack.\nReturn keeps the copy’s price and cost. Select racks on the shop toolbar."
 if state.data.phase=="report":info.text="Day %d • Revenue %s • Gross profit %s • Cash %s\nReview sales and misses before choosing the next shipment."%[state.data.day,money(state.report().revenue),money(state.report().margin),money(state.data.cash)]
 for_update(refresh_rows)
 dialog.confirmed.connect(dialog.queue_free);dialog.canceled.connect(dialog.queue_free);ui.add_child(dialog);dialog.popup_centered()
func for_update(callbacks):
 for callback in callbacks:callback.call()
func show_order():
 if state.data.phase != "report": return
 var order_day=state.data.day
 var dialog=ConfirmationDialog.new();dialog.title="Replenish • compare three games";dialog.ok_button_text="Pay & place order"
 dialog.theme=GlassUI.make_theme();dialog.theme.default_font_size=20
 var content=VBoxContainer.new();content.add_theme_constant_override("separation",12);dialog.add_child(content)
 var fields={}
 for product in State.PRODUCTS:
  var row=HBoxContainer.new();content.add_child(row)
  var info=Label.new();info.text="%s  • Buy %s / Ref %s"%[State.CATALOG[product].name,money(State.CATALOG[product].cost),money(State.CATALOG[product].reference)];info.custom_minimum_size.x=540;row.add_child(info)
  var quantity=SpinBox.new();quantity.min_value=0;quantity.max_value=6;quantity.step=1;quantity.custom_minimum_size=Vector2(110,44);row.add_child(quantity);fields[product]=quantity
 var total_label=Label.new();content.add_child(total_label)
 var update=func(_v=0):
  var total=0
  for product in State.PRODUCTS:total+=int(fields[product].value)*State.CATALOG[product].cost
  total_label.text="Cash %s • Total %s • After payment %s\nArrives day %d • One mixed order per day"%[money(state.data.cash),money(total),money(state.data.cash-total),order_day+1]
  dialog.get_ok_button().disabled=total==0 or total>state.data.cash or not state.pending_shipment().is_empty()
 for field in fields.values():field.value_changed.connect(update)
 update.call()
 dialog.confirmed.connect(func():
  var quantities={}
  for product in State.PRODUCTS:quantities[product]=int(fields[product].value)
  var ok=state.order(quantities,order_day)
  feedback.text="Mixed order paid once. Advance to receive it." if ok else "Order rejected. Check cash and quantities."
  trace.append({"action":"order","ok":ok,"quantities":quantities,"cash":state.data.cash});refresh();dialog.queue_free())
 dialog.canceled.connect(dialog.queue_free);ui.add_child(dialog);dialog.popup_centered(Vector2i(750,300))
func show_advance():
 if state.data.phase != "report": return
 var closing_day = state.data.day
 var dialog = ConfirmationDialog.new();dialog.theme=GlassUI.make_theme();dialog.theme.default_font_size=20;dialog.title="Start the next day"
 dialog.dialog_text="Advance to day %d?\nUnsold stock, prices and cash carry forward.\nDaily sales reset; paid orders arrive at receiving." % (closing_day+1)
 dialog.confirmed.connect(func():
  var ok=state.advance(closing_day)
  if ok:restore_view()
  feedback.text="New day. Receive any paid shipment, price and stock, then open." if ok else "Day already advanced."
  trace.append({"action":"advance","ok":ok,"day":state.data.day});refresh();dialog.queue_free())
 dialog.canceled.connect(dialog.queue_free);ui.add_child(dialog);dialog.popup_centered(Vector2i(550,170))
func route(from: Vector2,to: Vector2) -> Dictionary:
 var a=Vector2i((from/10).round());var b=Vector2i((to/10).round())
 if not nav.is_in_boundsv(a) or not nav.is_in_boundsv(b) or nav.is_point_solid(b):return {"reachable":false,"points":PackedVector2Array()}
 var points=nav.get_point_path(a,b)
 return {"reachable":not points.is_empty(),"points":points}
func station(action: String,fixture_id: String = "") -> Vector2:
 if fixture_id=="":fixture_id=selected_rack
 if action in ["receive","price","reprice"]:return Layout.ports(state.data.layout,"receiving-01").receive
 if action in ["stock","return"]:return Layout.ports(state.data.layout,fixture_id).get("work",Vector2(-100,-100))
 if action in ["sale","open","close"]:return Layout.ports(state.data.layout,"checkout-01").cashier
 return player.position
func request_action(action: String):
 if not draft.is_empty():feedback.text="Confirm or cancel the layout preview first.";return
 if pending!="":feedback.text="Finish/cancel current action first (click clear floor to cancel).";return
 if action=="advance":show_advance();return
 if action=="order":show_order();return
 if action=="wait":feedback.text="Customers browse independently. Serve the front of the checkout queue.";return
 pending_product=selected_product;pending_cents=roundi(price_input.value*100)
 pending_fixture=selected_rack;pending_revision=state.data.layout_revision;pending_copy="";pending_slot=-1
 if action in ["stock","return"]:
  for id in state.ordered_copy_ids():
   var item=state.data.items[id]
   if item.product==pending_product and ((action=="stock" and item.location=="backroom" and item.price>0) or (action=="return" and item.location=="shelf" and item.fixture_id==pending_fixture)):
    pending_copy=id;break
  if action=="stock":
   var slot=state.free_slot(pending_fixture)
   if not slot.is_empty():pending_slot=slot.slot_index
  if pending_copy=="" or (action=="stock" and pending_slot<0):feedback.text="No eligible copy or free slot on "+pending_fixture;return
 pending_copy_snapshot=state.data.items[pending_copy].duplicate(true) if pending_copy!="" else {}
 pending_customer=state.data.queue[0] if action=="sale" and not state.data.queue.is_empty() else ""
 pending_target=station(action,pending_fixture)
 var result=route(player.position,pending_target)
 path_reachable=result.reachable
 if not path_reachable:feedback.text="Unreachable station. Rearrange during preparation.";return
 pending=action;path=result.points;feedback.text="Rowan → "+{"receive":"receiving","price":"price labels","stock":pending_fixture,"return":pending_fixture,"sale":"checkout","open":"register","close":"register"}.get(action,action)
func perform(action: String, product: String = "", cents: int = 0):
 if not draft.is_empty() and action not in ["save","load","reset"]:return
 if product=="":product=selected_product
 if cents==0:cents=roundi(price_input.value*100)
 var ok=false
 if action in ["stock","return","sale"]:
  if pending_revision!=state.data.layout_revision or player.position.distance_to(station(action,pending_fixture))>=1:feedback.text="Return to the requested station before acting.";return
  if action!="sale" and (not state.data.items.has(pending_copy) or state.data.items[pending_copy]!=pending_copy_snapshot):feedback.text="Copy changed; request the action again.";return
 if action in ["load","reset"]:draft.clear();draft_result.clear()
 match action:
  "receive":ok=state.receive()
  "price":ok=state.price(cents,product)
  "reprice":ok=state.reprice(cents,product)
  "stock":
   ok=state.stock_copy(pending_copy,pending_fixture,pending_slot,pending_revision)
   if ok:player.reach()
  "return":ok=state.return_copy(pending_copy)
  "open":ok=state.open()
  "sale":
   if not state.data.queue.is_empty() and state.data.queue[0]==pending_customer:ok=state.sale(pending_customer)
  "close":ok=state.close()
  "finalize":ok=state.finalize()
  "save":ok=state.save_to(save_path)
  "load":
   ok=state.load_from(save_path)
   if ok:restore_view()
  "reset":state.reset();restore_view();ok=true
 feedback.text={"return":"Copy returned to backroom; cost and label retained.","receive":"Shipment received once. Price the new copies at the shift desk.","reprice":"Unsold copies repriced. Higher prices can lose buyers; lower prices reduce margin.","price":"Price labels ready. Stock the priced copies on the used-game shelf.","stock":"Priced copies on display. Open the shop when you’re ready.","open":"OPEN. Three visitors arrive in a staggered wave.","sale":"Sale complete. Remaining stock and cash updated.","close":"Admission closed. Existing customers may finish browsing and buying.","finalize":"Day finalized. Sales are now locked; review and replenish.","save":"Shift saved. Reload restores this exact business state.","load":"Saved shift restored. Inventory, reservations and cash agree.","reset":"Fresh practice shift. Your previous save is still available."}.get(action,action) if ok else ("Cannot load: malformed or unsupported checkpoint. This build supports schema 6 only; New practice shift is separate." if action=="load" else "Cannot do that now. Follow the current shift step.")
 trace.append({"action":action,"ok":ok,"report":state.report(),"phase":state.data.phase})
 print("R1_ACTION ",JSON.stringify(trace.back()))
 refresh()
func restore_view():
 path.clear();pending="";draft.clear();player.position=Layout.ports(state.data.layout,"checkout-01").cashier;rebuild_layout();update_rack_select();redraw_layout()
 for id in visitors:
  visitors[id].actor.visible=false
  if state.data.customers.has(id):
   var c=state.data.customers[id]
   visitors[id].actor.position=Vector2(c.position[0],c.position[1])
 var copies=state.data.items.values().filter(func(i):return i.product==selected_product and i.location!="sold" and i.price>0)
 price_input.value=float(copies[0].price if not copies.is_empty() else State.CATALOG[selected_product].reference)/100

func refresh():
 details.add_theme_font_size_override("font_size",16 if state.data.phase=="report" else 18)
 details.size=Vector2.ZERO
 var r=state.report()
 day_label.text=("ASSORTMENT COMPARISON · "+assortment_demo.to_upper()+" • " if assortment_demo!="" else "")+"DAY %d  /  MALL SHOP • 2002" % state.data.day
 summary.text="%s   •   Cash %s" % [state.data.phase.to_upper(),money(r.cash)]
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
 order_button.visible=state.data.phase=="report"
 if state.data.phase=="report":
  shelf_label.text="Shop capacity: %d slots • Rack investment paid: %s"%[state.capacity(),money(r.investment)]
  var shipment=state.pending_shipment()
  guide.text="Shift complete • Order within your cash, then advance to day %d." % (state.data.day+1)
  if not shipment.is_empty():guide.text="Paid shipment: %d copies • Arrives day %d • Advance, then receive at the box." % [shipment.quantity,shipment.day+1]
  details.tooltip_text="Rack investment paid: "+money(r.investment)+". Revenue: today’s completed sales. Inventory cost: historical purchase cost of each sold copy. Gross profit: revenue minus that cost, before overhead. Orders reduce cash, not profit, until sold."
  details.text="DAY %d • %d sold • %d price misses\n%d stock misses\nRevenue              %s\nInventory cost     %s\nGross profit          %s\nUnsold copies       %d\nCash available      %s"%[state.data.day,r.sold,r.missed,r.unavailable,money(r.revenue),money(r.cost),money(r.margin),r.remaining,money(r.cash)]
  primary.visible=true;primary.text="Advance to day %d" % (state.data.day+1);selected_action="advance"
  order_button.disabled=not shipment.is_empty()
  return
 primary.visible=true
 var prices=[]
 for item in state.data.items.values():
  if item.product==selected_product and item.location != "sold" and item.price > 0 and not prices.has(item.price):prices.append(item.price)
 prices.sort()
 var price_text="Set selling price" if prices.is_empty() else money(prices[0])+" each"
 if prices.size()>1:price_text=money(prices[0])+" – "+money(prices.back())+" labels"
 details.text="%s • Buy %s\nReference %s • Buyers vary\nShelf %d  •  Backroom %d"%[price_text,money(State.CATALOG[selected_product].cost),money(State.CATALOG[selected_product].reference),state.count_at("shelf",selected_product),state.count_at("backroom",selected_product)]
 if state.data.phase in ["open","closing"]:
  var lines=[]
  for id in state.data.customers:
   var c=state.data.customers[id]
   var status={"waiting":"Due shortly","arriving":"Arriving","browsing":"Browsing","selected":"Considering price","queued":"Queue #%d" % (state.data.queue.find(id)+1),"leaving":"Leaving","gone":"Left","cancelled":"Admission closed"}.get(c.state,c.state)
   if c.decision=="decline":status="Price declined"
   if c.decision=="unavailable":status="No stock available"
   if c.decision=="buy" and c.item=="":status="Purchased" if state.data.sales.any(func(row):return row.day==state.data.day and row.customer==id) else "Departed"
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
  guide.text="Admission closed • Finish existing customers, then finalize the day." if state.data.phase=="closing" else "Three visitors • Serve the numbered queue. Close admission whenever you choose."
 elif not state.data.received or not state.pending_shipment().is_empty():selected_action="receive";primary.text="Receive %d copies" % (3 if not state.data.received else state.pending_shipment().quantity);guide.text="1 / 7  •  Receive the shipment at the box."
 else:
  selected_action="open";primary.text="Open the shop"
  reprice_button.text="Label / reprice this product"
  guide.text="Prep • Choose a product, apply its price, then use Assortment to stock or return copies."
func move_actor(who,points: PackedVector2Array,delta: float,speed: float) -> Vector2:
 if points.is_empty():return Vector2.ZERO
 var target=points[0];var dir=(target-who.position).normalized();who.position=who.position.move_toward(target,speed*delta)
 if who.position.distance_to(target)<.1:points.remove_at(0)
 return dir
func _unhandled_input(event):
 if not draft.is_empty():
  if event is InputEventKey and event.pressed and not event.echo:
   match event.keycode:
    KEY_ESCAPE:cancel_layout()
    KEY_ENTER,KEY_KP_ENTER:confirm_layout()
    KEY_LEFT,KEY_RIGHT,KEY_UP,KEY_DOWN:
     var offset={KEY_LEFT:Vector2(-10,0),KEY_RIGHT:Vector2(10,0),KEY_UP:Vector2(0,-10),KEY_DOWN:Vector2(0,10)}[event.keycode]
     set_draft_origin(Vector2(draft.origin[0],draft.origin[1])+offset)
  if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT and event.position.x<910 and event.position.y>=300:set_draft_origin(event.position-Vector2(130,20))
  return
 if event is InputEventKey and event.pressed and not event.echo:
  match event.keycode:
   KEY_E:request_action(selected_action)
   KEY_K:perform("save")
   KEY_L:perform("load")
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
  elif Layout.floor_bounds().has_point(p):
   var result=route(player.position,p);path=result.points;path_reachable=result.reachable;pending=""
func _process(delta):
 if player==null:return
 if not draft.is_empty():return
 var dir=Vector2(float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT))-float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)),float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN))-float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP))).normalized()
 if price_input.get_line_edit().has_focus():dir=Vector2.ZERO
 if dir!=Vector2.ZERO:
  path.clear();pending=""
  var next=player.position+dir*110*delta
  var blocked=false
  for block in Layout.obstacles(state.data.layout):
   if block.grow(Layout.RADIUS).has_point(next):blocked=true
  for v in visitors.values():
   if v.actor.visible and next.distance_to(v.actor.position)<28:blocked=true
  if not blocked:player.position=next.clamp(Layout.floor_bounds().position,Layout.floor_bounds().end-Vector2(10,10))
  else:dir=Vector2.ZERO
 elif not player.reaching:
  var clear=true
  if not path.is_empty():
   var next=player.position.move_toward(path[0],110*delta)
   for v in visitors.values():
    if v.actor.visible and next.distance_to(v.actor.position)<28:clear=false
  if clear:dir=move_actor(player,path,delta,110)
  elif pending!="":feedback.text="Rowan: Waiting for aisle"
 player.pose(dir,delta)
 if path.is_empty() and pending!="" and path_reachable and player.position.distance_to(pending_target)<1:
  var action=pending;pending=""
  if pending_revision==state.data.layout_revision:perform(action,pending_product,pending_cents)
  else:feedback.text="Layout changed; request the action again."
 update_wave(delta)
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
   if door_clear and state.data.clock>=c.arrival:
    var destination=browse_destination(c.product)
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
   for other in visitors.values():
    if other==v or not other.actor.visible:continue
    for x in range(nav.region.position.x,nav.region.end.x):
     for y in range(nav.region.position.y,nav.region.end.y):
      var cell=Vector2i(x,y)
      if Vector2(cell*10).distance_to(other.actor.position)<28 and not nav.is_point_solid(cell):
       nav.set_point_solid(cell);blocked_cells.append(cell)
   var routed=route(v.actor.position,target)
   var points=routed.points
   for cell in blocked_cells:nav.set_point_solid(cell,false)
   if points.size()>1 and v.actor.position.distance_to(points[0])<8:points.remove_at(0)
   if not routed.reachable:feedback.text=c.name+": Waiting for aisle"
   if routed.reachable:
    var next=v.actor.position.move_toward(points[0],80*delta)
    var clear=true
    for other in visitors.values():
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
    state.order({"curb":2,"tide":2,"orbit":2},state.data.day);state.advance(state.data.day);restore_view();auto_step=1
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
 draft={"request_id":state.data.run_id+":"+str(Time.get_ticks_usec())+":"+str(request_serial),"phase":"prep","day":state.data.day,"revision":state.data.layout_revision,"operation":operation,"type":"rack","fixture_id":selected_rack,"origin":[400,430] if operation=="buy" else state.data.layout.fixtures[selected_rack].origin.duplicate()}
 set_draft_origin(Vector2(draft.origin[0],draft.origin[1]));refresh()
func set_draft_origin(pos: Vector2):
 draft.origin=[roundi(pos.x/10)*10,roundi(pos.y/10)*10]
 draft_result=state.preview_fixture(draft)
 if draft_result.ok and not Layout.walkable(draft_result.layout,player.position):draft_result={"ok":false,"code":"Placement covers Rowan; cancel and move Rowan first"}
 feedback.text=("BUY $60 • " if draft.operation=="buy" else "MOVE FREE • ")+draft_result.code+" • Click floor / arrows • Enter applies • Esc cancels"
 refresh();redraw_layout()
func confirm_layout():
 if draft.is_empty():return
 set_draft_origin(Vector2(draft.origin[0],draft.origin[1]))
 if not draft_result.ok:return
 var result=state.commit_fixture(draft)
 if result.ok:
  selected_rack=result.fixture_id;draft.clear();path.clear();pending="";rebuild_layout();update_rack_select()
 feedback.text=result.code+" • Cash "+money(state.data.cash)+" • "+str(state.capacity())+" slots"
 refresh();redraw_layout()
func cancel_layout():
 draft.clear();draft_result.clear();feedback.text="Layout preview canceled. Cash, copies and fixtures unchanged.";refresh();redraw_layout()
func browse_destination(product: String) -> Dictionary:
 var ids=[]
 for item in state.data.items.values():
  if item.location=="shelf" and item.product==product and item.fixture_id not in ids:ids.append(item.fixture_id)
 # Missing-product shoppers still physically inspect a rack before recording a stock miss.
 if ids.is_empty():ids=Layout.racks(state.data.layout)
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
