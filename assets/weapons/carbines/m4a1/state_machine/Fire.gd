extends Node

export(String) var stateName = "State"

# warning-ignore:unused_signal
signal changeState

# warning-ignore:unused_argument
func enter(prev : String) -> void:
	get_parent().get_parent().emit_signal("shotFired")
	yield(get_tree().create_timer(.08), "timeout")
	call_deferred("emit_signal", "changeState", "Back")

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
