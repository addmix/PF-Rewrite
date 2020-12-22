extends Node

signal change_state
signal entered
signal exited
signal finished

func enter() -> void:
	#set spring values
	get_parent().EquipPositionSpring.target = Vector3.ZERO
	get_parent().EquipRotationSpring.target = Vector3.ZERO
	get_parent().EquipPositionSpring.position = get_parent().get_parent().data["Weapon handling"]["Equip position"]
	get_parent().EquipRotationSpring.position = get_parent().get_parent().data["Weapon handling"]["Equip rotation"]
	get_parent().EquipPositionSpring.speed = get_parent().get_parent().data["Weapon handling"]["Equip translation speed"]
	get_parent().EquipPositionSpring.damper = get_parent().get_parent().data["Weapon handling"]["Equip translation damping"]
	get_parent().EquipRotationSpring.speed = get_parent().get_parent().data["Weapon handling"]["Equip rotation speed"]
	get_parent().EquipRotationSpring.damper = get_parent().get_parent().data["Weapon handling"]["Equip rotation damping"]
	
	emit_signal("entered")
	
	emit_signal("finished")

func exit() -> void:
	emit_signal("exited")

func process(delta : float) -> void:
	get_parent().EquipPositionSpring.positionvelocity(delta)
	get_parent().EquipRotationSpring.positionvelocity(delta)
	
	if (get_parent().EquipPositionSpring.position.length() < 0.001 and get_parent().EquipRotationSpring.position.length() < 0.001):
		emit_signal("change_state", "Idle")

func unhandled_input(event : InputEvent) -> void:
	pass
