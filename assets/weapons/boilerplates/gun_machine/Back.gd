extends Node

# warning-ignore:unused_signal
signal change_state

# warning-ignore:unused_argument
func enter(prev : String) -> void:
	if get_parent().get_parent().get_magazine() <= 0:
		call_deferred("emit_signal", "change_state", "Locked")
	else:
		call_deferred("emit_signal", "change_state", "Forward")
	

func exit() -> void:
	pass

func stop() -> void:
	pass

# warning-ignore:unused_argument
func process(delta: float) -> void:
	pass

# warning-ignore:unused_argument
func unhandled_input(event : InputEvent) -> void:
	pass

func fire() -> void:
	pass
