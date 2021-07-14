extends Node

onready var skip_intro : bool = ProjectSettings.get_setting("application/boot_splash/skip_intro")
var SplashScreen = preload("res://scenes/splash_screen/splash_screen.tscn")

# --skip, -s
#skips the intro animation
#
#--map, -m
#preloads a map so you dont have to go through the menus every time
#
#


func _ready() -> void:
	#loading commands
	var args : Array = OS.get_cmdline_args()
	
	#load resources
	ModLoader.load_resources(args)
	#apply settings to relevant nodes
	Settings.load_settings(args)
	#scan gamemodes
	Gamemodes.scan_gamemodes(args)
	#scan maps folder
	Maps.scan_maps(args)
	#scan weapons
	Weapons.scan_weapons(args)
	#particle compilation lag fix
	ParticleLoader.load_particles(args)
	
	#skip intro
	if args.has("--skip") or args.has("-s"):
		skip_intro = true
	
	#load map from command line
	if args.has("--map"):
		var index := args.find("--map")
		
		#if no map
		if index == args.size() - 1:
			return
		
		Server.game_data["map"] = args[index + 1]
		call_deferred("start_server")
	#load map from command line
	if args.has("-m"):
		var index := args.find("-m")
		
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
