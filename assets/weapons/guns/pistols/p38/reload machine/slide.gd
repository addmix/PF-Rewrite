extends Node

# warning-ignore:unused_signal
signal change_state
var stopped := false
# warning-ignore:unused_argument
func enter(prev : String) -> void:
	get_parent().get_parent()._AnimationPlayer.play("Slide", 0.3)

func exit() -> void:
	pass

func stop() -> void:
	stopped = true

# warning-ignore:unused_argument
func process(delta : float) -> void:
	pass

func resume() -> void:
	stopped = false
	get_parent().get_parent()._AnimationPlayer.play("Slide", 0.3)

# warning-ignore:unused_argument
func unhandled_input(event : InputEvent) -> void:
	pass

# warning-ignore:unused_argument
func anim_finished(anim : String) -> void:
	call_deferred("emit_signal", "change_state", "Ready")
	#release
	if get_parent().get_parent().GunMachine.current_state == "Locked":
		get_parent().get_parent().GunMachine.states["Locked"].call_deferred("release")
	else:
		get_parent().get_parent().GunMachine.call_deferred("emit_signal", "change_state", "Forward")
