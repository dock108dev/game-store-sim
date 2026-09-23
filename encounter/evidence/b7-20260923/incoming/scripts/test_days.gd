extends SceneTree
const State=preload("res://state.gd")
var results=[]
var path="user://days-test.json"
func check(name,ok):
 results.append({"check":name,"pass":ok})
 if not ok:push_error(name)
func reload_check(s,name):
 var t=State.new()
 check(name,s.save_to(path) and t.load_from(path) and t.data==s.data and t.valid())
 return t
func _initialize():
 var s=State.new();s.receive();s.price(2199);s.stock();s.open();s.reserve("visitor");s.queue("visitor");s.sale("visitor");s.close()
 s=reload_check(s,"before order")
 for q in [0,-1,7,1.5,"2"]:check("reject invalid quantity "+str(q),not s.order(q,1))
 check("reject wrong day",not s.order(2,2))
 check("paid order",s.order(2,1) and s.data.cash==55599 and s.pending_shipment().quantity==2)
 s=reload_check(s,"after order")
 check("no duplicate charge or premature receiving",not s.order(2,1) and not s.receive() and s.data.cash==55599)
 check("advance once",s.advance(1) and not s.advance(1) and s.data.day==2)
 check("daily reset cumulative stock and price",s.report().sold==0 and s.report().revenue==0 and s.data.sales.size()==1 and s.data.customers.is_empty() and s.count_at("shelf")==1 and s.data.items["case-02"].price==2199)
 s=reload_check(s,"after advance before receiving")
 check("receive exactly once unique copies",s.receive() and not s.receive() and s.data.items.size()==4 and s.data.items.has("order-1-copy-1") and s.data.items.has("order-1-copy-2") and s.data.cash==55599)
 s=reload_check(s,"after receiving")
 check("price new stock preserves unsold price",s.price(2499) and s.stock() and s.data.items["case-02"].price==2199 and s.data.items["order-1-copy-1"].price==2499)
 s=reload_check(s,"before second open")
 check("second shift",s.open() and s.reserve("visitor") and s.queue("visitor"))
 s=reload_check(s,"second queue before sale")
 check("second sale once",s.sale("visitor") and not s.sale("visitor") and s.data.cash==57798)
 s=reload_check(s,"after second sale")
 check("second report daily and cumulative",s.close() and s.report().sold==1 and s.report().revenue==2199 and s.report().cost==800 and s.report().margin==1399 and s.report().remaining==2 and s.data.sales.size()==2)
 s=reload_check(s,"second close")
 check("stale first-day order rejected",not s.order(2,1))
 # Spend available cash through legitimate days, with no sales; no artificial cash edit.
 while s.data.cash>=4800:
  var day=s.data.day
  s.order(6,day);s.advance(day);s.receive();s.price(2199);s.stock();s.open();s.close()
 var before=s.data.duplicate(true)
 check("insufficient funds atomic",not s.order(6,s.data.day) and s.data==before and s.valid())
 s=reload_check(s,"low cash with cumulative purchases")
 var t=State.new();var bad=s.data.duplicate(true);bad.orders.append(bad.orders[0])
 var f=FileAccess.open(path,FileAccess.WRITE);f.store_string(JSON.stringify(bad));f.close()
 check("duplicate ledger rejected",not t.load_from(path) and t.valid())
 check("advance without order",s.advance(s.data.day) and s.pending_shipment().is_empty() and s.valid())
 DirAccess.remove_absolute(path)
 var out=FileAccess.open("res://evidence/day-checks.json",FileAccess.WRITE);out.store_string(JSON.stringify(results,"  "));out.close()
 quit(0 if results.all(func(r):return r.pass) else 1)
