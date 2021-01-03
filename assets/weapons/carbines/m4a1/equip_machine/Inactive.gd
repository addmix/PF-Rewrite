extends Node

# warning-ignore:unused_signal
signal change_state
signal entered
signal exited
# warning-ignore:unused_signal
signal finished

func enter() -> void:
	emit_signal("entered")
	

func exit() -> void:
	emit_signal("exited")
	

# warning-ignore:unused_argument
func process(delta : float) -> void:
	pass

# warning-ignore:unused_argument
func unhandled_input(event : InputEvent) -> void:
	pass
