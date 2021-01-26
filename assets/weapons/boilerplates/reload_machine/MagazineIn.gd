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

# warning-ignore:unused_argument
func anim_finished(anim : String) -> void:
	var step = get_parent().get_parent().get_reserve() - get_parent().get_parent().data["Misc"]["Magazine"]
	if step < 0:
		get_parent().get_parent().set_reserve(0)
		get_parent().get_parent().set_magazine(get_parent().get_parent().data["Misc"]["Magazine"] - abs(step))
	else:
		get_parent().get_parent().set_reserve(step)
		get_parent().get_parent().set_magazine(get_parent().get_parent().data["Misc"]["Magazine"])
	
	if get_parent().gunMachine.current_state == "Locked":
		call_deferred("emit_signal", "changeState", "BoltRelease")
	else:
		call_deferred("emit_signal", "changeState", "Ready")
		get_parent().get_parent()._AnimationPlayer.play("Return")
