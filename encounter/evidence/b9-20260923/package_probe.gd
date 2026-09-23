extends SceneTree
func _initialize():
 print("B9_PROBE ",JSON.stringify({"user_dir":OS.get_user_data_dir(),"driver":AudioServer.get_driver_name(),"devices":AudioServer.get_output_device_list(),"device":AudioServer.output_device,"mix_rate":AudioServer.get_mix_rate(),"personal_beta":OS.has_feature("personal_beta"),"release":OS.has_feature("release"),"main":ResourceLoader.exists("res://main.tscn")}))
 quit()
