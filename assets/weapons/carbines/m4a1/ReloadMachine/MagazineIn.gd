extends Node

export(String) var stateName = "State"

# warning-ignore:unused_signal
signal changeState

var stopped := false

# warning-ignore:unused_argument
func enter(prev : String) -> void:
	get_parent().get_parent()._AnimationPlayer.play("MagazineIn")
	
	#from magazine out
	pass

func exit() -> void:
	#to bolt release
	pass

func stop() -> void:
	stopped = true

func resume() -> void:
	stopped = false
	get_parent().get_parent()._AnimationPlayer.play("MagazineIn")

# warning-ignore:unused_argument
func process(delta : float) -> void:
	pass

# warning-ignore:unused_argument
func unhandled_input(event : InputEvent) -> void:
	pass

func anim_finished(anim : String) -> void:
	get_parent().get_parent().set_magazine(get_parent().get_parent().data["Misc"]["Magazine"])
	
	#negative ammo bug here
	get_parent().get_parent().set_reserve(get_parent().get_parent().get_reserve() - get_parent().get_parent().data["Misc"]["Magazine"])
	
	if get_parent().gunMachine.currentState == "Locked":
		call_deferred("emit_signal", "changeState", "BoltRelease")
	else:
		call_deferred("emit_signal", "changeState", "Ready")
		get_parent().get_parent()._AnimationPlayer.play("Return")
