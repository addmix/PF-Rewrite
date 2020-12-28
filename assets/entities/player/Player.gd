extends Node

#values
var data : Dictionary
var loadout := ["M4A1", "P38", null, null]

var player_name : String
var player_id : int

#nodes
var character = preload("res://assets/entities/player/Character.tscn")
var Character : Spatial



#signals
signal died

func _connect_signals() -> void:
	pass

func instance_character() -> void:
	#remove preexisting character
	if Character:
		Character.queue_free()
	
	#instance fresh character
	Character = character.instance()
	#initializes character values
	initialize_character()
	#connects character signals
	connect_character_signals()

func initialize_character() -> void:
	#give character a reference to player node
	Character.set_network_master(player_id)
	
	Character.Player = self
	
	Character.add_to_group("characters")

func connect_character_signals() -> void:
	pass

#call to gamemode player spawner
func spawn_character(node : Position3D) -> void:
	instance_character()
	$"/root".add_child(Character)
	#set player's transform
	Character.transform = get_tree().get_nodes_in_group("Spawns")[0].transform

func remove_character() -> void:
	Character.remove_from_group("characters")
	Character.queue_free()
	if is_network_master():
		Server.GamemodeInstance.Spawner.show_menu()

func _exit_tree() -> void:
	if Character:
		remove_character()
