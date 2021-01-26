extends Node

# warning-ignore:unused_signal
signal changeState

func release() -> void:
	call_deferred("emit_signal", "changeState", "Forward")

# warning-ignore:unused_argument
func enter(prev : String) -> void:
	pass

func exit() -> void:
	pass

func stop() -> void:
	pass

# warning-ignore:unused_argument
func process(delta : float) -> void:
	pass

# warning-ignore:unused_argument
func unhandled_input(event : InputEvent) -> void:
	pass

func fire() -> void:
	pass
