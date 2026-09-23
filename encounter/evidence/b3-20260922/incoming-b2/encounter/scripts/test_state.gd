extends SceneTree
const State = preload("res://state.gd")
var results = []
func check(name: String, ok: bool):
 results.append({"check":name,"pass":ok})
 if not ok: push_error(name)
func prepared():
 var s = State.new()
 s.receive(); s.price(2199); s.stock(); s.open()
 return s
func _initialize():
 var s = State.new()
 check("fresh / unavailable actions",s.valid() and not s.stock() and not s.open() and not s.sale("a"))
 check("receive once",s.receive() and not s.receive() and s.data.items.size()==2)
 check("price bounds",not s.price(0) and not s.price(10000) and s.price(2199))
 check("stock depletion from backroom",s.stock() and not s.stock() and s.count_at("backroom")==0)
 check("open once",s.open() and not s.open())
 check("D2 competing customers reserve distinct copies",s.reserve("a") and s.reserve("b") and s.data.customers.a.item != s.data.customers.b.item and not s.reserve("c") and not s.reserve("a"))
 check("selection is not queue",not s.sale("a") and s.queue("a"))
 check("D1 close releases all reservations",s.close() and s.count_at("shelf")==2 and not s.sale("a") and not s.queue("b") and not s.reserve("c") and s.valid())
 s=prepared();s.reserve("a");s.queue("a")
 var id=s.data.customers.a.item
 s.data.carried=id # Reproduce the recovered incompatible hand reference.
 check("D3 sale clears hand and customer ownership",s.sale("a") and s.data.carried=="" and s.data.customers.a.item=="" and s.data.items[id].owner=="" and s.data.items[id].location=="sold" and s.valid())
 check("sale idempotency",not s.sale("a") and s.data.cash==57199)
 check("report",s.close() and s.report()=={"missed":0,"revenue":2199,"cost":800,"margin":1399,"cash":57199,"sold":1,"remaining":1})
 var path="user://regression-"+str(Time.get_ticks_usec())+".json"
 check("atomic save",s.save_to(path))
 var t=State.new()
 check("reload sold invariants",t.load_from(path) and t.data==s.data and t.valid() and not t.sale("a"))
 for stage in ["prep","selected","queued"]:
  s=prepared()
  if stage=="prep": s=State.new();s.receive();s.price(1899)
  else:
   s.reserve("a")
   if stage=="queued":s.queue("a")
  check("round trip "+stage,s.save_to(path) and t.load_from(path) and t.data==s.data and t.valid())
 var prior=t.data.duplicate(true)
 var f=FileAccess.open(path,FileAccess.WRITE);f.store_string('{"version":1,"phase":"open"}');f.close()
 check("malformed load preserves live state",not t.load_from(path) and t.data==prior)
 var bad=prior.duplicate(true)
 bad.items["alien-copy"]=bad.items["case-01"];bad.items.erase("case-01")
 f=FileAccess.open(path,FileAccess.WRITE);f.store_string(JSON.stringify(bad));f.close()
 check("unknown physical identity rejected atomically",not t.load_from(path) and t.data==prior)
 bad=prior.duplicate(true);bad.phase="prep"
 f=FileAccess.open(path,FileAccess.WRITE);f.store_string(JSON.stringify(bad));f.close()
 check("incompatible phase and ownership rejected atomically",not t.load_from(path) and t.data==prior)
 t.reset();check("reset is truly fresh",t.valid() and not t.data.received and t.data.cash==55000 and t.data.customers.is_empty())
 DirAccess.remove_absolute(path)
 var out=FileAccess.open("res://evidence/transaction-checks.json",FileAccess.WRITE);out.store_string(JSON.stringify(results,"  "))
 print(JSON.stringify(results))
 quit(0 if results.all(func(r):return r.pass) else 1)
