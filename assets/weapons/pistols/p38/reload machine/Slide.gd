extends Node

# warning-ignore:unused_signal
signal change_state
var stopped := false
func enter() -> void:
	call_deferred("emit_signal", "change_state", "Ready")
	#release
	get_parent().get_parent().GunMachine.find_node("Locked").call_deferred("release")

func exit() -> void:
	pass

# warning-ignore:unused_argument
func process(delta : float) -> void:
	pass

func resume() -> void:
	call_deferred("emit_signal", "change_state", "Ready")

# warning-ignore:unused_argument
func unhandled_input(event : InputEvent) -> void:
	pass

# warning-ignore:unused_argument
func anim_finished(anim : String) -> void:
	pass
