extends SceneTree
const State=preload("res://state.gd")
var results=[]
var path="user://pricing-test.json"
func check(name,ok):
 results.append({"check":name,"pass":ok})
 if not ok:push_error(name)
func reload_state(s,label):
 var t=State.new()
 check(label,s.save_to(path) and t.load_from(path) and t.data==s.data)
 return t
func _initialize():
 var loss=State.new();loss.receive();loss.price(100);loss.stock();loss.open();loss.reserve("visitor");loss.queue("visitor");loss.sale("visitor");loss.close()
 check("below cost sale records loss",loss.report().revenue==100 and loss.report().margin == -700 and loss.valid())
 var frozen=State.new();frozen.receive();frozen.price(2199);frozen.stock();frozen.open();frozen.reserve("visitor");frozen.queue("visitor")
 frozen.data.items[frozen.data.customers.visitor.item].price=2299
 check("altered queued label cannot change charge",not frozen.sale("visitor") and frozen.data.sales.is_empty() and frozen.data.cash==55000 and not frozen.valid())
 var comparison=[]
 for price in [1699,2199,2699]:
  var s=State.new();s.receive()
  var sold=0;var missed=0;var revenue=0;var margin=0
  for day in range(1,6):
   if day>1:s.receive()
   s.reprice(price);s.stock();s.open()
   s=reload_state(s,"before offer %d/%d"%[price,day])
   check("reserve",s.reserve("visitor"))
   var offer=s.data.customers.visitor.offer
   check("open price frozen",not s.reprice(100) and not s.price(100) and offer==price)
   s=reload_state(s,"before decision %d/%d"%[price,day])
   var buy=s.decide("visitor")
   s=reload_state(s,"after decision %d/%d"%[price,day])
   check("decision idempotent",s.decide("visitor")==buy and s.data.decisions.size()==day)
   if buy:
    check("buy at fixed offer",s.queue("visitor") and s.sale("visitor") and not s.sale("visitor"))
   else:
    check("refusal releases without consuming stock",s.count_at("customer")==0 and s.count_at("shelf")>0 and s.data.customers.visitor.item=="" and not s.queue("visitor") and not s.sale("visitor"))
   s.close();var r=s.report();sold+=r.sold;missed+=r.missed;revenue+=r.revenue;margin+=r.margin
   check("daily accounting",r.sold==int(buy) and r.missed==int(not buy) and r.revenue==price*int(buy) and r.margin==(price-800)*int(buy))
   s=reload_state(s,"report %d/%d"%[price,day])
   if day<5:
    s.order(1,day);s.advance(day)
    check("daily reset",s.report().missed==0 and s.report().sold==0 and s.data.customers.is_empty())
  comparison.append({"price":price,"sales":sold,"missed":missed,"revenue":revenue,"margin":margin})
 check("same scenarios tradeoff",comparison[0].sales==5 and comparison[1].sales==3 and comparison[2].sales==2 and comparison[2].margin/comparison[2].sales>comparison[0].margin/comparison[0].sales)
 for offset in [-1,0,1]:
  var s=State.new();s.receive();s.price(s.willingness(1)+offset);s.stock();s.open();s.reserve("visitor")
  check("inclusive willingness boundary "+str(offset),s.decide("visitor")== (offset<=0) and s.valid())
 var s=State.new();s.receive()
 for value in [0,-1,99,10000,1.5,"2199"]:check("invalid price "+str(value),not s.price(value) and not s.reprice(value))
 check("legal price endpoints",s.price(100) and s.reprice(9999))
 s.stock();s.open();s.reserve("visitor");s.decide("visitor")
 var bad=s.data.duplicate(true);bad.decisions.append(bad.decisions[0]);var f=FileAccess.open(path,FileAccess.WRITE);f.store_string(JSON.stringify(bad));f.close()
 var before=s.data.duplicate(true)
 check("duplicate decision load rejected atomically",not s.load_from(path) and s.data==before)
 var out=FileAccess.open("res://evidence/pricing-checks.json",FileAccess.WRITE);out.store_string(JSON.stringify({"checks":results,"comparison":comparison},"  "));out.close()
 quit(0 if results.all(func(r):return r.pass) else 1)
