extends Node

export(String) var stateName = "State"

# warning-ignore:unused_signal
signal change_state

var stopped := false

# warning-ignore:unused_argument
func enter(prev: String) -> void:
	get_parent().get_parent()._AnimationPlayer.play("BoltRelease", 0.3)
	
	#from magazine in
	pass

func exit() -> void:
	#to ready
	pass

func stop() -> void:
	stopped = true

func resume() -> void:
	stopped = false
	get_parent().get_parent()._AnimationPlayer.play("BoltRelease", 0.3)

# warning-ignore:unused_argument
func process(delta : float) -> void:
	pass

# warning-ignore:unused_argument
func unhandled_input(event : InputEvent) -> void:
	pass

# warning-ignore:unused_argument
func anim_finished(anim : String) -> void:
	call_deferred("emit_signal", "change_state", "Ready")
