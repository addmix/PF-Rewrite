extends Node

export(String) var stateName = "State"

# warning-ignore:unused_signal
signal changeState

# warning-ignore:unused_argument
func enter(prev : String) -> void:
	get_parent().get_parent().set_magazine(get_parent().get_parent().get_magazine() - 1)
	get_parent().get_parent().set_chamber(get_parent().get_parent().get_chamber() + 1)
	call_deferred("emit_signal", "changeState", "Ready")

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
