extends Control

var PlayerSpawner : Node
var PlayerButton : Resource = preload("res://gamemodes/boilerplates/playerspawner/player.tscn")

func _on_Spawn_pressed():
	PlayerSpawner.on_spawn_pressed()
