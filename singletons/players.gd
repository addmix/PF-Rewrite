extends Node


#Have persistent node for each player that deals with loadout information
#and is the wrapper for spawning/destroying



var player := {
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
	pass

