extends Node

signal change_state
var stopped := false
func enter() -> void:
	call_deferred("emit_signal", "change_state", "Ready")
	#release
	get_parent().get_parent().GunMachine.find_node("Locked").call_deferred("release")

func exit() -> void:
	pass

func process(delta : float) -> void:
	pass

func resume() -> void:
	call_deferred("emit_signal", "change_state", "Ready")

func unhandled_input(event : InputEvent) -> void:
	pass

func anim_finished(anim : String) -> void:
	pass
