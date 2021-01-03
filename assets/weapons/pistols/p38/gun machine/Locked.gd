extends Node

# warning-ignore:unused_signal
signal change_state

func release() -> void:
	call_deferred("emit_signal", "change_state", "Forward")

func enter() -> void:
	pass

func exit() -> void:
	pass

# warning-ignore:unused_argument
func process(delta : float) -> void:
	pass

# warning-ignore:unused_argument
func unhandled_input(event : InputEvent) -> void:
	pass
