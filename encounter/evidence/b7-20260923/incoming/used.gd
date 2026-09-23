extends RefCounted
# B6 authored five-title seller roster. Integer cents; persisted history is authoritative.
const GRADES={"good":80,"fair":60,"worn":40}
const ROWS=[["curb","good"],["orbit","fair"],["tide","good"],["curb","fair"],["orbit","good"],["rally","worn"]]
const DONE=["completed","refused","cancelled"]
static func terms(s,day: int) -> Dictionary:
 var row=ROWS[day-2]
 var resale=int(s.CATALOG[row[0]].reference*GRADES[row[1]]/100)
 var overrides=[[1100,800],[600,400],[1400,1000],[800,500],[800,600]]
 return {"product":row[0],"condition":row[1],"resale":resale,"asking":overrides[day-2][0] if day<7 else int(resale*70/100),"floor":overrides[day-2][1] if day<7 else int(resale*50/100)}
static func current(s) -> Dictionary:
 for row in s.data.sellers:
  if row.day==s.data.day:return row
 return {}
static func materialize(s):
 if s.data.day<2:return
 var row=terms(s,s.data.day)
 row.merge({"id":"seller:"+s.data.run_id+":"+str(int(s.data.day))+":1","day":s.data.day,"arrival":30.0,"status":"waiting","motion":"waiting","position":[210.0,580.0],"revision":0,"offers":[],"accepted":0,"inspected":false})
 s.data.sellers.append(row)
static func offer(s,id: String,revision: int,cents) -> Dictionary:
 var row=current(s)
 if s.data.phase!="open" or row.is_empty() or row.id!=id or row.revision!=revision or row.status not in ["ready","counter"] or not row.inspected:return result(false,"Seller or negotiation changed; inspect again")
 if not cents is int or cents<100 or cents>row.asking:return result(false,"Offer must be $1 through the disclosed asking price")
 row.offers.append(cents);row.revision+=1
 if cents>=row.floor:row.accepted=cents;row.status="accepted";return result(true,"Offer accepted; confirm the exact payment to purchase")
 if row.offers.size()==1:row.status="counter";return result(true,"Seller counters once at the disclosed minimum")
 row.status="refused";row.motion="leaving";row.revision+=1
 return result(true,"Final offer refused. No payment or copy")
static func result(ok: bool,code: String) -> Dictionary:return {"ok":ok,"code":code}
static func cancel(s,id: String,revision: int,refuse=false) -> Dictionary:
 var row=current(s)
 if s.data.phase!="open" or row.is_empty() or row.id!=id or row.revision!=revision or row.status in DONE:return result(false,"Seller already resolved or changed")
 row.status="refused" if refuse else "cancelled";row.motion="leaving" if row.motion!="waiting" else "gone";row.revision+=1
 return result(true,"Seller resolved without payment or stock")
static func command(s) -> Dictionary:
 var row=current(s)
 if row.is_empty():return {}
 return {"seller":row.id,"day":row.day,"revision":row.revision,"product":row.product,"condition":row.condition,"amount":row.accepted}
static func purchase(s,cmd: Dictionary) -> Dictionary:
 var row=current(s)
 if s.data.phase!="open" or row.is_empty() or row.status!="accepted" or cmd!=command(s):return result(false,"Stale or completed purchase; nothing paid")
 if s.data.cash<row.accepted:return result(false,"Not enough cash. Accepted offer stays pending")
 if s.backroom_committed()>=64:return result(false,"Backroom full, including inbound reservations. Offer stays pending")
 var id="used:"+s.data.run_id+":"+str(int(row.day))+":1"
 if s.data.items.has(id):return result(false,"Copy already acquired")
 var event=s.record_event("trade:"+s.data.run_id+":"+str(int(row.day))+":1","used_purchase",row.accepted,row.id)
 s.data.cash-=row.accepted
 s.data.items[id]={"product":row.product,"kind":"used","condition":row.condition,"available_day":row.day+1,"location":"backroom","owner":"","price":0,"cost":row.accepted,"fixture_id":null,"slot_index":null,"acquisition_id":event.id,"acquisition_seq":event.seq*100}
 row.status="completed";row.motion="leaving";row.revision+=1
 return result(true,"Purchased once. Unpriced used copy available next preparation")
static func close(s):
 var row=current(s)
 if row.is_empty():return
 if row.status not in DONE:row.status="cancelled";row.revision+=1
 row.motion="gone" if row.motion=="waiting" else "leaving" if row.motion!="gone" else "gone"
static func valid(s,expected: Dictionary) -> bool:
 var d=s.data
 if not d.get("sellers") is Array:return false
 var days=[];var events=[]
 for row in d.sellers:
  if not row is Dictionary or not s.whole(row.get("day")) or row.day<2 or row.day>d.day or int(row.day) in days:return false
  days.append(int(row.day))
  var t=terms(s,int(row.day))
  for k in t:
   if row.get(k)!=t[k]:return false
  if row.get("arrival")!=30.0:return false
  if row.get("id")!="seller:"+d.run_id+":"+str(int(row.day))+":1" or not s.whole(row.get("revision")) or not row.get("inspected") is bool:return false
  if row.get("status") not in ["waiting","arriving","ready","counter","accepted","completed","refused","cancelled"] or row.get("motion") not in ["waiting","arriving","intake","leaving","gone"]:return false
  if not row.get("offers") is Array or row.offers.size()>2 or not s.whole(row.get("accepted")):return false
  for amount in row.offers:
   if not s.whole(amount) or amount<100 or amount>row.asking:return false
  if row.offers.size()==2 and row.offers[0]>=row.floor:return false
  var accepted=int(row.offers.back()) if not row.offers.is_empty() and row.offers.back()>=row.floor else 0
  if row.accepted!=accepted or (not row.offers.is_empty() and not row.inspected):return false
  if row.status=="counter" and (row.offers.size()!=1 or accepted!=0):return false
  if row.status in ["accepted","completed"] and accepted==0:return false
  if row.status in ["waiting","arriving","ready"] and not row.offers.is_empty():return false
  if row.offers.size()==2 and accepted==0 and row.status!="refused":return false
  if row.revision!=row.offers.size()+(1 if row.inspected else 0)+(1 if row.status in DONE else 0):return false
  if row.status in DONE and row.motion not in ["leaving","gone"]:return false
  if row.status in ["ready","counter","accepted"] and row.motion!="intake":return false
  if row.status in ["waiting","arriving"] and row.motion!=row.status:return false
  if row.status in ["waiting","arriving"] and row.inspected:return false
  if row.status not in DONE and (row.day!=d.day or d.phase!="open"):return false
  if (row.day<d.day or d.phase in ["report","week_complete","bankrupt"]) and row.motion!="gone":return false
  if not row.get("position") is Array or row.position.size()!=2:return false
  for v in row.position:
   if not (v is int or v is float) or not is_finite(float(v)):return false
  var pos=Vector2(row.position[0],row.position[1])
  if not s.Layout.walkable(d.layout,pos):return false
  if row.motion=="intake" and pos.distance_to(s.Layout.ports(d.layout,"checkout-01").intake)>=1:return false
  var matches=d.events.filter(func(e):return e.kind=="used_purchase" and e.reference==row.id)
  if matches.size()!=(1 if row.status=="completed" else 0):return false
  if row.status=="completed":
   var e=matches[0];var eid="trade:"+d.run_id+":"+str(int(row.day))+":1"
   if e.id!=eid or e.amount!=accepted or e.day!=row.day:return false
   events.append(e.id)
   var id="used:"+d.run_id+":"+str(int(row.day))+":1"
   expected[id]={"product":row.product,"cost":accepted}
   if not d.items.has(id):return false
   var i=d.items[id]
   if not i is Dictionary:return false
   if i.get("kind")!="used" or i.get("condition")!=row.condition or i.get("available_day")!=row.day+1 or i.get("acquisition_id")!=eid or i.get("acquisition_seq")!=e.seq*100:return false
   if d.day<i.available_day and (i.get("price")!=0 or i.get("location")!="backroom"):return false
   if d.sales.any(func(sale):return sale.item==id and sale.day<i.available_day):return false
 if d.events.filter(func(e):return e.kind=="used_purchase").size()!=events.size():return false
 var last=int(d.day)-(1 if d.phase=="prep" else 0)
 return days.size()==maxi(0,last-1) and range(2,last+1).all(func(day):return day in days)
