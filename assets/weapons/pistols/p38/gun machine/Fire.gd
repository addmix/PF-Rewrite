extends Node

signal change_state

func enter() -> void:
	if get_parent().get_parent().chamber > 0:
		get_parent().get_parent().emit_signal("shotFired")
		yield(get_tree().create_timer(.08), "timeout")
		call_deferred("emit_signal", "change_state", "Back")
		

func exit() -> void:
	pass

func process(delta : float) -> void:
	pass

func unhandled_input(event : InputEvent) -> void:
	pass
