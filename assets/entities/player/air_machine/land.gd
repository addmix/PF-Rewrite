extends Node

signal change_state
var character : KinematicBody

func enter() -> void:
	#do a cooldown
	call_deferred("emit_signal", "change_state", "Ground")

func exit() -> void:
	pass

func unhandled_input(event : InputEvent) -> void:
	pass

func process(delta : float) -> void:
	pass
