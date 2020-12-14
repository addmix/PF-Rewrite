extends Node

export(String) var stateName = "State"

# warning-ignore:unused_signal
signal changeState

# warning-ignore:unused_argument
func enter(prev):
	pass

func exit():
	pass

func stop():
	pass

# warning-ignore:unused_argument
func process(delta):
	pass

func changeFiremode():
	emit_signal("changeState", "Auto")

func unhandled_input(event):
	if event.is_action_pressed("Shoot"):
		get_parent().emit_signal("fire")
		get_tree().set_input_as_handled()

func onReset():
	pass
