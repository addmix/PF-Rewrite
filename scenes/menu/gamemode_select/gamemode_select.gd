extends PopupDialog

onready var settings : VBoxContainer = $Margin/HBox/VBox/Scroll/Settings
var default_icon : String = "res://icon.png"
var gamemode_instance = preload("res://scenes/menu/gamemode_select/gamemode.tscn")

var dir = Directory.new()
var selection : Dictionary = {}

func _ready() -> void:
	call_deferred("load_gamemodes")

func load_gamemodes() -> void:
	var dict : Dictionary = Gamemodes.manifest
	for key in dict.keys():
		var gamemode : Dictionary = dict[key]
		#instance button
		var instance = gamemode_instance.instance()
		#set name of button
		instance.name = gamemode["info"]["name"]
		#give the level instance the path so it can load itself
		instance.set_gamemode(gamemode)
		#connect button selection event
		instance.connect("_pressed", self, "on_gamemode_pressed")
		
		#add button to scene, then self loading happens
		$Margin/HBox/Scroll/Gamemodes.add_child(instance)

func on_gamemode_pressed(dict : Dictionary) -> void:
	selection = dict
	load_options()

func _on_next_pressed():
	if selection.size() == 0:
		return
	else:
		#load proper levels
		var map_select = get_parent().get_node("MapSelect")
		map_select.gamemode = selection
		
		map_select.popup_centered()
		map_select.load_maps()
	

func _on_cancel_pressed():
	selection = {}
	self.hide()

var setting_scene : PackedScene = preload("res://scenes/ui/options_menu/option.tscn")

var OPTION : PackedScene = preload("res://scenes/ui/types/options.tscn")
var FLOAT : PackedScene = preload("res://scenes/ui/types/float.tscn")
var BOOL : PackedScene = preload("res://scenes/ui/types/bool.tscn")
var COLOR : PackedScene = preload("res://scenes/ui/types/color.tscn")
var VECTOR2 : PackedScene = preload("res://scenes/ui/types/vector2.tscn")
var VECTOR3 : PackedScene = preload("res://scenes/ui/types/vector3.tscn")

func load_options() -> void:
	#remove any options from previous gamemode
	for child in settings.get_children():
		child.queue_free()
	
	var options : Array = selection["options"].keys()
	var maps_dict : Dictionary = selection["options"]["maps"]
	
	#maps
	create_option("Map", maps_dict)
	options.erase("maps")
	#default time
	if !options.has("time"):
		create_option("Time (seconds)", {"type":2,"min":0, "max":7200, "step":30, "default": 600})
		options.erase("time")
	#multipalyer
	create_option("Multiplayer", {"type":1})
	
	
	#gamemode specific options
	for option in options:
		create_option(option, selection["options"][option])

func create_option(text : String, option : Dictionary) -> void:
	var setting_instance : HBoxContainer = setting_scene.instance()
	setting_instance.setting = text
	setting_instance.name = text.capitalize()
	
	var decision : PackedScene
	match option["type"]:
		TYPE_BOOL:
			decision = BOOL
		TYPE_INT:
			decision = FLOAT
		TYPE_REAL:
			decision = FLOAT
		TYPE_VECTOR2:
			decision = VECTOR2
		TYPE_VECTOR3:
			decision = VECTOR3
		TYPE_COLOR:
			decision = COLOR
		"OPTION":
			decision = OPTION
		_:
			return
	
	var type_instance = decision.instance()
	
	setting_instance.type = type_instance
	setting_instance.add_child(type_instance)
	settings.add_child(setting_instance)
	setting_instance.set_text(text.capitalize())
	
	if option.has("min"):
		type_instance.set_min(option["min"])
	if option.has("max"):
		type_instance.set_max(option["max"])
	if option.has("step"):
		type_instance.set_step(option["step"])
	if option.has("options"):
		type_instance.set_options(option["options"])
	if option.has("default"):
		setting_instance.call_deferred("set_value", option["default"])
	
	
