extends Button

var default_icon : String = "res://icon.png"
export var gamemode_name : String
var gamemode : Dictionary

signal _pressed

func _ready() -> void:
	# warning-ignore:return_value_discarded
	connect("pressed", self, "on_button_pressed")
	call_deferred("load_resources")

func on_button_pressed() -> void:
	emit_signal("_pressed", gamemode)

func set_gamemode(new_gamemode : Dictionary) -> void:
	gamemode = new_gamemode

func load_resources() -> void:
	#get level name
	gamemode_name = gamemode["info"]["name"]
	#load level text
	$Margin/VBox/Label.text = gamemode["info"]["name"]
	
	var path : String
	if gamemode["info"].has("icon"):
		path = gamemode["info"]["icon"]
	else:
		path = default_icon
	
	$Margin/VBox/Icon.texture = load(path)
