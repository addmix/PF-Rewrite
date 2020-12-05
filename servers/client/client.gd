extends Node

var network := NetworkedMultiplayerENet.new()

func _ready() -> void:
	connect_signals()

func connect_signals() -> void:
	network.connect("connection_failed", self, "on_failed_to_connect")
	network.connect("connection_succeeded", self, "on_successfully_connected")
	network.connect("peer_connected", self, "on_peer_connected")
	network.connect("peer_disconnected", self, "on_peer_disconnected")

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

func start_server() -> void:
#	network.create_client()
	
	pass
