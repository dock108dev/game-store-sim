extends SceneTree
const State=preload("res://state.gd")
var results=[]
var path="user://r5-test.json"
func check(name,ok):
 results.append({"check":name,"pass":ok})
 if not ok:push_error(name)
func rt(s,name):
 var t=State.new()
 check("reload "+name,s.save_to(path) and t.load_from(path) and t.data==s.data and t.valid())
 return t
func prep(missing="", reference=false):
 var s=State.new();s.receive()
 for p in State.PRODUCTS:
  s.price(State.CATALOG[p].reference if reference else 1000,p)
  if p!=missing:s.stock(p)
 s.open();return s
func select(s,id):
 s.tick(10);s.arrive(id);s.browse(id);return s.reserve(id)
func pay(s,id):
 s.data.customers[id].settled=true;return s.sale(id)
func finish(s):
 s.close()
 for id in s.data.customers:
  if s.data.customers[id].state not in ["cancelled","gone"]:
   if s.data.customers[id].state!="leaving":s.depart(id)
   s.gone(id)
 return s.finalize()
func reconcile(s,label):
 var total={"sold":0,"revenue":0,"cost":0,"margin":0,"missed":0,"unavailable":0,"remaining":0}
 for p in State.PRODUCTS:
  var r=s.report(p)
  for key in total:total[key]+=r[key]
 for key in total:check(label+" product sum "+key,total[key]==s.report()[key])
 check(label+" ledger valid",s.valid())
func _initialize():
 var s=State.new()
 check("fresh valid and gated",s.valid() and not s.open() and not s.stock() and not s.sale("visitor-1"))
 check("receive starter once",s.receive() and not s.receive() and s.data.items.size()==3)
 for n in range(3):check("unique starter identity "+str(n),s.data.items["case-%02d"%(n+1)].product==State.PRODUCTS[n])
 for price in [0,99,10000,1.5,"2199"]:check("invalid price "+str(price),not s.price(price) and not s.reprice(price))
 s=rt(s,"received unpriced")
 check("independent prices",s.price(2199,"curb") and s.price(1000,"tide") and s.price(1499,"orbit") and s.data.items["case-01"].price==2199 and s.data.items["case-02"].price==1000)
 for p in State.PRODUCTS:s.stock(p)
 var original=s.data.items["case-02"].duplicate(true)
 check("prep return",s.unstock("tide") and s.data.items["case-02"].price==original.price and s.data.items["case-02"].cost==original.cost and s.data.items["case-02"].product==original.product)
 s=rt(s,"assortment return")
 check("backroom allowed while open",s.open() and s.count_at("backroom")==1)
 check("no prep changes while trading",not s.unstock("curb") and not s.stock("tide") and not s.reprice(100,"curb"))
 check("fixed product preferences",s.data.customers["visitor-1"].product=="curb" and s.data.customers["visitor-2"].product=="tide" and s.data.customers["visitor-3"].product=="orbit")
 s=rt(s,"roster before arrival")
 check("staggered arrival",s.arrive("visitor-1") and not s.arrive("visitor-2") and not s.arrive("visitor-1"))
 s.browse("visitor-1");s.reserve("visitor-1")
 check("identified stock miss before price",not select(s,"visitor-2") and s.data.customers["visitor-2"].decision=="unavailable" and s.report("tide").unavailable==1 and s.report("tide").missed==0)
 check("other product reserved",select(s,"visitor-3") and s.data.items[s.data.customers["visitor-3"].item].product=="orbit")
 s=rt(s,"selection and stock miss")
 check("exclusive ownership",s.data.customers["visitor-1"].item!=s.data.customers["visitor-3"].item and not s.reserve("visitor-1"))
 check("locked FIFO offers",s.queue("visitor-3") and s.queue("visitor-1") and s.data.queue==["visitor-3","visitor-1"] and not pay(s,"visitor-1") and not s.sale("visitor-3"))
 s=rt(s,"queue offers")
 var copy=s.data.customers["visitor-3"].item
 s.data.items[copy].product="curb"
 check("wrong product checkout rejected",not pay(s,"visitor-3"));s.data.items[copy].product="orbit"
 s.data.items[copy].price+=1
 check("tampered offer rejected",not pay(s,"visitor-3"));s.data.items[copy].price-=1
 s.data.items[copy].owner="visitor-1"
 check("wrong reservation owner rejected",not pay(s,"visitor-3"));s.data.items[copy].owner="visitor-3"
 check("closing drains accepted queue",s.close() and not s.finalize() and s.data.queue.size()==2)
 s=rt(s,"closing")
 s.data.carried=copy
 check("sale clears copy references",pay(s,"visitor-3") and s.data.carried=="" and s.data.customers["visitor-3"].item=="" and s.data.items[copy].owner=="")
 check("sale once",not pay(s,"visitor-3"))
 check("next FIFO sale",pay(s,"visitor-1") and s.report().revenue==3698 and s.report().cost==1300 and s.report().margin==2398)
 finish(s);reconcile(s,"day1")
 check("final report locks transactions",not s.sale("visitor-1") and not s.reserve("visitor-2") and not s.finalize())
 for q in [{},{"curb":-1,"tide":0,"orbit":0},{"curb":7,"tide":0,"orbit":0},{"curb":1.5,"tide":0,"orbit":0},{"curb":0,"tide":0,"orbit":0}]:check("bad mixed order "+str(q),not s.order(q,1))
 var cash=s.data.cash
 check("mixed payment once",s.order({"curb":2,"tide":3,"orbit":1},1) and not s.order({"curb":1,"tide":0,"orbit":0},1) and s.data.cash==cash-5700)
 s=rt(s,"paid mixed order")
 check("advance once",s.advance(1) and not s.advance(1))
 s=rt(s,"shipment pending")
 check("receive mixed once",s.receive() and not s.receive() and s.data.items.size()==9)
 s=rt(s,"mixed received")
 for p in State.PRODUCTS:s.reprice(1000,p)
 check("capacity four and overflow",s.stock("curb",2) and s.stock("tide",6) and not s.stock("orbit") and s.shelf_used()==4 and s.count_at("backroom")==3)
 var costs={}
 for id in s.data.items:costs[id]=s.data.items[id].cost
 check("assortment exchange",s.unstock("tide") and s.stock("orbit") and s.shelf_used()==4)
 for id in s.data.items:check("historical copy cost "+id,s.data.items[id].cost==costs[id])
 s=rt(s,"full shelf with backroom")
 check("second day preference rotates",s.open() and s.data.customers["visitor-1"].product=="tide" and s.data.customers["visitor-2"].product=="orbit" and s.data.customers["visitor-3"].product=="curb")
 for id in State.VISITORS:check("day2 sought product buys "+id,select(s,id) and s.queue(id) and pay(s,id))
 finish(s);reconcile(s,"day2");s=rt(s,"day2 report")
 check("two day cumulative cash",s.data.cash==55000+3698+3000-5700)
 var full=prep();var missing=prep("orbit")
 for st in [full,missing]:
  for id in State.VISITORS:
   if select(st,id):st.queue(id);pay(st,id)
  finish(st)
 check("reproducible assortment comparison",full.report().sold==3 and missing.report().sold==2 and missing.report("orbit").unavailable==1 and full.report().revenue-missing.report().revenue==1000)
 s=prep("",true)
 for id in State.VISITORS:
  select(s,id);s.queue(id)
 check("price refusal is product-specific",s.report("tide").missed==1 and s.report().unavailable==0 and s.data.customers["visitor-2"].item=="" and s.count_at("shelf","tide")==1)
 var count=s.data.decisions.size();s.decide("visitor-2")
 check("no duplicate refusal",s.data.decisions.size()==count)
 s=rt(s,"price decisions")
 check("queued departure releases reservation",s.depart("visitor-1") and s.data.queue==["visitor-3"] and s.count_at("shelf","curb")==1)
 s=prep();s.arrive("visitor-1");s.browse("visitor-1")
 check("early close keeps browsing and cancels absent",s.close() and s.data.customers["visitor-2"].state=="cancelled" and s.reserve("visitor-1") and s.queue("visitor-1") and pay(s,"visitor-1"))
 finish(s)
 # Five-day inclusive willingness and persistent preferences.
 for day in range(1,6):
  for id in State.VISITORS:
   s=State.new();s.receive()
   for d in range(1,day):s.open();finish(s);s.advance(d)
   var p=s.preference(day,id);s.price(s.willingness(day,id),p);s.stock(p);s.open()
   check("inclusive budget d%d %s"%[day,id],select(s,id) and s.queue(id) and pay(s,id) and s.valid())
 s=prep();finish(s)
 while s.data.cash>=15000:
  var day=s.data.day;s.order({"curb":6,"tide":6,"orbit":6},day);s.advance(day);s.receive();s.open();finish(s)
 var before=s.data.duplicate(true)
 check("insufficient cash atomic",not s.order({"curb":6,"tide":6,"orbit":6},s.data.day) and s.data==before and s.valid())
 s=prep();select(s,"visitor-1");s.queue("visitor-1");var t=rt(s,"tamper baseline")
 for kind in ["preference","budget","copy identity","cost","queue","decision","phase","unknown copy"]:
  var bad=s.data.duplicate(true)
  match kind:
   "preference":bad.customers["visitor-1"].product="tide"
   "budget":bad.customers["visitor-1"].budget+=1
   "copy identity":bad.items["case-01"].product="orbit"
   "cost":bad.items["case-01"].cost+=1
   "queue":bad.queue.append("visitor-1")
   "decision":bad.decisions.append(bad.decisions[0])
   "phase":bad.phase="report"
   "unknown copy":bad.items["alien"]=bad.items["case-01"];bad.items.erase("case-01")
  var f=FileAccess.open(path,FileAccess.WRITE);f.store_string(JSON.stringify(bad));f.close();before=t.data.duplicate(true)
  check("malformed atomic rejection "+kind,not t.load_from(path) and t.data==before)
 var out=FileAccess.open("res://evidence/assortment-state.json",FileAccess.WRITE);out.store_string(JSON.stringify(results,"  "));out.close()
 print("R5_STATE ",results.size()," checks");quit(0 if results.all(func(r):return r.pass) else 1)
