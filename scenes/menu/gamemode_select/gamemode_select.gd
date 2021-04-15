extends PopupDialog

onready var settings : VBoxContainer = $Margin/HBox/VBox/Scroll/Settings
var default_icon : String = "res://icon.png"

var dir = Directory.new()
var selection : Dictionary = {}

func _ready() -> void:
	call_deferred("load_gamemodes")

func load_gamemodes() -> void:
	var dict : Dictionary = Gamemodes.manifest
	for key in dict.keys():
		var gamemode : Dictionary = dict[key]
		#add button to scene, then self loading happens
		var path : String
		if gamemode["info"].has("icon"):
			path = gamemode["info"]["icon"]
		else:
			path = default_icon
		
		$Margin/HBox/Scroll/Gamemodes.add_item(gamemode["info"]["name"], load(path))

func on_gamemode_pressed(dict : Dictionary) -> void:
	selection = dict
	load_options()

func _on_next_pressed():
	if selection.size() == 0:
		return
	else:
		var settings : Dictionary = get_settings()
		Server.game_settings = settings
		Server.start_host()

func _on_cancel_pressed():
	remove_options()
	selection = {}
	self.hide()

var setting_scene : PackedScene = preload("res://scenes/ui/options_menu/option.tscn")

var OPTION : PackedScene = preload("res://scenes/ui/types/options.tscn")
var FLOAT : PackedScene = preload("res://scenes/ui/types/float.tscn")
var BOOL : PackedScene = preload("res://scenes/ui/types/bool.tscn")
var COLOR : PackedScene = preload("res://scenes/ui/types/color.tscn")
var VECTOR2 : PackedScene = preload("res://scenes/ui/types/vector2.tscn")
var VECTOR3 : PackedScene = preload("res://scenes/ui/types/vector3.tscn")

func remove_options() -> void:
	#remove any options from previous gamemode
	for child in settings.get_children():
		child.queue_free()

func load_options() -> void:
	remove_options()
	var options : Array = selection["options"].keys()
	var maps_dict : Dictionary = selection["options"]["maps"]
	
	#maps
	create_option("Map", maps_dict)
	options.erase("maps")
	#default time
	if !options.has("time"):
		create_option("Play Time", {"name": "play time", "type":2,"min":0, "max":7200, "step":30, "default": 600})
		options.erase("time")
	create_option("Countdown Time", {"name": "countdown time", "type":2, "min":0, "max":120, "step":1, "default": 10})
	create_option("Post-match Cooldown Time", {"name": "cooldown time", "type":2, "min":0, "max":120, "step":1, "default": 10})
	#multipalyer
	create_option("Multiplayer", {"name": "multiplayer","type":1})
	create_option("Teams", {"name": "teams", "type":2, "min":1, "max":16, "step":1, "default":2})
	
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
	
	setting_instance.setting = option["name"]
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


func get_settings() -> Dictionary:
	var dict : Dictionary = {}
	
	dict["mode"] = selection["info"]["name"]
	for child in settings.get_children():
		dict[child.setting] = child.get_value()
	
	return dict

func _on_Gamemodes_item_selected(index: int) -> void:
	selection = Gamemodes.manifest[$Margin/HBox/Scroll/Gamemodes.get_item_text(index)]
	load_options()
