extends Node

#signals
signal player_spawned

#variables
var allow_spawning := false setget set_spawning, get_spawning
func set_spawning(value : bool = true) -> void:
	allow_spawning = value
func get_spawning() -> bool:
	return allow_spawning

#nodes
var Gamemode : Node
var selected_spawn : Position3D
var plugin = preload("res://gamemodes/boilerplates/playerspawner/playerspawneruiplugin.tscn")
var Plugin : Control


#base funcs
func _ready() -> void:
	#creates instance
	Plugin = plugin.instance()
	#gives UI plugin reference to spawn script
	Plugin.PlayerSpawner = self
	#adds plugin to tree
	add_child(Plugin)

func _exit_tree() -> void:
	Plugin.free()


#setup funcs
func _connect_signals() -> void:
	var err = connect("player_spawned", self, "on_Player_spawned")
	if err != OK:
		push_error("Error while connecting signal \"player_spawned\" to node " + str(self) + ", function \"on_Player_spawned\"")


#menu funcs
func show_menu() -> void:
	add_child(Plugin)

func hide_menu() -> void:
	remove_child(Plugin)


#spawn funcs
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

func spawn_check(_node : Position3D) -> bool:
	return allow_spawning

func on_Player_spawned(player : Player) -> void:
	#remove menu
	if player.is_network_master():
		#removes menu when spawned
		hide_menu()
