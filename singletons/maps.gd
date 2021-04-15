extends Node

var manifest := {
	
}

func scan_maps() -> void:
	var dir := Directory.new()
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
		if dir.current_is_dir():
			folders.append(value)
		value = dir.get_next()
	
	#loop through each map's folder
	for d in folders:
		# warning-ignore:return_value_discarded
		dir.open("res://maps/" + d)
		
		#if map data file exists
		if dir.file_exists("map.dat"):
			#load config file
			var config := ConfigFile.new()
			var err := config.load("res://maps/" + d + "/map.dat")
			
			#check for error
			if err != OK:
				print("Could not load " + "res://maps/" + d + "/map.dat Error " + str(err))
			#no error
			else:
				var dict : Dictionary = dictionary_from_config(config)
				
				#include mod's install location with other map info
				dict["info"]["path"] = "res://maps/" + d
				
				#add map dictionary to manifest
				manifest[dict["info"]["name"]] = dict
				
				#add map to gamemode manifest
				for gamemode in Gamemodes.manifest.keys():
					if dir.file_exists(Gamemodes.manifest[gamemode]["info"]["scene_name"] + ".tscn"):
						#add map to gamemode's options
						Gamemodes.manifest[gamemode]["options"]["maps"]["options"].append(dict["info"]["name"])
#	print(manifest)

func dictionary_from_config(config : ConfigFile) -> Dictionary:
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
	
	return dict

func load_map(map : String) -> Resource:
	var scene = load(manifest[map]["info"]["path"] + "/" + manifest[map]["info"]["scene"])
	return scene

func load_mode(map : String, mode : String) -> Resource:
	var scene = load(manifest[map]["info"]["path"] + "/" + manifest[map]["gamemodes"][mode])
	return scene
