extends Node

onready var skip_intro : bool = ProjectSettings.get_setting("application/boot_splash/skip_intro")
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
	
	if args.has("--map"):
		var index := args.find("--map")
		
		skip_intro = true
		#if no map
		if index == args.size() - 1:
			return
		
		Server.game_data["map"] = args[index + 1]
		call_deferred("start_server")
	
	#load menu
	var menu = load("res://scenes/menu/menu.tscn").instance()
	$"/root".call_deferred("add_child", menu, true)
	
	#load splash screen
	if !skip_intro:
		$"/root".call_deferred("add_child", SplashScreen.instance())
	call_deferred("queue_free")

func start_server() -> void:
	Server.start_host()
