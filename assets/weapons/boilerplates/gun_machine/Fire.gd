extends Node

# warning-ignore:unused_signal
signal change_state

# warning-ignore:unused_argument
func enter(prev : String) -> void:
	get_parent().get_parent().emit_signal("shotFired")
	yield(get_tree().create_timer(.08), "timeout")
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
