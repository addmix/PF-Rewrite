extends Node

func load_resources():
	#initialize directory for loading
	var dir := Directory.new()
	dir.open(OS.get_executable_path().get_base_dir())
	
	#check for resource folder
	if !dir.file_exists("resources"):
		dir.make_dir("resources")
	
	dir.list_dir_begin(true, true)
	var value := dir.get_next()
	
	#while files left
	while value != "":
		#if resource pack file
		if value.ends_with(".pck"):
			#load resource pack
			print("Loaded resource " + value)
			ProjectSettings.load_resource_pack(OS.get_executable_path().get_base_dir() + "/resources/" + value)
		
		value = dir.get_next()

