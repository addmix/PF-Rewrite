extends Node

# warning-ignore:unused_signal
signal change_state
var character : KinematicBody

func enter() -> void:
	#do a cooldown
	call_deferred("emit_signal", "change_state", "Ground")

func exit() -> void:
	pass

# warning-ignore:unused_argument
func unhandled_input(event : InputEvent) -> void:
	pass

# warning-ignore:unused_argument
func process(delta : float) -> void:
	pass
