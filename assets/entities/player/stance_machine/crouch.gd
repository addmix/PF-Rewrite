extends Node

# warning-ignore:unused_signal
signal change_state
var character : KinematicBody

func enter() -> void:
	character.Crouch.target = 1
	character.Prone.target = 0

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

# warning-ignore:unused_argument
func process(delta : float) -> void:
	pass
