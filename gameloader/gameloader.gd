extends Node

var SplashScreen = preload("res://scenes/splash_screen/splash_screen.tscn")
var load_menu := true

func _ready() -> void:
#	print(lerp(1.5/1.5, 1.5, ))
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
	
	if args.has("--map"):
		var index := args.find("--map")
		
		load_menu = false
		#if no map
		if index == args.size() - 1:
			return
		
		Server.game_data["map"] == args[index + 1]
		call_deferred("start_server")
	
	#load splash screen
	if load_menu:
		$"/root".call_deferred("add_child", SplashScreen.instance())
	call_deferred("queue_free")

func start_server() -> void:
	Server.start_host()
