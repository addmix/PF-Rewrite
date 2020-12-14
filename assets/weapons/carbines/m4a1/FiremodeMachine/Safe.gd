extends Node

export(String) var stateName = "State"

# warning-ignore:unused_signal
signal changeState

# warning-ignore:unused_argument
func enter(prev):
	pass

func exit():
	pass

# warning-ignore:unused_argument
func process(delta):
	pass

# warning-ignore:unused_argument
func unhandled_input(event):
	pass

func changeFiremode():
	emit_signal("changeState", "Auto")
