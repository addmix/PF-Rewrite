extends Node

var plugin = preload("res://gamemodes/boilerplates/playerspawner/playerspawneruiplugin.tscn")
var Plugin : Control

func _ready() -> void:
	Plugin = plugin.instance()
	add_child(Plugin)
