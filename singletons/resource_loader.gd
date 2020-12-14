extends Node

#for game patches
func load_patches():
	pass

#for mods
func load_resources():
#	print("loading resources")
	#initialize directory for loading
	var dir := Directory.new()
# warning-ignore:return_value_discarded
	dir.open(OS.get_executable_path().get_base_dir())
	
	#check for resource folder
	if !dir.file_exists("resources"):
# warning-ignore:return_value_discarded
		dir.make_dir("resources")
	
# warning-ignore:return_value_discarded
	dir.list_dir_begin(true, true)
	var value := dir.get_next()
	
	#while files left
	while value != "":
		#if resource pack file
		if value.ends_with(".pck"):
			#load resource pack
			print("Loaded resource " + value)
# warning-ignore:return_value_discarded
			ProjectSettings.load_resource_pack(OS.get_executable_path().get_base_dir() + "/resources/" + value)
		
		value = dir.get_next()

