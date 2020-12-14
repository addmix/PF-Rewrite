extends Button

export var level_name : String
export var filePath : String
var level := ConfigFile.new()

signal LevelPressed

func _ready() -> void:
	# warning-ignore:return_value_discarded
	connect("pressed", self, "onButtonPressed")
	call_deferred("loadResources")

func onButtonPressed() -> void:
	emit_signal("LevelPressed", self)

func setFilePath(path : String) -> void:
	filePath = path

func loadResources() -> void:
	#initialize config file and open level.dat file
	var err : int = level.load(filePath + "/map.dat")
	
	#push loading error
	if err != OK:
		push_error("Error " + str(err) + " while loading " + filePath + "/map.dat")
		return
	
	#get level name
	level_name = level.get_value("info", "name")
	#load level text
	$MarginContainer/VBoxContainer/Label.text = level.get_value("info", "name")
	#load level image
	$MarginContainer/VBoxContainer/TextureRect.texture = load(filePath + "/" + level.get_value("info", "icon"))
