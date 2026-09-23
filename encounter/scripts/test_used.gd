extends "res://scripts/test_growth.gd"
func intake(s):
 # Synthetic scene-arrival boundary. Visible travel is covered by test_used_scene.
 var row=s.seller();row.status="ready";row.motion="intake";row.position=[850.0,420.0]
 check("inspection requires physical shop port",not s.inspect_seller(row.id,Vector2.ZERO) and s.inspect_seller(row.id,Vector2(810,420)))
 return row
func ready(day=2):
 var s=State.new();day_to(s,day);s.open();intake(s);return s
func offered(s,amount):
 var r=s.seller();return s.seller_offer(r.id,int(r.revision),amount)
func bought(s,amount):
 offered(s,amount);return s.purchase_used(State.Used.command(s))
func finish_used(s):
 s.close()
 if not s.seller().is_empty():s.seller().motion="gone"
 return finish(s)
func _initialize():
 var s=ready();var r=s.seller();var start=s.data.cash
 check("schema 9 and three-title scope",s.data.version==9 and State.PRODUCTS.size()==3 and s.valid())
 check("good condition integer-cent terms",r.resale==1759 and r.asking==1231 and r.floor==879)
 check("invalid initial offers inert",not offered(s,99).ok and not offered(s,r.asking+1).ok and r.offers.is_empty())
 check("asking accepted exactly without auto purchase",offered(s,int(r.asking)).ok and r.accepted==1231 and s.data.cash==start and s.data.items.size()==6)
 var command=State.Used.command(s).duplicate(true)
 var stale=command.duplicate(true);stale.amount-=1
 check("changed accepted price rejected",not s.purchase_used(stale).ok and s.data.cash==start)
 for key in ["seller","day","revision","product","condition"]:
  stale=command.duplicate(true);stale[key]="stale" if stale[key] is String else stale[key]+1
  check("stale purchase field "+key,not s.purchase_used(stale).ok and s.data.cash==start and s.seller().status=="accepted")
 s=rt(s,"used-accepted")
 check("pending exact price persists",s.seller().accepted==1231 and s.purchase_used(command).ok)
 var id="used:"+s.data.run_id+":2:1";var i=s.data.items[id]
 check("atomic cost provenance and debit",s.data.cash==start-1231 and i.cost==1231 and i.kind=="used" and i.condition=="good" and i.price==0 and i.location=="backroom" and s.valid())
 check("duplicate old confirmation inert",not s.purchase_used(command).ok and s.data.items.size()==7 and s.data.cash==start-1231)
 s=rt(s,"used-purchased")
 check("reloaded duplicate inert",not s.purchase_used(command).ok and s.data.items.size()==7)
 check("same-day used cannot label stock or claim",not s.price_copy(id,1759,s.data.items[id].duplicate(true)) and not s.stock_copy(id,"rack-0001",0,0) and s.claim("player","stock",id,"rack-0001",0).is_empty())
 finish_used(s);check("close retains purchase and accounting",s.valid() and s.business_report(2).inventory_purchases==1231 and s.business_report(2).cost_of_sales==0 and s.business_report(2).margin==0)
 s.advance(2);s.hire("morgan");s.hire("jules");s.assign("morgan","stocking");s.assign("jules","stocking")
 check("next prep individual label",s.price_copy(id,1759,s.data.items[id].duplicate(true)))
 s.reprice(2199,"curb")
 check("new and used independent labels costs provenance",s.data.items[id].price==1759 and s.data.items["case-01"].price==2199 and s.data.items["case-01"].condition=="new" and s.data.items["case-01"].cost==800 and s.data.items["case-01"].acquisition_id!=s.data.items[id].acquisition_id)
 var job=s.claim("morgan","stock",id,"rack-0001",0)
 check("used copy worker worker player contention",not job.is_empty() and s.claim("jules","stock",id,"rack-0001",1).is_empty() and s.claim("player","stock",id,"rack-0001",2).is_empty())
 var snapshot=s.data.items.duplicate(true)
 var t=State.new();check("used claim restoration keeps one copy",s.save_to("user://b5-claimed.json") and t.load_from("user://b5-claimed.json") and t.data.items==snapshot and State.Staff.active(t.data).is_empty())
 check("used explicit takeover cannot duplicate",not s.take_over("morgan").is_empty() and s.visit_receiving("player",Vector2(370,450)) and s.complete_job("player",Vector2(500,400)) and not s.complete_job("player",Vector2(500,400)))
 s.assign("morgan","checkout");s.assign("jules","checkout");s.open()
 var buyer="visitor-2" # Day 3: Orbit, Curb, Tide.
 s.tick(20);s.arrive(buyer);s.browse(buyer);s.reserve(buyer);s.queue(buyer);s.data.customers[buyer].settled=true
 check("used buyer locks individual fixed offer",s.data.customers[buyer].item==id and s.data.customers[buyer].offer==1759)
 check("used checkout exclusive claims",not s.claim("morgan","sale","","",-1,buyer).is_empty() and s.claim("jules","sale","","",-1,buyer).is_empty() and not s.sale(buyer))
 check("used reserved restoration",s.save_to("user://b5-reserved.json") and t.load_from("user://b5-reserved.json") and t.data.items[id].owner==buyer and t.data.customers[buyer].offer==1759)
 check("restored worker can commit once",not t.claim("jules","sale","","",-1,buyer).is_empty() and t.complete_job("jules",Vector2(660,500)) and not t.complete_job("jules",Vector2(660,500)) and t.data.sales.size()==1 and t.valid())
 check("used worker sale posts actual acquisition cost once",s.complete_job("morgan",Vector2(660,500)) and not s.complete_job("morgan",Vector2(660,500)) and s.data.sales.back().cost==1231 and s.report().margin==528)
 finish_used(s)
 check("resale report arithmetic",s.valid() and s.business_report(3).receipts==1759 and s.business_report(3).cost_of_sales==1231 and s.business_report(3).inventory_purchases==0 and s.business_report(3).paid_overhead==2400 and s.data.cash==53128)
 examples["asking_then_worker_resale"]=s.data.duplicate(true)
 s=ready();r=s.seller()
 check("below floor produces one disclosed counter",offered(s,100).ok and r.status=="counter" and r.offers.size()==1 and r.accepted==0 and s.data.cash==55000)
 s=rt(s,"used-counter");r=s.seller()
 check("counter terms no reroll",r.resale==1759 and r.asking==1231 and r.floor==879 and r.offers==[100])
 check("accept counter exact",offered(s,int(r.floor)).ok and r.accepted==879 and r.offers.size()==2)
 check("negotiation limit rejects third offer",not offered(s,1000).ok)
 check("counter purchase exact",s.purchase_used(State.Used.command(s)).ok and s.data.cash==54121 and s.valid())
 s=ready(3);r=s.seller()
 check("fair grade changes resale and floor",r.condition=="fair" and r.resale==899 and r.asking==629 and r.floor==449)
 offered(s,100);check("final above floor keeps player amount",offered(s,500).ok and r.accepted==500 and s.purchase_used(State.Used.command(s)).ok and s.data.cash==54500 and s.valid())
 s=ready(5);check("same title condition changes valuation",s.seller().product=="curb" and s.seller().condition=="fair" and s.seller().resale==1319 and s.seller().floor==659)
 s=ready(7);check("worn original title only",s.seller().product=="tide" and s.seller().condition=="worn" and s.seller().resale==1119)
 for mode in ["refusal","cancel","final-low","close-ready","close-counter","close-accepted"]:
  s=ready();r=s.seller()
  if mode in ["final-low","close-counter"]:offered(s,100)
  if mode=="close-accepted":offered(s,int(r.asking))
  if mode=="final-low":offered(s,100)
  elif mode in ["refusal","cancel"]:s.seller_cancel(r.id,int(r.revision),mode=="refusal")
  else:s.close()
  check("no payment or copy "+mode,s.data.cash==55000 and s.data.items.size()==6 and r.status in State.Used.DONE and not offered(s,int(r.asking)).ok and s.valid())
  r.motion="gone";finish(s);check("resolved close settles "+mode,s.data.phase=="report" and s.valid())
 s=ready();offered(s,int(s.seller().asking));command=State.Used.command(s)
 # Fault injection is deliberately invalid cash, solely testing atomic preflight.
 s.data.cash=100;var before=s.data.duplicate(true)
 check("insufficient cash leaves exact pending offer",not s.purchase_used(command).ok and s.data==before)
 s.data.cash=55000
 # Fault injection: inbound reservations reserve capacity even before receipt.
 s.data.orders.append({"received":false,"quantity":58});before=s.data.duplicate(true)
 check("inbound committed capacity blocks purchase unchanged",not s.purchase_used(command).ok and s.data==before)
 s.data.orders.clear();check("retry after blocker purchases once",s.purchase_used(command).ok and s.valid())
 # Legitimate 64-copy full backroom from paid shipments.
 s=State.new();s.receive()
 for day in range(1,5):
  s.open();finish(s);s.order({"curb":6,"tide":6,"orbit":6} if day<4 else {"curb":4,"tide":0,"orbit":0},day);s.advance(day);s.receive()
 check("legitimate backroom full",s.backroom_committed()==64 and s.valid())
 s.price(1000,"curb");s.open();r=intake(s);offered(s,int(r.floor));command=State.Used.command(s);before=s.data.duplicate(true)
 check("full backroom pending no debit",not s.purchase_used(command).ok and s.data==before and s.valid())
 check("stocking frees one committed backroom space",not s.claim("player","stock","case-01","rack-0001",0).is_empty() and s.visit_receiving("player",Vector2(370,450)) and s.complete_job("player",Vector2(500,400)) and s.purchase_used(command).ok and s.backroom_committed()==64 and s.valid())
 # Separate ordinary full display state permits acquisition.
 s=State.new();day_to(s,2)
 for p in State.PRODUCTS:s.price(1000,p);s.stock(p,2)
 s.open();r=intake(s);check("full display does not block backroom purchase",s.shelf_used()==4 and bought(s,int(r.asking)).ok and s.valid())
 var acquired=s.data.items.keys().filter(func(k):return k.begins_with("used:"))[0]
 finish_used(s);s.advance(2);s.price_copy(acquired,1759,s.data.items[acquired].duplicate(true))
 check("full display leaves labeled used copy in backroom",s.free_slot().is_empty() and not s.stock_copy(acquired,"rack-0001",0,0) and s.claim("player","stock",acquired,"rack-0001",0).is_empty() and s.data.items[acquired].location=="backroom" and s.valid())
 for mode in ["condition","cost","provenance","duplicate","terms","offers","revision","orphan","old schema"]:
  var bad=s.data.duplicate(true);id=bad.items.keys().filter(func(k):return k.begins_with("used:"))[0]
  match mode:
   "condition":bad.items[id].condition="fair"
   "cost":bad.items[id].cost+=1
   "provenance":bad.items[id].acquisition_id="invented"
   "duplicate":bad.items[id+"-dup"]=bad.items[id].duplicate(true)
   "terms":bad.sellers.back().asking+=1
   "offers":bad.sellers.back().offers.append(100)
   "revision":bad.sellers.back().revision+=1
   "orphan":bad.sellers.clear()
   "old schema":bad.version=8
  var path="user://bad-used.json";var f=FileAccess.open(path,FileAccess.WRITE);f.store_string(JSON.stringify(bad));f.close()
  var bytes=FileAccess.get_file_as_string(path);before=s.data.duplicate(true)
  check("malformed reject without live replacement "+mode,not s.load_from(path) and s.data==before and FileAccess.get_file_as_string(path)==bytes)
  if mode=="old schema":check("incompatible overwrite rejected",not s.save_to(path) and FileAccess.get_file_as_string(path)==bytes)
 # Condition-adjusted fixed-price refusal is a real outcome, not an acquisition failure.
 var decline=ready(5);var fair=decline.seller();bought(decline,int(fair.floor));var fair_id="used:"+decline.data.run_id+":5:1"
 finish_used(decline);decline.advance(5);decline.price_copy(fair_id,1319,decline.data.items[fair_id].duplicate(true));decline.stock("curb");decline.open();decline.tick(20);decline.arrive("visitor-2");decline.browse("visitor-2");decline.reserve("visitor-2")
 check("fair buyer budget condition-adjusted and locked",decline.data.customers["visitor-2"].budget==1055 and decline.data.customers["visitor-2"].offer==1319 and not decline.queue("visitor-2") and decline.data.items[fair_id].location=="shelf" and decline.report().missed==1 and decline.valid())
 # Terminal rejects every seller mutation and retains purchases.
 s=ready(7);bought(s,int(s.seller().floor));finish_used(s);before=s.data.duplicate(true)
 check("terminal used history sealed",s.data.phase=="week_complete" and not s.purchase_used(State.Used.command(s)).ok and not offered(s,100).ok and not s.seller_cancel(s.seller().id,int(s.seller().revision)).ok and s.data==before and s.valid())
 s=rt(s,"used-terminal")
 var f=FileAccess.open("res://evidence/used-state.json",FileAccess.WRITE);f.store_string(JSON.stringify({"checks":results,"examples":examples},"  "));f.close()
 print("B5_USED ",results.size()," checks");quit(0 if results.all(func(row):return row.pass) else 1)
