extends Node

var plugin = preload("res://gamemodes/boilerplates/playerspawner/playerspawneruiplugin.tscn")

func _ready():
	#loads and instances the spawner's UI plugin
	var instance = plugin.instance()
	instance.PlayerSpawner = self
	add_child(instance)

var selected_spawn : Position3D

func on_player_selected(id : int) -> void:
	rpc_id(1, "select_player", id)

remotesync func select_player(id : int) -> void:
	#if player on same team
	#if player not in danger
	#if player not in restricted area
	pass

remotesync func spawn() -> void:
	#when no spawn point selected
	if selected_spawn == null:
		spawn_player(get_best_spawn())
	else:
		#check if player is viable to spawn on
		pass
	pass

remotesync func spawn_player(pos):
	if get_tree().get_rpc_sender_id() == 1:
		#spawn player
		pass

func get_best_spawn() -> Position3D:
	var spawns := get_tree().get_nodes_in_group("Spawners")
	
	var highest_value := 0.0
	var highest_spawn := 0
	#find spawn with the highest value
	for pos in range(spawns.size()):
		var value := get_spawn_value(spawns[pos])
		highest_value = value * int(value > highest_value)
		highest_spawn = pos * int(value > highest_value)
	
	return spawns[highest_spawn]

#computes a value for each spawn location
func get_spawn_value(spawn : Position3D) -> float:
	
	return 0.0
