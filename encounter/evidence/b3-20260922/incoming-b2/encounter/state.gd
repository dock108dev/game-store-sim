extends RefCounted
# R1 owns physical copies, never product-level reservations. Money is integer cents.
const Layout=preload("res://layout.gd")
var data: Dictionary
var checked_layout={}
var layout_ok=false
func _init():
 reset()
func reset():
 data = {"version":6,"clock":0.0,"queue":[],"decisions":[],"day":1,"orders":[],"phase":"prep","received":false,"cash":55000,"items":{},"customers":{},"sales":[],"carried":""}
 data.merge({"run_id":str(Time.get_unix_time_from_system())+"-"+str(Time.get_ticks_usec()),"ruleset_id":"b2-layout-1","opening_cash":55000,"layout":Layout.initial(),"layout_revision":0,"next_fixture_id":2,"next_event_seq":1,"fixture_events":[],"events":[],"fulfilled_requests":{}})
const PRODUCTS = ["curb", "tide", "orbit"]
const CATALOG = {
 "curb":{"name":"Curb Circuit 02","cost":800,"reference":2199,"art":"case"},
 "tide":{"name":"Tidebound Atlas","cost":1200,"reference":2799,"art":"case-tide"},
 "orbit":{"name":"Orbit Orchard","cost":500,"reference":1499,"art":"case-orbit"}}
func ordered_copy_ids() -> Array:
 var ids=data.items.keys()
 ids.sort_custom(func(a,b):return data.items[a].acquisition_seq<data.items[b].acquisition_seq if data.items[a].acquisition_seq!=data.items[b].acquisition_seq else a<b)
 return ids
func record_event(id: String,kind: String,amount: int,reference: String) -> Dictionary:
 var event={"id":id,"kind":kind,"day":data.day,"amount":amount,"reference":reference,"seq":data.next_event_seq,"status":"paid"}
 data.events.append(event);data.next_event_seq+=1
 return event
func capacity() -> int:return Layout.capacity(data.layout)
func free_slot(fixture_id="") -> Dictionary:
 for slot in Layout.slot_ids(data.layout):
  if fixture_id!="" and slot.fixture_id!=fixture_id:continue
  if not data.items.values().any(func(i):return i.fixture_id==slot.fixture_id and i.slot_index==slot.slot_index):return slot
 return {}
func stock_copy(copy_id: String,fixture_id: String,slot_index: int,expected_revision: int) -> bool:
 if data.phase!="prep" or expected_revision!=data.layout_revision or not data.items.has(copy_id):return false
 var slot={"fixture_id":fixture_id,"slot_index":slot_index}
 var item=data.items[copy_id]
 if slot not in Layout.slot_ids(data.layout) or item.location!="backroom" or item.price<100:return false
 if data.items.values().any(func(i):return i.fixture_id==fixture_id and i.slot_index==slot_index):return false
 item.location="shelf";item.fixture_id=fixture_id;item.slot_index=slot_index
 return true
func return_copy(copy_id: String) -> bool:
 if data.phase!="prep" or not data.items.has(copy_id):return false
 var item=data.items[copy_id]
 if item.location!="shelf" or item.owner!="":return false
 item.location="backroom";item.fixture_id=null;item.slot_index=null
 return true
func preview_fixture(command: Dictionary) -> Dictionary:
 var fail=func(code):return {"ok":false,"code":code,"fixture_id":"","revision":data.layout_revision}
 if data.phase!="prep":return fail.call("Arrange only during preparation")
 if command.get("phase")!=data.phase or command.get("day")!=data.day or command.get("revision")!=data.layout_revision:return fail.call("Stale layout request")
 if not command.get("request_id") is String or command.request_id.is_empty():return fail.call("Missing request identity")
 var id=command.get("fixture_id","")
 if command.get("operation")=="buy":
  if command.get("type")!="rack":return fail.call("Unknown fixture type")
  if data.layout.fixtures.has("rack-0002"):return fail.call("Rack limit reached")
  if data.cash<6000:return fail.call("Not enough cash")
  id="rack-0002"
 elif command.get("operation")=="move":
  if not data.layout.fixtures.has(id):return fail.call("Unknown fixture")
  if data.layout.fixtures[id].type!="rack":return fail.call("Fixed station cannot move")
 else:return fail.call("Unknown layout operation")
 var pos=command.get("origin")
 if not pos is Array or pos.size()!=2:return fail.call("Invalid origin")
 for v in pos:
  if not v is int or v%10!=0:return fail.call("Use integer 10px grid coordinates")
 var candidate=data.layout.duplicate(true)
 candidate.fixtures[id]={"type":"rack","origin":pos.duplicate()}
 var checked=Layout.check(candidate)
 if not checked.ok:return fail.call(checked.reason)
 return {"ok":true,"code":"Placement valid","fixture_id":id,"revision":data.layout_revision,"layout":candidate}
func commit_fixture(command: Dictionary) -> Dictionary:
 var request=command.get("request_id","")
 if data.fulfilled_requests.has(request):return {"ok":true,"code":"Already applied","fixture_id":data.fulfilled_requests[request].fixture_id,"revision":data.layout_revision}
 var result=preview_fixture(command)
 if not result.ok:return result
 data.layout=result.layout
 data.layout_revision+=1
 if command.operation=="buy":
  data.cash-=6000;data.next_fixture_id=3
  var event=record_event("fixture:"+data.run_id+":rack-0002","fixture_purchase",6000,"rack-0002")
  data.fixture_events.append({"id":event.id,"kind":event.kind,"day":event.day,"amount":event.amount,"fixture_id":"rack-0002","seq":event.seq})
 data.fulfilled_requests[request]={"fixture_id":result.fixture_id,"revision":data.layout_revision,"operation":command.operation}
 return {"ok":true,"code":"Rack purchased" if command.operation=="buy" else "Rack moved","fixture_id":result.fixture_id,"revision":data.layout_revision}

func preference(day: int, customer: String) -> String:
 return PRODUCTS[(day-1+maxi(VISITORS.find(customer),0))%3]
func receive() -> bool:
 if data.phase != "prep": return false
 if not data.received:
  data.received=true
  for n in range(3):
   var product=PRODUCTS[n]
   data.items["case-%02d"%(n+1)]={"product":product,"location":"backroom","owner":"","price":0,"cost":CATALOG[product].cost,"fixture_id":null,"slot_index":null,"acquisition_id":"starter:"+data.run_id,"acquisition_seq":n+1}
  return true
 for row in data.orders:
  if not row.received and row.day+1==data.day:
   row.received=true
   for product in PRODUCTS:
    for n in range(int(row.lines[product].quantity)):
     data.items["order-%d-%s-%d"%[row.day,product,n+1]]={"product":product,"location":"backroom","owner":"","price":0,"cost":row.lines[product].cost,"fixture_id":null,"slot_index":null,"acquisition_id":"supplier:"+data.run_id+":"+str(int(row.day)),"acquisition_seq":3+int(row.day)*18+PRODUCTS.find(product)*6+n}
   return true
 return false
func order(quantities, expected_day: int) -> bool:
 if data.phase != "report" or data.day != expected_day or not quantities is Dictionary or quantities.size()!=3: return false
 for row in data.orders:
  if row.day==data.day:return false
 var total=0
 var quantity=0
 var lines={}
 for product in PRODUCTS:
  var q=quantities.get(product)
  if not q is int or q<0 or q>6:return false
  total+=q*CATALOG[product].cost;quantity+=q
  lines[product]={"quantity":q,"cost":CATALOG[product].cost}
 if quantity<1 or total>data.cash:return false
 data.cash-=total
 var event=record_event("supplier:"+data.run_id+":"+str(int(data.day)),"supplier",total,str(int(data.day)))
 data.orders.append({"event_id":event.id,"day":data.day,"quantity":quantity,"lines":lines,"total":total,"received":false})
 return true
func advance(expected_day: int) -> bool:
 if data.phase != "report" or data.day != expected_day: return false
 data.day += 1
 data.phase = "prep"
 data.customers.clear()
 data.queue.clear()
 data.clock = 0.0
 data.carried = ""
 return true
func pending_shipment() -> Dictionary:
 for row in data.orders:
  if not row.received: return row
 return {}
func unpriced() -> bool:
 for item in data.items.values():
  if item.location == "backroom" and item.price == 0: return true
 return false
const REFERENCE = 2199
const WILLINGNESS = [110,125,80,95,140]
const VISITORS = ["visitor-1","visitor-2","visitor-3"]
const NAMES = ["Alex","Blair","Casey"]
func willingness(day: int, customer: String = "visitor-1") -> int:
 var index = VISITORS.find(customer)
 return CATALOG[preference(day,customer)].reference * WILLINGNESS[(day-1+maxi(index,0)*2) % WILLINGNESS.size()] / 100
func reprice(cents, product: String = "curb") -> bool:
 if data.phase != "prep" or not cents is int or cents < 100 or cents > 9999: return false
 var changed=false
 for item in data.items.values():
  if item.product == product and item.location in ["shelf","backroom"]:
   item.price=cents;changed=true
 return changed
func price(cents, product: String = "curb") -> bool:
 if data.phase != "prep" or not data.received or not cents is int or cents < 100 or cents > 9999: return false
 var changed=false
 for item in data.items.values():
  if item.product == product and item.location == "backroom":
   item.price = cents
   changed=true
 return changed
func shelf_used() -> int:
 return count_at("shelf")+count_at("customer")
func stock(product: String = "curb", quantity: int = 1) -> bool:
 if data.phase != "prep" or product not in PRODUCTS or quantity<1:return false
 var moved=0
 for id in ordered_copy_ids():
  if moved>=quantity:break
  var slot=free_slot()
  if slot.is_empty():break
  if data.items[id].product==product and stock_copy(id,slot.fixture_id,slot.slot_index,data.layout_revision):moved+=1
 return moved>0
func unstock(product: String, quantity: int = 1) -> bool:
 if data.phase != "prep" or quantity<1:return false
 var moved=0
 for item in data.items.values():
  if moved>=quantity:break
  if item.product==product and item.location=="shelf" and item.owner=="":
   item.location="backroom";item.fixture_id=null;item.slot_index=null;moved+=1
 return moved>0
func open() -> bool:
 if data.phase != "prep" or not pending_shipment().is_empty() or not data.received: return false
 data.phase = "open"
 for n in range(3):
  var id=VISITORS[n]
  data.customers[id]={"product":preference(data.day,id),"name":NAMES[n],"arrival":n*5.0,"state":"waiting","position":[Layout.ENTRY.x,Layout.ENTRY.y],"elapsed":0.0,"settled":false,"item":"","copy":"","offer":0,"budget":willingness(data.day,id),"decision":"pending","browse_fixture":"","browse_port":""}
 return true
func tick(delta: float):
 if data.phase == "open": data.clock += delta
func arrive(customer: String) -> bool:
 if data.phase != "open" or not data.customers.has(customer): return false
 var c=data.customers[customer]
 if c.state != "waiting" or data.clock < c.arrival: return false
 if c.browse_fixture=="":
  var candidates=[]
  for item in data.items.values():
   if item.product==c.product and item.location=="shelf" and item.fixture_id not in candidates:candidates.append(item.fixture_id)
  if candidates.is_empty():candidates=Layout.racks(data.layout)
  for fixture in candidates:
   for port in ["browse-0","browse-1"]:
    if c.browse_fixture=="" and not data.customers.values().any(func(other):return other!=c and other.state in ["arriving","browsing","selected"] and other.browse_fixture==fixture and other.browse_port==port):c.browse_fixture=fixture;c.browse_port=port
  if c.browse_fixture=="":return false
 c.state="arriving"
 return true
func browse(customer: String) -> bool:
 if data.phase not in ["open","closing"] or not data.customers.has(customer) or data.customers[customer].state != "arriving": return false
 data.customers[customer].state="browsing"
 return true
func record_decision(customer: String, outcome: String):
 var c=data.customers[customer]
 c.decision=outcome
 data.decisions.append({"product":c.product,"day":data.day,"customer":customer,"item":c.copy,"offer":c.offer,"budget":c.budget,"outcome":outcome})
func reserve(customer: String) -> bool:
 if data.phase not in ["open","closing"] or not data.customers.has(customer): return false
 var c=data.customers[customer]
 if c.state != "browsing" or c.decision != "pending": return false
 for id in ordered_copy_ids():
  var item = data.items[id]
  if item.product == c.product and item.location == "shelf" and item.owner == "" and item.fixture_id==c.browse_fixture:
   item.location="customer";item.owner=customer
   c.item=id;c.copy=id;c.offer=item.price;c.state="selected"
   return true
 record_decision(customer,"unavailable")
 c.state="leaving"
 return false
func release(customer: String):
 var c=data.customers[customer]
 if c.item != "":
  var item=data.items[c.item]
  item.location="shelf";item.owner=""
 c.item=""
 data.queue.erase(customer)
 c.state="leaving";c.settled=false
func depart(customer: String) -> bool:
 if data.phase not in ["open","closing"] or not data.customers.has(customer): return false
 var c=data.customers[customer]
 if c.state not in ["arriving","browsing","selected","queued"]: return false
 if c.decision == "pending": record_decision(customer,"departed")
 release(customer)
 return true
func decide(customer: String) -> bool:
 if data.phase not in ["open","closing"] or not data.customers.has(customer): return false
 var c=data.customers[customer]
 if c.decision != "pending": return c.decision == "buy"
 if c.state != "selected": return false
 record_decision(customer,"buy" if c.offer <= c.budget else "decline")
 if c.decision == "decline": release(customer)
 return c.decision == "buy"
func queue(customer: String) -> bool:
 if data.phase not in ["open","closing"] or not data.customers.has(customer) or data.customers[customer].state != "selected": return false
 if not decide(customer): return false
 data.customers[customer].state="queued"
 data.customers[customer].settled=false
 data.queue.append(customer)
 return true
func sale(customer: String) -> bool:
 if data.phase not in ["open","closing"] or data.queue.is_empty() or data.queue[0] != customer: return false
 var c=data.customers[customer]
 if c.state != "queued" or not c.settled or not data.items.has(c.item): return false
 var id=c.item
 var item=data.items[id]
 if item.product != c.product or item.location != "customer" or item.owner != customer or c.decision != "buy" or item.price != c.offer: return false
 data.cash += c.offer
 var event=record_event("sale:"+data.run_id+":"+str(int(data.day))+":"+customer,"sale",c.offer,id)
 data.sales.append({"event_id":event.id,"product":item.product,"day":data.day,"customer":customer,"item":id,"price":c.offer,"cost":item.cost})
 item.location="sold";item.owner="";item.fixture_id=null;item.slot_index=null
 if data.carried == id: data.carried=""
 c.item="";c.state="leaving";c.settled=false
 data.queue.pop_front()
 for other in data.queue: data.customers[other].settled=false
 return true
func close() -> bool:
 if data.phase != "open": return false
 data.phase="closing"
 for c in data.customers.values():
  if c.state == "waiting": c.state="cancelled"
 return true
func gone(customer: String) -> bool:
 if not data.customers.has(customer) or data.customers[customer].state != "leaving": return false
 data.customers[customer].state="gone"
 return true
func can_finalize() -> bool:
 return data.phase == "closing" and data.queue.is_empty() and data.customers.values().all(func(c):return c.state in ["gone","cancelled"])
func finalize() -> bool:
 if not can_finalize(): return false
 data.phase="report"
 return true
func count_at(location: String, product: String = "") -> int:
 var n = 0
 for item in data.items.values():
  if item.location == location and (product=="" or item.product==product): n += 1
 return n
func report(product: String = "") -> Dictionary:
 var revenue = 0
 var cost = 0
 var daily_sold = 0
 for s in data.sales:
  if s.day != data.day or (product!="" and s.product!=product): continue
  daily_sold += 1
  revenue += int(s.price)
  cost += int(s.cost)
 var unavailable=0
 var missed=0
 for d in data.decisions:
  if product!="" and d.product!=product:continue
  if d.day == data.day and d.outcome == "decline": missed+=1
  if d.day == data.day and d.outcome == "unavailable": unavailable+=1
 return {"investment":data.fixture_events.size()*6000,"unavailable":unavailable,"missed":missed,"revenue":revenue,"cost":cost,"margin":revenue-cost,"cash":data.cash,"sold":daily_sold,"remaining":count_at("shelf",product)+count_at("backroom",product)+count_at("customer",product)}
func whole(value) -> bool:
 return (value is int or value is float) and is_finite(float(value)) and value == int(value)
func valid_layout() -> bool:
 if data.get("ruleset_id")!="b2-layout-1" or not data.get("run_id") is String or data.run_id.is_empty() or data.get("opening_cash")!=55000:return false
 if data.get("layout")!=checked_layout:
  layout_ok=Layout.check(data.get("layout")).ok
  checked_layout=data.layout.duplicate(true) if data.get("layout") is Dictionary else {}
 if not layout_ok:return false
 for key in ["layout_revision","next_fixture_id","next_event_seq"]:
  if not whole(data.get(key)):return false
 if not data.get("fixture_events") is Array or not data.get("events") is Array or not data.get("fulfilled_requests") is Dictionary:return false
 var bought=data.layout.fixtures.has("rack-0002")
 if data.fixture_events.size()!=(1 if bought else 0) or data.next_fixture_id!=(3 if bought else 2) or data.next_event_seq!=data.events.size()+1:return false
 if bought:
  var e=data.fixture_events[0]
  if not e is Dictionary or e.get("id")!="fixture:"+data.run_id+":rack-0002" or e.get("kind")!="fixture_purchase" or e.get("amount")!=6000 or e.get("fixture_id")!="rack-0002" or not whole(e.get("seq")) or e.seq<1 or not whole(e.get("day")) or e.day<1 or e.day>data.day:return false
 var seen_events=[];var sequences=[]
 for event in data.events:
  if not event is Dictionary or not event.get("id") is String or event.id in seen_events or not whole(event.get("seq")) or event.seq<1 or event.seq>=data.next_event_seq or event.seq in sequences or not whole(event.get("day")) or event.day<1 or event.day>data.day or not whole(event.get("amount")) or event.amount<0 or event.get("status")!="paid":return false
  seen_events.append(event.id);sequences.append(event.seq)
  match event.get("kind"):
   "fixture_purchase":
    if not bought or event.id!=data.fixture_events[0].id or event.amount!=6000 or event.get("reference")!="rack-0002" or event.day!=data.fixture_events[0].day or event.seq!=data.fixture_events[0].seq:return false
   "supplier":
    if not data.get("orders") is Array:return false
    var matches=data.orders.filter(func(row):return row is Dictionary and row.get("event_id")==event.id and row.get("day")==event.day and row.get("total")==event.amount)
    if matches.size()!=1 or event.id!="supplier:"+data.run_id+":"+str(int(event.day)) or event.get("reference")!=str(int(event.day)):return false
   "sale":
    if not data.get("sales") is Array:return false
    var matches=data.sales.filter(func(row):return row is Dictionary and row.get("event_id")==event.id and row.get("day")==event.day and row.get("price")==event.amount and row.get("item")==event.get("reference"))
    if matches.size()!=1 or event.id!="sale:"+data.run_id+":"+str(int(event.day))+":"+str(matches[0].get("customer")):return false
   _:return false
 if not data.get("orders") is Array or not data.get("sales") is Array or data.events.size()!=data.orders.size()+data.sales.size()+data.fixture_events.size():return false
 for row in data.orders+data.sales:
  if not row is Dictionary or row.get("event_id") not in seen_events:return false
 if data.layout_revision!=data.fulfilled_requests.size():return false
 var revisions=[];var buys=0
 for request in data.fulfilled_requests:
  var row=data.fulfilled_requests[request]
  if request.is_empty() or not row is Dictionary or row.get("fixture_id") not in Layout.racks(data.layout) or not whole(row.get("revision")) or row.revision<1 or row.revision>data.layout_revision or row.revision in revisions:return false
  revisions.append(row.revision)
  if row.get("operation")=="buy":
   if row.fixture_id!="rack-0002":return false
   buys+=1
  elif row.get("operation")!="move":return false
 if buys!=(1 if bought else 0):return false
 return true
func valid() -> bool:
 if not valid_layout():return false
 if data.get("version") != 6 or data.get("phase") not in ["prep","open","closing","report"]: return false
 for key in ["items","customers"]:
  if not data.get(key) is Dictionary: return false
 if not data.get("sales") is Array or not data.get("received") is bool or not data.get("carried") is String: return false
 if not whole(data.get("day")) or data.day < 1 or not data.get("orders") is Array: return false
 var expected = {}
 if data.received:
  for n in range(3):expected["case-%02d"%(n+1)]={"product":PRODUCTS[n],"cost":CATALOG[PRODUCTS[n]].cost}
 var purchase_cost = 0
 var order_days = []
 for order_row in data.orders:
  if not order_row is Dictionary: return false
  if not whole(order_row.get("day")) or order_row.day < 1 or order_row.day > data.day or order_days.has(order_row.day): return false
  if not order_row.get("lines") is Dictionary or order_row.lines.size()!=3:return false
  var total=0
  var quantity=0
  for product in PRODUCTS:
   var line=order_row.lines.get(product)
   if not line is Dictionary or not whole(line.get("quantity")) or line.quantity<0 or line.quantity>6 or line.get("cost")!=CATALOG[product].cost:return false
   total+=line.quantity*line.cost;quantity+=line.quantity
  if quantity<1 or order_row.get("quantity")!=quantity or order_row.get("total")!=total or not order_row.get("received") is bool:return false
  if order_row.received and order_row.day >= data.day: return false
  if not order_row.received and (order_row.day < data.day-1 or (order_row.day == data.day and data.phase != "report") or (order_row.day < data.day and data.phase != "prep")): return false
  order_days.append(order_row.day)
  purchase_cost += int(order_row.total)
  if order_row.received:
   for product in PRODUCTS:
    for n in range(int(order_row.lines[product].quantity)):expected["order-%d-%s-%d"%[order_row.day,product,n+1]]={"product":product,"cost":order_row.lines[product].cost}
 if data.items.size() != expected.size(): return false
 for id in expected:
  if not data.items.has(id) or not data.items[id] is Dictionary or data.items[id].get("product")!=expected[id].product or data.items[id].get("cost")!=expected[id].cost: return false
 if shelf_used()>capacity():return false
 if data.phase != "prep" and not data.received: return false
 if data.phase == "prep" and not data.customers.is_empty(): return false
 if not data.get("queue") is Array or not (data.get("clock") is float or data.get("clock") is int) or not is_finite(float(data.clock)) or data.clock < 0: return false
 if data.phase != "prep" and data.customers.keys() != VISITORS: return false
 if data.phase == "prep" and (not data.queue.is_empty() or data.clock != 0): return false
 if not data.get("decisions") is Array: return false
 var decision_keys=[]
 for d in data.decisions:
  if not d is Dictionary or not whole(d.get("day")) or d.day < 1 or d.day > data.day: return false
  if d.get("customer") not in VISITORS or not d.get("item") is String: return false
  var key=str(int(d.day))+":"+d.customer
  if key in decision_keys: return false
  decision_keys.append(key)
  if d.get("product")!=preference(int(d.day),d.customer):return false
  if d.item!="" and (not data.items.has(d.item) or data.items[d.item].product!=d.product):return false
  if d.get("budget") != willingness(int(d.day),d.customer) or not whole(d.get("offer")): return false
  if d.get("outcome") in ["buy","decline"]:
   if not data.items.has(d.item) or d.offer < 100 or d.offer > 9999: return false
   if d.outcome != ("buy" if d.offer <= d.budget else "decline"): return false
  elif d.get("outcome") == "unavailable":
   if d.item != "" or d.offer != 0: return false
  elif d.get("outcome") == "departed":
   if d.item != "" and not data.items.has(d.item): return false
  else: return false
  if d.day == data.day and (data.phase == "prep" or not data.customers.has(d.customer)): return false
 var sold_customers=[]
 var sold = []
 var revenue = 0
 for s in data.sales:
  if not s is Dictionary or not data.items.has(s.get("item")) or sold.has(s.item): return false
  if not whole(s.get("day")) or s.day < 1 or s.day > data.day or (s.day == data.day and data.phase == "prep"): return false
  if not data.decisions.any(func(d):return d.day == s.day and d.customer == s.get("customer") and d.item == s.item and d.offer == s.price and d.outcome == "buy"): return false
  var i = data.items[s.item]
  if not i is Dictionary: return false
  if i.get("location") != "sold" or s.get("price") != i.get("price") or s.get("cost") != i.get("cost") or s.get("product") != i.get("product"): return false
  var sale_key=str(int(s.day))+":"+s.customer
  if sale_key in sold_customers: return false
  sold_customers.append(sale_key)
  sold.append(s.item)
  revenue += int(s.price)
 var cash_expected=data.opening_cash
 for event in data.events:cash_expected+=int(event.amount)*(1 if event.kind=="sale" else -1)
 if data.get("cash")!=cash_expected or cash_expected!=55000+revenue-purchase_cost-data.fixture_events.size()*6000 or data.cash<0:return false
 var occupied=[]
 for id in data.items:
  var item = data.items[id]
  if not item is Dictionary or item.get("location") not in ["backroom","shelf","customer","sold"]: return false
  if not item.get("price") is float and not item.get("price") is int: return false
  if item.price != int(item.price) or item.price < 0 or item.price > 9999 or item.get("product") not in PRODUCTS or not whole(item.get("cost")): return false
  if not item.has("fixture_id") or not item.has("slot_index"):return false
  var acquisition="starter:"+data.run_id
  var sequence=0
  if id.begins_with("case-"):sequence=int(id.get_slice("-",1))
  else:
   var day=int(id.get_slice("-",1));acquisition="supplier:"+data.run_id+":"+str(day)
   sequence=3+day*18+PRODUCTS.find(item.product)*6+int(id.get_slice("-",3))-1
  if item.get("acquisition_id")!=acquisition or item.get("acquisition_seq")!=sequence:return false
  if item.location in ["shelf","customer"]:
   var slot={"fixture_id":item.fixture_id,"slot_index":item.slot_index}
   if not whole(item.slot_index) or not Layout.slot_ids(data.layout).any(func(s):return s.fixture_id==item.fixture_id and s.slot_index==item.slot_index) or slot in occupied:return false
   occupied.append(slot)
  elif item.fixture_id!=null or item.slot_index!=null:return false
  if item.location != "backroom" and item.price < 100: return false
  if item.location == "sold" and not sold.has(id): return false
  if item.location == "customer":
   if data.phase not in ["open","closing"] or not data.customers.has(item.get("owner")): return false
   if data.customers[item.owner].get("item") != id: return false
  elif item.get("owner") != "": return false
  if data.carried == id and item.location != "backroom": return false
 if data.carried != "" and not data.items.has(data.carried): return false
 var queue_seen=[]
 for id in data.queue:
  if id in queue_seen or not data.customers.has(id) or data.customers[id].state != "queued": return false
  queue_seen.append(id)
 for id in data.customers:
  var c=data.customers[id]
  var n=VISITORS.find(id)
  if not c is Dictionary or c.get("state") not in ["waiting","arriving","browsing","selected","queued","leaving","gone","cancelled"]: return false
  if c.get("product")!=preference(data.day,id):return false
  if not c.get("browse_fixture") is String or not c.get("browse_port") is String:return false
  if c.state in ["waiting","cancelled"]:
   if c.browse_fixture!="" or c.browse_port!="":return false
  elif c.browse_fixture not in Layout.racks(data.layout) or c.browse_port not in ["browse-0","browse-1"]:return false
  if c.state in ["selected","queued"] and data.items.has(c.get("item")) and data.items[c.item].get("fixture_id")!=c.browse_fixture:return false
  if c.get("name") != NAMES[n] or c.get("arrival") != n*5.0 or c.get("budget") != willingness(data.day,id): return false
  if not c.get("position") is Array or c.position.size()!=2 or not c.get("settled") is bool: return false
  for v in c.position:
   if not (v is float or v is int) or not is_finite(float(v)): return false
  if not Layout.walkable(data.layout,Vector2(c.position[0],c.position[1])):return false
  if not (c.get("elapsed") is float or c.get("elapsed") is int) or not is_finite(float(c.elapsed)) or c.elapsed<0: return false
  if not whole(c.get("offer")) or not c.get("copy") is String or not c.get("item") is String: return false
  if c.copy!="" and (not data.items.has(c.copy) or c.offer<100 or c.offer>9999): return false
  if c.copy=="" and c.offer!=0: return false
  if c.state in ["waiting","arriving","browsing","cancelled"] and (c.copy!="" or c.decision!="pending"): return false
  if c.state in ["leaving","gone"] and c.decision=="pending": return false
  if c.state=="queued" and c.decision!="buy": return false
  if c.state == "waiting" and data.phase != "open": return false
  if c.state == "cancelled" and data.phase not in ["closing","report"]: return false
  if c.state not in ["waiting","cancelled"] and data.clock < c.arrival: return false
  if data.phase == "report" and c.state not in ["gone","cancelled"]: return false
  if c.decision not in ["pending","buy","decline","unavailable","departed"]: return false
  var matches=data.decisions.filter(func(d):return d.day == data.day and d.customer == id)
  if c.decision == "pending":
   if not matches.is_empty() or c.state == "queued": return false
  elif matches.size()!=1 or matches[0].item!=c.copy or matches[0].offer!=c.offer or matches[0].outcome!=c.decision: return false
  if c.state in ["selected","queued"]:
   if not data.items.has(c.item) or c.item!=c.copy or data.items[c.item].owner!=id or data.items[c.item].location!="customer" or data.items[c.item].price!=c.offer or data.items[c.item].product!=c.product: return false
  elif c.item!="": return false
  if (c.state == "queued") != (id in data.queue): return false
  if c.decision in ["decline","unavailable","departed"] and c.state not in ["leaving","gone"]: return false
 return true
func save_to(path: String) -> bool:
 if not valid(): return false
 var f = FileAccess.open(path+".tmp",FileAccess.WRITE)
 if f == null: return false
 f.store_string(JSON.stringify(data))
 f.flush()
 var ok = f.get_error() == OK
 f.close()
 return ok and DirAccess.rename_absolute(path+".tmp",path) == OK
func load_from(path: String) -> bool:
 var f = FileAccess.open(path,FileAccess.READ)
 if f == null: return false
 var parser=JSON.new()
 var parse_error=parser.parse(f.get_as_text())
 f.close()
 if parse_error!=OK:return false
 var parsed=parser.data
 if not parsed is Dictionary: return false
 var candidate = get_script().new()
 candidate.data = parsed
 if not candidate.valid(): return false
 for key in ["layout_revision","next_fixture_id","next_event_seq","opening_cash"]:parsed[key]=int(parsed[key])
 for fixture in parsed.layout.fixtures.values():fixture.origin=[int(fixture.origin[0]),int(fixture.origin[1])]
 for event in parsed.events:event.day=int(event.day);event.amount=int(event.amount);event.seq=int(event.seq)
 for e in parsed.fixture_events:e.day=int(e.day);e.amount=int(e.amount);e.seq=int(e.seq)
 for row in parsed.fulfilled_requests.values():row.revision=int(row.revision)
 parsed.layout.space_level=int(parsed.layout.space_level)
 parsed.version = int(parsed.version)
 parsed.cash = int(parsed.cash)
 parsed.day = int(parsed.day)
 for d in parsed.decisions:
  d.day=int(d.day);d.offer=int(d.offer);d.budget=int(d.budget)
 for c in parsed.customers.values():
  c.offer=int(c.offer);c.budget=int(c.budget)
 for row in parsed.orders:
  row.day = int(row.day);row.quantity = int(row.quantity);row.total = int(row.total)
  for line in row.lines.values():line.quantity=int(line.quantity);line.cost=int(line.cost)
 for item in parsed.items.values():
  item.acquisition_seq=int(item.acquisition_seq)
  if item.slot_index!=null:item.slot_index=int(item.slot_index)
  item.price = int(item.price)
  item.cost = int(item.cost)
 for sale_row in parsed.sales:
  sale_row.day = int(sale_row.day)
  sale_row.price = int(sale_row.price)
  sale_row.cost = int(sale_row.cost)
 data = parsed
 return true
