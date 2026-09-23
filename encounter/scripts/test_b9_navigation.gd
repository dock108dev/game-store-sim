extends "res://scripts/test_week_scene.gd"
func run():
 Engine.time_scale=1
 root.size=Vector2i(1280,720)
 scene=load("res://main.tscn").instantiate();root.add_child(scene);await frames(5)
 await enter_week()
 var fixture="/Users/michaelfuscoletti/Desktop/game-sim/encounter/evidence/b9-20260923/navigation-fixture.json"
 check("synthetic B8 checkpoint loads",scene.state.load_from(fixture))
 scene.restore_view();scene.refresh()
 # Explicit synthetic reproduction only: retained B8 player's unsaved physical position.
 scene.player.position=Vector2(485.3638,517.75275)
 await click_at(Vector2(410,550))
 var start=scene.player.position;var before=scene.state.data.duplicate(true)
 await view("b9-navigation-start")
 var t=Time.get_ticks_msec()
 while Time.get_ticks_msec()-t<10000:await process_frame
 await view("b9-navigation-after10s")
 var automatic=scene.player.position.distance_to(Vector2(410,550))<1
 var observation={"setup":"Retained synthetic B8 day7 business state plus explicit retained player-position fixture; 1x; no helper detours","automatic_completed":automatic,"after10s":[scene.player.position.x,scene.player.position.y],"start":[start.x,start.y],"state_valid":scene.state.valid(),"audio_driver":AudioServer.get_driver_name(),"output_device":AudioServer.output_device,"devices":AudioServer.get_output_device_list(),"user_dir":OS.get_user_data_dir()}
 if not automatic:
  await key(KEY_S);await key(KEY_S);await click_at(Vector2(410,550))
  t=Time.get_ticks_msec()
  while Time.get_ticks_msec()-t<10000:await process_frame
  observation["explicit_two_S_reclick_completed"]=scene.player.position.distance_to(Vector2(410,550))<1
  await view("b9-navigation-after-WASD")
 observation["final_valid"]=scene.state.valid()
 observation["no_automatic_transaction"]=scene.state.data.cash==before.cash and scene.state.data.sales==before.sales
 var f=FileAccess.open("res://evidence/b9-navigation.json",FileAccess.WRITE);f.store_string(JSON.stringify(observation,"  "));f.close()
 quit(0 if automatic and observation.final_valid and observation.no_automatic_transaction else 1)
