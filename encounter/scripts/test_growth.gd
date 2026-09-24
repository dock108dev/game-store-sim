extends SceneTree
const State=preload("res://state.gd")
const Layout=preload("res://layout.gd")
var results=[]
var examples={}
func check(name,ok):
 results.append({"check":name,"pass":ok})
 if not ok:push_error(name)
func cmd(s,op="expand",pos=[440,230],id="rack-0001",request="expand"):
 return {"request_id":request,"operation":op,"type":"rack","fixture_id":id,"origin":pos,"day":s.data.day,"phase":s.data.phase,"revision":s.data.layout_revision}
func finish(s):
 s.close()
 for id in s.data.customers:
  if s.data.customers[id].state not in ["gone","cancelled"]:
   if s.data.customers[id].state!="leaving":s.depart(id)
   s.gone(id)
 return s.finalize()
func day_to(s,day):
 if not s.data.received:s.receive()
 while s.data.day<day:
  s.open();finish(s);s.advance(s.data.day);s.receive()
func rt(s,name):
 var p="user://growth-"+name+".json";var t=State.new()
 check("reload "+name,s.valid() and s.save_to(p) and t.load_from(p) and t.data==s.data and t.valid())
 return t
func rejected(s,c,name):
 var before=s.data.duplicate(true)
 check(name,not s.commit_fixture(c).ok and s.data==before)
func sell_day(s):
 for p in State.PRODUCTS:s.reprice(1000,p);s.stock(p)
 s.open()
 for id in s.buyer_ids():
  s.tick(10);s.arrive(id);s.browse(id)
  if s.reserve(id):s.queue(id);s.data.customers[id].settled=true;s.sale(id)
  if s.data.customers[id].state=="leaving":s.gone(id)
 finish(s)
func _initialize():
 var s=State.new();s.receive()
 check("schema9 six prepaid copies original references",s.valid() and s.data.version==9 and s.data.cash==55000 and s.data.items.size()==6 and State.CATALOG.curb.reference==2199)
 rejected(s,cmd(s),"day1 expansion rejected unchanged")
 day_to(s,4);rejected(s,cmd(s),"day4 expansion rejected unchanged")
 day_to(s,5)
 var before=s.data.duplicate(true)
 check("expanded preview pure",s.preview_fixture(cmd(s)).ok and s.data==before)
 var expansion=cmd(s)
 check("expand without rack2",s.commit_fixture(expansion).ok and s.data.cash==45000 and s.capacity()==8 and s.valid())
 check("north bay walkable and queue unchanged",Layout.walkable(s.data.layout,Vector2(300,240)) and Layout.queue_ports(s.data.layout)==[Vector2(800,570),Vector2(720,570),Vector2(640,570)])
 s=rt(s,"expanded")
 before=s.data.duplicate(true)
 check("same expansion request after reload inert",s.commit_fixture(expansion).ok and s.data==before)
 rejected(s,cmd(s,"expand",[440,230],"rack-0001","another"),"new duplicate expansion rejected")
 check("rack2 later costs60 keeps rack3",s.commit_fixture(cmd(s,"buy",[400,430],"rack-0001","late-rack")).ok and s.data.cash==39000 and s.capacity()==12 and s.valid())
 s=rt(s,"late-rack")
 var blocked=State.new();day_to(blocked,5)
 check("move rack to obstruct future bay",blocked.commit_fixture(cmd(blocked,"move",[440,310],"rack-0001","blocking")).ok)
 rejected(blocked,cmd(blocked),"entire expanded layout checks blocked port without charge")
 check("rearrange then expand with rack2",blocked.commit_fixture(cmd(blocked,"move",[440,330],"rack-0001","unblock")).ok and blocked.commit_fixture(cmd(blocked,"buy",[400,430],"rack-0001","rack2")).ok and blocked.commit_fixture(cmd(blocked)).ok and blocked.capacity()==12 and blocked.valid())
 # Historical growth-only surviving run: $10 labels, three shoppers/day; buy growth, replenish overnight.
 var survivor=State.new();survivor.receive();survivor.commit_fixture(cmd(survivor,"buy",[400,430],"rack-0001","rack2"))
 for day in range(1,8):
  if day==5:check("surviving route buys expansion",survivor.commit_fixture(cmd(survivor)).ok)
  sell_day(survivor)
  check("survivor day%d reconciles"%day,survivor.valid() and survivor.business_report(day).cash==survivor.data.cash)
  survivor=rt(survivor,"survivor-day"+str(day))
  before=survivor.data.duplicate(true)
  check("settlement day%d cannot repeat"%day,not survivor.finalize() and survivor.data==before)
  if day<7:
   if day>=2:check("overnight replenishment day%d"%day,survivor.order({"curb":1,"tide":1,"orbit":1},day))
   survivor.advance(day);survivor.receive()
 check("surviving B3 actual $325 and no wages",survivor.data.phase=="week_complete" and survivor.data.cash==32500 and survivor.data.wage_commitments.is_empty() and survivor.data.sales.size()==21 and survivor.business_report().margin==3500 and survivor.business_report().operating_result==-11500)
 examples.surviving=survivor.data.duplicate(true)
 before=survivor.data.duplicate(true)
 check("terminal rejects all business mutations",not survivor.advance(7) and not survivor.open() and not survivor.receive() and not survivor.order({"curb":1,"tide":1,"orbit":1},7) and not survivor.price(1000) and not survivor.stock() and not survivor.return_copy("case-01") and not survivor.close() and not survivor.commit_fixture(expansion).ok and not survivor.commit_wage("morgan") and not survivor.reset() and survivor.data==before)
 # No employee costs: spend $450 in stock, $60 rack -> $40; rent shortfall $110.
 var poor=State.new();poor.receive();poor.commit_fixture(cmd(poor,"buy",[400,430],"rack-0001","rack"))
 for day in range(1,8):
  poor.open();finish(poor)
  if day<=3:check("failure stock spending day%d"%day,poor.order({"curb":6,"tide":6,"orbit":6},day))
  if day<7:poor.advance(day);poor.receive()
  if day==4:rejected(poor,cmd(poor),"insufficient expansion cash unchanged")
 check("actual B3 rent bankruptcy $40 cash $110 shortfall",poor.valid() and poor.data.phase=="bankrupt" and poor.data.cash==4000 and poor.data.terminal.shortfall==11000 and poor.business_report().unpaid_liabilities==15000 and poor.business_report().operating_result==-15000 and poor.data.items.size()==60 and poor.data.wage_commitments.is_empty())
 poor=rt(poor,"bankrupt");examples.bankrupt=poor.data.duplicate(true)
 var old=poor.data.duplicate(true)
 check("restart blocks if terminal preservation fails",not poor.restart("user://missing-directory/checkpoint.json") and poor.data==old)
 check("restart preserves terminal before fresh checkpoint",poor.restart("user://restart.json") and poor.data.day==1 and poor.data.phase=="prep" and poor.data.run_id!=old.run_id and FileAccess.file_exists("user://terminal-"+old.run_id+".json"))
 var retained=State.new();check("retained bankruptcy reload",retained.load_from("user://terminal-"+old.run_id+".json") and retained.data==old)
 # A $150 cash finish pays rent exactly and survives at zero. No artificial cash edit.
 var zero=State.new();zero.receive()
 for day in range(1,8):
  if day==7:
   zero.checkpoint_path="user://rent-retry.json";zero.retry_save();DirAccess.make_dir_absolute(zero.checkpoint_path+".tmp")
  zero.open();finish(zero)
  if day<7:
   if day<=2:zero.order({"curb":6,"tide":6,"orbit":6},day)
   if day==3:zero.order({"curb":5,"tide":5,"orbit":0},day)
   zero.advance(day);zero.receive()
 check("zero after full rent survives",zero.valid() and zero.data.cash==0 and zero.data.phase=="week_complete")
 before=zero.data.duplicate(true)
 check("paid rent despite save failure cannot repeat",zero.save_pending and not zero.last_save_ok and not zero.finalize() and zero.data==before)
 DirAccess.remove_absolute(zero.checkpoint_path+".tmp")
 check("paid rent save retry preserves one payment",zero.retry_save() and zero.data==before and zero.data.events.filter(func(e):return e.kind=="rent").size()==1)
 # Checkpoint write failure does not undo a committed charge or mark it saved.
 var retry=State.new();day_to(retry,5);retry.checkpoint_path="user://retry.json";check("baseline checkpoint",retry.retry_save())
 var checkpoint_bytes=FileAccess.get_file_as_string(retry.checkpoint_path)
 DirAccess.make_dir_absolute(retry.checkpoint_path+".tmp")
 var c=cmd(retry)
 check("failed expansion save keeps exactly one live charge",retry.commit_fixture(c).ok and retry.data.cash==45000 and retry.save_pending and not retry.last_save_ok and FileAccess.get_file_as_string(retry.checkpoint_path)==checkpoint_bytes)
 before=retry.data.duplicate(true);retry.commit_fixture(c)
 check("repeat failed-save confirmation inert",retry.data==before)
 DirAccess.remove_absolute(retry.checkpoint_path+".tmp")
 check("save retry succeeds without duplicate charge",retry.retry_save() and not retry.save_pending and retry.data==before)
 retry.open();retry.close();DirAccess.make_dir_absolute(retry.checkpoint_path+".tmp")
 check("settlement save failure leaves committed report",retry.finalize() and retry.data.phase=="report" and retry.save_pending)
 before=retry.data.duplicate(true)
 check("failed save cannot repeat settlement",not retry.finalize() and retry.data==before)
 DirAccess.remove_absolute(retry.checkpoint_path+".tmp");check("settlement save retry",retry.retry_save() and retry.data==before)
 DirAccess.make_dir_absolute(retry.checkpoint_path+".tmp")
 check("advance save failure commits day once",retry.advance(5) and retry.data.day==6 and retry.save_pending and not retry.advance(5))
 before=retry.data.duplicate(true);DirAccess.remove_absolute(retry.checkpoint_path+".tmp")
 check("advance retry no duplicate day",retry.retry_save() and retry.data==before)
 # Synthetic setup of empty days; actual employment commands own all wages.
 var wage=State.new();day_to(wage,3)
 check("employment commitments once",wage.hire("morgan") and wage.hire("morgan") and wage.hire("jules") and wage.data.wage_commitments.size()==2 and wage.business_report(3).incurred_overhead==2400)
 wage.open();finish(wage)
 check("employment sorted wage settlement",wage.valid() and wage.data.cash==52600 and wage.data.events[0].reference=="jules" and wage.data.events[1].reference=="morgan")
 wage=rt(wage,"synthetic-wages")
 # Synthetic inability pays wages by staff ID, then leaves all remaining bills due.
 var wage_failure=State.new();wage_failure.receive()
 for day in range(1,7):
  wage_failure.open();finish(wage_failure)
  if day<=3:wage_failure.order({"curb":6,"tide":6,"orbit":6},day)
  if day==4:wage_failure.order({"curb":1,"tide":3,"orbit":0},day)
  wage_failure.advance(day);wage_failure.receive()
 wage_failure.commit_fixture(cmd(wage_failure,"buy",[400,430],"rack-0001","unaffordable"))
 # $56 cash remains; purchase the $100 expansion rejects without mutation.
 rejected(wage_failure,cmd(wage_failure),"synthetic low-cash expansion rejection")
 wage_failure.hire("morgan");wage_failure.hire("jules");wage_failure.open();finish(wage_failure)
 check("synthetic wages paid before unpaid rent",wage_failure.valid() and wage_failure.data.cash==3200 and wage_failure.data.phase=="bankrupt" and wage_failure.business_report().paid_overhead==2400 and wage_failure.business_report().unpaid_liabilities==15000)
 var unpaid_wages=State.new();unpaid_wages.receive();unpaid_wages.commit_fixture(cmd(unpaid_wages,"buy",[400,430],"rack-0001","rack"))
 for day in range(1,7):
  unpaid_wages.open();finish(unpaid_wages)
  if day<=3:unpaid_wages.order({"curb":6,"tide":6,"orbit":6},day)
  if day==4:unpaid_wages.order({"curb":4,"tide":0,"orbit":0},day)
  unpaid_wages.advance(day);unpaid_wages.receive()
 unpaid_wages.hire("morgan");unpaid_wages.hire("jules");unpaid_wages.open();finish(unpaid_wages)
 check("synthetic first unpaid wage records all remaining liabilities",unpaid_wages.valid() and unpaid_wages.data.cash==800 and unpaid_wages.data.terminal.shortfall==400 and unpaid_wages.data.terminal.unpaid.size()==3 and unpaid_wages.business_report().unpaid_liabilities==17400)
 examples["paid_wages_unpaid_rent"]=wage_failure.data.duplicate(true)
 examples["unpaid_wages_and_rent"]=unpaid_wages.data.duplicate(true)
 var capacity=State.new();capacity.receive()
 for day in range(1,4):
  capacity.open();finish(capacity);capacity.order({"curb":6,"tide":6,"orbit":6},day);capacity.advance(day);capacity.receive()
 capacity.open();finish(capacity);before=capacity.data.duplicate(true)
 check("64 backroom limit includes paid inbound; excessive order atomic",not capacity.order({"curb":6,"tide":0,"orbit":0},4) and capacity.data==before)
 check("four inbound fit capacity",capacity.order({"curb":0,"tide":4,"orbit":0},4) and capacity.backroom_committed()==64 and capacity.valid())
 # Malformed and prior saves are rejected without overwriting file or live state.
 for kind in ["old schema","wrong ruleset","missing settlement","wrong report","wrong rent","terminal","event status","wage","day8","run path"]:
  var bad=examples.surviving.duplicate(true)
  match kind:
   "old schema":bad.version=6
   "wrong ruleset":bad.ruleset_id="b2-layout-1"
   "missing settlement":bad.settlements.pop_back()
   "wrong report":bad.settlements[0].report.cash+=1
   "wrong rent":bad.events.back().amount-=1
   "terminal":bad.terminal.shortfall=10
   "event status":bad.events.back().status="due"
   "wage":bad.wage_commitments.append({"id":"fake"})
   "day8":bad.day=8
   "run path":bad.run_id="../../bad"
  var path="user://bad-"+kind.replace(" ","-")+".json";var f=FileAccess.open(path,FileAccess.WRITE);f.store_string(JSON.stringify(bad));f.close()
  before=s.data.duplicate(true);var bytes=FileAccess.get_file_as_string(path)
  check("reject malformed "+kind,not s.load_from(path) and s.data==before and FileAccess.get_file_as_string(path)==bytes)
  if kind in ["old schema","wrong ruleset"]:check("refuse overwrite incompatible "+kind,not s.save_to(path) and FileAccess.get_file_as_string(path)==bytes)
 var out=FileAccess.open("res://evidence/growth-state.json",FileAccess.WRITE);out.store_string(JSON.stringify({"checks":results,"examples":examples},"  "));out.close()
 print("B3_GROWTH_STATE ",results.size()," checks")
 quit(0 if results.all(func(r):return r.pass) else 1)
