extends Node

signal change_state
var character : KinematicBody

func enter() -> void:
	character.Aim.target = 0

func exit() -> void:
	pass

func unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("aim"):
		call_deferred("emit_signal", "change_state", "Aim")
		get_tree().set_input_as_handled()
	elif event.is_action_pressed("toggle_aim"):
		call_deferred("emit_signal", "change_state", "Aim")
		get_tree().set_input_as_handled()

func process(delta : float) -> void:
	pass
