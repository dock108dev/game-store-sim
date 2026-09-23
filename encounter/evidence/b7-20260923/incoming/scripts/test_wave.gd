extends SceneTree
const State=preload("res://state.gd")
var results=[]
var path="user://wave-test.json"
func check(name,ok):
 results.append({"check":name,"pass":ok})
 if not ok:push_error(name)
func roundtrip(s,name):
 var t=State.new()
 check("reload "+name,s.save_to(path) and t.load_from(path) and t.data==s.data and t.valid())
 return t
func prep(price=1699):
 var s=State.new();s.receive();s.price(price);s.stock();s.open()
 return s
func admit(s,id):
 s.tick(10);s.arrive(id);s.browse(id)
func select(s,id):
 admit(s,id);return s.reserve(id)
func pay(s,id):
 s.data.customers[id].settled=true
 return s.sale(id)
func finish(s):
 s.close()
 for id in s.data.customers:
  if s.data.customers[id].state not in ["cancelled","gone"]:
   if s.data.customers[id].state!="leaving":s.depart(id)
   s.gone(id)
 return s.finalize()
func _initialize():
 var s=State.new()
 check("R1 fresh unavailable actions",s.valid() and not s.open() and not s.sale("visitor-1"))
 check("receive once three prepaid copies",s.receive() and not s.receive() and s.data.items.size()==3)
 for price in [0,-1,99,10000,1.5,"2199"]:check("R3 illegal cents "+str(price),not s.price(price) and not s.reprice(price))
 check("R1 price stock once",s.price(1699) and s.stock() and not s.stock() and s.open() and not s.open())
 check("fixed identities and individual budgets",s.data.customers.keys()==s.buyer_ids() and s.data.customers["visitor-1"].budget==2418 and s.data.customers["visitor-2"].budget==1759 and s.data.customers["visitor-3"].budget==3078)
 s=roundtrip(s,"before arrivals")
 check("staggered arrivals",s.arrive("visitor-1") and not s.arrive("visitor-1") and not s.arrive("visitor-2"))
 s=roundtrip(s,"arriving")
 check("arrival cannot repeat after reload",not s.arrive("visitor-1") and s.browse("visitor-1"))
 s=roundtrip(s,"browsing")
 check("three exclusive reservations",s.reserve("visitor-1") and select(s,"visitor-2") and select(s,"visitor-3") and s.count_at("customer")==3 and not s.reserve("visitor-1"))
 s=roundtrip(s,"selected")
 check("selection not checkout",not s.sale("visitor-1"))
 check("persisted FIFO",s.queue("visitor-2") and s.queue("visitor-1") and s.queue("visitor-3") and s.data.queue==["visitor-2","visitor-1","visitor-3"])
 s=roundtrip(s,"queue")
 check("no queue jumping or remote payment",not pay(s,"visitor-1") and not s.sale("visitor-2"))
 check("R3 cannot reprice locked offer",not s.reprice(9999) and not s.price(9999) and s.data.customers["visitor-2"].offer==1699)
 check("close admission preserves queue",s.close() and s.data.phase=="closing" and s.data.queue.size()==3 and not s.finalize())
 s=roundtrip(s,"closing queue")
 for id in ["visitor-2","visitor-1","visitor-3"]:
  var item=s.data.customers[id].item
  s.data.carried=item
  check("R1 D3 sale clears references "+id,pay(s,id) and s.data.carried=="" and s.data.customers[id].item=="" and s.data.items[item].owner=="")
  check("exactly once sale "+id,not pay(s,id))
  s.gone(id)
 check("three customer report finalization",s.finalize() and s.report().sold==3 and s.report().revenue==5097 and s.report().cost==2400 and s.report().margin==2697 and s.report().remaining==0 and s.valid())
 var report=s.data.duplicate(true)
 check("D1 finalized report rejects all sales",not s.sale("visitor-1") and not s.reserve("visitor-1") and not s.queue("visitor-1") and not s.finalize() and s.data==report)
 s=roundtrip(s,"final report")
 check("no stock next day opens",s.advance(1) and s.open())
 for id in s.buyer_ids():check("no stock distinct miss "+id,not select(s,id) and s.data.customers[id].decision=="unavailable")
 check("no stock no price misses",s.report().unavailable==3 and s.report().missed==0 and s.report().sold==0 and finish(s))
 s=roundtrip(s,"no stock report")
 for q in [0,-1,7,1.5,"2"]:check("R2 bad order quantity "+str(q),not s.order(q,2))
 var cash=s.data.cash
 check("R2 pay once",s.order(3,2) and not s.order(3,2) and not s.order(1,1) and s.data.cash==cash-2400)
 s=roundtrip(s,"paid order")
 check("R2 advance once",s.advance(2) and not s.advance(2) and s.report().sold==0 and s.data.customers.is_empty())
 s=roundtrip(s,"shipment pending")
 check("R2 receive once unique copies",s.receive() and not s.receive() and s.data.items.has("order-2-copy-3") and s.data.items.size()==6)
 check("R2 replenished stock",s.price(2199) and s.stock() and s.count_at("shelf")==3 and s.open() and s.valid())
 finish(s)
 # Mixed reference-price shift: Alex and Casey buy, Blair declines and releases.
 s=prep(2199)
 for id in s.buyer_ids():select(s,id)
 check("mixed decisions",s.queue("visitor-1") and not s.queue("visitor-2") and s.queue("visitor-3"))
 check("R3 refusal releases exactly one",s.count_at("shelf")==1 and s.data.customers["visitor-2"].item=="" and s.report().missed==1 and s.report().unavailable==0)
 var decision_count=s.data.decisions.size()
 check("R3 refusal idempotent",not s.decide("visitor-2") and s.data.decisions.size()==decision_count)
 s=roundtrip(s,"mixed decisions")
 check("mixed sales",pay(s,"visitor-1") and pay(s,"visitor-3") and s.report().sold==2 and s.report().revenue==4398 and s.report().margin==2798 and finish(s))
 check("R3 next day shelf repricing",s.advance(1) and s.reprice(1599) and s.data.items["case-02"].price==1599 and s.open())
 # One retained copy for three simultaneous selections.
 check("limited competing reservation",select(s,"visitor-1") and not select(s,"visitor-2") and not select(s,"visitor-3") and s.count_at("customer")==1 and s.report().unavailable==2)
 check("departure releases reservation",s.depart("visitor-1") and s.count_at("customer")==0 and s.count_at("shelf")==1 and s.valid())
 finish(s)
 s=prep(2699)
 select(s,"visitor-1");select(s,"visitor-2")
 check("refusal and departure release before third selection",not s.queue("visitor-1") and s.depart("visitor-2") and select(s,"visitor-3") and s.data.customers["visitor-3"].copy=="case-01" and s.queue("visitor-3") and pay(s,"visitor-3") and s.valid())
 finish(s)
 s=prep()
 s.arrive("visitor-1");s.browse("visitor-1")
 check("closing during browsing cancels only unarrived",s.close() and s.data.customers["visitor-2"].state=="cancelled" and not s.arrive("visitor-2") and s.reserve("visitor-1") and s.queue("visitor-1"))
 s=roundtrip(s,"closing browsing transaction")
 check("valid closing transaction completes",pay(s,"visitor-1") and not s.finalize() and s.gone("visitor-1") and s.finalize() and s.valid())
 s=prep();select(s,"visitor-1");select(s,"visitor-2");s.queue("visitor-1");s.queue("visitor-2")
 check("queued departure releases copy and preserves FIFO",s.depart("visitor-1") and s.data.queue==["visitor-2"] and s.count_at("shelf")==2 and pay(s,"visitor-2") and s.valid())
 s=prep();select(s,"visitor-1");s.queue("visitor-1")
 var locked=s.data.customers["visitor-1"].offer
 s.data.items[s.data.customers["visitor-1"].item].price=9999
 check("tampered label cannot change checkout offer",not pay(s,"visitor-1") and s.data.customers["visitor-1"].offer==locked and s.data.sales.is_empty())
 # R3 inclusive willingness and below-cost loss across the authored cycle.
 for day in range(1,6):
  for id in s.buyer_ids():
   s=State.new()
   for d in range(1,day):s.receive();s.price(2199);s.stock();s.open();finish(s);s.advance(d)
   s.receive();s.reprice(s.willingness(day,id));s.stock();s.open();select(s,id)
   check("inclusive willingness d%d %s"%[day,id],s.queue(id) and pay(s,id) and s.valid())
 s=prep(100);select(s,"visitor-1");s.queue("visitor-1")
 check("below-cost loss",pay(s,"visitor-1") and s.report().margin==-700)
 finish(s)
 while s.data.cash>=4800:
  var day=s.data.day
  s.order(6,day);s.advance(day);s.receive();s.price(2199);s.stock();s.open();finish(s)
 var before=s.data.duplicate(true)
 check("R2 insufficient cash atomic",not s.order(6,s.data.day) and s.data==before and s.valid())
 s=prep();select(s,"visitor-1");s.queue("visitor-1")
 var t=roundtrip(s,"malformed baseline")
 for kind in ["budget","duplicate queue","duplicate decision","phase","unknown copy","duplicate sale"]:
  var bad=s.data.duplicate(true)
  match kind:
   "budget":bad.customers["visitor-1"].budget+=1
   "duplicate queue":bad.queue.append("visitor-1")
   "duplicate decision":bad.decisions.append(bad.decisions[0])
   "phase":bad.phase="report"
   "unknown copy":bad.items["alien"]=bad.items["case-01"];bad.items.erase("case-01")
   "duplicate sale":pay(s,"visitor-1");bad=s.data.duplicate(true);bad.sales.append(bad.sales[0])
  var f=FileAccess.open(path,FileAccess.WRITE);f.store_string(JSON.stringify(bad));f.close()
  var prior=t.data.duplicate(true)
  check("atomic malformed rejection "+kind,not t.load_from(path) and t.data==prior)
 DirAccess.remove_absolute(path)
 var out=FileAccess.open("res://evidence/wave-state.json",FileAccess.WRITE);out.store_string(JSON.stringify(results,"  "));out.close()
 print("R4_STATE ",results.size()," checks")
 quit(0 if results.all(func(r):return r.pass) else 1)
