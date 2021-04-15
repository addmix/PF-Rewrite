extends PopupDialog

var level = preload("res://scenes/menu/Singleplayer/Level.tscn")

var dir = Directory.new()

var selected_map
var selected_mode

func _ready() -> void:
	# warning-ignore:return_value_discarded
	$MarginContainer/VBoxContainer/HBoxContainer/Load.connect("pressed", self, "onLoadPressed")
	# warning-ignore:return_value_discarded
	$MarginContainer/VBoxContainer/HBoxContainer/Cancel.connect("pressed", self, "onCancelPressed")
	call_deferred("load_levels")

#loads levels from map manifest
func load_levels() -> void:
	for key in Maps.manifest.keys():
		#open map folder
		dir.open(Maps.manifest[key]["info"]["path"])
		
		#open level.dat file
		var file = ConfigFile.new()
		var err = file.load(dir.get_current_dir() + "/map.dat")
		
		#check for error
		if err != OK:
			push_error("Error loading " + dir.get_current_dir() + "/map.dat")
			continue
		
		#instance button
		var instance = level.instance()
		#set name of button
		instance.name = file.get_value("info", "name")
		#give the level instance the path so it can load itself
		instance.setFilePath(dir.get_current_dir())
		
		#connect button selection event
		instance.connect("LevelPressed", self, "onLevelPressed")
		
		#add button to scene, then self loading happens
		$MarginContainer/VBoxContainer/ScrollContainer/HBoxContainer.add_child(instance)

#when level is clicked on
func onLevelPressed(node : Node) -> void:
	selected_map = node

#when load button pressed
func onLoadPressed() -> void:
	#if no selected level
	if selected_map == null:# or selected_mode == null:
		return
	
	
	loadSingleplayer()

#when menu closed
func onCancelPressed() -> void:
	#reset values when exiting menu
	selected_map = null
	selected_mode = null
	self.hide()



#loads singleplayer host
func loadSingleplayer() -> void:
	#set map
	Server.change_map(selected_map.level_name)
	#set gamemode
#	Server.change_mode(selected_mode.mode)
	
	Server.start_host()
