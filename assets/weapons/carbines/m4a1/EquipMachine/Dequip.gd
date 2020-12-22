extends Node

signal change_state
signal entered
signal exited
signal finished

func enter() -> void:
	#set spring values
	get_parent().EquipPositionSpring.target = get_parent().get_parent().data["Weapon handling"]["Dequip position"]
	get_parent().EquipRotationSpring.target = get_parent().get_parent().data["Weapon handling"]["Dequip rotation"]
	get_parent().EquipPositionSpring.speed = get_parent().get_parent().data["Weapon handling"]["Dequip translation speed"]
	get_parent().EquipPositionSpring.damper = get_parent().get_parent().data["Weapon handling"]["Dequip translation damping"]
	get_parent().EquipRotationSpring.speed = get_parent().get_parent().data["Weapon handling"]["Dequip rotation speed"]
	get_parent().EquipRotationSpring.damper = get_parent().get_parent().data["Weapon handling"]["Dequip rotation damping"]
	
	emit_signal("entered")
	

func exit() -> void:
	emit_signal("exited")

func process(delta : float) -> void:
	get_parent().EquipPositionSpring.positionvelocity(delta)
	get_parent().EquipRotationSpring.positionvelocity(delta)
	
	if((get_parent().EquipPositionSpring.position - get_parent().get_parent().data["Weapon handling"]["Dequip position"]).length() < 0.001 and (get_parent().EquipRotationSpring.position - get_parent().get_parent().data["Weapon handling"]["Dequip rotation"]).length() < 0.001):
		get_parent().emit_signal("dequipped")
		

func unhandled_input(event : InputEvent) -> void:
	pass
