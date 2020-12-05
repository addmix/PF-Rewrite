extends Node

#this will change
var ip := "127.0.0.1"
var port := 1909

var network := NetworkedMultiplayerENet.new()

func _ready() -> void:
	connect_signals()

func connect_signals() -> void:
# warning-ignore:return_value_discarded
	network.connect("connection_failed", self, "on_failed_to_connect")
# warning-ignore:return_value_discarded
	network.connect("connection_succeeded", self, "on_successfully_connected")
# warning-ignore:return_value_discarded
	network.connect("peer_connected", self, "on_peer_connected")
# warning-ignore:return_value_discarded
	network.connect("peer_disconnected", self, "on_peer_disconnected")

func start_multiplayer() -> void:
	#change port, ip, or other settings
	start_client()

func start_singleplayer() -> void:
	var server : Node = load("res://servers/server/server.tscn").instance()
	#set server properties
	
	#add server
	$"/root".add_child(server, true)
	#start server
	server.load_singleplayer_server()
	#start client after server loads fully
	start_client()

func start_client() -> void:
	# warning-ignore:return_value_discarded
	network.create_client(ip, port)

func on_failed_to_connect() -> void:
	print("Failed to connect")
	get_tree().set_network_peer(null)

func on_successfully_connected() -> void:
	print("Successfully connected")
	get_tree().set_network_peer(network)

func on_peer_connected(id : int) -> void:
	print("Peer successfully connected " + str(id))

func on_peer_disconnected(id : int) -> void:
	print("Peer disconnected " + str(id))
