extends Node

signal change_state
var character : KinematicBody

func enter() -> void:
	character.Sprint.target = 0

func exit() -> void:
	pass

# warning-ignore:unused_argument
func unhandled_input(event : InputEvent) -> void:
	pass

# warning-ignore:unused_argument
func process(delta : float) -> void:
	if character.movement_spring.target.length() > 0.001:
		emit_signal("change_state", "Walk")
