extends Node

signal change_state
var character : KinematicBody

func enter() -> void:
	character.crouch_spring.target = 1
	character.prone_spring.target = 0

func exit() -> void:
	pass

func unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("stance_down"):
		call_deferred("emit_signal", "change_state", "Prone")
		get_tree().set_input_as_handled()
	elif event.is_action_pressed("stance_up"):
		call_deferred("emit_signal", "change_state", "Stand")
		get_tree().set_input_as_handled()
	elif event.is_action_pressed("stand"):
		call_deferred("emit_signal", "change_state", "Stand")
		get_tree().set_input_as_handled()
	elif event.is_action_pressed("prone"):
		call_deferred("emit_signal", "change_state", "Prone")
		get_tree().set_input_as_handled()

func process(delta : float) -> void:
	pass
