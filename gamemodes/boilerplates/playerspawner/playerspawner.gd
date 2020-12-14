extends Node

var spawned_players := {}

var player = preload("res://assets/entities/player/Player.tscn")
var plugin = preload("res://gamemodes/boilerplates/playerspawner/playerspawneruiplugin.tscn")
var Plugin : Control

func _ready():
	#loads and instances the spawner's UI plugin
	var instance = plugin.instance()
	instance.PlayerSpawner = self
	Plugin = instance
	add_child(instance)

var selected_spawn : Position3D

func connect_signals() -> void:
	Server.network.connect("peer_disconnected", self, "on_player_left")

#when spawn pressed
func on_spawn_pressed() -> void:
	#send request to server
	Plugin.hide()
	if get_tree().is_network_server():
		request_spawn(1)
	else:
		rpc_id(1, "request_spawn")

#server recieves request from client to spawn
remote func request_spawn(id : int) -> void:
	#server validates spawn
	rpc("spawn_player", id, get_best_spawn())

remotesync func spawn_player(id : int, pos : Vector3) -> void:
	if get_tree().get_rpc_sender_id() == 1:
		#spawn player
		var instance = player.instance()
		instance.name = str(id)
		instance.set_network_master(id)
		instance.add_to_group("players")
		instance.transform.origin = pos
		spawned_players[id] = instance
		$"/root".add_child(instance)

remotesync func despawn_player(id : int) -> void:
	#remove player from world
	spawned_players[id].queue_free()
	#erase player from spawned players
	spawned_players.erase(id)

func get_best_spawn() -> Position3D:
	var spawns := get_tree().get_nodes_in_group("Spawners")
	
	var highest_value := 0.0
	var highest_spawn := 0
	#find spawn with the highest value
	for pos in range(spawns.size()):
		var value := get_spawn_value(spawns[pos])
		highest_value = value * int(value > highest_value)
		highest_spawn = pos * int(value > highest_value)
	
	return spawns[highest_spawn].transform.origin

#computes a value for each spawn location
func get_spawn_value(spawn : Position3D) -> float:
	
	return 0.0

#when player leaves the server
func on_player_left(id : int) -> void:
	if spawned_players.has(id):
		despawn_player(id)
