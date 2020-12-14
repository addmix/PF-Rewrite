extends Node

export(String) var stateName = "State"

# warning-ignore:unused_signal
signal changeState

func release():
	call_deferred("emit_signal", "changeState", "Forward")

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

# warning-ignore:unused_argument
func unhandled_input(event):
	pass

func fire():
	pass
