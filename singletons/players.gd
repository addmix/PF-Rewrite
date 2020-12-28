extends Node

var player = preload("res://assets/entities/player/Player.tscn")

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
	Server.connect("connection_successful", self, "on_connection_succeeded")
	Server.connect("connection_failed", self, "on_connection_dailed")
	Server.connect("peer_connected", self, "on_peer_connected")
	Server.connect("peer_disconnected", self, "on_peer_disconnected")

#client only
func on_connection_succeeded() -> void:
	rpc_id(1, "send_player_data", local_player)

#client only
func on_connection_failed() -> void:
	pass

func on_peer_connected(id : int) -> void:
	pass

func on_peer_disconnected(id : int) -> void:
	players[id].queue_free()

#on server
remote func send_player_data(data : Dictionary) -> void:
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
	for id in ids:
		players[id].spawn_character(get_tree().get_nodes_in_group("Spawns")[0])

#on clients
remotesync func distribute_player_data(id : int, data : Dictionary) -> void:
	if get_tree().get_rpc_sender_id() == 1:
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
	instance.add_to_group("players")
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
