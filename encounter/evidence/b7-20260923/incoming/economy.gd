extends RefCounted
# Pure accounting/settlement. All amounts are cents. No employee simulation.
static func integer(v) -> bool:
 return (v is int or v is float) and is_finite(float(v)) and v==int(v)
static func obligations(d: Dictionary,day: int) -> Array:
 var result=d.wage_commitments.filter(func(c):return c.day==day).duplicate(true)
 result.sort_custom(func(a,b):return a.staff_id<b.staff_id)
 var bills=[]
 for c in result:bills.append({"id":c.id,"kind":"wage","day":day,"amount":c.amount,"reference":c.staff_id})
 if day==7:bills.append({"id":"rent:"+d.run_id+":7","kind":"rent","day":7,"amount":15000,"reference":"week-1"})
 return bills
static func summary(d: Dictionary,day: int=0,through_seq: int=0) -> Dictionary:
 var r={"opening_cash":55000,"receipts":0,"inventory_purchases":0,"cost_of_sales":0,"margin":0,"incurred_overhead":0,"paid_overhead":0,"unpaid_liabilities":0,"investment":0,"cash":55000,"inventory_cost":5000 if d.received else 0,"operating_result":0}
 var included=[]
 for e in d.events:
  if through_seq>0 and e.seq>through_seq:continue
  included.append(e.id)
  var delta=int(e.amount)*(1 if e.kind=="sale" else -1) if e.status=="paid" else 0
  r.cash+=delta
  if e.kind in ["supplier","used_purchase"]:r.inventory_cost+=int(e.amount)
  if day>0 and e.day<day:r.opening_cash+=delta
  if day>0 and e.day!=day:continue
  match e.kind:
   "sale":r.receipts+=int(e.amount)
   "supplier","used_purchase":r.inventory_purchases+=int(e.amount)
   "fixture_purchase","expansion":r.investment+=int(e.amount)
   "wage","rent":
    if e.kind=="rent":r.incurred_overhead+=int(e.amount)
    if e.status=="paid":r.paid_overhead+=int(e.amount)
    else:r.unpaid_liabilities+=int(e.amount)
 for c in d.wage_commitments:
  if (day==0 or c.day==day) and (through_seq==0 or c.day<=day):r.incurred_overhead+=int(c.amount)
 for sale in d.sales:
  if sale.event_id not in included:continue
  r.inventory_cost-=int(sale.cost)
  if day==0 or sale.day==day:r.cost_of_sales+=int(sale.cost)
 r.margin=r.receipts-r.cost_of_sales
 r.operating_result=r.margin-r.incurred_overhead
 return r
static func settle(d: Dictionary):
 var start=int(d.next_event_seq)
 var failed={}
 var unpaid=[]
 for bill in obligations(d,int(d.day)):
  bill.seq=d.next_event_seq;d.next_event_seq+=1
  bill.status="paid" if failed.is_empty() and d.cash>=bill.amount else "due"
  if bill.status=="paid":d.cash-=int(bill.amount)
  else:
   if failed.is_empty():failed={"due_event":bill.id,"shortfall":int(bill.amount)-int(d.cash)}
   unpaid.append(bill.id)
  d.events.append(bill)
 d.phase="bankrupt" if not failed.is_empty() else ("week_complete" if d.day==7 else "report")
 var report=summary(d,int(d.day))
 d.settlements.append({"id":"finalize:"+d.run_id+":"+str(int(d.day)),"day":d.day,"start_seq":start,"end_seq":int(d.next_event_seq)-1,"report":report})
 if d.phase in ["bankrupt","week_complete"]:
  d.terminal={"outcome":"bankrupt" if d.phase=="bankrupt" else "survived","day":d.day,"due_event":failed.get("due_event",""),"shortfall":failed.get("shortfall",0),"unpaid":unpaid,"summary":summary(d)}
static func valid(d: Dictionary) -> bool:
 if not d.get("wage_commitments") is Array or not d.get("settlements") is Array or not d.has("terminal"):return false
 var ids=[]
 for c in d.wage_commitments:
  if not c is Dictionary or not integer(c.get("day")) or c.day<3 or c.day>d.day or c.get("staff_id") not in ["morgan","jules"] or c.get("amount")!=1200:return false
  if c.get("id")!="wage:"+d.run_id+":"+str(int(c.day))+":"+c.staff_id or c.id in ids:return false
  ids.append(c.id)
 var closed=d.phase in ["report","week_complete","bankrupt"]
 if d.settlements.size()!=int(d.day)-(0 if closed else 1):return false
 if d.phase=="report" and d.day==7:return false
 if not closed and d.terminal!=null:return false
 var last_day=1
 for n in range(d.events.size()):
  var e=d.events[n]
  if e.seq!=n+1 or e.day<last_day:return false
  last_day=e.day
 var generated=[]
 var prior_end=0
 for n in range(d.settlements.size()):
  var row=d.settlements[n];var day=n+1
  if not row is Dictionary or row.get("id")!="finalize:"+d.run_id+":"+str(day) or row.get("day")!=day or not integer(row.get("start_seq")) or not integer(row.get("end_seq")):return false
  if row.start_seq<1 or row.start_seq<prior_end+1 or row.end_seq<row.start_seq-1 or row.end_seq>=d.next_event_seq:return false
  var before=d.duplicate(true)
  before.day=day;before.events=d.events.slice(0,int(row.start_seq)-1);before.next_event_seq=int(row.start_seq);before.cash=55000;before.settlements=[];before.terminal=null
  before.wage_commitments=d.wage_commitments.filter(func(c):return c.day<=day)
  for e in before.events:
   if e.day>day:return false
   if e.status=="paid":before.cash+=int(e.amount)*(1 if e.kind=="sale" else -1)
  settle(before)
  if not equivalent(before.settlements[0],row):return false
  var actual=d.events.slice(int(row.start_seq)-1,int(row.end_seq))
  var expected=before.events.slice(int(row.start_seq)-1)
  if not equivalent(actual,expected):return false
  for e in expected:generated.append(e.id)
  if before.phase in ["week_complete","bankrupt"]:
   if day!=d.day or before.phase!=d.phase or not equivalent(before.terminal,d.terminal) or row.end_seq!=d.events.size():return false
  elif day==d.day and (d.phase!="report" or d.terminal!=null):return false
  # B6 closes are final: all supplier purchases precede opening.
  for e in d.events.slice(int(row.end_seq)):
   if e.day==day:return false
  prior_end=int(row.end_seq)
 for e in d.events:
  if e.kind in ["wage","rent"] and e.id not in generated:return false
 return true

static func equivalent(a,b) -> bool:
 if a is Dictionary:
  if not b is Dictionary or a.size()!=b.size():return false
  for key in a:
   if not b.has(key) or not equivalent(a[key],b[key]):return false
  return true
 if a is Array:
  if not b is Array or a.size()!=b.size():return false
  for n in range(a.size()):
   if not equivalent(a[n],b[n]):return false
  return true
 if a is int or a is float:return integer(a) and integer(b) and a==b
 return typeof(a)==typeof(b) and a==b
static func normalized(value):
 if value is Dictionary:
  var result={}
  for key in value:result[key]=normalized(value[key])
  return result
 if value is Array:
  var result=[]
  for v in value:result.append(normalized(v))
  return result
 if value is float and integer(value):return int(value)
 return value
