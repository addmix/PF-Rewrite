extends Node

var weapons := {}
var manifest := {}
var models := {}

var base_dir := "res://assets/weapons/"

func scan_weapons() -> void:
	#create directory to navigate through files
	var dir := Directory.new()
	#start in gamemodes folder
	# warning-ignore:return_value_discarded
	dir.open(base_dir)
	
	# warning-ignore:return_value_discarded
	#start listing directories
	dir.list_dir_begin(true, true)
	#get first object in directory
	var value := dir.get_next()
	
	#create list of folders
	var categories := []
	
	#find folders
	while value != "":
		#if is a folder
		if dir.current_is_dir():
			#append to folder array
			categories.append(value)
		
		#get next value
		value = dir.get_next()
	
	#go through each folder
	for d in categories:
		#open to gamemode's folder
		var category := Directory.new()
# warning-ignore:return_value_discarded
		category.open(base_dir + d)
		
# warning-ignore:return_value_discarded
		category.list_dir_begin(true, true)
		var weapon := category.get_next()
		
		#loop through each weapon's folder
		while weapon != "":
			
			#navigate into folder
			var weapon_folder := Directory.new()
# warning-ignore:return_value_discarded
			weapon_folder.open(base_dir + d + "/" + weapon)
			
			#check for weapon.dat file
			if weapon_folder.file_exists("weapon.dat"):
				#load config file
				var config := ConfigFile.new()
				#load config
				var err := config.load(base_dir + d + "/" + weapon + "/weapon.dat")
				
				#check for error
				if err != OK:
					push_error("Could not load " + base_dir + d + "/" + weapon + "/weapon.dat Error " + str(err))
				
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
					dict["info"]["path"] = base_dir + d + "/" + weapon
					
					#add map dictionary to manifest
					manifest[dict["info"]["name"]] = dict
			weapon = category.get_next()
	
	#loop through all weapons
	for weapon in manifest:
		#if no category
		if !weapons.has(manifest[weapon]["info"]["category"]):
			#create category
			weapons[manifest[weapon]["info"]["category"]] = {}
		
		weapons[manifest[weapon]["info"]["category"]][weapon] = manifest[weapon]
	
	#load all models for weapons
	for weapon in manifest:
		models[weapon] = load(manifest[weapon]["info"]["path"] + "/" + manifest[weapon]["info"]["scene"])
