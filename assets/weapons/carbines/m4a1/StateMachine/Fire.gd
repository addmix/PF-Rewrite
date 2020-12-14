extends Node

export(String) var stateName = "State"

# warning-ignore:unused_signal
signal changeState

# warning-ignore:unused_argument
func enter(prev):
	yield(get_tree().create_timer(.08), "timeout")
	call_deferred("emit_signal", "changeState", "Back")

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
