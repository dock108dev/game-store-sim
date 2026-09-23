extends SceneTree
const State=preload("res://state.gd")
const Main=preload("res://main.gd")
var checks=0
func check(label: String,ok: bool):
 checks+=1
 if not ok:push_error(label);quit(1)
func _initialize():
 var s=State.new();var path="user://ssot.json"
 check("fresh state uses persistence identity",s.data.version==State.SCHEMA_VERSION and s.data.ruleset_id==State.RULESET_ID)
 check("save authoritative state",s.save_to(path))
 var scene=Main.new();scene.save_path=path
 check("menu accepts loader-valid state",scene.checkpoint_info().ok)
 for key in ["version","ruleset_id","phase"]:
  var invalid=s.data.duplicate(true);invalid[key]=0 if key=="version" else "unsupported"
  var f=FileAccess.open(path,FileAccess.WRITE);f.store_string(JSON.stringify(invalid));f.close()
  var probe=State.new()
  check("loader and menu reject "+key,not probe.load_from(path) and not scene.checkpoint_info().ok)
  if key!="phase":check("compatibility rejection classified "+key,probe.last_storage_error.stage=="incompatible")
 scene.free()
 var options=Main.development_options(PackedStringArray(["--pricing-demo=reference"]),false)
 check("retired pricing mode fails explicitly",options.error!="" and not options.has("pricing"))
 check("retired launcher absent",not FileAccess.file_exists("res://Compare Pricing.command"))
 check("catalog alias points to week content",State.CATALOG==State.Week.CATALOG and State.PRODUCTS==State.Week.PRODUCTS)
 print("SSOT_CHECKS ",checks);quit(0)
