extends Node

signal change_state
var character : KinematicBody

func enter() -> void:
	pass

func exit() -> void:
	pass

func unhandled_input(event : InputEvent) -> void:
	pass

func process(delta : float) -> void:
	if !character.is_on_floor() and character.velocity.y <= 0:
		emit_signal("change_state", "Down")
