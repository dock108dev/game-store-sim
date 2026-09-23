extends "res://scripts/test_week.gd"
const Policy=preload("res://scripts/b8_policy.gd")
func _initialize():
 for name in ["growth","lean","recovery","closed","starter_only","one_worker","no_used","bankruptcy"]:
  var s=State.new();s.receive();var days=[]
  if name not in ["closed","starter_only"]:s.commit_fixture(cmd(s))
  for day in range(1,8):
   for id in State.Staff.IDS:
    if Policy.hire_day(name,id)==day or (name=="bankruptcy" and day==3):s.hire(id)
   if Policy.growth(name) and day==5:s.commit_fixture(cmd(s,"expand",[440,230],"rack-0003","bay"))
   var q=Policy.quantities(s,name);var order={}
   for n in range(5):order[State.PRODUCTS[n]]=q[n]
   if q.any(func(v):return v>0):check("screen order "+name,s.order(order,day) and s.receive())
   if name not in ["closed","bankruptcy"]:
    for p in State.PRODUCTS:s.reprice(int(State.CATALOG[p].reference*Policy.percent(name,day)/100),p)
    for copy in s.ordered_copy_ids():
     var item=s.data.items[copy]
     if item.location!="backroom" or item.available_day>day:continue
     if item.kind=="used":s.price_copy(copy,int(State.CATALOG[item.product].reference*State.Used.GRADES[item.condition]/100),item.duplicate(true))
     var slot=s.free_slot()
     if not slot.is_empty():s.stock_copy(copy,slot.fixture_id,slot.slot_index,s.data.layout_revision)
   s.open()
   if Policy.trading(name) and day in range(2,7):
    var row=intake(s);offer(s,100);var counter=s.seller().floor
    check("visible seller counter accepted",offer(s,int(counter)).ok)
    check("screen purchase",s.purchase_used(State.Used.command(s)).ok)
   for id in s.buyer_ids():
    if select(s,id):serve(s,id)
    else:s.gone(id)
   finish(s)
   days.append({"day":day,"report":s.business_report(day),"retail":s.report(),"state":s.data.duplicate(true)})
   if day<7:s.advance(day)
  examples[name]={"days":days,"final":s.business_report(),"terminal":s.data.terminal}
  check("screen terminal "+name,s.data.phase==("bankrupt" if name=="bankruptcy" else "week_complete"))
  var before=s.data.duplicate(true)
  check("terminal sealed "+name,not s.advance(7) and not s.open() and not s.finalize() and s.data==before)
 var f=FileAccess.open("res://evidence/b8-screen.json",FileAccess.WRITE);f.store_string(JSON.stringify({"checks":results,"strategies":examples},"  "));f.close()
 quit(1 if results.any(func(r):return not r.pass) else 0)
