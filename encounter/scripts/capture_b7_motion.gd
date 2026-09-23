extends SceneTree
var scene
var frames=0
var records=[]
var expanded=false
var output=""
func _initialize():call_deferred("run")
func run():
 root.size=Vector2i(1280,720)
 expanded="--expanded" in OS.get_cmdline_user_args()
 output="res://evidence/motion-"+("expanded" if expanded else "base")
 DirAccess.make_dir_recursive_absolute(output)
 scene=load("res://main.tscn").instantiate();root.add_child(scene)
 await process_frame
 scene.set_process(false)
 if scene.get("entry_menu")!=null:scene.entry_menu.hide();scene.entry_menu.queue_free();scene.flow_paused=false
 scene.save_path="user://motion.json";scene.state.checkpoint_path=scene.save_path
 scene.state.receive()
 while scene.state.data.day<5:
  scene.state.open();scene.state.close();scene.state.finalize();scene.state.advance(scene.state.data.day)
 if expanded:scene.begin_layout("expand");scene.confirm_layout()
 else:scene.begin_layout("buy");scene.confirm_layout()
 for p in ["curb","tide","orbit"]:scene.state.price(scene.State.CATALOG[p].reference,p)
 scene.state.hire("morgan");scene.state.hire("jules")
 scene.state.assign("morgan","stocking");scene.state.assign("jules","checkout")
 scene.restore_view();scene.refresh();scene.state.open();scene.set_process(true)
 scene.selected_product="curb";scene.request_action("stock")
 for n in range(1500):
  await process_frame
  if n in [450,850,1150]:
   scene.floor_walk=true;scene.floor_target=Vector2(410,550) if n!=850 else Vector2(300,520)
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_jpg(output+"/%05d.jpg"%n,.90)
  if n%30==0:
   var row={"frame":n,"player":[scene.player.position.x,scene.player.position.y],"actors":[],"valid":scene.state.valid()}
   for actor in scene.bodies():row.actors.append({"position":[actor.position.x,actor.position.y],"facing":actor.facing,"reaching":actor.reaching,"phase":actor.phase})
   records.append(row)
 var f=FileAccess.open(output+"/trace.json",FileAccess.WRITE);f.store_string(JSON.stringify(records));f.close()
 scene.queue_free();await process_frame;quit()
