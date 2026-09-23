extends RefCounted
# Evaluation policies use the public calendar, owned inventory, reference labels,
# disclosed seller counters and prior reports; never buyer budgets.
static func growth(name):return name in ["growth","one_worker","no_used"]
static func trading(name):return name in ["growth","one_worker"]
static func hire_day(name,id):
 if not growth(name):return 0
 return 3 if id=="morgan" else (6 if name=="growth" or name=="no_used" else 0)
static func percent(name,day):
 if name=="recovery":return 150 if day==1 else (100 if day==2 else 90)
 return 90 if name=="lean" else 100
static func quantities(s,name):
 var q=[0,0,0,0,0];var day=int(s.data.day)
 if name=="bankruptcy":return [6,6,6,0,0] if day<3 else q
 if name in ["closed","starter_only"]:return q
 if growth(name):
  if day in [3,5,7]:return [1,1,1,0,0]
  if day==4:return [1,1,1,2,0]
  if day==6:return [1,1,1,2,2]
  return q
 # Calendar replenishment: buy only today's visible demand shortfall.
 for n in range(5):
  var p=s.PRODUCTS[n]
  var owned=s.data.items.values().filter(func(i):return i.product==p and i.location!="sold" and i.kind=="new").size()
  q[n]=maxi(0,s.Week.DAYS[day-1].count(p)-owned)
 return q
