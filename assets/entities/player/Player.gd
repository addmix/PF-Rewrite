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
	Character.player = self
	
	Character.add_to_group("characters")

func connect_character_signals() -> void:
	pass

#call to gamemode player spawner
func spawn_character() -> void:
	instance_character()

func remove_character() -> void:
	Character.remove_from_group("characters")
	Character.queue_free()

func _exit_tree() -> void:
	if Character:
		remove_character()
