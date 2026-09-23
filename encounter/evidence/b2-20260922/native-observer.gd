extends SceneTree
var scene
var frames=0
var trace=[]
var last=""
func _initialize():call_deferred("start")
func start():
 scene=load("res://main.tscn").instantiate();root.add_child(scene);scene.save_path="user://b2-native.json"
 root.size=Vector2i(2560,1440)
 process_frame.connect(record)
func record():
 frames+=1
 if frames%15!=0:return
 trace.append({"frame":frames,"phase":scene.state.data.phase,"revision":scene.state.data.layout_revision,"cash":scene.state.data.cash,"customers":scene.state.data.customers.duplicate(true),"player":[scene.player.position.x,scene.player.position.y]})
 var out=FileAccess.open("res://evidence/native-motion.json",FileAccess.WRITE);out.store_string(JSON.stringify(trace));out.close()
 var identity=JSON.stringify([scene.state.data.phase,scene.state.data.layout_revision,scene.state.shelf_used(),scene.state.data.sales.size(),scene.draft.get("origin"),scene.state.data.queue])
 if identity!=last:
  last=identity
  RenderingServer.force_draw()
  root.get_texture().get_image().save_png("res://evidence/native-%05d.png"%frames)
