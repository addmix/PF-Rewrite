extends Node

signal change_state

func enter() -> void:
	pass
#	release()

func exit() -> void:
	pass

func process(delta : float) -> void:
	pass

func unhandled_input(event : InputEvent) -> void:
	pass

func release() -> void:
	call_deferred("emit_signal", "change_state", "Forward")
