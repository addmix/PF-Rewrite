extends Node

export(String) var stateName = "State"

# warning-ignore:unused_signal
signal changeState
signal reset

# warning-ignore:unused_argument
func enter(prev):
	call_deferred("emit_signal", "reset")

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
	if get_parent().currentState == stateName:
		emit_signal("changeState", "Fire")
		get_parent().get_parent().emit_signal("fire")
	pass # Replace with function body.
