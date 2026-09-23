extends SceneTree
func _initialize():call_deferred("run")
func run():
 root.size=Vector2i(1280,720)
 RenderingServer.set_default_clear_color(Color("e8e2d5"))
 var world=Node2D.new();root.add_child(world)
 var names=["Devon · glasses","Ellis · knit cap","Frankie · headphones"]
 for col in range(3):
  var label=Label.new();label.text=names[col];label.position=Vector2(120+col*400,20);label.add_theme_color_override("font_color",Color("293442"));label.add_theme_font_size_override("font_size",24);world.add_child(label)
  for row in range(3):
   var actor=load("res://actor.gd").new();actor.appearance=col+3;actor.position=Vector2(230+col*400,235+row*220);actor.scale=Vector2.ONE*1.7;world.add_child(actor)
   actor.pose([Vector2.ZERO,Vector2.RIGHT,Vector2.UP][row],0)
 for n in range(5):await process_frame
 await RenderingServer.frame_post_draw
 RenderingServer.force_draw();root.get_texture().get_image().save_png("res://evidence/b6-appearances-probe.png")
 quit()
