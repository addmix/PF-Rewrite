extends Node

signal change_state
var character : KinematicBody

func enter() -> void:
	character.Sprint.target = 1

func exit() -> void:
	pass

func unhandled_input(event : InputEvent) -> void:
	if event.is_action_released("sprint"):
		call_deferred("emit_signal", "change_state", "Walk")
		get_tree().set_input_as_handled()
	elif event.is_action_pressed("toggle_sprint"):
		call_deferred("emit_signal", "change_state", "Walk")
		get_tree().set_input_as_handled()

func process(delta : float) -> void:
	if character.movement_spring.target.length() < 0.01:
		emit_signal("change_state", "Idle")
