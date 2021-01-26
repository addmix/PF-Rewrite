extends Node

signal change_state
signal entered
signal exited
signal finished

func enter() -> void:
	
	#pos
	get_parent().EquipPosSpring.target = Vector3.ZERO
	get_parent().EquipPosSpring.position = get_parent().get_parent().data["Weapon handling"]["Equip pos"]
	get_parent().EquipPosSpring.speed = get_parent().get_parent().data["Weapon handling"]["Equip s"]
	get_parent().EquipPosSpring.damper = get_parent().get_parent().data["Weapon handling"]["Equip d"]
	#rot
	get_parent().EquipRotSpring.target = Vector3.ZERO
	get_parent().EquipRotSpring.position = get_parent().get_parent().data["Weapon handling"]["Equip rot"]
	get_parent().EquipRotSpring.speed = get_parent().get_parent().data["Weapon handling"]["Equip s"]
	get_parent().EquipRotSpring.damper = get_parent().get_parent().data["Weapon handling"]["Equip d"]
	
	emit_signal("entered")
	emit_signal("finished")

func exit() -> void:
	emit_signal("exited")

func process(delta : float) -> void:
	get_parent().EquipPosSpring.positionvelocity(delta)
	get_parent().EquipRotSpring.positionvelocity(delta)
	
	if get_parent().EquipPosSpring.position.length() < 0.1 and get_parent().EquipRotSpring.position.length() < 0.1:
		emit_signal("change_state", "Idle")
		get_parent().emit_signal("equipped")

# warning-ignore:unused_argument
func unhandled_input(event : InputEvent) -> void:
	pass
