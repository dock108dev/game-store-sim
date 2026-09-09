extends Node2D
const SAMPLE = "B-ROWAN-01 / retail-v4"
const SPEED = 72.0
const CYCLE = 0.72
var actor: Node2D
var rigs = {}
var players = {}
var facing = "front"
var status: Label
var demo = false
var elapsed = 0.0
var reaching = false
var reach_clock = 0.0
var gait = 0.0
var direction = Vector2.ZERO
var capture = false
var frame = 0
var shelf: Node2D
var rig_data = {}
var route_index = 0
var hold_time = 0.0
var phase = 0.0
var authored=false
var framesprite:Sprite2D
var trace=[]

func polygon(parent: Node, points: PackedVector2Array, color: Color) -> void:
 var p = Polygon2D.new()
 p.polygon = points
 p.color = color
 parent.add_child(p)

func label_at(text: String, pos: Vector2, size: int, color: Color) -> Label:
 var l = Label.new()
 l.text = text
 l.position = pos
 l.add_theme_font_size_override("font_size", size)
 l.modulate = color
 add_child(l)
 return l

func _ready() -> void:
 RenderingServer.set_default_clear_color(Color("e8e2d5"))
 texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
 var context = Sprite2D.new()
 context.texture = load("res://art/retail-context.png")
 context.centered = false
 context.scale = Vector2.ONE * 0.25
 add_child(context)
 var world = Node2D.new()
 world.y_sort_enabled = true
 add_child(world)
 shelf = Node2D.new()
 shelf.position = Vector2(640,390)
 world.add_child(shelf)
 var fixture = Sprite2D.new()
 fixture.texture = load("res://art/retail-shelf.png")
 fixture.centered = false
 fixture.position = Vector2(-125,-115)
 fixture.scale = Vector2.ONE * 0.25
 shelf.add_child(fixture)
 actor = Node2D.new()
 actor.position = Vector2(430,470)
 world.add_child(actor)
 var shadow = Polygon2D.new()
 var points = PackedVector2Array()
 for i in range(32): points.append(Vector2(cos(i*TAU/32)*15,sin(i*TAU/32)*4))
 shadow.polygon = points
 shadow.color = Color(0.15,0.19,0.17,0.18)
 actor.add_child(shadow)
 rig_data = JSON.parse_string(FileAccess.get_file_as_string("res://art/rig.json"))
 for view in ["front","side","back"]: build_rig(view)
 framesprite=Sprite2D.new()
 framesprite.centered=false
 framesprite.position=Vector2(-256,-480)*(110.0/449.0)
 framesprite.scale=Vector2.ONE*(110.0/449.0)
 actor.add_child(framesprite)
 var marker=Line2D.new()
 marker.width=1.5
 marker.default_color=Color("87927b")
 for i in range(33):marker.add_point(Vector2(493,379)+Vector2(cos(i*TAU/32),sin(i*TAU/32))*18)
 add_child(marker)
 label_at("REPLAY JUNCTION / ART DIRECTION SAMPLE",Vector2(55,36),15,Color("657265"))
 label_at("A mall game shop, circa 2002",Vector2(55,64),30,Color("293d38"))
 label_at("WASD / arrows  Walk     •     Release  Stop     •     E  Reach at shelf",Vector2(55,651),18,Color("293d38"))
 label_at("R  Reset     •     T  Demonstration     •     1–4  Turn     •     F  Compare authored side frames",Vector2(55,680),16,Color("657265"))
 status = label_at("",Vector2(55,115),17,Color("657265"))
 label_at(SAMPLE,Vector2(940,40),14,Color("657265"))
 capture = "--capture" in OS.get_cmdline_user_args()
 authored="--authored" in OS.get_cmdline_user_args()
 demo = capture or "--demo" in OS.get_cmdline_user_args()
 if capture: DirAccess.make_dir_recursive_absolute("res://evidence/frames")
 print("DISPLAY ",JSON.stringify({"window_pixels":DisplayServer.window_get_size(),"screen_scale":DisplayServer.screen_get_scale(),"screen_dpi":DisplayServer.screen_get_dpi(),"viewport":get_viewport_rect().size,"canvas_scale":get_viewport().get_final_transform().get_scale(),"character_logical_height":110,"sample":SAMPLE}))

func build_rig(view: String) -> void:
 var root = Node2D.new()
 root.name = view
 root.scale = Vector2.ONE * (110.0/928.0)
 actor.add_child(root)
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
 var ap = AnimationPlayer.new()
 root.add_child(ap)
 players[view] = ap
 var lib = AnimationLibrary.new()
 var walk = Animation.new()
 walk.length = CYCLE
 walk.loop_mode = Animation.LOOP_LINEAR
 var phase_track = walk.add_track(Animation.TYPE_VALUE)
 walk.track_set_path(phase_track,NodePath("../../../:phase"))
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

func _unhandled_key_input(event: InputEvent) -> void:
 if not event is InputEventKey or not event.pressed or event.echo:return
 if event.keycode == KEY_T:demo = not demo;elapsed = 0;route_index=0;hold_time=0;actor.position=Vector2(430,470)
 if event.keycode == KEY_R:actor.position=Vector2(430,470);reaching=false;demo=false
 if event.keycode == KEY_F:authored=not authored
 if event.keycode == KEY_E: start_reach()
 if event.keycode in [KEY_1,KEY_2,KEY_3,KEY_4] and not reaching:
  facing = {KEY_1:"front",KEY_2:"side",KEY_3:"back",KEY_4:"side"}[event.keycode]
  rigs.side.scale.x = abs(rigs.side.scale.x)*(-1 if event.keycode==KEY_4 else 1)

func start_reach() -> void:
 if reaching:return
 if actor.position.distance_to(Vector2(493,379))<28:
  actor.position=Vector2(493,379)
  facing="side"
  rigs.side.scale.x=abs(rigs.side.scale.x)
  reaching=true
  reach_clock=0
  players.side.play("reach")

func _process(delta: float) -> void:
 elapsed += delta
 direction=Vector2.ZERO
 if demo:
  var route=[Vector2(800,470),Vector2(850,470),Vector2(850,330),Vector2(480,330),Vector2(480,420),Vector2(493,379)]
  if hold_time>0:
   hold_time-=delta
  elif route_index<route.size():
   var dest:Vector2=route[route_index]
   if actor.position.distance_to(dest)>2.5:direction=(dest-actor.position).normalized()
   else:
    route_index+=1
    hold_time=0.5
  elif route_index==route.size():
   start_reach()
   route_index+=1
   hold_time=2.0
  else:
   actor.position=Vector2(430,470)
   route_index=0

 else:
  direction=Vector2(float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT))-float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)),float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN))-float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP))).normalized()
 if reaching:
  direction=Vector2.ZERO
  reach_clock+=delta
  if reach_clock>=1.5:reaching=false
 if direction!=Vector2.ZERO:
  facing="side" if abs(direction.x)>=abs(direction.y) else ("front" if direction.y>0 else "back")
  if facing=="side":rigs.side.scale.x=abs(rigs.side.scale.x)*sign(direction.x)
  var next=actor.position+direction*SPEED*delta
  # Footprint ends above the shelf sorting line; bypass at either end.
  if not Rect2(510,349,260,42).has_point(next):actor.position=next.clamp(Vector2(170,250),Vector2(1100,590))
  gait+=delta
  players[facing].play("walk")
 else:
  if not reaching:
   for ap in players.values():ap.stop()
   for root in rigs.values():
    for part in ["far_leg","near_leg","far_arm","near_arm"]:root.get_node(part).rotation=0
 if direction!=Vector2.ZERO: pose_feet()
 else:
  for view in rigs:
   for part in ["far_leg","near_leg"]:rigs[view].get_node(part).scale=Vector2.ONE
 for view in rigs:rigs[view].visible=view==facing and not (authored and facing=="side")
 rigs.side.get_node("near_arm").z_index=1 if reaching else 0
 framesprite.visible=authored and facing=="side"
 if framesprite.visible:
  var idx=5 if reaching and reach_clock>0.35 and reach_clock<1.1 else (int(fmod(gait,CYCLE)/CYCLE*4) if direction!=Vector2.ZERO else 4)
  framesprite.texture=load("res://art/authored/%d.png"%idx)
  framesprite.flip_h=rigs.side.scale.x<0
  framesprite.z_index=1 if reaching else 0
 status.text=("Authored comparison • " if authored else "Cutout • ")+("Demonstration" if demo else "Your controls")+"  /  "+("Reaching" if reaching else ("Walking" if direction!=Vector2.ZERO else "Stopped"))+"  /  "+facing
 if not reaching and actor.position.distance_to(Vector2(493,379))<28:status.text+="  •  E to reach"
 queue_redraw()
 if capture:
  trace.append({"frame":frame,"position":[actor.position.x,actor.position.y],"facing":facing,"moving":direction!=Vector2.ZERO,"reaching":reaching,"phase":phase,"route":route_index})
  await RenderingServer.frame_post_draw
  get_viewport().get_texture().get_image().save_png("res://evidence/frames/%04d.png"%frame)
  frame+=1
  if frame>=750:
   var out=FileAccess.open("res://evidence/motion-trace.json",FileAccess.WRITE)
   out.store_string(JSON.stringify(trace))
   get_tree().quit()


func pose_feet() -> void:
 var data:Dictionary=rig_data[facing]
 var unit=110.0/928.0
 for part in ["near_leg","far_leg"]:
  var node:Node2D=rigs[facing].get_node(part)
  var p=fmod(phase+(0.5 if part=="far_leg" else 0.0),1.0)
  var along=(0.5-p*2.0) if p<0.5 else (-0.5+(p-0.5)*2.0)
  var travel=direction*SPEED*CYCLE*0.5*along/unit
  if facing=="side":travel.x*=sign(rigs.side.scale.x)
  var lift=sin((p-0.5)*TAU)*4.0/unit if p>0.5 else 0.0
  var rest=Vector2(0,405)
  if facing=="front":rest=Vector2(-22 if part=="far_leg" else 18,400)
  if facing=="back":rest=Vector2(-20 if part=="far_leg" else 20,400)
  var target=rest+travel-Vector2(0,lift)
  node.rotation=target.angle()-rest.angle()
  node.scale.y=target.length()/rest.length()
