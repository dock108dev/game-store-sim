extends SceneTree
const State=preload("res://state.gd")
var checks=0
func check(label: String, ok: bool):
 checks+=1
 if not ok:push_error(label);quit(1)
func _initialize():
 var state=State.new()
 var path="user://storage-check.json"
 check("initial save",state.save_to(path))
 var original=FileAccess.get_file_as_string(path)
 state.receive()
 var live=state.data.duplicate(true)
 check("open failure classified",not state.save_to("user://missing/check.json") and state.last_storage_error.stage=="open_temporary" and state.data==live)
 check("previous checkpoint unchanged",FileAccess.get_file_as_string(path)==original)
 DirAccess.make_dir_absolute("user://blocked.json")
 check("rename failure classified",not state.save_to("user://blocked.json") and state.last_storage_error.stage=="replace" and state.data==live)
 var f=FileAccess.open("user://malformed.json",FileAccess.WRITE);f.store_string("{private-payload");f.close()
 check("malformed rejected without live mutation",not state.load_from("user://malformed.json") and state.last_storage_error.stage=="parse" and state.data==live)
 check("malformed original protected",not state.save_to("user://malformed.json") and state.last_storage_error.stage=="existing_checkpoint_rejected" and FileAccess.get_file_as_string("user://malformed.json")=="{private-payload")
 state.checkpoint_path=""
 check("missing target has accurate pending status",not state.checkpoint("probe") and state.save_pending and not state.last_save_ok and state.last_storage_error.stage=="missing_path")
 state.checkpoint_path=path
 check("retry saves without changing business state",state.retry_save() and not state.save_pending and state.last_storage_error.is_empty() and state.data==live)
 var restored=State.new()
 check("recovery reloads",restored.load_from(path) and restored.data==live)
 print("STORAGE_CHECKS ",checks)
 quit(0)
