extends Node

var weapons := {}
var manifest := {}
var models := {}

var base_dir := "res://assets/weapons"

func scan_weapons() -> void:
	scan_weapons_recursive(base_dir)
	load_categories()
	load_models()

func scan_weapons_recursive(start : String) -> void:
	var dir := Directory.new()
	# warning-ignore:return_value_discarded
	dir.open(start)
	
	#if current folder has a weapon
	if dir.file_exists("weapon.dat"):
		load_weapon(start + "/" + "weapon.dat")
		return
	
	#no weapon in this folder, search subsequent folders
	# warning-ignore:return_value_discarded
	dir.list_dir_begin(true, true)
	var value := dir.get_next()
	
	while value != "":
		if dir.current_is_dir():
			scan_weapons_recursive(start + "/" + value)
		value = dir.get_next()

func load_weapon(path : String) -> void:
	#load config file
	var config := ConfigFile.new()
	#load config
	var err := config.load(path)
	
	#check for error
	if err != OK:
		push_error("Could not load weapon at: " + path + ". Error " + str(err))
	else:
		var dict := {}
		for section in config.get_sections():
			
			var keys := {}
			for key in config.get_section_keys(section):
				keys[key] = config.get_value(section, key)
			dict[section] = keys
		
		#include mod's install location with other map info
		dict["info"]["path"] = path.substr(0, path.length() - 11)
		#add weapon dictionary to manifest
		manifest[dict["info"]["name"]] = dict

func load_categories() -> void:
	#loop through all weapons
	for weapon in manifest:
		#if no category
		if !weapons.has(manifest[weapon]["info"]["category"]):
			#create category
			weapons[manifest[weapon]["info"]["category"]] = {}
		
		weapons[manifest[weapon]["info"]["category"]][weapon] = manifest[weapon]

func load_models() -> void:
	#load all models for weapons
	for weapon in manifest:
		models[weapon] = load(manifest[weapon]["info"]["path"] + "/" + manifest[weapon]["info"]["scene"])
