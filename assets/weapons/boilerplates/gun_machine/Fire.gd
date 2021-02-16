extends Node

# warning-ignore:unused_signal
signal change_state

# warning-ignore:unused_argument
func enter(prev : String) -> void:
	if get_parent().get_parent().get_chamber() > 0:
		#subtract spent bullet
		get_parent().get_parent().set_chamber(get_parent().get_parent().get_chamber() - 1)
		#announce shot fired
		get_parent().get_parent().emit_signal("shotFired")
		#firerate delay
		yield(get_tree().create_timer(.08), "timeout")
		#change state
		call_deferred("emit_signal", "change_state", "Back")

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
