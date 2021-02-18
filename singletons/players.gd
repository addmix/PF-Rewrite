extends Node

signal player_added
# warning-ignore:unused_signal
signal player_removed

var player : PackedScene = preload("res://assets/entities/player/player.tscn")

#id: data
var players := {}

var players_data := {}

var local_player := {
	"name": "Player",
	"character": null,
}

func _ready() -> void:
	_connect_signals()

func _connect_signals() -> void:
# warning-ignore:return_value_discarded
	Server.connect("server_closed", self, "on_server_closed")
# warning-ignore:return_value_discarded
	Server.connect("connection_successful", self, "on_connection_succeeded")
# warning-ignore:return_value_discarded
	Server.connect("connection_failed", self, "on_connection_dailed")
# warning-ignore:return_value_discarded
	Server.connect("peer_connected", self, "on_peer_connected")
# warning-ignore:return_value_discarded
	Server.connect("peer_disconnected", self, "on_peer_disconnected")

func on_server_closed() -> void:
	#removes characters
	get_tree().call_group("characters", "free")
	#removes players
	get_tree().call_group("players", "free")
	#empties player dictionary
	players.clear()

#client only
func on_connection_succeeded() -> void:
	rpc_id(1, "send_player_data", local_player)

#client only
func on_connection_failed() -> void:
	pass

# warning-ignore:unused_argument
func on_peer_connected(id : int) -> void:
	pass

func on_peer_disconnected(id : int) -> void:
	players[id].queue_free()
# warning-ignore:return_value_discarded
	players.erase(id)

#on server
remote func send_player_data(data : Dictionary) -> void:
	if get_tree().is_network_server():
		#send new player's data to everyone
		rpc("distribute_player_data", get_tree().get_rpc_sender_id(), data)
		
		#sends all players' data to new client
		rpc_id(get_tree().get_rpc_sender_id(), "recieve_player_data", players_data)
		
		#get spawned players
		var characters = get_tree().get_nodes_in_group("characters")
		var ids := []
		for character in characters:
			ids.append(character.Player.player_id)
		
		rpc_id(get_tree().get_rpc_sender_id(), "recieve_spawned_players", ids)

#on new client
remote func recieve_player_data(data : Dictionary) -> void:
	if get_tree().get_rpc_sender_id() == 1:
		
		#loop through all entries and create players
		for id in data.keys():
			add_player(id, data[id])

remote func recieve_spawned_players(ids : Array) -> void:
	#this is bad solution
	for id in ids:
		players[id].spawn_character(get_tree().get_nodes_in_group("Spawns")[0])

#on clients
remotesync func distribute_player_data(id : int, data : Dictionary) -> void:
	if get_tree().get_rpc_sender_id() == 1 and id != get_tree().get_network_unique_id():
		add_player(id, data)

#everywhere
func add_player(id : int, data : Dictionary) -> void:
	#stores data
	players_data[id] = data
	#instance new player
	var instance = player.instance()
	#give player node full player data
	instance.data = players_data[id]
	
	
	
	#could move this all into player
	
	#set player master
	instance.set_network_master(id)
	#add to players group
	instance.add_to_group("Players")
	#set node name to player ID
	instance.name = str(id)
	#set player id
	instance.player_id = id
	#set player name
	instance.player_name = data["name"]
	
	
	
	#add player node to players dictionary
	players[id] = instance
	#adds player to the tree
	add_child(instance)
	
	#emit player added signal
	emit_signal("player_added", instance)
