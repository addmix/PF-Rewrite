extends Node

# warning-ignore:unused_signal
signal change_state
signal entered
signal exited
# warning-ignore:unused_signal
signal finished

func enter() -> void:
	get_parent().get_parent().get_parent().Equip = false
	get_parent().get_parent().get_parent().Dequip = true
	#set spring values
	get_parent().EquipPosSpring.target = get_parent().get_parent().data["Weapon handling"]["Dequip pos"]
	get_parent().EquipPosSpring.speed = get_parent().get_parent().data["Weapon handling"]["Dequip s"]
	get_parent().EquipPosSpring.damper = get_parent().get_parent().data["Weapon handling"]["Dequip d"]
	
	get_parent().EquipRotSpring.target = get_parent().get_parent().data["Weapon handling"]["Dequip rot"]
	get_parent().EquipRotSpring.speed = get_parent().get_parent().data["Weapon handling"]["Dequip s"]
	get_parent().EquipRotSpring.damper = get_parent().get_parent().data["Weapon handling"]["Dequip d"]
	
	emit_signal("entered")
	

func exit() -> void:
	emit_signal("exited")

func process(delta : float) -> void:
	get_parent().EquipPosSpring.positionvelocity(delta)
	get_parent().EquipRotSpring.positionvelocity(delta)
	
	if (get_parent().EquipPosSpring.position - get_parent().get_parent().data["Weapon handling"]["Dequip pos"]).length() < 0.001 and (get_parent().EquipRotSpring.position - get_parent().get_parent().data["Weapon handling"]["Dequip rot"]).length() < 0.001:
		get_parent().emit_signal("dequipped")
		

# warning-ignore:unused_argument
func unhandled_input(event : InputEvent) -> void:
	pass
