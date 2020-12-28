extends Node

signal change_state
var stopped := false
func enter() -> void:
	#move ammo from magazine to reserve
	get_parent().get_parent().set_reserve(get_parent().get_parent().get_reserve() + get_parent().get_parent().get_magazine())
	
	#set magazine to 0
	get_parent().get_parent().set_magazine(0)
	call_deferred("emit_signal", "change_state", "MagazineIn")

func exit() -> void:
	pass

func process(delta : float) -> void:
	pass

func resume() -> void:
	call_deferred("emit_signal", "change_state", "MagazineIn")

func unhandled_input(event : InputEvent) -> void:
	pass

func anim_finished(anim : String) -> void:
	pass
