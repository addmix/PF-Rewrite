extends Node

signal change_state

func enter() -> void:
	get_parent().get_parent().set_magazine(get_parent().get_parent().get_magazine() - 1)
	get_parent().get_parent().set_chamber(get_parent().get_parent().get_chamber() + 1)
	call_deferred("emit_signal", "change_state", "Ready")

func exit() -> void:
	pass

func process(delta : float) -> void:
	pass

func unhandled_input(event : InputEvent) -> void:
	pass
