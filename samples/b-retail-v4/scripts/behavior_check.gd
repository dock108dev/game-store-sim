extends SceneTree
var sample
var checks=[]
func _initialize():call_deferred("run")
func key(k:int,pressed:bool):
 var e=InputEventKey.new()
 e.keycode=k
 e.physical_keycode=k
 e.pressed=pressed
 Input.parse_input_event(e)
func wait_frames(n:int):
 for i in range(n):await process_frame
func check(name:String,ok:bool):
 checks.append({"name":name,"pass":ok})
 if not ok:push_error(name)
func run():
 sample=load("res://main.tscn").instantiate()
 root.add_child(sample)
 await wait_frames(3)
 var p:Vector2=sample.actor.position
 key(KEY_D,true)
 await wait_frames(20)
 key(KEY_D,false)
 await wait_frames(3)
 check("D moves right and side faces right",sample.actor.position.x>p.x and sample.facing=="side" and sample.rigs.side.scale.x>0)
 p=sample.actor.position
 await wait_frames(8)
 check("released input stops root translation",sample.actor.position.distance_to(p)<0.01)
 key(KEY_W,true)
 await wait_frames(10)
 key(KEY_W,false)
 await wait_frames(3)
 check("W moves up with back view",sample.actor.position.y<p.y and sample.facing=="back")
 key(KEY_S,true)
 await wait_frames(10)
 key(KEY_S,false)
 await wait_frames(3)
 check("S uses front view",sample.facing=="front")
 key(KEY_A,true)
 await wait_frames(10)
 key(KEY_A,false)
 await wait_frames(3)
 check("A mirrors side consistently",sample.facing=="side" and sample.rigs.side.scale.x<0)
 sample.actor.position=Vector2(493,379)
 key(KEY_E,true)
 await wait_frames(2)
 key(KEY_E,false)
 check("E begins shelf reach",sample.reaching)
 await wait_frames(50)
 check("reach returns to idle without root drift",not sample.reaching and sample.actor.position==Vector2(493,379))
 sample.actor.position=Vector2(640,394)
 key(KEY_W,true)
 await wait_frames(20)
 key(KEY_W,false)
 check("shelf footprint blocks crossing",sample.actor.position.y>=391)
 key(KEY_F,true)
 await wait_frames(2)
 key(KEY_F,false)
 check("authored comparison toggles",sample.authored)
 for k in [KEY_1,KEY_2,KEY_3,KEY_4]:
  key(k,true)
  await wait_frames(2)
  key(k,false)
  var expected={KEY_1:"front",KEY_2:"side",KEY_3:"back",KEY_4:"side"}[k]
  check("number key %d facing without translation"%k,sample.facing==expected and sample.direction==Vector2.ZERO and (k!=KEY_4 or sample.rigs.side.scale.x<0))
 var out=FileAccess.open("res://evidence/behavior-checks.json",FileAccess.WRITE)
 out.store_string(JSON.stringify(checks,"  "))
 var passed=true
 for c in checks:passed=passed and c.pass
 quit(0 if passed else 1)
