extends Node

# warning-ignore:unused_signal
signal change_state
signal reset

# warning-ignore:unused_argument
func enter(prev : String) -> void:
	call_deferred("emit_signal", "reset")

func exit() -> void:
	pass

func stop() -> void:
	pass

# warning-ignore:unused_argument
func process(delta : float) -> void:
	pass

# warning-ignore:unused_argument
func unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		emit_signal("change_state", "Fire")
		get_tree().set_input_as_handled()

func fire() -> void:
	pass
