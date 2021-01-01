extends Node

var Gamemode : Node

var plugin = preload("res://gamemodes/boilerplates/playerspawner/playerspawneruiplugin.tscn")
var Plugin : Control

var allow_spawning := false setget set_spawning, get_spawning
func set_spawning(value : bool = true) -> void:
	allow_spawning = value
func get_spawning() -> bool:
	return allow_spawning

func _ready() -> void:
	#creates instance
	Plugin = plugin.instance()
	#gives UI plugin reference to spawn script
	Plugin.PlayerSpawner = self
	#adds plugin to tree
	add_child(Plugin)

func show_menu() -> void:
	add_child(Plugin)

func hide_menu() -> void:
	remove_child(Plugin)

func spawn_check(node : Position3D) -> bool:
	return allow_spawning

func on_spawn_pressed() -> void:
	if get_tree().is_network_server():
		#accept/deny
		if spawn_check(get_tree().get_nodes_in_group("Spawns")[0]):
			rpc("accept_spawn", 1, get_tree().get_nodes_in_group("Spawns")[0])
		else:
			rpc("decline_spawn", 1, get_tree().get_nodes_in_group("Spawns")[0])
	else:
		rpc_id(1, "request_spawn", get_tree().get_nodes_in_group("Spawns")[0])

remote func request_spawn(node : Position3D) -> void:
	
	#make a decision here
	if spawn_check(node):
		rpc("accept_spawn", get_tree().get_rpc_sender_id(), node)
	else:
		rpc("decline_spawn", get_tree().get_rpc_sender_id(), node)

remotesync func accept_spawn(id : int, node : Position3D) -> void:
	Players.players[id].spawn_character(node)
	if id == get_tree().get_network_unique_id():
		#removes menu when spawned
		hide_menu()

remotesync func decline_spawn(id : int, node : Position3D) -> void:
	pass
