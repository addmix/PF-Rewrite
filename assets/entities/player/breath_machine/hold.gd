extends Node

signal change_state
var character : KinematicBody

func enter() -> void:
	character.Breath.target = 1

func exit() -> void:
	pass

func unhandled_input(event : InputEvent) -> void:
	if event.is_action_released("hold_breath"):
		emit_signal("change_state", "Release")
		get_tree().set_input_as_handled()

func process(delta : float) -> void:
	if character.MovementMachine.current_state != "Idle":
		emit_signal("change_state", "Release")
