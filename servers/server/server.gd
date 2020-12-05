extends Node

var network := NetworkedMultiplayerENet.new()

func _ready() -> void:
	connect_signals()

func connect_signals() -> void:
# warning-ignore:return_value_discarded
	network.connect("peer_connected", self, "on_peer_connected")
# warning-ignore:return_value_discarded
	network.connect("peer_disconnected", self, "on_peer_disconnected")

#for running dedicated server
func load_multiplayer_server() -> void:
	#load map/gamemode
	
	#load server
	start_server()

#for running singleplayer/lan server
func load_singleplayer_server() -> void:
	#load map/gamemode
	
	#load server
	start_server()

func start_server() -> void:
# warning-ignore:return_value_discarded
	network.create_server(ServerProperties.properties["port"], ServerProperties.properties["max_players"], ServerProperties.properties["in_bandwidth"], ServerProperties.properties["out_bandwidth"])
	get_tree().set_network_peer(network)

func on_peer_connected(id : int) -> void:
	print("Peer successfully connected " + str(id))
	#send client necessary information

func on_peer_disconnected(id : int) -> void:
	print("Peer disconnected " + str(id))
	#remove client's shit




#loading map/gamemode




#load map/gamemode
func load_match():
	pass

#unload map/gamemode (for after one match ends, then you can load another match
func unload_match():
	pass
