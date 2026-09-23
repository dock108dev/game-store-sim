extends SceneTree
const State=preload("res://state.gd")
const Main=preload("res://main.gd")
var checks=0
func check(label: String,ok: bool):
 checks+=1
 if not ok:push_error(label);quit(1)
func _initialize():
 var state=State.new();var original=state.data.duplicate(true)
 var path="user://oversized.json"
 var f=FileAccess.open(path,FileAccess.WRITE);f.store_buffer(" ".repeat(State.MAX_CHECKPOINT_BYTES+1).to_utf8_buffer());f.close()
 check("oversized load rejected",not state.load_from(path) and state.last_storage_error.stage=="size_limit" and state.data==original)
 check("oversized original not overwritten",not state.save_to(path) and FileAccess.get_file_as_bytes(path).size()==State.MAX_CHECKPOINT_BYTES+1)
 var probe=Main.new();probe.save_path=path
 check("menu probe uses bounded reader",not probe.checkpoint_info().ok and "oversized" in probe.checkpoint_info().text);probe.free()
 state.data.erase("phase")
 f=FileAccess.open("user://missing-phase.json",FileAccess.WRITE);f.store_string(JSON.stringify(state.data));f.close()
 state.data=original.duplicate(true)
 check("missing phase fails without runtime error",not state.load_from("user://missing-phase.json") and state.data==original)
 state.data.run_id="../escape"
 check("run id path traversal rejected",not state.valid())
 state.data=original.duplicate(true)
 var args=PackedStringArray(["--assortment-demo=stocked","--pricing-demo=low","--capture"])
 var personal=Main.development_options(args,true)
 check("personal feature disables fixture switches",personal=={"assortment":"","capture":false,"error":""})
 var dev=Main.development_options(PackedStringArray(["--assortment-demo=stocked","--capture"]),false)
 check("supported development modes retained",dev.assortment=="stocked" and dev.capture and dev.error=="")
 dev=Main.development_options(PackedStringArray(["--assortment-demo=../outside"]),false)
 check("unrecognized and traversal arguments ignored",dev=={"assortment":"","capture":false,"error":""})
 check("ordinary save and reload retained",state.save_to("user://security-roundtrip.json") and state.load_from("user://security-roundtrip.json") and state.data==original)
 print("SECURITY_CHECKS ",checks);quit(0)
