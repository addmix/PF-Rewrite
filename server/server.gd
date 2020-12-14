extends Node

export var ip := "127.0.0.1"
export var port := 1909
export var playerlimit := 32
export var in_bandwidth := 0
export var out_bandwidth := 0
export var client_port := 1909

export var game_data := {
	"map": "Desert Storm",
	"mode": "TDM",
}

var MapInstance : Spatial
var GamemodeInstance : Node
var PauseMenu : Control


var network := NetworkedMultiplayerENet.new()

signal recieved_game_data

func _ready() -> void:
	_connect_signals()

func _connect_signals() -> void:
	network.connect("connection_succeeded", self, "connection_succeeded")
	network.connect("connection_failed", self, "connection_failed")
	network.connect("peer_connected", self, "peer_connected")
	network.connect("peer_disconnected", self, "peer_disconnected")

func connection_succeeded(id : int) -> void:
	print("Connection succeeded for player id: " + str(id))

func connection_failed(id : int) -> void:
	print("Connection failed for player id: " + str(id))
	get_tree().set_network_peer(null)

func peer_connected(id : int) -> void:
	print("Peer connected with id: " + str(id))
	
	rpc_id(id, "return_game_data", game_data)

func peer_disconnected(id : int) -> void:
	print("Peer disconnected with id: " + str(id))

#start host player
func start_host() -> void:
	#create server
	network.create_server(port, playerlimit, in_bandwidth, out_bandwidth)
	get_tree().set_network_peer(network)
	
	#prevent players from joining while server is still loading
	network.refuse_new_connections = true
	
	#loads map and gamemode, and removes menu
	load_game()
	
	#loading stuff is done, allow players to join
	network.refuse_new_connections = false

#start client player, connects to host player
func start_client() -> void:
	#connect to server
	network.create_client(ip, port, in_bandwidth, out_bandwidth, client_port)
	get_tree().set_network_peer(network)
	
	#get server info and load map n shit
	yield(self, "recieved_game_data")
	
	#loads map and gamemode, and removes menu
	load_game()

#loads map and gamemode
func load_game() -> void:
	#load map
	var resource := Maps.load_map(game_data["map"])
	MapInstance = resource.instance()
	$"/root".add_child(MapInstance, true)
	
	#load map's gamemode nodes
	resource = Maps.load_mode(game_data["map"], game_data["mode"])
	GamemodeInstance = resource.instance()
	MapInstance.add_child(GamemodeInstance)
	
	#load gamemode script
	resource = Gamemodes.load_gamemode_script(game_data["mode"])
	GamemodeInstance.set_script(resource)
	#initialize gamemode
	GamemodeInstance.init()
	
	#load pause menu
	resource = load("res://scenes/ingame/pausemenu/pausemenu.tscn")
	PauseMenu = resource.instance()
	$"/root".add_child(PauseMenu)
	
	#remove menu
	$"/root/Menu".queue_free()
	print("Started host")

func close_server() -> void:
	#close server
	network.close_connection()
	
	#unload gamemode
	GamemodeInstance.queue_free()
	GamemodeInstance = null
	
	#unload map
	MapInstance.queue_free()
	MapInstance = null
	
	#removes pause menu
	PauseMenu.queue_free()
	PauseMenu = null
	
	#load menu
	var resource := load("res://scenes/menu/menu.tscn")
	$"/root".add_child(resource.instance())

#menu connection server starting funcs
func set_server(address : String, port : int) -> void:
	ip = address
	self.port = port




#host functions




#client functions
remote func return_game_data(data : Dictionary) -> void:
	game_data = data
	emit_signal("recieved_game_data")

remote func load_new_game(data : Dictionary) -> void:
	pass



#gamemode funcs
#changes all game data
func change_game(data : Dictionary) -> void:
	change_map(data["map"])
	change_mode(data["mode"])

#changes map
func change_map(map : String) -> void:
	game_data["map"] = map

#changes gamemode
func change_mode(mode : String) -> void:
	game_data["mode"] = mode

#loads map
func load_map() -> void:
	var resource := Maps.load_map(game_data["map"])
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
