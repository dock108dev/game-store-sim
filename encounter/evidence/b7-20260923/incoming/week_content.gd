extends RefCounted
# B6 authored first-week content. Materialize once at Open; no random demand.
const PRODUCTS=["curb","tide","orbit","signal","rally"]
const CATALOG={
 "curb":{"name":"Curb Circuit 02","cost":800,"reference":2000,"release":1,"art":"case"},
 "tide":{"name":"Tidebound Atlas","cost":1200,"reference":2600,"release":1,"art":"case-tide"},
 "orbit":{"name":"Orbit Orchard","cost":500,"reference":1400,"release":1,"art":"case-orbit"},
 "signal":{"name":"Signal Harbor","cost":1600,"reference":3000,"release":4,"art":"case-signal"},
 "rally":{"name":"Pocket Rally Club","cost":1000,"reference":2400,"release":6,"art":"case-rally"}}
const DAYS=[
 ["curb","tide","orbit"],
 ["curb","tide","orbit","tide"],
 ["curb","tide","orbit","curb","orbit"],
 ["curb","tide","orbit","signal","orbit","tide"],
 ["curb","tide","orbit","signal","tide","curb","orbit"],
 ["curb","tide","orbit","signal","rally","curb","tide","orbit"],
 ["curb","tide","orbit","signal","rally","orbit","curb","tide"]]
const NAMES=["Alex","Blair","Casey","Devon","Ellis","Frankie"]
static func released(product: String,day: int) -> bool:
 return CATALOG.has(product) and day>=CATALOG[product].release
static func roster(run: String,day: int) -> Dictionary:
 var result={};var seen={}
 for n in range(DAYS[day-1].size()):
  var product=DAYS[day-1][n];var occurrence=int(seen.get(product,0))
  var percent=110 if occurrence==0 else (90 if occurrence%2==1 else 80)
  var id="buyer:"+run+":"+str(day)+":"+str(n+1)
  result[id]={"product":product,"name":NAMES[n%6],"appearance":n%6,"arrival":n*18.0,"budget":int(CATALOG[product].reference*percent/100),"accept_used":occurrence>0}
  seen[product]=occurrence+1
 return result
