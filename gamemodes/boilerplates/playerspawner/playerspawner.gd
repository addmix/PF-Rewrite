extends Node

signal player_spawned

var Gamemode : Node

var plugin = preload("res://gamemodes/boilerplates/playerspawner/playerspawneruiplugin.tscn")
var Plugin : Control

var allow_spawning := false setget set_spawning, get_spawning
func set_spawning(value : bool = true) -> void:
	allow_spawning = value
func get_spawning() -> bool:
	return allow_spawning

var selected_spawn : Position3D

func _ready() -> void:
	#creates instance
	Plugin = plugin.instance()
	#gives UI plugin reference to spawn script
	Plugin.PlayerSpawner = self
	#adds plugin to tree
	add_child(Plugin)

func _connect_signals() -> void:
# warning-ignore:return_value_discarded
	connect("player_spawned", self, "on_Player_spawned")

func show_menu() -> void:
	add_child(Plugin)

func hide_menu() -> void:
	remove_child(Plugin)

func on_spawn_pressed() -> void:
	if get_tree().is_network_server():
		puppet_spawn(1, get_tree().get_nodes_in_group("Spawns")[0])
	else:
		rpc_id(1, "puppet_spawn", 0, get_tree().get_nodes_in_group("Spawns")[0])

remote func puppet_spawn(id : int, node : Position3D) -> void:
	if get_tree().is_network_server() and spawn_check(node):
		rpc("puppet_spawn", get_tree().get_rpc_sender_id(), node)
	spawn_player(id, node)

func spawn_player(player : int, node : Position3D) -> void:
	#spawn character
	Players.players[player].spawn_character(node)
	emit_signal("player_spawned", Players.players[player])

# warning-ignore:unused_argument
func spawn_check(node : Position3D) -> bool:
	return allow_spawning

# warning-ignore:unused_argument
func on_Player_spawned(player : Player) -> void:
	#remove menu
	if player.is_network_master():
		#removes menu when spawned
		hide_menu()

func _exit_tree() -> void:
	Plugin.free()
