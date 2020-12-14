extends Node

export(String) var stateName = "State"

# warning-ignore:unused_signal
signal changeState

var stopped := false

# warning-ignore:unused_argument
func enter(prev):
	get_parent().get_parent().animationPlayer.play("BoltRelease")
	
	#from magazine in
	pass

func exit():
	#to ready
	pass

func stop():
	stopped = true

func resume():
	stopped = false
	get_parent().get_parent().animationPlayer.play("BoltRelease")

# warning-ignore:unused_argument
func process(delta):
	pass

# warning-ignore:unused_argument
func unhandled_input(event):
	pass

func anim_finished(anim : String) -> void:
	call_deferred("emit_signal", "changeState", "Ready")
