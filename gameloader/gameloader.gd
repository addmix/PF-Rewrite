extends Node

var SplashScreen = preload("res://scenes/splash_screen/splash_screen.tscn")

func _ready():
	#load resources
	ModLoader.load_resources()
	#scan maps folder
	Maps.scan_maps()
	#scan gamemodes
	Gamemodes.scan_gamemodes()
	#scan weapons
	Weapons.scan_weapons()
	
	
	#load splash screen
	$"/root".call_deferred("add_child", SplashScreen.instance())
	call_deferred("queue_free")
