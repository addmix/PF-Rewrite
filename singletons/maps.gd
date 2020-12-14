extends Node

var manifest := {
	
}

func scan_maps() -> void:
	#create directory to navigate through files
	var dir := Directory.new()
	#start in gamemodes folder
# warning-ignore:return_value_discarded
	dir.open("res://maps/")
	
# warning-ignore:return_value_discarded
	#start listing directories
	dir.list_dir_begin(false, true)
	#get first object in directory
	var value := dir.get_next()
	
	#create list of folders
	var folders := []
	
	#find folders
	while value != "":
		#if is a folder
		if dir.current_is_dir():
			#append to folder array
			folders.append(value)
		
		#get next value
		value = dir.get_next()
	
	#go through each folder
	for d in folders:
		#open to map's folder
# warning-ignore:return_value_discarded
		dir.open("res://maps/" + d)
		
		#if map data file exists
		if dir.file_exists("map.dat"):
			#load config file
			var config := ConfigFile.new()
			#load config
			var err := config.load("res://maps/" + d + "/map.dat")
			
			#check for error
			if err != OK:
				push_error("Could not load " + "res://maps/" + d + "/map.dat Error " + str(err))
			#no error
			else:
				#store config to dictionary
				var dict := {}
				#go through each section
				for section in config.get_sections():
					#create a dictionary for that section
					var keys := {}
					#for every key in that section
					for key in config.get_section_keys(section):
						#add key/value to dictionary
						keys[key] = config.get_value(section, key)
					#add section to dictionary
					dict[section] = keys
				
				#include mod's install location with other map info
				dict["info"]["path"] = "res://maps/" + d
				
				#add map dictionary to manifest
				manifest[dict["info"]["name"]] = dict
#	print(manifest)

func load_map(map : String) -> Resource:
	var scene = load(manifest[map]["info"]["path"] + "/" + manifest[map]["info"]["scene"])
	return scene

func load_mode(map : String, mode : String) -> Resource:
	var scene = load(manifest[map]["info"]["path"] + "/" + manifest[map]["gamemodes"][mode])
	return scene
