extends Node

signal change_state
signal entered
signal exited
signal finished

func enter() -> void:
	get_parent().EquipPositionSpring.target = Vector3.ZERO
	get_parent().EquipRotationSpring.target = Vector3.ZERO
	
	emit_signal("entered")
#	yield()

func exit() -> void:
	emit_signal("exited")
#	yield()

func process(delta : float) -> void:
	pass

func unhandled_input(event : InputEvent) -> void:
	pass
