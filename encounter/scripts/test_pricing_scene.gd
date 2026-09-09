extends "res://scripts/test_encounter.gd"
func run():
 root.size=Vector2i(2560,1440) if "--retina" in OS.get_cmdline_user_args() else Vector2i(1280,720)
 scene=load("res://main.tscn").instantiate();root.add_child(scene);scene.save_path="user://pricing-scene-test.json";await frames(5)
 for cents in [1699,2199,2699]:
  scene.perform("reset")
  await click_at(Vector2(310,430));await settle()
  scene.price_input.value=0
  check("input clamps below minimum",scene.price_input.value==1)
  scene.price_input.value=100
  check("input clamps above maximum",is_equal_approx(scene.price_input.value,99.99))
  scene.price_input.value=float(cents)/100
  await view("price-guidance-"+str(cents))
  await click_at(Vector2(1080,423));await settle()
  await key(KEY_E);await settle()
  check("prep repricing control visible",scene.reprice_button.visible and scene.details.get_rect().end.y<scene.reprice_button.position.y)
  await click_at(Vector2(1080,423));await settle()
  await key(KEY_K);await key(KEY_L)
  check("reload before browsing decision",scene.state.data.decisions.is_empty())
  for i in range(1600):
   await process_frame
   if scene.customer_stage=="queued" or scene.state.report().missed==1:break
  var buy=cents<=scene.state.willingness(1)
  check("actual browse outcome "+str(cents),scene.customer_stage=="queued" if buy else scene.customer_stage=="leaving")
  await view("price-outcome-"+str(cents))
  var before=scene.state.data.duplicate(true)
  await key(KEY_K);await key(KEY_L)
  check("outcome reload no reroll",scene.state.data==before and scene.state.data.decisions.size()==1)
  if buy:
   await click_at(Vector2(1080,423));await settle()
  else:
   check("readable refusal without carried stock",scene.guide.text.begins_with("Price declined") and scene.state.count_at("shelf")==2 and not scene.carried_case.visible)
  await click_at(Vector2(1080,475));await settle()
  await view("price-report-"+str(cents))
  check("report layout and price misses",scene.details.get_rect().end.y<scene.primary.position.y and scene.state.report().missed==int(not buy))
 # Change the rejected stock's price the next day, via the ordinary prep control.
 await click_at(Vector2(1080,423));await frames(3)
 var dialog=scene.ui.get_children().filter(func(c):return c is ConfirmationDialog).back()
 dialog.confirmed.emit();await frames(3)
 scene.price_input.value=16.99
 await click_at(Vector2(1080,326));await settle()
 check("next decision reprices refused shelf copy",scene.state.data.items["case-01"].price==1699 and scene.state.report().missed==0)
 await view("next-day-reprice")
 await click_at(Vector2(1080,423));await settle()
 for i in range(1600):
  await process_frame
  if scene.customer_stage=="queued":break
 check("repriced copy now bought",scene.customer_stage=="queued" and scene.state.data.customers.visitor.offer==1699)
 await click_at(Vector2(1080,423));await settle()
 await click_at(Vector2(1080,475));await settle()
 await view("repriced-report")
 check("next report correct",scene.state.report().sold==1 and scene.state.report().missed==0 and scene.state.report().revenue==1699 and scene.state.report().margin==899 and scene.state.valid())
 var out=FileAccess.open("res://evidence/pricing-scene-checks.json",FileAccess.WRITE);out.store_string(JSON.stringify(results,"  "));out.close()
 quit(0 if results.all(func(r):return r.pass) else 1)
