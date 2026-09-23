extends RefCounted
# R1 owns physical copies, never product-level reservations. Money is integer cents.
const Used=preload("res://used.gd")
const Staff=preload("res://staff.gd")
const Economy=preload("res://economy.gd")
var checkpoint_path=""
var last_checkpoint_label="No supported checkpoint"
var last_save_ok=true
var save_pending=false
const MAX_CHECKPOINT_BYTES=8 * 1024 * 1024
var last_storage_error={}
var storage_failure_count=0
const Layout=preload("res://layout.gd")
var data: Dictionary
var checked_layout={}
var layout_ok=false
func _init():
 reset()
func reset() -> bool:
 if data is Dictionary and data.get("phase") in ["week_complete","bankrupt"]:return false
 data = {"version":10,"clock":0.0,"queue":[],"decisions":[],"day":1,"orders":[],"phase":"prep","received":false,"cash":55000,"items":{},"customers":{},"sales":[],"carried":""}
 data.merge({"run_id":str(Time.get_unix_time_from_system())+"-"+str(Time.get_ticks_usec()),"ruleset_id":"b6-retail-1","opening_cash":55000,"layout":Layout.initial(),"layout_revision":0,"next_fixture_id":2,"next_event_seq":1,"fixture_events":[],"events":[],"fulfilled_requests":{}})
 data.merge({"wage_commitments":[],"settlements":[],"terminal":null,"staff":Staff.initial(),"employment":[],"jobs":[],"next_job":1,"sellers":[],"daily_content":{}})
 return true
const Week=preload("res://week_content.gd")
const PRODUCTS=Week.PRODUCTS
const CATALOG=Week.CATALOG
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
  if not data.items.values().any(func(i):return i.fixture_id==slot.fixture_id and i.slot_index==slot.slot_index) and not Staff.active(data).any(func(j):return j.kind=="stock" and j.fixture==slot.fixture_id and j.slot==slot.slot_index):return slot
 return {}
func stock_copy(copy_id: String,fixture_id: String,slot_index: int,expected_revision: int, claim_id: String="") -> bool:
 if data.phase not in ["prep","open"] or expected_revision!=data.layout_revision or not data.items.has(copy_id):return false
 if Staff.active(data).any(func(j):return j.id!=claim_id and j.kind=="stock" and (j.copy==copy_id or (j.fixture==fixture_id and j.slot==slot_index))):return false
 var slot={"fixture_id":fixture_id,"slot_index":slot_index}
 var item=data.items[copy_id]
 if slot not in Layout.slot_ids(data.layout) or item.location!="backroom" or item.price<100 or item.available_day>data.day:return false
 if data.items.values().any(func(i):return i.fixture_id==fixture_id and i.slot_index==slot_index):return false
 item.location="shelf";item.fixture_id=fixture_id;item.slot_index=slot_index
 return true
func return_copy(copy_id: String) -> bool:
 if data.phase!="prep" or not data.items.has(copy_id) or backroom_committed()>=64:return false
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
 elif command.get("operation")=="expand":
  if data.day<5:return fail.call("Expansion available from day 5 preparation")
  if data.layout.space_level==1:return fail.call("Already expanded")
  if data.cash<10000:return fail.call("Not enough cash")
  if command.get("origin")!=[440,230]:return fail.call("Expansion rack starts at 440,230; rearrange after purchase")
  id="rack-0003"
 elif command.get("operation")=="move":
  if not data.layout.fixtures.has(id):return fail.call("Unknown fixture")
  if data.layout.fixtures[id].type!="rack":return fail.call("Fixed station cannot move")
 else:return fail.call("Unknown layout operation")
 var pos=command.get("origin")
 if not pos is Array or pos.size()!=2:return fail.call("Invalid origin")
 for v in pos:
  if not v is int or v%10!=0:return fail.call("Use integer 10px grid coordinates")
 var candidate=data.layout.duplicate(true)
 if command.operation=="expand":candidate.space_level=1
 candidate.fixtures[id]={"type":"rack","origin":pos.duplicate()}
 var checked=Layout.check(candidate)
 if not checked.ok:return fail.call(checked.reason)
 return {"ok":true,"code":"Placement valid","fixture_id":id,"revision":data.layout_revision,"layout":candidate}
func commit_fixture(command: Dictionary) -> Dictionary:
 var request=command.get("request_id","")
 if data.phase in ["week_complete","bankrupt"]:return {"ok":false,"code":"Business ended"}
 if data.fulfilled_requests.has(request):return {"ok":true,"code":"Already applied","fixture_id":data.fulfilled_requests[request].fixture_id,"revision":data.layout_revision}
 var result=preview_fixture(command)
 if not result.ok:return result
 Staff.cancel(data,"","Layout changed")
 data.layout=result.layout
 data.layout_revision+=1
 if command.operation=="buy":
  data.cash-=6000;data.next_fixture_id=3
  var event=record_event("fixture:"+data.run_id+":rack-0002","fixture_purchase",6000,"rack-0002")
  data.fixture_events.append({"id":event.id,"kind":event.kind,"day":event.day,"amount":event.amount,"fixture_id":"rack-0002","seq":event.seq})
 if command.operation=="expand":
  data.cash-=10000
  record_event("expansion:"+data.run_id+":1","expansion",10000,"rack-0003")
 data.next_fixture_id=4 if data.layout.space_level==1 else (3 if data.layout.fixtures.has("rack-0002") else 2)
 data.fulfilled_requests[request]={"fixture_id":result.fixture_id,"revision":data.layout_revision,"operation":command.operation}
 if command.operation=="expand":checkpoint("expansion")
 return {"ok":true,"code":"North bay expanded" if command.operation=="expand" else "Rack purchased" if command.operation=="buy" else "Rack moved","fixture_id":result.fixture_id,"revision":data.layout_revision}

func buyer_ids(day: int=0) -> Array:
 return Week.roster(data.run_id,data.day if day==0 else day).keys()
func buyer_definition(day: int,customer: String) -> Dictionary:
 return Week.roster(data.run_id,day).get(customer,{})
func preference(day: int, customer: String) -> String:
 return buyer_definition(day,customer).get("product","")
func eligible(item: Dictionary,c: Dictionary) -> bool:
 return item.product==c.product and item.available_day<=data.day and (item.kind=="new" or c.accept_used)
func receive() -> bool:
 if data.phase != "prep": return false
 if not data.received:
  data.received=true
  for n in range(6):
   var product=PRODUCTS[n%3]
   data.items["case-%02d"%(n+1)]={"product":product,"kind":"new","condition":"new","available_day":1,"location":"backroom","owner":"","price":0,"cost":CATALOG[product].cost,"fixture_id":null,"slot_index":null,"acquisition_id":"starter:"+data.run_id,"acquisition_seq":n+1}
  return true
 for row in data.orders:
  if not row.received and row.day==data.day:
   row.received=true
   for product in PRODUCTS:
    for n in range(int(row.lines[product].quantity)):
     data.items["order-%d-%s-%d"%[row.day,product,n+1]]={"product":product,"kind":"new","condition":"new","available_day":1,"location":"backroom","owner":"","price":0,"cost":row.lines[product].cost,"fixture_id":null,"slot_index":null,"acquisition_id":"supplier:"+data.run_id+":"+str(int(row.day)),"acquisition_seq":int(data.events.filter(func(e):return e.id==row.event_id)[0].seq)*100+PRODUCTS.find(product)*6+n}
   return true
 return false
func order(quantities, expected_day: int) -> bool:
 if data.phase != "prep" or data.day != expected_day or not data.received or not quantities is Dictionary or quantities.size()!=PRODUCTS.size(): return false
 for row in data.orders:
  if row.day==data.day:return false
 var total=0
 var quantity=0
 var lines={}
 for product in PRODUCTS:
  var q=quantities.get(product)
  if not q is int or q<0 or q>6 or (q>0 and not Week.released(product,data.day)):return false
  total+=q*CATALOG[product].cost;quantity+=q
  lines[product]={"quantity":q,"cost":CATALOG[product].cost}
 if quantity<1 or total>data.cash or backroom_committed()+quantity>64:return false
 data.cash-=total
 var event=record_event("supplier:"+data.run_id+":"+str(int(data.day)),"supplier",total,str(int(data.day)))
 data.orders.append({"event_id":event.id,"day":data.day,"quantity":quantity,"lines":lines,"total":total,"received":false})
 return true
func advance(expected_day: int) -> bool:
 if data.phase != "report" or data.day != expected_day or data.day>=7: return false
 data.day += 1
 data.phase = "prep"
 data.customers.clear()
 data.queue.clear()
 data.clock = 0.0
 data.carried = ""
 checkpoint("day advance")
 return true
func pending_shipment() -> Dictionary:
 for row in data.orders:
  if not row.received: return row
 return {}
func backroom_committed() -> int:
 var copies=count_at("backroom")
 for row in data.orders:
  if not row.received:copies+=int(row.quantity)
 return copies
func unpriced() -> bool:
 for item in data.items.values():
  if item.location == "backroom" and item.price == 0: return true
 return false
const REFERENCE=2000
func willingness(day: int, customer: String = "") -> int:
 return int(buyer_definition(day,customer).get("budget",0))
func reprice(cents, product: String = "curb") -> bool:
 if data.phase != "prep" or not cents is int or cents < 100 or cents > 9999: return false
 var changed=false
 for item in data.items.values():
  if item.kind=="new" and item.product == product and item.location in ["shelf","backroom"]:
   item.price=cents;changed=true
 return changed
func price(cents, product: String = "curb") -> bool:
 if data.phase != "prep" or not data.received or not cents is int or cents < 100 or cents > 9999: return false
 var changed=false
 for item in data.items.values():
  if item.kind=="new" and item.product == product and item.location == "backroom":
   item.price = cents
   changed=true
 return changed
func shelf_used() -> int:
 return count_at("shelf")+count_at("customer")
func stock(product: String = "curb", quantity: int = 1) -> bool:
 if data.phase not in ["prep","open"] or product not in PRODUCTS or quantity<1:return false
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
  if moved>=quantity or backroom_committed()>=64:break
  if item.product==product and item.location=="shelf" and item.owner=="":
   item.location="backroom";item.fixture_id=null;item.slot_index=null;moved+=1
 return moved>0
func open() -> bool:
 if data.phase != "prep" or not pending_shipment().is_empty() or not data.received: return false
 for id in Staff.IDS:
  if data.staff[id].employed:commit_wage(id)
 data.phase = "open"
 Used.materialize(self)
 var roster=Week.roster(data.run_id,data.day)
 data.daily_content[str(int(data.day))]=roster.duplicate(true)
 for id in roster:
  data.customers[id]=roster[id].duplicate(true)
  data.customers[id].merge({"state":"waiting","position":[Layout.ENTRY.x,Layout.ENTRY.y],"elapsed":0.0,"settled":false,"item":"","copy":"","offer":0,"decision":"pending","browse_fixture":"","browse_port":""})
 return true
func tick(delta: float):
 if data.phase == "open": data.clock += delta
func arrive(customer: String) -> bool:
 if data.phase != "open" or not data.customers.has(customer): return false
 var c=data.customers[customer]
 if c.state != "waiting" or data.clock < c.arrival: return false
 if data.customers.values().filter(func(other):return other.state not in ["waiting","gone","cancelled"]).size()>=3:return false
 if c.browse_fixture=="":
  var candidates=[]
  for copy_id in ordered_copy_ids():
   var item=data.items[copy_id]
   if eligible(item,c) and item.location=="shelf" and item.fixture_id not in candidates:candidates.append(item.fixture_id)
  if candidates.is_empty():candidates=Layout.racks(data.layout)
  else:candidates=candidates.slice(0,1) # Wait for the oldest eligible copy’s rack, not a newer substitute.
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
 if data.phase not in ["open","closing"] or not data.customers.has(customer):return
 var c=data.customers[customer]
 c.decision=outcome
 data.decisions.append({"product":c.product,"day":data.day,"customer":customer,"item":c.copy,"offer":c.offer,"budget":c.budget,"outcome":outcome})
func reserve(customer: String) -> bool:
 if data.phase not in ["open","closing"] or not data.customers.has(customer): return false
 var c=data.customers[customer]
 if c.state != "browsing" or c.decision != "pending": return false
 for id in ordered_copy_ids():
  var item = data.items[id]
  if eligible(item,c) and item.location == "shelf" and item.owner == "" and item.fixture_id==c.browse_fixture:
   item.location="customer";item.owner=customer
   c.item=id;c.copy=id;c.offer=item.price;c.budget=copy_budget(id,int(data.day),customer);c.state="selected"
   return true
 record_decision(customer,"unavailable")
 c.state="leaving"
 return false
func release(customer: String):
 if data.phase not in ["open","closing"] or not data.customers.has(customer):return
 for j in Staff.active(data):
  if j.kind=="sale" and j.customer==customer:j.status="cancelled";j.reason="Buyer left"
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
func sale(customer: String, claim_id: String="") -> bool:
 if Staff.active(data).any(func(j):return j.kind=="sale" and j.id!=claim_id):return false
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
 for j in Staff.active(data):
  if j.kind=="stock":j.status="cancelled";j.reason="Closing releases unfinished stocking"
 Used.close(self)
 data.phase="closing"
 for c in data.customers.values():
  if c.state == "waiting": c.state="cancelled"
 return true
func gone(customer: String) -> bool:
 if not data.customers.has(customer) or data.customers[customer].state != "leaving": return false
 data.customers[customer].state="gone"
 return true
func can_finalize() -> bool:
 return data.phase == "closing" and data.sellers.all(func(row):return row.motion=="gone") and Staff.active(data).is_empty() and data.queue.is_empty() and data.customers.values().all(func(c):return c.state in ["gone","cancelled"])
func finalize() -> bool:
 if not can_finalize(): return false
 var candidate=data.duplicate(true)
 Economy.settle(candidate)
 data=candidate
 checkpoint("settlement")
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
 return {"investment":data.fixture_events.size()*6000+(10000 if data.layout.space_level==1 else 0),"unavailable":unavailable,"missed":missed,"revenue":revenue,"cost":cost,"margin":revenue-cost,"cash":data.cash,"sold":daily_sold,"remaining":count_at("shelf",product)+count_at("backroom",product)+count_at("customer",product)}
func whole(value) -> bool:
 return (value is int or value is float) and is_finite(float(value)) and value == int(value)
func valid_layout() -> bool:
 if data.get("ruleset_id")!="b6-retail-1" or not data.get("run_id") is String or data.run_id.is_empty() or not data.run_id.is_valid_filename() or data.get("opening_cash")!=55000:return false
 if data.get("layout")!=checked_layout:
  layout_ok=Layout.check(data.get("layout")).ok
  checked_layout=data.layout.duplicate(true) if data.get("layout") is Dictionary else {}
 if not layout_ok:return false
 for key in ["layout_revision","next_fixture_id","next_event_seq"]:
  if not whole(data.get(key)):return false
 if not data.get("fixture_events") is Array or not data.get("events") is Array or not data.get("fulfilled_requests") is Dictionary:return false
 var bought=data.layout.fixtures.has("rack-0002")
 if data.fixture_events.size()!=(1 if bought else 0) or data.next_fixture_id!=(4 if data.layout.space_level==1 else (3 if bought else 2)) or data.next_event_seq!=data.events.size()+1:return false
 if bought:
  var e=data.fixture_events[0]
  if not e is Dictionary or e.get("id")!="fixture:"+data.run_id+":rack-0002" or e.get("kind")!="fixture_purchase" or e.get("amount")!=6000 or e.get("fixture_id")!="rack-0002" or not whole(e.get("seq")) or e.seq<1 or not whole(e.get("day")) or e.day<1 or e.day>data.day:return false
 var seen_events=[];var sequences=[]
 for event in data.events:
  if not event is Dictionary or not event.get("id") is String or event.id in seen_events or not whole(event.get("seq")) or event.seq<1 or event.seq>=data.next_event_seq or event.seq in sequences or not whole(event.get("day")) or event.day<1 or event.day>data.day or not whole(event.get("amount")) or event.amount<0 or event.get("status") not in ["paid","due"]:return false
  seen_events.append(event.id);sequences.append(event.seq)
  if event.get("kind") not in ["wage","rent"] and event.status!="paid":return false
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
   "expansion":
    if data.layout.space_level!=1 or event.id!="expansion:"+data.run_id+":1" or event.amount!=10000 or event.get("reference")!="rack-0003" or event.day<5:return false
   "used_purchase":pass # Reconstructed by Used.valid.
   "wage","rent":pass # Reconstructed in Economy.valid below.
   _:return false
 if not data.get("orders") is Array or not data.get("sales") is Array or data.events.filter(func(e):return e.kind not in ["wage","rent","expansion","used_purchase"]).size()!=data.orders.size()+data.sales.size()+data.fixture_events.size():return false
 for row in data.orders+data.sales:
  if not row is Dictionary or row.get("event_id") not in seen_events:return false
 if data.layout_revision!=data.fulfilled_requests.size():return false
 if data.events.filter(func(e):return e.kind=="expansion").size()!=data.layout.space_level:return false
 var revisions=[];var buys=0;var expansions=0
 for request in data.fulfilled_requests:
  var row=data.fulfilled_requests[request]
  if request.is_empty() or not row is Dictionary or row.get("fixture_id") not in Layout.racks(data.layout) or not whole(row.get("revision")) or row.revision<1 or row.revision>data.layout_revision or row.revision in revisions:return false
  revisions.append(row.revision)
  if row.get("operation")=="buy":
   if row.fixture_id!="rack-0002":return false
   buys+=1
  elif row.get("operation")=="expand":
   if row.fixture_id!="rack-0003":return false
   expansions+=1
  elif row.get("operation")!="move":return false
 if expansions!=data.layout.space_level:return false
 if buys!=(1 if bought else 0):return false
 return true
func valid() -> bool:
 if data.get("phase") not in ["prep","open","closing","report","week_complete","bankrupt"]:return false
 if data.get("version")!=10 or not whole(data.get("day")) or data.day<1 or data.day>7:return false
 if not valid_layout():return false
 if not data.get("daily_content") is Dictionary:return false
 var content_days=int(data.day)-(1 if data.phase=="prep" else 0)
 if data.daily_content.size()!=content_days:return false
 for day in range(1,content_days+1):
  if not Economy.equivalent(data.daily_content.get(str(day)),Week.roster(data.run_id,day)):return false
 if data.get("version") != 10 or data.get("phase") not in ["prep","open","closing","report","week_complete","bankrupt"]: return false
 for key in ["items","customers"]:
  if not data.get(key) is Dictionary: return false
 if not data.get("sales") is Array or not data.get("received") is bool or not data.get("carried") is String: return false
 if not whole(data.get("day")) or data.day < 1 or data.day>7 or not data.get("orders") is Array: return false
 var expected = {}
 if data.received:
  for n in range(6):expected["case-%02d"%(n+1)]={"product":PRODUCTS[n%3],"cost":CATALOG[PRODUCTS[n%3]].cost}
 var purchase_cost = 0
 var order_days = []
 for order_row in data.orders:
  if not order_row is Dictionary: return false
  if not whole(order_row.get("day")) or order_row.day < 1 or order_row.day > data.day or order_days.has(order_row.day): return false
  if not order_row.get("lines") is Dictionary or order_row.lines.size()!=PRODUCTS.size():return false
  var total=0
  var quantity=0
  for product in PRODUCTS:
   var line=order_row.lines.get(product)
   if not line is Dictionary or not whole(line.get("quantity")) or line.quantity<0 or line.quantity>6 or line.get("cost")!=CATALOG[product].cost or (line.quantity>0 and not Week.released(product,int(order_row.day))):return false
   total+=line.quantity*line.cost;quantity+=line.quantity
  if quantity<1 or order_row.get("quantity")!=quantity or order_row.get("total")!=total or not order_row.get("received") is bool:return false
  if not order_row.received and (order_row.day!=data.day or data.phase!="prep"):return false
  order_days.append(order_row.day)
  purchase_cost += int(order_row.total)
  if order_row.received:
   for product in PRODUCTS:
    for n in range(int(order_row.lines[product].quantity)):expected["order-%d-%s-%d"%[order_row.day,product,n+1]]={"product":product,"cost":order_row.lines[product].cost}
 if not Used.valid(self,expected):return false
 if data.customers.values().filter(func(c):return c.get("state") not in ["waiting","gone","cancelled"]).size()>3:return false
 if data.items.size() != expected.size() or backroom_committed()>64: return false
 for id in expected:
  if not data.items.has(id) or not data.items[id] is Dictionary or data.items[id].get("product")!=expected[id].product or data.items[id].get("cost")!=expected[id].cost: return false
 if shelf_used()>capacity():return false
 if data.phase != "prep" and not data.received: return false
 if data.phase == "prep" and not data.customers.is_empty(): return false
 if not data.get("queue") is Array or not (data.get("clock") is float or data.get("clock") is int) or not is_finite(float(data.clock)) or data.clock < 0: return false
 if data.phase != "prep" and data.customers.keys() != buyer_ids(): return false
 if data.phase == "prep" and (not data.queue.is_empty() or data.clock != 0): return false
 if not data.get("decisions") is Array: return false
 var decision_keys=[]
 for d in data.decisions:
  if not d is Dictionary or not whole(d.get("day")) or d.day < 1 or d.day > data.day: return false
  if d.get("customer") not in buyer_ids(int(d.day)) or not d.get("item") is String: return false
  var key=str(int(d.day))+":"+d.customer
  if key in decision_keys: return false
  decision_keys.append(key)
  if d.get("product")!=preference(int(d.day),d.customer):return false
  if d.item!="" and (not data.items.has(d.item) or data.items[d.item].product!=d.product):return false
  if d.get("budget") != copy_budget(d.item,int(d.day),d.customer) or not whole(d.get("offer")): return false
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
 for event in data.events:
  if event.status=="paid":cash_expected+=int(event.amount)*(1 if event.kind=="sale" else -1)
 if data.get("cash")!=cash_expected or data.cash<0:return false
 var occupied=[]
 for id in data.items:
  var item = data.items[id]
  if not item is Dictionary or item.get("location") not in ["backroom","shelf","customer","sold"]: return false
  if not item.get("price") is float and not item.get("price") is int: return false
  if item.price != int(item.price) or item.price < 0 or item.price > 9999 or item.get("product") not in PRODUCTS or not whole(item.get("cost")): return false
  if not item.has("fixture_id") or not item.has("slot_index"):return false
  var acquisition="starter:"+data.run_id
  var sequence=0
  if item.get("kind")=="used":
   acquisition=item.acquisition_id;sequence=item.acquisition_seq # Independently reconstructed from purchase above.
  elif id.begins_with("case-"):sequence=int(id.get_slice("-",1))
  else:
   var day=int(id.get_slice("-",1));acquisition="supplier:"+data.run_id+":"+str(day)
   var events=data.events.filter(func(e):return e.id==acquisition)
   if events.size()!=1:return false
   sequence=int(events[0].seq)*100+PRODUCTS.find(item.product)*6+int(id.get_slice("-",3))-1
  if item.get("kind")!="used" and (item.get("kind")!="new" or item.get("condition")!="new" or item.get("available_day")!=1):return false
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
  var definition=buyer_definition(data.day,id)
  if not c is Dictionary or c.get("state") not in ["waiting","arriving","browsing","selected","queued","leaving","gone","cancelled"]: return false
  if c.get("product")!=preference(data.day,id):return false
  if not c.get("browse_fixture") is String or not c.get("browse_port") is String:return false
  if c.state in ["waiting","cancelled"]:
   if c.browse_fixture!="" or c.browse_port!="":return false
  elif c.browse_fixture not in Layout.racks(data.layout) or c.browse_port not in ["browse-0","browse-1"]:return false
  if c.state in ["selected","queued"] and data.items.has(c.get("item")) and data.items[c.item].get("fixture_id")!=c.browse_fixture:return false
  for key in definition:
   if c.get(key)!=definition[key]:return false
  if c.get("copy","")!="" and data.items.has(c.copy) and not eligible(data.items[c.copy],c):return false
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
  if c.state == "cancelled" and data.phase not in ["closing","report","week_complete","bankrupt"]: return false
  if c.state not in ["waiting","cancelled"] and data.clock < c.arrival: return false
  if data.phase in ["report","week_complete","bankrupt"] and c.state not in ["gone","cancelled"]: return false
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
 return Economy.valid(data) and Staff.valid(self)
# Expected I/O failures are results, with payload-free diagnostics for each attempt.
func storage_failed(operation: String, stage: String, code: int=FAILED) -> bool:
 storage_failure_count+=1
 last_storage_error={"operation":operation,"stage":stage,"code":code,"attempt":storage_failure_count}
 print("STORAGE_FAILURE ",JSON.stringify(last_storage_error))
 return false
func save_to(path: String) -> bool:
 last_storage_error={}
 if not valid():return storage_failed("save","invalid_state")
 if FileAccess.file_exists(path):
  var old=get_script().new()
  if not old.load_from(path):return storage_failed("save","existing_checkpoint_rejected")
 var encoded=JSON.stringify(data)
 if encoded.to_utf8_buffer().size()>MAX_CHECKPOINT_BYTES:return storage_failed("save","size_limit")
 var f = FileAccess.open(path+".tmp",FileAccess.WRITE)
 if f == null:return storage_failed("save","open_temporary",FileAccess.get_open_error())
 f.store_string(encoded)
 f.flush()
 var write_error=f.get_error()
 f.close()
 if write_error!=OK:return storage_failed("save","write_flush",write_error)
 var rename_error=DirAccess.rename_absolute(path+".tmp",path)
 if rename_error!=OK:return storage_failed("save","replace",rename_error)
 last_checkpoint_label="Day %d • %s"%[data.day,data.phase.replace("_"," ")]
 return true
# Shared bounded reader: entry-menu probes must not bypass the load boundary.
func read_checkpoint(path: String) -> Dictionary:
 last_storage_error={}
 var f=FileAccess.open(path,FileAccess.READ)
 if f==null:
  storage_failed("load","open",FileAccess.get_open_error());return {"ok":false}
 var size=f.get_length()
 if size>MAX_CHECKPOINT_BYTES:
  f.close();storage_failed("load","size_limit");return {"ok":false}
 # Read one extra byte to reject concurrent growth without unbounded allocation.
 var bytes=f.get_buffer(size+1)
 var error=f.get_error();f.close()
 if error not in [OK,ERR_FILE_EOF] or bytes.size()!=size:
  storage_failed("load","read_changed",error);return {"ok":false}
 var parser=JSON.new()
 if parser.parse(bytes.get_string_from_utf8())!=OK:
  storage_failed("load","parse");return {"ok":false}
 if not parser.data is Dictionary:
  storage_failed("load","shape");return {"ok":false}
 return {"ok":true,"data":parser.data}
func load_from(path: String) -> bool:
 var result=read_checkpoint(path)
 if not result.ok:return false
 var parsed=result.data
 var candidate = get_script().new()
 candidate.data = parsed
 if not candidate.valid():return storage_failed("load","integrity")
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
  c.offer=int(c.offer);c.budget=int(c.budget);c.appearance=int(c.appearance)
 for row in parsed.orders:
  row.day = int(row.day);row.quantity = int(row.quantity);row.total = int(row.total)
  for line in row.lines.values():line.quantity=int(line.quantity);line.cost=int(line.cost)
 for item in parsed.items.values():
  item.acquisition_seq=int(item.acquisition_seq)
  if item.slot_index!=null:item.slot_index=int(item.slot_index)
  item.price = int(item.price)
  item.cost = int(item.cost)
 for row in parsed.sellers:
  for key in ["day","resale","asking","floor","revision","accepted"]:row[key]=int(row[key])
  for n in range(row.offers.size()):row.offers[n]=int(row.offers[n])
 for item in parsed.items.values():item.available_day=int(item.available_day)
 for sale_row in parsed.sales:
  sale_row.day = int(sale_row.day)
  sale_row.price = int(sale_row.price)
  sale_row.cost = int(sale_row.cost)
 for key in ["wage_commitments","settlements","terminal","employment","jobs","next_job"]:parsed[key]=Economy.normalized(parsed[key])
 for roster in parsed.daily_content.values():
  for c in roster.values():c.budget=int(c.budget);c.appearance=int(c.appearance)
 data = parsed
 Staff.cancel(data,"","Restored unfinished work; inventory and reservations retained")
 last_checkpoint_label="Day %d • %s"%[data.day,data.phase.replace("_"," ")]
 save_pending=false;last_save_ok=true
 return true

# Commit once per staff/day; employment commands and opening own this obligation.
func commit_wage(staff_id: String,amount: int=1200) -> bool:
 if data.phase!="prep" or data.day<3 or staff_id not in ["morgan","jules"] or amount!=1200 or not data.staff[staff_id].employed:return false
 var id="wage:"+data.run_id+":"+str(int(data.day))+":"+staff_id
 if data.wage_commitments.any(func(c):return c.id==id):return true
 data.wage_commitments.append({"id":id,"day":data.day,"staff_id":staff_id,"amount":amount})
 return true
func business_report(day: int=0,through_seq: int=0) -> Dictionary:
 return Economy.summary(data,day,through_seq)
func checkpoint(_reason: String) -> bool:
 save_pending=true
 if checkpoint_path.is_empty():
  last_save_ok=false
  return storage_failed("save","missing_path")
 return retry_save()
func retry_save() -> bool:
 last_save_ok=save_to(checkpoint_path) if not checkpoint_path.is_empty() else storage_failed("save","missing_path")
 save_pending=not last_save_ok
 return last_save_ok
func restart(path: String) -> bool:
 if data.phase in ["week_complete","bankrupt"]:
  var archive=path.get_base_dir()+"/terminal-"+data.run_id+".json"
  if FileAccess.file_exists(archive):
   var retained=get_script().new()
   if not retained.load_from(archive) or retained.data!=data:return storage_failed("restart","terminal_conflict")
  elif not save_to(archive):return false
 var fresh=get_script().new()
 if not fresh.save_to(path):
  save_pending=true;last_save_ok=false;last_storage_error=fresh.last_storage_error;return false
 data=fresh.data
 last_checkpoint_label=fresh.last_checkpoint_label
 checkpoint_path=path
 save_pending=false;last_save_ok=true
 return true

func hire(id: String) -> bool:
 if data.phase!="prep" or data.day<3 or id not in Staff.IDS:return false
 if data.staff[id].employed:return true
 data.staff[id].employed=true
 data.employment.append({"staff":id,"day":data.day,"kind":"hire"})
 return commit_wage(id)
func dismiss(id: String) -> bool:
 if data.phase!="prep" or id not in Staff.IDS:return false
 if not data.staff[id].employed:return true
 Staff.cancel(data,id,"Dismissed; committed wages remain due")
 data.staff[id]={"employed":false,"role":"unassigned"}
 data.employment.append({"staff":id,"day":data.day,"kind":"dismiss"})
 return true
func assign(id: String,role: String) -> bool:
 if data.phase not in ["prep","open"] or id not in Staff.IDS or not data.staff[id].employed or role not in Staff.ROLES:return false
 Staff.cancel(data,id,"Reassigned; commitment retained")
 data.staff[id].role=role
 return true
func claim(actor: String,kind: String,copy_id="",fixture="",slot=-1,customer="") -> Dictionary:
 if actor not in ["player","morgan","jules"] or not Staff.job(data,actor).is_empty():return {}
 if actor!="player" and (not data.staff[actor].employed or data.staff[actor].role!=("stocking" if kind=="stock" else "checkout")):return {}
 if kind=="stock":
  if data.phase not in ["prep","open"] or not data.items.has(copy_id) or data.items[copy_id].location!="backroom" or data.items[copy_id].price<100 or data.items[copy_id].available_day>data.day:return {}
  if {"fixture_id":fixture,"slot_index":slot} not in Layout.slot_ids(data.layout):return {}
  if data.items.values().any(func(i):return i.fixture_id==fixture and i.slot_index==slot):return {}
  if Staff.active(data).any(func(j):return j.kind=="stock" and (j.copy==copy_id or (j.fixture==fixture and j.slot==slot))):return {}
  var grid=Layout.navigation(data.layout)
  if grid.get_id_path(Vector2i(Layout.ports(data.layout,"receiving-01").receive/10),Vector2i(Layout.ports(data.layout,fixture).work/10)).is_empty():return {}
 elif kind=="sale":
  if data.phase not in ["open","closing"] or data.queue.is_empty() or data.queue[0]!=customer or not data.customers[customer].settled:return {}
  if Staff.active(data).any(func(j):return j.kind=="sale"):return {}
  copy_id=data.customers[customer].item;fixture="checkout-01";slot=-1
 else:return {}
 var j={"id":"job:"+data.run_id+":"+str(int(data.next_job)),"actor":actor,"kind":kind,"copy":copy_id,"fixture":fixture,"slot":slot,"customer":customer,"day":data.day,"revision":data.layout_revision,"received":false,"status":"claimed","reason":""}
 data.next_job+=1;data.jobs.append(j)
 return j
func visit_receiving(actor: String,position: Vector2) -> bool:
 var j=Staff.job(data,actor)
 if j.is_empty() or j.kind!="stock" or position.distance_to(Layout.ports(data.layout,"receiving-01").receive)>=1:return false
 j.received=true
 return true
func complete_job(actor: String,position: Vector2) -> bool:
 var j=Staff.job(data,actor)
 if j.is_empty() or j.revision!=data.layout_revision:return false
 var target=Layout.ports(data.layout,j.fixture).get("work" if j.kind=="stock" else "cashier",Vector2(-100,-100))
 if position.distance_to(target)>=1 or (j.kind=="stock" and not j.received):return false
 var ok=stock_copy(j.copy,j.fixture,j.slot,j.revision,j.id) if j.kind=="stock" else sale(j.customer,j.id)
 if ok:j.status="committed"
 return ok
func take_over(actor: String) -> Dictionary:
 var j=Staff.job(data,actor)
 if actor=="player" or j.is_empty() or not Staff.job(data,"player").is_empty():return {}
 var args=j.duplicate(true)
 Staff.cancel(data,actor,"Player took over before commit")
 return claim("player",args.kind,args.copy,args.fixture,args.slot,args.customer)

func seller() -> Dictionary:return Used.current(self)
func seller_offer(id: String,revision: int,cents) -> Dictionary:return Used.offer(self,id,revision,cents)
func seller_cancel(id: String,revision: int,refuse=false) -> Dictionary:return Used.cancel(self,id,revision,refuse)
func purchase_used(command: Dictionary) -> Dictionary:return Used.purchase(self,command)
func inspect_seller(id: String,position: Vector2) -> bool:
 var row=seller()
 if data.phase!="open" or row.is_empty() or row.id!=id or row.status not in ["ready","counter","accepted"] or position.distance_to(Layout.ports(data.layout,"checkout-01").inspect)>=1:return false
 if not row.inspected:row.inspected=true;row.revision+=1
 return true
func price_copy(id: String,cents,expected: Dictionary) -> bool:
 if data.phase!="prep" or not cents is int or cents<100 or cents>9999 or not data.items.has(id):return false
 var item=data.items[id]
 if item!=expected or item.location not in ["backroom","shelf"] or item.owner!="" or item.available_day>data.day or Staff.active(data).any(func(j):return j.copy==id):return false
 item.price=cents
 return true

func copy_budget(_id: String,day: int,customer: String) -> int:
 # Budgets are reference-based demand, never scaled by selected condition.
 return willingness(day,customer)
