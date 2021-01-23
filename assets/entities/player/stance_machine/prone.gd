extends Node

signal change_state
var character : KinematicBody

func enter() -> void:
	character.Crouch.target = 0
	character.Prone.target = 1

func exit() -> void:
	pass

func unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("stance_up"):
		call_deferred("emit_signal", "change_state", "Crouch")
		get_tree().set_input_as_handled()
	elif event.is_action_pressed("stand"):
		call_deferred("emit_signal", "change_state", "Stand")
		get_tree().set_input_as_handled()
	elif event.is_action_pressed("crouch"):
		call_deferred("emit_signal", "change_state", "Crouch")
		get_tree().set_input_as_handled()

func process(delta : float) -> void:
	pass
