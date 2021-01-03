extends Node

# warning-ignore:unused_signal
signal change_state
var stopped := true

func enter() -> void:
	pass

func exit() -> void:
	pass

# warning-ignore:unused_argument
func process(delta : float) -> void:
	pass

func resume() -> void:
	call_deferred("emit_signal", "change_state", "MagazineOut")

# warning-ignore:unused_argument
func unhandled_input(event : InputEvent) -> void:
	pass

# warning-ignore:unused_argument
func anim_finished(anim : String) -> void:
	pass
