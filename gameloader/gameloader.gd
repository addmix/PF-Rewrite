extends Node

var SplashScreen = preload("res://scenes/splash_screen/splash_screen.tscn")

func _ready() -> void:
	#load resources
	ModLoader.load_resources()
	#scan maps folder
	Maps.scan_maps()
	#scan gamemodes
	Gamemodes.scan_gamemodes()
	#scan weapons
	Weapons.scan_weapons()
	#particle compilation lag fix
	ParticleLoader.load_particles()
	
	#loading commands
	var args : Array = OS.get_cmdline_args()
	cmdline_args(args)
	
	#load splash screen
	$"/root".call_deferred("add_child", SplashScreen.instance())
	call_deferred("queue_free")

# warning-ignore:unused_argument
func cmdline_args(args : Array) -> void:
	
	pass
