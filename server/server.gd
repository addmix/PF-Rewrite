#global node
extends Node


signal server_closed
signal connection_successful
signal connection_failed
signal peer_connected
signal peer_disconnected

signal recieved_game_settings

#server variables
export var ip := "127.0.0.1"
export var port := 1909
export var playerlimit := 32
export var in_bandwidth := 0
export var out_bandwidth := 0
export var client_port := 1909

#game settings
var game_settings : Dictionary

var PauseMenu : Control
var Scoreboard : PopupDialog 

var MapInstance : Spatial
var GamemodeInstance : Node

var network := NetworkedMultiplayerENet.new()

func _ready() -> void:
	_connect_signals()

func _connect_signals() -> void:
	var err := []
	err.append(network.connect("connection_succeeded", self, "connection_succeeded"))
	err.append(network.connect("connection_failed", self, "connection_failed"))
	err.append(network.connect("peer_connected", self, "peer_connected"))
	err.append(network.connect("peer_disconnected", self, "peer_disconnected"))
	err.append(network.connect("server_disconnected", self, "close_server"))
	#check error

#only on client
func connection_succeeded() -> void:
	emit_signal("connection_successful")

#only on client
func connection_failed() -> void:
	emit_signal("connection_failed")
	get_tree().set_network_peer(null)

func peer_connected(id : int) -> void:
	emit_signal("peer_connected", id)
	#only on server
	if get_tree().is_network_server():
		#send game data to new player
		rpc_id(id, "return_game_settings", game_settings)

func peer_disconnected(id : int) -> void:
	emit_signal("peer_disconnected", id)

#start host player
func start_host() -> void:
	
	
	
	
	
	
	
	
	
	
	
	network.allow_object_decoding = true
	
	
	
	
	
	
	
	
	
	
	
	
	#create server
# warning-ignore:return_value_discarded
	network.create_server(port, playerlimit, in_bandwidth, out_bandwidth)
	get_tree().set_network_peer(network)
	
	#prevent players from joining while server is still loading
	network.refuse_new_connections = true
	
	#loads map and gamemode, and removes menu
	load_game()
	
	#loading stuff is done, allow players to join
	network.refuse_new_connections = !game_settings["multiplayer"]
	Players.add_player(1, Players.local_player)

#start client player, connects to host player
func start_client() -> void:
	
	
	
	
	
	
	
	
	
	
	network.allow_object_decoding = true
	
	
	
	
	
	
	
	
	
	
	
	#connect to server
# warning-ignore:return_value_discarded
	network.create_client(ip, port, in_bandwidth, out_bandwidth)
	get_tree().set_network_peer(network)

# warning-ignore:unused_argument
remote func kick(reason : String) -> void:
	#display kick info here
	print("Kicked for: ", reason)
	close_server()

remote func return_game_settings(data : Dictionary) -> void:
	game_settings = data
	emit_signal("recieved_game_settings")
	#makes sure we are getting data from the server
	#loads map and gamemode, and removes menu
	load_game()

#loads map and gamemode
func load_game() -> void:
	#player stuff
	
	
	#game related stuff
	#load map
	var resource : Resource = Maps.load_map(game_settings["map"])
	MapInstance = resource.instance()
	$"/root".add_child(MapInstance, true)
	
	#load scoreboard
	resource = load("res://assets/ui/scoreboard.tscn")
	Scoreboard = resource.instance()
	$"/root".add_child(Scoreboard)
	
	#load map's gamemode nodes
	resource = Maps.load_mode(game_settings["map"], game_settings["mode"])
	GamemodeInstance = resource.instance()
	MapInstance.add_child(GamemodeInstance)
	
	#load gamemode script
	resource = Gamemodes.load_gamemode_script(game_settings["mode"])
	GamemodeInstance.set_script(resource)
	
# warning-ignore:return_value_discarded
	GamemodeInstance.connect("teams_created", self, "on_teams_created")
	#initialize gamemode
	GamemodeInstance.init()
	
	
	#menus
	#load pause menu
	resource = load("res://scenes/ingame/pausemenu/pausemenu.tscn")
	PauseMenu = resource.instance()
	$"/root".add_child(PauseMenu)
	
	#remove menu
	var menu = $"/root/Menu"
	if menu != null:
		menu.queue_free()

func close_server() -> void:
	#server
	if !get_tree().is_network_server():
		print("server closed")
		#server closed scene here
		pass
	
	emit_signal("server_closed")
	
	#null out variables
	GamemodeInstance.queue_free()
	MapInstance.queue_free()
	Scoreboard.queue_free()
	PauseMenu.queue_free()
	
	#close server
	network.call_deferred("close_connection")
	
	#load menu
	var resource := load("res://scenes/menu/menu.tscn")
	$"/root".add_child(resource.instance())

func _exit_tree() -> void:
	if get_tree().network_peer == network:
		network.close_connection()
	
	if PauseMenu:
		PauseMenu.queue_free()
	if Scoreboard:
		Scoreboard.queue_free()
	if MapInstance:
		MapInstance.queue_free()
	if GamemodeInstance:
		GamemodeInstance.queue_free()
	

#menu connection server starting funcs
# warning-ignore:shadowed_variable
func set_server(address : String, port : int) -> void:
	ip = address
	self.port = port

#gamemode funcs
#changes all game data
func change_game(data : Dictionary) -> void:
	change_map(data["map"])
	change_mode(data["mode"])

#changes map
func change_map(map : String) -> void:
	game_settings["map"] = map

#changes gamemode
func change_mode(mode : String) -> void:
	game_settings["mode"] = mode

#loads map
func load_map() -> void:
	var resource : Resource = Maps.load_map(game_settings["map"])
	var scene : Spatial = resource.instance()
	MapInstance = scene
	$"/root".add_child(scene, true)

#unloads map
func unload_map() -> void:
	MapInstance.queue_free()

#loads gamemode
func load_mode() -> void:
	pass

#unloads gamemode
func unload_mode() -> void:
	GamemodeInstance.queue_free()

func on_teams_created() -> void:
	Scoreboard.update_scoreboard()
