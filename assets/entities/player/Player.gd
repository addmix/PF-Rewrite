extends Node

class_name Player

#values
var data : Dictionary
var loadout := ["M4A1", "P38", null, null]

var player_name : String
var player_id : int
var team : int

#nodes
var character = preload("res://assets/entities/player/Character.tscn")
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
	#initializes character values
	initialize_character()
	#connects character signals
	connect_character_signals()

func initialize_character() -> void:
	#give character a reference to player node
	character_instance.name = str(player_id)
	
	character_instance.set_network_master(player_id)
	
	character_instance.Player = self
	
	character_instance.add_to_group("characters")

func connect_character_signals() -> void:
# warning-ignore:return_value_discarded
	character_instance.connect("died", self, "on_player_died")

func on_player_died() -> void:
	emit_signal("died", self)
	
	remove_character()
	
	#show menu
	if is_network_master():
		Server.GamemodeInstance.Spawner.show_menu()

#call to gamemode player spawner
# warning-ignore:unused_argument
func spawn_character(node : Position3D) -> void:
	push_error("ww")
	instance_character()
	call_deferred("spawn_deferred")

func spawn_deferred() -> void:
	add_child(character_instance)
	var spawn_point : Transform = get_tree().get_nodes_in_group("Spawns")[0].get_global_transform()
	character_instance.transform.origin = spawn_point.origin
	character_instance.rotation.y = spawn_point.basis.get_euler().y

func remove_character() -> void:
	character_instance.remove_from_group("characters")
	character_instance.queue_free()

func _exit_tree() -> void:
	if character_instance:
		remove_character()
