extends "res://scripts/test_encounter.gd"
func run():
 scene=load("res://main.tscn").instantiate();root.add_child(scene);await frames(3)
 scene.perform("receive")
 scene.selected_product="curb";scene.price_input.value=21.99;scene.request_action("reprice")
 scene.selected_product="tide";scene.price_input.value=19.99
 await settle()
 check("walking label request keeps original product and price",scene.state.data.items["case-01"].price==2199 and scene.state.data.items["case-02"].price==0)
 scene.request_action("reprice");scene.price_input.value=99.99;await settle()
 check("later field edits do not change pending label offer",scene.state.data.items["case-02"].price==1999)
 check("pending label requests preserve inventory validity",scene.state.valid())
 var out=FileAccess.open("res://evidence/price-request.json",FileAccess.WRITE);out.store_string(JSON.stringify(results,"  "));out.close()
 quit(0 if results.all(func(r):return r.pass) else 1)
