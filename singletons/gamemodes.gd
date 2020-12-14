extends Node

var manifest := {
	
}

var base_dir := "res://gamemodes/"

func scan_gamemodes() -> void:
	#create directory to navigate through files
	var dir := Directory.new()
	#start in gamemodes folder
# warning-ignore:return_value_discarded
	dir.open(base_dir)
	
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
	
	#prevents default folder from being searched
	folders.erase("boilerplates")
	
	#go through each folder
	for d in folders:
		#open to gamemode's folder
# warning-ignore:return_value_discarded
		dir.open(base_dir + d)
		
		#if gamemode data file exists
		if dir.file_exists("gamemode.dat"):
			#load config file
			var config := ConfigFile.new()
			#load config
			var err := config.load(base_dir + "/" + d + "/gamemode.dat")
			
			#check for error
			if err != OK:
				push_error("Could not load " + base_dir + "/" + d + "/gamemode.dat Error " + str(err))
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
				dict["info"]["path"] = base_dir + "/" + d
				
				#add map dictionary to manifest
				manifest[dict["info"]["name"]] = dict
#	print(manifest)

func load_gamemode_script(mode : String) -> Resource:
	var script = load(manifest[mode]["info"]["path"] + "/" + manifest[mode]["info"]["script"])
	return script
