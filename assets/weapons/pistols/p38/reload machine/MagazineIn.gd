extends Node

# warning-ignore:unused_signal
signal change_state
var stopped := false
func enter(prev : String) -> void:
	get_parent().get_parent()._AnimationPlayer.play("MagazineIn", 0.3)

func exit() -> void:
	pass

func stop() -> void:
	pass

func resume() -> void:
	stopped = false
	get_parent().get_parent()._AnimationPlayer.play("MagazineIn", 0.5)

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
	
	if get_parent().get_parent().GunMachine.current_state == "Locked":
		call_deferred("emit_signal", "change_state", "Slide")
	else:
		call_deferred("emit_signal", "change_state", "Ready")
