extends Node

class_name Player

#values
var data : Dictionary
var loadout := ["M4A1", null, null, null]

var player_name : String
var player_id : int
var team : int

var kills := 0
# warning-ignore:unused_signal
signal update_kills
var deaths := 0
signal update_deaths
var assists := 0
# warning-ignore:unused_signal
signal update_assists
var score := 0.0
# warning-ignore:unused_signal
signal update_score

#nodes
onready var character = load("res://assets/entities/player/character/character.tscn")
var character_instance : Character

#signals
signal died

func _connect_signals() -> void:
	pass

func instance_character() -> void:
	#remove preexisting character
	if character_instance:
		remove_character()
	
	#instance fresh character
	character_instance = character.instance()
	
	#give character a reference to player node
	character_instance.name = str(player_id)
	
	character_instance.set_network_master(player_id)
	
	character_instance.Player = self
	
	character_instance.add_to_group("characters")
	#connects character signals
	connect_character_signals()

func connect_character_signals() -> void:
# warning-ignore:return_value_discarded
	character_instance.connect("died", self, "on_player_died")
# warning-ignore:return_value_discarded
	character_instance.connect("spawned", self, "on_player_spawned")

func on_player_died() -> void:
	deaths += 1
	emit_signal("update_deaths")
	emit_signal("died", self)
	
	remove_character()
	
	#show menu
	if is_network_master():
		Server.GamemodeInstance.Spawner.show_menu()

func on_player_spawned() -> void:
	if is_network_master():
		Server.GamemodeInstance.Spawner.hide_menu()

#call to gamemode player spawner
# warning-ignore:unused_argument
func spawn_character(node : Position3D) -> void:
	instance_character()
#	call_deferred("spawn_deferred")
	spawn_deferred()

func spawn_deferred() -> void:
	add_child(character_instance, true)
	
	var spawn_point : Transform = get_tree().get_nodes_in_group("Spawns")[0].get_global_transform()
	character_instance.transform.origin = spawn_point.origin

func remove_character() -> void:
	character_instance.remove_from_group("characters")
	character_instance.queue_free()

func _exit_tree() -> void:
	if character_instance:
		remove_character()

var hitmarker : PackedScene = preload("res://assets/weapons/hitmarker.tscn")
func connect_hit() -> void:
	var instance : AudioStreamPlayer = hitmarker.instance()
	instance.add_to_group("Hitmarkers")
	add_child(instance)
	instance.play(0)
