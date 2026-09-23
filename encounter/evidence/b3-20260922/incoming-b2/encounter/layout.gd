extends RefCounted
# All geometry is in logical pixels. Footprints, ports, artwork and paths share origins.
const RADIUS=12
const ENTRY=Vector2(210,580)
const SPAWN=Vector2(400,550)
const SLOT_ANCHORS=[Vector2(65,-34),Vector2(105,-34),Vector2(145,-34),Vector2(185,-34)]
static func initial() -> Dictionary:
 return {"space_level":0,"fixtures":{"receiving-01":{"type":"receiving","origin":[270,430]},"checkout-01":{"type":"counter","origin":[690,470]},"rack-0001":{"type":"rack","origin":[440,330]}}}
static func fixture_definition(type: String) -> Dictionary:
 return {"rack":{"size":Vector2(260,40),"slots":4,"art":"retail-shelf-empty","art_offset":Vector2(5,-74)},"receiving":{"size":Vector2(80,40),"slots":0,"art":"shipment","art_offset":Vector2(1,-22)},"counter":{"size":Vector2(200,80),"slots":0,"art":"counter","art_offset":Vector2(-5,-30)}}.get(type,{})
static func origin(f: Dictionary) -> Vector2:return Vector2(f.origin[0],f.origin[1])
static func footprint(f: Dictionary) -> Rect2:return Rect2(origin(f),fixture_definition(f.type).size)
static func floor_bounds(_space_level=0) -> Rect2:return Rect2(180,300,720,310)
static func capacity(layout: Dictionary) -> int:return slot_ids(layout).size()
static func racks(layout: Dictionary) -> Array:
 var ids=layout.fixtures.keys().filter(func(id):return layout.fixtures[id].type=="rack");ids.sort();return ids
static func slot_ids(layout: Dictionary) -> Array:
 var slots=[]
 for id in racks(layout):
  for n in range(4):slots.append({"fixture_id":id,"slot_index":n})
 return slots
static func obstacles(layout: Dictionary) -> Array:
 var result=[]
 for f in layout.fixtures.values():result.append(footprint(f))
 return result
static func ports(layout: Dictionary,id: String) -> Dictionary:
 if not layout.fixtures.has(id):return {}
 var f=layout.fixtures[id];var p=origin(f)
 match f.type:
  "rack":return {"browse-0":p+Vector2(60,70),"browse-1":p+Vector2(180,70),"work":p+Vector2(60,70)}
  "receiving":return {"receive":p+Vector2(100,20)}
  "counter":return {"cashier":p+Vector2(-30,30),"buyer":p+Vector2(110,100),"intake":p+Vector2(160,-50)}
 return {}
static func queue_ports(_layout: Dictionary) -> Array:return [Vector2(800,570),Vector2(720,570),Vector2(640,570)]
static func walkable(layout: Dictionary,p: Vector2) -> bool:
 if not floor_bounds().has_point(p):return false
 for b in obstacles(layout):
  if b.grow(RADIUS).has_point(p):return false
 return true
static func navigation(layout: Dictionary) -> AStarGrid2D:
 var grid=AStarGrid2D.new();grid.region=Rect2i(18,30,72,31);grid.cell_size=Vector2(10,10);grid.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_NEVER;grid.update()
 for x in range(18,90):
  for y in range(30,61):
   if not walkable(layout,Vector2(x,y)*10):grid.set_point_solid(Vector2i(x,y))
 return grid
static func failure(reason: String,id="",port="") -> Dictionary:return {"ok":false,"reason":reason,"fixture_id":id,"port_id":port}
static func check(layout) -> Dictionary:
 if not layout is Dictionary or layout.get("space_level")!=0 or not layout.get("fixtures") is Dictionary:return failure("Unsupported shop space")
 var fixtures=layout.fixtures
 if fixtures.size()<3 or fixtures.size()>4:return failure("Rack limit reached")
 for id in fixtures:
  var f=fixtures[id]
  if not f is Dictionary or f.get("type") not in ["rack","receiving","counter"] or not f.get("origin") is Array or f.origin.size()!=2:return failure("Invalid fixture",id)
  for v in f.origin:
   if not (v is int or v is float) or not is_finite(float(v)) or v!=int(v) or int(v)%10!=0:return failure("Use the 10px grid",id)
  if id not in ["rack-0001","rack-0002","receiving-01","checkout-01"]:return failure("Unknown fixture",id)
  if id.begins_with("rack") and f.type!="rack":return failure("Invalid rack",id)
  var b=footprint(f)
  if not floor_bounds().encloses(b):return failure("Outside shop",id)
  if b.intersects(Rect2(190,300,60,310)) or b.intersects(Rect2(180,560,720,50)):return failure("Blocks reserved aisle",id)
 for id in initial().fixtures:
  if not fixtures.has(id):return failure("Missing fixture",id)
  if id!="rack-0001" and (fixtures[id].type!=initial().fixtures[id].type or origin(fixtures[id])!=origin(initial().fixtures[id])):return failure("Fixed station cannot move",id)
 for id in fixtures:
  for other in fixtures:
   if other!=id and footprint(fixtures[id]).intersects(footprint(fixtures[other])):return failure("Overlaps "+other,id)
 var required={"entry":ENTRY,"spawn":SPAWN}
 for id in fixtures:
  for key in ports(layout,id):required[id+"/"+key]=ports(layout,id)[key]
 for n in range(3):required["queue/"+str(n)]=queue_ports(layout)[n]
 var grid=navigation(layout)
 for key in required:
  var p=required[key]
  if not walkable(layout,p):return failure("Blocks port "+key,key.get_slice("/",0),key)
  if grid.get_id_path(Vector2i(ENTRY/10),Vector2i(p/10)).is_empty():return failure("Blocks route to "+key,key.get_slice("/",0),key)
 return {"ok":true,"reason":"Placement valid","fixture_id":"","port_id":""}
