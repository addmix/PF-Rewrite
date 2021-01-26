extends Node

export(String) var stateName = "State"

# warning-ignore:unused_signal
signal change_state

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

func changeFiremode() -> void:
	emit_signal("change_state", "Auto")

func unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		get_parent().emit_signal("fire")
		get_tree().set_input_as_handled()

func onReset() -> void:
	pass
