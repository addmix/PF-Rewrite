extends Node

var manifest := {
	
}

func scan_maps() -> void:
	var dir := Directory.new()
# warning-ignore:return_value_discarded
	dir.open("res://maps/")
	
# warning-ignore:return_value_discarded
	dir.list_dir_begin(false, true)
	var value := dir.get_next()
	
	var folders := []
	
	#find folders
	while value != "":
		if dir.current_is_dir():
			folders.append(value)
		
		value = dir.get_next()
	
	for d in folders:
		#open to map folder
# warning-ignore:return_value_discarded
		dir.open("res://maps/" + d)
		
		if dir.file_exists("map.dat"):
			#load config file
			var config := ConfigFile.new()
			var err := config.load("res://maps/" + d + "/map.dat")
			
			#error
			if err != OK:
				push_error("Could not load " + "res://maps/" + d + "/map.dat Error " + str(err))
			#ok
			else:
				var dict := {}
				for section in config.get_sections():
					var keys := {}
					for key in config.get_section_keys(section):
						#add key/value to dictionary
						keys[key] = config.get_value(section, key)
					#add section to dictionary
					dict[section] = keys
				
				#include mod's install location with other map info
				dict["info"]["path"] = "res://maps/" + d
				
				#add map dictionary to manifest
				manifest[dict["info"]["name"]] = dict
