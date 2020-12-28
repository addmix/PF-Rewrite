extends Node

var player = preload("res://assets/entities/player/Player.tscn")

#Have persistent node for each player that deals with loadout information
#and is the wrapper for spawning/destroying



var player_template := {
	"name": "name",
	"character": null,
}

#id: data
var players := {}

var local_player := {
	"name": "Player",
	"character": null,
}

func _ready() -> void:
	Server.connect("connection_successful", self, "on_connection_successful")
	Server.connect("connection_failed", self, "on_connection_dailed")
	Server.connect("peer_connected", self, "on_peer_connected")
	Server.connect("peer_disconnected", self, "on_peer_disconnected")

func on_connection_succeeded(id : int) -> void:
	pass

func on_connection_failed(id : int) -> void:
	pass

func on_peer_connected(id : int) -> void:
	#add peer to player list
	#send peer player data
	pass

func on_peer_disconnected(id : int) -> void:
	#remove peer
	pass

func add_player(id : int, data : Dictionary) -> void:
	#instance new player
	var instance = player.instance()
	#set player master
	instance.set_network_master(id)
	#add to players group
	instance.add_to_group("players")
	#set node name to player ID
	instance.name = str(id)
	#set player id
	instance.player_id = id
	#set player name
	instance.player_name = data["name"]
	
	#add player node to players dictionary
	players[id] = instance

