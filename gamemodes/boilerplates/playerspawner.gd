extends Node

var selected_spawn : Position3D

func select_player(player : Position3D) -> void:
	#if player on same team
	#if player not in danger
	#if player not in restricted area
	pass

func spawn() -> void:
	#when no spawn point selected
	if selected_spawn == null:
		spawn_player(get_best_spawn())
	else:
		#check if player is viable to spawn on
		pass
	
	pass

func spawn_player(pos : Position3D) -> void:
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
