extends Node

export(String) var stateName = "State"

# warning-ignore:unused_signal
signal change_state

var stopped := true

# warning-ignore:unused_argument
func enter(prev : String) -> void:
	get_parent().get_parent()._AnimationPlayer.play("Return", 0.4)

func exit() -> void:
	pass

func stop() -> void:
	pass

func resume() -> void:
	emit_signal("change_state", "MagazineOut")

# warning-ignore:unused_argument
func process(delta : float) -> void:
	pass

# warning-ignore:unused_argument
func unhandled_input(event : InputEvent) -> void:
	pass

# warning-ignore:unused_argument
func anim_finished(anim : String) -> void:
	stopped = true
