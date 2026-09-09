extends RefCounted
# R1 owns physical copies, never product-level reservations. Money is integer cents.
var data: Dictionary
func _init():
 reset()
func reset():
 data = {"version":4,"clock":0.0,"queue":[],"decisions":[],"day":1,"orders":[],"phase":"prep","received":false,"cash":55000,"items":{},"customers":{},"sales":[],"carried":""}
func receive() -> bool:
 if data.phase != "prep": return false
 if data.received:
  for order in data.orders:
   if not order.received and order.day + 1 == data.day:
    order.received = true
    for n in range(order.quantity):
     data.items["order-%d-copy-%d" % [order.day,n+1]] = {"location":"backroom","owner":"","price":0,"cost":800}
    return true
  return false
 data.received = true
 for id in ["case-01","case-02","case-03"]:
  data.items[id] = {"location":"backroom","owner":"","price":0,"cost":800}
 return true
func order(quantity, expected_day: int) -> bool:
 if data.phase != "report" or data.day != expected_day or not quantity is int or quantity < 1 or quantity > 6: return false
 for row in data.orders:
  if row.day == data.day: return false
 if quantity * 800 > data.cash: return false
 data.cash -= quantity * 800
 data.orders.append({"day":data.day,"quantity":quantity,"total":quantity*800,"received":false})
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
 return REFERENCE * WILLINGNESS[(day-1+maxi(index,0)*2) % WILLINGNESS.size()] / 100
func reprice(cents) -> bool:
 if data.phase != "prep" or not cents is int or cents < 100 or cents > 9999: return false
 var changed=false
 for item in data.items.values():
  if item.location in ["shelf","backroom"]:
   item.price=cents;changed=true
 return changed
func price(cents) -> bool:
 if data.phase != "prep" or not data.received or not cents is int or cents < 100 or cents > 9999: return false
 var changed=false
 for item in data.items.values():
  if item.location == "backroom":
   item.price = cents
   changed=true
 return changed
func stock() -> bool:
 if data.phase != "prep": return false
 var changed = false
 for item in data.items.values():
  if item.location == "backroom" and item.price > 0:
   item.location = "shelf"
   changed = true
 return changed
func open() -> bool:
 if data.phase != "prep" or count_at("backroom") > 0 or not pending_shipment().is_empty() or not data.received: return false
 data.phase = "open"
 for n in range(3):
  var id=VISITORS[n]
  data.customers[id]={"name":NAMES[n],"arrival":n*5.0,"state":"waiting","position":[210.0,580.0],"elapsed":0.0,"settled":false,"item":"","copy":"","offer":0,"budget":willingness(data.day,id),"decision":"pending"}
 return true
func tick(delta: float):
 if data.phase == "open": data.clock += delta
func arrive(customer: String) -> bool:
 if data.phase != "open" or not data.customers.has(customer): return false
 var c=data.customers[customer]
 if c.state != "waiting" or data.clock < c.arrival: return false
 c.state="arriving"
 return true
func browse(customer: String) -> bool:
 if data.phase not in ["open","closing"] or not data.customers.has(customer) or data.customers[customer].state != "arriving": return false
 data.customers[customer].state="browsing"
 return true
func record_decision(customer: String, outcome: String):
 var c=data.customers[customer]
 c.decision=outcome
 data.decisions.append({"day":data.day,"customer":customer,"item":c.copy,"offer":c.offer,"budget":c.budget,"outcome":outcome})
func reserve(customer: String) -> bool:
 if data.phase not in ["open","closing"] or not data.customers.has(customer): return false
 var c=data.customers[customer]
 if c.state != "browsing" or c.decision != "pending": return false
 for id in data.items:
  var item = data.items[id]
  if item.location == "shelf" and item.owner == "":
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
 if item.location != "customer" or item.owner != customer or c.decision != "buy" or item.price != c.offer: return false
 data.cash += c.offer
 data.sales.append({"day":data.day,"customer":customer,"item":id,"price":c.offer,"cost":item.cost})
 item.location="sold";item.owner=""
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
func count_at(location: String) -> int:
 var n = 0
 for item in data.items.values():
  if item.location == location: n += 1
 return n
func report() -> Dictionary:
 var revenue = 0
 var cost = 0
 var daily_sold = 0
 for s in data.sales:
  if s.day != data.day: continue
  daily_sold += 1
  revenue += int(s.price)
  cost += int(s.cost)
 var unavailable=0
 var missed=0
 for d in data.decisions:
  if d.day == data.day and d.outcome == "decline": missed+=1
  if d.day == data.day and d.outcome == "unavailable": unavailable+=1
 return {"unavailable":unavailable,"missed":missed,"revenue":revenue,"cost":cost,"margin":revenue-cost,"cash":data.cash,"sold":daily_sold,"remaining":data.items.size()-data.sales.size()}
func whole(value) -> bool:
 return (value is int or value is float) and is_finite(float(value)) and value == int(value)
func valid() -> bool:
 if data.get("version") != 4 or data.get("phase") not in ["prep","open","closing","report"]: return false
 for key in ["items","customers"]:
  if not data.get(key) is Dictionary: return false
 if not data.get("sales") is Array or not data.get("received") is bool or not data.get("carried") is String: return false
 if not whole(data.get("day")) or data.day < 1 or not data.get("orders") is Array: return false
 var expected = ["case-01","case-02","case-03"] if data.received else []
 var purchase_cost = 0
 var order_days = []
 for order_row in data.orders:
  if not order_row is Dictionary: return false
  if not whole(order_row.get("day")) or order_row.day < 1 or order_row.day > data.day or order_days.has(order_row.day): return false
  if not whole(order_row.get("quantity")) or order_row.quantity < 1 or order_row.quantity > 6: return false
  if order_row.get("total") != order_row.quantity * 800 or not order_row.get("received") is bool: return false
  if order_row.received and order_row.day >= data.day: return false
  if not order_row.received and (order_row.day < data.day-1 or (order_row.day == data.day and data.phase != "report") or (order_row.day < data.day and data.phase != "prep")): return false
  order_days.append(order_row.day)
  purchase_cost += int(order_row.total)
  if order_row.received:
   for n in range(int(order_row.quantity)): expected.append("order-%d-copy-%d" % [order_row.day,n+1])
 if data.items.size() != expected.size(): return false
 for id in expected:
  if not data.items.has(id): return false
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
 var sold = []
 var revenue = 0
 for s in data.sales:
  if not s is Dictionary or not data.items.has(s.get("item")) or sold.has(s.item): return false
  if not whole(s.get("day")) or s.day < 1 or s.day > data.day or (s.day == data.day and data.phase == "prep"): return false
  if not data.decisions.any(func(d):return d.day == s.day and d.customer == s.get("customer") and d.item == s.item and d.offer == s.price and d.outcome == "buy"): return false
  var i = data.items[s.item]
  if not i is Dictionary: return false
  if i.get("location") != "sold" or s.get("price") != i.get("price") or s.get("cost") != 800: return false
  sold.append(s.item)
  revenue += int(s.price)
 if data.get("cash") != 55000 + revenue - purchase_cost or data.cash < 0: return false
 for id in data.items:
  var item = data.items[id]
  if not item is Dictionary or item.get("location") not in ["backroom","shelf","customer","sold"]: return false
  if not item.get("price") is float and not item.get("price") is int: return false
  if item.price != int(item.price) or item.price < 0 or item.price > 9999 or item.get("cost") != 800: return false
  if item.location != "backroom" and item.price < 100: return false
  if data.phase != "prep" and item.location == "backroom": return false
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
  if c.get("name") != NAMES[n] or c.get("arrival") != n*5.0 or c.get("budget") != willingness(data.day,id): return false
  if not c.get("position") is Array or c.position.size()!=2 or not c.get("settled") is bool: return false
  for v in c.position:
   if not (v is float or v is int) or not is_finite(float(v)): return false
  if c.position[0]<180 or c.position[0]>890 or c.position[1]<300 or c.position[1]>610: return false
  if not (c.get("elapsed") is float or c.get("elapsed") is int) or not is_finite(float(c.elapsed)) or c.elapsed<0: return false
  if not whole(c.get("offer")) or not c.get("copy") is String or not c.get("item") is String: return false
  if c.state in ["waiting","cancelled"] and (c.copy!="" or c.decision!="pending"): return false
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
   if not data.items.has(c.item) or c.item!=c.copy or data.items[c.item].owner!=id or data.items[c.item].location!="customer" or data.items[c.item].price!=c.offer: return false
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
 var parsed = JSON.parse_string(f.get_as_text())
 if not parsed is Dictionary: return false
 var candidate = get_script().new()
 candidate.data = parsed
 if not candidate.valid(): return false
 parsed.version = int(parsed.version)
 parsed.cash = int(parsed.cash)
 parsed.day = int(parsed.day)
 for d in parsed.decisions:
  d.day=int(d.day);d.offer=int(d.offer);d.budget=int(d.budget)
 for c in parsed.customers.values():
  c.offer=int(c.offer);c.budget=int(c.budget)
 for row in parsed.orders:
  row.day = int(row.day);row.quantity = int(row.quantity);row.total = int(row.total)
 for item in parsed.items.values():
  item.price = int(item.price)
  item.cost = int(item.cost)
 for sale_row in parsed.sales:
  sale_row.day = int(sale_row.day)
  sale_row.price = int(sale_row.price)
  sale_row.cost = int(sale_row.cost)
 data = parsed
 return true
