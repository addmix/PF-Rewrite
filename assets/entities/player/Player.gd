extends Node

#nodes
var player_name : String = "Player"
var player_id : int = 0

var character_reference = preload("res://assets/entities/player/Character.tscn")
var character : Spatial

#values
var loadout := ["M4A1", "P38", null, null]

#signals
signal died

func _connect_signals() -> void:
	pass

func instance_character() -> void:
	#remove preexisting character
	if character:
		character.queue_free()
	
	#iunstance fresh character
	character = character_reference.instance()
	#initializes character values
	initialize_character()
	#connects character signals
	connect_character_signals()

func initialize_character() -> void:
	#give character a reference to player node
	character.player = self

func connect_character_signals() -> void:
	pass

#call to gamemode player spawner
func spawn_character() -> void:
	pass

func remove_character() -> void:
	pass

