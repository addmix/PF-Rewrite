extends Node

# warning-ignore:unused_signal
signal change_state

func enter() -> void:
	if get_parent().get_parent().chamber > 0:
		get_parent().get_parent().emit_signal("shotFired")
		yield(get_tree().create_timer(.08), "timeout")
		call_deferred("emit_signal", "change_state", "Back")
		

func exit() -> void:
	pass

# warning-ignore:unused_argument
func process(delta : float) -> void:
	pass

# warning-ignore:unused_argument
func unhandled_input(event : InputEvent) -> void:
	pass
