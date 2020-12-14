extends Node

export(String) var stateName = "State"

# warning-ignore:unused_signal
signal changeState

var stopped := true

# warning-ignore:unused_argument
func enter(prev):
	pass

func exit():
	pass

func stop():
	pass

func resume():
	emit_signal("changeState", "MagazineOut")

# warning-ignore:unused_argument
func process(delta):
	pass

func unhandled_input(event):
	pass

func anim_finished(anim : String) -> void:
	stopped = true
