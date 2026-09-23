extends Node2D
const SPEED = 110.0
const CYCLE = 0.72
var appearance=0
var rigs = {}
var players = {}
var rig_data = {}
var phase = 0.0
var facing = "front"
var direction = Vector2.ZERO
var reaching = false
var reach_clock = 0.0
var last_position=Vector2.ZERO
var pose_initialized=false
var turn_clock=0.0
var stride_weight=0.0
func _ready():
 rig_data = JSON.parse_string(FileAccess.get_file_as_string("res://art/rig.json"))
 for view in ["front","side","back"]: build_rig(view)
 pose(Vector2.ZERO,0.0)
func reach():
 reaching=true
 reach_clock=0
 facing="side"
 rigs.side.scale.x=abs(rigs.side.scale.x)
 players.side.play("reach")
func pose(movement: Vector2,delta: float):
 # Derive stride from physical displacement, never a requested but blocked route.
 var displacement=position-last_position if pose_initialized else Vector2.ZERO
 last_position=position;pose_initialized=true
 if displacement.length()>30:displacement=Vector2.ZERO # restored/spawned pose
 direction=displacement.normalized() if displacement.length()>.01 else Vector2.ZERO
 if delta==0:direction=movement
 if reaching:
  reach_clock+=delta
  direction=Vector2.ZERO
  if reach_clock>=1.5:reaching=false
 if direction!=Vector2.ZERO:
  turn_clock+=delta
  var wanted="side" if abs(direction.x)>abs(direction.y)*1.15 else "front" if direction.y>0 else "back"
  if wanted!=facing and turn_clock>=.10:
   facing=wanted;turn_clock=0
  if facing=="side" and abs(direction.x)>.2:rigs.side.scale.x=abs(rigs.side.scale.x)*sign(direction.x)
  phase=fmod(phase+displacement.length()/(SPEED*CYCLE),1.0)
 stride_weight=move_toward(stride_weight,1.0 if direction!=Vector2.ZERO else 0.0,delta*8)
 for view in rigs:
  rigs[view].visible=view==facing
  if not reaching:
   players[view].stop()
   for part in ["near_arm","far_arm"]:
    var node=rigs[view].get_node(part)
    var swing=sin(phase*TAU)*(.10 if part=="far_arm" else -.10)*stride_weight
    node.rotation=lerp_angle(node.rotation,swing,minf(1,delta*14))
 pose_feet()
func build_rig(view: String) -> void:
 var root = Node2D.new()
 root.name = view
 root.scale = Vector2.ONE * (110.0/928.0)
 add_child(root)
 rigs[view] = root
 var data: Dictionary = rig_data[view]
 for part in ["far_leg","near_leg","far_arm","torso","head","near_arm"]:
  var pivot = Vector2(data.pivots[part][0],data.pivots[part][1])
  var node = Node2D.new()
  node.name = part
  node.position = pivot-Vector2(data.foot[0],data.foot[1])
  root.add_child(node)
  var sprite = Sprite2D.new()
  sprite.texture = load("res://art/"+view+"/"+part+".png")
  sprite.centered = false
  sprite.position = -pivot
  node.add_child(sprite)
  # B6 adds authored outfit/accessory variants to the retained illustrated rig.
  if appearance>=3:
   if part=="torso":sprite.modulate=[Color("b594d8"),Color("75b9a0"),Color("dea266")][appearance-3]
   if part=="head":
    var accessory=Sprite2D.new();accessory.texture=load("res://art/customer-%d-%s.png"%[appearance,view]);accessory.centered=false;accessory.position=-pivot;node.add_child(accessory)
 var ap = AnimationPlayer.new()
 root.add_child(ap)
 players[view] = ap
 var lib = AnimationLibrary.new()
 var walk = Animation.new()
 walk.length = CYCLE
 walk.loop_mode = Animation.LOOP_LINEAR
 var phase_track = walk.add_track(Animation.TYPE_VALUE)
 walk.track_set_path(phase_track,NodePath("../:phase"))
 walk.track_insert_key(phase_track,0.0,0.0)
 walk.track_insert_key(phase_track,CYCLE,1.0)
 for part in ["far_arm","near_arm"]:
  var track = walk.add_track(Animation.TYPE_VALUE)
  walk.track_set_path(track,NodePath(part+":rotation"))
  var amp = 0.12 if part=="far_arm" else -0.12
  for i in range(5):walk.track_insert_key(track,i*CYCLE/4.0,sin(i*PI/2)*amp)
 lib.add_animation("walk",walk)
 var reach = Animation.new()
 reach.length = 1.5
 var tr = reach.add_track(Animation.TYPE_VALUE)
 reach.track_set_path(tr,NodePath("near_arm:rotation"))
 for kv in [[0.0,0.0],[0.45,-0.70],[1.0,-0.70],[1.5,0.0]]:reach.track_insert_key(tr,kv[0],kv[1])
 lib.add_animation("reach",reach)
 ap.add_animation_library("",lib)

func pose_feet() -> void:
 var data:Dictionary=rig_data[facing]
 var unit=110.0/928.0
 for part in ["near_leg","far_leg"]:
  var node:Node2D=rigs[facing].get_node(part)
  var p=fmod(phase+(0.5 if part=="far_leg" else 0.0),1.0)
  var along=(0.5-p*2.0) if p<0.5 else (-0.5+(p-0.5)*2.0)
  var travel=direction*SPEED*CYCLE*0.5*along*stride_weight/unit
  if facing=="side":travel.x*=sign(rigs.side.scale.x)
  var lift=sin((p-0.5)*TAU)*4.0/unit if p>0.5 else 0.0
  var rest=Vector2(0,405)
  if facing=="front":rest=Vector2(-22 if part=="far_leg" else 18,400)
  if facing=="back":rest=Vector2(-20 if part=="far_leg" else 20,400)
  var target=rest+travel-Vector2(0,lift*stride_weight)
  node.rotation=lerp_angle(node.rotation,target.angle()-rest.angle(),0.45)
  # Keep the painted leg shape; bounded stretch avoids rubber-like deformation.
  node.scale.y=lerpf(node.scale.y,clampf(target.length()/rest.length(),0.96,1.04),0.45)
