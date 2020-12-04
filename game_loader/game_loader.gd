extends Node

#cmdline args
# server args
#--server: starts game as a server, if not present, will load client
#--map: specifies which map the server will load, no usage without --server argument. Will load default map from server.properties
#--gamemode: specifies which gamemode the server will load, no usage without --server arguement. Will load default gamemode from server.properties

func _ready() -> void:
	var args := Array(OS.get_cmdline_args())
	
	#decision
	if args.has("--server"):
		load_server()
	else:
		load_client()
	
	
	queue_free()


func load_client() -> void:
	var splash_screen = load("res://game_loader/game/splash_screen/splash_screen.tscn").instance()
	$"/root".call_deferred("add_child", splash_screen, true)

func load_server() -> void:
	var server = load("res://servers/server/server.tscn").instance()
	$"/root".call_deferred("add_child", server, true)
	server.load_server_with_cmdline_args()
