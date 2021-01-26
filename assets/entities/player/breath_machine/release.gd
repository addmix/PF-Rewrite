extends Node

signal change_state
var character : KinematicBody

func enter() -> void:
	character.Breath.target = 0

func exit() -> void:
	pass

func unhandled_input(event : InputEvent) -> void:
	#trying to hold breath, while aiming and not sprinting
	if event.is_action_pressed("hold_breath") and character.AimMachine.current_state == "Aim" and character.MovementMachine.current_state == "Idle":
		emit_signal("change_state", "Hold")
		get_tree().set_input_as_handled()

func process(delta : float) -> void:
	pass
