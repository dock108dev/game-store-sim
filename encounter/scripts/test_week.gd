extends SceneTree
const State=preload("res://state.gd")
var results=[]
var examples={}
func check(name,ok):
 results.append({"check":name,"pass":ok})
 if not ok:push_error(name)
func counts(c=0,t=0,o=0,s=0,r=0):return {"curb":c,"tide":t,"orbit":o,"signal":s,"rally":r}
func cmd(s,op="buy",pos=[400,430],id="rack-0001",request="rack"):
 return {"request_id":request,"operation":op,"type":"rack","fixture_id":id,"origin":pos,"day":s.data.day,"phase":s.data.phase,"revision":s.data.layout_revision}
func rt(s,name):
 var p="user://b6-"+name+".json";var t=State.new()
 check("valid before save "+name,s.valid())
 check("save and resume "+name,s.save_to(p) and t.load_from(p) and t.data==s.data and t.valid())
 return t
func finish(s):
 s.close()
 for id in s.data.customers:
  if s.data.customers[id].state not in ["gone","cancelled"]:
   if s.data.customers[id].state!="leaving":s.depart(id)
   s.gone(id)
 if not s.seller().is_empty():s.seller().motion="gone"
 check("drain and settle day "+str(s.data.day),s.finalize() and s.valid())
func day_to(s,day):
 s.receive()
 while s.data.day<day:
  if s.data.phase!="report":s.open();finish(s)
  s.advance(s.data.day)
func intake(s):
 var row=s.seller();row.status="ready";row.motion="intake";row.position=[850.0,420.0]
 check("inspection physical port",not s.inspect_seller(row.id,Vector2.ZERO) and s.inspect_seller(row.id,Vector2(810,420)))
 return row
func offer(s,amount):return s.seller_offer(s.seller().id,int(s.seller().revision),amount)
func select(s,id):
 s.tick(200);s.arrive(id);s.browse(id);return s.reserve(id)
func serve(s,id,actor="player"):
 if s.queue(id):
  s.data.customers[id].settled=true
  var job=s.claim(actor,"sale","","",-1,id)
  check("settled sale claim",not job.is_empty())
  check("no remote sale",not s.complete_job(actor,Vector2.ZERO))
  check("exactly once physical commit",s.complete_job(actor,Vector2(660,500)) and not s.complete_job(actor,Vector2(660,500)))
 s.gone(id)
func label_stock(s,actor="player"):
 for p in State.PRODUCTS:s.price(State.CATALOG[p].reference,p)
 for id in s.ordered_copy_ids():
  var i=s.data.items[id]
  if i.location!="backroom" or i.available_day>s.data.day:continue
  if i.kind=="used":s.price_copy(id,int(State.CATALOG[i.product].reference*State.Used.GRADES[i.condition]/100),i.duplicate(true))
  var slot=s.free_slot()
  if slot.is_empty():continue
  var j=s.claim(actor,"stock",id,slot.fixture_id,slot.slot_index)
  check("stock exclusive claim",not j.is_empty() and s.claim("jules" if actor!="jules" else "morgan","stock",id,slot.fixture_id,slot.slot_index).is_empty())
  check("receiving before stock",not s.complete_job(actor,State.Layout.ports(s.data.layout,slot.fixture_id).work) and s.visit_receiving(actor,Vector2(370,450)))
  check("stock once",s.complete_job(actor,State.Layout.ports(s.data.layout,slot.fixture_id).work) and not s.complete_job(actor,State.Layout.ports(s.data.layout,slot.fixture_id).work))
func worked(failure=false):
 var s=State.new();s.receive();s.commit_fixture(cmd(s))
 var days=[]
 for day in range(1,8):
  if day==3:s.hire("morgan")
  if day==(3 if failure else 6):s.hire("jules")
  if day==5 and not failure:check("worked expansion",s.commit_fixture(cmd(s,"expand",[440,230],"rack-0003","bay")).ok)
  var q=counts()
  if failure and day<3:q=counts(6,6,6)
  if not failure:
   if day in [3,5,7]:q=counts(1,1,1)
   if day==4:q=counts(1,1,1,2)
   if day==6:q=counts(1,1,1,2,2)
  if q.values().any(func(v):return v>0):
   check("worked same-day order",s.order(q,day));s=rt(s,"paid-"+str(day)+str(failure))
   check("unreceived blocks open",not s.open());check("receive once same prep",s.receive() and not s.receive())
  if not failure:
   if day>=3:s.assign("morgan","stocking")
   label_stock(s,"morgan" if day>=3 else "player")
   if day>=3:s.assign("morgan","checkout")
  check("worked open",s.open());s=rt(s,"opened-"+str(day)+str(failure))
  if day>=2 and not failure:
   var row=intake(s)
   if day==7:s.seller_cancel(row.id,int(row.revision),true)
   else:
    offer(s,100);check("worked authored floor",offer(s,int(row.floor)).ok)
    s=rt(s,"seller-"+str(day));var command=State.Used.command(s)
    check("worked seller payment",s.purchase_used(command).ok and not s.purchase_used(command).ok)
  if not failure:
   for id in s.buyer_ids():
    if select(s,id):serve(s,id,"morgan" if day>=3 else "player")
    else:s.gone(id)
    check("buyer content invariant",s.valid())
  finish(s);s=rt(s,"report-"+str(day)+str(failure))
  days.append({"day":day,"cash":s.data.cash,"report":s.business_report(day),"sales":s.report().sold})
  if day<7:check("advance once",s.advance(day) and not s.advance(day))
 examples["failure" if failure else "worked_survivor"]={"days":days,"final":s.data.duplicate(true)}
 print("B1_ROUTE ",failure," ",JSON.stringify(days))
 if failure:check("failure route actual $70 cash $80 shortfall",s.data.phase=="bankrupt" and s.data.cash==7000 and s.data.terminal.shortfall==8000 and s.business_report().inventory_cost==35000)
 else:check("surviving route recorded, terminal and reconciled",s.data.phase=="week_complete" and s.business_report().cash==s.data.cash)
 check("terminal sealed",not s.advance(7) and not s.order(counts(1),7) and not s.open() and not s.stock("curb") and not s.reset())
 var before=s.data.duplicate(true);check("duplicate settlement inert",not s.finalize() and s.data==before)
func _initialize():
 var s=State.new();check("schema10 initial",s.data.version==10 and s.valid() and State.PRODUCTS.size()==5)
 s.receive()
 for day in range(1,8):
  for product in ["signal","rally"]:
   var q=counts();q[product]=1;var before=s.data.duplicate(true)
   if not State.Week.released(product,day):check("early purchase no mutation "+product+str(day),not s.order(q,day) and s.data==before)
  var product="signal" if day<6 else "rally"
  if State.Week.released(product,day):
   var q=counts();q[product]=1;var cash=s.data.cash
   check("released purchase day "+str(day),s.order(q,day) and s.data.cash==cash-State.CATALOG[product].cost)
   var before=s.data.duplicate(true);check("duplicate order inert",not s.order(q,day) and s.data==before)
   check("pending save and receive",s.save_to("user://release.json"));var t=State.new();check("pending restored",t.load_from("user://release.json") and not t.open() and t.receive() and not t.receive() and t.valid())
   s.receive()
  s.open();check("roster count",s.data.customers.size()==[3,4,5,6,7,8,8][day-1]);s=rt(s,"roster"+str(day))
  for id in s.buyer_ids():
   var d=s.buyer_definition(day,id);check("budget no condition scaling",s.copy_budget("",day,id)==d.budget)
  check("no open orders",not s.order(counts(1),day))
  finish(s);check("no report orders",not s.order(counts(1),day))
  if day<7:s.advance(day)
 # B2 geometry, copy/slot and atomic layout regressions.
 s=State.new();s.receive();var before=s.data.duplicate(true)
 check("invalid layout no payment",not s.commit_fixture(cmd(s,"buy",[690,470])).ok and s.data==before)
 var buy=cmd(s);check("rack request idempotent",s.commit_fixture(buy).ok and s.commit_fixture(buy).ok and s.data.cash==49000 and s.capacity()==8)
 label_stock(s)
 var items=s.data.items.duplicate(true);check("stocked layout move",s.commit_fixture(cmd(s,"move",[430,330],"rack-0001","move")).ok and s.data.items==items)
 s=rt(s,"moved");s.open();s.tick(200)
 for id in s.buyer_ids():s.arrive(id)
 check("oldest rack waits for free browse port",s.data.customers.values().filter(func(c):return c.state=="arriving").size()==2 and s.data.customers[s.buyer_ids()[2]].state=="waiting")
 finish(s)
 # B5 exact accepted terms / bounds / payment rejection / immutable provenance.
 for day in range(2,8):
  s=State.new();day_to(s,day);s.open();var row=intake(s);var terms=State.Used.terms(s,day)
  check("authored terms "+str(day),row.asking==[1100,600,1400,800,800,672][day-2] and row.floor==[800,400,1000,500,600,480][day-2])
  check("bounded offers",not offer(s,99).ok and not offer(s,int(row.asking)+1).ok and offer(s,100).ok and row.status=="counter")
  s=rt(s,"counter"+str(day));row=s.seller();var amount=int(row.floor)+1
  check("above floor exact accepted",offer(s,amount).ok and row.accepted==amount and not offer(s,amount).ok)
  var command=State.Used.command(s);before=s.data.duplicate(true)
  for key in command:
   var stale=command.duplicate(true);stale[key]="bad" if stale[key] is String else stale[key]+1
   check("stale used command "+key,not s.purchase_used(stale).ok and s.data==before)
  s.data.cash=0;var broke=s.data.duplicate(true);check("cash preflight preserves offer",not s.purchase_used(command).ok and s.data==broke);s.data=before.duplicate(true)
  s.data.orders.append({"quantity":64,"received":false});var full=s.data.duplicate(true);check("inbound preflight preserves offer",not s.purchase_used(command).ok and s.data==full);s.data=before.duplicate(true)
  check("exact payment once",s.purchase_used(command).ok and not s.purchase_used(command).ok and s.data.cash==before.cash-amount)
  var id="used:"+s.data.run_id+":"+str(day)+":1"
  check("same-day trade locked",not s.price_copy(id,terms.resale,s.data.items[id].duplicate(true)) and not s.stock(""))
  s=rt(s,"acquisition"+str(day));s.data.items[id].cost+=1;check("tampered cost rejected",not s.valid());s.data.items[id].cost-=1
  if day<7:
   finish(s);s.advance(day);s.price_copy(id,int(terms.resale),s.data.items[id].duplicate(true));s.stock(s.data.items[id].product);s.open()
   var first=s.buyer_ids().filter(func(cid):return s.data.customers[cid].product==terms.product and not s.data.customers[cid].accept_used)[0]
   check("first occurrence rejects used even cheap",not select(s,first) and s.data.customers[first].decision=="unavailable");s.gone(first)
   var repeats=s.buyer_ids().filter(func(cid):return s.data.customers[cid].product==terms.product and s.data.customers[cid].accept_used)
   if not repeats.is_empty():
    check("repeat accepts used at unchanged reference budget",select(s,repeats[0]) and s.data.customers[repeats[0]].budget==int(State.CATALOG[terms.product].reference*90/100))
    var locked=s.data.customers[repeats[0]].duplicate(true)
    check("reservation cannot reprice or return",not s.price_copy(id,100,s.data.items[id].duplicate(true)) and not s.return_copy(id) and s.data.customers[repeats[0]]==locked)
    serve(s,repeats[0]);check("sale cost is accepted history",s.data.sales.back().cost==amount and s.valid())
 # Strict wrong namespace/schema file preservation, never touch owner saves.
 s=State.new();before=s.data.duplicate(true)
 var file=FileAccess.open("user://old.json",FileAccess.WRITE);file.store_string('{"version":9,"ruleset_id":"b5-used-1"}');file.close()
 var old=FileAccess.get_file_as_string("user://old.json")
 check("incompatible load and save nonreplacement",not s.load_from("user://old.json") and not s.save_to("user://old.json") and s.data==before and FileAccess.get_file_as_string("user://old.json")==old)
 worked();worked(true)
 var f=FileAccess.open("res://evidence/week-state.json",FileAccess.WRITE);f.store_string(JSON.stringify({"checks":results,"examples":examples},"  "));f.close()
 print("B6_STATE ",results.size()," checks")
 quit(1 if results.any(func(r):return not r.pass) else 0)
