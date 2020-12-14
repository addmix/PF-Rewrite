extends Node

export(String) var stateName = "State"

# warning-ignore:unused_signal
signal changeState

var stopped := false

# warning-ignore:unused_argument
func enter(prev):
	get_parent().get_parent().animationPlayer.play("MagazineIn")
	
	#from magazine out
	pass

func exit():
	#to bolt release
	pass

func stop():
	stopped = true

func resume():
	stopped = false
	get_parent().get_parent().animationPlayer.play("MagazineIn")

# warning-ignore:unused_argument
func process(delta):
	pass

# warning-ignore:unused_argument
func unhandled_input(event):
	pass

func anim_finished(anim : String) -> void:
	get_parent().get_parent().set_magazine(get_parent().get_parent().magazineCapacity)
	
	#negative ammo bug here
	get_parent().get_parent().set_reserve(get_parent().get_parent().get_reserve() - get_parent().get_parent().magazineCapacity)
	
	if get_parent().gunMachine.currentState == "Locked":
		call_deferred("emit_signal", "changeState", "BoltRelease")
	else:
		call_deferred("emit_signal", "changeState", "Ready")
		get_parent().get_parent().animationPlayer.play("Return")
