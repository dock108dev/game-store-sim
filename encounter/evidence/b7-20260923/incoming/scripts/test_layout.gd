extends SceneTree
const State=preload("res://state.gd")
const Layout=preload("res://layout.gd")
var results=[]
var save_path="user://b2-layout-test.json"
func check(name,ok):
 results.append({"check":name,"pass":ok})
 if not ok:push_error(name)
func command(s,operation="buy",pos=[400,430],id="rack-0001",request="test"):
 return {"request_id":request,"phase":s.data.phase,"day":s.data.day,"revision":s.data.layout_revision,"operation":operation,"type":"rack","fixture_id":id,"origin":pos}
func reject(s,cmd,reason):
 var before=s.data.duplicate(true);var result=s.commit_fixture(cmd)
 check("reject "+reason,not result.ok and reason in result.code and s.data==before)
func reload(s,name):
 var t=State.new()
 check("save/reload "+name,s.save_to(save_path) and t.load_from(save_path) and t.data==s.data and t.valid())
 return t
func finish(s):
 s.close()
 for id in s.data.customers:
  if s.data.customers[id].state not in ["cancelled","gone"]:
   if s.data.customers[id].state!="leaving":s.depart(id)
   s.gone(id)
 s.finalize()
func _initialize():
 var s=State.new()
 check("fresh schema9 four slots zero expense and original economy",s.valid() and s.data.version==9 and s.capacity()==4 and s.data.cash==55000 and s.data.fixture_events.is_empty() and State.PRODUCTS.size()==3)
 s.receive()
 check("six uniquely acquired starter copies",s.data.items.size()==6 and s.valid())
 for p in State.PRODUCTS:s.price(1000,p);s.stock(p)
 var originals=s.data.items.duplicate(true)
 var buy=command(s)
 var before=s.data.duplicate(true)
 check("preview is pure",s.preview_fixture(buy).ok and s.data==before)
 check("buy exactly 60 once eight slots",s.commit_fixture(buy).ok and s.data.cash==49000 and s.capacity()==8 and s.data.fixture_events.size()==1 and s.valid())
 before=s.data.duplicate(true)
 check("same request inert",s.commit_fixture(buy).code=="Already applied" and s.data==before)
 reject(s,command(s,"buy",[400,430],"rack-0001","third"),"Rack limit")
 var move=command(s,"move",[430,330],"rack-0001","move")
 check("stocked move preserves every copy field",s.commit_fixture(move).ok and s.data.items==originals and s.data.layout.fixtures["rack-0001"].origin==[430,330] and s.valid())
 s=reload(s,"stocked moved and bought")
 before=s.data.duplicate(true)
 check("purchase duplicate after reload inert",s.commit_fixture(buy).ok and s.data==before)
 var stale=move.duplicate(true);stale.request_id="stale";reject(s,stale,"Stale")
 reject(s,command(s,"move",[430,330],"checkout-01","fixed"),"Fixed")
 reject(s,command(s,"move",[430,330],"alien","unknown"),"Unknown")
 reject(s,command(s,"move",[430.5,330],"rack-0001","fraction"),"integer")
 reject(s,command(s,"move",[430,331],"rack-0001","grid"),"integer")
 reject(s,command(s,"move",[850,330],"rack-0001","bounds"),"Outside")
 reject(s,command(s,"move",[190,330],"rack-0001","aisle"),"aisle")
 reject(s,command(s,"move",[400,430],"rack-0001","overlap"),"Overlaps")
 reject(s,command(s,"move",[620,360],"rack-0001","disconnected"),"route")
 reject(s,command(s,"move",[440,390],"rack-0002","port"),"port")
 check("return releases exact slot",s.return_copy("case-01") and s.data.items["case-01"].fixture_id==null and s.data.items["case-01"].price==1000)
 check("explicit rack2 slot and no double use",s.stock_copy("case-01","rack-0002",3,s.data.layout_revision) and not s.stock_copy("case-02","rack-0002",3,s.data.layout_revision) and s.valid())
 s.open();s.arrive("visitor-1");s.browse("visitor-1");s.reserve("visitor-1")
 var held=s.data.items["case-01"].duplicate(true)
 check("held reservation retains slot",held.fixture_id=="rack-0002" and held.slot_index==3 and s.shelf_used()==3)
 s=reload(s,"reserved rack2")
 reject(s,command(s,"move",[430,330],"rack-0001","open-edit"),"preparation")
 check("reserved copy cannot return",not s.return_copy("case-01"))
 s.queue("visitor-1");s.data.customers["visitor-1"].settled=true
 check("sale frees slot and preserves original cost",s.sale("visitor-1") and s.data.items["case-01"].fixture_id==null and s.data.sales[0].cost==800 and s.data.cash==50000 and s.valid())
 s.close()
 reject(s,command(s,"move",[430,330],"rack-0001","closing-edit"),"preparation")
 finish(s)
 reject(s,command(s,"move",[430,330],"rack-0001","report-edit"),"preparation")
 check("original next day paid order",s.order({"curb":3,"tide":3,"orbit":3},1) and not s.receive() and s.advance(1) and s.receive())
 for p in State.PRODUCTS:s.reprice(1000,p);s.stock(p,9)
 check("eight-slot boundary and remaining backroom",s.shelf_used()==8 and s.count_at("backroom")==6 and not s.stock("orbit",9) and s.valid())
 s=reload(s,"eight occupied")
 # Refusal releases the identical slot, without capacity changes.
 s.reprice(9999,"tide");s.open();s.arrive("visitor-1");s.browse("visitor-1");s.reserve("visitor-1")
 var copy=s.data.customers["visitor-1"].item;var slot=s.data.items[copy].duplicate(true)
 check("refusal returns same slot",not s.queue("visitor-1") and s.data.items[copy].fixture_id==slot.fixture_id and s.data.items[copy].slot_index==slot.slot_index and s.shelf_used()==8 and s.valid())
 finish(s)
 # Separate unbought layout with low cash, reached using the ordinary order ledger.
 var poor=State.new();poor.receive()
 for day in range(1,5):
  poor.open();finish(poor)
  poor.order({"curb":6,"tide":6,"orbit":6} if day<4 else {"curb":0,"tide":4,"orbit":0},day);poor.advance(day);poor.receive()
 reject(poor,command(poor),"Not enough cash")
 check("poor ledger valid",poor.valid())
 var baseline=State.new();baseline.receive();baseline.price(1000);baseline.stock()
 baseline=reload(baseline,"malformed baseline")
 for kind in ["duplicate event","bad cash","old schema","bad origin","wrong space","duplicate slot","orphan slot","wrong acquisition","missing fixture","bad expense","bad revision","customer in fixture"]:
  var bad=baseline.data.duplicate(true)
  match kind:
   "duplicate event":bad.events.append({"id":"fake"})
   "bad cash":bad.cash+=1
   "old schema":bad.version=5
   "bad origin":bad.layout.fixtures["rack-0001"].origin=[430.5,330]
   "wrong space":bad.layout.space_level=1
   "duplicate slot":bad.items["case-02"].location="shelf";bad.items["case-02"].price=1000;bad.items["case-02"].fixture_id="rack-0001";bad.items["case-02"].slot_index=0
   "orphan slot":bad.items["case-01"].fixture_id="rack-9999"
   "wrong acquisition":bad.items["case-01"].acquisition_seq=999
   "missing fixture":bad.layout.fixtures.erase("checkout-01")
   "bad expense":bad.fixture_events.append({"amount":6000})
   "bad revision":bad.layout_revision=5
   "customer in fixture":
    baseline.open();bad=baseline.data.duplicate(true);bad.customers["visitor-1"].position=[500,350]
  var f=FileAccess.open(save_path,FileAccess.WRITE);f.store_string(JSON.stringify(bad));f.close()
  before=baseline.data.duplicate(true)
  check("malformed atomic "+kind,not baseline.load_from(save_path) and baseline.data==before)
 before=baseline.data.duplicate(true)
 for malformed in ["{", "[]", "null"]:
  var bad_file=FileAccess.open(save_path,FileAccess.WRITE);bad_file.store_string(malformed);bad_file.close()
  check("invalid JSON shape preserves live state "+malformed,not baseline.load_from(save_path) and baseline.data==before)
 DirAccess.remove_absolute(save_path)
 var late=State.new();late.receive();late.price(1000);late.stock();late.open();late.arrive("visitor-1");late.browse("visitor-1");late.reserve("visitor-1");late.queue("visitor-1");late.data.customers["visitor-1"].settled=true;late.sale("visitor-1");finish(late)
 late.order({"curb":1,"tide":0,"orbit":0},1);late.advance(1);late.receive()
 check("buy after supplier and sale uses next event identity",late.commit_fixture(command(late)).ok and late.data.events.size()==3 and late.data.next_event_seq==4 and late.data.cash==49200 and late.valid())
 late=reload(late,"purchase after earlier financial events")
 var out=FileAccess.open("res://evidence/layout-state.json",FileAccess.WRITE);out.store_string(JSON.stringify(results,"  "));out.close()
 print("B2_LAYOUT_STATE ",results.size()," checks")
 quit(0 if results.all(func(r):return r.pass) else 1)
