extends Node

func _ready():
	var args := Array(OS.get_cmdline_args())


func load_game():
	var splash_screen = load("res://game_loader/game/splash_screen.tscn")
	$"/root".add_child(splash_screen.instance(), true)

func load_server():
	pass
