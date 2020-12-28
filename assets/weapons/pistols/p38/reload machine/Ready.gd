extends Node

signal change_state
var stopped := true

func enter() -> void:
	pass

func exit() -> void:
	pass

func process(delta : float) -> void:
	pass

func resume() -> void:
	call_deferred("emit_signal", "change_state", "MagazineOut")

func unhandled_input(event : InputEvent) -> void:
	pass

func anim_finished(anim : String) -> void:
	pass
