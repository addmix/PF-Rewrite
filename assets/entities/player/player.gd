extends Node
class_name Player


#signals


#stats
signal update_kills
signal update_deaths
signal update_assists
signal update_score

#state
signal spawned
signal died


#variables


#player vars
var player_name : String
var player_id : int
var team : int
var data : Dictionary
var loadout := ["M4A1", null, null, null]

#stats
var kills := 0 setget set_kills, get_kills
func set_kills(k : int) -> void:
	kills = k
	emit_signal("update_kills")
func get_kills() -> int:
	return kills
var deaths := 0 setget set_deaths, get_deaths
func set_deaths(d : int) -> void:
	deaths = d
	emit_signal("update_deaths")
func get_deaths() -> int:
	return deaths
var assists := 0 setget set_assists, get_assists
func set_assists(a : int) -> void:
	assists = a
	emit_signal("update_assists")
func get_assists() -> int:
	return assists
var score := 0.0 setget set_score, get_score
func set_score(s : float) -> void:
	score = s
	emit_signal("update_score")
func get_score() -> float:
	return score


#nodes

#player nodes
onready var character = load("res://assets/entities/player/character/character.tscn")
var character_instance : Character

#visuals
var hitmarker : PackedScene = preload("res://assets/weapons/hitmarker.tscn")




#functions


#base functions
func _exit_tree() -> void:
	if character_instance:
		remove_character()

func connect_character_signals() -> void:
	var err := []
	err.append(character_instance.connect("spawned", self, "on_player_spawned"))
	err.append(character_instance.connect("died", self, "on_player_died"))
	#check for errors


#when player is hit
func connect_hit() -> void:
	#plays hitmarker
	var instance : AudioStreamPlayer = hitmarker.instance()
	instance.add_to_group("Hitmarkers")
	add_child(instance)
	instance.play(0)


#spawning/removing
func on_player_spawned() -> void:
	emit_signal("spawned")
	
	#hide menu
	if is_network_master():
		Server.GamemodeInstance.Spawner.hide_menu()

func on_player_died() -> void:
	deaths += 1
	emit_signal("update_deaths")
	emit_signal("died", self)
	remove_character()
	
	#show menu
	if is_network_master():
		Server.GamemodeInstance.Spawner.show_menu()

func remove_character() -> void:
	character_instance.remove_from_group("characters")
	character_instance.queue_free()

func spawn_character(_node : Position3D) -> void:
	instance_character()
	add_child(character_instance)
	
	var spawn_point : Transform = get_tree().get_nodes_in_group("Spawns")[0].get_global_transform()
	character_instance.transform.origin = spawn_point.origin

func instance_character() -> void:
	#remove preexisting character
	if character_instance:
		remove_character()
	
	#instance new character
	character_instance = character.instance()
	character_instance.name = str(player_id)
	character_instance.set_network_master(player_id)
	character_instance.Player = self
	character_instance.add_to_group("characters")
	connect_character_signals()


