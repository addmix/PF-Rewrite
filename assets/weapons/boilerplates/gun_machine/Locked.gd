extends Node

# warning-ignore:unused_signal
signal change_state

func release() -> void:
	print("release")
	call_deferred("emit_signal", "change_state", "Forward")

# warning-ignore:unused_argument
func enter(prev : String) -> void:
	print("locked")
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
