extends Node

signal change_state

func _ready() -> void:
	pass

func enter(prev : String) -> void:
	#set's the map's deploy camera to be current
	Server.MapInstance.DeployCamera.current = true

func exit() -> void:
	#set's the map's deploy camera to no longer be current
	Server.MapInstance.DeployCamera.current = false

func process(delta : float) -> void:
	pass

func unhandled_input(event : InputEvent) -> void:
	pass
