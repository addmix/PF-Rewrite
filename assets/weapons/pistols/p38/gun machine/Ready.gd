extends Node

signal change_state

func enter() -> void:
	pass

func exit() -> void:
	pass

func process(delta : float) -> void:
	pass

func unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		emit_signal("change_state", "Fire")
		get_tree().set_input_as_handled()
