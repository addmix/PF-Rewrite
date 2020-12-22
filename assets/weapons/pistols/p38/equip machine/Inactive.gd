extends Node

signal change_state
signal entered
signal exited
signal finished

func enter() -> void:
	emit_signal("entered")
	

func exit() -> void:
	emit_signal("exited")
	

func process(delta : float) -> void:
	pass

func unhandled_input(event : InputEvent) -> void:
	pass
