extends Node

export(String) var stateName = "State"

# warning-ignore:unused_signal
signal changeState

var stopped := false

# warning-ignore:unused_argument
func enter(prev):
	get_parent().get_parent().animationPlayer.play("MagazineOut")
	
	
	#from ready
	pass

func exit():
	#to magazine in
	pass

func stop():
	stopped = true

func resume():
	stopped = false
	get_parent().get_parent().animationPlayer.play("MagazineOut")


# warning-ignore:unused_argument
func process(delta):
	pass

# warning-ignore:unused_argument
func unhandled_input(event):
	pass

func anim_finished(anim : String) -> void:
	get_parent().get_parent().set_reserve(get_parent().get_parent().get_reserve() + get_parent().get_parent().get_magazine())
	get_parent().get_parent().set_magazine(0)
	
	call_deferred("emit_signal", "changeState", "MagazineIn")
