extends RefCounted
# Execution claims are independent of customer ownership and never move inventory.
const IDS=["morgan","jules"]
const ROLES=["unassigned","stocking","checkout"]
static func initial() -> Dictionary:
 return {"morgan":{"employed":false,"role":"unassigned"},"jules":{"employed":false,"role":"unassigned"}}
static func active(d: Dictionary) -> Array:
 return d.jobs.filter(func(j):return j.status=="claimed")
static func job(d: Dictionary,actor: String) -> Dictionary:
 for j in active(d):
  if j.actor==actor:return j
 return {}
static func cancel(d: Dictionary,actor: String,reason: String):
 for j in active(d):
  if actor=="" or j.actor==actor:j.status="cancelled";j.reason=reason
static func valid(s) -> bool:
 var d=s.data
 if not d.get("staff") is Dictionary or d.staff.size()!=2 or not d.get("employment") is Array or not d.get("jobs") is Array:return false
 if not s.whole(d.get("next_job")) or d.next_job!=d.jobs.size()+1:return false
 var expected=initial();var commitments={};var last_day=3
 for e in d.employment:
  if not e is Dictionary or e.get("staff") not in IDS or e.get("kind") not in ["hire","dismiss"] or not s.whole(e.get("day")) or e.day<3 or e.day>d.day:return false
  if e.day<last_day:return false
  last_day=e.day
  if e.kind=="hire":
   if expected[e.staff].employed:return false
   expected[e.staff].employed=true
   commitments[str(int(e.day))+":"+e.staff]=true
  else:
   if not expected[e.staff].employed:return false
   expected[e.staff].employed=false
 # Reconstruct the employed set at each opening from prep events.
 var hired={"morgan":false,"jules":false}
 for day in range(3,int(d.day)+1):
  for e in d.employment:
   if e.day==day:hired[e.staff]=e.kind=="hire"
  if day<d.day or d.phase!="prep":
   for id in IDS:
    if hired[id]:commitments[str(day)+":"+id]=true
 for id in IDS:
  if not d.staff.get(id) is Dictionary or not d.staff[id].get("employed") is bool or d.staff[id].employed!=expected[id].employed or d.staff[id].get("role") not in ROLES:return false
  if not d.staff[id].employed and d.staff[id].role!="unassigned":return false
 if commitments.size()!=d.wage_commitments.size():return false
 for c in d.wage_commitments:
  if not commitments.has(str(int(c.day))+":"+c.staff_id):return false
 var owners=[];var copies=[];var slots=[];var cashier=false;var completed_sales=[]
 for n in range(d.jobs.size()):
  var j=d.jobs[n]
  if not j is Dictionary or j.get("id")!="job:"+d.run_id+":"+str(n+1) or j.get("actor") not in ["player","morgan","jules"] or j.get("kind") not in ["stock","sale"] or j.get("status") not in ["claimed","committed","cancelled"]:return false
  if not s.whole(j.get("day")) or j.day<1 or j.day>d.day or not s.whole(j.get("revision")) or j.revision<0 or j.revision>d.layout_revision or not j.get("received") is bool:return false
  if not j.get("copy") is String or not d.items.has(j.copy) or not j.get("fixture") is String or not s.whole(j.get("slot")) or not j.get("customer") is String or not j.get("reason") is String:return false
  if j.fixture not in d.layout.fixtures:return false
  if j.kind=="stock" and (j.slot<0 or j.slot>3 or j.customer!="" or (j.status=="committed" and not j.received)):return false
  if j.kind=="sale":
   if j.customer not in s.buyer_ids(int(j.day)) or j.fixture!="checkout-01" or j.slot!=-1:return false
   if j.status=="committed":
    var key=str(int(j.day))+":"+j.customer
    if key in completed_sales or not d.sales.any(func(row):return row.day==j.day and row.customer==j.customer and row.item==j.copy):return false
    completed_sales.append(key)
  if j.status!="claimed":continue
  if j.actor in owners or j.day!=d.day or j.revision!=d.layout_revision:return false
  owners.append(j.actor)
  if j.actor!="player" and (not d.staff[j.actor].employed or d.staff[j.actor].role!=("stocking" if j.kind=="stock" else "checkout")):return false
  if j.kind=="stock":
   var slot={"fixture_id":j.fixture,"slot_index":int(j.slot)}
   if d.phase not in ["prep","open"] or slot not in s.Layout.slot_ids(d.layout) or j.copy in copies or slot in slots or d.items[j.copy].location!="backroom" or d.items[j.copy].price<100:return false
   if d.items.values().any(func(i):return i.fixture_id==j.fixture and i.slot_index==j.slot):return false
   copies.append(j.copy);slots.append(slot)
  else:
   if cashier or d.phase not in ["open","closing"] or d.queue.is_empty() or d.queue[0]!=j.customer or d.customers[j.customer].item!=j.copy:return false
   cashier=true
 return true
